-- Shared Race Locked leaderboard data and sorting (settings tab + main screen).

function RaceLocked_GetPlayerAchievementPoints()
  if type(RaceLocked_GetHCATotalPoints) == 'function' then
    return RaceLocked_GetHCATotalPoints()
  end
  return 0
end

function RaceLocked_GetPlayerLeaderboardRow()
  local name = UnitName and UnitName('player')
  local level = UnitLevel and UnitLevel('player')
  if not level or level < 1 then
    level = 1
  end
  local guid = UnitGUID and UnitGUID('player')
  return {
    name = name,
    playerId = guid,
    level = level,
    achievementPoints = RaceLocked_GetPlayerAchievementPoints(),
    enemiesSlain = (RaceLocked_GetPlayerEnemiesSlain and RaceLocked_GetPlayerEnemiesSlain()) or 0,
    dungeonsCompleted = (RaceLocked_GetPlayerDungeonCompletions and RaceLocked_GetPlayerDungeonCompletions()) or 0,
    playerJumps = (RaceLocked_GetPlayerJumpCount and RaceLocked_GetPlayerJumpCount()) or 0,
  }
end

-- Guild roster / broadcast names are often "Name-Realm"; strip realm for UI labels.
function RaceLocked_LeaderboardDisplayName(name)
  if name == nil or name == '' then
    return name
  end
  local s = tostring(name)
  local dash = string.find(s, '-', 1, true)
  if not dash or dash <= 1 then
    return s
  end
  return string.sub(s, 1, dash - 1)
end

local function leaderboardCompare(a, b)
  local la, lb = a.level or 0, b.level or 0
  if la ~= lb then
    return la > lb
  end
  local apA = a.achievementPoints or 0
  local apB = b.achievementPoints or 0
  if apA ~= apB then
    return apA > apB
  end
  local na, nb = tostring(a.name or ''), tostring(b.name or '')
  return na < nb
end

--- Shallow copy of leaderboard rows (pass `source` or omit to use the current guild-sorted list).
function RaceLocked_CopyLeaderboardEntries(source)
  local r = {}
  local t = source
  if not t then
    t = RaceLocked_GetSortedGuildLeaderboardCopy()
  end
  for i = 1, #t do
    r[i] = t[i]
  end
  return r
end

function RaceLocked_SortLeaderboardInPlace(rows)
  table.sort(rows, leaderboardCompare)
end

local function achievementPointsLeaderboardCompare(a, b)
  local apA = a.achievementPoints or 0
  local apB = b.achievementPoints or 0
  if apA ~= apB then
    return apA > apB
  end
  local la, lb = a.level or 0, b.level or 0
  if la ~= lb then
    return la > lb
  end
  return tostring(a.name or '') < tostring(b.name or '')
end

--- Highest `achievementPoints` in `rows` (tie: level, then name). Does not mutate `rows`.
function RaceLocked_GetTopAchievementPointsLeaderboardRowFromRows(rows)
  if not rows or #rows == 0 then
    return nil
  end
  local copy = RaceLocked_CopyLeaderboardEntries(rows)
  table.sort(copy, achievementPointsLeaderboardCompare)
  return copy[1]
end

