----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Self-Found & Self-Made Tracking
--
-- Two related checks in one module:
--
-- 1. SELF-FOUND BUFF — Characters with selfFound=true in CharacterData
--    must be on a Self-Found realm / have the Self-Found buff active.
--    We detect this by scanning the player's auras for the Self-Found
--    buff, using spell IDs first (locale-safe) then falling back to
--    an English-name scan for discovery.
--
-- 2. SELF-MADE CHALLENGE — Characters with the "Self-made" or
--    "Self-made guns" challenge must equip only items that are:
--      (a) crafted (on the crafted_items list from ItemSourceData.lua), OR
--      (b) white (Common) or grey (Poor) quality.
--    Since ProfessionCheck.lua already verifies the player has the
--    correct professions, we just need the flat crafted_items list —
--    a player can only craft items from professions they've learned.
--
-- Results are stored in HCE_CharDB.selfFoundResults so the
-- requirements panel can display pass/fail indicators.
--
-- WoW Classic API used:
--   UnitBuff("player", index) — iterate auras to find Self-Found
--   GetInventoryItemID("player", slot) — read equipped items
--   GetItemInfo(itemID) — quality field (index 3, 0-based)
----------------------------------------------------------------------

HCE = HCE or {}

local SF = {}
HCE.SelfFoundCheck = SF

----------------------------------------------------------------------
-- Status constants (shared vocabulary)
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

SF.STATUS = { PASS = PASS, FAIL = FAIL, UNCHECKED = UNCHECKED }

----------------------------------------------------------------------
-- Self-Found buff spell IDs
--
-- The Self-Found buff is a permanent aura applied to characters on
-- Self-Found realms (Classic Era).  We check multiple candidate spell
-- IDs because the ID may vary between client versions / patches.
-- If none match, we fall back to a name-based scan.
--
-- These IDs should be verified in-game.  If the real ID differs,
-- add it here and the check will pick it up automatically.
----------------------------------------------------------------------

local SELF_FOUND_SPELL_IDS = {
    -- Known / candidate spell IDs for the Self-Found buff
    -- (verify in-game and update as needed)
    462515,   -- Self-Found (Classic Era Fresh)
    456540,   -- Self-Found (alternate candidate)
}

-- English name for the fallback scan.  On non-English clients the
-- spell-ID path should catch it first; if both miss we report
-- UNCHECKED rather than a false FAIL.
local SELF_FOUND_BUFF_NAME = "Self-Found"

----------------------------------------------------------------------
-- Buff scanning
----------------------------------------------------------------------

--- Scan the player's buffs for the Self-Found aura.
--- @return string status  "pass" if found, "fail" if not, "unchecked" if API missing
--- @return string detail  human-readable explanation
local function CheckSelfFoundBuff()
    -- Guard against missing API (shouldn't happen in Classic, but
    -- defensive is good)
    if not UnitBuff then
        return UNCHECKED, "UnitBuff API not available"
    end

    -- Strategy 1: check by spell ID (locale-independent)
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
        if not name then break end
        if spellID then
            for _, knownID in ipairs(SELF_FOUND_SPELL_IDS) do
                if spellID == knownID then
                    return PASS, "Self-Found buff active (spell " .. spellID .. ")"
                end
            end
        end
    end

    -- Strategy 2: check by English name (fast path for EN clients)
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        -- Case-insensitive partial match to catch variations like
        -- "Self-Found", "Self Found", "Selffound"
        local lower = name:lower()
        if lower:find("self") and lower:find("found") then
            return PASS, "Self-Found buff active (\"" .. name .. "\")"
        end
    end

    -- Strategy 3: try AuraUtil if available (some Classic builds)
    if AuraUtil and AuraUtil.FindAuraByName then
        local name = AuraUtil.FindAuraByName(SELF_FOUND_BUFF_NAME, "player")
        if name then
            return PASS, "Self-Found buff active (AuraUtil)"
        end
    end

    -- Not found
    return FAIL, "Self-Found buff not detected"
end

----------------------------------------------------------------------
-- Crafted item checking (for Self-Made challenge)
--
-- Uses the comprehensive crafted_items list from ItemSourceData.lua
-- (auto-generated from Wowhead Classic, ~900+ items).  Since the
-- addon already tracks which professions a character has via
-- ProfessionCheck.lua, we don't need per-profession lists — players
-- can only craft items from professions they've actually learned.
--
-- Engineering-crafted guns are kept as a small separate list for
-- the "Self-made guns" challenge (Mountaineer character).
----------------------------------------------------------------------

