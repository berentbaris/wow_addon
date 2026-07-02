----------------------------------------------------------------------
-- ClassicClassesEnhanced — Integrated Class Catalog & Picker
--
-- A unified UI that combines browsing and selecting enhanced classes.
--
-- Three-screen flow:
--   Screen 1: WoW class grid (9 classes)
--   Screen 2: Enhanced classes for that WoW class (Core + Additional)
--   Screen 3: Class detail with art panel on the right + Select button
--
-- Auto-opens on login when no class is picked.
-- Also reachable via /cce catalog, /cce pick, /cce ui.
----------------------------------------------------------------------

CCE = CCE or {}

local Catalog = {}
CCE.CatalogUI = Catalog

----------------------------------------------------------------------
-- Hardcore realm detection (no API exists; maintain list manually)
----------------------------------------------------------------------
local HARDCORE_REALMS = {
    -- NA (original Aug 2023)
    ["Skull Rock"]       = true,
    ["Defias Pillager"]  = true,
    -- EU (original Aug 2023)
    ["Nek'Rosh"]         = true,
    ["Stitches"]         = true,
    -- Anniversary (Nov 2024)
    ["Doomhowl"]         = true,
    ["Soulseeker"]       = true,
    -- Add new HC realms here as Blizzard creates them
}

local function IsHardcoreRealm()
    local realm = GetRealmName and GetRealmName()
    return realm and HARDCORE_REALMS[realm] or false
end

----------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------
local FRAME_WIDTH   = 710
local FRAME_HEIGHT  = 620
local GRID_COL_W    = 280    -- width of each faction column
local GRID_GAP      = 30     -- gap between faction columns
local GRID_CELL_H   = 44
local GRID_PAD_Y    = 6
local LIST_ROW_H    = 40
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

----------------------------------------------------------------------
-- Race data for Screen 1 grid
----------------------------------------------------------------------
local RACE_ORDER = {
    "Human",     "Dwarf",    "Night Elf", "Gnome",
    "Orc",       "Troll",    "Tauren",    "Undead",
}

-- Race portrait icons (Blizzard race icon textures)
local RACE_ICONS = {
    ["Human"]     = "Interface\\Icons\\Achievement_Character_Human_Male",
    ["Dwarf"]     = "Interface\\Icons\\Achievement_Character_Dwarf_Male",
    ["Night Elf"] = "Interface\\Icons\\Achievement_Character_Nightelf_Male",
    ["Gnome"]     = "Interface\\Icons\\Achievement_Character_Gnome_Male",
    ["Orc"]       = "Interface\\Icons\\Achievement_Character_Orc_Male",
    ["Troll"]     = "Interface\\Icons\\Achievement_Character_Troll_Male",
    ["Tauren"]    = "Interface\\Icons\\Achievement_Character_Tauren_Male",
    ["Undead"]    = "Interface\\Icons\\Achievement_Character_Undead_Male",
}

-- Race display colours (faction-tinted)
local RACE_COLORS = {
    ["Human"]     = "3399ff", ["Dwarf"]     = "3399ff",
    ["Night Elf"] = "3399ff", ["Gnome"]     = "3399ff",
    ["Orc"]       = "ff4444", ["Troll"]     = "ff4444",
    ["Tauren"]    = "ff4444", ["Undead"]    = "ff4444",
}

-- WoW Classic race → valid base classes
local RACE_CLASSES = {
    ["Human"]     = { WARRIOR=true, PALADIN=true, ROGUE=true, PRIEST=true, MAGE=true, WARLOCK=true },
    ["Dwarf"]     = { WARRIOR=true, PALADIN=true, HUNTER=true, ROGUE=true, PRIEST=true },
    ["Night Elf"] = { WARRIOR=true, HUNTER=true, ROGUE=true, PRIEST=true, DRUID=true },
    ["Gnome"]     = { WARRIOR=true, ROGUE=true, MAGE=true, WARLOCK=true },
    ["Orc"]       = { WARRIOR=true, HUNTER=true, ROGUE=true, SHAMAN=true, WARLOCK=true },
    ["Troll"]     = { WARRIOR=true, HUNTER=true, ROGUE=true, PRIEST=true, SHAMAN=true, MAGE=true },
    ["Tauren"]    = { WARRIOR=true, HUNTER=true, SHAMAN=true, DRUID=true },
    ["Undead"]    = { WARRIOR=true, ROGUE=true, PRIEST=true, MAGE=true, WARLOCK=true },
}

-- Alliance races are indices 1–4, Horde are 5–8 in RACE_ORDER
local ALLIANCE_RACE_ORDER = { "Human", "Dwarf", "Night Elf", "Gnome" }
local HORDE_RACE_ORDER    = { "Orc", "Troll", "Tauren", "Undead" }

