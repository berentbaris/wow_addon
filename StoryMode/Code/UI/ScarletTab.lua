local _, SM = ...
local L = SM.L

local LEDGER_PAGES = { 250, 500, 1000 }

-- Named Crusade figures whose deaths strike a name from the hunt list.
-- Matched by NPC ID (locale-safe) with an exact enUS name fallback in case an
-- ID drifts between client flavors. Display order is this table's order.
-- listOnly entries appear on the list but have no kill trigger in this era
-- (Benedictus Voss's death belongs to Lilian, not the player).
SM.ScarletNamedTargets = {
    -- showAtCount staggers list visibility along the ledger pages; kills are
    -- recorded (and their banner fires) regardless, so an early kill shows up
    -- already struck through the moment its name surfaces.
    { key = "Korgal",         npcID = 1667,  name = "Meven Korgal" },
    { key = "Perrine",        npcID = 1662,  name = "Captain Perrine" },
    { key = "Vachon",         npcID = 1664,  name = "Captain Vachon" },
    { key = "Melrache",       npcID = 1665,  name = "Captain Melrache" },
    { key = "Thalnos",        npcID = 4543,  name = "Bloodmage Thalnos" },
    { key = "Vishas",         npcID = 3983,  name = "Interrogator Vishas" },
    { key = "Loksey",         npcID = 3974,  name = "Houndmaster Loksey" },
    { key = "Doan",           npcID = 6487,  name = "Arcanist Doan" },
    { key = "Herod",          npcID = 3975,  name = "Herod", showAtCount = 250 },
    { key = "Mograine",       npcID = 3976,  name = "Scarlet Commander Mograine", showAtCount = 250 },
    { key = "Fairbanks",      npcID = 4542,  name = "High Inquisitor Fairbanks", showAtCount = 250 },
    { key = "Whitemane",      npcID = 3977,  name = "High Inquisitor Whitemane", showAtCount = 250 },
    { key = "Balnazzar",      npcID = 10813, name = "Balnazzar", showAtCount = 1000 },
    { key = "Radley",         npcID = 11613, name = "Huntsman Radley", showAtCount = 500 },
    { key = "Durgen",         npcID = 11611, name = "Cavalier Durgen", showAtCount = 500 },
    { key = "Abbendis",       npcID = 10828, name = "High General Abbendis", showAtCount = 500 },
    { key = "Courier",        npcID = 12337, name = "Crimson Courier", showAtCount = 500 },
    { key = "Demetria",       npcID = 12339, name = "Demetria", showAtCount = 500 },
    -- Only surfaces once "The Priest's Daughter" page has named him.
    { key = "BenedictusVoss", npcID = 39097, name = "High Priest Benedictus Voss", listOnly = true, showAtCount = 1000 },
}


local function BuildScarletSections(count)
    local sections = {
        { title = L["Scarlet Section 100"], body = L["Scarlet Tab Body"] },
    }
    for _, threshold in ipairs(LEDGER_PAGES) do
        if count >= threshold then
            sections[#sections + 1] = {
                title = L["Scarlet Section " .. threshold],
                body = L["Scarlet Tab Body " .. threshold],
            }
        end
    end
    return sections
end

function SM.LayoutScarletTab(data, w, contentW, visibleContentW)
    local ui = SM.DetailUI
    local detailChild = ui.detailChild
    local CP = ui.CP
    local sScarletTitle = ui.sScarletTitle
    local sScarletCount = ui.sScarletCount
    local sScarletCountBtn = ui.sScarletCountBtn
    local sScarletSections = ui.sScarletSections

    SM.FactionUI:HideAll()

    sScarletTitle:ClearAllPoints()
    sScarletTitle:SetPoint("TOP", detailChild, "TOP", 0, -18)
    sScarletTitle:Show()

    local count = SM.GetScarletKillCount and SM.GetScarletKillCount() or 0
    if count >= (SM.ScarletCapstoneThreshold or 5000) then
        sScarletCount:SetText(L["Scarlet Stopped Counting"])
    else
        sScarletCount:SetText(string.format(L["Scarlet Crusader Note Format"], count))
    end
    sScarletCount:ClearAllPoints()
    sScarletCount:SetPoint("TOP", sScarletTitle, "BOTTOM", 0, -4)
    sScarletCount:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
    sScarletCount:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
    if contentW > 20 then sScarletCount:SetWidth(contentW) end
    sScarletCount:Show()

    sScarletCountBtn:ClearAllPoints()
    sScarletCountBtn:SetPoint("TOPLEFT", sScarletCount, "TOPLEFT", 0, 2)
    sScarletCountBtn:SetPoint("BOTTOMRIGHT", sScarletCount, "BOTTOMRIGHT", 0, -2)
    sScarletCountBtn:Show()

    -- The List first: every named target, centered, struck through once felled.
    local C_BODY = ui.C_BODY
    local recorded = SM.GetScarletNamedKills and SM.GetScarletNamedKills() or {}
    local listEntry = SM.GetScarletSection(1)
    listEntry.title:SetText(L["Scarlet Names Header"])
    listEntry.title:ClearAllPoints()
    listEntry.title:SetPoint("TOP", sScarletCount, "BOTTOM", 0, -18)
    listEntry.title:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
    listEntry.title:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
    listEntry.title:Show()
    listEntry.body:Hide()

    local sScarletHuntRows = ui.sScarletHuntRows
    local rowAnchor = listEntry.title
    local shownRows = 0
    for _, target in ipairs(SM.ScarletNamedTargets) do
        -- A name shows once its tier unlocks, or the moment you fell it —
        -- never hide a target you have already struck from the list.
        local isStruck = recorded[target.key] and true or false
        if not target.showAtCount or count >= target.showAtCount or isStruck then
            shownRows = shownRows + 1
            local row = SM.GetScarletHuntRow(shownRows)

            row.text:SetText(L[target.name])
            row.text:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
            row.text:ClearAllPoints()
            row.text:SetPoint("TOP", rowAnchor, "BOTTOM", 0, shownRows == 1 and -10 or -5)
            row.text:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
            row.text:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
            row.text:Show()

            if isStruck then
                row.strike:ClearAllPoints()
                row.strike:SetPoint("CENTER", row.text, "CENTER", 0, 0)
                row.strike:SetWidth(row.text:GetStringWidth() + 10)
                row.strike:Show()
            else
                row.strike:Hide()
            end

            rowAnchor = row.text
        end
    end
    for i = shownRows + 1, #sScarletHuntRows do
        sScarletHuntRows[i].text:Hide()
        sScarletHuntRows[i].strike:Hide()
    end

    -- Prose pages below the list, journal-style: gold title, body, repeat.
    local sections = BuildScarletSections(count)
    local lastAnchor = rowAnchor
    for i, section in ipairs(sections) do
        local entry = SM.GetScarletSection(i + 1)

        entry.title:SetText(section.title)
        entry.title:ClearAllPoints()
        entry.title:SetPoint("TOP", lastAnchor, "BOTTOM", 0, -20)
        entry.title:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
        entry.title:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
        entry.title:Show()

        entry.body:SetText(section.body)
        entry.body:ClearAllPoints()
        entry.body:SetPoint("TOP", entry.title, "BOTTOM", 0, -6)
        entry.body:SetPoint("LEFT", detailChild, "LEFT", CP, 0)
        entry.body:SetPoint("RIGHT", detailChild, "RIGHT", -CP, 0)
        if contentW > 20 then entry.body:SetWidth(contentW) end
        entry.body:Show()

        lastAnchor = entry.body
    end
    for i = #sections + 2, #sScarletSections do
        sScarletSections[i].title:Hide()
        sScarletSections[i].body:Hide()
    end

    local scarletBottomEl = lastAnchor
    -- Set scroll height
    C_Timer.After(0, function()
        local bot = scarletBottomEl:GetBottom()
        local top = detailChild:GetTop()
        if bot and top then
            detailChild:SetHeight(math.max(top - bot + 40, 400))
        else
            detailChild:SetHeight(500)
        end
    end)
end