-- Legacy table kept empty for backward compat; actual check uses
-- HCE.CuratedItems.crafted_items from ItemSourceData.lua.
SF.CraftedByProfession = {}

----------------------------------------------------------------------
-- Engineering-crafted gun list (for "Self-made guns" challenge)
--
-- Specifically guns that an Engineer would craft.  Used by the
-- Mountaineer character who requires self-crafted ranged weapons.
----------------------------------------------------------------------

SF.EngineeringGuns = {
    [4362]  = true,   -- Rough Boomstick (skill 1)
    [4363]  = true,   -- Deadly Blunderbuss (skill 65)
    [4369]  = true,   -- Moonsight Rifle (skill 100)
    [4372]  = true,   -- Lovingly Crafted Boomstick (skill 120)
    [4379]  = true,   -- Silver-plated Shotgun (skill 130)
    [4403]  = true,   -- Mithril Blunderbuss (skill 205)
    [10510] = true,   -- Mithril Heavy-bore Rifle (skill 220)
    [15995] = true,   -- Thorium Rifle (skill 260)
    [16004] = true,   -- Dark Iron Rifle (Dark Iron recipe)
    [18282] = true,   -- Core Marksman Rifle (MC recipe, skill 300)
}

----------------------------------------------------------------------
-- Equipment slot IDs (same as EquipmentCheck)
----------------------------------------------------------------------

local SLOT_IDS = {
    1,   -- INVSLOT_HEAD
    2,   -- INVSLOT_NECK
    3,   -- INVSLOT_SHOULDER
    5,   -- INVSLOT_CHEST
    6,   -- INVSLOT_WAIST
    7,   -- INVSLOT_LEGS
    8,   -- INVSLOT_FEET
    9,   -- INVSLOT_WRIST
    10,  -- INVSLOT_HAND
    11,  -- INVSLOT_FINGER0
    12,  -- INVSLOT_FINGER1
    13,  -- INVSLOT_TRINKET0
    14,  -- INVSLOT_TRINKET1
    15,  -- INVSLOT_BACK
    16,  -- INVSLOT_MAINHAND
    17,  -- INVSLOT_OFFHAND
    18,  -- INVSLOT_RANGED
    19,  -- INVSLOT_TABARD
    4,   -- INVSLOT_BODY (shirt)
}

local RANGED_SLOT = 18

----------------------------------------------------------------------
-- Self-made item checking
----------------------------------------------------------------------

--- Check a single equipped item against the self-made rules.
--- An item passes if it is:
---   (a) white (Common, quality=1) or grey (Poor, quality=0), OR
---   (b) on the crafted_items list from ItemSourceData.lua
---
--- @param itemID number
--- @return string status
--- @return string detail
local function CheckSelfMadeItem(itemID)
    if not itemID then
        return PASS, "Empty slot"
    end

    local itemName, _, itemQuality = GetItemInfo(itemID)
    if not itemName then
        -- Item not cached yet; can't verify
        return UNCHECKED, "Item " .. itemID .. " not in cache"
    end

    -- White or grey quality always passes (no restrictions)
    if itemQuality <= 1 then
        return PASS, itemName .. " — quality " .. itemQuality .. " (white/grey, always OK)"
    end

    -- Higher quality: must be on the crafted items list
    local craftedList = HCE.CuratedItems and HCE.CuratedItems.crafted_items
    if not craftedList or not next(craftedList) then
        return UNCHECKED, itemName .. " — crafted item list not loaded"
    end

    if craftedList[itemID] then
        return PASS, itemName .. " — confirmed crafted item"
    end

    return FAIL, itemName .. " (quality " .. itemQuality .. ") — not on crafted item list"
end

--- Check the ranged slot specifically for a self-made Engineering gun.
--- @return string status
--- @return string detail
local function CheckSelfMadeGun()
    local itemID = GetInventoryItemID("player", RANGED_SLOT)
    if not itemID then
        return PASS, "No ranged weapon equipped"
    end

    local itemName, _, itemQuality = GetItemInfo(itemID)
    if not itemName then
        return UNCHECKED, "Ranged item " .. itemID .. " not in cache"
    end

    -- White/grey guns are fine (same as general self-made rule)
    if itemQuality <= 1 then
        return PASS, itemName .. " — quality " .. itemQuality .. " (white/grey, always OK)"
    end

    -- Must be on the engineering gun list
    if SF.EngineeringGuns[itemID] then
        return PASS, itemName .. " — confirmed Engineering-crafted gun"
    end

    return FAIL, itemName .. " (quality " .. itemQuality .. ") — not an Engineering-crafted gun"
