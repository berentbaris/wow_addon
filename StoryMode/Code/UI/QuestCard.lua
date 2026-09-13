local _, SM = ...
local L = SM.L
local SMTooltip = SM.Tooltip
local C_BODY = SM.UIColors.body
local C_GOLD = SM.UIColors.gold
local C_DIM = SM.UIColors.dim

local QCARD_H = 44 + 8

function SM.ExecuteTrackButton(data, quest)
    if not data or not quest then return end
    local result = SM.SetWaypointForQuest(data, quest)
    SM.PrintTrackResult(result, quest, data)
    local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
    if storyFrame then storyFrame:Hide() end
end

local activeQuestTooltipCard = nil
local questTooltipRefreshToken = 0

local function IsQuestTooltipDataCached(questID)
    if questID and C_QuestLog and C_QuestLog.IsQuestDataCached then
        local ok, cached = pcall(C_QuestLog.IsQuestDataCached, questID)
        if ok then return cached and true or false end
    end
    return nil
end

local function QuestCardHasQuestID(card, questID)
    if not (card and questID) then return false end
    if card.questID == questID then return true end
    if card.questEntry and SM.GetQuestIDs then
        for _, id in ipairs(SM.GetQuestIDs(card.questEntry)) do
            if id == questID then return true end
        end
    end
    return false
end

local function IsQuestTooltipCardActive(card)
    return card
        and activeQuestTooltipCard == card
        and card:IsShown()
        and card:IsMouseOver()
end

local function QueueQuestTooltipRefresh(card, delay)
    if not (C_Timer and C_Timer.After) then return end
    questTooltipRefreshToken = questTooltipRefreshToken + 1
    local token = questTooltipRefreshToken
    C_Timer.After(delay or 0, function()
        if token ~= questTooltipRefreshToken then return end
        if SM.RefreshQuestCardTooltip and IsQuestTooltipCardActive(card) then
            SM.RefreshQuestCardTooltip(card, false)
        end
    end)
end

local function EnsureQuestTooltipEvents()
    if SM.questTooltipEventFrame then return end

    SM.questTooltipEventFrame = CreateFrame("Frame")
    SM.questTooltipEventFrame:RegisterEvent("QUEST_LOG_UPDATE")
    if C_QuestLog and C_QuestLog.RequestLoadQuestByID then
        pcall(SM.questTooltipEventFrame.RegisterEvent, SM.questTooltipEventFrame, "QUEST_DATA_LOAD_RESULT")
    end

    SM.questTooltipEventFrame:SetScript("OnEvent", function(_, event, questID, success)
        local card = activeQuestTooltipCard
        if not IsQuestTooltipCardActive(card) then return end

        if event == "QUEST_DATA_LOAD_RESULT" then
            if not success or not QuestCardHasQuestID(card, questID) then return end
            QueueQuestTooltipRefresh(card, 0)
        elseif event == "QUEST_LOG_UPDATE" then
            QueueQuestTooltipRefresh(card, 0.05)
        end
    end)
end

local function RequestQuestTooltipData(card)
    local questID = card and card.questID
    if not (questID and C_QuestLog and C_QuestLog.RequestLoadQuestByID) then
        return false
    end

    EnsureQuestTooltipEvents()
    local ok = pcall(C_QuestLog.RequestLoadQuestByID, questID)
    if ok then
        QueueQuestTooltipRefresh(card, 0.35)
    end
    return ok
end

function SM.RefreshQuestCardTooltip(card, requestQuestData)
    if not (card and card.questID) then return end

    local questDataCached = IsQuestTooltipDataCached(card.questID)
    local requestedQuestData = requestQuestData and RequestQuestTooltipData(card) or false

    SMTooltip:SetOwner(card, "ANCHOR_RIGHT")
    SMTooltip:ClearLines()

    local qName = (QuestUtils_GetQuestName and QuestUtils_GetQuestName(card.questID)) or card.tooltipTitle or ""
    SMTooltip:AddLine(qName, 1, 1, 1)

    if card.tooltipNPC then
        SMTooltip:AddLine(card.tooltipNPC, C_BODY[1], C_BODY[2], C_BODY[3])
    end

    -- Objectives are only useful for active, incomplete quests. Completed
    -- quests no longer keep live counters, which makes old objective lines stale.
    local qComplete = SM.IsQuestFlaggedCompleted(card.questID)
    local hasObjectives = false
    if not qComplete then
        local objectives = SM.GetQuestObjectives(card.questID)
        if objectives and #objectives > 0 then
            SMTooltip:AddLine(" ")
            for _, obj in ipairs(objectives) do
                if obj.text and obj.text ~= "" then
                    hasObjectives = true
                    if obj.finished then
                        SMTooltip:AddLine(obj.text, 0.45, 0.90, 0.35, true)
                    else
                        SMTooltip:AddLine(obj.text, 0.9, 0.9, 0.9, true)
                    end
                end
            end
        end

        if requestedQuestData and questDataCached ~= true and not hasObjectives then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(L["Quest Tooltip Loading"], C_DIM[1], C_DIM[2], C_DIM[3], true)
        end
    end

    if card.tooltipStatus then
        SMTooltip:AddLine(" ")
        SMTooltip:AddLine(card.tooltipStatus)
    end
    if card.tooltipRequirement then
        SMTooltip:AddLine(card.tooltipRequirement, 1.0, 0.82, 0.35, true)
    end

    SMTooltip:Show()
