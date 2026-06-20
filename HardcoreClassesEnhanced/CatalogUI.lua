----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Integrated Class Catalog & Picker
--
-- A unified UI that combines browsing and selecting enhanced classes.
--
-- Three-screen flow:
--   Screen 1: WoW class grid (9 classes)
--   Screen 2: Enhanced classes for that WoW class (Core + Additional)
--   Screen 3: Class detail with art panel on the right + Select button
--
-- Auto-opens on login when no class is picked.
-- Also reachable via /hce catalog, /hce pick, /hce ui.
----------------------------------------------------------------------

HCE = HCE or {}

local Catalog = {}
HCE.CatalogUI = Catalog

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------
local FRAME_WIDTH   = 660
local FRAME_HEIGHT  = 520
local GRID_COLS     = 3
local GRID_CELL_W   = 180
local GRID_CELL_H   = 52
local GRID_PAD_X    = 12
local GRID_PAD_Y    = 8
local LIST_ROW_H    = 38
local ROW_HEIGHT    = 16

-- WoW class colours (hex, no leading |cff)
local CLASS_COLORS = {
    WARRIOR = "c79c6e", PALADIN = "f58cba", HUNTER  = "abd473",
    ROGUE   = "fff569", PRIEST  = "ffffff", SHAMAN  = "0070de",
    MAGE    = "69ccf0", WARLOCK = "9482c9", DRUID   = "ff7d0a",
}

-- WoW class icons (Blizzard texture atlas paths)
local CLASS_ICONS = {
    WARRIOR = "Interface\\Icons\\ClassIcon_Warrior",
    PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
    HUNTER  = "Interface\\Icons\\ClassIcon_Hunter",
    ROGUE   = "Interface\\Icons\\ClassIcon_Rogue",
    PRIEST  = "Interface\\Icons\\ClassIcon_Priest",
    SHAMAN  = "Interface\\Icons\\ClassIcon_Shaman",
    MAGE    = "Interface\\Icons\\ClassIcon_Mage",
    WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
    DRUID   = "Interface\\Icons\\ClassIcon_Druid",
}

-- Ordered class list for the grid (row by row)
local CLASS_ORDER = {
    "WARRIOR", "PALADIN", "HUNTER",
    "ROGUE",   "PRIEST",  "SHAMAN",
    "MAGE",    "WARLOCK", "DRUID",
}

-- Catalog spec overrides (same as before, for display)
local CATALOG_SPEC = {
    ["Mountain King"] = "Shield slam tank",
    ["Brewmaster"] = "Slam fury",
    ["Demon Hunter"] = "Dual-sword ghost",
    ["Tinker"] = "Mace combat",
    ["Blademaster"] = "Sword arms",
    ["Brave"] = "Polearm arms",
    ["Berserker"] = "Fury tank",
    ["Sister of Steel"] = "Arms tank",
    ["Warden"] = "Poison assassination",
    ["Runemaster"] = "Dual-fist weapon fury",
    ["Pyremaster"] = "Firestone/conflagrate",
    ["Death Knight"] = "Soul link tank",
    ["Necromancer"] = "Drain life",
    ["Druid of the Claw"] = "Feral tank",
    ["Plagueshifter"] = "Powershifting/healer hybrid",
    ["Savagekin"] = "Moonkin",
    ["Buccaneer"] = "Backstab assassination",
    ["Beastmaster"] = "Beast mastery",
    ["Mountaineer"] = "Marksmanship",
    ["Earthcaller"] = "Stormstrike tank",
    ["Witch Doctor"] = "Totem-based resto",
    ["Spiritwalker"] = "Elemental",
    ["Exemplar"] = "Retribution",
    ["Templar"] = "Tank/healer holy",
    ["Scarlet Champion"] = "Holy shield tank",
    ["Priestess of the Moon"] = "Spirit-based holy/arcane dps",
    ["Apothecary"] = "Discipline",
    ["Shadow Hunter"] = "Melee weaving shadow",
    ["Bloodmage"] = "Fire-only mage",
    ["Techno-mage"] = "Pyroblast arcane",
    ["Spellblade"] = "Aoe frost",
    ["Wilderness Stalker"] = "Trap-based melee survival",
    ["Lightslayer"] = "Shadow-only priest",
    ["Hedge Wizard"] = "Self-taught scorch fire",
    ["Dark Ranger"] = "Shadow subtlety",
    ["Prospector"] = "Ambush subtlety",
    ["Elven Ranger"] = "Lone wolf survival",
    ["Dragonsworn"] = "Swiftmend resto",
    ["Ley Walker"] = "Truecaster balance",
    ["Graven One"] = "Melee weaving drainlock",
    ["Spirit Champion"] = "2h enhancement",
    ["Archmage of Kirin Tor"] = "Frostfire mage",
}

