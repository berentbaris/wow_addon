--- Guild Found Roster • message handling, self-broadcast, and event wiring.
--- Members broadcast their own status (S:), the guild master broadcasts
--- overrides (G:), and peers relay overrides they already hold (O:) so a
--- member who logs in late still learns about an override that predates them.

local ADDON_PREFIX = 'RLGFRoster'

--- Append to the in-panel session log (the user-facing record of traffic).
--- `raw` is the original wire message, shown on hover when enabled.
local function sessionLog(kind, text, raw)
  RaceLocked_Roster_AppendSessionLog(kind, text, raw)
end

-- ── Helpers ──────────────────────────────────────────────────────────────

local function isSenderLocalPlayer(sender)
  if type(sender) ~= 'string' or sender == '' then return false end
  local short = Ambiguate(sender, 'short')
  if UnitName then
    return short == UnitName('player')
  end
  return false
end

local function getAddonSend()
  if not IsInGuild or not IsInGuild() then return nil end
  return SendAddonMessage or (C_ChatInfo and C_ChatInfo.SendAddonMessage)
end

local function registerPrefix()
  if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
  elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(ADDON_PREFIX)
  end
end

-- ── Wire encoding helpers ────────────────────────────────────────────────

local function boolToWire(val)
  if val == true then return '1' end
  if val == false then return '0' end
  return '-'
end

local function wireToBool(s)
  if s == '1' then return true end
  if s == '0' then return false end
  return nil
end

-- ── Human-readable descriptions for the session log ──────────────────────
-- These turn the raw wire values into plain language. The raw message is
-- still kept alongside each log line (shown on hover) for debugging.

--- Status wording mirrors the roster UI columns (Verified, Tampered):
--- e.g. "Verified, Not Tampered" / "Not Verified, Tampered".
local function describeStatus(verified, clean)
  local v = (verified == true) and 'Verified'
    or (verified == false) and 'Not Verified' or '?'
  local c = (clean == true) and 'Not Tampered'
    or (clean == false) and 'Tampered' or '?'
  return v .. ', ' .. c
end

