function RaceLocked_CancelTradeWithMessage(message)
  if message then
    RaceLocked_PrintRestrictionMessage(message)
  end
  CancelTrade()
end
