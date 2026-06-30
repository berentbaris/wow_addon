function RaceLocked_Settings_RegisterDataBroker()
  local S = RaceLocked_Settings

  local addonLDB = LibStub('LibDataBroker-1.1'):NewDataObject('RaceLocked', {
    type = 'data source',
    text = 'Race Locked',
    icon = S.TEXTURE_PATH .. '\\icon_racelock.jpg',
    OnClick = function(_, btn)
      if btn == 'LeftButton' then
        ToggleRaceLockedSettings()
      end
    end,
    OnTooltipShow = function(tooltip)
      if not tooltip or not tooltip.AddLine then return end
      tooltip:AddLine('|cffffffffRace Locked|r\n\nLeft-click to open', nil, nil, nil, nil)
    end,
  })

  local addonIcon = LibStub('LibDBIcon-1.0')
  addonIcon:Register('RaceLocked', addonLDB, RaceLockedDB.minimapButton)

  local minimapButton = addonIcon:GetMinimapButton('RaceLocked')
  if minimapButton and minimapButton.icon then
    minimapButton.icon:ClearAllPoints()
    minimapButton.icon:SetPoint('CENTER', minimapButton, 'CENTER', 0.5, 0)
  end
end

RaceLocked_Settings_RegisterDataBroker()
