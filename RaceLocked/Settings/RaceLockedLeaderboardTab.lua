-- Main window content: 2×2 faction race grid only.

local MAIN_MARGIN_X = 12
local MAIN_TOP_INSET = -62
local MAIN_BOTTOM_INSET = 8

function RaceLocked_InitializeMainPanel(settingsFrame, forceRefresh)
  if not settingsFrame then
    return
  end
  local mount = settingsFrame.raceLockedMainMount
  if not mount then
    mount = CreateFrame('Frame', nil, settingsFrame)
    settingsFrame.raceLockedMainMount = mount
    mount:SetPoint('TOPLEFT', settingsFrame, 'TOPLEFT', MAIN_MARGIN_X, MAIN_TOP_INSET)
    mount:SetPoint('BOTTOMRIGHT', settingsFrame, 'BOTTOMRIGHT', -MAIN_MARGIN_X, MAIN_BOTTOM_INSET)
  end
  if mount.raceRoot and not forceRefresh then
    return
  end
  if mount.raceRoot then
    mount.raceRoot:Hide()
    mount.raceRoot:SetParent(nil)
    mount.raceRoot = nil
  end
  if RaceLocked_CreateFactionRaceGrid then
    mount.raceRoot = select(1, RaceLocked_CreateFactionRaceGrid(mount, 0))
  end
end
