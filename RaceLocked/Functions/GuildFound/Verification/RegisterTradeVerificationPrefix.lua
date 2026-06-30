local ADDON_PREFIX = 'RaceLocked'

local prefixFrame = CreateFrame('Frame')
prefixFrame:RegisterEvent('PLAYER_LOGIN')

prefixFrame:SetScript('OnEvent', function()
  if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
  end
end)

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
  C_ChatInfo.RegisterAddonMessagePrefix(ADDON_PREFIX)
end
