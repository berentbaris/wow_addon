----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Requirements Panel
--
-- A persistent, dockable panel that shows the selected enhanced
-- class's full requirement list, with level-gated items greyed out
-- and currently-active items lit up.
--
-- Opens via:
--   * /hce panel  (toggle)
--   * /hce req    (toggle, alias)
--   * the draggable minimap button
--
-- Auto-refreshes on PLAYER_LEVEL_UP and when the selection changes.
--
-- Layout:
--   +------------------------------------------+
--   | Mountain King               [ pin ] [X]  |
--   |  Protection Warrior · lv 14 / 60         |
--   |------------------------------------------|
--   |  3 / 7 requirements active               |
--   |------------------------------------------|
--   |  EQUIPMENT                               |
--   |  [ACTIVE] Mace or axe                    |
--   |  [lv 5]   Shield                         |
--   |  [lv 50]  Flask trinkets                 |
--   |                                          |
--   |  CHALLENGES                              |
--   |  [ACTIVE] No professions                 |
--   |  [lv 20]  Homebound                      |
--   |      Can't leave home continent          |
--   |                                          |
--   |  COMPANION · PET · MOUNT                 |
--   |  ...                                     |
--   +------------------------------------------+
----------------------------------------------------------------------

HCE = HCE or {}

local Panel = {}
HCE.Panel   = Panel

----------------------------------------------------------------------
-- Constants / visual config
----------------------------------------------------------------------

local FRAME_WIDTH   = 320
local FRAME_HEIGHT  = 440
local ROW_HEIGHT    = 16
local SECTION_GAP   = 8
local PAD_X         = 14
local PAD_Y         = 10

local COLOR_ACTIVE   = { r = 0.30, g = 0.90, b = 0.35 }
local COLOR_INACTIVE = { r = 0.55, g = 0.55, b = 0.55 }
local COLOR_HEADER   = { r = 1.00, g = 0.78, b = 0.10 }
local COLOR_SUBTXT   = { r = 0.75, g = 0.75, b = 0.75 }
local COLOR_PASS     = { r = 0.30, g = 0.90, b = 0.35 }   -- green checkmark
local COLOR_FAIL     = { r = 1.00, g = 0.35, b = 0.30 }   -- red cross
local COLOR_UNCHK    = { r = 0.65, g = 0.65, b = 0.50 }   -- muted amber

local CLASS_COLORS = {
    WARRIOR = "c79c6e", ROGUE   = "fff569", MAGE    = "69ccf0",
    WARLOCK = "9482c9", PRIEST  = "ffffff", PALADIN = "f58cba",
    DRUID   = "ff7d0a", SHAMAN  = "0070de", HUNTER  = "abd473",
}

local function classColor(c)
    return CLASS_COLORS[c or ""] or "ffd100"
end

local function titleCase(s)
    if not s or s == "" then return "" end
    return s:sub(1, 1):upper() .. s:sub(2):lower()
end

-- Returns nil (white/default) when active, COLOR_INACTIVE when not.
-- Can't use "active and nil or COLOR_INACTIVE" because nil is falsy in Lua.
local function activeTextColor(isActive)
    if isActive then return nil end
    return COLOR_INACTIVE
end

----------------------------------------------------------------------
-- Global DB defaults for panel persistence
----------------------------------------------------------------------

local function db()
    HCE_GlobalDB = HCE_GlobalDB or {}
    HCE_GlobalDB.panel = HCE_GlobalDB.panel or {
        shown       = false,     -- visible on login if true
        locked      = false,     -- lock position (disables drag)
        point       = "CENTER",
        relPoint    = "CENTER",
        x           = 0,
        y           = 0,
        minimap     = { angle = 215, hide = false },
    }
    return HCE_GlobalDB.panel
end

----------------------------------------------------------------------
-- Main frame
----------------------------------------------------------------------

local frame          -- the panel itself
local contentFrame   -- child holding the row fontstrings (scroll child)
local scrollFrame
local rowPool = {}
local headerLabel, subLabel
local pinButton
local closeButton

local function acquireRow(index)
    local row = rowPool[index]
    if row then return row end

    row = CreateFrame("Frame", nil, contentFrame)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("LEFT", contentFrame, "LEFT", 0, 0)
    row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)
    row:EnableMouse(true)

    row.tag = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.tag:SetPoint("TOPLEFT", row, "TOPLEFT", 2, 0)
    row.tag:SetWidth(50)
    row.tag:SetJustifyH("LEFT")

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 2, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(true)

    -- Hover highlight for interactive rows (manually shown/hidden via
    -- OnEnter/OnLeave — we use ARTWORK not HIGHLIGHT so WoW doesn't
    -- auto-show it on every mouse-enabled row)
    row.highlight = row:CreateTexture(nil, "ARTWORK", nil, 7)
    row.highlight:SetColorTexture(0.85, 0.70, 0.20, 0.08)
    row.highlight:SetAllPoints()
    row.highlight:Hide()

    rowPool[index] = row
    return row
end

local function clearRowTooltip(row)
    row.challengeKey = nil
    row.challengeLevel = nil
    row.challengeActive = nil
    row.equipDetail = nil
    row.equipStatus = nil
    row.curatedKey = nil
    row.companionKey = nil
    row.selfFoundTip = nil
    row.highlight:Hide()
    row:SetScript("OnEnter", nil)
    row:SetScript("OnLeave", nil)
end

local function releaseExtraRows(used)
    for i = used + 1, #rowPool do
        clearRowTooltip(rowPool[i])
        rowPool[i]:Hide()
    end
end

----------------------------------------------------------------------
-- Tooltip for challenge rows
----------------------------------------------------------------------

-- Challenges that get item forgiveness at rank milestones
local FORGIVABLE_TOOLTIP = {
    ["Exotic"]        = true,
    ["Scout"]         = true,
    ["Scavenger"]     = true,
    ["Partisan"]      = true,
    ["Self-made"]     = true,
    ["Cloth/leather"] = true,
    ["Leather/mail"]  = true,
    ["Mail/plate"]    = true,
    ["Expeditionary"]    = true,
}

local PERMA_CHALLENGE_TOOLTIP = {
    ["No nonsense"]        = true,
    ["Imp"]         = true,
    ["Voidwalker"]     = true,
    ["Lone Wolf"]      = true,
    ["No demons"]     = true,
    ["Ephemeral"] = true,
    ["Drifter"]  = true,
    ["Mortal pets"]    = true,
    ["Pyromancer"]  = true,
    ["Light of Elune"]  = true,
    ["All-out Assault"]  = true,
    ["Truecaster"]  = true,
    ["Windfury Weapon"]  = true,
    ["Rockbiter Weapon"]  = true,
    ["Crude"]  = true,
    ["Overt"]  = true,
    ["Shadow Ascendant"]  = true,
    ["Self-taught"]  = true,
}

-- Get the player's current rank name, hex color, and number of allowed violations.
local function getCurrentRankAndAllowed()
    if not HCE.Progress or not HCE.Progress.Collect or not HCE.Progress.Percentage or not HCE.Progress.GetRank then
        return "Initiate", "ffffff", 0
    end
    local summary = HCE.Progress.Collect()
    if not summary or not summary.counts then return "Initiate", "ffffff", 0 end
    local pct = HCE.Progress.Percentage(summary.counts)
    local rank, color = HCE.Progress.GetRank(pct)
    local allowed = 0
    if pct >= 100 then allowed = 999
    elseif pct >= 75 then allowed = 3
    elseif pct >= 50 then allowed = 2
    elseif pct >= 25 then allowed = 1
    end
    return rank, color, allowed
end

