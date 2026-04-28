----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Talent / Spec Tracking
--
-- Starting at level 10, checks that the player is putting talent
-- points into the correct spec tree for their selected character.
--
-- WoW Classic talent API (1.15.x):
--   GetNumTalentTabs()                → 3
--   GetTalentTabInfo(tabIndex)        → name, texture, pointsSpent, …
--
-- Every class has exactly three talent tabs in a fixed order.
-- We map each character's `spec` field to the expected tab index
-- via a hardcoded class→spec→tabIndex table, using the canonical
-- English spec names from the CharacterData spreadsheet.
--
-- "Correct" means: the expected spec tree has a plurality of points
-- (strictly more than either other tree individually).  We don't
-- demand every single point goes into the spec tree — hybrids are
-- fine as long as the majority goes where it should.
--
-- Results are stored in HCE_CharDB.talentResults so the panel can
-- display a TALENTS section.  Chat warnings fire once per session
-- when the player's talent allocation first diverges.
----------------------------------------------------------------------

HCE = HCE or {}

local TC = {}
HCE.TalentCheck = TC

----------------------------------------------------------------------
-- Status constants (shared vocabulary)
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

TC.STATUS = { PASS = PASS, FAIL = FAIL, UNCHECKED = UNCHECKED }

----------------------------------------------------------------------
-- Spec → talent tab index mapping
--
-- Tab indices are stable across all Classic locales because they're
-- positional (1 / 2 / 3), not name-based.
--
-- Source: WoW Classic talent calculator
--   Warrior:  1=Arms,       2=Fury,       3=Protection
--   Rogue:    1=Assassination, 2=Combat,  3=Subtlety
--   Warlock:  1=Affliction,  2=Demonology, 3=Destruction
--   Druid:    1=Balance,     2=Feral,      3=Restoration
--   Hunter:   1=Beast Mastery, 2=Marksmanship, 3=Survival
--   Shaman:   1=Elemental,   2=Enhancement, 3=Restoration
--   Paladin:  1=Holy,        2=Protection,  3=Retribution
--   Priest:   1=Discipline,  2=Holy,        3=Shadow
--   Mage:     1=Arcane,      2=Fire,        3=Frost
----------------------------------------------------------------------

local SPEC_TAB = {
    WARRIOR = {
        ["Arms"]       = 1,
        ["Fury"]       = 2,
        ["Protection"] = 3,
    },
    ROGUE = {
        ["Assassination"] = 1,
        ["Combat"]        = 2,
        ["Subtlety"]      = 3,
    },
    WARLOCK = {
        ["Affliction"]  = 1,
        ["Demonology"]  = 2,
        ["Destruction"] = 3,
    },
    DRUID = {
        ["Balance"]     = 1,
        ["Feral"]       = 2,
        ["Restoration"] = 3,
    },
    HUNTER = {
        ["Beast Mastery"] = 1,
        ["Marksmanship"]  = 2,
        ["Survival"]      = 3,
    },
    SHAMAN = {
        ["Elemental"]   = 1,
        ["Enhancement"] = 2,
        ["Restoration"] = 3,
    },
    PALADIN = {
        ["Holy"]        = 1,
        ["Protection"]  = 2,
        ["Retribution"] = 3,
    },
    PRIEST = {
        ["Discipline"] = 1,
        ["Holy"]       = 2,
        ["Shadow"]     = 3,
    },
    MAGE = {
        ["Arcane"] = 1,
        ["Fire"]   = 2,
        ["Frost"]  = 3,
    },
}

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

--- Read the current talent point distribution.
--- @return table  { [1] = N, [2] = N, [3] = N }, total
local function ReadTalentPoints()
    local points = { 0, 0, 0 }
    local total  = 0
    local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 0
    for i = 1, math.min(numTabs, 3) do
        local _, _, spent = GetTalentTabInfo(i)
        points[i] = spent or 0
        total = total + points[i]
    end
    return points, total
end

--- How many talent points should the player have spent by this level?
--- In Classic, first talent point is at level 10, one per level.
--- @return number  expected total talent points
local function ExpectedPointsAtLevel(playerLevel)
    if playerLevel < 10 then return 0 end
    return playerLevel - 9
