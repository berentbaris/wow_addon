-- Faction race grid: four playable races for your faction in a 2×2 layout (no champion / average panel).

--- @param root Frame
--- @return Frame refreshRow, Button refreshBtn
local function createChrome(root)
  local G = RaceLocked_GuildChampion

  local refreshRow = CreateFrame('Frame', nil, root)
  refreshRow:SetHeight(G.REFRESH_ROW_H)
  local refreshBtn = CreateFrame('Button', nil, refreshRow)
  refreshBtn:SetSize(30, 30)
  refreshBtn:SetPoint('BOTTOMRIGHT', refreshRow, 'BOTTOMRIGHT', -4, -5)

  local guildLoadFailFs = refreshRow:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
  guildLoadFailFs:SetPoint('RIGHT', refreshBtn, 'LEFT', -10, 0)
  guildLoadFailFs:SetJustifyH('RIGHT')
  guildLoadFailFs:SetWordWrap(true)
  guildLoadFailFs:SetWidth(420)
  guildLoadFailFs:SetTextColor(1, 0.42, 0.42)
  guildLoadFailFs:SetText('Guild Roster not ready, try again')
  guildLoadFailFs:Hide()
  refreshRow._guildLoadFailFs = guildLoadFailFs

  local refreshTex = 'Interface\\Buttons\\UI-RefreshButton'
  local loadingTex = 'Interface\\Buttons\\UI-GroupLoot-Pass-Down'
  local validTex = 'Interface\\AddOns\\RaceLocked\\Textures\\valid.png'
  refreshBtn._refreshTex = refreshTex
  refreshBtn._loadingTex = loadingTex
  refreshBtn._validTex = validTex
  refreshBtn:SetNormalTexture(refreshTex)
  refreshBtn:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square', 'ADD')
  refreshBtn:SetPushedTexture(refreshTex)
  refreshBtn:EnableMouse(true)
  refreshBtn:SetScript('OnEnter', function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:AddLine('Reload', 1, 0.92, 0.62)
    GameTooltip:AddLine('Reload guild data and broadcast to other players', 1, 1, 1)
    GameTooltip:Show()
  end)
  refreshBtn:SetScript('OnLeave', function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)

  return refreshRow, refreshBtn
end

--- @param n number|nil
--- @return string
local function formatRaceGridStatDisplay(n)
  local v = tonumber(n)
  if v == nil then
    return '-'
  end
  local rounded = math.floor(v + 0.5)
  if rounded == 0 then
    return '-'
  end
  return tostring(rounded)
end

