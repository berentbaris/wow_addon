local function GetOrCreateMainMount(settingsFrame)
  local L = RaceLocked_MainMenu
  local mainTab = RaceLocked_GetMainTabContent and RaceLocked_GetMainTabContent()
  local parent = mainTab or settingsFrame
  local mount = settingsFrame.raceLockedMainMount
  if not mount then
    mount = CreateFrame('Frame', nil, parent)
    settingsFrame.raceLockedMainMount = mount
  else
    mount:SetParent(parent)
    mount:ClearAllPoints()
  end
  if mainTab then
    mount:SetPoint('TOPLEFT', parent, 'TOPLEFT', L.MAIN_MARGIN_X, -6)
    mount:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -L.MAIN_MARGIN_X, L.MAIN_BOTTOM_INSET)
  else
    mount:SetPoint('TOPLEFT', parent, 'TOPLEFT', L.MAIN_MARGIN_X, L.MAIN_TOP_INSET)
    mount:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -L.MAIN_MARGIN_X, L.MAIN_BOTTOM_INSET)
  end
  return mount
end

--- @param settingsFrame Frame
--- @param forceRefresh boolean|nil when true, rebuild the grid even if one exists
function RaceLocked_InitializeMainPanel(settingsFrame, forceRefresh)
  if not settingsFrame then return end
  local mount = GetOrCreateMainMount(settingsFrame)
  if mount.raceRoot and not forceRefresh then return end

  if mount.raceRoot then
    mount.raceRoot:Hide()
    mount.raceRoot:SetParent(nil)
    mount.raceRoot = nil
  end

  if RaceLocked_CreateFactionRaceGrid then
    mount.raceRoot = select(1, RaceLocked_CreateFactionRaceGrid(mount))
  end
end
