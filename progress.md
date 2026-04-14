# HardcoreClassesEnhanced — Progress Log

## 2026-04-09

- Created addon scaffold: `.toc` file (Interface 11507), main `HardcoreClassesEnhanced.lua` with event frame, SavedVariables, slash commands (`/hce`, `/hardcoreclasses`), and ADDON_LOADED/PLAYER_LOGIN/PLAYER_LOGOUT handling
- Built `CharacterData.lua` with all 27 enhanced characters transcribed from the spreadsheet, including structured fields for equipment (with level gates), challenges, companions, pets, mounts, and gameplay tips; also includes challenge type descriptions from the Notes sheet
- Implemented character auto-detection on login: matches player race/class/gender against character data, handles exact match (auto-assign), multiple matches (prompt to pick), and no match (manual pick). Selection persists across sessions via SavedVariablesPerCharacter
- Added `/hce status` command that prints full requirement details with level-gated colour coding (green ACTIVE vs grey "lv N"), and `/hce pick <name>` for case-insensitive manual selection
- Tasks 1.1, 1.2, and 1.3 all complete. Next up: Task 1.4 (character selection UI frame)

## 2026-04-10

- Built `SelectionUI.lua` — a full WoW UI frame using `BasicFrameTemplateWithInset`, draggable, with a `FauxScrollFrameTemplate` list of up to 9 visible rows, class-coloured names, spec/race/gender subtext, click-to-select and double-click-to-commit
- Added a two-option radio filter ("matches for my character" vs. "all archetypes for my class"), with automatic fallback to the full class list if the player has zero matches so the frame is never empty
- Built a details pane (right side) that shows race/gender/self-found, professions, level-gated equipment, challenges with their Notes-sheet descriptions inlined, companion/pet/mount, and gameplay flavour tips — all inside a scrollable body so long requirement lists still fit
- Wired the UI into the rest of the addon: `/hce ui` (and `/hce show`/`/hce open`) opens it, `/hce pick` with no args now opens it (instead of dumping a chat list), and `TryAutoDetect` schedules `HCE.ShowSelectionUI` on a 0.5s timer when multiple race/class/gender matches exist on login
- Added `SelectionUI.lua` to the `.toc` load order (between CharacterData.lua and the main file) and verified all three Lua files parse cleanly. Milestone 1 is now complete; next up is Task 2.1 (standalone requirements panel)

## 2026-04-11

- Built `RequirementsPanel.lua` — a persistent draggable sidebar frame (separate from the selection popup) with a dark charcoal backdrop and a gold stripe that deliberately avoids Blizzard's stock `BasicFrameTemplate` look. Features a title header with the selected character's class-coloured name, a `Spec Class · lv X / 60` subtitle, a "N / M requirements active" summary bar, a scrollable body with section headers (EQUIPMENT / CHALLENGES / COMPANIONS / GAMEPLAY), and per-row tags showing `ACTIVE` in green or `lv N` in grey with matching text dimming for level-gated rows
- Added a pin/lock toggle on the title bar, full drag-to-move support, and persisted frame position + shown state in `HCE_GlobalDB.panel`. Panel auto-reopens on login if it was open when the player last logged out
- Built a custom minimap button (draggable around the minimap ring via polar-angle math, left-click toggles the panel, right-click toggles lock, tooltip explains both). Icon uses a plain gold `HC` glyph over a dark disc instead of reusing a stock Blizzard spell icon, to keep the visual identity distinctive
- Hooked `PLAYER_LEVEL_UP` for live refresh and wired `HCE.RefreshPanel` into both `/hce pick <name>` and the SelectionUI commit path so newly-picked characters render immediately. Added slash commands `/hce panel`, `/hce req`, `/hce requirements`, and `/hce minimap`
- Registered `RequirementsPanel.lua` in the `.toc` load order, ran all four Lua files through a parse check (clean), and moved Task 2.1 to completed. Next up is Task 2.2 (level-gate toast alert on PLAYER_LEVEL_UP)

## 2026-04-12