--- @param root Frame
--- @param raceToken string API race token for icon path
--- @param raceAccent number[] rgb accent bar
--- @return Frame pane, Texture icon, FontString labelFs, FontString detailFs
local function createRaceStatPane(root, raceToken, raceAccent)
  local G = RaceLocked_GuildChampion
  local paneH = math.max(1, (tonumber(G.STATS_ROW_H) or 0) - 25)

  local f = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  f:SetBackdrop(G.CELL_BACKDROP)
  f:SetBackdropColor(G.AP_BG.r, G.AP_BG.g, G.AP_BG.b, G.AP_BG.a)
  f:SetBackdropBorderColor(G.AP_BORDER.r, G.AP_BORDER.g, G.AP_BORDER.b, G.AP_BORDER.a)
  f:SetHeight(paneH)

  local icon = f:CreateTexture(nil, 'OVERLAY')
  icon:SetTexture(RaceLocked_GuildChampion_RaceIconTexture(raceToken))
  icon:SetTexCoord(0, 1, 0, 1)
  icon:SetSize(G.FACTION_ICON_SIZE, G.FACTION_ICON_SIZE)
  icon:Show()
  icon:EnableMouse(true)
  icon:SetScript('OnEnter', function(self)
    if not GameTooltip then return end
    local raceName = (G.RACE_LABEL and G.RACE_LABEL[raceToken]) or raceToken
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:ClearLines()
    GameTooltip:AddLine(raceName, 1, 0.92, 0.62)
    GameTooltip:Show()
  end)
  icon:SetScript('OnLeave', function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)

  local lbl = f:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
  lbl:SetJustifyH('LEFT')
  lbl:SetTextColor(G.LABEL_GOLD[1] * 0.9, G.LABEL_GOLD[2] * 0.9, G.LABEL_GOLD[3] * 0.9)

  f._skullCountFs = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  f._skullCountFs:SetJustifyH('RIGHT')
  f._skullCountFs:SetTextColor(
    G.LABEL_GOLD[1] * 0.85,
    G.LABEL_GOLD[2] * 0.85,
    G.LABEL_GOLD[3] * 0.85
  )
  f._skullCountFs:SetText('-')

  f._skullIcon = f:CreateTexture(nil, 'OVERLAY')
  f._skullIcon:SetTexture('Interface\\AddOns\\RaceLocked\\Textures\\skull.png')
  f._skullIcon:SetSize(16, 16)

  f._skullInfoHit = CreateFrame('Frame', nil, f)
  f._skullInfoHit:EnableMouse(true)
  f._skullInfoHit:SetScript('OnEnter', function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:AddLine('Total number of Deaths', 1, 0.92, 0.62)
    GameTooltip:AddLine('Only includes players with the addon', 1, 1, 1)
    GameTooltip:Show()
  end)
  f._skullInfoHit:SetScript('OnLeave', function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)

  f._achievementPointsFs = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  f._achievementPointsFs:SetJustifyH('RIGHT')
  f._achievementPointsFs:SetTextColor(
    G.LABEL_GOLD[1] * 0.85,
    G.LABEL_GOLD[2] * 0.85,
    G.LABEL_GOLD[3] * 0.85
  )
  f._achievementPointsFs:SetText('-')

  f._achievementIcon = f:CreateTexture(nil, 'OVERLAY')
  f._achievementIcon:SetTexture(
    'Interface\\AddOns\\RaceLocked\\Textures\\HardcoreAchievementsButton.png'
  )
  f._achievementIcon:SetSize(16, 16)

  f._achievementInfoHit = CreateFrame('Frame', nil, f)
  f._achievementInfoHit:SetFrameLevel((f.GetFrameLevel and f:GetFrameLevel() or 0) + 6)
  f._achievementInfoHit:EnableMouse(true)
  f._achievementInfoHit:SetScript('OnEnter', function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:ClearLines()
    GameTooltip:AddLine('Race average achievement points', 1, 0.92, 0.62)
    local token = self._rlRaceToken
    if token and RaceLocked_GuildChampion and RaceLocked_GuildChampion.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and RaceLocked_AchievementTracking_GetGuildReportingCount then
      local rows = RaceLocked_GuildChampion.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[token]
      if type(rows) == 'table' then
        local totalReporting = 0
        for _, row in ipairs(rows) do
          if type(row) == 'table' and (tonumber(row.guildSize) or 0) > 0 then
            totalReporting =
              totalReporting + RaceLocked_AchievementTracking_GetGuildReportingCount(row.guildName)
          end
        end
        if totalReporting > 0 then
          GameTooltip:AddLine('Based on ' .. totalReporting .. ' players with the addon', 1, 1, 1)
        end
      end
    end
    GameTooltip:Show()
  end)
  f._achievementInfoHit:SetScript('OnLeave', function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)

  local det = f:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  det:SetJustifyH('CENTER')
  det:SetText('•')
  det:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])
  f._detailFs = det

  f._guildSectionTitle = f:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  f._guildSectionTitle:SetJustifyH('LEFT')

  f._guildNames = f:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  f._guildNames:SetJustifyH('LEFT')
  f._guildNames:SetJustifyV('TOP')
  f._guildNames:SetWordWrap(false)

  f._avgSubtitle = f:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  f._avgSubtitle:SetJustifyH('CENTER')

  f._totalPlayersSubtitle = f:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  f._totalPlayersSubtitle:SetJustifyH('CENTER')

  f._totalPlayersFs = f:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  f._totalPlayersFs:SetJustifyH('CENTER')
  f._totalPlayersFs:SetText('0')
  f._totalPlayersFs:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])

  f._total60sSubtitle = f:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  f._total60sSubtitle:SetJustifyH('CENTER')

  f._total60sFs = f:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  f._total60sFs:SetJustifyH('CENTER')
  f._total60sFs:SetText('0')
  f._total60sFs:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])

  f._classSubtitle = f:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  f._classSubtitle:SetJustifyH('CENTER')

  f._classBarHost = CreateFrame('Frame', nil, f)
  f._classBarHost:SetHeight(G.CLASS_BAR_HOST_H)

  f._classBarPctRow = CreateFrame('Frame', nil, f._classBarHost)
  f._classBarPctRow:SetHeight(G.CLASS_BAR_LABEL_ROW)

  f._classBarBarWell = CreateFrame('Frame', nil, f._classBarHost, 'BackdropTemplate')
  f._classBarBarWell:SetBackdrop(G.CLASS_BAR_CHART_BACKDROP)
  f._classBarBarWell:SetBackdropColor(0.05, 0.06, 0.08, 0.92)
  f._classBarBarWell:SetBackdropBorderColor(
    G.AP_BORDER.r,
    G.AP_BORDER.g,
    G.AP_BORDER.b,
    G.AP_BORDER.a * 0.85
  )
  f._classBarBarWell:SetHeight(G.CLASS_BAR_HEIGHT + 2 * G.CLASS_BAR_BORDER_PAD)

  f._classBarRow = CreateFrame('Frame', nil, f._classBarBarWell)
  f._classBarRow:SetHeight(G.CLASS_BAR_HEIGHT)

  f._classCol = {}
  for idx = 1, 9 do
    local col = CreateFrame('Frame', nil, f._classBarRow)
    col:SetHeight(G.CLASS_BAR_HEIGHT)
    col:EnableMouse(true)
    local tex = col:CreateTexture(nil, 'ARTWORK')
    tex:SetHeight(G.CLASS_BAR_HEIGHT)
    tex:SetPoint('TOPLEFT', col, 'TOPLEFT', 0, 0)
    tex:SetPoint('TOPRIGHT', col, 'TOPRIGHT', 0, 0)
    local pct = f._classBarPctRow:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
    pct:SetHeight(G.CLASS_BAR_LABEL_ROW)
    pct:SetJustifyH('CENTER')
    pct:SetJustifyV('BOTTOM')
    local pctHit = CreateFrame('Frame', nil, f._classBarPctRow)
    pctHit:SetFrameLevel((pct.GetFrameLevel and pct:GetFrameLevel() or 0) + 3)
    pctHit:EnableMouse(true)
    pctHit:Hide()
    local cell = {
      frame = col,
      tex = tex,
      pct = pct,
      pctHit = pctHit,
    }
    f._classCol[idx] = cell
    col._rlCell = cell
    pctHit._rlCell = cell
    col:SetScript('OnEnter', RaceLocked_GuildChampion_OnClassBarCellEnter)
    col:SetScript('OnLeave', RaceLocked_GuildChampion_OnClassBarCellLeave)
    pctHit:SetScript('OnEnter', RaceLocked_GuildChampion_OnClassBarCellEnter)
    pctHit:SetScript('OnLeave', RaceLocked_GuildChampion_OnClassBarCellLeave)
  end

  f._classBarSep = {}
  for s = 1, 8 do
    local sep = f._classBarRow:CreateTexture(nil, 'OVERLAY')
    sep:SetColorTexture(G.CLASS_BAR_SEP[1], G.CLASS_BAR_SEP[2], G.CLASS_BAR_SEP[3], 1)
    sep:SetWidth(G.CLASS_BAR_SEP_W)
    sep:SetHeight(G.CLASS_BAR_HEIGHT)
    sep:Hide()
    f._classBarSep[s] = sep
  end

  return f, icon, lbl, det