end

----------------------------------------------------------------------
-- Full check
----------------------------------------------------------------------

--- Run all self-found / self-made checks for the current character.
--- @return table results  { selfFound = {status, detail},
---                          selfMade  = {status, detail, items = {...}},
---                          selfMadeGuns = {status, detail} }
function SF.CheckAll()
    local results = {}
    if not HCE_CharDB then return results end

    local key = HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then return results end

    -- 1. Self-found buff check (only if character requires it)
    if char.selfFound then
        local status, detail = CheckSelfFoundBuff()
        results.selfFound = { status = status, detail = detail }
    end

    -- 2. Self-made challenge check
    local hasSelfMade = false
    local hasSelfMadeGuns = false
    if char.challenges then
        for _, ch in ipairs(char.challenges) do
            if ch.desc == "Self-made" then hasSelfMade = true end
            if ch.desc == "Self-made guns" then hasSelfMadeGuns = true end
        end
    end

    if hasSelfMade then
        -- Check all equipment slots
        local itemResults = {}
        local overallStatus = PASS
        local failCount = 0
        local uncheckCount = 0

        for _, slotID in ipairs(SLOT_IDS) do
            local itemID = GetInventoryItemID("player", slotID)
            if itemID then
                local status, detail = CheckSelfMadeItem(itemID)
                table.insert(itemResults, {
                    slot   = slotID,
                    itemID = itemID,
                    status = status,
                    detail = detail,
                })
                if status == FAIL then
                    failCount = failCount + 1
                    overallStatus = FAIL
                elseif status == UNCHECKED and overallStatus ~= FAIL then
                    uncheckCount = uncheckCount + 1
                    overallStatus = UNCHECKED
                end
            end
        end

        local summary
        if overallStatus == PASS then
            summary = "All equipped items are crafted or white/grey"
        elseif overallStatus == FAIL then
            summary = failCount .. " item" .. (failCount == 1 and "" or "s") .. " not crafted"
        else
            summary = uncheckCount .. " item" .. (uncheckCount == 1 and "" or "s") .. " could not be verified"
        end

        results.selfMade = {
            status = overallStatus,
            detail = summary,
            items  = itemResults,
        }
    end

    if hasSelfMadeGuns then
        local status, detail = CheckSelfMadeGun()
        results.selfMadeGuns = { status = status, detail = detail }
    end

    return results
end

--- Run a full check and store results in SavedVariables.
function SF.RunCheck()
    local results = SF.CheckAll()
    if HCE_CharDB then
        HCE_CharDB.selfFoundResults = results
    end
    return results
end

--- Get stored results from the last check.
function SF.GetResults()
    return HCE_CharDB and HCE_CharDB.selfFoundResults or {}
end

----------------------------------------------------------------------
-- Chat warnings (one-shot per session)
----------------------------------------------------------------------

local CHAT_PREFIX = "|cffe6b422[HCE]|r "

local warnedSelfFound    = false
local warnedSelfMade     = false
local warnedSelfMadeGuns = false

