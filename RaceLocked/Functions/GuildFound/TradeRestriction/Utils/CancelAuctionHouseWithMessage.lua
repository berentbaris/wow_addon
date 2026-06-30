function RaceLocked_CancelAuctionHouseWithMessage(message)
  if message then
    RaceLocked_PrintRestrictionMessage(message)
  end

  if C_Timer and C_Timer.After then
    C_Timer.After(0.1, function()
      if CloseAuctionHouse then
        CloseAuctionHouse()
      end
    end)
  end
end