end

local function textLeftOffset()
  local G = RaceLocked_GuildChampion
  return G.ACCENT_INSET_X + G.GAP_AFTER_ACCENT + G.FACTION_ICON_SIZE + G.GAP_AFTER_ICON
end

--- @param pane Frame
--- @param labelFs FontString race name
--- @param detailFs FontString average level value
--- @param tx number left inset for text block
--- @param raceToken string UnitRace token for class availability
local function layoutRaceGridPane(pane, labelFs, detailFs, tx, raceToken)
  local G = RaceLocked_GuildChampion
  local lg = G.RACE_GRID_PANE_SECTION_GAP or 0
  local w = pane:GetWidth() - tx - G.INNER_PAD
  w = math.max(w, 48)
  local panelLeft = G.INNER_PAD
  local panelW = pane:GetWidth() - 2 * G.INNER_PAD
  panelW = math.max(panelW, 48)

  labelFs:ClearAllPoints()
  labelFs:SetPoint('TOPLEFT', pane, 'TOPLEFT', tx, -6)
  local labelW = pane._skullIcon and math.max(40, w - 56) or w
  labelFs:SetWidth(labelW)
  labelFs:SetText('')

  local guildH = pane._guildSectionTitle
  guildH:ClearAllPoints()
  guildH:SetPoint('TOPLEFT', pane, 'TOPLEFT', tx, -4 - lg)
  guildH:SetWidth(w)

  local gNames = pane._guildNames
  gNames:ClearAllPoints()
  gNames:SetPoint('TOPLEFT', guildH, 'BOTTOMLEFT', 0, -2)
  gNames:SetWidth(w)

  local avgSub = pane._avgSubtitle
  local totalSub = pane._totalPlayersSubtitle
  local totalFs = pane._totalPlayersFs
  local sixtySub = pane._total60sSubtitle
  local sixtyFs = pane._total60sFs
  local statsGap = 8
  local nGaps = 2
  local segment = math.max(24, math.floor((panelW - nGaps * statsGap) / 3))
  local avgW = segment
  local totalW = segment
  local sixtyW = math.max(24, panelW - nGaps * statsGap - avgW - totalW)
  avgSub:ClearAllPoints()
  avgSub:SetPoint('TOPLEFT', gNames, 'BOTTOMLEFT', panelLeft - tx, -(10 + lg))
  avgSub:SetWidth(avgW)

  totalSub:ClearAllPoints()
  totalSub:SetPoint('TOPLEFT', avgSub, 'TOPRIGHT', statsGap, 0)
  totalSub:SetWidth(totalW)

  sixtySub:ClearAllPoints()
  sixtySub:SetPoint('TOPLEFT', totalSub, 'TOPRIGHT', statsGap, 0)
  sixtySub:SetWidth(sixtyW)

  detailFs:ClearAllPoints()
  detailFs:SetPoint('TOPLEFT', avgSub, 'BOTTOMLEFT', 0, -2)
  detailFs:SetWidth(avgW)

  totalFs:ClearAllPoints()
  totalFs:SetPoint('TOPLEFT', totalSub, 'BOTTOMLEFT', 0, -2)
  totalFs:SetWidth(totalW)

  sixtyFs:ClearAllPoints()
  sixtyFs:SetPoint('TOPLEFT', sixtySub, 'BOTTOMLEFT', 0, -2)
  sixtyFs:SetWidth(sixtyW)

  local cSub = pane._classSubtitle
  cSub:ClearAllPoints()
  cSub:SetPoint('TOPLEFT', detailFs, 'BOTTOMLEFT', 0, -(1 + lg))
  cSub:SetWidth(panelW)

  local host = pane._classBarHost
  host:ClearAllPoints()
  host:SetPoint('TOPLEFT', cSub, 'BOTTOMLEFT', 0, -4)
  host:SetWidth(panelW)
  host:SetHeight(G.CLASS_BAR_HOST_H)

  local pctRow = pane._classBarPctRow
  pctRow:ClearAllPoints()
  pctRow:SetPoint('TOPLEFT', host, 'TOPLEFT', 0, 0)
  pctRow:SetWidth(panelW)
  pctRow:SetHeight(G.CLASS_BAR_LABEL_ROW)

  local well = pane._classBarBarWell
  well:ClearAllPoints()
  well:SetPoint('BOTTOMLEFT', host, 'BOTTOMLEFT', 0, 0)
  well:SetWidth(panelW)
  well:SetHeight(G.CLASS_BAR_HEIGHT + 2 * G.CLASS_BAR_BORDER_PAD)

  local pad = G.CLASS_BAR_BORDER_PAD
  local row = pane._classBarRow
  row:ClearAllPoints()
  row:SetPoint('TOPLEFT', well, 'TOPLEFT', pad, -pad)
  row:SetPoint('TOPRIGHT', well, 'TOPRIGHT', -pad, -pad)
  row:SetHeight(G.CLASS_BAR_HEIGHT)

  if pane._skullIcon then
    pane._skullIcon:ClearAllPoints()
    pane._skullIcon:SetPoint('TOPRIGHT', pane, 'TOPRIGHT', -G.INNER_PAD + 4, -4)
  end
  if pane._skullCountFs and pane._skullIcon then
    pane._skullCountFs:ClearAllPoints()
    pane._skullCountFs:SetPoint('RIGHT', pane._skullIcon, 'LEFT', -4, -1)
  end
  if pane._skullInfoHit and pane._skullIcon then
    pane._skullInfoHit:ClearAllPoints()
    pane._skullInfoHit:SetPoint('TOPRIGHT', pane._skullIcon, 'TOPRIGHT', 0, 0)
    pane._skullInfoHit:SetPoint('BOTTOMLEFT', pane._skullIcon, 'BOTTOMLEFT', -24, 0)
  end
  if pane._achievementIcon and pane._skullIcon then
    pane._achievementIcon:ClearAllPoints()
    pane._achievementIcon:SetPoint('TOPRIGHT', pane._skullIcon, 'BOTTOMRIGHT', 0, -3)
  end
  if pane._achievementPointsFs and pane._achievementIcon then
    pane._achievementPointsFs:ClearAllPoints()
    pane._achievementPointsFs:SetPoint('RIGHT', pane._achievementIcon, 'LEFT', -4, -1)
  end
  if pane._achievementInfoHit and pane._achievementIcon and pane._achievementPointsFs then
    pane._achievementInfoHit:ClearAllPoints()
    pane._achievementInfoHit:SetPoint('TOPRIGHT', pane._achievementIcon, 'TOPRIGHT', 0, 0)
    pane._achievementInfoHit:SetPoint('BOTTOMLEFT', pane._achievementPointsFs, 'BOTTOMLEFT', 0, 0)
  end
