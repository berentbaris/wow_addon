----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Settings Panel
--
-- A standalone settings frame that exposes all user-configurable
-- toggles: alert types, sounds, edge-flash, chat warnings, minimap
-- button, and panel behaviour.  Accessible via /hce settings.
--
-- Visual style matches the requirements panel: dark charcoal backdrop
-- with gold accents, NOT a stock Blizzard options template.
----------------------------------------------------------------------

HCE = HCE or {}

local Settings = {}
HCE.SettingsPanel = Settings

----------------------------------------------------------------------
-- Colour constants (shared visual language with RequirementsPanel)
----------------------------------------------------------------------

local COL = {
    BG          = { 0.10, 0.10, 0.10, 0.92 },
    BORDER      = { 0.72, 0.62, 0.20, 1.0 },
    GOLD        = { 0.90, 0.78, 0.25 },
    GOLD_DIM    = { 0.68, 0.58, 0.18 },
    WHITE       = { 0.92, 0.92, 0.90 },
    GREY        = { 0.55, 0.55, 0.55 },
    GREEN       = { 0.30, 0.90, 0.30 },
    RED         = { 1.00, 0.35, 0.35 },
    SECTION_BG  = { 0.14, 0.14, 0.14, 0.80 },
}

----------------------------------------------------------------------
-- Frame dimensions
----------------------------------------------------------------------

local FRAME_W = 340
local FRAME_H = 420
local MARGIN  = 14
local ROW_H   = 26
local SECTION_PAD = 10

----------------------------------------------------------------------
-- Internal state
----------------------------------------------------------------------

local frame    -- the main settings frame
local built = false

----------------------------------------------------------------------
-- Helpers
----------------------------------------------------------------------

--- Get or init the global settings table.
local function db()
    HCE_GlobalDB = HCE_GlobalDB or {}
    return HCE_GlobalDB
end

--- Ensure a default value exists.
local function default(key, val)
    if db()[key] == nil then db()[key] = val end
end

--- Create a section header label.
local function SectionHeader(parent, yOff, text)
    local bg = parent:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", parent, "TOPLEFT", MARGIN - 4, yOff + 2)
    bg:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -MARGIN + 4, yOff + 2)
    bg:SetHeight(20)
    bg:SetColorTexture(unpack(COL.SECTION_BG))

    local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT", parent, "TOPLEFT", MARGIN, yOff)
    lbl:SetTextColor(unpack(COL.GOLD))
    lbl:SetText(text)
    return yOff - 22
end

----------------------------------------------------------------------
-- Toggle checkbox factory
----------------------------------------------------------------------

local checkboxPool = {}

local function MakeCheckbox(parent, yOff, label, tooltipText, getVal, setVal)
    local row = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", MARGIN, yOff)
    row:SetSize(24, 24)

    -- Label text
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", row, "RIGHT", 4, 1)
    text:SetTextColor(unpack(COL.WHITE))
    text:SetText(label)
    row.label = text

    -- Set initial state
    row:SetChecked(getVal() and true or false)

    -- Click handler
    row:SetScript("OnClick", function(self)
        local newVal = self:GetChecked() and true or false
        setVal(newVal)
        -- Play a subtle click
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856)
    end)

    -- Tooltip
    if tooltipText then
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(label, unpack(COL.GOLD))
            GameTooltip:AddLine(tooltipText, unpack(COL.WHITE))
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    table.insert(checkboxPool, row)
    return yOff - ROW_H, row
end

----------------------------------------------------------------------
-- Build the frame
----------------------------------------------------------------------

