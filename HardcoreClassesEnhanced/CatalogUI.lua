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
    ["Mountain King"] = "Sword & board",
    ["Brewmaster"] = "Slam spec",
    ["Demon Hunter"] = "Dual-sword ghost spec",
    ["Tinker"] = "Mace spec",
    ["Blademaster"] = "Sword spec",
    ["Brave"] = "Polearm spec",
    ["Berserker"] = "Dual-axe tank spec",
    ["Sister of Steel"] = "Arms tank spec",
    ["Warden"] = "Ambush spec",
    ["Runemaster"] = "Fist weapon spec",
    ["Pyremaster"] = "Melee-weaving firestone spec",
    ["Death Knight"] = "Soul link tank spec",
    ["Necromancer"] = "Drain life spec",
    ["Druid of the Claw"] = "Bear tank",
    ["Dragonsworn"] = "Truecaster",
    ["Savagekin"] = "Powershifting spec",
    ["Earthcaller"] = "Rockbiter tank spec",
    ["Witch Doctor"] = "Totem spec",
    ["Templar"] = "Healer/tank spec",
    ["Scarlet Champion"] = "Sword & board",
    ["Priestess of the Moon"] = "Spirit spec",
    ["Shadow Hunter"] = "Melee-weaving mind flayer",
    ["Bloodmage"] = "Pyromancer",
    ["Techno-mage"] = "Arcane missiles spec",
    ["Spellblade"] = "Aoe-grinder",
    ["Wilderness Stalker"] = "Melee trapper",
    ["Lightslayer"] = "Shadow ascendant",
    ["Hedge Wizard"] = "Self-taught",
    ["Bloodmage"] = "Pyromancer",
    ["Barbarian"] = "Mace spec",
    ["Prospector"] = "Backstab spec",
    ["Elven Ranger"] = "Lone wolf",
    ["Ley Walker"] = "Moonkin spec",
    ["Graven One"] = "Melee-weaving necromancer",
    ["Spirit Champion"] = "2-handed spec",
    ["Archmage of Kirin Tor"] = "Frostfire spec",
}

local HIDE_CHALLENGE = { ["yamama"] = true }

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
local selectedOptChallenge  -- desc string of chosen optional challenge, or nil for "None"

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

local ALLIANCE_RACES = { Human = true, Dwarf = true, ["Night Elf"] = true, Gnome = true }
local HORDE_RACES    = { Orc = true, Troll = true, Tauren = true, Undead = true }

local FACTION_CLASS = { SHAMAN = "HORDE", PALADIN = "ALLIANCE" }

local function factionColor(race, classToken)
    -- Shaman is always Horde, Paladin is always Alliance in Classic
    if classToken and FACTION_CLASS[classToken] == "HORDE" then
        return 0.70, 0.20, 0.20, 0.30
    elseif classToken and FACTION_CLASS[classToken] == "ALLIANCE" then
        return 0.20, 0.40, 0.80, 0.30
    end
    if not race or race == "Any race" or race == "" then
        return 0.85, 0.75, 0.30, 0.25   -- gold/neutral
    end
    -- Handle multi-race like "Human, Gnome"
    local allA, allH = true, true
    for token in race:gmatch("[^,]+") do
        local r = token:match("^%s*(.-)%s*$")  -- trim whitespace
        if not ALLIANCE_RACES[r] then allA = false end
        if not HORDE_RACES[r] then allH = false end
    end
    if allA and not allH then
        return 0.20, 0.40, 0.80, 0.30   -- blue/alliance
    elseif allH and not allA then
        return 0.70, 0.20, 0.20, 0.30   -- red/horde
    end
    return 0.85, 0.75, 0.30, 0.25       -- gold/neutral (mixed)
end

--- Get all characters for a given WoW class, sorted by name.
local function getCharactersForClass(wowClass)
    local chars = {}
    for key, char in pairs(HCE.Characters or {}) do
        if char.class == wowClass then
            table.insert(chars, char)
        end
    end
    table.sort(chars, function(a, b) return a.name < b.name end)
    return chars
end

