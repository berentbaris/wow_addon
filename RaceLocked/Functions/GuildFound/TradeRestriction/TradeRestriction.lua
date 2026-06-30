local frame = CreateFrame('Frame')
frame:RegisterEvent('TRADE_SHOW')
frame:RegisterEvent('TRADE_UPDATE')
frame:RegisterEvent('TRADE_CLOSED')
frame:RegisterEvent('AUCTION_HOUSE_SHOW')

-- Guards against starting verification more than once per trade window.
-- TRADE_UPDATE can fire repeatedly, and is our retry path for the case where
-- the partner name isn't available yet on TRADE_SHOW.
local tradeVerifyStarted = false

local function tryVerifyTradePartner()
  if tradeVerifyStarted then return end
  local targetName = GetUnitName('npc', true)
  -- Name not ready yet • a later TRADE_UPDATE will retry before any trade
  -- can be completed, so we never allow an unverified trade through.
  if not targetName then return end
  tradeVerifyStarted = true
  RaceLocked_CanPerformTradeWithPlayer(targetName, function(canTrade, message)
    if not canTrade then
      RaceLocked_CancelTradeWithMessage(message)
    end
  end)
end

frame:SetScript('OnEvent', function(self, event, ...)
  if event == 'TRADE_CLOSED' then
    tradeVerifyStarted = false
    RaceLocked_EndTradeVerification()
    return
  end

  if not (RaceLocked_IsInGuildFoundGuild() and RaceLocked_AmIVerified()) then return end

  if event == 'TRADE_SHOW' or event == 'TRADE_UPDATE' then
    tryVerifyTradePartner()
  elseif event == 'AUCTION_HOUSE_SHOW' then
    RaceLocked_CancelAuctionHouseWithMessage('Auction House blocked')
  end
end)
