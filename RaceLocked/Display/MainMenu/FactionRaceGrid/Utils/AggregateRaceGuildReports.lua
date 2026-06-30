RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion

--- Comma-separated guild slot names for this race (always from the store; never depends on merge/live).
--- @param raceToken string
--- @return string
function RaceLocked_GuildChampion_HardcodedGuildNamesTextForRace(raceToken)
  local names = {}
  local rows =
    G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[raceToken]
  if type(rows) == 'table' then
    for _, e in ipairs(rows) do
      if type(e) == 'table' and e.guildName and e.guildName ~= '' then
        names[#names + 1] = e.guildName
      end
    end
  end
  return table.concat(names, ', ')
end

local function zeroClassesAggregate()
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

--- @param entries table[] guild report rows for one race
--- @return table|nil guildNamesText, averageLevel, classes
function RaceLocked_GuildChampion_AggregateGuildsForRace(entries)
  if not entries or #entries < 1 then
    return nil
  end
  local totalMembers = 0
  local totalLevel60Members = 0
  local weightedSum = 0
  local names = {}
  local classes = {
    druids = {
      count = 0,
      _sumLevel = 0,
    },
    rogues = {
      count = 0,
      _sumLevel = 0,
    },
    hunters = {
      count = 0,
      _sumLevel = 0,
    },
    warriors = {
      count = 0,
      _sumLevel = 0,
    },
    mages = {
      count = 0,
      _sumLevel = 0,
    },
    priests = {
      count = 0,
      _sumLevel = 0,
    },
    warlocks = {
      count = 0,
      _sumLevel = 0,
    },
    paladins = {
      count = 0,
      _sumLevel = 0,
    },
    shamans = {
      count = 0,
      _sumLevel = 0,
    },
  }
  for _, e in ipairs(entries) do
    local sz = tonumber(e.guildSize) or 0
    local av = tonumber(e.averageLevel) or 0
    local lv60 = tonumber(e.guildMembersLevel60) or 0
    if sz > 0 then
      totalMembers = totalMembers + sz
      weightedSum = weightedSum + av * sz
      totalLevel60Members = totalLevel60Members + lv60
    end
    if e.guildName and e.guildName ~= '' then
      names[#names + 1] = e.guildName
    end
    local c = e.classes
    if type(c) == 'table' then
      for k, outEntry in pairs(classes) do
        local inEntry = c[k]
        local inCount = 0
        local inAvg = 0
        if type(inEntry) == 'table' then
          inCount = tonumber(inEntry.count) or 0
          inAvg = tonumber(inEntry.averageLevel) or 0
        else
          inCount = tonumber(inEntry) or 0
        end
        outEntry.count = (tonumber(outEntry.count) or 0) + inCount
        outEntry._sumLevel = (tonumber(outEntry._sumLevel) or 0) + (inAvg * inCount)
      end
    end
  end
  for _, classEntry in pairs(classes) do
    local classCount = tonumber(classEntry.count) or 0
    local classSumLevel = tonumber(classEntry._sumLevel) or 0
    classEntry.averageLevel = classCount > 0 and (classSumLevel / classCount) or 0
    classEntry._sumLevel = nil
  end
  return {
    guildNamesText = table.concat(names, ', '),
    averageLevel = totalMembers > 0 and (weightedSum / totalMembers) or nil,
    classes = classes,
    --- Sum of each row’s `guildSize` (full roster) for this race’s slots. Used for the “Total players” label; class rows may be incomplete for some guilds.
    totalRosterMembers = totalMembers,
    --- Sum of `guildMembersLevel60` across guild rows with data (same slice as guildSize).
    totalLevel60Members = totalLevel60Members,
  }
end

--- Aggregate directly from stored guild rows (DB-backed source of truth).
--- @param raceToken string
--- @return table|nil
function RaceLocked_GuildChampion_GetAggregatedMockForRace(raceToken)
  RaceLocked_GuildChampion_EnsureRaceGridAllowedGuildNamesBuilt()
  local stored =
    G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE and G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE[raceToken]
  local agg =
    RaceLocked_GuildChampion_AggregateGuildsForRace(type(stored) == 'table' and stored or nil)
  local namesText = RaceLocked_GuildChampion_HardcodedGuildNamesTextForRace(raceToken)
  if not agg then
    return {
      guildNamesText = namesText,
      averageLevel = nil,
      classes = zeroClassesAggregate(),
      totalRosterMembers = 0,
      totalLevel60Members = 0,
    }
  end
  agg.guildNamesText = namesText
  return agg
end
