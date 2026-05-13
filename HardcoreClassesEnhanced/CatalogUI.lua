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
    local list = {}
    for key, char in pairs(HCE.Characters or {}) do
        table.insert(list, { key = key, char = char })
    end
    -- Sort by class then name
    table.sort(list, function(a, b)
        if a.char.class ~= b.char.class then
            return a.char.class < b.char.class
        end
        return a.char.name < b.char.name
    end)
    return list
end

----------------------------------------------------------------------
-- Build one character card as a block of text lines
----------------------------------------------------------------------
local function buildCard(char)
    local lines = {}

    -- Character name (header)
    local cc = CLASS_COLORS[char.class] or "|cffffffff"
    table.insert(lines, {
        text = cc .. char.name .. "|r",
        size = 13,
        isHeader = true,
    })

    -- Creation requirements
    local sfText = char.selfFound and "|cff00ff00Yes|r" or "|cffff5555No|r"
    table.insert(lines, {
        text = "|cffaaaaaaClass:|r " .. cc .. char.class:sub(1,1) .. char.class:sub(2):lower() .. "|r"
             .. "   |cffaaaaaaRace:|r " .. char.race
             .. "   |cffaaaaaaGender:|r " .. char.gender
             .. "   |cffaaaaaaSelf-found:|r " .. sfText,
    })

    -- Spec
    table.insert(lines, {
        text = "|cffaaaaaa Spec:|r " .. char.spec,
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

    -- Challenges (summary)
    if char.challenges and #char.challenges > 0 then
        local chParts = {}
        for _, ch in ipairs(char.challenges) do
            table.insert(chParts, ch.desc)
        end
        table.insert(lines, {
            text = "|cffaaaaaa Challenges:|r " .. table.concat(chParts, ", "),
        })
    end

    -- Wiki link
    local wikiURL = WIKI_BASE .. char.name:gsub(" ", "-")
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

    frame = CreateFrame("Frame", "HCE_CatalogFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(520, 500)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("DIALOG")
    frame.TitleText:SetText("Enhanced Classes — Catalog")

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "HCE_CatalogScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame.InsetBg, "TOPLEFT", 4, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame.InsetBg, "BOTTOMRIGHT", -24, 4)

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

function Catalog.Refresh()
    ensureFrame()
    hideAllFS()

    local chars = getSortedCharacters()
    local yOff = 4
    local fsIdx = 0
    local contentWidth = contentFrame:GetWidth() - 8

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
            else
                fs:SetFontObject(GameFontHighlightSmall)
            end

            fs:Show()
            local h = fs:GetStringHeight()
            if h < ROW_HEIGHT then h = ROW_HEIGHT end
            yOff = yOff + h + 1
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
            sep.sepTex:SetColorTexture(C_DIVIDER.r, C_DIVIDER.g, C_DIVIDER.b, C_DIVIDER.a)
            sep.sepTex:SetHeight(1)
        end
        sep.sepTex:ClearAllPoints()
        sep.sepTex:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 8, -yOff)
        sep.sepTex:SetPoint("RIGHT", contentFrame, "RIGHT", -8, 0)
        sep.sepTex:Show()

        yOff = yOff + CARD_PAD
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
