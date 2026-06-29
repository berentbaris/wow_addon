----------------------------------------------------------------------
-- ClassicClassesEnhanced — Quest Completion Tracker
--
-- Checks whether the player has completed the quests required by
-- their enhanced class.  Quest data lives in CharacterData.lua as
-- a quests = { {name, level, questID}, ... } array per character.
--
-- Uses the WoW API:
--   C_QuestLog.IsQuestFlaggedCompleted(questID)  — server-side,
--     persistent, no SavedVars needed.
--
-- Provides:
--   QuestCheck.RunCheck()   — refresh results
--   QuestCheck.GetResults() — { [i] = {status, detail} }
--   QuestCheck.STATUS       — {PASS, FAIL, UNCHECKED, INACTIVE}
----------------------------------------------------------------------

CCE = CCE or {}

local QC = {}
CCE.QuestCheck = QC

----------------------------------------------------------------------
-- Status constants
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"
local INACTIVE  = "inactive"

QC.STATUS = {
    PASS      = PASS,
    FAIL      = FAIL,
    UNCHECKED = UNCHECKED,
    INACTIVE  = INACTIVE,
}

----------------------------------------------------------------------
-- Results cache — indexed by quest position in char.quests
----------------------------------------------------------------------

local results = {}

function QC.GetResults()
    return results
end

----------------------------------------------------------------------
-- Core check
----------------------------------------------------------------------

function QC.RunCheck()
    results = {}

    if not CCE_CharDB or not CCE_CharDB.selectedCharacter then return end
    local char = CCE.GetCharacter and CCE.GetCharacter(CCE_CharDB.selectedCharacter)
    local quests = CCE.GetCharQuests and CCE.GetCharQuests(char) or char.quests or {}
    if not char or #quests == 0 then return end

    local playerLevel = UnitLevel("player") or 1

    -- C_QuestLog.IsQuestFlaggedCompleted may not exist on every
    -- Classic build.  Fall back to GetQuestsCompleted if needed.
    local checkCompleted
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        checkCompleted = C_QuestLog.IsQuestFlaggedCompleted
    else
        -- Bulk lookup fallback
        local completed = GetQuestsCompleted and GetQuestsCompleted() or {}
        checkCompleted = function(qid) return completed[qid] end
    end

    for i, quest in ipairs(quests) do
        if playerLevel < quest.level then
            results[i] = {
                status = INACTIVE,
                detail = "Unlocks at level " .. quest.level,
            }
        else
            local done = checkCompleted(quest.questID)
            if done then
                results[i] = {
                    status = PASS,
                    detail = quest.name .. " — completed",
                }
            else
                results[i] = {
                    status = FAIL,
                    detail = quest.name .. " — not yet completed (quest #" .. quest.questID .. ")",
                }
            end
        end
    end
end

----------------------------------------------------------------------
-- Slash command: /cce quests
----------------------------------------------------------------------

function QC.PrintStatus()
    if not CCE_CharDB or not CCE_CharDB.selectedCharacter then
        CCE.Print("No enhanced class selected.")
        return
    end

    local char = CCE.GetCharacter and CCE.GetCharacter(CCE_CharDB.selectedCharacter)
    local quests = CCE.GetCharQuests and CCE.GetCharQuests(char) or char.quests or {}
    if not char or #quests == 0 then
        CCE.Print("Your character has no quest requirements.")
        return
    end

    QC.RunCheck()

    -- Build group list
    local groups
    if char.questGroups then
        groups = char.questGroups
    elseif char.questTheme then
        groups = { { theme = char.questTheme, count = #quests } }
    else
        groups = { { theme = "Quests", count = #quests } }
    end

    local questIdx = 1
    for _, group in ipairs(groups) do
        CCE.Print("Quest progress — " .. (group.theme or "Quests") .. ":")
        for _ = 1, group.count do
            local quest = quests[questIdx]
            if not quest then break end
            local res = results[questIdx]
            questIdx = questIdx + 1
            local tag
            if not res or res.status == INACTIVE then
                tag = "|cff595959INACTIVE|r"
            elseif res.status == PASS then
                tag = "|cff4de64dDONE|r"
            elseif res.status == FAIL then
                tag = "|cffff5a4cINCOMPLETE|r"
            else
                tag = "|cffa5a582???|r"
            end
            CCE.Print("  " .. tag .. " [lv " .. quest.level .. "] " .. quest.name)
        end
    end
end

----------------------------------------------------------------------
-- Event frame — re-check on relevant events
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("QUEST_TURNED_IN")
eventFrame:RegisterEvent("QUEST_LOG_UPDATE")

eventFrame:SetScript("OnEvent", function(_, event)
    -- Only run if we have a selected character with quests
    if not CCE_CharDB or not CCE_CharDB.selectedCharacter then return end
    local char = CCE.GetCharacter and CCE.GetCharacter(CCE_CharDB.selectedCharacter)
    local quests = CCE.GetCharQuests and CCE.GetCharQuests(char) or char.quests or {}
    if not char or #quests == 0 then return end

    if event == "PLAYER_LOGIN" then
        -- Initial check after a short delay so other systems are ready
        C_Timer.After(2, function()
            QC.RunCheck()
            if CCE.RefreshPanel then CCE.RefreshPanel() end
        end)
    elseif event == "QUEST_TURNED_IN" then
        -- A quest was just turned in — re-check immediately
        C_Timer.After(0.5, function()
            QC.RunCheck()
            if CCE.RefreshPanel then CCE.RefreshPanel() end
        end)
    elseif event == "QUEST_LOG_UPDATE" then
        -- Throttle quest log updates to avoid spam
        C_Timer.After(1, function()
            QC.RunCheck()
        end)
    end
end)
