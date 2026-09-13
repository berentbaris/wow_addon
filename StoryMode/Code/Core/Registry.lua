local addonName, SM = ...
local L = SM.L

local categories = {
    { name = "Stories", displayName = L["Category Stories"], questlines = {} },
    { name = "Epic Stories", displayName = L["Category Epic Stories"], questlines = {} },
    { name = "Short Stories", displayName = L["Category Short Stories"], questlines = {} },
    { name = "Character Stories", displayName = L["Category Character Stories"], questlines = {} },
    { name = "Identity", displayName = string.format(L["Category Identity Format"], UnitRace("player"), UnitClass("player")), questlines = {} },
}

local allQuestlines = {}
local questlinesByID = {}
local questLookupByID = {}
local questLookupByName = {}
local questlineSortOrder = 0
local registryReady = false

local playerClass
local playerFaction
local playerRace

local contentRegistry = {
    { key = "DefiasBrotherhoodData", category = "Stories" },
    { key = "ArugalData", category = "Stories" },
    { key = "ANewPlagueData", category = "Stories" },
    { key = "AlthalaxxData", category = "Stories" },
    { key = "DuskwoodData", category = "Stories" },
    { key = "ScytheOfEluneData", category = "Stories" },
    { key = "RaenesCleansingData", category = "Stories" },
    { key = "BattleOfHillsbradData", category = "Stories" },
    { key = "SavingYennikuData", category = "Stories" },
    { key = "MissingDiplomatData", category = "Stories" },
    { key = "PrincessMoiraData", category = "Stories" },
    { key = "MaraudonData", category = "Stories" },
    { key = "UldamanData", category = "Stories" },
    { key = "RheasLastEggData", category = "Stories" },
    { key = "RunasTheShamedData", category = "Stories" },
    { key = "MourningRiseData", category = "Stories" },

    { key = "ScarletCrusadeData", category = "Epic Stories" },
    { key = "DarrowshireData", category = "Epic Stories" },
    { key = "FallenHeroData", category = "Epic Stories" },
    { key = "OnyxiaData", category = "Epic Stories" },
    { key = "DungeonSetTwoData", category = "Epic Stories" },
    { key = "HakkariTrailData", category = "Epic Stories" },
    { key = "ScholomanceData", category = "Epic Stories" },
    { key = "ShiftingSandsData", category = "Epic Stories" },
    { key = "FrozenThroneData", category = "Epic Stories" },
    { key = "JadeForestData", category = "Epic Stories" },
    { key = "DrustvarData", category = "Epic Stories" },
    { key = "SuramarData", category = "Epic Stories" },
    { key = "NazmirData", category = "Epic Stories" },
    { key = "RevendrethData", category = "Epic Stories" },
    { key = "BlueDragonflightData", category = "Epic Stories" },

    { key = "VeritistraszData", category = "Short Stories" },
    { key = "TeddiesAndTeaData", category = "Short Stories" },
    { key = "LinkenData", category = "Short Stories" },
    { key = "CortellosRiddleData", category = "Short Stories" },
    { key = "MissingCourierData", category = "Short Stories" },
    { key = "HoggerData", category = "Short Stories" },
    { key = "PoorOldBlanchyData", category = "Short Stories" },
    { key = "AgamandFamilyData", category = "Short Stories" },
    { key = "KingsTributeData", category = "Short Stories" },
    { key = "MankriksWifeData", category = "Short Stories" },
    { key = "ShadyRestInnData", category = "Short Stories" },
    { key = "NothingButTheTruthData", category = "Short Stories" },

    { key = "SylvanasData", category = "Character Stories" },
    { key = "JainaData", category = "Character Stories" },
    { key = "LilianVossData", category = "Character Stories" },

    { key = "ClassicDruidQuestData", category = "Identity" },
    { key = "ClassicHunterQuestData", category = "Identity" },
    { key = "ClassicMageQuestData", category = "Identity" },
    { key = "ClassicPaladinQuestData", category = "Identity" },
    { key = "ClassicPriestQuestData", category = "Identity" },
    { key = "ClassicRogueQuestData", category = "Identity" },
    { key = "ClassicShamanQuestData", category = "Identity" },
    { key = "ClassicWarlockQuestData", category = "Identity" },
    { key = "ClassicWarriorQuestData", category = "Identity" },
    { key = "DeathKnightCampaignData", category = "Identity" },
    { key = "DemonHunterCampaignData", category = "Identity" },
    { key = "DruidCampaignData", category = "Identity" },
    { key = "HunterCampaignData", category = "Identity" },
    { key = "MageCampaignData", category = "Identity" },
    { key = "MonkCampaignData", category = "Identity" },
    { key = "PaladinCampaignData", category = "Identity" },
    { key = "PriestCampaignData", category = "Identity" },
    { key = "RogueCampaignData", category = "Identity" },
    { key = "ShamanCampaignData", category = "Identity" },
    { key = "WarlockCampaignData", category = "Identity" },
    { key = "WarriorCampaignData", category = "Identity" },
    { key = "ForsakenHeritageData", category = "Identity" },
    { key = "BloodElfHeritageData", category = "Identity" },
    { key = "GoblinHeritageData", category = "Identity" },
    { key = "TrollHeritageData", category = "Identity" },
    { key = "OrcHeritageData", category = "Identity" },
    { key = "TaurenHeritageData", category = "Identity" },
    { key = "HumanHeritageData", category = "Identity" },
    { key = "DwarfHeritageData", category = "Identity" },
    { key = "GnomeHeritageData", category = "Identity" },
    { key = "NightElfHeritageData", category = "Identity" },
    { key = "WorgenHeritageData", category = "Identity" },
    { key = "DraeneiHeritageData", category = "Identity" },
    { key = "PandarenHeritageData", category = "Identity" },
    { key = "DarkIronHeritageData", category = "Identity" },
}

