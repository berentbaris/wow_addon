----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Progress Summary
--
-- Collects check results from every tracking module and presents a
-- unified checklist + percentage-completion view.
--
-- Two display modes:
--   1) A compact progress bar embedded at the top of RequirementsPanel
--      (called by Panel.Refresh via HCE.Progress.BuildBar / UpdateBar)
--   2) A full chat printout via /hce progress
--
-- Each requirement is classified as one of:
--   PASS      — active and verified met
--   FAIL      — active and verified NOT met
--   UNCHECKED — active but can't verify yet (incomplete curated data, etc.)
--   INACTIVE  — not yet level-gated in
----------------------------------------------------------------------

HCE = HCE or {}

local Progress = {}
HCE.Progress = Progress

----------------------------------------------------------------------
-- Status constants (mirror the values used by check modules)
----------------------------------------------------------------------

local S_PASS      = "pass"
local S_FAIL      = "fail"
local S_UNCHECKED = "unchecked"
local S_INACTIVE  = "inactive"

----------------------------------------------------------------------
-- Colour palette
----------------------------------------------------------------------

local COL = {
    PASS      = { r = 0.30, g = 0.90, b = 0.35, hex = "4de64d" },
    FAIL      = { r = 1.00, g = 0.35, b = 0.30, hex = "ff5a4c" },
    UNCHECKED = { r = 0.65, g = 0.65, b = 0.50, hex = "a5a582" },
    INACTIVE  = { r = 0.35, g = 0.35, b = 0.35, hex = "595959" },
    GOLD      = { r = 0.90, g = 0.78, b = 0.25, hex = "e6c73f" },
    WHITE     = { r = 0.93, g = 0.93, b = 0.93, hex = "ededed" },
    GREY      = { r = 0.55, g = 0.55, b = 0.55, hex = "8c8c8c" },
}

----------------------------------------------------------------------
-- Collect all requirement statuses into a flat list
----------------------------------------------------------------------
-- Returns { items = { {name, category, status, detail}, ... },
--           counts = { pass, fail, unchecked, inactive, total } }