----------------------------------------------------------------------
-- Frame creation (once)
----------------------------------------------------------------------
-- Sub-frames for each screen
local classGridFrame     -- Screen 1
local classListFrame     -- Screen 2
local detailFrame        -- Screen 3
local challengeFrame     -- Screen 4 (optional challenge picker)

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
        if currentScreen == 4 then
            Catalog.ShowScreen3(selectedCharKey)
        elseif currentScreen == 3 then
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
    selectBtn:SetSize(240, 26)
    selectBtn:SetPoint("BOTTOMRIGHT", detailFrame, "BOTTOMRIGHT", -4, 4)
    selectBtn:SetText("Select This Class")
    selectBtn:SetScript("OnClick", function()
        if not selectedCharKey then return end
        local ch = HCE.Characters and HCE.Characters[selectedCharKey]
        if ch and ch.optionalChallenges and #ch.optionalChallenges > 0 then
            Catalog.ShowScreen4(selectedCharKey)
        else
            selectedOptChallenge = nil
            Catalog.CommitSelection()
        end
    end)
    detailFrame.selectBtn = selectBtn

    -- Screen 4: Optional challenge picker
    challengeFrame = CreateFrame("Frame", nil, frame)
    challengeFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -40)
    challengeFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12)
    challengeFrame:Hide()

    challengeFrame.titleText = challengeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    challengeFrame.titleText:SetPoint("TOPLEFT", 100, -4)
    challengeFrame.titleText:SetJustifyH("LEFT")

    challengeFrame.subtitleText = challengeFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    challengeFrame.subtitleText:SetPoint("TOPLEFT", challengeFrame.titleText, "BOTTOMLEFT", 0, -4)
    challengeFrame.subtitleText:SetJustifyH("LEFT")

    -- Scroll frame for challenge options
    local chScroll = CreateFrame("ScrollFrame", "HCE_CatalogChallengeScroll", challengeFrame, "UIPanelScrollFrameTemplate")
    chScroll:SetPoint("TOPLEFT", challengeFrame, "TOPLEFT", 0, -50)
    chScroll:SetPoint("BOTTOMRIGHT", challengeFrame, "BOTTOMRIGHT", -24, 4)
    local chContent = CreateFrame("Frame", nil, chScroll)
    chContent:SetWidth(chScroll:GetWidth() or 400)
    chContent:SetHeight(1)
    chScroll:SetScrollChild(chContent)
    challengeFrame.scroll = chScroll
    challengeFrame.content = chContent
    challengeFrame.rows = {}

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
    selectedOptChallenge = nil

    frame.titleText:SetText("|cffffd100Enhanced Classes — Choose Your Path|r")
    frame.backBtn:Hide()

    classGridFrame:Show()
    classListFrame:Hide()
    detailFrame:Hide()
    challengeFrame:Hide()

    -- Update counts on each class button
    for i, classToken in ipairs(CLASS_ORDER) do
        local btn = classGridFrame.buttons[i]
        local chars = getCharactersForClass(classToken)
        local total = #chars
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
    selectedOptChallenge = nil

    frame.titleText:SetText("|cffffd100" .. titleCase(wowClass) .. " — Enhanced Classes|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Show()
    detailFrame:Hide()
    challengeFrame:Hide()

    local chars = getCharactersForClass(wowClass)
    local color = cc(wowClass)
    local playerRace = UnitRace("player") or ""

    classListFrame.sectionLabel:SetText("|cff" .. color .. titleCase(wowClass) .. "|r Enhanced Classes")

    -- Hide all existing rows/headers/dividers
    for _, row in pairs(classListFrame.rows) do row:Hide() end
    for _, h in pairs(classListFrame.headers) do h:Hide() end
    for _, d in pairs(classListFrame.dividers) do d:Hide() end

    local parent = classListFrame.listContent
    local yOff = 0
    local rowIdx = 0

    for _, char in ipairs(chars) do
        rowIdx = rowIdx + 1
        local row = acquireListRow(rowIdx, parent)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
        row:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
        row.charKey = char.name

        local displayName = HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
        local specText = CATALOG_SPEC[char.name] or char.spec
        local specTextMain = char.spec
        row.nameText:SetText("|cff" .. color .. displayName .. "|r")
        row.subText:SetText(specTextMain .. "  ·  " .. specText .. "  ·  " .. char.race .. "  ·  " .. char.gender)
        -- Faction-tinted background
        if row.SetBackdropColor then
            row:SetBackdropColor(factionColor(char.race, char.class))
        end
        -- Gold border if race matches the player
        if row.SetBackdropBorderColor then
            if (char.raceSet and (char.raceSet["Any race"] or char.raceSet[playerRace])) or char.race == playerRace or char.race == "Any race" then
                row:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
            else
                row:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.0)
            end
        end
        row:Show()
        yOff = yOff + LIST_ROW_H + 2
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
    challengeFrame:Hide()

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
    local allChallenges = {}
    for _, ch in ipairs(char.challenges or {}) do
        if not HIDE_CHALLENGE[ch.desc] then
            table.insert(allChallenges, ch)
        end
    end
    if char.optionalChallenges then
        for _, ch in ipairs(char.optionalChallenges) do
            if not HIDE_CHALLENGE[ch.desc] then
                table.insert(allChallenges, { desc = ch.desc, level = ch.level, endLevel = ch.endLevel, optional = true })
            end
        end
    end
    if #allChallenges > 0 then
        index, yOff = emitCatSectionHeader(index, yOff, "CHALLENGES")
        for _, ch in ipairs(allChallenges) do
            local lvTag = "lv " .. ch.level
            if ch.endLevel then
                lvTag = "lv " .. ch.level .. "-" .. ch.endLevel
            end
            local label = ch.desc
            if ch.optional then
                label = label .. " |cff888888(optional)|r"
            end
            index, yOff = emitCatRow(index, yOff, lvTag, COLOR_INACTIVE, label)
            local extra = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc]
            if extra then
                index, yOff = emitCatRow(index, yOff, nil, nil, "  " .. extra, COLOR_SUBTXT)
                yOff = yOff + 4
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
    if char.optionalChallenges and #char.optionalChallenges > 0 then
        detailFrame.selectBtn:SetText("Select " .. displayName .. " >")
    else
        detailFrame.selectBtn:SetText("Select " .. displayName)
    end