-- Challenges to hide from display
local HIDE_CHALLENGE = { ["Ephemeral"] = true }

-- Colours matching RequirementsPanel (exact same values)
local COLOR_HEADER   = { r = 1.00, g = 0.78, b = 0.10 }
local COLOR_SUBTXT   = { r = 0.75, g = 0.75, b = 0.75 }
local COLOR_INACTIVE = { r = 0.55, g = 0.55, b = 0.55 }
local COLOR_TIPS     = { r = 0.55, g = 0.70, b = 0.85 }
local DETAIL_ROW_H   = 16
local DETAIL_PAD_X   = 14
local DETAIL_PAD_Y   = 10
local DETAIL_SEC_GAP = 8
local DETAIL_WIDTH   = 320

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local frame              -- main frame (created once)
local currentScreen = 1  -- 1=class grid, 2=class list, 3=detail
local selectedWowClass   -- e.g. "WARRIOR"
local selectedCharKey    -- e.g. "Mountain King"

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------
local function titleCase(s)
    if not s or s == "" then return "" end
    return s:sub(1, 1):upper() .. s:sub(2):lower()
end

local function cc(classToken)
    return CLASS_COLORS[classToken or ""] or "ffd100"
end

--- Get characters for a given WoW class, split into core and additional.
local function getCharactersForClass(wowClass)
    local core, additional = {}, {}
    local extras = HCE.AdditionalCharacters or {}
    for key, char in pairs(HCE.Characters or {}) do
        if char.class == wowClass then
            if extras[char.name] then
                table.insert(additional, char)
            else
                table.insert(core, char)
            end
        end
    end
    table.sort(core, function(a, b) return a.name < b.name end)
    table.sort(additional, function(a, b) return a.name < b.name end)
    return core, additional
end

----------------------------------------------------------------------
-- Frame creation (once)
----------------------------------------------------------------------
-- Sub-frames for each screen
local classGridFrame     -- Screen 1
local classListFrame     -- Screen 2
local detailFrame        -- Screen 3