function Progress.Collect()
    local items = {}
    local counts = { pass = 0, fail = 0, unchecked = 0, inactive = 0, total = 0 }

    local key = HCE_CharDB and HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then
        return { items = items, counts = counts }
    end

    local playerLevel = UnitLevel and UnitLevel("player") or 1

    -- Helper: add an item and bump counts
    local function add(name, category, status, detail)
        table.insert(items, {
            name     = name,
            category = category,
            status   = status,
            detail   = detail or "",
        })
        counts.total = counts.total + 1
        if status == S_PASS then
            counts.pass = counts.pass + 1
        elseif status == S_FAIL then
            counts.fail = counts.fail + 1
        elseif status == S_UNCHECKED then
            counts.unchecked = counts.unchecked + 1
        else
            counts.inactive = counts.inactive + 1
        end
    end

    -- 1) Self-found
    if char.selfFound then
        local sfResults = HCE.SelfFoundCheck and HCE.SelfFoundCheck.GetResults and HCE.SelfFoundCheck.GetResults() or {}
        local sfBuff = sfResults.selfFound
        if sfBuff then
            add("Self-found", "General", sfBuff.status or S_UNCHECKED, sfBuff.detail)
        else
            add("Self-found", "General", S_UNCHECKED, "Waiting for data")
        end
    end

    -- 2) Professions (active from level 5)
    local profResults = HCE.ProfessionCheck and HCE.ProfessionCheck.GetResults and HCE.ProfessionCheck.GetResults() or {}
    if char.professions then
        for _, profName in ipairs(char.professions) do
            if playerLevel < 5 then
                add(profName, "Professions", S_INACTIVE, "Unlocks at level 5")
            else
                local res = profResults[profName]
                if res then
                    add(profName, "Professions", res.status or S_UNCHECKED, res.detail)
                else
                    add(profName, "Professions", S_UNCHECKED, "No data")
                end
            end
        end
    end

    -- 3) Talent/spec (active from level 10)
    if char.spec then
        local talentResult = HCE.TalentCheck and HCE.TalentCheck.GetResults and HCE.TalentCheck.GetResults() or {}
        -- Spec plurality row
        if playerLevel < 10 then
            add("Spec: " .. char.spec, "Talents", S_INACTIVE, "Unlocks at level 10")
        elseif talentResult.specStatus then
            add("Spec: " .. char.spec, "Talents", talentResult.specStatus, talentResult.specDetail or talentResult.detail)
        elseif talentResult.status then
            add("Spec: " .. char.spec, "Talents", talentResult.status, talentResult.detail)
        else
            add("Spec: " .. char.spec, "Talents", S_UNCHECKED, "No data")
        end
        -- Per-talent requirement rows (read from data file, overlay check results)
        local rawReqs   = HCE.TalentRequirements and HCE.TalentRequirements[char.name]
        local checkReqs = talentResult.talentReqs
        if rawReqs then
            for ri, req in ipairs(rawReqs) do
                local chk = checkReqs and checkReqs[ri]
                if playerLevel < req.level then
                    add(req.name, "Talents", S_INACTIVE, "Unlocks at level " .. req.level)
                elseif chk and chk.status then
                    add(req.name, "Talents", chk.status, chk.detail)
                else
                    add(req.name, "Talents", S_UNCHECKED, "Talent check pending")
                end
            end
        end
    end

    -- 4) Equipment
    local eqResults = HCE.EquipmentCheck and HCE.EquipmentCheck.GetResults and HCE.EquipmentCheck.GetResults() or {}
    local eqStatus  = HCE.EquipmentCheck and HCE.EquipmentCheck.STATUS or {}
    for i, eq in ipairs(char.equipment or {}) do
        if playerLevel < eq.level then
            add(eq.desc, "Equipment", S_INACTIVE, "Unlocks at level " .. eq.level)
        else
            local res = eqResults[i]
            if res then
                -- Normalise status strings from EquipmentCheck constants
                local st = S_UNCHECKED
                if res.status == (eqStatus.PASS or "pass") then
                    st = S_PASS
                elseif res.status == (eqStatus.FAIL or "fail") then
                    st = S_FAIL
                elseif res.status == (eqStatus.UNCHECKED or "unchecked") then
                    st = S_UNCHECKED
                end
                add(eq.desc, "Equipment", st, res.detail)
            else
                add(eq.desc, "Equipment", S_UNCHECKED, "Not checked")
            end
        end
    end

    -- 5) Challenges
    local chResults = HCE.ChallengeCheck and HCE.ChallengeCheck.GetResults and HCE.ChallengeCheck.GetResults() or {}
    local chStatus  = HCE.ChallengeCheck and HCE.ChallengeCheck.STATUS or {}
    for i, ch in ipairs(char.challenges or {}) do
        if playerLevel < ch.level then
            add(ch.desc, "Challenges", S_INACTIVE, "Unlocks at level " .. ch.level)
        else
            local res = chResults[i]
            if res then
                local st = S_UNCHECKED
                if res.status == (chStatus.PASS or "pass") then
                    st = S_PASS
                elseif res.status == (chStatus.FAIL or "fail") then
                    st = S_FAIL
                elseif res.status == (chStatus.UNCHECKED or "unchecked") then
                    st = S_UNCHECKED
                end
                add(ch.desc, "Challenges", st, res.detail)
            else
                add(ch.desc, "Challenges", S_UNCHECKED, "Not checked")
            end
        end
    end

    -- 6) Companion
    if char.companion then
        if playerLevel < char.companion.level then
            add("Companion: " .. char.companion.desc, "Companions", S_INACTIVE,
                "Unlocks at level " .. char.companion.level)
        else
            local compResult = HCE_CharDB and HCE_CharDB.companionResults
            if compResult and compResult.status then
                add("Companion: " .. char.companion.desc, "Companions",
                    compResult.status, compResult.detail)
            else
                add("Companion: " .. char.companion.desc, "Companions",
                    S_UNCHECKED, "No data")
            end
        end
    end

    -- 7) Hunter pet
    if char.pet then
        if playerLevel < char.pet.level then
            add("Hunter pet: " .. char.pet.desc, "Companions", S_INACTIVE,
                "Unlocks at level " .. char.pet.level)
        else
            local hpResult = HCE_CharDB and HCE_CharDB.hunterPetResults
            if hpResult and hpResult.status then
                add("Hunter pet: " .. char.pet.desc, "Companions",
                    hpResult.status, hpResult.detail)
            else
                add("Hunter pet: " .. char.pet.desc, "Companions",
                    S_UNCHECKED, "No data")
            end
        end
    end

    -- 8) Mount
    if char.mount then
        if playerLevel < char.mount.level then
            add("Mount: " .. char.mount.desc, "Companions", S_INACTIVE,
                "Unlocks at level " .. char.mount.level)
        else
            local mtResult = HCE_CharDB and HCE_CharDB.mountResults
            if mtResult and mtResult.status then
                add("Mount: " .. char.mount.desc, "Companions",
                    mtResult.status, mtResult.detail)
            else
                add("Mount: " .. char.mount.desc, "Companions",
                    S_UNCHECKED, "No data")
            end
        end
    end

    return { items = items, counts = counts }
end

----------------------------------------------------------------------
-- Percentage calculation
----------------------------------------------------------------------
-- "Completion" = PASS / (total active).  Inactive reqs don't count
-- against you.  UNCHECKED reqs count as neither pass nor fail.

