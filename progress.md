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

## 2026-04-15

- Created `CuratedItems.lua` — a dedicated file that populates `HCE.CuratedItems` (defined by EquipmentCheck) with verified WoW Classic item IDs. Filled in what can be confirmed from stable class-item and recipe-item IDs: Flying Tiger Goggles (4368), Green-tinted Goggles (4385 + Green Lens 10500), Gnomish goggle headpieces (Green Lens 10500, Deepdive Helmet 10501, Gnomish Mind Control Cap 10546, Goblin Rocket Helmet 10548), warlock Firestone ranks (1254/13699/13700), warlock Spellstone ranks (5522/13602/13603), Wolfshead Helm (8345), Guild Tabard (5976), Festival Dress/Suit (21509/21510), Blue Linen Shirt (1770), Blue Martial Shirt (2575), and First Mate Hat (12251). Every entry carries a provenance comment. Lists that aren't exhaustive yet stay empty with `TODO(M7)` markers so Milestone 7 has a clean handoff
- Introduced `HCE.CuratedComplete` — an opt-in per-list "this curation is definitive" flag. Marked Flying Tiger Goggles, Firestone, Spellstone, and Guild Tabard as complete. Reworked `EquipmentCheck.slotInCurated` and `anySlotInCurated` so a miss on a NOT-complete list returns `UNCHECKED` with a "`<item>` isn't on the curated list yet (N items approved so far)" message, while a miss on a complete list still returns the hard `FAIL` it did before. This avoids falsely telling a player their goggles are "wrong" when the real story is that curation is still in flight
- Added `/hce curated` slash command — prints a table of every list, its count, and a coloured tag (`done` / `N items` / `empty`), sorted by count descending. Ends with a total-items / total-lists / marked-complete summary line. Wired into the `/hce help` listing
- Registered `CuratedItems.lua` in `HardcoreClassesEnhanced.toc` directly after `EquipmentCheck.lua` so the equipment rules are loaded before they get populated. Parse-checked all seven Lua files via `load()` in lupa (all clean)
- Task 3.3 moved to completed; bumped `Next Task` to 3.4 (forbidden-item flash alerts)

## 2026-04-16

- Built `ForbiddenAlert.lua` — a red-accent toast system that fires when the player equips an item that violates one of their active equipment rules. Reuses LevelAlert's charcoal body + gold border for family resemblance but swaps the left-edge stripe from gold to red and adds a dim red wash on the headline plate. Toasts live in their own vertical column (anchor y = -500) below the LevelAlert column so both can fire at once without overlap. Pooled frames, slide-in ease-out-cubic, 5s hold, 0.8s fade, click-to-dismiss, hover pauses the fade timer
- Added a full-UIParent screen-edge vignette pulse at BACKGROUND strata: four gradient textures (top/bottom/left/right) each 80px thick, tapered to transparent toward the centre. 0.12s fade-in → 0.18s hold → 0.60s fade-out at 35% peak alpha. Uses `SetGradient`/`SetGradientAlpha` with a pcall fallback so it keeps working across the 10.x API change. Sound is `SOUNDKIT.IG_QUEST_FAILED` — short "nope" chime, not the raid-warning horn
- Reworked `EquipmentCheck.CheckAndWarn` to snapshot old status values up front before `EQ.RunCheck()` overwrites `HCE_CharDB.equipResults` (otherwise new-vs-old comparison always compares against the new state and never fires). Collects new violations into a batch and hands them to `ForbiddenAlert.FireBatch`, which plays sound+flash only on the first toast (burst-suppresses the rest) and collapses to a single summary toast when more than three fire simultaneously so a dirty login with multiple bad items doesn't strobe the screen
- Added `HCE_GlobalDB.forbiddenAlertsEnabled` (default true), slash command `/hce forbidden` to toggle it, and `/hce testforbidden` to preview. Registered `ForbiddenAlert.lua` in the `.toc` after `CuratedItems.lua` so EquipmentCheck can reference `HCE.ForbiddenAlert.FireBatch` at load time
- Parse-checked all eight Lua files via `texluac -p` (Lua 5.3, clean on all). Task 3.4 moved to completed; Milestone 3 is now fully done. Bumped `Next Task` to 4.1 (profession tracking) with implementation notes about the locale-dependent skill-name problem

## 2026-04-17

