local _, SM = ...
local L = SM.L

function SM.LayoutStoryTab(data, w, contentW, visibleContentW)
    local ui = SM.DetailUI
    local detailChild = ui.detailChild
    local CP = ui.CP
    local ADVENTURE_COVER_W = ui.ADVENTURE_COVER_W
    local ADVENTURE_COVER_TEX_LEFT = ui.ADVENTURE_COVER_TEX_LEFT
    local ADVENTURE_COVER_TEX_RIGHT = ui.ADVENTURE_COVER_TEX_RIGHT
    local ADVENTURE_COVER_TEX_TOP = ui.ADVENTURE_COVER_TEX_TOP
    local ADVENTURE_COVER_TEX_BOTTOM = ui.ADVENTURE_COVER_TEX_BOTTOM
    local aCoverFrame = ui.aCoverFrame
    local aCoverTexture = ui.aCoverTexture
    local aCoverTitle = ui.aCoverTitle
    local aCoverDivider = ui.aCoverDivider
    local aCoverLevel = ui.aCoverLevel
    local sIntro = ui.sIntro
    local sTrackBtn = ui.sTrackBtn
    local sTrackBtnSecure = ui.sTrackBtnSecure
    local sCompleteText = ui.sCompleteText
    local FactionUI = SM.FactionUI
    local ExecuteTrackButton = SM.ExecuteTrackButton
        -- ── STORY TAB layout ────────────────────────────────────────────
        -- Clean top-down chain: cover → intro → CTA

        -- The fade mask has 40px transparent borders on a 512px-wide canvas, so
        -- the visually opaque portion of the cover is 432/512 = 0.84375 of the
        -- frame width. Bleed the frame outward on both sides so the *visible*
        -- area lines up with the text content bounds.
        local COVER_MASK_VISIBLE_X = 432 / 512
        local visibleTargetW = math.min(ADVENTURE_COVER_W, contentW)
        if visibleTargetW < 360 then visibleTargetW = 360 end
        local coverW = visibleTargetW / COVER_MASK_VISIBLE_X
        local coverH = coverW
            * ((ADVENTURE_COVER_TEX_BOTTOM - ADVENTURE_COVER_TEX_TOP)
            / (ADVENTURE_COVER_TEX_RIGHT - ADVENTURE_COVER_TEX_LEFT))
        local hBleed = (coverW - visibleTargetW) / 2
        aCoverFrame:ClearAllPoints()
        aCoverFrame:SetPoint("TOPLEFT", detailChild, "TOPLEFT", CP - hBleed, -18)
        aCoverFrame:SetSize(coverW, coverH)
        aCoverTexture:SetSize(coverW, coverH)
        aCoverTitle:SetWidth(visibleTargetW - 56)
        aCoverDivider:ClearAllPoints()
        aCoverDivider:SetPoint("TOP", aCoverTitle, "BOTTOM", 0, -6)
        local titleW = aCoverTitle:GetStringWidth()
        if titleW < 60 then titleW = 60 end
        aCoverDivider:SetWidth(titleW)
        aCoverLevel:SetWidth(visibleTargetW - 80)
        aCoverLevel:ClearAllPoints()
        aCoverLevel:SetPoint("TOP", aCoverDivider, "BOTTOM", 0, -6)
        aCoverFrame:Show()

        -- Story intro below hero
        sIntro:ClearAllPoints()
        sIntro:SetPoint("TOPLEFT",  detailChild, "TOPLEFT",  CP, -(coverH + 40))
        sIntro:SetPoint("TOPRIGHT", detailChild, "TOPRIGHT", -CP, -(coverH + 40))
        if contentW > 20 then sIntro:SetWidth(contentW) end

        local lastAnchor = sIntro

        FactionUI:HideAll()

        -- CTA button
        local quest, _, nextChapter = SM.FindNextQuest(data)
        local done = select(1, SM.GetCampaignProgress(data))
        local gateReason = SM.GetQuestlineGateReason(data, nextChapter)
        sTrackBtn:ClearAllPoints()
        sTrackBtn:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -24)
        sCompleteText:Hide()
        if quest then
            if gateReason then
                sTrackBtn:SetText(L["Button Story Locked"])
                sTrackBtn:SetScript("OnClick", nil)
                SM.SetSecureOverlayActive(false)
                sTrackBtn:Disable()
                sTrackBtn:SetAlpha(0.5)
                sTrackBtn.lockReason = gateReason
            else
                sTrackBtn:SetText(done > 0 and L["Button Continue Story"] or L["Button Begin Story"])
                if SM.IsClassicClient() then
                    SM.SetSecureOverlayActive(false)
                    sTrackBtn:SetScript("OnClick", function()
                        ExecuteTrackButton(data, quest)
                    end)
                else
                    -- PreClick on the secure overlay queues the action BEFORE the
                    -- macro fires. The macro then performs the waypoint +
                    -- supertrack calls in a secure execution context.
                    sTrackBtnSecure:SetScript("PreClick", function()
                        SM.QueueSecureTrack(data, quest)
                    end)
                    SM.SetSecureOverlayActive(true)
                    sTrackBtn:SetScript("OnClick", function()
                        ExecuteTrackButton(data, quest)
                    end)
                end
                sTrackBtn:Enable()
                sTrackBtn:SetAlpha(1.0)
                sTrackBtn.lockReason = nil
            end
        else
            sTrackBtn:SetText(L["Button Story Finished"])
            sTrackBtn:SetScript("OnClick", nil)
            SM.SetSecureOverlayActive(false)
            sTrackBtn:Disable()
            sTrackBtn:SetAlpha(0.5)
            sTrackBtn.lockReason = nil
        end
        sTrackBtn:Show()
        SM.SyncSecureOverlay()
        lastAnchor = sTrackBtn

        local storyBottomEl = lastAnchor
        -- Set scroll height
        C_Timer.After(0, function()
            local bot = storyBottomEl:GetBottom()
            local top = detailChild:GetTop()
            if bot and top then
                detailChild:SetHeight(math.max(top - bot + 40, 400))
            else
                detailChild:SetHeight(500)
            end
        end)
end

