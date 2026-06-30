--- Prevents the player from sending mail to recipients outside Guild Found rules.
--- For guild members with no GF roster entry, sends a TV probe and notifies the
--- player to try again once the reply arrives.

local PROBE_TIMEOUT = RACE_LOCKED_MAIL_PROBE_TIMEOUT  -- shared in MailRestriction/Utils/Constants.lua

local pendingOutboundProbes = {}  -- shortName → true while probe is in flight
local timedOutProbes = {}         -- shortName → true; allows send on next click

--- Called from TradeVerificationSession when a new roster entry is seeded.
--- If we had a pending outbound probe for that player, notify the player they
--- can retry. The reply doesn't guarantee the recipient is eligible (they may
--- have answered "not verified"), so the message stays neutral • the retry
--- itself will allow or block with the precise reason.
function RaceLocked_NotifyOutboundProbeResolved(shortName)
  if pendingOutboundProbes[shortName] then
    pendingOutboundProbes[shortName] = nil
    RaceLocked_PrintRestrictionMessage(shortName .. ' responded to verification • try sending again.')
  end
end

local function isGuildFoundActive()
  return RaceLocked_IsInGuildFoundGuild
    and RaceLocked_IsInGuildFoundGuild()
    and RaceLocked_AmIVerified
    and RaceLocked_AmIVerified()
end

local function getRecipient()
  if SendMailNameEditBox then
    return SendMailNameEditBox:GetText()
  end
  return nil
end

local function isRecipientAllowed(recipient)
  if not recipient or recipient == '' then return true end

  -- Must be in the WoW guild
  if not RaceLocked_IsPlayerInGuildRoster(recipient) then
    return false, 'Cannot send mail to ' .. Ambiguate(recipient, 'short') .. ' • not in guild'
  end

  local guildName = RaceLocked_Roster_GetPlayerGuildName
    and RaceLocked_Roster_GetPlayerGuildName()
  -- Default-deny: if guild data isn't available we can't verify the recipient,
  -- so block rather than silently allow (consistent with the mail policy).
  if not guildName then
    return false, 'Cannot verify ' .. Ambiguate(recipient, 'short') .. ' • guild data unavailable'
  end

  local shortRecipient = Ambiguate(recipient, 'short')
  local entry = RaceLocked_Roster_GetEntry and RaceLocked_Roster_GetEntry(guildName, shortRecipient)

  if entry then
    -- Has GF entry: require eligible
    if RaceLocked_Roster_IsPlayerEligible
      and not RaceLocked_Roster_IsPlayerEligible(guildName, shortRecipient)
    then
      return false, 'Cannot send mail to ' .. shortRecipient .. ' • not eligible'
    end
    return true
  end

  -- Probe already timed out • allow as confirmed guildmate.
  if timedOutProbes[shortRecipient] then
    timedOutProbes[shortRecipient] = nil
    return true
  end

  -- Probe still in flight • keep waiting.
  if pendingOutboundProbes[shortRecipient] then
    return false, 'Awaiting verification from ' .. shortRecipient .. '...'
  end

  -- Send probe, block this attempt, let player retry when notified or after timeout.
  pendingOutboundProbes[shortRecipient] = true
  if RaceLocked_SendTradeVerificationStatus and RaceLocked_AmIVerified then
    RaceLocked_SendTradeVerificationStatus(RaceLocked_AmIVerified(), recipient)
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(PROBE_TIMEOUT + 0.1, function()
      if not pendingOutboundProbes[shortRecipient] then return end
      pendingOutboundProbes[shortRecipient] = nil
      timedOutProbes[shortRecipient] = true
      RaceLocked_PrintRestrictionMessage(
        'No verification reply from ' .. shortRecipient .. ' • click Send to allow as guildmate.'
      )
    end)
  end
  return false, 'Verification probe sent to ' .. shortRecipient .. '. Try again in a moment.'
end

local sendGuardInstalled = false

local function installSendGuard()
  if sendGuardInstalled then return end

  if type(SendMail) == 'function' then
    local origSendMail = SendMail
    SendMail = function(recipient, ...)
      if isGuildFoundActive() then
        local allowed, reason = isRecipientAllowed(recipient)
        if not allowed then
          RaceLocked_PrintRestrictionMessage(reason)
          return
        end
      end
      return origSendMail(recipient, ...)
    end
    sendGuardInstalled = true
    return
  end

  if type(SendMailFrame_SendMail) == 'function' then
    local origFrameSend = SendMailFrame_SendMail
    SendMailFrame_SendMail = function(...)
      if isGuildFoundActive() then
        local recipient = getRecipient()
        local allowed, reason = isRecipientAllowed(recipient)
        if not allowed then
          RaceLocked_PrintRestrictionMessage(reason)
          return
        end
      end
      return origFrameSend(...)
    end
    sendGuardInstalled = true
  end
end

local guardFrame = CreateFrame('Frame')
guardFrame:RegisterEvent('PLAYER_LOGIN')
guardFrame:RegisterEvent('MAIL_SHOW')

guardFrame:SetScript('OnEvent', function(_, event)
  if event == 'PLAYER_LOGIN' or event == 'MAIL_SHOW' then
    installSendGuard()
  end
end)