end

--- Get the localised name of a talent tab.
--- Falls back to "Tree <N>" if the API isn't available.
local function TabName(tabIndex)
    if GetTalentTabInfo then
        local name = GetTalentTabInfo(tabIndex)
        if name and name ~= "" then return name end
    end
    return "Tree " .. tabIndex
end

----------------------------------------------------------------------
-- Checking logic
----------------------------------------------------------------------

--- Run talent checks for the current character.
--- @return table  { status, detail, specTab, specPoints, totalSpent,
---                  expectedTotal, points = {N,N,N} }
function TC.CheckAll()
    local result = {
        status        = UNCHECKED,
        detail        = "",
        specTab       = nil,
        specPoints    = 0,
        totalSpent    = 0,
        expectedTotal = 0,
        points        = { 0, 0, 0 },
    }

    if not HCE_CharDB then return result end
    local key  = HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then return result end

    local _, playerClass = UnitClass("player")
    local playerLevel    = UnitLevel("player") or 1

    -- Before level 10: talents not available yet
    if playerLevel < 10 then
        result.status = "inactive"
        result.detail = "Talent tracking starts at level 10"
        return result
    end

    -- Resolve expected tab index
    local classSpecs = SPEC_TAB[playerClass]
    if not classSpecs then
        result.status = UNCHECKED
        result.detail = "Unknown class: " .. tostring(playerClass)
        return result
    end
    local expectedTab = classSpecs[char.spec]
    if not expectedTab then
        result.status = UNCHECKED
        result.detail = "Unknown spec: " .. tostring(char.spec)
        return result
    end

    result.specTab = expectedTab

    -- Read actual talent distribution
    local points, totalSpent = ReadTalentPoints()
    result.points      = points
    result.totalSpent  = totalSpent
    result.specPoints  = points[expectedTab]

    local expected = ExpectedPointsAtLevel(playerLevel)
    result.expectedTotal = expected

    -- Check 1: are there any unspent talent points?
    -- (This is informational, not a hard fail — the player might be
    -- saving them deliberately.)
    local unspent = expected - totalSpent

    -- Check 2: does the expected spec tree have a plurality?
    -- "Plurality" = strictly more points than each other tree.
    local specName     = TabName(expectedTab)
    local specPts      = points[expectedTab]
    local otherMax     = 0
    local otherMaxName = ""
    for i = 1, 3 do
        if i ~= expectedTab and points[i] > otherMax then
            otherMax     = points[i]
            otherMaxName = TabName(i)
        end
    end

    if totalSpent == 0 then
        -- No points spent at all
        if expected > 0 then
            result.status = FAIL
            result.detail = string.format(
                "No talent points spent yet (%d point%s available at lv %d)",
                expected, expected == 1 and "" or "s", playerLevel
            )
        else
            result.status = UNCHECKED
            result.detail = "No talent points available yet"
        end
    elseif specPts > otherMax then
        -- Spec tree has the plurality — PASS
        result.status = PASS
        if unspent > 0 then
            result.detail = string.format(
                "%s leads with %d/%d points (%d unspent)",
                specName, specPts, totalSpent, unspent
            )
        else
            result.detail = string.format(
                "%s leads with %d/%d points",
                specName, specPts, totalSpent
            )
        end
    elseif specPts == otherMax and specPts > 0 then
        -- Tied — soft warning, not a hard fail
        result.status = FAIL
        result.detail = string.format(
            "%s tied at %d points with %s — should lead",
            specName, specPts, otherMaxName
        )
    else
        -- Another tree has more points
        result.status = FAIL
        result.detail = string.format(
            "%s has only %d points — %s leads with %d",
            specName, specPts, otherMaxName, otherMax
        )
    end

    return result
end

--- Run a full check and store results in SavedVariables.
function TC.RunCheck()
    local result = TC.CheckAll()
    if HCE_CharDB then
        HCE_CharDB.talentResults = result
    end
    return result
end

--- Get stored results from the last check.
function TC.GetResults()
    return HCE_CharDB and HCE_CharDB.talentResults or {}
end

----------------------------------------------------------------------
-- Chat warnings (one-shot per session)
----------------------------------------------------------------------

