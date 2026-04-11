----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Requirements Panel
--
-- A persistent, dockable panel that shows the selected enhanced
-- class's full requirement list, with level-gated items greyed out
-- and currently-active items lit up.
--
-- Opens via:
--   * /hce panel  (toggle)
--   * /hce req    (toggle, alias)
--   * the draggable minimap button
--
-- Auto-refreshes on PLAYER_LEVEL_UP and when the selection changes.
--
-- Layout:
--   +------------------------------------------+
--   | Mountain King               [ pin ] [X]  |
--   |  Protection Warrior · lv 14 / 60         |
--   |------------------------------------------|
--   |  3 / 7 requirements active               |
--   |------------------------------------------|
--   |  EQUIPMENT                               |
--   |  [ACTIVE] Mace or axe                    |
--   |  [lv 5]   Shield                         |
--   |  [lv 50]  Flask trinkets                 |
--   |                                          |
--   |  CHALLENGES                              |
--   |  [ACTIVE] No professions                 |
--   |  [lv 20]  Homebound                      |
--   |      Can't leave home continent          |
--   |                                          |
--   |  COMPANION · PET · MOUNT                 |
--   |  ...                                     |
--   +------------------------------------------+
----------------------------------------------------------------------

HCE = HCE or {}

local Panel = {}
HCE.Panel   = Panel

----------------------------------------------------------------------
-- Constants / visual config
----------------------------------------------------------------------

local FRAME_WIDTH   = 320
local FRAME_HEIGHT  = 440
local ROW_HEIGHT    = 16
local SECTION_GAP   = 8
local PAD_X         = 14
local PAD_Y         = 10

local COLOR_ACTIVE   = { r = 0.30, g = 0.90, b = 0.35 }
local COLOR_INACTIVE = { r = 0.55, g = 0.55, b = 0.55 }
local COLOR_HEADER   = { r = 1.00, g = 0.78, b = 0.10 }
local COLOR_SUBTXT   = { r = 0.75, g = 0.75, b = 0.75 }

local CLASS_COLORS = {
    WARRIOR = "c79c6e", ROGUE   = "fff569", MAGE    = "69ccf0",
    WARLOCK = "9482c9", PRIEST  = "ffffff", PALADIN = "f58cba",
    DRUID   = "ff7d0a", SHAMAN  = "0070de", HUNTER  = "abd473",
}

local function classColor(c)
    return CLASS_COLORS[c or ""] or "ffd100"
end

local function titleCase(s)
    if not s or s == "" then return "" end
    return s:sub(1, 1):upper() .. s:sub(2):lower()
end

----------------------------------------------------------------------
-- Global DB defaults for panel persistence
----------------------------------------------------------------------

local function db()
    HCE_GlobalDB = HCE_GlobalDB or {}
    HCE_GlobalDB.panel = HCE_GlobalDB.panel or {
        shown       = false,     -- visible on login if true
        locked      = false,     -- lock position (disables drag)
        point       = "CENTER",
        relPoint    = "CENTER",
        x           = 0,
        y           = 0,
        minimap     = { angle = 215, hide = false },
    }
    return HCE_GlobalDB.panel
end

----------------------------------------------------------------------
-- Main frame
----------------------------------------------------------------------

local frame          -- the panel itself
local contentFrame   -- child holding the row fontstrings (scroll child)
local scrollFrame
local rowPool = {}
local headerLabel, subLabel, countLabel
local pinButton
local closeButton

local function acquireRow(index)
    local row = rowPool[index]
    if row then return row end

    row = CreateFrame("Frame", nil, contentFrame)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("LEFT", contentFrame, "LEFT", 0, 0)
    row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)

    row.tag = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.tag:SetPoint("TOPLEFT", row, "TOPLEFT", 2, 0)
    row.tag:SetWidth(58)
    row.tag:SetJustifyH("LEFT")

    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 4, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetWordWrap(true)

    rowPool[index] = row
    return row
end

local function releaseExtraRows(used)
    for i = used + 1, #rowPool do
        rowPool[i]:Hide()
    end
