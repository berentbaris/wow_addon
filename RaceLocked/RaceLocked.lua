addonName = ...
RaceLocked = CreateFrame('Frame')

function RaceLocked_RefreshGuildRoster()
  local inGuild = IsInGuild and IsInGuild()
  if inGuild and GuildRoster then
    SetGuildRosterShowOffline(true)
    GuildRoster()
  end
end

RaceLocked:RegisterEvent('ADDON_LOADED')
RaceLocked:SetScript('OnEvent', function(self, event, loadedAddonName)
  if event == 'ADDON_LOADED' and loadedAddonName == addonName then
    RaceLockedDB = RaceLockedDB or {}
    RaceLockedDB.minimapButton = RaceLockedDB.minimapButton or { hide = false }
    RaceLockedAccountDB = RaceLockedAccountDB or {}
    if RaceLocked_Options_EnsureLoaded then
      RaceLocked_Options_EnsureLoaded()
    end

    RaceLocked_RefreshGuildRoster()
  end
end)