local function onChallengeRowEnter(self)
    local key = self.challengeKey
    if not key then return end
    local desc = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[key]
    if not desc then return end

    self.highlight:Show()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 20, 0)
    GameTooltip:ClearLines()

    -- Title line in gold
    GameTooltip:AddLine(key, 0.85, 0.70, 0.20)

    -- Status line
    if self.challengeActive then
        GameTooltip:AddLine("ACTIVE", 0.30, 0.90, 0.35)
    else
        GameTooltip:AddLine("Unlocks at level " .. tostring(self.challengeLevel or "?"), 0.55, 0.55, 0.55)
    end

    -- Separator
    GameTooltip:AddLine(" ")

    -- Full description, wrapped
    GameTooltip:AddLine(desc, 0.93, 0.93, 0.93, true)

    -- More info on Expeditionary
    if key == "Expeditionary" then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Group content items include dungeon boss drops and rewards from elite & dungeon quests.", 0.93, 0.93, 0.93, true)
    end

    -- Forgiveness info for eligible challenges
    if FORGIVABLE_TOOLTIP[key] then
        local curRank = getCurrentRankAndAllowed()
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Rank rewards:", 0.85, 0.70, 0.20)

        -- Tier table — highlight the player's current rank, dim the rest
        local tiers = {
            { rank = "Adept",  label = "Adept (25%)",   reward = "1 exemption",    r = 0.12, g = 1.0,  b = 0.0  },
            { rank = "Prime",  label = "Prime (50%)",   reward = "2 exemptions",   r = 0.0,  g = 0.44, b = 0.87 },
            { rank = "Elite",  label = "Elite (75%)",   reward = "3 exemptions",   r = 0.64, g = 0.21, b = 0.93 },
            { rank = "Master", label = "Master (100%)", reward = "All items exempt", r = 1.0,  g = 0.50, b = 0.0  },
        }
        for _, t in ipairs(tiers) do
            if t.rank == curRank then
                -- Current rank: bright colors + arrow marker
                GameTooltip:AddDoubleLine("> " .. t.label, t.reward, t.r, t.g, t.b, 1.0, 1.0, 1.0)
            else
                -- Other ranks: dimmed
                GameTooltip:AddDoubleLine("  " .. t.label, t.reward, 0.45, 0.45, 0.45, 0.45, 0.45, 0.45)
            end
        end

        -- Warrior/Paladin weapon restriction warning for Self-made
        if key == "Self-made" then
            local _, classToken = UnitClass("player")
            if classToken == "WARRIOR" or classToken == "PALADIN" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Exemptions cannot be used on weapons.", 1.0, 0.3, 0.3, true)
            end
        end

        -- Shoulder restriction warning for armor-type challenges
        if key == "Cloth/leather" or key == "Leather/mail" or key == "Mail/plate" then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Exemptions cannot be used on shoulders.", 1.0, 0.3, 0.3, true)
        end
    end

    -- reset info for eligible challenges
    if PERMA_CHALLENGE_TOOLTIP[key] then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("You can always reset this challenge by typing '/hce reset' in the chat.")
    end

    GameTooltip:Show()
end

local function onChallengeRowLeave(self)
    self.highlight:Hide()
    GameTooltip:Hide()
end

----------------------------------------------------------------------
-- Tooltip for equipment check rows
----------------------------------------------------------------------

local function onEquipRowEnter(self)
    local detail = self.equipDetail
    if not detail then return end

    self.highlight:Show()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8, 0)
    GameTooltip:ClearLines()

    local eqStatus = HCE.EquipmentCheck and HCE.EquipmentCheck.STATUS or {}
    if self.equipStatus == eqStatus.PASS then
        GameTooltip:AddLine("Requirement met", 0.30, 0.90, 0.35)
    elseif self.equipStatus == eqStatus.FAIL then
        GameTooltip:AddLine("Requirement not met", 1.00, 0.35, 0.30)
    else
        GameTooltip:AddLine("Cannot verify yet", 0.65, 0.65, 0.50)
    end

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(detail, 0.93, 0.93, 0.93, true)

    -- Self-found settings hint
    if self.selfFoundTip then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("If you want to play without the self-found restriction or outside of Hardcore realms, you can turn off this requirement in the addon settings.", 0.55, 0.80, 0.95, true)
    end

    -- Show companion accepted creatures if this is a companion row
    if self.companionKey then
        local db = HCE.CompanionCheck and HCE.CompanionCheck.CompanionDB
        local entry = db and db[self.companionKey]
        if entry then
            GameTooltip:AddLine(" ")
            local names = {}
            if entry.creatureNames then
                for n in pairs(entry.creatureNames) do
                    table.insert(names, n)
                end
                table.sort(names)
            end
            if #names > 0 then
                GameTooltip:AddLine("Accepted companions (" .. #names .. "):", 0.90, 0.78, 0.25)
                for _, n in ipairs(names) do
                    GameTooltip:AddLine("  " .. n, 0.75, 0.75, 0.70)
                end
            end
            if entry.notes then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(entry.notes, 0.55, 0.80, 0.95, true)
            end
        end
    end

    -- Show curated approved items if this row has a curated list
    local curatedKey = self.curatedKey
    if curatedKey then
        local items = HCE.CuratedItems and HCE.CuratedItems[curatedKey]
        if items then
            local count = 0
            for _ in pairs(items) do count = count + 1 end
            if count > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Approved items (" .. count .. "):", 0.90, 0.78, 0.25)
                for itemID, note in pairs(items) do
                    local displayName
                    if type(note) == "string" then
                        displayName = note
                    else
                        displayName = "Item #" .. itemID
                    end
                    GameTooltip:AddLine("  " .. displayName, 0.75, 0.75, 0.70)
                end
            end
        end
    end

    GameTooltip:Show()
end

local function onEquipRowLeave(self)
    self.highlight:Hide()
    GameTooltip:Hide()
end

--- Tag a row as a challenge row so it shows a tooltip on hover.
--- Call this AFTER emitRow for the challenge.
local function tagChallengeRow(rowIndex, challengeKey, level, isActive)
    local row = rowPool[rowIndex]
    if not row then return end
    row.challengeKey    = challengeKey
    row.challengeLevel  = level
    row.challengeActive = isActive
    row:SetScript("OnEnter", onChallengeRowEnter)
    row:SetScript("OnLeave", onChallengeRowLeave)
end

----------------------------------------------------------------------
-- Row emitters
----------------------------------------------------------------------

-- returns a "tag" string and a tag color for a level-gated requirement
local function tagFor(level, playerLevel)
    if playerLevel >= level then
        return "ACTIVE", COLOR_ACTIVE
    else
        return "lv " .. level, COLOR_INACTIVE
    end
end

-- Universal requirement tag: checks PASS/FAIL for ALL requirements (active or not).
--   PASS (active or inactive) -> "PASS" green
--   FAIL + active             -> "FAIL" red
--   FAIL + inactive           -> "lv X" gray
--   unchecked + active        -> "ACTIVE" green
--   unchecked + inactive      -> "lv X" gray
-- Returns: tag, tagColor, textColor
local function reqTag(level, endLevel, playerLevel, status)
    local superseded = endLevel and playerLevel > endLevel
    local isActive = (playerLevel >= level) and not superseded

    -- Normalise: all checkers use lowercase "pass"/"fail"/"unchecked"
    local st = status and status:lower() or nil

    if st == "pass" then
        return "PASS", COLOR_PASS, nil
    elseif st == "fail" then
        if isActive then
            return "FAIL", COLOR_FAIL, nil
        end
        -- Failing + inactive: just the level, gray
        if endLevel then
            return "lv " .. level .. "-" .. endLevel, COLOR_INACTIVE, COLOR_INACTIVE
        end
        return "lv " .. level, COLOR_INACTIVE, COLOR_INACTIVE
    end

    -- No result or unchecked
    if isActive then
        return "ACTIVE", COLOR_ACTIVE, nil
    end
    if endLevel then
        return "lv " .. level .. "-" .. endLevel, COLOR_INACTIVE, COLOR_INACTIVE
    end
    return "lv " .. level, COLOR_INACTIVE, COLOR_INACTIVE
end

-- Emit a single-line row.  Returns the next row index and accumulated height used
local function emitRow(index, yOffset, tagText, tagColor, text, textColor, indent)
    local row = acquireRow(index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", (indent or 0), -yOffset)
    row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)

    if tagText then
        row.tag:Show()
        row.tag:SetText(tagText)
        row.tag:SetTextColor(tagColor.r, tagColor.g, tagColor.b)
    else
        row.tag:Hide()
        row.tag:SetText("")
    end
    row.text:SetText(text or "")
    if textColor then
        row.text:SetTextColor(textColor.r, textColor.g, textColor.b)
    else
        row.text:SetTextColor(0.93, 0.93, 0.93)
    end

    row:Show()

    -- compute wrapped height so the next row lays out below the wrap
    local h = row.text:GetStringHeight()
    if h < ROW_HEIGHT then h = ROW_HEIGHT end
    row:SetHeight(h)

    return index + 1, yOffset + h + 2
end

local function emitSectionHeader(index, yOffset, title)
    yOffset = yOffset + SECTION_GAP
    local row = acquireRow(index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -yOffset)
    row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)
    row:SetHeight(ROW_HEIGHT)

    row.tag:Hide()
    row.text:SetText(title)
    row.text:SetTextColor(COLOR_HEADER.r, COLOR_HEADER.g, COLOR_HEADER.b)
    row.text:ClearAllPoints()
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row:Show()

    local nextIdx = index + 1
    -- separator line under the header
    if not row.separator then
        row.separator = row:CreateTexture(nil, "ARTWORK")
        row.separator:SetColorTexture(COLOR_HEADER.r, COLOR_HEADER.g, COLOR_HEADER.b, 0.35)
        row.separator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, -2)
        row.separator:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -2)
        row.separator:SetHeight(1)
    end
    row.separator:Show()
    return nextIdx, yOffset + ROW_HEIGHT + 4
