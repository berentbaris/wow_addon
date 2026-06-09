----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Character Catalog
--
-- Scrollable reference window showing all 27 enhanced characters with
-- their creation requirements, spec, key features, and wiki links.
-- Opened via /hce catalog (or /hce list) and the book icon on the
-- requirements panel header.
----------------------------------------------------------------------

HCE = HCE or {}

local Catalog = {}
HCE.CatalogUI = Catalog

local frame       -- main frame (created once, toggled)
local contentFrame -- inner scrollchild
local ROW_HEIGHT = 14
local CARD_PAD   = 8

-- Colours
local C_HEADER  = { r = 1.00, g = 0.82, b = 0.00 }  -- gold
local C_LABEL   = { r = 0.65, g = 0.65, b = 0.65 }  -- grey label
local C_VALUE   = { r = 0.93, g = 0.93, b = 0.93 }  -- white-ish value
local C_SUBTLE  = { r = 0.50, g = 0.50, b = 0.50 }
local C_LINK    = { r = 0.40, g = 0.73, b = 1.00 }  -- blue link
local C_DIVIDER = { r = 0.35, g = 0.35, b = 0.35, a = 0.6 }

-- WoW class colours for the class tag
local CLASS_COLORS = {
    WARRIOR = "|cffc79c6e",
    PALADIN = "|cfff58cba",
    HUNTER  = "|cffabd473",
    ROGUE   = "|cfffff569",
    PRIEST  = "|cffffffff",
    SHAMAN  = "|cff0070de",
    MAGE    = "|cff69ccf0",
    WARLOCK = "|cff9482c9",
    DRUID   = "|cffff7d0a",
}

----------------------------------------------------------------------
-- Wiki URL base — edit this to point at your wiki
----------------------------------------------------------------------
local WIKI_BASE = "https://warcraft.wiki.gg/wiki/"

----------------------------------------------------------------------
-- Build a sorted list of all characters
----------------------------------------------------------------------
local function getSortedCharacters()
    local core = {}
    local additional = {}
    local extras = HCE.AdditionalCharacters or {}
    for key, char in pairs(HCE.Characters or {}) do
        if extras[char.name] then
            table.insert(additional, { key = key, char = char })
        else
            table.insert(core, { key = key, char = char })
        end
    end
    -- Sort each list by class then name
    local function sorter(a, b)
        if a.char.class ~= b.char.class then
            return a.char.class < b.char.class
        end
        return a.char.name < b.char.name
    end
    table.sort(core, sorter)
    table.sort(additional, sorter)
    return core, additional
end

----------------------------------------------------------------------
-- Catalog spec overrides — edit these to show a different spec
-- description than what CharacterData uses for talent tracking.
----------------------------------------------------------------------
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
    ["Hedge Wizard"] = "Self-taught frostfire mage",
    ["Dark Ranger"] = "Shadow subtlety",
    ["Prospector"] = "Ambush subtlety",
    ["Elven Ranger"] = "Lone wolf survival",
    ["Dragonsworn"] = "Truecaster balance",
    ["Spirit Champion"] = "2h enhancement",
}

