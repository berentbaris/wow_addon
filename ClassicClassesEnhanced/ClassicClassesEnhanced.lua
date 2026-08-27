----------------------------------------------------------------------
-- ClassicClassesEnhanced
-- Extra lore-based character classes for hardcore runs.
-- Tracks whether you're meeting your chosen character's requirements.
----------------------------------------------------------------------

-- Addon-wide namespace (CharacterData.lua loads first and may have
-- already created CCE, so we preserve it)
CCE = CCE or {}
CCE.version = "0.1.0"

----------------------------------------------------------------------
-- Saved variable defaults
----------------------------------------------------------------------
local GLOBAL_DEFAULTS = {
    alertsEnabled = true,
    forbiddenAlertsEnabled = true,
    chatWarningsEnabled = true,
    alertSoundEnabled = true,
    edgeFlashEnabled = true,
    gameplayTipsEnabled = true,
    partyAnnounce = true,
    guildAnnounce = true,
    guildAnnounceReqs = true,
    welcomeShown = {},  -- keyed by "name-realm"
}

local CHAR_DEFAULTS = {
    selectedCharacter = nil,   -- string key into CCE.Characters
    manualOverride    = false, -- true if the player picked manually
    lastLevel         = nil,   -- highest level this char had last time we looked
                               -- (used by LevelAlert to detect crossed gates)
}

----------------------------------------------------------------------
-- Event frame
----------------------------------------------------------------------
local eventFrame = CreateFrame("Frame", "HCE_EventFrame", UIParent)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

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
local CHAT_PREFIX = "|cff66bbff[CCE]|r "

function CCE.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_PREFIX .. tostring(msg))
end

----------------------------------------------------------------------
-- Character detection & assignment
----------------------------------------------------------------------

--- Try to auto-detect the player's enhanced class from race/class/gender.
--- If exactly one match, assign it automatically.
--- If multiple matches, list them and prompt for /cce pick.
--- If no match, inform the player.
local function TryAutoDetect()
    -- Skip if the player already chose manually
    if CCE_CharDB.manualOverride then return end
    -- Skip if already assigned from a previous session
    if CCE_CharDB.selectedCharacter then return end

    local matches = CCE.FindMatchingCharacters()

    if #matches == 1 then
        local char = matches[1]
        CCE_CharDB.selectedCharacter = char.key
        -- First-time selection: the player has already levelled up to
        -- their current level under no enhanced rules, so don't fire
        -- toasts retroactively for the climb to get here.
        CCE_CharDB.lastLevel = UnitLevel("player") or 1
        if CCE.DoubtSystem and CCE.DoubtSystem.OnClassChanged then CCE.DoubtSystem.OnClassChanged() end
        if CCE.SavagerySystem and CCE.SavagerySystem.OnClassChanged then CCE.SavagerySystem.OnClassChanged() end
        if CCE.BrewmasterSystem and CCE.BrewmasterSystem.OnClassChanged then CCE.BrewmasterSystem.OnClassChanged() end
        if CCE.ElixirSystem and CCE.ElixirSystem.OnClassChanged then CCE.ElixirSystem.OnClassChanged() end
        if CCE.EventChallenges and CCE.EventChallenges.RefreshChallengeCache then CCE.EventChallenges.RefreshChallengeCache() end
        CCE.Print("Auto-detected your enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. " " .. char.class:sub(1,1) .. char.class:sub(2):lower() .. ")")
    else
        if CCE.CatalogUI and CCE.CatalogUI.ShowForPlayer then
            C_Timer.After(0.5, CCE.CatalogUI.ShowForPlayer)
        end
    end
end

----------------------------------------------------------------------
-- Welcome & status display
----------------------------------------------------------------------

function CCE.PrintWelcome()
    local _, classToken = UnitClass("player")
    local race   = UnitRace("player")
    local sex    = UnitSex("player")
    local name   = UnitName("player")
    local gender = (sex == 3) and "female" or "male"
    local class  = classToken:sub(1,1) .. classToken:sub(2):lower()

    if CCE_CharDB.selectedCharacter then
        local char = CCE.GetCharacter(CCE_CharDB.selectedCharacter)
        if char then
            CCE.Print("CCE loaded. Enhanced class: |cffffd100" .. char.name .. "|r")
            -- Show a quick summary using ProgressSummary as the source of truth
            local level = UnitLevel("player")
            local summary = CCE.Progress and CCE.Progress.Collect and CCE.Progress.Collect()
            if summary and summary.counts then
                local c = summary.counts
                local active = c.pass + c.fail + c.unchecked
                CCE.Print(active .. " requirement(s) active at level " .. level .. ". Click the minimap icon or type |cffffd100/cce status|r for details.")
            else
                CCE.Print("Click the minimap icon or type |cffffd100/cce status|r for details.")
            end
            -- Warn if the saved enhanced class doesn't match this character's WoW class
            if char.class ~= classToken then
                local expectedClass = char.class:sub(1,1) .. char.class:sub(2):lower()
                local displayName = CCE.GetCharDisplayName and CCE.GetCharDisplayName(char) or char.name
                CCE.Print("|cffff5555WARNING:|r Your saved enhanced class |cffffd100" .. displayName
                    .. "|r requires a |cffffd100" .. expectedClass .. "|r, but you are a |cffffd100" .. class
                    .. "|r! Use |cffffd100/cce reset|r to clear your selection.")
            end
        else
            CCE.Print("Enhanced class: |cffffd100" .. CCE_CharDB.selectedCharacter .. "|r (data not found - try |cffffd100/cce reset|r)")
        end
    else
        CCE.Print("No enhanced class selected. Type |cffffd100/cce catalog|r to choose one.")
    end
    CCE.Print("Join the CCE Discord Community by typing |cffffd100/cce join|r.")
    CCE.Print("Support the addon: |cff66bbffbuymeacoffee.com/berentbaris|r or type |cffffd100/cce donate|r")