local function BuildFrame()
    if frame then return end

    frame = CreateFrame("Frame", "HCE_CatalogFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    -- Ornate gold border
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = 16,
            insets   = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0.06, 0.06, 0.08, 0.96)
        frame:SetBackdropBorderColor(1.0, 0.85, 0.45, 0.95)
    end

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 4, -4)
    titleBar:SetPoint("TOPRIGHT", -4, -4)
    titleBar:SetHeight(32)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetColorTexture(0.85, 0.70, 0.20, 0.10)
    titleBg:SetAllPoints()

    local titleStripe = titleBar:CreateTexture(nil, "ARTWORK")
    titleStripe:SetColorTexture(1.0, 0.82, 0.0, 0.70)
    titleStripe:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    titleStripe:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    titleStripe:SetHeight(2)

    frame.titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", 0, 2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Back button (hidden on screen 1)
    local backBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    backBtn:SetSize(80, 22)
    backBtn:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 8, -6)
    backBtn:SetText("< Back")
    backBtn:Hide()
    backBtn:SetScript("OnClick", function()
        if currentScreen == 3 then
            Catalog.ShowScreen2(selectedWowClass)
        elseif currentScreen == 2 then
            Catalog.ShowScreen1()
        end
    end)
    frame.backBtn = backBtn

    -- Content area (below title + back button)
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -68)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    frame.content = content

    ----------------------------------------------------------------
    -- SCREEN 1: Class Grid
    ----------------------------------------------------------------
    classGridFrame = CreateFrame("Frame", nil, content)
    classGridFrame:SetAllPoints()

    local gridSubtitle = classGridFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    gridSubtitle:SetPoint("TOPLEFT", 4, 0)
    gridSubtitle:SetText("Choose a class to browse enhanced archetypes:")
    classGridFrame.subtitle = gridSubtitle

    classGridFrame.buttons = {}
    for i, classToken in ipairs(CLASS_ORDER) do
        local row = math.floor((i - 1) / GRID_COLS)
        local col = (i - 1) % GRID_COLS

        local btn = CreateFrame("Button", nil, classGridFrame, "BackdropTemplate")
        btn:SetSize(GRID_CELL_W, GRID_CELL_H)
        btn:SetPoint("TOPLEFT", classGridFrame, "TOPLEFT",
            4 + col * (GRID_CELL_W + GRID_PAD_X),
            -24 + (-row * (GRID_CELL_H + GRID_PAD_Y)))

        if btn.SetBackdrop then
            btn:SetBackdrop({
                bgFile   = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets   = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            btn:SetBackdropColor(0.12, 0.12, 0.14, 0.85)
            btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        end

        -- Class icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(32, 32)
        icon:SetPoint("LEFT", 8, 0)
        icon:SetTexture(CLASS_ICONS[classToken])
        btn.icon = icon

        -- Class name
        local name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", icon, "RIGHT", 8, 4)
        name:SetText("|cff" .. cc(classToken) .. titleCase(classToken) .. "|r")
        btn.nameText = name

        -- Count of enhanced classes
        local count = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        count:SetPoint("LEFT", icon, "RIGHT", 8, -8)
        btn.countText = count

        -- Hover highlight
        local hl = btn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 0.82, 0, 0.12)

        btn.classToken = classToken
        btn:SetScript("OnClick", function()
            Catalog.ShowScreen2(classToken)
        end)

        -- Highlight if it's the player's class
        btn:SetScript("OnShow", function(self)
            local _, playerClass = UnitClass("player")
            if self.classToken == playerClass then
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
                end
            else
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                end
            end
        end)

        classGridFrame.buttons[i] = btn
    end

    ----------------------------------------------------------------
    -- SCREEN 2: Enhanced class list for a WoW class
    ----------------------------------------------------------------
    classListFrame = CreateFrame("Frame", nil, content)
    classListFrame:SetAllPoints()
    classListFrame:Hide()

    classListFrame.sectionLabel = classListFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    classListFrame.sectionLabel:SetPoint("TOPLEFT", 4, 0)

    -- Scroll frame for the list
    local listScroll = CreateFrame("ScrollFrame", "HCE_CatalogListScroll", classListFrame, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", 0, -22)
    listScroll:SetPoint("BOTTOMRIGHT", -24, 0)
    classListFrame.scroll = listScroll

    local listContent = CreateFrame("Frame", nil, listScroll)
    listContent:SetWidth(listScroll:GetWidth() - 8)
    listContent:SetHeight(1)
    listScroll:SetScrollChild(listContent)
    classListFrame.listContent = listContent

    -- Pool of row buttons (reused)
    classListFrame.rows = {}
    classListFrame.headers = {}
    classListFrame.dividers = {}

    ----------------------------------------------------------------
    -- SCREEN 3: Character detail — pixel-perfect RequirementsPanel replica
    -- Art panel docked to the LEFT, info panel on the right, same row
    -- system (tag 50px + text), same colours, fonts, spacing.
    ----------------------------------------------------------------
    detailFrame = CreateFrame("Frame", nil, content)
    detailFrame:SetAllPoints()
    detailFrame:Hide()

    -- Art panel on the LEFT (same as RequirementsPanel)
    local artPanel = CreateFrame("Frame", nil, detailFrame, "BackdropTemplate")
    artPanel:SetWidth(DETAIL_WIDTH)
    artPanel:SetPoint("TOPLEFT", detailFrame, "TOPLEFT", 0, 0)
    artPanel:SetPoint("BOTTOMLEFT", detailFrame, "BOTTOMLEFT", 0, 36)
    if artPanel.SetBackdrop then
        artPanel:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            edgeSize = 16,
            insets   = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        artPanel:SetBackdropColor(0.06, 0.06, 0.08, 1.0)
        artPanel:SetBackdropBorderColor(1.0, 0.85, 0.45, 0.95)
    end
    local artSolidBg = artPanel:CreateTexture(nil, "BACKGROUND", nil, 0)
    artSolidBg:SetColorTexture(0.05, 0.05, 0.05, 1.0)
    artSolidBg:SetPoint("TOPLEFT", 6, -6)
    artSolidBg:SetPoint("BOTTOMRIGHT", -6, 6)
    local artTex = artPanel:CreateTexture(nil, "ARTWORK")
    artTex:SetPoint("TOPLEFT", artPanel, "TOPLEFT", 6, -6)
    artTex:SetPoint("BOTTOMRIGHT", artPanel, "BOTTOMRIGHT", -6, 6)
    artTex:SetTexCoord(0, 1, 0, 1)
    detailFrame.artPanel = artPanel
    detailFrame.artTex = artTex

    -- Right side: scrolling info panel (mirrors RequirementsPanel scroll)
    local infoScroll = CreateFrame("ScrollFrame", "HCE_CatalogDetailScroll", detailFrame, "UIPanelScrollFrameTemplate")
    infoScroll:SetPoint("TOPLEFT", artPanel, "TOPRIGHT", 8, 0)
    infoScroll:SetPoint("BOTTOMRIGHT", detailFrame, "BOTTOMRIGHT", -24, 36)

    local infoContent = CreateFrame("Frame", nil, infoScroll)
    infoContent:SetWidth(1)
    infoContent:SetHeight(1)
    infoScroll:SetScrollChild(infoContent)
    detailFrame.infoScroll = infoScroll
    detailFrame.infoContent = infoContent

    -- Row pool (frames with .tag + .text, identical to RequirementsPanel)
    detailFrame.rowPool = {}

    -- Select button (bottom-right)
    local selectBtn = CreateFrame("Button", nil, detailFrame, "UIPanelButtonTemplate")
    selectBtn:SetSize(160, 26)
    selectBtn:SetPoint("BOTTOMRIGHT", detailFrame, "BOTTOMRIGHT", -4, 4)
    selectBtn:SetText("Select This Class")
    selectBtn:SetScript("OnClick", function()
        Catalog.CommitSelection()
    end)
    detailFrame.selectBtn = selectBtn

    frame:SetScript("OnShow", function() end)
    frame:SetScript("OnHide", function() end)
end

----------------------------------------------------------------------
-- Screen 1: WoW class grid
----------------------------------------------------------------------
function Catalog.ShowScreen1()
    BuildFrame()
    currentScreen = 1
    selectedWowClass = nil
    selectedCharKey = nil

    frame.titleText:SetText("|cffffd100Enhanced Classes — Choose Your Path|r")
    frame.backBtn:Hide()

    classGridFrame:Show()
    classListFrame:Hide()
    detailFrame:Hide()

    -- Update counts on each class button
    for i, classToken in ipairs(CLASS_ORDER) do
        local btn = classGridFrame.buttons[i]
        local core, additional = getCharactersForClass(classToken)
        local total = #core + #additional
        btn.countText:SetText(total .. " enhanced class" .. (total == 1 and "" or "es"))
    end
end

----------------------------------------------------------------------
-- Screen 2: Enhanced class list for a WoW class
----------------------------------------------------------------------

local function acquireListRow(index, parent)
    local rows = classListFrame.rows
    if rows[index] then return rows[index] end

    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(LIST_ROW_H)

    if row.SetBackdrop then
        row:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        row:SetBackdropColor(0.15, 0.15, 0.17, 0.6)
        row:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.0) -- invisible by default
    end

    -- Hover
    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 0.82, 0, 0.10)

    -- Name
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", 10, -4)
    name:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    name:SetJustifyH("LEFT")
    row.nameText = name

    -- Subtext (spec + race/gender)
    local sub = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    sub:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -1)
    sub:SetPoint("RIGHT", row, "RIGHT", -10, 0)
    sub:SetJustifyH("LEFT")
    row.subText = sub

    row:SetScript("OnClick", function(self)
        if self.charKey then
            Catalog.ShowScreen3(self.charKey)
        end
    end)

    rows[index] = row
    return row