function Progress.Percentage(counts)
    local active = counts.pass + counts.fail + counts.unchecked
    if active == 0 then return 100 end   -- nothing to check = all good
    return math.floor((counts.pass / active) * 100 + 0.5)
end

----------------------------------------------------------------------
-- Visual progress bar for RequirementsPanel
----------------------------------------------------------------------
-- The bar is a thin stacked horizontal bar showing proportional
-- green / red / amber / grey segments.  Created once and updated
-- each Panel.Refresh.

local barFrame, barSegments, barLabel, barPctLabel

function Progress.BuildBar(parent, anchorFrame, yOffset)
    if barFrame then return barFrame end

    local BAR_H = 12
    local PAD_X = 14

    barFrame = CreateFrame("Frame", nil, parent)
    barFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", PAD_X, yOffset or -4)
    barFrame:SetPoint("RIGHT", parent, "RIGHT", -PAD_X, 0)
    barFrame:SetHeight(BAR_H + 26)  -- bar + labels

    -- "Progress" label
    barLabel = barFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    barLabel:SetPoint("TOPLEFT", barFrame, "TOPLEFT", 0, 0)
    barLabel:SetTextColor(COL.GOLD.r, COL.GOLD.g, COL.GOLD.b)
    barLabel:SetText("Progress")

    -- Percentage label (right-aligned)
    barPctLabel = barFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    barPctLabel:SetPoint("TOPRIGHT", barFrame, "TOPRIGHT", 0, 0)
    barPctLabel:SetJustifyH("RIGHT")
    barPctLabel:SetTextColor(COL.WHITE.r, COL.WHITE.g, COL.WHITE.b)
    barPctLabel:SetText("0%")

    -- Bar background
    local barBg = CreateFrame("Frame", nil, barFrame, "BackdropTemplate")
    barBg:SetPoint("TOPLEFT", barLabel, "BOTTOMLEFT", 0, -3)
    barBg:SetPoint("RIGHT", barFrame, "RIGHT", 0, 0)
    barBg:SetHeight(BAR_H)
    if barBg.SetBackdrop then
        barBg:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        barBg:SetBackdropColor(0.08, 0.08, 0.10, 0.90)
        barBg:SetBackdropBorderColor(0.30, 0.30, 0.30, 0.60)
    end
    barFrame.barBg = barBg

    -- Stacked segment textures: pass, fail, unchecked, inactive
    -- They're anchored left-to-right by width proportion
    barSegments = {}
    local segDefs = {
        { key = "pass",      col = COL.PASS },
        { key = "fail",      col = COL.FAIL },
        { key = "unchecked", col = COL.UNCHECKED },
        { key = "inactive",  col = COL.INACTIVE },
    }
    for _, def in ipairs(segDefs) do
        local seg = barBg:CreateTexture(nil, "ARTWORK")
        seg:SetColorTexture(def.col.r, def.col.g, def.col.b, 0.85)
        seg:SetHeight(BAR_H - 2)
        seg:Hide()
        barSegments[def.key] = seg
    end

    -- Count labels below the bar
    local countRow = barFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countRow:SetPoint("TOPLEFT", barBg, "BOTTOMLEFT", 0, -2)
    countRow:SetPoint("RIGHT", barFrame, "RIGHT", 0, 0)
    countRow:SetJustifyH("LEFT")
    countRow:SetTextColor(COL.GREY.r, COL.GREY.g, COL.GREY.b)
    barFrame.countRow = countRow

    return barFrame
end

function Progress.UpdateBar()
    if not barFrame then return end

    local data = Progress.Collect()
    local c = data.counts
    local pct = Progress.Percentage(c)

    -- Update percentage label with colour based on value
    if pct >= 80 then
        barPctLabel:SetTextColor(COL.PASS.r, COL.PASS.g, COL.PASS.b)
    elseif pct >= 50 then
        barPctLabel:SetTextColor(COL.GOLD.r, COL.GOLD.g, COL.GOLD.b)
    else
        barPctLabel:SetTextColor(COL.FAIL.r, COL.FAIL.g, COL.FAIL.b)
    end
    barPctLabel:SetText(pct .. "%")

    -- Update the stacked bar segments
    local total = c.total
    if total == 0 then total = 1 end   -- avoid div-by-zero

    local barBg = barFrame.barBg
    local barW = barBg:GetWidth() - 2   -- subtract border insets
    if barW <= 0 then barW = 200 end    -- fallback before first layout

    local order = { "pass", "fail", "unchecked", "inactive" }
    local xOff = 1   -- start inside the left border
    for _, key in ipairs(order) do
        local seg = barSegments[key]
        local count = c[key] or 0
        if count > 0 then
            local w = math.max(2, math.floor((count / total) * barW + 0.5))
            -- Clamp so segments don't overflow
            if xOff + w > barW + 1 then w = barW + 1 - xOff end
            if w > 0 then
                seg:ClearAllPoints()
                seg:SetPoint("TOPLEFT", barBg, "TOPLEFT", xOff, -1)
                seg:SetWidth(w)
                seg:Show()
                xOff = xOff + w
            else
                seg:Hide()
            end
        else
            seg:Hide()
        end
    end

    -- Count summary text
    local parts = {}
    if c.pass > 0 then
        table.insert(parts, "|cff" .. COL.PASS.hex .. c.pass .. " met|r")
    end
    if c.fail > 0 then
        table.insert(parts, "|cff" .. COL.FAIL.hex .. c.fail .. " broken|r")
    end
    if c.unchecked > 0 then
        table.insert(parts, "|cff" .. COL.UNCHECKED.hex .. c.unchecked .. " unverified|r")
    end
    if c.inactive > 0 then
        table.insert(parts, "|cff" .. COL.INACTIVE.hex .. c.inactive .. " locked|r")
    end
    barFrame.countRow:SetText(table.concat(parts, "  "))
