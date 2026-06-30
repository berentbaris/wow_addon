--- @return string texture path
function RaceLocked_Settings_GetClassBackgroundTexture()
  local S = RaceLocked_Settings
  local _, classFileName = UnitClass('player')
  if classFileName and S.CLASS_BACKGROUND_MAP[classFileName] then
    return S.CLASS_BACKGROUND_MAP[classFileName]
  end
  return 'Interface\\DialogFrame\\UI-DialogBox-Background'
end
