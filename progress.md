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