end

----------------------------------------------------------------------
-- Rebuild contents
----------------------------------------------------------------------

function Panel.Refresh()
    if not frame or not frame:IsShown() then
        -- still update the header info so the next open is correct,
        -- but we don't need to rebuild rows while hidden
    end

    -- No frame yet? Nothing to do.
    if not frame then return end

    local key = HCE_CharDB and HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    local playerLevel = UnitLevel("player") or 1
    local _, classToken = UnitClass("player")

    -- Reset row state that SectionHeader may have added, and clear
    -- tooltip data from previous layout (rows are pooled and reused)
    for _, row in ipairs(rowPool) do
        if row.separator then row.separator:Hide() end
        row.text:ClearAllPoints()
        row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 4, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
        clearRowTooltip(row)
    end

    -- Header
    if char then
        local col = classColor(char.class)
        local displayName = HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
        headerLabel:SetText("|cff" .. col .. displayName .. "|r")
        subLabel:SetText(char.spec .. " " .. titleCase(char.class) .. " · lv " .. playerLevel .. " / 60")
        -- Art panel (docked to the left, full-opacity class portrait)
        if Panel._artFrame then
            local texPath = HCE.ClassBackgrounds and HCE.ClassBackgrounds[char.name]
            if not texPath and HCE.GetCharDisplayName then
                texPath = HCE.ClassBackgrounds and HCE.ClassBackgrounds[HCE.GetCharDisplayName(char)]
            end
            if texPath then
                Panel._artTex:SetTexture(texPath)
                Panel._artFrame:Show()
            else
                Panel._artFrame:Hide()
            end
        end
    else
        headerLabel:SetText("|cffffd100No enhanced class selected|r")
        subLabel:SetText("Type |cffffd100/hce pick|r to choose one")
        if Panel._artFrame then Panel._artFrame:Hide() end
    end

    -- Show/hide lore button (only for core-set characters)
    if Panel._loreButton then
        local isAdditional = char and HCE.AdditionalCharacters and HCE.AdditionalCharacters[char.name]
        if char and not isAdditional then
            Panel._loreButton:Show()
        else
            Panel._loreButton:Hide()
        end
    end

    local index  = 1
    local yOff   = 0

    if not char then
        local row = acquireRow(index)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -6)
        row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)
        row:SetHeight(ROW_HEIGHT * 3)
        row.tag:Hide()
        row.text:SetText("Open the selection window with |cffffd100/hce ui|r to pick an enhanced class for this character.")
        row.text:SetTextColor(COLOR_SUBTXT.r, COLOR_SUBTXT.g, COLOR_SUBTXT.b)
        row:Show()
        releaseExtraRows(1)
        contentFrame:SetHeight(ROW_HEIGHT * 3 + 12)
        return
    end

    -- Compute completion % and rank using ProgressSummary
    local summary = HCE.Progress and HCE.Progress.Collect and HCE.Progress.Collect()
    local pct = 0
    if summary and summary.counts then
        pct = HCE.Progress.Percentage(summary.counts)
        -- Check for rank changes
        HCE.Progress.CheckRankUp()
    end
    -- Progress bar (built once, updated each refresh)
    -- Anchored below the titleBar, fitting inside the progressSpacer region.
    if HCE.Progress and HCE.Progress.BuildBar then
        if not Panel._progressBar then
            Panel._progressBar = HCE.Progress.BuildBar(frame, Panel._titleBar, -4)
        end
        -- Defer the bar update slightly so all check modules have
        -- had time to write their results this frame
        C_Timer.After(0.05, function()
            if HCE.Progress.UpdateBar then HCE.Progress.UpdateBar() end
        end)
    end

    -- Race / gender / self-found summary row with PASS/FAIL tag
    local sfResults = HCE.SelfFoundCheck and HCE.SelfFoundCheck.GetResults() or {}
    local sfStatus  = HCE.SelfFoundCheck and HCE.SelfFoundCheck.STATUS or {}
    local sfEnabled = not HCE.SelfFoundEnabled or HCE.SelfFoundEnabled()
    local charSelfFound
    if HCE.GetCharSelfFound then charSelfFound = HCE.GetCharSelfFound(char) else charSelfFound = char.selfFound end

    -- Check race and gender against the player
    local playerRace = UnitRace("player") or ""
    local playerSex  = UnitSex("player")  -- 2=male, 3=female
    local playerGender = (playerSex == 3) and "Female" or "Male"
    local raceOk   = (char.race == "Any") or (playerRace == char.race)
    local genderOk = (char.gender == "Any") or (playerGender == char.gender)

    -- Determine self-found pass/fail (only counts if SF requirement exists and is enabled)
    local sfText = ""
    local sfPass = true  -- assume pass if no SF requirement
    if charSelfFound then
        if not sfEnabled then
            sfText = " · |cff888888self-found (disabled)|r"
            -- Disabled doesn't count as fail
        else
            sfText = " · self-found"
            local sfBuff = sfResults.selfFound
            if sfBuff then
                if sfBuff.status == sfStatus.PASS then
                    sfPass = true
                elseif sfBuff.status == sfStatus.FAIL then
                    sfPass = false
                else
                    sfPass = true  -- unchecked: don't penalise
                end
            end
        end
    elseif charSelfFound == false then
        sfText = " · not self-found"
        local nsfResult = sfResults.notSelfFound
        if nsfResult then
            if nsfResult.status == sfStatus.PASS then
                sfPass = true
            elseif nsfResult.status == sfStatus.FAIL then
                sfPass = false
            else
                sfPass = true
            end
        end
    end

    -- Overall row tag
    local rowPass = raceOk and genderOk and sfPass
    local rowTag, rowTagCol
    if rowPass then
        rowTag = "PASS"
        rowTagCol = COLOR_PASS
    else
        rowTag = "FAIL"
        rowTagCol = COLOR_FAIL
    end
    index, yOff = emitRow(index, yOff, rowTag, rowTagCol,
        char.race .. " · " .. char.gender .. sfText, nil)
    -- Tag row for tooltip on hover (race/gender/self-found details)
    do
        local row = rowPool[index - 1]
        if row then
            -- Build tooltip text covering all parts of this row
            local lines = {}
            if not raceOk then
                lines[#lines+1] = "Race mismatch: you are " .. playerRace .. ", requires " .. char.race .. "."
            end
            if not genderOk then
                lines[#lines+1] = "Gender mismatch: you are " .. playerGender .. ", requires " .. char.gender .. "."
            end
            if charSelfFound then
                if sfEnabled then
                    local sfBuff = sfResults.selfFound
                    if sfBuff and sfBuff.detail then
                        lines[#lines+1] = sfBuff.detail
                    end
                else
                    lines[#lines+1] = "Self-found tracking is disabled in addon settings."
                end
            elseif charSelfFound == false then
                local nsfResult = sfResults.notSelfFound
                if nsfResult and nsfResult.detail then
                    lines[#lines+1] = nsfResult.detail
                else
                    lines[#lines+1] = "This character must NOT be self-found (requires AH/trade access)."
                end
            end
            if #lines > 0 then
                row.equipDetail = table.concat(lines, "\n")
                row.equipStatus = rowPass and "pass" or "fail"
                row:SetScript("OnEnter", onEquipRowEnter)
                row:SetScript("OnLeave", onEquipRowLeave)
            end
        end
    end

    -- Challenges section (with tracking from ChallengeCheck + SelfFoundCheck)
    local chResults = HCE.ChallengeCheck and HCE.ChallengeCheck.GetResults() or {}
    local chStatus  = HCE.ChallengeCheck and HCE.ChallengeCheck.STATUS or {}
    if char.challenges and #char.challenges > 0 then
        -- Determine which challenges are excluded by easy mode
        local easyExclude = {}
        if HCE.EasyModeEnabled and HCE.EasyModeEnabled() then
            easyExclude = (HCE.EasyModeExclusions and HCE.EasyModeExclusions[char.name]) or {}
        end
        -- Check if we have any non-excluded challenges to show
        local hasVisible = false
        for _, ch in ipairs(char.challenges) do
            if not easyExclude[ch.desc] then hasVisible = true; break end
        end
        if hasVisible then
            index, yOff = emitSectionHeader(index, yOff, "CHALLENGES")
        end
        for i, ch in ipairs(char.challenges) do
            -- Skip challenges excluded by easy mode
            if easyExclude[ch.desc] then
                -- do nothing, challenge is hidden
            else
            local isActive = (playerLevel >= ch.level) and not (ch.endLevel and playerLevel > ch.endLevel)
            local checkResult = chResults[i]
            local tag, col, txtCol = reqTag(ch.level, ch.endLevel, playerLevel,
                checkResult and checkResult.status or nil)

            -- Add forgiveness rank label for forgivable challenges
            local forgiveSuffix = ""
            if isActive and FORGIVABLE_TOOLTIP[ch.desc] then
                local curRank, rankCol, allowed = getCurrentRankAndAllowed()
                if allowed >= 999 then
                    forgiveSuffix = " |cff888888(|cff" .. rankCol .. "Master|r|cff888888: all exempt)|r"
                else
                    local word = allowed == 1 and "item" or "items"
                    forgiveSuffix = " |cff888888(|cff" .. rankCol .. curRank .. "|r|cff888888: " .. allowed .. " exemptions)|r"
                end
            end

            index, yOff = emitRow(index, yOff, tag, col, ch.desc .. forgiveSuffix, txtCol)
            -- Tag this row for hover tooltip (index-1 because emitRow already incremented)
            tagChallengeRow(index - 1, ch.desc, ch.level, isActive)

            -- Check if this challenge is excludable by easy mode (for tooltip hint)
            local isExcludable = (HCE.EasyModeExclusions and HCE.EasyModeExclusions[char.name]
                                  and HCE.EasyModeExclusions[char.name][ch.desc]) or false

            -- Add a hover tooltip with the check detail from ChallengeCheck
            local row = rowPool[index - 1]
            if row then
                if isActive and checkResult and checkResult.detail then
                    row.equipDetail = checkResult.detail
                    row.equipStatus = checkResult.status
                end
                -- Keep the challenge description tooltip on enter
                -- and also append the check detail + easy mode hint below it
                local origEnter = row:GetScript("OnEnter")
                local capturedResult = (isActive and checkResult) or nil
                local capturedExcludable = isExcludable
                row:SetScript("OnEnter", function(self)
                    if origEnter then origEnter(self) end
                    if GameTooltip:IsShown() then
                        if capturedResult and capturedResult.detail then
                            GameTooltip:AddLine(" ")
                            local statusLabel
                            if capturedResult.status == chStatus.PASS then
                                statusLabel = "|cff4de64dPassing|r"
                            elseif capturedResult.status == chStatus.FAIL then
                                statusLabel = "|cffff5a4cViolation detected|r"
                            else
                                statusLabel = "|cffa5a582Cannot fully verify yet|r"
                            end
                            GameTooltip:AddLine("Status: " .. statusLabel, 0.93, 0.93, 0.93)
                            GameTooltip:AddLine(capturedResult.detail, 0.75, 0.75, 0.75, true)
                        end
                        if capturedExcludable then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine("This challenge can be disabled by turning on Easy Mode in the addon settings.", 0.55, 0.80, 0.95, true)
                        end
                        GameTooltip:Show()
                    end
                end)
            end

            local extra = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc]
            if extra then
                index, yOff = emitRow(index, yOff, nil, nil, "  " .. extra, COLOR_SUBTXT)
                yOff = yOff + 4  -- extra spacing after description text
            end
            end  -- end of else (not excluded)
        end
    end

    -- Professions section (with tracking indicators from ProfessionCheck)
    local profResults = HCE.ProfessionCheck and HCE.ProfessionCheck.GetResults() or {}
    local profStatus  = HCE.ProfessionCheck and HCE.ProfessionCheck.STATUS or {}
    if char.professions and #char.professions > 0 then
        index, yOff = emitSectionHeader(index, yOff, "PROFESSIONS")
        for _, profName in ipairs(char.professions) do
            local res = profResults[profName]
            local tag, col, txtCol = reqTag(5, nil, playerLevel,
                res and res.status or nil)
            index, yOff = emitRow(index, yOff, tag, col, profName, txtCol)
            -- Tag profession rows for tooltip on hover (show rank detail)
            if res and res.detail then
                local row = rowPool[index - 1]
                if row then
                    row.equipDetail = res.detail
                    row.equipStatus = res.status
                    row:SetScript("OnEnter", onEquipRowEnter)
                    row:SetScript("OnLeave", onEquipRowLeave)
                end
            end
        end
    end

    -- Weapon Proficiency section
    local wpResults = HCE.WeaponProficiencyCheck and HCE.WeaponProficiencyCheck.GetResults() or {}
    local wpStatus  = HCE.WeaponProficiencyCheck and HCE.WeaponProficiencyCheck.STATUS or {}
    if char.weaponProficiency and #char.weaponProficiency > 0 then
        index, yOff = emitSectionHeader(index, yOff, "WEAPON PROFICIENCY")
        for _, wpnEntry in ipairs(char.weaponProficiency) do
            -- Support both "Bows" and E("Bows", 10) formats
            local wpn, wpnLevel
            if type(wpnEntry) == "table" then
                wpn = wpnEntry.desc or wpnEntry.name or "?"
                wpnLevel = wpnEntry.level or 1
            else
                wpn = wpnEntry
                wpnLevel = 1
            end
            local res = wpResults[wpn]
            local tag, col, txtCol = reqTag(wpnLevel, nil, playerLevel,
                res and res.status or nil)
            index, yOff = emitRow(index, yOff, tag, col, wpn, txtCol)
            if res and res.detail then
                local row = rowPool[index - 1]
                if row then
                    row.equipDetail = res.detail
                    row.equipStatus = res.status
                    row:SetScript("OnEnter", onEquipRowEnter)
                    row:SetScript("OnLeave", onEquipRowLeave)
                end
            end
        end
    end

    -- Equipment section
    local eqResults = HCE.EquipmentCheck and HCE.EquipmentCheck.GetResults() or {}
    local eqStatus  = HCE.EquipmentCheck and HCE.EquipmentCheck.STATUS or {}
    if char.equipment and #char.equipment > 0 then
        index, yOff = emitSectionHeader(index, yOff, "EQUIPMENT")
        for i, eq in ipairs(char.equipment) do
            local res = eqResults[i]
            local tag, col, txtCol = reqTag(eq.level, eq.endLevel, playerLevel,
                res and res.status or nil)
            local isActive = (playerLevel >= eq.level) and not (eq.endLevel and playerLevel > eq.endLevel)
            index, yOff = emitRow(index, yOff, tag, col, eq.desc, txtCol)
            -- Tag equipment rows for tooltip on hover (show check detail + curated items)
            local row = rowPool[index - 1]
            if row then
                -- Attach curated list key so tooltip can show approved items
                local keyMap = HCE.CuratedKeyForDesc or {}
                row.curatedKey = keyMap[eq.desc]

                if res and res.detail then
                    row.equipDetail = res.detail
                    row.equipStatus = res.status
                    row:SetScript("OnEnter", onEquipRowEnter)
                    row:SetScript("OnLeave", onEquipRowLeave)
                elseif row.curatedKey then
                    -- Even without a check result, show curated items on hover
                    row.equipDetail = "Hover to see approved items"
                    row.equipStatus = "unchecked"
                    row:SetScript("OnEnter", onEquipRowEnter)
                    row:SetScript("OnLeave", onEquipRowLeave)
                end
            end
        end
    end

    -- Talents section (spec tracking + per-talent requirements)
    -- Run a fresh check so results are always current (the API calls
    -- are cheap and this avoids stale-cache / timing-race issues).
    if HCE.TalentCheck and HCE.TalentCheck.RunCheck then
        local tok, terr = pcall(HCE.TalentCheck.RunCheck)
        if not tok and HCE.Print then
            HCE.Print("|cffff5555Talent check error:|r " .. tostring(terr))
        end
    end
    local talentResult = HCE.TalentCheck and HCE.TalentCheck.GetResults() or {}
    local talentStatus = HCE.TalentCheck and HCE.TalentCheck.STATUS or {}
    if char.spec then
        index, yOff = emitSectionHeader(index, yOff, "TALENTS")

        -- Row 1: spec label (informational only, not tracked)
        index, yOff = emitRow(index, yOff, nil, nil,
            "Spec: " .. char.spec, COLOR_SUBTXT)

        -- Per-talent requirement rows (indented under the spec row)
        -- Read directly from TalentRequirements data so rows are ALWAYS
        -- visible, even before the talent scan has run.  Check results
        -- (from talentResult.talentReqs) are overlaid for ✓/✗/? status.
        local rawReqs   = HCE.TalentRequirements and HCE.TalentRequirements[char.name]
        local checkReqs = talentResult.talentReqs
        if rawReqs then
            for ri, req in ipairs(rawReqs) do
                -- Use check result for this index if available
                local chk = checkReqs and checkReqs[ri]
                local tTag, tCol, tTxtCol = reqTag(req.level, req.endLevel, playerLevel,
                    chk and chk.status or nil)
                local maxRank = (chk and chk.maxRank) or req.rank
                local rankStr = req.rank .. "/" .. maxRank
                local tText = req.name .. " (" .. rankStr .. ")"
                index, yOff = emitRow(index, yOff, tTag, tCol, tText, tTxtCol)
                -- Hover tooltip
                local tRow = rowPool[index - 1]
                if tRow then
                    tRow.equipDetail = (chk and chk.detail) or "Talent check pending\226\128\166"
                    tRow.equipStatus = (chk and chk.status) or "unchecked"
                    tRow:SetScript("OnEnter", onEquipRowEnter)
                    tRow:SetScript("OnLeave", onEquipRowLeave)
                end
            end
        end
    end

    -- Quests section
    local qcResults = HCE.QuestCheck and HCE.QuestCheck.GetResults() or {}
    local qcStatus  = HCE.QuestCheck and HCE.QuestCheck.STATUS or {}
    local charQuests = HCE.GetCharQuests and HCE.GetCharQuests(char) or char.quests or {}
    if #charQuests > 0 then
        index, yOff = emitSectionHeader(index, yOff, "QUESTS")

        -- Build group boundaries: either from questGroups or a single group
        local groups
        if char.questGroups then
            groups = char.questGroups
        elseif char.questTheme then
            groups = { { theme = char.questTheme, count = #charQuests } }
        else
            groups = { { theme = nil, count = #charQuests } }
        end

        local questIdx = 1
        for _, group in ipairs(groups) do
            -- Sub-header for each quest group theme
            if group.theme then
                index, yOff = emitRow(index, yOff, nil, nil,
                    group.theme, COLOR_SUBTXT)
            end

            for _ = 1, group.count do
                local quest = charQuests[questIdx]
                if not quest then break end
                local i = questIdx
                questIdx = questIdx + 1

                local res = qcResults[i]
                local tag, col, txtCol = reqTag(quest.level, nil, playerLevel,
                    res and res.status or nil)

                index, yOff = emitRow(index, yOff, tag, col, quest.name, txtCol)

                -- Tooltip on hover showing quest completion detail
                if res and res.detail then
                    local row = rowPool[index - 1]
                    if row then
                        row.equipDetail = res.detail
                        row.equipStatus = res.status
                        row:SetScript("OnEnter", onEquipRowEnter)
                        row:SetScript("OnLeave", onEquipRowLeave)
                    end
                end
            end
        end
    end

    -- Companion / pet / mount
    local hasAnimals = char.companion or char.pet or char.mount
    if hasAnimals then
        index, yOff = emitSectionHeader(index, yOff, "MOUNTS/COMPANIONS/PETS")
        if char.companion then
            local compResult = HCE_CharDB and HCE_CharDB.companionResults
            local tag, col, txtCol = reqTag(char.companion.level, nil, playerLevel,
                compResult and compResult.status or nil)
            index, yOff = emitRow(index, yOff, tag, col, "Companion: " .. char.companion.desc, txtCol)
            -- Tooltip: always attach so hover shows CompanionDB info
            local compRow = rowPool[index - 1]
            if compRow then
                compRow.companionKey = char.companion.desc
                if compResult then
                    compRow.equipDetail = compResult.detail or "Checking..."
                    compRow.equipStatus = compResult.status
                else
                    compRow.equipDetail = "Activates at level " .. char.companion.level
                    compRow.equipStatus = "unchecked"
                end
                compRow:SetScript("OnEnter", onEquipRowEnter)
                compRow:SetScript("OnLeave", onEquipRowLeave)
            end
        end
        if char.pet then
            local hpResult = HCE_CharDB and HCE_CharDB.hunterPetResults
            local tag, col, txtCol = reqTag(char.pet.level, nil, playerLevel,
                hpResult and hpResult.status or nil)
            index, yOff = emitRow(index, yOff, tag, col, "Hunter pet: " .. char.pet.desc, txtCol)
            -- Tooltip on hover showing hunter pet check detail
            if hpResult and hpResult.detail then
                local row = rowPool[index - 1]
                if row then
                    row.equipDetail = hpResult.detail
                    row.equipStatus = hpResult.status
                    row:SetScript("OnEnter", onEquipRowEnter)
                    row:SetScript("OnLeave", onEquipRowLeave)
                end
            end
        end
        if char.mount then
            local mtResult = HCE_CharDB and HCE_CharDB.mountResults
            local tag, col, txtCol = reqTag(char.mount.level, nil, playerLevel,
                mtResult and mtResult.status or nil)
            index, yOff = emitRow(index, yOff, tag, col, "Mount: " .. char.mount.desc, txtCol)
            -- Tooltip on hover showing mount check detail
            if mtResult and mtResult.detail then
                local row = rowPool[index - 1]
                if row then
                    row.equipDetail = mtResult.detail
                    row.equipStatus = mtResult.status
                    row:SetScript("OnEnter", onEquipRowEnter)
                    row:SetScript("OnLeave", onEquipRowLeave)
                end
            end
        end
    end

    -- Recommended profession (not a requirement — shown like gameplay tips)
    if char.recommendedProfession then
        local COLOR_TIPS = { r = 0.55, g = 0.70, b = 0.85 }
        local rp = char.recommendedProfession
        index, yOff = emitSectionHeader(index, yOff, "RECOMMENDED")
        local rowIdx = index
        index, yOff = emitRow(index, yOff, nil, nil,
            "Profession: " .. rp.name, COLOR_TIPS)
        local row = rowPool[rowIdx]
        if row then
            row.tipTitle = "Recommended: " .. rp.name
            row.tipDesc  = rp.reason
            row:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(self.tipTitle, 0.55, 0.70, 0.85)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(self.tipDesc, 0.93, 0.93, 0.93, true)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("This is a suggestion, not a requirement.", 0.55, 0.55, 0.50, true)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end

    -- Gameplay tips (expanded via GameplayTips module)
    if char.gameplay and char.gameplay ~= "" then
        index, yOff = emitSectionHeader(index, yOff, "GAMEPLAY")
        local COLOR_TIPS = { r = 0.55, g = 0.70, b = 0.85 }
        local tips = HCE.GameplayTips and HCE.GameplayTips.Parse and HCE.GameplayTips.Parse(char.gameplay)
        if tips and #tips > 0 then
            for _, tip in ipairs(tips) do
                local rowIdx = index
                index, yOff = emitRow(index, yOff, nil, nil,
                    tip.title, COLOR_TIPS)
                -- Add hover tooltip with the full description
                local row = rowPool[rowIdx]
                if row then
                    row.tipDesc = tip.desc
                    row.tipTitle = tip.title
                    row:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:ClearLines()
                        GameTooltip:AddLine(self.tipTitle, 0.55, 0.70, 0.85)
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine(self.tipDesc, 0.93, 0.93, 0.93, true)
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("This is a flavour suggestion, not a requirement.", 0.55, 0.55, 0.50, true)
                        GameTooltip:Show()
                    end)
                    row:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                end
            end
        else
            -- Fallback: show raw text if GameplayTips module not loaded
            index, yOff = emitRow(index, yOff, nil, nil, char.gameplay, COLOR_SUBTXT)
        end
    end

    releaseExtraRows(index - 1)
    contentFrame:SetHeight(math.max(yOff + 10, 1))
end

----------------------------------------------------------------------
-- Build the frame
----------------------------------------------------------------------

local function BuildFrame()
    if frame then return frame end

    frame = CreateFrame("Frame", "HCE_RequirementsPanel", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)

    -- Close panel with Escape key
    tinsert(UISpecialFrames, "HCE_RequirementsPanel")

    -- Ornate gold/bronze backdrop
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = 16,
            insets   = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0.06, 0.06, 0.08, 1.0)
        frame:SetBackdropBorderColor(1.0, 0.85, 0.45, 0.95)
    end

    -- Solid opaque fill behind everything so the game world never shows through
    local solidBg = frame:CreateTexture(nil, "BACKGROUND", nil, 0)
    solidBg:SetColorTexture(0.20, 0.20, 0.20, 1.0)
    solidBg:SetPoint("TOPLEFT", 6, -6)
    solidBg:SetPoint("BOTTOMRIGHT", -6, 6)

    -- Title bar -------------------------------------------------------
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(46)
    Panel._titleBar = titleBar
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        if not db().locked then frame:StartMoving() end
    end)
    titleBar:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local p, _, rp, x, y = frame:GetPoint()
        local s = db()
        s.point, s.relPoint, s.x, s.y = p, rp, x, y
    end)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetColorTexture(0.85, 0.70, 0.20, 0.12)
    titleBg:SetAllPoints(titleBar)

    local titleStripe = titleBar:CreateTexture(nil, "ARTWORK")
    titleStripe:SetColorTexture(0.85, 0.70, 0.20, 0.85)
    titleStripe:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    titleStripe:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    titleStripe:SetHeight(1)

    headerLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerLabel:SetPoint("TOPLEFT", titleBar, "TOPLEFT", PAD_X, -PAD_Y)
    headerLabel:SetPoint("RIGHT", titleBar, "RIGHT", -58, 0)
    headerLabel:SetJustifyH("LEFT")
    headerLabel:SetText("Hardcore Classes Enhanced")

    subLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subLabel:SetPoint("TOPLEFT", headerLabel, "BOTTOMLEFT", 0, -2)
    subLabel:SetJustifyH("LEFT")
    subLabel:SetTextColor(COLOR_SUBTXT.r, COLOR_SUBTXT.g, COLOR_SUBTXT.b)
    subLabel:SetText("")

    -- Close button (top-right corner)
    closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() Panel.Hide() end)

    ----------------------------------------------------------------
    -- ROW 1: Left of close button — Scan, Catalog, Lore
    ----------------------------------------------------------------

    -- Scan button (magnifying glass)
    local scanButton = CreateFrame("Button", nil, titleBar)
    scanButton:SetSize(20, 20)
    scanButton:SetPoint("RIGHT", closeButton, "LEFT", -4, 0)
    scanButton.icon = scanButton:CreateTexture(nil, "ARTWORK")
    scanButton.icon:SetAllPoints()
    scanButton.icon:SetTexture("Interface\\MINIMAP\\TRACKING\\None")
    scanButton:SetScript("OnClick", function()
        if HCE.AddonComm and HCE.AddonComm.StartNearbyScan then
            HCE.AddonComm.StartNearbyScan()
        else
            HCE.Print("Addon communication module not loaded.")
        end
    end)
    scanButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Find HCE Players", 0.85, 0.70, 0.20)
        GameTooltip:AddLine("Scan for other players using", 0.75, 0.75, 0.75, true)
        GameTooltip:AddLine("Hardcore Classes Enhanced", 0.75, 0.75, 0.75, true)
        GameTooltip:Show()
    end)
    scanButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Catalog button (class icon)
    local catalogButton = CreateFrame("Button", nil, titleBar)
    catalogButton:SetSize(20, 20)
    catalogButton:SetPoint("RIGHT", scanButton, "LEFT", -2, 0)
    catalogButton.icon = catalogButton:CreateTexture(nil, "ARTWORK")
    catalogButton.icon:SetAllPoints()
    catalogButton.icon:SetTexture("Interface\\MINIMAP\\TRACKING\\Class")
    catalogButton:SetScript("OnClick", function()
        if HCE.CatalogUI and HCE.CatalogUI.Toggle then
            HCE.CatalogUI.Toggle()
        end
    end)
    catalogButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Browse all enhanced classes")
        GameTooltip:Show()
    end)
    catalogButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Lore button (scroll icon) — only shown for core-set characters
    local loreButton = CreateFrame("Button", nil, titleBar)
    loreButton:SetSize(15, 15)
    loreButton:SetPoint("RIGHT", catalogButton, "LEFT", -2, 0)
    loreButton.icon = loreButton:CreateTexture(nil, "ARTWORK")
    loreButton.icon:SetAllPoints()
    loreButton.icon:SetTexture("Interface\\ICONS\\INV_Scroll_02")
    loreButton.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    loreButton:SetScript("OnClick", function()
        Panel.ToggleLore()
    end)
    loreButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Read lore background")
        GameTooltip:Show()
    end)
    loreButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    loreButton:Hide()
    Panel._loreButton = loreButton

    ----------------------------------------------------------------
    -- ROW 2: Below close button — Settings, Commands
    ----------------------------------------------------------------

    -- Settings button (gear icon)
    local settingsButton = CreateFrame("Button", nil, titleBar)
    settingsButton:SetSize(18, 18)
    settingsButton:SetPoint("TOP", closeButton, "BOTTOM", 0, -1)
    settingsButton.icon = settingsButton:CreateTexture(nil, "ARTWORK")
    settingsButton.icon:SetAllPoints()
    settingsButton.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    settingsButton:SetScript("OnClick", function()
        if HCE.SettingsPanel and HCE.SettingsPanel.Toggle then
            HCE.SettingsPanel.Toggle()
        end
    end)
    settingsButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Settings")
        GameTooltip:Show()
    end)
    settingsButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Commands button (? icon)
    local cmdButton = CreateFrame("Button", nil, titleBar)
    cmdButton:SetSize(27, 27)
    cmdButton:SetPoint("RIGHT", settingsButton, "LEFT", -2, 0)
    cmdButton.icon = cmdButton:CreateTexture(nil, "ARTWORK")
    cmdButton.icon:SetAllPoints()
    cmdButton.icon:SetTexture("Interface\\COMMON\\help-i")
    cmdButton:SetScript("OnClick", function()
        SlashCmdList["HCE"]("help")
    end)
    cmdButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Commands", 0.85, 0.70, 0.20)
        GameTooltip:AddLine("Click to show all /hce commands", 0.75, 0.75, 0.75)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("/hce scan", "Find HCE players", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce share <name>", "Whisper about HCE", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce share party", "Share in party chat", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce list", "Browse all classes", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce reset", "Clear your character selection", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce pick", "Open character selection window", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce pick <name>", "Pick a specific character by name", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce donate", "Support the addon", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:AddDoubleLine("/hce join", "Join the Discord", 1,1,1, 0.7,0.7,0.7)
        GameTooltip:Show()
    end)
    cmdButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- UpdatePinIcon kept as no-op for backward compat
    function Panel.UpdatePinIcon() end

    -- Progress bar spacer — reserve vertical space so the scroll frame
    -- starts below the progress bar when it's present.  The bar itself
    -- is created lazily in Panel.Refresh; this just offsets the scroll.
    local PROGRESS_H = 48
    local progressSpacer = CreateFrame("Frame", nil, frame)
    progressSpacer:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    progressSpacer:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    progressSpacer:SetHeight(PROGRESS_H)
    progressSpacer:EnableMouse(true)
    progressSpacer:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Rank Tiers", 0.85, 0.70, 0.20)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("0%",   "Initiate", 1, 1, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine("25%",  "Adept",    1, 1, 1, 0.12, 1.0, 0.0)
        GameTooltip:AddDoubleLine("50%",  "Prime",    1, 1, 1, 0.0, 0.44, 0.87)
        GameTooltip:AddDoubleLine("75%",  "Elite",    1, 1, 1, 0.64, 0.21, 0.93)
        GameTooltip:AddDoubleLine("100%", "Master",   1, 1, 1, 1.0, 0.50, 0.0)
        GameTooltip:Show()
    end)
    progressSpacer:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Panel._progressSpacer = progressSpacer

    -- Scroll frame ----------------------------------------------------
    scrollFrame = CreateFrame("ScrollFrame", "HCE_RequirementsPanelScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", progressSpacer, "BOTTOMLEFT", PAD_X, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, PAD_Y)

    contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(FRAME_WIDTH - PAD_X - 34, 10)
    scrollFrame:SetScrollChild(contentFrame)

    -- Art panel — a separate frame docked to the left of the requirements
    -- panel, showing the class portrait at full opacity.  Moves with the
    -- main frame and shares the same ornate border style.
    local artFrame = CreateFrame("Frame", "HCE_ArtPanel", frame, "BackdropTemplate")
    artFrame:SetWidth(FRAME_WIDTH)
    artFrame:SetPoint("TOPRIGHT", frame, "TOPLEFT", 0, 0)
    artFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, 0)
    artFrame:SetFrameStrata("MEDIUM")
    if artFrame.SetBackdrop then
        artFrame:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = 16,
            insets   = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        artFrame:SetBackdropColor(0.06, 0.06, 0.08, 1.0)
        artFrame:SetBackdropBorderColor(1.0, 0.85, 0.45, 0.95)
    end
    -- Solid black fill so nothing bleeds through
    local artSolidBg = artFrame:CreateTexture(nil, "BACKGROUND", nil, 0)
    artSolidBg:SetColorTexture(0.05, 0.05, 0.05, 1.0)
    artSolidBg:SetPoint("TOPLEFT", 6, -6)
    artSolidBg:SetPoint("BOTTOMRIGHT", -6, 6)

    -- The actual class art texture — full opacity, fills the panel
    local artTex = artFrame:CreateTexture(nil, "ARTWORK")
    artTex:SetPoint("TOPLEFT", artFrame, "TOPLEFT", 6, -6)
    artTex:SetPoint("BOTTOMRIGHT", artFrame, "BOTTOMRIGHT", -6, 6)
    artTex:SetTexCoord(0, 1, 0, 1)

    artFrame:Hide()
    Panel._artFrame = artFrame
    Panel._artTex = artTex

    -- Restore position
    local s = db()
    -- Default position offsets the main frame rightward by half the art
    -- panel width so the combined pair (art + requirements) is centered.
    local defaultX = math.floor(FRAME_WIDTH / 2)
    frame:ClearAllPoints()
    frame:SetPoint(s.point or "CENTER", UIParent, s.relPoint or "CENTER", s.x or defaultX, s.y or 0)
    Panel.UpdatePinIcon()

    frame:Hide()
    return frame