----------------------------------------------------------------------
-- Build one character card as a block of text lines
----------------------------------------------------------------------
local function buildCard(char)
    local lines = {}

    -- Character name (header)
    local cc = CLASS_COLORS[char.class] or "|cffffffff"
    local displayName = HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
    table.insert(lines, {
        text = cc .. displayName .. "|r",
        size = 13,
        isHeader = true,
    })

    -- Creation requirements
    local charSF
    if HCE.GetCharSelfFound then charSF = HCE.GetCharSelfFound(char) else charSF = char.selfFound end
    local sfText = charSF and "|cff00ff00Yes|r" or "|cffff5555No|r"
    table.insert(lines, {
        text = "|cffaaaaaaClass:|r " .. cc .. char.class:sub(1,1) .. char.class:sub(2):lower() .. "|r"
             .. "   |cffaaaaaaRace:|r " .. char.race
             .. "   |cffaaaaaaGender:|r " .. char.gender
             .. "   |cffaaaaaaSelf-found:|r " .. sfText,
    })

    -- Spec (use override if set, otherwise CharacterData spec)
    local specText = CATALOG_SPEC[char.name] or char.spec
    table.insert(lines, {
        text = "|cffaaaaaa Spec:|r " .. specText,
    })

    -- Professions
    if char.professions and #char.professions > 0 then
        local profStr = ""
        for pi, p in ipairs(char.professions) do
            if type(p) == "table" then
                profStr = profStr .. (p.name or "?")
            else
                profStr = profStr .. tostring(p)
            end
            if pi < #char.professions then profStr = profStr .. ", " end
        end
        table.insert(lines, {
            text = "|cffaaaaaa Professions:|r " .. profStr,
        })
    end

    -- Weapon Proficiency
    if char.weaponProficiency and #char.weaponProficiency > 0 then
        local wpNames = {}
        for _, entry in ipairs(char.weaponProficiency) do
            if type(entry) == "table" then
                table.insert(wpNames, (entry.desc or entry.name or "?"))
            else
                table.insert(wpNames, tostring(entry))
            end
        end
        table.insert(lines, {
            text = "|cffaaaaaa Weapon proficiency:|r " .. table.concat(wpNames, ", "),
        })
    end

    -- Equipment (summary) — skip stat requirements
    local STAT_PATTERN = "^%d+%s+%a"  -- matches "140 stamina", "800 armor", etc.
    local HIDE_EQ = { ["Show helm"] = true, ["Hide helm"] = true, ["Show cloak"] = true, ["Hide cloak"] = true }
    if char.equipment and #char.equipment > 0 then
        local eqParts = {}
        for _, eq in ipairs(char.equipment) do
            if not eq.desc:match(STAT_PATTERN) and not HIDE_EQ[eq.desc] then
                table.insert(eqParts, eq.desc)
            end
        end
        if #eqParts > 0 then
            table.insert(lines, {
                text = "|cffaaaaaa Equipment:|r " .. table.concat(eqParts, ", "),
            })
        end
    end

    -- Challenges (with descriptions) — hide internal/mechanical ones
    local HIDE_CHALLENGE = {
        ["Ephemeral"] = true,
    }
    if char.challenges and #char.challenges > 0 then
        local chParts = {}
        local visibleChallenges = {}
        local easyExclude = HCE.EasyModeExclusions and HCE.EasyModeExclusions[char.name] or {}
        for _, ch in ipairs(char.challenges) do
            if not HIDE_CHALLENGE[ch.desc] then
                local label = ch.desc
                if easyExclude[ch.desc] then
                    label = label .. " |cff888888(Optional)|r"
                end
                table.insert(chParts, label)
                table.insert(visibleChallenges, ch)
            end
        end
        if #chParts > 0 then
            table.insert(lines, {
                text = "|cffaaaaaa Challenges:|r " .. table.concat(chParts, ", "),
            })
            -- Individual challenge descriptions
            local descs = HCE.ChallengeDescriptions or {}
            for _, ch in ipairs(visibleChallenges) do
                local d = descs[ch.desc]
                if d and d ~= "" then
                    table.insert(lines, {
                        text = "   |cff888888" .. ch.desc .. ":|r |cffbbbbbb" .. d .. "|r",
                        isDetail = true,
                    })
                end
            end
        end
    end

    -- Quest theme
    if char.questTheme then
        table.insert(lines, {
            text = "|cffaaaaaa Quest theme:|r |cffe0c040" .. char.questTheme .. "|r",
        })
    elseif char.questGroups then
        local themes = {}
        for _, g in ipairs(char.questGroups) do
            if g.theme then table.insert(themes, g.theme) end
        end
        if #themes > 0 then
            table.insert(lines, {
                text = "|cffaaaaaa Quest themes:|r |cffe0c040" .. table.concat(themes, ", ") .. "|r",
            })
        end
    end

    -- Wiki link
    local wikiURL = WIKI_BASE .. char.name:gsub(" ", "_")
    table.insert(lines, {
        text = "|cff66bbff Wiki:|r " .. wikiURL,
    })

    return lines
end

----------------------------------------------------------------------
-- Create or refresh the catalog frame
----------------------------------------------------------------------
local function ensureFrame()
    if frame then return end

    frame = CreateFrame("Frame", "HCE_CatalogFrame", UIParent, "BackdropTemplate")
    frame:SetSize(520, 500)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")

    -- Ornate gold border (matching requirements panel)
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

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    titleText:SetText("|cffffd100Enhanced Classes — Catalog|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeBtn:SetSize(24, 24)
    closeBtn:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", 0, 2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "HCE_CatalogScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 10, -6)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

    contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetWidth(scrollFrame:GetWidth() - 8)
    contentFrame:SetHeight(1) -- will be resized
    scrollFrame:SetScrollChild(contentFrame)
end

local fontStrings = {}

local function acquireFS(index)
    if fontStrings[index] then return fontStrings[index] end
    local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fontStrings[index] = fs
    return fs
end

local function hideAllFS()
    for _, fs in ipairs(fontStrings) do
        fs:Hide()
    end
end

