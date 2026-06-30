local ADDON_PREFIX = 'RaceLocked'

local addonMessageFrame = CreateFrame('Frame')
addonMessageFrame:RegisterEvent('CHAT_MSG_ADDON')

addonMessageFrame:SetScript('OnEvent', function(_, event, ...)
  if event ~= 'CHAT_MSG_ADDON' then return end

  local prefix, message, channel, sender = ...
  if prefix ~= ADDON_PREFIX or channel ~= 'WHISPER' or not sender then return end

  local isVerified = RaceLocked_ParseTradeVerificationMessage(message)
  if isVerified == nil then return end

  RaceLocked_OnTradeVerificationMessageReceived(sender, isVerified)

  -- Auto-reply: if this probe did not come from our own active trade session,
  -- reply with our status so the sender can seed our Guild Found roster entry.
  -- Only auto-reply to guildmates • otherwise any stranger could whisper the
  -- right addon message to probe our verification status and trigger roster
  -- side effects.
  local activeSession = RaceLocked_TradeVerificationSession
  local isOurTradePartner = activeSession
    and RaceLocked_PlayerNamesMatch
    and RaceLocked_PlayerNamesMatch(sender, activeSession.targetName)

  local senderIsGuildmate = RaceLocked_IsPlayerInGuildRoster
    and RaceLocked_IsPlayerInGuildRoster(sender)

  if not isOurTradePartner
    and senderIsGuildmate
    and RaceLocked_IsInGuildFoundGuild and RaceLocked_IsInGuildFoundGuild()
    and RaceLocked_AmIVerified and RaceLocked_SendTradeVerificationStatus
  then
    RaceLocked_SendTradeVerificationStatus(RaceLocked_AmIVerified(), sender)
  end
end)