end

----------------------------------------------------------------------
-- Row emitters
----------------------------------------------------------------------

-- returns a "tag" string and a tag color for a level-gated requirement
local function tagFor(level, playerLevel)
    if playerLevel >= level then
        return "ACTIVE", COLOR_ACTIVE
    else
        return "lv " .. level, COLOR_INACTIVE
    end
end

-- Emit a single-line row.  Returns the next row index and accumulated height used
local function emitRow(index, yOffset, tagText, tagColor, text, textColor, indent)
    local row = acquireRow(index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", (indent or 0), -yOffset)
    row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)

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

    row:Show()

    -- compute wrapped height so the next row lays out below the wrap
    local h = row.text:GetStringHeight()
    if h < ROW_HEIGHT then h = ROW_HEIGHT end
    row:SetHeight(h)

    return index + 1, yOffset + h + 2
end

local function emitSectionHeader(index, yOffset, title)
    yOffset = yOffset + SECTION_GAP
    local row = acquireRow(index)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -yOffset)
    row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)
    row:SetHeight(ROW_HEIGHT)

    row.tag:Hide()
    row.text:SetText(title)
    row.text:SetTextColor(COLOR_HEADER.r, COLOR_HEADER.g, COLOR_HEADER.b)
    row.text:ClearAllPoints()
    row.text:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    row:Show()

    local nextIdx = index + 1
    -- separator line under the header
    if not row.separator then
        row.separator = row:CreateTexture(nil, "ARTWORK")
        row.separator:SetColorTexture(COLOR_HEADER.r, COLOR_HEADER.g, COLOR_HEADER.b, 0.35)
        row.separator:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, -2)
        row.separator:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, -2)
        row.separator:SetHeight(1)
    end
    row.separator:Show()
    return nextIdx, yOffset + ROW_HEIGHT + 4
end

----------------------------------------------------------------------
-- Rebuild contents
----------------------------------------------------------------------

