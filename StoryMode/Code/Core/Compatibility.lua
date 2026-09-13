local addonName, SM = ...

_G.StoryMode = SM

local WOW_PROJECT_MAINLINE = _G.WOW_PROJECT_MAINLINE or 1
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_BURNING_CRUSADE_CLASSIC = _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5

local projectID = _G.WOW_PROJECT_ID or WOW_PROJECT_MAINLINE
local isClassicEra = projectID == WOW_PROJECT_CLASSIC
local isTBC = projectID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
local isRetail = projectID == WOW_PROJECT_MAINLINE

local expansionLevels = {
    Classic = 0,
    ["The Burning Crusade"] = 1,
    ["Wrath of the Lich King"] = 2,
    Cataclysm = 3,
    ["Mists of Pandaria"] = 4,
    ["Warlords of Draenor"] = 5,
    Legion = 6,
    ["Battle for Azeroth"] = 7,
    Shadowlands = 8,
    Dragonflight = 9,
    ["The War Within"] = 10,
    Midnight = 11,
}

local maxExpansionLevel
if isClassicEra then
    maxExpansionLevel = expansionLevels.Classic
elseif isTBC then
    maxExpansionLevel = expansionLevels["The Burning Crusade"]
elseif GetExpansionLevel then
    maxExpansionLevel = GetExpansionLevel()
else
    maxExpansionLevel = expansionLevels["The War Within"]
end

SM.Client = {
    projectID = projectID,
    isRetail = isRetail,
    isClassicEra = isClassicEra,
    isTBC = isTBC,
    maxExpansionLevel = maxExpansionLevel,
}

function SM.IsRetailClient()
    return SM.Client and SM.Client.isRetail
end

function SM.IsClassicClient()
    return not SM.IsRetailClient()
end

if not CopyTable then
    function CopyTable(source)
        if type(source) ~= "table" then return source end
        local copy = {}
        for key, value in pairs(source) do
            copy[key] = type(value) == "table" and CopyTable(value) or value
        end
        return copy
    end
end

if not CreateColor then
    function CreateColor(r, g, b, a)
        return {
            r = r,
            g = g,
            b = b,
            a = a == nil and 1 or a,
            GetRGBA = function(self)
                return self.r, self.g, self.b, self.a
            end,
        }
    end
end

if not GetAchievementInfo then
    function GetAchievementInfo(id)
        return nil
    end
end

if not GetAchievementNumCriteria then
    function GetAchievementNumCriteria(id)
        return 0
    end
end

if not GetAchievementCriteriaInfo then
    function GetAchievementCriteriaInfo(id, index)
        return nil
    end
end

function SM.LoadAddOn(addon)
    if C_AddOns and C_AddOns.LoadAddOn then
        return pcall(C_AddOns.LoadAddOn, addon)
    end
    if LoadAddOn then
        return pcall(LoadAddOn, addon)
    end
    return false
end

function SM.GetAchievementInfo(id)
    if GetAchievementInfo then
        return GetAchievementInfo(id)
    end
    return nil
end

function SM.GetAchievementNumCriteria(id)
    if GetAchievementNumCriteria then
        return GetAchievementNumCriteria(id)
    end
    return 0
end

function SM.GetAchievementCriteriaInfo(id, index)
    if GetAchievementCriteriaInfo then
        return GetAchievementCriteriaInfo(id, index)
    end
    return nil
end

