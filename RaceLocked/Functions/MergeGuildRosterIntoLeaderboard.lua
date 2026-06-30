-- Apply cached guild roster rows to the leaderboard.
-- When `pruneMissing` is true, remove saved peers not found in the current guild roster.

function RaceLocked_MergeGuildRosterIntoLeaderboard(pruneMissing)
  if not IsInGuild() or type(RaceLocked_ApplyGuildRosterRowToLeaderboard) ~= 'function' then
    return false
  end
  local total = select(1, GetNumGuildMembers(true))
  if not total or total < 1 then
    total = select(1, GetNumGuildMembers())
  end
  total = tonumber(total) or 0
  if total < 1 then
    return false
  end

  local changed = false
  local seenPlayerIds = {}
  for i = 1, total do
    local name, _, _, level, _, _, _, _, _, _, _, achievementPoints, _, _, _, _, guid = GetGuildRosterInfo(i)
    if guid and guid ~= '' and name and name ~= '' then
      seenPlayerIds[guid] = true
      local rowChanged = RaceLocked_ApplyGuildRosterRowToLeaderboard({
        name = name,
        playerId = guid,
        level = level,
        achievementPoints = achievementPoints,
      })
      changed = changed or rowChanged
    end
  end

  if pruneMissing then
    RaceLockedDB = RaceLockedDB or {}
    RaceLockedDB.guildPeers = RaceLockedDB.guildPeers or {}
    for playerId in pairs(RaceLockedDB.guildPeers) do
      if not seenPlayerIds[playerId] then
        RaceLockedDB.guildPeers[playerId] = nil
        changed = true
      end
    end
  end

  return changed
end
