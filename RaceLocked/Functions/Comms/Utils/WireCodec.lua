RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion

G.Comms = G.Comms or {}
local Comms = G.Comms

Comms.PREFIX = 'RLRaceGridV1'
Comms.CHANNEL_NAME = 'RaceLockedDataBus'
Comms.WIRE_FIELD_SEP = '\001'

function Comms.BytesToHex(s)
  if type(s) ~= 'string' or s == '' then
    return ''
  end
  local t = {}
  for i = 1, #s do
    t[i] = string.format('%02x', string.byte(s, i))
  end
  return table.concat(t)
end

function Comms.HexToBytes(h)
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

function Comms.EmptyClasses()
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

local function classWireCount(classEntry)
  if type(classEntry) == 'table' then
    return tonumber(classEntry.count) or 0
  end
  return tonumber(classEntry) or 0
end

local function classWireAverage(classEntry)
  if type(classEntry) == 'table' then
    return tonumber(classEntry.averageLevel) or 0
  end
  return 0
end

local function wireInt(n)
  local v = tonumber(n) or 0
  return math.floor(v + 0.5)
end

function Comms.SanitizeGuildName(name)
  local s = tostring(name or '')
  s = s:gsub('|', '/')
  s = s:gsub(Comms.WIRE_FIELD_SEP, '')
  return s
end

function Comms.BuildPayload(raceToken, row)
  if type(row) ~= 'table' then
    return nil
  end
  local c = row.classes or Comms.EmptyClasses()
  local ts = wireInt(row.timestamp)
  local deaths = wireInt(row.guildDeaths)
  local achAvg = wireInt(row.guildAchievementsAverage)
  return table.concat(
    {
      'v5',
      tostring(raceToken or ''),
      Comms.SanitizeGuildName(row.guildName or ''),
      tostring(wireInt(row.guildSize)),
      tostring(wireInt(row.averageLevel)),
      tostring(wireInt(classWireCount(c.druids))),
      tostring(wireInt(classWireAverage(c.druids))),
      tostring(wireInt(classWireCount(c.rogues))),
      tostring(wireInt(classWireAverage(c.rogues))),
      tostring(wireInt(classWireCount(c.hunters))),
      tostring(wireInt(classWireAverage(c.hunters))),
      tostring(wireInt(classWireCount(c.warriors))),
      tostring(wireInt(classWireAverage(c.warriors))),
      tostring(wireInt(classWireCount(c.mages))),
      tostring(wireInt(classWireAverage(c.mages))),
      tostring(wireInt(classWireCount(c.priests))),
      tostring(wireInt(classWireAverage(c.priests))),
      tostring(wireInt(classWireCount(c.warlocks))),
      tostring(wireInt(classWireAverage(c.warlocks))),
      tostring(wireInt(classWireCount(c.paladins))),
      tostring(wireInt(classWireAverage(c.paladins))),
      tostring(wireInt(classWireCount(c.shamans))),
      tostring(wireInt(classWireAverage(c.shamans))),
      tostring(ts),
      tostring(deaths),
      tostring(achAvg),
      tostring(wireInt(row.guildMembersLevel60)),
    },
    Comms.WIRE_FIELD_SEP
  )
end

--- Guild death event payload on the RaceLockedDataBus channel.
--- Carries guild identity so every client can increment the matching stored row.
--- @param guildName string
--- @param raceToken string
--- @return string|nil
function Comms.BuildGuildDeathPayload(guildName, raceToken)
  local gn = Comms.SanitizeGuildName(guildName)
  local rt = tostring(raceToken or '')
  if gn == '' or rt == '' then
    return nil
  end
  return table.concat({ 'd1', gn, rt }, Comms.WIRE_FIELD_SEP)
end