end

local function acquireHeader(index, parent)
    local headers = classListFrame.headers
    if headers[index] then return headers[index] end

    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fs:SetJustifyH("LEFT")
    headers[index] = fs
    return fs
end

local function acquireDivider(index, parent)
    local dividers = classListFrame.dividers
    if dividers[index] then return dividers[index] end

    local tex = parent:CreateTexture(nil, "ARTWORK")
    tex:SetHeight(1)
    tex:SetColorTexture(1.0, 0.82, 0.0, 0.4)
    dividers[index] = tex
    return tex
end

function Catalog.ShowScreen2(wowClass)
    BuildFrame()
    currentScreen = 2
    selectedWowClass = wowClass
    selectedCharKey = nil

    frame.titleText:SetText("|cffffd100" .. titleCase(wowClass) .. " — Enhanced Classes|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Show()
    detailFrame:Hide()

    local core, additional = getCharactersForClass(wowClass)
    local color = cc(wowClass)
    local playerRace = UnitRace("player") or ""

    classListFrame.sectionLabel:SetText("|cff" .. color .. titleCase(wowClass) .. "|r Enhanced Classes")

    -- Hide all existing rows/headers/dividers
    for _, row in pairs(classListFrame.rows) do row:Hide() end
    for _, h in pairs(classListFrame.headers) do h:Hide() end
    for _, d in pairs(classListFrame.dividers) do d:Hide() end

    local parent = classListFrame.listContent
    local contentWidth = parent:GetWidth() - 8
    local yOff = 0
    local rowIdx = 0
    local hdrIdx = 0
    local divIdx = 0

    -- Core set header
    hdrIdx = hdrIdx + 1
    local hdr = acquireHeader(hdrIdx, parent)
    hdr:ClearAllPoints()
    hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
    hdr:SetWidth(contentWidth)
    hdr:SetText("|cffffd100Core Set|r |cff888888— one unique class per talent spec|r")
    hdr:Show()
    yOff = yOff + 20

    divIdx = divIdx + 1
    local div = acquireDivider(divIdx, parent)
    div:ClearAllPoints()
    div:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
    div:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
    div:Show()
    yOff = yOff + 6

    for _, char in ipairs(core) do
        rowIdx = rowIdx + 1
        local row = acquireListRow(rowIdx, parent)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
        row:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
        row.charKey = char.name

        local displayName = HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
        local specText = CATALOG_SPEC[char.name] or char.spec
        row.nameText:SetText("|cff" .. color .. displayName .. "|r")
        row.subText:SetText(specText .. "  ·  " .. char.race .. " " .. char.gender)
        -- Gold border if race matches the player
        if row.SetBackdropBorderColor then
            if char.race == playerRace or char.race == "Any" then
                row:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
            else
                row:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.0)
            end
        end
        row:Show()
        yOff = yOff + LIST_ROW_H + 2
    end

    if #additional > 0 then
        yOff = yOff + 12

        hdrIdx = hdrIdx + 1
        local hdr2 = acquireHeader(hdrIdx, parent)
        hdr2:ClearAllPoints()
        hdr2:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
        hdr2:SetWidth(contentWidth)
        hdr2:SetText("|cffffd100Additional|r |cff888888— alternate takes on existing specs|r")
        hdr2:Show()
        yOff = yOff + 20

        divIdx = divIdx + 1
        local div2 = acquireDivider(divIdx, parent)
        div2:ClearAllPoints()
        div2:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
        div2:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
        div2:Show()
        yOff = yOff + 6

        for _, char in ipairs(additional) do
            rowIdx = rowIdx + 1
            local row = acquireListRow(rowIdx, parent)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
            row:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
            row.charKey = char.name

            local displayName = HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
            local specText = CATALOG_SPEC[char.name] or char.spec
            row.nameText:SetText("|cff" .. color .. displayName .. "|r")
            row.subText:SetText(specText .. "  ·  " .. char.race .. " " .. char.gender)
            -- Gold border if race matches the player
            if row.SetBackdropBorderColor then
                if char.race == playerRace or char.race == "Any" then
                    row:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
                else
                    row:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.0)
                end
            end
            row:Show()
            yOff = yOff + LIST_ROW_H + 2
        end
    end

    parent:SetHeight(yOff + 20)
