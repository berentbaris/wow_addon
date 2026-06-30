--- @param settingsFrame Frame
function RaceLocked_Settings_AttachBackgroundTexture(settingsFrame)
  local tex = settingsFrame:CreateTexture(nil, 'BACKGROUND')
  tex:SetPoint('CENTER', settingsFrame, 'CENTER')
  tex:SetTexCoord(0, 1, 0, 1)
  settingsFrame.raceLockedBackgroundTexture = tex
  RaceLocked_Settings_UpdateFrameBackdrop(settingsFrame)
end
