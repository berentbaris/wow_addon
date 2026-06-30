--- Blocks mailbox access until inbox is scanned and the player consents to required returns.

local overlay
local BUTTON_HEIGHT = 22
local INNER_PAD = 14
local TOP_PAD = 36
local ROW_LINE_HEIGHT = 16
local ROW_PADDING = 3
local BTN_BOTTOM_PAD = 14
local BTN_CENTER_GAP = 6
local TITLE_FONT = 'GameFontHighlightLarge'
local BODY_FONT = 'GameFontHighlightSmall'
local REASON_FONT = 'GameFontNormalSmall'
local FOOTER_FONT = 'GameFontHighlight'

local COLORS = {
  title     = { r = 1.0,  g = 0.82, b = 0.0  },
  subtitle  = { r = 0.85, g = 0.85, b = 0.85 },
  returnRow = { r = 0.82, g = 0.33, b = 0.33 },
  pendRow   = { r = 1.0,  g = 0.82, b = 0.0  },
  allowed   = { r = 0.35, g = 0.8,  b = 0.35 },
  muted     = { r = 0.55, g = 0.55, b = 0.55 },
  reason    = { r = 0.7,  g = 0.7,  b = 0.7  },
  rowEven   = { r = 0.12, g = 0.12, b = 0.15, a = 0.7 },
  rowOdd    = { r = 0.08, g = 0.08, b = 0.10, a = 0.5 },
}

local function updateSpinner(self, elapsed)
  if not self.spinner or not self.spinner:IsShown() then return end
  self.pulse = (self.pulse or 0) + elapsed
  local alpha = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(self.pulse * 3))
  self.spinner:SetAlpha(alpha)
  if self.spinner.SetRotation then
    self.rotation = (self.rotation or 0) - elapsed * 2
    self.spinner:SetRotation(self.rotation)
  end
end

local function hideAllActionRows()
  if not overlay or not overlay.actionRows then return end
  for _, row in ipairs(overlay.actionRows) do
    row:Hide()
  end
end

local function ensureActionRow(index)
  if overlay.actionRows[index] then return overlay.actionRows[index] end

  local row = CreateFrame('Frame', nil, overlay.scrollChild)

  row.bg = row:CreateTexture(nil, 'BACKGROUND')
  row.bg:SetAllPoints()

  row.senderLine = row:CreateFontString(nil, 'OVERLAY', BODY_FONT)
  row.senderLine:SetPoint('TOPLEFT', row, 'TOPLEFT', 6, -ROW_PADDING)
  row.senderLine:SetPoint('RIGHT', row, 'RIGHT', -6, 0)
  row.senderLine:SetJustifyH('LEFT')
  row.senderLine:SetWordWrap(false)

  row.reasonLine = row:CreateFontString(nil, 'OVERLAY', REASON_FONT)
  row.reasonLine:SetPoint('TOPLEFT', row.senderLine, 'BOTTOMLEFT', 0, -1)
  row.reasonLine:SetPoint('RIGHT', row, 'RIGHT', -6, 0)
  row.reasonLine:SetJustifyH('LEFT')
  row.reasonLine:SetWordWrap(false)

  overlay.actionRows[index] = row
  return row
end

local function showLoadingState(message)
  overlay.titleText:SetText('')
  overlay.subtitleText:Hide()
  overlay.footerText:Hide()
  overlay.listArea:Hide()
  overlay.proceedBtn:Hide()
  overlay.cancelBtn:Hide()

  overlay.spinner:ClearAllPoints()
  overlay.spinner:SetPoint('CENTER', overlay, 'CENTER', 0, 20)
  overlay.spinner:Show()

  if not overlay.loadingText then
    overlay.loadingText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    overlay.loadingText:SetJustifyH('CENTER')
  end
  overlay.loadingText:ClearAllPoints()
  overlay.loadingText:SetPoint('TOP', overlay.spinner, 'BOTTOM', 0, -12)
  overlay.loadingText:SetPoint('LEFT', overlay, 'LEFT', INNER_PAD, 0)
  overlay.loadingText:SetPoint('RIGHT', overlay, 'RIGHT', -INNER_PAD, 0)
  overlay.loadingText:SetText(message)
  overlay.loadingText:SetTextColor(COLORS.title.r, COLORS.title.g, COLORS.title.b)
  overlay.loadingText:Show()