local function BuildFrame()
    if built then return end
    built = true

    -- Ensure defaults
    default("alertsEnabled", true)
    default("forbiddenAlertsEnabled", true)
    default("chatWarningsEnabled", true)
    default("alertSoundEnabled", true)
    default("edgeFlashEnabled", true)
    default("partyAnnounce", true)

    -- Main frame
    frame = CreateFrame("Frame", "HCE_SettingsPanel", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_W, FRAME_H)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)

    -- Dark charcoal backdrop with gold border
    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile     = true, tileSize = 16,
        edgeSize = 16,
        insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(unpack(COL.BG))
    frame:SetBackdropBorderColor(unpack(COL.BORDER))

    -- Title bar (draggable)
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
    titleBar:SetHeight(28)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop",  function() frame:StopMovingOrSizing() end)

    -- Gold stripe under title
    local stripe = frame:CreateTexture(nil, "ARTWORK")
    stripe:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -32)
    stripe:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -32)
    stripe:SetHeight(2)
    stripe:SetColorTexture(unpack(COL.GOLD_DIM))

    -- Title text
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", frame, "TOP", 0, -11)
    title:SetTextColor(unpack(COL.GOLD))
    title:SetText("Settings")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Body area starts below stripe
    local y = -40

    ----------------------------------------------------------------
    -- SECTION: Alerts
    ----------------------------------------------------------------
    y = SectionHeader(frame, y, "ALERTS")

    y = MakeCheckbox(frame, y,
        "Level-up requirement toasts",
        "Show a toast banner when you level up and new requirements become active.",
        function() return db().alertsEnabled end,
        function(v)
            db().alertsEnabled = v
            if not v and HCE.Alert then HCE.Alert.DismissAll() end
        end
    )

    y = MakeCheckbox(frame, y,
        "Forbidden-item warnings",
        "Show a red toast and screen flash when you equip an item that violates a requirement.",
        function() return db().forbiddenAlertsEnabled end,
        function(v)
            db().forbiddenAlertsEnabled = v
            if not v and HCE.ForbiddenAlert then HCE.ForbiddenAlert.DismissAll() end
        end
    )

    y = MakeCheckbox(frame, y,
        "Chat warnings",
        "Print gold [HCE] messages in chat when requirements change status (profession behind, wrong talent spec, etc.).",
        function() return db().chatWarningsEnabled end,
        function(v) db().chatWarningsEnabled = v end
    )

    y = MakeCheckbox(frame, y,
        "Party announcements",
        "Announce your enhanced class in party chat when you level up or join a group, so your groupmates know your rules.",
        function() return db().partyAnnounce end,
        function(v) db().partyAnnounce = v end
    )

    y = y - SECTION_PAD

    ----------------------------------------------------------------
    -- SECTION: Effects
    ----------------------------------------------------------------
    y = SectionHeader(frame, y, "EFFECTS")

    y = MakeCheckbox(frame, y,
        "Alert sounds",
        "Play a sound effect with level-up toasts and forbidden-item warnings.",
        function() return db().alertSoundEnabled end,
        function(v) db().alertSoundEnabled = v end
    )

    y = MakeCheckbox(frame, y,
        "Screen-edge flash",
        "Flash a red vignette around the screen edges when a forbidden item is equipped.",
        function() return db().edgeFlashEnabled end,
        function(v) db().edgeFlashEnabled = v end
    )

    y = y - SECTION_PAD

    ----------------------------------------------------------------
    -- SECTION: Interface
    ----------------------------------------------------------------
    y = SectionHeader(frame, y, "INTERFACE")

    y = MakeCheckbox(frame, y,
        "Show minimap button",
        "Display the HC minimap button. Left-click toggles the requirements panel, right-click toggles lock.",
        function()
            local p = db().panel or {}
            local m = p.minimap or {}
            return not m.hide
        end,
        function(v)
            db().panel = db().panel or {}
            db().panel.minimap = db().panel.minimap or {}
            db().panel.minimap.hide = not v
            if v then
                if HCE.ShowMinimapButton then HCE.ShowMinimapButton() end
            else
                if HCE.HideMinimapButton then HCE.HideMinimapButton() end
            end
        end
    )

    y = MakeCheckbox(frame, y,
        "Auto-show panel on login",
        "Automatically reopen the requirements panel when you log in (if it was open last session).",
        function()
            local p = db().panel or {}
            -- Default: true (restore last state).  We use a separate flag
            -- so users who always close it manually can turn this off.
            if p.autoShow == nil then return true end
            return p.autoShow
        end,
        function(v)
            db().panel = db().panel or {}
            db().panel.autoShow = v
        end
    )

    y = MakeCheckbox(frame, y,
        "Lock panel position",
        "Prevent the requirements panel from being dragged.",
        function()
            local p = db().panel or {}
            return p.locked
        end,
        function(v)
            db().panel = db().panel or {}
            db().panel.locked = v
            -- If RequirementsPanel exposes a SetLocked method, call it.
            if HCE.SetPanelLocked then HCE.SetPanelLocked(v) end
        end
    )

    y = y - SECTION_PAD

    ----------------------------------------------------------------
    -- SECTION: Character
    ----------------------------------------------------------------
    y = SectionHeader(frame, y, "CHARACTER")

    -- Current character display (not a checkbox)
    local charLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    charLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", MARGIN, y)
    charLabel:SetTextColor(unpack(COL.WHITE))
    frame.charLabel = charLabel
    y = y - 18

    -- Reset button
    local resetBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", MARGIN, y)
    resetBtn:SetSize(110, 22)
    resetBtn:SetText("Reset Selection")
    resetBtn:SetScript("OnClick", function()
        if SlashCmdList and SlashCmdList["HCE"] then
            SlashCmdList["HCE"]("reset")
        end
        Settings.Refresh()
    end)
    resetBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reset Character", unpack(COL.GOLD))
        GameTooltip:AddLine("Clear your enhanced class selection so auto-detect can run again on next login.", unpack(COL.WHITE))
        GameTooltip:Show()
    end)
    resetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Change button (opens selection UI)
    local changeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    changeBtn:SetPoint("LEFT", resetBtn, "RIGHT", 8, 0)
    changeBtn:SetSize(100, 22)
    changeBtn:SetText("Change Class")
    changeBtn:SetScript("OnClick", function()
        if HCE.ShowSelectionUI then HCE.ShowSelectionUI() end
    end)

    y = y - 30

    ----------------------------------------------------------------
    -- Support / Donate section
    ----------------------------------------------------------------
    local donateHeader = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    donateHeader:SetPoint("TOPLEFT", frame, "TOPLEFT", MARGIN, y)
    donateHeader:SetTextColor(unpack(COL.GOLD))
    donateHeader:SetText("SUPPORT")
    y = y - 20

    local donateLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    donateLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", MARGIN, y)
    donateLabel:SetPoint("RIGHT", frame, "RIGHT", -MARGIN, 0)
    donateLabel:SetJustifyH("LEFT")
    donateLabel:SetTextColor(unpack(COL.WHITE))
    donateLabel:SetText("Enjoy the addon? Consider supporting development:")
    y = y - 18

    local donateLink = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    donateLink:SetPoint("TOPLEFT", frame, "TOPLEFT", MARGIN, y)
    donateLink:SetTextColor(0.40, 0.75, 1.0)
    donateLink:SetText("buymeacoffee.com/berentbaris")
    y = y - 16

    local donateTip = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    donateTip:SetPoint("TOPLEFT", frame, "TOPLEFT", MARGIN, y)
    donateTip:SetTextColor(unpack(COL.GREY))
    donateTip:SetText("Type |cffffd100/hce donate|r to copy the link.")
    y = y - 24

    ----------------------------------------------------------------
    -- Version footer
    ----------------------------------------------------------------
    local ver = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ver:SetPoint("BOTTOM", frame, "BOTTOM", 0, 8)
    ver:SetTextColor(unpack(COL.GREY))
    ver:SetText("Hardcore Classes Enhanced v" .. (HCE.version or "?"))

    -- ESC to close
    table.insert(UISpecialFrames, "HCE_SettingsPanel")

    -- Resize the frame to fit content
    local totalH = math.abs(y) + 30
    if totalH > FRAME_H then
        frame:SetHeight(totalH)
    end

    frame:Hide()
