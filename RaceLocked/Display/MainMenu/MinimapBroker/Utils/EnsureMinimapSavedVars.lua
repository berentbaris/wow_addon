function RaceLocked_Settings_EnsureMinimapSavedVars()
  if not RaceLockedDB then
    RaceLockedDB = {}
  end
  if not RaceLockedDB.minimapButton then
    RaceLockedDB.minimapButton = { hide = false }
  end
end

RaceLocked_Settings_EnsureMinimapSavedVars()
