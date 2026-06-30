-- Static layout, copy, and visual data for the faction race grid (settings panel).

RaceLocked_GuildChampion = RaceLocked_GuildChampion or {}

local G = RaceLocked_GuildChampion

G.MID_GAP = 6
G.OUTER_PAD_Y = 4
-- Extra space above the 2×2 grid (below root top).
G.GRID_TOP_OFFSET = 10
-- Tall cells: race row + guilds + average + class subtitle + chart host (same width w as copy).
-- Chart host: % row on top, gap, full-width bordered bar strip anchored to bottom of host.
G.CLASS_BAR_BORDER_PAD = 2
-- Extra inset for the class bar only (full-width bar vs text column); added to INNER_PAD on the left.
G.CLASS_BAR_EXTRA_LEFT_PAD = 4
G.CLASS_BAR_HEIGHT = 4
G.CLASS_BAR_LABEL_ROW = 14
G.CLASS_BAR_PCT_GAP = 2
G.CLASS_BAR_SEGMENT_GAP = 2
G.CLASS_BAR_SECTION_RIGHT_GAP = 2
-- Vertical lines between stacked class colours (drawn in OVERLAY on the bar row).
G.CLASS_BAR_SEP_W = 1
G.CLASS_BAR_SEP = { 0.22, 0.22, 0.24 }
-- Multiplier applied to class colors so bars/labels are less vivid.
G.CLASS_COLOR_BRIGHTNESS = 0.82
G.CLASS_BAR_HOST_H =
  G.CLASS_BAR_HEIGHT + 2 * G.CLASS_BAR_BORDER_PAD + G.CLASS_BAR_PCT_GAP + G.CLASS_BAR_LABEL_ROW
-- Extra vertical space between **sections** (after race name, after guild list, after level value).
-- Not applied between a subheading and its value (guild title→names, avg label→number, class label→bar).
G.RACE_GRID_PANE_SECTION_GAP = 5
-- Pane height: chart + bar border; +6 for race title; +3 section gaps (see layoutRaceGridPane).
-- Base (147) includes a little room below the class bar; trim here to tighten bottom padding.
G.STATS_ROW_H = 127 + 2 * G.CLASS_BAR_BORDER_PAD + 6 + 3 * G.RACE_GRID_PANE_SECTION_GAP
G.ROW_GAP = 6
G.GAP_AFTER_GRID = 11
--- Reserve space for `UIPanelScrollFrameTemplate` scrollbar when sizing scroll content width.
G.RACE_GRID_SCROLL_BAR_PAD = 28
--- Nudge `ScrollBar` this many pixels left from the template’s default anchor (negative X).
G.RACE_GRID_SCROLL_BAR_SHIFT_LEFT = 20
G.REFRESH_ROW_H = 26
G.EXPLAIN_TOP_GAP = 8
G.FOOTER_TOP_GAP = 8
G.INNER_PAD = 8

G.EXPLAIN_TEXT =
  'Race Locked will automatically remove you from groups that contain players from other races to your own.\n\nThe race averages show each playable race (Alliance and Horde) using guild data stored for this account.'

G.ACCENT_W = 3
G.ACCENT_INSET_X = 3
G.ACCENT_INSET_Y = 1
G.FACTION_ICON_SIZE = 28
G.GAP_AFTER_ACCENT = 7
G.GAP_AFTER_ICON = 6

G.LABEL_GOLD = { 1, 0.92, 0.62 }
G.MUTED = { 0.62, 0.6, 0.55 }

G.AP_BG = {
  r = 0.08,
  g = 0.1,
  b = 0.14,
  a = 0.94,
}
G.AP_BORDER = {
  r = 0.38,
  g = 0.45,
  b = 0.52,
  a = 0.88,
}

--- Per-race crests under Interface\Icons (glue CharacterCreate assets are not usable from addons).
--- @type table<string, string>
G.RACE_ICON_TEXTURE = {
  Human = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Human',
  Dwarf = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Dwarf',
  NightElf = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Nightelf',
  Gnome = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Gnome',
  Orc = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Orc',
  Troll = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Troll',
  Tauren = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Tauren',
  Scourge = 'Interface\\Icons\\INV_Misc_Tournaments_Symbol_Scourge',
}

G.CELL_BACKDROP = {
  bgFile = 'Interface\\Buttons\\WHITE8x8',
  edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
  tile = false,
  edgeSize = 8,
  insets = {
    left = 3,
    right = 3,
    top = 3,
    bottom = 3,
  },
}

-- Class stacked bar: border only around the colored strip (see _classBarBarWell in View).
G.CLASS_BAR_CHART_BACKDROP = {
  bgFile = 'Interface\\Buttons\\WHITE8x8',
  edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
  tile = false,
  edgeSize = 6,
  insets = {
    left = 2,
    right = 2,
    top = 2,
    bottom = 2,
  },
}

