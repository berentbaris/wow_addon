local _, SM = ...

local function EncodeStoryLinkID(storyID)
    storyID = tostring(storyID or "")
    return storyID:gsub(".", function(char)
        return string.format("%02x", char:byte())
    end)
end

local function DecodeStoryLinkID(encoded)
    if not encoded or encoded == "" or encoded:find("[^0-9a-fA-F]") then return nil end
    return encoded:gsub("..", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

function SM.GetStoryChatLink(data)
    if not data or not data.id or not data.title then return nil end
    local senderGUID = UnitGUID and UnitGUID("player") or "0"
    return "|Hstorymode:" .. EncodeStoryLinkID(data.id) .. ":" .. senderGUID .. "|h|cff66d9ef[Story Mode: " .. data.title .. "]|r|h"
end

function SM.GetStoryShareText(data)
    if not data or not data.title then return nil end
    return "[Story Mode: " .. data.title .. "]"
end

function SM.InsertStoryChatLink(data)
    local shareText = SM.GetStoryShareText(data)
    if not shareText then return false end

    if ChatFrame1EditBox and not ChatFrame1EditBox:IsVisible() and ChatFrame_OpenChat then
        ChatFrame_OpenChat(shareText)
        return true
    end

    if ChatEdit_InsertLink and ChatEdit_InsertLink(shareText) then
        return true
    end

    return false
end

local function NormalizeShareTitle(title)
    title = type(title) == "string" and title or ""
    title = title:match("^%s*(.-)%s*$")
    return title:lower()
end

local function FindStoryByTitle(title)
    if not title or title == "" then return nil end
    local target = NormalizeShareTitle(title)
    for _, data in ipairs(SM.GetAllQuestlines()) do
        if NormalizeShareTitle(data.title) == target or NormalizeShareTitle(data._originalTitle) == target then
            return data
        end
    end
    if target == "lost in battle" then
        return SM.GetQuestlineByID("lost-in-battle")
    end
    return nil
end

function SM.LinkifyStoryShares(message)
    if type(message) ~= "string" or not message:find("%[Story Mode: ") then return false, message end
    if message:find("|Hstorymode:", 1, true) then return false, message end

    local changed = false
    message = message:gsub("%[Story Mode: ([^%]]+)%]", function(title)
        local data = FindStoryByTitle(title)
        local link = data and SM.GetStoryChatLink(data)
        if link then
            changed = true
            return link
        end
        return "[Story Mode: " .. title .. "]"
    end)

    return changed, message
end

-- Scarlet ledger countersign. The wire format is deliberately fixed English:
-- to anyone without the addon (or without the reveal) it stays plain text;
-- only another revealed Scarlet Crusader's client turns it into a link.
local SCARLET_SHARE_PREFIX = "[Story Mode: A Private War — "
local SCARLET_SHARE_PATTERN = "%[Story Mode: A Private War — (%d+)%]"

function SM.GetScarletLedgerShareText()
    if not (SM.IsScarletCrusaderRevealed and SM.IsScarletCrusaderRevealed()) then return nil end
    local count = SM.GetScarletKillCount and SM.GetScarletKillCount() or 0
    return SCARLET_SHARE_PREFIX .. count .. "]"
end

function SM.InsertScarletLedgerChatLink()
    local shareText = SM.GetScarletLedgerShareText()
    if not shareText then return false end

    -- An already-active edit box takes the text directly.
    if ChatEdit_InsertLink and ChatEdit_InsertLink(shareText) then
        return true
    end

    -- Otherwise activate one: "visible but inactive" edit boxes (IM-style
    -- chat, classic clients) make the IsVisible check unreliable, so
    -- activate-and-insert explicitly before falling back to OpenChat.
    if ChatEdit_ChooseBoxForSend and ChatEdit_ActivateChat then
        local editBox = ChatEdit_ChooseBoxForSend()
        if editBox then
            ChatEdit_ActivateChat(editBox)
            editBox:Insert(shareText)
            return true
        end
    end

    if ChatFrame_OpenChat then
        ChatFrame_OpenChat(shareText)
        return true
    end

    return false
end

function SM.LinkifyScarletShares(message)
    if type(message) ~= "string" or not message:find("%[Story Mode: A Private War") then return false, message end
    if not (SM.IsScarletCrusaderRevealed and SM.IsScarletCrusaderRevealed()) then return false, message end
    -- Both the CHAT_MSG filter and the AddMessage wrapper run this; a second
    -- pass over already-linkified text must not nest another |H...|h layer.
    if message:find("|Hstorymodescarlet:", 1, true) then return false, message end

    local changed = false
    message = message:gsub(SCARLET_SHARE_PATTERN, function(count)
        changed = true
        return "|Hstorymodescarlet:" .. count .. "|h|cffe62929" .. SCARLET_SHARE_PREFIX .. count .. "]|r|h"
    end)

    return changed, message
end

function SM.GetScarletTabChatLink()
    return "|Hstorymodescarlettab:0|h|cffe62929[" .. (SM.L["Tab Scarlet Crusader"] or "The Scarlet Crusader") .. "]|r|h"
end

function SM.OpenScarletTabLink()
    if not (SM.IsScarletCrusaderRevealed and SM.IsScarletCrusaderRevealed()) then return false end
    if not (SM.GetQuestlineByID and SM.GetQuestlineByID("the-scarlet-crusade")) then return false end
    return SM.OpenStoryModeToSelection and SM.OpenStoryModeToSelection("the-scarlet-crusade", 1, "scarlet") or false
end

function SM.OpenScarletLedgerLink(theirCount)
    theirCount = tonumber(theirCount)
    if not theirCount then return false end
    if not (SM.IsScarletCrusaderRevealed and SM.IsScarletCrusaderRevealed()) then return false end
    -- Navigating to an unregistered story would strand activeTab on a tab
    -- that doesn't exist; bail before OpenStoryModeToSelection mutates state.
    if not (SM.GetQuestlineByID and SM.GetQuestlineByID("the-scarlet-crusade")) then return false end
    if not (SM.OpenStoryModeToSelection and SM.OpenStoryModeToSelection("the-scarlet-crusade", 1, "scarlet")) then
        return false
    end
    local myCount = SM.GetScarletKillCount and SM.GetScarletKillCount() or 0
    print(SM.L["Addon Prefix"] .. string.format(SM.L["Scarlet Link Compare Format"], theirCount, myCount))
    return true
end

local function GetQuestShareText(questID, questName)
    if not questID then return nil end
    questName = questName or (QuestUtils_GetQuestName and QuestUtils_GetQuestName(questID))
    if not questName or questName == "" then return nil end
    return "[" .. questName .. " (" .. questID .. ")]"
end

function SM.InsertQuestChatLink(questEntry, questID, questName)
    local shareText = GetQuestShareText(questID, questName)
    if not shareText then return false end

    if ChatFrame1EditBox and not ChatFrame1EditBox:IsVisible() and ChatFrame_OpenChat then
        ChatFrame_OpenChat(shareText)
        return true
    end

    if ChatEdit_InsertLink and ChatEdit_InsertLink(shareText) then
        return true
    end

    return false
end

function SM.LinkifyQuestShares(message)
    if type(message) ~= "string" or not message:find("%(%d+%)") then return false, message end
    if message:find("|Hstorymodequest:", 1, true) then return false, message end

    local changed = false
    message = message:gsub("%[([^%[%]]-) %((%d+)%)%]", function(questName, questIDText)
        local questID = tonumber(questIDText)
        local data = questID and SM.FindQuestStory(questID)
        local link = data and SM.GetQuestChatLink(questID, questName, "ffff00")
        if link then
            changed = true
            return link
        end
        return "[" .. questName .. " (" .. questIDText .. ")]"
    end)

    return changed, message
end

function SM.OpenStoryLink(encodedStoryID)
    local storyID = DecodeStoryLinkID(encodedStoryID) or encodedStoryID
    local data = SM.GetQuestlineByID(storyID)
    if not data then return false end

    if SM.OpenStoryModeToSelection then
        return SM.OpenStoryModeToSelection(storyID, StoryModeDB.selectedChapter or 1, "story")
    end

    StoryModeDB.selectedQuestlineID = storyID
    StoryModeDB.selectedChapter = StoryModeDB.selectedChapter or 1
    if SM.SetActiveTab then SM.SetActiveTab("story") end
    if SM.ShowStoryModeFrame then SM.ShowStoryModeFrame() end
    return true
end

function SM.OpenQuestLink(questID)
    questID = tonumber(questID)
    if not questID then return false end

    local data, _, chapter = SM.FindQuestStory(questID)
    if not data then return false end

    local chapterIndex = chapter and chapter._chapterIndex or 1
    return SM.OpenStoryModeToSelection(data.id, chapterIndex, "progress")
end

local function DispatchItemRef(link)
    local encodedStoryID = link and link:match("^storymode:(%x+):")
    if encodedStoryID and SM.OpenStoryLink and SM.OpenStoryLink(encodedStoryID) then
        return true
    end

    local questID = link and link:match("^storymodequest:(%d+):")
    if questID and SM.OpenQuestLink and SM.OpenQuestLink(questID) then
        return true
    end

    if link and link:match("^storymodescarlettab:") then
        return SM.OpenScarletTabLink and SM.OpenScarletTabLink() or false
    end

    local scarletCount = link and link:match("^storymodescarlet:(%d+)")
    if scarletCount and SM.OpenScarletLedgerLink and SM.OpenScarletLedgerLink(scarletCount) then
        return true
    end

    return false
end

if not SM.shareLinkItemRefInstalled and SetItemRef then
    local OriginalSetItemRef = SetItemRef
    SetItemRef = function(link, text, button, chatFrame)
        if DispatchItemRef(link) then
            return
        end
        return OriginalSetItemRef(link, text, button, chatFrame)
    end
    SM.shareLinkItemRefInstalled = true
end

local SHARE_EVENTS = {
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN", "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE",
}

function SM.StoryModeShareMessageFilter(_, _, message, ...)
    local changed = false
    local scarletChanged, storyChanged, questChanged

    -- Scarlet first: its bracket text also matches the generic story pattern.
    scarletChanged, message = SM.LinkifyScarletShares(message)
    changed = changed or scarletChanged
    storyChanged, message = SM.LinkifyStoryShares(message)
    changed = changed or storyChanged
    questChanged, message = SM.LinkifyQuestShares(message)
    changed = changed or questChanged

    if changed then
        return false, message, ...
    end
    return false, message, ...
end

function SM.RegisterStoryModeShareFilters()
    if SM.shareMessageFiltersRegistered then return end
    local addFilter = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter
    if not addFilter then return end

    for _, event in ipairs(SHARE_EVENTS) do
        addFilter(event, SM.StoryModeShareMessageFilter)
    end
    SM.shareMessageFiltersRegistered = true
end

local function LinkifyShareMessage(message)
    local changed = false
    local scarletChanged, storyChanged, questChanged

    scarletChanged, message = SM.LinkifyScarletShares(message)
    changed = changed or scarletChanged
    storyChanged, message = SM.LinkifyStoryShares(message)
    changed = changed or storyChanged
    questChanged, message = SM.LinkifyQuestShares(message)
    changed = changed or questChanged

    return changed, message
end

local function WrapChatFrameAddMessage(chatFrame)
    if not chatFrame or chatFrame._storyModeShareWrapped or not chatFrame.AddMessage then return end

    local originalAddMessage = chatFrame.AddMessage
    chatFrame.AddMessage = function(self, message, ...)
        local originalMessage = message
        local changed
        changed, message = LinkifyShareMessage(message)
        if message == nil then message = originalMessage end
        return originalAddMessage(self, message, ...)
    end
    chatFrame._storyModeShareWrapped = true
end

function SM.RegisterShareDisplayHooks()
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        WrapChatFrameAddMessage(_G["ChatFrame" .. i])
    end
end

SM.RegisterStoryModeShareFilters()
if not SM.shareDisplayHooksRegistered then
    SM.RegisterShareDisplayHooks()
    SM.shareDisplayHooksRegistered = true
end
