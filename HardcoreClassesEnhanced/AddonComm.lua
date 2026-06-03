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

local function cachePlayer(name, className)
    if not name or name == "" or not className or className == "" then return end
    playerCache[name] = { class = className, time = GetTime() }
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
-- Sending messages
----------------------------------------------------------------------
local function safeSend(msg, channel, target)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, channel, target)
    elseif SendAddonMessage then
        SendAddonMessage(PREFIX, msg, channel, target)
    end
end

local function broadcastHello(channel, target)
    local myClass = getMyClassName()
    if not myClass then return end
    safeSend("HELLO:" .. myClass, channel, target)
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
        local className = msg:sub(7)
        cachePlayer(sender, className)
        -- Also cache the short name for tooltip/chat matching
        cachePlayer(shortName, className)
    elseif msg == "PING" then
        -- Respond with our class
        broadcastHello(channel)
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

local function chatFilter(self, event, msg, sender, ...)
    -- Strip realm for cache lookup
    local shortName = sender:match("^([^%-]+)") or sender
    local className = Comm.GetPlayerClass(sender) or Comm.GetPlayerClass(shortName)
    if not className then return false end

    -- Prepend the HCE tag to the message
    local tag = "|cffffd100[" .. className .. "]|r "
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
    HCE.Print("Scanning for nearby HCE players...")

    -- Send ping to all available channels
    sendPing("YELL")
    if IsInGroup and IsInGroup() then
        sendPing("PARTY")
    end
    if IsInRaid and IsInRaid() then
        sendPing("RAID")
    end
    if IsInGuild and IsInGuild() then
        sendPing("GUILD")
    end
    -- Also check the cache for players we already know about
    -- who might be nearby (targeted, moused over, etc.)

    -- After 3 seconds, print results
    if nearbyTimer then nearbyTimer:Cancel() end
    nearbyTimer = C_Timer.NewTimer(3.0, function()
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
        if (now - entry.time) < 5 and not name:find("%-") then
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
        if (now - entry.time) < 5 and name:find("%-") then
            local short = name:match("^([^%-]+)") or name
            table.insert(found, { name = short, class = entry.class })
        end
    end

    if #found == 0 then
        HCE.Print("No other HCE players found nearby.")
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
-- Initialisation
----------------------------------------------------------------------
local commFrame = CreateFrame("Frame", "HCE_AddonCommFrame", UIParent)

local function Init()
    -- Register the addon message prefix
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
    end

    -- Register for addon messages
    commFrame:RegisterEvent("CHAT_MSG_ADDON")

    -- Register for target/mouseover changes to ping players
    commFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    commFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

    -- Register chat filters for tag injection
    for _, event in ipairs(TAGGED_CHANNELS) do
        ChatFrame_AddMessageEventFilter(event, chatFilter)
    end

    -- Broadcast our class on login (delayed to let everything load)
    C_Timer.After(5.0, function()
        if IsInGuild and IsInGuild() then
            broadcastHello("GUILD")
        end
        if IsInGroup and IsInGroup() then
            broadcastHello("PARTY")
        end
        -- YELL channel for nearby discovery
        broadcastHello("YELL")
    end)
end

commFrame:RegisterEvent("PLAYER_LOGIN")

commFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        Init()
    elseif event == "CHAT_MSG_ADDON" then
        onAddonMessage(...)
    elseif event == "PLAYER_TARGET_CHANGED" then
        pingUnit("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        pingUnit("mouseover")
    end
end)
