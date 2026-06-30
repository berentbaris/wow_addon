-- Tab strip for the settings frame (matches UltraStatistics Settings/TabManager.lua visuals).
-- Use RaceLocked_* globals only so we do not collide with other addons' TabManager state.

local TAB_WIDTH = 190
local TAB_HEIGHT = 32
local TAB_SPACING = 3
local MAX_TABS = 3
-- Tab tops align with UltraStatistics (-57). Content starts below tab row (incl. active tab +6 height) + gap.
local TAB_TOP_Y = -57
local CONTENT_TOP_Y = -(57 + TAB_HEIGHT)
local CONTENT_BOTTOM_INSET = 8

local S = RaceLocked_Settings
local TAB_TEXTURE =
  (S and S.TEXTURE_PATH or 'Interface\\AddOns\\RaceLocked\\Textures') .. '\\tab_texture.png'
local TAB_WIDTHS = {
  [1] = TAB_WIDTH, -- Main
  [2] = TAB_WIDTH, -- Settings
  [3] = TAB_WIDTH, -- Guild Verification
}

local BASE_TEXT_COLOR = {
  r = 0.922,
  g = 0.871,
  b = 0.761,
}
local ACTIVE_CLASS_FADE = 0.75

local tabButtons = {}
local tabContents = {}
local activeTab = 1

local function getPlayerClassColor()
  local _, playerClass = UnitClass('player')
  if playerClass and RAID_CLASS_COLORS and RAID_CLASS_COLORS[playerClass] then
    local c = RAID_CLASS_COLORS[playerClass]
    return c.r, c.g, c.b
  end
  if playerClass and GetClassColor then
    local r, g, b = GetClassColor(playerClass)
    if type(r) == 'number' and type(g) == 'number' and type(b) == 'number' then
      return r, g, b
    end
  end
  return BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b
end

local function calculateTabOffset(index)
  local totalWidth = 0
  for i = 1, MAX_TABS do
    local width = TAB_WIDTHS[i] or 86
    if i < MAX_TABS then
      totalWidth = totalWidth + width + TAB_SPACING
    else
      totalWidth = totalWidth + width
    end
  end

  local leftEdge = -totalWidth / 2
  local cumulativeWidth = 0
  for i = 1, index - 1 do
    local width = TAB_WIDTHS[i] or 86
    cumulativeWidth = cumulativeWidth + width + TAB_SPACING
  end

  local tabWidth = TAB_WIDTHS[index] or 86
  return leftEdge + cumulativeWidth + (tabWidth / 2)
end

