--- Pixels to subtract from the guild-names line width so text truncates before the full cell width.
local GUILD_NAMES_TRUNCATE_EARLY_PX = 50

--- Display-only: title-case each whitespace-delimited word in comma-separated guild names.
--- (Stored and wire data are unchanged; tooltips use raw `row.guildName`.)
--- @param word string
--- @return string
local function titleCaseOneWordDisplay(word)
  if not word or word == '' then
    return word or ''
  end
  return string.upper(string.sub(word, 1, 1)) .. string.lower(string.sub(word, 2, -1))
end

--- @param segment string one guild name (no commas)
--- @return string
local function titleCaseOneGuildNameSegment(segment)
  segment = (segment or ''):gsub('^%s+', ''):gsub('%s+$', '')
  if segment == '' then
    return segment
  end
  local words = {}
  for w in string.gmatch(segment, '%S+') do
    words[#words + 1] = titleCaseOneWordDisplay(w)
  end
  return table.concat(words, ' ')
end

--- @param text string e.g. "foo bar, BAZ"
--- @return string
local function guildNamesCommaListToTitleCase(text)
  if not text or text == '' then
    return text
  end
  local segs = {}
  for part in string.gmatch(text, '([^,]+)') do
    local seg = part:match('^%s*(.-)%s*$') or part
    if seg ~= '' then
      segs[#segs + 1] = titleCaseOneGuildNameSegment(seg)
    end
  end
  if #segs == 0 then
    return text
  end
  return table.concat(segs, ', ')
end

--- Truncate a string so it fits on one line in `fs` (no wrapping); appends "..." when shortened.
--- Full text should remain in tooltips or elsewhere; this is for display only.
--- @param fs FontString
--- @param text string
--- @param maxW number
--- @return string
local function fitGuildNamesToSingleLine(fs, text, maxW)
  if not text or text == '' then
    return text or ''
  end
  if not fs or not maxW or maxW <= 0 then
    return text
  end
  local ell = '...'
  fs:SetText(text)
  if (fs:GetStringWidth() or 0) <= maxW then
    return text
  end
  fs:SetText(ell)
  if (fs:GetStringWidth() or 0) > maxW then
    return ''
  end
  local s = text
  local lo, hi = 0, #s
  while lo < hi do
    local mid = math.floor((lo + hi + 1) / 2)
    local trial = string.sub(s, 1, mid) .. ell
    fs:SetText(trial)
    if (fs:GetStringWidth() or 0) <= maxW then
      lo = mid
    else
      hi = mid - 1
    end
  end
  if lo == 0 then
    return ell
  end
  return string.sub(s, 1, lo) .. ell
end

--- @param classKey string e.g. warriors
--- @return number r, number g, number b
local function classColorForReportKey(G, classKey)
  local brightness = tonumber(G.CLASS_COLOR_BRIGHTNESS) or 0.82
  if brightness < 0 then
    brightness = 0
  elseif brightness > 1 then
    brightness = 1
  end
  local file = G.CLASS_KEY_TO_FILE[classKey]
  if not file then
    return 0.85 * brightness, 0.85 * brightness, 0.8 * brightness
  end
  if RAID_CLASS_COLORS and RAID_CLASS_COLORS[file] then
    local c = RAID_CLASS_COLORS[file]
    return c.r * brightness, c.g * brightness, c.b * brightness
  end
  if GetClassColor then
    local r, g, b = GetClassColor(file)
    if type(r) == 'number' and type(g) == 'number' and type(b) == 'number' then
      return r * brightness, g * brightness, b * brightness
    end
  end
  return 0.85 * brightness, 0.85 * brightness, 0.8 * brightness
end

--- @param G table
--- @param classKey string
--- @return string
local function classLabelForReportKey(G, classKey)
  for i = 1, #G.CLASS_REPORT_KEYS do
    local row = G.CLASS_REPORT_KEYS[i]
    if row.key == classKey then
      return row.label
    end
  end
  return classKey or ''
end

--- Called from bar / % hit frames (`self._rlCell` -> cell table).
function RaceLocked_GuildChampion_OnClassBarCellEnter(self)
  if not self then return end
  local cell = self._rlCell
  if not cell or not cell._rlHasTip or not GameTooltip then return end
  local G = RaceLocked_GuildChampion
  GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
  GameTooltip:ClearLines()
  if cell._rlEmptyTip then
    GameTooltip:AddLine(
      G.RACE_GRID_CLASS_SUBTITLE,
      G.LABEL_GOLD[1],
      G.LABEL_GOLD[2],
      G.LABEL_GOLD[3]
    )
    GameTooltip:AddLine('No character counts for this race.', 1, 1, 1)
  else
    local key = cell._rlClassKey
    local count = cell._rlCount or 0
    local averageLevel = cell._rlAverageLevel or 0
    local label = classLabelForReportKey(G, key)
    local r, g, b = classColorForReportKey(G, key)
    GameTooltip:AddLine(label, r, g, b)
    GameTooltip:AddLine(string.format('%d players', count), 1, 1, 1)
    if averageLevel > 0 then
      GameTooltip:AddLine(string.format('Avg level: %d', math.floor(averageLevel + 0.5)), 1, 1, 1)
    else
      GameTooltip:AddLine('Avg level: -', 1, 1, 1)
    end
  end
  GameTooltip:Show()
end

function RaceLocked_GuildChampion_OnClassBarCellLeave()
  if GameTooltip then
    GameTooltip:Hide()
  end
end

--- Horizontally stack class bar segments under the class subtitle.
--- @param pane Frame
--- @param widths number[] pixel width per column index (1..9)
local function layoutClassBarColumns(pane, widths)
  local G = RaceLocked_GuildChampion
  local row = pane._classBarRow
  local pctRow = pane._classBarPctRow
  if not row or not pctRow or not pane._classCol then return end
  local seps = pane._classBarSep
  if seps then
    for s = 1, 8 do
      seps[s]:Hide()
    end
  end
  local colH = row:GetHeight()
  local rightGap = math.max(0, tonumber(G.CLASS_BAR_SECTION_RIGHT_GAP) or 0)
  local lastVisibleIdx = 0
  for i = 1, 9 do
    if (widths[i] or 0) > 0 then
      lastVisibleIdx = i
    end
  end
  local x = 0
  local sepIdx = 1
  local sawVisible = false
  for idx = 1, 9 do
    local cell = pane._classCol[idx]
    if not cell then
      break
    end
    local wpx = widths[idx] or 0
    if wpx <= 0 then
      cell.frame:Hide()
      cell.pct:Hide()
      if cell.pctHit then
        cell.pctHit:Hide()
      end
    else
      if sawVisible and seps and sepIdx <= 8 then
        local sep = seps[sepIdx]
        sep:ClearAllPoints()
        sep:SetPoint('TOPLEFT', row, 'TOPLEFT', x, 0)
        sep:SetSize(G.CLASS_BAR_SEP_W, colH)
        sep:SetColorTexture(G.CLASS_BAR_SEP[1], G.CLASS_BAR_SEP[2], G.CLASS_BAR_SEP[3], 1)
        sep:Show()
        sepIdx = sepIdx + 1
      end
      sawVisible = true
      local renderW = wpx
      if idx ~= lastVisibleIdx then
        renderW = math.max(0, wpx - rightGap)
      end
      cell.frame:Show()
      cell.frame:ClearAllPoints()
      cell.frame:SetPoint('TOPLEFT', row, 'TOPLEFT', x, 0)
      cell.frame:SetSize(renderW, colH)
      cell.tex:SetWidth(math.max(1, renderW))
      cell.pct:Show()
      cell.pct:ClearAllPoints()
      cell.pct:SetPoint('BOTTOMLEFT', pctRow, 'BOTTOMLEFT', x, 0)
      cell.pct:SetSize(wpx, G.CLASS_BAR_LABEL_ROW)
      if cell.pctHit then
        cell.pctHit:Show()
        cell.pctHit:ClearAllPoints()
        cell.pctHit:SetPoint('BOTTOMLEFT', pctRow, 'BOTTOMLEFT', x, 0)
        cell.pctHit:SetSize(renderW, G.CLASS_BAR_LABEL_ROW)
      end
      x = x + wpx
    end
  end
end

--- @param G table RaceLocked_GuildChampion
local function mutedBarTexture(tex)
  tex:SetColorTexture(0.22, 0.22, 0.24, 1)
end

--- @param ts number|nil Unix timestamp (stored as realm/server time when available)
--- @return string
local function formatGuildLastUpdate(ts)
  local n = tonumber(ts) or 0
  if n <= 0 then
    return 'Never'
  end
  if RaceLocked_GuildChampion_FormatUnixAsEasternFriendly then
    local s = RaceLocked_GuildChampion_FormatUnixAsEasternFriendly(n)
    if s and s ~= '' then
      return s
    end
  end
  if RaceLocked_GuildChampion_FormatUnixAsEastern then
    local s = RaceLocked_GuildChampion_FormatUnixAsEastern(n)
    if s and s ~= '' then
      return s
    end
  end
  return tostring(math.floor(n))
end

--- @param classEntry number|table|nil
--- @return number
local function classCount(classEntry)
  if type(classEntry) == 'table' then
    return tonumber(classEntry.count) or 0
  end
  return tonumber(classEntry) or 0
end

--- @param classEntry number|table|nil
--- @return number
local function classAverageLevel(classEntry)
  if type(classEntry) == 'table' then
    return tonumber(classEntry.averageLevel) or 0
  end
  return 0
end

--- @param pane Frame
--- @param raceToken string
local function ensureGuildNamesTooltip(pane, raceToken)
  if not pane or not pane._guildNames then return end
  if not pane._guildNamesHit then
    local hit = CreateFrame('Frame', nil, pane)
    local paneLevel = (pane.GetFrameLevel and pane:GetFrameLevel()) or 0
    hit:SetFrameLevel(paneLevel + 5)
    hit:EnableMouse(true)
    hit:Hide()
    hit:SetScript('OnLeave', function()
      if GameTooltip then
        GameTooltip:Hide()
      end
    end)
    hit:SetScript('OnEnter', function(self)
      if not GameTooltip then return end
      local token = self._rlRaceToken
      local rows =
        RaceLocked_GuildChampion.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and RaceLocked_GuildChampion.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[token]
      if type(rows) ~= 'table' or #rows < 1 then return end
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
      GameTooltip:ClearLines()
      GameTooltip:AddLine('Guild Last Update', 1, 0.92, 0.62)
      for _, row in ipairs(rows) do
        local guildName = type(row.guildName) == 'string' and row.guildName or ''
        if guildName ~= '' then
          local stamp = formatGuildLastUpdate(row.timestamp)
          GameTooltip:AddDoubleLine(
            guildName .. ' (' .. row.guildSize .. ')',
            stamp,
            1,
            1,
            1,
            0.9,
            0.9,
            0.9
          )
        end
      end
      GameTooltip:Show()
    end)
    pane._guildNamesHit = hit
  end
  local hit = pane._guildNamesHit
  hit._rlRaceToken = raceToken
  hit:ClearAllPoints()
  hit:SetPoint('TOPLEFT', pane._guildNames, 'TOPLEFT', 0, 0)
  hit:SetPoint('BOTTOMRIGHT', pane._guildNames, 'BOTTOMRIGHT', 0, 0)
end

function RaceLocked_GuildChampion_RefreshRaceGridDisplay(panes, raceTokens)
  local G = RaceLocked_GuildChampion
  if not panes[1] or not panes[1]._guildSectionTitle or not panes[1]._classBarHost then return end
  local n = type(raceTokens) == 'table' and #raceTokens or 0
  for i = 1, n do
    local pane = panes[i]
    if not pane then
      break
    end
    local token = raceTokens[i]
    local agg =
      RaceLocked_GuildChampion_GetAggregatedMockForRace and RaceLocked_GuildChampion_GetAggregatedMockForRace(
        token
      )
    local subR, subG, subB = G.LABEL_GOLD[1] * 0.85, G.LABEL_GOLD[2] * 0.85, G.LABEL_GOLD[3] * 0.85
    pane._guildSectionTitle:SetText(G.RACE_GRID_GUILD_SECTION_TITLE)
    pane._guildSectionTitle:SetTextColor(subR, subG, subB)

    if agg and agg.guildNamesText and agg.guildNamesText ~= '' then
      local gNames = pane._guildNames
      local w = (gNames.GetWidth and gNames:GetWidth()) or 0
      if w <= 0 and pane.GetWidth then
        w = math.max(48, (pane:GetWidth() or 0) - 2 * (G.INNER_PAD or 0) - 40)
      end
      if w > 0 then
        w = math.max(1, w - GUILD_NAMES_TRUNCATE_EARLY_PX)
      end
      gNames:SetText(
        fitGuildNamesToSingleLine(gNames, guildNamesCommaListToTitleCase(agg.guildNamesText), w)
      )
      gNames:SetTextColor(0.88, 0.86, 0.8)
      ensureGuildNamesTooltip(pane, token)
      pane._guildNamesHit:Show()
    else
      pane._guildNames:SetText('•')
      pane._guildNames:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])
      if pane._guildNamesHit then
        pane._guildNamesHit:Hide()
      end
    end

    pane._avgSubtitle:SetText(G.RACE_GRID_AVG_SUBTITLE)
    pane._avgSubtitle:SetTextColor(subR, subG, subB)
    pane._totalPlayersSubtitle:SetText(G.RACE_GRID_TOTAL_PLAYERS_SUBTITLE or 'Total players')
    pane._totalPlayersSubtitle:SetTextColor(subR, subG, subB)
    if pane._total60sSubtitle then
      pane._total60sSubtitle:SetText(G.RACE_GRID_TOTAL_60S_SUBTITLE or 'Total 60s')
      pane._total60sSubtitle:SetTextColor(subR, subG, subB)
    end

    local det = pane._detailFs
    if agg and agg.averageLevel and agg.averageLevel > 0 then
      det:SetText(tostring(math.floor(agg.averageLevel + 0.5)))
      det:SetTextColor(0.82, 0.8, 0.74)
    else
      det:SetText('-')
      det:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])
    end

    local classes = (agg and agg.classes) or {}
    local totalPlayers = 0
    for _, classEntry in pairs(classes) do
      totalPlayers = totalPlayers + classCount(classEntry)
    end
    local rosterTotal = (agg and tonumber(agg.totalRosterMembers)) or 0
    if rosterTotal > 0 then
      totalPlayers = math.floor(rosterTotal + 0.5)
    end
    if totalPlayers > 0 then
      pane._totalPlayersFs:SetText(tostring(totalPlayers))
      pane._totalPlayersFs:SetTextColor(0.82, 0.8, 0.74)
    else
      pane._totalPlayersFs:SetText('-')
      pane._totalPlayersFs:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])
    end

    local total60s = (agg and tonumber(agg.totalLevel60Members)) or 0
    if pane._total60sFs then
      if total60s > 0 then
        pane._total60sFs:SetText(tostring(math.floor(total60s + 0.5)))
        pane._total60sFs:SetTextColor(0.82, 0.8, 0.74)
      else
        pane._total60sFs:SetText('-')
        pane._total60sFs:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])
      end
    end

    pane._classSubtitle:SetText(G.RACE_GRID_CLASS_SUBTITLE)
    pane._classSubtitle:SetTextColor(subR, subG, subB)

    local keys = G.RACE_TOKEN_TO_CLASS_KEYS[token] or {}
    local nKeys = #keys
    local total = 0
    for _, k in ipairs(keys) do
      total = total + classCount(classes[k])
    end

    local row = pane._classBarRow
    -- Inner width (row), not outer host • matches padded bar area inside the chart border.
    local hostW = row and row:GetWidth() or 0
    if not hostW or hostW < 4 then
      hostW = 160
    end

    local widths = {}
    for idx = 1, 9 do
      widths[idx] = 0
    end

    local pctRow = pane._classBarPctRow
    if row and pctRow and pane._classCol then
      for clearIdx = 1, 9 do
        local c = pane._classCol[clearIdx]
        if not c then
          break
        end
        c._rlHasTip = false
        c._rlEmptyTip = false
        c._rlClassKey = nil
        c._rlCount = nil
        c._rlTotal = nil
        c._rlAverageLevel = nil
        if c.pctHit then
          c.pctHit:Hide()
        end
      end
      if pane._classBarSep then
        for s = 1, 8 do
          pane._classBarSep[s]:Hide()
        end
      end
      if nKeys < 1 or total <= 0 then
        local barH = row:GetHeight()
        for idx = 1, 9 do
          local cell = pane._classCol[idx]
          if not cell then
            break
          end
          if idx == 1 then
            cell.frame:Show()
            cell.frame:ClearAllPoints()
            cell.frame:SetPoint('TOPLEFT', row, 'TOPLEFT', 0, 0)
            cell.frame:SetSize(hostW, barH)
            cell.tex:SetWidth(math.max(1, hostW))
            mutedBarTexture(cell.tex)
            cell.pct:Show()
            cell.pct:ClearAllPoints()
            cell.pct:SetPoint('BOTTOMLEFT', pctRow, 'BOTTOMLEFT', 0, 0)
            cell.pct:SetSize(hostW, G.CLASS_BAR_LABEL_ROW)
            cell.pct:SetText('-')
            cell.pct:SetTextColor(G.MUTED[1], G.MUTED[2], G.MUTED[3])
            cell._rlHasTip = true
            cell._rlEmptyTip = true
            if cell.pctHit then
              cell.pctHit:Show()
              cell.pctHit:ClearAllPoints()
              cell.pctHit:SetPoint('BOTTOMLEFT', pctRow, 'BOTTOMLEFT', 0, 0)
              cell.pctHit:SetSize(hostW, G.CLASS_BAR_LABEL_ROW)
            end
          else
            cell.frame:Hide()
            cell.pct:Hide()
            cell.pct:SetText('')
          end
        end
      else
        local assigned = 0
        for j = 1, nKeys - 1 do
          local k = keys[j]
          local c = classCount(classes[k])
          local wpx = math.floor((c / total) * hostW)
          widths[j] = wpx
          assigned = assigned + wpx
        end
        widths[nKeys] = math.max(0, hostW - assigned)

        for idx = 1, nKeys do
          local cell = pane._classCol[idx]
          if not cell then
            break
          end
          local classKey = keys[idx]
          local c = classCount(classes[classKey])
          local wpx = widths[idx] or 0
          local r, g, b = classColorForReportKey(G, classKey)
          if wpx <= 0 then
            cell.frame:Hide()
            cell.pct:Hide()
            cell.pct:SetText('')
          else
            cell.tex:SetColorTexture(r, g, b, 1)
            local pctNum = math.floor((100 * c / total) + 0.5)
            cell.pct:SetText(string.format('%d%%', pctNum))
            cell.pct:SetTextColor(r * 0.85, g * 0.85, b * 0.85)
            cell._rlHasTip = true
            cell._rlEmptyTip = false
            cell._rlClassKey = classKey
            cell._rlCount = c
            cell._rlTotal = total
            cell._rlAverageLevel = classAverageLevel(classes[classKey])
          end
        end
        for idx = nKeys + 1, 9 do
          local cell = pane._classCol[idx]
          if not cell then
            break
          end
          cell.frame:Hide()
          cell.pct:Hide()
          cell.pct:SetText('')
        end
        layoutClassBarColumns(pane, widths)
      end
    end
  end
end