end

----------------------------------------------------------------------
-- Lore popup
----------------------------------------------------------------------

local loreFrame  -- created once, toggled

local function BuildLoreFrame()
    if loreFrame then return loreFrame end

    loreFrame = CreateFrame("Frame", "HCE_LoreFrame", UIParent, "BackdropTemplate")
    loreFrame:SetSize(340, 320)
    loreFrame:SetFrameStrata("DIALOG")
    loreFrame:SetClampedToScreen(true)
    loreFrame:SetMovable(true)
    loreFrame:EnableMouse(true)
    tinsert(UISpecialFrames, "HCE_LoreFrame")

    if loreFrame.SetBackdrop then
        loreFrame:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = 16,
            insets   = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        loreFrame:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
        loreFrame:SetBackdropBorderColor(1.0, 0.85, 0.45, 0.95)
    end

    -- Title bar
    local loreTitleBar = CreateFrame("Frame", nil, loreFrame)
    loreTitleBar:SetPoint("TOPLEFT", 0, 0)
    loreTitleBar:SetPoint("TOPRIGHT", 0, 0)
    loreTitleBar:SetHeight(32)
    loreTitleBar:EnableMouse(true)
    loreTitleBar:RegisterForDrag("LeftButton")
    loreTitleBar:SetScript("OnDragStart", function() loreFrame:StartMoving() end)
    loreTitleBar:SetScript("OnDragStop", function() loreFrame:StopMovingOrSizing() end)

    local loreTitleBg = loreTitleBar:CreateTexture(nil, "BACKGROUND")
    loreTitleBg:SetColorTexture(0.70, 0.55, 0.15, 0.15)
    loreTitleBg:SetAllPoints(loreTitleBar)

    local loreTitleStripe = loreTitleBar:CreateTexture(nil, "ARTWORK")
    loreTitleStripe:SetColorTexture(0.70, 0.55, 0.15, 0.65)
    loreTitleStripe:SetPoint("BOTTOMLEFT", loreTitleBar, "BOTTOMLEFT", 0, 0)
    loreTitleStripe:SetPoint("BOTTOMRIGHT", loreTitleBar, "BOTTOMRIGHT", 0, 0)
    loreTitleStripe:SetHeight(1)

    loreFrame.titleText = loreTitleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    loreFrame.titleText:SetPoint("LEFT", loreTitleBar, "LEFT", 12, 0)
    loreFrame.titleText:SetPoint("RIGHT", loreTitleBar, "RIGHT", -28, 0)
    loreFrame.titleText:SetJustifyH("LEFT")
    loreFrame.titleText:SetTextColor(0.85, 0.70, 0.20)

    local loreClose = CreateFrame("Button", nil, loreTitleBar, "UIPanelCloseButton")
    loreClose:SetSize(22, 22)
    loreClose:SetPoint("TOPRIGHT", loreTitleBar, "TOPRIGHT", -2, -2)
    loreClose:SetScript("OnClick", function() loreFrame:Hide() end)

    -- Scroll frame for lore body
    local loreScroll = CreateFrame("ScrollFrame", "HCE_LoreScroll", loreFrame, "UIPanelScrollFrameTemplate")
    loreScroll:SetPoint("TOPLEFT", loreTitleBar, "BOTTOMLEFT", 12, -8)
    loreScroll:SetPoint("BOTTOMRIGHT", loreFrame, "BOTTOMRIGHT", -30, 12)

    -- 340 frame - 12 left pad - 30 scrollbar - 12 right margin = ~280
    local LORE_TEXT_W = 276

    local loreContent = CreateFrame("Frame", nil, loreScroll)
    loreContent:SetWidth(LORE_TEXT_W + 4)
    loreContent:SetHeight(1)
    loreScroll:SetScrollChild(loreContent)

    loreFrame.body = loreContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    loreFrame.body:SetPoint("TOPLEFT", loreContent, "TOPLEFT", 0, 0)
    loreFrame.body:SetWidth(LORE_TEXT_W)
    loreFrame.body:SetJustifyH("LEFT")
    loreFrame.body:SetWordWrap(true)
    loreFrame.body:SetSpacing(3)

    -- Wiki link at the bottom of the content
    loreFrame.wikiLabel = loreContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    loreFrame.wikiLabel:SetPoint("TOPLEFT", loreFrame.body, "BOTTOMLEFT", 0, -12)
    loreFrame.wikiLabel:SetWidth(LORE_TEXT_W)
    loreFrame.wikiLabel:SetJustifyH("LEFT")
    loreFrame.wikiLabel:SetWordWrap(true)
    loreFrame.wikiLabel:SetTextColor(0.40, 0.73, 1.00)

    loreFrame.loreContent = loreContent

    -- Position next to the requirements panel
    if frame then
        loreFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)
    else
        loreFrame:SetPoint("CENTER")
    end

    loreFrame:Hide()
    return loreFrame