local CHAT_PREFIX = "|cffe6b422[HCE]|r "

local warnedNoPoints = false
local warnedWrongSpec = false

--- Run checks and fire chat warnings for new problems.
function TC.CheckAndWarn()
    local oldResult = TC.GetResults()
    local oldStatus = oldResult.status

    local newResult = TC.RunCheck()

    if newResult.status == FAIL then
        if newResult.totalSpent == 0 and not warnedNoPoints then
            if not HCE.ChatWarningsEnabled or HCE.ChatWarningsEnabled() then
                DEFAULT_CHAT_FRAME:AddMessage(
                    CHAT_PREFIX .. "|cffffaa33Talents:|r " .. newResult.detail
                )
            end
            warnedNoPoints = true
        elseif newResult.totalSpent > 0 and not warnedWrongSpec then
            if not HCE.ChatWarningsEnabled or HCE.ChatWarningsEnabled() then
                DEFAULT_CHAT_FRAME:AddMessage(
                    CHAT_PREFIX .. "|cffffaa33Talent spec warning:|r " .. newResult.detail
                )
            end
            warnedWrongSpec = true
        end
    elseif newResult.status == PASS then
        -- Clear warning flags so we can re-warn if they respec
        warnedNoPoints  = false
        warnedWrongSpec = false
    end

    -- Refresh the panel to show updated indicators
    if HCE.RefreshPanel then HCE.RefreshPanel() end
end

--- Reset one-shot warning state (called on character pick / reset).
function TC.ResetWarnings()
    warnedNoPoints  = false
    warnedWrongSpec = false
end

----------------------------------------------------------------------
-- Slash command handler: /hce talents  (and /hce talent)
----------------------------------------------------------------------

function TC.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
        return
    end

    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char then
        HCE.Print("Character data not found.")
        return
    end

    local level = UnitLevel("player") or 1
    local result = TC.RunCheck()

    HCE.Print("Talent status (level " .. level .. ", spec: " .. char.spec .. "):")

    -- Show per-tree breakdown
    local points = result.points or { 0, 0, 0 }
    local numTabs = GetNumTalentTabs and GetNumTalentTabs() or 3
    for i = 1, math.min(numTabs, 3) do
        local name = TabName(i)
        local marker = ""
        if result.specTab and i == result.specTab then
            marker = " |cffffd100◄ required|r"
        end
        local ptsColor
        if result.specTab and i == result.specTab then
            ptsColor = points[i] > 0 and "|cff00ff00" or "|cffff5555"
        else
            ptsColor = "|cff888888"
        end
        HCE.Print("  " .. name .. ": " .. ptsColor .. points[i] .. "|r" .. marker)
    end

    -- Overall verdict
    local tag
    if result.status == PASS then
        tag = "|cff00ff00OK|r"
    elseif result.status == FAIL then
        tag = "|cffff5555BEHIND|r"
    elseif result.status == "inactive" then
        tag = "|cff888888inactive|r"
    else
        tag = "|cffffaa33???|r"
    end
    HCE.Print("  Verdict: " .. tag .. " — " .. (result.detail or ""))
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

local initialCheckDone = false

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer so SavedVariables and CharacterData are ready
        C_Timer.After(3.0, function()
            TC.RunCheck()
            initialCheckDone = true
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
        -- Second pass for chat warnings
        C_Timer.After(6.0, function()
            TC.CheckAndWarn()
        end)

    elseif event == "CHARACTER_POINTS_CHANGED" then
        if not initialCheckDone then return end
        -- Fired when talent points are spent or refunded
        C_Timer.After(0.3, function()
            TC.CheckAndWarn()
        end)

    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        if not initialCheckDone then return end
        -- Fired on talent group swap (dual spec in later expansions;
        -- in Classic this may not fire, but we register it for safety)
        C_Timer.After(0.5, function()
            TC.CheckAndWarn()
        end)

    elseif event == "PLAYER_LEVEL_UP" then
        if not initialCheckDone then return end
        -- New level = new expected talent points
        C_Timer.After(0.5, function()
            TC.CheckAndWarn()
        end)
    end
end)