local function GetContentRegistryData(entry)
    local data = entry and SM[entry.key]
    if data then
        data.category = entry.category
    end
    return data
end

local function ForEachContentRegistryData(callback)
    for _, entry in ipairs(contentRegistry) do
        local data = GetContentRegistryData(entry)
        if data then callback(data, entry) end
    end
end

local function RefreshPlayerContext()
    local raceName
    local className
    raceName, playerRace = UnitRace("player")
    className, playerClass = UnitClass("player")
    playerFaction = UnitFactionGroup("player")
    if raceName and className and categories[5] then
        categories[5].displayName = string.format(L["Category Identity Format"], raceName, className)
    end
end

local function SlugifyQuestlineID(text)
    text = tostring(text or ""):lower()
    text = text:gsub("[^a-z0-9]+", "-")
    text = text:gsub("^-+", ""):gsub("-+$", "")
    return text ~= "" and text or "story"
end

local function EnsureUniqueQuestlineID(data)
    local baseID = data.id or data.storyID or SlugifyQuestlineID(data.title or data.achievementName)
    local id = baseID
    local suffix = 2
    while questlinesByID[id] and questlinesByID[id] ~= data do
        id = baseID .. "-" .. suffix
        suffix = suffix + 1
    end
    data.id = id
    questlinesByID[id] = data
end

local function AssignStableQuestlineID(data)
    if data and not data.id and not data.storyID then
        data.id = SlugifyQuestlineID(data.title or data.achievementName)
    end
end

