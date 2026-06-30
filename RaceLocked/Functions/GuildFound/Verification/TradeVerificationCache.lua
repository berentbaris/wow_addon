local CACHE_TTL_SECONDS = 5

RaceLocked_partnerVerificationCache = RaceLocked_partnerVerificationCache or {}

function RaceLocked_PlayerNamesMatch(nameA, nameB)
  if not nameA or not nameB then
    return false
  end

  return Ambiguate(nameA, 'short') == Ambiguate(nameB, 'short')
end

function RaceLocked_CachePartnerVerification(playerName, isVerified)
  if not playerName then return end

  RaceLocked_partnerVerificationCache[playerName] = {
    verified = isVerified,
    at = time(),
  }
end

function RaceLocked_GetCachedPartnerVerification(playerName)
  for cachedName, entry in pairs(RaceLocked_partnerVerificationCache) do
    if RaceLocked_PlayerNamesMatch(cachedName, playerName) then
      if (time() - entry.at) > CACHE_TTL_SECONDS then
        RaceLocked_partnerVerificationCache[cachedName] = nil
        return nil
      end

      return entry.verified
    end
  end

  return nil
end
