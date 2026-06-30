--- Hook into HardcoreAchievements to track per-player achievement points,
--- share them within the guild via addon messages, and make the guild average
--- available for the race grid broadcast.

local ADDON_PREFIX = 'RLGuildAch'
local thisAddonName = ...

local lastKnownTotalPoints = nil

local function registerPrefix()
  if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
  elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(ADDON_PREFIX)
  end
end

local function getPlayerGuildName()
  if not IsInGuild or not IsInGuild() or not GetGuildInfo then
    return nil
  end
  local guildName = GetGuildInfo('player')
  if type(guildName) ~= 'string' or guildName == '' then
    return nil
  end
  return guildName
end

local function getPlayerName()
  if not UnitName then
    return nil
  end
  local name = UnitName('player')
  if type(name) ~= 'string' or name == '' then
    return nil
  end
  return name
end

local function isSenderLocalPlayer(sender)
  if type(sender) ~= 'string' or sender == '' then
    return false
  end
  if GetUnitName then
    local full = GetUnitName('player', true)
    if full and full ~= '' and sender == full then
      return true
    end
  end
  if UnitName then
    return sender == UnitName('player')
  end
  return false
end

local function getAddonSend()
  if not IsInGuild or not IsInGuild() then
    return nil
  end
  return SendAddonMessage or (C_ChatInfo and C_ChatInfo.SendAddonMessage)
end

--- All guild addon messages use the "R:" relay format: "R:Name1=Pts1,Name2=Pts2,..."
--- packed to fit within the 255-byte addon message limit.
local RELAY_PREFIX = 'R:'
local MAX_ADDON_MSG = 255

local function broadcastOwnPointsToGuild(playerName, totalPoints)
  local send = getAddonSend()
  if not send then return end
  local msg = RELAY_PREFIX .. playerName .. '=' .. tostring(tonumber(totalPoints) or 0)
  send(ADDON_PREFIX, msg, 'GUILD')
end

