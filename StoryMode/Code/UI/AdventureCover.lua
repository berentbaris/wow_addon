local _, SM = ...

local HERITAGE_ICON_BY_RACE = {
    BloodElf = 2459464,
    Goblin = "Interface\\Icons\\inv_misc_tabard_goblin",
    Troll = "Interface\\Icons\\inv_misc_tabard_darkspear",
    Orc = "Interface\\Icons\\inv_misc_tabard_orgrimmar",
    Tauren = "Interface\\Icons\\inv_misc_tabard_thunderbluff",
    Human = "Interface\\Icons\\inv_misc_tabard_stormwind",
    Dwarf = "Interface\\Icons\\inv_misc_tabard_ironforge",
    Gnome = "Interface\\Icons\\inv_misc_tabard_gnomeregan",
    NightElf = "Interface\\Icons\\inv_misc_tabard_darnassus",
    Worgen = "Interface\\Icons\\inv_misc_tabard_gilneas",
    Draenei = "Interface\\Icons\\inv_misc_tabard_exodar",
    Pandaren = "Interface\\Icons\\inv_misc_tabard_tushui",
    DarkIronDwarf = "Interface\\Icons\\inv_misc_tabard_darkiron",
    Scourge = "Interface\\Icons\\inv_misc_tabard_forsaken",
}
local HERITAGE_ICON_FALLBACK = "Interface\\Icons\\inv_misc_cape_18"
local PANDAREN_TABARD_ICON = "Interface\\Icons\\inv_misc_tabard_tushui"
SM.HeritageIconByRace = HERITAGE_ICON_BY_RACE
SM.HeritageIconFallback = HERITAGE_ICON_FALLBACK
SM.PandarenTabardIcon = PANDAREN_TABARD_ICON

local ADVENTURE_COVER_W = 1200
local ADVENTURE_COVER_TEX_LEFT = 0.07
local ADVENTURE_COVER_TEX_RIGHT = 0.74
local ADVENTURE_COVER_TEX_TOP = 0.29
local ADVENTURE_COVER_TEX_BOTTOM = 0.46
local ADVENTURE_COVER_H = ADVENTURE_COVER_W
    * ((ADVENTURE_COVER_TEX_BOTTOM - ADVENTURE_COVER_TEX_TOP)
    / (ADVENTURE_COVER_TEX_RIGHT - ADVENTURE_COVER_TEX_LEFT))

SM.AdventureCover = {
    width = ADVENTURE_COVER_W,
    height = ADVENTURE_COVER_H,
    texLeft = ADVENTURE_COVER_TEX_LEFT,
    texRight = ADVENTURE_COVER_TEX_RIGHT,
    texTop = ADVENTURE_COVER_TEX_TOP,
    texBottom = ADVENTURE_COVER_TEX_BOTTOM,
}
SM.AdventureLoadingScreenTexHeight = (16 / 9) / (ADVENTURE_COVER_W / ADVENTURE_COVER_H)
SM.AdventureLoadingScreenTexTop = (1 - SM.AdventureLoadingScreenTexHeight) / 2
SM.AdventureLoadingScreenTexBottom = SM.AdventureLoadingScreenTexTop + SM.AdventureLoadingScreenTexHeight

local adventureGuideImageCache = {}
SM.AdventureGuideLoadingScreenByMapID = {
    [33] = 131869,    -- Shadowfang Keep
    [36] = 131833,    -- Deadmines
    [43] = 131882,    -- Wailing Caverns
    [70] = 131876,    -- Uldaman
    [90] = 131841,    -- Gnomeregan
    [230] = 131824,   -- Blackrock Depths
    [564] = 131826,   -- Black Temple
    [580] = 131873,   -- The Sunwell / Sunwell Plateau
    [608] = 236058,   -- Violet Hold
    [631] = 318964,   -- Icecrown Citadel
    [643] = 397151,   -- Throne of the Tides
    [960] = 633149,   -- Temple of the Jade Serpent
    [1004] = 645156,  -- Scarlet Monastery
    [1009] = 633148,  -- Heart of Fear
    [1136] = 903869,  -- Siege of Orgrimmar
    [1182] = 1034725, -- Auchindoun
    [1466] = 1389212, -- Darkheart Thicket
    [1477] = 1454826, -- Halls of Valor
    [1520] = 1394867, -- The Emerald Nightmare
    [1530] = 1448532, -- The Nighthold
    [1571] = 1477131, -- Court of Stars
    [1594] = 2016712, -- The MOTHERLODE!!
    [1676] = 1615560, -- Tomb of Sargeras
    [1677] = 1616802, -- Cathedral of Eternal Night
    [1753] = 1717768, -- Seat of the Triumvirate
    [1763] = 1968998, -- Atal'Dazar
    [1822] = 2068775, -- Siege of Boralus
    [1841] = 2175832, -- The Underrot
    [1862] = 1984118, -- Waycrest Manor
    [2296] = 3582016, -- Castle Nathria
}

