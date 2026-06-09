----------------------------------------------------------------------
-- HardcoreClassesEnhanced  —  Addon Communication  (v4)
--
-- Modelled after AutoLayer_Vanilla's proven pattern:
--   - Hidden custom channel "hce"
--   - Messages queued, sent only on hardware events (mouse/key)
--     because SendChatMessage is protected in Classic 1.15.x
--   - ChatFrame_RemoveChannel hides protocol traffic
----------------------------------------------------------------------

HCE = HCE or {}

local Comm = {}
HCE.AddonComm = Comm

local CHANNEL_NAME = "hce"
local PROTO_TAG    = "HCE:"
local CACHE_TTL    = 240        -- 4 min; generous AFK window since sends need hardware events

----------------------------------------------------------------------
-- Debug
----------------------------------------------------------------------
local debugMode = false

function Comm.ToggleDebug()
    debugMode = not debugMode
    HCE.Print(debugMode and "|cff00ff00AddonComm debug ON|r" or "|cffff6060AddonComm debug OFF|r")
end

local function dbg(msg)
    if debugMode and HCE.Print then
        HCE.Print("|cff888888[dbg] " .. msg .. "|r")
    end
end

----------------------------------------------------------------------
-- Rank colours
----------------------------------------------------------------------
local RANK_COLORS = {
    ["Master"]   = "ff8000",
    ["Elite"]    = "a335ee",
    ["Prime"]    = "0070dd",
    ["Adept"]    = "1eff00",
    ["Initiate"] = "ffffff",
}

----------------------------------------------------------------------
-- Player cache
----------------------------------------------------------------------
local playerCache = {}

function Comm.GetPlayerClass(name)
    local e = playerCache[name]
    if e and (GetTime() - e.time) < CACHE_TTL then return e.class end
    return nil
end

function Comm.GetPlayerRank(name)
    local e = playerCache[name]
    if e and (GetTime() - e.time) < CACHE_TTL then return e.rank end
    return nil
end

local function cachePlayer(name, className, rank)
    if not name or name == "" or not className or className == "" then return end
    local short = name:match("^([^%-]+)") or name

    local isNew = true
    for k, v in pairs(playerCache) do
        local ks = k:match("^([^%-]+)") or k
        if ks == short and (GetTime() - v.time) < CACHE_TTL then
            isNew = false
            break
        end
    end

    playerCache[name] = { class = className, rank = rank or "Initiate", time = GetTime() }
    dbg("Cached: " .. short .. " = " .. className .. " (" .. (rank or "Initiate") .. ")" .. (isNew and " NEW" or ""))

    if isNew and HCE.Print then
        local col = RANK_COLORS[rank] or "ffffff"
        HCE.Print("|cff4de64dHCE player spotted:|r |cffffffff" .. short .. "|r \226\128\148 |cff" .. col .. (rank or "Initiate") .. "|r |cffe0c040" .. className .. "|r")
    end
end

----------------------------------------------------------------------
-- Own identity
----------------------------------------------------------------------
local function getMyClassName()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then return nil end
    local char = HCE.GetCharacter and HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char then return nil end
    return HCE.GetCharDisplayName and HCE.GetCharDisplayName(char) or char.name
end

local function getMyRank()
    if not HCE.Progress or not HCE.Progress.Collect
       or not HCE.Progress.Percentage or not HCE.Progress.GetRank then
        return "Initiate"
    end
    local s = HCE.Progress.Collect()
    if not s or not s.counts then return "Initiate" end
    return HCE.Progress.GetRank(HCE.Progress.Percentage(s.counts))
end

----------------------------------------------------------------------
-- Channel management  (mirrors AutoLayer)
----------------------------------------------------------------------
local function joinHCE()
    JoinChannelByName(CHANNEL_NAME)
    local id = GetChannelName(CHANNEL_NAME)
    if id and id > 0 then
        for i = 1, 10 do
            local cf = _G["ChatFrame" .. i]
            if cf then ChatFrame_RemoveChannel(cf, CHANNEL_NAME) end
        end
        dbg("Joined channel #" .. id)
        return true
    end
    dbg("Join failed")
    return false
end

----------------------------------------------------------------------
-- Send queue  (AutoLayer pattern)
--
-- SendChatMessage is protected in Classic 1.15.x — it can only be
-- called from a hardware-event execution path (mouse click, key
-- press).  We queue outgoing messages and drain the queue on
-- WorldFrame:OnMouseDown and a keyboard hook, exactly like AutoLayer.
----------------------------------------------------------------------
local sendQueue = {}