end

-- ── Row rendering ────────────────────────────────────────────────────────

local function renderActionRows(plan)
  hideAllActionRows()

  local scrollWidth = overlay.listArea:GetWidth()
  if scrollWidth < 40 then scrollWidth = 200 end
  overlay.scrollChild:SetWidth(scrollWidth)

  local rowHeight = ROW_LINE_HEIGHT * 2 + ROW_PADDING * 2 + 1
  local scrollChild = overlay.scrollChild
  local yOffset = 0
  local shown = 0

  for _, action in ipairs(plan.actions) do
    shown = shown + 1

    local row = ensureActionRow(shown)
    row:ClearAllPoints()
    row:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 0, -yOffset)
    row:SetPoint('RIGHT', scrollChild, 'RIGHT', 0, 0)
    row:SetHeight(rowHeight)

    local bg = (shown % 2 == 0) and COLORS.rowEven or COLORS.rowOdd
    row.bg:SetColorTexture(bg.r, bg.g, bg.b, bg.a)

    local sender = action.sender and Ambiguate(action.sender, 'short') or '?'
    local subject = action.subject and action.subject ~= '' and action.subject or nil
    local reason = ''

    if action.action == 'return' then
      if action.kind == 'auction_house' then
        reason = 'AH disabled'
      elseif action.description then
        local dash = action.description:match(' • (.+)$')
        if dash then reason = dash end
      end
    elseif action.action == 'pending' then
      reason = 'pending verification'
    elseif action.action == 'allowed' then
      if action.kind == 'gm' then
        reason = 'GM mail'
      elseif action.kind == 'npc_system' then
        reason = 'system mail'
      else
        reason = 'verified sender'
      end
    end

    local senderText = sender
    if subject then senderText = senderText .. '  "' .. subject .. '"' end

    row.senderLine:SetText(senderText)
    local c
    if action.action == 'return' then
      c = COLORS.returnRow
    elseif action.action == 'pending' then
      c = COLORS.pendRow
    else
      c = COLORS.allowed
    end
    row.senderLine:SetTextColor(c.r, c.g, c.b)

    row.reasonLine:SetText(reason)
    row.reasonLine:SetTextColor(COLORS.reason.r, COLORS.reason.g, COLORS.reason.b)

    row:Show()
    yOffset = yOffset + rowHeight
  end

  scrollChild:SetHeight(math.max(1, yOffset))
end

-- ── Plan display ─────────────────────────────────────────────────────────