end

function Panel.ShowLore()
    BuildLoreFrame()

    local key = HCE_CharDB and HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then return end

    -- Only core characters have lore
    if HCE.AdditionalCharacters and HCE.AdditionalCharacters[char.name] then return end

    local lore = HCE.LoreData and HCE.LoreData[char.name]
    if not lore or lore == "" then
        lore = "No lore entry found for this class."
    end

    local cc = classColor(char.class)
    loreFrame.titleText:SetText("|cff" .. cc .. char.name .. "|r — Lore")
    loreFrame.body:SetText(lore)

    -- Wiki link
    local slug = char.name:gsub(" ", "_")
    loreFrame.wikiLabel:SetText("Read more: https://warcraft.wiki.gg/wiki/" .. slug)

    -- Resize content to fit text
    local textH = loreFrame.body:GetStringHeight()
    local wikiH = loreFrame.wikiLabel:GetStringHeight()
    loreFrame.loreContent:SetHeight(textH + wikiH + 24)

    -- Reanchor next to the panel if it's shown
    if frame and frame:IsShown() then
        loreFrame:ClearAllPoints()
        loreFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)
    end

    loreFrame:Show()
end

function Panel.HideLore()
    if loreFrame then loreFrame:Hide() end
end

function Panel.ToggleLore()
    BuildLoreFrame()
    if loreFrame:IsShown() then
        Panel.HideLore()
    else
        Panel.ShowLore()
    end
