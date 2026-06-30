-- Trust model: when a roster entry already exists we resolve instantly from it;
-- otherwise we fall through to a live Trade Verification (TV) whisper handshake.
-- TV is inherently trust-based • like any client-side addon, a modified client
-- can reply TV:1 (verified) when it is not, which would both allow the trade and
-- seed a verified=true roster entry. This cannot be prevented purely client-side.
-- The guild-wide roster sync (S: self-report broadcasts) is the corrective layer:
-- a lying entry will be overwritten by the real owner's authenticated self-report
-- (see C3 sender binding in Roster/Index.lua), so any false-allow is a transient
-- window, not a permanent bypass.
function RaceLocked_CanPerformTradeWithPlayer(playerName, onComplete)
  if not playerName or not onComplete then return end

  if not RaceLocked_IsTradePartnerInMyGuild() then
    onComplete(false, 'Trade with ' .. playerName .. ' blocked - not in my Guild.')
    return
  end

  local shortName = Ambiguate and Ambiguate(playerName, 'short') or playerName
  local guildName = GetGuildInfo and GetGuildInfo('player')
  if guildName and shortName and RaceLocked_Roster_GetEntry then
    local entry = RaceLocked_Roster_GetEntry(guildName, shortName)
    if entry then
      if RaceLocked_Roster_IsPlayerEligible
        and RaceLocked_Roster_IsPlayerEligible(guildName, shortName) then
        RaceLocked_PrintRestrictionMessage(shortName .. ' is roster eligible.')
        onComplete(true, nil)
        return
      end

      onComplete(false, 'Trade with ' .. playerName .. ' blocked - partner not eligible.')
      return
    end
  end

  RaceLocked_PrintRestrictionMessage(
    playerName .. ' is in my Guild.' .. ' Starting verification...'
  )

  RaceLocked_BeginTradeVerification(playerName, onComplete)
end
