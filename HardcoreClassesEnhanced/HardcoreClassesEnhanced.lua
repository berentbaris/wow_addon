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
    forbiddenAlertsEnabled = true,
    chatWarningsEnabled = true,
    alertSoundEnabled = true,
    edgeFlashEnabled = true,
    gameplayTipsEnabled = true,
    partyAnnounce = true,
    welcomeShown = {},  -- keyed by "name-realm"
}

local CHAR_DEFAULTS = {
    selectedCharacter = nil,   -- string key into HCE.Characters
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
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("GROUP_JOINED")

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
        -- First-time selection: the player has already levelled up to
        -- their current level under no enhanced rules, so don't fire
        -- toasts retroactively for the climb to get here.
        HCE_CharDB.lastLevel = UnitLevel("player") or 1
        HCE.Print("Auto-detected your enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. " " .. char.class:sub(1,1) .. char.class:sub(2):lower() .. ")")
    else
        HCE.Print("Multiple enhanced classes match your character:")
        for i, char in ipairs(matches) do
            HCE.Print("  " .. i .. ". |cffffd100" .. char.name .. "|r — " .. char.spec)
        end
        HCE.Print("Opening selection window… (type |cffffd100/hce ui|r to reopen it later)")
        -- Pop the UI so the player can pick with a click
        if HCE.ShowSelectionUI then
            C_Timer.After(0.5, HCE.ShowSelectionUI)
        end
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

    HCE.Print("Support the addon: |cff66bbffbuymeacoffee.com/berentbaris|r — or type |cffffd100/hce donate|r")
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
        HCE.Print("  /hce settings   — open the settings panel")
        HCE.Print("  /hce donate     — support the addon developer")
        HCE.Print("  /hce progress   — show progress checklist with completion %")
        HCE.Print("  /hce status     — show full requirement details")
        HCE.Print("  /hce ui         — open the character selection window")
        HCE.Print("  /hce pick       — open the selection window")
        HCE.Print("  /hce pick <name>— pick a specific character by name (text)")
        HCE.Print("  /hce panel      — toggle the requirements panel")
        HCE.Print("  /hce minimap    — show/hide the minimap button")
        HCE.Print("  /hce alerts     — toggle level-up requirement toasts")
        HCE.Print("  /hce testalert  — preview a toast alert")
        HCE.Print("  /hce forbidden  — toggle forbidden-item alerts")
        HCE.Print("  /hce testforbidden — preview a forbidden-item alert")
        HCE.Print("  /hce testsummary — preview the level-up summary frame")
        HCE.Print("  /hce selffound  — check self-found / self-made status")
        HCE.Print("  /hce talents    — check talent/spec status")
        HCE.Print("  /hce professions— check profession status")
        HCE.Print("  /hce challenges — check challenge status")
        HCE.Print("  /hce zones      — check zone/continent tracking status")
        HCE.Print("  /hce companion  — check companion (vanity pet) status")
        HCE.Print("  /hce hunterpet  — check hunter pet species status")
        HCE.Print("  /hce mount      — check mount requirement status")
        HCE.Print("  /hce quests     — check quest completion progress")
        HCE.Print("  /hce behavioral — check behavioral challenge status (Drifter/Ephemeral)")
        HCE.Print("  /hce sources    — show item-source breakdown (vendor/quest/crafted)")
        HCE.Print("  /hce gameplay   — show expanded gameplay flavour tips")
        HCE.Print("  /hce tips       — toggle periodic gameplay tip reminders")
        HCE.Print("  /hce curated    — show curated item-ID list status")
        HCE.Print("  /hce list       — list all enhanced classes for your class")
        HCE.Print("  /hce reset      — clear your character selection")
        HCE.Print("  /hce version    — show addon version")

    elseif cmd == "status" then
        PrintFullStatus()

    elseif cmd == "panel" or cmd == "req" or cmd == "requirements" then
        if HCE.TogglePanel then
            HCE.TogglePanel()
        else
            HCE.Print("Requirements panel not loaded.")
        end

    elseif cmd == "testalert" or cmd == "test" then
        if HCE.TestAlert then
            HCE.TestAlert()
        else
            HCE.Print("Alert module not loaded.")
        end

    elseif cmd == "alerts" then
        HCE_GlobalDB.alertsEnabled = not HCE_GlobalDB.alertsEnabled
        if HCE_GlobalDB.alertsEnabled then
            HCE.Print("Level-up requirement toasts |cff00ff00enabled|r.")
        else
            HCE.Print("Level-up requirement toasts |cffff5555disabled|r.")
            if HCE.Alert then HCE.Alert.DismissAll() end
        end

    elseif cmd == "forbidden" then
        HCE_GlobalDB.forbiddenAlertsEnabled = not HCE_GlobalDB.forbiddenAlertsEnabled
        if HCE_GlobalDB.forbiddenAlertsEnabled then
            HCE.Print("Forbidden-item alerts |cff00ff00enabled|r.")
        else
            HCE.Print("Forbidden-item alerts |cffff5555disabled|r.")
            if HCE.ForbiddenAlert then HCE.ForbiddenAlert.DismissAll() end
        end

    elseif cmd == "testforbidden" then
        if HCE.TestForbiddenAlert then
            HCE.TestForbiddenAlert()
        else
            HCE.Print("Forbidden-alert module not loaded.")
        end

    elseif cmd == "minimap" then
        if HCE.ShowMinimapButton and HCE_GlobalDB and HCE_GlobalDB.panel then
            if HCE_GlobalDB.panel.minimap and HCE_GlobalDB.panel.minimap.hide then
                HCE.ShowMinimapButton()
                HCE.Print("Minimap button shown.")
            else
                HCE.HideMinimapButton()
                HCE.Print("Minimap button hidden. Use |cffffd100/hce minimap|r to bring it back.")
            end
        end

    elseif cmd == "ui" or cmd == "show" or cmd == "open" then
        if HCE.ShowSelectionUI then
            HCE.ShowSelectionUI()
        else
            HCE.Print("Selection UI not loaded.")
        end

    elseif cmd:sub(1, 4) == "pick" then
        local arg = strtrim(cmd:sub(5))
        if arg == "" then
            if HCE.ShowSelectionUI then
                HCE.ShowSelectionUI()
            else
                HCE.Print("Selection UI not loaded. Try |cffffd100/hce list|r instead.")
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
                if HCE.ResyncLevelAlerts then HCE.ResyncLevelAlerts() end
                if HCE.ProfessionCheck and HCE.ProfessionCheck.ResetWarnings then HCE.ProfessionCheck.ResetWarnings() end
                if HCE.TalentCheck and HCE.TalentCheck.ResetWarnings then HCE.TalentCheck.ResetWarnings() end
                if HCE.SelfFoundCheck and HCE.SelfFoundCheck.ResetWarnings then HCE.SelfFoundCheck.ResetWarnings() end
                if HCE.ChallengeCheck and HCE.ChallengeCheck.ResetWarnings then HCE.ChallengeCheck.ResetWarnings() end
                if HCE.ZoneCheck and HCE.ZoneCheck.ResetTracking then HCE.ZoneCheck.ResetTracking() end
                if HCE.BehavioralCheck and HCE.BehavioralCheck.ResetTracking then HCE.BehavioralCheck.ResetTracking() end
                if HCE.CompanionCheck and HCE.CompanionCheck.ResetWarnings then HCE.CompanionCheck.ResetWarnings() end
                if HCE.HunterPetCheck and HCE.HunterPetCheck.ResetWarnings then HCE.HunterPetCheck.ResetWarnings() end
                if HCE.MountCheck and HCE.MountCheck.ResetWarnings then HCE.MountCheck.ResetWarnings() end
                if HCE.RefreshPanel then HCE.RefreshPanel() end
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

    elseif cmd == "professions" or cmd == "prof" then
        if not HCE.ProfessionCheck then
            HCE.Print("Profession tracking module not loaded.")
        elseif not HCE_CharDB or not HCE_CharDB.selectedCharacter then
            HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
        else
            local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
            if not char or not char.professions or #char.professions == 0 then
                HCE.Print("Your enhanced class has no profession requirements.")
            else
                local results = HCE.ProfessionCheck.RunCheck()
                local level = UnitLevel("player") or 1
                HCE.Print("Profession status (level " .. level .. "):")
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
                        HCE.Print("  " .. profName .. ": " .. tag .. " — " .. (r.detail or ""))
                    else
                        HCE.Print("  " .. profName .. ": |cff888888no data|r")
                    end
                end
                -- Debug: dump raw skill lines
                HCE.Print("|cff888888--- Debug: raw skill lines ---|r")
                local n = GetNumSkillLines and GetNumSkillLines() or 0
                for i = 1, n do
                    local v = { GetSkillLineInfo(i) }
                    local parts = {}
                    for idx = 1, #v do
                        parts[idx] = tostring(v[idx])
                    end
                    HCE.Print("  [" .. i .. "] " .. table.concat(parts, " | "))
                end
            end
        end

    elseif cmd == "challenges" or cmd == "challenge" or cmd == "ch" then
        if HCE.ChallengeCheck and HCE.ChallengeCheck.PrintStatus then
            HCE.ChallengeCheck.PrintStatus()
        else
            HCE.Print("Challenge tracking module not loaded.")
        end

    elseif cmd == "zones" or cmd == "zone" or cmd == "homebound" then
        if HCE.ZoneCheck and HCE.ZoneCheck.PrintStatus then
            HCE.ZoneCheck.PrintStatus()
        else
            HCE.Print("Zone tracking module not loaded.")
        end

    elseif cmd == "selffound" or cmd == "selfmade" or cmd == "sf" then
        if HCE.SelfFoundCheck and HCE.SelfFoundCheck.PrintStatus then
            HCE.SelfFoundCheck.PrintStatus()
        else
            HCE.Print("Self-found tracking module not loaded.")
        end

    elseif cmd == "talents" or cmd == "talent" or cmd == "spec" then
        if HCE.TalentCheck and HCE.TalentCheck.PrintStatus then
            HCE.TalentCheck.PrintStatus()
        else
            HCE.Print("Talent tracking module not loaded.")
        end

    elseif cmd == "sources" or cmd == "source" or cmd == "itemsource" then
        if HCE.PrintItemSources then
            HCE.PrintItemSources()
        else
            HCE.Print("Item source data module not loaded.")
        end

    elseif cmd == "curated" then
        -- Diagnostic: show curated item-ID list status.  Sorted so the
        -- finished lists surface at the top.
        if not HCE.CuratedItems then
            HCE.Print("Curated item lists not loaded.")
        else
            local rows = {}
            for name, list in pairs(HCE.CuratedItems) do
                local n = 0
                for _ in pairs(list) do n = n + 1 end
                local complete = HCE.CuratedComplete and HCE.CuratedComplete[name]
                table.insert(rows, { name = name, count = n, complete = complete })
            end
            table.sort(rows, function(a, b)
                if a.count ~= b.count then return a.count > b.count end
                return a.name < b.name
            end)
            HCE.Print("Curated item lists:")
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
                HCE.Print("  " .. r.name .. ": " .. tag)
                totalItems = totalItems + r.count
            end
            HCE.Print(string.format(
                "Total: %d item%s across %d list%s (%d marked complete).",
                totalItems, totalItems == 1 and "" or "s",
                totalLists, totalLists == 1 and "" or "s",
                doneLists
            ))
        end

    elseif cmd == "reset" then
        HCE_CharDB.selectedCharacter = nil
        HCE_CharDB.manualOverride = false
        HCE_CharDB.lastLevel = UnitLevel("player") or 1
        HCE.Print("Enhanced class selection cleared.")
        if HCE.ProfessionCheck and HCE.ProfessionCheck.ResetWarnings then HCE.ProfessionCheck.ResetWarnings() end
        if HCE.TalentCheck and HCE.TalentCheck.ResetWarnings then HCE.TalentCheck.ResetWarnings() end
        if HCE.SelfFoundCheck and HCE.SelfFoundCheck.ResetWarnings then HCE.SelfFoundCheck.ResetWarnings() end
        if HCE.ChallengeCheck and HCE.ChallengeCheck.ResetWarnings then HCE.ChallengeCheck.ResetWarnings() end
        if HCE.ZoneCheck and HCE.ZoneCheck.ResetTracking then HCE.ZoneCheck.ResetTracking() end
        if HCE.BehavioralCheck and HCE.BehavioralCheck.ResetTracking then HCE.BehavioralCheck.ResetTracking() end
        if HCE.CompanionCheck and HCE.CompanionCheck.ResetWarnings then HCE.CompanionCheck.ResetWarnings() end
        if HCE.HunterPetCheck and HCE.HunterPetCheck.ResetWarnings then HCE.HunterPetCheck.ResetWarnings() end
        if HCE.MountCheck and HCE.MountCheck.ResetWarnings then HCE.MountCheck.ResetWarnings() end
        if HCE.RefreshPanel then HCE.RefreshPanel() end

    elseif cmd == "companion" or cmd == "pet" or cmd == "critter" then
        if HCE.CompanionCheck and HCE.CompanionCheck.PrintStatus then
            HCE.CompanionCheck.PrintStatus()
        else
            HCE.Print("Companion tracking module not loaded.")
        end

    elseif cmd == "hunterpet" or cmd == "hpet" then
        if HCE.HunterPetCheck and HCE.HunterPetCheck.PrintStatus then
            HCE.HunterPetCheck.PrintStatus()
        else
            HCE.Print("Hunter pet tracking module not loaded.")
        end

    elseif cmd == "mount" or cmd == "riding" then
        if HCE.MountCheck and HCE.MountCheck.PrintStatus then
            HCE.MountCheck.PrintStatus()
        else
            HCE.Print("Mount tracking module not loaded.")
        end

    elseif cmd == "quests" or cmd == "quest" then
        if HCE.QuestCheck and HCE.QuestCheck.PrintStatus then
            HCE.QuestCheck.PrintStatus()
        else
            HCE.Print("Quest tracking module not loaded.")
        end

    elseif cmd == "behavioral" or cmd == "behaviour" or cmd == "behavior" then
        if HCE.BehavioralCheck and HCE.BehavioralCheck.PrintStatus then
            HCE.BehavioralCheck.PrintStatus()
        else
            HCE.Print("Behavioral tracking module not loaded.")
        end

    elseif cmd == "progress" or cmd == "prog" or cmd == "checklist" then
        if HCE.Progress and HCE.Progress.PrintStatus then
            HCE.Progress.PrintStatus()
        else
            HCE.Print("Progress summary module not loaded.")
        end

    elseif cmd == "donate" or cmd == "support" then
        HCE.Print("Thanks for your support!")
        HCE.Print("|cff66bbffhttps://buymeacoffee.com/berentbaris|r")
        -- Open an edit box so the player can copy the URL
        if not HCE._donateEditBox then
            local eb = CreateFrame("EditBox", "HCE_DonateEditBox", UIParent, "InputBoxTemplate")
            eb:SetSize(320, 28)
            eb:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
            eb:SetAutoFocus(true)
            eb:SetText("https://buymeacoffee.com/berentbaris")
            eb:HighlightText()
            eb:SetScript("OnEscapePressed", function(self) self:Hide() end)
            eb:SetScript("OnEnterPressed", function(self) self:Hide() end)
            eb:SetScript("OnEditFocusLost", function(self) self:Hide() end)
            HCE._donateEditBox = eb
        else
            HCE._donateEditBox:SetText("https://buymeacoffee.com/berentbaris")
            HCE._donateEditBox:Show()
            HCE._donateEditBox:HighlightText()
            HCE._donateEditBox:SetFocus()
        end

    elseif cmd == "settings" or cmd == "options" or cmd == "config" then
        if HCE.SettingsPanel and HCE.SettingsPanel.Toggle then
            HCE.SettingsPanel.Toggle()
        else
            HCE.Print("Settings panel not loaded.")
        end

    elseif cmd == "gameplay" or cmd == "tips" or cmd == "flavor" then
        if cmd == "tips" and HCE.GameplayTips then
            -- Toggle periodic tip reminders
            if HCE_GlobalDB.gameplayTipsEnabled == nil then
                HCE_GlobalDB.gameplayTipsEnabled = true
            end
            HCE_GlobalDB.gameplayTipsEnabled = not HCE_GlobalDB.gameplayTipsEnabled
            if HCE_GlobalDB.gameplayTipsEnabled then
                HCE.Print("Periodic gameplay tip reminders |cff00ff00enabled|r.")
                HCE.GameplayTips.StartReminder()
            else
                HCE.Print("Periodic gameplay tip reminders |cffff5555disabled|r.")
                HCE.GameplayTips.StopReminder()
            end
        elseif HCE.GameplayTips and HCE.GameplayTips.PrintStatus then
            HCE.GameplayTips.PrintStatus()
        else
            HCE.Print("Gameplay tips module not loaded.")
        end

    elseif cmd == "testsummary" then
        if HCE.LevelUpSummary and HCE.LevelUpSummary.Test then
            HCE.LevelUpSummary.Test()
        else
            HCE.Print("Level-up summary module not loaded.")
        end

    elseif cmd == "version" then
        HCE.Print("Version " .. HCE.version)

    else
        HCE.Print("Unknown command: " .. cmd .. ". Type /hce for help.")
    end
end

----------------------------------------------------------------------
-- Party chat announcements
--
-- Sends messages to PARTY chat so groupmates know you're playing
-- an enhanced class.  Controlled by HCE_GlobalDB.partyAnnounce.
----------------------------------------------------------------------

--- Check whether the player is in a party/raid.
local function IsInGroup()
    return IsInGroup and IsInGroup() or GetNumGroupMembers() > 0
end

--- Get the selected character data, or nil.
local function GetSelectedChar()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return nil end
    return HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
end

--- Group-join announcement to party chat.
local function AnnounceGroupJoin()
    if not HCE_GlobalDB.partyAnnounce then return end
    if not IsInGroup() then return end
    local char = GetSelectedChar()
    if not char then return end

    -- Build a short flavour warning based on challenges
    local warnings = {}

    local msg = "I'm playing as a " .. char.name
        .. " — enhanced class with special rules"
    if #warnings > 0 then
        msg = msg .. " (" .. table.concat(warnings, ", ") .. ")"
    end
    msg = msg .. ". [HCE]"

    SendChatMessage(msg, "PARTY")
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

    elseif event == "PLAYER_LEVEL_UP" then
        local newLevel = ...
        if newLevel then
            AnnounceLevelUp(newLevel)
        end

    elseif event == "GROUP_JOINED" then
        -- Small delay so the party channel is ready
        C_Timer.After(2.0, function()
            AnnounceGroupJoin()
        end)

    elseif event == "PLAYER_LOGOUT" then
        -- Future: persist runtime state
    end
end)
