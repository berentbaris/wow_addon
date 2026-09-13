local addonName, SM = ...
local L = SM.L

local STORYMODE_ICON_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_icon"
local STORYMODE_ICON_GLOW_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_icon_glow"
local STORYMODE_AVATAR_TEXTURE = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_avatar"
local MINIMAP_BUTTON_NAME = "StoryModeMinimapButton"
local MINIMAP_STYLE_BORDERLESS = "borderless"
local MINIMAP_STYLE_DEFAULT_BORDER = "defaultBorder"

local function GetMinimapIconStyle()
    if not StoryModeDB or StoryModeDB.minimapIconStyle ~= MINIMAP_STYLE_DEFAULT_BORDER then
        return MINIMAP_STYLE_BORDERLESS
    end
    return MINIMAP_STYLE_DEFAULT_BORDER
end

local function IsButtonGrabbed(button)
    return button and button.GetParent and button:GetParent() ~= Minimap
end

local function ToggleStoryFrame(storyFrame)
    if InCombatLockdown() then
        UIErrorsFrame:AddMessage(L["Error In Combat"], 1, 0.1, 0.1)
        return
    end

    C_Timer.After(0, function()
        if storyFrame:IsShown() then
            storyFrame:Hide()
        else
            storyFrame:Show()
        end
    end)
end

local function RegisterDataBrokerLauncher(storyFrame)
    if SM.DataBrokerObject or type(LibStub) ~= "function" then return end

    local ldb = LibStub("LibDataBroker-1.1", true)
    if not ldb or type(ldb.NewDataObject) ~= "function" then return end

    SM.DataBrokerObject = ldb:NewDataObject(addonName or "StoryMode", {
        type = "launcher",
        text = L["Addon Name"],
        label = L["Addon Name"],
        icon = STORYMODE_ICON_TEXTURE,
        OnClick = function(_, button)
            if button and button ~= "LeftButton" then return end
            ToggleStoryFrame(storyFrame)
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or type(tooltip.AddLine) ~= "function" then return end
            tooltip:AddLine(L["Minimap Tooltip Title"])
            tooltip:AddLine(L["Minimap Tooltip Open"])
        end,
    })
end

