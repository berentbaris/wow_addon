local addonName, SM = ...

SM.L = SM.L or {}

setmetatable(SM.L, {
    __index = function(_, key)
        return type(key) == "string" and key or nil
    end,
})

function SM.Locale(key)
    return SM.L[key]
end

function SM.LocaleFormat(key, ...)
    return string.format(SM.L[key] or key, ...)
end

local function Localize(value)
    return type(value) == "string" and SM.L[value] or value
end

local function LocalizeField(tbl, key)
    if tbl and type(tbl[key]) == "string" then
        tbl[key] = Localize(tbl[key])
    end
end

local function LocalizeKeyedTable(tbl)
    if type(tbl) ~= "table" then return tbl end

    local localized = {}
    for key, value in pairs(tbl) do
        localized[Localize(key)] = value
    end
    return localized
end

local function LocalizeQuest(quest)
    if type(quest) ~= "table" then return end

    LocalizeField(quest, "name")
    LocalizeField(quest, "displayName")
    LocalizeField(quest, "npc")
    LocalizeField(quest, "location")
    LocalizeField(quest, "trackingHint")
    LocalizeField(quest, "trackingHintFormat")
    LocalizeField(quest, "trackingHintQuestName")
    LocalizeField(quest, "trackingHintPlace")
    LocalizeField(quest, "trackingHintNPC")
    LocalizeField(quest, "trackingHintDestination")
    LocalizeQuest(quest.guidanceQuest)
    if type(quest.guidanceQuests) == "table" then
        for _, guidanceQuest in ipairs(quest.guidanceQuests) do
            LocalizeQuest(guidanceQuest)
        end
    end
end

local function LocalizeChapter(chapter)
    if type(chapter) ~= "table" then return end

    LocalizeField(chapter, "chapter")
    LocalizeField(chapter, "summary")
    LocalizeField(chapter, "recap")
    LocalizeField(chapter, "note")
    LocalizeField(chapter, "achievementName")

    if type(chapter.repRequirement) == "table" then
        LocalizeField(chapter.repRequirement, "faction")
        LocalizeField(chapter.repRequirement, "level")
    end

    if type(chapter.quests) == "table" then
        for _, quest in ipairs(chapter.quests) do
            LocalizeQuest(quest)
        end
    end

    if type(chapter.prerequisites) == "table" then
        for _, quest in ipairs(chapter.prerequisites) do
            LocalizeQuest(quest)
        end
    end
end

function SM.LocalizeContentData(data)
    if type(data) ~= "table" or data._localized then return data end
    data._localized = true

    if type(data.title) == "string" and not data._originalTitle then
        data._originalTitle = data.title
    end

    LocalizeField(data, "title")
    LocalizeField(data, "achievementName")
    LocalizeField(data, "description")
    LocalizeField(data, "zone")
    LocalizeField(data, "expansion")
    LocalizeField(data, "adventureGuideInstanceName")

    LocalizeQuest(data.startQuest)

    data.npcLocations = LocalizeKeyedTable(data.npcLocations)
    data.npcDisplayIDs = LocalizeKeyedTable(data.npcDisplayIDs)
    data.chapterDisplayIDs = LocalizeKeyedTable(data.chapterDisplayIDs)
    data.chapterIcons = LocalizeKeyedTable(data.chapterIcons)

    if type(data.factions) == "table" then
        for _, entry in ipairs(data.factions) do
            if type(entry) == "table" then
                LocalizeField(entry, "name")
                LocalizeField(entry, "description")
            end
        end
    end

    if type(data.prereqs) == "table" then
        for _, chapter in ipairs(data.prereqs) do
            LocalizeChapter(chapter)
        end
    end

    if type(data.chapters) == "table" then
        for _, chapter in ipairs(data.chapters) do
            LocalizeChapter(chapter)
        end
    end

    return data
end