end

--- Print full requirement details for the selected character.
local function PrintFullStatus()
    if not CCE_CharDB.selectedCharacter then
        CCE.Print("No enhanced class selected. Type |cffffd100/cce pick|r to choose one.")
        return
    end
    local char = CCE.GetCharacter(CCE_CharDB.selectedCharacter)
    if not char then
        CCE.Print("Character data not found for \"" .. CCE_CharDB.selectedCharacter .. "\".")
        return
    end

    local level = UnitLevel("player")
    local class = char.class:sub(1,1) .. char.class:sub(2):lower()

    CCE.Print("--- " .. char.name .. " (" .. char.spec .. " " .. class .. ") ---")

    -- Race / gender
    CCE.Print("Race: " .. char.race .. " | Gender: " .. char.gender)

    -- Professions
    if #char.professions > 0 then
        CCE.Print("Professions: " .. table.concat(char.professions, ", "))
    end

    -- Equipment
    local _equip = CCE.GetCharEquipment(char)
    if #_equip > 0 then
        CCE.Print("Equipment:")
        for _, eq in ipairs(_equip) do
            local tag = (level >= eq.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. eq.level .. "|r"
            CCE.Print("  " .. tag .. " " .. eq.desc)
        end
    end

    -- Challenges
    local activeChallenges = CCE.GetActiveChallenges and CCE.GetActiveChallenges(char) or char.challenges or {}
    if #activeChallenges > 0 then
        CCE.Print("Challenges:")
        for _, ch in ipairs(activeChallenges) do
            local tag = (level >= ch.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. ch.level .. "|r"
            local desc = ch.desc
            local extra = CCE.ChallengeDescriptions and CCE.ChallengeDescriptions[ch.desc]
            if extra then desc = desc .. " - " .. extra end
            CCE.Print("  " .. tag .. " " .. desc)
        end
    end

    -- Companion / pet / mount
    if char.companion then
        local tag = (level >= char.companion.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. char.companion.level .. "|r"
        CCE.Print("Companion: " .. tag .. " " .. char.companion.desc)
    end
    if char.pet then
        local tag = (level >= char.pet.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. char.pet.level .. "|r"
        CCE.Print("Hunter pet: " .. tag .. " " .. char.pet.desc)
    end
    if char.mount then
        local tag = (level >= char.mount.level) and "|cff00ff00ACTIVE|r" or "|cff888888lv " .. char.mount.level .. "|r"
        CCE.Print("Mount: " .. tag .. " " .. char.mount.desc)
    end

    -- Gameplay tips
    local _gameplay = CCE.GetCharGameplay and CCE.GetCharGameplay(char) or char.gameplay
    if _gameplay then
        CCE.Print("Gameplay: " .. _gameplay)
    end
end

----------------------------------------------------------------------
-- Slash commands
----------------------------------------------------------------------
SLASH_CCE1 = "/cce"
SLASH_CCE2 = "/classicclasses"

SlashCmdList["CCE"] = function(msg)
    local cmd = strtrim(msg):lower()

    if cmd == "" or cmd == "help" then
        CCE.Print("Commands:")
        CCE.Print("  /cce            - show this help")
        CCE.Print("  /cce settings   - open the settings panel")
        CCE.Print("  /cce donate     - support the addon developer")
        CCE.Print("  /cce join     - join the CCE Discord Community")
        CCE.Print("  /cce wiki     - check out the addon wiki")
        CCE.Print("  /cce progress   - show progress checklist with completion %")
        CCE.Print("  /cce status     - show full requirement details")
        CCE.Print("  /cce ui         - open the character selection window")
        CCE.Print("  /cce pick       - open the class catalog")
        CCE.Print("  /cce pick <name>- pick a specific character by name (text)")
        CCE.Print("  /cce panel      - toggle the requirements panel")
        CCE.Print("  /cce minimap    - show/hide the minimap button")
        CCE.Print("  /cce alerts     - toggle level-up requirement toasts")
        CCE.Print("  /cce testalert  - preview a toast alert")
        CCE.Print("  /cce forbidden  - toggle forbidden-item alerts")
        CCE.Print("  /cce testforbidden - preview a forbidden-item alert")
        CCE.Print("  /cce testsummary - preview the level-up summary frame")
        CCE.Print("  /cce selffound  - check self-found / self-made status")
        CCE.Print("  /cce talents    - check talent/spec status")
        CCE.Print("  /cce professions- check profession status")
        CCE.Print("  /cce challenges - check challenge status")
        CCE.Print("  /cce zones      - check zone/continent tracking status")
        CCE.Print("  /cce companion  - check companion (vanity pet) status")
        CCE.Print("  /cce hunterpet  - check hunter pet species status")
        CCE.Print("  /cce mount      - check mount requirement status")
        CCE.Print("  /cce quests     - check quest completion progress")
        CCE.Print("  /cce behavioral - check behavioral challenge status (Drifter/Ephemeral)")
        CCE.Print("  /cce sources    - show item-source breakdown (vendor/quest/crafted)")
        CCE.Print("  /cce gameplay   - show expanded gameplay flavour tips")
        CCE.Print("  /cce tips       - toggle periodic gameplay tip reminders")
        CCE.Print("  /cce curated    - show curated item-ID list status")
        CCE.Print("  /cce list       - list all enhanced classes for your class")
        CCE.Print("  /cce reset      - clear your character selection")
        CCE.Print("  /cce doubt      - show current doubt level")
        CCE.Print("  /cce doubt reset- reset doubt for current class")
        CCE.Print("  /cce savagery   - show current savagery (Plagueshifter)")
        CCE.Print("  /cce happyhour  - show Happy Hour timer (Brewmaster)")
        CCE.Print("  /cce elixir     - show Elixir Frenzy grace (Berserker)")
        CCE.Print("  /cce insular    - show insular violations | /cce insular reset")
        CCE.Print("  /cce version    - show addon version")
        CCE.Print(" ")
        CCE.Print("|cffffd100Social:|r")
        CCE.Print("  /cce scan       - scan for other CCE players")
        CCE.Print("  /cce share <name> - whisper a player about CCE")
        CCE.Print("  /cce share party- share CCE info in party chat")
        CCE.Print("  /cce debug      - toggle comm debug messages")
        CCE.Print("  /cce status     - show comm channel diagnostics")

    elseif cmd == "status" then
        PrintFullStatus()

    elseif cmd == "panel" or cmd == "req" or cmd == "requirements" then
        if CCE.TogglePanel then
            CCE.TogglePanel()
        else
            CCE.Print("Requirements panel not loaded.")
        end

    elseif cmd == "testalert" or cmd == "test" then
        if CCE.TestAlert then
            CCE.TestAlert()
        else
            CCE.Print("Alert module not loaded.")
        end

    elseif cmd == "alerts" then
        CCE_GlobalDB.alertsEnabled = not CCE_GlobalDB.alertsEnabled
        if CCE_GlobalDB.alertsEnabled then
            CCE.Print("Level-up requirement toasts |cff00ff00enabled|r.")
        else
            CCE.Print("Level-up requirement toasts |cffff5555disabled|r.")
            if CCE.Alert then CCE.Alert.DismissAll() end
        end

    elseif cmd == "forbidden" then
        CCE_GlobalDB.forbiddenAlertsEnabled = not CCE_GlobalDB.forbiddenAlertsEnabled
        if CCE_GlobalDB.forbiddenAlertsEnabled then
            CCE.Print("Forbidden-item alerts |cff00ff00enabled|r.")
        else
            CCE.Print("Forbidden-item alerts |cffff5555disabled|r.")
            if CCE.ForbiddenAlert then CCE.ForbiddenAlert.DismissAll() end
        end

    elseif cmd == "testforbidden" then
        if CCE.TestForbiddenAlert then
            CCE.TestForbiddenAlert()
        else
            CCE.Print("Forbidden-alert module not loaded.")
        end

    elseif cmd == "minimap" then
        if CCE.ShowMinimapButton and CCE_GlobalDB and CCE_GlobalDB.panel then
            if CCE_GlobalDB.panel.minimap and CCE_GlobalDB.panel.minimap.hide then
                CCE.ShowMinimapButton()
                CCE.Print("Minimap button shown.")
            else
                CCE.HideMinimapButton()
                CCE.Print("Minimap button hidden. Use |cffffd100/cce minimap|r to bring it back.")
            end
        end

    elseif cmd == "ui" or cmd == "show" or cmd == "open" then
        if CCE.CatalogUI and CCE.CatalogUI.Show then
            CCE.CatalogUI.Show()
        else
            CCE.Print("Catalog UI not loaded.")
        end

    elseif cmd:sub(1, 4) == "pick" then
        local arg = strtrim(cmd:sub(5))
        if arg == "" then
            if CCE.CatalogUI and CCE.CatalogUI.ShowForPlayer then
                CCE.CatalogUI.ShowForPlayer()
            else
                CCE.Print("Catalog UI not loaded.")
            end
        else
            -- Try to find a character by name (case-insensitive partial match)
            local found = nil
            local argLower = arg:lower()
            for key, char in pairs(CCE.Characters) do
                if key:lower() == argLower or key:lower():find(argLower, 1, true) then
                    found = char
                    break
                end
            end
            if found then
                CCE_CharDB.selectedCharacter = found.key
                CCE_CharDB.manualOverride = true
                CCE.Print("Selected enhanced class: |cffffd100" .. found.name .. "|r (" .. found.spec .. ")")
                if CCE.ResyncLevelAlerts then CCE.ResyncLevelAlerts() end
                if CCE.ProfessionCheck and CCE.ProfessionCheck.ResetWarnings then CCE.ProfessionCheck.ResetWarnings() end
                if CCE.TalentCheck and CCE.TalentCheck.ResetWarnings then CCE.TalentCheck.ResetWarnings() end
                if CCE.SelfFoundCheck and CCE.SelfFoundCheck.ResetWarnings then CCE.SelfFoundCheck.ResetWarnings() end
                if CCE.ChallengeCheck and CCE.ChallengeCheck.ResetWarnings then CCE.ChallengeCheck.ResetWarnings() end
                if CCE.ZoneCheck and CCE.ZoneCheck.ResetTracking then CCE.ZoneCheck.ResetTracking() end
                if CCE.BehavioralCheck and CCE.BehavioralCheck.ResetTracking then CCE.BehavioralCheck.ResetTracking() end
                if CCE.CompanionCheck and CCE.CompanionCheck.ResetWarnings then CCE.CompanionCheck.ResetWarnings() end
                if CCE.HunterPetCheck and CCE.HunterPetCheck.ResetWarnings then CCE.HunterPetCheck.ResetWarnings() end
                if CCE.MountCheck and CCE.MountCheck.ResetWarnings then CCE.MountCheck.ResetWarnings() end
                -- Immediately run fresh checks so the panel has results
                if CCE.EquipmentCheck and CCE.EquipmentCheck.RunCheck then CCE.EquipmentCheck.RunCheck() end
                if CCE.CompanionCheck and CCE.CompanionCheck.RunCheck then CCE.CompanionCheck.RunCheck() end
                if CCE.HunterPetCheck and CCE.HunterPetCheck.RunCheck then CCE.HunterPetCheck.RunCheck() end
                if CCE.MountCheck and CCE.MountCheck.RunCheck then CCE.MountCheck.RunCheck() end
                if CCE.QuestCheck and CCE.QuestCheck.RunCheck then CCE.QuestCheck.RunCheck() end
                if CCE.DoubtSystem and CCE.DoubtSystem.OnClassChanged then CCE.DoubtSystem.OnClassChanged() end
        if CCE.SavagerySystem and CCE.SavagerySystem.OnClassChanged then CCE.SavagerySystem.OnClassChanged() end
        if CCE.BrewmasterSystem and CCE.BrewmasterSystem.OnClassChanged then CCE.BrewmasterSystem.OnClassChanged() end
        if CCE.ElixirSystem and CCE.ElixirSystem.OnClassChanged then CCE.ElixirSystem.OnClassChanged() end
                if CCE.EventChallenges and CCE.EventChallenges.RefreshChallengeCache then CCE.EventChallenges.RefreshChallengeCache() end
                if CCE.RefreshPanel then CCE.RefreshPanel() end
            else
                CCE.Print("No enhanced class found matching \"" .. arg .. "\". Try |cffffd100/cce pick|r to see options.")
            end
        end

    elseif cmd == "list" or cmd == "catalog" or cmd == "catalogue" or cmd == "browse" then
        if CCE.CatalogUI and CCE.CatalogUI.Toggle then
            CCE.CatalogUI.Toggle()
        else
            CCE.Print("Catalog module not loaded.")
        end

    elseif cmd == "professions" or cmd == "prof" then
        if not CCE.ProfessionCheck then
            CCE.Print("Profession tracking module not loaded.")
        elseif not CCE_CharDB or not CCE_CharDB.selectedCharacter then
            CCE.Print("No enhanced class selected. Type |cffffd100/cce pick|r to choose one.")
        else
            local char = CCE.GetCharacter(CCE_CharDB.selectedCharacter)
            if not char or not char.professions or #char.professions == 0 then
                CCE.Print("Your enhanced class has no profession requirements.")
            else
                local results = CCE.ProfessionCheck.RunCheck()
                local level = UnitLevel("player") or 1
                CCE.Print("Profession status (level " .. level .. "):")
                for _, profName in ipairs(char.professions) do
                    local r = results[profName]
                    if r then
                        local tag
                        if r.status == "pass" then
                            tag = "|cff00ff00OK|r"
                        elseif r.status == "fail" then
                            tag = "|cffff5555BEHIND|r"
                        elseif r.status == "inactive" then
                            tag = "|cff888888inactive|r"
                        else
                            tag = "|cffffaa33???|r"
                        end
                        CCE.Print("  " .. profName .. ": " .. tag .. " - " .. (r.detail or ""))
                    else
                        CCE.Print("  " .. profName .. ": |cff888888no data|r")
                    end
                end
                -- Debug: dump raw skill lines
                CCE.Print("|cff888888--- Debug: raw skill lines ---|r")
                local n = GetNumSkillLines and GetNumSkillLines() or 0
                for i = 1, n do
                    local v = { GetSkillLineInfo(i) }
                    local parts = {}
                    for idx = 1, #v do
                        parts[idx] = tostring(v[idx])
                    end
                    CCE.Print("  [" .. i .. "] " .. table.concat(parts, " | "))
                end
            end
        end

    elseif cmd == "challenges" or cmd == "challenge" or cmd == "ch" then
        if CCE.ChallengeCheck and CCE.ChallengeCheck.PrintStatus then
            CCE.ChallengeCheck.PrintStatus()
        else
            CCE.Print("Challenge tracking module not loaded.")
        end

    elseif cmd == "zones" or cmd == "zone" or cmd == "homebound" then
        if CCE.ZoneCheck and CCE.ZoneCheck.PrintStatus then
            CCE.ZoneCheck.PrintStatus()
        else
            CCE.Print("Zone tracking module not loaded.")
        end

    elseif cmd == "selffound" or cmd == "selfmade" or cmd == "sf" then
        if CCE.SelfFoundCheck and CCE.SelfFoundCheck.PrintStatus then
            CCE.SelfFoundCheck.PrintStatus()
        else
            CCE.Print("Self-found tracking module not loaded.")
        end

    elseif cmd == "talents" or cmd == "talent" or cmd == "spec" then
        if CCE.TalentCheck and CCE.TalentCheck.PrintStatus then
            CCE.TalentCheck.PrintStatus()
        else
            CCE.Print("Talent tracking module not loaded.")
        end

    elseif cmd == "sources" or cmd == "source" or cmd == "itemsource" then
        if CCE.PrintItemSources then
            CCE.PrintItemSources()
        else
            CCE.Print("Item source data module not loaded.")
        end

    elseif cmd == "curated" then
        -- Diagnostic: show curated item-ID list status.  Sorted so the
        -- finished lists surface at the top.
        if not CCE.CuratedItems then
            CCE.Print("Curated item lists not loaded.")
        else
            local rows = {}
            for name, list in pairs(CCE.CuratedItems) do
                local n = 0
                for k in pairs(list) do if k ~= "_order" then n = n + 1 end end
                local complete = CCE.CuratedComplete and CCE.CuratedComplete[name]
                table.insert(rows, { name = name, count = n, complete = complete })
            end
            table.sort(rows, function(a, b)
                if a.count ~= b.count then return a.count > b.count end
                return a.name < b.name
            end)
            CCE.Print("Curated item lists:")
            local totalItems, doneLists, totalLists = 0, 0, #rows
            for _, r in ipairs(rows) do
                local tag
                if r.complete then
                    tag = "|cff00ff00done|r"
                    doneLists = doneLists + 1
                elseif r.count > 0 then
                    tag = "|cffffd100" .. r.count .. " item" .. (r.count == 1 and "" or "s") .. "|r"
                else
                    tag = "|cff888888empty|r"
                end
                CCE.Print("  " .. r.name .. ": " .. tag)
                totalItems = totalItems + r.count
            end
            CCE.Print(string.format(
                "Total: %d item%s across %d list%s (%d marked complete).",
                totalItems, totalItems == 1 and "" or "s",
                totalLists, totalLists == 1 and "" or "s",
                doneLists
            ))
        end

    elseif cmd == "reset" then
        if CCE.DoubtSystem and CCE.DoubtSystem.ResetDoubt then CCE.DoubtSystem.ResetDoubt() end
        CCE_CharDB.selectedCharacter = nil
        CCE_CharDB.manualOverride = false
        CCE_CharDB.selectedChallenge = nil
        CCE_CharDB.selectedChallenges = nil
        CCE_CharDB.lastLevel = UnitLevel("player") or 1
        CCE.Print("Enhanced class selection cleared. Opening the catalog…")
        if CCE.ProfessionCheck and CCE.ProfessionCheck.ResetWarnings then CCE.ProfessionCheck.ResetWarnings() end
        if CCE.TalentCheck and CCE.TalentCheck.ResetWarnings then CCE.TalentCheck.ResetWarnings() end
        if CCE.SelfFoundCheck and CCE.SelfFoundCheck.ResetWarnings then CCE.SelfFoundCheck.ResetWarnings() end
        if CCE.ChallengeCheck and CCE.ChallengeCheck.ResetWarnings then CCE.ChallengeCheck.ResetWarnings() end
        if CCE.ZoneCheck and CCE.ZoneCheck.ResetTracking then CCE.ZoneCheck.ResetTracking() end
        if CCE.BehavioralCheck and CCE.BehavioralCheck.ResetTracking then CCE.BehavioralCheck.ResetTracking() end
        if CCE.CompanionCheck and CCE.CompanionCheck.ResetWarnings then CCE.CompanionCheck.ResetWarnings() end
        if CCE.HunterPetCheck and CCE.HunterPetCheck.ResetWarnings then CCE.HunterPetCheck.ResetWarnings() end
        if CCE.MountCheck and CCE.MountCheck.ResetWarnings then CCE.MountCheck.ResetWarnings() end
        if CCE.EventChallenges and CCE.EventChallenges.ResetAll then CCE.EventChallenges.ResetAll() end
        if CCE.EventChallenges and CCE.EventChallenges.RefreshChallengeCache then CCE.EventChallenges.RefreshChallengeCache() end
        if CCE.RefreshPanel then CCE.RefreshPanel() end
        -- Auto-open the catalog for the player's class
        if CCE.CatalogUI and CCE.CatalogUI.ShowForPlayer then
            C_Timer.After(0.3, CCE.CatalogUI.ShowForPlayer)
        end

    elseif cmd == "companion" or cmd == "pet" or cmd == "critter" then
        if CCE.CompanionCheck and CCE.CompanionCheck.PrintStatus then
            CCE.CompanionCheck.PrintStatus()
        else
            CCE.Print("Companion tracking module not loaded.")
        end

    elseif cmd == "hunterpet" or cmd == "hpet" then
        if CCE.HunterPetCheck and CCE.HunterPetCheck.PrintStatus then
            CCE.HunterPetCheck.PrintStatus()
        else
            CCE.Print("Hunter pet tracking module not loaded.")
        end

    elseif cmd == "mount" or cmd == "riding" then
        if CCE.MountCheck and CCE.MountCheck.PrintStatus then
            CCE.MountCheck.PrintStatus()
        else
            CCE.Print("Mount tracking module not loaded.")
        end

    elseif cmd == "quests" or cmd == "quest" then
        if CCE.QuestCheck and CCE.QuestCheck.PrintStatus then
            CCE.QuestCheck.PrintStatus()
        else
            CCE.Print("Quest tracking module not loaded.")
        end

    elseif cmd == "weapons" or cmd == "weapon" or cmd == "wpn" then
        if CCE.WeaponProficiencyCheck and CCE.WeaponProficiencyCheck.PrintStatus then
            CCE.WeaponProficiencyCheck.PrintStatus()
        else
            CCE.Print("Weapon proficiency module not loaded.")
        end

    elseif cmd == "behavioral" or cmd == "behaviour" or cmd == "behavior" then
        if CCE.BehavioralCheck and CCE.BehavioralCheck.PrintStatus then
            CCE.BehavioralCheck.PrintStatus()
        else
            CCE.Print("Behavioral tracking module not loaded.")
        end

    elseif cmd == "progress" or cmd == "prog" or cmd == "checklist" then
        if CCE.Progress and CCE.Progress.PrintStatus then
            CCE.Progress.PrintStatus()
        else
            CCE.Print("Progress summary module not loaded.")
        end

    elseif cmd == "donate" or cmd == "support" then
        CCE.Print("Thanks for your support!")
        CCE.Print("|cff66bbffhttps://buymeacoffee.com/berentbaris|r")
        -- Open an edit box so the player can copy the URL
        if not CCE._donateEditBox then
            local eb = CreateFrame("EditBox", "HCE_DonateEditBox", UIParent, "InputBoxTemplate")
            eb:SetSize(320, 28)
            eb:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
            eb:SetAutoFocus(true)
            eb:SetText("https://buymeacoffee.com/berentbaris")
            eb:HighlightText()
            eb:SetScript("OnEscapePressed", function(self) self:Hide() end)
            eb:SetScript("OnEnterPressed", function(self) self:Hide() end)
            eb:SetScript("OnEditFocusLost", function(self) self:Hide() end)
            CCE._donateEditBox = eb
        else
            CCE._donateEditBox:SetText("https://buymeacoffee.com/berentbaris")
            CCE._donateEditBox:Show()
            CCE._donateEditBox:HighlightText()
            CCE._donateEditBox:SetFocus()
        end

    elseif cmd == "join" or cmd == "discord" then
        CCE.Print("Welcome to the community!")
        CCE.Print("|cff66bbffhttps://discord.gg/YdNZkAsSFf|r")
        -- Open an edit box so the player can copy the URL
        if not CCE._donateJoinBox then
            local eb = CreateFrame("EditBox", "HCE_donateJoinBox", UIParent, "InputBoxTemplate")
            eb:SetSize(320, 28)
            eb:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
            eb:SetAutoFocus(true)
            eb:SetText("https://discord.gg/YdNZkAsSFf")
            eb:HighlightText()
            eb:SetScript("OnEscapePressed", function(self) self:Hide() end)
            eb:SetScript("OnEnterPressed", function(self) self:Hide() end)
            eb:SetScript("OnEditFocusLost", function(self) self:Hide() end)
            CCE._donateJoinBox = eb
        else
            CCE._donateJoinBox:SetText("https://discord.gg/YdNZkAsSFf")
            CCE._donateJoinBox:Show()
            CCE._donateJoinBox:HighlightText()
            CCE._donateJoinBox:SetFocus()
        end

    elseif cmd == "pole weaving" then
        CCE.Print("Check this Youtube video for detailed explanation")
        CCE.Print("|cff66bbffhttps://www.youtube.com/watch?v=-bxMMK2vS5s|r")
        -- Open an edit box so the player can copy the URL
        if not CCE._donateJoinBox then
            local eb = CreateFrame("EditBox", "HCE_donateJoinBox", UIParent, "InputBoxTemplate")
            eb:SetSize(320, 28)
            eb:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
            eb:SetAutoFocus(true)
            eb:SetText("https://www.youtube.com/watch?v=-bxMMK2vS5s")
            eb:HighlightText()
            eb:SetScript("OnEscapePressed", function(self) self:Hide() end)
            eb:SetScript("OnEnterPressed", function(self) self:Hide() end)
            eb:SetScript("OnEditFocusLost", function(self) self:Hide() end)
            CCE._donateJoinBox = eb
        else
            CCE._donateJoinBox:SetText("https://www.youtube.com/watch?v=-bxMMK2vS5s")
            CCE._donateJoinBox:Show()
            CCE._donateJoinBox:HighlightText()
            CCE._donateJoinBox:SetFocus()
        end

    elseif cmd == "wiki" then
        CCE.Print("|cff66bbffhttps://hce-wiki.polia.nl/|r")
        -- Open an edit box so the player can copy the URL
        if not CCE._donateJoinBox then
            local eb = CreateFrame("EditBox", "HCE_donateJoinBox", UIParent, "InputBoxTemplate")
            eb:SetSize(320, 28)
            eb:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
            eb:SetAutoFocus(true)
            eb:SetText("https://hce-wiki.polia.nl/")
            eb:HighlightText()
            eb:SetScript("OnEscapePressed", function(self) self:Hide() end)
            eb:SetScript("OnEnterPressed", function(self) self:Hide() end)
            eb:SetScript("OnEditFocusLost", function(self) self:Hide() end)
            CCE._donateJoinBox = eb
        else
            CCE._donateJoinBox:SetText("https://hce-wiki.polia.nl/")
            CCE._donateJoinBox:Show()
            CCE._donateJoinBox:HighlightText()
            CCE._donateJoinBox:SetFocus()
        end

    elseif cmd == "settings" or cmd == "options" or cmd == "config" then
        if CCE.SettingsPanel and CCE.SettingsPanel.Toggle then
            CCE.SettingsPanel.Toggle()
        else
            CCE.Print("Settings panel not loaded.")
        end

    elseif cmd == "gameplay" or cmd == "tips" or cmd == "flavor" then
        if cmd == "tips" and CCE.GameplayTips then
            -- Toggle periodic tip reminders
            if CCE_GlobalDB.gameplayTipsEnabled == nil then
                CCE_GlobalDB.gameplayTipsEnabled = true
            end
            CCE_GlobalDB.gameplayTipsEnabled = not CCE_GlobalDB.gameplayTipsEnabled
            if CCE_GlobalDB.gameplayTipsEnabled then
                CCE.Print("Periodic gameplay tip reminders |cff00ff00enabled|r.")
                CCE.GameplayTips.StartReminder()
            else
                CCE.Print("Periodic gameplay tip reminders |cffff5555disabled|r.")
                CCE.GameplayTips.StopReminder()
            end
        elseif CCE.GameplayTips and CCE.GameplayTips.PrintStatus then
            CCE.GameplayTips.PrintStatus()
        else
            CCE.Print("Gameplay tips module not loaded.")
        end

    elseif cmd == "testsummary" then
        if CCE.LevelUpSummary and CCE.LevelUpSummary.Test then
            CCE.LevelUpSummary.Test()
        else
            CCE.Print("Level-up summary module not loaded.")
        end

    elseif cmd:sub(1, 5) == "doubt" then
        local doubtArg = strtrim(cmd:sub(6)):lower()
        if doubtArg == "reset" then
            if CCE.DoubtSystem and CCE.DoubtSystem.ResetDoubt then
                CCE.DoubtSystem.ResetDoubt()
            else
                CCE.Print("Doubt system not loaded.")
            end
        elseif doubtArg:sub(1, 3) == "set" then
            local val = tonumber(strtrim(doubtArg:sub(4)))
            if val and CCE.DoubtSystem then
                CCE.DoubtSystem.SetDoubt(val)
                CCE.Print(string.format("Doubt set to %.1f%%", val))
            else
                CCE.Print("Usage: /cce doubt set <0-100>")
            end
        elseif doubtArg == "" then
            -- Show current doubt
            if CCE.DoubtSystem then
                local val = CCE.DoubtSystem.GetDoubt()
                CCE.Print(string.format("Current doubt: %.1f%%", val))
            else
                CCE.Print("Doubt system not loaded.")
            end
        else
            CCE.Print("Usage: /cce doubt - show doubt | /cce doubt set <0-100> | /cce doubt reset")
        end

    elseif cmd:sub(1, 8) == "savagery" then
        local savArg = strtrim(cmd:sub(9)):lower()
        if savArg == "reset" then
            if CCE.SavagerySystem and CCE.SavagerySystem.ResetSavagery then
                CCE.SavagerySystem.ResetSavagery()
            else
                CCE.Print("Savagery system not loaded.")
            end
        elseif savArg == "" then
            if CCE.SavagerySystem then
                CCE.Print(string.format("Current savagery: %.0f%%", CCE.SavagerySystem.GetSavagery()))
            else
                CCE.Print("Savagery system not loaded.")
            end
        else
            CCE.Print("Usage: /cce savagery | /cce savagery reset")
        end

    elseif cmd:sub(1, 9) == "happyhour" then
        local hhArg = strtrim(cmd:sub(10)):lower()
        if hhArg == "reset" then
            if CCE.BrewmasterSystem and CCE.BrewmasterSystem.Reset then
                CCE.BrewmasterSystem.Reset()
            else
                CCE.Print("Brewmaster system not loaded.")
            end
        elseif hhArg == "" then
            if CCE.BrewmasterSystem then
                local t = CCE.BrewmasterSystem.GetTimeRemaining()
                CCE.Print(string.format("Happy Hour: %d:%02d remaining", math.floor(t/60), t%60))
            else
                CCE.Print("Brewmaster system not loaded.")
            end
        else
            CCE.Print("Usage: /cce happyhour | /cce happyhour reset")
        end

    elseif cmd:sub(1, 6) == "elixir" then
        local elArg = strtrim(cmd:sub(7)):lower()
        if elArg == "reset" then
            if CCE.ElixirSystem and CCE.ElixirSystem.Reset then
                CCE.ElixirSystem.Reset()
            else
                CCE.Print("Elixir system not loaded.")
            end
        elseif elArg == "" then
            if CCE.ElixirSystem then
                local t = CCE.ElixirSystem.GetGraceRemaining()
                CCE.Print(string.format("Elixir Frenzy grace: %d:%02d remaining", math.floor(t/60), t%60))
            else
                CCE.Print("Elixir system not loaded.")
            end
        else
            CCE.Print("Usage: /cce elixir | /cce elixir reset")
        end

    elseif cmd:sub(1, 7) == "insular" then
        local iArg = strtrim(cmd:sub(8)):lower()
        if iArg == "reset" then
            if CCE.EventChallenges and CCE.EventChallenges.ResetInsular then
                CCE.EventChallenges.ResetInsular()
            else
                CCE.Print("Event challenge module not loaded.")
            end
        else
            local db = CCE_CharDB and CCE_CharDB.eventChallenges
            local v = db and db.nativeTongueViolations or 0
            CCE.Print("Insular violations: " .. v)
        end

    elseif cmd == "version" then
        CCE.Print("Version " .. CCE.version)

    elseif cmd == "scan" then
        if CCE.AddonComm and CCE.AddonComm.StartNearbyScan then
            CCE.AddonComm.StartNearbyScan()
        else
            CCE.Print("Addon communication module not loaded.")
        end

    elseif cmd == "debug" then
        if CCE.AddonComm and CCE.AddonComm.ToggleDebug then
            CCE.AddonComm.ToggleDebug()
        end

    elseif cmd == "status" then
        if CCE.AddonComm and CCE.AddonComm.PrintStatus then
            CCE.AddonComm.PrintStatus()
        end

    elseif cmd:sub(1, 5) == "share" then
        local arg = strtrim(cmd:sub(6))

        -- Build class name and progress info
        local className = ""
        local progressLine = ""
        if CCE_CharDB and CCE_CharDB.selectedCharacter then
            local char = CCE.GetCharacter and CCE.GetCharacter(CCE_CharDB.selectedCharacter)
            if char then
                className = CCE.GetCharDisplayName and CCE.GetCharDisplayName(char) or char.name
            end
            if CCE.Progress and CCE.Progress.Collect and CCE.Progress.Percentage and CCE.Progress.GetRank then
                local summary = CCE.Progress.Collect()
                if summary and summary.counts then
                    local pct = CCE.Progress.Percentage(summary.counts)
                    local rank = CCE.Progress.GetRank(pct)
                    progressLine = " I'm at " .. math.floor(pct) .. "% progress towards becoming a Master " .. className .. "."
                end
            end
        end

        local msg1 = "I'm using Classic Classes Enhanced, an addon that adds 30+ lore-based classes to WoW Classic with unique challenges, requirements, and a rank system."
        local msg2
        if className ~= "" then
            msg2 = progressLine .. " Check it out on CurseForge!"
        else
            msg2 = "Check it out on CurseForge!"
        end

        if arg == "party" then
            if not IsInGroup or not IsInGroup() then
                CCE.Print("You are not in a party.")
                return
            end
            SendChatMessage(msg1, "PARTY")
            SendChatMessage(msg2, "PARTY")
            CCE.Print("Shared CCE info with your party!")
        else
            -- Determine whisper target: argument name, or current target
            local whisperTarget
            if arg ~= "" then
                whisperTarget = arg:sub(1,1):upper() .. arg:sub(2):lower()
            else
                local targetName = UnitName("target")
                if targetName and UnitIsPlayer("target") then
                    whisperTarget = targetName
                end
            end

            if not whisperTarget then
                CCE.Print("Usage: |cffffd100/cce share <name>|r or target a player.")
                CCE.Print("  |cffffd100/cce share party|r to share in party chat.")
                return
            end

            local myName = UnitName("player")
            if whisperTarget == myName then
                CCE.Print("You can't share with yourself!")
                return
            end

            SendChatMessage(msg1, "WHISPER", nil, whisperTarget)
            SendChatMessage(msg2, "WHISPER", nil, whisperTarget)
            CCE.Print("Shared CCE info with |cffffd100" .. whisperTarget .. "|r!")
        end

    elseif cmd == "debugtooltip" then
        if CCE.SelfFoundCheck and CCE.SelfFoundCheck.DebugTooltips then
            CCE.SelfFoundCheck.DebugTooltips()
        else
            CCE.Print("SelfFoundCheck module not loaded.")
        end

    else
        CCE.Print("Unknown command: " .. cmd .. ". Type /cce for help.")
    end
end

----------------------------------------------------------------------
-- Party chat announcements
--
-- Sends messages to PARTY chat so groupmates know you're playing
-- an enhanced class.  Controlled by CCE_GlobalDB.partyAnnounce.
----------------------------------------------------------------------

--- Check whether the player is in a party/raid.
--- Named HCE_IsInGroup to avoid shadowing the WoW API IsInGroup().
local function HCE_IsInGroup()
    if IsInGroup then return IsInGroup() end
    return (GetNumGroupMembers or GetNumPartyMembers or function() return 0 end)() > 0
end

--- Get the selected character data, or nil.
local function GetSelectedChar()
    if not CCE_CharDB or not CCE_CharDB.selectedCharacter then return nil end
    return CCE.GetCharacter and CCE.GetCharacter(CCE_CharDB.selectedCharacter)
end

--- Group-join announcement to party chat.
--- Waits until at least one other member is actually in the group
--- (not just invited), retrying a few times with a delay.
local function AnnounceGroupJoin(retries)
    retries = retries or 0
    if not CCE_GlobalDB.partyAnnounce then return end
    if not HCE_IsInGroup() then return end

    -- GetNumGroupMembers counts actual members (not pending invites).
    -- Right after sending an invite the count is 1 (just us).
    local count = (GetNumGroupMembers or GetNumPartyMembers or function() return 0 end)()
    if count < 2 then
        if retries < 10 then
            C_Timer.After(2.0, function() AnnounceGroupJoin(retries + 1) end)
        end
        return
    end

    local char = GetSelectedChar()
    if not char then return end

    local displayName = CCE.GetCharDisplayName and CCE.GetCharDisplayName(char) or char.name
    local msg = "[CCE] Beware! I’m playing as a " .. displayName
        .. " - a lore-based sub-optimal build with special rules."

    SendChatMessage(msg, "PARTY")
end

----------------------------------------------------------------------
-- Main event handler
----------------------------------------------------------------------
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == "ClassicClassesEnhanced" then
            CCE_GlobalDB = InitDB(CCE_GlobalDB, GLOBAL_DEFAULTS)
            CCE_CharDB   = InitDB(CCE_CharDB, CHAR_DEFAULTS)
        end

    elseif event == "PLAYER_LOGIN" then
        -- Snapshot current group state so a /reload while already grouped
        -- doesn't trigger a false "just joined" announcement.
        CCE._wasInGroup = HCE_IsInGroup()
        C_Timer.After(1.0, function()
            TryAutoDetect()
            CCE.PrintWelcome()
        end)
        -- Achievement system init (hooks rank-up, takes initial snapshot)
        if CCE.Achieve and CCE.Achieve.Init then
            CCE.Achieve.Init()
        end
        -- Language support check
        C_Timer.After(4.0, function()
            local locale = GetLocale()
            if locale ~= "enUS" and locale ~= "enGB" then
                local f = CreateFrame("Frame", "CCE_LanguageWarning", UIParent, "BackdropTemplate")
                f:SetSize(340, 100)
                f:SetPoint("TOP", UIParent, "TOP", 0, -120)
                f:SetBackdrop({
                    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
                    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
                    tile     = true, tileSize = 32, edgeSize = 24,
                    insets   = { left = 6, right = 6, top = 6, bottom = 6 },
                })
                f:SetBackdropColor(0.1, 0.08, 0.05, 0.95)
                f:SetFrameStrata("DIALOG")
                f:EnableMouse(true)
                f:SetMovable(true)
                f:RegisterForDrag("LeftButton")
                f:SetScript("OnDragStart", f.StartMoving)
                f:SetScript("OnDragStop", f.StopMovingOrSizing)

                local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                title:SetPoint("TOP", 0, -14)
                title:SetText("|cffe6b422Classic Classes Enhanced|r")

                local msg = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                msg:SetPoint("TOP", title, "BOTTOM", 0, -6)
                msg:SetWidth(310)
                msg:SetJustifyH("CENTER")
                msg:SetText("Languages other than English are not yet supported. Some features may not work correctly.")

                local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
                btn:SetSize(80, 22)
                btn:SetPoint("BOTTOM", 0, 10)
                btn:SetText("OK")
                btn:SetScript("OnClick", function() f:Hide() end)

                f:Show()
            end
        end)

    elseif event == "GROUP_ROSTER_UPDATE" then
        -- Only announce once when we transition from solo -> grouped,
        -- not on every roster change (someone joins/leaves/role changes).
        local inGroup = HCE_IsInGroup()
        if inGroup and not CCE._wasInGroup then
            -- Just joined a group - announce after a short delay
            CCE._wasInGroup = true  -- set immediately to prevent double-fire
            C_Timer.After(2.0, function()
                AnnounceGroupJoin()
            end)
        elseif not inGroup then
            CCE._wasInGroup = false
        end

    elseif event == "PLAYER_LOGOUT" then
        -- Future: persist runtime state
    end
end)
