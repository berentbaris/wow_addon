----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Addon Communication
--
-- Lets HCE users discover each other in the game world.
--
-- Features:
--   1. Chat tag: A coloured [HCE] tag + class name is prepended to
--      chat messages from other HCE users (only visible to HCE users).
--
--   2. /hce scan: Broadcasts a ping and lists all HCE users on the
--      same server.
--
-- How it works:
--   - On login, joins a hidden custom channel "hce" that all addon
--     users share (borrowed from the AutoLayer approach).  This is
--     the primary discovery backbone — any HCE player on the same
--     server is reachable regardless of guild, group, or proximity.
--   - Also registers the "HCE" addon-message prefix for whisper and
--     guild/party/raid as supplementary channels.
--   - A cache maps player names to their enhanced class.
--   - ChatFrame_AddMessageEventFilter injects the tag into chat.
--
-- Protocol:
--   "HELLO:<className>:<rank>"  — announce your class
--   "PING"                      — request a HELLO back
----------------------------------------------------------------------

HCE = HCE or {}

local Comm = {}
HCE.AddonComm = Comm

local PREFIX       = "HCE"
local CACHE_TTL    = 600  -- seconds before a cached entry expires
local CHANNEL_NAME = "hce" -- dedicated hidden channel for HCE users

----------------------------------------------------------------------
-- Player cache: name-realm -> { class, rank, time }
----------------------------------------------------------------------
local playerCache = {}

function Comm.GetPlayerClass(name)
    local entry = playerCache[name]
    if entry and (GetTime() - entry.time) < CACHE_TTL then
        return entry.class
    end
    return nil
end

function Comm.GetPlayerRank(name)
    local entry = playerCache[name]
    if entry and (GetTime() - entry.time) < CACHE_TTL then
        return entry.rank
    end
    return nil
end

local function cachePlayer(name, className, rank)
    if not name or name == "" or not className or className == "" then return end
    playerCache[name] = { class = className, rank = rank or "Initiate", time = GetTime() }
end

----------------------------------------------------------------------
-- Get our own class name (display name, faction-resolved)
----------------------------------------------------------------------
local function getMyClassName()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return nil end
    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char then return nil end
    return HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
end

----------------------------------------------------------------------
-- Get our own rank
----------------------------------------------------------------------
local function getMyRank()
    if not HCE.Progress or not HCE.Progress.Collect or not HCE.Progress.Percentage or not HCE.Progress.GetRank then
        return "Initiate"
    end
    local summary = HCE.Progress.Collect()
    if not summary or not summary.counts then return "Initiate" end
    local pct = HCE.Progress.Percentage(summary.counts)
    return HCE.Progress.GetRank(pct)
end

----------------------------------------------------------------------
-- Dedicated "hce" channel management
--
-- All HCE addon users on the same server auto-join this hidden
-- channel.  It is removed from all chat frames so it is invisible.
-- SendAddonMessage with "CHANNEL" distribution reaches every member.
----------------------------------------------------------------------
local hceChannelId = 0  -- updated after join

local function getHCEChannelId()
    local id = GetChannelName(CHANNEL_NAME)
    if id and id > 0 then
        hceChannelId = id
    end
    return hceChannelId
end

local function hideChannelFromChatFrames()
    for i = 1, 10 do
        local cf = _G["ChatFrame" .. i]
        if cf then
            ChatFrame_RemoveChannel(cf, CHANNEL_NAME)
        end
    end
end

local function joinHCEChannel()
    JoinChannelByName(CHANNEL_NAME)
    local id = GetChannelName(CHANNEL_NAME)
    if id and id > 0 then
        hceChannelId = id
        hideChannelFromChatFrames()
        return true
    end
    return false
end

----------------------------------------------------------------------
-- Sending messages
----------------------------------------------------------------------
local function safeSend(msg, channel, target)
    local ok, err
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        ok, err = pcall(C_ChatInfo.SendAddonMessage, PREFIX, msg, channel, target)
    elseif SendAddonMessage then
        ok, err = pcall(SendAddonMessage, PREFIX, msg, channel, target)
    end
    -- Silently swallow send errors
end

local function buildHelloMsg()
    local myClass = getMyClassName()
    if not myClass then return nil end
    local myRank = getMyRank()
    return "HELLO:" .. myClass .. ":" .. myRank
end

local function broadcastHello(channel, target)
    local msg = buildHelloMsg()
    if msg then safeSend(msg, channel, target) end
end

local function sendPing(channel, target)
    safeSend("PING", channel, target)
end