end

--- Sort key: higher average first; ties keep stable order by race index.
local function computeRaceGridSortOrder(raceTokens)
  local n = type(raceTokens) == 'table' and #raceTokens or 0
  local rows = {}
  for i = 1, n do
    local token = raceTokens[i]
    local agg =
      RaceLocked_GuildChampion_GetAggregatedMockForRace and RaceLocked_GuildChampion_GetAggregatedMockForRace(
        token
      )
    local avg = agg and agg.averageLevel
    local avn = type(avg) == 'number' and avg or -math.huge
    rows[#rows + 1] = {
      idx = i,
      avg = avn,
    }
  end
  table.sort(rows, function(a, b)
    if a.avg ~= b.avg then
      return a.avg > b.avg
    end
    return a.idx < b.idx
  end)
  local order = {}
  local rankByIdx = {}
  for slot = 1, n do
    order[slot] = rows[slot].idx
    rankByIdx[rows[slot].idx] = slot
  end
  return order, rankByIdx
end

--- Lay out scrollable 2-column race grid (all races) and fixed refresh row on `root`.
--- @param ctx table
local function layoutGrid(ctx)
  local G = RaceLocked_GuildChampion
  local paneH = math.max(1, (tonumber(G.STATS_ROW_H) or 0) - 30)
  local root = ctx.root
  local parent = ctx.parent
  local scrollFrame = ctx.scrollFrame
  local scrollChild = ctx.scrollChild

  local rw = root:GetWidth()
  if (not rw or rw < 2) and parent and parent.GetWidth then
    rw = math.max(0, parent:GetWidth())
  end
  if rw < 80 then
    rw = 400
  end

  local sw = scrollFrame and scrollFrame.GetWidth and scrollFrame:GetWidth() or rw
  if not sw or sw < 40 then
    sw = rw
  end
  local pad = tonumber(G.RACE_GRID_SCROLL_BAR_PAD) or 28
  scrollChild:SetWidth(math.max(80, sw - pad))

  local rowInner = scrollChild:GetWidth() - G.MID_GAP
  local wLeft = math.floor(rowInner / 2)
  local wRight = rowInner - wLeft

  local gridTop = G.OUTER_PAD_Y + G.GRID_TOP_OFFSET

  local panes = ctx.panes
  local raceTokens = ctx.raceTokens
  local numRaces = #raceTokens
  if numRaces < 1 then return end
  local numRows = math.max(1, math.ceil(numRaces / 2))

  local order, rankByIdx = computeRaceGridSortOrder(raceTokens)
  ctx.sortOrder = order

  for row = 1, numRows do
    local li = (row - 1) * 2 + 1
    local ri = (row - 1) * 2 + 2
    local leftIdx = order[li]
    local rightIdx = ri <= numRaces and order[ri] or nil

    panes[leftIdx]:ClearAllPoints()
    panes[leftIdx]:SetSize(wLeft, paneH)
    if row == 1 then
      panes[leftIdx]:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 0, -gridTop)
    else
      local aboveLeft = order[(row - 2) * 2 + 1]
      panes[leftIdx]:SetPoint('TOPLEFT', panes[aboveLeft], 'BOTTOMLEFT', 0, -G.ROW_GAP)
    end

    if rightIdx then
      panes[rightIdx]:ClearAllPoints()
      panes[rightIdx]:SetSize(wRight, paneH)
      panes[rightIdx]:SetPoint('TOPLEFT', panes[leftIdx], 'TOPRIGHT', G.MID_GAP, 0)
    end
  end

  local icons = ctx.icons
  for j = 1, numRaces do
    local icon = icons[j]
    icon:ClearAllPoints()
    icon:SetSize(G.FACTION_ICON_SIZE, G.FACTION_ICON_SIZE)
    icon:SetPoint('LEFT', panes[j], 'LEFT', G.ACCENT_INSET_X + G.GAP_AFTER_ACCENT - 3, 0)
    icon:SetPoint('TOP', panes[j], 'TOP', 0, -6)
  end

  local tx = textLeftOffset()
  for i = 1, numRaces do
    layoutRaceGridPane(panes[i], ctx.labels[i], ctx.details[i], tx, ctx.raceTokens[i])
    ctx.labels[i]:SetText('')
    if panes[i]._skullCountFs then
      local deaths = 0
      if RaceLocked_GuildChampion_GetTotalGuildDeathsForRace then
        deaths = RaceLocked_GuildChampion_GetTotalGuildDeathsForRace(ctx.raceTokens[i]) or 0
      end
      panes[i]._skullCountFs:SetText(formatRaceGridStatDisplay(deaths))
    end
    if panes[i]._achievementPointsFs then
      local ach = 0
      if RaceLocked_GuildChampion_GetWeightedGuildAchievementsAverageForRace then
        ach =
          RaceLocked_GuildChampion_GetWeightedGuildAchievementsAverageForRace(
            ctx.raceTokens[i]
          ) or 0
      end
      panes[i]._achievementPointsFs:SetText(formatRaceGridStatDisplay(ach))
    end
    if panes[i]._achievementInfoHit then
      panes[i]._achievementInfoHit._rlRaceToken = ctx.raceTokens[i]
    end
  end

  ctx.refreshRow:ClearAllPoints()
  ctx.refreshRow:SetPoint('BOTTOMLEFT', root, 'BOTTOMLEFT', 0, G.OUTER_PAD_Y)
  ctx.refreshRow:SetPoint('BOTTOMRIGHT', root, 'BOTTOMRIGHT', 0, G.OUTER_PAD_Y)

  local gridContentH =
    gridTop + numRows * paneH + math.max(0, numRows - 1) * G.ROW_GAP + G.OUTER_PAD_Y
  scrollChild:SetHeight(gridContentH)

  local newH = gridContentH + G.GAP_AFTER_GRID + G.REFRESH_ROW_H + 2 * G.OUTER_PAD_Y
  ctx.totalH = newH

  RaceLocked_GuildChampion_RefreshRaceGridDisplay(ctx.panes, ctx.raceTokens)
