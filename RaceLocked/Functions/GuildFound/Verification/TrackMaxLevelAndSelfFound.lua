local trackerFrame = CreateFrame('Frame')

local function ensureHasBeenMaxLevelDefault()
  if RaceLocked_GetDBValue('hasBeenMaxLevelAndSelfFound') == nil then
    RaceLocked_SaveDBData('hasBeenMaxLevelAndSelfFound', false)
  end
end

local function tryMarkHasBeenMaxLevelAndSelfFound()
  if RaceLocked_GetDBValue('hasBeenMaxLevelAndSelfFound') then return end
  local level = UnitLevel('player')
  if level and level >= RACE_LOCKED_GUILD_FOUND_MAX_LEVEL and RaceLocked_PlayerHasSelfFoundBuff() then
    RaceLocked_SaveDBData('hasBeenMaxLevelAndSelfFound', true)
  end
end

trackerFrame:RegisterEvent('ADDON_LOADED')
trackerFrame:RegisterEvent('PLAYER_LOGIN')
trackerFrame:RegisterEvent('PLAYER_LEVEL_UP')
trackerFrame:RegisterEvent('UNIT_AURA')

trackerFrame:SetScript('OnEvent', function(_, event, arg1)
  if event == 'ADDON_LOADED' then
    if arg1 ~= addonName then return end
    ensureHasBeenMaxLevelDefault()
    tryMarkHasBeenMaxLevelAndSelfFound()
  elseif event == 'PLAYER_LOGIN' or event == 'PLAYER_LEVEL_UP' then
    tryMarkHasBeenMaxLevelAndSelfFound()
  elseif event == 'UNIT_AURA' and arg1 == 'player' then
    tryMarkHasBeenMaxLevelAndSelfFound()
  end
end)