-- Single roster from `RaceLockedDB.guildPeers` plus local player (live HCA), sorted.
-- One row per `playerId`; newer `lastSeen` wins if saved data ever has duplicate keys/entries.
function RaceLocked_GetSortedGuildLeaderboardCopy(guildKey)
  local byPlayerId = {}
  local peers = RaceLockedDB and RaceLockedDB.guildPeers
  if type(peers) == 'table' then
    for _, e in pairs(peers) do
      if type(e) == 'table' and e.name and e.playerId then
        local pid = e.playerId
        local ts = type(e.lastSeen) == 'number' and e.lastSeen or 0
        local prev = byPlayerId[pid]
        if not prev or ts >= (prev._ts or 0) then
          byPlayerId[pid] = {
            name = e.name,
            playerId = pid,
            achievementPoints = e.achievementPoints or 0,
            enemiesSlain = e.enemiesSlain or 0,
            dungeonsCompleted = e.dungeonsCompleted or 0,
            playerJumps = e.playerJumps or 0,
            level = e.level or 1,
            _ts = ts,
          }
        end
      end
    end
  end

  local rows = {}
  for _, row in pairs(byPlayerId) do
    row._ts = nil
    rows[#rows + 1] = row
  end

  local player = RaceLocked_GetPlayerLeaderboardRow()
  local myGuid = player.playerId
  local found = false
  if myGuid then
    for i = 1, #rows do
      if rows[i].playerId == myGuid then
        rows[i].name = player.name
        rows[i].achievementPoints = player.achievementPoints
        rows[i].enemiesSlain = player.enemiesSlain
        rows[i].dungeonsCompleted = player.dungeonsCompleted
        rows[i].playerJumps = player.playerJumps
        rows[i].level = player.level
        found = true
        break
      end
    end
  end
  if not found then
    rows[#rows + 1] = player
  end

  RaceLocked_SortLeaderboardInPlace(rows)
  return rows
end

function RaceLocked_GetSortedLeaderboardCopy()
  return RaceLocked_GetSortedGuildLeaderboardCopy()
end

function RaceLocked_GetSortedOtherLeaderboardCopy()
  return RaceLocked_GetSortedGuildLeaderboardCopy()
end

-- Alias for compatibility with older callers.
function RaceLocked_GetSortedCombinedLeaderboardCopy()
  return RaceLocked_GetSortedGuildLeaderboardCopy()
end

function RaceLocked_IsLocalLeaderboardName(name)
  local nm = string.lower(tostring(name or ''))
  if nm == '' then
    return false
  end
  local un = UnitName and UnitName('player')
  if un and string.lower(un) == nm then
    return true
  end
  return false
end

--- Prefer matching `playerId` to `UnitGUID('player')` so duplicate display names stay distinct.
function RaceLocked_IsLocalLeaderboardRow(row)
  if not row then
    return false
  end
  local myGuid = UnitGUID and UnitGUID('player')
  if myGuid and row.playerId and row.playerId == myGuid then
    return true
  end
  return RaceLocked_IsLocalLeaderboardName(row.name)
end

-- Up to `maxRows` entries; your row centered when possible.
function RaceLocked_GetMainScreenHardcoreLeaderboardWindow(maxRows)
  maxRows = maxRows or 7
  local sorted = RaceLocked_GetSortedGuildLeaderboardCopy()
  local n = #sorted
  if n == 0 then
    return {}, 1
  end

  local midSlot = math.floor(maxRows / 2) + 1
  local playerIdx
  for i = 1, n do
    if RaceLocked_IsLocalLeaderboardRow(sorted[i]) then
      playerIdx = i
      break
    end
  end
  if not playerIdx then
    playerIdx = math.min(midSlot, n)
  end

  local start = playerIdx - (midSlot - 1)
  if start < 1 then
    start = 1
  end
  if start + maxRows - 1 > n then
    start = math.max(1, n - maxRows + 1)
  end

  local window = {}
  for i = 1, maxRows do
    window[i] = sorted[start + i - 1]
  end
  return window, start
end

-- Compatibility alias: now returns the same single leaderboard window.
function RaceLocked_GetMainScreenOtherLeaderboardWindow(maxRows)
  return RaceLocked_GetMainScreenHardcoreLeaderboardWindow(maxRows)
end

-- Main on-screen panel uses the same single leaderboard list.
function RaceLocked_GetMainScreenCombinedLeaderboardWindow(maxRows)
  return RaceLocked_GetMainScreenHardcoreLeaderboardWindow(maxRows)
end

RaceLocked_GetMainScreenLeaderboardWindow = RaceLocked_GetMainScreenCombinedLeaderboardWindow

function RaceLocked_NotifyMainScreenLeaderboardDataChanged()
  if RaceLocked_RefreshMainScreenLeaderboard then
    RaceLocked_RefreshMainScreenLeaderboard()
  end
end

function RaceLocked_NotifyLeaderboardDataChanged()
  RaceLocked_NotifyMainScreenLeaderboardDataChanged()
  if RaceLocked_RefreshGuildLeaderboardTabUI then
    RaceLocked_RefreshGuildLeaderboardTabUI()
  end
end
