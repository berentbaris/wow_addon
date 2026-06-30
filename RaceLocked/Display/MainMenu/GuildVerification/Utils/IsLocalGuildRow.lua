--- @param row table|nil roster row with name, playerId
--- @return boolean
function RaceLocked_GuildVerification_IsLocalGuildRow(row)
  if not row then
    return false
  end
  local myGuid = UnitGUID and UnitGUID('player')
  if myGuid and row.playerId and row.playerId == myGuid then
    return true
  end
  local un = UnitName and UnitName('player')
  if un and row.name then
    local nm = RaceLocked_GuildVerification_StripRealmFromName(row.name)
    if string.lower(nm) == string.lower(un) then
      return true
    end
  end
  return false
end
