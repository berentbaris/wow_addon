----------------------------------------------------------------------
-- HardcoreClassesEnhanced
-- Extra lore-based character classes for hardcore runs.
-- Tracks whether you're meeting your chosen character's requirements.
----------------------------------------------------------------------

-- Addon-wide namespace (CharacterData.lua loads first and may have
-- already created HCE, so we preserve it)
HCE = HCE or {}
HCE.version = "0.1.0"

----------------------------------------------------------------------
-- Saved variable defaults
----------------------------------------------------------------------
local GLOBAL_DEFAULTS = {
    alertsEnabled = true,
    welcomeShown = {},  -- keyed by "name-realm"
}

local CHAR_DEFAULTS = {
    selectedCharacter = nil,   -- string key into HCE.Characters
    manualOverride    = false,  -- true if the player picked manually
}

----------------------------------------------------------------------
-- Event frame
----------------------------------------------------------------------
local eventFrame = CreateFrame("Frame", "HCE_EventFrame", UIParent)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

----------------------------------------------------------------------
-- Saved-variable initialisation helpers
----------------------------------------------------------------------
local function InitDB(saved, defaults)
    if saved == nil then return CopyTable(defaults) end
    for k, v in pairs(defaults) do
        if saved[k] == nil then
            saved[k] = v
        end
    end
    return saved
end

----------------------------------------------------------------------
-- Chat helpers
----------------------------------------------------------------------
local CHAT_PREFIX = "|cff66bbff[HCE]|r "

function HCE.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. tostring(msg))
end

----------------------------------------------------------------------
-- Character detection & assignment
----------------------------------------------------------------------

--- Try to auto-detect the player's enhanced class from race/class/gender.
--- If exactly one match, assign it automatically.
--- If multiple matches, list them and prompt for /hce pick.
--- If no match, inform the player.
local function TryAutoDetect()
    -- Skip if the player already chose manually
    if HCE_CharDB.manualOverride then return end
    -- Skip if already assigned from a previous session
    if HCE_CharDB.selectedCharacter then return end

    local matches = HCE.FindMatchingCharacters()

    if #matches == 0 then
        HCE.Print("No enhanced class matches your race/class/gender combo.")
        HCE.Print("Type |cffffd100/hce pick|r to choose one manually.")
    elseif #matches == 1 then
        local char = matches[1]
        HCE_CharDB.selectedCharacter = char.name
        HCE.Print("Auto-detected your enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. " " .. char.class:sub(1,1) .. char.class:sub(2):lower() .. ")")
    else
        HCE.Print("Multiple enhanced classes match your character:")
        for i, char in ipairs(matches) do
            HCE.Print("  " .. i .. ". |cffffd100" .. char.name .. "|r — " .. char.spec)
        end
        HCE.Print("Type |cffffd100/hce pick|r to choose one.")
    end
end

----------------------------------------------------------------------
-- Welcome & status display
----------------------------------------------------------------------

function HCE.PrintWelcome()
    local _, classToken = UnitClass("player")
    local race   = UnitRace("player")
    local sex    = UnitSex("player")
    local name   = UnitName("player")
    local gender = (sex == 3) and "female" or "male"
    local class  = classToken:sub(1,1) .. classToken:sub(2):lower()

    HCE.Print("Hardcore Classes Enhanced v" .. HCE.version .. " loaded.")
    HCE.Print("You are " .. name .. ", a " .. gender .. " " .. race .. " " .. class .. ".")

    if HCE_CharDB.selectedCharacter then
        local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
        if char then
            HCE.Print("Enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. ")")
            -- Show a quick summary of active requirements
            local level = UnitLevel("player")
            local active = 0
            for _, eq in ipairs(char.equipment) do
                if level >= eq.level then active = active + 1 end
            end
            for _, ch in ipairs(char.challenges) do
                if level >= ch.level then active = active + 1 end
            end
            HCE.Print(active .. " requirement(s) active at level " .. level .. ". Type |cffffd100/hce status|r for details.")
        else
            HCE.Print("Enhanced class: |cffffd100" .. HCE_CharDB.selectedCharacter .. "|r (data not found — try |cffffd100/hce reset|r)")
        end
    else
        HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
    end
end

