RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion

G.Comms = G.Comms or {}
local Comms = G.Comms

local function PrintIncomingBroadcast(status, reason, report)
  local guildName = report and report.guildName or 'nil'
  local raceToken = report and report.raceToken or 'nil'
  local guildSize = report and report.guildSize or 'nil'
  local ts = report and report.timestamp or 'nil'
  local deaths = report and report.guildDeaths or 'nil'
  -- print(
  --   string.format(
  --     '|cffffffffRace Locked|r: Incoming broadcast %s guild=%s race=%s size=%s ts=%s deaths=%s reason=%s',
  --     tostring(status),
  --     tostring(guildName),
  --     tostring(raceToken),
  --     tostring(guildSize),
  --     tostring(ts),
  --     tostring(deaths),
  --     tostring(reason or '')
  --   )
  -- )
end

function Comms.ApplyIncomingReport(report)
  PrintIncomingBroadcast('RECEIVED', 'payload received', report)
  if not report then
    PrintIncomingBroadcast('REJECTED', 'missing payload', report)
    return false
  end
  local minN = tonumber(G.MIN_GUILD_MEMBERS_FOR_RACE_GRID)
  if (tonumber(report.guildSize) or 0) < minN then
    PrintIncomingBroadcast('REJECTED', 'guild size below minimum', report)
    return false
  end
  if RaceLocked_GuildChampion_EnsureStoredGuildReportsDB then
    RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  end
  if not RaceLocked_GuildChampion_IsGuildNameAllowedForRaceGrid then
    PrintIncomingBroadcast('REJECTED', 'allow-list checker unavailable', report)
    return false
  end
  if not RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid then
    PrintIncomingBroadcast('REJECTED', 'guild-name normalizer unavailable', report)
    return false
  end
  if not RaceLocked_GuildChampion_IsGuildNameAllowedForRaceGrid(report.guildName) then
    PrintIncomingBroadcast('REJECTED', 'guild not allowed for race grid', report)
    return false
  end

  local rows =
    G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[report.raceToken]
  if type(rows) ~= 'table' then
    PrintIncomingBroadcast('REJECTED', 'race bucket missing', report)
    return false
  end

  local incomingNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(report.guildName)
  if incomingNorm == '' then
    PrintIncomingBroadcast('REJECTED', 'normalized incoming guild empty', report)
    return false
  end
  if RaceLocked_GuildChampion_GetNormalizedPlayerGuildName and RaceLocked_GuildChampion_MeetsMinGuildMembersForRaceGrid then
    local ownGuildNorm = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
    if ownGuildNorm ~= '' and incomingNorm == ownGuildNorm and not RaceLocked_GuildChampion_MeetsMinGuildMembersForRaceGrid() then
      PrintIncomingBroadcast('REJECTED', 'own guild below minimum members', report)
      return false
    end
  end

  local incomingTs = tonumber(report.timestamp) or 0

  for _, row in ipairs(rows) do
    if type(row) == 'table' then
      local rowNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(row.guildName)
      if rowNorm ~= '' and rowNorm == incomingNorm then
        local storedTs = tonumber(row.timestamp) or 0
        local acceptByTimestamp = incomingTs > storedTs
        if not acceptByTimestamp and incomingTs == 0 and storedTs == 0 then
          acceptByTimestamp = true
        end
        local incomingDeaths = tonumber(report.guildDeaths) or 0
        local storedDeaths = tonumber(row.guildDeaths) or 0
        local acceptByDeaths = incomingDeaths > storedDeaths
        if not acceptByTimestamp and not acceptByDeaths then
          PrintIncomingBroadcast(
            'REJECTED',
            'incoming report not newer and no death increase',
            report
          )
          return false
        end
        if acceptByTimestamp then
          row.guildSize = report.guildSize
          row.averageLevel = report.averageLevel
          row.classes = report.classes or Comms.EmptyClasses()
          row.guildMembersLevel60 = tonumber(report.guildMembersLevel60) or 0
          local incomingAch = tonumber(report.guildAchievementsAverage) or 0
          if incomingAch > 0 then
            row.guildAchievementsAverage = incomingAch
          end
          row.timestamp = incomingTs
        end
        if acceptByDeaths then
          row.guildDeaths = incomingDeaths
        end
        PrintIncomingBroadcast(
          'ACCEPTED',
          string.format(
            'applied update byTimestamp=%s byDeaths=%s storedTs=%s incomingTs=%s storedDeaths=%s incomingDeaths=%s',
            tostring(acceptByTimestamp),
            tostring(acceptByDeaths),
            tostring(storedTs),
            tostring(incomingTs),
            tostring(storedDeaths),
            tostring(incomingDeaths)
          ),
          report
        )
        if RaceLocked_GuildChampion_PersistStoredGuildReportsByRace then
          RaceLocked_GuildChampion_PersistStoredGuildReportsByRace()
        end
        if RaceLocked_GuildChampion_RequestRaceGridRerender then
          RaceLocked_GuildChampion_RequestRaceGridRerender()
        end
        return true
      end
    end
  end
  PrintIncomingBroadcast('REJECTED', 'no matching guild row found', report)
  return false
end

--- Apply a guild-death event coming from the RaceLockedDataBus channel.
--- @param event table { guildName: string, raceToken: string }
--- @return boolean
function Comms.ApplyIncomingGuildDeath(event)
  if type(event) ~= 'table' then
    return false
  end
  local guildName = event.guildName
  local raceToken = event.raceToken
  if type(guildName) ~= 'string' or guildName == '' or type(
    raceToken
  ) ~= 'string' or raceToken == '' then
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
  if not RaceLocked_GuildChampion_IsGuildNameAllowedForRaceGrid(guildName) then
    return false
  end

  local rows =
    G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[raceToken]
  if type(rows) ~= 'table' then
    return false
  end
  local incomingNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(guildName)
  if incomingNorm == '' then
    return false
  end

  for _, row in ipairs(rows) do
    if type(row) == 'table' then
      local rowNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(row.guildName)
      if rowNorm ~= '' and rowNorm == incomingNorm then
        row.guildDeaths = (tonumber(row.guildDeaths) or 0) + 1
        -- print(
        --   string.format(
        --     '|cffffffffRace Locked|r: Received bus death event for %s (%s), incrementing guild deaths.',
        --     tostring(guildName),
        --     tostring(raceToken)
        --   )
        -- )
        if RaceLocked_GuildChampion_PersistStoredGuildReportsByRace then
          RaceLocked_GuildChampion_PersistStoredGuildReportsByRace()
        end
        if RaceLocked_GuildChampion_RequestRaceGridRerender then
          RaceLocked_GuildChampion_RequestRaceGridRerender()
        end
        return true
      end
    end
  end
  return false
end
