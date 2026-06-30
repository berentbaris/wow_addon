--- Consent-first mailbox session: scan on open, confirm, then execute returns.
---
--- Phases:
---   loading    – waiting for first MAIL_INBOX_UPDATE after CheckInbox()
---   ready      – plan is built, waiting for user action
---   verifying  – TV probes in flight, waiting for replies or timeout
---   executing  – returning flagged mail one item at a time
---   approved   – inbox is clean, overlay dismissed

local session
local EXECUTE_STEP_DELAY = 0.6

local function appliesToPlayer()
  return RaceLocked_IsInGuildFoundGuild
    and RaceLocked_IsInGuildFoundGuild()
    and RaceLocked_AmIVerified
    and RaceLocked_AmIVerified()
end

--- @return table|nil
function RaceLocked_GetMailAccessSession()
  return session
end

function RaceLocked_IsMailAccessApproved()
  return session and session.approved == true
end

function RaceLocked_BeginMailAccessSession()
  if not appliesToPlayer() then return end

  session = {
    phase = 'loading',
    plan = nil,
    approved = false,
    statusPrinted = false,
    pendingProbes = {},
    plannedReturns = 0,
  }

  if CheckInbox then
    CheckInbox()
  end
end

local PROBE_TIMEOUT = RACE_LOCKED_MAIL_PROBE_TIMEOUT

local function sendNewProbes(plan)
  if not session or not plan then return end
  local sessionRef = session
  for _, action in ipairs(plan.actions) do
    if action.action == 'pending' and action.sender then
      local shortSender = Ambiguate(action.sender, 'short')
      if not session.pendingProbes[shortSender] then
        session.pendingProbes[shortSender] = GetTime and GetTime() or 0
        if RaceLocked_SendTradeVerificationStatus and RaceLocked_AmIVerified then
          RaceLocked_SendTradeVerificationStatus(RaceLocked_AmIVerified(), action.sender)
        end
        if C_Timer and C_Timer.After then
          C_Timer.After(PROBE_TIMEOUT + 0.1, function()
            if session ~= sessionRef then return end
            if session.phase ~= 'verifying' then return end
            if RaceLocked_RefreshMailAccessPlan then
              RaceLocked_RefreshMailAccessPlan()
            end
            if RaceLocked_RefreshMailVerificationDisplay then
              RaceLocked_RefreshMailVerificationDisplay()
            end
          end)
        end
      end
    end
  end
end

local function finishExecution()
  if not session then return end
  if session.plannedReturns > 0 then
    RaceLocked_PrintRestrictionMessage(
      'Returned ' .. session.plannedReturns .. ' message(s) to meet Guild Found mail rules.'
    )
  end
  session.approved = true
  session.phase = 'approved'
  local cb = session.onApproveComplete
  if cb then cb() end
end

--- Timer-driven execution: remove one item, wait, refresh inbox, repeat.
local function executeStep()
  if not session or session.phase ~= 'executing' then return end

  local sessionRef = session
  local pendingProbes = session.pendingProbes or {}
  local plan = RaceLocked_BuildMailAccessPlan(pendingProbes)
  session.plan = plan

  if not plan.requiresReturn then
    finishExecution()
    if RaceLocked_RefreshMailVerificationDisplay then
      RaceLocked_RefreshMailVerificationDisplay()
    end
    return
  end

  if RaceLocked_ExecuteNextMailAction then
    RaceLocked_ExecuteNextMailAction(plan)
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(EXECUTE_STEP_DELAY, function()
      if session ~= sessionRef then return end
      executeStep()
    end)
  end
end

--- Re-scan inbox after MAIL_INBOX_UPDATE while not executing.
function RaceLocked_RefreshMailAccessPlan()
  if not session or session.approved then return end
  if session.phase == 'executing' then return end
  if not RaceLocked_BuildMailAccessPlan then return end

  local pendingProbes = session.pendingProbes or {}
  session.plan = RaceLocked_BuildMailAccessPlan(pendingProbes)

  -- If we were verifying and all probes have resolved, transition to ready
  -- so the button re-enables for the next step.
  if session.phase == 'verifying' and not session.plan.requiresPending then
    session.phase = 'ready'
  elseif session.phase == 'loading' then
    session.phase = 'ready'
  end
end

function RaceLocked_ResetMailAccessSession()
  session = nil
end

function RaceLocked_ResetMailAccessApproval()
  if not session then return end
  session.approved = false
  session.phase = 'ready'
  session.plannedReturns = 0
end

--- User clicked Proceed. Behavior depends on current state:
---   ready + pending senders  → start verifying (send probes)
---   ready + returns needed   → start executing (return mail)
---   ready + clean            → approve and dismiss
--- @param onComplete function|nil  called when the inbox is clean
function RaceLocked_ApproveMailAccessSession(onComplete)
  if not session or session.approved then return end

  local plan = session.plan
  if not plan then return end

  session.onApproveComplete = onComplete

  -- Step 1: if there are unverified senders, kick off probes first.
  if plan.requiresPending then
    session.phase = 'verifying'
    sendNewProbes(plan)
    return
  end

  -- Step 2: if there are returns, execute them.
  if plan.requiresReturn then
    session.phase = 'executing'
    session.plannedReturns = plan.returnCount
    executeStep()
    return
  end

  -- Everything is clean.
  session.approved = true
  session.phase = 'approved'
  if onComplete then onComplete() end
end

function RaceLocked_CancelMailAccessSession()
  session = nil
  if CloseMail then
    CloseMail()
  end
end
