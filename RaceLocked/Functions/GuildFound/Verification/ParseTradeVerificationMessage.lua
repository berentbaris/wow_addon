function RaceLocked_ParseTradeVerificationMessage(message)
  if not message then
    return nil
  end

  local status = message:match('^TV:(%d)$')
  if status == '1' then
    return true
  end
  if status == '0' then
    return false
  end

  return nil
end