end

function SM.CreateQuestCard(parent)
    local card = CreateFrame("Button", nil, parent, (SM.IsRetailClient()) and nil or "BackdropTemplate")
    card:EnableMouse(true)
    card:SetHeight(QCARD_H)
    if SM.IsClassicClient() then
        SM.ApplyClassicCardBackdrop(card, 0.18, 0.50)
    end

    -- Housing endeavor-style card background
    local bg = card:CreateTexture(nil, "BACKGROUND")
    if SM.IsRetailClient() then
        bg:SetAtlas("housing-dashboard-initiatives-tasks-listitem-bg", false)
    else
        SM.ClearCardFillTexture(bg)
    end
    bg:SetAllPoints()
    card.bg = bg
    if SM.IsClassicClient() then
        card.shade = SM.CreateInsetCardShade(card, 0.38)
    end

    local cardMask = card:CreateMaskTexture()
    cardMask:SetTexture("Interface/Buttons/WHITE8x8")
    cardMask:SetPoint("TOPLEFT", card, "TOPLEFT", 2, -2)
    cardMask:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -2, 2)
    bg:AddMaskTexture(cardMask)
    card.bgMask = cardMask

    -- Hover highlight
    if SM.IsRetailClient() then
        card:SetHighlightAtlas("housing-dashboard-initiatives-tasks-listitem-bg")
        card:GetHighlightTexture():SetAllPoints()
        card:GetHighlightTexture():SetAlpha(0.3)
    else
        SM.SetSubtleCardHover(card)
    end
    if card:GetHighlightTexture() then
        card:GetHighlightTexture():AddMaskTexture(cardMask)
    end

    -- Status icon (always 14x14 for consistent text alignment)
    local ICON_LEFT = 10
    local TEXT_LEFT = ICON_LEFT + 14 + 8  -- icon width + gap
    local icon = card:CreateTexture(nil, "ARTWORK")
    icon:SetSize(14, 14)
    icon:SetPoint("LEFT", card, "LEFT", ICON_LEFT, 0)
    card.icon = icon

    -- Quest name (top line)
    local title = SM.NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormal"))
    title:SetPoint("LEFT", card, "LEFT", TEXT_LEFT, 0)
    title:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    title:SetPoint("BOTTOM", card, "CENTER", 0, 1)
    title:SetJustifyH("LEFT")
    title:SetJustifyV("BOTTOM")
    title:SetWordWrap(false)
    card.title = title

    -- NPC name (bottom line, same left edge as title)
    local npcLabel = SM.NoShadow(card:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall"))
    npcLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    npcLabel:SetPoint("RIGHT", card, "RIGHT", -10, 0)
    npcLabel:SetJustifyH("LEFT")
    npcLabel:SetWordWrap(false)
    card.npcLabel = npcLabel

    -- Tooltip — refreshes in place when Blizzard finishes loading quest data.
    card:SetScript("OnEnter", function(self)
        if not self.questID then return end
        activeQuestTooltipCard = self
        EnsureQuestTooltipEvents()
        SM.RefreshQuestCardTooltip(self, true)
    end)
    card:SetScript("OnLeave", function(self)
        if activeQuestTooltipCard == self then
            activeQuestTooltipCard = nil
            questTooltipRefreshToken = questTooltipRefreshToken + 1
        end
        SMTooltip:Hide()
    end)
    card:SetScript("OnClick", function(self, button)
        if not self.questEntry then return end

        local questName = self.tooltipTitle or self.questEntry.name or L["Quest"]
        if button == "LeftButton" and IsShiftKeyDown() and SM.InsertQuestChatLink(self.questEntry, self.questID, questName) then
            return
        end

        local questText = SM.GetQuestChatLink(self.questEntry, questName)
        if self.questCompleteForClick or SM.IsQuestEntryComplete(self.questEntry) then
            local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
            if storyFrame then storyFrame:Hide() end
            print(L["Addon Prefix"] .. string.format(L["Quest Click Complete Format"], questText))
            return
        end

        if self.tooltipRequirement then
            local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
            if storyFrame then storyFrame:Hide() end
            print(L["Addon Prefix"] .. self.tooltipRequirement)
            return
        end

        SM.ExecuteTrackButton(self.storyData, self.questEntry)
    end)

    return card
end
