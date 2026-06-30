local SECTION_TITLE_COLOR = { r = 0.98, g = 0.86, b = 0.42 }
local BODY_COLOR = { r = 0.85, g = 0.82, b = 0.76 }

local SECTIONS = {
  {
    title = 'Leaderboard',
    body = 'The leaderboard is sorted by player levels, highest first. '
      .. '\nWhen levels are tied, the player with the most achievements breaks the tie, then character name.',
  },
  {
    title = 'Guild Champion',
    body = 'The guild champion is the player who ranks #1 in the leaderboard. '
  },
  {
    title = 'Most Achievements',
    body = 'The player with the most achievements in the leaderboard gains this title.',
  },
  {
    title = 'On Screen Leaderboard',
    body = 'The on screen leaderboard is a shortened version of the leaderboard. '
      .. '\nOnly the closest 4 players are shown, with you in the middle.',
  },
  {
    title = 'Race Locked Grouping',
    body = 'The addon stops you from grouping with players of different races. '
      .. '\nAs leader you will auto kick other races, whilst if not lead you will auto leave.'
  },
  {
    title = 'Guild Sync',
    body = 'Every 5 minutes, you send out data to your guildies. '
      .. '\nThis is used to update the leaderboard for other online members.'
      .. '\nIf your data seems to not be updating, do not panic, it is just a delayed update!',
  },
}

function RaceLocked_InitializePointsExplainedTab(tabContents, index)
  local content = tabContents and tabContents[index]
  if not content or content.pointsExplainedInit then
    return
  end
  content.pointsExplainedInit = true

  local scroll = CreateFrame('ScrollFrame', nil, content, 'UIPanelScrollFrameTemplate')
  scroll:SetPoint('TOPLEFT', content, 'TOPLEFT', 6, -8)
  scroll:SetPoint('BOTTOMRIGHT', content, 'BOTTOMRIGHT', -8, 10)

  if scroll.ScrollBar then
    scroll.ScrollBar:Hide()
    scroll.ScrollBar:SetScript('OnShow', function(self)
      self:Hide()
    end)
  end

  local scrollChild = CreateFrame('Frame', nil, scroll)
  local contentW = content:GetWidth()
  if not contentW or contentW < 100 then
    contentW = 348
  end
  local padX = 14
  local w = math.max(200, contentW - 28)
  scrollChild:SetWidth(w + padX * 2)
  scroll:SetScrollChild(scrollChild)

  local y = -16
  local gapAfterTitle = 6
  local gapAfterBody = 22

  for s = 1, #SECTIONS do
    local sec = SECTIONS[s]
    local titleFs = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    titleFs:SetWidth(w)
    titleFs:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', padX, y)
    titleFs:SetJustifyH('LEFT')
    titleFs:SetJustifyV('TOP')
    titleFs:SetText(sec.title)
    titleFs:SetTextColor(SECTION_TITLE_COLOR.r, SECTION_TITLE_COLOR.g, SECTION_TITLE_COLOR.b)

    y = y - titleFs:GetStringHeight() - gapAfterTitle

    local bodyFs = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    bodyFs:SetWidth(w)
    bodyFs:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', padX, y)
    bodyFs:SetJustifyH('LEFT')
    bodyFs:SetJustifyV('TOP')
    bodyFs:SetSpacing(3)
    bodyFs:SetText(sec.body)
    bodyFs:SetTextColor(BODY_COLOR.r, BODY_COLOR.g, BODY_COLOR.b)

    y = y - bodyFs:GetStringHeight() - gapAfterBody
  end

  scrollChild:SetHeight(math.max(-y + 24, 1))
end
