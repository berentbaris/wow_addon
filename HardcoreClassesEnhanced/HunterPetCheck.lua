----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Hunter Pet Tracking
--
-- Verifies that the hunter's tamed pet matches the species
-- required by their enhanced class.  Uses UnitCreatureFamily("pet")
-- which returns the beast family in English on English clients
-- (e.g. "Cat", "Bear", "Wolf").
--
-- Only two characters currently have hunter pet requirements:
--   Buccaneer  → "Jungle cat" (level 15)  → Cat family
--   Mountaineer → "Bear"      (level 10)  → Bear family
--
-- The module maps the spreadsheet description to a set of accepted
-- creature families.  If the pet is alive and belongs to the right
-- family, it passes.  If no pet is active (dead, dismissed, or
-- pre-level-10), the check returns UNCHECKED rather than FAIL since
-- hunters rotate pets and the addon shouldn't nag when a pet is
-- simply dismissed.
--
-- Events:
--   PLAYER_LOGIN, PLAYER_LEVEL_UP   — initial / level-up checks
--   UNIT_PET                         — pet summon/dismiss/swap
----------------------------------------------------------------------

HCE = HCE or {}

local HP = {}
HCE.HunterPetCheck = HP

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

----------------------------------------------------------------------
-- Hunter pet family database
--
-- Maps the spreadsheet description to a table with:
--   families : set of accepted UnitCreatureFamily("pet") return
--              values (English; locale note below)
--   notes    : human-readable acquisition tips
--
-- LOCALE NOTE: UnitCreatureFamily returns localised strings.
-- The family sets here are English.  For non-English clients the
-- match will fail gracefully (UNCHECKED, not false FAIL) and we
-- fall back to a locale-safe creature-type check where possible.
----------------------------------------------------------------------

HP.PetDB = {
    ["Jungle cat"] = {
        families = {
            ["Cat"] = true,   -- WoW Classic beast family for all felines
        },
        -- Specific creature names that match the "jungle cat" theme
        creatureHints = {
            "Shadowmaw Panther",   -- STV
            "Shadow Panther",      -- STV
            "Stranglethorn Tiger",
            "Stranglethorn Tigress",
            "Young Panther",       -- STV
            "Panther",
            "Elder Shadowmaw Panther",
            "Bhag'thera",          -- STV elite panther
            "King Bangalash",      -- STV elite white tiger
            "Shy-Rotam",           -- Winterspring
            "Frostsaber",          -- Winterspring
            "Frostsaber Pride Watcher",
            "Frostsaber Stalker",
            "Savannah Huntress",   -- Barrens
        },
        notes = "Any cat-family beast — jungle cats in STV, Barrens lions, Winterspring frostsabers, etc.",
    },

    ["Bear"] = {
        families = {
            ["Bear"] = true,  -- WoW Classic beast family for all ursines
        },
        creatureHints = {
            "Young Black Bear",     -- Dun Morogh
            "Black Bear",           -- Loch Modan
            "Elder Black Bear",
            "Grizzled Bear",        -- Hillsbrad
            "Ashenvale Bear",
            "Den Mother",
            "Old Grizzlegut",       -- Ashenvale
            "Ironfur Bear",         -- Felwood
            "Shardtooth Bear",      -- Winterspring
            "Diseased Grizzly",     -- WPL
            "Plagued Bear",
        },
        notes = "Any bear-family beast — Dun Morogh cubs, Hillsbrad grizzlies, Felwood ironjaws, etc.",
    },
}

----------------------------------------------------------------------
-- Chat helpers
----------------------------------------------------------------------

local CHAT_PREFIX = "|cff66bbff[HCE]|r "

local function cprint(msg)
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. tostring(msg))
end

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------

local warnedNoPet    = false
local warnedWrongPet = false

----------------------------------------------------------------------
-- Reset (called on /hce pick, /hce reset)
----------------------------------------------------------------------

function HP.ResetWarnings()
    warnedNoPet    = false
    warnedWrongPet = false
    if HCE_CharDB then
        HCE_CharDB.hunterPetResults = nil
    end
end

----------------------------------------------------------------------
-- Core detection
----------------------------------------------------------------------

