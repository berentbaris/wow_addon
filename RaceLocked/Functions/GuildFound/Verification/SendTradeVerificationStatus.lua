local ADDON_PREFIX = 'RaceLocked'

function RaceLocked_SendTradeVerificationStatus(isVerified, playerName)
  if not playerName then return end

  local message = isVerified and 'TV:1' or 'TV:0'
  C_ChatInfo.SendAddonMessage(ADDON_PREFIX, message, 'WHISPER', playerName)
end