-- Catalog spec overrides (same as before, for display)
local CATALOG_SPEC = {
    ["Mountain King"] = "Sword & board",
    ["Brewmaster"] = "Slam spec",
    ["Demon Hunter"] = "Sword spec",
    ["Tinker"] = "Mace spec",
    ["Blademaster"] = "Sword spec",
    ["Brave"] = "Polearm spec",
    ["Berserker"] = "Dual-axe tank spec",
    ["Sister of Steel"] = "Arms tank spec",
    ["Warden"] = "Poison spec",
    ["Buccaneer"] = "Backstab spec",
    ["Runemaster"] = "Fist weapon spec",
    ["Pyremaster"] = "Melee-weaving firestone spec",
    ["Death Knight"] = "Soul link tank spec",
    ["Necromancer"] = "Drain life spec",
    ["Druid of the Claw"] = "Bear tank",
    ["Dragonsworn"] = "Truecaster",
    ["Savagekin"] = "Powershifting spec",
    ["Earthcaller"] = "Tank spec",
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
    ["Prospector"] = "Ambush spec",
    ["Elven Ranger"] = "Lone wolf",
    ["Ley Walker"] = "Moonkin spec",
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
local DETAIL_WIDTH   = 350

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------
local frame              -- main frame (created once)
local currentScreen = 1  -- 1=class grid, 2=class list, 3=detail
local selectedRace   -- e.g. "WARRIOR"
local selectedCharKey    -- e.g. "Mountain King"
local selectedOptChallenges = {}  -- set of desc strings currently ticked

-- Gear-based (exemptable) challenges — only one allowed at a time
local GEAR_CHALLENGES_CAT = {
    ["Exotic"] = true, ["Scout"] = true, ["Scavenger"] = true,
    ["Partisan"] = true, ["Self-made"] = true, ["Expeditionary"] = true,
    ["Cloth/leather"] = true, ["Leather/mail"] = true, ["Mail/plate"] = true,
    ["Cloth"] = true, ["Leather"] = true, ["Off-the-shelf"] = true,
}
local selectedSelfFound    -- true/false/nil — player's self-found choice (hardcore only)

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
    for key, char in pairs(CCE.Characters or {}) do
        if char.class == wowClass then
            table.insert(chars, char)
        end
    end
    table.sort(chars, function(a, b) return a.name < b.name end)
    return chars
end

--- Get all characters available for a given race, sorted by class then name.
--- Includes "Any race" characters, but only for classes the race can play.
local function getCharactersForRace(race)
    local validClasses = RACE_CLASSES[race] or {}
    local chars = {}
    for _, char in pairs(CCE.Characters or {}) do
        -- Must be a class this race can play
        if validClasses[char.class] then
            -- Must match the race (explicit or "Any race")
            if char.raceSet and (char.raceSet[race] or char.raceSet["Any race"]) then
                table.insert(chars, char)
            end
        end
    end
    table.sort(chars, function(a, b)
        if a.class ~= b.class then return a.class < b.class end
        return a.name < b.name
    end)
    return chars
end

----------------------------------------------------------------------
-- Frame creation (once)
----------------------------------------------------------------------
-- Sub-frames for each screen
local classGridFrame     -- Screen 1
local classListFrame     -- Screen 2
local detailFrame        -- Screen 3
local selfFoundFrame     -- Screen 3.5 (self-found picker, hardcore only)
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

    -- Dark panel with gold tooltip-border (StoryMode-inspired)
    if CCE.Style then
        CCE.Style.ApplyPanelBackdrop(frame)
        CCE.Style.AddInnerFill(frame)
    elseif frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets   = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        frame:SetBackdropColor(0.040, 0.035, 0.030, 0.94)
        frame:SetBackdropBorderColor(0.72, 0.56, 0.30, 0.72)
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

    if CCE.Style then
        CCE.Style.TintTitleBar(titleBar)
        CCE.Style.CreateGoldStripe(frame, titleBar, 0)
    else
        local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
        titleBg:SetColorTexture(0.85, 0.70, 0.20, 0.10)
        titleBg:SetAllPoints()
        local titleStripe = titleBar:CreateTexture(nil, "ARTWORK")
        titleStripe:SetColorTexture(0.72, 0.56, 0.30, 0.85)
        titleStripe:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 0, 0)
        titleStripe:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
        titleStripe:SetHeight(1)
    end

    frame.titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", 0, 2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Back button (hidden on screen 1)
    local backBtn
    if CCE.Style then
        backBtn = CCE.Style.CreateButton(frame, 80, 22, "< Back")
    else
        backBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        backBtn:SetText("< Back")
    end
    backBtn:SetSize(80, 22)
    backBtn:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 8, -6)
    backBtn:Hide()
    backBtn:SetScript("OnClick", function()
        if currentScreen == 4 then
            -- Go back to self-found screen if it was shown, else detail
            local ch = selectedCharKey and CCE.Characters and CCE.Characters[selectedCharKey]
            local charSF = ch and (CCE.GetCharSelfFound and CCE.GetCharSelfFound(ch) or ch.selfFound)
            if charSF and IsHardcoreRealm() then
                Catalog.ShowSelfFoundScreen(selectedCharKey)
            else
                Catalog.ShowScreen3(selectedCharKey)
            end
        elseif currentScreen == 35 then  -- self-found screen
            Catalog.ShowScreen3(selectedCharKey)
        elseif currentScreen == 3 then
            Catalog.ShowScreen2(selectedRace)
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
    -- SCREEN 1: Race Grid — Alliance (left) | Horde (right)
    ----------------------------------------------------------------
    classGridFrame = CreateFrame("Frame", nil, content)
    classGridFrame:SetAllPoints()

    local gridSubtitle = classGridFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    gridSubtitle:SetPoint("TOP", classGridFrame, "TOP", 0, 2)
    gridSubtitle:SetTextColor(0.92, 0.87, 0.76)
    gridSubtitle:SetText("Choose a race to browse enhanced classes")
    classGridFrame.subtitle = gridSubtitle

    -- Faction column labels
    local alliLabel = classGridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    alliLabel:SetPoint("TOP", classGridFrame, "TOP", -(GRID_COL_W / 2 + GRID_GAP / 2), -22)
    alliLabel:SetText("|cff4488ffAlliance|r")

    local hordeLabel = classGridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    hordeLabel:SetPoint("TOP", classGridFrame, "TOP",  (GRID_COL_W / 2 + GRID_GAP / 2), -22)
    hordeLabel:SetText("|cffff4444Horde|r")

    -- Faction dividers (gradient lines under headers)
    if CCE.Style then
        local alliDiv = classGridFrame:CreateTexture(nil, "ARTWORK")
        alliDiv:SetTexture("Interface\\Buttons\\WHITE8x8")
        alliDiv:SetHeight(1)
        alliDiv:SetPoint("TOPLEFT", classGridFrame, "TOP", -(GRID_COL_W + GRID_GAP / 2), -38)
        alliDiv:SetWidth(GRID_COL_W)
        alliDiv:SetGradient("HORIZONTAL",
            CreateColor(0.30, 0.50, 1.0, 0.0),
            CreateColor(0.30, 0.50, 1.0, 0.60))

        local hordeDiv = classGridFrame:CreateTexture(nil, "ARTWORK")
        hordeDiv:SetTexture("Interface\\Buttons\\WHITE8x8")
        hordeDiv:SetHeight(1)
        hordeDiv:SetPoint("TOPLEFT", classGridFrame, "TOP", GRID_GAP / 2, -38)
        hordeDiv:SetWidth(GRID_COL_W)
        hordeDiv:SetGradient("HORIZONTAL",
            CreateColor(1.0, 0.30, 0.30, 0.60),
            CreateColor(1.0, 0.30, 0.30, 0.0))
    end

    -- Helper: create one race button
    classGridFrame.buttons = {}
    local function createRaceBtn(raceName, idx, colX, rowY)
        local btn = CreateFrame("Button", nil, classGridFrame, "BackdropTemplate")
        btn:SetSize(GRID_COL_W, GRID_CELL_H)
        btn:SetPoint("TOPLEFT", classGridFrame, "TOP", colX, rowY)

        if CCE.Style then
            CCE.Style.ApplyCardBackdrop(btn)
        elseif btn.SetBackdrop then
            btn:SetBackdrop({
                bgFile   = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                edgeSize = 12,
                insets   = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            btn:SetBackdropColor(0.055, 0.050, 0.045, 0.85)
            btn:SetBackdropBorderColor(0.50, 0.42, 0.25, 0.55)
        end

        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(30, 30)
        icon:SetPoint("LEFT", 8, 0)
        icon:SetTexture(RACE_ICONS[raceName])
        btn.icon = icon

        local raceColor = RACE_COLORS[raceName] or "ffd100"
        local name = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("LEFT", icon, "RIGHT", 8, 5)
        name:SetText("|cff" .. raceColor .. raceName .. "|r")
        btn.nameText = name

        local count = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        count:SetPoint("LEFT", icon, "RIGHT", 8, -7)
        btn.countText = count

        local hl = btn:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(0.92, 0.82, 0.58, 0.08)

        btn.raceName = raceName
        btn:SetScript("OnClick", function()
            Catalog.ShowScreen2(raceName)
        end)
        btn:SetScript("OnShow", function(self)
            local playerRace = UnitRace and UnitRace("player") or ""
            if self.raceName == playerRace then
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.9)
                end
            else
                if self.SetBackdropBorderColor then
                    self:SetBackdropBorderColor(0.50, 0.42, 0.25, 0.55)
                end
            end
        end)

        classGridFrame.buttons[idx] = btn
        return btn
    end

    -- Alliance column (left of center)
    local startY = -44
    for i, raceName in ipairs(ALLIANCE_RACE_ORDER) do
        local colX = -(GRID_COL_W + GRID_GAP / 2)
        local rowY = startY - (i - 1) * (GRID_CELL_H + GRID_PAD_Y)
        createRaceBtn(raceName, i, colX, rowY)
    end
    -- Horde column (right of center)
    for i, raceName in ipairs(HORDE_RACE_ORDER) do
        local colX = GRID_GAP / 2
        local rowY = startY - (i - 1) * (GRID_CELL_H + GRID_PAD_Y)
        createRaceBtn(raceName, 4 + i, colX, rowY)
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
    listScroll:SetPoint("TOPLEFT", 0, -24)
    listScroll:SetPoint("BOTTOMRIGHT", 19, 0)
    classListFrame.scroll = listScroll
    if CCE.Style then CCE.Style.StyleScrollbar(listScroll) end

    local listContent = CreateFrame("Frame", nil, listScroll)
    listContent:SetWidth(FRAME_WIDTH - 36)
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
    if CCE.Style then
        CCE.Style.ApplyPanelBackdrop(artPanel)
        CCE.Style.AddInnerFill(artPanel)
    elseif artPanel.SetBackdrop then
        artPanel:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 16,
            insets   = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        artPanel:SetBackdropColor(0.040, 0.035, 0.030, 0.94)
        artPanel:SetBackdropBorderColor(0.72, 0.56, 0.30, 0.72)
    end
    local artTex = artPanel:CreateTexture(nil, "ARTWORK")
    artTex:SetPoint("TOPLEFT", artPanel, "TOPLEFT", 6, -6)
    artTex:SetPoint("BOTTOMRIGHT", artPanel, "BOTTOMRIGHT", -6, 6)
    artTex:SetTexCoord(0, 1, 0, 1)
    detailFrame.artPanel = artPanel
    detailFrame.artTex = artTex

    -- Right side: scrolling info panel (mirrors RequirementsPanel scroll)
    local infoScroll = CreateFrame("ScrollFrame", "HCE_CatalogDetailScroll", detailFrame, "UIPanelScrollFrameTemplate")
    infoScroll:SetPoint("TOPLEFT", artPanel, "TOPRIGHT", 8, 8)
    infoScroll:SetPoint("BOTTOMRIGHT", detailFrame, "BOTTOMRIGHT", 20, 36)
    if CCE.Style then CCE.Style.StyleScrollbar(infoScroll) end

    local infoContent = CreateFrame("Frame", nil, infoScroll)
    infoContent:SetWidth(1)
    infoContent:SetHeight(1)
    infoScroll:SetScrollChild(infoContent)
    detailFrame.infoScroll = infoScroll
    detailFrame.infoContent = infoContent

    -- Row pool (frames with .tag + .text, identical to RequirementsPanel)
    detailFrame.rowPool = {}

    -- Select button (bottom-right)
    local selectBtn
    if CCE.Style then
        selectBtn = CCE.Style.CreateButton(detailFrame, 240, 26, "Select This Class")
    else
        selectBtn = CreateFrame("Button", nil, detailFrame, "UIPanelButtonTemplate")
        selectBtn:SetText("Select This Class")
    end
    selectBtn:SetSize(240, 28)
    selectBtn:SetPoint("BOTTOM", detailFrame, "BOTTOM", 0, 6)
    selectBtn:SetScript("OnClick", function()
        if not selectedCharKey then return end
        Catalog.ProceedFromDetail()
    end)
    detailFrame.selectBtn = selectBtn

    -- Screen 3.5: Self-found picker (hardcore realms only)
    selfFoundFrame = CreateFrame("Frame", nil, content)
    selfFoundFrame:SetAllPoints()
    selfFoundFrame:Hide()

    selfFoundFrame.titleText = selfFoundFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    selfFoundFrame.titleText:SetPoint("TOP", selfFoundFrame, "TOP", 0, -4)
    selfFoundFrame.titleText:SetJustifyH("CENTER")

    selfFoundFrame.subtitleText = selfFoundFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    selfFoundFrame.subtitleText:SetPoint("TOP", selfFoundFrame.titleText, "BOTTOM", 0, -6)
    selfFoundFrame.subtitleText:SetJustifyH("CENTER")
    selfFoundFrame.subtitleText:SetWidth(500)
    selfFoundFrame.subtitleText:SetWordWrap(true)
    selfFoundFrame.subtitleText:SetTextColor(0.92, 0.87, 0.76)

    selfFoundFrame.rows = {}

    -- Screen 4: Optional challenge picker
    challengeFrame = CreateFrame("Frame", nil, frame)
    challengeFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -40)
    challengeFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 21, 12)
    challengeFrame:Hide()

    challengeFrame.titleText = challengeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    challengeFrame.titleText:SetPoint("TOP", challengeFrame, "TOP", 0, -4)
    challengeFrame.titleText:SetJustifyH("CENTER")

    challengeFrame.subtitleText = challengeFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    challengeFrame.subtitleText:SetPoint("TOP", challengeFrame.titleText, "BOTTOM", 0, -4)
    challengeFrame.subtitleText:SetJustifyH("CENTER")
    challengeFrame.subtitleText:SetTextColor(0.92, 0.87, 0.76)

    -- Scroll frame for challenge options
    local chScroll = CreateFrame("ScrollFrame", "HCE_CatalogChallengeScroll", challengeFrame, "UIPanelScrollFrameTemplate")
    chScroll:SetPoint("TOPLEFT", challengeFrame, "TOPLEFT", 0, -50)
    chScroll:SetPoint("BOTTOMRIGHT", challengeFrame, "BOTTOMRIGHT", -15, 4)
    if CCE.Style then CCE.Style.StyleScrollbar(chScroll) end
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
    selectedRace = nil
    selectedCharKey = nil
    selectedOptChallenges = {}
    selectedSelfFound = nil

    frame.titleText:SetText("|cffffd100Enhanced Classes — Choose Your Race|r")
    frame.backBtn:Hide()

    classGridFrame:Show()
    classListFrame:Hide()
    detailFrame:Hide()
    selfFoundFrame:Hide()
    challengeFrame:Hide()

    -- Update counts on each race button
    for i, raceName in ipairs(ALLIANCE_RACE_ORDER) do
        local btn = classGridFrame.buttons[i]
        local total = #getCharactersForRace(raceName)
        btn.countText:SetText(total .. " enhanced class" .. (total == 1 and "" or "es"))
    end
    for i, raceName in ipairs(HORDE_RACE_ORDER) do
        local btn = classGridFrame.buttons[4 + i]
        local total = #getCharactersForRace(raceName)
        btn.countText:SetText(total .. " enhanced class" .. (total == 1 and "" or "es"))
    end