end

----------------------------------------------------------------------
-- Screen 4: Optional challenge picker
----------------------------------------------------------------------
local OPT_ROW_H = 60
local OPT_ROW_H_EXEMPT = 82  -- taller when exemption notice is shown

local EXEMPTION_CHALLENGES = {
    ["Exotic"] = true, ["Scout"] = true, ["Scavenger"] = true,
    ["Partisan"] = true, ["Self-made"] = true, ["Expeditionary"] = true,
    ["Cloth/leather"] = true, ["Leather/mail"] = true, ["Mail/plate"] = true,
    ["Cloth"] = true,
}

local function acquireChallengeRow(index, parent)
    local rows = challengeFrame.rows
    if rows[index] then return rows[index] end

    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(OPT_ROW_H)
    if row.SetBackdrop then
        row:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        row:SetBackdropColor(0.12, 0.12, 0.14, 0.8)
        row:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.6)
    end

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 0.82, 0, 0.12)

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", 12, -6)
    name:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    name:SetJustifyH("LEFT")
    row.nameText = name

    local desc = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    desc:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    desc:SetJustifyH("LEFT")
    desc:SetWordWrap(true)
    row.descText = desc

    -- Exemption notice (hidden by default, shown for forgivable challenges)
    local exempt = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    exempt:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -4)
    exempt:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    exempt:SetJustifyH("LEFT")
    exempt:SetWordWrap(true)
    exempt:Hide()
    row.exemptText = exempt

    rows[index] = row
    return row
end