function Panel.Refresh()
    if not frame or not frame:IsShown() then
        -- still update the header info so the next open is correct,
        -- but we don't need to rebuild rows while hidden
    end

    -- No frame yet? Nothing to do.
    if not frame then return end

    local key = HCE_CharDB and HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    local playerLevel = UnitLevel("player") or 1
    local _, classToken = UnitClass("player")

    -- Reset row state that SectionHeader may have added
    for _, row in ipairs(rowPool) do
        if row.separator then row.separator:Hide() end
        row.text:ClearAllPoints()
        row.text:SetPoint("TOPLEFT", row.tag, "TOPRIGHT", 4, 0)
        row.text:SetPoint("RIGHT", row, "RIGHT", -2, 0)
    end

    -- Header
    if char then
        local col = classColor(char.class)
        headerLabel:SetText("|cff" .. col .. char.name .. "|r")
        subLabel:SetText(char.spec .. " " .. titleCase(char.class) .. " · lv " .. playerLevel .. " / 60")
    else
        headerLabel:SetText("|cffffd100No enhanced class selected|r")
        subLabel:SetText("Type |cffffd100/hce pick|r to choose one")
    end

    local index  = 1
    local yOff   = 0

    if not char then
        countLabel:SetText("")
        local row = acquireRow(index)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, -6)
        row:SetPoint("RIGHT", contentFrame, "RIGHT", 0, 0)
        row:SetHeight(ROW_HEIGHT * 3)
        row.tag:Hide()
        row.text:SetText("Open the selection window with |cffffd100/hce ui|r to pick an enhanced class for this character.")
        row.text:SetTextColor(COLOR_SUBTXT.r, COLOR_SUBTXT.g, COLOR_SUBTXT.b)
        row:Show()
        releaseExtraRows(1)
        contentFrame:SetHeight(ROW_HEIGHT * 3 + 12)
        return
    end

    -- Count active requirements for the summary
    local activeCount, totalCount = 0, 0
    local function count(item) if item then
        totalCount = totalCount + 1
        if playerLevel >= item.level then activeCount = activeCount + 1 end
    end end

    for _, eq in ipairs(char.equipment or {}) do count(eq) end
    for _, ch in ipairs(char.challenges or {}) do count(ch) end
    count(char.companion); count(char.pet); count(char.mount)

    countLabel:SetText(activeCount .. " / " .. totalCount .. " requirements active")

    -- Race / gender / self-found summary row
    local sf = char.selfFound and " · |cffaaddffself-found|r" or ""
    index, yOff = emitRow(index, yOff, nil, nil,
        char.race .. " · " .. char.gender .. sf, COLOR_SUBTXT)

    -- Professions
    if char.professions and #char.professions > 0 then
        index, yOff = emitRow(index, yOff, nil, nil,
            "Professions: " .. table.concat(char.professions, ", "), COLOR_SUBTXT)
    end

    -- Equipment section
    if char.equipment and #char.equipment > 0 then
        index, yOff = emitSectionHeader(index, yOff, "EQUIPMENT")
        for _, eq in ipairs(char.equipment) do
            local tag, col = tagFor(eq.level, playerLevel)
            local txtCol = (playerLevel >= eq.level) and nil or COLOR_INACTIVE
            index, yOff = emitRow(index, yOff, tag, col, eq.desc, txtCol)
        end
    end

    -- Challenges section
    if char.challenges and #char.challenges > 0 then
        index, yOff = emitSectionHeader(index, yOff, "CHALLENGES")
        for _, ch in ipairs(char.challenges) do
            local tag, col = tagFor(ch.level, playerLevel)
            local txtCol = (playerLevel >= ch.level) and nil or COLOR_INACTIVE
            index, yOff = emitRow(index, yOff, tag, col, ch.desc, txtCol)
            local extra = HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc]
            if extra then
                index, yOff = emitRow(index, yOff, nil, nil, "  " .. extra, COLOR_SUBTXT)
            end
        end
    end

    -- Companion / pet / mount
    local hasAnimals = char.companion or char.pet or char.mount
    if hasAnimals then
        index, yOff = emitSectionHeader(index, yOff, "COMPANIONS")
        if char.companion then
            local tag, col = tagFor(char.companion.level, playerLevel)
            local txtCol = (playerLevel >= char.companion.level) and nil or COLOR_INACTIVE
            index, yOff = emitRow(index, yOff, tag, col, "Companion: " .. char.companion.desc, txtCol)
        end
        if char.pet then
            local tag, col = tagFor(char.pet.level, playerLevel)
            local txtCol = (playerLevel >= char.pet.level) and nil or COLOR_INACTIVE
            index, yOff = emitRow(index, yOff, tag, col, "Hunter pet: " .. char.pet.desc, txtCol)
        end
        if char.mount then
            local tag, col = tagFor(char.mount.level, playerLevel)
            local txtCol = (playerLevel >= char.mount.level) and nil or COLOR_INACTIVE
            index, yOff = emitRow(index, yOff, tag, col, "Mount: " .. char.mount.desc, txtCol)
        end
    end

    -- Gameplay tips
    if char.gameplay and char.gameplay ~= "" then
        index, yOff = emitSectionHeader(index, yOff, "GAMEPLAY")
        index, yOff = emitRow(index, yOff, nil, nil, char.gameplay, COLOR_SUBTXT)
    end

    releaseExtraRows(index - 1)
    contentFrame:SetHeight(math.max(yOff + 10, 1))
end

----------------------------------------------------------------------
-- Build the frame
----------------------------------------------------------------------