end

----------------------------------------------------------------------
-- Screen 2: Enhanced class list for a WoW class
----------------------------------------------------------------------

-- Card tile dimensions for the horizontal grid
local CARD_W    = 200
local CARD_H    = 275
local CARD_ART  = 220   -- height of art portion
local CARD_GAP  = 10

local function acquireListRow(index, parent)
    local rows = classListFrame.rows
    if rows[index] then return rows[index] end

    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetSize(CARD_W, CARD_H)

    if CCE.Style then
        CCE.Style.ApplyCardBackdrop(row, { bgA = 0.85 })
    elseif row.SetBackdrop then
        row:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        row:SetBackdropColor(0.055, 0.050, 0.045, 0.85)
        row:SetBackdropBorderColor(0.50, 0.42, 0.25, 0.55)
    end

    -- Hover: brighten border
    row:SetScript("OnEnter", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(1.0, 0.82, 0.0, 0.90)
        end
    end)
    row:SetScript("OnLeave", function(self)
        if self.SetBackdropBorderColor then
            self:SetBackdropBorderColor(0.50, 0.42, 0.25, 0.55)
        end
    end)

    -- Art portrait (fills top of card, square-ish crop)
    local art = row:CreateTexture(nil, "ARTWORK")
    art:SetPoint("TOPLEFT", row, "TOPLEFT", 3, -3)
    art:SetPoint("TOPRIGHT", row, "TOPRIGHT", -3, -3)
    art:SetHeight(CARD_ART)
    art:SetTexCoord(0.05, 0.95, 0.0, 0.85) -- crop to show more of the character
    row.artTex = art

    -- Dark gradient overlay at the bottom of the art for text readability
    local artFade = row:CreateTexture(nil, "ARTWORK", nil, 1)
    artFade:SetTexture("Interface\\Buttons\\WHITE8x8")
    artFade:SetPoint("BOTTOMLEFT", art, "BOTTOMLEFT", 0, 0)
    artFade:SetPoint("BOTTOMRIGHT", art, "BOTTOMRIGHT", 0, 0)
    artFade:SetHeight(40)
    artFade:SetGradient("VERTICAL",
        CreateColor(0.03, 0.025, 0.02, 0.90),
        CreateColor(0.03, 0.025, 0.02, 0.0))

    -- Name (below art)
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("TOPLEFT", art, "BOTTOMLEFT", 4, -6)
    name:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    name:SetJustifyH("LEFT")
    row.nameText = name

    -- Subtext (spec tree)
    local sub = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
    sub:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    sub:SetJustifyH("LEFT")
    row.subText = sub

    -- Description (catalog spec hint)
    local desc = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    desc:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -1)
    desc:SetPoint("RIGHT", row, "RIGHT", -6, 0)
    desc:SetJustifyH("LEFT")
    row.descText = desc

    -- Keep classIcon ref for backwards compat (hidden, not used now)
    row.classIcon = row:CreateTexture(nil, "ARTWORK")
    row.classIcon:SetSize(1, 1)
    row.classIcon:Hide()

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
    tex:SetTexture("Interface\\Buttons\\WHITE8x8")
    tex:SetGradient("HORIZONTAL",
        CreateColor(1.0, 0.80, 0.45, 0.55),
        CreateColor(1.0, 0.80, 0.45, 0.0))
    dividers[index] = tex
    return tex
