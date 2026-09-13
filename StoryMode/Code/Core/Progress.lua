local addonName, SM = ...
local L = SM.L

local function GetPlayerFaction()
    return UnitFactionGroup("player")
end

local function GetPlayerRace()
    return select(2, UnitRace("player"))
end

local function GetPlayerClass()
    return select(2, UnitClass("player"))
end

local function PlayerMatches(value, playerValue)
    if type(value) == "table" then
        for _, candidate in ipairs(value) do
            if candidate == playerValue then return true end
        end
        return false
    end
    return value == playerValue
end

function SM.GetQuestIDs(q)
    if type(q) ~= "table" then return { q } end
    if q._questIDs then return q._questIDs end
    local ids = {}
    if q.id then ids[#ids + 1] = q.id end
    if q.altIds then
        for _, id in ipairs(q.altIds) do
            ids[#ids + 1] = id
        end
    end
    return ids
end

local function GetQuestLinkColor(color)
    color = color or "ffd200"
    if color:match("^ff%x%x%x%x%x%x$") then
        color = color:sub(3)
    end
    return color
end

function SM.GetQuestChatLink(questOrID, questName, color)
    color = GetQuestLinkColor(color)
    -- Guidance quests carry no id, so GetQuestIDs returns an empty list. Keep
    -- questID nil in that case (the plain-text fallback below handles it)
    -- rather than letting `and/or` fall through to the quest table itself.
    local questID
    if type(questOrID) == "table" then
        questID = SM.GetQuestIDs(questOrID)[1]
    else
        questID = questOrID
    end
    if not questID then
        return questName and ("|cff" .. color .. questName .. "|r") or nil
    end

    if not questName and type(questOrID) == "table" then
        questName = questOrID.name or questOrID.displayName
    end
    questName = questName or (QuestUtils_GetQuestName and QuestUtils_GetQuestName(questID))
    if not questName or questName == "" then
        questName = string.format(SM.L["Quest ID Format"], tostring(questID))
    end

    local senderGUID = UnitGUID and UnitGUID("player") or "0"
    return "|Hstorymodequest:" .. questID .. ":" .. senderGUID .. "|h|cff" .. color .. "[" .. questName .. "]|r|h"
end

local function NewWeakKeyCache()
    return setmetatable({}, { __mode = "k" })
end

local progressCache = {
    allChapters = NewWeakKeyCache(),
    chapterProgress = NewWeakKeyCache(),
    campaignProgress = NewWeakKeyCache(),
    nextQuest = NewWeakKeyCache(),
}

function SM.InvalidateProgressCache()
    progressCache.allChapters = NewWeakKeyCache()
    progressCache.chapterProgress = NewWeakKeyCache()
    progressCache.campaignProgress = NewWeakKeyCache()
    progressCache.nextQuest = NewWeakKeyCache()
    if SM.InvalidateStoryStateCache then SM.InvalidateStoryStateCache() end
end

function SM.IsQuestComplete(questID)
    return SM.IsQuestFlaggedCompleted(questID)
end

function SM.IsQuestEntryComplete(q)
    for _, questID in ipairs(SM.GetQuestIDs(q)) do
        if SM.IsQuestComplete(questID) then return true end
    end
    return false
end

function SM.IsQuestForPlayer(q)
    if not SM.IsContentAvailableForClient(q) then return false end
    if q.faction and q.faction ~= GetPlayerFaction() then return false end
    if q.class then
        local playerClass = GetPlayerClass()
        if not PlayerMatches(q.class, playerClass) then return false end
    end
    if q.race then
        local playerRace = GetPlayerRace()
        if not PlayerMatches(q.race, playerRace) then return false end
    end
    if q.excludeRace then
        local playerRace = GetPlayerRace()
        if PlayerMatches(q.excludeRace, playerRace) then return false end
    end
    return true
end

function SM.ShouldHideQuest(q)
    if q.showIf then
        if not SM.IsQuestComplete(q.showIf) then return true end
    elseif q.hideIf then
        local ids = type(q.hideIf) == "table" and q.hideIf or { q.hideIf }
        for _, hid in ipairs(ids) do
            if SM.IsQuestComplete(hid) then return true end
        end
    end
    return false
end

function SM.IsQuestEffectivelyComplete(questIndex, chapterQuests)
    local q = chapterQuests[questIndex]
    -- Quests for the opposing faction are irrelevant.
    if not SM.IsQuestForPlayer(q) then return true end

    if SM.IsQuestEntryInLog(q) then return false end
    if SM.IsQuestEntryComplete(q) then return true end

    for i = 1, questIndex - 1 do
        if SM.IsQuestForPlayer(chapterQuests[i]) and SM.IsQuestEntryInLog(chapterQuests[i]) then
            return false
        end
    end

    for i = questIndex + 1, #chapterQuests do
        local laterQuest = chapterQuests[i]
        if laterQuest and not laterQuest.parallel and SM.IsQuestForPlayer(laterQuest) and SM.IsQuestEntryComplete(laterQuest) then
            return true
        end
    end

    return false
end

function SM.IsQuestInLog(questID)
    return SM.GetLogIndexForQuestID(questID) ~= nil
end

function SM.IsQuestEntryInLog(q)
    for _, questID in ipairs(SM.GetQuestIDs(q)) do
        if SM.IsQuestInLog(questID) then return true, questID end
    end
    return false, nil
end

function SM.IsStoryActive(data)
    if not data then return false end
    for _, ch in ipairs(SM.GetAllChapters(data)) do
        if ch.quests then
            for _, q in ipairs(ch.quests) do
                if SM.IsQuestForPlayer(q) and not SM.ShouldHideQuest(q) and SM.IsQuestEntryInLog(q) then
                    return true
                end
            end
        end
    end
    return false
end

function SM.GetAllChapters(data)
    if progressCache.allChapters[data] then return progressCache.allChapters[data] end
    local all = {}
    local playerFaction = GetPlayerFaction()

    local function ShouldShowChapter(ch)
        if not SM.IsContentAvailableForClient(ch) then return false end
        return not ch.faction or ch.faction == playerFaction
    end

    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            if ShouldShowChapter(ch) then
                ch._section = 1
                all[#all + 1] = ch
            end
        end
    end
    if data.chapters then
        for _, ch in ipairs(data.chapters) do
            if ShouldShowChapter(ch) then
                ch._section = 2
                all[#all + 1] = ch
            end
        end
    end
    if data.insurrection then
        for _, ch in ipairs(data.insurrection) do
            if ShouldShowChapter(ch) then
                ch._section = 3
                all[#all + 1] = ch
            end
        end
    end
    if #all == 0 and data.startQuest then
        all[#all + 1] = {
            chapter = data.title,
            summary = data.description,
            recap = data.description,
            quests = { data.startQuest },
            _section = 2,
        }
    end
    progressCache.allChapters[data] = all
    return all
end

function SM.GetStoryAchievements(data)
    local ids, seen = {}, {}
    local function add(id)
        if type(id) == "string" then
            local target = id:lower()
            for scan = 1, 50000 do
                local _, scanName = GetAchievementInfo(scan)
                if scanName and scanName:lower() == target then id = scan; break end
            end
            if type(id) ~= "number" then return end
        end
        if id and not seen[id] then
            seen[id] = true
            local _, name = GetAchievementInfo(id)
            if name then ids[#ids + 1] = id end
        end
    end

    if data.achievements then
        for _, id in ipairs(data.achievements) do add(id) end
    else
        add(data.achievementID)
    end
    for _, ch in ipairs(SM.GetAllChapters(data)) do
        add(ch.achievementID)
    end
    return ids
end

function SM.GetStoryFactions(data)
    if not data then return nil end
    if SM.IsClassicClient() then return nil end
    local faction = GetPlayerFaction()
    return (data.factionsByFaction and data.factionsByFaction[faction]) or data.factions
end

function SM.GetChapterProgress(ch)
    local cached = progressCache.chapterProgress[ch]
    if cached then return cached.done, cached.total end
    local currentStoryData = ch and ch._story or (SM.GetCurrentStoryData and SM.GetCurrentStoryData())

    if ch.loreOnly then
        if currentStoryData and SM.IsLoreChapterViewed(currentStoryData.title, ch.chapter) then
            progressCache.chapterProgress[ch] = { done = 1, total = 1 }
            return 1, 1
        end
        progressCache.chapterProgress[ch] = { done = 0, total = 0 }
        return 0, 0
    end
    if ch.replayable and currentStoryData and SM.IsChapterPlayed(currentStoryData.title, ch.chapter) then
        progressCache.chapterProgress[ch] = { done = 1, total = 1 }
        return 1, 1
    end

    local total, done = 0, 0
    local optionalTotal, optionalDone = 0, 0
    for i, q in ipairs(ch.quests or {}) do
        if SM.IsQuestForPlayer(q) and not SM.ShouldHideQuest(q) then
            if q.optional then
                optionalTotal = optionalTotal + 1
                if SM.IsQuestEntryComplete(q) then optionalDone = optionalDone + 1 end
            else
                total = total + 1
                if SM.IsQuestEffectivelyComplete(i, ch.quests) then done = done + 1 end
            end
        end
    end

    if total == 0 and optionalTotal > 0 then
        progressCache.chapterProgress[ch] = { done = optionalDone, total = optionalTotal }
        return optionalDone, optionalTotal
    end

    if total > 0 then
        progressCache.chapterProgress[ch] = { done = done, total = total }
        return done, total
    end

    if ch.achievementID then
        local _, _, _, completed = GetAchievementInfo(ch.achievementID)
        if completed then
            progressCache.chapterProgress[ch] = { done = 1, total = 1 }
            return 1, 1
        end
    end
    if ch.completionAchievementID then
        local _, _, _, completed = GetAchievementInfo(ch.completionAchievementID)
        if completed then
            progressCache.chapterProgress[ch] = { done = 1, total = 1 }
            return 1, 1
        end
    end

    progressCache.chapterProgress[ch] = { done = 0, total = 0 }
    return 0, 0
end

function SM.GetCampaignProgress(data)
    local cached = progressCache.campaignProgress[data]
    if cached then return cached.done, cached.total end
    local total, done = 0, 0
    for _, ch in ipairs(SM.GetAllChapters(data)) do
        for _, q in ipairs(ch.quests or {}) do
            if not q.optional and SM.IsQuestForPlayer(q) and not SM.ShouldHideQuest(q) then
                total = total + 1
                if SM.IsQuestEntryComplete(q) then done = done + 1 end
            end
        end
    end

    progressCache.campaignProgress[data] = { done = done, total = total }
    return done, total
end

function SM.GetFirstUnmetChapterPrerequisite(ch)
    if not ch or not ch.prerequisites then return nil end
    for _, req in ipairs(ch.prerequisites) do
        if req.id and not SM.IsQuestComplete(req.id) and not SM.IsQuestInLog(req.id) then
            return req
        end
    end
    return nil
end

function SM.GetQuestLockReason(data, ch, questIndex)
    if not data or not ch then return nil end

    local function Highlight(text)
        return "|cffffd200" .. text .. "|r"
    end

    local function QuestLink(quest)
        return SM.GetQuestChatLink(quest, quest and quest.name)
    end

    local playerLevel = UnitLevel("player") or 0
    if data.requiredLevel and playerLevel < data.requiredLevel then
        return string.format(L["Lock Required Level Format"], data.requiredLevel)
    end
    if ch.requiredLevel and playerLevel < ch.requiredLevel then
        return string.format(L["Lock Required Level Format"], ch.requiredLevel)
    end

    local unmetPrereq = SM.GetFirstUnmetChapterPrerequisite(ch)
    if unmetPrereq then
        local questName = QuestLink(unmetPrereq)
        if unmetPrereq.npc and unmetPrereq.npc ~= "" then
            return string.format(L["Lock Pick Up Quest Format"], questName, Highlight(unmetPrereq.npc))
        end
        return string.format(L["Lock Complete Quest Format"], questName)
    end

    local currentQuest = ch.quests and questIndex and ch.quests[questIndex] or nil
    if questIndex and questIndex > 1 and not (currentQuest and currentQuest.parallel) then
        local prevIndex = questIndex - 1
        local prevQuest = ch.quests and ch.quests[prevIndex]
        while prevQuest and (prevQuest.optional or not SM.IsQuestForPlayer(prevQuest) or SM.ShouldHideQuest(prevQuest)) do
            prevIndex = prevIndex - 1
            prevQuest = ch.quests and ch.quests[prevIndex]
        end
        if prevQuest and not SM.IsQuestEffectivelyComplete(prevIndex, ch.quests) then
            return string.format(L["Lock Complete Previous Quest Format"], QuestLink(prevQuest))
        end
    end

    return nil
end

function SM.GetQuestlineGateReason(data, ch)
    if not data then return nil end

    local playerLevel = UnitLevel("player") or 0
    if data.requiredLevel and playerLevel < data.requiredLevel then
        return string.format(L["Lock Required Level Format"], data.requiredLevel)
    end
    if ch and ch.requiredLevel and playerLevel < ch.requiredLevel then
        return string.format(L["Lock Required Level Format"], ch.requiredLevel)
    end

    return nil
end

function SM.FindNextQuest(data)
    local cached = progressCache.nextQuest[data]
    if cached then
        return cached.quest, cached.chapter, cached.chapterData
    end
    local chapters = SM.GetAllChapters(data)
    local hasPrereqProgress = not data.prereqs

    if data.prereqs then
        for _, ch in ipairs(data.prereqs) do
            local d = SM.GetChapterProgress(ch)
            if d > 0 then hasPrereqProgress = true; break end
        end
    end

    local logCandidates = {}
    local readyCandidates = {}

    for chIdx, ch in ipairs(chapters) do
        -- Optional chapters remain visible in the track, but they do not keep
        -- the main story CTA from reaching "Story Finished".
        if not ch.optional then
            local unmetPrereq = SM.GetFirstUnmetChapterPrerequisite(ch)
            if unmetPrereq then
                readyCandidates[#readyCandidates + 1] = {
                    quest = {
                        id = unmetPrereq.id,
                        name = unmetPrereq.name,
                        npc = unmetPrereq.npc,
                        _isPrerequisiteForChapter = ch.chapter,
                    },
                    chapter = ch.chapter,
                    chapterData = ch,
                    section = ch._section or 1,
                    depth = 0,
                    order = chIdx,
                }
            else
                local chDone, chTotal = SM.GetChapterProgress(ch)
                if chDone < chTotal then
                    local section = ch._section or 1

                    for j, q in ipairs(ch.quests or {}) do
                        if not SM.IsQuestForPlayer(q) then
                            -- skip opposing-faction variant
                        elseif SM.IsQuestEntryInLog(q) then
                            logCandidates[#logCandidates + 1] = {
                                quest = q, chapter = ch.chapter,
                                chapterData = ch,
                                section = section, depth = j, order = chIdx,
                            }
                            break
                        elseif not SM.IsQuestEffectivelyComplete(j, ch.quests) then
                            if j == 1 then
                                if section >= 2 and hasPrereqProgress then
                                    readyCandidates[#readyCandidates + 1] = {
                                        quest = q, chapter = ch.chapter,
                                        chapterData = ch,
                                        section = section, depth = j, order = chIdx,
                                    }
                                elseif section == 1 and chDone == 0 and not hasPrereqProgress then
                                    readyCandidates[#readyCandidates + 1] = {
                                        quest = q, chapter = ch.chapter,
                                        chapterData = ch,
                                        section = section, depth = j, order = chIdx,
                                    }
                                end
                                break
                            elseif SM.IsQuestEffectivelyComplete(j - 1, ch.quests) then
                                readyCandidates[#readyCandidates + 1] = {
                                    quest = q, chapter = ch.chapter,
                                    chapterData = ch,
                                    section = section, depth = j, order = chIdx,
                                }
                                break
                            else
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(logCandidates, function(a, b)
        if a.section ~= b.section then return a.section < b.section end
        if a.order ~= b.order then return a.order < b.order end
        return a.depth < b.depth
    end)

    table.sort(readyCandidates, function(a, b)
        if a.section ~= b.section then return a.section < b.section end
        if a.order ~= b.order then return a.order < b.order end
        return a.depth < b.depth
    end)

    if #logCandidates > 0 then
        local best = logCandidates[1]
        progressCache.nextQuest[data] = { quest = best.quest, chapter = best.chapter, chapterData = best.chapterData }
        return best.quest, best.chapter, best.chapterData
    end
    if #readyCandidates > 0 then
        local best = readyCandidates[1]
        progressCache.nextQuest[data] = { quest = best.quest, chapter = best.chapter, chapterData = best.chapterData }
        return best.quest, best.chapter, best.chapterData
    end

    progressCache.nextQuest[data] = { quest = nil, chapter = nil, chapterData = nil }
    return nil, nil
end
