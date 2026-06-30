--- Local-player verification predicates.
---
--- The atomic predicates below are the single source of truth for each raw
--- condition. Both the enforcement helpers (IsLocalVerified / IsLocalClean)
--- and the Guild Verification display read them, so the displayed per-row
--- state can never drift from what actually gates trading and mail.

--- Atomic: did this character reach max level while self found?
--- This is the raw self-found achievement, independent of any GM/rank override.
function RaceLocked_IsLocalMaxLevelSelfFound()
  return RaceLocked_GetDBValue('hasBeenMaxLevelAndSelfFound') == true
end

--- Atomic: has offline gold tampering been detected for this character?
--- This is the raw tamper flag, independent of any GM override.
function RaceLocked_IsLocalTampered()
  return RaceLocked_GetDBValue('playerMoneyValidationFailed') == true
end

--- Atomic: unix time of the most recent detected tamper incident, or 0 if the
--- character is not currently flagged. Used as the "tamper epoch" so a GM
--- override (which carries its own timestamp) only clears incidents up to its
--- own time • a newer incident beats it. Also broadcast in the self-report so
--- peers can apply the same comparison (see RosterStore.GetEffectiveStatus).
function RaceLocked_GetLocalTamperAt()
  if RaceLocked_GetDBValue('playerMoneyValidationFailed') ~= true then return 0 end
  return tonumber(RaceLocked_GetDBValue('playerMoneyValidationFailedAt')) or 0
end

--- Raw self-report fields for guild `S:` broadcasts and roster `entry.verified` /
--- `entry.clean`. Excludes roster GM overrides and guild-note override; those
--- travel separately (`gm*` on `S:` / `G:`) or apply only in IsLocalVerified.
function RaceLocked_GetLocalSelfReportVerified()
  return RaceLocked_IsLocalMaxLevelSelfFound()
end

function RaceLocked_GetLocalSelfReportClean()
  return not RaceLocked_IsLocalTampered()
end

--- Whether the local player has passed the verified requirement (60+ SF or override).
function RaceLocked_IsLocalVerified()
  local verified = RaceLocked_IsLocalMaxLevelSelfFound()
    or RaceLocked_ShouldOverrideVerificationViaGuildNote(UnitName('player')) == true

  if RaceLocked_Roster_GetGMOverrideForSelf then
    local gmOverride = RaceLocked_Roster_GetGMOverrideForSelf()
    if gmOverride.verified ~= nil then
      verified = gmOverride.verified == true
    end
  end

  return verified
end

--- Whether the local player has a clean (not tampered) status.
--- A GM "clean" override only clears tamper incidents up to the override's own
--- timestamp. A tamper detected AFTER the override (newer epoch) reflags the
--- player, so an override can't grant a permanent pass on future tampering.
function RaceLocked_IsLocalClean()
  local clean = not RaceLocked_IsLocalTampered()

  if RaceLocked_Roster_GetGMOverrideForSelf then
    local gmOverride = RaceLocked_Roster_GetGMOverrideForSelf()
    if gmOverride.clean == false then
      clean = false
    elseif gmOverride.clean == true then
      local tamperAt = RaceLocked_GetLocalTamperAt()
      local overrideAt = tonumber(gmOverride.timestamp) or 0
      if tamperAt > 0 and tamperAt > overrideAt then
        clean = false  -- tampered after the override was issued
      else
        clean = true
      end
    end
  end

  return clean
end

function RaceLocked_AmIVerified()
  return RaceLocked_IsLocalVerified() and RaceLocked_IsLocalClean()
end
