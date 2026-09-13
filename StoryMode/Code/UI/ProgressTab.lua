local _, SM = ...
local L = SM.L

function SM.LayoutProgressTab(data, w, contentW, visibleContentW)
    local ui = SM.DetailUI
    local detailChild = ui.detailChild
    local CP = ui.CP
    local C_DIM = ui.C_DIM
    local RING_GREEN = ui.RING_GREEN
    local RING_GOLD = ui.RING_GOLD
    local dTitle = ui.dTitle
    local dProgSummary = ui.dProgSummary
    local dTrackContainer = ui.dTrackContainer
    local dTrackClip = ui.dTrackClip
    local dTrackInner = ui.dTrackInner
    local dTrackNodes = ui.dTrackNodes
    local dTrackArrows = ui.dTrackArrows
    local dTrackLeftBtn = ui.dTrackLeftBtn
    local dTrackRightBtn = ui.dTrackRightBtn
    local dChapterTitle = ui.dChapterTitle
    local dChapterSummary = ui.dChapterSummary
    local dChapterNote = ui.dChapterNote
    local dQuestCards = ui.dQuestCards
    local TRACK_NODE_SIZE = ui.TRACK_NODE_SIZE
    local TRACK_ARROW_GAP = ui.TRACK_ARROW_GAP
    local TRACK_STEP = ui.TRACK_STEP
        -- ── PROGRESS TAB layout ─────────────────────────────────────────
        local chapters = SM.GetAllChapters(data)

        -- CTA
        -- Progress summary line
        local done, total = SM.GetCampaignProgress(data)
        local chapDone = 0
        for ci, ch in ipairs(chapters) do
            local cd, ct = SM.GetChapterProgress(ch)
            if cd == ct and ct > 0 then chapDone = chapDone + 1 end
        end
        dProgSummary:SetText(string.format(L["Progress Summary Format"], chapDone, #chapters, done, total))
        dProgSummary:ClearAllPoints()
        dProgSummary:SetPoint("TOP", dTitle, "BOTTOM", 0, -4)
        dProgSummary:Show()

        -- ── Horizontal chapter track + quest cards ────────────────────
        local GREEN_R, GREEN_G, GREEN_B = RING_GREEN[1], RING_GREEN[2], RING_GREEN[3]
        local GOLD_R,  GOLD_G,  GOLD_B  = RING_GOLD[1],  RING_GOLD[2],  RING_GOLD[3]
        local DIM_R, DIM_G, DIM_B = C_DIM[1], C_DIM[2], C_DIM[3]

        -- Hide old pools
        for _, node in ipairs(dTrackNodes) do node:Hide() end
        for _, arrow in ipairs(dTrackArrows) do arrow:Hide() end
        for _, card in ipairs(dQuestCards) do card:Hide() end

        -- Find the first incomplete chapter (current chapter)
        local currentChapter = #chapters
        for i, ch in ipairs(chapters) do
            local cd, ct = SM.GetChapterProgress(ch)
            if cd < ct or ct == 0 then currentChapter = i; break end
        end
        local savedChapter = tonumber(StoryModeDB.selectedChapter)
        if savedChapter and savedChapter >= 1 and savedChapter <= #chapters then
            currentChapter = savedChapter
        end
        SM.SetProgressSelectedChapter(currentChapter)
        SM.SetProgressChapterCount(#chapters)

        -- Build horizontal track nodes
        local totalTrackW = #chapters * TRACK_NODE_SIZE + math.max(0, #chapters - 1) * TRACK_ARROW_GAP
        dTrackInner:SetWidth(totalTrackW)
        local lineY = math.floor(TRACK_NODE_SIZE / 2)

        for i, ch in ipairs(chapters) do
            if not dTrackNodes[i] then
                dTrackNodes[i] = SM.CreateTrackNode(dTrackInner)
            end
            local node = dTrackNodes[i]
            local cDone, cTotal = SM.GetChapterProgress(ch)
            local isComplete = cDone == cTotal and cTotal > 0
            local isActive = cDone > 0 and not isComplete

            -- NPC portrait
            local displayID, chapterIcon, hasDataBackedPortrait = SM.GetChapterPortraitSource(data, ch)
            local questPortraitID = ch.quests and ch.quests[1] and ch.quests[1].id
            if hasDataBackedPortrait then questPortraitID = nil end
            SM.SetChapterPortrait(node.portrait, displayID, chapterIcon, questPortraitID)

            -- Tooltip
            node.tooltipTitle = ch.chapter
            node.tooltipBody = ch.summary or nil
            node.tooltipProgress = cDone .. " / " .. cTotal .. " quests"
            node.tooltipAchievementID = ch.achievementID or nil

            -- Status styling
            if ch.loreOnly and not isComplete then
                node.isDimmed = true
                node.portrait:SetVertexColor(0.80, 0.80, 0.80)
                node.portrait:SetDesaturation(0.4)
                node.ring:SetVertexColor((SM.IsRetailClient()) and 0.55 or 1, (SM.IsRetailClient()) and 0.48 or 1, (SM.IsRetailClient()) and 0.38 or 1)
                node.ring:SetAlpha((SM.IsRetailClient()) and 0.55 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, 0.55, 0.48, 0.38, node.hasRingAtlas and 0 or 0.55)
                node.checkmark:Hide()
            elseif isComplete then
                node.isDimmed = false
                node.portrait:SetVertexColor(1, 1, 1)
                node.portrait:SetDesaturation(0)
                node.ring:SetVertexColor((SM.IsRetailClient()) and GREEN_R or 1, (SM.IsRetailClient()) and GREEN_G or 1, (SM.IsRetailClient()) and GREEN_B or 1)
                node.ring:SetAlpha((SM.IsRetailClient()) and 0.8 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, GREEN_R, GREEN_G, GREEN_B, node.hasRingAtlas and 0 or 0.8)
                node.checkmark:Show()
            elseif isActive then
                node.isDimmed = false
                node.portrait:SetVertexColor(1, 1, 1)
                node.portrait:SetDesaturation(0)
                node.ring:SetVertexColor((SM.IsRetailClient()) and GOLD_R or 1, (SM.IsRetailClient()) and GOLD_G or 1, (SM.IsRetailClient()) and GOLD_B or 1)
                node.ring:SetAlpha((SM.IsRetailClient()) and 0.9 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, GOLD_R, GOLD_G, GOLD_B, node.hasRingAtlas and 0 or 0.9)
                node.checkmark:Hide()
            else
                node.isDimmed = true
                node.portrait:SetVertexColor(0.6, 0.6, 0.6)
                node.portrait:SetDesaturation(0.7)
                node.ring:SetVertexColor((SM.IsRetailClient()) and 0.4 or 1, (SM.IsRetailClient()) and 0.35 or 1, (SM.IsRetailClient()) and 0.30 or 1)
                node.ring:SetAlpha((SM.IsRetailClient()) and 0.5 or 1.0)
                SM.SetSimpleBorder(node.portraitBorder, 0.4, 0.35, 0.30, node.hasRingAtlas and 0 or 0.5)
                node.checkmark:Hide()
            end
            node.borderR, node.borderG, node.borderB = node.ring:GetVertexColor()
            node.borderA = node.ring:GetAlpha()

            -- Shape: gated and flagged special chapters render as squares on Retail.
            -- ch.prerequisites = explicit quest gate; ch.gated = manual flag for
            -- chapters locked behind progress that can't be expressed as a quest ID.
            local CIRC = "Interface/CHARACTERFRAME/TempPortraitAlphaMask"
            local isGated = SM.IsRetailClient()
                and (ch.prerequisites ~= nil or ch.gated == true or ch.chapterNodeStyle == "rectangle")
            node.isGated = isGated
            if isGated then
                node.portraitMask:SetTexture("Interface/Buttons/WHITE8x8")
                node.glowMask:SetTexture("Interface/Buttons/WHITE8x8")
                node.hoverGlowMask:SetTexture("Interface/Buttons/WHITE8x8")
                local r, g, b = node.ring:GetVertexColor()
                local a = node.ring:GetAlpha()
                node.ring:Hide()
                node.squareBorder:SetVertexColor(r, g, b)
                node.squareBorder:SetAlpha(a)
                node.squareBorder:Show()
                SM.SetSimpleBorder(node.portraitBorder, r, g, b, node.hasRingAtlas and 0 or a)
                node.borderR, node.borderG, node.borderB, node.borderA = r, g, b, a
            else
                node.portraitMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.glowMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.hoverGlowMask:SetTexture(CIRC, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
                node.squareBorder:Hide()
                if node.hasRingAtlas then
                    node.ring:Show()
                else
                    node.ring:Hide()
                end
                SM.SetSimpleBorder(node.portraitBorder, node.borderR, node.borderG, node.borderB, node.hasRingAtlas and 0 or node.borderA)
            end

            -- Position
            node:ClearAllPoints()
            local x = (i - 1) * TRACK_STEP
            node:SetPoint("TOP", dTrackInner, "TOPLEFT", x + TRACK_NODE_SIZE / 2, -8)

            -- Click handler
            local idx = i
            node:SetScript("OnClick", function()
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                SM.SetProgressSelectedChapter(idx)
                StoryModeDB.selectedChapter = idx
                SM.LayoutSelectedChapter()
                C_Timer.After(0, function() SM.CenterTrackOnSelected(dTrackClip:GetWidth()) end)
            end)

            node:Show()

            -- Arrow between nodes (except after last)
            if i < #chapters then
                if not dTrackArrows[i] then
                    dTrackArrows[i] = dTrackInner:CreateTexture(nil, "ARTWORK")
                    SM.SetStoryArrowTexture(dTrackArrows[i], "right", false)
                end
                local arrow = dTrackArrows[i]
                arrow:ClearAllPoints()
                arrow:SetSize(SM.TrackArrowSize, SM.TrackArrowSize)
                arrow:SetPoint("LEFT", dTrackInner, "TOPLEFT",
                    x + TRACK_NODE_SIZE + (TRACK_ARROW_GAP - SM.TrackArrowSize) / 2, -(lineY + 5))

                -- Arrow color
                if isComplete then
                    arrow:SetVertexColor(GREEN_R, GREEN_G, GREEN_B, 0.6)
                else
                    arrow:SetVertexColor(DIM_R, DIM_G, DIM_B, 0.3)
                end
                arrow:Show()
            end
        end
        for i = #chapters + 1, #dTrackNodes do dTrackNodes[i]:Hide() end
        for i = #chapters, #dTrackArrows do if dTrackArrows[i] then dTrackArrows[i]:Hide() end end

        -- Position track container
        dTrackContainer:ClearAllPoints()
        dTrackContainer:SetPoint("TOP", dProgSummary, "BOTTOM", 0, -18)
        dTrackContainer:SetPoint("LEFT", detailChild, "LEFT", 0, 0)
        dTrackContainer:SetPoint("RIGHT", detailChild, "RIGHT", 0, 0)
        dTrackContainer:Show()

        -- Center track on selected chapter + apply node fading
        C_Timer.After(0, function()
            local clipW = dTrackClip:GetWidth()
            SM.CenterTrackOnSelected(clipW)
            dTrackLeftBtn:Show()
            dTrackRightBtn:Show()
        end)

        -- Chapter title + summary below track
        dChapterTitle:ClearAllPoints()
        dChapterTitle:SetPoint("TOPLEFT", dTrackContainer, "BOTTOMLEFT", CP, -10)
        dChapterTitle:SetPoint("TOPRIGHT", dTrackContainer, "BOTTOMRIGHT", -CP, -10)

        dChapterSummary:ClearAllPoints()
        dChapterSummary:SetPoint("TOPLEFT", dChapterTitle, "BOTTOMLEFT", 0, -4)
        dChapterSummary:SetPoint("TOPRIGHT", dChapterTitle, "BOTTOMRIGHT", 0, -4)

        dChapterNote:ClearAllPoints()
        dChapterNote:SetPoint("TOPLEFT", dChapterSummary, "BOTTOMLEFT", 0, -8)
        dChapterNote:SetPoint("TOPRIGHT", dChapterSummary, "BOTTOMRIGHT", 0, -8)

        -- Render quest cards for selected chapter
        SM.LayoutSelectedChapter()
end

