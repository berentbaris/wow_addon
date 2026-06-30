-- Guild roster slice for the race grid: members of a given API race token in your guild (class counts + average level).
-- `RaceLocked_GetGuildRaceGridReportForRaceToken` scans the roster; snapshots persist via `RaceGridGuildSnapshot.lua`.

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion

local fileToReportKey

local function ensureClassFileMap()
  if fileToReportKey then return end
  fileToReportKey = {}
  for reportKey, classFile in pairs(G.CLASS_KEY_TO_FILE) do
    fileToReportKey[classFile] = reportKey
  end
end

local function emptyClasses()
  local t = {}
  for i = 1, #G.CLASS_REPORT_KEYS do
    t[G.CLASS_REPORT_KEYS[i].key] = {
      count = 0,
      sumLevel = 0,
      averageLevel = 0,
    }
  end
  return t
end

--- @param a string|nil
--- @param b string|nil
local function raceTokensMatch(a, b)
  if not a or not b or a == '' or b == '' then
    return false
  end
  return string.lower(a) == string.lower(b)
end

--- @param name string|nil
local function stripRealmFromRosterName(name)
  if name == nil or name == '' then
    return ''
  end
  local s = tostring(name)
  local dash = string.find(s, '-', 1, true)
  if not dash or dash <= 1 then
    return s
  end
  return string.sub(s, 1, dash - 1)
end

--- If return 17 is not a Player-/Character- GUID, scan other return indices (same roster row).
--- @param index number
--- @param guid17 string|nil
--- @return string|nil
local function resolveGuidFromRosterRow(index, guid17)
  if type(guid17) == 'string' and guid17 ~= '' then
    if string.find(guid17, '^Player%-') or string.find(guid17, '^Character%-') then
      return guid17
    end
  end
  for j = 1, 24 do
    local v = select(j, GetGuildRosterInfo(index))
    if type(v) == 'string' and v ~= '' then
      if string.find(v, '^Player%-') or string.find(v, '^Character%-') then
        return v
      end
    end
  end
  return nil
end

--- Guild roster slice for one API race token (all guild members of that race in your guild).
--- @param raceToken string e.g. Human, NightElf, Scourge
--- @return table|nil row { guildName, guildSize, guildMembersLevel60, averageLevel, classes, guildAchievementsAverage } or nil if not in a guild / no members of that race
function RaceLocked_GetGuildRaceGridReportForRaceToken(raceToken)
  if not raceToken or raceToken == '' then
    return nil
  end
  if not IsInGuild or not IsInGuild() or not GetGuildInfo or not GetGuildRosterInfo then
    return nil
  end
  local guildName = GetGuildInfo('player')
  if type(guildName) ~= 'string' or guildName == '' then
    return nil
  end
  ensureClassFileMap()
  local classes = emptyClasses()
  local sumLevel = 0
  local n = 0
  local membersLevel60 = 0
  local total = GetNumGuildMembers(true)
  if not total or tonumber(total) < 1 then
    total = GetNumGuildMembers()
  end
  total = tonumber(total) or 0
  if total < G.MIN_GUILD_MEMBERS_FOR_RACE_GRID then
    return nil
  end

  local playerShort = UnitName('player') and stripRealmFromRosterName(UnitName('player')) or ''
  local rosterNames = {}
  for i = 1, total do
    -- Returns (warcraft.wiki.gg): … class (11), …, guid (17) • not an 18th slot.
    local name, _, _, level, _, _, _, _, _, _, classFile, _, _, _, _, guid17 = GetGuildRosterInfo(i)
    local memberShort = stripRealmFromRosterName(name)
    if memberShort ~= '' then
      rosterNames[memberShort] = true
    end
    local levelNum = tonumber(level) or 0
    local guid = resolveGuidFromRosterRow(i, guid17)

    local engRace = nil
    local engClass = nil
    if guid and guid ~= '' and GetPlayerInfoByGUID then
      -- localizedClass, englishClass, localizedRace, englishRace (e.g. NightElf)
      local _, classTok, _, raceTok = GetPlayerInfoByGUID(guid)
      engClass = classTok
      engRace = raceTok
    end

    if not engRace and name and playerShort ~= '' then
      local rosterShort = stripRealmFromRosterName(name)
      if rosterShort ~= '' and string.lower(rosterShort) == string.lower(
        playerShort
      ) and UnitRace then
        _, engRace = UnitRace('player')
      end
    end

    if not engClass and classFile and classFile ~= '' then
      engClass = classFile
    end

    if engRace and raceTokensMatch(engRace, raceToken) then
      n = n + 1
      if levelNum == 60 then
        membersLevel60 = membersLevel60 + 1
      end
      if levelNum > 0 then
        sumLevel = sumLevel + levelNum
      end
      local effClass = engClass and string.upper(tostring(engClass)) or nil
      local rk = effClass and fileToReportKey[effClass]
      if rk then
        local classEntry = classes[rk]
        if type(classEntry) ~= 'table' then
          classEntry = {
            count = 0,
            sumLevel = 0,
            averageLevel = 0,
          }
          classes[rk] = classEntry
        end
        classEntry.count = (tonumber(classEntry.count) or 0) + 1
        if levelNum > 0 then
          classEntry.sumLevel = (tonumber(classEntry.sumLevel) or 0) + levelNum
        end
      end
    end
  end
  if n < 1 then
    return nil
  end
  for _, classEntry in pairs(classes) do
    if type(classEntry) == 'table' then
      local classCount = tonumber(classEntry.count) or 0
      local classSumLevel = tonumber(classEntry.sumLevel) or 0
      classEntry.averageLevel = classCount > 0 and (classSumLevel / classCount) or 0
      classEntry.sumLevel = nil
    end
  end

  if RaceLocked_AchievementTracking_CleanupForRoster then
    RaceLocked_AchievementTracking_CleanupForRoster(guildName, rosterNames)
  end
  local guildAchievementsAverage = 0
  if RaceLocked_AchievementTracking_GetGuildAveragePoints then
    guildAchievementsAverage = RaceLocked_AchievementTracking_GetGuildAveragePoints(guildName) or 0
  end

  return {
    guildName = guildName:match('^%s*(.-)%s*$') or guildName,
    guildSize = n,
    guildMembersLevel60 = membersLevel60,
    -- Always a number when n > 0 so merge/weighting can show a level (even if roster levels read as 0).
    averageLevel = n > 0 and (sumLevel / n) or nil,
    classes = classes,
    guildAchievementsAverage = guildAchievementsAverage,
  }
end

--- Total guild roster rows (online-first count, then full roster), for race grid gating.
--- @return number
function RaceLocked_GuildChampion_GetGuildRosterMemberCount()
  if not GetNumGuildMembers then
    return 0
  end
  -- Do not use tonumber(select(1, GetNumGuildMembers())): select returns all tail values, so tonumber would get a bogus radix.
  local total = GetNumGuildMembers(true)
  total = tonumber(total) or 0
  if total < 1 then
    total = GetNumGuildMembers()
    total = tonumber(total) or 0
  end
  return total
end

--- When not in a guild, always true. When in a guild, true only if roster has at least MIN_GUILD_MEMBERS_FOR_RACE_GRID.
--- @return boolean
function RaceLocked_GuildChampion_MeetsMinGuildMembersForRaceGrid()
  if not IsInGuild or not IsInGuild() then
    return true
  end
  local minN = tonumber(G.MIN_GUILD_MEMBERS_FOR_RACE_GRID)
  return RaceLocked_GuildChampion_GetGuildRosterMemberCount() >= minN
end
