--- Per-player Guild Found roster storage.
--- Each guild member's verification and clean status is stored in
--- RaceLockedAccountDB keyed by normalized guild name, mirroring the
--- GuildPointsStore pattern.

local function normalizeGuild(name)
  if RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid then
    return RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(name)
  end
  local s = tostring(name or ''):match('^%s*(.-)%s*$') or ''
  if s == '' then
    return ''
  end
  return string.lower(s)
end

local function ensureDB(guildName)
  RaceLockedAccountDB = RaceLockedAccountDB or {}
  RaceLockedAccountDB.guildFoundRoster = RaceLockedAccountDB.guildFoundRoster or {}
  local norm = normalizeGuild(guildName)
  if norm == '' then
    return nil, ''
  end
  RaceLockedAccountDB.guildFoundRoster[norm] =
    RaceLockedAccountDB.guildFoundRoster[norm] or {}
  return RaceLockedAccountDB.guildFoundRoster[norm], norm
end

local function ensureEntry(store, playerName)
  if type(playerName) ~= 'string' or playerName == '' then
    return nil
  end
  store[playerName] = store[playerName] or {}
  return store[playerName]
end

--- Store a player's self-reported verification and clean status.
--- Nil-field contract: passing nil for `verified`, `clean`, or `clientTamperAt`
--- means "do not update this field" (leave whatever was stored), NOT "clear it".
--- To clear a bool field, pass `false` explicitly. This lets TV seeding record a
--- known `verified` value while leaving `clean`/`clientTamperAt` untouched.
--- `clientTamperAt` is the sender's own tamper-incident time (0 = not tampered);
--- it's compared against a GM clean override's timestamp in GetEffectiveStatus
--- so a tamper newer than the override reflags the player network-wide.
--- Note: the wire self-report path (Index.lua) rejects messages missing
--- verified/clean, so over the network both are always concrete booleans and
--- clientTamperAt is always present.
--- @param guildName string
--- @param playerName string
--- @param verified boolean|nil       nil = leave existing value unchanged
--- @param clean boolean|nil          nil = leave existing value unchanged
--- @param clientTamperAt number|nil  nil = leave existing value unchanged
function RaceLocked_Roster_SetSelfReport(guildName, playerName, verified, clean, clientTamperAt)
  local store = ensureDB(guildName)
  if not store then return end
  local entry = ensureEntry(store, playerName)
  if not entry then return end
  if verified ~= nil then
    entry.verified = (verified == true)
  end
  if clean ~= nil then
    entry.clean = (clean == true)
  end
  if clientTamperAt ~= nil then
    entry.clientTamperAt = tonumber(clientTamperAt) or 0
  end
  entry.lastSeen = time()
end

--- Store a GM override for a player.
--- Values of nil mean "clear this override field" (revert to self-report).
--- Only accepts the override if its timestamp is >= the stored one,
--- so stale badges or relays cannot overwrite a newer GM action.
--- @param guildName string
--- @param playerName string
--- @param gmVerified boolean|nil
--- @param gmClean boolean|nil
--- @param gmTimestamp number|nil  unix timestamp from the GM who issued the override
--- @return boolean accepted  true if the override was applied
function RaceLocked_Roster_SetGMOverride(guildName, playerName, gmVerified, gmClean, gmTimestamp)
  local store = ensureDB(guildName)
  if not store then return false end
  local entry = ensureEntry(store, playerName)
  if not entry then return false end

  local incomingTs = tonumber(gmTimestamp) or 0
  local storedTs = tonumber(entry.gmTimestamp) or 0
  if incomingTs < storedTs then
    return false
  end

  entry.gmVerified = gmVerified
  entry.gmClean = gmClean
  entry.gmTimestamp = incomingTs > 0 and incomingTs or nil
  return true
end

