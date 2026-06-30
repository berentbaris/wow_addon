-- Language IDs from the client (see GetLanguageByIndex); map is keyed by RaceId / race file token.

local function nativeLanguageOptionEnabled()
  if RaceLocked_Options_GetNativeLanguageOnly then
    return RaceLocked_Options_GetNativeLanguageOnly()
  end
  return true
end

local RACE_ID_TO_LANGUAGE_ID = {
  [1] = 7, -- Human → Common
  [2] = 1, -- Orc → Orcish
  [3] = 6, -- Dwarf → Dwarvish
  [4] = 2, -- Night Elf → Darnassian
  [5] = 33, -- Undead → Forsaken
  [6] = 3, -- Tauren → Taurahe
  [7] = 13, -- Gnome → Gnomish
  [8] = 14, -- Troll → Zandali
}

local RACE_FILE_TO_LANGUAGE_ID = {
  Human = 7,
  Orc = 1,
  Dwarf = 6,
  NightElf = 2,
  Scourge = 33,
  Tauren = 3,
  Gnome = 13,
  Troll = 14,
}

local applyingRaceLanguage = false
local languageHooksInstalled = false
local pollAccum = 0
local pendingDeferredEnforce = false

local function getRaceNativeLanguageId()
  local _, raceFile, raceId = UnitRace('player')
  if not raceFile and not raceId then
    return nil
  end
  return (raceId and RACE_ID_TO_LANGUAGE_ID[raceId]) or (raceFile and RACE_FILE_TO_LANGUAGE_ID[raceFile])
end

local function findKnownLanguageNameAndId(targetLanguageId)
  if not targetLanguageId or not GetNumLanguages or not GetLanguageByIndex then
    return nil, nil
  end
  for i = 1, GetNumLanguages() do
    local languageName, languageId = GetLanguageByIndex(i)
    if languageId == targetLanguageId then
      return languageName, languageId
    end
  end
  return nil, nil
end

local function applyToAllChatEditBoxes(languageName, languageId)
  if not languageName or not languageId or not NUM_CHAT_WINDOWS then return end
  for i = 1, NUM_CHAT_WINDOWS do
    local editBox = _G['ChatFrame' .. i .. 'EditBox']
    if editBox then
      editBox.language = languageName
      editBox.languageID = languageId
    end
  end
end

local function EnforceRaceLanguage()
  if applyingRaceLanguage then return end
  if not nativeLanguageOptionEnabled() then return end
  local wantedId = getRaceNativeLanguageId()
  if not wantedId then return end

  local languageName, languageId = findKnownLanguageNameAndId(wantedId)
  if not languageName or not languageId then return end

  applyingRaceLanguage = true
  applyToAllChatEditBoxes(languageName, languageId)
  applyingRaceLanguage = false
end

local function scheduleEnforceRaceLanguage()
  if C_Timer and C_Timer.After then
    C_Timer.After(0, EnforceRaceLanguage)
  else
    -- No C_Timer: same frame runs `pollChatLanguageMismatch`; flush on next tick.
    pendingDeferredEnforce = true
  end
end

local function registerLanguageLockedHooks()
  if languageHooksInstalled or type(hooksecurefunc) ~= 'function' then return end
  local function afterLanguageChange()
    if nativeLanguageOptionEnabled() then
      scheduleEnforceRaceLanguage()
    end
  end
  local hookedAny = false
  for _, fname in
    ipairs({ 'ChatEdit_OnLanguageChanged', 'ChatFrame_ChatEdit_OnLanguageChanged' })
  do
    if type(_G[fname]) == 'function' then
      hooksecurefunc(fname, afterLanguageChange)
      hookedAny = true
    end
  end
  if hookedAny then
    languageHooksInstalled = true
  end
end

local function pollChatLanguageMismatch(_, elapsed)
  if pendingDeferredEnforce then
    pendingDeferredEnforce = false
    EnforceRaceLanguage()
  end
  pollAccum = pollAccum + (elapsed or 0)
  if pollAccum < 0.25 then return end
  pollAccum = 0
  if not nativeLanguageOptionEnabled() then return end
  local wantedId = getRaceNativeLanguageId()
  if not wantedId or not NUM_CHAT_WINDOWS then return end
  for i = 1, NUM_CHAT_WINDOWS do
    local eb = _G['ChatFrame' .. i .. 'EditBox']
    if eb and tonumber(eb.languageID) ~= tonumber(wantedId) then
      EnforceRaceLanguage()
      break
    end
  end
end

EnforceRaceLanguageFrame = CreateFrame('Frame')

EnforceRaceLanguageFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
EnforceRaceLanguageFrame:RegisterEvent('LANGUAGE_LIST_CHANGED')

EnforceRaceLanguageFrame:SetScript('OnEvent', function(_, event, ...)
  if event == 'PLAYER_ENTERING_WORLD' or event == 'LANGUAGE_LIST_CHANGED' then
    registerLanguageLockedHooks()
    scheduleEnforceRaceLanguage()
  end
end)

EnforceRaceLanguageFrame:SetScript('OnUpdate', pollChatLanguageMismatch)

function RaceLocked_ApplyNativeLanguageOption()
  registerLanguageLockedHooks()
  scheduleEnforceRaceLanguage()
end
