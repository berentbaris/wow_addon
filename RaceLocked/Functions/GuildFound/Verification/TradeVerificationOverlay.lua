local overlay
local OVERLAY_PADDING = 12

local function updateSpinner(self, elapsed)
  self.pulse = (self.pulse or 0) + elapsed
  local alpha = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(self.pulse * 3))
  self.spinner:SetAlpha(alpha)

  if self.spinner.SetRotation then
    self.rotation = (self.rotation or 0) - elapsed * 2
    self.spinner:SetRotation(self.rotation)
  end
end

function RaceLocked_ShowTradeVerificationOverlay()
  if not TradeFrame then return end

  if not overlay then
    overlay =
      CreateFrame('Frame', 'RaceLockedTradeVerificationOverlay', TradeFrame, 'BackdropTemplate')
    overlay:SetFrameStrata('HIGH')
    overlay:SetFrameLevel(TradeFrame:GetFrameLevel() + 20)
    overlay:EnableMouse(true)
    overlay:SetBackdrop({
      bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
      edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
      tile = true,
      tileSize = 32,
      edgeSize = 32,
      insets = {
        left = 11,
        right = 11,
        top = 11,
        bottom = 11,
      },
    })
    overlay:SetBackdropColor(0, 0, 0, 0.85)

    overlay.spinner = overlay:CreateTexture(nil, 'ARTWORK')
    overlay.spinner:SetTexture('Interface\\COMMON\\StreamBackground')
    overlay.spinner:SetSize(56, 56)
    overlay.spinner:SetPoint('CENTER', 0, 24)

    overlay.statusText = overlay:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
    overlay.statusText:SetPoint('CENTER', 0, -20)
    overlay.statusText:SetText('Verifying Guild Found status...')

    overlay:SetScript('OnUpdate', updateSpinner)
  end

  overlay:SetSize(
    TradeFrame:GetWidth() + (OVERLAY_PADDING * 2),
    TradeFrame:GetHeight() + (OVERLAY_PADDING * 2)
  )
  overlay:ClearAllPoints()
  overlay:SetPoint('CENTER', TradeFrame, 'CENTER')
  overlay:Show()
end

function RaceLocked_HideTradeVerificationOverlay()
  if overlay then
    overlay:Hide()
  end
end
