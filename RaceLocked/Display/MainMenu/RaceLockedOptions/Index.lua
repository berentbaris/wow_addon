-- Addon options: defaults and persistence (RaceLockedDB.options). Amend defaults here.

RaceLocked_OptionsDefaults = {
  nativeLanguageOnly = true,
  forceRaceOnlyGrouping = true,
}

local function ensureOptionsTable()
  RaceLockedDB = RaceLockedDB or {}
  if type(RaceLockedDB.options) ~= 'table' then
    RaceLockedDB.options = {}
  end
  for key, defaultValue in pairs(RaceLocked_OptionsDefaults) do
    if RaceLockedDB.options[key] == nil then
      RaceLockedDB.options[key] = defaultValue
    end
  end
end

function RaceLocked_Options_EnsureLoaded()
  ensureOptionsTable()
end

function RaceLocked_Options_GetNativeLanguageOnly()
  ensureOptionsTable()
  return RaceLockedDB.options.nativeLanguageOnly ~= false
end

function RaceLocked_Options_SetNativeLanguageOnly(enabled)
  ensureOptionsTable()
  RaceLockedDB.options.nativeLanguageOnly = enabled and true or false
end

function RaceLocked_Options_GetForceRaceOnlyGrouping()
  ensureOptionsTable()
  return RaceLockedDB.options.forceRaceOnlyGrouping ~= false
end

function RaceLocked_Options_SetForceRaceOnlyGrouping(enabled)
  ensureOptionsTable()
  RaceLockedDB.options.forceRaceOnlyGrouping = enabled and true or false
end

RaceLocked_Options_EnsureLoaded()
