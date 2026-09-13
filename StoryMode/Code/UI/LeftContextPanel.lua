local _, SM = ...
local L = SM.L
local SMTooltip = SM.Tooltip
local C_BODY = SM.UIColors.body
local C_GOLD = SM.UIColors.gold
local C_DIM = SM.UIColors.dim
local FactionUI = SM.FactionUI

local function HideStoryFrame()
    local storyFrame = SM.GetStoryModeFrame and SM.GetStoryModeFrame()
    if storyFrame then storyFrame:Hide() end
end

function SM.InitializeLeftContextPanel()
    if not SM.LeftContextChild then return end
    SM.LeftContextAchievementButtons = SM.LeftContextAchievementButtons or {}
    SM.LeftContextFactionCards = SM.LeftContextFactionCards or {}
    SM.LeftContextDividers = SM.LeftContextDividers or {}
    if not SM.LeftContextEmptyText then
        SM.LeftContextEmptyText = SM.NoShadow(SM.LeftContextChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
        SM.LeftContextEmptyText:SetTextColor(C_DIM[1], C_DIM[2], C_DIM[3])
        SM.LeftContextEmptyText:SetJustifyH("CENTER")
        SM.LeftContextEmptyText:Hide()
    end
end

function SM.HideLeftContext()
    SM.InitializeLeftContextPanel()
    for _, btn in ipairs(SM.LeftContextAchievementButtons) do btn:Hide() end
    for _, card in ipairs(SM.LeftContextFactionCards) do card:Hide() end
    for _, div in ipairs(SM.LeftContextDividers) do div:Hide() end
    SM.LeftContextEmptyText:Hide()
end

function SM.UseStoryLeftPanel()
    SM.InitializeLeftContextPanel()
    local scrollOffset = SM.LeftStoryScrollOffset or 0
    if SM.LeftPanelMode == "story" then
        scrollOffset = SM.LeftScroll:GetVerticalScroll() or scrollOffset
    end
    SM.HideLeftContext()
    SM.LeftContextChild:Hide()
    SM.LeftStoryChild:Show()
    SM.LeftScroll:SetScrollChild(SM.LeftStoryChild)
    SM.LeftPanelMode = "story"
    SM.LeftStoryScrollOffset = scrollOffset
    SM.RestoreLeftStoryScroll()
end

function SM.UseContextLeftPanel()
    SM.InitializeLeftContextPanel()
    SM.SaveLeftStoryScroll()
    SM.LeftStoryChild:Hide()
    SM.LeftContextChild:Show()
    SM.LeftScroll:SetScrollChild(SM.LeftContextChild)
    SM.LeftScroll:SetVerticalScroll(0)
    SM.LeftPanelMode = "context"
    SM.HideLeftContext()
end

function SM.GetLeftContextDivider(index, text, yOff)
    SM.InitializeLeftContextPanel()
    local div = SM.LeftContextDividers[index]
    if not div then
        local _
        _, div = SM.CreateCatDivider(SM.LeftContextChild, text, yOff)
        SM.LeftContextDividers[index] = div
    end
    div:ClearAllPoints()
    div:SetPoint("TOPLEFT",  SM.LeftContextChild, "TOPLEFT",  4, yOff)
    div:SetPoint("TOPRIGHT", SM.LeftContextChild, "TOPRIGHT", -4, yOff)
    div:Show()
    if div.label then div.label:SetText(text) end
    return 26
end

function SM.CreateLeftAchievementButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(42, 42)
    btn:EnableMouse(true)

    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(34, 34)
    icon:SetPoint("CENTER")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = icon

    local border = btn:CreateTexture(nil, "OVERLAY", nil, 2)
    if not SM.SafeSetAtlas(border, "talents-node-square-gray", false) then
        border:Hide()
    end
    border:SetSize(42, 42)
    border:SetPoint("CENTER", icon, "CENTER", 0, 0)
    btn.border = border

    btn:SetScript("OnEnter", function(self)
        if not self.achievementID then return end
        self.border:SetVertexColor(1, 0.90, 0.60)
        local _, achName, _, completed, month, day, year, description, _, _, _, rewardText =
            GetAchievementInfo(self.achievementID)
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine(achName or "", 1, 1, 1)
        if completed then
            local dateStr = (month and month > 0) and (" — " .. month .. "/" .. day .. "/" .. year) or ""
            SMTooltip:AddLine(L["Achievement Earned"] .. dateStr, 0.2, 0.83, 0.2)
        else
            SMTooltip:AddLine(L["Achievement Not Yet Earned"], C_DIM[1], C_DIM[2], C_DIM[3])
        end
        if description and description ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(description, C_BODY[1], C_BODY[2], C_BODY[3], true)
        end
        if type(rewardText) == "string" and rewardText ~= "" then
            SMTooltip:AddLine(" ")
            SMTooltip:AddLine(string.format(L["Achievement Reward Format"], rewardText), C_GOLD[1], C_GOLD[2], C_GOLD[3], true)
        end
        SMTooltip:AddLine(" ")
        SMTooltip:AddLine(L["Achievement Open Log"], 0.5, 0.5, 0.5)
        SMTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        self.border:SetVertexColor(self.borderR or C_DIM[1], self.borderG or C_DIM[2], self.borderB or C_DIM[3])
        SMTooltip:Hide()
    end)
    btn:SetScript("OnClick", function(self)
        if not self.achievementID then return end
        SMTooltip:Hide()
        HideStoryFrame()
        if not AchievementFrame then SM.LoadAddOn("Blizzard_AchievementUI") end
        if AchievementFrame and ShowUIPanel and AchievementFrame_SelectAchievement then
            ShowUIPanel(AchievementFrame)
            AchievementFrame_SelectAchievement(self.achievementID)
        end
    end)

    return btn
end

function SM.PrepareLeftFactionCard(card)
    card.leftContext = true
    card.tileMode = true
    card:SetParent(SM.LeftContextChild)
    card.button:SetScale(1)
    card.button:ClearAllPoints()
    card.button:SetAllPoints(card)
    if card.button.Background then
        card.button.Background:ClearAllPoints()
        card.button.Background:SetAllPoints(card.button)
    end
    FactionUI:SetCardAtlas(card, FactionUI:GetCardAtlas(card, false))
    card.button.IconFrame:SetSize(58, 58)
    card.button.IconFrame:ClearAllPoints()
    card.button.IconFrame:SetPoint("TOP", card.button, "TOP", 0, -10)
    if card.button.IconFrame.Border then
        card.button.IconFrame.Border:SetSize(58, 58)
    end
    if card.button.IconFrame.IconMask then
        card.button.IconFrame.IconMask:SetAllPoints(card.icon)
    end
    if card.progress then
        card.progress:SetAllPoints(card.button.IconFrame)
    end
    if card.fullRing then
        card.fullRing:SetAllPoints(card.button.IconFrame)
    end
    card.icon:SetSize(42, 42)
    card.nameLabel:ClearAllPoints()
    card.nameLabel:SetPoint("TOP", card.button.IconFrame, "BOTTOM", 0, -4)
    card.nameLabel:SetPoint("LEFT", card, "LEFT", 8, 0)
    card.nameLabel:SetPoint("RIGHT", card, "RIGHT", -8, 0)
    card.nameLabel:SetJustifyH("CENTER")
    card.nameLabel:SetJustifyV("TOP")
    card.nameLabel:SetScale(1)
    card.nameLabel:SetMaxLines(2)
    card.nameLabel:SetWordWrap(true)
    do
        local f, _, fl = card.nameLabel:GetFont()
        if f then card.nameLabel:SetFont(f, 10, fl) end
    end
    card.statusLabel:ClearAllPoints()
    card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, 0)
    card.statusLabel:SetPoint("RIGHT", card.nameLabel, "RIGHT", 0, 0)
    card.statusLabel:SetJustifyH("CENTER")
    card.statusLabel:SetScale(1)
    do
        local f, _, fl = card.statusLabel:GetFont()
        if f then card.statusLabel:SetFont(f, 9, fl) end
    end
    card.statusLabel:SetMaxLines(1)
    card.statusLabel:SetWordWrap(false)
    FactionUI:LayoutLeftCardText(card)
    card.button:RegisterForClicks("LeftButtonUp")
    card.button:SetScript("OnClick", function()
        local factionID = card.factionID
        if not factionID then return end
        local isMajor = card.isMajorFaction
        SMTooltip:Hide()
        HideStoryFrame()
        C_Timer.After(0, function()
        if isMajor and EventRegistry then
            SM.LoadAddOn("Blizzard_MajorFactions")
            EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", factionID)
        else
            if not CharacterFrame or not CharacterFrame:IsShown() then
                ToggleCharacter("ReputationFrame")
            elseif ReputationFrame and not ReputationFrame:IsShown() then
                ToggleCharacter("ReputationFrame")
            end
            local function findIndex()
                if not C_Reputation or not C_Reputation.GetNumFactions or not C_Reputation.GetFactionDataByIndex then
                    return nil
                end
                local n = C_Reputation.GetNumFactions()
                for i = 1, n do
                    local d = C_Reputation.GetFactionDataByIndex(i)
                    if d and d.factionID == factionID then return i end
                end
            end
            local idx = findIndex()
            if not idx and C_Reputation and C_Reputation.GetNumFactions and C_Reputation.GetFactionDataByIndex then
                local n = C_Reputation.GetNumFactions()
                for i = n, 1, -1 do
                    local d = C_Reputation.GetFactionDataByIndex(i)
                    if d and d.isHeader and d.isCollapsed and C_Reputation.ExpandFactionHeader then
                        C_Reputation.ExpandFactionHeader(i)
                    end
                end
                idx = findIndex()
            end
            if idx and C_Reputation and C_Reputation.SetSelectedFaction then
                C_Reputation.SetSelectedFaction(idx)
                if ReputationFrame and ReputationFrame.Update then ReputationFrame:Update() end
                if ReputationFrame and ReputationFrame.ScrollBox and ReputationFrame.ScrollBox.ScrollToElementDataByPredicate then
                    ReputationFrame.ScrollBox:ScrollToElementDataByPredicate(function(node)
                        local d = node and node.GetData and node:GetData()
                        return d and d.factionID == factionID
                    end, ScrollBoxConstants and ScrollBoxConstants.AlignCenter or 0.5)
                end
            end
        end
        end)
    end)
