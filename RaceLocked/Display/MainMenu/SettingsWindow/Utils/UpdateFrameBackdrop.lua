--- @param settingsFrame Frame must have `raceLockedBackgroundTexture` (BACKGROUND region)
function RaceLocked_Settings_UpdateFrameBackdrop(settingsFrame)
  local S = RaceLocked_Settings
  local bg = settingsFrame.raceLockedBackgroundTexture
  if not bg then return end
  bg:SetTexture(RaceLocked_Settings_GetClassBackgroundTexture())
  local frameHeight = settingsFrame:GetHeight()
  bg:SetSize(frameHeight * S.CLASS_BACKGROUND_ASPECT_RATIO, frameHeight)
  settingsFrame:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8x8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = false,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  settingsFrame:SetBackdropColor(0.03, 0.03, 0.03, 0.5)
  settingsFrame:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.9)
end
