-- Faction race grid: four playable races for your faction in a 2×2 layout (no champion / average panel).

local MID_GAP = 6
local OUTER_PAD_Y = 4
local TITLE_TOP_PAD = 8
local TITLE_ROW_H = 18
local GAP_AFTER_TITLE = 6
local STATS_ROW_H = 46
local ROW_GAP = 6
local GAP_AFTER_GRID = 6
local REFRESH_ROW_H = 26
local EXPLAIN_TOP_GAP = 8
local FOOTER_TOP_GAP = 8
local INNER_PAD = 8

local EXPLAIN_TEXT =
  'Race Locked will automatically remove you from groups that contain players from other races to your own.\n\nThe race averages compute the average level of each race in your faction.'

local ACCENT_W = 3
local ACCENT_INSET_X = 3
local ACCENT_INSET_Y = 1
local FACTION_ICON_SIZE = 28
local GAP_AFTER_ACCENT = 7
local GAP_AFTER_ICON = 6

local LABEL_GOLD = { 1, 0.92, 0.62 }
local MUTED = { 0.62, 0.6, 0.55 }

local AP_BG = { r = 0.08, g = 0.1, b = 0.14, a = 0.94 }
local AP_BORDER = { r = 0.38, g = 0.45, b = 0.52, a = 0.88 }

-- Per-race crests under Interface\Icons (load reliably in-game; glue CharacterCreate files are not usable from addons).
--- @type table<string, string>
local RACE_ICON_TEXTURE = {
  Human = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Human',
  Dwarf = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Dwarf',
  NightElf = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Nightelf',
  Gnome = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Gnome',
  Orc = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Orc',
  Troll = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Troll',
  Tauren = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Tauren',
  Scourge = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Scourge',
}

local function raceIconTexture(token)
  return RACE_ICON_TEXTURE[token] or RACE_ICON_TEXTURE.Human
end