SM.LoadingScreenChoices = {
    { name = "Eastern Kingdoms", texture = 131839 },
    { name = "Kalimdor", texture = 131848 },
    { name = "Eastern Kingdoms (Wide)", texture = 343001 },
    { name = "Kalimdor (Wide)", texture = 343002 },
    { name = "Ragefire Chasm", texture = 131862 },
    { name = "Wailing Caverns", texture = 131882 },
    { name = "The Deadmines", texture = 131833 },
    { name = "Shadowfang Keep", texture = 131869 },
    { name = "Blackfathom Deeps", texture = 131823 },
    { name = "The Stockade", texture = 131870 },
    { name = "Gnomeregan", texture = 131841 },
    { name = "Razorfen Kraul", texture = 131865 },
    { name = "Scarlet Monastery", texture = 131852 },
    { name = "Scarlet Monastery", texture = 645156 },
    { name = "Razorfen Downs", texture = 131864 },
    { name = "Uldaman", texture = 131876 },
    { name = "Zul'Farrak", texture = 131885 },
    { name = "Maraudon", texture = 131850 },
    { name = "Sunken Temple", texture = 131872 },
    { name = "Blackrock Depths", texture = 131824 },
    { name = "Blackrock Spire", texture = 131825 },
    { name = "Dire Maul", texture = 131835 },
    { name = "Scholomance", texture = 131868 },
    { name = "Stratholme", texture = 131871 },
    { name = "Caverns of Time: Old Stratholme", texture = 131859 },
    { name = "Molten Core", texture = 131851 },
    { name = "Blackwing Lair", texture = 131827 },
    { name = "Ruins of Ahn'Qiraj", texture = 131818 },
    { name = "Temple of Ahn'Qiraj", texture = 131819 },
    { name = "Zul'Gurub", texture = 131886 },
    { name = "Naxxramas", texture = 131854 },
    { name = "Arathi Basin", texture = 131820 },
    { name = "Warsong Gulch", texture = 131883 },
    { name = "Ruins of Lordaeron", texture = 131867 },
    { name = "Deeprun Tram", texture = 131834 },
    { name = "Champions' Hall", texture = 131831 },
    { name = "Hall of Legends", texture = 131843 },
    { name = "Cave", texture = 131829 },
    { name = "Dungeon", texture = 131838 },
    { name = "Raid", texture = 131863 },
    { name = "Ruined City", texture = 131866 },
    { name = "Demon Fall Canyon", texture = 6213069 },
    { name = "Storm Cliffs", texture = 6213070 },
    { name = "Tainted Scar", texture = 6213071 },
    { name = "Scarlet Enclave", texture = 6422642 },
    { name = "Karazhan Crypts", texture = 6514589 },
    { name = "Crystal Vale", texture = 6650900 },
    { name = "Nightmare Grove", texture = 6730949 },
}

function SM.NormalizeAdventureGuideName(name)
    if not name then return nil end
    name = string.lower(name)
    name = name:gsub("^the%s+", "")
    name = name:gsub("[^%w]", "")
    return name
end

function SM.EnsureEncounterJournalAPI()
    if EJ_GetInstanceInfo and EJ_GetInstanceByIndex then return true end
    SM.LoadAddOn("Blizzard_EncounterJournal")
    return EJ_GetInstanceInfo and EJ_GetInstanceByIndex
end

