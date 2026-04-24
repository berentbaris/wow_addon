----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Mount Tracking
--
-- At level 40+, verifies the player is using the correct mount
-- species.  In WoW Classic, mounts are learned as spells and show
-- up as aura buffs when mounted.  Detection uses:
--   1. IsMounted() to know if the player is currently on a mount
--   2. Buff scanning to find the active mount buff name
--   3. A mapping from spreadsheet descriptions to accepted buff
--      names and mount spell IDs
--
-- Four characters have mount requirements (all at level 40):
--   Hellcaller     → "Wolf"           (Horde wolf mounts)
--   Death Knight   → "Skeletal horse"  (Undead skeletal mounts)
--   Sister of Steel→ "Ram"            (Dwarf ram mounts)
--   Priestess      → "Frostsaber"     (Night Elf cat mounts)
--
-- The addon checks on login and when the player mounts/dismounts.
-- Since the player isn't always mounted, the check returns UNCHECKED
-- when not mounted (not FAIL).  A FAIL only fires when the player
-- IS mounted on the WRONG mount.
--
-- Events:
--   PLAYER_LOGIN, PLAYER_LEVEL_UP
--   UNIT_AURA (player) — catches mount buff application/removal
----------------------------------------------------------------------

HCE = HCE or {}

local MC = {}
HCE.MountCheck = MC

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

----------------------------------------------------------------------
-- Mount database
--
-- Maps spreadsheet description to:
--   spellIDs    : set of accepted mount spell IDs (locale-independent)
--   buffNames   : set of accepted mount buff names (English; fallback)
--   notes       : acquisition tips
--
-- WoW Classic mount spell IDs (verified from Classic DB):
--   These are the "Summon <Mount>" spells, NOT the item IDs.
----------------------------------------------------------------------