function Catalog.ShowScreen4(charKey)
    BuildFrame()
    currentScreen = 4
    selectedOptChallenge = nil

    local char = HCE.Characters and HCE.Characters[charKey]
    if not char then return end

    local displayName = HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
    local color = cc(char.class)

    frame.titleText:SetText("|cffffd100" .. displayName .. " — Optional Challenge|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Hide()
    detailFrame:Hide()
    challengeFrame:Show()

    challengeFrame.titleText:SetText("|cff" .. color .. displayName .. "|r")
    challengeFrame.subtitleText:SetText("Pick an optional challenge, or choose None to skip.")

    local contentWidth = challengeFrame.scroll:GetWidth() - 20
    if contentWidth < 100 then contentWidth = 400 end
    challengeFrame.content:SetWidth(contentWidth)

    -- Hide old rows
    for _, row in pairs(challengeFrame.rows) do row:Hide() end

    local parent = challengeFrame.content
    local yOff = 4
    local idx = 0

    -- "None" option
    idx = idx + 1
    local noneRow = acquireChallengeRow(idx, parent)
    noneRow:ClearAllPoints()
    noneRow:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
    noneRow:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
    noneRow.nameText:SetText("|cffffffffNo Optional Challenge|r")
    noneRow.descText:SetText("|cff888888Play " .. displayName .. " without any additional challenge.|r")
    noneRow:SetScript("OnClick", function()
        selectedOptChallenge = nil
        Catalog.CommitSelection()
    end)
    if noneRow.SetBackdropColor then
        noneRow:SetBackdropColor(0.15, 0.15, 0.17, 0.8)
    end
    noneRow.exemptText:Hide()
    noneRow:SetHeight(OPT_ROW_H)
    noneRow:Show()
    yOff = yOff + OPT_ROW_H + 4

    -- One row per optional challenge
    for _, ch in ipairs(char.optionalChallenges or {}) do
        idx = idx + 1
        local row = acquireChallengeRow(idx, parent)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
        row:SetPoint("RIGHT", parent, "RIGHT", -4, 0)

        row.nameText:SetText("|cffffd100" .. ch.desc .. "|r")
        local extra = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc] or ""
        row.descText:SetText("|cffcccccc" .. extra .. "|r")

        -- Show exemption notice for forgivable challenges
        local isExempt = EXEMPTION_CHALLENGES[ch.desc]
        if isExempt then
            row.exemptText:SetText("|cff44dd44Rankable:|r |cffaaeeaaThis challenge can be softened by ranking up. Complete other requirements to earn exemptions.|r")
            row.exemptText:Show()
            row:SetHeight(OPT_ROW_H_EXEMPT)
        else
            row.exemptText:Hide()
            row:SetHeight(OPT_ROW_H)
        end

        local capturedDesc = ch.desc
        row:SetScript("OnClick", function()
            selectedOptChallenge = capturedDesc
            Catalog.CommitSelection()
        end)
        if row.SetBackdropColor then
            row:SetBackdropColor(0.12, 0.12, 0.14, 0.8)
        end
        row:Show()
        yOff = yOff + (isExempt and OPT_ROW_H_EXEMPT or OPT_ROW_H) + 4
    end

    parent:SetHeight(yOff + 10)
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
    HCE_CharDB.selectedChallenge = selectedOptChallenge

    local challengeMsg = ""
    if selectedOptChallenge then
        challengeMsg = " + |cffffd100" .. selectedOptChallenge .. "|r"
    end
    HCE.Print("Selected enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. ")" .. challengeMsg)

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
    if HCE.DoubtSystem and HCE.DoubtSystem.OnClassChanged then HCE.DoubtSystem.OnClassChanged() end
    -- Clear stale stored results so Progress.Collect doesn't read
    -- old data from a previous character during rank calculation
    HCE_CharDB.challengeResults   = nil
    HCE_CharDB.selfFoundResults   = nil
    HCE_CharDB.companionResults   = nil
    HCE_CharDB.hunterPetResults   = nil
    HCE_CharDB.mountResults       = nil

    -- Run ALL check modules — ChallengeCheck LAST because its rank
    -- calculation (computeOptimisticAllowed -> Progress.Collect) reads
    -- stored results from every other module.
    if HCE.ProfessionCheck and HCE.ProfessionCheck.RunCheck then HCE.ProfessionCheck.RunCheck() end
    if HCE.WeaponProficiencyCheck and HCE.WeaponProficiencyCheck.RunCheck then HCE.WeaponProficiencyCheck.RunCheck() end
    if HCE.EquipmentCheck and HCE.EquipmentCheck.RunCheck then HCE.EquipmentCheck.RunCheck() end
    if HCE.TalentCheck and HCE.TalentCheck.RunCheck then HCE.TalentCheck.RunCheck() end
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.RunCheck then HCE.SelfFoundCheck.RunCheck() end
    if HCE.CompanionCheck and HCE.CompanionCheck.RunCheck then HCE.CompanionCheck.RunCheck() end
    if HCE.HunterPetCheck and HCE.HunterPetCheck.RunCheck then HCE.HunterPetCheck.RunCheck() end
    if HCE.MountCheck and HCE.MountCheck.RunCheck then HCE.MountCheck.RunCheck() end
    if HCE.QuestCheck and HCE.QuestCheck.RunCheck then HCE.QuestCheck.RunCheck() end
    if HCE.ZoneCheck and HCE.ZoneCheck.RunCheck then HCE.ZoneCheck.RunCheck() end
    if HCE.BehavioralCheck and HCE.BehavioralCheck.RunCheck then HCE.BehavioralCheck.RunCheck() end
    -- ChallengeCheck last: rank depends on fresh results from above
    if HCE.ChallengeCheck and HCE.ChallengeCheck.RunCheck then HCE.ChallengeCheck.RunCheck() end
    if HCE.RefreshPanel then HCE.RefreshPanel() end

    -- Close the catalog and show the requirements panel
    panelWasShown = false  -- don't double-show via Catalog.Hide
    if frame then frame:Hide() end
    if HCE.ShowPanel then
        C_Timer.After(0.3, function()
            HCE.ShowPanel()
        end)
    end
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

local panelWasShown = false  -- track whether we hid the requirements panel

function Catalog.Show()
    BuildFrame()
    -- Hide requirements panel while catalog is open
    if HCE.HidePanel then
        panelWasShown = HCE.IsShownPanel and HCE.IsShownPanel() or false
        HCE.HidePanel()
    end
    Catalog.ShowScreen1()
    frame:Show()
end

function Catalog.Hide()
    if frame then frame:Hide() end
    -- Restore / open requirements panel after catalog closes
    if panelWasShown and HCE.ShowPanel then
        C_Timer.After(0.3, HCE.ShowPanel)
    end
    panelWasShown = false
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