end

function Catalog.ShowScreen2(race)
    BuildFrame()
    currentScreen = 2
    selectedRace = race
    selectedCharKey = nil
    selectedOptChallenges = {}
    selectedSelfFound = nil

    local raceColor = RACE_COLORS[race] or "ffd100"
    frame.titleText:SetText("|cffffd100" .. race .. " — Enhanced Classes|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Show()
    detailFrame:Hide()
    selfFoundFrame:Hide()
    challengeFrame:Hide()

    local chars = getCharactersForRace(race)

    classListFrame.sectionLabel:SetText("|cff" .. raceColor .. race .. "|r Enhanced Classes")

    -- Hide all existing rows/headers/dividers
    for _, row in pairs(classListFrame.rows) do row:Hide() end
    for _, h in pairs(classListFrame.headers) do h:Hide() end
    for _, d in pairs(classListFrame.dividers) do d:Hide() end

    local parent = classListFrame.listContent
    local yOff = 0
    local rowIdx = 0
    local headerIdx = 0
    local divIdx = 0
    local colIdx = 0
    local lastClass = nil

    -- Horizontal card grid: 3 cards per row (192*3 + 8*2 = 592, fits in ~610px content)
    local padX = 8
    local maxCols = 3

    for _, char in ipairs(chars) do
        -- Class section header when the class changes
        if char.class ~= lastClass then
            -- Close out the previous section's last card row
            if colIdx > 0 then
                yOff = yOff + CARD_H + CARD_GAP
                colIdx = 0
            end

            lastClass = char.class
            local classColor = cc(char.class)

            -- Divider (skip for the very first section)
            if yOff > 0 then
                yOff = yOff + 4
                divIdx = divIdx + 1
                local div = acquireDivider(divIdx, parent)
                div:ClearAllPoints()
                div:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -yOff)
                div:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
                div:Show()
                yOff = yOff + 8
            end

            headerIdx = headerIdx + 1
            local hdr = acquireHeader(headerIdx, parent)
            hdr:ClearAllPoints()
            hdr:SetPoint("TOPLEFT", parent, "TOPLEFT", padX, -yOff)
            hdr:SetText("|cff" .. classColor .. titleCase(char.class) .. "|r")
            hdr:Show()
            yOff = yOff + 22
        end

        -- Calculate grid position (left-to-right flow)
        local col = colIdx % maxCols
        if col == 0 and colIdx > 0 then
            yOff = yOff + CARD_H + CARD_GAP
        end
        local xPos = padX + col * (CARD_W + CARD_GAP)

        rowIdx = rowIdx + 1
        local row = acquireListRow(rowIdx, parent)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", xPos, -yOff)
        row.charKey = char.name

        -- Set art portrait from ClassBackgrounds (fallback to class icon)
        local bgPath = CCE.ClassBackgrounds and CCE.ClassBackgrounds[char.name]
        if bgPath and row.artTex then
            row.artTex:SetTexture(bgPath)
            row.artTex:Show()
        elseif row.artTex and CLASS_ICONS[char.class] then
            row.artTex:SetTexture(CLASS_ICONS[char.class])
            row.artTex:SetTexCoord(0, 1, 0, 1)
            row.artTex:Show()
        end

        local displayName = CCE.GetCharDisplayName and CCE.GetCharDisplayName(char) or char.name
        local color = cc(char.class)
        row.nameText:SetText("|cff" .. color .. displayName .. "|r")

        -- Subtext: spec tree
        local specTextMain = char.spec or ""
        row.subText:SetText(specTextMain)

        -- Description: catalog spec hint
        local specDesc = CATALOG_SPEC[char.name]
        if row.descText then
            row.descText:SetText(specDesc and ("|cffbbbbbb" .. specDesc .. "|r") or "")
        end

        if row.SetBackdropBorderColor then
            row:SetBackdropBorderColor(0.50, 0.42, 0.25, 0.55)
        end
        row:Show()
        colIdx = colIdx + 1
    end

    -- Account for the last row of cards
    if colIdx > 0 then
        yOff = yOff + CARD_H + CARD_GAP
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

    local char = CCE.Characters and CCE.Characters[charKey]
    if not char then return end

    local color = cc(char.class)
    local displayName = CCE.GetCharDisplayName and CCE.GetCharDisplayName(char) or char.name

    frame.titleText:SetText("|cffffd100" .. displayName .. "|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Hide()
    detailFrame:Show()
    selfFoundFrame:Hide()
    challengeFrame:Hide()

    -- Art panel (LEFT side)
    local bgPath = CCE.ClassBackgrounds and CCE.ClassBackgrounds[char.name]
    if not bgPath and CCE.GetCharDisplayName then
        bgPath = CCE.ClassBackgrounds and CCE.ClassBackgrounds[CCE.GetCharDisplayName(char)]
    end
    if bgPath then
        detailFrame.artTex:SetTexture(bgPath)
        detailFrame.artPanel:Show()
    else
        detailFrame.artPanel:Hide()
    end

    -- Set info content width to match RequirementsPanel content width
    local infoWidth = detailFrame.infoScroll:GetWidth() - 40
    if infoWidth < 100 then infoWidth = 200 end
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

    -- Race / gender summary row
    index, yOff = emitCatRow(index, yOff, nil, nil,
        char.race .. " \194\183 " .. char.gender, COLOR_SUBTXT)

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
            local extra = CCE.ChallengeDescriptions and CCE.ChallengeDescriptions[ch.desc]
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
        local rawReqs = CCE.TalentRequirements and CCE.TalentRequirements[char.name]
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
    local charQuests = CCE.GetCharQuests and CCE.GetCharQuests(char) or char.quests or {}
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
        local tips = CCE.GameplayTips and CCE.GameplayTips.Parse and CCE.GameplayTips.Parse(char.gameplay)
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
-- Screen 3 → next: routing logic
----------------------------------------------------------------------

--- Determine whether to show the self-found picker, optional challenges,
--- or commit immediately after the player clicks "Select This Class".
function Catalog.ProceedFromDetail()
    if not selectedCharKey then return end
    local ch = CCE.Characters and CCE.Characters[selectedCharKey]
    if not ch then return end

    local charSF = CCE.GetCharSelfFound and CCE.GetCharSelfFound(ch) or ch.selfFound

    -- On hardcore realms, ask about self-found if the character supports it
    if charSF and IsHardcoreRealm() then
        Catalog.ShowSelfFoundScreen(selectedCharKey)
        return
    end

    -- Char doesn't support self-found → skip to challenges or commit
    selectedSelfFound = nil
    Catalog.ProceedFromSelfFound()
end

--- Continue after self-found choice (or skip) → optional challenges or commit.
function Catalog.ProceedFromSelfFound()
    if not selectedCharKey then return end
    local ch = CCE.Characters and CCE.Characters[selectedCharKey]
    if ch and ch.optionalChallenges and #ch.optionalChallenges > 0 then
        Catalog.ShowScreen4(selectedCharKey)
    else
        selectedOptChallenges = {}
        Catalog.CommitSelection()
    end
end

----------------------------------------------------------------------
-- Screen 3.5: Self-found picker (hardcore realms only)
----------------------------------------------------------------------

local SF_ROW_H = 70

local function acquireSFRow(index, parent)
    local rows = selfFoundFrame.rows
    if rows[index] then return rows[index] end

    local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
    row:SetHeight(SF_ROW_H)
    if CCE.Style then
        CCE.Style.ApplyCardBackdrop(row, { bgA = 0.80 })
    elseif row.SetBackdrop then
        row:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        row:SetBackdropColor(0.055, 0.050, 0.045, 0.80)
        row:SetBackdropBorderColor(0.50, 0.42, 0.25, 0.55)
    end

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(0.92, 0.82, 0.58, 0.08)

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("TOPLEFT", 14, -10)
    name:SetPoint("RIGHT", row, "RIGHT", -14, 0)
    name:SetJustifyH("LEFT")
    row.nameText = name

    local desc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
    desc:SetPoint("RIGHT", row, "RIGHT", -14, 0)
    desc:SetJustifyH("LEFT")
    desc:SetWordWrap(true)
    desc:SetTextColor(0.75, 0.73, 0.68)
    row.descText = desc

    rows[index] = row
    return row
end

function Catalog.ShowSelfFoundScreen(charKey)
    BuildFrame()
    currentScreen = 35  -- 3.5
    selectedSelfFound = nil

    local char = CCE.Characters and CCE.Characters[charKey]
    if not char then return end

    local displayName = CCE.GetCharDisplayName and CCE.GetCharDisplayName(char) or char.name
    local color = cc(char.class)

    frame.titleText:SetText("|cffffd100" .. displayName .. " — Self-Found|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Hide()
    detailFrame:Hide()
    selfFoundFrame:Show()
    challengeFrame:Hide()

    selfFoundFrame.titleText:SetText("|cff" .. color .. displayName .. "|r")
    selfFoundFrame.subtitleText:SetText("You are on a Hardcore realm. Will you play this character as Self-Found?")

    for _, row in pairs(selfFoundFrame.rows) do row:Hide() end

    local parent = selfFoundFrame
    local cardW = 500
    local yOff = 70

    -- "Self-Found" option
    local sfRow = acquireSFRow(1, parent)
    sfRow:ClearAllPoints()
    sfRow:SetSize(cardW, SF_ROW_H)
    sfRow:SetPoint("TOP", parent, "TOP", 0, -yOff)
    sfRow.nameText:SetText("|cffaaddffSelf-Found|r")
    sfRow.descText:SetText("No auction house, no trading. Only use items you find or craft yourself.\n|cff88cc88Recommended for immersion.|r")
    sfRow:SetScript("OnClick", function()
        selectedSelfFound = true
        Catalog.ProceedFromSelfFound()
    end)
    sfRow:Show()
    yOff = yOff + SF_ROW_H + 8

    -- "Not Self-Found" option
    local nsfRow = acquireSFRow(2, parent)
    nsfRow:ClearAllPoints()
    nsfRow:SetSize(cardW, SF_ROW_H)
    nsfRow:SetPoint("TOP", parent, "TOP", 0, -yOff)
    nsfRow.nameText:SetText("|cffffffffNot Self-Found|r")
    nsfRow.descText:SetText("Use the auction house and trade freely. The self-found buff check will be skipped.")
    nsfRow:SetScript("OnClick", function()
        selectedSelfFound = false
        Catalog.ProceedFromSelfFound()
    end)
    nsfRow:Show()
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
    if CCE.Style then
        CCE.Style.ApplyCardBackdrop(row, { bgA = 0.80 })
    elseif row.SetBackdrop then
        row:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        row:SetBackdropColor(0.06, 0.055, 0.05, 0.80)
        row:SetBackdropBorderColor(0.50, 0.42, 0.25, 0.45)
    end

    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(0.92, 0.82, 0.58, 0.08)

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    name:SetPoint("TOPLEFT", 14, -8)
    name:SetPoint("RIGHT", row, "RIGHT", -14, 0)
    name:SetJustifyH("LEFT")
    row.nameText = name

    local desc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    desc:SetPoint("RIGHT", row, "RIGHT", -14, 0)
    desc:SetJustifyH("LEFT")
    desc:SetWordWrap(true)
    desc:SetTextColor(0.75, 0.73, 0.68)
    row.descText = desc

    -- Exemption notice (hidden by default, shown for forgivable challenges)
    local exempt = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    exempt:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -4)
    exempt:SetPoint("RIGHT", row, "RIGHT", -14, 0)
    exempt:SetJustifyH("LEFT")
    exempt:SetWordWrap(true)
    exempt:SetTextColor(0.53, 0.80, 0.53)
    exempt:Hide()
    row.exemptText = exempt

    rows[index] = row
    return row
end

local function refreshScreen4Highlights()
    if not challengeFrame or not challengeFrame.rows then return end
    local anySelected = next(selectedOptChallenges) ~= nil
    local useStyle = CCE.Style and CCE.Style.SetCardPressed and CCE.Style.SetCardNormal
    for _, row in pairs(challengeFrame.rows) do
        if row:IsShown() then
            local desc = row.challengeDesc
            local isActive = false
            if desc == nil then
                isActive = not anySelected  -- "None" active when nothing selected
            elseif selectedOptChallenges[desc] then
                isActive = true
            end
            if useStyle then
                if isActive then
                    CCE.Style.SetCardPressed(row)
                else
                    CCE.Style.SetCardNormal(row)
                end
            elseif row.SetBackdropColor then
                if isActive then
                    row:SetBackdropColor(0.15, 0.42, 0.15, 0.55)
                else
                    row:SetBackdropColor(0.06, 0.055, 0.05, 0.80)
                end
            end
        end
    end
end

function Catalog.ShowScreen4(charKey)
    BuildFrame()
    currentScreen = 4
    selectedOptChallenges = {}

    local char = CCE.Characters and CCE.Characters[charKey]
    if not char then return end

    local displayName = CCE.GetCharDisplayName and CCE.GetCharDisplayName(char) or char.name
    local color = cc(char.class)

    frame.titleText:SetText("|cffffd100" .. displayName .. " — Optional Challenges|r")
    frame.backBtn:Show()

    classGridFrame:Hide()
    classListFrame:Hide()
    detailFrame:Hide()
    selfFoundFrame:Hide()
    challengeFrame:Show()

    challengeFrame.titleText:SetText("|cff" .. color .. displayName .. "|r")
    challengeFrame.subtitleText:SetText("Pick optional challenges. Only one gear-based challenge allowed.")

    local contentWidth = challengeFrame.scroll:GetWidth() - 20
    if contentWidth < 100 then contentWidth = 400 end
    challengeFrame.content:SetWidth(contentWidth)

    -- Hide old rows
    for _, row in pairs(challengeFrame.rows) do row:Hide() end

    local parent = challengeFrame.content
    local yOff = 4
    local idx = 0

    -- One row per optional challenge
    for _, ch in ipairs(char.optionalChallenges or {}) do
        idx = idx + 1
        local row = acquireChallengeRow(idx, parent)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
        row:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
        row.challengeDesc = ch.desc

        row.nameText:SetText("|cffffd100" .. ch.desc .. "|r")
        local extra = CCE.ChallengeDescriptions and CCE.ChallengeDescriptions[ch.desc] or ""
        row.descText:SetText(extra)

        -- Show exemption notice for forgivable challenges
        local isExempt = EXEMPTION_CHALLENGES[ch.desc]
        if isExempt then
            row.exemptText:SetText("Rankable: This restriction loosens as you level up and stay on top of your class requirements.")
            row.exemptText:Show()
            row:SetHeight(OPT_ROW_H_EXEMPT)
        else
            row.exemptText:Hide()
            row:SetHeight(OPT_ROW_H)
        end

        local capturedDesc = ch.desc
        row:SetScript("OnClick", function()
            if selectedOptChallenges[capturedDesc] then
                -- Untick
                selectedOptChallenges[capturedDesc] = nil
            else
                -- Tick — if gear-based, remove any other gear-based first
                if GEAR_CHALLENGES_CAT[capturedDesc] then
                    for d in pairs(selectedOptChallenges) do
                        if GEAR_CHALLENGES_CAT[d] then
                            selectedOptChallenges[d] = nil
                        end
                    end
                end
                selectedOptChallenges[capturedDesc] = true
            end
            refreshScreen4Highlights()
        end)
        row:Show()
        yOff = yOff + (isExempt and OPT_ROW_H_EXEMPT or OPT_ROW_H) + 4
    end

    -- "None" option — clears all
    idx = idx + 1
    local noneRow = acquireChallengeRow(idx, parent)
    noneRow:ClearAllPoints()
    noneRow:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, -yOff)
    noneRow:SetPoint("RIGHT", parent, "RIGHT", -4, 0)
    noneRow.challengeDesc = nil
    noneRow.nameText:SetText("|cffffffffNo Optional Challenge|r")
    noneRow.descText:SetText("Play " .. displayName .. " without any additional challenge.")
    noneRow:SetScript("OnClick", function()
        selectedOptChallenges = {}
        refreshScreen4Highlights()
    end)
    noneRow.exemptText:Hide()
    noneRow:SetHeight(OPT_ROW_H)
    noneRow:Show()
    yOff = yOff + OPT_ROW_H + 4

    -- Confirm button
    idx = idx + 1
    if not challengeFrame.confirmBtn then
        local btn
        if CCE.Style then
            btn = CCE.Style.CreateButton(challengeFrame, 140, 26, "Confirm")
        else
            btn = CreateFrame("Button", nil, challengeFrame, "UIPanelButtonTemplate")
            btn:SetSize(140, 26)
            btn:SetText("Confirm")
        end
        challengeFrame.confirmBtn = btn
    end
    challengeFrame.confirmBtn:ClearAllPoints()
    challengeFrame.confirmBtn:SetPoint("BOTTOM", challengeFrame, "BOTTOM", 0, 12)
    challengeFrame.confirmBtn:SetScript("OnClick", function()
        Catalog.CommitSelection()
    end)
    challengeFrame.confirmBtn:Show()

    parent:SetHeight(yOff + 10)
    refreshScreen4Highlights()