function Comms.ParsePayload(msg)
  if type(msg) ~= 'string' or msg == '' then
    return nil
  end

  local headHex = Comms.PREFIX .. ':'
  if string.sub(msg, 1, #headHex) ~= headHex then
    return nil
  end
  local inner = Comms.HexToBytes(string.sub(msg, #headHex + 1))
  if type(inner) ~= 'string' or inner == '' then
    return nil
  end

  local p = { strsplit(Comms.WIRE_FIELD_SEP, inner) }
  if #p < 14 then
    if p[1] == 'd1' and #p >= 3 then
      local guildName = p[2]
      local raceToken = p[3]
      if guildName ~= '' and raceToken ~= '' then
        return {
          kind = 'guildDeath',
          guildName = guildName,
          raceToken = raceToken,
        }
      end
    end
    return nil
  end

  local wireVersion = p[1]
  local timestamp = 0
  local guildDeaths = 0
  local guildAchievementsAverage = 0
  local guildMembersLevel60 = 0
  if wireVersion == 'v5' and #p >= 27 then
    timestamp = tonumber(p[24]) or 0
    guildDeaths = tonumber(p[25]) or 0
    guildAchievementsAverage = tonumber(p[26]) or 0
    guildMembersLevel60 = tonumber(p[27]) or 0
  elseif wireVersion == 'v4' and #p >= 25 then
    timestamp = tonumber(p[24]) or 0
    guildDeaths = tonumber(p[25]) or 0
    if #p >= 26 then
      guildAchievementsAverage = tonumber(p[26]) or 0
    end
  elseif wireVersion == 'v3' and #p >= 24 then
    timestamp = tonumber(p[24]) or 0
  elseif wireVersion == 'v2' and #p >= 15 then
    timestamp = tonumber(p[15]) or 0
  elseif wireVersion == 'v1' and #p >= 14 then
    timestamp = 0
  else
    return nil
  end

  local raceToken = p[2]
  local guildName = p[3]
  if raceToken == '' or guildName == '' then
    return nil
  end

  return {
    wireVersion = wireVersion,
    raceToken = raceToken,
    guildName = guildName,
    guildSize = tonumber(p[4]) or 0,
    averageLevel = tonumber(p[5]) or 0,
    classes = (wireVersion == 'v3' or wireVersion == 'v4' or wireVersion == 'v5') and {
      druids = {
        count = tonumber(p[6]) or 0,
        averageLevel = tonumber(p[7]) or 0,
      },
      rogues = {
        count = tonumber(p[8]) or 0,
        averageLevel = tonumber(p[9]) or 0,
      },
      hunters = {
        count = tonumber(p[10]) or 0,
        averageLevel = tonumber(p[11]) or 0,
      },
      warriors = {
        count = tonumber(p[12]) or 0,
        averageLevel = tonumber(p[13]) or 0,
      },
      mages = {
        count = tonumber(p[14]) or 0,
        averageLevel = tonumber(p[15]) or 0,
      },
      priests = {
        count = tonumber(p[16]) or 0,
        averageLevel = tonumber(p[17]) or 0,
      },
      warlocks = {
        count = tonumber(p[18]) or 0,
        averageLevel = tonumber(p[19]) or 0,
      },
      paladins = {
        count = tonumber(p[20]) or 0,
        averageLevel = tonumber(p[21]) or 0,
      },
      shamans = {
        count = tonumber(p[22]) or 0,
        averageLevel = tonumber(p[23]) or 0,
      },
    } or {
      druids = {
        count = tonumber(p[6]) or 0,
        averageLevel = 0,
      },
      rogues = {
        count = tonumber(p[7]) or 0,
        averageLevel = 0,
      },
      hunters = {
        count = tonumber(p[8]) or 0,
        averageLevel = 0,
      },
      warriors = {
        count = tonumber(p[9]) or 0,
        averageLevel = 0,
      },
      mages = {
        count = tonumber(p[10]) or 0,
        averageLevel = 0,
      },
      priests = {
        count = tonumber(p[11]) or 0,
        averageLevel = 0,
      },
      warlocks = {
        count = tonumber(p[12]) or 0,
        averageLevel = 0,
      },
      paladins = {
        count = tonumber(p[13]) or 0,
        averageLevel = 0,
      },
      shamans = {
        count = tonumber(p[14]) or 0,
        averageLevel = 0,
      },
    },
    timestamp = timestamp,
    guildDeaths = guildDeaths,
    guildAchievementsAverage = guildAchievementsAverage,
    guildMembersLevel60 = guildMembersLevel60,
  }
end