function SM.FindAdventureGuideInstanceID(instanceName)
    if not instanceName or instanceName == "" then return nil end
    if adventureGuideImageCache[instanceName] ~= nil then
        return adventureGuideImageCache[instanceName]
    end
    if not SM.EnsureEncounterJournalAPI() then return nil end

    -- securecall keeps our addon's insecure taint off Blizzard_EncounterJournal's
    -- saved tier state. Without it, EJ_SelectTier from this insecure context
    -- taints EJ's secure data and surfaces later as a MoneyFrame_Update arithmetic
    -- error when the user hovers loot in the Adventure Guide.
    local previousTier = EJ_GetCurrentTier and EJ_GetCurrentTier()
    local numTiers = EJ_GetNumTiers and EJ_GetNumTiers() or 0
    if numTiers <= 0 then
        adventureGuideImageCache[instanceName] = false
        return nil
    end

    local function RestorePreviousTier()
        if previousTier and previousTier >= 1 and previousTier <= numTiers then
            pcall(securecall, EJ_SelectTier, previousTier)
        end
    end

    local normalizedTarget = SM.NormalizeAdventureGuideName(instanceName)
    local normalizedMatches = {}
    for tier = 1, numTiers do
        pcall(securecall, EJ_SelectTier, tier)
        for _, isRaid in ipairs({ false, true }) do
            for i = 1, 200 do
                local instanceID, name = EJ_GetInstanceByIndex(i, isRaid)
                if not instanceID then break end
                if name == instanceName then
                    adventureGuideImageCache[instanceName] = instanceID
                    RestorePreviousTier()
                    return instanceID
                end
                if SM.NormalizeAdventureGuideName(name) == normalizedTarget then
                    normalizedMatches[#normalizedMatches + 1] = instanceID
                end
            end
        end
    end

    RestorePreviousTier()
    if normalizedMatches[1] then
        adventureGuideImageCache[instanceName] = normalizedMatches[1]
        return normalizedMatches[1]
    end
    adventureGuideImageCache[instanceName] = false
    return nil
end

function SM.GetAdventureCoverTexture(data)
    if not data then return nil end
    if data.adventureCoverTexture then
        return data.adventureCoverTexture, data.adventureCoverIsLoadingScreen
    end

    local instanceID = data.adventureGuideInstanceID
        or SM.FindAdventureGuideInstanceID(data.adventureGuideInstanceName)
    if instanceID and SM.EnsureEncounterJournalAPI() then
        local _, _, bgImage, buttonImage1, loreImage, buttonImage2, _, _, _, mapID = EJ_GetInstanceInfo(instanceID)
        if not data.adventureGuideImage then
            local loadingScreen = SM.AdventureGuideLoadingScreenByMapID[mapID]
            if loadingScreen then
                return loadingScreen, true
            end
        end
        if data.adventureGuideImage == "background" then
            return bgImage or loreImage or buttonImage1 or buttonImage2
        elseif data.adventureGuideImage == "button" then
            return buttonImage1 or buttonImage2 or loreImage or bgImage
        elseif data.adventureGuideImage == "button2" then
            return buttonImage2 or buttonImage1 or loreImage or bgImage
        elseif data.adventureGuideImage == "lore" then
            return loreImage or bgImage or buttonImage1 or buttonImage2
        end
        return loreImage or bgImage or buttonImage1 or buttonImage2
    end

    return data.adventureFallbackTexture or data.icon
end

local function ApplyAdventureCoverTexCoords(tex, data, useFullTexCoords)
    local texCoords = data and data.adventureCoverTexCoords
    if texCoords then
        tex:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
    elseif useFullTexCoords then
        tex:SetTexCoord(0, 1, SM.AdventureLoadingScreenTexTop, SM.AdventureLoadingScreenTexBottom)
    else
        tex:SetTexCoord(
            ADVENTURE_COVER_TEX_LEFT,
            ADVENTURE_COVER_TEX_RIGHT,
            ADVENTURE_COVER_TEX_TOP,
            ADVENTURE_COVER_TEX_BOTTOM
        )
    end
end

function SM.ApplyAdventureCoverFrame(cover, data, displayTitle)
    if not cover or not cover.texture then return end
    if cover.title then
        cover.title:SetText(displayTitle or (data and data.title) or "")
    end
    if cover.level then
        local levelText = SM.GetStorySuggestedLevelText and SM.GetStorySuggestedLevelText(data)
        if levelText and levelText ~= "" then
            cover.level:SetText(levelText)
            cover.level:Show()
        else
            cover.level:SetText("")
            cover.level:Hide()
        end
    end

    local texture, useFullTexCoords = SM.GetAdventureCoverTexture(data)
    if texture then
        ApplyAdventureCoverTexCoords(cover.texture, data, useFullTexCoords)
        if not SM.SafeSetTexture(cover.texture, texture) then
            cover.texture:SetColorTexture(0.08, 0.07, 0.06, 1)
        end
    else
        cover.texture:SetColorTexture(0.08, 0.07, 0.06, 1)
    end
end

function SM.SetAdventureCoverTexture(tex, data)
    if not tex then return false end
    local texture, useFullTexCoords = SM.GetAdventureCoverTexture(data)
    if not texture then
        tex:SetTexture(nil)
        return false
    end

    ApplyAdventureCoverTexCoords(tex, data, useFullTexCoords)

    if SM.SafeSetTexture(tex, texture) then
        return true
    end

    tex:SetTexture(nil)
    return false
end

function SM.SetChapterPortrait(portraitTex, displayID, iconPath, questID)
    portraitTex:SetTexture(nil)

    if questID and C_QuestLog and C_QuestLog.GetQuestPortraitGiver then
        local portrait = C_QuestLog.GetQuestPortraitGiver(questID)
        if portrait then
            portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            portraitTex:SetTexture(portrait)
            if portraitTex:GetTexture() then
                return
            end
        end
    end

    local currentStoryData = SM.GetCurrentStoryData and SM.GetCurrentStoryData() or nil
    local fallbackID = currentStoryData and currentStoryData.portraitDisplayID
    local tryID = nil
    if displayID and displayID ~= 0 then
        tryID = displayID
    elseif (SM.IsRetailClient()) and fallbackID then
        tryID = fallbackID
    end
    if tryID then
        portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        SetPortraitTextureFromCreatureDisplayID(portraitTex, tryID)
        if not portraitTex:GetTexture() then
            portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            if not (iconPath and SM.SafeSetTexture(portraitTex, iconPath)) then
                local storyIcon = currentStoryData and currentStoryData.icon
                SM.SafeSetTexture(portraitTex, storyIcon or "Interface\\Icons\\INV_Misc_Map_01")
            end
        end
    elseif currentStoryData and currentStoryData.race and not currentStoryData.class then
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        local achIcon
        if currentStoryData.achievementID then
            local _,_,_,_,_,_,_,_,_,icon = GetAchievementInfo(currentStoryData.achievementID)
            if icon and icon ~= 0 then achIcon = icon end
        end
        if not (achIcon and SM.SafeSetTexture(portraitTex, achIcon)) then
            local heritageIcon = HERITAGE_ICON_BY_RACE[currentStoryData.race]
            if not (heritageIcon and SM.SafeSetTexture(portraitTex, heritageIcon)) then
                if currentStoryData.race == "Pandaren" then
                    SM.SafeSetTexture(portraitTex, PANDAREN_TABARD_ICON)
                elseif not SM.SafeSetTexture(portraitTex, HERITAGE_ICON_FALLBACK) then
                    SM.SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_Map_01")
                end
            end
        end
    elseif iconPath then
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        if not SM.SafeSetTexture(portraitTex, iconPath) then
            local storyIcon = currentStoryData and currentStoryData.icon
            SM.SafeSetTexture(portraitTex, storyIcon or "Interface\\Icons\\INV_Misc_Map_01")
        end
    elseif currentStoryData and currentStoryData.icon then
        portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
        if not SM.SafeSetTexture(portraitTex, currentStoryData.icon) then
            local fallback = currentStoryData.race and HERITAGE_ICON_BY_RACE[currentStoryData.race]
            if not (fallback and SM.SafeSetTexture(portraitTex, fallback)) then
                SM.SafeSetTexture(portraitTex, "Interface\\Icons\\INV_Misc_Map_01")
            end
        end
    else
        portraitTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        local fallback = currentStoryData and currentStoryData.race and HERITAGE_ICON_BY_RACE[currentStoryData.race]
        if fallback then
            portraitTex:SetTexCoord(0.16, 0.84, 0.12, 0.88)
            SM.SafeSetTexture(portraitTex, fallback)
        else
            portraitTex:SetTexture(nil)
        end
    end
end

local function GetFirstQuestGiverDisplayID(data, chapter, playerFaction)
    if not data or not data.npcDisplayIDs or not chapter or not chapter.quests then
        return nil
    end
    for _, q in ipairs(chapter.quests) do
        if not q.faction or q.faction == playerFaction then
            local id = q.npc and data.npcDisplayIDs[q.npc]
            if id and id ~= 0 then
                return id
            end
        end
    end
    return nil
end

function SM.GetChapterPortraitSource(data, chapter)
    if not data or not chapter then
        return nil, nil, false
    end
    local playerFaction = UnitFactionGroup("player")
    local firstQuestGiverDisplayID = GetFirstQuestGiverDisplayID(data, chapter, playerFaction)

    if firstQuestGiverDisplayID then
        return firstQuestGiverDisplayID, nil, true
    end

    if data.race and not data.class then
        if data.chapterDisplayIDs then
            local chapterDisplayID = data.chapterDisplayIDs[chapter.chapter]
            if chapterDisplayID and chapterDisplayID ~= 0 then
                return chapterDisplayID, nil, true
            end
        end
        if data.chapterIcons then
            local chapterIcon = data.chapterIcons[chapter.chapter]
            if chapterIcon and chapterIcon ~= "" and chapterIcon ~= 0 then
                return nil, chapterIcon, true
            end
        end
        return nil, nil, false
    end

    if data.chapterDisplayIDs then
        local chapterDisplayID = data.chapterDisplayIDs[chapter.chapter]
        if chapterDisplayID and chapterDisplayID ~= 0 then
            return chapterDisplayID, nil, true
        end
    end

    if data.chapterIcons then
        local chapterIcon = data.chapterIcons[chapter.chapter]
        if chapterIcon and chapterIcon ~= "" and chapterIcon ~= 0 then
            return nil, chapterIcon, true
        end
    end

    return nil, nil, false
end
