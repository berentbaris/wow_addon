--- Per-player achievement points storage for guild members.
--- Each player's totalPoints (from HardcoreAchievements) are stored in RaceLockedAccountDB
--- keyed by normalized guild name, so alts in the same guild share the same store.

local function normalizeGuild(name)
  if RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid then
    return RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(name)
  end
  local s = tostring(name or ''):match('^%s*(.-)%s*$') or ''
  if s == '' then
    return ''
  end
  return string.lower(s)
end

local function ensureDB(guildName)
  RaceLockedAccountDB = RaceLockedAccountDB or {}
  RaceLockedAccountDB.guildAchievementPoints = RaceLockedAccountDB.guildAchievementPoints or {}
  local norm = normalizeGuild(guildName)
  if norm == '' then
    return nil, ''
  end
  RaceLockedAccountDB.guildAchievementPoints[norm] =
    RaceLockedAccountDB.guildAchievementPoints[norm] or {}
  return RaceLockedAccountDB.guildAchievementPoints[norm], norm
end

--- Store (or update) a player's totalPoints for a guild.
--- Uses max(stored, incoming) since achievement points only go up.
--- @param guildName string
--- @param playerName string
--- @param totalPoints number
function RaceLocked_AchievementTracking_SetPlayerPoints(guildName, playerName, totalPoints)
  local store = ensureDB(guildName)
  if not store then return end
  if type(playerName) ~= 'string' or playerName == '' then return end
  local incoming = tonumber(totalPoints) or 0
  local existing = tonumber(store[playerName]) or 0
  if incoming >= existing then
    store[playerName] = incoming
  end
end

--- Get a single player's stored totalPoints (or 0 if unknown).
--- @param guildName string
--- @param playerName string
--- @return number
function RaceLocked_AchievementTracking_GetPlayerPoints(guildName, playerName)
  local store = ensureDB(guildName)
  if not store or type(playerName) ~= 'string' or playerName == '' then
    return 0
  end
  return tonumber(store[playerName]) or 0
end

--- Compute average achievement points across all stored players for a guild.
--- Players who have reported 0 still count toward the denominator.
--- @param guildName string
--- @return number
function RaceLocked_AchievementTracking_GetGuildAveragePoints(guildName)
  local store = ensureDB(guildName)
  if not store then
    return 0
  end
  local sum = 0
  local count = 0
  for _, pts in pairs(store) do
    local n = tonumber(pts) or 0
    sum = sum + n
    count = count + 1
  end
  if count <= 0 then
    return 0
  end
  return sum / count
end

--- Number of players who have reported achievement points for a guild.
--- @param guildName string
--- @return number
function RaceLocked_AchievementTracking_GetGuildReportingCount(guildName)
  local store = ensureDB(guildName)
  if not store then
    return 0
  end
  local count = 0
  for _ in pairs(store) do
    count = count + 1
  end
  return count
end

--- Return the full store table for a guild (for relay broadcasting).
--- @param guildName string
--- @return table<string, number>|nil
function RaceLocked_AchievementTracking_GetAllPlayerPoints(guildName)
  return ensureDB(guildName)
end

--- Remove stored entries for players no longer in the guild roster.
--- @param guildName string
--- @param rosterNames table<string, boolean> set of player names currently in the roster
function RaceLocked_AchievementTracking_CleanupForRoster(guildName, rosterNames)
  local store = ensureDB(guildName)
  if not store or type(rosterNames) ~= 'table' then return end
  for name, _ in pairs(store) do
    if not rosterNames[name] then
      store[name] = nil
    end
  end
end
