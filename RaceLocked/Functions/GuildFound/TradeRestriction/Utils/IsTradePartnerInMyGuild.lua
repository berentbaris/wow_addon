function RaceLocked_IsTradePartnerInMyGuild()
  local myGuild = GetGuildInfo('player')
  local theirGuild = GetGuildInfo('npc')

  return myGuild and theirGuild and myGuild == theirGuild
end
