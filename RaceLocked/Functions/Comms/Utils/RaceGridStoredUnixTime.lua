RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}

--- Unix seconds for race-grid guild report storage and wire payloads.
--- Prefers the realm clock (GetServerTime) so all clients on the realm agree on "now"
--- even when the player's OS clock is wrong. If the API is missing or returns a
--- non-positive value, falls back to the client's Unix epoch (same scale as UTC).
--- @return number
function RaceLocked_GuildChampion_GetRaceGridStoredUnixTime()
  if type(GetServerTime) == 'function' then
    local t = GetServerTime()
    if type(t) == 'number' and t > 0 then
      return math.floor(t)
    end
  end
  if type(time) == 'function' then
    local u = time()
    if type(u) == 'number' and u > 0 then
      return math.floor(u)
    end
  end
  return 0
end
