-- Saved row tint for leaderboard tables (settings + main screen). Per-character in RaceLockedDB.

local DEFAULT_R, DEFAULT_G, DEFAULT_B, DEFAULT_A = 0.13, 0.19, 0.40, 0.30

local swatchRefreshFn

local function clamp01(x)
  x = tonumber(x) or 0
  if x < 0 then
    return 0
  end
  if x > 1 then
    return 1
  end
  return x
end

function RaceLocked_EnsureLeaderboardRowColorDefaults()
  RaceLockedDB = RaceLockedDB or {}
  local c = RaceLockedDB.leaderboardRowColor
  if type(c) ~= 'table' then
    RaceLockedDB.leaderboardRowColor = {
      r = DEFAULT_R,
      g = DEFAULT_G,
      b = DEFAULT_B,
      a = DEFAULT_A,
    }
    return
  end
  if c.r == nil then c.r = DEFAULT_R end
  if c.g == nil then c.g = DEFAULT_G end
  if c.b == nil then c.b = DEFAULT_B end
  if c.a == nil then c.a = DEFAULT_A end
  c.r = clamp01(c.r)
  c.g = clamp01(c.g)
  c.b = clamp01(c.b)
  c.a = clamp01(c.a)
end

function RaceLocked_GetLeaderboardRowTint()
  RaceLocked_EnsureLeaderboardRowColorDefaults()
  local c = RaceLockedDB.leaderboardRowColor
  return { r = c.r, g = c.g, b = c.b, a = c.a }
end

function RaceLocked_RegisterLeaderboardRowColorSwatchRefresh(fn)
  swatchRefreshFn = fn
end

function RaceLocked_SetLeaderboardRowColor(r, g, b, a)
  RaceLocked_EnsureLeaderboardRowColorDefaults()
  local c = RaceLockedDB.leaderboardRowColor
  c.r = clamp01(r)
  c.g = clamp01(g)
  c.b = clamp01(b)
  c.a = clamp01(a)
  if swatchRefreshFn then
    swatchRefreshFn()
  end
  if RaceLocked_NotifyLeaderboardDataChanged then
    RaceLocked_NotifyLeaderboardDataChanged()
  end
end

function RaceLocked_ResetLeaderboardRowColorToDefault()
  RaceLocked_SetLeaderboardRowColor(DEFAULT_R, DEFAULT_G, DEFAULT_B, DEFAULT_A)
end

function RaceLocked_ShowLeaderboardRowColorPicker()
  local t = RaceLocked_GetLeaderboardRowTint()
  local r0, g0, b0, a0 = t.r, t.g, t.b, t.a

  local cp = ColorPickerFrame
  if not cp then
    return
  end

  if cp.SetupColorPickerAndShow then
    local prevR, prevG, prevB, prevA = r0, g0, b0, a0
    cp:SetupColorPickerAndShow({
      r = r0,
      g = g0,
      b = b0,
      opacity = a0,
      hasOpacity = true,
      swatchFunc = function()
        local r, g, b = cp:GetColorRGB()
        local a = cp.GetColorAlpha and cp:GetColorAlpha() or a0
        RaceLocked_SetLeaderboardRowColor(r, g, b, a)
      end,
      opacityFunc = function()
        local r, g, b = cp:GetColorRGB()
        local a = cp.GetColorAlpha and cp:GetColorAlpha() or prevA
        RaceLocked_SetLeaderboardRowColor(r, g, b, a)
      end,
      cancelFunc = function()
        RaceLocked_SetLeaderboardRowColor(prevR, prevG, prevB, prevA)
      end,
    })
    return
  end

  cp.func = function()
    local r, g, b = cp:GetColorRGB()
    local a = a0
    if cp.hasOpacity and OpacitySliderFrame and OpacitySliderFrame.GetValue then
      a = tonumber(OpacitySliderFrame:GetValue()) or a0
    end
    RaceLocked_SetLeaderboardRowColor(r, g, b, a)
  end
  cp.opacityFunc = function()
    local r, g, b = cp:GetColorRGB()
    local a = a0
    if OpacitySliderFrame and OpacitySliderFrame.GetValue then
      a = tonumber(OpacitySliderFrame:GetValue()) or a0
    end
    RaceLocked_SetLeaderboardRowColor(r, g, b, a)
  end
  cp.cancelFunc = function()
    RaceLocked_SetLeaderboardRowColor(r0, g0, b0, a0)
  end
  cp.previousValues = { r0, g0, b0, a0 }
  cp:SetFrameStrata('FULLSCREEN_DIALOG')
  cp:SetFrameLevel(cp:GetFrameLevel() + 20)
  cp:SetColorRGB(r0, g0, b0)
  cp.hasOpacity = true
  if OpacitySliderFrame and OpacitySliderFrame.SetValue then
    OpacitySliderFrame:SetValue(a0)
  end
  cp.opacity = a0
  ShowUIPanel(cp)
end