local function NormalizeQuestlineData(data)
    if not data or data._storyModeNormalized then return end
    EnsureUniqueQuestlineID(data)
    local chapters = SM.GetAllChapters(data)
    for chapterIndex, ch in ipairs(chapters) do
        ch._story = data
        ch._storyID = data.id
        ch._chapterIndex = chapterIndex
        ch._chapterKey = ch.chapter or tostring(chapterIndex)
        if ch.quests then
            for questIndex, q in ipairs(ch.quests) do
                q._story = data
                q._storyID = data.id
                q._chapter = ch
                q._chapterIndex = chapterIndex
                q._questIndex = questIndex
                q._questIDs = SM.GetQuestIDs(q)
                for _, questID in ipairs(q._questIDs) do
                    questLookupByID[questID] = { story = data, quest = q, chapter = ch }
                end
                if q.name and q.name ~= "" then
                    questLookupByName[q.name] = { story = data, quest = q, chapter = ch }
                end
            end
        end
    end
    data._storyModeNormalized = true
end

local function CanShowQuestline(data)
    RefreshPlayerContext()
    if not data then return false end
    if not SM.IsContentAvailableForClient(data) then return false end
    if data.class and data.class ~= playerClass then return false end
    if data.faction and data.faction ~= playerFaction then return false end
    if data.race and data.race ~= playerRace then return false end
    return true
end

local function RegisterQuestline(data, categoryName)
    NormalizeQuestlineData(data)
    questlineSortOrder = questlineSortOrder + 1
    data._storyModeSortOrder = questlineSortOrder
    allQuestlines[#allQuestlines + 1] = data
    for _, cat in ipairs(categories) do
        if cat.name == categoryName then
            cat.questlines[#cat.questlines + 1] = data
            break
        end
    end
end

local function GetQuestlineSortLevel(data)
    return SM.GetRecommendedLevelMinimum(data) or math.huge
end

local function SortQuestlineCategories()
    for _, cat in ipairs(categories) do
        if cat.questlines and #cat.questlines > 1 then
            table.sort(cat.questlines, function(a, b)
                local aLevel = GetQuestlineSortLevel(a)
                local bLevel = GetQuestlineSortLevel(b)
                if aLevel ~= bLevel then
                    return aLevel < bLevel
                end
                return (a._storyModeSortOrder or 0) < (b._storyModeSortOrder or 0)
            end)
        end
    end
end

function SM.GetQuestlineZoneText(data)
    RefreshPlayerContext()
    if not data then return "" end
    if data.zoneByFaction then
        local factionZone = data.zoneByFaction[playerFaction]
        if factionZone and factionZone ~= "" then return factionZone end
    end
    return data.zone or ""
end

function SM.GetQuestlineByID(id)
    return id and questlinesByID[id] or nil
end

function SM.GetAllQuestlines()
    return allQuestlines
end

function SM.GetQuestlineCategories()
    return categories
end

local function IsLookupVisible(match)
    if not match then return false end
    return SM.IsQuestForPlayer(match.quest) and not SM.ShouldHideQuest(match.quest)
end

function SM.FindQuestStory(questID)
    if not questID then return nil end
    local match = questLookupByID[questID]
    if IsLookupVisible(match) then
        return match.story, match.quest, match.chapter
    end
    return nil
end

function SM.FindQuestStoryByName(questName)
    if not questName or questName == "" then return nil end
    local match = questLookupByName[questName]
    if IsLookupVisible(match) then
        return match.story, match.quest, match.chapter
    end
    return nil
end

function SM.LocalizeContentRegistry()
    ForEachContentRegistryData(function(data)
        AssignStableQuestlineID(data)
        SM.LocalizeContentData(data)
    end)
end

function SM.RegisterQuestlines()
    if registryReady then return end
    RefreshPlayerContext()
    if not (playerClass and playerFaction and playerRace) then return end

    ForEachContentRegistryData(function(data, entry)
        if CanShowQuestline(data) then
            RegisterQuestline(data, data.category or entry.category)
        end
    end)

    SortQuestlineCategories()
    registryReady = true
    if SM.InvalidateProgressCache then SM.InvalidateProgressCache() end
end

function SM.IsQuestlineRegistryReady()
    return registryReady
end

SM.LocalizeContentRegistry()
