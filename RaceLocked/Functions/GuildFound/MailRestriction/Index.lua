--- Event wiring for the consent-first mail restriction.
--- Owns the MailFrame pre-hook and the mail event frame, and orchestrates the
--- overlay (in MailVerificationOverlay.lua) and the access session
--- (in MailAccessSession.lua). Kept separate from the overlay's frame/layout
--- code so each file has a single responsibility.

-- Pre-hook MailFrame so the overlay blocks interaction before any event
-- handlers (ours or other addons') can fire. The hook runs the instant
-- MailFrame:Show() is called by the default UI, which happens before
-- MAIL_SHOW events are dispatched.
local mailFrameHooked = false
local function hookMailFrame()
  if mailFrameHooked or not MailFrame then return end
  mailFrameHooked = true
  MailFrame:HookScript('OnShow', function()
    if not RaceLocked_IsInGuildFoundGuild or not RaceLocked_IsInGuildFoundGuild() then return end
    if not RaceLocked_AmIVerified or not RaceLocked_AmIVerified() then return end
    RaceLocked_ShowMailVerificationOverlay()
  end)
end

local mailOverlayEvents = CreateFrame('Frame')
mailOverlayEvents:RegisterEvent('MAIL_SHOW')
mailOverlayEvents:RegisterEvent('MAIL_CLOSED')
mailOverlayEvents:RegisterEvent('MAIL_INBOX_UPDATE')
mailOverlayEvents:RegisterEvent('PLAYER_LOGIN')

mailOverlayEvents:SetScript('OnEvent', function(_, event)
  if event == 'PLAYER_LOGIN' then
    hookMailFrame()
    return
  end

  if not RaceLocked_IsInGuildFoundGuild or not RaceLocked_IsInGuildFoundGuild() then return end
  if not RaceLocked_AmIVerified or not RaceLocked_AmIVerified() then return end

  if event == 'MAIL_SHOW' then
    if RaceLocked_BeginMailAccessSession then
      RaceLocked_BeginMailAccessSession()
    end
    RaceLocked_PrintRestrictionMessage('Checking mail contents.')
    RaceLocked_ShowMailVerificationOverlay()
    -- CheckInbox() fires MAIL_INBOX_UPDATE which builds the plan. But on a
    -- quick close/reopen the inbox data is already cached and WoW may skip
    -- the event entirely, leaving the session stuck in 'loading'. This
    -- fallback forces a plan build if nothing has happened after a short delay.
    local sess = RaceLocked_GetMailAccessSession and RaceLocked_GetMailAccessSession()
    if sess and C_Timer and C_Timer.After then
      local ref = sess
      C_Timer.After(0.5, function()
        local current = RaceLocked_GetMailAccessSession and RaceLocked_GetMailAccessSession()
        if current ~= ref then return end
        if current.phase ~= 'loading' then return end
        if RaceLocked_RefreshMailAccessPlan then
          RaceLocked_RefreshMailAccessPlan()
        end
        if RaceLocked_RefreshMailVerificationDisplay then
          RaceLocked_RefreshMailVerificationDisplay()
        end
      end)
    end

  elseif event == 'MAIL_CLOSED' then
    if RaceLocked_ResetMailAccessSession then
      RaceLocked_ResetMailAccessSession()
    end
    RaceLocked_HideMailVerificationOverlay()

  elseif event == 'MAIL_INBOX_UPDATE' then
    if RaceLocked_IsMailAccessApproved and RaceLocked_IsMailAccessApproved() then
      local sess = RaceLocked_GetMailAccessSession and RaceLocked_GetMailAccessSession()
      if sess and RaceLocked_BuildMailAccessPlan then
        local fresh = RaceLocked_BuildMailAccessPlan(sess.pendingProbes)
        if fresh.requiresReturn or fresh.requiresPending then
          sess.plan = fresh
          RaceLocked_ResetMailAccessApproval()
          RaceLocked_ShowMailVerificationOverlay()
          if RaceLocked_RefreshMailVerificationDisplay then
            RaceLocked_RefreshMailVerificationDisplay()
          end
        end
      end
      return
    end

    if RaceLocked_RefreshMailAccessPlan then
      RaceLocked_RefreshMailAccessPlan()
    end
    if RaceLocked_RefreshMailVerificationDisplay then
      RaceLocked_RefreshMailVerificationDisplay()
    end
  end
end)
