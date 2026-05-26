----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Behavioral Challenge Tracking
--
-- Tracks challenges that restrict player ACTIONS rather than gear:
--   Drifter     → cannot use hearthstone or bank
--   Ephemeral   → cannot repair gear
--   Mortal pets → hunter pets that die stay dead
--
-- Violations are persistent: once triggered they stick in SavedVars
-- until the player does /hce reset. This matches the Homebound
-- pattern from ZoneCheck.lua — a casual addon shouldn't forget that
-- you broke a rule just because you logged out.
--
-- Events hooked:
--   BANKFRAME_OPENED       → Drifter (bank)
--   UNIT_SPELLCAST_SENT    → Drifter (hearthstone), Mortal pets
--   MERCHANT_SHOW          → Ephemeral (snapshot durability)
--   MERCHANT_CLOSED        → Ephemeral (compare durability)
--   UPDATE_INVENTORY_DURABILITY → Ephemeral (live repair detection)
----------------------------------------------------------------------

HCE = HCE or {}

local BC = {}
HCE.BehavioralCheck = BC

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

-- Hearthstone spell ID (the actual spell cast when using the item).
-- Item ID 6948, but the spell it triggers is 8690.
local HEARTHSTONE_SPELL_ID = 8690
-- The Hearthstone item ID, for belt-and-suspenders detection.
local HEARTHSTONE_ITEM_ID  = 6948

-- Revive Pet spell ID (Hunter ability).
local REVIVE_PET_SPELL_ID  = 982

-- Durability-bearing inventory slots (slots that can take damage).
local DURABILITY_SLOTS = {
     1, -- Head
     3, -- Shoulder
     5, -- Chest
     6, -- Waist
     7, -- Legs
     8, -- Feet
     9, -- Wrist
    10, -- Hands
    16, -- Main hand
    17, -- Off hand
    18, -- Ranged
}
----------------------------------------------------------------------
-- SPELL RESTRICTIONS
--
-- Challenges that forbid casting spells from a certain talent tree.
-- Once a forbidden spell is cast, the violation is permanent until
-- /hce reset.
--
-- Spell lists: WoW Classic 1.15.x spell names (we match by name
-- rather than spell ID to catch all ranks automatically).
----------------------------------------------------------------------

-- Frost mage spells forbidden by "Pyromancer"
local FROST_SPELLS = {
    ["Frostbolt"]       = true,
    ["Frost Nova"]      = true,
    ["Blizzard"]        = true,
    ["Cone of Cold"]    = true,
    ["Ice Barrier"]     = true,
    ["Ice Block"]       = true,
    ["Ice Armor"]       = true,
    ["Frost Armor"]     = true,
    ["Frost Ward"]      = true,
    ["Frostbite"]       = true,
}

-- Shadow priest spells forbidden by "Light of Elune"
local SHADOW_SPELLS = {
    ["Shadow Word: Pain"]    = true,
    ["Mind Blast"]           = true,
    ["Mind Flay"]            = true,
    ["Shadow Word: Death"]   = true,
    ["Vampiric Embrace"]     = true,
    ["Shadowform"]           = true,
    ["Devouring Plague"]     = true,
    ["Mind Soothe"]          = true,
    ["Mind Vision"]          = true,
    ["Psychic Scream"]       = true,
    ["Silence"]              = true,
    ["Mind Control"]         = true,
    ["Shadow Protection"]    = true,
    ["Shadow Guard"]         = true,
    ["Hex of Weakness"]      = true,
    ["Fade"]      = true,
}

-- Subtlety rogue spells forbidden by "Crude"
local SUBTLETY_SPELLS = {
    ["Ambush"]              = true,
    ["Hemorrhage"]          = true,
    ["Premeditation"]       = true,
    ["Preparation"]         = true,
    ["Stealth"]             = true,
    ["Vanish"]              = true,
    ["Blind"]               = true,
    ["Sap"]                 = true,
    ["Distract"]            = true,
    ["Pick Pocket"]         = true,
    ["Detect Traps"]        = true,
    ["Disarm Trap"]         = true,
}

