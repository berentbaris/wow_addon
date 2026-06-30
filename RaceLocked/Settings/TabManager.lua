
local TAB_HEIGHT = 32
local TAB_SPACING = 3
local TAB_COUNT = 3
local TEXTURE_PATH = 'Interface\\AddOns\\RaceLocked\\Textures'

local TAB_WIDTH = 175
local TAB_WIDTHS = {
  [1] = TAB_WIDTH,
  [2] = TAB_WIDTH,
  [3] = TAB_WIDTH,
}

local BASE_TEXT_COLOR = {
  r = 0.922,
  g = 0.871,
  b = 0.761,
}
local ACTIVE_CLASS_FADE = 0.75

local function getPlayerClassColor()
  local _, playerClass = UnitClass('player')
  if not playerClass then
    return BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b
  end
  local r, g, b = GetClassColor(playerClass)
  if not r then
    return BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b
  end
  return r, g, b
end

local tabButtons = {}
local tabContents = {}
local activeTab = 1

local function calculateTabOffset(index)
  local totalWidth = 0
  for i = 1, TAB_COUNT do
    local w = TAB_WIDTHS[i] or TAB_WIDTH
    totalWidth = totalWidth + w + (i < TAB_COUNT and TAB_SPACING or 0)
  end
  local leftEdge = -totalWidth / 2
  local cumulativeWidth = 0
  for i = 1, index - 1 do
    cumulativeWidth = cumulativeWidth + (TAB_WIDTHS[i] or TAB_WIDTH) + TAB_SPACING
  end
  local tabWidth = TAB_WIDTHS[index] or TAB_WIDTH
  return leftEdge + cumulativeWidth + (tabWidth / 2)
end

local function createTabButton(text, index, parentFrame)
  local button = CreateFrame('Button', nil, parentFrame, 'BackdropTemplate')
  local tabWidth = TAB_WIDTHS[index] or TAB_WIDTH
  button:SetSize(tabWidth, TAB_HEIGHT)
  local horizontalOffset = calculateTabOffset(index)
  button:SetPoint('TOP', parentFrame, 'TOP', horizontalOffset, -57)

  local background = button:CreateTexture(nil, 'BACKGROUND')
  background:SetAllPoints()
  background:SetTexture(TEXTURE_PATH .. '\\tab_texture.png')
  button.backgroundTexture = background
  button:SetBackdrop({
    bgFile = nil,
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  button:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

  local buttonText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
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

-- Below title bar + divider + tab row (tabs at -57, up to ~38px tall when active) + small gap
local TAB_CONTENT_TOP_OFFSET = -92
-- Match Settings.lua frame size; keep tab content inside with ~10px bottom margin
-- Must match Settings.lua SETTINGS_FRAME_WIDTH (frame outer width)
local SETTINGS_FRAME_WIDTH = 540
local SETTINGS_FRAME_HEIGHT = 580
local TAB_CONTENT_WIDTH = SETTINGS_FRAME_WIDTH - 40
local TAB_CONTENT_HEIGHT = SETTINGS_FRAME_HEIGHT + TAB_CONTENT_TOP_OFFSET - 10

local function createTabContent(index, parentFrame)
  local content = CreateFrame('Frame', nil, parentFrame)
  content:SetSize(TAB_CONTENT_WIDTH, TAB_CONTENT_HEIGHT)
  content:SetPoint('TOP', parentFrame, 'TOP', 0, TAB_CONTENT_TOP_OFFSET)
  content:Hide()
  return content
end

function RaceLocked_InitializeTabs(settingsFrame)
  if tabButtons[1] then return end

  tabButtons[1] = createTabButton('Leaderboard', 1, settingsFrame)
  tabButtons[2] = createTabButton('Settings', 2, settingsFrame)
  tabButtons[3] = createTabButton('Explainer', 3, settingsFrame)

  tabContents[1] = createTabContent(1, settingsFrame)
  tabContents[2] = createTabContent(2, settingsFrame)
  tabContents[3] = createTabContent(3, settingsFrame)
end

function RaceLocked_SwitchToTab(index)
  for i, content in ipairs(tabContents) do
    content:Hide()
  end

  for i, tabButton in ipairs(tabButtons) do
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
      insets = { left = 0, right = 0, top = 0, bottom = 0 },
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
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  tabButtons[index]:SetBackdropBorderColor(fadedR, fadedG, fadedB, 1)
  activeTab = index

  if RaceLockedDB then
    RaceLockedDB.lastOpenedSettingsTab = index
  end

  if index == 1 and RaceLocked_InitializeGuildLeaderboardTab then
    RaceLocked_InitializeGuildLeaderboardTab(tabContents, index)
  end
  if index == 2 and RaceLocked_InitializeSettingsTab then
    RaceLocked_InitializeSettingsTab(tabContents, index)
  end
  if index == 3 and RaceLocked_InitializePointsExplainedTab then
    RaceLocked_InitializePointsExplainedTab(tabContents, index)
  end
end

function RaceLocked_SetDefaultTab()
  local defaultIndex = 1
  if RaceLockedDB and RaceLockedDB.lastOpenedSettingsTab then
    local saved = RaceLockedDB.lastOpenedSettingsTab
    if type(saved) == 'number' then
      -- Legacy index remap from older multi-leaderboard layouts.
      if saved == 2 then
        saved = 1
      end
      if saved == 4 then
        saved = 3
      end
      if saved == 5 then
        saved = 2
      end
      if saved < 1 or saved > TAB_COUNT then
        saved = 1
      end
      if saved >= 1 and saved <= TAB_COUNT and tabContents[saved] then
        defaultIndex = saved
      end
    end
  end
  RaceLocked_SwitchToTab(defaultIndex)
end

function RaceLocked_GetActiveTab()
  return activeTab
end

function RaceLocked_GetTabContent(index)
  return tabContents[index]
end

function RaceLocked_GetTabButton(index)
  return tabButtons[index]
end

function RaceLocked_HideAllTabs()
  for i, content in ipairs(tabContents) do
    content:Hide()
  end
  for i, tabButton in ipairs(tabButtons) do
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
      insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    tabButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
  end
end

function RaceLocked_ResetTabState()
  activeTab = 1
  for i, content in ipairs(tabContents) do
    content:Hide()
  end
  for i, tabButton in ipairs(tabButtons) do
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
