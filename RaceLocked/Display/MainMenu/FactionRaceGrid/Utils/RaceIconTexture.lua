--- @param token string
--- @return string
function RaceLocked_GuildChampion_RaceIconTexture(token)
  local G = RaceLocked_GuildChampion
  return G.RACE_ICON_TEXTURE[token] or G.RACE_ICON_TEXTURE.Human
end