local HOLY_SPELLS = {
    ["Smite"]              = true,
    ["Holy Nova"]          = true,
    ["Holy Fire"]       = true,
    ["Renew"]         = true,
    ["Heal"]             = true,
    ["Greater Heal"]              = true,
    ["Lesser Heal"]               = true,
    ["Flash Heal"]                 = true,
    ["Desperate Prayer"]            = true,
    ["Cure Disease"]         = true,
    ["Fear Ward"]        = true,
    ["Abolish Disease"]         = true,
    ["Prayer of Healing"]         = true,
    ["Lightwell"]         = true,
}

local ARCANE_SPELLS = {
    ["Arcane Intellect"]              = true,
    ["Conjure Water"]          = true,
    ["Blink"]       = true,
    ["Polymorph"]         = true,
    ["Slow Fall"]             = true,
    ["Dampen Magic"]              = true,
    ["Arcane Explosion"]               = true,
    ["Arcane Missiles"]                 = true,
    ["Amplify Magic"]            = true,
    ["Evocation"]         = true,
    ["Teleport: Undercity"]         = true,
    ["Teleport: Orgrimmar"]         = true,
    ["Teleport: Thunder Bluff"]         = true,
    ["Teleport: Stormwind"]         = true,
    ["Teleport: Ironforge"]         = true,
    ["Teleport: Darnassus"]         = true,
    ["Teleport: Theramore"]         = true,
    ["Counterspell"]         = true,
    ["Conjure Mana Agate"]         = true,
    ["Conjure Food"]         = true,
    ["Mage Armor"]         = true,
    ["Mana Shield"]         = true,
    ["Conjure Mana Jade"]         = true,
    ["Portal: Undercity"]         = true,
    ["Portal: Orgrimmar"]         = true,
    ["Portal: Thunder Bluff"]         = true,
    ["Portal: Stormwind"]         = true,
    ["Portal: Ironforge"]         = true,
    ["Portal: Darnassus"]         = true,
    ["Portal: Stonard"]         = true,
    ["Conjure Mana Citrine"]         = true,
    ["Conjure Mana Ruby"]          = true,
    ["Arcane Brilliance"]         = true,
    ["Remove Curse"]         = true,
    ["Remove Lesser Curse"]         = true,
}

local DEFENSIVE_STANCE = {
    ["Defensive Stance"]              = true,
}

local STEALTH = {
    ["Ambush"]              = true,
    ["Hemorrhage"]          = true,
    ["Premeditation"]       = true,
    ["Preparation"]         = true,
    ["Stealth"]             = true,
    ["Vanish"]              = true,
    ["Sap"]                 = true,
    ["Distract"]            = true,
    ["Pick Pocket"]         = true,
}

local HOLY_PALADIN = {
    ["Holy Light"]              = true,
    ["Seal of Righteousness"]              = true,
    ["Purify"]              = true,
    ["Cleanse"]              = true,
    ["Hammer of Wrath"]              = true,
    ["Flash of Light"]              = true,
    ["Redemption"]              = true,
    ["Exorcism"]              = true,
    ["Sense Undead"]              = true,
    ["Turn Undead"]              = true,
    ["Blessing of Wisdom"]              = true,
    ["Seal of Light"]              = true,
    ["Lay on Hands"]              = true,
    ["Summon Warhose"]              = true,
    ["Summon Charger"]              = true,
    ["Seal of Wisdom"]              = true,
    ["Blessing of Light"]              = true,
    ["Greater Blessing of Wisdom"]              = true,
    ["Greater Blessing of Light"]              = true,
}

-- Map challenge name -> { spellSet, classToken, label }
local SPELL_RESTRICTIONS = {
    ["Pyromancer"]     = { spells = FROST_SPELLS,     class = "MAGE",   label = "Frost" },
    ["Light of Elune"] = { spells = SHADOW_SPELLS,    class = "PRIEST", label = "Shadow" },
    ["Crude"]          = { spells = SUBTLETY_SPELLS,  class = "ROGUE",  label = "Subtlety" },
    ["Shadow Ascendant"]          = { spells = HOLY_SPELLS,  class = "PRIEST",  label = "Holy" },
    ["Self-taught"]          = { spells = ARCANE_SPELLS,  class = "MAGE",  label = "Arcane" },
    ["All-out Assault"]          = { spells = DEFENSIVE_STANCE,  class = "WARRIOR",  label = "Prot" },
    ["Overt"]           = { spells = STEALTH,  class = "ROGUE",  label = "Stealth" },
    ["Agnostic"]           = { spells = HOLY_PALADIN,  class = "PALADIN",  label = "Holy" },
}


