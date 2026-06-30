local overlay
local OVERLAY_PADDING = 12
local OVERLAY_EXTRA_HEIGHT = 60
local OVERLAY_OFFSET_Y = -20

local function updateSpinner(self, elapsed)
  self.pulse = (self.pulse or 0) + elapsed
  local alpha = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(self.pulse * 3))
  self.spinner:SetAlpha(alpha)

  if self.spinner.SetRotation then
    self.rotation = (self.rotation or 0) - elapsed * 2
    self.spinner:SetRotation(self.rotation)
  end
end

function RaceLocked_ShowMailVerificationOverlay()
  if not MailFrame then return end

  if not overlay then
    overlay =
      CreateFrame('Frame', 'RaceLockedMailVerificationOverlay', MailFrame, 'BackdropTemplate')
    overlay:SetFrameStrata('HIGH')
    overlay:SetFrameLevel(MailFrame:GetFrameLevel() + 20)
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
    overlay.statusText:SetText('Mail is not yet available...')

    overlay:SetScript('OnUpdate', updateSpinner)
  end

  overlay:SetSize(
    MailFrame:GetWidth() + (OVERLAY_PADDING * 2),
    MailFrame:GetHeight() + (OVERLAY_PADDING * 2)
  )
  overlay:ClearAllPoints()
  overlay:SetPoint('CENTER', MailFrame, 'CENTER', 0, OVERLAY_OFFSET_Y)
  overlay:Show()
end

function RaceLocked_HideMailVerificationOverlay()
  if overlay then
    overlay:Hide()
  end
end

local mailOverlayEvents = CreateFrame('Frame')
mailOverlayEvents:RegisterEvent('MAIL_SHOW')
mailOverlayEvents:RegisterEvent('MAIL_CLOSED')

mailOverlayEvents:SetScript('OnEvent', function(_, event)
  if RaceLocked_IsInGuildFoundGuild() and RaceLocked_AmIVerified() then
    if event == 'MAIL_SHOW' then
      RaceLocked_ShowMailVerificationOverlay()
    elseif event == 'MAIL_CLOSED' then
      RaceLocked_HideMailVerificationOverlay()
    end
  end
end)
