--- Build a sorted row list for the Guild Found roster UI.
--- Uses only the persisted roster store • no live guild roster scan.

--- @return table[] rows, boolean isGM
function RaceLocked_GetGuildFoundRosterRows()
  local rows = {}
  local guildName = RaceLocked_Roster_GetPlayerGuildName()
  if not guildName then
    return rows, false
  end

  local isGM = RaceLocked_AmIGuildMaster()
  local myName = RaceLocked_Roster_GetPlayerName()

  local store = RaceLocked_Roster_GetAllEntries(guildName)
  if not store then
    return rows, isGM
  end

  for name, entry in pairs(store) do
    local ev, ec = RaceLocked_Roster_GetEffectiveStatus(guildName, name)

    -- A GM "clean" override only clears tamper incidents up to its own
    -- timestamp. If the player has since self-reported a NEWER tamper, the
    -- override is superseded (see RosterStore.GetEffectiveStatus). Present it
    -- as absent for display/editing so the row reads as a plain self-reported
    -- tampered player, and the GM's edit buffer starts without the dead
    -- override • letting a fresh "Not tampered" selection commit a new,
    -- winning timestamp. The stored override is left intact (it stays robust
    -- against peer relays); only the displayed value is adjusted.
    local gmClean = entry.gmClean
    if gmClean == true then
      local tamperAt = tonumber(entry.clientTamperAt) or 0
      local overrideAt = tonumber(entry.gmTimestamp) or 0
      if tamperAt > 0 and tamperAt > overrideAt then
        gmClean = nil
      end
    end

    local hasGMOverride = (entry.gmVerified ~= nil or gmClean ~= nil)
    local isLocal = myName and name == myName

    rows[#rows + 1] = {
      name = name,
      selfVerified = entry.verified,
      selfClean = entry.clean,
      effectiveVerified = ev,
      effectiveClean = ec,
      hasGMOverride = hasGMOverride,
      gmVerified = entry.gmVerified,
      gmClean = gmClean,
      isLocalPlayer = isLocal,
      lastSeen = entry.lastSeen,
    }
  end

  table.sort(rows, function(a, b)
    local aElig = RaceLocked_Roster_IsPlayerEligible(guildName, a.name) and 1 or 0
    local bElig = RaceLocked_Roster_IsPlayerEligible(guildName, b.name) and 1 or 0
    if aElig ~= bElig then
      return aElig > bElig
    end
    return (a.name or '') < (b.name or '')
  end)

  return rows, isGM
end
