local addonName, SM = ...
local L = SM.L

function SM.CreateBanners()
    local alertFrame = CreateFrame("Frame", nil, UIParent)
    alertFrame:SetPoint("TOP", UIParent, "TOP", 0, -24)
    alertFrame:SetSize(400, 60)
    alertFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    alertFrame:Hide()

    local alertHeader = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    alertHeader:SetPoint("BOTTOM", alertFrame, "CENTER", 0, 2)
    alertHeader:SetJustifyH("CENTER")
    alertHeader:SetTextColor(0.95, 0.85, 0.55)
    alertHeader:SetShadowOffset(1, -1)

    local alertTitle = alertFrame:CreateFontString(nil, "OVERLAY", "QuestFont_Huge")
    alertTitle:SetPoint("TOP", alertFrame, "CENTER", 0, -2)
    alertTitle:SetJustifyH("CENTER")
    alertTitle:SetTextColor(1, 1, 1)
    alertTitle:SetShadowOffset(1, -1)

    local alertFadeIn = alertFrame:CreateAnimationGroup()
    local alphaIn = alertFadeIn:CreateAnimation("Alpha")
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(1)
    alphaIn:SetDuration(0.6)
    alphaIn:SetSmoothing("OUT")
    alertFadeIn:SetScript("OnFinished", function() alertFrame:SetAlpha(1) end)

    local alertFadeOut = alertFrame:CreateAnimationGroup()
    local alphaOut = alertFadeOut:CreateAnimation("Alpha")
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)
    alphaOut:SetDuration(1.0)
    alphaOut:SetSmoothing("IN")
    alertFadeOut:SetScript("OnFinished", function() alertFrame:Hide(); alertFrame:SetAlpha(1) end)

    local function ShowStoryBanner(headerText, titleText, questlineData, npcName, isChapter)
        alertHeader:SetText(string.upper(headerText))
        alertTitle:SetText(titleText)

        alertFadeOut:Stop()
        alertFadeIn:Stop()
        alertFrame:SetAlpha(0)
        alertFrame:Show()
        alertFadeIn:Play()

        local hold = isChapter and 4.0 or 3.0
        C_Timer.After(hold, function()
            if alertFrame:IsShown() then alertFadeOut:Play() end
        end)
    end

    local function ShowStoryComplete(storyTitle)
        ShowStoryBanner(L["Banner Story Complete"], storyTitle or "", nil, nil, true)
    end

    return ShowStoryBanner, ShowStoryComplete
end