local function BuildFrame()
    if frame then return frame end

    frame = CreateFrame("Frame", "HCE_RequirementsPanel", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetFrameStrata("MEDIUM")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)

    -- Backdrop — darker and more angular than BasicFrameTemplate so the
    -- panel reads as a sidebar, not a popup dialog.
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets   = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        frame:SetBackdropColor(0.05, 0.06, 0.08, 0.92)
        frame:SetBackdropBorderColor(0.85, 0.70, 0.20, 0.85)
    end

    -- Title bar -------------------------------------------------------
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(40)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function()
        if not db().locked then frame:StartMoving() end
    end)
    titleBar:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        local p, _, rp, x, y = frame:GetPoint()
        local s = db()
        s.point, s.relPoint, s.x, s.y = p, rp, x, y
    end)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetColorTexture(0.85, 0.70, 0.20, 0.12)
    titleBg:SetAllPoints(titleBar)

    local titleStripe = titleBar:CreateTexture(nil, "ARTWORK")
    titleStripe:SetColorTexture(0.85, 0.70, 0.20, 0.85)
    titleStripe:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    titleStripe:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    titleStripe:SetHeight(1)

    headerLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerLabel:SetPoint("TOPLEFT", titleBar, "TOPLEFT", PAD_X, -PAD_Y)
    headerLabel:SetPoint("RIGHT", titleBar, "RIGHT", -58, 0)
    headerLabel:SetJustifyH("LEFT")
    headerLabel:SetText("Hardcore Classes Enhanced")

    subLabel = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subLabel:SetPoint("TOPLEFT", headerLabel, "BOTTOMLEFT", 0, -2)
    subLabel:SetJustifyH("LEFT")
    subLabel:SetTextColor(COLOR_SUBTXT.r, COLOR_SUBTXT.g, COLOR_SUBTXT.b)
    subLabel:SetText("")

    -- Close button
    closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -4, -4)
    closeButton:SetScript("OnClick", function() Panel.Hide() end)

    -- Pin/lock button
    pinButton = CreateFrame("Button", nil, titleBar)
    pinButton:SetSize(20, 20)
    pinButton:SetPoint("RIGHT", closeButton, "LEFT", -2, 0)
    pinButton.icon = pinButton:CreateTexture(nil, "ARTWORK")
    pinButton.icon:SetAllPoints()
    pinButton.icon:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
    pinButton:SetScript("OnClick", function()
        local s = db()
        s.locked = not s.locked
        Panel.UpdatePinIcon()
    end)
    pinButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(db().locked and "Unlock panel" or "Lock panel position")
        GameTooltip:Show()
    end)
    pinButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    function Panel.UpdatePinIcon()
        if db().locked then
            pinButton.icon:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
        else
            pinButton.icon:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
        end
    end

    -- Summary bar -----------------------------------------------------
    local summary = CreateFrame("Frame", nil, frame)
    summary:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, 0)
    summary:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, 0)
    summary:SetHeight(22)

    countLabel = summary:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countLabel:SetPoint("LEFT", summary, "LEFT", PAD_X, 0)
    countLabel:SetTextColor(0.85, 0.70, 0.20)

    local summaryLine = summary:CreateTexture(nil, "ARTWORK")
    summaryLine:SetColorTexture(0.85, 0.70, 0.20, 0.25)
    summaryLine:SetPoint("BOTTOMLEFT", summary, "BOTTOMLEFT", PAD_X, 0)
    summaryLine:SetPoint("BOTTOMRIGHT", summary, "BOTTOMRIGHT", -PAD_X, 0)
    summaryLine:SetHeight(1)

    -- Scroll frame ----------------------------------------------------
    scrollFrame = CreateFrame("ScrollFrame", "HCE_RequirementsPanelScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", summary, "BOTTOMLEFT", PAD_X, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, PAD_Y)

    contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(FRAME_WIDTH - PAD_X - 34, 10)
    scrollFrame:SetScrollChild(contentFrame)

    -- Restore position
    local s = db()
    frame:ClearAllPoints()
    frame:SetPoint(s.point or "CENTER", UIParent, s.relPoint or "CENTER", s.x or 0, s.y or 0)
    Panel.UpdatePinIcon()

    frame:Hide()
    return frame
end

----------------------------------------------------------------------
-- Show / hide / toggle
----------------------------------------------------------------------

function Panel.Show()
    BuildFrame()
    frame:Show()
    db().shown = true
    Panel.Refresh()
end

function Panel.Hide()
    if frame then frame:Hide() end
    db().shown = false
end

function Panel.Toggle()
    BuildFrame()
    if frame:IsShown() then Panel.Hide() else Panel.Show() end