--- Optional " [GM: …]" suffix that lists only the override fields that are
--- actually set, so unremarkable rows stay short.
local function describeOverrideSuffix(gmVerified, gmClean)
  local parts = {}
  if gmVerified ~= nil then
    parts[#parts + 1] = gmVerified and 'Verified' or 'Not Verified'
  end
  if gmClean ~= nil then
    parts[#parts + 1] = gmClean and 'Not Tampered' or 'Tampered'
  end
  if #parts == 0 then return '' end
  return ' [GM: ' .. table.concat(parts, ', ') .. ']'
end

--- A GM override can also clear a field (nil), reverting it to the player's
--- self-report, so spell out all three states.
local function describeGMDecision(gmVerified, gmClean)
  local v = (gmVerified == true) and 'Verified'
    or (gmVerified == false) and 'Not Verified' or 'Verified Reset'
  local c = (gmClean == true) and 'Not Tampered'
    or (gmClean == false) and 'Tampered' or 'Tampered Reset'
  return v .. ', ' .. c
end

local function staleSuffix(accepted)
  return accepted and '' or ' (stale, ignored)'
end

-- ── Deferred roster cleanup ───────────────────────────────────────────────

-- Set to the guild name by the manual sync command; consumed on the next
-- GUILD_ROSTER_UPDATE (after the async GuildRoster() call has delivered its
-- refreshed, offline-inclusive result).
local pendingCleanupGuild = nil

-- ── Outgoing messages ────────────────────────────────────────────────────

-- Coalesce accidental bursts: never put two self-reports on the guild channel
-- within this many seconds (the manual Sync button and login share this path).
local SELF_REPORT_THROTTLE = 2
local lastSelfReportAt = 0

-- Session announce runs once per game session; set when we broadcast S: or when
-- we permanently skip broadcast (e.g. below level 60).
local hasAnnouncedThisSession = false

local function broadcastSelfReport()
  if RaceLocked_HasValidatedLocalMoneyThisSession
    and not RaceLocked_HasValidatedLocalMoneyThisSession() then
    sessionLog('info', 'Skipping self-report • waiting for money validation.')
    return false
  end

  if RaceLocked_GuildFound_IsAtOrAboveRequiredLevel
    and not RaceLocked_GuildFound_IsAtOrAboveRequiredLevel() then
    local lvl = UnitLevel and UnitLevel('player') or 0
    sessionLog('info', 'Skipping self-report (level ' .. lvl .. ' < '
      .. tostring(RACE_LOCKED_GUILD_FOUND_MAX_LEVEL) .. ')')
    hasAnnouncedThisSession = true
    return false
  end
  local now = (GetTime and GetTime()) or 0
  if now > 0 and (now - lastSelfReportAt) < SELF_REPORT_THROTTLE then return false end
  local send = getAddonSend()
  if not send then return false end
  local playerName = RaceLocked_Roster_GetPlayerName()
  local guildName = RaceLocked_Roster_GetPlayerGuildName()
  if not playerName or not guildName then return false end

  lastSelfReportAt = now

  -- Self fields must reflect atomic player state only; GM overrides ride in fields 5-7.
  local verified = RaceLocked_GetLocalSelfReportVerified
    and RaceLocked_GetLocalSelfReportVerified() or false
  local clean = RaceLocked_GetLocalSelfReportClean
    and RaceLocked_GetLocalSelfReportClean() or false
  local tamperAt = RaceLocked_GetLocalTamperAt and RaceLocked_GetLocalTamperAt() or 0

  RaceLocked_Roster_SetSelfReport(guildName, playerName, verified, clean, tamperAt)

  -- Wire layout: S:name,verified,clean,tamperAt[,gmVerified,gmClean,gmTimestamp]
  -- tamperAt is always present (field 4) so the optional GM badge stays at a
  -- fixed offset (fields 5-7).
  local v = boolToWire(verified)
  local c = boolToWire(clean)
  local msg = 'S:' .. playerName .. ',' .. v .. ',' .. c .. ',' .. tostring(tamperAt)

  local entry = RaceLocked_Roster_GetEntry(guildName, playerName)
  if entry and (entry.gmVerified ~= nil or entry.gmClean ~= nil) then
    msg = msg .. ',' .. boolToWire(entry.gmVerified) .. ',' ..
      boolToWire(entry.gmClean) .. ',' .. tostring(entry.gmTimestamp or 0)
  end

  send(ADDON_PREFIX, msg, 'GUILD')
  sessionLog('sent', playerName .. ' • ' .. describeStatus(verified, clean)
    .. describeOverrideSuffix(entry and entry.gmVerified, entry and entry.gmClean), msg)
  return true
end

--- Send a targeted O: relay for a single player whose S: arrived without
--- the GM badge we have stored locally.
local function sendTargetedRelay(guildName, playerName)
  local entry = RaceLocked_Roster_GetEntry(guildName, playerName)
  if not entry then return end
  if entry.gmVerified == nil and entry.gmClean == nil then return end

  local send = getAddonSend()
  if not send then return end

  local msg = 'O:' .. playerName .. ',' ..
    boolToWire(entry.gmVerified) .. ',' ..
    boolToWire(entry.gmClean) .. ',' .. tostring(entry.gmTimestamp or 0)
  send(ADDON_PREFIX, msg, 'GUILD')
  sessionLog('sent', playerName .. ' • Relay'
    .. describeOverrideSuffix(entry.gmVerified, entry.gmClean), msg)
end

-- Relay dampening: when many members hold the same override and a member
-- reports in without it, we don't want everyone relaying simultaneously.
-- Each pending relay waits a short randomized delay; if the override reaches
-- that player in the meantime (their own badge or another peer's relay), we
-- cancel ours. The jitter means only the earliest few members actually send.
local RELAY_MIN_DELAY = 1.5
local RELAY_MAX_JITTER = 2.0
local pendingRelay = {}
local relayTimerArmed = false

local function flushPendingRelays(guildName)
  relayTimerArmed = false
  for playerName in pairs(pendingRelay) do
    pendingRelay[playerName] = nil
    sendTargetedRelay(guildName, playerName)
  end
end

local function queueRelay(guildName, playerName)
  pendingRelay[playerName] = true
  if relayTimerArmed or not C_Timer then return end
  relayTimerArmed = true
  local delay = RELAY_MIN_DELAY + math.random() * RELAY_MAX_JITTER
  C_Timer.After(delay, function() flushPendingRelays(guildName) end)
end

local function cancelPendingRelay(playerName)
  pendingRelay[playerName] = nil
end

--- Apply a GM override to the local store WITHOUT broadcasting. Used while the
--- guild master is editing a row: each Verified/Tampered selection stages
--- locally so the UI updates, and the combined result is broadcast once when
--- they finish (see RaceLocked_Roster_CommitGMOverride). Silent no-op for
--- non-GMs.
function RaceLocked_Roster_StageGMOverride(playerName, gmVerified, gmClean)
  if not RaceLocked_AmIGuildMaster() then return end
  local guildName = RaceLocked_Roster_GetPlayerGuildName()
  if not guildName then return end
  RaceLocked_Roster_SetGMOverride(guildName, playerName, gmVerified, gmClean, time())
end

--- Broadcast the override currently stored for `playerName` to the guild as a
--- single message. This is the only place a GM override goes out, so editing
--- both flags still results in just one broadcast.
--- @return boolean sent  true if a message was put on the channel
function RaceLocked_Roster_CommitGMOverride(playerName)
  if not RaceLocked_AmIGuildMaster() then
    sessionLog('warn', 'Cannot send GM override • you are not the guild master.')
    return false
  end
  local guildName = RaceLocked_Roster_GetPlayerGuildName()
  if not guildName then return false end
  local send = getAddonSend()
  if not send then return false end

  -- Read straight from the entry; do NOT use `a and b or c`, which would turn
  -- a legitimate `false` (Not Verified / Tampered) override into nil.
  local entry = RaceLocked_Roster_GetEntry(guildName, playerName)
  local gmVerified = entry and entry.gmVerified
  local gmClean = entry and entry.gmClean
  local ts = (entry and entry.gmTimestamp) or time()

  local msg = 'G:' .. playerName .. ',' .. boolToWire(gmVerified) .. ',' ..
    boolToWire(gmClean) .. ',' .. tostring(ts)
  send(ADDON_PREFIX, msg, 'GUILD')
  sessionLog('sent', playerName .. ' • GM Override: ' .. describeGMDecision(gmVerified, gmClean), msg)
  return true
end

-- ── Incoming message parsing ─────────────────────────────────────────────

local function splitComma(str)
  local fields = {}
  for field in string.gmatch(str, '[^,]+') do
    fields[#fields + 1] = field
  end
  return fields
end

local function handleSelfReport(guildName, senderShort, fields, rawMessage)
  -- Wire layout: name,verified,clean,tamperAt[,gmVerified,gmClean,gmTimestamp]
  local playerName = fields[1]
  local verified = wireToBool(fields[2])
  local clean = wireToBool(fields[3])
  local clientTamperAt = tonumber(fields[4]) or 0
  if not playerName or playerName == '' or verified == nil or clean == nil then return end

  -- A self-report can only speak for the sender. Reject any payload whose
  -- subject name doesn't match the addon-message sender, otherwise a member
  -- could broadcast `S:Victim,1,1` and poison the victim's roster status for
  -- everyone (trade/mail now trust roster entries when present).
  if not senderShort or Ambiguate(playerName, 'short') ~= senderShort then
    sessionLog('warn', 'Rejected self-report for ' .. playerName .. ' from ' .. tostring(senderShort) .. ' • name/sender mismatch', rawMessage)
    return
  end

  -- Capture whether we already hold a GM override this sender doesn't know
  -- about. This must happen BEFORE storing their self-report (which only
  -- touches the self-reported fields), so the check reflects prior state.
  local existingEntry = RaceLocked_Roster_GetEntry(guildName, playerName)
  local hadLocalOverride = existingEntry
    and (existingEntry.gmVerified ~= nil or existingEntry.gmClean ~= nil)

  RaceLocked_Roster_SetSelfReport(guildName, playerName, verified, clean, clientTamperAt)

  -- A self-report may carry the sender's own GM override badge (fields 5-7).
  -- If present, store it; otherwise we may need to relay an override the
  -- sender is missing. Like O: relays, this badge is accepted on timestamp
  -- alone (not GM-authenticated) • see the trust-model note on handlePeerRelay.
  local incomingHasBadge = false
  if fields[5] and fields[6] then
    local gmVerified = wireToBool(fields[5])
    local gmClean = wireToBool(fields[6])
    if gmVerified ~= nil or gmClean ~= nil then
      incomingHasBadge = true
      local gmTimestamp = tonumber(fields[7]) or 0
      local accepted = RaceLocked_Roster_SetGMOverride(guildName, playerName, gmVerified, gmClean, gmTimestamp)
      -- If the sender's badge is current, no relay is needed. If it was rejected
      -- as stale, we hold a newer override (e.g. issued while they were offline)
      -- and must relay it back so they pick it up.
      if accepted then
        cancelPendingRelay(playerName)
      else
        queueRelay(guildName, playerName)
      end
      sessionLog('recv', playerName .. ' • ' .. describeStatus(verified, clean)
        .. describeOverrideSuffix(gmVerified, gmClean) .. staleSuffix(accepted), rawMessage)
    end
  end

  if not incomingHasBadge then
    sessionLog('recv', playerName .. ' • ' .. describeStatus(verified, clean), rawMessage)
    if hadLocalOverride then
      queueRelay(guildName, playerName)
    end
  end
end

--- Apply a flat list of override groups (name, verified, clean, timestamp, …)
--- to the store. `describe` turns each applied group into a session-log line,
--- or returns nil to skip logging it. The raw wire message is attached to each
--- logged line for the hover-to-inspect tooltip.
--- @param guildName string
--- @param fields string[]
--- @param rawMessage string
--- @param describe fun(name:string, gmVerified:boolean|nil, gmClean:boolean|nil, gmTimestamp:number, accepted:boolean):string|nil
local function applyOverrideGroups(guildName, fields, rawMessage, describe)
  local index = 1
  while index + 3 <= #fields do
    local playerName = fields[index]
    local gmVerified = wireToBool(fields[index + 1])
    local gmClean = wireToBool(fields[index + 2])
    local gmTimestamp = tonumber(fields[index + 3]) or 0
    if playerName and playerName ~= '' then
      local accepted = RaceLocked_Roster_SetGMOverride(guildName, playerName, gmVerified, gmClean, gmTimestamp)
      local line = describe(playerName, gmVerified, gmClean, gmTimestamp, accepted)
      if line then
        sessionLog('recv', line, rawMessage)
      end
    end
    index = index + 4
  end
end

local function handleGMOverride(guildName, sender, fields, rawMessage)
  if not RaceLocked_IsGuildMaster(sender) then
    sessionLog('warn', 'Rejected override from ' .. sender .. ' • not guild master', rawMessage)
    return
  end
  applyOverrideGroups(guildName, fields, rawMessage, function(name, gmVerified, gmClean, _, accepted)
    return name .. ' • GM Override (' .. sender .. '): ' .. describeGMDecision(gmVerified, gmClean) .. staleSuffix(accepted)
  end)
end

-- Trust model for override propagation (intentional, not an oversight):
-- Only `G:` is sender-authenticated (handleGMOverride requires IsGuildMaster).
-- `O:` peer relays and the `S:` self-report badge are accepted on timestamp
-- alone so a GM override can reach members who were offline when it was issued,
-- even after the GM logs off. This means a protocol-participating attacker
-- could forge an override. We accept that because:
--   * The override is a *positive* tool (clear false-positive tampering, admit a
--     trusted non-self-found member). Forging a grant buys nothing beyond the
--     self-report trust a client already has (a modified client can already
--     broadcast S:Self,1,1 • see the TV/self-report trust note in
--     CanPerformTradeWithPlayer.lua).
--   * Forging a *revoke* to grief an honest member is the only residual, and the
--     real-world remedy for such a bad actor is removal from the guild.
-- Authenticating relays to the GM would close forgery but break the offline
-- propagation this feature depends on, so it is deliberately not done.
local function handlePeerRelay(guildName, fields, rawMessage)
  applyOverrideGroups(guildName, fields, rawMessage, function(name, gmVerified, gmClean, _, accepted)
    if not accepted then return nil end
    -- A current relay from a peer covers this player, so we can drop ours.
    -- (If it were stale we'd keep ours so our newer override still propagates.)
    cancelPendingRelay(name)
    return name .. ' • Relay' .. describeOverrideSuffix(gmVerified, gmClean)
  end)
end

local function onAddonMessage(prefix, message, channel, sender)
  if prefix ~= ADDON_PREFIX then return end
  if not IsInGuild or not IsInGuild() then return end
  if isSenderLocalPlayer(sender) then return end
  local guildName = RaceLocked_Roster_GetPlayerGuildName()
  if not guildName then return end

  local senderShort = Ambiguate(sender, 'short')

  local typeMarker = string.sub(message, 1, 2)
  local payload = string.sub(message, 3)
  if payload == '' then return end
  local fields = splitComma(payload)
  if #fields == 0 then return end

  if typeMarker == 'S:' then
    handleSelfReport(guildName, senderShort, fields, message)
  elseif typeMarker == 'G:' then
    handleGMOverride(guildName, senderShort, fields, message)
  elseif typeMarker == 'O:' then
    handlePeerRelay(guildName, fields, message)
  end
end

-- ── Slash command for debug inspection ───────────────────────────────────

--- Build a set of the current guild's member short-names from the live roster.
--- Returns the set plus the member count so callers can detect an unloaded
--- roster (count 0) and skip destructive cleanup.
--- @return table<string, boolean> names  short names keyed true
--- @return number count            number of roster rows scanned
local function buildCurrentGuildNameSet()
  local names = {}
  if not GetNumGuildMembers or not GetGuildRosterInfo then
    return names, 0
  end
  local num = GetNumGuildMembers() or 0
  for index = 1, num do
    local fullName = GetGuildRosterInfo(index)
    if fullName and fullName ~= '' then
      names[Ambiguate(fullName, 'short')] = true
    end
  end
  return names, num
end

SLASH_RLROSTER1 = '/rlroster'

SlashCmdList['RLROSTER'] = function(input)
  local guildName = RaceLocked_Roster_GetPlayerGuildName()
  if not guildName then
    RaceLocked_PrintRestrictionMessage('Not in a guild.')
    return
  end

  local arg = (input or ''):match('^%s*(.-)%s*$')

  if arg == 'sync' then
    broadcastSelfReport()

    -- Request a roster refresh with offline members included, then set a flag
    -- so the next GUILD_ROSTER_UPDATE fires the actual prune. We never prune
    -- inline because GuildRoster() is async • GetNumGuildMembers() right after
    -- may still reflect an older, online-only snapshot.
    RaceLocked_RefreshGuildRoster()
    pendingCleanupGuild = guildName
    RaceLocked_PrintRestrictionMessage('Roster cleanup queued • waiting for guild data.')
    return
  end

  if arg == 'reset' then
    RaceLockedAccountDB = RaceLockedAccountDB or {}
    RaceLockedAccountDB.guildFoundRoster = nil
    RaceLocked_PrintRestrictionMessage('Roster DB wiped. /reload to re-initialize.')
    return
  end

  if arg == 'gm' then
    RaceLocked_DevToggleGM()
    return
  end

  if arg == 'fakedata' then
    local fakes = {
      { name = 'Testplayer',  v = true,  c = true  },
      { name = 'Cheaterboy',  v = true,  c = false },
      { name = 'Newbieguy',   v = false, c = true  },
      { name = 'Altchar',     v = false, c = false },
    }
    for _, f in ipairs(fakes) do
      RaceLocked_Roster_SetSelfReport(guildName, f.name, f.v, f.c)
    end
    RaceLocked_PrintRestrictionMessage('Injected ' .. #fakes .. ' fake roster entries.')
    -- If the Guild Verification tab is currently visible, refresh it so the
    -- injected rows appear immediately in the table.
    if RaceLocked_GetActiveTab and RaceLocked_SwitchToTab
      and RaceLocked_GetActiveTab() == 3 then
      RaceLocked_SwitchToTab(3)
    end
    return
  end

  RaceLocked_PrintRestrictionMessage('── Roster for <' .. guildName .. '> ──')
  RaceLocked_PrintRestrictionMessage('I am GM: ' .. tostring(RaceLocked_AmIGuildMaster()))

  local store = RaceLocked_Roster_GetAllEntries(guildName)
  if not store then
    RaceLocked_PrintRestrictionMessage('  (empty)')
    return
  end

  local count = 0
  for name, entry in pairs(store) do
    local ev, ec = RaceLocked_Roster_GetEffectiveStatus(guildName, name)
    local parts = '  ' .. name .. ': V=' .. tostring(entry.verified) ..
      ' C=' .. tostring(entry.clean)
    if entry.gmVerified ~= nil or entry.gmClean ~= nil then
      parts = parts .. ' | gmV=' .. tostring(entry.gmVerified) ..
        ' gmC=' .. tostring(entry.gmClean) ..
        ' ts=' .. tostring(entry.gmTimestamp or 0)
    end
    parts = parts .. ' | effective: V=' .. tostring(ev) .. ' C=' .. tostring(ec)
    RaceLocked_PrintRestrictionMessage(parts)
    count = count + 1
  end
  RaceLocked_PrintRestrictionMessage('Total entries: ' .. count)
  RaceLocked_PrintRestrictionMessage('Commands: /rlroster sync | /rlroster reset | /rlroster gm | /rlroster fakedata')
end

-- ── Event frame ──────────────────────────────────────────────────────────

local thisAddonName = ...

-- PLAYER_ENTERING_WORLD fires on every loading screen (zoning, instances,
-- etc.), not just login. We only want to announce and broadcast once per
-- session (see hasAnnouncedThisSession above).

--- Log the session-start line and broadcast our self-report once guild info is
--- readable. Guild name often isn't ready on the first PLAYER_ENTERING_WORLD,
--- so several events call this until it succeeds.
local function trySessionAnnounce()
  if hasAnnouncedThisSession then return end
  if RaceLocked_HasValidatedLocalMoneyThisSession
    and not RaceLocked_HasValidatedLocalMoneyThisSession() then
    return
  end
  local playerName = RaceLocked_Roster_GetPlayerName()
  local guildName = RaceLocked_Roster_GetPlayerGuildName()
  if not playerName or not guildName then
    -- IsInGuild can be true while GetGuildInfo('player') is still nil until
    -- the roster finishes loading • nudge a refresh and try again on
    -- GUILD_ROSTER_UPDATE.
    if IsInGuild and IsInGuild() and RaceLocked_RefreshGuildRoster then
      RaceLocked_RefreshGuildRoster()
    end
    return
  end

  local verified = RaceLocked_IsLocalVerified and RaceLocked_IsLocalVerified() or false
  local clean = RaceLocked_IsLocalClean and RaceLocked_IsLocalClean() or false
  local loginStatus = 'Login • ' .. describeStatus(verified, clean)
  sessionLog('info', loginStatus)
  -- Echo just this one line to chat so players can confirm the addon
  -- initialized correctly on login.
  RaceLocked_PrintRestrictionMessage(loginStatus)
  local sent = broadcastSelfReport()
  if sent then
    hasAnnouncedThisSession = true
  end
end

local service = CreateFrame('Frame')
service:RegisterEvent('ADDON_LOADED')
service:RegisterEvent('PLAYER_ENTERING_WORLD')
service:RegisterEvent('GUILD_ROSTER_UPDATE')
service:RegisterEvent('CHAT_MSG_ADDON')
service:SetScript('OnEvent', function(_, event, ...)
  if event == 'ADDON_LOADED' then
    local loadedAddonName = ...
    if loadedAddonName == thisAddonName then
      registerPrefix()
      trySessionAnnounce()
    end
    return
  end

  if event == 'PLAYER_ENTERING_WORLD' then
    trySessionAnnounce()
    return
  end

  if event == 'GUILD_ROSTER_UPDATE' then
    trySessionAnnounce()

    -- Deferred roster cleanup: the manual sync command set pendingCleanupGuild
    -- and called GuildRoster(). Now that GUILD_ROSTER_UPDATE has fired, the
    -- live roster should include offline members. Two guards prevent pruning
    -- against a bad snapshot:
    --   1. Self-name check: if our own name isn't in the scan, the roster
    --      hasn't finished loading at all • abort.
    --   2. Count guard: if the live scan has fewer than half the stored entries,
    --      the roster is likely still partial (e.g. only online members loaded
    --      so far) • abort rather than mass-pruning offline members.
    -- Even past both guards the prune is self-correcting: a wrongly removed
    -- member reappears on their next self-report.
    if pendingCleanupGuild and RaceLocked_Roster_CleanupForRoster then
      local guildForCleanup = pendingCleanupGuild
      pendingCleanupGuild = nil

      local currentMembers, liveCount = buildCurrentGuildNameSet()
      local myName = RaceLocked_Roster_GetPlayerName()
      if liveCount == 0 or not myName or not currentMembers[Ambiguate(myName, 'short')] then
        sessionLog('info', 'Roster cleanup skipped • guild roster not fully loaded.')
        return
      end

      local storedCount = RaceLocked_Roster_GetEntryCount
        and RaceLocked_Roster_GetEntryCount(guildForCleanup) or 0
      if storedCount > 0 and liveCount < math.floor(storedCount / 2) then
        sessionLog('info', 'Roster cleanup skipped • live roster (' .. liveCount
          .. ') is less than half of stored entries (' .. storedCount .. ').')
        return
      end

      local removed = RaceLocked_Roster_CleanupForRoster(guildForCleanup, currentMembers)
      if removed > 0 then
        RaceLocked_PrintRestrictionMessage(
          'Removed ' .. removed .. ' former member(s) from the Guild Found roster.')
        -- If the Guild Verification tab is currently visible, refresh it so the
        -- table view drops departed members immediately.
        if RaceLocked_GetActiveTab and RaceLocked_SwitchToTab
          and RaceLocked_GetActiveTab() == 3 then
          RaceLocked_SwitchToTab(3)
        end
      else
        RaceLocked_PrintRestrictionMessage('Roster cleanup complete • no departed members found.')
      end
    end
    return
  end

  if event == 'CHAT_MSG_ADDON' then
    onAddonMessage(...)
    return
  end
end)