local function buildRelayMessages(guildName)
  if not RaceLocked_AchievementTracking_GetAllPlayerPoints then
    return {}
  end
  local store = RaceLocked_AchievementTracking_GetAllPlayerPoints(guildName)
  if not store then
    return {}
  end
  local messages = {}
  local buf = RELAY_PREFIX
  for name, pts in pairs(store) do
    local entry = name .. '=' .. tostring(tonumber(pts) or 0)
    local piece = (buf == RELAY_PREFIX) and entry or (',' .. entry)
    if #buf + #piece > MAX_ADDON_MSG then
      if buf ~= RELAY_PREFIX then
        messages[#messages + 1] = buf
      end
      buf = RELAY_PREFIX .. entry
    else
      buf = buf .. piece
    end
  end
  if buf ~= RELAY_PREFIX then
    messages[#messages + 1] = buf
  end
  return messages
end

--- Send relay messages one per frame to avoid throttling.
local relayQueue = {}
local relayTicker = nil

local function drainRelayQueue()
  if #relayQueue == 0 then
    if relayTicker then
      relayTicker:Cancel()
      relayTicker = nil
    end
    return
  end
  local send = getAddonSend()
  if not send then
    relayQueue = {}
    if relayTicker then
      relayTicker:Cancel()
      relayTicker = nil
    end
    return
  end
  local msg = table.remove(relayQueue, 1)
  send(ADDON_PREFIX, msg, 'GUILD')
end

local function broadcastRelayToGuild(guildName)
  local msgs = buildRelayMessages(guildName)
  if #msgs == 0 then return end
  for i = 1, #msgs do
    relayQueue[#relayQueue + 1] = msgs[i]
  end
  if not relayTicker and C_Timer and C_Timer.NewTicker then
    relayTicker = C_Timer.NewTicker(0.1, drainRelayQueue)
  end
end

local function storeOwnPoints(totalPoints)
  local guildName = getPlayerGuildName()
  local playerName = getPlayerName()
  if not guildName or not playerName then return end
  if RaceLocked_AchievementTracking_SetPlayerPoints then
    RaceLocked_AchievementTracking_SetPlayerPoints(guildName, playerName, totalPoints)
  end
end

--- Read the player's current total points from HardcoreAchievements if available.
--- Falls back to scraping the UI frame text since the hook API (see below) is not
--- yet exposed by the current release of HardcoreAchievements. This is the primary
--- method used today -- called on each manual sync.
--- @return number|nil
local function queryHardcoreAchievementPoints()
  if HardcoreAchievementsFrame and HardcoreAchievementsFrame.TotalPoints then
    local tp = HardcoreAchievementsFrame.TotalPoints
    if tp.GetText then
      return tonumber(tp:GetText())
    end
  end
  return nil
end

--- Attempt to install a real-time hook into HardcoreAchievements so points are
--- automatically updated whenever the player earns an achievement, without needing
--- a manual sync.
---
--- STATUS: HardcoreAchievements documents an OnAchievement hook via
--- HardcoreAchievements_Hooks:HookScript, but the current release does NOT expose
--- the HardcoreAchievements_Hooks global. This function will silently return false
--- until a future HA update creates that global. When it does, this will "just work"
--- and start auto-broadcasting points on each achievement earned.
local function installHardcoreAchievementsHook()
  if not HardcoreAchievements_Hooks then
    return false
  end
  HardcoreAchievements_Hooks:HookScript('OnAchievement', function(achievementData)
    if type(achievementData) ~= 'table' then return end
    local totalPoints = tonumber(achievementData.totalPoints) or 0
    lastKnownTotalPoints = totalPoints
    storeOwnPoints(totalPoints)
    local pn = getPlayerName()
    if pn then
      broadcastOwnPointsToGuild(pn, totalPoints)
    end
  end)
  return true
end

local function applyRelayMessage(guildName, message)
  local payload = string.sub(message, #RELAY_PREFIX + 1)
  if payload == '' then return end
  if not RaceLocked_AchievementTracking_SetPlayerPoints then return end
  for entry in string.gmatch(payload, '[^,]+') do
    local eq = string.find(entry, '=', 1, true)
    if eq and eq > 1 then
      local name = string.sub(entry, 1, eq - 1)
      local pts = tonumber(string.sub(entry, eq + 1))
      if name ~= '' and pts then
        RaceLocked_AchievementTracking_SetPlayerPoints(guildName, name, pts)
      end
    end
  end
end

local function onAddonMessage(prefix, message, channel, sender)
  if prefix ~= ADDON_PREFIX then return end
  if not IsInGuild or not IsInGuild() then return end
  if isSenderLocalPlayer(sender) then return end
  local guildName = getPlayerGuildName()
  if not guildName then return end
  if string.sub(message, 1, #RELAY_PREFIX) == RELAY_PREFIX then
    applyRelayMessage(guildName, message)
  end
end

--- Query HardcoreAchievements for current points and store locally.
--- Called from the sync button BEFORE the roster scan so the player's own
--- points are included in the average. Does NOT broadcast -- call
--- RaceLocked_AchievementTracking_BroadcastRelay after the roster scan
--- so stale entries are pruned before going out on the wire.
function RaceLocked_AchievementTracking_SyncOwnPoints()
  local guildName = getPlayerGuildName()
  local playerName = getPlayerName()
  local live = queryHardcoreAchievementPoints()
  if live and live > 0 then
    lastKnownTotalPoints = live
    storeOwnPoints(live)
  elseif guildName and playerName then
    if lastKnownTotalPoints and lastKnownTotalPoints > 0 then
      storeOwnPoints(lastKnownTotalPoints)
    end
  end
end

--- Broadcast the full known points store to the guild.
--- Called AFTER the roster scan so CleanupForRoster has already pruned
--- players who left the guild.
function RaceLocked_AchievementTracking_BroadcastRelay()
  local guildName = getPlayerGuildName()
  if guildName then
    broadcastRelayToGuild(guildName)
  end
end

-- Retry the hook install on ADDON_LOADED (each addon) and PLAYER_ENTERING_WORLD
-- because HardcoreAchievements may load after us. Once the hook is installed we
-- stop trying. Until then, manual sync via queryHardcoreAchievementPoints is the
-- only way to pick up points.
local hookInstalled = false

local service = CreateFrame('Frame')
service:RegisterEvent('ADDON_LOADED')
service:RegisterEvent('PLAYER_ENTERING_WORLD')
service:RegisterEvent('CHAT_MSG_ADDON')
service:SetScript('OnEvent', function(_, event, ...)
  if event == 'ADDON_LOADED' then
    local loadedAddonName = ...
    if loadedAddonName == thisAddonName then
      registerPrefix()
    end
    if not hookInstalled then
      hookInstalled = installHardcoreAchievementsHook()
    end
    return
  end
  if event == 'PLAYER_ENTERING_WORLD' then
    if not hookInstalled then
      hookInstalled = installHardcoreAchievementsHook()
    end
    return
  end
  if event == 'CHAT_MSG_ADDON' then
    onAddonMessage(...)
    return
  end
end)
