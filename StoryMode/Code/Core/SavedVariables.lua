local addonName, SM = ...

local defaults = {
    version = "1.7.0",
    selectedQuestline = 1,
    selectedQuestlineID = nil,
    minimapIconStyle = "borderless",
    characterChapterFlags = {},
    viewedLoreChapters = {},
    playedChapters = {},
}

local function ChapterFlagKey(storylineTitle, chapterName)
    return (storylineTitle or "") .. "|" .. (chapterName or "")
end

local function CharacterKey()
    local name, realm
    if UnitFullName then
        name, realm = UnitFullName("player")
    end
    if not name or name == "" then
        name = UnitName and UnitName("player")
    end
    if not name or name == "" then
        return nil
    end
    if not realm or realm == "" then
        realm = GetNormalizedRealmName and GetNormalizedRealmName()
    end
    if not realm or realm == "" then
        realm = GetRealmName and GetRealmName()
    end
    return (realm or "UnknownRealm") .. ":" .. name
end

local function GetCharacterChapterFlags(flagType, create)
    if not StoryModeDB then return nil end

    local characterKey = CharacterKey()
    if not characterKey then return nil end

    if create and not StoryModeDB.characterChapterFlags then
        StoryModeDB.characterChapterFlags = {}
    end
    local allCharacterFlags = StoryModeDB.characterChapterFlags
    if not allCharacterFlags then return nil end

    if create and not allCharacterFlags[characterKey] then
        allCharacterFlags[characterKey] = {}
    end
    local characterFlags = allCharacterFlags[characterKey]
    if not characterFlags then return nil end

    if create and not characterFlags[flagType] then
        characterFlags[flagType] = {}
    end
    return characterFlags[flagType]
end

function SM.ApplySavedVariableDefaults()
    StoryModeDB = StoryModeDB or {}
    for key, value in pairs(defaults) do
        if StoryModeDB[key] == nil then
            StoryModeDB[key] = type(value) == "table" and CopyTable(value) or value
        end
    end
end

function SM.IsLoreChapterViewed(storylineTitle, chapterName)
    local viewedLoreChapters = GetCharacterChapterFlags("viewedLoreChapters", false)
    if not viewedLoreChapters then return false end
    return viewedLoreChapters[ChapterFlagKey(storylineTitle, chapterName)] == true
end

function SM.SetLoreChapterViewed(storylineTitle, chapterName)
    local viewedLoreChapters = GetCharacterChapterFlags("viewedLoreChapters", true)
    if not viewedLoreChapters then return end
    viewedLoreChapters[ChapterFlagKey(storylineTitle, chapterName)] = true
    if SM.InvalidateProgressCache then SM.InvalidateProgressCache() end
end

local function GetCharacterRecord(create)
    if not StoryModeDB then return nil end
    local characterKey = CharacterKey()
    if not characterKey then return nil end
    if create and not StoryModeDB.characterChapterFlags then
        StoryModeDB.characterChapterFlags = {}
    end
    local allCharacterFlags = StoryModeDB.characterChapterFlags
    if not allCharacterFlags then return nil end
    if create and not allCharacterFlags[characterKey] then
        allCharacterFlags[characterKey] = {}
    end
    return allCharacterFlags[characterKey]
end

function SM.GetScarletKillCount()
    local record = GetCharacterRecord(false)
    return (record and tonumber(record.scarletKills)) or 0
end

function SM.IncrementScarletKillCount()
    local record = GetCharacterRecord(true)
    if not record then return 0 end
    record.scarletKills = (tonumber(record.scarletKills) or 0) + 1
    return record.scarletKills
end

function SM.IsScarletCrusaderRevealed()
    local record = GetCharacterRecord(false)
    return (record and record.scarletCrusaderRevealed == true) or false
end

function SM.SetScarletCrusaderRevealed()
    local record = GetCharacterRecord(true)
    if not record or record.scarletCrusaderRevealed then return end
    record.scarletCrusaderRevealed = true
    if SM.InvalidateProgressCache then SM.InvalidateProgressCache() end
end

function SM.RecordScarletNamedKill(key)
    if not key then return false end
    local record = GetCharacterRecord(true)
    if not record then return false end
    record.scarletNames = record.scarletNames or {}
    if record.scarletNames[key] then return false end
    record.scarletNames[key] = true
    return true
end

function SM.GetScarletNamedKills()
    local record = GetCharacterRecord(false)
    return record and record.scarletNames or nil
end

function SM.IsScarletVossBannerShown()
    local record = GetCharacterRecord(false)
    return (record and record.scarletVossBanner == true) or false
end

function SM.SetScarletVossBannerShown()
    local record = GetCharacterRecord(true)
    if not record then return end
    record.scarletVossBanner = true
end

function SM.IsScarletCapstoneBannerShown()
    local record = GetCharacterRecord(false)
    return (record and record.scarletCapstoneBanner == true) or false
end

function SM.SetScarletCapstoneBannerShown()
    local record = GetCharacterRecord(true)
    if not record then return end
    record.scarletCapstoneBanner = true
end

function SM.IsChapterPlayed(storylineTitle, chapterName)
    local playedChapters = GetCharacterChapterFlags("playedChapters", false)
    if not playedChapters then return false end
    return playedChapters[ChapterFlagKey(storylineTitle, chapterName)] == true
end

function SM.SetChapterPlayed(storylineTitle, chapterName)
    local playedChapters = GetCharacterChapterFlags("playedChapters", true)
    if not playedChapters then return end
    playedChapters[ChapterFlagKey(storylineTitle, chapterName)] = true
    if SM.InvalidateProgressCache then SM.InvalidateProgressCache() end
end
