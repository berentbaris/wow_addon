--- Creates and wires the settings frame hierarchy (runs once at addon load).
function RaceLocked_Settings_BuildWindow()
  local f = RaceLocked_Settings_CreateRootFrame()
  RaceLocked_Settings.settingsFrame = f
  RaceLocked_Settings_RegisterResetMenuPosition(f)
  RaceLocked_Settings_AttachBackgroundTexture(f)
  RaceLocked_Settings_CreateTitleChrome(f)
  if RaceLocked_InitializeTabs then
    RaceLocked_InitializeTabs(f)
  end
end

RaceLocked_Settings_BuildWindow()

function ToggleRaceLockedSettings()
  local settingsFrame = _G.RaceLockedSettingsFrame
  if not settingsFrame then return end
  if settingsFrame:IsShown() then
    if _G.HideConfirmationDialog then
      _G.HideConfirmationDialog()
    end
    if RaceLocked_ResetTabState then
      RaceLocked_ResetTabState()
    end
    settingsFrame:Hide()
  else
    RaceLocked_RefreshGuildRoster()
    RaceLocked_Settings_UpdateFrameBackdrop(settingsFrame)
    if RaceLocked_InitializeTabs then
      RaceLocked_InitializeTabs(settingsFrame)
    end
    if RaceLocked_HideAllTabs and RaceLocked_SetDefaultTab then
      RaceLocked_HideAllTabs()
      RaceLocked_SetDefaultTab()
    elseif RaceLocked_SwitchToTab then
      RaceLocked_SwitchToTab(1)
    end
    if RaceLocked_InitializeMainPanel then
      RaceLocked_InitializeMainPanel(settingsFrame)
    end
    settingsFrame:Show()
  end
end
