-- Myregen - Mana and Energy Regen Tracker
-- Optimized for performance and clean code

local ADDON_NAME = "Myregen"
local ADDON_VERSION = "1.2"

-- Localize globals for performance
local _G = _G
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitClass = UnitClass
local UnitAffectingCombat = UnitAffectingCombat
local GetManaRegen = GetManaRegen
local GetSpellInfo = GetSpellInfo
local GetSpellPowerCost = GetSpellPowerCost
local math_floor = math.floor
local format = string.format
local unpack = unpack

-- Addon namespace
local MyRegen = {}

-- Constants
local MANA_POWER_TYPE = Enum.PowerType.Mana or 0
local ENERGY_POWER_TYPE = Enum.PowerType.Energy or 3
local REGEN_INTERVAL = 2
local FSR_DURATION = 5

local SPIRIT_COLOR = {0.0, 0.1, 0.3}  -- Dark blue for spirit regen (out of FSR)
local MP5_COLOR = {0.0, 0.7, 0.5}     -- Greenish blue for MP5 only (in FSR)
local ENERGY_COLOR = {1, 1, 0}         -- Yellow for energy

-- Default settings
local DEFAULT_SETTINGS = {
    hideInCombat = false,
    hideOutOfCombat = false,
    trackManaRegen = true,
    trackFormManaRegen = true,
    trackEnergyRegen = true,
    showEnergyOutOfCat = false,
    barWidthMana = 200,
    barHeightMana = 20,
    barWidthEnergy = 200,
    barHeightEnergy = 20,
    useAccountWide = false,
}

-- Local state
local state = {
    playerClass = nil,
    isDruid = false,
    hasMP5 = false,
    powerToken = nil,
    lastCastTime = 0,
    lastManaTickTime = 0,
    lastMana = 0,
    lastEnergyTickTime = 0,
    lastEnergy = 0,
}

-- Frame references
local frames = {
    mana = nil,
    energy = nil,
    event = nil,
    update = nil,
}

-- ============================================================================
-- Settings Management
-- ============================================================================

local function GetSettings()
    if MyRegenDB_Account and MyRegenDB_Account.useAccountWide then
        return MyRegenDB_Account
    end
    return MyRegenDB
end

