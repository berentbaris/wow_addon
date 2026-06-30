local TITLE_TOP_OFFSET = -30
local LIST_LEFT_OFFSET = RaceLocked_GuildVerification.LIST_LEFT_OFFSET
local TITLE_BOTTOM_GAP = 16
local ROW_GAP = 12
local HELPER_INDENT = 12
local HELPER_TOP_GAP = 4

local STATUS_TITLE = {
  valid = {
    text = 'Guild Found Trading is unlocked',
    r = 0.35,
    g = 0.8,
    b = 0.35,
  },
  invalid = {
    text = 'Guild Found Trading is locked',
    r = 0.82,
    g = 0.33,
    b = 0.33,
  },
}

local CHECK_PASS_COLOR = {
  r = 0.35,
  g = 0.8,
  b = 0.35,
}

local CHECK_FAIL_COLOR = {
  r = 0.82,
  g = 0.33,
  b = 0.33,
}

local CHECK_WARNING_COLOR = {
  r = 0.95,
  g = 0.82,
  b = 0.2,
}

local CHECK_INACTIVE_COLOR = {
  r = 0.55,
  g = 0.55,
  b = 0.55,
}

local CHECK_OVERRIDE_COLOR = {
  r = 0.4,
  g = 0.7,
  b = 1.0,
}

local function getDetectedOnHelperText(failedAt)
  if failedAt then
    return 'Detected on ' .. date('%d %b %Y', failedAt)
  end
end

local function getVerificationChecks()
  local playerMoneyValidationFailed = RaceLocked_GetDBValue('playerMoneyValidationFailed')
  local hasBeenMaxLevelAndSelfFound = RaceLocked_GetDBValue('hasBeenMaxLevelAndSelfFound')

  if playerMoneyValidationFailed == nil then
    playerMoneyValidationFailed = false
  end

  -- Source the raw per-row conditions from the shared atomic predicates so the
  -- display can never diverge from the enforcement logic. Fall back to direct
  -- DB reads only if the predicates aren't loaded yet (TOC load-order safety).
  local maxLevelSelfFound = hasBeenMaxLevelAndSelfFound == true
  if RaceLocked_IsLocalMaxLevelSelfFound then
    maxLevelSelfFound = RaceLocked_IsLocalMaxLevelSelfFound()
  end

  local tampered = playerMoneyValidationFailed == true
  if RaceLocked_IsLocalTampered then
    tampered = RaceLocked_IsLocalTampered()
  end

  local gmOverride = RaceLocked_Roster_GetGMOverrideForSelf and RaceLocked_Roster_GetGMOverrideForSelf() or {}
  local hasRosterOverride = gmOverride.verified ~= nil or gmOverride.clean ~= nil
  local hasRankOverride = RaceLocked_ShouldOverrideVerificationViaGuildNote(UnitName('player')) == true
  local hasGMOverride = hasRosterOverride or hasRankOverride

  local checks = {}

  -- 1. In guild
  checks[#checks + 1] = {
    passed = RaceLocked_IsInGuildFoundGuild(),
    passMessage = 'You are in a Guild Found guild',
    failMessage = 'You are not in a Guild Found guild',
    failHelperText = 'You must be in the Guild Found guild to unlock Guild Found',
  }

  -- 2. Reached max level as self found
  checks[#checks + 1] = {
    passed = maxLevelSelfFound,
    passMessage = 'This character reached level ' .. RACE_LOCKED_GUILD_FOUND_MAX_LEVEL .. ' whilst self found',
    failMessage = UnitLevel('player') < RACE_LOCKED_GUILD_FOUND_MAX_LEVEL
      and 'You are not yet level ' .. RACE_LOCKED_GUILD_FOUND_MAX_LEVEL
      or 'Did not turn off self found at level ' .. RACE_LOCKED_GUILD_FOUND_MAX_LEVEL,
    failHelperText = UnitLevel('player') < RACE_LOCKED_GUILD_FOUND_MAX_LEVEL
      and nil
      or 'You must be level ' .. RACE_LOCKED_GUILD_FOUND_MAX_LEVEL .. ' before turning off self found',
  }

  -- 3. Tampering
  checks[#checks + 1] = {
    passed = not tampered,
    passMessage = 'No tampering detected',
    failMessage = 'Tampering detected',
    failHelperText = tampered and getDetectedOnHelperText(
      RaceLocked_GetDBValue('playerMoneyValidationFailedAt')
    ) or nil,
  }

  -- 4. GM override • grey when absent (informational, not a blocker on its own)
  checks[#checks + 1] = {
    passed = hasGMOverride,
    passMessage = 'Manual override applied',
    passColor = CHECK_OVERRIDE_COLOR,
    failMessage = 'No manual override applied',
    failHelperText = 'You do not have a manual override from a GM',
    failColor = CHECK_INACTIVE_COLOR,
  }

  return checks