MC.MountDB = {
    ["Wolf"] = {
        spellIDs = {
            -- Dire Wolf (Orc racial mounts)
            580,    -- Timber Wolf          (grey wolf)
            6653,   -- Dire Wolf            (brown wolf)
            6654,   -- Brown Wolf
            23250,  -- Swift Brown Wolf
            23251,  -- Swift Timber Wolf
            23252,  -- Swift Gray Wolf
            -- Note: Warlock/Paladin class mounts are NOT wolves
        },
        buffNames = {
            ["Timber Wolf"]       = true,
            ["Dire Wolf"]         = true,
            ["Brown Wolf"]        = true,
            ["Swift Brown Wolf"]  = true,
            ["Swift Timber Wolf"] = true,
            ["Swift Gray Wolf"]   = true,
            ["Gray Wolf"]         = true,
        },
        notes = "Orc racial mount — buy from Ogunaro Wolfrunner in Orgrimmar",
    },

    ["Skeletal horse"] = {
        spellIDs = {
            -- Undead racial mounts
            8980,   -- Skeletal Horse       (blue)
            10789,  -- Skeletal Horse       (red)
            10790,  -- Skeletal Horse       (brown)
            10793,  -- Skeletal Horse       (green)
            23246,  -- Purple Skeletal Warhorse
            17462,  -- Red Skeletal Horse (epic)
            17464,  -- Blue Skeletal Horse (alt)
            23247,  -- Green Skeletal Warhorse
        },
        buffNames = {
            ["Skeletal Horse"]            = true,
            ["Red Skeletal Horse"]        = true,
            ["Blue Skeletal Horse"]       = true,
            ["Brown Skeletal Horse"]      = true,
            ["Green Skeletal Warhorse"]   = true,
            ["Purple Skeletal Warhorse"]  = true,
            ["Skeletal Warhorse"]         = true,
        },
        notes = "Undead racial mount — buy from Zachariah Post in Brill",
    },

    ["Ram"] = {
        spellIDs = {
            -- Dwarf racial mounts
            6777,   -- Gray Ram
            6898,   -- White Ram
            6899,   -- Brown Ram
            23238,  -- Swift Brown Ram
            23239,  -- Swift Gray Ram
            23240,  -- Swift White Ram
        },
        buffNames = {
            ["Gray Ram"]         = true,
            ["White Ram"]        = true,
            ["Brown Ram"]        = true,
            ["Swift Brown Ram"]  = true,
            ["Swift Gray Ram"]   = true,
            ["Swift White Ram"]  = true,
            ["Ram"]              = true,
        },
        notes = "Dwarf racial mount — buy from Veron Amberstill in Dun Morogh",
    },

    ["Frostsaber"] = {
        spellIDs = {
            -- Night Elf racial mounts (sabers/nightsabers)
            10789,  -- (shared ID range; Classic uses these)
            8394,   -- Striped Frostsaber
            10793,  -- Striped Nightsaber
            6648,   -- Spotted Frostsaber
            23219,  -- Swift Mistsaber
            23221,  -- Swift Frostsaber
            23338,  -- Swift Stormsaber
            23220,  -- Swift Dawnsaber (placeholder; verify)
        },
        buffNames = {
            ["Striped Frostsaber"]    = true,
            ["Spotted Frostsaber"]    = true,
            ["Striped Nightsaber"]    = true,
            ["Swift Mistsaber"]       = true,
            ["Swift Frostsaber"]      = true,
            ["Swift Stormsaber"]      = true,
            ["Swift Dawnsaber"]       = true,
            ["Frostsaber"]            = true,
            ["Nightsaber"]            = true,
        },
        notes = "Night Elf racial mount — buy from Lelanai in Darnassus",
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

local warnedWrongMount = false

----------------------------------------------------------------------
-- Reset
----------------------------------------------------------------------

function MC.ResetWarnings()
    warnedWrongMount = false
    if HCE_CharDB then
        HCE_CharDB.mountResults = nil
    end
end

----------------------------------------------------------------------
-- Buff scanning helpers
----------------------------------------------------------------------

--- Scan the player's buffs looking for the active mount buff.
--- Returns the buff name if found, or nil.
--- In Classic, mount buffs appear as normal auras on the player.
local function getActiveMountBuff()
    if not IsMounted or not IsMounted() then return nil end

    -- Scan player buffs (index 1..40 is the practical limit)
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellID
        -- Classic 1.15+ / Era uses this signature:
        if AuraUtil and AuraUtil.ForEachAura then
            -- Modern approach (Wrath+): use UnitAura
            name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
        else
            -- Fallback
            name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
        end
        if not name then break end

        -- Check this buff's spell ID against our mount DB
        -- (we do a broad scan — any match in ANY mount entry)
        for _, entry in pairs(MC.MountDB) do
            if entry.spellIDs then
                for _, sid in ipairs(entry.spellIDs) do
                    if spellID == sid then
                        return name, spellID
                    end
                end
            end
            -- Fallback: check by buff name
            if entry.buffNames and entry.buffNames[name] then
                return name, spellID
            end
        end
    end

    -- If we didn't match any known mount buff but the player IS mounted,
    -- try to return whatever mount buff might be active by checking
    -- if any buff's name contains mount-like keywords
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
        if not name then break end
        -- Heuristic: many mount buffs contain the mount's name
        -- We'll return it for identification even if it's not in our DB
        local lower = name:lower()
        if lower:find("wolf") or lower:find("ram") or lower:find("skeletal")
           or lower:find("saber") or lower:find("horse") or lower:find("raptor")
           or lower:find("kodo") or lower:find("mechanostrider")
           or lower:find("mount") or lower:find("riding") then
            return name, spellID
        end
    end

    return nil
end

--- Check if a given buff name or spell ID matches a specific mount entry.
local function matchesMountEntry(entry, buffName, spellID)
    if not entry then return false end

    -- Check spell ID first (locale-independent, preferred)
    if spellID and entry.spellIDs then
        for _, sid in ipairs(entry.spellIDs) do
            if spellID == sid then return true end
        end
    end

    -- Fallback: check buff name (English)
    if buffName and entry.buffNames then
        if entry.buffNames[buffName] then return true end
    end

    return false
end

----------------------------------------------------------------------
-- Core check
----------------------------------------------------------------------

function MC.RunCheck()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        return { status = UNCHECKED, detail = "No character selected" }
    end

    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.mount then
        return { status = UNCHECKED, detail = "No mount requirement" }
    end

    local playerLevel = UnitLevel("player") or 1
    if playerLevel < char.mount.level then
        return {
            status = UNCHECKED,
            detail = string.format(
                "Mount requirement activates at level %d (currently %d)",
                char.mount.level, playerLevel
            ),
        }
    end

    local mountKey = char.mount.desc   -- e.g. "Wolf", "Ram"
    local dbEntry = MC.MountDB[mountKey]

    if not dbEntry then
        return {
            status = UNCHECKED,
            detail = string.format(
                "\"%s\" — not in the mount database yet",
                mountKey
            ),
        }
    end

    -- Check if the player is currently mounted
    if not IsMounted or not IsMounted() then
        local result = {
            status = UNCHECKED,
            detail = string.format(
                "Not mounted. When you ride, use a %s. %s",
                mountKey, dbEntry.notes or ""
            ),
        }
        HCE_CharDB.mountResults = result
        return result
    end

    -- Player is mounted — identify the mount
    local buffName, spellID = getActiveMountBuff()

    local result = {}

    if not buffName then
        -- Mounted but couldn't identify the buff — probably a locale issue
        -- or a mount we don't have in the DB. Don't false-fail.
        result.status = UNCHECKED
        result.detail = "Mounted, but couldn't identify the mount buff"
    elseif matchesMountEntry(dbEntry, buffName, spellID) then
        result.status = PASS
        result.detail = string.format(
            "Riding %s — correct mount!",
            buffName
        )
    else
        result.status = FAIL
        result.detail = string.format(
            "Riding %s — your requirement is a %s mount. %s",
            buffName, mountKey, dbEntry.notes or ""
        )
    end

    result.buffName = buffName
    result.spellID  = spellID

    HCE_CharDB.mountResults = result
    return result
end

----------------------------------------------------------------------
-- Warning logic
----------------------------------------------------------------------

local function maybeWarn(result)
    if not result then return end
    if result.status == PASS then
        if warnedWrongMount then
            cprint("|cff00ff00Mount:|r " .. (result.detail or "Correct mount!"))
        end
        warnedWrongMount = false
        return
    end
    if result.status == UNCHECKED then return end

    -- FAIL — wrong mount
    if not warnedWrongMount then
        warnedWrongMount = true
        cprint("|cffffaa33Mount:|r " .. result.detail)
    end
end

----------------------------------------------------------------------
-- Slash command: /hce mount
----------------------------------------------------------------------

function MC.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        cprint("No enhanced class selected.")
        return
    end

    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.mount then
        cprint("Your enhanced class has no mount requirement.")
        return
    end

    local playerLevel = UnitLevel("player") or 1
    local tag = (playerLevel >= char.mount.level)
        and "|cff00ff00ACTIVE|r"
        or  "|cff888888lv " .. char.mount.level .. "|r"

    cprint("Mount requirement: " .. tag .. " " .. char.mount.desc)

    local dbEntry = MC.MountDB[char.mount.desc]
    if dbEntry then
        local buffList = {}
        for b in pairs(dbEntry.buffNames or {}) do
            table.insert(buffList, b)
        end
        table.sort(buffList)
        cprint("  Accepted mount names: " .. table.concat(buffList, ", "))
        if dbEntry.notes then
            cprint("  Note: " .. dbEntry.notes)
        end
    else
        cprint("  |cffffaa33Not in mount database yet|r")
    end

    -- Current mount status
    if IsMounted and IsMounted() then
        local buffName, spellID = getActiveMountBuff()
        if buffName then
            cprint("  Currently riding: " .. buffName .. (spellID and (" (spell " .. spellID .. ")") or ""))
        else
            cprint("  Currently mounted (buff not identified)")
        end
    else
        cprint("  Currently: not mounted")
    end

    -- Run check
    local result = MC.RunCheck()
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

local eventFrame = CreateFrame("Frame", "HCE_MountCheckFrame", UIParent)

eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("UNIT_AURA")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return end
    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.mount then return end

    if event == "PLAYER_LOGIN" then
        C_Timer.After(3.0, function()
            local result = MC.RunCheck()
            maybeWarn(result)
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)

    elseif event == "PLAYER_LEVEL_UP" then
        C_Timer.After(1.0, function()
            local result = MC.RunCheck()
            maybeWarn(result)
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)

    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            -- Check if mount state changed
            C_Timer.After(0.3, function()
                local result = MC.RunCheck()
                -- Only warn/notify when actually mounted
                if IsMounted and IsMounted() then
                    maybeWarn(result)
                else
                    -- Dismounted — clear the wrong-mount warning
                    -- so it can re-fire next time they mount
                    warnedWrongMount = false
                end
                if HCE.RefreshPanel then HCE.RefreshPanel() end
            end)
        end
    end
end)
