--- @param name string|nil
--- @return string|nil
function RaceLocked_GuildVerification_StripRealmFromName(name)
  if name == nil or name == '' then
    return name
  end
  local s = tostring(name)
  local dash = string.find(s, '-', 1, true)
  if not dash or dash <= 1 then
    return s
  end
  return string.sub(s, 1, dash - 1)
end
