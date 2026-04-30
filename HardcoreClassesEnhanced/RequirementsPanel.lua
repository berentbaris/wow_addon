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
local headerLabel, subLabel, countLabel
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
    row.tag:SetWidth(58)
    row.tag:SetJustifyH("LEFT")

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 4, 0)
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

local function onChallengeRowEnter(self)
    local key = self.challengeKey
    if not key then return end
    local desc = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[key]
    if not desc then return end

    self.highlight:Show()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 8, 0)
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
        headerLabel:SetText("|cff" .. col .. char.name .. "|r")
        subLabel:SetText(char.spec .. " " .. titleCase(char.class) .. " · lv " .. playerLevel .. " / 60")
    else
        headerLabel:SetText("|cffffd100No enhanced class selected|r")
        subLabel:SetText("Type |cffffd100/hce pick|r to choose one")
    end

    local index  = 1
    local yOff   = 0

    if not char then
        countLabel:SetText("")
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

    -- Count active requirements for the summary
    local activeCount, totalCount = 0, 0
    local function count(item) if item then
        totalCount = totalCount + 1
        if playerLevel >= item.level then activeCount = activeCount + 1 end
    end end

    -- Self-found counts as active from level 1
    if char.selfFound then
        totalCount = totalCount + 1
        activeCount = activeCount + 1
    end

    -- Professions count as active from level 5
    if char.professions then
        for _ in ipairs(char.professions) do
            totalCount = totalCount + 1
            if playerLevel >= 5 then activeCount = activeCount + 1 end
        end
    end

    -- Talent/spec counts as active from level 10
    if char.spec then
        totalCount = totalCount + 1
        if playerLevel >= 10 then activeCount = activeCount + 1 end
    end

    for _, eq in ipairs(char.equipment or {}) do count(eq) end
    for _, ch in ipairs(char.challenges or {}) do count(ch) end
    count(char.companion); count(char.pet); count(char.mount)

    countLabel:SetText(activeCount .. " / " .. totalCount .. " requirements active")

    -- Progress bar (built once, updated each refresh)
    if HCE.Progress and HCE.Progress.BuildBar then
        -- The bar anchors below countLabel's parent (the summary frame).
        -- We build it lazily on first refresh, then just update.
        if not Panel._progressBar then
            -- Find the summary frame (countLabel's parent)
            local summaryFrame = countLabel:GetParent()
            Panel._progressBar = HCE.Progress.BuildBar(frame, summaryFrame, -2)
        end
        -- Defer the bar update slightly so all check modules have
        -- had time to write their results this frame
        C_Timer.After(0.05, function()
            if HCE.Progress.UpdateBar then HCE.Progress.UpdateBar() end
        end)
    end

    -- Race / gender / self-found summary row
    -- If self-found is required, append a tracking indicator
    local sfResults = HCE.SelfFoundCheck and HCE.SelfFoundCheck.GetResults() or {}
    local sfStatus  = HCE.SelfFoundCheck and HCE.SelfFoundCheck.STATUS or {}
    local sf = ""
    if char.selfFound then
        local sfBuff = sfResults.selfFound
        if sfBuff then
            if sfBuff.status == sfStatus.PASS then
                sf = " · |cff4de64dself-found \226\156\147|r"
            elseif sfBuff.status == sfStatus.FAIL then
                sf = " · |cffff5a4cself-found \226\156\151|r"
            else
                sf = " · |cffa5a582self-found ?|r"
            end
        else
            sf = " · |cffaaddffself-found|r"
        end
    end
    index, yOff = emitRow(index, yOff, nil, nil,
        char.race .. " · " .. char.gender .. sf, COLOR_SUBTXT)
    -- Tag self-found row for tooltip on hover
    if char.selfFound then
        local sfBuff = sfResults.selfFound
        if sfBuff and sfBuff.detail then
            local row = rowPool[index - 1]
            if row then
                row.equipDetail = sfBuff.detail
                row.equipStatus = sfBuff.status
                row:SetScript("OnEnter", onEquipRowEnter)
                row:SetScript("OnLeave", onEquipRowLeave)
            end
        end
    end

    -- Professions section (with tracking indicators from ProfessionCheck)
    local profResults = HCE.ProfessionCheck and HCE.ProfessionCheck.GetResults() or {}
    local profStatus  = HCE.ProfessionCheck and HCE.ProfessionCheck.STATUS or {}
    if char.professions and #char.professions > 0 then
        index, yOff = emitSectionHeader(index, yOff, "PROFESSIONS")
        for _, profName in ipairs(char.professions) do
            local res = profResults[profName]
            local tag, col, txtCol
            if playerLevel < 5 then
                tag = "lv 5"
                col = COLOR_INACTIVE
                txtCol = COLOR_INACTIVE
            else
                tag = "ACTIVE"
                col = COLOR_ACTIVE
                txtCol = nil
            end
            -- Append a tracking indicator
            local suffix = ""
            if res and playerLevel >= 5 then
                if res.status == profStatus.PASS then
                    suffix = "  |cff4de64d\226\156\147|r"   -- green checkmark ✓
                elseif res.status == profStatus.FAIL then
                    suffix = "  |cffff5a4c\226\156\151|r"   -- red ✗
                elseif res.status == "unchecked" then
                    suffix = "  |cffa5a582?|r"              -- muted ?
                end
            end
            index, yOff = emitRow(index, yOff, tag, col, profName .. suffix, txtCol)
            -- Tag profession rows for tooltip on hover (show rank detail)
            if res and playerLevel >= 5 and res.detail then
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

    -- Talents section (spec tracking from TalentCheck)
    local talentResult = HCE.TalentCheck and HCE.TalentCheck.GetResults() or {}
    local talentStatus = HCE.TalentCheck and HCE.TalentCheck.STATUS or {}
    if char.spec then
        index, yOff = emitSectionHeader(index, yOff, "TALENTS")
        local tag, col, txtCol
        if playerLevel < 10 then
            tag = "lv 10"
            col = COLOR_INACTIVE
            txtCol = COLOR_INACTIVE
        else
            tag = "ACTIVE"
            col = COLOR_ACTIVE
            txtCol = nil
        end
        -- Build the display text: "Spec: <spec name>"
        local specText = "Spec: " .. char.spec
        -- Append tracking indicator
        local suffix = ""
        if talentResult.status and playerLevel >= 10 then
            if talentResult.status == talentStatus.PASS then
                suffix = "  |cff4de64d\226\156\147|r"   -- green ✓
            elseif talentResult.status == talentStatus.FAIL then
                suffix = "  |cffff5a4c\226\156\151|r"   -- red ✗
            elseif talentResult.status == "unchecked" then
                suffix = "  |cffa5a582?|r"              -- muted ?
            end
        end
        index, yOff = emitRow(index, yOff, tag, col, specText .. suffix, txtCol)
        -- Tag talent row for tooltip on hover (show point breakdown)
        if talentResult.detail and playerLevel >= 10 then
            local row = rowPool[index - 1]
            if row then
                -- Build a richer tooltip detail showing per-tree points
                local detail = talentResult.detail
                local pts = talentResult.points
                if pts and pts[1] then
                    local lines = {}
                    local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 3
                    for i = 1, math.min(numTabs, 3) do
                        local tName = ""
                        if GetTalentTabInfo then
                            tName = GetTalentTabInfo(i) or ("Tree " .. i)
                        else
                            tName = "Tree " .. i
                        end
                        local marker = ""
                        if talentResult.specTab and i == talentResult.specTab then
                            marker = " (required)"
                        end
                        table.insert(lines, tName .. ": " .. pts[i] .. marker)
                    end
                    detail = detail .. "\n" .. table.concat(lines, "\n")
                end
                row.equipDetail = detail
                row.equipStatus = talentResult.status
                row:SetScript("OnEnter", onEquipRowEnter)
                row:SetScript("OnLeave", onEquipRowLeave)
            end
        end
    end

    -- Equipment section
    local eqResults = HCE.EquipmentCheck and HCE.EquipmentCheck.GetResults() or {}
    local eqStatus  = HCE.EquipmentCheck and HCE.EquipmentCheck.STATUS or {}
    if char.equipment and #char.equipment > 0 then
        index, yOff = emitSectionHeader(index, yOff, "EQUIPMENT")
        for i, eq in ipairs(char.equipment) do
            local tag, col = tagFor(eq.level, playerLevel)
            local txtCol = (playerLevel >= eq.level) and nil or COLOR_INACTIVE
            -- Append a tracking indicator for active requirements
            local suffix = ""
            local res = eqResults[i]
            if res and playerLevel >= eq.level then
                if res.status == eqStatus.PASS then
                    suffix = "  |cff4de64d\226\156\147|r"   -- green checkmark ✓
                elseif res.status == eqStatus.FAIL then
                    suffix = "  |cffff5a4c\226\156\151|r"   -- red ✗
                elseif res.status == eqStatus.UNCHECKED then
                    suffix = "  |cffa5a582?|r"              -- muted ?
                end
            end
            index, yOff = emitRow(index, yOff, tag, col, eq.desc .. suffix, txtCol)
            -- Tag equipment rows for tooltip on hover (show check detail)
            if res and playerLevel >= eq.level and res.detail then
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

    -- Challenges section (with tracking from ChallengeCheck + SelfFoundCheck)
    local chResults = HCE.ChallengeCheck and HCE.ChallengeCheck.GetResults() or {}
    local chStatus  = HCE.ChallengeCheck and HCE.ChallengeCheck.STATUS or {}
    if char.challenges and #char.challenges > 0 then
        index, yOff = emitSectionHeader(index, yOff, "CHALLENGES")
        for i, ch in ipairs(char.challenges) do
            local tag, col = tagFor(ch.level, playerLevel)
            local isActive = (playerLevel >= ch.level)
            local txtCol = isActive and nil or COLOR_INACTIVE

            -- Build a tracking indicator from ChallengeCheck results.
            -- Self-made / Self-made guns still use SelfFoundCheck for
            -- the detailed per-item breakdown, but ChallengeCheck now
            -- delegates to SelfFoundCheck internally so both sources
            -- agree on pass/fail/unchecked.
            local suffix = ""
            local checkResult = chResults[i]
            if isActive and checkResult then
                if checkResult.status == chStatus.PASS then
                    suffix = "  |cff4de64d\226\156\147|r"
                elseif checkResult.status == chStatus.FAIL then
                    suffix = "  |cffff5a4c\226\156\151|r"
                elseif checkResult.status == chStatus.UNCHECKED then
                    suffix = "  |cffa5a582?|r"
                end
            end

            index, yOff = emitRow(index, yOff, tag, col, ch.desc .. suffix, txtCol)
            -- Tag this row for hover tooltip (index-1 because emitRow already incremented)
            tagChallengeRow(index - 1, ch.desc, ch.level, isActive)

            -- Add a hover tooltip with the check detail from ChallengeCheck
            if isActive and checkResult and checkResult.detail then
                local row = rowPool[index - 1]
                if row then
                    row.equipDetail = checkResult.detail
                    row.equipStatus = checkResult.status
                    -- Keep the challenge description tooltip on enter
                    -- and also append the check detail below it
                    local origEnter = row:GetScript("OnEnter")
                    local capturedResult = checkResult
                    row:SetScript("OnEnter", function(self)
                        if origEnter then origEnter(self) end
                        if GameTooltip:IsShown() then
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
                            GameTooltip:Show()
                        end
                    end)
                end
            end

            local extra = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc]
            if extra then
                index, yOff = emitRow(index, yOff, nil, nil, "  " .. extra, COLOR_SUBTXT)
            end
        end
    end

    -- Companion / pet / mount
    local hasAnimals = char.companion or char.pet or char.mount
    if hasAnimals then
        index, yOff = emitSectionHeader(index, yOff, "COMPANIONS")
        if char.companion then
            local tag, col = tagFor(char.companion.level, playerLevel)
            local txtCol = (playerLevel >= char.companion.level) and nil or COLOR_INACTIVE
            -- Append tracking indicator from CompanionCheck
            local suffix = ""
            local compResult = HCE_CharDB and HCE_CharDB.companionResults
            local isCompActive = playerLevel >= char.companion.level
            if isCompActive and compResult then
                if compResult.status == "pass" then
                    suffix = "  |cff4de64d\226\156\147|r"   -- green ✓
                elseif compResult.status == "fail" then
                    suffix = "  |cffff5a4c\226\156\151|r"   -- red ✗
                elseif compResult.status == "unchecked" then
                    suffix = "  |cffa5a582?|r"              -- muted ?
                end
            end
            index, yOff = emitRow(index, yOff, tag, col, "Companion: " .. char.companion.desc .. suffix, txtCol)
            -- Tooltip on hover showing companion check detail
            if isCompActive and compResult and compResult.detail then
                local row = rowPool[index - 1]
                if row then
                    row.equipDetail = compResult.detail
                    row.equipStatus = compResult.status
                    row:SetScript("OnEnter", onEquipRowEnter)
                    row:SetScript("OnLeave", onEquipRowLeave)
                end
            end
        end
        if char.pet then
            local tag, col = tagFor(char.pet.level, playerLevel)
            local txtCol = (playerLevel >= char.pet.level) and nil or COLOR_INACTIVE
            -- Append tracking indicator from HunterPetCheck
            local hpSuffix = ""
            local hpResult = HCE_CharDB and HCE_CharDB.hunterPetResults
            local isPetActive = playerLevel >= char.pet.level
            if isPetActive and hpResult then
                if hpResult.status == "pass" then
                    hpSuffix = "  |cff4de64d\226\156\147|r"   -- green ✓
                elseif hpResult.status == "fail" then
                    hpSuffix = "  |cffff5a4c\226\156\151|r"   -- red ✗
                elseif hpResult.status == "unchecked" then
                    hpSuffix = "  |cffa5a582?|r"              -- muted ?
                end
            end
            index, yOff = emitRow(index, yOff, tag, col, "Hunter pet: " .. char.pet.desc .. hpSuffix, txtCol)
            -- Tooltip on hover showing hunter pet check detail
            if isPetActive and hpResult and hpResult.detail then
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
            local tag, col = tagFor(char.mount.level, playerLevel)
            local txtCol = (playerLevel >= char.mount.level) and nil or COLOR_INACTIVE
            -- Append tracking indicator from MountCheck
            local mtSuffix = ""
            local mtResult = HCE_CharDB and HCE_CharDB.mountResults
            local isMtActive = playerLevel >= char.mount.level
            if isMtActive and mtResult then
                if mtResult.status == "pass" then
                    mtSuffix = "  |cff4de64d\226\156\147|r"   -- green ✓
                elseif mtResult.status == "fail" then
                    mtSuffix = "  |cffff5a4c\226\156\151|r"   -- red ✗
                elseif mtResult.status == "unchecked" then
                    mtSuffix = "  |cffa5a582?|r"              -- muted ?
                end
            end
            index, yOff = emitRow(index, yOff, tag, col, "Mount: " .. char.mount.desc .. mtSuffix, txtCol)
            -- Tooltip on hover showing mount check detail
            if isMtActive and mtResult and mtResult.detail then
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

    -- Gameplay tips (expanded via GameplayTips module)
    if char.gameplay and char.gameplay ~= "" then
        index, yOff = emitSectionHeader(index, yOff, "GAMEPLAY")
        local COLOR_TIPS = { r = 0.55, g = 0.70, b = 0.85 }
        local tips = HCE.GameplayTips and HCE.GameplayTips.Parse and HCE.GameplayTips.Parse(char.gameplay)
        if tips and #tips > 0 then
            for _, tip in ipairs(tips) do
                local rowIdx = index
                index, yOff = emitRow(index, yOff, nil, nil,
                    tip.icon .. "  " .. tip.title, COLOR_TIPS)
                -- Add hover tooltip with the full description
                local row = rowPool[rowIdx]
                if row then
                    row.tipDesc = tip.desc
                    row.tipTitle = tip.title
                    row.tipIcon = tip.icon
                    row:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:ClearLines()
                        GameTooltip:AddLine(self.tipIcon .. " " .. self.tipTitle, 0.55, 0.70, 0.85)
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

    -- Backdrop — darker and more angular than BasicFrameTemplate so the
    -- panel reads as a sidebar, not a popup dialog.
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        frame:SetBackdropColor(0.05, 0.06, 0.08, 0.92)
        frame:SetBackdropBorderColor(0.85, 0.70, 0.20, 0.85)
    end

    -- Title bar -------------------------------------------------------
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(40)
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

    -- Close button
    closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() Panel.Hide() end)

    -- Pin/lock button
    pinButton = CreateFrame("Button", nil, titleBar)
    pinButton:SetSize(20, 20)
    pinButton:SetPoint("RIGHT", closeButton, "LEFT", -2, 0)
    pinButton.icon = pinButton:CreateTexture(nil, "ARTWORK")
    pinButton.icon:SetAllPoints()
    pinButton.icon:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
    pinButton:SetScript("OnClick", function()
        local s = db()
        s.locked = not s.locked
        Panel.UpdatePinIcon()
    end)
    pinButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(db().locked and "Unlock panel" or "Lock panel position")
        GameTooltip:Show()
    end)
    pinButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    function Panel.UpdatePinIcon()
        if db().locked then
            pinButton.icon:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
        else
            pinButton.icon:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
        end
    end

    -- Summary bar -----------------------------------------------------
    local summary = CreateFrame("Frame", nil, frame)
    summary:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    summary:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    summary:SetHeight(22)

    countLabel = summary:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countLabel:SetPoint("LEFT", summary, "LEFT", PAD_X, 0)
    countLabel:SetTextColor(0.85, 0.70, 0.20)

    local summaryLine = summary:CreateTexture(nil, "ARTWORK")
    summaryLine:SetColorTexture(0.85, 0.70, 0.20, 0.25)
    summaryLine:SetPoint("BOTTOMLEFT", summary, "BOTTOMLEFT", PAD_X, 0)
    summaryLine:SetPoint("BOTTOMRIGHT", summary, "BOTTOMRIGHT", -PAD_X, 0)
    summaryLine:SetHeight(1)

    -- Progress bar spacer — reserve vertical space so the scroll frame
    -- starts below the progress bar when it's present.  The bar itself
    -- is created lazily in Panel.Refresh; this just offsets the scroll.
    local PROGRESS_H = 42
    local progressSpacer = CreateFrame("Frame", nil, frame)
    progressSpacer:SetPoint("TOPLEFT", summary, "BOTTOMLEFT", 0, 0)
    progressSpacer:SetPoint("TOPRIGHT", summary, "BOTTOMRIGHT", 0, 0)
    progressSpacer:SetHeight(PROGRESS_H)

    -- Scroll frame ----------------------------------------------------
    scrollFrame = CreateFrame("ScrollFrame", "HCE_RequirementsPanelScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", progressSpacer, "BOTTOMLEFT", PAD_X, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, PAD_Y)

    contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(FRAME_WIDTH - PAD_X - 34, 10)
    scrollFrame:SetScrollChild(contentFrame)

    -- Restore position
    local s = db()
    frame:ClearAllPoints()
    frame:SetPoint(s.point or "CENTER", UIParent, s.relPoint or "CENTER", s.x or 0, s.y or 0)
    Panel.UpdatePinIcon()

    frame:Hide()
    return frame
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

local function UpdateMinimapPos()
    if not minimapButton then return end
    local angle = db().minimap.angle or 215
    local rad = math.rad(angle)
    local radius = 80
    local x = math.cos(rad) * radius
    local y = math.sin(rad) * radius
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
    elseif event == "BAG_UPDATE" then
        -- Bag contents changed -- refresh for herb pouch / consumable checks.
        C_Timer.After(0.6, Panel.Refresh)
    end
end)
