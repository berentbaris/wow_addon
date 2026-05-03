----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Challenge Tracking (Rule Engine)
--
-- Each challenge type from CharacterData gets a checker function that
-- evaluates the player's CURRENT STATE against the challenge rules.
-- This is the central engine; individual checkers range from trivial
-- (quality-based gear checks) to zone-based (ZoneCheck.lua) to
-- item-source (Renegade/Partisan/Off-the-shelf using curated lists
-- from ItemSourceData.lua).
--
-- Challenges covered by other modules:
--   Self-made, Self-made guns → SelfFoundCheck.lua
--   Homebound, zone visits    → ZoneCheck.lua
--   Item source data          → ItemSourceData.lua
--
-- Results are stored in HCE_CharDB.challengeResults so the
-- RequirementsPanel can show pass/fail/unchecked indicators.
----------------------------------------------------------------------

HCE = HCE or {}

local CC = {}
HCE.ChallengeCheck = CC

----------------------------------------------------------------------
-- Status constants (same vocabulary as EquipmentCheck)
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

CC.STATUS = {
    PASS      = PASS,
    FAIL      = FAIL,
    UNCHECKED = UNCHECKED,
}

----------------------------------------------------------------------
-- WoW Classic inventory slot IDs (duplicated from EquipmentCheck so
-- this module is self-contained — they're just integer constants)
----------------------------------------------------------------------

local SLOT = {
    HEAD      =  1,
    NECK      =  2,
    SHOULDER  =  3,
    SHIRT     =  4,
    CHEST     =  5,
    WAIST     =  6,
    LEGS      =  7,
    FEET      =  8,
    WRIST     =  9,
    HANDS     = 10,
    FINGER0   = 11,
    FINGER1   = 12,
    TRINKET0  = 13,
    TRINKET1  = 14,
    BACK      = 15,
    MAINHAND  = 16,
    OFFHAND   = 17,
    RANGED    = 18,
    TABARD    = 19,
}

-- Armor classID = 4, weapon classID = 2 (from GetItemInfo)
local ARMOR_CLASS  = 4
local WEAPON_CLASS = 2

local ARMOR_SUB = {
    MISC    = 0,
    CLOTH   = 1,
    LEATHER = 2,
    MAIL    = 3,
    PLATE   = 4,
    SHIELD  = 6,
}

----------------------------------------------------------------------
-- Equipment snapshot helper — reuses EquipmentCheck if available,
-- otherwise builds its own (defensive, should never actually run
-- because EquipmentCheck loads first)
----------------------------------------------------------------------

local function getEquipSnapshot()
    if HCE.EquipmentCheck and HCE.EquipmentCheck.Snapshot then
        return HCE.EquipmentCheck.Snapshot()
    end
    -- Fallback: build a minimal snapshot ourselves
    local state = {}
    for _, slotID in pairs(SLOT) do
        local itemID = GetInventoryItemID("player", slotID)
        if itemID then
            local name, link, quality, _, _, _, _,
                  _, equipLoc, _, _, classID, subclassID = GetItemInfo(itemID)
            if classID then
                state[slotID] = {
                    id         = itemID,
                    name       = name or "",
                    quality    = quality or 0,
                    classID    = classID,
                    subclassID = subclassID,
                    equipLoc   = equipLoc or "",
                }
            end
        end
    end
    return state
end

----------------------------------------------------------------------
-- Armor slot set — slots where armor can be worn (excludes shirt,
-- tabard, weapons, trinkets, rings, neck).  Used by quality and
-- armor-type challenges that only care about actual armor pieces.
----------------------------------------------------------------------

local ARMOR_SLOTS = {
    SLOT.HEAD, SLOT.SHOULDER, SLOT.CHEST, SLOT.WAIST,
    SLOT.LEGS, SLOT.FEET, SLOT.WRIST, SLOT.HANDS, SLOT.BACK,
}

-- ALL gear slots — every slot that can hold a quality-bearing item.
-- Used by quality-based challenges (White Knight, Exotic, etc.).
-- Excludes shirt and tabard since those are cosmetic.
local GEAR_SLOTS = {
    SLOT.HEAD, SLOT.NECK, SLOT.SHOULDER, SLOT.CHEST,
    SLOT.WAIST, SLOT.LEGS, SLOT.FEET, SLOT.WRIST, SLOT.HANDS,
    SLOT.FINGER0, SLOT.FINGER1, SLOT.TRINKET0, SLOT.TRINKET1,
    SLOT.BACK, SLOT.MAINHAND, SLOT.OFFHAND, SLOT.RANGED,
}

----------------------------------------------------------------------
-- Challenge rule registry
--
-- Maps challenge description strings (from CharacterData.challenges)
-- to checker functions.  Each function receives no arguments (it
-- reads from the WoW API directly) and returns (status, detail).
--
-- Matching is case-insensitive.
----------------------------------------------------------------------

local rules = {}

local function R(pattern, fn)
    rules[pattern:lower()] = fn
end

----------------------------------------------------------------------
-- QUALITY-BASED CHALLENGES
----------------------------------------------------------------------

--- Helper: scan all gear slots and flag items whose quality violates
--- a predicate.  Returns (status, detail).
--- @param badQualityFn  function(quality) -> bool  true if this quality is forbidden
--- @param ruleName      string  for the detail message
local function qualityGearCheck(badQualityFn, ruleName)
    local state = getEquipSnapshot()
    local violations = {}
    local checked = 0

    for _, sid in ipairs(GEAR_SLOTS) do
        local item = state[sid]
        if item then
            checked = checked + 1
            if badQualityFn(item.quality) then
                local qLabel
                if item.quality == 1 then qLabel = "common"
                elseif item.quality == 2 then qLabel = "uncommon"
                elseif item.quality == 3 then qLabel = "rare"
                elseif item.quality == 4 then qLabel = "epic"
                elseif item.quality == 0 then qLabel = "poor"
                else qLabel = "q" .. item.quality end
                table.insert(violations, item.name .. " (" .. qLabel .. ")")
            end
        end
    end

    if #violations > 0 then
        local detail = ruleName .. " — " .. #violations .. " violation"
            .. (#violations > 1 and "s" or "") .. ": "
            .. table.concat(violations, ", ")
        return FAIL, detail
    end

    if checked == 0 then
        return PASS, "No gear equipped"
    end

    return PASS, "All " .. checked .. " equipped items meet the " .. ruleName .. " rule"
end

-- White knight: only white (1) or grey (0) gear
R("White knight", function()
    return qualityGearCheck(
        function(q) return q >= 2 end,
        "White Knight (white/grey only)"
    )
end)

-- Exotic: no uncommon (green, quality 2) gear
R("Exotic", function()
    return qualityGearCheck(
        function(q) return q == 2 end,
        "Exotic (no uncommon/green)"
    )
end)

-- Footman: no rare (3) or epic (4) quality items
R("Footman", function()
    return qualityGearCheck(
        function(q) return q >= 3 end,
        "Footman (no rare/epic)"
    )
end)

-- Grunt: same as Footman — no rare or epic
R("Grunt", function()
    return qualityGearCheck(
        function(q) return q >= 3 end,
        "Grunt (no rare/epic)"
    )
end)

----------------------------------------------------------------------
-- ARMOR-TYPE CHALLENGES
----------------------------------------------------------------------

-- Cloth/leather: can only wear cloth or leather armor.
-- Check all armor slots (not weapons/trinkets/rings/neck/back).
-- Back (cloak) is always cloth regardless of class, so we skip it.
R("Cloth/leather", function()
    local state = getEquipSnapshot()
    local violations = {}
    local checked = 0

    -- Slots that actually have armor subclasses (head, shoulder, chest,
    -- waist, legs, feet, wrist, hands).  Back is always "cloth" in Classic.
    local checkSlots = {
        SLOT.HEAD, SLOT.SHOULDER, SLOT.CHEST, SLOT.WAIST,
        SLOT.LEGS, SLOT.FEET, SLOT.WRIST, SLOT.HANDS,
    }

    for _, sid in ipairs(checkSlots) do
        local item = state[sid]
        if item and item.classID == ARMOR_CLASS then
            checked = checked + 1
            local sub = item.subclassID
            if sub ~= ARMOR_SUB.CLOTH and sub ~= ARMOR_SUB.LEATHER and sub ~= ARMOR_SUB.MISC then
                local label
                if sub == ARMOR_SUB.MAIL then label = "mail"
                elseif sub == ARMOR_SUB.PLATE then label = "plate"
                else label = "type " .. sub end
                table.insert(violations, item.name .. " (" .. label .. ")")
            end
        end
    end

    if #violations > 0 then
        return FAIL, "Cloth/leather only — " .. #violations .. " violation"
            .. (#violations > 1 and "s" or "") .. ": "
            .. table.concat(violations, ", ")
    end

    if checked == 0 then
        return PASS, "No armor equipped"
    end

    return PASS, "All " .. checked .. " armor pieces are cloth or leather"
end)

-- Mail/plate: must wear mail or plate in all armor slots where the
-- class can equip those types.  Paladin can wear mail 1–39, plate 40+.
-- Off-hand (shield) is excluded since shields are their own type.
R("Mail/plate", function()
    local state = getEquipSnapshot()
    local violations = {}
    local checked = 0

    local checkSlots = {
        SLOT.HEAD, SLOT.SHOULDER, SLOT.CHEST, SLOT.WAIST,
        SLOT.LEGS, SLOT.FEET, SLOT.WRIST, SLOT.HANDS,
    }

    for _, sid in ipairs(checkSlots) do
        local item = state[sid]
        if item and item.classID == ARMOR_CLASS then
            checked = checked + 1
            local sub = item.subclassID
            if sub ~= ARMOR_SUB.MAIL and sub ~= ARMOR_SUB.PLATE then
                local label
                if sub == ARMOR_SUB.CLOTH then label = "cloth"
                elseif sub == ARMOR_SUB.LEATHER then label = "leather"
                else label = "type " .. sub end
                table.insert(violations, item.name .. " (" .. label .. ")")
            end
        end
    end

    if #violations > 0 then
        return FAIL, "Mail/plate only — " .. #violations .. " violation"
            .. (#violations > 1 and "s" or "") .. ": "
            .. table.concat(violations, ", ")
    end

    if checked == 0 then
        -- No armor equipped — technically not violating, but warn
        return UNCHECKED, "No armor equipped to verify"
    end

    return PASS, "All " .. checked .. " armor pieces are mail or plate"
end)

----------------------------------------------------------------------
-- PROFESSION-BASED CHALLENGES
----------------------------------------------------------------------

-- No professions: cannot learn any professions.  We piggyback on
-- ProfessionCheck's spell-ID detection.
R("No professions", function()
    -- Use IsSpellKnown with the same profession spell IDs from ProfessionCheck
    local PROF_SPELLS = {
        { name = "Alchemy",        id = 2259 },
        { name = "Blacksmithing",  id = 2018 },
        { name = "Enchanting",     id = 7411 },
        { name = "Engineering",    id = 4036 },
        { name = "Herbalism",      id = 2366 },
        { name = "Leatherworking", id = 2108 },
        { name = "Mining",         id = 2575 },
        { name = "Skinning",       id = 8613 },
        { name = "Tailoring",      id = 3908 },
        { name = "Cooking",        id = 2550 },
        { name = "First Aid",      id = 3273 },
        { name = "Fishing",        id = 7620 },
    }

    local learned = {}
    for _, prof in ipairs(PROF_SPELLS) do
        if IsSpellKnown and IsSpellKnown(prof.id) then
            table.insert(learned, prof.name)
        end
    end

    if #learned > 0 then
        return FAIL, "Learned " .. #learned .. " profession"
            .. (#learned > 1 and "s" or "") .. ": "
            .. table.concat(learned, ", ")
    end

    return PASS, "No professions learned"
end)

----------------------------------------------------------------------
-- PET / DEMON CHALLENGES
----------------------------------------------------------------------

-- Imp: must always use the Imp as your demon pet.
-- We check if the warlock has an active pet and whether it's an Imp.
-- In Classic, warlock demons each have a creature family that we can
-- detect.  The Imp's creature family is "Imp" and its creature type
-- is "Demon".  We use UnitCreatureFamily("pet").
R("Imp", function()
    -- Only relevant for warlocks, but the rule engine doesn't filter by
    -- class — if someone assigns this challenge to a non-warlock, it'll
    -- just pass trivially.
    local _, classToken = UnitClass("player")
    if classToken ~= "WARLOCK" then
        return PASS, "Not a warlock — Imp rule not applicable"
    end

    -- Is a pet active?
    if not UnitExists("pet") then
        return PASS, "No pet summoned (OK — rule applies when a pet is active)"
    end

    -- Check if the pet is an Imp.  UnitCreatureFamily returns the
    -- family name (locale-dependent).  For locale safety we also check
    -- creature type and the pet's name.
    local family = UnitCreatureFamily("pet") or ""
    -- In English: "Imp".  We do a case-insensitive check.
    if family:lower() == "imp" then
        return PASS, "Imp is summoned"
    end

    -- Fallback: check the pet spell name.  Warlock demon spells in Classic:
    --   Imp:       spell 688
    --   Voidwalker: spell 697
    --   Succubus:  spell 712
    --   Felhunter: spell 691
    -- If the player knows these spells, we can check which pet is out
    -- by comparing the pet's name to the spell's summoned creature name.
    -- For now the family check is our best approach.

    local petName = UnitName("pet") or "unknown"
    return FAIL, "Active pet is not an Imp — pet: " .. petName .. " (" .. family .. ")"
end)

-- No demon: cannot summon a demon pet.
R("No demon", function()
    local _, classToken = UnitClass("player")
    if classToken ~= "WARLOCK" then
        return PASS, "Not a warlock — no demon rule not applicable"
    end

    if not UnitExists("pet") then
        return PASS, "No pet summoned"
    end

    -- Check if the pet is a demon.  UnitCreatureType returns the type.
    local creatureType = UnitCreatureType("pet") or ""
    -- In English: "Demon".  Locale-dependent, but most common locales
    -- have a recognisable word.  We check multiple known translations.
    local demonWords = {
        ["demon"]  = true,
        ["démon"]  = true,  -- French
        ["dämon"]  = true,  -- German
        ["demonio"] = true, -- Spanish
    }
    if demonWords[creatureType:lower()] then
        local petName = UnitName("pet") or "unknown"
        return FAIL, "Demon pet summoned: " .. petName .. " — demons are forbidden"
    end

    -- If it's some other pet type (e.g. a quest companion), that's fine
    return PASS, "Active pet is not a demon"
end)

----------------------------------------------------------------------
-- ITEM-SOURCE CHALLENGES
--
-- These challenges restrict WHERE the player's gear comes from.
-- Item source data is auto-generated from Wowhead Classic and lives
-- in ItemSourceData.lua (quest rewards, vendor items, crafted items,
-- and loot drops — all four source types).
--
-- Design:
--   Renegade      → deny-list (quest_rewards is a blocklist)
--   Off-the-shelf → allow-list (vendor_items is an allowlist)
--   Partisan      → deny-list (looted_gear is a blocklist)
--
-- Quality 0–1 (white/grey) items auto-pass all source checks.
----------------------------------------------------------------------

--- Count entries in a table.
local function tblCount(tbl)
    if not tbl then return 0 end
    local n = 0
    for _ in pairs(tbl) do n = n + 1 end
    return n
end

-- Renegade: cannot equip quest reward gear.
-- Deny-list: if the item appears on quest_rewards, it's forbidden.
-- White/grey auto-passes.
R("Renegade", function()
    local list = HCE.CuratedItems and HCE.CuratedItems.quest_rewards
    if not list or tblCount(list) == 0 then
        return UNCHECKED, "Quest-reward item list not loaded"
    end

    local state = getEquipSnapshot()
    local violations = {}
    local checked = 0

    for _, sid in ipairs(GEAR_SLOTS) do
        local item = state[sid]
        if item then
            checked = checked + 1
            if item.quality >= 2 and list[item.id] then
                table.insert(violations, item.name)
            end
        end
    end

    if #violations > 0 then
        return FAIL, "Quest reward gear equipped: " .. table.concat(violations, ", ")
    end
    if checked == 0 then
        return PASS, "No gear equipped"
    end
    return PASS, "No quest reward gear equipped (" .. checked .. " items verified)"
end)

-- Partisan: cannot equip looted (mob drop) gear.
-- Deny-list approach: green+ items on the looted_gear list → FAIL.
-- White/grey auto-passes.
R("Partisan", function()
    local list = HCE.CuratedItems and HCE.CuratedItems.looted_gear
    if not list or not next(list) then
        return UNCHECKED, "Loot-drop item list not loaded"
    end

    local state = getEquipSnapshot()
    local violations = {}
    local checked = 0

    for _, sid in ipairs(GEAR_SLOTS) do
        local item = state[sid]
        if item then
            checked = checked + 1
            if item.quality >= 2 and list[item.id] then
                table.insert(violations, item.name)
            end
        end
    end

    if #violations > 0 then
        return FAIL, "Looted gear equipped: " .. table.concat(violations, ", ")
    end
    if checked == 0 then
        return PASS, "No gear equipped"
    end
    return PASS, "No loot-drop gear equipped (" .. checked .. " items checked)"
end)

-- Off-the-shelf: can only equip gear sold by vendors.
-- Allow-list: green+ items must appear on vendor_items.
-- White/grey auto-passes (basic vendor gear).
R("Off-the-shelf", function()
    local list = HCE.CuratedItems and HCE.CuratedItems.vendor_items
    if not list or tblCount(list) == 0 then
        return UNCHECKED, "Vendor-item list not loaded"
    end

    local state = getEquipSnapshot()
    local violations = {}
    local checked = 0

    for _, sid in ipairs(GEAR_SLOTS) do
        local item = state[sid]
        if item then
            checked = checked + 1
            if item.quality >= 2 and not list[item.id] then
                table.insert(violations, item.name)
            end
        end
    end

    if #violations > 0 then
        return FAIL, "Non-vendor gear equipped: " .. table.concat(violations, ", ")
    end
    if checked == 0 then
        return PASS, "No gear equipped"
    end
    return PASS, "All " .. checked .. " items are vendor-sourced"
end)

----------------------------------------------------------------------
-- ZONE-BASED CHALLENGES (powered by ZoneCheck.lua)
----------------------------------------------------------------------

-- Homebound: can't leave home continent.
-- Uses ZoneCheck.lua for C_Map continent detection + persistent
-- violation tracking.
R("Homebound", function()
    if not HCE.ZoneCheck or not HCE.ZoneCheck.CheckHomebound then
        return UNCHECKED, "Zone tracking module not loaded"
    end
    return HCE.ZoneCheck.CheckHomebound()
end)

-- Zone-visit challenges: these are thematic gameplay suggestions rather
-- than hard pass/fail rules.  They report how many of the suggested
-- zones the player has visited.  Currently no characters have these as
-- formal challenge entries (they appear in gameplay tips), but we
-- register rules so the engine has full coverage.

local function zoneVisitChecker(listName, label)
    return function()
        if not HCE.ZoneCheck or not HCE.ZoneCheck.GetZoneProgress then
            return UNCHECKED, "Zone tracking module not loaded"
        end
        local count, total, visited, unvisited = HCE.ZoneCheck.GetZoneProgress(listName)
        if total == 0 then
            return UNCHECKED, "No zone list defined for " .. label
        end
        if count == total then
            return PASS, "Visited all " .. total .. " " .. label .. " zones: "
                .. table.concat(visited, ", ")
        end
        local detail = count .. "/" .. total .. " zones visited"
        if #visited > 0 then
            detail = detail .. " — visited: " .. table.concat(visited, ", ")
        end
        if #unvisited > 0 then
            detail = detail .. " — remaining: " .. table.concat(unvisited, ", ")
        end
        -- These are aspirational, not restrictive — use UNCHECKED so the
        -- panel shows ? instead of ✗ when incomplete.
        return UNCHECKED, detail
    end
end

R("Anti-undead", zoneVisitChecker("Anti-undead", "anti-undead"))
R("Pro-nature",  zoneVisitChecker("Pro-nature",  "pro-nature"))
R("Anti-demon",  zoneVisitChecker("Anti-demon",  "anti-demon"))
R("Aoe-farmer",  zoneVisitChecker("Aoe-farmer",  "AoE farmer"))

----------------------------------------------------------------------
-- BEHAVIORAL CHALLENGES (powered by BehavioralCheck.lua)
----------------------------------------------------------------------

-- Drifter: cannot use hearthstone or bank.
-- BehavioralCheck.lua hooks BANKFRAME_OPENED and UNIT_SPELLCAST_SENT
-- for hearthstone detection.  Violations are persistent in saved vars.
R("Drifter", function()
    if not HCE.BehavioralCheck or not HCE.BehavioralCheck.CheckDrifter then
        return UNCHECKED, "Behavioral tracking module not loaded"
    end
    return HCE.BehavioralCheck.CheckDrifter()
end)

-- Ephemeral: cannot repair gear.
-- BehavioralCheck.lua hooks MERCHANT_SHOW/MERCHANT_CLOSED and
-- UPDATE_INVENTORY_DURABILITY to detect repair actions via durability
-- comparison.
R("Ephemeral", function()
    if not HCE.BehavioralCheck or not HCE.BehavioralCheck.CheckEphemeral then
        return UNCHECKED, "Behavioral tracking module not loaded"
    end
    return HCE.BehavioralCheck.CheckEphemeral()
end)

----------------------------------------------------------------------
-- PET / COMPANION CHALLENGES (stubs until Milestone 6)
----------------------------------------------------------------------

-- Mortal pets: hunter pets that die stay dead.
-- BehavioralCheck.lua hooks UNIT_SPELLCAST_SENT to detect Revive Pet
-- casts (spell ID 982).  This is an honour-system rule — the addon
-- warns but cannot prevent the revive.
R("Mortal pets", function()
    if not HCE.BehavioralCheck or not HCE.BehavioralCheck.CheckMortalPets then
        local _, classToken = UnitClass("player")
        if classToken ~= "HUNTER" then
            return PASS, "Not a hunter — mortal pets rule not applicable"
        end
        return UNCHECKED, "Behavioral tracking module not loaded"
    end
    return HCE.BehavioralCheck.CheckMortalPets()
end)

----------------------------------------------------------------------
-- REPUTATION-BASED CHALLENGES (stubs)
----------------------------------------------------------------------

-- Faction leader: become exalted with your own faction before 60.
R("Faction leader", function()
    local playerLevel = UnitLevel("player") or 1
    if playerLevel >= 60 then
        -- At 60, the window has closed.  Check if they achieved it.
        -- For now we can't verify retroactively.
        return UNCHECKED, "Reputation tracking not yet implemented"
    end
    -- Before 60, this is a goal to work toward — not a violation.
    return UNCHECKED, "Reputation tracking not yet implemented"
end)

-- Diplomat: must obtain another faction's mount before reaching 60.
R("Diplomat", function()
    return UNCHECKED, "Reputation tracking not yet implemented"
end)

----------------------------------------------------------------------
-- CHALLENGES HANDLED ELSEWHERE
-- Self-made and Self-made guns are tracked by SelfFoundCheck.lua.
-- We register stubs here that defer to SelfFoundCheck results so the
-- rule engine has entries for ALL challenge types (no gaps in lookup).
----------------------------------------------------------------------

R("Self-made", function()
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.GetResults then
        local results = HCE.SelfFoundCheck.GetResults()
        if results.selfMade then
            return results.selfMade.status, results.selfMade.detail
        end
    end
    return UNCHECKED, "Self-found module not loaded"
end)

R("Self-made guns", function()
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.GetResults then
        local results = HCE.SelfFoundCheck.GetResults()
        if results.selfMadeGuns then
            return results.selfMadeGuns.status, results.selfMadeGuns.detail
        end
    end
    return UNCHECKED, "Self-found module not loaded"
end)

----------------------------------------------------------------------
-- Rule lookup and execution
----------------------------------------------------------------------

--- Look up the checker for a challenge description.
function CC.FindRule(desc)
    if not desc then return nil end
    return rules[desc:lower()]
end

--- Run all challenge checks for the current character.
--- Returns a table of results keyed by challenge index.
function CC.CheckAll()
    local results = {}
    if not HCE_CharDB then return results end

    local key = HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then return results end

    local playerLevel = UnitLevel("player") or 1

    for i, ch in ipairs(char.challenges or {}) do
        if playerLevel >= ch.level then
            local rule = CC.FindRule(ch.desc)
            if rule then
                local status, detail = rule()
                results[i] = { status = status, detail = detail, desc = ch.desc }
            else
                results[i] = { status = UNCHECKED, detail = "No rule defined for this challenge", desc = ch.desc }
            end
        else
            results[i] = { status = "inactive", detail = "Unlocks at level " .. ch.level, desc = ch.desc }
        end
    end

    return results
end

--- Run a full check and store results.  Returns the results table.
function CC.RunCheck()
    local results = CC.CheckAll()
    if HCE_CharDB then
        HCE_CharDB.challengeResults = results
    end
    return results
end

--- Get stored results (from last check).
function CC.GetResults()
    return HCE_CharDB and HCE_CharDB.challengeResults or {}
end

----------------------------------------------------------------------
-- Chat warnings — fires once per challenge per state transition
----------------------------------------------------------------------

local CHAT_PREFIX = "|cffe6b422[HCE]|r "
local warnedChallenges = {}  -- [challengeDesc] = lastWarnedStatus

local function warnChallenge(desc, detail)
    if HCE.ChatWarningsEnabled and not HCE.ChatWarningsEnabled() then return end
    DEFAULT_CHAT_FRAME:AddMessage(
        CHAT_PREFIX .. "|cffff8844Challenge violation:|r " .. desc ..
        (detail and (" — " .. detail) or "")
    )
end

--- Run checks and print warnings for newly-failed challenges.
--- Also triggers forbidden-alert toasts for quality/armor violations.
function CC.CheckAndWarn()
    local oldResults = CC.GetResults()
    local oldStatus = {}
    for i, r in pairs(oldResults) do oldStatus[i] = r.status end

    local newResults = CC.RunCheck()

    local newViolations = {}
    for i, res in pairs(newResults) do
        if res.status == FAIL then
            local was = oldStatus[i]
            if was ~= FAIL then
                warnChallenge(res.desc, res.detail)
                table.insert(newViolations, { desc = res.desc, detail = res.detail })
            end
        end
    end

    -- Fire forbidden-alert toasts for challenge violations too
    if #newViolations > 0 and HCE.ForbiddenAlert and HCE.ForbiddenAlert.FireBatch then
        HCE.ForbiddenAlert.FireBatch(newViolations)
    end

    if HCE.RefreshPanel then HCE.RefreshPanel() end
end

--- Reset warning state (called on character pick/reset).
function CC.ResetWarnings()
    warnedChallenges = {}
    if HCE_CharDB then
        HCE_CharDB.challengeResults = {}
    end
end

----------------------------------------------------------------------
-- Slash command: /hce challenges
----------------------------------------------------------------------

function CC.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected.")
        return
    end
    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.challenges or #char.challenges == 0 then
        HCE.Print("Your enhanced class has no challenge requirements.")
        return
    end

    local results = CC.RunCheck()
    local level = UnitLevel("player") or 1
    HCE.Print("Challenge status (level " .. level .. "):")

    for i, ch in ipairs(char.challenges) do
        local res = results[i]
        local tag
        if not res or res.status == "inactive" then
            tag = "|cff888888inactive|r"
        elseif res.status == PASS then
            tag = "|cff00ff00OK|r"
        elseif res.status == FAIL then
            tag = "|cffff5555FAIL|r"
        else
            tag = "|cffffaa33???|r"
        end
        local detail = (res and res.detail) and (" — " .. res.detail) or ""
        HCE.Print("  " .. ch.desc .. ": " .. tag .. detail)
    end
end

----------------------------------------------------------------------
-- Curated item list stubs — ensure the tables exist so the challenge
-- checkers don't nil-index.  ItemSourceData.lua (loaded after this
-- file) populates these with actual item IDs.
----------------------------------------------------------------------

local function ensureCuratedList(name)
    HCE.CuratedItems = HCE.CuratedItems or {}
    if not HCE.CuratedItems[name] then
        HCE.CuratedItems[name] = {}
    end
end

ensureCuratedList("quest_rewards")
ensureCuratedList("vendor_items")
ensureCuratedList("crafted_items")
ensureCuratedList("looted_gear")

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("BANKFRAME_OPENED")
eventFrame:RegisterEvent("MERCHANT_CLOSED")

local initialCheckDone = false

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer so SavedVariables + item cache are ready
        C_Timer.After(2.5, function()
            CC.RunCheck()
            initialCheckDone = true
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
        -- Second pass for uncached items
        C_Timer.After(5.5, function()
            CC.CheckAndWarn()
        end)

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if not initialCheckDone then return end
        -- Quality, armor-type, and item-source challenges all react to
        -- equipment changes.
        C_Timer.After(0.4, function()
            CC.CheckAndWarn()
        end)

    elseif event == "UNIT_PET" then
        if not initialCheckDone then return end
        -- Imp / No demon challenges react to pet changes.
        local unit = ...
        if unit == "player" then
            C_Timer.After(0.3, function()
                CC.CheckAndWarn()
            end)
        end

    elseif event == "ZONE_CHANGED_NEW_AREA" then
        if not initialCheckDone then return end
        -- Homebound and zone-visit challenges react to zone changes.
        -- ZoneCheck.lua handles its own zone recording; we just need
        -- to re-evaluate challenge results here.
        C_Timer.After(0.6, function()
            CC.CheckAndWarn()
        end)

    elseif event == "BANKFRAME_OPENED" or event == "MERCHANT_CLOSED" then
        if not initialCheckDone then return end
        -- Behavioral challenges (Drifter, Ephemeral) are tracked by
        -- BehavioralCheck.lua, which handles its own warnings and
        -- forbidden-alert toasts.  We re-run the full challenge check
        -- here so the results table stays current for the panel.
        C_Timer.After(0.5, function()
            CC.RunCheck()
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
    end
end)
