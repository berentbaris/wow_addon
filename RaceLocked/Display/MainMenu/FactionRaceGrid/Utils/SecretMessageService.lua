-- Race grid secret-message service over a hidden custom chat channel.
-- Sends your own guild race reports and applies received reports into stored guild rows.

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion
local thisAddonName = ...

local PREFIX = 'RLRaceGridV1'
local CHANNEL_NAME = 'RaceLockedDataBus'
-- Internal field separator inside the payload (before hex encoding for chat).
local WIRE_FIELD_SEP = '\001'
local channelFiltersInstalled = false
local delayedJoinScheduled = false

local function bytesToHex(s)
  if type(s) ~= 'string' or s == '' then
    return ''
  end
  local t = {}
  for i = 1, #s do
    t[i] = string.format('%02x', string.byte(s, i))
  end
  return table.concat(t)
end

local function hexToBytes(h)
  if type(h) ~= 'string' or h == '' or #h % 2 ~= 0 then
    return nil
  end
  local t = {}
  for i = 1, #h, 2 do
    local b = tonumber(string.sub(h, i, i + 1), 16)
    if not b then
      return nil
    end
    t[#t + 1] = string.char(b)
  end
  return table.concat(t)
end

local function emptyClasses()
  return {
    druids = 0,
    rogues = 0,
    hunters = 0,
    warriors = 0,
    mages = 0,
    priests = 0,
    warlocks = 0,
    paladins = 0,
    shamans = 0,
  }
end

--- One-line class counts for debug prints (matches wire / CLASS_REPORT_KEYS order).
local function formatClassesOneLine(classes)
  if type(classes) ~= 'table' then
    return '(no class breakdown)'
  end
  local bits = {}
  local keys = G.CLASS_REPORT_KEYS
  if type(keys) == 'table' then
    for i = 1, #keys do
      local entry = keys[i]
      local k = entry and entry.key
      if k then
        local label = entry.label or k
        local short = string.sub(tostring(label), 1, 3)
        bits[#bits + 1] = string.format('%s=%d', short, tonumber(classes[k]) or 0)
      end
    end
  end
  if #bits < 1 then
    return '(no class keys)'
  end
  return table.concat(bits, ', ')
end

local function sanitizeGuildName(name)
  local s = tostring(name or '')
  s = s:gsub('|', '/')
  s = s:gsub(WIRE_FIELD_SEP, '')
  return s
end

local function buildPayload(raceToken, row)
  if type(row) ~= 'table' then
    return nil
  end
  local c = row.classes or emptyClasses()
  return table.concat({
    'v1',
    tostring(raceToken or ''),
    sanitizeGuildName(row.guildName or ''),
    tostring(tonumber(row.guildSize) or 0),
    tostring(tonumber(row.averageLevel) or 0),
    tostring(tonumber(c.druids) or 0),
    tostring(tonumber(c.rogues) or 0),
    tostring(tonumber(c.hunters) or 0),
    tostring(tonumber(c.warriors) or 0),
    tostring(tonumber(c.mages) or 0),
    tostring(tonumber(c.priests) or 0),
    tostring(tonumber(c.warlocks) or 0),
    tostring(tonumber(c.paladins) or 0),
    tostring(tonumber(c.shamans) or 0),
  }, WIRE_FIELD_SEP)
end

local function parsePayload(msg)
  if type(msg) ~= 'string' or msg == '' then
    return nil
  end

  local headHex = PREFIX .. ':'
  if string.sub(msg, 1, #headHex) ~= headHex then
    return nil
  end
  local inner = hexToBytes(string.sub(msg, #headHex + 1))
  if type(inner) ~= 'string' or inner == '' then
    return nil
  end

  local p = { strsplit(WIRE_FIELD_SEP, inner) }
  if #p < 14 then
    return nil
  end
  if p[1] ~= 'v1' then
    return nil
  end

  local raceToken = p[2]
  local guildName = p[3]
  if raceToken == '' or guildName == '' then
    return nil
  end

  return {
    raceToken = raceToken,
    guildName = guildName,
    guildSize = tonumber(p[4]) or 0,
    averageLevel = tonumber(p[5]) or 0,
    classes = {
      druids = tonumber(p[6]) or 0,
      rogues = tonumber(p[7]) or 0,
      hunters = tonumber(p[8]) or 0,
      warriors = tonumber(p[9]) or 0,
      mages = tonumber(p[10]) or 0,
      priests = tonumber(p[11]) or 0,
      warlocks = tonumber(p[12]) or 0,
      paladins = tonumber(p[13]) or 0,
      shamans = tonumber(p[14]) or 0,
    },
  }
end

local function applyIncomingReport(report)
  if not report then
    return false
  end
  local minN = tonumber(G.MIN_GUILD_MEMBERS_FOR_RACE_GRID) or 100
  if (tonumber(report.guildSize) or 0) < minN then
    return false
  end
  if RaceLocked_GuildChampion_EnsureStoredGuildReportsDB then
    RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  end
  if not RaceLocked_GuildChampion_IsGuildNameAllowedForRaceGrid then
    return false
  end
  if not RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid then
    return false
  end
  if not RaceLocked_GuildChampion_IsGuildNameAllowedForRaceGrid(report.guildName) then
    return false
  end

  local rows = G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[report.raceToken]
  if type(rows) ~= 'table' then
    return false
  end

  local incomingNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(report.guildName)
  if incomingNorm == '' then
    return false
  end
  if RaceLocked_GuildChampion_GetNormalizedPlayerGuildName
    and RaceLocked_GuildChampion_MeetsMinGuildMembersForRaceGrid
  then
    local ownGuildNorm = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
    if ownGuildNorm ~= '' and incomingNorm == ownGuildNorm
      and not RaceLocked_GuildChampion_MeetsMinGuildMembersForRaceGrid()
    then
      return false
    end
  end

  for _, row in ipairs(rows) do
    if type(row) == 'table' then
      local rowNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(row.guildName)
      if rowNorm ~= '' and rowNorm == incomingNorm then
        row.guildSize = report.guildSize
        row.averageLevel = report.averageLevel
        row.classes = report.classes or emptyClasses()
        if RaceLocked_GuildChampion_PersistStoredGuildReportsByRace then
          RaceLocked_GuildChampion_PersistStoredGuildReportsByRace()
        end
        return true
      end
    end
  end
  return false
end

local function getDataChannelId()
  if not GetChannelName then
    return 0
  end
  local id = GetChannelName(CHANNEL_NAME)
  id = tonumber(id) or 0
  return id
end

local function hideChannelFromChatWindows()
  if not ChatFrame_RemoveChannel or not NUM_CHAT_WINDOWS then
    return
  end
  for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G['ChatFrame' .. i]
    if frame then
      ChatFrame_RemoveChannel(frame, CHANNEL_NAME)
    end
  end
end

local function installChannelNoticeFilters()
  if channelFiltersInstalled or not ChatFrame_AddMessageEventFilter then
    return
  end
  channelFiltersInstalled = true
  local function filterFn(_, _, ...)
    local arg1 = select(1, ...)
    local arg2 = select(2, ...)
    local arg3 = select(3, ...)
    if tostring(arg1 or '') == CHANNEL_NAME then
      return true
    end
    if tostring(arg2 or '') == CHANNEL_NAME then
      return true
    end
    if tostring(arg3 or '') == CHANNEL_NAME then
      return true
    end
    return false
  end
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE', filterFn)
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE_USER', filterFn)

  -- Hide normal channel lines on the data bus; we still handle them via CHAT_MSG_CHANNEL.
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL', function(_, _, ...)
    local channelIndex = select(8, ...)
    local channelBaseName = select(9, ...)
    if channelBaseName == CHANNEL_NAME then
      return true
    end
    local id = tonumber(channelIndex) or 0
    if id > 0 and id == getDataChannelId() then
      return true
    end
    return false
  end)
end

local function ensureDataChannelJoined()
  local id = getDataChannelId()
  if id > 0 then
    hideChannelFromChatWindows()
    return id
  end
  if JoinChannelByName then
    JoinChannelByName(CHANNEL_NAME)
    id = getDataChannelId()
    if id > 0 then
      hideChannelFromChatWindows()
      return id
    end
  end
  if JoinTemporaryChannel then
    JoinTemporaryChannel(CHANNEL_NAME)
    id = getDataChannelId()
    if id > 0 then
      hideChannelFromChatWindows()
      return id
    end
  end
  return 0
end

local function scheduleDelayedDataChannelJoin()
  if delayedJoinScheduled then
    return
  end
  delayedJoinScheduled = true
  if not C_Timer or not C_Timer.After then
    ensureDataChannelJoined()
    delayedJoinScheduled = false
    return
  end

  local delays = { 0.5, 1.5, 3.0 }
  local idx = 1
  local function attemptJoin()
    local id = ensureDataChannelJoined()
    if id > 0 or idx >= #delays then
      delayedJoinScheduled = false
      return
    end
    idx = idx + 1
    C_Timer.After(delays[idx], attemptJoin)
  end

  C_Timer.After(delays[idx], attemptJoin)
end

--- Classic does not support C_ChatInfo.SendAddonMessage(..., "CHANNEL", ...). Use SendChatMessage(..., "CHANNEL", channelIndex); there is no separate SendChannelMessage in this API.
--- SendChatMessage to CHANNEL is protected: call only from a user-driven path (same stack as refresh click or /rlrgb).
local function sendRaceGridChannelLine(channelId, payload, raceToken, classes)
  if not SendChatMessage or channelId <= 0 or not payload or payload == '' then
    return
  end
  -- Hex on the wire: no '|' (chat escapes) and no raw control bytes that might get altered.
  local wire = PREFIX .. ':' .. bytesToHex(payload)
  if #wire > 255 then
    return
  end
  SendChatMessage(wire, 'CHANNEL', nil, channelId)
end

local function isOurDataChannelMessage(...)
  local channelIndex = select(8, ...)
  local channelBaseName = select(9, ...)
  if channelBaseName == CHANNEL_NAME then
    return true
  end
  local id = tonumber(channelIndex) or 0
  return id > 0 and id == getDataChannelId()
end

function RaceLocked_GuildChampion_BroadcastOwnGuildRaceGridReports()
  if not RaceLocked_GuildChampion_GetNormalizedPlayerGuildName or not RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid then
    return
  end
  if RaceLocked_GuildChampion_MeetsMinGuildMembersForRaceGrid and not RaceLocked_GuildChampion_MeetsMinGuildMembersForRaceGrid() then
    return
  end
  local channelId = ensureDataChannelJoined()
  if channelId <= 0 then
    return
  end
  local ownGuildNorm = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
  if ownGuildNorm == '' then
    return
  end

  for raceToken, rows in pairs(G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE or {}) do
    if type(rows) == 'table' then
      for _, row in ipairs(rows) do
        if type(row) == 'table' then
          local rowNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(row.guildName)
          if rowNorm ~= '' and rowNorm == ownGuildNorm then
            local payload = buildPayload(raceToken, row)
            if payload and payload ~= '' then
              sendRaceGridChannelLine(channelId, payload, raceToken, row.classes)
            end
          end
        end
      end
    end
  end
end

local service = CreateFrame('Frame')
service:RegisterEvent('ADDON_LOADED')
service:RegisterEvent('PLAYER_LOGIN')
service:RegisterEvent('PLAYER_ENTERING_WORLD')
service:RegisterEvent('CHAT_MSG_CHANNEL')
service:RegisterEvent('CHANNEL_UI_UPDATE')
service:SetScript('OnEvent', function(_, event, ...)
  if event == 'ADDON_LOADED' then
    local loadedAddonName = ...
    if loadedAddonName == thisAddonName then
      if RaceLocked_GuildChampion_EnsureStoredGuildReportsDB then
        RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
      end
      installChannelNoticeFilters()
      scheduleDelayedDataChannelJoin()
    end
    return
  end
  if event == 'PLAYER_LOGIN' then
    scheduleDelayedDataChannelJoin()
    return
  end
  if event == 'PLAYER_ENTERING_WORLD' then
    scheduleDelayedDataChannelJoin()
    return
  end
  if event == 'CHANNEL_UI_UPDATE' then
    ensureDataChannelJoined()
    return
  end
  if event == 'CHAT_MSG_CHANNEL' then
    if not isOurDataChannelMessage(...) then
      return
    end
    local msg = select(1, ...)
    local sender = select(2, ...)
    local report = parsePayload(msg)
    if not report then
      return
    end
    -- Keep incoming reports persisted, but do not force live UI rerenders;
    -- the race grid redraw is user-driven from Apply Update.
    applyIncomingReport(report)
  end
end)
