-- Title bar, divider, header art, and close control • same patterns as UltraFound

--- @param settingsFrame Frame
function RaceLocked_Settings_CreateTitleChrome(settingsFrame)
  local S = RaceLocked_Settings
  local tp = S.TEXTURE_PATH

  local titleBar = CreateFrame('Frame', nil, settingsFrame, 'BackdropTemplate')
  titleBar:SetSize(S.FRAME_WIDTH, 60)
  titleBar:SetPoint('TOP', settingsFrame, 'TOP')
  titleBar:SetFrameStrata('DIALOG')
  titleBar:SetFrameLevel(20)
  titleBar:SetBackdropBorderColor(0, 0, 0, 1)
  titleBar:SetBackdropColor(0, 0, 0, 0.95)
  local titleBarBackground = titleBar:CreateTexture(nil, 'BACKGROUND')
  titleBarBackground:SetAllPoints()
  titleBarBackground:SetTexture(tp .. '\\header.png')
  titleBarBackground:SetTexCoord(0, 1, 0, 1)
  local settingsTitleLabel = titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')
  settingsTitleLabel:SetPoint('CENTER', titleBar, 'CENTER', 0, 4)
  settingsTitleLabel:SetText('Race Locked')
  settingsTitleLabel:SetTextColor(0.922, 0.871, 0.761)

  local dividerFrame = CreateFrame('Frame', nil, settingsFrame)
  dividerFrame:SetSize(S.FRAME_WIDTH + 10, 24)
  dividerFrame:SetPoint('BOTTOM', titleBar, 'BOTTOM', 0, -10)
  dividerFrame:SetFrameStrata('DIALOG')
  dividerFrame:SetFrameLevel(20)
  local dividerTexture = dividerFrame:CreateTexture(nil, 'ARTWORK')
  dividerTexture:SetAllPoints()
  dividerTexture:SetTexture(tp .. '\\divider.png')
  dividerTexture:SetTexCoord(0, 1, 0, 1)

  local titleBarLeftIcon = titleBar:CreateTexture(nil, 'OVERLAY')
  titleBarLeftIcon:SetSize(36, 36)
  titleBarLeftIcon:SetPoint('LEFT', titleBar, 'LEFT', 15, 3)
  titleBarLeftIcon:SetTexture(tp .. '\\bonnie-round.png')
  titleBarLeftIcon:SetTexCoord(0, 1, 0, 1)

  local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
  closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -15, 4)
  closeButton:SetSize(12, 12)
  closeButton:SetScript('OnClick', function()
    if _G.HideConfirmationDialog then
      _G.HideConfirmationDialog()
    end
    if RaceLocked_ResetTabState then
      RaceLocked_ResetTabState()
    end
    settingsFrame:Hide()
  end)
  closeButton:SetNormalTexture(tp .. '\\header-x.png')
  closeButton:SetPushedTexture(tp .. '\\header-x.png')
  closeButton:SetHighlightTexture('Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight', 'ADD')
  local closeButtonTex = closeButton:GetNormalTexture()
  if closeButtonTex then
    closeButtonTex:SetTexCoord(0, 1, 0, 1)
  end
  local closeButtonPushed = closeButton:GetPushedTexture()
  if closeButtonPushed then
    closeButtonPushed:SetTexCoord(0, 1, 0, 1)
  end
end
