local _, SM = ...
local L = SM.L
local SMTooltip = SM.Tooltip

local categories = SM.GetQuestlineCategories()
local allQuestlines = SM.GetAllQuestlines()

local storyLeftRows    = {}
local storyContentBuilt = false
local storyIndexToData = {}
local storyListFrames = {}
local activeStoriesSignature = ""

local function RememberStoryListFrame(frame)
    storyListFrames[#storyListFrames + 1] = frame
    return frame
end

local function CollectActiveStorylines()
    local activeQuestlines = {}
    local activeSet = {}
    if not SM.IsStoryActive then return activeQuestlines, activeSet end
    for _, cat in ipairs(categories) do
        if not cat.disabled then
            for _, data in ipairs(cat.questlines) do
                if not activeSet[data] and SM.IsStoryActive(data) then
                    activeQuestlines[#activeQuestlines + 1] = data
                    activeSet[data] = true
                end
            end
        end
    end
    return activeQuestlines, activeSet
end

local function GetActiveStoriesSignature(activeQuestlines)
    local parts = {}
    for _, data in ipairs(activeQuestlines or {}) do
        parts[#parts + 1] = data.id or data.title or tostring(data)
    end
    return table.concat(parts, "|")
end

local function CategoryHasVisibleQuestlines(cat, activeSet)
    if not cat or not cat.questlines then return false end
    for _, data in ipairs(cat.questlines) do
        if cat.active or not activeSet[data] then
            return true
        end
    end
    return false
end

local function BuildDisplayCategories(activeQuestlines)
    local displayCategories = {}
    if #activeQuestlines > 0 then
        displayCategories[#displayCategories + 1] = {
            name = "Active Stories",
            displayName = L["Category Active Stories"],
            active = true,
            questlines = activeQuestlines,
        }
    end
    for _, cat in ipairs(categories) do
        displayCategories[#displayCategories + 1] = cat
    end
    return displayCategories
end

function SM.GetIntroStoryRow()
    return storyLeftRows[0]
end

function SM.GetStoryRowForData(data)
    if not data then return nil end
    for _, row in pairs(storyLeftRows) do
        if row.data == data then return row end
    end
    return nil
end

function SM.GetStoryDataByIndex(index)
    return storyIndexToData[index]
end

SM.StoryCardBorderNormal   = {0.48, 0.36, 0.18, 0.56}
SM.StoryCardBorderHover    = {1.00, 0.82, 0.18, 0.95}
SM.StoryCardBorderSelected = {1.00, 0.70, 0.12, 0.90}

function SM.ApplyStoryCardBorderState(row, isHover)
    if not row or not row.btn then return end
    if SM.IsRetailClient() then
        if row.isSelected then
            row.btn:LockHighlight()
        else
            row.btn:UnlockHighlight()
        end
        return
    end
    if not row.btn.SetBackdropBorderColor then return end
    local color = SM.StoryCardBorderNormal
    if isHover then
        color = SM.StoryCardBorderHover
    elseif row.isSelected then
        color = SM.StoryCardBorderSelected
    end
    row.btn:SetBackdropBorderColor(color[1], color[2], color[3], color[4])
end

local function ApplyCurrentSelectionState()
    local currentData = SM.GetCurrentStoryData and SM.GetCurrentStoryData() or nil
    local selectedID = currentData and currentData.id or StoryModeDB and StoryModeDB.selectedQuestlineID or nil
    for idx, row in pairs(storyLeftRows) do
        row.isSelected = (idx == 0 and not selectedID) or (row.data and row.data.id == selectedID) or false
        if row.btn then row.btn:UnlockHighlight() end
        if row.portBorder then row.portBorder:SetAlpha(row.isSelected and 1.0 or 0.5) end
        SM.ApplyStoryCardBorderState(row, false)
    end
end

function SM.ApplyIntroCompletionState(row)
    if not row or not row.btn then return end
    local allComplete = SM.AreAllStoriesFinished()

    if row.checkmark then
        row.checkmark:SetShown(allComplete)
    end
    if row.bg then
        row.bg:SetAlpha(1.0)
    end

    if row.nameLabel then
        row.nameLabel:ClearAllPoints()
        row.nameLabel:SetPoint("LEFT", row.icon or row.btn, row.icon and "RIGHT" or "LEFT", row.icon and 8 or 24, 0)
        row.nameLabel:SetPoint("RIGHT", row.btn, "RIGHT", -8, 0)
        row.nameLabel:SetPoint("CENTER", row.btn, "CENTER", 0, 0)
        row.nameLabel:SetJustifyV("MIDDLE")
    end
end

-- Portrait circle sizes (Delve companion style)
local PORT = 46
local ICON = 34

function SM.ClampLeftScrollOffset(offset)
    local range = SM.LeftScroll:GetVerticalScrollRange() or 0
    offset = offset or 0
    if offset < 0 then return 0 end
    if offset > range then return range end
    return offset
end

function SM.SaveLeftStoryScroll()
    if SM.LeftPanelMode == "story" then
        SM.LeftStoryScrollOffset = SM.LeftScroll:GetVerticalScroll() or SM.LeftStoryScrollOffset or 0
    end
end

function SM.RestoreLeftStoryScroll()
    local function apply()
        if SM.LeftPanelMode ~= "story" then return end
        SM.LeftScroll:SetVerticalScroll(SM.ClampLeftScrollOffset(SM.LeftStoryScrollOffset or 0))
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0, apply)
    else
        apply()
    end
end

function SM.SelectStory(index, chapterIndex)
    SM.SaveLeftStoryScroll()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    StoryModeDB.selectedQuestline = index
    local selectedData = storyIndexToData[index]
    StoryModeDB.selectedQuestlineID = selectedData and selectedData.id or nil
    StoryModeDB.selectedChapter = chapterIndex or 1  -- reset to first chapter when switching stories
    for i, row in pairs(storyLeftRows) do
        local sel = (i == index)
        if row.btn then row.btn:UnlockHighlight() end
        if row.coverTex then
            if SM.IsRetailClient() then
                local hasCover = SM.SetAdventureCoverTexture(row.coverTex, row.data)
                row.coverTex:SetShown(hasCover)
                row.coverTex:SetAlpha(1)
            else
                local hasCover = SM.SetAdventureCoverTexture(row.coverTex, row.data)
                row.coverTex:SetShown(hasCover)
                row.coverTex:SetAlpha(0.72)
            end
        end
        row.isSelected = sel
        SM.ApplyStoryCardBorderState(row, false)
        if row.bg then row.bg:SetAlpha(1.0) end
        if row.portBorder then row.portBorder:SetAlpha(sel and 1.0 or 0.5) end
        if i == 0 then SM.ApplyIntroCompletionState(row) end
        if row.nameLabel then row.nameLabel:SetTextColor(1.0, 1.0, 1.0) end
        if row.zoneLabel then row.zoneLabel:SetTextColor(1.0, 0.82, 0.36) end
        local state = row.data and SM.GetStoryState(row.data) or nil
        local gateReason = state and state.gateReason or nil
        if row.btn then row.btn.lockReason = gateReason end
        if row.checkmark and row.data then
            row.checkmark:SetShown(state and state.isFinished)
        elseif row.checkmark and row.isIntro then
            row.checkmark:SetShown(SM.AreAllStoriesFinished())
        end
    end
    if index == 0 or not selectedData then
        SM.UpdateStoryDetail(nil)
    else
        SM.UpdateStoryDetail(selectedData)
    end
end

function SM.GetStoryIndexByID(storyID)
    if not storyID then return nil end
    for idx, data in pairs(storyIndexToData) do
        if data and data.id == storyID then return idx end
    end
    return nil
end

local function RefreshStoryRow(row)
    if not row then return end
    if row.isIntro then
        SM.ApplyIntroCompletionState(row)
    elseif row.data then
        local state = SM.GetStoryState(row.data)
        local gateReason = state and state.gateReason or nil
        if row.btn then row.btn.lockReason = gateReason end
        if row.checkmark then
            row.checkmark:SetShown(state and state.isFinished)
        end
        if row.coverTex and SM.IsClassicClient() then
            row.coverTex:SetShown(SM.SetAdventureCoverTexture(row.coverTex, row.data))
        end
    end
    SM.ApplyStoryCardBorderState(row, false)
end

function SM.RebuildStoryWindow()
    if not storyContentBuilt then return end
    SM.SaveLeftStoryScroll()
    for _, frame in ipairs(storyListFrames) do
        frame:Hide()
        frame:ClearAllPoints()
    end
    wipe(storyListFrames)
    wipe(storyLeftRows)
    wipe(storyIndexToData)
    storyContentBuilt = false
    SM.BuildStoryWindow()
    local currentData = SM.GetCurrentStoryData and SM.GetCurrentStoryData() or nil
    local selectedID = currentData and currentData.id or StoryModeDB and StoryModeDB.selectedQuestlineID or nil
    local selectedIndex = selectedID and SM.GetStoryIndexByID(selectedID) or nil
    if selectedIndex then
        StoryModeDB.selectedQuestline = selectedIndex
    elseif not selectedID then
        StoryModeDB.selectedQuestline = 0
    end
    ApplyCurrentSelectionState()
    SM.RestoreLeftStoryScroll()
end

local function RefreshActiveStorySection()
    if not storyContentBuilt then return false end
    local activeQuestlines = CollectActiveStorylines()
    local signature = GetActiveStoriesSignature(activeQuestlines)
    if signature == activeStoriesSignature then return false end
    SM.RebuildStoryWindow()
    return true
end

function SM.RefreshStoryListState(data)
    local rebuilt = RefreshActiveStorySection()
    if rebuilt then
        data = nil
    end
    if data then
        RefreshStoryRow(SM.GetStoryRowForData(data))
        RefreshStoryRow(storyLeftRows[0])
        ApplyCurrentSelectionState()
        return
    end
    for _, row in pairs(storyLeftRows) do
        RefreshStoryRow(row)
    end
    ApplyCurrentSelectionState()
end

local function CreateListCardFrame(cardHeight, cardPadding, yOffset, backgroundSublevel, classicShadeInset)
    local card = RememberStoryListFrame(CreateFrame("Button", nil, SM.LeftStoryChild, (SM.IsRetailClient()) and nil or "BackdropTemplate"))
    card:SetHeight(cardHeight)
    card:SetPoint("TOPLEFT", SM.LeftStoryChild, "TOPLEFT", cardPadding, yOffset)
    card:SetPoint("TOPRIGHT", SM.LeftStoryChild, "TOPRIGHT", -cardPadding, yOffset)
    card:RegisterForClicks("AnyUp")
    if SM.IsClassicClient() then
        SM.ApplyClassicCardBackdrop(card, 0, 0.50)
    end

    local bg = card:CreateTexture(nil, "BACKGROUND", nil, backgroundSublevel)
    if SM.IsRetailClient() then
        bg:SetAtlas("housefinder_neighborhood-list-item-default", false)
        bg:SetAllPoints()
    else
        SM.ClearCardFillTexture(bg)
    end

    if SM.IsClassicClient() then
        card.shade = SM.CreateInsetCardShade(card, 0.38, classicShadeInset)
    end

    if SM.IsRetailClient() then
        card:SetHighlightAtlas("housefinder_neighborhood-list-item-highlight")
        card:GetHighlightTexture():SetAllPoints()
    else
        SM.SetSubtleCardHover(card)
    end

    return card, bg
end

local function CreateMaskedIcon(parent, texture)
    local portFrame = CreateFrame("Frame", nil, parent)
    portFrame:SetSize(PORT, PORT)
    portFrame:SetPoint("LEFT", parent, "LEFT", 16, 0)

    local iconTex = portFrame:CreateTexture(nil, "ARTWORK")
    iconTex:SetSize(ICON, ICON)
    iconTex:SetPoint("CENTER")
    if texture then
        iconTex:SetTexture(texture)
    else
        iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        iconTex:SetTexelSnappingBias(0)
        iconTex:SetSnapToPixelGrid(false)
    end

    local iconMask = portFrame:CreateMaskTexture()
    iconMask:SetTexture(
        "Interface/CHARACTERFRAME/TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    iconMask:SetAllPoints(iconTex)
    iconTex:AddMaskTexture(iconMask)

    return portFrame, iconTex
end

local function GetAchievementIcon(data)
    if not data or not data.achievementID then return nil end
    local _, _, _, _, _, _, _, _, _, achIcon = GetAchievementInfo(data.achievementID)
    if achIcon and achIcon ~= 0 then return achIcon end
    return nil
end

local function ApplyFallbackStoryIcon(iconTex, data)
    if data and data.race and not data.class then
        local heritageIcon = SM.HeritageIconByRace[data.race]
        if heritageIcon and SM.SafeSetTexture(iconTex, heritageIcon) then return end
    end
    if data and data.race == "Pandaren" then
        SM.SafeSetTexture(iconTex, SM.PandarenTabardIcon)
    else
        SM.SafeSetTexture(iconTex, SM.HeritageIconFallback)
    end
end

local function ApplyStoryPortrait(iconTex, data)
    if data.portraitDisplayID then
        SetPortraitTextureFromCreatureDisplayID(iconTex, data.portraitDisplayID)
        if not iconTex:GetTexture() then
            local achievementIcon = GetAchievementIcon(data)
            if achievementIcon then iconTex:SetTexture(achievementIcon) end
            if not iconTex:GetTexture() and data.icon then
                SM.SafeSetTexture(iconTex, data.icon)
            end
            if not iconTex:GetTexture() and data.race and not data.class then
                ApplyFallbackStoryIcon(iconTex, data)
            end
        end
    elseif data.race and not data.class and data.icon then
        if not SM.SafeSetTexture(iconTex, data.icon) then
            ApplyFallbackStoryIcon(iconTex, data)
        end
    elseif data.achievementID and not data.icon then
        local achievementIcon = GetAchievementIcon(data)
        if achievementIcon then iconTex:SetTexture(achievementIcon) end
    elseif data.icon then
        if not SM.SafeSetTexture(iconTex, data.icon) then
            ApplyFallbackStoryIcon(iconTex, data)
        end
    elseif data.race and not data.class then
        ApplyFallbackStoryIcon(iconTex, data)
    end
    if not iconTex:GetTexture() and data.race and not data.class then
        ApplyFallbackStoryIcon(iconTex, data)
    end
end

local function CreateCardCompletionRibbon(parent)
    local checkmark = SM.CreateCompletionRibbon(parent)
    if SM.IsRetailClient() then
        checkmark:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, -1)
    else
        checkmark:SetPoint("RIGHT", parent, "RIGHT", -18, 0)
    end
    return checkmark
end

local function GetStoryCardSubline(data)
    local zoneText = SM.GetQuestlineCardSubline(data)
    local parts = {}
    for part in zoneText:gmatch("[^/]+") do
        parts[#parts + 1] = part:match("^%s*(.-)%s*$")
    end
    if SM.IsClassicClient() and #parts > 1 then
        return parts[1]
    elseif #parts > 2 then
        return parts[1] .. " / " .. parts[2]
    end
    return zoneText
end

local function CreateIntroStoryCard(cardHeight, cardPadding, yOffset)
    local introCard, introBg = CreateListCardFrame(cardHeight, cardPadding, yOffset, 2, 4)
    local _, introIcon = CreateMaskedIcon(introCard, SM.StoryModeIconTexture)

    local introName = SM.NoShadow(introCard:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    introName:SetPoint("LEFT", introIcon, "RIGHT", 8, 0)
    introName:SetPoint("RIGHT", introCard, "RIGHT", -8, 0)
    introName:SetJustifyH("LEFT"); introName:SetJustifyV("MIDDLE")
    introName:SetMaxLines(1); introName:SetWordWrap(false)
    introName:SetText(L["Addon Name"])
    introName:SetTextColor(1.0, 1.0, 1.0)

    introCard.checkmark = CreateCardCompletionRibbon(introCard)
    introCard.checkmark:SetShown(SM.AreAllStoriesFinished())

    local row = {
        btn       = introCard,
        bg        = introBg,
        icon      = introIcon,
        nameLabel = introName,
        zoneLabel = nil,
        checkmark = introCard.checkmark,
        isIntro   = true,
    }
    storyLeftRows[0] = row

    introCard:SetScript("OnClick", function() SM.SelectStory(0) end)
    introCard:SetScript("OnEnter", function()
        SM.ApplyStoryCardBorderState(row, true)
    end)
    introCard:SetScript("OnLeave", function()
        SM.ApplyStoryCardBorderState(row, false)
    end)
    SM.ApplyIntroCompletionState(row)

    return row
end

local function CreateStoryListCard(data, idx, cardHeight, cardPadding, yOffset)
    local card, bg = CreateListCardFrame(cardHeight, cardPadding, yOffset, 2, 4)

    local coverTex = card:CreateTexture(nil, "BACKGROUND", nil, (SM.IsRetailClient()) and 0 or 2)
    if SM.IsRetailClient() then
        coverTex:SetPoint("TOPLEFT", card, "TOPLEFT", 7, -7)
        coverTex:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -7, 7)
        coverTex:SetAlpha(0.78)
        coverTex:Hide()
    else
        coverTex:SetPoint("TOPLEFT", card, "TOPLEFT", 3, -3)
        coverTex:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -3, 3)
        coverTex:SetAlpha(0.72)
        coverTex:SetShown(SM.SetAdventureCoverTexture(coverTex, data))
    end

    local portFrame, iconTex = CreateMaskedIcon(card)
    ApplyStoryPortrait(iconTex, data)

    local portBorder = portFrame:CreateTexture(nil, "OVERLAY")
    if not SM.SafeSetAtlas(portBorder, "ui-frame-genericplayerchoice-portrait-border", false) then
        portBorder:Hide()
    end
    portBorder:SetPoint("TOPLEFT", iconTex, "TOPLEFT", -3, 3)
    portBorder:SetPoint("BOTTOMRIGHT", iconTex, "BOTTOMRIGHT", 3, -3)
    portBorder:SetVertexColor(1.0, 0.82, 0.5)
    portBorder:SetAlpha(0.85)
    portFrame:Hide()

    local nameLabel = SM.NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    nameLabel:SetPoint("LEFT", card, "LEFT", 24, 0)
    nameLabel:SetPoint("RIGHT", card, "RIGHT", -42, 0)
    nameLabel:SetPoint("BOTTOM", card, "CENTER", 0, 1)
    nameLabel:SetJustifyH("LEFT"); nameLabel:SetJustifyV("BOTTOM")
    nameLabel:SetMaxLines(1); nameLabel:SetWordWrap(false)
    nameLabel:SetText(data.title)
    nameLabel:SetTextColor(1.0, 1.0, 1.0)

    local zoneLabel = SM.NoShadow(card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
    zoneLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -2)
    zoneLabel:SetPoint("RIGHT", card, "RIGHT", -42, 0)
    zoneLabel:SetJustifyH("LEFT")
    zoneLabel:SetText(GetStoryCardSubline(data))
    zoneLabel:SetTextColor(1.0, 0.82, 0.36)

    local cardCheckmark = CreateCardCompletionRibbon(card)
    local state = SM.GetStoryState(data)
    local gateReason = state and state.gateReason or nil
    card.lockReason = gateReason
    if gateReason then
        cardCheckmark:Hide()
    elseif state and state.isFinished then
        cardCheckmark:Show()
    else
        cardCheckmark:Hide()
    end

    local row = {
        btn       = card,
        bg        = bg,
        coverTex  = coverTex,
        data      = data,
        portBorder= portBorder,
        nameLabel = nameLabel,
        zoneLabel = zoneLabel,
        checkmark = cardCheckmark,
    }
    storyLeftRows[idx] = row

    card:SetScript("OnClick", function(_, button)
        if button == "LeftButton" and IsShiftKeyDown() and SM.InsertStoryChatLink(data) then
            return
        end
        SM.SelectStory(idx)
    end)
    card:SetScript("OnEnter", function(self)
        SM.ApplyStoryCardBorderState(row, true)
        if not self.lockReason then return end
        SMTooltip:SetOwner(self, "ANCHOR_RIGHT")
        SMTooltip:ClearLines()
        SMTooltip:AddLine(L["Tooltip Story Locked"], 1, 1, 1)
        SMTooltip:AddLine(self.lockReason, 1.0, 0.82, 0.35, true)
        SMTooltip:Show()
    end)
    card:SetScript("OnLeave", function()
        SM.ApplyStoryCardBorderState(row, false)
        SMTooltip:Hide()
    end)

    return row
end

local function AddCategoryDivider(text, yOffset, bottomPadding)
    local divH, div = SM.CreateCatDivider(SM.LeftStoryChild, text, yOffset)
    RememberStoryListFrame(div)
    return yOffset - divH - bottomPadding
end

local function RenderStoryCategory(cat, activeSet, globalIdx, cardHeight, cardPadding, yOffset)
    if cat.disabled then
        return globalIdx, AddCategoryDivider(cat.displayName or cat.name, yOffset, 12)
    end
    if not CategoryHasVisibleQuestlines(cat, activeSet) then
        return globalIdx, yOffset
    end

    yOffset = AddCategoryDivider(cat.displayName or cat.name, yOffset, 4)
    for _, data in ipairs(cat.questlines) do
        if not (activeSet[data] and not cat.active) then
            globalIdx = globalIdx + 1
            storyIndexToData[globalIdx] = data
            CreateStoryListCard(data, globalIdx, cardHeight, cardPadding, yOffset)
            yOffset = yOffset - cardHeight - 5
        end
    end
    return globalIdx, yOffset - 8
end


function SM.BuildStoryWindow()
    if storyContentBuilt then
        RefreshActiveStorySection()
        return
    end
    if SM.RegisterQuestlines then SM.RegisterQuestlines() end
    if SM.IsQuestlineRegistryReady and not SM.IsQuestlineRegistryReady() then return end
    storyContentBuilt = true
    for _, data in ipairs(allQuestlines) do SM.ResolveAchievementID(data) end
    wipe(storyIndexToData)
    local activeQuestlines, activeSet = CollectActiveStorylines()
    activeStoriesSignature = GetActiveStoriesSignature(activeQuestlines)
    local displayCategories = BuildDisplayCategories(activeQuestlines)

    local CARD_H   = (SM.IsRetailClient()) and 78 or 70
    local CARD_PAD = 4
    local yOffset  = -16
    local globalIdx = 0

    local playerName = UnitName("player")
    yOffset = AddCategoryDivider(playerName and string.format(L["Greeting Format"], playerName) or L["Greeting Fallback"], yOffset, 4)
    CreateIntroStoryCard(CARD_H, CARD_PAD, yOffset)
    yOffset = yOffset - CARD_H - 4

    for _, cat in ipairs(displayCategories) do
        globalIdx, yOffset = RenderStoryCategory(cat, activeSet, globalIdx, CARD_H, CARD_PAD, yOffset)
    end
    SM.LeftStoryChild:SetHeight(math.abs(yOffset) + 16)
    ApplyCurrentSelectionState()
end
