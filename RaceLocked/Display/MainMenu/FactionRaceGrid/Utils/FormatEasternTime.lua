-- US Eastern wall clock (EST/EDT) from a Unix instant, for shared display across clients.
-- DST matches US post-2007 rules: 2nd Sunday March 07:00 UTC → 1st Sunday November 06:00 UTC.

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}

local floor = math.floor

--- Unix seconds at the given UTC civil date-time.
--- @return number
local function utc_ts(y, mo, d, h, mi, s)
  local a = floor((14 - mo) / 12)
  local yy = y + 4800 - a
  local m = mo + 12 * a - 3
  local jd =
    d + floor((153 * m + 2) / 5) + 365 * yy + floor(yy / 4) - floor(yy / 100) + floor(
      yy / 400
    ) - 32045
  return (jd - 2440588) * 86400 + h * 3600 + mi * 60 + s
end

--- @return number|nil
local function dst_start_spring_utc(y)
  local count = 0
  for d = 1, 31 do
    local u = utc_ts(y, 3, d, 0, 0, 0)
    local t = date('!*t', u)
    if t.wday == 1 then
      count = count + 1
      if count == 2 then
        return utc_ts(y, 3, d, 7, 0, 0)
      end
    end
  end
  return nil
end

--- @return number|nil
local function dst_end_fall_utc(y)
  for d = 1, 30 do
    local u = utc_ts(y, 11, d, 0, 0, 0)
    local t = date('!*t', u)
    if t.wday == 1 then
      return utc_ts(y, 11, d, 6, 0, 0)
    end
  end
  return nil
end

--- US Eastern daylight saving for instant `n` (America/New_York, 2007+ transition dates).
--- @param n number Unix seconds
--- @return boolean
local function is_us_eastern_dst(n)
  local t = date('!*t', n)
  local y = tonumber(t.year) or 1970
  local start = dst_start_spring_utc(y)
  local ending = dst_end_fall_utc(y)
  if not start or not ending then
    return false
  end
  return n >= start and n < ending
end

--- @param n number positive Unix instant
--- @return string
function RaceLocked_GuildChampion_FormatUnixAsEastern(n)
  n = floor(tonumber(n) or 0)
  if n <= 0 then
    return ''
  end
  local dst = is_us_eastern_dst(n)
  local offset = dst and (4 * 3600) or (5 * 3600)
  local adj = n - offset
  local lab = dst and 'EDT' or 'EST'
  if date then
    local s = date('!%Y-%m-%d %H:%M:%S', adj)
    if s and s ~= '' then
      return s .. ' ' .. lab
    end
  end
  return tostring(n)
end

--- Friendly relative age string, e.g. "1 hr ago", "2 days ago".
--- @param n number positive Unix instant
--- @return string
function RaceLocked_GuildChampion_FormatUnixAsEasternFriendly(n)
  n = floor(tonumber(n) or 0)
  if n <= 0 then
    return ''
  end
  if not time then
    return ''
  end
  local now = floor(tonumber(time()) or 0)
  if now <= 0 then
    return ''
  end

  local diff = now - n
  if diff < 0 then
    diff = 0
  end

  if diff < (10 * 60) then
    return 'Just now'
  end
  if diff < 3600 then
    local mins = floor(diff / 60)
    if mins <= 1 then
      return '1 min ago'
    end
    return tostring(mins) .. ' mins ago'
  end
  if diff < 86400 then
    local hrs = floor(diff / 3600)
    if hrs <= 1 then
      return '1 hr ago'
    end
    return tostring(hrs) .. ' hrs ago'
  end
  local days = floor(diff / 86400)
  if days <= 1 then
    return '1 day ago'
  end
  return tostring(days) .. ' days ago'
end
