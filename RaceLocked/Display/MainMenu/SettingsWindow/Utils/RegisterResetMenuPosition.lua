--- @param settingsFrame Frame
function RaceLocked_Settings_RegisterResetMenuPosition(settingsFrame)
  _G.ResetRaceLockedMenuPosition = function()
    settingsFrame:ClearAllPoints()
    settingsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 30)
    print('|cfff44336[Race Locked]|r Menu position reset to default.')
  end
end
