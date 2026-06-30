-- Per-race guild slots for the race grid: hardcoded guild names, numeric fields start at 0.
-- Update `RaceLocked_GuildChampion.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE` from addon messages or other code;
-- the whitelist is derived from these names (see AllowedRaceGridGuildNames.lua).

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion

local function zeroClasses()
  return {
    druids = {
      count = 0,
      averageLevel = 0,
    },
    rogues = {
      count = 0,
      averageLevel = 0,
    },
    hunters = {
      count = 0,
      averageLevel = 0,
    },
    warriors = {
      count = 0,
      averageLevel = 0,
    },
    mages = {
      count = 0,
      averageLevel = 0,
    },
    priests = {
      count = 0,
      averageLevel = 0,
    },
    warlocks = {
      count = 0,
      averageLevel = 0,
    },
    paladins = {
      count = 0,
      averageLevel = 0,
    },
    shamans = {
      count = 0,
      averageLevel = 0,
    },
  }
end

local function guildRow(guildName)
  return {
    guildName = guildName,
    guildSize = 0,
    guildMembersLevel60 = 0,
    guildDeaths = 0,
    guildAchievementsAverage = 0,
    averageLevel = 0,
    classes = zeroClasses(),
    --- Unix time: last broadcast stamp (realm server clock via GetRaceGridStoredUnixTime when possible),
    --- or last applied incoming stamp. UI shows US Eastern (EST/EDT) for the same instant for everyone.
    timestamp = 0,
  }
end

--- @type table<string, table[]>
local DEFAULT_RACE_GRID_STORED_GUILD_REPORTS_BY_RACE = {
  Human = { guildRow('Human Error'), guildRow('Honorcore') },
  NightElf = { guildRow('ELFCORE'), guildRow('NELFCORE'), guildRow('NIGHTCORE') },
  Dwarf = { guildRow('STONECORE'), guildRow('ROCKCORE') },
  Gnome = { guildRow('FOR GNOMEREGAN') },
  Orc = { guildRow('ZUGCORE') },
  Troll = { guildRow('Hardingo') },
  Tauren = { guildRow('HERDCORE') },
  Scourge = { guildRow('DEADCORE') },
}

local function copyClasses(classes)
  local src = type(classes) == 'table' and classes or {}
  local c = zeroClasses()
  for k, _ in pairs(c) do
    local classEntry = src[k]
    if type(classEntry) == 'table' then
      c[k] = {
        count = tonumber(classEntry.count) or 0,
        averageLevel = tonumber(classEntry.averageLevel) or 0,
      }
    else
      -- Backward-compatible upgrade from older numeric-only class counts.
      c[k] = {
        count = tonumber(classEntry) or 0,
        averageLevel = 0,
      }
    end
  end
  return c
end

local function minGuildMembersForStore()
  return tonumber(G.MIN_GUILD_MEMBERS_FOR_RACE_GRID)
end

local function coerceGuildRow(row, defaultRow)
  local src = type(row) == 'table' and row or {}
  local guildSize = tonumber(src.guildSize) or 0
  local averageLevel = tonumber(src.averageLevel) or 0
  local classes = copyClasses(src.classes)
  local timestamp = tonumber(src.timestamp) or 0
  local guildDeaths = tonumber(src.guildDeaths)
  if guildDeaths == nil then
    guildDeaths = tonumber(defaultRow.guildDeaths) or 0
  end
  local guildAchievementsAverage = tonumber(src.guildAchievementsAverage)
  if guildAchievementsAverage == nil then
    guildAchievementsAverage = tonumber(defaultRow.guildAchievementsAverage) or 0
  end
  local guildMembersLevel60 = tonumber(src.guildMembersLevel60)
  if guildMembersLevel60 == nil then
    guildMembersLevel60 = tonumber(defaultRow.guildMembersLevel60) or 0
  end
  if guildSize > 0 and guildSize < minGuildMembersForStore() then
    guildSize = 0
    averageLevel = 0
    classes = zeroClasses()
    timestamp = 0
    guildMembersLevel60 = 0
  end
  if guildSize == 0 then
    timestamp = 0
    guildMembersLevel60 = 0
  end
  return {
    guildName = defaultRow.guildName,
    guildSize = guildSize,
    guildMembersLevel60 = guildMembersLevel60,
    guildDeaths = guildDeaths,
    guildAchievementsAverage = guildAchievementsAverage,
    averageLevel = averageLevel,
    classes = classes,
    timestamp = timestamp,
  }
end

local function buildStoredGuildReportsByRace(savedByRace)
  local out = {}
  local saved = type(savedByRace) == 'table' and savedByRace or {}
  for raceToken, defaults in pairs(DEFAULT_RACE_GRID_STORED_GUILD_REPORTS_BY_RACE) do
    out[raceToken] = {}
    local savedRows = type(saved[raceToken]) == 'table' and saved[raceToken] or {}
    for i = 1, #defaults do
      local defaultRow = defaults[i]
      out[raceToken][i] = coerceGuildRow(savedRows[i], defaultRow)
    end
  end
  return out
end

local function ensureStoredGuildReportsDB()
  RaceLockedAccountDB = RaceLockedAccountDB or {}
  RaceLockedAccountDB.raceGridStoredGuildReportsByRace =
    buildStoredGuildReportsByRace(RaceLockedAccountDB.raceGridStoredGuildReportsByRace)
  G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE = RaceLockedAccountDB.raceGridStoredGuildReportsByRace
end

