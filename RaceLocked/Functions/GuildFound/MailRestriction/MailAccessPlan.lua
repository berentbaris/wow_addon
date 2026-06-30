--- Scan inbox and describe mail that must be returned before Guild Found mailbox access.

local ACTION_RETURN = 'return'
local ACTION_PENDING = 'pending'

local PROBE_TIMEOUT = RACE_LOCKED_MAIL_PROBE_TIMEOUT  -- shared in MailRestriction/Utils/Constants.lua

local INVOICE_LABELS = {
  buyer = 'purchase',
  seller = 'sale proceeds',
  seller_temp_invoice = 'pending sale',
}

local function trimSender(sender)
  if type(sender) ~= 'string' or sender == '' then return '(unknown sender)' end
  return Ambiguate(sender, 'short')
end

local function describeAuctionAction(inboxIndex, sender, subject)
  local invoiceType, itemName = nil, nil
  if GetInboxInvoiceInfo then
    invoiceType, itemName = GetInboxInvoiceInfo(inboxIndex)
  end
  local invoiceLabel = INVOICE_LABELS[invoiceType] or 'invoice'
  local itemPart = itemName and (' • ' .. itemName) or ''
  local subjectPart = subject and subject ~= '' and (' "' .. subject .. '"') or ''
  return 'Return Auction House mail (' .. invoiceLabel .. ') from '
    .. trimSender(sender) .. itemPart .. subjectPart
end

--- Evaluate one inbox message against Guild Found mail rules.
--- Returns an action table if something must happen, nil if mail is allowed.
--- @param inboxIndex number
--- @param guildName string|nil
--- @param pendingProbes table  keyed by short sender name → probe start time
--- @return table|nil action  { action = 'return'|'pending', ... }
function RaceLocked_GetMailRequiredAction(inboxIndex, guildName, pendingProbes)
  if not inboxIndex or not RaceLocked_ClassifyInboxMail then return nil end

  local mail = RaceLocked_ClassifyInboxMail(inboxIndex)
  if not mail then return nil end

  local _, _, sender, subject = GetInboxHeaderInfo(inboxIndex)

  -- AH mail: always block
  if mail.kind == 'auction_house' then
    return {
      inboxIndex = inboxIndex,
      action = ACTION_RETURN,
      kind = mail.kind,
      sender = sender,
      subject = subject,
      description = describeAuctionAction(inboxIndex, sender, subject),
    }
  end

  -- GM and NPC/system: always allow
  if mail.kind ~= 'player' then return nil end

  local shortSender = trimSender(sender)
  local subjectPart = subject and subject ~= '' and (' "' .. subject .. '"') or ''

  -- Not on WoW guild roster: block
  if not RaceLocked_IsPlayerInGuildRoster(sender) then
    return {
      inboxIndex = inboxIndex,
      action = ACTION_RETURN,
      kind = mail.kind,
      sender = sender,
      subject = subject,
      description = 'Return mail from ' .. shortSender .. subjectPart .. ' • not in guild',
    }
  end

  -- On WoW roster: check Guild Found eligibility
  if guildName then
    local entry = RaceLocked_Roster_GetEntry and RaceLocked_Roster_GetEntry(guildName, shortSender)

    if entry then
      -- Has GF entry: require eligible (verified + clean)
      if RaceLocked_Roster_IsPlayerEligible and not RaceLocked_Roster_IsPlayerEligible(guildName, shortSender) then
        return {
          inboxIndex = inboxIndex,
          action = ACTION_RETURN,
          kind = mail.kind,
          sender = sender,
          subject = subject,
          description = 'Return mail from ' .. shortSender .. subjectPart .. ' • not eligible',
        }
      end
      -- Eligible: allow
      return nil
    end

    -- No GF entry: probe and hold pending
    local probeTime = pendingProbes and pendingProbes[shortSender]
    if probeTime then
      local elapsed = (GetTime and GetTime() or 0) - probeTime
      if elapsed >= PROBE_TIMEOUT then
        -- Probe timed out: block
        return {
          inboxIndex = inboxIndex,
          action = ACTION_RETURN,
          kind = mail.kind,
          sender = sender,
          subject = subject,
          description = 'Return mail from ' .. shortSender .. subjectPart
            .. ' • no verification reply',
        }
      end
      -- Still within timeout: pending
      return {
        inboxIndex = inboxIndex,
        action = ACTION_PENDING,
        kind = mail.kind,
        sender = sender,
        subject = subject,
        description = 'Awaiting verification from ' .. shortSender,
      }
    end

    -- No probe sent yet: pending (caller will send probe)
    return {
      inboxIndex = inboxIndex,
      action = ACTION_PENDING,
      kind = mail.kind,
      sender = sender,
      subject = subject,
      description = 'Awaiting verification from ' .. shortSender,
    }
  end

  -- No guild name: can't check GF roster, hold pending
  return {
    inboxIndex = inboxIndex,
    action = ACTION_PENDING,
    kind = mail.kind,
    sender = sender,
    subject = subject,
    description = 'Awaiting verification from ' .. shortSender,
  }
end

