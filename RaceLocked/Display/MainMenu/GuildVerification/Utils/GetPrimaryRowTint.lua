--- @return table r, g, b, a
function RaceLocked_GuildVerification_GetPrimaryRowTint()
  if RaceLocked_GetLeaderboardRowTint then
    return RaceLocked_GetLeaderboardRowTint()
  end
  return {
    r = 0.13,
    g = 0.19,
    b = 0.40,
    a = 0.30,
  }
end
