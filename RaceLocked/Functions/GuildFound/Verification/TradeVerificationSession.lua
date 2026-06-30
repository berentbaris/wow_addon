local VERIFICATION_TIMEOUT_SECONDS = 5

RaceLocked_TradeVerificationSession = nil
RaceLocked_tradeVerificationTimeout = nil

function RaceLocked_ClearTradeVerificationSession()
  if RaceLocked_tradeVerificationTimeout then
    RaceLocked_tradeVerificationTimeout:Cancel()
    RaceLocked_tradeVerificationTimeout = nil
  end
  RaceLocked_TradeVerificationSession = nil
end

function RaceLocked_EndTradeVerification()
  RaceLocked_HideTradeVerificationOverlay()
  RaceLocked_ClearTradeVerificationSession()
end

local function getTradeBlockedMessage(session)
  if not RaceLocked_AmIVerified() then
    return 'Trade blocked - you are not verified.'
  end
  if session.partnerVerified == false then
    return 'Trade with ' .. session.targetName .. ' blocked - partner not verified.'
  end
  return 'Trade with ' .. session.targetName .. ' blocked - verification failed.'
end

function RaceLocked_TryResolveTradeVerification(isTimeout)
  local session = RaceLocked_TradeVerificationSession
  if not session or session.resolved then return end

  if isTimeout and session.partnerVerified == nil then
    session.resolved = true
    local onComplete = session.onComplete
    local targetName = session.targetName
    RaceLocked_ClearTradeVerificationSession()
    onComplete(false, 'Trade with ' .. targetName .. ' blocked - verification timed out.')
    return
  end

  if session.partnerVerified == nil then return end

  session.resolved = true

  local canTrade = RaceLocked_AmIVerified() and session.partnerVerified
  local message = canTrade and nil or getTradeBlockedMessage(session)
  local onComplete = session.onComplete

  RaceLocked_ClearTradeVerificationSession()

  if canTrade then
    RaceLocked_PrintRestrictionMessage('Verification passed, trading can continue')
    RaceLocked_HideTradeVerificationOverlay()
  end

  onComplete(canTrade, message)
end

function RaceLocked_BeginTradeVerification(playerName, onComplete)
  RaceLocked_ClearTradeVerificationSession()
  RaceLocked_ShowTradeVerificationOverlay()

  RaceLocked_TradeVerificationSession = {
    targetName = playerName,
    onComplete = onComplete,
    partnerVerified = nil,
    resolved = false,
  }

  local iAmVerified = RaceLocked_AmIVerified()
  RaceLocked_PrintRestrictionMessage(
    iAmVerified and 'I have passed verification' or 'I have failed verification'
  )
  RaceLocked_SendTradeVerificationStatus(iAmVerified, playerName)

  local cached = RaceLocked_GetCachedPartnerVerification(playerName)
  if cached ~= nil then
    RaceLocked_PrintRestrictionMessage(
      playerName .. ' has ' .. (cached and 'passed' or 'failed') .. ' verification'
    )
    RaceLocked_TradeVerificationSession.partnerVerified = cached
    RaceLocked_TryResolveTradeVerification()
  end

  if C_Timer and C_Timer.NewTimer then
    RaceLocked_tradeVerificationTimeout = C_Timer.NewTimer(VERIFICATION_TIMEOUT_SECONDS, function()
      RaceLocked_TryResolveTradeVerification(true)
    end)
  end
end

function RaceLocked_OnTradeVerificationMessageReceived(sender, isVerified)
  RaceLocked_CachePartnerVerification(sender, isVerified)

  -- Trust note: this seeds a roster entry from a TV whisper reply, which is
  -- trust-based (a modified client can claim verified=true). We only seed when
  -- no entry exists yet, so an authenticated guild-sync self-report (S:) from the
  -- real owner can later correct it. See CanPerformTradeWithPlayer.lua for the
  -- full trust-model rationale.
  local shortName = Ambiguate(sender, 'short')

  -- Notify the send guard regardless of whether a roster entry already exists.
  -- An S: broadcast can arrive between probe and reply, so the entry may exist
  -- by the time the TV response comes back.
  if RaceLocked_NotifyOutboundProbeResolved then
    RaceLocked_NotifyOutboundProbeResolved(shortName)
  end

  if RaceLocked_Roster_SetSelfReport and RaceLocked_Roster_GetEntry
    and IsInGuild and IsInGuild() and GetGuildInfo then
    local guildName = GetGuildInfo('player')
    if guildName then
      if not RaceLocked_Roster_GetEntry(guildName, shortName) then
        if isVerified then
          RaceLocked_Roster_SetSelfReport(guildName, shortName, true, true)
        else
          RaceLocked_Roster_SetSelfReport(guildName, shortName, false, nil)
        end
      end
      -- Re-evaluate any mail held pending this sender
      if RaceLocked_RefreshMailAccessPlan then
        RaceLocked_RefreshMailAccessPlan()
      end
      if RaceLocked_RefreshMailVerificationDisplay then
        RaceLocked_RefreshMailVerificationDisplay()
      end
    end
  end

  local session = RaceLocked_TradeVerificationSession
  if not session or session.resolved or not RaceLocked_PlayerNamesMatch(
    sender,
    session.targetName
  ) then return end

  session.partnerVerified = isVerified
  RaceLocked_PrintRestrictionMessage(
    session.targetName .. ' has ' .. (isVerified and 'passed' or 'failed') .. ' verification'
  )
  RaceLocked_TryResolveTradeVerification()
end
