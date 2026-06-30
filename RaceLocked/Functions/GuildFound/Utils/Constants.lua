--- Shared Guild Found constants (verification level gate, etc.).

--- Minimum character level for roster self-report (`S:`) and for marking
--- `hasBeenMaxLevelAndSelfFound` while self-found.
RACE_LOCKED_GUILD_FOUND_MAX_LEVEL = 60

--- @return boolean
function RaceLocked_GuildFound_IsAtOrAboveRequiredLevel()
  if not UnitLevel then return false end
  return UnitLevel('player') >= RACE_LOCKED_GUILD_FOUND_MAX_LEVEL
end