--- Print full requirement details for the selected character.
local function PrintFullStatus()
    if not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
        return
    end
    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char then
        HCE.Print("Character data not found for \"" .. HCE_CharDB.selectedCharacter .. "\".")
        return
    end

    local level = UnitLevel("player")
    local class = char.class:sub(1,1) .. char.class:sub(2):lower()

    HCE.Print("--- " .. char.name .. " (" .. char.spec .. " " .. class .. ") ---")

    -- Race / gender / self-found
    HCE.Print("Race: " .. char.race .. " | Gender: " .. char.gender .. " | Self-found: " .. (char.selfFound and "Yes" or "No"))

    -- Professions
    if #char.professions > 0 then
        HCE.Print("Professions: " .. table.concat(char.professions, ", "))
    end

    -- Equipment
    if #char.equipment > 0 then
        HCE.Print("Equipment:")
        for _, eq in ipairs(char.equipment) do
            local tag = (level >= eq.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. eq.level .. "|r"
            HCE.Print("  " .. tag .. " " .. eq.desc)
        end
    end

    -- Challenges
    if #char.challenges > 0 then
        HCE.Print("Challenges:")
        for _, ch in ipairs(char.challenges) do
            local tag = (level >= ch.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. ch.level .. "|r"
            local desc = ch.desc
            local extra = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc]
            if extra then desc = desc .. " — " .. extra end
            HCE.Print("  " .. tag .. " " .. desc)
        end
    end

    -- Companion / pet / mount
    if char.companion then
        local tag = (level >= char.companion.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. char.companion.level .. "|r"
        HCE.Print("Companion: " .. tag .. " " .. char.companion.desc)
    end
    if char.pet then
        local tag = (level >= char.pet.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. char.pet.level .. "|r"
        HCE.Print("Hunter pet: " .. tag .. " " .. char.pet.desc)
    end
    if char.mount then
        local tag = (level >= char.mount.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. char.mount.level .. "|r"
        HCE.Print("Mount: " .. tag .. " " .. char.mount.desc)
    end

    -- Gameplay tips
    if char.gameplay then
        HCE.Print("Gameplay: " .. char.gameplay)
    end
end

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
SLASH_HCE1 = "/hce"
SLASH_HCE2 = "/hardcoreclasses"

SlashCmdList["HCE"] = function(msg)
    local cmd = strtrim(msg):lower()

    if cmd == "" or cmd == "help" then
        HCE.Print("Commands:")
        HCE.Print("  /hce            — show this help")
        HCE.Print("  /hce status     — show full requirement details")
        HCE.Print("  /hce pick       — choose or change your enhanced class")
        HCE.Print("  /hce pick <name>— pick a specific character by name")
        HCE.Print("  /hce list       — list all enhanced classes for your class")
        HCE.Print("  /hce reset      — clear your character selection")
        HCE.Print("  /hce version    — show addon version")

    elseif cmd == "status" then
        PrintFullStatus()

    elseif cmd:sub(1, 4) == "pick" then
        local arg = strtrim(cmd:sub(5))
        if arg == "" then
            -- Show available characters for the player's class
            local _, playerClass = UnitClass("player")
            local available = {}
            for key, char in pairs(HCE.Characters) do
                if char.class == playerClass then
                    table.insert(available, char)
                end
            end
            if #available == 0 then
                HCE.Print("No enhanced classes found for your base class.")
            else
                HCE.Print("Enhanced classes available for " .. playerClass:sub(1,1) .. playerClass:sub(2):lower() .. ":")
                table.sort(available, function(a, b) return a.name < b.name end)
                for _, char in ipairs(available) do
                    local marker = ""
                    if HCE_CharDB.selectedCharacter == char.name then
                        marker = " |cff00ff00(selected)|r"
                    end
                    HCE.Print("  |cffffd100" .. char.name .. "|r — " .. char.spec .. " | " .. char.race .. " " .. char.gender .. marker)
                end
                HCE.Print("Type |cffffd100/hce pick <name>|r to select one.")
            end
        else
            -- Try to find a character by name (case-insensitive partial match)
            local found = nil
            local argLower = arg:lower()
            for key, char in pairs(HCE.Characters) do
                if key:lower() == argLower or key:lower():find(argLower, 1, true) then
                    found = char
                    break
                end
            end
            if found then
                HCE_CharDB.selectedCharacter = found.name
                HCE_CharDB.manualOverride = true
                HCE.Print("Selected enhanced class: |cffffd100" .. found.name .. "|r (" .. found.spec .. ")")
            else
                HCE.Print("No enhanced class found matching \"" .. arg .. "\". Try |cffffd100/hce pick|r to see options.")
            end
        end

    elseif cmd == "list" then
        local _, playerClass = UnitClass("player")
        local all = {}
        for key, char in pairs(HCE.Characters) do
            if char.class == playerClass then
                table.insert(all, char)
            end
        end
        table.sort(all, function(a, b) return a.name < b.name end)
        if #all == 0 then
            HCE.Print("No enhanced classes for your base class.")
        else
            HCE.Print("Enhanced classes for " .. playerClass:sub(1,1) .. playerClass:sub(2):lower() .. ":")
            for _, char in ipairs(all) do
                HCE.Print("  |cffffd100" .. char.name .. "|r — " .. char.spec .. " | " .. char.race .. " " .. char.gender)
            end
        end

    elseif cmd == "reset" then
        HCE_CharDB.selectedCharacter = nil
        HCE_CharDB.manualOverride = false
        HCE.Print("Enhanced class selection cleared.")

    elseif cmd == "version" then
        HCE.Print("Version " .. HCE.version)

    else
        HCE.Print("Unknown command: " .. cmd .. ". Type /hce for help.")
    end
end

----------------------------------------------------------------------
-- Main event handler
----------------------------------------------------------------------
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == "HardcoreClassesEnhanced" then
            HCE_GlobalDB = InitDB(HCE_GlobalDB, GLOBAL_DEFAULTS)
            HCE_CharDB   = InitDB(HCE_CharDB, CHAR_DEFAULTS)
        end

    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(1.0, function()
            TryAutoDetect()
            HCE.PrintWelcome()
        end)

    elseif event == "PLAYER_LOGOUT" then
        -- Future: persist runtime state
    end
end)
