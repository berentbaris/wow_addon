----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Quest Completion Tracker
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

HCE = HCE or {}

local QC = {}
HCE.QuestCheck = QC

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

    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return end
    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.quests then return end

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

    for i, quest in ipairs(char.quests) do
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
-- Slash command: /hce quests
----------------------------------------------------------------------

function QC.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected.")
        return
    end

    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.quests or #char.quests == 0 then
        HCE.Print("Your character has no quest requirements.")
        return
    end

    QC.RunCheck()

    local theme = char.questTheme or "Quests"
    HCE.Print("Quest progress — " .. theme .. ":")

    for i, quest in ipairs(char.quests) do
        local res = results[i]
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
        HCE.Print("  " .. tag .. " [lv " .. quest.level .. "] " .. quest.name)
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
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return end
    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char or not char.quests then return end

    if event == "PLAYER_LOGIN" then
        -- Initial check after a short delay so other systems are ready
        C_Timer.After(2, function()
            QC.RunCheck()
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
    elseif event == "QUEST_TURNED_IN" then
        -- A quest was just turned in — re-check immediately
        C_Timer.After(0.5, function()
            QC.RunCheck()
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
    elseif event == "QUEST_LOG_UPDATE" then
        -- Throttle quest log updates to avoid spam
        C_Timer.After(1, function()
            QC.RunCheck()
        end)
    end
end)
