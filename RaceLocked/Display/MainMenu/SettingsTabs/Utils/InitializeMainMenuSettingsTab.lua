-- Settings tab (Race Locked main window): option rows styled like RaceLockedStatistics RaceLockedSettingsTab.

local ROW_BUTTON_HEIGHT = 48
local ROW_BUTTON_PAD_H = 14

local function CreateOptionRowButton(parent)
  local row = CreateFrame('Button', nil, parent)
  row:SetHeight(ROW_BUTTON_HEIGHT)
  row:RegisterForClicks('LeftButtonUp')

  local check = CreateFrame('CheckButton', nil, row, 'UICheckButtonTemplate')
  check:SetPoint('TOPLEFT', row, 'TOPLEFT', 0, -6)
  row.Check = check

  local label = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  label:SetPoint('TOPLEFT', check, 'TOPRIGHT', 4, -2)
  label:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
  label:SetJustifyH('LEFT')
  label:SetNonSpaceWrap(false)
  row.Text = label

  local desc = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  desc:SetPoint('TOPLEFT', label, 'BOTTOMLEFT', 0, -2)
  desc:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
  desc:SetJustifyH('LEFT')
  desc:SetWordWrap(true)
  desc:SetNonSpaceWrap(false)
  desc:SetTextColor(0.75, 0.72, 0.65, 1)
  row.Description = desc

  function row:SetDescription(text)
    if self.Description then
      self.Description:SetText(text or '')
      self.Description:SetShown(text and text ~= '')
    end
  end

  function row:SetChecked(on)
    check:SetChecked(on and true or false)
  end

  function row:GetChecked()
    return check:GetChecked() and true or false
  end

  do
    local rawEnable, rawDisable = row.Enable, row.Disable
    row.Enable = function(self)
      if rawEnable then
        rawEnable(self)
      end
      check:Enable()
      check:SetAlpha(1)
    end
    row.Disable = function(self)
      if rawDisable then
        rawDisable(self)
      end
      check:Disable()
      check:SetAlpha(0.6)
    end
  end

  row:SetScript('OnClick', function(self)
    if not check:IsEnabled() then return end
    check:Click()
  end)

  row:SetChecked(false)
  row:SetDescription('')
  return row
end

function RaceLocked_InitializeMainMenuSettingsTab(content)
  if not content or content.raceLockedMainMenuSettingsInit then return end
  content.raceLockedMainMenuSettingsInit = true

  if RaceLocked_Options_EnsureLoaded then
    RaceLocked_Options_EnsureLoaded()
  end

  local optionsFrame = CreateFrame('Frame', nil, content, 'BackdropTemplate')
  content.mainMenuSettingsOptionsFrame = optionsFrame
  optionsFrame:SetPoint('TOPLEFT', content, 'TOPLEFT', 3, -14)
  optionsFrame:SetPoint('BOTTOMRIGHT', content, 'BOTTOMRIGHT', -3, 12)
  optionsFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  optionsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  optionsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  local body = CreateFrame('Frame', nil, optionsFrame)
  body:SetPoint('TOPLEFT', optionsFrame, 'TOPLEFT', 10, -10)
  body:SetPoint('BOTTOMRIGHT', optionsFrame, 'BOTTOMRIGHT', -10, 10)

  local langRow = CreateOptionRowButton(body)
  langRow:SetPoint('TOPLEFT', body, 'TOPLEFT', ROW_BUTTON_PAD_H, -10)
  langRow:SetPoint('TOPRIGHT', body, 'TOPRIGHT', -ROW_BUTTON_PAD_H, -10)
  langRow.Text:SetText('Native language only')
  langRow:SetDescription('When enabled, chat input is set to your race native language.')
  -- Don't use `getter and getter() or default` here: that pattern collapses a
  -- legitimate `false` result to the default, leaving the checkbox stuck on.
  local nativeOnly = true
  if RaceLocked_Options_GetNativeLanguageOnly then
    nativeOnly = RaceLocked_Options_GetNativeLanguageOnly()
  end
  langRow:SetChecked(nativeOnly)

  langRow.Check:SetScript('OnClick', function(btn)
    local newVal = btn:GetChecked() and true or false
    langRow:SetChecked(newVal)
    if RaceLocked_Options_SetNativeLanguageOnly then
      RaceLocked_Options_SetNativeLanguageOnly(newVal)
    end
    if RaceLocked_ApplyNativeLanguageOption then
      RaceLocked_ApplyNativeLanguageOption()
    end
  end)

  local forceRaceOnlyGroupingRow = CreateOptionRowButton(body)
  forceRaceOnlyGroupingRow:SetPoint('TOPLEFT', langRow, 'BOTTOMLEFT', 0, -10)
  forceRaceOnlyGroupingRow:SetPoint('TOPRIGHT', langRow, 'BOTTOMRIGHT', 0, -10)
  forceRaceOnlyGroupingRow.Text:SetText('Force race only grouping')
  forceRaceOnlyGroupingRow:SetDescription(
    'When enabled, players will only be able to group with other players of the same race.'
  )
  local forceRaceOnly = true
  if RaceLocked_Options_GetForceRaceOnlyGrouping then
    forceRaceOnly = RaceLocked_Options_GetForceRaceOnlyGrouping()
  end
  forceRaceOnlyGroupingRow:SetChecked(forceRaceOnly)

  forceRaceOnlyGroupingRow.Check:SetScript('OnClick', function(btn)
    local newVal = btn:GetChecked() and true or false
    forceRaceOnlyGroupingRow:SetChecked(newVal)
    if RaceLocked_Options_SetForceRaceOnlyGrouping then
      RaceLocked_Options_SetForceRaceOnlyGrouping(newVal)
    end
  end)
end
