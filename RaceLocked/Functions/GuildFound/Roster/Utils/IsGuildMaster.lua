--- Guild master authority check.
--- Uses the same roster-scan pattern as IsPlayerInGuildRoster and
--- ShouldOverrideVerificationViaGuildNote.

local devForceGM = false

function RaceLocked_DevToggleGM()
  devForceGM = not devForceGM
  RaceLocked_PrintRestrictionMessage('GM dev override: ' .. (devForceGM and 'ON' or 'OFF'))
  return devForceGM
end

function RaceLocked_IsGuildMaster(playerName)
  if not playerName or not IsInGuild() then
    return false
  end

  if devForceGM then
    local localName = UnitName and UnitName('player')
    if localName and Ambiguate(playerName, 'short') == localName then
      return true
    end
  end

  RaceLocked_RefreshGuildRoster()

  local targetName = Ambiguate(playerName, 'short')
  local numMembers = GetNumGuildMembers()

  for index = 1, numMembers do
    local name, _, rankIndex = GetGuildRosterInfo(index)
    if name and Ambiguate(name, 'short') == targetName then
      return rankIndex == 1 or rankIndex == 0
    end
  end

  return false
end

function RaceLocked_AmIGuildMaster()
  local playerName = UnitName and UnitName('player')
  if not playerName then
    return false
  end
  return RaceLocked_IsGuildMaster(playerName)
end