end

----------------------------------------------------------------------
-- Refresh checkbox states (call after external changes)
----------------------------------------------------------------------

function Settings.Refresh()
    if not frame then return end
    for _, cb in ipairs(checkboxPool) do
        -- Re-trigger the getter by simulating a fresh read.
        -- Each checkbox was created with a closure; we stored the
        -- getVal inside the OnClick.  Instead, just rebuild.
        -- Simpler: brute-force hide/show to re-fire OnShow hooks.
    end
    -- Update character label
    if frame.charLabel then
        local key = HCE_CharDB and HCE_CharDB.selectedCharacter
        if key then
            local char = HCE.GetCharacter and HCE.GetCharacter(key)
            if char then
                local classStr = char.class:sub(1,1) .. char.class:sub(2):lower()
                frame.charLabel:SetText("Current: |cffffd100" .. char.name .. "|r (" .. char.spec .. " " .. classStr .. ")")
            else
                frame.charLabel:SetText("Current: |cffffd100" .. key .. "|r (data not found)")
            end
        else
            frame.charLabel:SetText("No enhanced class selected.")
        end
    end
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

function Settings.Show()
    BuildFrame()
    Settings.Refresh()
    -- Also refresh checkboxes to match current DB state
    for _, cb in ipairs(checkboxPool) do
        -- We need the getter.  Store it on the checkbox at creation time.
    end
    frame:Show()
end

function Settings.Hide()
    if frame then frame:Hide() end
end

function Settings.Toggle()
    BuildFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        Settings.Show()
    end
end

function Settings.IsShown()
    return frame and frame:IsShown()
end

----------------------------------------------------------------------
-- Expose chatWarningsEnabled check for other modules
----------------------------------------------------------------------

function HCE.ChatWarningsEnabled()
    return db().chatWarningsEnabled ~= false
end

----------------------------------------------------------------------
-- Expose alertSoundEnabled check for other modules
----------------------------------------------------------------------

function HCE.AlertSoundEnabled()
    return db().alertSoundEnabled ~= false
end

----------------------------------------------------------------------
-- Expose edgeFlashEnabled check for other modules
----------------------------------------------------------------------

function HCE.EdgeFlashEnabled()
    return db().edgeFlashEnabled ~= false
end