-- Per-race accent (left bar); legacy 4-pane Alliance order (see `RACE_TOKEN_ACCENT` for the full grid).
G.ALLIANCE_RACE_ACCENT = {
  { 0.78, 0.52, 0.28 }, -- Dwarf
  { 0.52, 0.35, 0.82 }, -- Night Elf
  { 0.72, 0.62, 0.42 }, -- Human
  { 0.88, 0.45, 0.72 }, -- Gnome
}

G.HORDE_RACE_ACCENT = {
  { 0.32, 0.72, 0.28 }, -- Orc
  { 0.18, 0.58, 0.85 }, -- Troll
  { 0.68, 0.48, 0.32 }, -- Tauren
  { 0.42, 0.68, 0.52 }, -- Undead
}

--- All Classic playable races (both factions), for the combined race grid tab.
G.RACE_GRID_ALL_TOKENS =
  { 'Human', 'Dwarf', 'NightElf', 'Gnome', 'Orc', 'Troll', 'Tauren', 'Scourge' }

--- Left-bar tint per race token (for any grid order).
G.RACE_TOKEN_ACCENT = {
  Human = { 0.72, 0.62, 0.42 },
  Dwarf = { 0.78, 0.52, 0.28 },
  NightElf = { 0.52, 0.35, 0.82 },
  Gnome = { 0.88, 0.45, 0.72 },
  Orc = { 0.32, 0.72, 0.28 },
  Troll = { 0.18, 0.58, 0.85 },
  Tauren = { 0.68, 0.48, 0.32 },
  Scourge = { 0.42, 0.68, 0.52 },
}

--- Title row label for each API race token.
G.RACE_LABEL = {
  Human = 'Human',
  Dwarf = 'Dwarf',
  NightElf = 'Night Elf',
  Gnome = 'Gnome',
  Orc = 'Orc',
  Troll = 'Troll',
  Tauren = 'Tauren',
  Scourge = 'Undead',
}

-- Section copy for each race cell (guild names come from aggregated data).
G.RACE_GRID_GUILD_SECTION_TITLE = 'Guilds'
G.RACE_GRID_AVG_SUBTITLE = 'Avg Level'
G.RACE_GRID_TOTAL_PLAYERS_SUBTITLE = 'Total Players'
G.RACE_GRID_TOTAL_60S_SUBTITLE = 'Total 60s'
G.RACE_GRID_CLASS_SUBTITLE = 'Class breakdown'
G.RACE_GRID_TRUSTED_GUILDS_TITLE = 'Guild names accepted for addon-reported data:'
G.TRUSTED_GUILDS_TITLE_TOP_GAP = 6

--- Default roster size required to refresh the race grid from guild data or publish to the data bus (in-guild only).
G.MIN_GUILD_MEMBERS_FOR_RACE_GRID = 400

--- Display order for class keys (matches stored payload keys).
G.CLASS_REPORT_KEYS = { {
  key = 'druids',
  label = 'Druid',
}, {
  key = 'rogues',
  label = 'Rogue',
}, {
  key = 'hunters',
  label = 'Hunter',
}, {
  key = 'warriors',
  label = 'Warrior',
}, {
  key = 'mages',
  label = 'Mage',
}, {
  key = 'priests',
  label = 'Priest',
}, {
  key = 'warlocks',
  label = 'Warlock',
}, {
  key = 'paladins',
  label = 'Paladin',
}, {
  key = 'shamans',
  label = 'Shaman',
} }

--- Maps report keys to RAID_CLASS_COLORS / GetClassColor file tokens.
G.CLASS_KEY_TO_FILE = {
  druids = 'DRUID',
  rogues = 'ROGUE',
  hunters = 'HUNTER',
  warriors = 'WARRIOR',
  mages = 'MAGE',
  priests = 'PRIEST',
  warlocks = 'WARLOCK',
  paladins = 'PALADIN',
  shamans = 'SHAMAN',
}

--- Which classes can roll this race (WoW Classic–style; API race tokens).
--- Order is display order in the grid. Edit if your ruleset differs.
G.RACE_TOKEN_TO_CLASS_KEYS = {
  Human = { 'rogues', 'warriors', 'paladins', 'mages', 'warlocks', 'priests' },
  Dwarf = { 'rogues', 'warriors', 'paladins', 'hunters', 'priests' },
  NightElf = { 'rogues', 'warriors', 'hunters', 'druids', 'priests' },
  Gnome = { 'rogues', 'warriors', 'mages', 'warlocks' },
  Orc = { 'rogues', 'warriors', 'hunters', 'shamans', 'warlocks' },
  Troll = { 'rogues', 'warriors', 'hunters', 'shamans', 'mages', 'priests' },
  Tauren = { 'warriors', 'hunters', 'druids', 'shamans' },
  Scourge = { 'rogues', 'warriors', 'mages', 'warlocks', 'priests' },
}