function SM.CreateMinimapButton(storyFrame, tooltip, bodyColor)
    RegisterDataBrokerLauncher(storyFrame)

    local minimapBtn = CreateFrame("Button", MINIMAP_BUTTON_NAME, Minimap)
    local borderlessButtonSize = (SM.IsRetailClient()) and 42 or 38
    local borderlessIconSize = (SM.IsRetailClient()) and 36 or 32
    local defaultButtonSize = (SM.IsRetailClient()) and 32 or 30
    local defaultIconSize = (SM.IsRetailClient()) and 25 or 22
    local defaultBorderSize = (SM.IsRetailClient()) and 50 or 53
    local defaultIconOffsetX = (SM.IsRetailClient()) and 0 or 1
    local edgeOffset = (SM.IsRetailClient()) and 8 or 5
    minimapBtn:SetSize(borderlessButtonSize, borderlessButtonSize)
    minimapBtn:SetFrameStrata("MEDIUM")
    minimapBtn:SetFrameLevel(9)
    minimapBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapBtn:SetMovable(true)
    minimapBtn:SetClampedToScreen(true)
    minimapBtn.isMinimapButton = true
    minimapBtn.isStoryModeMinimapButton = true

    local minimapIcon = minimapBtn:CreateTexture(nil, "ARTWORK", nil, 2)
    minimapIcon:SetSize(borderlessIconSize, borderlessIconSize)
    minimapIcon:SetPoint("CENTER", 0, (SM.IsRetailClient()) and 2 or 1)
    minimapIcon:SetTexture(STORYMODE_ICON_TEXTURE)
    minimapBtn.icon = minimapIcon
    minimapBtn.Icon = minimapIcon

    local minimapMask = minimapBtn:CreateMaskTexture()
    minimapMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    minimapMask:SetAllPoints(minimapIcon)
    minimapIcon:AddMaskTexture(minimapMask)

    local minimapIconGlow = minimapBtn:CreateTexture(nil, "OVERLAY", nil, 4)
    minimapIconGlow:SetTexture(STORYMODE_ICON_GLOW_TEXTURE)
    minimapIconGlow:SetTexCoord(0, 1, 0, 1)
    minimapIconGlow:Hide()

    local defaultBorder = minimapBtn:CreateTexture(nil, "OVERLAY", nil, 3)
    defaultBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    local isHoveringMinimapButton = false
    local function UpdateIconGlow()
        minimapIconGlow:SetShown(isHoveringMinimapButton and GetMinimapIconStyle() == MINIMAP_STYLE_BORDERLESS)
    end

    local function ApplyIconStyle()
        minimapIcon:ClearAllPoints()
        minimapIconGlow:ClearAllPoints()
        defaultBorder:ClearAllPoints()

        if GetMinimapIconStyle() == MINIMAP_STYLE_DEFAULT_BORDER then
            minimapBtn:SetSize(defaultButtonSize, defaultButtonSize)
            minimapIcon:SetSize(defaultIconSize, defaultIconSize)
            minimapIcon:SetPoint("CENTER", minimapBtn, "CENTER", defaultIconOffsetX, 0)
            minimapIcon:SetTexture(STORYMODE_AVATAR_TEXTURE)
            minimapIconGlow:Hide()
            defaultBorder:SetSize(defaultBorderSize, defaultBorderSize)
            defaultBorder:SetPoint("TOPLEFT", minimapBtn, "TOPLEFT", 0, 0)
            defaultBorder:Show()
        else
            minimapBtn:SetSize(borderlessButtonSize, borderlessButtonSize)
            minimapIcon:SetSize(borderlessIconSize, borderlessIconSize)
            minimapIcon:SetPoint("CENTER", minimapBtn, "CENTER", 0, (SM.IsRetailClient()) and 2 or 1)
            minimapIcon:SetTexture(STORYMODE_ICON_TEXTURE)
            minimapIconGlow:SetSize(borderlessButtonSize, borderlessButtonSize)
            minimapIconGlow:SetPoint("CENTER", minimapBtn, "CENTER", 0, (SM.IsRetailClient()) and 2 or 1)
            defaultBorder:Hide()
        end
        UpdateIconGlow()
    end

    local minimapMenuFrame
    local function SetIconStyle(style)
        if StoryModeDB then StoryModeDB.minimapIconStyle = style end
        ApplyIconStyle()
    end

    local function ShowIconStyleMenu(owner)
        tooltip:Hide()

        if MenuUtil and MenuUtil.CreateContextMenu then
            MenuUtil.CreateContextMenu(owner, function(_, rootDescription)
                rootDescription:CreateTitle(L["Minimap Icon Style"])
                rootDescription:CreateRadio(
                    L["Minimap Icon Style Borderless"],
                    function() return GetMinimapIconStyle() == MINIMAP_STYLE_BORDERLESS end,
                    function() SetIconStyle(MINIMAP_STYLE_BORDERLESS) end
                )
                rootDescription:CreateRadio(
                    L["Minimap Icon Style Default"],
                    function() return GetMinimapIconStyle() == MINIMAP_STYLE_DEFAULT_BORDER end,
                    function() SetIconStyle(MINIMAP_STYLE_DEFAULT_BORDER) end
                )
            end)
            return
        end

        if EasyMenu then
            if not minimapMenuFrame then
                minimapMenuFrame = CreateFrame("Frame", "StoryModeMinimapIconStyleMenu", UIParent, "UIDropDownMenuTemplate")
            end
            EasyMenu({
                {
                    text = L["Minimap Icon Style"],
                    isTitle = true,
                    notCheckable = true,
                },
                {
                    text = L["Minimap Icon Style Borderless"],
                    checked = function() return GetMinimapIconStyle() == MINIMAP_STYLE_BORDERLESS end,
                    func = function() SetIconStyle(MINIMAP_STYLE_BORDERLESS) end,
                },
                {
                    text = L["Minimap Icon Style Default"],
                    checked = function() return GetMinimapIconStyle() == MINIMAP_STYLE_DEFAULT_BORDER end,
                    func = function() SetIconStyle(MINIMAP_STYLE_DEFAULT_BORDER) end,
                },
            }, minimapMenuFrame, "cursor", 0, 0, "MENU")
        end
    end

    local function UpdatePosition(angle)
        if IsButtonGrabbed(minimapBtn) then return end

        local r = (Minimap:GetWidth() / 2) + edgeOffset  -- sit on the edge
        local x = math.cos(angle) * r
        local y = math.sin(angle) * r
        minimapBtn:ClearAllPoints()
        minimapBtn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    minimapBtn:RegisterForDrag("LeftButton")
    minimapBtn:SetScript("OnDragStart", function(self)
        if IsButtonGrabbed(self) then return end

        self.dragging = true
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local angle = math.atan2(cy - my, cx - mx)
            UpdatePosition(angle)
            StoryModeDB.minimapAngle = angle
        end)
    end)
    minimapBtn:SetScript("OnDragStop", function(self)
        self.dragging = false
        self:SetScript("OnUpdate", nil)
    end)

    minimapBtn:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            ShowIconStyleMenu(self)
            return
        end

        ToggleStoryFrame(storyFrame)
    end)

    minimapBtn:SetScript("OnEnter", function(self)
        isHoveringMinimapButton = true
        UpdateIconGlow()
        tooltip:SetOwner(self, "ANCHOR_LEFT")
        tooltip:ClearLines()
        tooltip:AddLine(L["Minimap Tooltip Title"])
        tooltip:AddLine(L["Minimap Tooltip Open"])
        tooltip:AddLine(L["Minimap Tooltip Settings"])
        tooltip._minW = 0
        tooltip:Show()
    end)
    minimapBtn:SetScript("OnLeave", function()
        isHoveringMinimapButton = false
        UpdateIconGlow()
        tooltip:Hide()
    end)

    minimapBtn:SetAlpha(1)

    return function()
        ApplyIconStyle()
        minimapBtn:SetAlpha(1)
        local angle = StoryModeDB and StoryModeDB.minimapAngle or 4.4  -- default: bottom
        UpdatePosition(angle)
    end
end