local function createTabButton(text, index, parentFrame)
  local button = CreateFrame('Button', nil, parentFrame, 'BackdropTemplate')
  local tabWidth = TAB_WIDTHS[index] or 86
  button:SetSize(tabWidth, TAB_HEIGHT)
  local horizontalOffset = calculateTabOffset(index)
  button:SetPoint('TOP', parentFrame, 'TOP', horizontalOffset, TAB_TOP_Y)

  local background = button:CreateTexture(nil, 'BACKGROUND')
  background:SetAllPoints()
  background:SetTexture(TAB_TEXTURE)
  button.backgroundTexture = background

  button:SetBackdrop({
    bgFile = nil,
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  button:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

  local buttonText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  buttonText:SetPoint('CENTER', button, 'CENTER', 0, -2)
  buttonText:SetText(text)
  buttonText:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
  button.text = buttonText

  button:SetScript('OnClick', function()
    RaceLocked_SwitchToTab(index)
  end)

  button.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
  button:SetAlpha(0.9)
  return button
end

local function createTabContent(_, parentFrame)
  local content = CreateFrame('Frame', nil, parentFrame)
  local w = (S and S.FRAME_WIDTH or parentFrame:GetWidth()) - 20
  local topReserve = -CONTENT_TOP_Y
  local h = parentFrame:GetHeight() - topReserve - CONTENT_BOTTOM_INSET
  content:SetSize(w, math.max(80, h))
  content:SetPoint('TOP', parentFrame, 'TOP', 0, CONTENT_TOP_Y)
  content:Hide()
  return content
end

function RaceLocked_InitializeTabs(settingsFrame)
  if tabButtons[1] then return end

  tabButtons[1] = createTabButton('Overview', 1, settingsFrame)
  tabContents[1] = createTabContent(1, settingsFrame)
  tabButtons[2] = createTabButton('Settings', 2, settingsFrame)
  tabContents[2] = createTabContent(2, settingsFrame)
  tabButtons[3] = createTabButton('Guild Verification', 3, settingsFrame)
  tabContents[3] = createTabContent(3, settingsFrame)
end

--- @return Frame|nil main tab body (faction grid mounts here)
function RaceLocked_GetMainTabContent()
  return tabContents[1]
end

function RaceLocked_SwitchToTab(index)
  index = tonumber(index) or 1
  if index < 1 then
    index = 1
  end
  if index > MAX_TABS then
    index = MAX_TABS
  end

  for _, content in ipairs(tabContents) do
    content:Hide()
  end

  for _, tabButton in ipairs(tabButtons) do
    if tabButton.backgroundTexture then
      tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
    end
    tabButton:SetAlpha(0.9)
    tabButton:SetHeight(TAB_HEIGHT)
    if tabButton.text then
      tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
    end
    tabButton:SetBackdrop({
      bgFile = nil,
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      tile = false,
      edgeSize = 1,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    tabButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
  end

  tabContents[index]:Show()
  if tabButtons[index].backgroundTexture then
    tabButtons[index].backgroundTexture:SetVertexColor(1, 1, 1, 1)
  end
  tabButtons[index]:SetAlpha(1.0)
  tabButtons[index]:SetHeight(TAB_HEIGHT + 6)

  local classR, classG, classB = getPlayerClassColor()
  local fadedR = (classR * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.r * (1 - ACTIVE_CLASS_FADE))
  local fadedG = (classG * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.g * (1 - ACTIVE_CLASS_FADE))
  local fadedB = (classB * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.b * (1 - ACTIVE_CLASS_FADE))
  if tabButtons[index].text then
    tabButtons[index].text:SetTextColor(fadedR, fadedG, fadedB)
  end
  tabButtons[index]:SetBackdrop({
    bgFile = nil,
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  tabButtons[index]:SetBackdropBorderColor(fadedR, fadedG, fadedB, 1)

  activeTab = index

  if index == 1 and RaceLocked_InitializeMainPanel then
    local f = _G.RaceLockedSettingsFrame
    if f then
      RaceLocked_InitializeMainPanel(f)
    end
  end

  if index == 2 and RaceLocked_InitializeMainMenuSettingsTab then
    RaceLocked_InitializeMainMenuSettingsTab(tabContents[index])
  end

  if index == 3 and RaceLocked_InitializeGuildVerificationTab then
    RaceLocked_InitializeGuildVerificationTab(tabContents[index])
  end
end

function RaceLocked_SetDefaultTab()
  RaceLocked_SwitchToTab(1)
end

function RaceLocked_GetActiveTab()
  return activeTab
end

function RaceLocked_HideAllTabs()
  for _, content in ipairs(tabContents) do
    content:Hide()
  end
  for _, tabButton in ipairs(tabButtons) do
    if tabButton.backgroundTexture then
      tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
    end
    tabButton:SetAlpha(0.9)
    tabButton:SetHeight(TAB_HEIGHT)
    if tabButton.text then
      tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
    end
    tabButton:SetBackdrop({
      bgFile = nil,
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      tile = false,
      edgeSize = 1,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    tabButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
  end
end

function RaceLocked_ResetTabState()
  activeTab = 1
  for _, content in ipairs(tabContents) do
    content:Hide()
  end
  for _, tabButton in ipairs(tabButtons) do
    if tabButton then
      if tabButton.backgroundTexture then
        tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
      end
      tabButton:SetAlpha(0.9)
      tabButton:Show()
      tabButton:SetHeight(TAB_HEIGHT)
      if tabButton.text then
        tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
      end
      tabButton:SetBackdrop(nil)
    end
  end
end
