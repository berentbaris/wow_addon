----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Addon Communication
--
-- Lets HCE users discover each other in the game world.
--
-- Features:
--   1. Chat tag: A coloured [HCE] tag + class name is prepended to
--      chat messages from other HCE users (only visible to HCE users).
--
--   2. /hce nearby: Broadcasts a ping and lists all HCE users in range
--      with their enhanced class name.
--
-- How it works:
--   - Registers a hidden addon message prefix "HCE".
--   - On login, broadcasts your enhanced class to GUILD and CHANNEL
--     (hidden addon channel, invisible to non-addon users).
--   - When you encounter another player (target, mouseover, group),
--     a lightweight ping is exchanged.
--   - A cache maps player names to their enhanced class.
--   - ChatFrame_AddMessageEventFilter injects the tag into chat.
--
-- Protocol:
--   "HELLO:<className>"  — announce your class (response to PING too)
--   "PING"               — request a HELLO back
----------------------------------------------------------------------

HCE = HCE or {}

local Comm = {}
HCE.AddonComm = Comm

local PREFIX = "HCE"
local CACHE_TTL = 600  -- seconds before a cached entry expires

-- Public channels to scan for other HCE users
local PUBLIC_CHANNELS = {
    "General",
    "Trade",
    "LookingForGroup",
    "LocalDefense",
}

----------------------------------------------------------------------
-- Player cache: name-realm → { class = "Mountain King", time = GetTime() }
----------------------------------------------------------------------
local playerCache = {}

function Comm.GetPlayerClass(name)
    local entry = playerCache[name]
    if entry and (GetTime() - entry.time) < CACHE_TTL then
        return entry.class
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

function Comm.GetPlayerRank(name)
    local entry = playerCache[name]
    if entry and (GetTime() - entry.time) < CACHE_TTL then
        return entry.rank
    end
    return nil
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
-- Sending messages
----------------------------------------------------------------------
local function safeSend(msg, channel, target)
    local ok, err
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        ok, err = pcall(C_ChatInfo.SendAddonMessage, PREFIX, msg, channel, target)
    elseif SendAddonMessage then
        ok, err = pcall(SendAddonMessage, PREFIX, msg, channel, target)
    end
    if not ok and err then
        -- Silently swallow send errors so they don't break the caller
    end
end

local function broadcastHello(channel, target)
    local myClass = getMyClassName()
    if not myClass then return end
    local myRank = getMyRank()
    safeSend("HELLO:" .. myClass .. ":" .. myRank, channel, target)
end

local function sendPing(channel, target)
    safeSend("PING", channel, target)
end

----------------------------------------------------------------------
-- Receiving messages
----------------------------------------------------------------------
local function onAddonMessage(prefix, msg, channel, sender)
    if prefix ~= PREFIX then return end

    -- Strip realm from sender if present ("Name-Realm" → "Name")
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
        -- Also cache the short name for tooltip/chat matching
        cachePlayer(shortName, className, rank)
    elseif msg == "PING" then
        -- Respond with our class back to the sender.
        -- For CHANNEL and WHISPER, reply via WHISPER to avoid flooding.
        -- For GUILD/PARTY/RAID, broadcast so everyone benefits.
        if channel == "CHANNEL" or channel == "WHISPER" then
            local myClass = getMyClassName()
            if myClass then
                local myRank = getMyRank()
                safeSend("HELLO:" .. myClass .. ":" .. myRank, "WHISPER", sender)
            end
        else
            broadcastHello(channel)
        end
    end
end

----------------------------------------------------------------------
-- Chat tag injection
--
-- When we see a chat message from a cached HCE user, prepend a
-- coloured tag: |cffffd100[HCE]|r ClassName |cff888888·|r
-- Only visible to other HCE addon users.
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
    -- Strip realm for cache lookup
    local shortName = sender:match("^([^%-]+)") or sender
    local className = Comm.GetPlayerClass(sender) or Comm.GetPlayerClass(shortName)
    if not className then return false end

    local rank = Comm.GetPlayerRank(sender) or Comm.GetPlayerRank(shortName) or "Initiate"
    local col = RANK_COLORS[rank] or "ffffff"
    local rankPrefix = "|cff" .. col .. rank .. "|r "

    -- Prepend the HCE tag to the message
    local tag = "|cffffd100[" .. rankPrefix .. className .. "]|r "
    local newMsg = tag .. msg
    return false, newMsg, sender, ...
end

----------------------------------------------------------------------
-- /hce nearby — ping and list all HCE users in range
----------------------------------------------------------------------
local nearbyResults = {}
local nearbyTimer = nil

function Comm.StartNearbyScan()
    nearbyResults = {}
    HCE.Print("Scanning for HCE players...")

    -- Send ping to all available channels
    -- Note: addon messages only support PARTY/RAID/GUILD/OFFICER/WHISPER/CHANNEL.
    -- SAY/YELL are NOT valid for SendAddonMessage.
    if IsInGroup and IsInGroup() then
        sendPing("PARTY")
    end
    if IsInRaid and IsInRaid() then
        sendPing("RAID")
    end

    -- Guild: broadcast + whisper each online member for reliability.
    -- GUILD distribution can be unreliable in some Classic builds,
    -- so we also iterate the roster and whisper each online member.
    if IsInGuild and IsInGuild() then
        sendPing("GUILD")
        -- Whisper-ping online guild members individually
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

    -- Ping public channels (General, Trade, LFG, etc.)
    for _, ch in ipairs(PUBLIC_CHANNELS) do
        local id = GetChannelName(ch)
        if id and id > 0 then
            sendPing("CHANNEL", tostring(id))
        end
    end

    -- After 5 seconds, print results (gives time for channel responses)
    if nearbyTimer then nearbyTimer:Cancel() end
    nearbyTimer = C_Timer.NewTimer(5.0, function()
        Comm.PrintNearbyResults()
        nearbyTimer = nil
    end)