local function CopyDefaults(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            dst[k] = v
        end
    end
end

local function ResetToDefaults()
    local settings = GetSettings()
    for k, v in pairs(DEFAULT_SETTINGS) do
        settings[k] = v
    end
end

-- ============================================================================
-- Slider Texture Fix
-- ============================================================================

local function FixSliderThumb(slider)
    -- Set thumb texture
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    slider:SetOrientation("HORIZONTAL")
    
    -- Create clean track background
    if not slider.track then
        slider.track = slider:CreateTexture(nil, "BACKGROUND")
        slider.track:SetTexture("Interface\\Buttons\\UI-SliderBar-Background")
        slider.track:SetAllPoints(slider)
    end
    
    -- Properly sized thumb
    local thumb = slider:GetThumbTexture()
    if thumb then
        thumb:SetSize(28, 28)
    end
end

-- ============================================================================
-- Frame Creation
-- ============================================================================

local function CreateRegenFrame(name, yOffset)
    local frame = CreateFrame("Frame", name, UIParent)
    frame:SetPoint("CENTER", 0, yOffset)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    local bar = CreateFrame("StatusBar", nil, frame)
    bar:SetAllPoints()
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill")
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    
    local text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("CENTER")
    text:SetText("0.0")
    
    frame.bar = bar
    frame.text = text
    
    return frame
end

local function InitializeFrames()
    frames.mana = CreateRegenFrame("MyRegenManaFrame", 50)
    frames.energy = CreateRegenFrame("MyRegenEnergyFrame", -50)
end

-- ============================================================================
-- Size Management
-- ============================================================================

local function UpdateFrameSize(frame, width, height)
    frame:SetSize(width, height)
end

local function UpdateManaSize()
    local settings = GetSettings()
    UpdateFrameSize(frames.mana, settings.barWidthMana, settings.barHeightMana)
end

local function UpdateEnergySize()
    local settings = GetSettings()
    UpdateFrameSize(frames.energy, settings.barWidthEnergy, settings.barHeightEnergy)
end

local function UpdateAllSizes()
    UpdateManaSize()
    UpdateEnergySize()
end

-- ============================================================================
-- MP5 and Color Management
-- ============================================================================

local function UpdateHasMP5()
    local _, castingRegen = GetManaRegen()
    state.hasMP5 = (castingRegen and castingRegen > 0)
end

local function UpdateManaBarColor()
    local currentTime = GetTime()
    local inFSR = (currentTime - state.lastCastTime < FSR_DURATION)
    
    if inFSR and state.hasMP5 then
        frames.mana.bar:SetStatusBarColor(unpack(MP5_COLOR))
    else
        frames.mana.bar:SetStatusBarColor(unpack(SPIRIT_COLOR))
    end
end

local function UpdateEnergyBarColor()
    frames.energy.bar:SetStatusBarColor(unpack(ENERGY_COLOR))
end

-- ============================================================================
-- Visibility Management
-- ============================================================================

local function ShouldShowFrame(inCombat)
    local settings = GetSettings()
    if settings.hideInCombat and inCombat then
        return false
    end
    if settings.hideOutOfCombat and not inCombat then
        return false
    end
    return true
end

local function UpdateManaVisibility()
    local settings = GetSettings()
    local inCombat = UnitAffectingCombat("player")
    if not ShouldShowFrame(inCombat) then
        frames.mana:Hide()
        return
    end
    
    local maxMana = UnitPowerMax("player", MANA_POWER_TYPE) or 0
    if maxMana <= 0 then
        frames.mana:Hide()
        return
    end
    
    local _, token = UnitPowerType("player")
    state.powerToken = token
    
    local shouldShow = false
    if token == "MANA" and settings.trackManaRegen then
        shouldShow = true
    elseif token ~= "MANA" and settings.trackFormManaRegen then
        shouldShow = true
    end
    
    if shouldShow then
        frames.mana:Show()
    else
        frames.mana:Hide()
    end
end

local function UpdateEnergyVisibility()
    local settings = GetSettings()
    local inCombat = UnitAffectingCombat("player")
    if not ShouldShowFrame(inCombat) then
        frames.energy:Hide()
        return
    end
    
    if not settings.trackEnergyRegen then
        frames.energy:Hide()
        return
    end
    
    local maxEnergy = UnitPowerMax("player", ENERGY_POWER_TYPE) or 0
    if maxEnergy <= 0 then
        frames.energy:Hide()
        return
    end
    
    local shouldShow = false
    
    if state.playerClass == "ROGUE" then
        shouldShow = true
    elseif state.isDruid then
        local _, token = UnitPowerType("player")
        if token == "ENERGY" then
            shouldShow = true
        elseif settings.showEnergyOutOfCat then
            shouldShow = true
        end
    end
    
    if shouldShow then
        frames.energy:Show()
    else
        frames.energy:Hide()
    end
end

local function UpdateVisibility()
    UpdateManaVisibility()
    UpdateEnergyVisibility()
end

-- ============================================================================
-- Update Loop
-- ============================================================================

local function OnUpdate(self, elapsed)
    local currentTime = GetTime()
    
    -- Update Mana Bar
    if frames.mana:IsShown() then
        local elapsedSinceTick = currentTime - state.lastManaTickTime
        local progress = (elapsedSinceTick % REGEN_INTERVAL) / REGEN_INTERVAL
        frames.mana.bar:SetValue(progress)
        
        local timeLeft = REGEN_INTERVAL - (elapsedSinceTick % REGEN_INTERVAL)
        frames.mana.text:SetText(format("%.1f", timeLeft))
        
        UpdateManaBarColor()
    end
    
    -- Update Energy Bar
    if frames.energy:IsShown() then
        local elapsedSinceTick = currentTime - state.lastEnergyTickTime
        local progress = (elapsedSinceTick % REGEN_INTERVAL) / REGEN_INTERVAL
        frames.energy.bar:SetValue(progress)
        
        local timeLeft = REGEN_INTERVAL - (elapsedSinceTick % REGEN_INTERVAL)
        frames.energy.text:SetText(format("%.1f", timeLeft))
        
        UpdateEnergyBarColor()
    end
end

local function InitializeUpdateFrame()
    frames.update = CreateFrame("Frame")
    frames.update:SetScript("OnUpdate", OnUpdate)
end

-- ============================================================================
-- Event Handling
-- ============================================================================

local function OnSpellCastSucceeded(unitTarget, _, spellID)
    if unitTarget ~= "player" then return end
    
    local spellName = GetSpellInfo(spellID)
    if not spellName then return end
    
    local costTable = GetSpellPowerCost(spellName)
    if not costTable then return end
    
    for _, costInfo in ipairs(costTable) do
        if costInfo.type == MANA_POWER_TYPE then
            if costInfo.cost > 0 then
                state.lastCastTime = GetTime()
            end
            break
        end
    end
end

local function OnPowerUpdate(unitTarget, powerType)
    if unitTarget ~= "player" then return end
    
    if powerType == "MANA" then
        local currentMana = UnitPower("player", MANA_POWER_TYPE)
        if currentMana > state.lastMana then
            state.lastManaTickTime = GetTime()
        end
        state.lastMana = currentMana
    elseif powerType == "ENERGY" then
        local currentEnergy = UnitPower("player", ENERGY_POWER_TYPE)
        if currentEnergy > state.lastEnergy then
            state.lastEnergyTickTime = GetTime()
        end
        state.lastEnergy = currentEnergy
    end
end

local function OnAddonLoaded(addonName)
    if addonName ~= ADDON_NAME then return end
    
    -- Initialize player info
    state.playerClass = select(2, UnitClass("player"))
    state.isDruid = (state.playerClass == "DRUID")
    
    -- Initialize saved variables
    if not MyRegenDB_Account then
        MyRegenDB_Account = {}
    end
    if not MyRegenDB then
        MyRegenDB = {}
    end
    
    -- Migrate old settings from character-specific to both tables
    if MyRegenDB.barWidth then
        MyRegenDB.barWidthMana = MyRegenDB.barWidth
        MyRegenDB.barHeightMana = MyRegenDB.barHeight
        MyRegenDB.barWidthEnergy = MyRegenDB.barWidth
        MyRegenDB.barHeightEnergy = MyRegenDB.barHeight
        MyRegenDB.barWidth = nil
        MyRegenDB.barHeight = nil
    end
    
    -- Ensure all settings exist in both tables
    CopyDefaults(MyRegenDB_Account, DEFAULT_SETTINGS)
    CopyDefaults(MyRegenDB, DEFAULT_SETTINGS)
    
    -- Initialize frames
    InitializeFrames()
    InitializeUpdateFrame()
    MyRegen.CreateOptionsPanel()
    UpdateVisibility()
end

local function OnPlayerLogin()
    state.lastMana = UnitPower("player", MANA_POWER_TYPE)
    state.lastEnergy = UnitPower("player", ENERGY_POWER_TYPE)
    state.lastManaTickTime = GetTime()
    state.lastEnergyTickTime = GetTime()
    UpdateVisibility()
end

local function OnEvent(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(arg1)
    elseif event == "PLAYER_LOGIN" then
        OnPlayerLogin()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_SHAPESHIFT_FORM" then
        UpdateVisibility()
        UpdateAllSizes()
    elseif event == "UNIT_DISPLAYPOWER" and arg1 == "player" then
        UpdateVisibility()
        UpdateAllSizes()
    elseif event == "CHARACTER_POINTS_CHANGED" or event == "PLAYER_EQUIPMENT_CHANGED" then
        UpdateHasMP5()
        UpdateVisibility()
    elseif event == "UNIT_AURA" and arg1 == "player" then
        UpdateHasMP5()
        UpdateVisibility()
    elseif event == "UNIT_POWER_UPDATE" then
        OnPowerUpdate(arg1, arg2)
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        UpdateVisibility()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        OnSpellCastSucceeded(arg1, arg2, arg3)
    end
end

-- ============================================================================
-- Options Panel
-- ============================================================================

function MyRegen.CreateOptionsPanel()
    local panel = CreateFrame("Frame", "MyRegenOptionsPanel")
    panel.name = "My Regen"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("My Regen v" .. ADDON_VERSION)
    
    local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText("Track your mana and energy regeneration")
    
    -- Helper function to create checkboxes
    local function CreateCheckbox(name, label, point, relativeFrame, relativePoint, offsetX, offsetY)
        local cb = CreateFrame("CheckButton", name, panel, "UICheckButtonTemplate")
        cb:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
        _G[cb:GetName() .. "Text"]:SetText(label)
        return cb
    end
    
    -- Helper function to create sliders
    local function CreateSlider(name, label, minVal, maxVal, point, relativeFrame, relativePoint, offsetX, offsetY)
        local slider = CreateFrame("Slider", name, panel, "OptionsSliderTemplate")
        slider:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
        slider:SetWidth(200)
        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(1)
        _G[slider:GetName() .. "Low"]:SetText(tostring(minVal))
        _G[slider:GetName() .. "High"]:SetText(tostring(maxVal))
        _G[slider:GetName() .. "Text"]:SetText(label)
        FixSliderThumb(slider)
        return slider
    end
    
    -- Account-wide settings checkbox
    local accountWideCB = CreateCheckbox("MyRegenAccountWideCB", "Use account-wide settings", 
        "TOPLEFT", subtitle, "BOTTOMLEFT", 0, -20)
    accountWideCB:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        MyRegenDB_Account.useAccountWide = checked
        MyRegenDB.useAccountWide = checked
        -- Refresh panel to show correct settings
        panel:GetScript("OnShow")()
    end)
    
    -- Combat visibility options
    local hideInCombatCB = CreateCheckbox("MyRegenHideInCombatCB", "Hide in combat", 
        "TOPLEFT", accountWideCB, "BOTTOMLEFT", 0, -10)
    hideInCombatCB:SetScript("OnClick", function(self)
        GetSettings().hideInCombat = self:GetChecked()
        UpdateVisibility()
    end)
    
    local hideOutOfCombatCB = CreateCheckbox("MyRegenHideOutOfCombatCB", "Hide out of combat", 
        "TOPLEFT", hideInCombatCB, "BOTTOMLEFT", 0, -10)
    hideOutOfCombatCB:SetScript("OnClick", function(self)
        GetSettings().hideOutOfCombat = self:GetChecked()
        UpdateVisibility()
    end)
    
    -- Mana bar size section
    local manaSizeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    manaSizeTitle:SetPoint("TOPLEFT", hideOutOfCombatCB, "BOTTOMLEFT", 0, -20)
    manaSizeTitle:SetText("Mana Regen Bar Size")
    
    local widthManaSlider = CreateSlider("MyRegenWidthManaSlider", "Width", 50, 400,
        "TOPLEFT", manaSizeTitle, "BOTTOMLEFT", 0, -20)
    widthManaSlider:SetScript("OnValueChanged", function(self, value)
        value = math_floor(value)
        GetSettings().barWidthMana = value
        _G[self:GetName() .. "Text"]:SetText("Width: " .. value)
        UpdateManaSize()
    end)
    
    local heightManaSlider = CreateSlider("MyRegenHeightManaSlider", "Height", 10, 100,
        "TOPLEFT", widthManaSlider, "BOTTOMLEFT", 0, -20)
    heightManaSlider:SetScript("OnValueChanged", function(self, value)
        value = math_floor(value)
        GetSettings().barHeightMana = value
        _G[self:GetName() .. "Text"]:SetText("Height: " .. value)
        UpdateManaSize()
    end)
    
    -- Energy bar size section
    local energySizeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    energySizeTitle:SetPoint("TOPLEFT", heightManaSlider, "BOTTOMLEFT", 0, -30)
    energySizeTitle:SetText("Energy Regen Bar Size")
    
    local widthEnergySlider = CreateSlider("MyRegenWidthEnergySlider", "Width", 50, 400,
        "TOPLEFT", energySizeTitle, "BOTTOMLEFT", 0, -20)
    widthEnergySlider:SetScript("OnValueChanged", function(self, value)
        value = math_floor(value)
        GetSettings().barWidthEnergy = value
        _G[self:GetName() .. "Text"]:SetText("Width: " .. value)
        UpdateEnergySize()
    end)
    
    local heightEnergySlider = CreateSlider("MyRegenHeightEnergySlider", "Height", 10, 100,
        "TOPLEFT", widthEnergySlider, "BOTTOMLEFT", 0, -20)
    heightEnergySlider:SetScript("OnValueChanged", function(self, value)
        value = math_floor(value)
        GetSettings().barHeightEnergy = value
        _G[self:GetName() .. "Text"]:SetText("Height: " .. value)
        UpdateEnergySize()
    end)
    
    -- Tracking options
    local manaCheck = CreateCheckbox("MyRegenManaCheck", "Track mana regen",
        "TOPLEFT", heightEnergySlider, "BOTTOMLEFT", 0, -30)
    manaCheck:SetScript("OnClick", function(self)
        GetSettings().trackManaRegen = self:GetChecked()
        UpdateVisibility()
    end)
    
    local energyCheck = CreateCheckbox("MyRegenEnergyCheck", "Track energy regen",
        "TOPLEFT", manaCheck, "BOTTOMLEFT", 0, -10)
    energyCheck:SetScript("OnClick", function(self)
        GetSettings().trackEnergyRegen = self:GetChecked()
        UpdateVisibility()
    end)
    
    -- Druid-specific options
    local formCheck, outOfCatCheck
    if state.isDruid then
        formCheck = CreateCheckbox("MyRegenFormCheck", "Track mana regen in forms",
            "TOPLEFT", energyCheck, "BOTTOMLEFT", 0, -10)
        formCheck:SetScript("OnClick", function(self)
            GetSettings().trackFormManaRegen = self:GetChecked()
            UpdateVisibility()
        end)
        
        outOfCatCheck = CreateCheckbox("MyRegenOutOfCatCheck", "Show energy bar out of cat form",
            "TOPLEFT", formCheck, "BOTTOMLEFT", 0, -10)
        outOfCatCheck:SetScript("OnClick", function(self)
            GetSettings().showEnergyOutOfCat = self:GetChecked()
            UpdateVisibility()
        end)
    end
    
    -- OnShow handler to sync UI with saved variables
    panel:SetScript("OnShow", function()
        local settings = GetSettings()
        
        accountWideCB:SetChecked(MyRegenDB_Account.useAccountWide)
        hideInCombatCB:SetChecked(settings.hideInCombat)
        hideOutOfCombatCB:SetChecked(settings.hideOutOfCombat)
        manaCheck:SetChecked(settings.trackManaRegen)
        energyCheck:SetChecked(settings.trackEnergyRegen)
        
        widthManaSlider:SetValue(settings.barWidthMana)
        heightManaSlider:SetValue(settings.barHeightMana)
        widthEnergySlider:SetValue(settings.barWidthEnergy)
        heightEnergySlider:SetValue(settings.barHeightEnergy)
        
        if formCheck then
            formCheck:SetChecked(settings.trackFormManaRegen)
        end
        if outOfCatCheck then
            outOfCatCheck:SetChecked(settings.showEnergyOutOfCat)
        end
        
        UpdateAllSizes()
    end)
    
    -- Register with Settings API
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    
    -- Slash commands
    SLASH_MYREGEN1 = "/myregen"
    SlashCmdList["MYREGEN"] = function(msg)
        msg = msg:lower()
        if msg == "" then
            Settings.OpenToCategory(category:GetID())
        elseif msg == "reset" then
            ResetToDefaults()
            UpdateAllSizes()
            UpdateVisibility()
            print("My Regen: Settings reset to default.")
        else
            print("My Regen v" .. ADDON_VERSION)
            print("Usage: /myregen - Open settings")
            print("       /myregen reset - Reset to defaults")
        end
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

frames.event = CreateFrame("Frame")
frames.event:SetScript("OnEvent", OnEvent)
frames.event:RegisterEvent("ADDON_LOADED")
frames.event:RegisterEvent("PLAYER_LOGIN")
frames.event:RegisterEvent("PLAYER_ENTERING_WORLD")
frames.event:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
frames.event:RegisterEvent("UNIT_DISPLAYPOWER")
frames.event:RegisterEvent("CHARACTER_POINTS_CHANGED")
frames.event:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frames.event:RegisterEvent("UNIT_AURA")
frames.event:RegisterEvent("UNIT_POWER_UPDATE")
frames.event:RegisterEvent("PLAYER_REGEN_DISABLED")
frames.event:RegisterEvent("PLAYER_REGEN_ENABLED")
frames.event:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")