- Built `LevelAlert.lua` — a stackable toast system that surfaces newly active requirements. Toasts are a charcoal/gold banner anchored top-right of the screen, slide in from ~40px right with an ease-out cubic, hold for 6s, and fade over 0.9s. Pooled frames, click-to-dismiss, hover brightens the border. Deliberately not a Blizzard `RaidNotice`/`UIErrorsFrame` reuse so the visual identity stays consistent with the requirements panel
- Added `HCE_CharDB.lastLevel` to the saved-variables defaults. On `PLAYER_LEVEL_UP` and on `PLAYER_LOGIN` the alert module calls `flippedRequirements(char, lastLevel, currentLevel)` which walks equipment/challenges/companion/pet/mount and returns everything in `(last, current]`. Each entry fires its own toast, except when more than 4 would fire at once — in that case we collapse to a single summary banner to catch up cross-session level-ups without spamming
- Wired `HCE.ResyncLevelAlerts` into the auto-detect path, `/hce pick <name>`, `/hce reset`, and the `SelectionUI` commit handler so picking a character mid-run snaps the baseline to the current level instead of replaying every prior gate. Added `/hce alerts` (toggle), `/hce testalert` (preview three staggered banners), and registered the new file in `HardcoreClassesEnhanced.toc` between `RequirementsPanel.lua` and the main file
- Parse-checked all five Lua files via `load()` in lupa (all clean). Task 2.2 is now complete; moved to the Completed Tasks section of `goals.md` and bumped Next Task to 2.3 (challenge-type info tooltips/panel)

## 2026-04-13

- Added GameTooltip-powered hover tooltips to challenge rows in `RequirementsPanel.lua` — hovering a challenge row (e.g. "Homebound", "Renegade") pops a tooltip with the challenge name in gold, ACTIVE/unlock status, and the full rule description. Used a manually-toggled ARTWORK highlight texture instead of the HIGHLIGHT draw layer to avoid auto-highlighting non-challenge rows. Tooltip state is cleared when rows are reused (pooled row system)
- Added right-click challenge tooltip to `LevelAlert.lua` toast banners — challenge toasts now carry a `challengeKey` field, show a "(right-click for details)" hint in the subtitle, and pop a GameTooltip on right-click. Left-click still dismisses. Both hover and right-click tooltip pause the toast auto-fade timer (`hoverPaused`/`tooltipPaused` flags checked in the hold phase of the animation)
- Updated `flippedRequirements()` in LevelAlert.lua to pass a `challengeKey` field through to `Alert.Toast()` for challenge-type entries, and updated `/hce testalert` to test the new challenge tooltip on the "Homebound" preview toast
- Parse-checked all five Lua files via `load()` in lupa (all clean). Task 2.3 complete; Milestone 2 fully done. Next task bumped to 3.1 (equipment type tracking)

## 2026-04-14

- Built `EquipmentCheck.lua` — a comprehensive equipment tracking module with a rule registry that maps each equipment requirement description to a checker function. Registers PLAYER_EQUIPMENT_CHANGED and PLAYER_LOGIN, snapshots all 19 inventory slots via GetInventoryItemID + GetItemInfo, and evaluates every active requirement
- Implemented 25+ weapon/armor type rules using locale-independent classID/subclassID constants: single and combo weapon types (swords, maces, axes, staves, daggers, fist weapons, guns, wands, polearms, thrown, 2H weapons), armor slot checks (shield, robe via INVTYPE_ROBE, no-chest), and negative rules (no daggers, no wands, no guns, no robes). Each rule returns pass/fail/unchecked with a human-readable detail string
- Created curated item ID placeholder tables (`HCE.CuratedItems`) for 30+ visual/thematic requirements (voodoo mask, wolf helm, shell shield, captain's hat, etc.) — empty tables ready for Milestone 7 population. Pre-filled Flying Tiger Goggles (4368) and Green Tinted Goggles (4385) as known item IDs
- Integrated equipment check results into RequirementsPanel: active equipment rows now display ✓ (pass), ✗ (fail), or ? (unchecked) indicators with colour coding, plus hover tooltips explaining the check result. Panel refreshes on PLAYER_EQUIPMENT_CHANGED. Chat warnings fire only on NEW violations to avoid spam
- Parse-checked all six Lua files via `load()` in lupa (all clean). Tasks 3.1 and 3.2 complete; next task is 3.3 (visual/thematic item classification)