--- Get the raw roster entry for a player (or nil).
--- @param guildName string
--- @param playerName string
--- @return table|nil
function RaceLocked_Roster_GetEntry(guildName, playerName)
  local store = ensureDB(guildName)
  if not store or type(playerName) ~= 'string' or playerName == '' then
    return nil
  end
  return store[playerName]
end

--- Get the effective (resolved) status for a player.
--- GM overrides take precedence when non-nil, with one exception for clean: a
--- GM "clean" override (gmClean == true) only clears tamper incidents up to its
--- own timestamp. If the player has since self-reported a NEWER tamper incident
--- (clientTamperAt > gmTimestamp), the override no longer applies and clean
--- resolves to false. This mirrors AmIVerified.IsLocalClean so a GM correction
--- of a false positive can't grant a permanent pass on future tampering.
--- @param guildName string
--- @param playerName string
--- @return boolean|nil effectiveVerified
--- @return boolean|nil effectiveClean
function RaceLocked_Roster_GetEffectiveStatus(guildName, playerName)
  local entry = RaceLocked_Roster_GetEntry(guildName, playerName)
  if not entry then
    return nil, nil
  end

  local v = entry.gmVerified
  if v == nil then v = entry.verified end

  local c
  if entry.gmClean == nil then
    c = entry.clean
  elseif entry.gmClean == false then
    c = false
  else
    -- gmClean == true: cleared only up to the override's timestamp
    local tamperAt = tonumber(entry.clientTamperAt) or 0
    local overrideAt = tonumber(entry.gmTimestamp) or 0
    if tamperAt > 0 and tamperAt > overrideAt then
      c = false
    else
      c = true
    end
  end

  return v, c
end

--- Return the full roster store for a guild (for iteration / relay).
--- @param guildName string
--- @return table|nil
function RaceLocked_Roster_GetAllEntries(guildName)
  return ensureDB(guildName)
end

--- Count the number of stored entries for a guild.
--- @param guildName string
--- @return number
function RaceLocked_Roster_GetEntryCount(guildName)
  local store = ensureDB(guildName)
  if not store then return 0 end
  local count = 0
  for _ in pairs(store) do
    count = count + 1
  end
  return count
end

--- Prune stored entries for players no longer in the guild.
--- Callers pass a set of the CURRENT guild member names (short form) as keys;
--- any stored entry whose key is absent from that set is removed.
--- No-op when `currentMembers` is empty (basic protection against a completely
--- unloaded roster). Callers should apply their own higher-level guards (e.g.
--- self-name presence, count ratio) before invoking this. Even past all guards
--- the prune is self-correcting • a wrongly removed member reappears on their
--- next self-report.
--- @param guildName string
--- @param currentMembers table<string, boolean>  short names currently in the guild
--- @return number removed  count of entries pruned
function RaceLocked_Roster_CleanupForRoster(guildName, currentMembers)
  local store = ensureDB(guildName)
  if not store or type(currentMembers) ~= 'table' then
    return 0
  end
  if next(currentMembers) == nil then
    return 0
  end

  local removed = 0
  for playerName in pairs(store) do
    if not currentMembers[playerName] then
      store[playerName] = nil
      removed = removed + 1
    end
  end
  return removed
end

--- Read the local player's own GM override from the roster.
--- Used by AmIVerified() to check for a GM override on self. The timestamp is
--- the tamper-epoch boundary: a GM "clean" override only clears tamper
--- incidents at or before this time (see AmIVerified.IsLocalClean).
--- @return table { verified = bool|nil, clean = bool|nil, timestamp = number|nil }
function RaceLocked_Roster_GetGMOverrideForSelf()
  local guildName = GetGuildInfo and GetGuildInfo('player')
  local playerName = UnitName and UnitName('player')
  if not guildName or not playerName then
    return {}
  end
  local entry = RaceLocked_Roster_GetEntry(guildName, playerName)
  if not entry then
    return {}
  end
  return { verified = entry.gmVerified, clean = entry.gmClean, timestamp = entry.gmTimestamp }
end