local function renderPlanDisplay(plan, phase)
  overlay.spinner:Hide()
  overlay.spinner:ClearAllPoints()
  overlay.spinner:SetPoint('TOP', overlay, 'TOP', 0, -TOP_PAD)
  if overlay.loadingText then overlay.loadingText:Hide() end
  overlay.titleText:SetText('Guild Found Mail')
  overlay.titleText:SetTextColor(COLORS.title.r, COLORS.title.g, COLORS.title.b)

  -- Subtitle stays the same regardless of phase
  overlay.subtitleText:SetText('Resolve flagged mail before access can be granted:')
  overlay.subtitleText:SetTextColor(COLORS.subtitle.r, COLORS.subtitle.g, COLORS.subtitle.b)
  overlay.subtitleText:Show()
  overlay.listArea:Show()

  renderActionRows(plan)

  -- Footer: shows processing status during work, counts otherwise
  if phase == 'verifying' then
    overlay.footerText:SetText('Verifying ' .. (plan.pendingCount or 0) .. ' sender(s)...')
    overlay.footerText:SetTextColor(COLORS.pendRow.r, COLORS.pendRow.g, COLORS.pendRow.b)
  elseif phase == 'executing' then
    overlay.footerText:SetText('Returning mail...')
    overlay.footerText:SetTextColor(COLORS.pendRow.r, COLORS.pendRow.g, COLORS.pendRow.b)
  else
    local footerParts = {}
    if plan.returnCount > 0 then
      footerParts[#footerParts + 1] = plan.returnCount .. ' to return'
    end
    if plan.pendingCount > 0 then
      footerParts[#footerParts + 1] = plan.pendingCount .. ' pending'
    end
    if plan.allowedCount > 0 then
      footerParts[#footerParts + 1] = plan.allowedCount .. ' allowed'
    end
    overlay.footerText:SetText(table.concat(footerParts, '   ·   '))
    overlay.footerText:SetTextColor(COLORS.title.r, COLORS.title.g, COLORS.title.b)
  end
  overlay.footerText:Show()

  -- Cancel is always available
  overlay.cancelBtn:Show()
  overlay.cancelBtn:Enable()

  -- Proceed: always visible, text and state change per phase
  overlay.proceedBtn:Show()
  if phase == 'verifying' or phase == 'executing' then
    overlay.proceedBtn:Disable()
  else
    overlay.proceedBtn:Enable()
  end
  if plan.requiresPending then
    overlay.proceedBtn:SetText('Verify')
  elseif plan.requiresReturn then
    overlay.proceedBtn:SetText('Return')
  else
    overlay.proceedBtn:SetText('Proceed')
  end
end

-- ── Main refresh ─────────────────────────────────────────────────────────

local function refreshMailOverlay()
  if not overlay or not overlay:IsShown() then return end

  local session = RaceLocked_GetMailAccessSession and RaceLocked_GetMailAccessSession()
  local loading = not session or not session.plan or session.phase == 'loading'

  if loading then
    showLoadingState('Checking mailbox...')
    return
  end

  local plan = session.plan
  local phase = session.phase

  if not session.statusPrinted then
    session.statusPrinted = true
    if plan.requiresAction then
      RaceLocked_PrintRestrictionMessage('Mail contents need resolution.')
    else
      RaceLocked_PrintRestrictionMessage('Mail contents verified.')
    end
  end

  if not plan.requiresAction then
    RaceLocked_ApproveMailAccessSession(function()
      RaceLocked_HideMailVerificationOverlay()
    end)
    return
  end

  renderPlanDisplay(plan, phase)
end

-- ── Tooltip helper ───────────────────────────────────────────────────────

local function updateProceedTooltip(self)
  if not GameTooltip then return end
  GameTooltip:SetOwner(self, 'ANCHOR_TOP')

  local sess = RaceLocked_GetMailAccessSession and RaceLocked_GetMailAccessSession()
  local plan = sess and sess.plan
  if not plan then
    GameTooltip:AddLine('Proceed', 1, 0.82, 0)
    GameTooltip:Show()
    return
  end

  if plan.requiresPending then
    GameTooltip:AddLine('Verify unknown senders', 1, 0.82, 0)
    GameTooltip:AddLine(
      plan.pendingCount .. ' sender(s) will be checked via addon handshake.',
      1, 1, 1, true
    )
  elseif plan.requiresReturn then
    GameTooltip:AddLine('Return flagged mail', 1, 0.82, 0)
    GameTooltip:AddLine(
      plan.returnCount .. ' message(s) will be returned to their sender.',
      1, 1, 1, true
    )
  else
    GameTooltip:AddLine('Proceed', 1, 0.82, 0)
  end
  GameTooltip:Show()
end

-- ── Frame creation ───────────────────────────────────────────────────────

local function ensureOverlay()
  if overlay then return overlay end
  if not MailFrame then return nil end

  overlay = CreateFrame('Frame', 'RaceLockedMailVerificationOverlay', MailFrame, 'BackdropTemplate')
  overlay:SetFrameStrata('DIALOG')
  overlay:SetFrameLevel(MailFrame:GetFrameLevel() + 20)
  overlay:EnableMouse(true)
  overlay:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  overlay:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
  overlay:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  -- Spinner (centered, shown during loading)
  overlay.spinner = overlay:CreateTexture(nil, 'ARTWORK')
  overlay.spinner:SetTexture('Interface\\COMMON\\StreamBackground')
  overlay.spinner:SetSize(32, 32)
  overlay.spinner:SetPoint('TOP', overlay, 'TOP', 0, -TOP_PAD)

  -- Title
  overlay.titleText = overlay:CreateFontString(nil, 'OVERLAY', TITLE_FONT)
  overlay.titleText:SetPoint('TOPLEFT', overlay, 'TOPLEFT', INNER_PAD, -TOP_PAD)
  overlay.titleText:SetPoint('RIGHT', overlay, 'RIGHT', -INNER_PAD, 0)
  overlay.titleText:SetJustifyH('LEFT')

  -- Subtitle (below title)
  overlay.subtitleText = overlay:CreateFontString(nil, 'OVERLAY', BODY_FONT)
  overlay.subtitleText:SetPoint('TOPLEFT', overlay.titleText, 'BOTTOMLEFT', 0, -8)
  overlay.subtitleText:SetPoint('RIGHT', overlay, 'RIGHT', -INNER_PAD, 0)
  overlay.subtitleText:SetJustifyH('LEFT')
  overlay.subtitleText:SetWordWrap(true)

  -- Scrollable action list (below subtitle, above footer)
  overlay.listArea = CreateFrame('ScrollFrame', 'RaceLocked_MailListScroll', overlay, 'UIPanelScrollFrameTemplate')
  overlay.listArea:SetPoint('TOPLEFT', overlay.subtitleText, 'BOTTOMLEFT', 0, -12)
  overlay.listArea:SetPoint('RIGHT', overlay, 'RIGHT', -INNER_PAD - 22, 0)
  overlay.listArea:SetPoint('BOTTOM', overlay, 'BOTTOM', 0, BUTTON_HEIGHT + BTN_BOTTOM_PAD + 38)

  overlay.scrollChild = CreateFrame('Frame', nil, overlay.listArea)
  overlay.scrollChild:SetWidth(overlay.listArea:GetWidth())
  overlay.listArea:SetScrollChild(overlay.scrollChild)
  overlay.scrollChild:SetHeight(1)
  overlay.actionRows = {}

  -- Footer (above buttons)
  overlay.footerText = overlay:CreateFontString(nil, 'OVERLAY', FOOTER_FONT)
  overlay.footerText:SetPoint('BOTTOM', overlay, 'BOTTOM', 0, BUTTON_HEIGHT + BTN_BOTTOM_PAD + 16)
  overlay.footerText:SetPoint('LEFT', overlay, 'LEFT', INNER_PAD, 0)
  overlay.footerText:SetPoint('RIGHT', overlay, 'RIGHT', -INNER_PAD, 0)
  overlay.footerText:SetJustifyH('CENTER')

  -- Cancel (left of center)
  overlay.cancelBtn = CreateFrame('Button', nil, overlay, 'UIPanelButtonTemplate')
  overlay.cancelBtn:SetSize(100, BUTTON_HEIGHT)
  overlay.cancelBtn:SetPoint('BOTTOMRIGHT', overlay, 'BOTTOM', -BTN_CENTER_GAP, BTN_BOTTOM_PAD)
  overlay.cancelBtn:SetText('Cancel')
  overlay.cancelBtn:SetScript('OnClick', function()
    if RaceLocked_CancelMailAccessSession then
      RaceLocked_CancelMailAccessSession()
    end
    RaceLocked_HideMailVerificationOverlay()
  end)

  -- Proceed (right of center)
  overlay.proceedBtn = CreateFrame('Button', nil, overlay, 'UIPanelButtonTemplate')
  overlay.proceedBtn:SetSize(100, BUTTON_HEIGHT)
  overlay.proceedBtn:SetPoint('BOTTOMLEFT', overlay, 'BOTTOM', BTN_CENTER_GAP, BTN_BOTTOM_PAD)
  overlay.proceedBtn:SetText('Proceed')
  overlay.proceedBtn:SetScript('OnEnter', updateProceedTooltip)
  overlay.proceedBtn:SetScript('OnLeave', function()
    if GameTooltip then GameTooltip:Hide() end
  end)
  overlay.proceedBtn:SetScript('OnClick', function()
    if RaceLocked_ApproveMailAccessSession then
      RaceLocked_ApproveMailAccessSession(function()
        RaceLocked_HideMailVerificationOverlay()
      end)
    end
    refreshMailOverlay()
  end)

  overlay:SetScript('OnUpdate', updateSpinner)
  return overlay
end

function RaceLocked_ShowMailVerificationOverlay()
  if not MailFrame then return end
  local frame = ensureOverlay()
  if not frame then return end

  frame:ClearAllPoints()
  frame:SetAllPoints(MailFrame)
  frame:Show()
  refreshMailOverlay()
end

function RaceLocked_HideMailVerificationOverlay()
  if overlay then
    overlay:Hide()
  end
end

function RaceLocked_RefreshMailVerificationDisplay()
  refreshMailOverlay()
end