end

----------------------------------------------------------------------
-- Commit selection (same logic as SelectionUI.Commit)
----------------------------------------------------------------------
function Catalog.CommitSelection()
    if not selectedCharKey then return end
    local char = CCE.Characters and CCE.Characters[selectedCharKey]
    if not char then return end

    CCE_CharDB.selectedCharacter = char.name
    CCE_CharDB.manualOverride    = true
    -- Save multi-select challenges as an array
    local selArray = {}
    for desc in pairs(selectedOptChallenges) do
        selArray[#selArray + 1] = desc
    end
    CCE_CharDB.selectedChallenges = #selArray > 0 and selArray or nil
    CCE_CharDB.selectedChallenge  = nil  -- clear legacy field
    CCE_CharDB.selfFoundChoice    = selectedSelfFound  -- true/false/nil

    local challengeMsg = ""
    if #selArray > 0 then
        challengeMsg = " + |cffffd100" .. table.concat(selArray, ", ") .. "|r"
    end
    CCE.Print("Selected enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. ")" .. challengeMsg)

    -- Re-sync all modules
    if CCE.ResyncLevelAlerts then CCE.ResyncLevelAlerts() end
    if CCE.CompanionCheck and CCE.CompanionCheck.ResetWarnings then CCE.CompanionCheck.ResetWarnings() end
    if CCE.HunterPetCheck and CCE.HunterPetCheck.ResetWarnings then CCE.HunterPetCheck.ResetWarnings() end
    if CCE.MountCheck and CCE.MountCheck.ResetWarnings then CCE.MountCheck.ResetWarnings() end
    if CCE.ProfessionCheck and CCE.ProfessionCheck.ResetWarnings then CCE.ProfessionCheck.ResetWarnings() end
    if CCE.TalentCheck and CCE.TalentCheck.ResetWarnings then CCE.TalentCheck.ResetWarnings() end
    if CCE.SelfFoundCheck and CCE.SelfFoundCheck.ResetWarnings then CCE.SelfFoundCheck.ResetWarnings() end
    if CCE.ChallengeCheck and CCE.ChallengeCheck.ResetWarnings then CCE.ChallengeCheck.ResetWarnings() end
    if CCE.ZoneCheck and CCE.ZoneCheck.ResetTracking then CCE.ZoneCheck.ResetTracking() end
    if CCE.BehavioralCheck and CCE.BehavioralCheck.ResetTracking then CCE.BehavioralCheck.ResetTracking() end
    if CCE.DoubtSystem and CCE.DoubtSystem.OnClassChanged then CCE.DoubtSystem.OnClassChanged() end
    -- Clear stale stored results so Progress.Collect doesn't read
    -- old data from a previous character during rank calculation
    CCE_CharDB.challengeResults   = nil
    CCE_CharDB.selfFoundResults   = nil
    CCE_CharDB.companionResults   = nil
    CCE_CharDB.hunterPetResults   = nil
    CCE_CharDB.mountResults       = nil

    -- Run ALL check modules — ChallengeCheck LAST because its rank
    -- calculation (computeOptimisticAllowed -> Progress.Collect) reads
    -- stored results from every other module.
    if CCE.ProfessionCheck and CCE.ProfessionCheck.RunCheck then CCE.ProfessionCheck.RunCheck() end
    if CCE.WeaponProficiencyCheck and CCE.WeaponProficiencyCheck.RunCheck then CCE.WeaponProficiencyCheck.RunCheck() end
    if CCE.EquipmentCheck and CCE.EquipmentCheck.RunCheck then CCE.EquipmentCheck.RunCheck() end
    if CCE.TalentCheck and CCE.TalentCheck.RunCheck then CCE.TalentCheck.RunCheck() end
    if CCE.SelfFoundCheck and CCE.SelfFoundCheck.RunCheck then CCE.SelfFoundCheck.RunCheck() end
    if CCE.CompanionCheck and CCE.CompanionCheck.RunCheck then CCE.CompanionCheck.RunCheck() end
    if CCE.HunterPetCheck and CCE.HunterPetCheck.RunCheck then CCE.HunterPetCheck.RunCheck() end
    if CCE.MountCheck and CCE.MountCheck.RunCheck then CCE.MountCheck.RunCheck() end
    if CCE.QuestCheck and CCE.QuestCheck.RunCheck then CCE.QuestCheck.RunCheck() end
    if CCE.ZoneCheck and CCE.ZoneCheck.RunCheck then CCE.ZoneCheck.RunCheck() end
    if CCE.BehavioralCheck and CCE.BehavioralCheck.RunCheck then CCE.BehavioralCheck.RunCheck() end
    -- ChallengeCheck last: rank depends on fresh results from above
    if CCE.ChallengeCheck and CCE.ChallengeCheck.RunCheck then CCE.ChallengeCheck.RunCheck() end
    if CCE.RefreshPanel then CCE.RefreshPanel() end

    -- Close the catalog and show the requirements panel
    panelWasShown = false  -- don't double-show via Catalog.Hide
    if frame then frame:Hide() end
    if CCE.ShowPanel then
        C_Timer.After(0.3, function()
            CCE.ShowPanel()
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
    if CCE.HidePanel then
        panelWasShown = CCE.IsShownPanel and CCE.IsShownPanel() or false
        CCE.HidePanel()
    end
    Catalog.ShowScreen1()
    frame:Show()
end

function Catalog.Hide()
    if frame then frame:Hide() end
    -- Restore / open requirements panel after catalog closes
    if panelWasShown and CCE.ShowPanel then
        C_Timer.After(0.3, CCE.ShowPanel)
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
function CCE.ShowSelectionUI()
    Catalog.Show()
end

function CCE.HideSelectionUI()
    Catalog.Hide()
end

function CCE.ToggleSelectionUI()
    Catalog.Toggle()
end

-- Keep the old Catalog API names working
Catalog.Refresh = Catalog.Show
