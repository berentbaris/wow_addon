function RaceLocked_IsPlayerInGuildRoster(playerName)
  RaceLocked_RefreshGuildRoster()

  if not playerName or not IsInGuild() then
    return false
  end

  local targetName = Ambiguate(playerName, 'short')
  local numMembers = GetNumGuildMembers()

  for index = 1, numMembers do
    local name = GetGuildRosterInfo(index)
    if name and Ambiguate(name, 'short') == targetName then
      return true
    end
  end

  return false
end
