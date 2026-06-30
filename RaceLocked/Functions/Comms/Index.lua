RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}
local G = RaceLocked_GuildChampion
local thisAddonName = ...

G.Comms = G.Comms or {}
local Comms = G.Comms

function RaceLocked_GuildChampion_BroadcastOwnGuildRaceGridReports()
  if not RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid then return end
  if RaceLocked_GuildChampion_EnsureStoredGuildReportsDB then
    RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
  end
  local channelId = Comms.EnsureDataChannelJoined()
  if channelId <= 0 then return end
  local raceTokens = {}
  for raceToken, _ in pairs(G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE or {}) do
    raceTokens[#raceTokens + 1] = raceToken
  end
  if #raceTokens > 0 and RaceLocked_GuildChampion_UpdateOwnStoredGuildReportsFromRoster then
    -- If we are broadcasting, our own roster data should be fresh and included.
    RaceLocked_GuildChampion_UpdateOwnStoredGuildReportsFromRoster(raceTokens)
  end
  local ownGuildNorm = ''
  if RaceLocked_GuildChampion_GetNormalizedPlayerGuildName then
    ownGuildNorm = RaceLocked_GuildChampion_GetNormalizedPlayerGuildName() or ''
  end
  local ownGuildRaw = ''
  if GetGuildInfo then
    ownGuildRaw = GetGuildInfo('player') or ''
  end
  local canStampOwnGuild = ownGuildNorm ~= ''
  local now = RaceLocked_GuildChampion_GetRaceGridStoredUnixTime()
  local stampedOwn = false
  local ownRowsSeen = 0
  local ownRowsSent = 0

  for raceToken, rows in pairs(G.RACE_GRID_STORED_GUILD_REPORTS_BY_RACE or {}) do
    if type(rows) == 'table' then
      for _, row in ipairs(rows) do
        if type(row) == 'table' then
          local rowNorm = RaceLocked_GuildChampion_NormalizeGuildNameForRaceGrid(row.guildName)
          local isOwnRow = canStampOwnGuild and rowNorm ~= '' and rowNorm == ownGuildNorm
          if isOwnRow then
            ownRowsSeen = ownRowsSeen + 1
          end
          if isOwnRow then
            row.timestamp = now
            stampedOwn = true
          end
          local payload = Comms.BuildPayload(raceToken, row)
          if payload and payload ~= '' then
            Comms.SendRaceGridChannelLine(channelId, payload)
            if isOwnRow then
              ownRowsSent = ownRowsSent + 1
            end
          end
        end
      end
    end
  end

  if stampedOwn and RaceLocked_GuildChampion_PersistStoredGuildReportsByRace then
    RaceLocked_GuildChampion_PersistStoredGuildReportsByRace()
  end
  -- print(
  --   string.format(
  --     '|cffffffffRace Locked|r: Broadcast own-guild rows seen=%s sent=%s guildNorm=%s guildRaw=%s',
  --     tostring(ownRowsSeen),
  --     tostring(ownRowsSent),
  --     tostring(ownGuildNorm),
  --     tostring(ownGuildRaw)
  --   )
  -- )
end

local service = CreateFrame('Frame')
service:RegisterEvent('ADDON_LOADED')
service:RegisterEvent('PLAYER_LOGIN')
service:RegisterEvent('PLAYER_ENTERING_WORLD')
service:RegisterEvent('CHAT_MSG_CHANNEL')
service:RegisterEvent('CHAT_MSG_ADDON')
service:RegisterEvent('PLAYER_DEAD')
service:RegisterEvent('CHANNEL_UI_UPDATE')
service:SetScript('OnEvent', function(_, event, ...)
  if event == 'ADDON_LOADED' then
    local loadedAddonName = ...
    if loadedAddonName == thisAddonName then
      if RaceLocked_GuildChampion_EnsureStoredGuildReportsDB then
        RaceLocked_GuildChampion_EnsureStoredGuildReportsDB()
      end
      if RaceLocked_GuildChampion_EnsureGuildDeathAddonPrefixRegistered then
        RaceLocked_GuildChampion_EnsureGuildDeathAddonPrefixRegistered()
      end
      Comms.InstallChannelNoticeFilters()
      Comms.ScheduleDelayedDataChannelJoin()
    end
    return
  end
  if event == 'PLAYER_LOGIN' then
    Comms.ScheduleDelayedDataChannelJoin()
    return
  end
  if event == 'PLAYER_ENTERING_WORLD' then
    Comms.ScheduleDelayedDataChannelJoin()
    return
  end
  if event == 'CHANNEL_UI_UPDATE' then
    Comms.EnsureDataChannelJoined()
    return
  end
  if event == 'CHAT_MSG_ADDON' then
    local prefix, msg, channel, sender = ...
    if RaceLocked_GuildChampion_OnGuildDeathAddonMessage then
      RaceLocked_GuildChampion_OnGuildDeathAddonMessage(prefix, msg, channel, sender)
    end
    return
  end
  if event == 'PLAYER_DEAD' then
    if IsInGuild and IsInGuild() then
      if RaceLocked_GuildChampion_IncrementGuildDeathsForOwnGuild then
        RaceLocked_GuildChampion_IncrementGuildDeathsForOwnGuild()
      end
      if RaceLocked_GuildChampion_BroadcastGuildDeathPing then
        RaceLocked_GuildChampion_BroadcastGuildDeathPing()
      end
    end
    return
  end
  if event == 'CHAT_MSG_CHANNEL' then
    if not Comms.IsOurDataChannelMessage(...) then return end
    local msg = select(1, ...)
    local report = Comms.ParsePayload(msg)
    if not report then return end
    -- Keep incoming reports persisted, but do not force live UI rerenders;
    -- the race grid redraw is user-driven from Apply Update.
    Comms.ApplyIncomingReport(report)
  end
end)