local function queueMsg(text)
    sendQueue[#sendQueue + 1] = text
    dbg("queued: " .. text .. " (queue=" .. #sendQueue .. ")")
end

local function drainQueue()
    if #sendQueue == 0 then return end

    local id = GetChannelName(CHANNEL_NAME)
    if not id or id == 0 then
        joinHCE()
        id = GetChannelName(CHANNEL_NAME)
        if not id or id == 0 then return end
    end

    -- Send ONE message per hardware event to avoid throttle
    local text = table.remove(sendQueue, 1)
    dbg("drain #" .. id .. ": " .. text)
    SendChatMessage(text, "CHANNEL", nil, id)
end

----------------------------------------------------------------------
-- Protocol helpers
----------------------------------------------------------------------
local function helloText()
    local c = getMyClassName()
    if not c then return nil end
    return PROTO_TAG .. "HELLO:" .. c .. ":" .. getMyRank()
end

local function queueHello()
    local h = helloText()
    if h then queueMsg(h) end
end

local function queuePing()
    queueMsg(PROTO_TAG .. "PING")
end

----------------------------------------------------------------------
-- Receive  (CHAT_MSG_CHANNEL handler)
----------------------------------------------------------------------
local function onChannelMsg(msg, sender, channelName)
    if not channelName or channelName:lower() ~= CHANNEL_NAME then return end
    if not msg or msg:sub(1, #PROTO_TAG) ~= PROTO_TAG then return end

    local short = sender:match("^([^%-]+)") or sender
    if short == UnitName("player") then return end

    local payload = msg:sub(#PROTO_TAG + 1)
    dbg("recv from " .. short .. ": " .. payload)

    if payload:sub(1, 6) == "HELLO:" then
        local rest = payload:sub(7)
        local className, rank = rest:match("^(.+):(.+)$")
        if not className then className = rest; rank = "Initiate" end
        cachePlayer(sender, className, rank)
        cachePlayer(short, className, rank)
    elseif payload == "PING" then
        queueHello()
    end
end

----------------------------------------------------------------------
-- Chat tag injection  (SAY / YELL / PARTY / GUILD / WHISPER only)
----------------------------------------------------------------------
local TAG_EVENTS = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_WHISPER",
}

local function chatTagFilter(self, event, msg, sender, ...)
    if not msg or not sender then return false end
    local short = sender:match("^([^%-]+)") or sender
    local cls = Comm.GetPlayerClass(sender) or Comm.GetPlayerClass(short)
    if not cls then return false end
    local rank = Comm.GetPlayerRank(sender) or Comm.GetPlayerRank(short) or "Initiate"
    local col = RANK_COLORS[rank] or "ffffff"
    local tag = "|cffffd100[|cff" .. col .. rank .. "|r " .. cls .. "]|r "
    return false, tag .. msg, sender, ...
end

----------------------------------------------------------------------
-- Scan popup frame  (shown when clicking the magnifying glass)
----------------------------------------------------------------------
local scanFrame = nil
local ROW_H = 18

local function getOnlinePlayers()
    local found, seen = {}, {}
    local now = GetTime()
    for name, e in pairs(playerCache) do
        if (now - e.time) < CACHE_TTL then
            local s = name:match("^([^%-]+)") or name
            if not seen[s] then
                seen[s] = true
                found[#found+1] = { name = s, class = e.class, rank = e.rank }
            end
        end
    end
    table.sort(found, function(a, b) return a.name < b.name end)
    return found
end

local function createScanFrame()
    local f = CreateFrame("Frame", "HCE_ScanFrame", UIParent, "BackdropTemplate")
    f:SetSize(260, 200)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets   = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    f:SetBackdropColor(0.08, 0.08, 0.10, 0.92)
    f:SetBackdropBorderColor(0.60, 0.50, 0.15, 1)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -10)
    title:SetText("|cffffd100HCE Players Online|r")
    f._title = title

    -- Close button
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetSize(20, 20)
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    close:SetScript("OnClick", function() f:Hide() end)

    -- Scroll area
    local scroll = CreateFrame("ScrollFrame", "HCE_ScanScroll", f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -30)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, 10)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    f._content = content
    f._rows = {}

    return f
end

local function acquireScanRow(index)
    local rows = scanFrame._rows
    if rows[index] then
        rows[index]:Show()
        return rows[index]
    end
    local parent = scanFrame._content
    local r = CreateFrame("Button", nil, parent)
    r:SetHeight(ROW_H)
    r:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * ROW_H)
    r:SetPoint("RIGHT", parent, "RIGHT", 0, 0)

    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.name:SetPoint("LEFT", r, "LEFT", 4, 0)
    r.name:SetWidth(90)
    r.name:SetJustifyH("LEFT")

    r.rank = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.rank:SetPoint("LEFT", r.name, "RIGHT", 4, 0)
    r.rank:SetWidth(60)
    r.rank:SetJustifyH("LEFT")

    r.class = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.class:SetPoint("LEFT", r.rank, "RIGHT", 4, 0)
    r.class:SetPoint("RIGHT", r, "RIGHT", -4, 0)
    r.class:SetJustifyH("LEFT")

    -- Whisper on click
    r:SetScript("OnClick", function(self)
        if self._playerName then
            ChatFrame_OpenChat("/w " .. self._playerName .. " ", ChatFrame1)
        end
    end)
    r:SetScript("OnEnter", function(self)
        self.name:SetTextColor(1, 1, 0.4)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Click to whisper " .. (self._playerName or ""))
        GameTooltip:Show()
    end)
    r:SetScript("OnLeave", function(self)
        self.name:SetTextColor(1, 1, 1)
        GameTooltip:Hide()
    end)

    rows[index] = r
    return r
end

local function refreshScanFrame()
    if not scanFrame then scanFrame = createScanFrame() end
    local players = getOnlinePlayers()
    local content = scanFrame._content

    -- Hide old rows
    for _, r in pairs(scanFrame._rows) do r:Hide() end

    if #players == 0 then
        scanFrame._title:SetText("|cffffd100No HCE Players Detected|r")
        content:SetHeight(ROW_H)
        local r = acquireScanRow(1)
        r.name:SetText("Players are discovered automatically.")
        r.name:SetTextColor(0.6, 0.6, 0.6)
        r.name:SetWidth(220)
        r.rank:SetText("")
        r.class:SetText("")
        r._playerName = nil
        r:Disable()
    else
        scanFrame._title:SetText("|cffffd100" .. #players .. " HCE Player(s) Online|r")
        for i, p in ipairs(players) do
            local r = acquireScanRow(i)
            r.name:SetText(p.name)
            r.name:SetTextColor(1, 1, 1)
            r.name:SetWidth(90)
            local col = RANK_COLORS[p.rank] or "ffffff"
            r.rank:SetText("|cff" .. col .. (p.rank or "Initiate") .. "|r")
            r.class:SetText("|cffe0c040" .. p.class .. "|r")
            r._playerName = p.name
            r:Enable()
        end
        content:SetHeight(#players * ROW_H)
    end

    -- Resize frame to fit content (min 80, max 300)
    local h = math.max(80, math.min(300, (#players * ROW_H) + 50))
    scanFrame:SetHeight(h)
    scanFrame:Show()
end

----------------------------------------------------------------------
-- /hce scan  (public API)
----------------------------------------------------------------------
function Comm.StartNearbyScan()
    -- Show the popup
    refreshScanFrame()
    -- Queue a fresh ping so new players will reply for next time
    queuePing()
end

----------------------------------------------------------------------
-- /hce status
----------------------------------------------------------------------
function Comm.PrintStatus()
    local id = GetChannelName(CHANNEL_NAME) or 0
    HCE.Print("|cffffd100HCE AddonComm Status:|r")
    HCE.Print("  Channel: " .. CHANNEL_NAME .. " #" .. tostring(id))
    HCE.Print("  My class: " .. tostring(getMyClassName() or "NONE"))
    HCE.Print("  My rank: " .. tostring(getMyRank()))
    HCE.Print("  Debug: " .. (debugMode and "ON" or "OFF"))
    HCE.Print("  Queue: " .. #sendQueue .. " pending")
    local count = 0
    local now = GetTime()
    for _, e in pairs(playerCache) do
        if (now - e.time) < CACHE_TTL then count = count + 1 end
    end
    HCE.Print("  Cached players: " .. count)
    local cl = { GetChannelList() }
    if #cl > 0 then
        HCE.Print("  Channels:")
        local i = 1
        while i <= #cl do
            HCE.Print("    #" .. tostring(cl[i]) .. " " .. tostring(cl[i+1]))
            i = i + 3
        end
    end
end

----------------------------------------------------------------------
-- Periodic heartbeat
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Init
----------------------------------------------------------------------
local frame = CreateFrame("Frame", "HCE_CommFrame", UIParent)

local function Init()
    dbg("Init()")

    -- Chat tag filters (NOT on CHAT_MSG_CHANNEL)
    for _, ev in ipairs(TAG_EVENTS) do
        ChatFrame_AddMessageEventFilter(ev, chatTagFilter)
    end

    -- Join channel with retries
    local attempts = 0
    local function tryJoin()
        attempts = attempts + 1
        if joinHCE() then
            dbg("Channel OK on attempt " .. attempts)
        elseif attempts < 6 then
            C_Timer.After(5.0, tryJoin)
        end
    end
    C_Timer.After(3.0, tryJoin)

    -- Queue initial broadcast after channel settles
    C_Timer.After(10.0, queueHello)

    -- Heartbeat every 30 sec (no auto-print; use scan button to see players)
    C_Timer.NewTicker(30, function()
        queueHello()
    end)

    -- HARDWARE EVENT HOOKS (the AutoLayer secret sauce)
    -- SendChatMessage is protected; it can only run inside a
    -- hardware-event callstack.  We drain the queue on every
    -- mouse click / key press, exactly like AutoLayer does.
    C_Timer.After(1.0, function()
        WorldFrame:HookScript("OnMouseDown", function()
            drainQueue()
        end)
    end)

    local keyFrame = CreateFrame("Frame", "HCE_KeyDrain", UIParent)
    keyFrame:SetScript("OnKeyDown", function()
        drainQueue()
    end)
    keyFrame:SetPropagateKeyboardInput(true)
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("CHAT_MSG_CHANNEL")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        Init()
    elseif event == "CHAT_MSG_CHANNEL" then
        local msg, sender, _, _, _, _, _, _, channelName = ...
        onChannelMsg(msg, sender, channelName)
    end
end)
