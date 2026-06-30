--- Per-character SavedVariables (RaceLockedDB) accessors.

function RaceLocked_GetDBValue(key)
  if not key or not RaceLockedDB then
    return nil
  end
  return RaceLockedDB[key]
end

function RaceLocked_SaveDBData(key, value)
  if not key then return end
  RaceLockedDB = RaceLockedDB or {}
  RaceLockedDB[key] = value
end
