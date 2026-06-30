--- Local player / guild identity helpers for the Guild Found roster.
--- Both the message service (Index.lua) and the UI row builder
--- (RosterRowData.lua) need the same notion of "my guild" and "my name",
--- so the guarded lookups live here instead of being copied per file.

--- @return string|nil guildName  nil when not in a guild or the API is unavailable
function RaceLocked_Roster_GetPlayerGuildName()
  if not IsInGuild or not IsInGuild() or not GetGuildInfo then
    return nil
  end
  local guildName = GetGuildInfo('player')
  if type(guildName) ~= 'string' or guildName == '' then
    return nil
  end
  return guildName
end

--- @return string|nil playerName  nil when the API is unavailable
function RaceLocked_Roster_GetPlayerName()
  if not UnitName then return nil end
  local name = UnitName('player')
  if type(name) ~= 'string' or name == '' then return nil end
  return name
end