--- Ensure the race-grid stored rows are present and linked to RaceLockedAccountDB (all characters on this account).
function RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  ensureStoredGuildReportsDB()
end

--- Persist current in-memory stored rows back to RaceLockedAccountDB.
--- Useful after mutating rows from incoming race-grid channel reports.
function RaceLocked_GuildChampion_PersistStoredGuildReportsByRace()
  RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  RaceLockedAccountDB.raceGridStoredGuildReportsByRace = G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE
end

local function normalizeGuildName(name)
  if RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid then
    return RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(name)
  end
  local s = tostring(name or ''):match('^%s*(.-)%s*$') or ''
  if s == '' then
    return ''
  end
  return string.lower(s)
end

local function applyRowReport(targetRow, report)
  if type(targetRow) ~= 'table' then
    return false
  end
  local guildSize = tonumber(report and report.guildSize) or 0
  if guildSize < minGuildMembersForStore() then
    return false
  end
  targetRow.guildSize = guildSize
  targetRow.averageLevel = tonumber(report and report.averageLevel) or 0
  targetRow.classes = copyClasses(report and report.classes)
  targetRow.guildMembersLevel60 = tonumber(report and report.guildMembersLevel60) or 0
  -- Roster refresh does not imply a broadcast stamp; timestamp is owned by comms apply / own broadcast.
  targetRow.guildAchievementsAverage =
    tonumber(report and report.guildAchievementsAverage) or targetRow.guildAchievementsAverage or 0
  return true
end

--- Refresh your guild's stored rows from live roster data for each race token.
--- Only rows whose guild name matches your current guild are updated.
--- @param raceTokens string[]
--- @return boolean true when at least one row was updated
function RaceLocked_GuildChampion_UpdateOwnStoredGuildReportsFromRoster(raceTokens)
  RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  if not raceTokens or #raceTokens < 1 then
    return false
  end
  if not RaceLocked_GetGuildRaceGridReportForRaceToken or not RaceLocked_GuildChampion_GetNormalizedPlayerGuildName then
    return false
  end
  local ownGuildNorm = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
  if ownGuildNorm == '' then
    return false
  end

  local changed = false
  for i = 1, #raceTokens do
    local raceToken = raceTokens[i]
    local rows =
      G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[raceToken]
    if type(rows) == 'table' then
      local report = RaceLocked_GetGuildRaceGridReportForRaceToken(raceToken)
      for _, row in ipairs(rows) do
        if type(row) == 'table' and normalizeGuildName(row.guildName) == ownGuildNorm then
          if applyRowReport(row, report) then
            changed = true
          end
        end
      end
    end
  end

  if changed then
    RaceLocked_GuildChampion_PersistStoredGuildReportsByRace()
  end
  return changed
end

--- Increment `guildDeaths` on stored rows for the current player's race column that match their guild.
--- @return boolean true when any row was updated
function RaceLocked_GuildChampion_IncrementGuildDeathsForOwnGuild()
  RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  if not RaceLocked_GuildChampion_GetNormalizedPlayerGuildName then
    return false
  end
  local ownGuildNorm = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName() or ''
  if ownGuildNorm == '' then
    return false
  end
  local playerRaceToken = ''
  if UnitRace then
    local _, token = UnitRace('player')
    playerRaceToken = type(token) == 'string' and token or ''
  end
  if playerRaceToken == '' then
    return false
  end
  local rows =
    G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[playerRaceToken]
  if type(rows) ~= 'table' then
    return false
  end
  local changed = false
  for _, row in ipairs(rows) do
    if type(row) == 'table' and normalizeGuildName(row.guildName) == ownGuildNorm then
      row.guildDeaths = (tonumber(row.guildDeaths) or 0) + 1
      changed = true
    end
  end
  if changed then
    RaceLocked_GuildChampion_PersistStoredGuildReportsByRace()
    if RaceLocked_GuildChampion_RequestRaceGridRerender then
      RaceLocked_GuildChampion_RequestRaceGridRerender()
    end
  end
  return changed
end

--- Sum `guildDeaths` across all guild slots stored for one race (for UI).
--- @param raceToken string
--- @return number
function RaceLocked_GuildChampion_GetTotalGuildDeathsForRace(raceToken)
  RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  local rows =
    G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[raceToken]
  if type(rows) ~= 'table' then
    return 0
  end
  local sum = 0
  for _, row in ipairs(rows) do
    if type(row) == 'table' then
      sum = sum + (tonumber(row.guildDeaths) or 0)
    end
  end
  return sum
end

--- Member-weighted average of `guildAchievementsAverage` for stored guild rows of one race (for UI).
--- Guilds with 0 achievement average are excluded (0 means no data, not zero points).
--- @param raceToken string
--- @return number 0 when no guilds have reported achievement data
function RaceLocked_GuildChampion_GetWeightedGuildAchievementsAverageForRace(raceToken)
  RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  local rows =
    G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[raceToken]
  if type(rows) ~= 'table' then
    return 0
  end
  local totalMembers = 0
  local weighted = 0
  for _, row in ipairs(rows) do
    if type(row) == 'table' then
      local sz = tonumber(row.guildSize) or 0
      local ach = tonumber(row.guildAchievementsAverage) or 0
      if sz > 0 and ach > 0 then
        totalMembers = totalMembers + sz
        weighted = weighted + ach * sz
      end
    end
  end
  if totalMembers <= 0 then
    return 0
  end
  return weighted / totalMembers
end

ensureStoredGuildReportsDB()