function SM.IsQuestFlaggedCompleted(questID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
    end
    if IsQuestFlaggedCompleted then
        return IsQuestFlaggedCompleted(questID)
    end
    return false
end

function SM.GetLogIndexForQuestID(questID)
    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        return C_QuestLog.GetLogIndexForQuestID(questID)
    end
    if GetQuestLogIndexByID then
        local index = GetQuestLogIndexByID(questID)
        if index and index > 0 then return index end
    end
    return nil
end

function SM.AddQuestWatch(questID)
    if C_QuestLog and C_QuestLog.AddQuestWatch then
        return C_QuestLog.AddQuestWatch(questID)
    end
    if AddQuestWatch then
        return AddQuestWatch(SM.GetLogIndexForQuestID(questID) or questID)
    end
end

function SM.OpenQuestLogToQuest(questID)
    local logIndex = SM.GetLogIndexForQuestID(questID)
    if not logIndex then return false end

    if QuestLog_OpenToQuest and pcall(QuestLog_OpenToQuest, questID) then
        return true
    end

    if C_QuestLog and C_QuestLog.SetSelectedQuest then
        pcall(C_QuestLog.SetSelectedQuest, questID)
    end
    if QuestMapFrame_OpenToQuestDetails and pcall(QuestMapFrame_OpenToQuestDetails, questID) then
        return true
    end

    if OpenQuestLog then
        pcall(OpenQuestLog)
    elseif QuestLogFrame and ShowUIPanel then
        ShowUIPanel(QuestLogFrame)
    elseif ToggleQuestLog then
        ToggleQuestLog()
    end

    if SelectQuestLogEntry then
        pcall(SelectQuestLogEntry, logIndex)
    end
    if QuestLog_SetSelection then
        pcall(QuestLog_SetSelection, logIndex)
    end
    if QuestLog_Update then
        pcall(QuestLog_Update)
    end
    return true
end

function SM.GetQuestObjectives(questID)
    if C_QuestLog and C_QuestLog.GetQuestObjectives then
        return C_QuestLog.GetQuestObjectives(questID)
    end
    local logIndex = SM.GetLogIndexForQuestID(questID)
    if not logIndex or not GetNumQuestLeaderBoards or not GetQuestLogLeaderBoard then
        return nil
    end

    local objectives = {}
    for index = 1, GetNumQuestLeaderBoards(logIndex) do
        local text, objectiveType, finished = GetQuestLogLeaderBoard(index, logIndex)
        objectives[#objectives + 1] = {
            text = text,
            type = objectiveType,
            finished = finished,
        }
    end
    return objectives
end

function SM.GetNumTrackingTypes()
    if C_Minimap and C_Minimap.GetNumTrackingTypes then
        return C_Minimap.GetNumTrackingTypes()
    end
    if GetNumTrackingTypes then
        return GetNumTrackingTypes()
    end
    return 0
end

function SM.GetTrackingInfo(index)
    if C_Minimap and C_Minimap.GetTrackingInfo then
        return C_Minimap.GetTrackingInfo(index)
    end
    if GetTrackingInfo then
        local name, texture, active, category, nested, spellID = GetTrackingInfo(index)
        return {
            name = name,
            texture = texture,
            active = active,
            category = category,
            nested = nested,
            spellID = spellID,
        }
    end
    return nil
end

function SM.SetTracking(index, enabled)
    if C_Minimap and C_Minimap.SetTracking then
        return C_Minimap.SetTracking(index, enabled)
    end
    if SetTracking then
        return SetTracking(index, enabled)
    end
end

function SM.GetFactionDataByID(factionID)
    if C_Reputation and C_Reputation.GetFactionDataByID then
        return C_Reputation.GetFactionDataByID(factionID)
    end
    if GetFactionInfoByID then
        local name, description, standingID, bottomValue, topValue, earnedValue, atWarWith,
            canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild,
            factionIDOut, hasBonusRepGain, canSetInactive = GetFactionInfoByID(factionID)
        if name then
            return {
                name = name,
                description = description,
                reaction = standingID,
                currentReactionThreshold = bottomValue,
                nextReactionThreshold = topValue,
                currentStanding = earnedValue,
                atWarWith = atWarWith,
                canToggleAtWar = canToggleAtWar,
                isHeader = isHeader,
                isCollapsed = isCollapsed,
                hasRep = hasRep,
                isWatched = isWatched,
                isChild = isChild,
                factionID = factionIDOut or factionID,
                hasBonusRepGain = hasBonusRepGain,
                canSetInactive = canSetInactive,
            }
        end
    end
    return nil
end

function SM.GetContentExpansionLevel(data)
    local expansion = data and data.expansion
    if type(expansion) ~= "string" then return nil end

    local best
    for name, level in pairs(expansionLevels) do
        if expansion:find(name, 1, true) and (not best or level < best) then
            best = level
        end
    end
    return best
end

function SM.IsContentAvailableForClient(data)
    if type(data) == "table" and type(data.gameVersions) == "table" then
        if isRetail and data.gameVersions.retail then return true end
        if isClassicEra and data.gameVersions.classicEra then return true end
        if isTBC and data.gameVersions.tbc then return true end
        return false
    end

    if isRetail then
        return true
    end

    local contentLevel = SM.GetContentExpansionLevel(data)
    return not contentLevel or contentLevel <= maxExpansionLevel
end