end

function SM.LayoutLeftAchievements(data)
    SM.InitializeLeftContextPanel()
    local yOffset = SM.LeftContextYOffset or -16
    local ids = SM.GetStoryAchievements(data)
    if #ids == 0 then
        for _, btn in ipairs(SM.LeftContextAchievementButtons) do btn:Hide() end
        return yOffset, false
    end

    yOffset = yOffset - SM.GetLeftContextDivider(SM.LeftContextDividerIndex or 1, L["Section Achievements"], yOffset) - 8
    SM.LeftContextDividerIndex = (SM.LeftContextDividerIndex or 1) + 1

    local iconSize, cols = 42, 5
    local contentW = (SM.LeftWidth or 274) - 24
    -- Match the faction grid's effective width (4px margin on each side).
    local rowW = contentW - 8
    local gap = (cols > 1) and math.max(4, math.floor((rowW - cols * iconSize) / (cols - 1))) or 8
    local total = #ids
    for i, achID in ipairs(ids) do
        local btn = SM.LeftContextAchievementButtons[i]
        if not btn then
            btn = SM.CreateLeftAchievementButton(SM.LeftContextChild)
            SM.LeftContextAchievementButtons[i] = btn
        end
        local _, _, _, completed, _, _, _, _, _, icon = GetAchievementInfo(achID)
        btn.achievementID = achID
        btn.icon:SetTexture(icon)
        btn.icon:SetDesaturated(not completed)
        btn.borderR = completed and C_GOLD[1] or C_DIM[1]
        btn.borderG = completed and C_GOLD[2] or C_DIM[2]
        btn.borderB = completed and C_GOLD[3] or C_DIM[3]
        btn.border:SetVertexColor(btn.borderR, btn.borderG, btn.borderB)
        btn:ClearAllPoints()
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local rowStart = row * cols + 1
        local rowCount = math.min(cols, total - rowStart + 1)
        local thisRowW = rowCount * iconSize + (rowCount - 1) * gap
        local startX = math.floor((contentW - thisRowW) / 2)
        btn:SetPoint("TOPLEFT", SM.LeftContextChild, "TOPLEFT", startX + col * (iconSize + gap), yOffset - row * (iconSize + gap))
        btn:Show()
    end
    for i = #ids + 1, #SM.LeftContextAchievementButtons do
        SM.LeftContextAchievementButtons[i]:Hide()
    end

    local rows = math.ceil(#ids / cols)
    SM.LeftContextYOffset = yOffset - rows * iconSize - math.max(0, rows - 1) * gap - 14
    return SM.LeftContextYOffset, true
end

function SM.LayoutLeftFactions(data)
    SM.InitializeLeftContextPanel()
    local yOffset = SM.LeftContextYOffset or -16
    local factions = SM.GetStoryFactions(data)
    if not factions or #factions == 0 then
        for _, card in ipairs(SM.LeftContextFactionCards) do card:Hide() end
        return yOffset, false
    end

    yOffset = yOffset - SM.GetLeftContextDivider(SM.LeftContextDividerIndex or 1, L["Section Factions"], yOffset) - 8
    SM.LeftContextDividerIndex = (SM.LeftContextDividerIndex or 1) + 1

    local shown = 0
    local cols, gap = 2, 4
    local contentW = (SM.LeftWidth or 274) - 24
    local tileW = math.floor((contentW - 8 - gap) / cols)
    local tileH = tileW
    for _, entry in ipairs(factions) do
        local card = SM.LeftContextFactionCards[shown + 1]
        if not card then
            card = FactionUI:Create(SM.LeftContextChild)
            SM.LeftContextFactionCards[shown + 1] = card
        end
        card:SetSize(tileW, tileH)
        SM.PrepareLeftFactionCard(card)
        if FactionUI:Update(card, entry, data) then
            local col = shown % cols
            local row = math.floor(shown / cols)
            shown = shown + 1
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", SM.LeftContextChild, "TOPLEFT", 4 + col * (tileW + gap), yOffset - row * (tileH + gap))
        end
    end
    for i = shown + 1, #SM.LeftContextFactionCards do
        SM.LeftContextFactionCards[i]:Hide()
    end

    if shown == 0 then
        local div = SM.LeftContextDividers[(SM.LeftContextDividerIndex or 2) - 1]
        if div then div:Hide() end
        SM.LeftContextDividerIndex = math.max(1, (SM.LeftContextDividerIndex or 2) - 1)
        return SM.LeftContextYOffset or yOffset, false
    end
    if shown > 0 then
        local rows = math.ceil(shown / cols)
        yOffset = yOffset - rows * tileH - math.max(0, rows - 1) * gap
    end
    SM.LeftContextYOffset = yOffset
    return SM.LeftContextYOffset, true
end

function SM.LayoutLeftProgressJournal(data)
    SM.InitializeLeftContextPanel()
    local achievements = SM.GetStoryAchievements(data)
    local factions = SM.GetStoryFactions(data)
    if (not achievements or #achievements == 0) and (not factions or #factions == 0) then
        SM.UseStoryLeftPanel()
        return
    end

    SM.UseContextLeftPanel()
    SM.LeftContextYOffset = -16
    SM.LeftContextDividerIndex = 1
    local _, hasAchievements = SM.LayoutLeftAchievements(data)
    local _, hasFactions = SM.LayoutLeftFactions(data)
    if not hasAchievements and not hasFactions then
        SM.UseStoryLeftPanel()
        return
    end
    SM.LeftContextChild:SetHeight(math.max(math.abs(SM.LeftContextYOffset or -16) + 16, 180))
end

SM.UpdateLeftPanelForTab = function(tab, data)
    SM.InitializeLeftContextPanel()
    if not data or tab == "story" then
        SM.UseStoryLeftPanel()
    elseif tab == "progress" or tab == "journal" then
        SM.LayoutLeftProgressJournal(data)
    else
        SM.UseStoryLeftPanel()
    end
end