----------------------------------------------------------------------
-- Chat helpers
----------------------------------------------------------------------

local CHAT_PREFIX = "|cffe6b422[HCE]|r "
local WARN_PREFIX = "|cffe6b422[HCE]|r |cffff8844"

local function Chat(msg)
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. msg)
end

local function Warn(msg)
    DEFAULT_CHAT_FRAME:AddMessage(WARN_PREFIX .. msg .. "|r")
end

----------------------------------------------------------------------
-- Saved variable access
--
-- We store violation flags in HCE_CharDB.behavioral:
--   .drifterBank       = true if bank was opened
--   .drifterHearthstone = true if hearthstone was used
--   .ephemeralRepaired  = true if gear was repaired
--   .mortalPetsRevived  = true if Revive Pet was cast
----------------------------------------------------------------------

local function GetDB()
    if not HCE_CharDB then return nil end
    if not HCE_CharDB.behavioral then
        HCE_CharDB.behavioral = {}
    end
    return HCE_CharDB.behavioral
end

----------------------------------------------------------------------
-- Challenge relevance — does the current character actually have
-- this challenge?  We check once per event rather than building a
-- persistent cache, because character picks can change mid-session.
----------------------------------------------------------------------

local function hasChallenge(name)
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return false end
    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.challenges then return false end
    local nameLower = name:lower()
    local level = UnitLevel("player") or 1
    for _, ch in ipairs(char.challenges) do
        if ch.desc:lower() == nameLower and level >= ch.level then
            return true
        end
    end
    return false
end

----------------------------------------------------------------------
-- DRIFTER: no hearthstone, no bank
----------------------------------------------------------------------

--- Called when BANKFRAME_OPENED fires.
function BC.OnBankOpened()
    if not hasChallenge("Drifter") then return end
    local db = GetDB()
    if not db then return end

    if not db.drifterBank then
        db.drifterBank = true
        Warn("Drifter violation: you opened the bank!")
        Warn("Drifters live out of their bags — no banking allowed.")

        -- Fire a forbidden-alert toast if available
        if HCE.ForbiddenAlert and HCE.ForbiddenAlert.FireBatch then
            HCE.ForbiddenAlert.FireBatch({
                { desc = "Drifter", detail = "Opened the bank" },
            })
        end

        -- Refresh challenge results
        if HCE.ChallengeCheck and HCE.ChallengeCheck.RunCheck then
            HCE.ChallengeCheck.RunCheck()
        end
        if HCE.RefreshPanel then HCE.RefreshPanel() end
    end
end

