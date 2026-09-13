local _, SM = ...
local L = SM.L

function SM.LayoutJournalTab(data, w, contentW, visibleContentW)
    local ui = SM.DetailUI
    local detailChild = ui.detailChild
    local detailScroll = ui.detailScroll
    local CP = ui.CP
    local sJournalHeader = ui.sJournalHeader
    local sJournalSubline = ui.sJournalSubline
    local sJournalEmptyTitle = ui.sJournalEmptyTitle
    local sJournalEmptyText = ui.sJournalEmptyText
    local sFactionHeader = ui.sFactionHeader
    local sJournalEntries = ui.sJournalEntries
    local FactionUI = SM.FactionUI
        -- ── JOURNAL TAB layout ──────────────────────────────────────────
        -- Show recap for each completed chapter (no spoilers for future ones)
        local chapters = SM.GetAllChapters(data)
        local journalIdx = 0
        local hasAnyRecap = false
        local quest = SM.FindNextQuest(data)
        local done = SM.GetCampaignProgress(data)
        local lastAnchor = sJournalHeader

        -- Factions live in the contextual left panel on the Journal tab.
        FactionUI:HideAll()
        sFactionHeader:Hide()

        sJournalHeader:SetText(quest and L["Journal Header"] or L["Journal Header Complete"])
        sJournalHeader:ClearAllPoints()
        sJournalHeader:SetPoint("TOP", detailChild, "TOP", 0, -18)
        sJournalHeader:Show()

        sJournalSubline:ClearAllPoints()
        sJournalSubline:SetPoint("TOP", sJournalHeader, "BOTTOM", 0, -4)
        sJournalSubline:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
        sJournalSubline:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
        if contentW > 20 then sJournalSubline:SetWidth(contentW) end
        sJournalSubline:Show()

        for ci, ch in ipairs(chapters) do
            local cd, ct = SM.GetChapterProgress(ch)
            local chComplete = cd == ct and ct > 0
            if chComplete and ch.recap then
                journalIdx = journalIdx + 1
                hasAnyRecap = true
                local entry = SM.GetJournalEntry(journalIdx)

                -- Chapter title
                entry.title:ClearAllPoints()
                if journalIdx == 1 then
                    entry.title:SetPoint("TOP", sJournalSubline, "BOTTOM", 0, -18)
                else
                    local prev = sJournalEntries[journalIdx - 1]
                    entry.title:SetPoint("TOP", prev.body, "BOTTOM", 0, -20)
                end
                entry.title:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
                entry.title:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
                entry.title:SetText(ch.chapter)
                entry.title:Show()

                -- Recap body
                entry.body:ClearAllPoints()
                entry.body:SetPoint("TOP", entry.title, "BOTTOM", 0, -6)
                entry.body:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
                entry.body:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
                entry.body:SetText(ch.recap)
                entry.body:Show()

                lastAnchor = entry.body
            end
        end

        if not hasAnyRecap then
            sJournalHeader:Hide()
            sJournalSubline:Hide()
            local emptyTop = -math.max(150, math.floor((detailScroll:GetHeight() or 420) * 0.42))
            sJournalEmptyTitle:ClearAllPoints()
            sJournalEmptyTitle:SetPoint("TOP", detailChild, "TOP", 0, emptyTop)
            sJournalEmptyTitle:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
            sJournalEmptyTitle:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
            if done > 0 then
                sJournalEmptyTitle:SetText(L["Journal No Recaps Title"])
                sJournalEmptyText:SetText(L["Journal No Recaps Text"])
            else
                sJournalEmptyTitle:SetText(L["Journal Empty Title"])
                sJournalEmptyText:SetText(L["Journal Empty Text"])
            end
            sJournalEmptyTitle:Show()
            sJournalEmptyText:ClearAllPoints()
            sJournalEmptyText:SetPoint("TOPLEFT", sJournalEmptyTitle, "BOTTOMLEFT", 0, -8)
            sJournalEmptyText:SetPoint("TOPRIGHT", sJournalEmptyTitle, "BOTTOMRIGHT", 0, -8)
            if contentW > 20 then sJournalEmptyText:SetWidth(contentW) end
            sJournalEmptyText:Show()
            lastAnchor = sJournalEmptyText
        else
            sJournalHeader:Show()
            sJournalSubline:Show()
            sJournalEmptyTitle:Hide()
            sJournalEmptyText:Hide()
        end

        -- Hide unused journal entries
        for i = journalIdx + 1, #sJournalEntries do
            sJournalEntries[i].title:Hide()
            sJournalEntries[i].body:Hide()
        end

        local journalBottomEl = lastAnchor
        -- Set scroll height
        C_Timer.After(0, function()
            local bot = journalBottomEl:GetBottom()
            local top = detailChild:GetTop()
            if bot and top then
                detailChild:SetHeight(math.max(top - bot + 40, 400))
            else
                detailChild:SetHeight(500)
            end
        end)
end

