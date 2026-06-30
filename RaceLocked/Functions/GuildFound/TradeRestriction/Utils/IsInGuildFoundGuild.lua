local GUILD_FOUND_GUILD_NAME = 'FOR GNOMEREGAN'

function RaceLocked_IsInGuildFoundGuild()
  if not IsInGuild or not IsInGuild() or not GetGuildInfo then
    return false
  end
  local guildName = GetGuildInfo('player')
  if type(guildName) ~= 'string' or guildName == '' then
    return false
  end
  guildName = guildName:match('^%s*(.-)%s*$') or guildName
  return guildName == GUILD_FOUND_GUILD_NAME
end