--- Check if the player has an active pet and whether it matches.
function HP.RunCheck()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        return { status = UNCHECKED, detail = "No character selected" }
    end

    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.pet then
        return { status = UNCHECKED, detail = "No hunter pet requirement" }
    end

    -- Only applies to hunters
    local _, classToken = UnitClass("player")
    if classToken ~= "HUNTER" then
        return { status = UNCHECKED, detail = "Not a hunter" }
    end

    local playerLevel = UnitLevel("player") or 1
    if playerLevel < char.pet.level then
        return {
            status = UNCHECKED,
            detail = string.format(
                "Hunter pet requirement activates at level %d (currently %d)",
                char.pet.level, playerLevel
            ),
        }
    end

    -- Hunters get their first pet at level 10 (taming quest)
    if playerLevel < 10 then
        return {
            status = UNCHECKED,
            detail = "Hunters cannot tame pets until level 10",
        }
    end

    local petKey = char.pet.desc   -- e.g. "Jungle cat", "Bear"
    local dbEntry = HP.PetDB[petKey]

    if not dbEntry then
        return {
            status = UNCHECKED,
            detail = string.format(
                "\"%s\" — not in the hunter pet database yet",
                petKey
            ),
        }
    end

    -- Check if a pet exists
    if not UnitExists("pet") then
        -- No pet out — this is common (dead, dismissed, stable).
        -- Return UNCHECKED rather than FAIL: don't penalise for
        -- dismissing between fights.
        local result = {
            status = UNCHECKED,
            detail = string.format(
                "No pet active. When you summon your pet, it should be a %s. %s",
                petKey, dbEntry.notes or ""
            ),
        }
        HCE_CharDB.hunterPetResults = result
        return result
    end

    -- Check if pet is dead
    if UnitIsDead("pet") then
        local result = {
            status = UNCHECKED,
            detail = "Your pet is dead — revive it to check the requirement",
        }
        HCE_CharDB.hunterPetResults = result
        return result
    end

    -- Get the pet's creature family
    local family = UnitCreatureFamily("pet") or ""
    local petName = UnitName("pet") or "Unknown"
    local result = {}

    if dbEntry.families[family] then
        result.status = PASS
        result.detail = string.format(
            "%s (%s family) — correct pet type!",
            petName, family
        )
    elseif family ~= "" then
        result.status = FAIL
        result.detail = string.format(
            "%s is a %s — your requirement is a %s. %s",
            petName, family, petKey, dbEntry.notes or ""
        )
    else
        -- UnitCreatureFamily returned empty — locale issue or API quirk.
        -- Fall back to UNCHECKED to avoid false FAILs.
        result.status = UNCHECKED
        result.detail = string.format(
            "Could not determine %s's creature family (locale issue?)",
            petName
        )
    end

    result.petName = petName
    result.petFamily = family

    HCE_CharDB.hunterPetResults = result
    return result
end

----------------------------------------------------------------------
-- Warning logic
----------------------------------------------------------------------

local function maybeWarn(result)
    if not result then return end
    if result.status == PASS then
        -- Correct pet — clear warnings, acknowledge if we warned before
        if warnedWrongPet then
            cprint("|cff00ff00Hunter pet:|r " .. (result.detail or "Correct pet!"))
        end
        warnedNoPet    = false
        warnedWrongPet = false
        return
    end
    if result.status == UNCHECKED then return end

    -- FAIL — wrong pet type
    if not warnedWrongPet then
        warnedWrongPet = true
        cprint("|cffffaa33Hunter pet:|r " .. result.detail)
    end
end

----------------------------------------------------------------------
-- Slash command: /hce hunterpet
----------------------------------------------------------------------

function HP.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        cprint("No enhanced class selected.")
        return
    end

    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.pet then
        cprint("Your enhanced class has no hunter pet requirement.")
        return
    end

    local _, classToken = UnitClass("player")
    if classToken ~= "HUNTER" then
        cprint("Hunter pet tracking only applies to Hunter characters.")
        return
    end

    local playerLevel = UnitLevel("player") or 1
    local tag = (playerLevel >= char.pet.level)
        and "|cff00ff00ACTIVE|r"
        or  "|cff888888lv " .. char.pet.level .. "|r"

    cprint("Hunter pet requirement: " .. tag .. " " .. char.pet.desc)

    local dbEntry = HP.PetDB[char.pet.desc]
    if dbEntry then
        local familyList = {}
        for f in pairs(dbEntry.families) do
            table.insert(familyList, f)
        end
        table.sort(familyList)
        cprint("  Accepted families: " .. table.concat(familyList, ", "))
        if dbEntry.notes then
            cprint("  Note: " .. dbEntry.notes)
        end
    else
        cprint("  |cffffaa33Not in hunter pet database yet|r")
    end

    -- Current pet info
    if UnitExists("pet") then
        local petName = UnitName("pet") or "Unknown"
        local family  = UnitCreatureFamily("pet") or "unknown"
        local dead    = UnitIsDead("pet")
        cprint("  Current pet: " .. petName .. " (" .. family .. ")" .. (dead and " |cffff5555DEAD|r" or ""))
    else
        cprint("  Current pet: none active")
    end

    -- Run check
    local result = HP.RunCheck()
    if result.status == PASS then
        cprint("  Status: |cff00ff00" .. (result.detail or "OK") .. "|r")
    elseif result.status == FAIL then
        cprint("  Status: |cffff5555" .. (result.detail or "FAIL") .. "|r")
    else
        cprint("  Status: |cffffaa33" .. (result.detail or "unchecked") .. "|r")
    end
end

----------------------------------------------------------------------
-- Event frame
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame", "HCE_HunterPetCheckFrame", UIParent)

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("UNIT_PET")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    -- Only relevant for hunters with a pet requirement
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return end
    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.pet then return end

    local _, classToken = UnitClass("player")
    if classToken ~= "HUNTER" then return end

    if event == "PLAYER_LOGIN" then
        C_Timer.After(3.0, function()
            local result = HP.RunCheck()
            maybeWarn(result)
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)

    elseif event == "PLAYER_LEVEL_UP" then
        C_Timer.After(1.0, function()
            local result = HP.RunCheck()
            maybeWarn(result)
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)

    elseif event == "UNIT_PET" then
        local unit = ...
        -- UNIT_PET fires for "player" when the hunter's pet changes
        if unit == "player" then
            C_Timer.After(0.5, function()
                local result = HP.RunCheck()
                maybeWarn(result)
                if HCE.RefreshPanel then HCE.RefreshPanel() end
            end)
        end
    end
end)
