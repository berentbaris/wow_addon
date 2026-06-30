-- Guild-scoped addon messages for death pings (safe from non-click event handlers).

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}

RaceLocked_GuildChampion.GUILD_DEATH_ADDON_PREFIX = 'RLGuildDeath'
local PREFIX = RaceLocked_GuildChampion.GUILD_DEATH_ADDON_PREFIX

local function registerPrefix()
  if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
  elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(PREFIX)
  end
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

local function sendGuildDeathPing()
  if not IsInGuild or not IsInGuild() then return end
  local send = SendAddonMessage or (C_ChatInfo and C_ChatInfo.SendAddonMessage)
  if not send then return end
  -- print('|cffffffffRace Locked|r: Sending guild death ping.')
  send(PREFIX, '1', 'GUILD')
end

--- Call on local `PLAYER_DEAD` while in a guild (after incrementing stored counts).
function RaceLocked_GuildChampion_BroadcastGuildDeathPing()
  sendGuildDeathPing()
end

--- Handle `CHAT_MSG_ADDON` for guild death pings (increment; do not re-broadcast).
function RaceLocked_GuildChampion_OnGuildDeathAddonMessage(prefix, message, channel, sender)
  if prefix ~= PREFIX then return end
  if not IsInGuild or not IsInGuild() then return end
  if isSenderLocalPlayer(sender) then return end
  -- print(
  --   string.format(
  --     '|cffffffffRace Locked|r: Received guild death ping from %s, incrementing stored guild deaths.',
  --     tostring(sender or 'unknown')
  --   )
  -- )
  if RaceLocked_GuildChampion_IncrementGuildDeathsForOwnGuild then
    RaceLocked_GuildChampion_IncrementGuildDeathsForOwnGuild()
  end
end

function RaceLocked_GuildChampion_EnsureGuildDeathAddonPrefixRegistered()
  registerPrefix()
end