end

--- @param parent Frame
--- @return Frame root
--- @return number total height
function RaceLocked_CreateFactionRaceGrid(parent)
  local G = RaceLocked_GuildChampion
  local paneH = math.max(1, (tonumber(G.STATS_ROW_H) or 0) - 30)

  local raceTokens =
    G.RACE_GRID_ALL_TOKENS or {
      'Human',
      'Dwarf',
      'NightElf',
      'Gnome',
      'Orc',
      'Troll',
      'Tauren',
      'Scourge',
    }
  local numRaces = #raceTokens
  local numRows = math.max(1, math.ceil(numRaces / 2))
  local totalH =
    G.OUTER_PAD_Y + G.GRID_TOP_OFFSET + numRows * paneH + math.max(
      0,
      numRows - 1
    ) * G.ROW_GAP + G.GAP_AFTER_GRID + G.REFRESH_ROW_H + 2 * G.OUTER_PAD_Y

  local root = CreateFrame('Frame', nil, parent)
  root:SetAllPoints(parent)

  local scrollFrame = CreateFrame('ScrollFrame', nil, root, 'UIPanelScrollFrameTemplate')
  local scrollChild = CreateFrame('Frame', nil, scrollFrame)
  scrollFrame:SetScrollChild(scrollChild)

  local refreshRow, refreshBtn = createChrome(root)
  refreshRow:SetPoint('BOTTOMLEFT', root, 'BOTTOMLEFT', 0, G.OUTER_PAD_Y)
  refreshRow:SetPoint('BOTTOMRIGHT', root, 'BOTTOMRIGHT', 0, G.OUTER_PAD_Y)
  refreshRow:SetFrameLevel((scrollFrame:GetFrameLevel() or 0) + 10)

  scrollFrame:SetPoint('TOPLEFT', root, 'TOPLEFT', 0, -G.OUTER_PAD_Y)
  scrollFrame:SetPoint('BOTTOMLEFT', refreshRow, 'TOPLEFT', 0, 6)
  scrollFrame:SetPoint('BOTTOMRIGHT', refreshRow, 'TOPRIGHT', 0, 6)

  do
    local sb = scrollFrame.ScrollBar
    local shift = tonumber(G.RACE_GRID_SCROLL_BAR_SHIFT_LEFT) or 20
    if sb and sb.GetPoint and shift ~= 0 then
      local p1, rel1, rp1, x1, y1 = sb:GetPoint(1)
      local p2, rel2, rp2, x2, y2 = sb:GetPoint(2)
      sb:ClearAllPoints()
      if p1 and rel1 and rp1 then
        sb:SetPoint(p1, rel1, rp1, (tonumber(x1) or 0) - shift, tonumber(y1) or 0)
      end
      if p2 and rel2 and rp2 then
        sb:SetPoint(p2, rel2, rp2, (tonumber(x2) or 0) - shift, tonumber(y2) or 0)
      end
    end
  end

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
  local icons = {}
  local baseRaceLabels = {}

  for i = 1, numRaces do
    local token = raceTokens[i]
    local accent = (G.RACE_TOKEN_ACCENT and G.RACE_TOKEN_ACCENT[token]) or { 0.55, 0.55, 0.55 }
    local f, icon, lbl, det = createRaceStatPane(scrollChild, token, accent)
    panes[i] = f
    labels[i] = lbl
    details[i] = det
    icons[i] = icon
    local baseRaceName = (G.RACE_LABEL and G.RACE_LABEL[token]) or token
    baseRaceLabels[i] = baseRaceName
    lbl:SetText(baseRaceName)
  end

  local layoutCtx = {
    root = root,
    parent = parent,
    scrollFrame = scrollFrame,
    scrollChild = scrollChild,
    refreshRow = refreshRow,
    panes = panes,
    labels = labels,
    details = details,
    icons = icons,
    baseRaceLabels = baseRaceLabels,
    raceTokens = raceTokens,
    playerRaceToken = playerRaceToken,
    totalH = totalH,
  }

  local function runLayout()
    layoutGrid(layoutCtx)
  end
  RaceLocked_GuildChampion_RequestRaceGridRerender = runLayout

  refreshBtn:SetScript('OnClick', function()
    if refreshBtn._isLoading or refreshBtn._isAppliedAndBroadcasted then return end

    local ROSTER_FAIL_MSG = 'Guild Roster not ready, try again'
    local function setGuildLoadFailVisible(show)
      local fs = refreshRow._guildLoadFailFs
      if not fs then return end
      fs:SetText(ROSTER_FAIL_MSG)
      if show then
        fs:Show()
      else
        fs:Hide()
      end
    end

    local inGuild = IsInGuild and IsInGuild()
    --- Guild member count for min-size gates: use `RaceLocked_GuildChampion_GetGuildRosterMemberCount` when present, else `GetNumGuildMembers`.
    local function readGuildRosterMemberCountForGate()
      if RaceLocked_GuildChampion_GetGuildRosterMemberCount then
        return RaceLocked_GuildChampion_GetGuildRosterMemberCount()
      end
      if not GetNumGuildMembers then
        return 0
      end
      local n = GetNumGuildMembers(true)
      n = tonumber(n) or 0
      if n < 1 then
        n = GetNumGuildMembers()
        n = tonumber(n) or 0
      end
      return n
    end

    setGuildLoadFailVisible(false)
    refreshBtn._isLoading = true
    refreshBtn:SetNormalTexture(
      refreshBtn._loadingTex or 'Interface\\Buttons\\UI-GroupLoot-Pass-Down'
    )
    refreshBtn:SetPushedTexture(
      refreshBtn._loadingTex or 'Interface\\Buttons\\UI-GroupLoot-Pass-Down'
    )
    refreshBtn:SetDisabledTexture(
      refreshBtn._loadingTex or 'Interface\\Buttons\\UI-GroupLoot-Pass-Down'
    )
    refreshBtn:Disable()
    refreshBtn:SetAlpha(0.75)

    if RaceLocked_AchievementTracking_SyncOwnPoints then
      RaceLocked_AchievementTracking_SyncOwnPoints()
    end

    local rosterRequested = false
    RaceLocked_RefreshGuildRoster()
    rosterRequested = true

    local function refreshOwnStoredRowsAndRedraw()
      if inGuild then
        local n = readGuildRosterMemberCountForGate()
        local minN = tonumber(G.MIN_GUILD_MEMBERS_FOR_RACE_GRID)
        if rosterRequested and n < 1 then
          setGuildLoadFailVisible(true)
          return false
        end
        if n < minN then
          -- print(
          --   string.format(
          --     '|cffffffffRace Locked|r: Guild roster size check failed (need %d, have %d).',
          --     minN,
          --     n
          --   )
          -- )
          setGuildLoadFailVisible(true)
          return false
        end
        -- print(
        --   string.format(
        --     '|cffffffffRace Locked|r: Guild roster size check passed (need %d, have %d).',
        --     minN,
        --     n
        --   )
        -- )
      end
      if RaceLocked_GuildChampion_UpdateOwnStoredGuildReportsFromRoster then
        -- Keep refresh resilient: if no rows update yet (roster/race data still settling),
        -- continue rendering existing stored data instead of hard-failing this refresh.
        RaceLocked_GuildChampion_UpdateOwnStoredGuildReportsFromRoster(raceTokens)
      end
      runLayout()
      return true
    end

    local function finishRefreshButton()
      if refreshBtn._isAppliedAndBroadcasted then
        refreshBtn:SetNormalTexture(
          refreshBtn._validTex or 'Interface\\AddOns\\RaceLocked\\Textures\\valid.png'
        )
        refreshBtn:SetPushedTexture(
          refreshBtn._validTex or 'Interface\\AddOns\\RaceLocked\\Textures\\valid.png'
        )
        refreshBtn:SetDisabledTexture(
          refreshBtn._validTex or 'Interface\\AddOns\\RaceLocked\\Textures\\valid.png'
        )
        refreshBtn:Disable()
        refreshBtn:SetAlpha(1)
        refreshBtn._isLoading = false
        return
      end
      refreshBtn:SetNormalTexture(refreshBtn._refreshTex or 'Interface\\Buttons\\UI-RefreshButton')
      refreshBtn:SetPushedTexture(refreshBtn._refreshTex or 'Interface\\Buttons\\UI-RefreshButton')
      refreshBtn:SetDisabledTexture(
        refreshBtn._refreshTex or 'Interface\\Buttons\\UI-RefreshButton'
      )
      refreshBtn:Enable()
      refreshBtn:SetAlpha(1)
      refreshBtn._isLoading = false
    end

    -- Roster may still be loading after GuildRoster(); user can click again. Under min size: no broadcast.
    -- SendChatMessage to CHANNEL is protected • broadcast only runs here on the same stack as this click.
    local ok = refreshOwnStoredRowsAndRedraw()
    if ok then
      setGuildLoadFailVisible(false)
      if RaceLocked_GuildChampion_BroadcastOwnGuildRaceGridReports then
        RaceLocked_GuildChampion_BroadcastOwnGuildRaceGridReports()
      end
      if RaceLocked_AchievementTracking_BroadcastRelay then
        RaceLocked_AchievementTracking_BroadcastRelay()
      end
      refreshBtn._isAppliedAndBroadcasted = true
    end
    finishRefreshButton()
  end)

  local settingsFrame = _G.RaceLockedSettingsFrame
  if settingsFrame and settingsFrame.HookScript then
    settingsFrame:HookScript('OnHide', function()
      refreshBtn._isAppliedAndBroadcasted = false
      refreshBtn._isLoading = false
      refreshBtn:SetNormalTexture(refreshBtn._refreshTex or 'Interface\\Buttons\\UI-RefreshButton')
      refreshBtn:SetPushedTexture(refreshBtn._refreshTex or 'Interface\\Buttons\\UI-RefreshButton')
      refreshBtn:SetDisabledTexture(
        refreshBtn._refreshTex or 'Interface\\Buttons\\UI-RefreshButton'
      )
      refreshBtn:Enable()
      refreshBtn:SetAlpha(1)
    end)
  end

  root:SetScript('OnSizeChanged', runLayout)
  root:SetScript('OnShow', function()
    runLayout()
    if C_Timer and C_Timer.After then
      C_Timer.After(0, runLayout)
    end
  end)
  runLayout()

  return root, layoutCtx.totalH
end