end

----------------------------------------------------------------------
-- Screen 3: Character detail — RequirementsPanel replica
----------------------------------------------------------------------

-- Row pool: each row is a Frame with .tag (50px FontString) + .text
-- Identical structure to RequirementsPanel.acquireRow()
local function acquireCatRow(index)
    local pool = detailFrame.rowPool
    if pool[index] then return pool[index] end

    local row = CreateFrame("Frame", nil, detailFrame.infoContent)
    row:SetHeight(DETAIL_ROW_H)

    row.tag = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.tag:SetPoint("TOPLEFT", row, "TOPLEFT", 2, 0)
    row.tag:SetWidth(50)
    row.tag:SetJustifyH("LEFT")

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 2, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(true)

    pool[index] = row
    return row
end

-- Identical to RequirementsPanel.emitRow()
local function emitCatRow(index, yOffset, tagText, tagColor, text, textColor, indent)
    local row = acquireCatRow(index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", detailFrame.infoContent, "TOPLEFT", (indent or 0), -yOffset)
    row:SetPoint("RIGHT", detailFrame.infoContent, "RIGHT", 0, 0)
    if tagText then
        row.tag:Show()
        row.tag:SetText(tagText)
        row.tag:SetTextColor(tagColor.r, tagColor.g, tagColor.b)
    else
        row.tag:Hide()
        row.tag:SetText("")
    end
    row.text:SetText(text or "")
    if textColor then
        row.text:SetTextColor(textColor.r, textColor.g, textColor.b)
    else
        row.text:SetTextColor(0.93, 0.93, 0.93)
    end
    -- Reset text anchoring (section headers change it)
    row.text:ClearAllPoints()
    row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 2, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row:Show()
    local h = row.text:GetStringHeight()
    if h < DETAIL_ROW_H then h = DETAIL_ROW_H end
    row:SetHeight(h)
    return index + 1, yOffset + h + 2
end

-- Identical to RequirementsPanel.emitSectionHeader()
local function emitCatSectionHeader(index, yOffset, title)
    yOffset = yOffset + DETAIL_SEC_GAP
    local row = acquireCatRow(index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", detailFrame.infoContent, "TOPLEFT", 0, -yOffset)
    row:SetPoint("RIGHT", detailFrame.infoContent, "RIGHT", 0, 0)
    row:SetHeight(DETAIL_ROW_H)
    row.tag:Hide()
    row.text:SetText(title)
    row.text:SetTextColor(COLOR_HEADER.r, COLOR_HEADER.g, COLOR_HEADER.b)
    row.text:ClearAllPoints()
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row:Show()
    if not row.separator then
        row.separator = row:CreateTexture(nil, "ARTWORK")
        row.separator:SetColorTexture(COLOR_HEADER.r, COLOR_HEADER.g, COLOR_HEADER.b, 0.35)
        row.separator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, -2)
        row.separator:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -2)
        row.separator:SetHeight(1)
    end
    row.separator:Show()
    return index + 1, yOffset + DETAIL_ROW_H + 4