end

----------------------------------------------------------------------
-- Show / hide / toggle
----------------------------------------------------------------------

function Panel.Show()
    BuildFrame()
    frame:Show()
    db().shown = true
    Panel.Refresh()
end

function Panel.Hide()
    if frame then frame:Hide() end
    db().shown = false
end

function Panel.Toggle()
    BuildFrame()
    if frame:IsShown() then Panel.Hide() else Panel.Show() end
end

function Panel.IsShown()
    return frame and frame:IsShown()
end

-- Expose under HCE so the main file's slash command can call it
HCE.TogglePanel  = Panel.Toggle
HCE.ShowPanel    = Panel.Show
HCE.HidePanel    = Panel.Hide
HCE.RefreshPanel = Panel.Refresh

----------------------------------------------------------------------
-- Minimap button
----------------------------------------------------------------------

local minimapButton

-- Minimap shape quadrant table (matches LibDBIcon-1.0 approach).
-- Each entry is {BL-round, TL-round, BR-round, TR-round}.
-- true = that quadrant is round, false = that quadrant is square.
local minimapShapes = {
    ["ROUND"]                 = {true, true, true, true},
    ["SQUARE"]                = {false, false, false, false},
    ["CORNER-TOPLEFT"]        = {false, false, false, true},
    ["CORNER-TOPRIGHT"]       = {false, false, true, false},
    ["CORNER-BOTTOMLEFT"]     = {false, true, false, false},
    ["CORNER-BOTTOMRIGHT"]    = {true, false, false, false},
    ["SIDE-LEFT"]             = {false, true, false, true},
    ["SIDE-RIGHT"]            = {true, false, true, false},
    ["SIDE-TOP"]              = {false, false, true, true},
    ["SIDE-BOTTOM"]           = {true, true, false, false},
    ["TRICORNER-TOPLEFT"]     = {false, true, true, true},
    ["TRICORNER-TOPRIGHT"]    = {true, false, true, true},
    ["TRICORNER-BOTTOMLEFT"]  = {true, true, false, true},
    ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local BUTTON_RADIUS = 5  -- extra offset beyond minimap edge

local function UpdateMinimapPos()
    if not minimapButton then return end
    local angle = math.rad(db().minimap.angle or 215)
    local x, y = math.cos(angle), math.sin(angle)

    -- Determine which quadrant (1-4) the angle falls in
    local q = 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end

    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadTable = minimapShapes[shape] or minimapShapes["ROUND"]

    local w = (Minimap:GetWidth() / 2) + BUTTON_RADIUS
    local h = (Minimap:GetHeight() / 2) + BUTTON_RADIUS

    if quadTable[q] then
        -- Round quadrant: place on the ellipse
        x, y = x * w, y * h
    else
        -- Square quadrant: use diagonal radius, clamped to edges
        local diagW = math.sqrt(2 * w ^ 2) - 10
        local diagH = math.sqrt(2 * h ^ 2) - 10
        x = math.max(-w, math.min(x * diagW, w))
        y = math.max(-h, math.min(y * diagH, h))
    end

    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function BuildMinimapButton()
    if minimapButton then return minimapButton end

    minimapButton = CreateFrame("Button", "HCE_MinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetMovable(true)

    -- Outer ring (reuses Blizzard's minimap tracking ring texture)
    local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetSize(54, 54)
    overlay:SetPoint("TOPLEFT", 0, 0)

    -- Background circle (gives the icon a consistent fill)
    local bg = minimapButton:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(20, 20)
    bg:SetPoint("TOPLEFT", 7, -6)

    -- Custom icon drawn with plain textures — an angular gold chevron
    -- over a dark disc.  Keeps it visually distinct from stock addon
    -- buttons which are all Blizzard spell icons.
    local disc = minimapButton:CreateTexture(nil, "ARTWORK")
    disc:SetTexture("Interface\\Buttons\\WHITE8x8")
    disc:SetVertexColor(0.08, 0.08, 0.11, 1)
    disc:SetSize(18, 18)
    disc:SetPoint("TOPLEFT", 8, -7)

    local glyph = minimapButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    glyph:SetPoint("CENTER", disc, "CENTER", 0, 0)
    glyph:SetText("|cffe6b422H|r|cffffd100C|r")

    minimapButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            -- Right-click toggles the lock
            local s = db()
            s.locked = not s.locked
            Panel.UpdatePinIcon()
            HCE.Print(s.locked and "Requirements panel locked." or "Requirements panel unlocked.")
        else
            Panel.Toggle()
        end
    end)

    -- Drag-around-minimap support
    minimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            local angle = math.deg(math.atan2(py - my, px - mx))
            db().minimap.angle = angle
            UpdateMinimapPos()
        end)
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Hardcore Classes Enhanced")
        GameTooltip:AddLine("|cffffffffLeft-click|r toggle requirements panel", 1, 1, 1)
        GameTooltip:AddLine("|cffffffffRight-click|r lock/unlock panel", 1, 1, 1)
        GameTooltip:AddLine("|cffffffffDrag|r move this button", 1, 1, 1)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdateMinimapPos()
    if db().minimap.hide then minimapButton:Hide() else minimapButton:Show() end
    return minimapButton
end

function Panel.ShowMinimapButton()
    BuildMinimapButton()
    db().minimap.hide = false
    minimapButton:Show()
end

function Panel.HideMinimapButton()
    db().minimap.hide = true
    if minimapButton then minimapButton:Hide() end
end

HCE.ShowMinimapButton = Panel.ShowMinimapButton
HCE.HideMinimapButton = Panel.HideMinimapButton

----------------------------------------------------------------------
-- Event hookup (for live refresh)
----------------------------------------------------------------------

local liveFrame = CreateFrame("Frame")
liveFrame:RegisterEvent("PLAYER_LOGIN")
liveFrame:RegisterEvent("PLAYER_LEVEL_UP")
liveFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
liveFrame:RegisterEvent("SKILL_LINES_CHANGED")
liveFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
liveFrame:RegisterEvent("UNIT_AURA")
liveFrame:RegisterEvent("UNIT_PET")
pcall(function() liveFrame:RegisterEvent("COMPANION_UPDATE") end)
liveFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
liveFrame:RegisterEvent("ZONE_CHANGED")
pcall(function() liveFrame:RegisterEvent("PLAYER_UPDATE_RESTING") end)
liveFrame:RegisterEvent("BAG_UPDATE")
liveFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer a tick so SavedVariables + CharacterData are ready
        C_Timer.After(1.2, function()
            BuildFrame()
            BuildMinimapButton()
            if db().shown then Panel.Show() end
            Panel.Refresh()
        end)
    elseif event == "PLAYER_LEVEL_UP" then
        -- Player level isn't updated until the next frame; defer.
        C_Timer.After(0.1, Panel.Refresh)
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        -- EquipmentCheck.lua handles the actual check and calls
        -- RefreshPanel, but if it hasn't loaded yet we still refresh.
        C_Timer.After(0.5, Panel.Refresh)
    elseif event == "SKILL_LINES_CHANGED" then
        -- ProfessionCheck.lua handles the actual check and calls
        -- RefreshPanel, but we also refresh here as a fallback.
        C_Timer.After(0.5, Panel.Refresh)
    elseif event == "CHARACTER_POINTS_CHANGED" then
        -- TalentCheck.lua handles the actual check and calls
        -- RefreshPanel, but we also refresh here as a fallback.
        C_Timer.After(0.5, Panel.Refresh)
    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            -- SelfFoundCheck.lua handles the actual check and calls
            -- RefreshPanel, but we also refresh here as a fallback.
            C_Timer.After(0.5, Panel.Refresh)
        end
    elseif event == "UNIT_PET" then
        local unit = ...
        if unit == "player" then
            -- ChallengeCheck (Imp/No demon) reacts to pet changes.
            C_Timer.After(0.5, Panel.Refresh)
        end
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        -- Homebound / zone-visit challenges react to zone changes.
        C_Timer.After(0.7, Panel.Refresh)
    elseif event == "ZONE_CHANGED" or event == "PLAYER_UPDATE_RESTING" then
        -- Nocturnal/Diurnal challenges react to entering/leaving rest areas.
        C_Timer.After(0.3, Panel.Refresh)
    elseif event == "BAG_UPDATE" then
        -- Bag contents changed -- refresh for herb pouch / consumable checks.
        C_Timer.After(0.6, Panel.Refresh)
    end
end)

-- Periodic timer for time-of-day challenges (Nocturnal/Diurnal).
-- Checks every 60 seconds so the panel updates when server hour changes.
C_Timer.NewTicker(60, function()
    if Panel.frame and Panel.frame:IsShown() then
        Panel.Refresh()
    end
end)
