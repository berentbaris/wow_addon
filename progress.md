# HardcoreClassesEnhanced — Progress Log

## 2026-04-09

- Created addon scaffold: `.toc` file (Interface 11507), main `HardcoreClassesEnhanced.lua` with event frame, SavedVariables, slash commands (`/hce`, `/hardcoreclasses`), and ADDON_LOADED/PLAYER_LOGIN/PLAYER_LOGOUT handling
- Built `CharacterData.lua` with all 27 enhanced characters transcribed from the spreadsheet, including structured fields for equipment (with level gates), challenges, companions, pets, mounts, and gameplay tips; also includes challenge type descriptions from the Notes sheet
- Implemented character auto-detection on login: matches player race/class/gender against character data, handles exact match (auto-assign), multiple matches (prompt to pick), and no match (manual pick). Selection persists across sessions via SavedVariablesPerCharacter
- Added `/hce status` command that prints full requirement details with level-gated colour coding (green ACTIVE vs grey "lv N"), and `/hce pick <name>` for case-insensitive manual selection
- Tasks 1.1, 1.2, and 1.3 all complete. Next up: Task 1.4 (character selection UI frame)