--- Scan inbox without modifying mail.
--- @param pendingProbes table|nil  keyed by short sender name → probe start time
--- @return table plan
function RaceLocked_BuildMailAccessPlan(pendingProbes)
  pendingProbes = pendingProbes or {}

  local plan = {
    inboxCount = 0,
    actions = {},
    returnCount = 0,
    pendingCount = 0,
    allowedCount = 0,
    requiresReturn = false,
    requiresPending = false,
    requiresAction = false,
    lines = {},
  }

  if RaceLocked_RefreshGuildRoster then
    RaceLocked_RefreshGuildRoster()
  end

  local guildName = RaceLocked_Roster_GetPlayerGuildName
    and RaceLocked_Roster_GetPlayerGuildName() or nil

  plan.inboxCount = GetInboxNumItems and GetInboxNumItems() or 0

  for inboxIndex = 1, plan.inboxCount do
    local required = RaceLocked_GetMailRequiredAction(inboxIndex, guildName, pendingProbes)
    if required then
      plan.actions[#plan.actions + 1] = required
      if required.action == ACTION_RETURN then
        plan.returnCount = plan.returnCount + 1
      else
        plan.pendingCount = plan.pendingCount + 1
      end
    else
      plan.allowedCount = plan.allowedCount + 1
      local _, _, sender, subject = GetInboxHeaderInfo(inboxIndex)
      local mail = RaceLocked_ClassifyInboxMail and RaceLocked_ClassifyInboxMail(inboxIndex)
      local kindLabel = mail and mail.kind or 'unknown'
      plan.actions[#plan.actions + 1] = {
        inboxIndex = inboxIndex,
        action = 'allowed',
        kind = kindLabel,
        sender = sender,
        subject = subject,
        description = nil,
      }
    end
  end

  plan.requiresReturn = plan.returnCount > 0
  plan.requiresPending = plan.pendingCount > 0
  plan.requiresAction = plan.returnCount > 0 or plan.pendingCount > 0

  if plan.inboxCount == 0 then
    plan.lines[#plan.lines + 1] = 'Your mailbox is empty.'
  elseif plan.requiresReturn then
    -- plan.lines feeds the chat-based dev report (MailStateReport), not the
    -- player overlay. The overlay renders the full scrollable list from
    -- plan.actions; here we cap at 8 bullets so the chat report stays readable.
    plan.lines[#plan.lines + 1] = 'To access your mailbox, the following mail must be returned:'
    plan.lines[#plan.lines + 1] = ''
    local shown = 0
    for _, action in ipairs(plan.actions) do
      if action.action == ACTION_RETURN then
        shown = shown + 1
        if shown <= 8 then
          plan.lines[#plan.lines + 1] = '• ' .. action.description
        end
      end
    end
    if shown > 8 then
      plan.lines[#plan.lines + 1] = '• (+' .. (shown - 8) .. ' more)'
    end
    if plan.pendingCount > 0 then
      plan.lines[#plan.lines + 1] = ''
      plan.lines[#plan.lines + 1] = plan.pendingCount .. ' sender(s) awaiting verification.'
    end
    if plan.allowedCount > 0 then
      plan.lines[#plan.lines + 1] = ''
      plan.lines[#plan.lines + 1] = plan.allowedCount .. ' other message(s) will remain.'
    end
  elseif plan.requiresPending then
    plan.lines[#plan.lines + 1] = 'Verifying sender(s) • please wait...'
    plan.lines[#plan.lines + 1] = ''
    for i, action in ipairs(plan.actions) do
      if i <= 6 then
        plan.lines[#plan.lines + 1] = '• ' .. action.description
      end
    end
    if plan.allowedCount > 0 then
      plan.lines[#plan.lines + 1] = ''
      plan.lines[#plan.lines + 1] = plan.allowedCount .. ' other message(s) will remain.'
    end
  else
    plan.lines[#plan.lines + 1] = 'Your inbox meets Guild Found mail rules.'
    plan.lines[#plan.lines + 1] = 'No mail needs to be returned.'
    if plan.inboxCount > 0 then
      plan.lines[#plan.lines + 1] = ''
      plan.lines[#plan.lines + 1] = plan.inboxCount .. ' message(s) ready to read.'
    end
  end

  return plan
end

--- Remove one inbox message using the return/delete path that matches the default UI.
--- @param inboxIndex number
function RaceLocked_RemoveInboxMail(inboxIndex)
  if not inboxIndex then return end
  if InboxItemCanDelete and InboxItemCanDelete(inboxIndex) then
    DeleteInboxItem(inboxIndex)
  else
    ReturnInboxItem(inboxIndex)
  end
end

--- Execute the single highest-index ACTION_RETURN item from the plan.
--- Removing the highest index first means lower indices never shift under us
--- within a single pass. The caller (executeStep in MailAccessSession.lua)
--- drives the next step on a timer and rebuilds the plan from fresh inbox data
--- each time, so indices are always re-derived and never drift.
--- @param plan table  from RaceLocked_BuildMailAccessPlan
function RaceLocked_ExecuteNextMailAction(plan)
  if not plan or not plan.requiresReturn then return end

  local best = nil
  for _, action in ipairs(plan.actions) do
    if action.action == ACTION_RETURN then
      if not best or action.inboxIndex > best.inboxIndex then
        best = action
      end
    end
  end

  if best then
    RaceLocked_RemoveInboxMail(best.inboxIndex)
  end
end