end

-- Collect incoming HELLOs during a nearby scan
local nearbyScanning = false

function Comm.PrintNearbyResults()
    -- Gather all recently cached players (within the scan window)
    local found = {}
    local now = GetTime()
    for name, entry in pairs(playerCache) do
        -- Only include entries from the last 5 seconds (scan window)
        -- and skip short-name duplicates (keep "Name-Realm" version)
        if (now - entry.time) < 6 and not name:find("%-") then
            -- Skip if we also have the full name version
            local skip = false
            for fullName, _ in pairs(playerCache) do
                if fullName:find("%-") and fullName:match("^([^%-]+)") == name then
                    skip = true
                    break
                end
            end
            if not skip then
                table.insert(found, { name = name, class = entry.class })
            end
        end
    end
    -- Also grab full-name entries
    for name, entry in pairs(playerCache) do
        if (now - entry.time) < 6 and name:find("%-") then
            local short = name:match("^([^%-]+)") or name
            table.insert(found, { name = short, class = entry.class })
        end
    end

    if #found == 0 then
        HCE.Print("No other HCE players found.")
    else
        HCE.Print("|cffffd100" .. #found .. " HCE player(s) found:|r")
        for _, p in ipairs(found) do
            HCE.Print("  |cffffffff" .. p.name .. "|r — |cffe0c040" .. p.class .. "|r")
        end
    end
end

----------------------------------------------------------------------
-- Target/mouseover pinging
--
-- When we target or mouseover a player, send a whisper-channel ping.
-- If they have HCE, they'll respond with their class.
----------------------------------------------------------------------
local lastPinged = {}

local function pingUnit(unit)
    if not UnitIsPlayer(unit) then return end
    if not UnitIsConnected(unit) then return end
    -- Don't ping enemies (cross-faction addon messages don't work)
    if UnitIsEnemy("player", unit) then return end

    local name, realm = UnitName(unit)
    if not name then return end
    local myName = UnitName("player")
    if name == myName then return end

    local fullName = realm and realm ~= "" and (name .. "-" .. realm) or name

    -- Don't spam-ping the same person
    local now = GetTime()
    if lastPinged[fullName] and (now - lastPinged[fullName]) < 30 then return end
    lastPinged[fullName] = now

    -- Send a whisper-channel ping (only the addon sees it)
    safeSend("PING", "WHISPER", fullName)
end

----------------------------------------------------------------------
-- Public channel broadcasting
--
-- SendAddonMessage supports "CHANNEL" distribution with a channel
-- index number.  We look up General, Trade, LookingForGroup etc.
-- and broadcast/ping on them so any HCE user in those channels
-- discovers us automatically.
----------------------------------------------------------------------

--- Send an addon message to a named public channel (if joined).
local function sendToPublicChannel(msg, channelName)
    local id = GetChannelName(channelName)
    if id and id > 0 then
        safeSend(msg, "CHANNEL", tostring(id))
    end
end

--- Broadcast HELLO on all available channels (guild, party, public).
local function broadcastAll()
    local myClass = getMyClassName()
    if not myClass then return end

    -- Guild
    if IsInGuild and IsInGuild() then
        broadcastHello("GUILD")
    end
    -- Party / raid
    if IsInRaid and IsInRaid() then
        broadcastHello("RAID")
    elseif IsInGroup and IsInGroup() then
        broadcastHello("PARTY")
    end
    -- Public channels (General, Trade, LFG, etc.)
    local myRank = getMyRank()
    for _, ch in ipairs(PUBLIC_CHANNELS) do
        sendToPublicChannel("HELLO:" .. myClass .. ":" .. myRank, ch)
    end
end

----------------------------------------------------------------------
-- Periodic heartbeat
--
-- Every 5 minutes, re-broadcast on all channels so newly logged-in
-- HCE users discover us, and we discover them.
----------------------------------------------------------------------
local HEARTBEAT_INTERVAL = 300  -- seconds (5 minutes)

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
    -- Register the addon message prefix (required before send/receive works)
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

    -- Register for target/mouseover changes to ping players
    commFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    commFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

    -- Detect joining groups / channels to broadcast immediately
    commFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    commFrame:RegisterEvent("CHANNEL_UI_UPDATE")
    commFrame:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")

    -- Register chat filters for tag injection
    for _, event in ipairs(TAGGED_CHANNELS) do
        ChatFrame_AddMessageEventFilter(event, chatFilter)
    end

    -- Initial broadcast (delayed to let channels finish joining)
    C_Timer.After(8.0, function()
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
        -- Broadcast when joining a group
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
        -- Re-broadcast on public channels when channel list changes
        -- (e.g., zoning into a new area with different General channel)
        C_Timer.After(3.0, function()
            local myClass = getMyClassName()
            if myClass then
                local myRank = getMyRank()
                for _, ch in ipairs(PUBLIC_CHANNELS) do
                    sendToPublicChannel("HELLO:" .. myClass .. ":" .. myRank, ch)
                end
            end
        end)
    end
end)
