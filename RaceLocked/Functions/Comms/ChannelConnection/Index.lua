RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion

G.Comms = G.Comms or {}
local Comms = G.Comms

local channelFiltersInstalled = false
local delayedJoinScheduled = false

-- Upper bound for the channel slot scan. Classic caps players at 10 chat
-- channels, but we probe a bit higher to be safe across versions.
local MAX_CHANNEL_SLOTS = 20

function Comms.GetDataChannelId()
  if not GetChannelName then
    return 0
  end
  local id = GetChannelName(Comms.CHANNEL_NAME)
  id = tonumber(id) or 0
  return id
end

local function hideChannelFromChatWindows()
  if not ChatFrame_RemoveChannel or not NUM_CHAT_WINDOWS then return end
  for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G['ChatFrame' .. i]
    if frame then
      ChatFrame_RemoveChannel(frame, Comms.CHANNEL_NAME)
    end
  end
end

-- Highest occupied channel slot excluding our own data bus. Used to decide
-- whether it's safe to join (we want to land at othersHighest + 1) and to
-- detect when our channel is sitting below others (and should be swapped up).
local function getOtherChannelsHighestIndex(ourId)
  if not GetChannelName then
    return 0
  end
  local highest = 0
  for i = 1, MAX_CHANNEL_SLOTS do
    if i ~= ourId then
      local id, name = GetChannelName(i)
      local occupied = (type(id) == 'number' and id > 0) or (name and name ~= '')
      if occupied then
        highest = i
      end
    end
  end
  return highest
end

-- Bubble our channel slot up until nothing sits above it. This relies on
-- C_ChatInfo.SwapChatChannelsByChannelIndex; if that API is unavailable
-- (older Classic clients), this is a no-op and we accept the current slot.
local function tryMoveOurChannelToBack()
  local swap = C_ChatInfo and C_ChatInfo.SwapChatChannelsByChannelIndex
  if not swap or not GetChannelName then return end
  for _ = 1, MAX_CHANNEL_SLOTS do
    local id = Comms.GetDataChannelId()
    if id <= 0 then return end
    local nextId, nextName = GetChannelName(id + 1)
    local nextOccupied = (type(nextId) == 'number' and nextId > 0) or (nextName and nextName ~= '')
    if not nextOccupied then return end
    swap(id, id + 1)
  end
end

function Comms.InstallChannelNoticeFilters()
  if channelFiltersInstalled or not ChatFrame_AddMessageEventFilter then return end
  channelFiltersInstalled = true
  local function filterFn(_, _, ...)
    local arg1 = select(1, ...)
    local arg2 = select(2, ...)
    local arg3 = select(3, ...)
    if tostring(arg1 or '') == Comms.CHANNEL_NAME then
      return true
    end
    if tostring(arg2 or '') == Comms.CHANNEL_NAME then
      return true
    end
    if tostring(arg3 or '') == Comms.CHANNEL_NAME then
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
    if channelBaseName == Comms.CHANNEL_NAME then
      return true
    end
    local id = tonumber(channelIndex) or 0
    if id > 0 and id == Comms.GetDataChannelId() then
      return true
    end
    return false
  end)
end

-- forceJoin: when true, join even if no other channels are detected yet.
-- This is the final fallback for unusual setups (e.g. user left every default
-- zone channel) where waiting indefinitely would mean never joining.
function Comms.EnsureDataChannelJoined(forceJoin)
  local id = Comms.GetDataChannelId()
  if id > 0 then
    -- Already joined. If anything sits above us, push our slot to the back so
    -- /1 stays General etc. Idempotent: stops as soon as nothing is above us.
    local othersHighest = getOtherChannelsHighestIndex(id)
    if othersHighest > id then
      tryMoveOurChannelToBack()
      id = Comms.GetDataChannelId()
    end
    hideChannelFromChatWindows()
    return id
  end

  -- Not joined yet. Defer until at least one other channel exists, otherwise
  -- JoinChannelByName would grab slot 1 (where General usually lives) before
  -- the default zone channels have loaded post-PLAYER_ENTERING_WORLD.
  local othersHighest = getOtherChannelsHighestIndex(0)
  if othersHighest == 0 and not forceJoin then
    return 0
  end

  if JoinChannelByName then
    JoinChannelByName(Comms.CHANNEL_NAME)
    id = Comms.GetDataChannelId()
    if id > 0 then
      tryMoveOurChannelToBack()
      id = Comms.GetDataChannelId()
      hideChannelFromChatWindows()
      return id
    end
  end
  if JoinTemporaryChannel then
    JoinTemporaryChannel(Comms.CHANNEL_NAME)
    id = Comms.GetDataChannelId()
    if id > 0 then
      tryMoveOurChannelToBack()
      id = Comms.GetDataChannelId()
      hideChannelFromChatWindows()
      return id
    end
  end
  return 0
end

function Comms.ScheduleDelayedDataChannelJoin()
  if delayedJoinScheduled then return end
  delayedJoinScheduled = true
  if not C_Timer or not C_Timer.After then
    Comms.EnsureDataChannelJoined(true)
    delayedJoinScheduled = false
    return
  end

  -- Extra retries past 3s give the default zone channels more time to load
  -- on slow clients before we give up and force-join at whatever slot.
  local delays = { 0.5, 1.5, 3.0, 5.0, 8.0 }
  local idx = 1
  local function attemptJoin()
    local id = Comms.EnsureDataChannelJoined(false)
    if id > 0 then
      delayedJoinScheduled = false
      return
    end
    if idx >= #delays then
      Comms.EnsureDataChannelJoined(true)
      delayedJoinScheduled = false
      return
    end
    idx = idx + 1
    C_Timer.After(delays[idx], attemptJoin)
  end

  C_Timer.After(delays[idx], attemptJoin)
end

--- Classic does not support C_ChatInfo.SendAddonMessage(..., "CHANNEL", ...). Use SendChatMessage(..., "CHANNEL", channelIndex).
function Comms.SendRaceGridChannelLine(channelId, payload)
  if not SendChatMessage or channelId <= 0 or not payload or payload == '' then return end
  -- Hex on the wire: no '|' (chat escapes) and no raw control bytes that might get altered.
  local wire = Comms.PREFIX .. ':' .. Comms.BytesToHex(payload)
  if #wire > 255 then
    -- print(
    --   string.format(
    --     '|cffffffffRace Locked|r: Broadcast dropped (wire too long len=%s, max=255).',
    --     tostring(#wire)
    --   )
    -- )
    return
  end
  SendChatMessage(wire, 'CHANNEL', nil, channelId)
end

function Comms.IsOurDataChannelMessage(...)
  local channelIndex = select(8, ...)
  local channelBaseName = select(9, ...)
  if channelBaseName == Comms.CHANNEL_NAME then
    return true
  end
  local id = tonumber(channelIndex) or 0
  return id > 0 and id == Comms.GetDataChannelId()
end
