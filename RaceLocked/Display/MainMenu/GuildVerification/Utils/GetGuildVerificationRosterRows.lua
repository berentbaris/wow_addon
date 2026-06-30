local function raceInfoForGuid(guid)
  if not guid or guid == '' or not GetPlayerInfoByGUID then
    return nil, nil
  end
  local _, _, localizedRace, englishRace = GetPlayerInfoByGUID(guid)
  if localizedRace == '' then
    localizedRace = nil
  end
  if englishRace == '' then
    englishRace = nil
  end
  return localizedRace, englishRace
end

--- Guild roster for Guild Verification tab: members whose race differs from yours.
--- Rows: { name, playerId, level, race }.
--- Second return is true when you are in a guild, the roster had at least one member, and every member was filtered out as your race.
function RaceLocked_GetGuildVerificationRosterRows()
  local rows = {}
  if not IsInGuild() then
    return rows, false
  end
  local _, playerRaceEn = UnitRace('player')
  if playerRaceEn == '' then
    playerRaceEn = nil
  end
  local total = select(1, GetNumGuildMembers(true))
  if not total or total < 1 then
    total = select(1, GetNumGuildMembers())
  end
  total = tonumber(total) or 0
  local memberCount = 0
  for i = 1, total do
    local name, _, _, level, _, _, _, _, _, _, _, _, _, _, _, _, guid = GetGuildRosterInfo(i)
    if guid and guid ~= '' and name and name ~= '' then
      memberCount = memberCount + 1
      local locRace, engRace = raceInfoForGuid(guid)
      if engRace and playerRaceEn and engRace == playerRaceEn then
        -- Same race as the player; omit from this list.
      else
        rows[#rows + 1] = {
          name = name,
          playerId = guid,
          level = tonumber(level) or 1,
          race = locRace,
        }
      end
    end
  end
  table.sort(rows, function(a, b)
    return tostring(a.name or '') < tostring(b.name or '')
  end)
  local allSameRaceAsPlayer = memberCount > 0 and #rows == 0
  return rows, allSameRaceAsPlayer
end
