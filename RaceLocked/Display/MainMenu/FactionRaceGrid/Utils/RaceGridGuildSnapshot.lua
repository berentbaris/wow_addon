-- Persist last guild roster breakdown for the faction race grid in RaceLockedAccountDB (shared across characters).

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}

local function copyGuildReportRow(e)
  if type(e) ~= 'table' then
    return nil
  end
  local c = {}
  if type(e.classes) == 'table' then
    for k, v in pairs(e.classes) do
      c[k] = v
    end
  end
  return {
    guildName = e.guildName,
    guildSize = e.guildSize,
    guildMembersLevel60 = tonumber(e.guildMembersLevel60) or 0,
    averageLevel = e.averageLevel,
    classes = c,
  }
end

--- Ensure `RaceLockedAccountDB.raceGridGuildSnapshot` exists (called from ADDON_LOADED and before save).
function RaceLocked_GuildChampion_EnsureRaceGridGuildSnapshotDB()
  RaceLockedAccountDB = RaceLockedAccountDB or {}
  local s = RaceLockedAccountDB.raceGridGuildSnapshot
  if type(s) ~= 'table' then
    s = {}
    RaceLockedAccountDB.raceGridGuildSnapshot = s
  end
  if type(s.byRace) ~= 'table' then
    s.byRace = {}
  end
  if type(s.normalizedGuild) ~= 'string' then
    s.normalizedGuild = ''
  end
end

--- Scan the current guild roster and store one report row per `raceToken` (your guild only).
--- Call after `GuildRoster()` and optional delay so `GetGuildRosterInfo` is populated.
--- @param raceTokens string[] e.g. four faction race API tokens in grid order
function RaceLocked_GuildChampion_SaveRaceGridGuildSnapshotFromRoster(raceTokens)
  RaceLocked_GuildChampion_EnsureRaceGridGuildSnapshotDB()
  local snap = RaceLockedAccountDB.raceGridGuildSnapshot
  snap.byRace = {}
  if not raceTokens or #raceTokens < 1 then
    snap.normalizedGuild = ''
    return
  end
  if not IsInGuild or not IsInGuild() or not RaceLocked_GuildChampion_GetNormalizedPlayerGuildName then
    snap.normalizedGuild = ''
    return
  end
  local gnorm = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
  if gnorm == '' then
    snap.normalizedGuild = ''
    return
  end
  snap.normalizedGuild = gnorm
  if not RaceLocked_GetGuildRaceGridReportForRaceToken then return end
  for i = 1, #raceTokens do
    local token = raceTokens[i]
    local row = RaceLocked_GetGuildRaceGridReportForRaceToken(token)
    if row then
      snap.byRace[token] = copyGuildReportRow(row)
    end
  end
end

--- Row from last manual refresh for this race, if snapshot guild matches the guild you are in now.
--- @param raceToken string
--- @return table|nil
function RaceLocked_GuildChampion_GetSnapshotGuildRowForRace(raceToken)
  if not raceToken or raceToken == '' or not RaceLockedAccountDB or type(
    RaceLockedAccountDB.raceGridGuildSnapshot
  ) ~= 'table' then
    return nil
  end
  local snap = RaceLockedAccountDB.raceGridGuildSnapshot
  if not RaceLocked_GuildChampion_GetNormalizedPlayerGuildName then
    return nil
  end
  local pg = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
  if pg == '' or snap.normalizedGuild ~= pg then
    return nil
  end
  local row = snap.byRace and snap.byRace[raceToken]
  if type(row) ~= 'table' then
    return nil
  end
  return row
end
