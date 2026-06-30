--- Root settings panel: movable, draggable, dialog strata, clips children.
--- @return Frame settingsFrame global `RaceLockedSettingsFrame`
function RaceLocked_Settings_CreateRootFrame()
  local S = RaceLocked_Settings
  local settingsFrame =
    CreateFrame('Frame', 'RaceLockedSettingsFrame', UIParent, 'BackdropTemplate')
  tinsert(UISpecialFrames, 'RaceLockedSettingsFrame')
  settingsFrame:SetSize(S.FRAME_WIDTH, S.FRAME_HEIGHT)
  settingsFrame:SetMovable(true)
  settingsFrame:EnableMouse(true)
  settingsFrame:RegisterForDrag('LeftButton')
  settingsFrame:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)
  settingsFrame:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
  end)
  settingsFrame:SetScript('OnHide', function(self)
    if _G.HideConfirmationDialog then
      _G.HideConfirmationDialog()
    end
  end)
  settingsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 30)
  settingsFrame:Hide()
  settingsFrame:SetFrameStrata('DIALOG')
  settingsFrame:SetFrameLevel(15)
  settingsFrame:SetClipsChildren(true)
  return settingsFrame
end