--- Called on UNIT_SPELLCAST_SENT — checks for Hearthstone cast.
function BC.OnSpellCast(unit, _, spellID)
    if unit ~= "player" then return end

    -- Drifter: hearthstone detection
    if spellID == HEARTHSTONE_SPELL_ID and hasChallenge("Drifter") then
        local db = GetDB()
        if db and not db.drifterHearthstone then
            db.drifterHearthstone = true
            Warn("Drifter violation: you used your hearthstone!")
            Warn("Drifters wander — no teleporting home.")

            if HCE.ForbiddenAlert and HCE.ForbiddenAlert.FireBatch then
                HCE.ForbiddenAlert.FireBatch({
                    { desc = "Drifter", detail = "Used hearthstone" },
                })
            end

            if HCE.ChallengeCheck and HCE.ChallengeCheck.RunCheck then
                HCE.ChallengeCheck.RunCheck()
            end
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end
    end

    -- Spell restriction detection (Pyromancer / Light of Elune / Crude)
    -- We need the spell name to match against the forbidden lists.
    local spellName = GetSpellInfo and GetSpellInfo(spellID) or nil
    if spellName then
        for challengeName, restriction in pairs(SPELL_RESTRICTIONS) do
            if restriction.spells[spellName] and hasChallenge(challengeName) then
                local db = GetDB()
                if db then
                    local key = "spellViolation_" .. challengeName
                    if not db[key] then
                        db[key] = spellName
                        Warn(challengeName .. " violation: you cast " .. spellName .. "!")
                        Warn(restriction.label .. " spells are forbidden. This violation is permanent.")
                        Chat("Use |cffffd100/hce reset|r to clear all violations.")

                        if HCE.ForbiddenAlert and HCE.ForbiddenAlert.FireBatch then
                            HCE.ForbiddenAlert.FireBatch({
                                { desc = challengeName, detail = "Cast " .. spellName },
                            })
                        end

                        if HCE.ChallengeCheck and HCE.ChallengeCheck.RunCheck then
                            HCE.ChallengeCheck.RunCheck()
                        end
                        if HCE.RefreshPanel then HCE.RefreshPanel() end
                    end
                end
            end
        end
    end

    -- Mortal pets: Revive Pet detection
    if spellID == REVIVE_PET_SPELL_ID and hasChallenge("Mortal pets") then
        local db = GetDB()
        if db then
            -- Always warn, even if already violated — the player might
            -- be testing or might have multiple pets die.
            db.mortalPetsRevived = true
            Warn("Mortal pets violation: you cast Revive Pet!")
            Warn("Dead pets stay dead. This violation is permanent.")

            if HCE.ForbiddenAlert and HCE.ForbiddenAlert.FireBatch then
                HCE.ForbiddenAlert.FireBatch({
                    { desc = "Mortal pets", detail = "Cast Revive Pet" },
                })
            end

            if HCE.ChallengeCheck and HCE.ChallengeCheck.RunCheck then
                HCE.ChallengeCheck.RunCheck()
            end
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end
    end
end

--- Drifter check result — returns (status, detail) for the rule engine.
function BC.CheckDrifter()
    local db = GetDB()

    -- If no violations tracked yet, all good
    if not db then return PASS, "No violations recorded" end

    local violations = {}
    if db.drifterBank then
        table.insert(violations, "opened bank")
    end
    if db.drifterHearthstone then
        table.insert(violations, "used hearthstone")
    end

    -- Check if hearthstone is in bags — this is also a violation
    local hsCount = GetItemCount and GetItemCount(HEARTHSTONE_ITEM_ID) or 0
    if hsCount > 0 then
        table.insert(violations, "hearthstone in bags — destroy it")
    end

    if #violations > 0 then
        return FAIL, "Drifter violated: " .. table.concat(violations, ", ")
    end

    return PASS, "No bank or hearthstone usage recorded"
end

----------------------------------------------------------------------
-- EPHEMERAL: no repair
--
-- Strategy: snapshot total durability when the merchant window opens.
-- If durability increases while the merchant is open (or by the time
-- it closes), the player repaired.  We also hook
-- UPDATE_INVENTORY_DURABILITY for instant detection if they click
-- the repair button with the merchant still open.
----------------------------------------------------------------------

local merchantOpen = false
local durabilitySnapshot = nil  -- total current durability before merchant

--- Sum up current durability across all gear slots.
local function totalCurrentDurability()
    local total = 0
    for _, slot in ipairs(DURABILITY_SLOTS) do
        local cur, _ = GetInventoryItemDurability(slot)
        if cur then
            total = total + cur
        end
    end
    return total
end

--- Called when MERCHANT_SHOW fires.
function BC.OnMerchantShow()
    if not hasChallenge("Ephemeral") then return end

    merchantOpen = true
    durabilitySnapshot = totalCurrentDurability()

    -- Always warn when opening a merchant — gentle reminder
    Chat("|cffffaa33Ephemeral reminder:|r Don't repair! "
        .. "Your gear is meant to wear down and break.")
end

--- Called when MERCHANT_CLOSED fires.
function BC.OnMerchantClosed()
    if not merchantOpen then return end
    merchantOpen = false

    if not hasChallenge("Ephemeral") then
        durabilitySnapshot = nil
        return
    end

    -- Final check: did durability go up?
    BC.CheckForRepair()
    durabilitySnapshot = nil
