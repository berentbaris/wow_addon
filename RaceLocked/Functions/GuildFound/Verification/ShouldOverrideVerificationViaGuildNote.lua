function RaceLocked_ShouldOverrideVerificationViaGuildNote(playerName)
  if not playerName or not IsInGuild() then
    return nil
  end

  RaceLocked_RefreshGuildRoster()

  local targetName = Ambiguate(playerName, 'short')
  local numMembers = GetNumGuildMembers()

  for index = 1, numMembers do
    local name, rank = GetGuildRosterInfo(index)
    if name and Ambiguate(name, 'short') == targetName then
      return rank == 'Chief Engineer'
    end
  end

  return nil
end