----------------------------------------------------------------------
-- Broadcast on the dedicated HCE channel
----------------------------------------------------------------------
local function sendOnHCEChannel(msg)
    local id = getHCEChannelId()
    if id > 0 then
        safeSend(msg, "CHANNEL", tostring(id))
    end
end

--- Broadcast HELLO on all available channels.
local function broadcastAll()
    local msg = buildHelloMsg()
    if not msg then return end

    -- Primary: dedicated HCE channel (reaches all server-wide users)
    sendOnHCEChannel(msg)

    -- Supplementary: guild
    if IsInGuild and IsInGuild() then
        broadcastHello("GUILD")
    end
    -- Supplementary: party / raid
    if IsInRaid and IsInRaid() then
        broadcastHello("RAID")
    elseif IsInGroup and IsInGroup() then
        broadcastHello("PARTY")
    end
end

----------------------------------------------------------------------
-- Receiving messages
----------------------------------------------------------------------
local function onAddonMessage(prefix, msg, channel, sender)
    if prefix ~= PREFIX then return end

    -- Strip realm from sender if present ("Name-Realm" -> "Name")
    local shortName = sender:match("^([^%-]+)") or sender

    -- Ignore messages from ourselves
    local myName = UnitName("player")
    if shortName == myName then return end

    if msg:sub(1, 6) == "HELLO:" then
        local payload = msg:sub(7)
        local className, rank = payload:match("^(.+):(.+)$")
        if not className then
            -- Old format without rank
            className = payload
            rank = "Initiate"
        end
        cachePlayer(sender, className, rank)
        cachePlayer(shortName, className, rank)
    elseif msg == "PING" then
        -- Respond with our class.
        -- For CHANNEL and WHISPER, reply via WHISPER so we don't flood.
        -- For GUILD/PARTY/RAID, broadcast so everyone benefits.
        if channel == "CHANNEL" or channel == "WHISPER" then
            local replyMsg = buildHelloMsg()
            if replyMsg then
                safeSend(replyMsg, "WHISPER", sender)
            end
        else
            broadcastHello(channel)
        end
    end
end

----------------------------------------------------------------------
-- Chat tag injection
----------------------------------------------------------------------
local TAGGED_CHANNELS = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_CHANNEL",
}

-- Rank color lookup (matches ProgressSummary RANK_TIERS)
local RANK_COLORS = {
    ["Master"]   = "ff8000",  -- orange/legendary
    ["Elite"]    = "a335ee",  -- purple/epic
    ["Prime"]    = "0070dd",  -- blue/rare
    ["Adept"]    = "1eff00",  -- green/uncommon
    ["Initiate"] = "ffffff",  -- white/common
}

local function chatFilter(self, event, msg, sender, ...)
    local shortName = sender:match("^([^%-]+)") or sender
    local className = Comm.GetPlayerClass(sender) or Comm.GetPlayerClass(shortName)
    if not className then return false end

    local rank = Comm.GetPlayerRank(sender) or Comm.GetPlayerRank(shortName) or "Initiate"
    local col = RANK_COLORS[rank] or "ffffff"
    local rankPrefix = "|cff" .. col .. rank .. "|r "

    local tag = "|cffffd100[" .. rankPrefix .. className .. "]|r "
    local newMsg = tag .. msg
    return false, newMsg, sender, ...
end

----------------------------------------------------------------------
-- /hce scan — ping and list all HCE users on the server
----------------------------------------------------------------------
local nearbyTimer = nil

function Comm.StartNearbyScan()
    HCE.Print("Scanning for HCE players...")

    -- Primary: ping on the dedicated HCE channel (server-wide)
    local id = getHCEChannelId()
    if id > 0 then
        sendPing("CHANNEL", tostring(id))
    else
        -- Channel not joined yet, try to join and retry
        if joinHCEChannel() then
            id = getHCEChannelId()
            if id > 0 then
                sendPing("CHANNEL", tostring(id))
            end
        end
    end

    -- Supplementary: guild + party/raid
    if IsInGroup and IsInGroup() then
        sendPing("PARTY")
    end
    if IsInRaid and IsInRaid() then
        sendPing("RAID")
    end
    if IsInGuild and IsInGuild() then
        sendPing("GUILD")
        -- Also whisper-ping online guild members for reliability
        local numMembers = GetNumGuildMembers and GetNumGuildMembers() or 0
        local myName = UnitName("player")
        for i = 1, numMembers do
            local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
            if name and online then
                local short = name:match("^([^%-]+)") or name
                if short ~= myName then
                    sendPing("WHISPER", name)
                end
            end
        end
    end

    -- After 5 seconds, print results
    if nearbyTimer then nearbyTimer:Cancel() end
    nearbyTimer = C_Timer.NewTimer(5.0, function()
        Comm.PrintNearbyResults()
        nearbyTimer = nil
    end)