end

--- Called on UPDATE_INVENTORY_DURABILITY while merchant is open.
function BC.OnDurabilityUpdate()
    if not merchantOpen then return end
    if not hasChallenge("Ephemeral") then return end
    -- Small delay so the durability values have settled
    C_Timer.After(0.2, function()
        if merchantOpen then
            BC.CheckForRepair()
        end
    end)
end

--- Compare current durability against the snapshot.
function BC.CheckForRepair()
    if not durabilitySnapshot then return end

    local now = totalCurrentDurability()
    if now > durabilitySnapshot then
        local db = GetDB()
        if db and not db.ephemeralRepaired then
            db.ephemeralRepaired = true
            Warn("Ephemeral violation: you repaired your gear!")
            Warn("Ephemeral warriors let their equipment crumble.")

            if HCE.ForbiddenAlert and HCE.ForbiddenAlert.FireBatch then
                HCE.ForbiddenAlert.FireBatch({
                    { desc = "Ephemeral", detail = "Repaired gear at merchant" },
                })
            end

            if HCE.ChallengeCheck and HCE.ChallengeCheck.RunCheck then
                HCE.ChallengeCheck.RunCheck()
            end
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end
        -- Update snapshot so we don't re-fire
        durabilitySnapshot = now
    end
end

--- Ephemeral check result — returns (status, detail) for the rule engine.
function BC.CheckEphemeral()
    local db = GetDB()
    if not db then return PASS, "No violations recorded" end

    if db.ephemeralRepaired then
        return FAIL, "Repaired gear (use /hce reset to clear)"
    end

    -- Report current durability state as flavour
    local totalCur, totalMax = 0, 0
    for _, slot in ipairs(DURABILITY_SLOTS) do
        local cur, mx = GetInventoryItemDurability(slot)
        if cur and mx then
            totalCur = totalCur + cur
            totalMax = totalMax + mx
        end
    end

    if totalMax > 0 then
        local pct = math.floor(totalCur / totalMax * 100)
        return PASS, "No repairs recorded — gear at " .. pct .. "% durability"
    end

    return PASS, "No repairs recorded"
end

----------------------------------------------------------------------
-- MORTAL PETS: hunter pets that die stay dead
----------------------------------------------------------------------

--- Mortal pets check result — returns (status, detail) for the rule engine.
function BC.CheckMortalPets()
    local _, classToken = UnitClass("player")
    if classToken ~= "HUNTER" then
        return PASS, "Not a hunter — mortal pets rule not applicable"
    end

    local db = GetDB()
    if not db then return PASS, "No violations recorded" end

    if db.mortalPetsRevived then
        return FAIL, "Cast Revive Pet — permanent violation"
    end

    -- Check if the pet is alive or dead as extra context
    if UnitExists("pet") then
        if UnitIsDead("pet") then
            return PASS, "Pet is dead — remember, don't revive it"
        else
            return PASS, "Pet is alive — no revive attempts detected"
        end
    end

    return PASS, "No pet summoned — no Revive Pet casts detected"
end

----------------------------------------------------------------------
-- Spell restriction check results
----------------------------------------------------------------------

function BC.CheckSpellRestriction(challengeName)
    local restriction = SPELL_RESTRICTIONS[challengeName]
    if not restriction then
        return UNCHECKED, "Unknown spell restriction: " .. challengeName
    end

    local _, classToken = UnitClass("player")
    if classToken ~= restriction.class then
        return PASS, "Not a " .. restriction.class:sub(1,1) .. restriction.class:sub(2):lower() .. " — rule not applicable"
    end

    local db = GetDB()
    if not db then return PASS, "No violations recorded" end

    local key = "spellViolation_" .. challengeName
    if db[key] then
        return FAIL, "Cast " .. tostring(db[key]) .. " — " .. restriction.label .. " spells are forbidden"
    end

    return PASS, "No " .. restriction.label .. " spell casts detected"
end

----------------------------------------------------------------------
-- Reset — called by /hce reset and /hce pick
----------------------------------------------------------------------

function BC.ResetTracking()
    if HCE_CharDB then
        HCE_CharDB.behavioral = {}
    end
    merchantOpen = false
    durabilitySnapshot = nil
