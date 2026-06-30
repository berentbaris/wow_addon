--- @param innerW number
--- @return table edge, nameW, raceW, gapNr
function RaceLocked_GuildVerification_ComputeGuildTableColumns(innerW)
  local V = RaceLocked_GuildVerification
  innerW = math.max(innerW or 0, 120)
  local sbReserve = V.SCROLL_BAR_WIDTH + 6
  local usableText = innerW - V.COL_EDGE * 2 - sbReserve
  if usableText < 48 then
    usableText = 48
  end
  local nameW = math.floor(usableText * 0.55)
  local raceW = usableText - nameW - V.COL_GAP_NAME_RACE
  if raceW < 28 then
    raceW = 28
    nameW = math.max(usableText - raceW - V.COL_GAP_NAME_RACE, 36)
  end
  return {
    edge = V.COL_EDGE,
    nameW = nameW,
    raceW = raceW,
    gapNr = V.COL_GAP_NAME_RACE,
  }
end