-- Render a list of character entries, returns updated fsIdx and yOff
local function renderCharList(chars, fsIdx, yOff, contentWidth)
    for ci, entry in ipairs(chars) do
        local card = buildCard(entry.char)

        for li, line in ipairs(card) do
            fsIdx = fsIdx + 1
            local fs = acquireFS(fsIdx)
            fs:ClearAllPoints()
            fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
            fs:SetWidth(contentWidth)
            fs:SetText(line.text)

            if line.isHeader then
                fs:SetFontObject(GameFontNormalLarge)
            elseif line.isDetail then
                fs:SetFontObject(GameFontDisableSmall)
            else
                fs:SetFontObject(GameFontHighlightSmall)
            end

            fs:Show()
            local h = fs:GetStringHeight()
            if h < ROW_HEIGHT then h = ROW_HEIGHT end
            -- Extra padding when text wraps to a second line
            local gap = (h > ROW_HEIGHT) and 4 or 2
            yOff = yOff + h + gap
        end

        -- Divider between cards
        yOff = yOff + CARD_PAD

        -- Draw a separator line
        fsIdx = fsIdx + 1
        local sep = acquireFS(fsIdx)
        sep:ClearAllPoints()
        sep:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
        sep:SetWidth(contentWidth)
        sep:SetText("")
        sep:SetFontObject(GameFontHighlightSmall)
        sep:Show()

        if not sep.sepTex then
            sep.sepTex = contentFrame:CreateTexture(nil, "ARTWORK")
            sep.sepTex:SetColorTexture(0.72, 0.55, 0.15, 0.35)
            sep.sepTex:SetHeight(1)
        end
        sep.sepTex:ClearAllPoints()
        sep.sepTex:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
        sep.sepTex:SetPoint("RIGHT", contentFrame, "RIGHT", -8, 0)
        sep.sepTex:Show()

        yOff = yOff + CARD_PAD
    end
    return fsIdx, yOff
end

-- Render a section header (gold text + thick separator)
local function renderSectionHeader(fsIdx, yOff, contentWidth, title, subtitle)
    yOff = yOff + 4

    -- Title line
    fsIdx = fsIdx + 1
    local fs = acquireFS(fsIdx)
    fs:ClearAllPoints()
    fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
    fs:SetWidth(contentWidth)
    fs:SetText("|cffffd100" .. title .. "|r")
    fs:SetFontObject(GameFontNormalLarge)
    fs:Show()
    local h = fs:GetStringHeight()
    if h < ROW_HEIGHT then h = ROW_HEIGHT end
    yOff = yOff + h + 2

    -- Subtitle line
    if subtitle then
        fsIdx = fsIdx + 1
        local sub = acquireFS(fsIdx)
        sub:ClearAllPoints()
        sub:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
        sub:SetWidth(contentWidth)
        sub:SetText("|cff888888" .. subtitle .. "|r")
        sub:SetFontObject(GameFontHighlightSmall)
        sub:Show()
        local sh = sub:GetStringHeight()
        if sh < ROW_HEIGHT then sh = ROW_HEIGHT end
        yOff = yOff + sh + 2
    end

    -- Thick gold separator
    fsIdx = fsIdx + 1
    local sep = acquireFS(fsIdx)
    sep:ClearAllPoints()
    sep:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
    sep:SetWidth(contentWidth)
    sep:SetText("")
    sep:SetFontObject(GameFontHighlightSmall)
    sep:Show()
    if not sep.sepTex then
        sep.sepTex = contentFrame:CreateTexture(nil, "ARTWORK")
        sep.sepTex:SetHeight(2)
    end
    sep.sepTex:SetColorTexture(1.0, 0.82, 0.0, 0.6)
    sep.sepTex:ClearAllPoints()
    sep.sepTex:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
    sep.sepTex:SetPoint("RIGHT", contentFrame, "RIGHT", -8, 0)
    sep.sepTex:Show()
    yOff = yOff + CARD_PAD + 4

    return fsIdx, yOff
end

function Catalog.Refresh()
    ensureFrame()
    hideAllFS()

    local core, additional = getSortedCharacters()
    local yOff = 4
    local fsIdx = 0
    local contentWidth = contentFrame:GetWidth() - 8

    -- Core Set section
    fsIdx, yOff = renderSectionHeader(fsIdx, yOff, contentWidth,
        "Core Set — " .. #core .. " Enhanced Classes",
        "One unique class per talent spec")
    fsIdx, yOff = renderCharList(core, fsIdx, yOff, contentWidth)

    -- Additional section (only if there are any)
    if #additional > 0 then
        yOff = yOff + 8
        fsIdx, yOff = renderSectionHeader(fsIdx, yOff, contentWidth,
            "Additional — " .. #additional .. " Extra Classes",
            "Alternate takes on existing specs")
        fsIdx, yOff = renderCharList(additional, fsIdx, yOff, contentWidth)
    end

    contentFrame:SetHeight(yOff + 20)
end

function Catalog.Show()
    ensureFrame()
    Catalog.Refresh()
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