end

function Panel.IsShown()
    return frame and frame:IsShown()
end

-- Expose under HCE so the main file's slash command can call it
HCE.TogglePanel  = Panel.Toggle
HCE.ShowPanel    = Panel.Show
HCE.HidePanel    = Panel.Hide
HCE.RefreshPanel = Panel.Refresh

----------------------------------------------------------------------
-- Minimap button
----------------------------------------------------------------------

local minimapButton

local function UpdateMinimapPos()
    if not minimapButton then return end
    local angle = db().minimap.angle or 215
    local rad = math.rad(angle)
    local radius = 80
    local x = math.cos(rad) * radius
    local y = math.sin(rad) * radius
    minimapButton:ClearAllPoints()
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function BuildMinimapButton()
    if minimapButton then return minimapButton end

    minimapButton = CreateFrame("Button", "HCE_MinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetMovable(true)

    -- Outer ring (reuses Blizzard's minimap tracking ring texture)
    local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetSize(54, 54)
    overlay:SetPoint("TOPLEFT", 0, 0)

    -- Background circle (gives the icon a consistent fill)
    local bg = minimapButton:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(20, 20)
    bg:SetPoint("TOPLEFT", 7, -6)

    -- Custom icon drawn with plain textures — an angular gold chevron
    -- over a dark disc.  Keeps it visually distinct from stock addon
    -- buttons which are all Blizzard spell icons.
    local disc = minimapButton:CreateTexture(nil, "ARTWORK")
    disc:SetTexture("Interface\\Buttons\\WHITE8x8")
    disc:SetVertexColor(0.08, 0.08, 0.11, 1)
    disc:SetSize(18, 18)
    disc:SetPoint("TOPLEFT", 8, -7)

    local glyph = minimapButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    glyph:SetPoint("CENTER", disc, "CENTER", 0, 0)
    glyph:SetText("|cffe6b422H|r|cffffd100C|r")

    minimapButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            -- Right-click toggles the lock
            local s = db()
            s.locked = not s.locked
            Panel.UpdatePinIcon()
            HCE.Print(s.locked and "Requirements panel locked." or "Requirements panel unlocked.")
        else
            Panel.Toggle()
        end
    end)

    -- Drag-around-minimap support
    minimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            local angle = math.deg(math.atan2(py - my, px - mx))
            db().minimap.angle = angle
            UpdateMinimapPos()
        end)
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Hardcore Classes Enhanced")
        GameTooltip:AddLine("|cffffffffLeft-click|r toggle requirements panel", 1, 1, 1)
        GameTooltip:AddLine("|cffffffffRight-click|r lock/unlock panel", 1, 1, 1)
        GameTooltip:AddLine("|cffffffffDrag|r move this button", 1, 1, 1)
        GameTooltip:Show()
    end)
    minimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdateMinimapPos()
    if db().minimap.hide then minimapButton:Hide() else minimapButton:Show() end
    return minimapButton
end

function Panel.ShowMinimapButton()
    BuildMinimapButton()
    db().minimap.hide = false
    minimapButton:Show()
end

function Panel.HideMinimapButton()
    db().minimap.hide = true
    if minimapButton then minimapButton:Hide() end
end

HCE.ShowMinimapButton = Panel.ShowMinimapButton
HCE.HideMinimapButton = Panel.HideMinimapButton

----------------------------------------------------------------------
-- Event hookup (for live refresh)
----------------------------------------------------------------------

local liveFrame = CreateFrame("Frame")
liveFrame:RegisterEvent("PLAYER_LOGIN")
liveFrame:RegisterEvent("PLAYER_LEVEL_UP")
liveFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer a tick so SavedVariables + CharacterData are ready
        C_Timer.After(1.2, function()
            BuildFrame()
            BuildMinimapButton()
            if db().shown then Panel.Show() end
            Panel.Refresh()
        end)
    elseif event == "PLAYER_LEVEL_UP" then
        -- Player level isn't updated until the next frame; defer.
        C_Timer.After(0.1, Panel.Refresh)
    end
end)
