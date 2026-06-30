--- Tamper detection for the "clean" half of Guild Found verification.
---
--- Model: while playing we persist the player's current gold on every
--- PLAYER_MONEY event. On the next login we compare the saved gold to the
--- live amount: if they differ, the SavedVariables file was edited offline
--- (the only way gold can change while logged out), so we set the persistent
--- flag `playerMoneyValidationFailed = true` and stamp the incident time in
--- `playerMoneyValidationFailedAt`. We only check on login because that is the
--- boundary where offline tampering can be detected.
---
--- Per-incident (not one-shot): every login that finds a discrepancy records a
--- FRESH `playerMoneyValidationFailedAt`. This is what lets a GM override clear
--- a known false positive while still allowing a *later* tamper to reflag: the
--- override clears incidents up to its own timestamp, and a newer incident
--- timestamp beats it. See the epoch comparison in AmIVerified.IsLocalClean and
--- RosterStore.GetEffectiveStatus. After each check we reset the saved baseline
--- to the live amount so a single offline edit is only counted once.
---
--- Self-found exemption: a character still flagged self-found by the game
--- cannot meaningfully tamper for advantage, so any prior failure flag while
--- self-found is treated as a false positive and cleared.
---
--- The flag/timestamp are consumed by RaceLocked_IsLocalClean() (AmIVerified.lua)
--- and shown as the "Tampering" row in the Guild Verification display.
local playerMoneyFrame = CreateFrame('Frame')
local moneyValidatedThisSession = false

local function OnMoneyChanged()
  local current = GetMoney() or 0
  RaceLocked_SaveDBData('playerMoney', current)
end

local function ValidatePlayerMoneyOnLogin()
  if RaceLocked_PlayerHasSelfFoundBuff and RaceLocked_PlayerHasSelfFoundBuff() then
    if RaceLocked_GetDBValue('playerMoneyValidationFailed') then
      RaceLocked_SaveDBData('playerMoneyValidationFailed', false)
      RaceLocked_SaveDBData('playerMoneyValidationFailedAt', nil)
    end
    return
  end

  local playerMoney = RaceLocked_GetDBValue('playerMoney')
  local current = GetMoney()
  if playerMoney ~= nil and playerMoney ~= current then
    -- Record a fresh incident every time (no one-shot guard), so a tamper
    -- that happens after a GM override gets a newer timestamp and can reflag.
    RaceLocked_SaveDBData('playerMoneyValidationFailed', true)
    RaceLocked_SaveDBData('playerMoneyValidationFailedAt', time())
  end

  -- Reset the baseline to the live amount so the same offline edit isn't
  -- re-detected on the next login.
  RaceLocked_SaveDBData('playerMoney', current)
end

--- Session gate used by roster self-report:
--- false until PLAYER_LOGIN money validation has run at least once.
function RaceLocked_HasValidatedLocalMoneyThisSession()
  return moneyValidatedThisSession == true
end

playerMoneyFrame:RegisterEvent('PLAYER_MONEY')
playerMoneyFrame:RegisterEvent('PLAYER_LOGIN')

playerMoneyFrame:SetScript('OnEvent', function(_, event, arg1)
  if event == 'PLAYER_MONEY' then
    OnMoneyChanged()
  elseif event == 'PLAYER_LOGIN' then
    ValidatePlayerMoneyOnLogin()
    moneyValidatedThisSession = true
  end
end)
