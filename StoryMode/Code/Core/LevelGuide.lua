local addonName, SM = ...
local L = SM.L

function SM.IsClassicLevelGuideShown(data)
    if not (data and SM.Client) then return false end
    local versions = data.gameVersions
    if SM.Client.isClassicEra then
        return type(versions) == "table" and versions.classicEra == true
    elseif SM.Client.isTBC then
        return type(versions) == "table" and versions.tbc == true
    end
    return false
end

function SM.GetRecommendedLevelText(data)
    if not SM.IsClassicLevelGuideShown(data) then return nil end

    local level = data.recommendedLevel
    if type(level) == "number" then
        return tostring(level)
    elseif type(level) == "string" and level ~= "" then
        return level
    elseif type(level) == "table" then
        if level.min and level.max and level.min ~= level.max then
            return string.format("%d-%d", level.min, level.max)
        elseif level.min or level.max then
            return tostring(level.min or level.max)
        end
    end

    if data.requiredLevel then
        return tostring(data.requiredLevel)
    end

    local minLevel, maxLevel
    local chapters = SM.GetAllChapters(data)
    for _, chapter in ipairs(chapters) do
        local requiredLevel = chapter.requiredLevel
        if requiredLevel then
            minLevel = minLevel and math.min(minLevel, requiredLevel) or requiredLevel
            maxLevel = maxLevel and math.max(maxLevel, requiredLevel) or requiredLevel
        end
    end
    if minLevel and maxLevel and minLevel ~= maxLevel then
        return string.format("%d-%d", minLevel, maxLevel)
    elseif minLevel then
        return tostring(minLevel)
    end
    return nil
end

function SM.GetRecommendedLevelMinimum(data)
    local levelText = SM.GetRecommendedLevelText(data)
    if type(levelText) ~= "string" then return nil end
    return tonumber(levelText:match("^(%d+)"))
end

function SM.GetQuestlineCardSubline(data)
    local zoneText = SM.GetQuestlineZoneText(data)
    local levelText = SM.GetRecommendedLevelText(data)
    if levelText and zoneText ~= "" then
        return string.format(L["Story Level Zone Format"], levelText, zoneText)
    elseif levelText then
        return string.format(L["Story Level Format"], levelText)
    end
    return zoneText
end

function SM.GetStoryIntroText(data)
    return data and data.description or ""
end

function SM.GetStorySuggestedLevelText(data)
    local levelText = SM.GetRecommendedLevelText(data)
    if not levelText then return nil end
    return string.format(L["Story Suggested Level Format"], levelText)
end