end

local function getOverallStatus(checks)
  if RaceLocked_IsInGuildFoundGuild() and RaceLocked_AmIVerified() then
    return STATUS_TITLE.valid
  else
    return STATUS_TITLE.invalid
  end
end

local function getWrapWidth(content, extraIndent)
  extraIndent = extraIndent or 0

  local width = content:GetWidth() - (LIST_LEFT_OFFSET * 2) - extraIndent

  if width < 1 then
    return 1
  end

  return width
end

local function applyWrappedText(fontString, content, extraIndent)
  fontString:SetWidth(getWrapWidth(content, extraIndent))

  fontString:SetWordWrap(true)

  fontString:SetJustifyH('LEFT')

  fontString:SetJustifyV('TOP')
end

local function ensureVerificationTabLayout(content)
  if content.verificationInitialized then return end

  content.titleLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')

  content.checkRows = {}

  content.checkHelpers = {}

  content.verificationInitialized = true
end

local function updateVerificationTabDisplay(content)
  local checks = getVerificationChecks()

  local status = getOverallStatus(checks)

  applyWrappedText(content.titleLabel, content)

  content.titleLabel:ClearAllPoints()

  content.titleLabel:SetPoint('TOPLEFT', content, 'TOPLEFT', LIST_LEFT_OFFSET, TITLE_TOP_OFFSET)

  content.titleLabel:SetText(status.text)

  content.titleLabel:SetTextColor(status.r, status.g, status.b)

  local blockEnd = content.titleLabel

  local firstRowGap = -TITLE_BOTTOM_GAP

  for index, check in ipairs(checks) do
    local row = content.checkRows[index]

    if not row then
      row = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')

      content.checkRows[index] = row
    end

    applyWrappedText(row, content)

    row:ClearAllPoints()

    row:SetPoint('TOP', blockEnd, 'BOTTOM', 0, firstRowGap)

    row:SetPoint('LEFT', content, 'LEFT', LIST_LEFT_OFFSET, 0)

    firstRowGap = -ROW_GAP

    local passed = check.passed

    local color = passed and (check.passColor or CHECK_PASS_COLOR) or (check.failColor or CHECK_FAIL_COLOR)

    row:SetText('• ' .. (passed and check.passMessage or check.failMessage))

    row:SetTextColor(color.r, color.g, color.b)

    row:Show()

    blockEnd = row

    local helper = content.checkHelpers[index]

    if check.failHelperText and not passed then
      if not helper then
        helper = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')

        content.checkHelpers[index] = helper
      end

      applyWrappedText(helper, content, HELPER_INDENT)

      helper:ClearAllPoints()

      helper:SetPoint('TOP', row, 'BOTTOM', 0, -HELPER_TOP_GAP)

      helper:SetPoint('LEFT', content, 'LEFT', LIST_LEFT_OFFSET + HELPER_INDENT, 0)

      helper:SetText(check.failHelperText)

      helper:SetTextColor(0.85, 0.85, 0.85)

      helper:Show()

      blockEnd = helper
    elseif helper then
      helper:Hide()
    end
  end

  for index = #checks + 1, #content.checkRows do
    content.checkRows[index]:Hide()
  end

  if content.checkHelpers then
    for index = #checks + 1, #content.checkHelpers do
      content.checkHelpers[index]:Hide()
    end
  end

  return blockEnd
end

-- ── Public entry point ──────────────────────────────────────────────────

function RaceLocked_InitializeGuildVerificationTab(content)
  if not content then return end

  ensureVerificationTabLayout(content)

  local blockEnd = updateVerificationTabDisplay(content)

  RaceLocked_GuildVerification_UpdateRosterSection(content, blockEnd)
end