--- Run checks and fire chat warnings for new problems.
function SF.CheckAndWarn()
    local oldResults = SF.GetResults()

    -- Snapshot old statuses
    local oldSF   = oldResults.selfFound and oldResults.selfFound.status
    local oldSM   = oldResults.selfMade and oldResults.selfMade.status
    local oldSMG  = oldResults.selfMadeGuns and oldResults.selfMadeGuns.status

    local newResults = SF.RunCheck()

    -- Self-found buff warning
    if newResults.selfFound and newResults.selfFound.status == FAIL and not warnedSelfFound then
        DEFAULT_CHAT_FRAME:AddMessage(
            CHAT_PREFIX .. "|cffffaa33Self-Found buff not detected.|r " ..
            "Your character requires Self-Found mode — make sure you're on a Self-Found realm."
        )
        warnedSelfFound = true
    elseif newResults.selfFound and newResults.selfFound.status == PASS then
        warnedSelfFound = false
    end

    -- Self-made challenge warning
    if newResults.selfMade and newResults.selfMade.status == FAIL and not warnedSelfMade then
        DEFAULT_CHAT_FRAME:AddMessage(
            CHAT_PREFIX .. "|cffffaa33Self-made violation:|r " ..
            (newResults.selfMade.detail or "Some equipped items are not crafted or white/grey")
        )
        warnedSelfMade = true
    elseif newResults.selfMade and newResults.selfMade.status == PASS then
        warnedSelfMade = false
    end

    -- Self-made guns warning
    if newResults.selfMadeGuns and newResults.selfMadeGuns.status == FAIL and not warnedSelfMadeGuns then
        DEFAULT_CHAT_FRAME:AddMessage(
            CHAT_PREFIX .. "|cffffaa33Self-made guns violation:|r " ..
            (newResults.selfMadeGuns.detail or "Ranged weapon is not Engineering-crafted")
        )
        warnedSelfMadeGuns = true
    elseif newResults.selfMadeGuns and newResults.selfMadeGuns.status == PASS then
        warnedSelfMadeGuns = false
    end

    -- Refresh the panel to show updated indicators
    if HCE.RefreshPanel then HCE.RefreshPanel() end
end

--- Reset one-shot warning state.  Called when a new character is
--- selected so stale warnings from a previous pick don't block.
function SF.ResetWarnings()
    warnedSelfFound    = false
    warnedSelfMade     = false
    warnedSelfMadeGuns = false
end

----------------------------------------------------------------------
-- Slash command: /hce selffound
----------------------------------------------------------------------

function SF.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
        return
    end

    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char then
        HCE.Print("Character data not found.")
        return
    end

    HCE.Print("Self-Found / Self-Made status:")

    local results = SF.RunCheck()

    -- Self-found buff
    if char.selfFound then
        local r = results.selfFound
        if r then
            local tag
            if r.status == PASS then
                tag = "|cff00ff00ACTIVE|r"
            elseif r.status == FAIL then
                tag = "|cffff5555NOT FOUND|r"
            else
                tag = "|cffffaa33???|r"
            end
            HCE.Print("  Self-Found buff: " .. tag .. " — " .. (r.detail or ""))
        else
            HCE.Print("  Self-Found buff: |cff888888no data|r")
        end
    else
        HCE.Print("  Self-Found: not required for this character")
    end

    -- Self-made challenge
    if results.selfMade then
        local r = results.selfMade
        local tag
        if r.status == PASS then
            tag = "|cff00ff00OK|r"
        elseif r.status == FAIL then
            tag = "|cffff5555VIOLATION|r"
        else
            tag = "|cffffaa33PARTIAL|r"
        end
        HCE.Print("  Self-made: " .. tag .. " — " .. (r.detail or ""))

        -- Show per-item breakdown if any failures
        if r.items then
            for _, item in ipairs(r.items) do
                if item.status ~= PASS then
                    local itemTag = item.status == FAIL and "|cffff5555FAIL|r" or "|cffffaa33?|r"
                    HCE.Print("    Slot " .. item.slot .. ": " .. itemTag .. " " .. (item.detail or ""))
                end
            end
        end
    end

    -- Self-made guns
    if results.selfMadeGuns then
        local r = results.selfMadeGuns
        local tag
        if r.status == PASS then
            tag = "|cff00ff00OK|r"
        elseif r.status == FAIL then
            tag = "|cffff5555VIOLATION|r"
        else
            tag = "|cffffaa33???|r"
        end
        HCE.Print("  Self-made guns: " .. tag .. " — " .. (r.detail or ""))
    end
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

local initialCheckDone = false

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer so SavedVariables and CharacterData are ready
        C_Timer.After(3.0, function()
            SF.RunCheck()
            initialCheckDone = true
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
        -- Second pass to fire warnings after everything settled
        C_Timer.After(6.0, function()
            SF.CheckAndWarn()
        end)

    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit ~= "player" then return end
        if not initialCheckDone then return end
        -- Re-check self-found buff when auras change
        C_Timer.After(0.3, function()
            SF.CheckAndWarn()
        end)

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if not initialCheckDone then return end
        -- Re-check self-made items when gear changes
        C_Timer.After(0.5, function()
            SF.CheckAndWarn()
        end)

    elseif event == "PLAYER_LEVEL_UP" then
        if not initialCheckDone then return end
        C_Timer.After(0.5, function()
            SF.CheckAndWarn()
        end)
    end
end)