end

local function releaseExtraCatRows(lastUsed)
    local pool = detailFrame.rowPool
    for i = lastUsed + 1, #pool do
        pool[i]:Hide()
        if pool[i].separator then pool[i].separator:Hide() end
    end
end

function Catalog.ShowScreen3(charKey)
    BuildFrame()
    currentScreen = 3
    selectedCharKey = charKey

    local char = HCE.Characters and HCE.Characters[charKey]
    if not char then return end

    local color = cc(char.class)
    local displayName = HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name

    frame.titleText:SetText("|cffffd100" .. displayName .. "|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Hide()
    detailFrame:Show()

    -- Art panel (LEFT side)
    local bgPath = HCE.ClassBackgrounds and HCE.ClassBackgrounds[char.name]
    if not bgPath and HCE.GetCharDisplayName then
        bgPath = HCE.ClassBackgrounds and HCE.ClassBackgrounds[HCE.GetCharDisplayName(char)]
    end
    if bgPath then
        detailFrame.artTex:SetTexture(bgPath)
        detailFrame.artPanel:Show()
    else
        detailFrame.artPanel:Hide()
    end

    -- Set info content width to match RequirementsPanel content width
    local infoWidth = detailFrame.infoScroll:GetWidth() - 20
    if infoWidth < 100 then infoWidth = 260 end
    detailFrame.infoContent:SetWidth(infoWidth)

    -- Reset row pool state (separators, text anchors)
    for _, row in ipairs(detailFrame.rowPool) do
        if row.separator then row.separator:Hide() end
        row.text:ClearAllPoints()
        row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 2, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    end

    local index = 1
    local yOff  = 0

    -- Race / gender / self-found summary row (same as RequirementsPanel top row)
    local charSF
    if HCE.GetCharSelfFound then charSF = HCE.GetCharSelfFound(char) else charSF = char.selfFound end
    local sf = ""
    if charSF then
        sf = " \194\183 |cffaaddffself-found|r"
    elseif charSF == false then
        sf = " \194\183 |cffaaddffnot self-found|r"
    end
    index, yOff = emitCatRow(index, yOff, nil, nil,
        char.race .. " \194\183 " .. char.gender .. sf, COLOR_SUBTXT)

    -- PROFESSIONS
    if char.professions and #char.professions > 0 then
        index, yOff = emitCatSectionHeader(index, yOff, "PROFESSIONS")
        for _, profName in ipairs(char.professions) do
            local pName = type(profName) == "table" and (profName.name or "?") or tostring(profName)
            index, yOff = emitCatRow(index, yOff, "lv 5", COLOR_INACTIVE, pName)
        end
    end

    -- WEAPON PROFICIENCY
    if char.weaponProficiency and #char.weaponProficiency > 0 then
        index, yOff = emitCatSectionHeader(index, yOff, "WEAPON PROFICIENCY")
        for _, wpnEntry in ipairs(char.weaponProficiency) do
            local wpn, wpnLevel
            if type(wpnEntry) == "table" then
                wpn = wpnEntry.desc or wpnEntry.name or "?"
                wpnLevel = wpnEntry.level or 1
            else
                wpn = tostring(wpnEntry)
                wpnLevel = 1
            end
            index, yOff = emitCatRow(index, yOff, "lv " .. wpnLevel, COLOR_INACTIVE, wpn)
        end
    end

    -- CHALLENGES
    if char.challenges and #char.challenges > 0 then
        local hasVisible = false
        for _, ch in ipairs(char.challenges) do
            if not HIDE_CHALLENGE[ch.desc] then hasVisible = true; break end
        end
        if hasVisible then
            index, yOff = emitCatSectionHeader(index, yOff, "CHALLENGES")
            local easyExclude = HCE.EasyModeExclusions and HCE.EasyModeExclusions[char.name] or {}
            for _, ch in ipairs(char.challenges) do
                if not HIDE_CHALLENGE[ch.desc] then
                    local lvTag = "lv " .. ch.level
                    if ch.endLevel then
                        lvTag = "lv " .. ch.level .. "-" .. ch.endLevel
                    end
                    local label = ch.desc
                    if easyExclude[ch.desc] then
                        label = label .. " |cff888888(optional)|r"
                    end
                    index, yOff = emitCatRow(index, yOff, lvTag, COLOR_INACTIVE, label)
                    -- Challenge description (indented, dimmer)
                    local extra = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc]
                    if extra then
                        index, yOff = emitCatRow(index, yOff, nil, nil, "  " .. extra, COLOR_SUBTXT)
                        yOff = yOff + 4
                    end
                end
            end
        end
    end

    -- EQUIPMENT
    if char.equipment and #char.equipment > 0 then
        index, yOff = emitCatSectionHeader(index, yOff, "EQUIPMENT")
        for _, eq in ipairs(char.equipment) do
            local lvTag = "lv " .. eq.level
            if eq.endLevel then
                lvTag = "lv " .. eq.level .. "-" .. eq.endLevel
            end
            index, yOff = emitCatRow(index, yOff, lvTag, COLOR_INACTIVE, eq.desc)
        end
    end

    -- TALENTS
    if char.spec then
        index, yOff = emitCatSectionHeader(index, yOff, "TALENTS")
        -- Spec label
        index, yOff = emitCatRow(index, yOff, nil, nil,
            "Spec: " .. char.spec, COLOR_SUBTXT)
        -- Per-talent requirements
        local rawReqs = HCE.TalentRequirements and HCE.TalentRequirements[char.name]
        if rawReqs then
            for _, req in ipairs(rawReqs) do
                local lvTag = "lv " .. req.level
                if req.endLevel then
                    lvTag = "lv " .. req.level .. "-" .. req.endLevel
                end
                local maxRank = req.maxRank or req.rank
                local rankStr = req.rank .. "/" .. maxRank
                index, yOff = emitCatRow(index, yOff, lvTag, COLOR_INACTIVE,
                    req.name .. " (" .. rankStr .. ")")
            end
        end
    end

    -- QUESTS
    local charQuests = HCE.GetCharQuests and HCE.GetCharQuests(char) or char.quests or {}
    if #charQuests > 0 then
        index, yOff = emitCatSectionHeader(index, yOff, "QUESTS")
        local groups
        if char.questGroups then
            groups = char.questGroups
        elseif char.questTheme then
            groups = { { theme = char.questTheme, count = #charQuests } }
        else
            groups = { { theme = nil, count = #charQuests } }
        end
        local questIdx = 1
        for _, group in ipairs(groups) do
            if group.theme then
                index, yOff = emitCatRow(index, yOff, nil, nil,
                    group.theme, COLOR_SUBTXT)
            end
            for _ = 1, group.count do
                local quest = charQuests[questIdx]
                if not quest then break end
                questIdx = questIdx + 1
                index, yOff = emitCatRow(index, yOff, "lv " .. quest.level, COLOR_INACTIVE, quest.name)
            end
        end
    end

    -- MOUNTS/COMPANIONS/PETS
    local hasAnimals = char.companion or char.pet or char.mount
    if hasAnimals then
        index, yOff = emitCatSectionHeader(index, yOff, "MOUNTS/COMPANIONS/PETS")
        if char.companion then
            index, yOff = emitCatRow(index, yOff, "lv " .. char.companion.level, COLOR_INACTIVE,
                "Companion: " .. char.companion.desc)
        end
        if char.pet then
            index, yOff = emitCatRow(index, yOff, "lv " .. char.pet.level, COLOR_INACTIVE,
                "Hunter pet: " .. char.pet.desc)
        end
        if char.mount then
            index, yOff = emitCatRow(index, yOff, "lv " .. char.mount.level, COLOR_INACTIVE,
                "Mount: " .. char.mount.desc)
        end
    end

    -- RECOMMENDED PROFESSION
    if char.recommendedProfession then
        index, yOff = emitCatSectionHeader(index, yOff, "RECOMMENDED")
        index, yOff = emitCatRow(index, yOff, nil, nil,
            "Profession: " .. char.recommendedProfession.name, COLOR_TIPS)
    end

    -- GAMEPLAY
    if char.gameplay and char.gameplay ~= "" then
        index, yOff = emitCatSectionHeader(index, yOff, "GAMEPLAY")
        local tips = HCE.GameplayTips and HCE.GameplayTips.Parse and HCE.GameplayTips.Parse(char.gameplay)
        if tips and #tips > 0 then
            for _, tip in ipairs(tips) do
                index, yOff = emitCatRow(index, yOff, nil, nil, tip.title, COLOR_TIPS)
            end
        else
            index, yOff = emitCatRow(index, yOff, nil, nil, char.gameplay, COLOR_SUBTXT)
        end
    end

    releaseExtraCatRows(index - 1)
    detailFrame.infoContent:SetHeight(math.max(yOff + 10, 1))

    -- Select button label
    detailFrame.selectBtn:SetText("Select " .. displayName)
end

----------------------------------------------------------------------
-- Commit selection (same logic as SelectionUI.Commit)
----------------------------------------------------------------------
function Catalog.CommitSelection()
    if not selectedCharKey then return end
    local char = HCE.Characters and HCE.Characters[selectedCharKey]
    if not char then return end

    HCE_CharDB.selectedCharacter = char.name
    HCE_CharDB.manualOverride    = true

    HCE.Print("Selected enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. ")")

    -- Re-sync all modules
    if HCE.ResyncLevelAlerts then HCE.ResyncLevelAlerts() end
    if HCE.CompanionCheck and HCE.CompanionCheck.ResetWarnings then HCE.CompanionCheck.ResetWarnings() end
    if HCE.HunterPetCheck and HCE.HunterPetCheck.ResetWarnings then HCE.HunterPetCheck.ResetWarnings() end
    if HCE.MountCheck and HCE.MountCheck.ResetWarnings then HCE.MountCheck.ResetWarnings() end
    if HCE.ProfessionCheck and HCE.ProfessionCheck.ResetWarnings then HCE.ProfessionCheck.ResetWarnings() end
    if HCE.TalentCheck and HCE.TalentCheck.ResetWarnings then HCE.TalentCheck.ResetWarnings() end
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.ResetWarnings then HCE.SelfFoundCheck.ResetWarnings() end
    if HCE.ChallengeCheck and HCE.ChallengeCheck.ResetWarnings then HCE.ChallengeCheck.ResetWarnings() end
    if HCE.ZoneCheck and HCE.ZoneCheck.ResetTracking then HCE.ZoneCheck.ResetTracking() end
    if HCE.BehavioralCheck and HCE.BehavioralCheck.ResetTracking then HCE.BehavioralCheck.ResetTracking() end
    -- Run ALL check modules so the panel is fully up-to-date
    if HCE.ProfessionCheck and HCE.ProfessionCheck.RunCheck then HCE.ProfessionCheck.RunCheck() end
    if HCE.WeaponProficiencyCheck and HCE.WeaponProficiencyCheck.RunCheck then HCE.WeaponProficiencyCheck.RunCheck() end
    if HCE.EquipmentCheck and HCE.EquipmentCheck.RunCheck then HCE.EquipmentCheck.RunCheck() end
    if HCE.TalentCheck and HCE.TalentCheck.RunCheck then HCE.TalentCheck.RunCheck() end
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.RunCheck then HCE.SelfFoundCheck.RunCheck() end
    if HCE.ChallengeCheck and HCE.ChallengeCheck.RunCheck then HCE.ChallengeCheck.RunCheck() end
    if HCE.CompanionCheck and HCE.CompanionCheck.RunCheck then HCE.CompanionCheck.RunCheck() end
    if HCE.HunterPetCheck and HCE.HunterPetCheck.RunCheck then HCE.HunterPetCheck.RunCheck() end
    if HCE.MountCheck and HCE.MountCheck.RunCheck then HCE.MountCheck.RunCheck() end
    if HCE.QuestCheck and HCE.QuestCheck.RunCheck then HCE.QuestCheck.RunCheck() end
    if HCE.ZoneCheck and HCE.ZoneCheck.RunCheck then HCE.ZoneCheck.RunCheck() end
    if HCE.BehavioralCheck and HCE.BehavioralCheck.RunCheck then HCE.BehavioralCheck.RunCheck() end
    if HCE.RefreshPanel then HCE.RefreshPanel() end

    -- Close the catalog and show the requirements panel
    if frame then frame:Hide() end
    if HCE.ShowPanel then
        C_Timer.After(0.3, HCE.ShowPanel)
    end
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

function Catalog.Show()
    BuildFrame()
    Catalog.ShowScreen1()
    frame:Show()
end

function Catalog.Hide()
    if frame then frame:Hide() end
end

function Catalog.Toggle()
    if frame and frame:IsShown() then
        Catalog.Hide()
    else
        Catalog.Show()
    end
end

--- Open the catalog. Always starts at the 9-class grid.
function Catalog.ShowForPlayer()
    Catalog.Show()
end

-- Alias for old SelectionUI API (so existing code keeps working)
function HCE.ShowSelectionUI()
    Catalog.Show()
end

function HCE.HideSelectionUI()
    Catalog.Hide()
end

function HCE.ToggleSelectionUI()
    Catalog.Toggle()
end

-- Keep the old Catalog API names working
Catalog.Refresh = Catalog.Show
