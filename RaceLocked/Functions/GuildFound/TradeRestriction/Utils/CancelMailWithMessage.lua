function RaceLocked_CancelMailWithMessage(inboxIndex, message)
  if not inboxIndex then return end

  if message then
    RaceLocked_PrintRestrictionMessage(message)
  end
  ReturnInboxItem(inboxIndex)
end
