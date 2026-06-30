SLASH_RACELOCKED1 = '/racelocked'
SLASH_RACELOCKED2 = '/racelock'

SlashCmdList['RACELOCKED'] = function()
  if ToggleRaceLockedSettings then
    ToggleRaceLockedSettings()
  end
end