end

function Comm.PrintNearbyResults()
    -- Gather all recently cached players (within the scan window)
    local found = {}
    local seen = {}
    local now = GetTime()
    for name, entry in pairs(playerCache) do
        if (now - entry.time) < 6 then
            local short = name:match("^([^%-]+)") or name
            if not seen[short] then
                seen[short] = true
                table.insert(found, { name = short, class = entry.class, rank = entry.rank })
            end
        end
    end

    if #found == 0 then
        HCE.Print("No other HCE players found.")
    else
        HCE.Print("|cffffd100" .. #found .. " HCE player(s) found:|r")
        for _, p in ipairs(found) do
            local col = RANK_COLORS[p.rank] or "ffffff"
            HCE.Print("  |cffffffff" .. p.name .. "|r — |cff" .. col .. (p.rank or "Initiate") .. "|r |cffe0c040" .. p.class .. "|r")
        end
    end
end

----------------------------------------------------------------------
-- Target/mouseover pinging
----------------------------------------------------------------------
local lastPinged = {}

local function pingUnit(unit)
    if not UnitIsPlayer(unit) then return end
    if not UnitIsConnected(unit) then return end
    if UnitIsEnemy("player", unit) then return end

    local name, realm = UnitName(unit)
    if not name then return end
    local myName = UnitName("player")
    if name == myName then return end

    local fullName = realm and realm ~= "" and (name .. "-" .. realm) or name

    local now = GetTime()
    if lastPinged[fullName] and (now - lastPinged[fullName]) < 30 then return end
    lastPinged[fullName] = now

    safeSend("PING", "WHISPER", fullName)
end

----------------------------------------------------------------------
-- Periodic heartbeat (every 5 minutes, re-broadcast)
----------------------------------------------------------------------
local HEARTBEAT_INTERVAL = 300

local function startHeartbeat()
    C_Timer.NewTicker(HEARTBEAT_INTERVAL, function()
        broadcastAll()
    end)
end

----------------------------------------------------------------------
-- Initialisation
----------------------------------------------------------------------
local commFrame = CreateFrame("Frame", "HCE_AddonCommFrame", UIParent)

local function Init()
    -- Register the addon message prefix
    if C_ChatInfo then
        if C_ChatInfo.IsAddonMessagePrefixRegistered
            and not C_ChatInfo.IsAddonMessagePrefixRegistered(PREFIX) then
            C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        elseif C_ChatInfo.RegisterAddonMessagePrefix then
            C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        end
    end

    -- Register for addon messages
    commFrame:RegisterEvent("CHAT_MSG_ADDON")

    -- Register for target/mouseover changes
    commFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    commFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

    -- Detect joining groups / channels
    commFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    commFrame:RegisterEvent("CHANNEL_UI_UPDATE")
    commFrame:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")

    -- Register chat filters for tag injection
    for _, event in ipairs(TAGGED_CHANNELS) do
        ChatFrame_AddMessageEventFilter(event, chatFilter)
    end

    -- Join the dedicated HCE channel (delay to let the client finish loading)
    C_Timer.After(5.0, function()
        if not joinHCEChannel() then
            -- Retry once more after another 5s if it failed
            C_Timer.After(5.0, function()
                joinHCEChannel()
            end)
        end
    end)

    -- Initial broadcast (delayed further to ensure channel is joined)
    C_Timer.After(12.0, function()
        broadcastAll()
    end)

    -- Start the periodic heartbeat
    startHeartbeat()
end

-- Track group state for join detection
local wasInGroup = false

commFrame:RegisterEvent("PLAYER_LOGIN")

commFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        wasInGroup = (IsInGroup and IsInGroup()) or false
        Init()
    elseif event == "CHAT_MSG_ADDON" then
        onAddonMessage(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
        pingUnit("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        pingUnit("mouseover")
    elseif event == "GROUP_ROSTER_UPDATE" then
        local inGroup = IsInGroup and IsInGroup() or false
        if inGroup and not wasInGroup then
            C_Timer.After(2.0, function()
                if IsInRaid and IsInRaid() then
                    broadcastHello("RAID")
                else
                    broadcastHello("PARTY")
                end
            end)
        end
        wasInGroup = inGroup
    elseif event == "CHANNEL_UI_UPDATE" or event == "CHAT_MSG_CHANNEL_JOIN" then
        -- Re-join HCE channel and broadcast when channel list changes
        -- (e.g., zoning into a new area)
        C_Timer.After(3.0, function()
            joinHCEChannel()
            local msg = buildHelloMsg()
            if msg then sendOnHCEChannel(msg) end
        end)
    end
end)
