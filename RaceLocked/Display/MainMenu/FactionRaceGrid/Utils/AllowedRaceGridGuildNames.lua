-- Whitelist of guild names that may contribute addon-merged race grid data (built from stored guild slots).
-- Incoming reports for any other guild name are ignored. Your own guild is never taken from messages;
-- see GetPlayerGuildRaceGridReport.lua for live roster aggregation.

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion

--- @param name string|nil
--- @return string lowercased trimmed, or '' if invalid
function RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(name)
  if type(name) ~= 'string' then
    return ''
  end
  local s = name:match('^%s*(.-)%s*$') or ''
  if s == '' then
    return ''
  end
  return string.lower(s)
end

local built = false

function RaceLocked_GuildChampion_EnsureRaceGridAllowedGuildNamesBuilt()
  if built then return end
  built = true
  local lookup = {}
  local displayByNorm = {}
  for _, rows in pairs(G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE or {}) do
    if type(rows) == 'table' then
      for _, row in ipairs(rows) do
        local raw = row.guildName
        if type(raw) == 'string' and raw ~= '' then
          local norm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(raw)
          if norm ~= '' and not lookup[norm] then
            lookup[norm] = true
            displayByNorm[norm] = raw:match('^%s*(.-)%s*$') or raw
          end
        end
      end
    end
  end
  local sorted = {}
  for norm, _ in pairs(lookup) do
    sorted[#sorted + 1] = displayByNorm[norm] or norm
  end
  table.sort(sorted, function(a, b)
    return string.lower(a) < string.lower(b)
  end)
  G._raceGridAllowedGuildLookup = lookup
  G._raceGridTrustedGuildNamesSorted = sorted
end

--- Guild name is on the trusted list (same names as the stored guild slots).
--- @param name string|nil
--- @return boolean
function RaceLocked_GuildChampion_IsGuildNameAllowedForRaceGrid(name)
  RaceLocked_GuildChampion_EnsureRaceGridAllowedGuildNamesBuilt()
  local norm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(name)
  if norm == '' then
    return false
  end
  return G._raceGridAllowedGuildLookup[norm] == true
end

--- @return string[] sorted display names
function RaceLocked_GuildChampion_GetRaceGridTrustedGuildNamesSorted()
  RaceLocked_GuildChampion_EnsureRaceGridAllowedGuildNamesBuilt()
  return G._raceGridTrustedGuildNamesSorted
end

--- Current player's guild name (normalized), or '' if not in a guild.
--- @return string
function RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
  if not GetGuildInfo then
    return ''
  end
  local guildName = GetGuildInfo('player')
  if type(guildName) ~= 'string' or guildName == '' then
    return ''
  end
  return RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(guildName)
end

--- True if this row's guild name is the guild the player is in (compare normalized).
--- @param name string|nil
--- @return boolean
function RaceLocked_GuildChampion_IsCurrentPlayerGuildName(name)
  local pg = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName()
  if pg == '' then
    return false
  end
  return RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(name) == pg
end

--- Drop entries whose guild is not whitelisted, and drop the player's guild (never trust messages for it).
--- @param entries table[]|nil each { guildName, guildSize?, averageLevel?, classes? }
--- @return table[]
function RaceLocked_GuildChampion_FilterGuildReportsToAllowedSources(entries)
  RaceLocked_GuildChampion_EnsureRaceGridAllowedGuildNamesBuilt()
  local out = {}
  if not entries then
    return out
  end
  for _, e in ipairs(entries) do
    if type(e) == 'table' and e.guildName and e.guildName ~= '' then
      if RaceLocked_GuildChampion_IsGuildNameAllowedForRaceGrid(e.guildName) then
        if not RaceLocked_GuildChampion_IsCurrentPlayerGuildName(e.guildName) then
          out[#out + 1] = e
        end
      end
    end
  end
  return out
end
