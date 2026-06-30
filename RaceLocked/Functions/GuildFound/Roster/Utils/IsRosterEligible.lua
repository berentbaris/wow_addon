--- Guild Found roster eligibility helper.
--- A player is eligible if their effective verified and clean status both resolve to true,
--- matching the "Eligible" column in the roster UI.

function RaceLocked_Roster_IsPlayerEligible(guildName, playerName)
  if not guildName or not playerName then return false end
  local ev, ec = RaceLocked_Roster_GetEffectiveStatus(guildName, playerName)
  return ev == true and ec == true
end