- Built `ProfessionCheck.lua` — a profession tracking module that uses locale-independent spell IDs (`IsSpellKnown`) for profession detection (12 professions mapped: 9 primary + 3 secondary) and then scans `GetNumSkillLines/GetSkillLineInfo` in a three-pass locale-fallback matcher to read rank numbers. Expected rank formula: `5 * playerLevel`, starts at level 5, caps at 300
- Added a PROFESSIONS section to RequirementsPanel between the race/gender summary and EQUIPMENT — each required profession gets its own row with ACTIVE/lv 5 tag, ✓/✗/? tracking indicator, and a hover tooltip showing rank vs expected detail (e.g. "Alchemy rank 105 / 150 (expected 100 at lv 20)")
- Chat warnings fire once per profession per state-transition ("not learned" and "falling behind") using the gold `[HCE]` chat prefix — deliberately softer than the red ForbiddenAlert toast. Warning state resets on `/hce pick` and `/hce reset` so switching characters doesn't carry stale warnings
- Added `/hce professions` and `/hce prof` slash commands that print a full status table. Panel now also listens to SKILL_LINES_CHANGED for live refresh. Registered `ProfessionCheck.lua` in the .toc after `ForbiddenAlert.lua`. Parse-checked all nine Lua files via lupa `load()` (all clean). Task 4.1 complete; bumped Next Task to 4.2 (talent/spec tracking)

## 2026-04-18

- Built `TalentCheck.lua` (422 lines) — talent/spec tracking module using `GetNumTalentTabs`/`GetTalentTabInfo` with locale-independent positional tab indices (1/2/3). Hardcoded `SPEC_TAB` mapping covers all 9 classes and their 3 specs each. Starting at level 10, checks that the expected spec tree has a plurality of talent points (strictly more than any other tree). Handles edge cases: no points spent, tied trees, and pre-level-10 inactive state
- Added a TALENTS section to RequirementsPanel between PROFESSIONS and EQUIPMENT — one row showing "Spec: <name>" with ACTIVE/lv 10 tag, ✓/✗/? tracking indicator, and a hover tooltip showing the verdict plus a per-tree point breakdown (e.g. "Arms: 12 (required), Fury: 3, Protection: 0")
- Chat warnings fire once per session on two transitions: "no points spent" and "wrong spec leading" — using the gold `[HCE]` chat prefix, same soft style as profession warnings. Warning state resets on `/hce pick` and `/hce reset`
- Added `/hce talents`, `/hce talent`, and `/hce spec` slash commands that print a full per-tree breakdown with colour-coded verdict. Wired `TalentCheck.ResetWarnings()` into pick and reset flows. Panel listens to CHARACTER_POINTS_CHANGED for live refresh
- Registered `TalentCheck.lua` in the .toc after `ProfessionCheck.lua`. Parse-checked all ten Lua files via lupa `load()` (all clean). Task 4.2 complete; bumped Next Task to 4.3 (self-found tracking)

## 2026-04-19

- Built `SelfFoundCheck.lua` (768 lines) — combined self-found buff detection and self-made challenge tracking module. Self-found buff detection uses a three-strategy locale-safe approach: spell-ID scan against candidate IDs, English name-based partial match fallback, and `AuraUtil.FindAuraByName` if available. Registers UNIT_AURA for live buff tracking
- Implemented self-made challenge item verification: scans all 19 equipment slots, items with quality 0–1 (white/grey) always pass, higher-quality items checked against curated profession-crafted ID lists. Seeded starter lists for Tailoring (35 items), Blacksmithing (33 items), Leatherworking (35 items), and Engineering (22 items) with verified Classic item IDs. Separate `EngineeringGuns` table (10 items) for the Mountaineer's "Self-made guns" challenge. Lists marked incomplete so misses return UNCHECKED instead of false FAILs until Milestone 7 curation
- Enhanced RequirementsPanel: summary row's "self-found" label now shows ✓/✗/? tracking indicator with hover tooltip showing buff status detail. CHALLENGES section shows ✓/✗/? for "Self-made" and "Self-made guns" rows with a combined tooltip (challenge description + self-made check detail). Added UNIT_AURA to panel event listener for live refresh
- Added `/hce selffound` (and `/hce selfmade`, `/hce sf`) slash commands with full per-item breakdown on failures. Wired `SelfFoundCheck.ResetWarnings()` into pick and reset flows. Chat warnings fire once per session for missing buff, self-made violations, and self-made gun violations
- Registered `SelfFoundCheck.lua` in the .toc after `TalentCheck.lua`. Parse-checked all eleven Lua files via lupa `load()` (all clean). Task 4.3 complete; Milestone 4 fully done. Bumped Next Task to 5.1 (challenge rule engine)