local CELL_BACKDROP = {
  bgFile = 'Interface\\Buttons\\WHITE8x8',
  edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
  tile = false,
  edgeSize = 8,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

-- Per-race accent (left bar); order matches panes 1–4 for that faction.
local ALLIANCE_RACE_ACCENT = {
  { 0.78, 0.52, 0.28 }, -- Dwarf
  { 0.52, 0.35, 0.82 }, -- Night Elf
  { 0.72, 0.62, 0.42 }, -- Human
  { 0.88, 0.45, 0.72 }, -- Gnome
}

local HORDE_RACE_ACCENT = {
  { 0.32, 0.72, 0.28 }, -- Orc
  { 0.18, 0.58, 0.85 }, -- Troll
  { 0.68, 0.48, 0.32 }, -- Tauren
  { 0.42, 0.68, 0.52 }, -- Undead
}

local function textLeftOffset()
  return ACCENT_INSET_X + ACCENT_W + GAP_AFTER_ACCENT + FACTION_ICON_SIZE + GAP_AFTER_ICON
end

--- Mean level across current guild roster rows (nil if not in a guild or roster empty).
local function getGuildAverageLevel()
  if not IsInGuild or not IsInGuild() then
    return nil
  end
  local total = select(1, GetNumGuildMembers(true))
  if not total or total < 1 then
    total = select(1, GetNumGuildMembers())
  end
  total = tonumber(total) or 0
  if total < 1 then
    return nil
  end
  local sum = 0
  local n = 0
  for i = 1, total do
    local _, _, _, level = GetGuildRosterInfo(i)
    local lv = tonumber(level)
    if lv and lv >= 1 then
      sum = sum + lv
      n = n + 1
    end
  end
  if n < 1 then
    return nil
  end
  return sum / n
end

local function printGuildAverageAfterRefresh()
  local avg = getGuildAverageLevel()
  if avg then
    local n = math.floor(avg + 0.5)
    print(
      string.format('|cfffcdd76[Race Locked]|r New race average: |cffffffff%d|r', n)
    )
  else
    print(
      '|cfff44336[Race Locked]|r No average yet (not in a guild or empty roster).'
    )
  end
end

--- @param parent Frame
--- @param rightInset number optional right inset (legacy; kept for call compatibility)
--- @return Frame root
--- @return number total height
function RaceLocked_CreateFactionRaceGrid(parent, rightInset)
  rightInset = rightInset or 0

  -- Final height set in layoutGrid (includes explainer wrap height).
  local totalH = OUTER_PAD_Y
    + TITLE_TOP_PAD
    + TITLE_ROW_H
    + GAP_AFTER_TITLE
    + STATS_ROW_H * 2
    + ROW_GAP
    + GAP_AFTER_GRID
    + REFRESH_ROW_H
    + EXPLAIN_TOP_GAP
    + 72
    + FOOTER_TOP_GAP
    + 20
    + OUTER_PAD_Y
  local root = CreateFrame('Frame', nil, parent)
  root:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, 0)
  root:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', -rightInset, 0)
  root:SetHeight(totalH)

  local titleLabel = root:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  titleLabel:SetJustifyH('CENTER')
  titleLabel:SetText('Average Levels')
  titleLabel:SetTextColor(LABEL_GOLD[1], LABEL_GOLD[2], LABEL_GOLD[3])

  local refreshRow = CreateFrame('Frame', nil, root)
  refreshRow:SetHeight(REFRESH_ROW_H)
  local refreshBtn = CreateFrame('Button', nil, refreshRow, 'UIPanelButtonTemplate')
  refreshBtn:SetText('Refresh')
  refreshBtn:SetSize(120, REFRESH_ROW_H - 2)
  refreshBtn:SetPoint('CENTER', refreshRow, 'CENTER', 0, 0)

  local explainer = root:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  explainer:SetJustifyH('LEFT')
  explainer:SetJustifyV('TOP')
  explainer:SetWordWrap(true)
  explainer:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
  explainer:SetText(EXPLAIN_TEXT)
  if explainer.SetMaxLines then
    explainer:SetMaxLines(99)
  end

  local footerLabel = root:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  footerLabel:SetJustifyH('CENTER')
  footerLabel:SetJustifyV('TOP')
  footerLabel:SetText('More to come!')
  footerLabel:SetTextColor(LABEL_GOLD[1], LABEL_GOLD[2], LABEL_GOLD[3])

  local playerFaction = UnitFactionGroup and UnitFactionGroup('player') or 'Alliance'
  local isHorde = playerFaction == 'Horde'
  local raceAccents = isHorde and HORDE_RACE_ACCENT or ALLIANCE_RACE_ACCENT
  local raceTokens = isHorde and { 'Orc', 'Troll', 'Tauren', 'Scourge' }
    or { 'Dwarf', 'NightElf', 'Human', 'Gnome' }

  local playerRaceToken = ''
  if UnitRace then
    local _, token = UnitRace('player')
    if token and token ~= '' then
      playerRaceToken = token
    end
  end

  local panes = {}
  local labels = {}
  local details = {}
  local accents = {}
  local icons = {}

  for i = 1, 4 do
    local f = CreateFrame('Frame', nil, root, 'BackdropTemplate')
    f:SetBackdrop(CELL_BACKDROP)
    f:SetBackdropColor(AP_BG.r, AP_BG.g, AP_BG.b, AP_BG.a)
    f:SetBackdropBorderColor(AP_BORDER.r, AP_BORDER.g, AP_BORDER.b, AP_BORDER.a)
    f:SetHeight(STATS_ROW_H)
    panes[i] = f

    local ac = raceAccents[i]
    local accent = f:CreateTexture(nil, 'BORDER')
    accent:SetColorTexture(ac[1], ac[2], ac[3], 1)
    accent:SetWidth(ACCENT_W)
    accent:SetPoint('TOPLEFT', f, 'TOPLEFT', ACCENT_INSET_X, -ACCENT_INSET_Y)
    accent:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', ACCENT_INSET_X, ACCENT_INSET_Y)
    accents[i] = accent

    -- OVERLAY draws above the cell backdrop; full-bleed portrait per race (not the shared atlas strip).
    local icon = f:CreateTexture(nil, 'OVERLAY')
    local token = raceTokens[i]
    icon:SetTexture(raceIconTexture(token))
    icon:SetTexCoord(0, 1, 0, 1)
    icon:SetSize(FACTION_ICON_SIZE, FACTION_ICON_SIZE)
    icon:Show()
    icons[i] = icon
  end

  for i = 1, 4 do
    local lbl = panes[i]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    lbl:SetJustifyH('LEFT')
    lbl:SetTextColor(LABEL_GOLD[1] * 0.9, LABEL_GOLD[2] * 0.9, LABEL_GOLD[3] * 0.9)
    labels[i] = lbl
    local det = panes[i]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    det:SetJustifyH('LEFT')
    det:SetWordWrap(true)
    det:SetText('coming soon')
    det:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
    details[i] = det
  end

  if isHorde then
    labels[1]:SetText('Orc')
    labels[2]:SetText('Troll')
    labels[3]:SetText('Tauren')
    labels[4]:SetText('Undead')
  else
    labels[1]:SetText('Dwarf')
    labels[2]:SetText('Night Elf')
    labels[3]:SetText('Human')
    labels[4]:SetText('Gnome')
  end

  local tx = textLeftOffset()

  local function refreshRaceDetails()
    local avg = getGuildAverageLevel()
    local avgStr
    if avg then
      avgStr = tostring(math.floor(avg + 0.5))
    end
    for i = 1, 4 do
      if raceTokens[i] == playerRaceToken then
        if avgStr then
          details[i]:SetText(avgStr)
          details[i]:SetTextColor(0.82, 0.8, 0.74)
        else
          details[i]:SetText('—')
          details[i]:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
        end
      else
        details[i]:SetText('coming soon')
        details[i]:SetTextColor(MUTED[1], MUTED[2], MUTED[3])
      end
    end
  end

  local function layoutStatPane(labelFs, detailFs, pane)
    labelFs:ClearAllPoints()
    detailFs:ClearAllPoints()
    labelFs:SetPoint('LEFT', pane, 'LEFT', tx, 0)
    labelFs:SetPoint('RIGHT', pane, 'RIGHT', -INNER_PAD, 0)
    labelFs:SetPoint('BOTTOM', pane, 'CENTER', 0, 4)
    detailFs:SetPoint('LEFT', pane, 'LEFT', tx, 0)
    detailFs:SetPoint('RIGHT', pane, 'RIGHT', -INNER_PAD, 0)
    detailFs:SetPoint('TOP', pane, 'CENTER', 0, -4)
  end

  local function layoutGrid()
    local rw = root:GetWidth()
    if (not rw or rw < 2) and parent and parent.GetWidth then
      rw = math.max(0, parent:GetWidth() - rightInset)
    end
    if rw < 80 then
      rw = 400
    end

    local rowInner = rw - MID_GAP
    local wLeft = math.floor(rowInner / 2)
    local wRight = rowInner - wLeft

    local gridTop = OUTER_PAD_Y + TITLE_TOP_PAD + TITLE_ROW_H + GAP_AFTER_TITLE
    titleLabel:ClearAllPoints()
    titleLabel:SetPoint('TOPLEFT', root, 'TOPLEFT', 0, -(OUTER_PAD_Y + TITLE_TOP_PAD))
    titleLabel:SetPoint('TOPRIGHT', root, 'TOPRIGHT', 0, -(OUTER_PAD_Y + TITLE_TOP_PAD))

    panes[1]:ClearAllPoints()
    panes[1]:SetPoint('TOPLEFT', root, 'TOPLEFT', 0, -gridTop)
    panes[1]:SetSize(wLeft, STATS_ROW_H)

    panes[2]:ClearAllPoints()
    panes[2]:SetPoint('TOPLEFT', panes[1], 'TOPRIGHT', MID_GAP, 0)
    panes[2]:SetSize(wRight, STATS_ROW_H)

    panes[3]:ClearAllPoints()
    panes[3]:SetPoint('TOPLEFT', panes[1], 'BOTTOMLEFT', 0, -ROW_GAP)
    panes[3]:SetSize(wLeft, STATS_ROW_H)

    panes[4]:ClearAllPoints()
    panes[4]:SetPoint('TOPLEFT', panes[3], 'TOPRIGHT', MID_GAP, 0)
    panes[4]:SetSize(wRight, STATS_ROW_H)

    for j = 1, 4 do
      local icon = icons[j]
      icon:ClearAllPoints()
      icon:SetSize(FACTION_ICON_SIZE, FACTION_ICON_SIZE)
      icon:SetPoint('LEFT', panes[j], 'LEFT', ACCENT_INSET_X + ACCENT_W + GAP_AFTER_ACCENT, 0)
      local topInset = math.max(2, (STATS_ROW_H - FACTION_ICON_SIZE) / 2)
      icon:SetPoint('TOP', panes[j], 'TOP', 0, -topInset)
    end

    for i = 1, 4 do
      layoutStatPane(labels[i], details[i], panes[i])
    end

    refreshRow:ClearAllPoints()
    refreshRow:SetPoint('TOPLEFT', panes[3], 'BOTTOMLEFT', 0, -GAP_AFTER_GRID)
    refreshRow:SetPoint('TOPRIGHT', panes[4], 'BOTTOMRIGHT', 0, -GAP_AFTER_GRID)

    explainer:ClearAllPoints()
    local explainW = math.max(40, rw - INNER_PAD * 2)
    explainer:SetWidth(explainW)
    explainer:SetPoint('TOPLEFT', refreshRow, 'BOTTOMLEFT', INNER_PAD, -EXPLAIN_TOP_GAP)

    local explH = explainer:GetStringHeight()
    local _, fontH = explainer:GetFont()
    fontH = tonumber(fontH) or 11
    -- GetStringHeight can under-report one frame; pad by part of a line so root is not too short (avoids “…” truncation).
    explH = explH + math.ceil(fontH * 0.75)

    footerLabel:ClearAllPoints()
    footerLabel:SetPoint('TOPLEFT', explainer, 'BOTTOMLEFT', INNER_PAD, -FOOTER_TOP_GAP)
    footerLabel:SetPoint('TOPRIGHT', explainer, 'BOTTOMRIGHT', -INNER_PAD, -FOOTER_TOP_GAP)
    local footerH = footerLabel:GetStringHeight()

    local newH = gridTop
      + STATS_ROW_H * 2
      + ROW_GAP
      + GAP_AFTER_GRID
      + REFRESH_ROW_H
      + EXPLAIN_TOP_GAP
      + explH
      + FOOTER_TOP_GAP
      + footerH
      + OUTER_PAD_Y
    root:SetHeight(newH)
    totalH = newH

    refreshRaceDetails()
  end

  refreshBtn:SetScript('OnClick', function()
    if GuildRoster then
      GuildRoster()
    end
    refreshRaceDetails()
    if C_Timer and C_Timer.After then
      C_Timer.After(0, function()
        refreshRaceDetails()
        printGuildAverageAfterRefresh()
      end)
    else
      printGuildAverageAfterRefresh()
    end
  end)

  if GuildRoster then
    GuildRoster()
  end

  root:RegisterEvent('GUILD_ROSTER_UPDATE')
  root:RegisterEvent('PLAYER_GUILD_UPDATE')
  root:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_GUILD_UPDATE' or event == 'GUILD_ROSTER_UPDATE' then
      refreshRaceDetails()
    end
  end)

  root:SetScript('OnSizeChanged', layoutGrid)
  root:SetScript('OnShow', function()
    layoutGrid()
    if C_Timer and C_Timer.After then
      C_Timer.After(0, layoutGrid)
    end
  end)
  layoutGrid()

  return root, totalH
end