end

-- Expose spell restriction names so ChallengeCheck can detect them
BC.SPELL_RESTRICTIONS = SPELL_RESTRICTIONS

----------------------------------------------------------------------
-- Slash command: /hce behavioral
----------------------------------------------------------------------

function BC.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected.")
        return
    end

    local level = UnitLevel("player") or 1
    HCE.Print("Behavioral challenge status (level " .. level .. "):")

    -- Drifter
    if hasChallenge("Drifter") then
        local status, detail = BC.CheckDrifter()
        local tag
        if status == PASS then tag = "|cff00ff00OK|r"
        elseif status == FAIL then tag = "|cffff5555FAIL|r"
        else tag = "|cffffaa33???|r" end
        HCE.Print("  Drifter: " .. tag .. " — " .. detail)
    end

    -- Ephemeral
    if hasChallenge("Ephemeral") then
        local status, detail = BC.CheckEphemeral()
        local tag
        if status == PASS then tag = "|cff00ff00OK|r"
        elseif status == FAIL then tag = "|cffff5555FAIL|r"
        else tag = "|cffffaa33???|r" end
        HCE.Print("  Ephemeral: " .. tag .. " — " .. detail)
    end

    -- Mortal pets
    if hasChallenge("Mortal pets") then
        local status, detail = BC.CheckMortalPets()
        local tag
        if status == PASS then tag = "|cff00ff00OK|r"
        elseif status == FAIL then tag = "|cffff5555FAIL|r"
        else tag = "|cffffaa33???|r" end
        HCE.Print("  Mortal pets: " .. tag .. " — " .. detail)
    end

    -- Spell restrictions
    for challengeName, _ in pairs(SPELL_RESTRICTIONS) do
        if hasChallenge(challengeName) then
            local status, detail = BC.CheckSpellRestriction(challengeName)
            local tag
            if status == PASS then tag = "|cff00ff00OK|r"
            elseif status == FAIL then tag = "|cffff5555FAIL|r"
            else tag = "|cffffaa33???|r" end
            HCE.Print("  " .. challengeName .. ": " .. tag .. " — " .. detail)
        end
    end

    local hasAny = hasChallenge("Drifter") or hasChallenge("Ephemeral") or hasChallenge("Mortal pets")
    for cn, _ in pairs(SPELL_RESTRICTIONS) do
        if hasChallenge(cn) then hasAny = true end
    end
    if not hasAny then
        HCE.Print("  Your character has no behavioral challenges.")
    end
end

----------------------------------------------------------------------
-- Event frame
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("BANKFRAME_OPENED")
eventFrame:RegisterEvent("MERCHANT_SHOW")
eventFrame:RegisterEvent("MERCHANT_CLOSED")
eventFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Ensure the behavioral sub-table exists in saved vars
        GetDB()

    elseif event == "BANKFRAME_OPENED" then
        BC.OnBankOpened()

    elseif event == "MERCHANT_SHOW" then
        BC.OnMerchantShow()

    elseif event == "MERCHANT_CLOSED" then
        BC.OnMerchantClosed()

    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        BC.OnDurabilityUpdate()

    elseif event == "UNIT_SPELLCAST_SENT" then
        -- Args: unit, castGUID, spellID
        -- In Classic, UNIT_SPELLCAST_SENT args vary by patch:
        --   Pre-TBC Classic: unit, target, castGUID, spellID
        --   Some builds:     unit, castGUID, spellID
        -- We handle both by checking arg types.
        local arg1, arg2, arg3, arg4 = ...
        local unit, spellID
        unit = arg1
        -- If arg4 is a number, the format is (unit, target, castGUID, spellID)
        -- If arg3 is a number, the format is (unit, castGUID, spellID)
        -- If arg2 is a number, it's (unit, spellID) — unlikely but defensive
        if type(arg4) == "number" then
            spellID = arg4
        elseif type(arg3) == "number" then
            spellID = arg3
        elseif type(arg2) == "number" then
            spellID = arg2
        end

        if unit and spellID then
            BC.OnSpellCast(unit, nil, spellID)
        end
    end
end)