end

----------------------------------------------------------------------
-- Get the total height consumed by the bar widget
----------------------------------------------------------------------

function Progress.GetBarHeight()
    return 38   -- label + bar + count row + padding
end

----------------------------------------------------------------------
-- Chat printout: /hce progress
----------------------------------------------------------------------

function Progress.PrintStatus()
    local key = HCE_CharDB and HCE_CharDB.selectedCharacter
    if not key then
        HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
        return
    end
    local char = HCE.GetCharacter and HCE.GetCharacter(key)
    if not char then
        HCE.Print("Character data not found.")
        return
    end

    local data = Progress.Collect()
    local c = data.counts
    local pct = Progress.Percentage(c)

    -- Header
    local classStr = char.class:sub(1, 1) .. char.class:sub(2):lower()
    HCE.Print("--- " .. char.name .. " (" .. char.spec .. " " .. classStr .. ") Progress ---")

    -- Percentage line
    local pctCol
    if pct >= 80 then pctCol = COL.PASS.hex
    elseif pct >= 50 then pctCol = COL.GOLD.hex
    else pctCol = COL.FAIL.hex
    end
    HCE.Print("|cff" .. pctCol .. pct .. "% complete|r  ("
        .. c.pass .. " met, "
        .. c.fail .. " broken, "
        .. c.unchecked .. " unverified, "
        .. c.inactive .. " locked)")

    -- Visual ASCII bar (20 chars wide)
    local barLen = 20
    local active = c.pass + c.fail + c.unchecked
    local total  = c.total
    if total == 0 then total = 1 end

    local nPass = math.floor((c.pass / total) * barLen + 0.5)
    local nFail = math.floor((c.fail / total) * barLen + 0.5)
    local nUnch = math.floor((c.unchecked / total) * barLen + 0.5)
    local nInac = barLen - nPass - nFail - nUnch
    if nInac < 0 then nInac = 0 end

    local bar = "|cff" .. COL.PASS.hex .. string.rep("|", nPass) .. "|r"
             .. "|cff" .. COL.FAIL.hex .. string.rep("|", nFail) .. "|r"
             .. "|cff" .. COL.UNCHECKED.hex .. string.rep("|", nUnch) .. "|r"
             .. "|cff" .. COL.INACTIVE.hex .. string.rep(".", nInac) .. "|r"
    HCE.Print("[" .. bar .. "]")

    -- Per-item checklist, grouped by category
    local lastCat = nil
    for _, item in ipairs(data.items) do
        if item.category ~= lastCat then
            lastCat = item.category
            HCE.Print("|cff" .. COL.GOLD.hex .. item.category .. "|r")
        end
        local icon, col
        if item.status == S_PASS then
            icon = "\226\156\147"   -- ✓
            col  = COL.PASS.hex
        elseif item.status == S_FAIL then
            icon = "\226\156\151"   -- ✗
            col  = COL.FAIL.hex
        elseif item.status == S_UNCHECKED then
            icon = "?"
            col  = COL.UNCHECKED.hex
        else
            icon = "\194\183"       -- · (middle dot)
            col  = COL.INACTIVE.hex
        end
        local detail = ""
        if item.detail and item.detail ~= "" and item.status ~= S_INACTIVE then
            -- Truncate long details for chat readability
            local d = item.detail
            if #d > 60 then d = d:sub(1, 57) .. "..." end
            detail = " |cff" .. COL.GREY.hex .. "(" .. d .. ")|r"
        end
        HCE.Print("  |cff" .. col .. icon .. "|r " .. item.name .. detail)
    end
end
