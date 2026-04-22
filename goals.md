# HardcoreClassesEnhanced - Addon Development Goals

**Last updated:** 2026-04-22
**Current status:** Task 5.3 complete — item-source challenges implemented. Created `ItemSourceData.lua` (343 lines) with curated quest-reward IDs (50+ verified Classic items across Westfall, Barrens, STV, SM, Plaguelands, BRD, etc.) and vendor-item IDs (20+ limited-supply/faction vendor items). Renegade checker uses deny-list approach (quest rewards are forbidden, white/grey auto-passes). Off-the-shelf uses allow-list (green+ items must appear on vendor list, white/grey auto-passes). Partisan rewritten with exclusion approach — instead of an impractical "all looted items" list, checks each green+ item against ALL known non-loot sources (vendor, quest reward, profession-crafted from SelfFoundCheck) and flags unidentified items as "likely looted." `HCE.CheckItemSource()` utility traces any item ID across all three source categories. Added `/hce sources` slash command with per-slot item-source breakdown showing vendor/quest/crafted/unknown classification. Quality-based challenges (White Knight, Exotic, Footman, Grunt) were already fully functional from Task 5.1. All fourteen Lua files parse cleanly.

## Ultimate Goal

A fully functioning World of Warcraft Classic addon that introduces extra lore-based "character classes" (one per specialization of every base class) to a player's hardcore run, and tracks whether the player is complying with their chosen character's challenge requirements.

The addon is **not** a verification/auditing system like the Hardcore addon — it's purely for fun. It tells the player what their character's requirements are at all times, surfacing new requirements as they level up and those requirements become relevant.

## Source Data

- **EnhancedClasses.xlsx** (Toons sheet): 27 characters across 9 classes (Warrior, Rogue, Warlock, Druid, Hunter, Shaman, Paladin, Priest, Mage), each tied to one spec. Columns: Class, Spec, Character name, Race, Gender, Self-found, Profession, Equipment, Challenge(s), Companion, Pet, Mount, Gameplay.
- **EnhancedClasses.xlsx** (Notes sheet): Descriptions of challenge types (Anti-undead, Pro-nature, Homebound, Renegade, White Knight, Partisan, Drifter, Ephemeral, Self-made, Exotic, Off-the-shelf, Faction leader, Footman/Grunt, Diplomat, Aoe-farmer).
- **Reference addons:** Hardcore/ and UltraHardcore/ sub-folders contain working addons with similar tracking patterns.

## Current Milestone

**Milestone 5: Tracking - Challenges**

## Next Task

**Task 5.4: Behavioral challenges** — Drifter (no hearthstone/bank), Ephemeral (no repair), No Professions. Hook relevant events: USE_ITEM for hearthstone, MERCHANT_SHOW to warn about repairs, BANKFRAME_OPENED for bank access.

---

## Task Breakdown

### Milestone 1: Core Addon Skeleton + Character Detection
- [x] **1.1** Create addon scaffold (.toc, main .lua, .xml, SavedVariables, slash command, basic event frame)
- [x] **1.2** Build character data table — hardcode all 27 characters from the spreadsheet into a Lua table with structured fields (class, spec, race, gender, selfFound, professions, equipment requirements by level, challenges, companion, pet, mount, gameplay notes)
- [x] **1.3** Character detection on login — on PLAYER_LOGIN, read UnitClass, UnitRace, UnitSex to find matching character(s). If a match is found, store it in SavedVariablesPerCharacter and show a welcome message. Handle cases where multiple characters match (race+class match but gender is "Any")
- [x] **1.4** Character selection UI — if multiple matches exist, or if no match exists but the player wants to pick one manually, show a simple selection frame

### Milestone 2: Requirement Display System
- [x] **2.1** Build a requirements panel (minimap button + slash command toggle) that shows the current character's full requirement list, with level-gated items greyed out vs. active
- [x] **2.2** Implement level-gated requirement surfacing — parse the "(N)" level markers from equipment/challenge strings, and on PLAYER_LEVEL_UP (or login), highlight newly active requirements with a toast/alert
- [x] **2.3** Create a tooltip or info panel that explains each challenge type (pull from Notes sheet descriptions)

### Milestone 3: Tracking - Equipment & Items
- [x] **3.1** Equipment type tracking — on PLAYER_EQUIPMENT_CHANGED, check equipped items via GetInventoryItemID + GetItemInfo. Verify weapon types (sword, mace, staff, dagger, etc.), armor types (robe, shield, kilt), and item quality (rarity) against requirements
- [x] **3.2** Build item classification database — create Lua lookup tables for equipment requirements that map to item subtypes from GetItemInfo (e.g., "Swords" = itemSubType "One-Handed Swords" or "Two-Handed Swords"). For straightforward type-based rules (no daggers, swords only, gun only), this is reliable
- [x] **3.3** Handle visual/thematic item classification — for requirements like "shell shield," "voodoo mask," "captain's hat," "wolf helm," "lunar festival suit," "flying tiger goggles," etc., build curated item ID lists. These cannot be detected by type alone and require manual curation using a Classic WoW database
- [x] **3.4** Forbidden item alerts — when a forbidden item is equipped, show a non-intrusive warning (chat message + optional frame flash). Do NOT auto-unequip or block gameplay

### Milestone 4: Tracking - Professions & Talents
- [x] **4.1** Profession tracking — on SKILL_LINES_CHANGED (and login), iterate GetNumSkillLines/GetSkillLineInfo to find required professions and check their ranks. Starting at level 5, verify the right professions are learned. As player levels, check profession rank keeps pace (e.g., level 20 = 100 profession skill)
- [x] **4.2** Talent/spec tracking — starting at level 10, check talent point distribution. Use GetTalentTabInfo to count points in each tree and verify majority are in the correct spec tree. Alert if the player is falling behind on their spec
- [x] **4.3** Self-found tracking — check for the self-found buff on the character. For "self-made" requirements, combine buff check with curated profession-crafted item ID lists to verify equipped items are self-crafted

### Milestone 5: Tracking - Challenges
- [x] **5.1** Implement challenge rule engine — each challenge type (Homebound, Renegade, Partisan, Drifter, Exotic, etc.) gets its own checker module. Structure: a table of challenge definitions with check functions that run on relevant events
- [x] **5.2** Zone-based challenges — Homebound (continent restriction) using C_Map.GetBestMapForUnit + C_Map.GetMapInfo to detect continent. Anti-undead/Pro-nature/Anti-demon (must visit specific zones) using ZONE_CHANGED events
- [x] **5.3** Item-source challenges — Renegade (no quest rewards), Partisan (no looted gear), White Knight (only white/grey), Self-made (only self-crafted or white/grey), Off-the-shelf (only vendor gear), Exotic (no uncommon/green gear). Use curated item ID lists from Wowhead Classic DB (quest rewards, vendor items, crafted items) to check currently equipped items on PLAYER_EQUIPMENT_CHANGED. For quality-based challenges (White Knight, Exotic, Footman/Grunt), simply check item rarity from GetItemInfo
- [ ] **5.4** Behavioral challenges — Drifter (no hearthstone/bank), Ephemeral (no repair), No Professions. Hook relevant events: USE_ITEM for hearthstone, MERCHANT_SHOW to warn about repairs, BANKFRAME_OPENED for bank access

### Milestone 6: Tracking - Companions, Pets & Mounts
- [ ] **6.1** Companion (non-combat pet) tracking — detect if the correct vanity pet is summoned at the required level. Use unit checks or buff tracking for active pets
- [ ] **6.2** Hunter pet tracking — for Hunter characters, verify the tamed pet species matches requirements (e.g., "Jungle cat," "Bear"). Use UnitCreatureFamily("pet") or similar API
- [ ] **6.3** Mount tracking — at level 40+, verify correct mount is used. Mount detection via buff/aura scanning when mounted

### Milestone 7: Curated Item ID Lists (from Wowhead Classic DB)
- [ ] **7.1** Build curated item ID lists for item-source challenges — using Wowhead Classic DB filters, compile lists of: quest reward items, vendor-sold items, and profession-crafted items (per profession). These power the Renegade, Off-the-shelf, Self-made, and Partisan challenge checks
- [ ] **7.2** Build curated item ID lists for visual/thematic requirements — for each non-type-based equipment requirement, compile lists of valid item IDs. E.g., all shields that look like turtle/tortoise shells, all voodoo-style masks, all rapier/cutlass swords. Start with placeholder lists and fill them in during curation
- [ ] **7.3** Build curated item ID lists for specific named items — look up IDs for specific items referenced in requirements: flask trinkets, argent dawn trinket, firestone, spellstone, cursed amulet, guild tabard, insignia, lunar festival suit, etc.
- [ ] **7.4** Package item data as addon-embedded Lua tables — convert curated lists into .lua files that load with the addon. Keep file size reasonable by only including IDs for items that are actually relevant to character requirements

### Milestone 8: Polish & UX
- [ ] **8.1** Settings panel — allow players to toggle alerts, reposition the requirements panel, change alert sound/visual style
- [ ] **8.2** Progress summary — show a checklist-style overview of which requirements are met vs. not, with percentage completion
- [ ] **8.3** Level-up integration — on level up, show a brief summary of any new requirements that just became active
- [ ] **8.4** Gameplay suggestions panel — display the non-required "Gameplay" column tips (beer, melee weaving, /roar, etc.) as flavor text

### Milestone 9: Testing & Release
- [ ] **9.1** Test with at least 3-4 different characters across different classes/factions
- [ ] **9.2** Test edge cases: character with no profession requirement, "Any" race/gender, multiple challenge types on one character
- [ ] **9.3** Write a README with installation instructions and character list
- [ ] **9.4** Package as a distributable addon folder

---

## Completed Tasks

- **1.1** Addon scaffold — HardcoreClassesEnhanced.toc, HardcoreClassesEnhanced.lua, SavedVariables (HCE_GlobalDB, HCE_CharDB), slash commands (/hce, /hardcoreclasses), event frame (2026-04-09)
- **1.2** Character data table — CharacterData.lua with all 27 characters, challenge descriptions from Notes sheet, race alias normalisation, FindMatchingCharacters() lookup helper (2026-04-09)
- **1.3** Character detection on login — auto-detect from race/class/gender on PLAYER_LOGIN, store in SavedVariablesPerCharacter, handle 0/1/multiple matches, /hce pick <name> for manual selection, /hce status for full requirement printout with level-gated ACTIVE/greyed indicators (2026-04-09)
- **1.4** Character selection UI — SelectionUI.lua builds a draggable `BasicFrameTemplateWithInset` frame with a FauxScrollFrame list of archetypes, class-coloured names, a radio-button filter (matches vs. full class list), detail pane with full requirement breakdown and challenge explanations, Select/Cancel buttons, and double-click-to-select. Auto-opens on login when multiple matches exist; reachable via `/hce ui` or `/hce pick`. Registered in .toc. (2026-04-10)
- **2.2** Level-gated requirement surfacing — `LevelAlert.lua` builds a stackable charcoal/gold toast banner anchored top-right that slides in, holds ~6s and fades. Compares `HCE_CharDB.lastLevel` against the current level on PLAYER_LEVEL_UP and PLAYER_LOGIN and fires one toast per newly-active equipment/challenge/companion/pet/mount requirement (burst-suppressed to a single summary banner when more than 4 would fire at once so cross-session catch-up isn't spammy). `/hce alerts` toggles the whole system, `/hce testalert` previews it, and `ResyncBaseline` is called when a character is picked (slash or UI) so mid-run selections don't dump a backlog. Registered in `.toc` between RequirementsPanel and the main file. (2026-04-12)
- **2.1** Requirements panel — RequirementsPanel.lua builds a persistent, draggable sidebar frame with its own backdrop (dark charcoal + gold stripe, deliberately distinct from the popup-style selection window), a summary bar ("N / M requirements active"), scrollable body with section headers for Equipment / Challenges / Companions / Gameplay, per-row ACTIVE / lv-N tags with colour coding, lock (pin) button for position, saved frame position in HCE_GlobalDB, close button, and a custom minimap button (draggable around the minimap ring, left-click toggle panel, right-click lock toggle). Panel auto-refreshes on PLAYER_LEVEL_UP and whenever a selection is committed. Slash commands: `/hce panel` (toggle), `/hce req`, `/hce requirements`, `/hce minimap` (show/hide the minimap button). Registered in .toc between SelectionUI.lua and the main file. (2026-04-11)
- **2.3** Challenge-type info tooltips — RequirementsPanel challenge rows now show a GameTooltip on hover: gold title with the challenge name, ACTIVE/unlock status, and the full rule description from `HCE.ChallengeDescriptions`. A subtle gold highlight appears on hover. Toast banners for challenge-type requirements show a "(right-click for details)" hint in the subtitle; right-clicking a challenge toast pops the same GameTooltip with the full description. Hover and right-click tooltip both pause the toast auto-fade timer so the player has time to read. Non-challenge toasts and rows are unaffected. All five Lua files pass `load()` syntax check. (2026-04-13)
- **3.1** Equipment type tracking — `EquipmentCheck.lua` registers PLAYER_EQUIPMENT_CHANGED and PLAYER_LOGIN, takes a full equipment snapshot via GetInventoryItemID + GetItemInfo, and runs each active equipment requirement through a rule registry. Weapon type rules use locale-independent classID/subclassID: swords (1H+2H), maces, axes, staves, daggers, fist weapons, guns, wands, polearms, thrown, 2H weapons. Armor/slot rules: shield detection, robe vs chest via INVTYPE_ROBE, empty-slot checks. Negative rules: no daggers, no wands, no guns, no robes, no chest. Combo rules: "dagger and sword", "mace or axe", "sword or mace", "staff or pole". Results stored in HCE_CharDB.equipResults. Chat warnings fire only on NEW violations. Integrated into RequirementsPanel with ✓/✗/? indicators and hover tooltips. (2026-04-14)
- **3.2** Item classification database — built into EquipmentCheck.lua. Weapon classID=2 with all WoW Classic subclassID constants (0=1H Axe through 20=Fishing Pole). Armor classID=4 with subclassIDs (cloth/leather/mail/plate/shield). Convenience groupings for multi-type rules (SWORDS, MACES, AXES, TWO_HANDED, etc.). Curated item ID placeholder tables (`HCE.CuratedItems`) for 30+ visual/thematic requirements ready for Milestone 7 population. Flying Tiger Goggles (4368) and Green Tinted Goggles (4385) pre-filled as known IDs. (2026-04-14)
- **3.3** Visual/thematic item classification — created `CuratedItems.lua` which populates `HCE.CuratedItems` with verified WoW Classic item IDs. Confirmed entries: Flying Tiger Goggles (4368), Green-tinted Goggles (4385 + Green Lens 10500), Gnomish Goggles set (10500, 10501, 10546, 10548), Warlock Firestone (1254/13699/13700), Warlock Spellstone (5522/13602/13603), Wolfshead Helm (8345), Guild Tabard (5976), Festival Dress/Suit (21509/21510), Blue Linen Shirt (1770) + Blue Martial Shirt (2575), First Mate Hat (12251). Added `HCE.CuratedComplete` set: Flying Tiger Goggles, Firestone, Spellstone, and Guild Tabard marked definitive. `EquipmentCheck.slotInCurated` and `anySlotInCurated` were updated so lists that are NOT marked complete return UNCHECKED (with a "N items approved so far" message) on a miss instead of a false FAIL. Added `/hce curated` slash command that prints a per-list count, complete/empty/partial tag, and totals. Registered `CuratedItems.lua` in the .toc after `EquipmentCheck.lua`. All seven Lua files parse cleanly. Remaining thematic lists (kilt, cowl, voodoo mask, cursed amulet, shell shield, torch, anti-beast gear, unholy weapon, armored weapon/off-hand/rings, staff-like off-hand, shadow/fire wand, etc.) are left with clear `TODO(M7)` markers for the Milestone 7 curation pass. (2026-04-15)
- **3.4** Forbidden-item alerts — created `ForbiddenAlert.lua` which fires a red-accent toast, a brief red screen-edge vignette pulse, and an IG_QUEST_FAILED chime when a NEW equipment violation surfaces. Toast reuses LevelAlert's charcoal body + gold border for family resemblance but swaps the gold left-stripe for a red stripe and adds a dim red wash on the headline plate so it's unambiguously "you broke a rule" not "something unlocked". Toasts stack in their own column (y=-500) below the LevelAlert column to avoid overlap. Edge-flash covers the full UIParent at BACKGROUND strata with four gradient textures that taper toward the centre, 0.12s fade-in / 0.18s hold / 0.60s fade-out at 35% peak alpha. `EQ.CheckAndWarn` now snapshots old status up front (since RunCheck mutates `HCE_CharDB.equipResults`) and passes new-violation entries to `ForbiddenAlert.FireBatch`, which suppresses sound+flash on the 2nd/3rd toasts and collapses to a single summary toast when >3 fire simultaneously so first-login with multiple violations doesn't strobe. Global toggle `HCE_GlobalDB.forbiddenAlertsEnabled` (default true) exposed via `/hce forbidden`; `/hce testforbidden` previews it. Registered `ForbiddenAlert.lua` in the .toc after `CuratedItems.lua`. All eight Lua files parse cleanly. (2026-04-16)
- **4.1** Profession tracking — created `ProfessionCheck.lua` (422 lines). Uses `IsSpellKnown()` with hardcoded learn-spell IDs (Alchemy=2259, Blacksmithing=2018, Enchanting=7411, Engineering=4036, Herbalism=2366, Leatherworking=2108, Mining=2575, Skinning=8613, Tailoring=3908, Cooking=2550, First Aid=3273, Fishing=7620) for locale-independent profession detection. Then scans `GetNumSkillLines/GetSkillLineInfo` in a three-pass matcher to read rank numbers even on non-English clients: pass 1 direct name match, pass 2 cached locale name, pass 3 unmatched-pair heuristic. Expected rank formula `5 * playerLevel` (starts level 5, caps at 300). Results stored in `HCE_CharDB.profResults`. RequirementsPanel now has a PROFESSIONS section header (between race/gender row and EQUIPMENT) with ✓/✗/? indicators and hover tooltips showing `"Alchemy rank 105 / 150 (expected 100 at lv 20)"` style detail. Chat warnings fire once per profession per state transition — "not learned" and "falling behind" — using the gold `[HCE]` prefix, NOT the red ForbiddenAlert toast. Warning state resets on `/hce pick` and `/hce reset`. Added `/hce professions` and `/hce prof` slash commands. Panel also listens to SKILL_LINES_CHANGED for live refresh. Registered in .toc after ForbiddenAlert.lua. All nine Lua files parse cleanly via lupa `load()`. (2026-04-17)

- **4.2** Talent/spec tracking — created `TalentCheck.lua` (422 lines). Uses `GetNumTalentTabs`/`GetTalentTabInfo` with locale-independent tab indices (positional 1/2/3). Hardcoded `SPEC_TAB` mapping for all 9 classes and 27 specs. Starting at level 10, checks that the player's expected spec tree has a plurality of talent points (strictly more than any other tree individually). Results stored in `HCE_CharDB.talentResults`. RequirementsPanel now has a TALENTS section between PROFESSIONS and EQUIPMENT with ✓/✗/? indicators and hover tooltips showing per-tree point breakdown. Chat warnings fire once per session when talent allocation diverges — "no points spent" or "wrong spec leading" — using the gold `[HCE]` prefix, NOT the red ForbiddenAlert toast. Added `/hce talents`, `/hce talent`, and `/hce spec` slash commands. Warning state resets on `/hce pick` and `/hce reset`. Panel listens to CHARACTER_POINTS_CHANGED for live refresh. Registered in `.toc` after `ProfessionCheck.lua`. All ten Lua files parse cleanly via lupa `load()`. (2026-04-18)

- **5.1** Challenge rule engine — created `ChallengeCheck.lua` (450+ lines). Central challenge registry with checker functions for all 19 challenge types. Quality-based: White Knight (white/grey only), Exotic (no uncommon), Footman/Grunt (no rare/epic) scan all gear slots via `getEquipSnapshot()`. Armor-type: Cloth/leather and Mail/plate verify `classID`/`subclassID` on body armor slots. Profession: No professions uses `IsSpellKnown` with hardcoded spell IDs for all 12 professions. Pet: Imp checks `UnitCreatureFamily("pet")` for locale-safe detection; No demon checks `UnitCreatureType("pet")` with multi-locale keyword table. Item-source: Renegade/Partisan/Off-the-shelf wired to curated lists (`quest_rewards`, `looted_gear`, `vendor_items`) — return UNCHECKED until Milestone 7 populates them. Self-made/Self-made guns delegate to SelfFoundCheck. Zone-based (Homebound) and behavioral (Drifter, Ephemeral, Mortal pets) stub as UNCHECKED with "planned in task 5.x" messages. Reputation (Faction leader, Diplomat) stub as UNCHECKED. Results stored in `HCE_CharDB.challengeResults`. RequirementsPanel CHALLENGES section updated: all challenge rows now show ✓/✗/? indicators with hover tooltips combining challenge description + check detail. Chat warnings fire once per challenge on state transitions; forbidden-alert toasts on new failures. Added `/hce challenges` (and `/hce challenge`, `/hce ch`) slash commands. `CC.ResetWarnings()` wired into pick/reset flows. Panel listens to UNIT_PET for pet-related challenge changes. Registered in `.toc` after `SelfFoundCheck.lua`. All twelve Lua files parse cleanly via lupa `load()`. (2026-04-20)

- **5.3** Item-source challenges — created `ItemSourceData.lua` (343 lines) with curated quest-reward IDs (50+ verified Classic items) and vendor-item IDs (20+ limited-supply/faction vendor items). Renegade checker uses deny-list: quest_rewards is a blocklist, white/grey auto-passes. Off-the-shelf uses allow-list: green+ must be on vendor_items list. Partisan rewritten with exclusion approach — instead of maintaining an impractical looted_gear list, checks green+ items against ALL known non-loot sources (vendor/quest/crafted via `HCE.CheckItemSource()`) and flags unidentified items as "likely looted." Quality-based challenges (White Knight, Exotic, Footman, Grunt) were already fully functional from Task 5.1. Added `/hce sources` slash command with per-slot item-source breakdown. Registered `ItemSourceData.lua` in `.toc` after `ChallengeCheck.lua`. All fourteen Lua files parse cleanly. (2026-04-22)

- **5.2** Zone-based challenges — created `ZoneCheck.lua` (456 lines). Continent detection via `C_Map.GetBestMapForUnit` + `C_Map.GetMapInfo` hierarchy traversal: walks `parentMapID` upward until `mapType == 2` (Continent), with cycle guard. Race→home-continent mapping for all 8 Classic races (Alliance EK: Human/Dwarf/Gnome; Alliance Kalimdor: Night Elf; Horde Kalimdor: Orc/Troll/Tauren; Horde EK: Undead). Homebound challenge fully implemented: `ZC.CheckHomebound()` compares current continent to home continent, with persistent violation tracking in `HCE_CharDB.homeboundViolated` — once the player leaves their home continent the violation sticks (clearable via `/hce reset`). Zone-visit tracking for Anti-undead (10 zones), Pro-nature (4 zones), Anti-demon (7 zones), and Aoe-farmer (5 zones) using curated uiMapID lists. On `ZONE_CHANGED_NEW_AREA` / `ZONE_CHANGED`, records current zone in `HCE_CharDB.visitedZones` and prints a thematic notification if relevant to the character. Zone-visit challenge rules registered in ChallengeCheck.lua as informational UNCHECKED checkers (aspirational goals, not hard restrictions). `ZONE_CHANGED_NEW_AREA` added to ChallengeCheck event frame and RequirementsPanel for live refresh on zone transitions. Added `/hce zones` (and `/hce zone`, `/hce homebound`) slash commands. `ZC.ResetTracking()` wired into pick/reset flows. Registered `ZoneCheck.lua` in `.toc` between `SelfFoundCheck.lua` and `ChallengeCheck.lua`. All thirteen Lua files parse cleanly via lupa `load()`. (2026-04-21)

- **4.3** Self-found & self-made tracking — created `SelfFoundCheck.lua` (768 lines). Self-found buff detection uses a three-strategy approach: (1) spell-ID scan against known candidate IDs for locale-independent detection, (2) English name-based partial match as fallback, (3) `AuraUtil.FindAuraByName` if available. Self-made challenge checks all 19 equipment slots: items with quality 0–1 (white/grey) always pass; higher-quality items must appear on curated profession-crafted ID lists. Starter curated lists seeded for Tailoring (35 items), Blacksmithing (33 items), Leatherworking (35 items), and Engineering (22 items) with verified Classic item IDs; remaining professions have placeholder tables for Milestone 7. Separate `EngineeringGuns` table (10 items) powers the "Self-made guns" challenge. Results stored in `HCE_CharDB.selfFoundResults`. RequirementsPanel summary row now shows self-found ✓/✗/? with hover tooltip. CHALLENGES section shows ✓/✗/? for "Self-made" and "Self-made guns" rows with combined tooltip. Chat warnings fire once per session. `/hce selffound` (and `/hce selfmade`, `/hce sf`) prints full per-item breakdown. Warning state resets on pick/reset. Panel listens to UNIT_AURA. Registered in `.toc` after `TalentCheck.lua`. All eleven Lua files parse cleanly. Milestone 4 complete. (2026-04-19)

---

## Bottleneck Analysis & Feasibility

### What CAN be tracked reliably (via WoW Classic API)

1. **Class, Race, Gender** — `UnitClass("player")`, `UnitRace("player")`, `UnitSex("player")`. Rock solid. Gender returns 2=male, 3=female.

2. **Equipped item type** (swords, maces, daggers, staves, shields, guns, etc.) — `GetInventoryItemID("player", slot)` + `GetItemInfo(itemID)` returns itemType and itemSubType. These are stable across all languages/locales and use item IDs (integers), NOT names. This means "no daggers," "swords only," "gun only," "staff only," "shield required" are all fully trackable.

3. **Item quality/rarity** — `GetItemInfo()` returns rarity as integer (0=poor/grey, 1=common/white, 2=uncommon/green, 3=rare/blue, 4=epic/purple). Challenges like "White Knight" (white/grey only), "Exotic" (no green), "Footman/Grunt" (no rare/epic) are fully trackable.

4. **Talents/spec** — `GetSpellTabInfo(tabIndex)` gives info per talent tree. We can count points per tree to determine majority spec. Fully trackable from level 10 onward.

5. **Professions and their levels** — `GetNumSkillLines()` + `GetSkillLineInfo(index)` returns profession name and current rank. Fully trackable.

6. **Zone/continent detection** — `C_Map.GetBestMapForUnit("player")` + `C_Map.GetMapInfo()` with parentMapID traversal to determine continent. Homebound challenge is fully trackable.

7. **Item count and inventory** — `C_Container.GetContainerItemID(bag, slot)` and `GetItemCount()`. Can check for specific items like trinkets, pouches, torches.

8. **Events for behavioral restrictions** — `BANKFRAME_OPENED` (Drifter/no bank), `MERCHANT_SHOW` (Ephemeral/no repair), hearthstone usage via spell cast tracking. All hookable.

### What CAN be tracked with manual item curation (medium effort)

9. **Visual/thematic items** — Requirements like "shell shield," "voodoo mask," "captain's hat," "wolf helm," "lunar festival suit," "flying tiger goggles," "gnomish goggles," "rapier," "cutlass," "harpoon" are NOT detectable by item type alone. They require curated lists of specific item IDs. This is doable because:
   - Item IDs are stable integers (work in all languages)
   - Classic WoW has a finite, known item pool
   - Databases like dkpminus/Classic-Wow-Database provide full item dumps
   - Each thematic requirement only needs maybe 5-50 specific items identified

   **This is the single biggest manual effort in the project** but it's a solvable problem, not a blocker.

10. **Specific trinkets** — "flask trinkets," "argent dawn trinket," "firestone," "spellstone," "cursed amulet" — these are specific items with known IDs. Just need to look them up once.

11. **Mount verification** — Specific mounts (wolf, ram, frostsaber, skeletal horse) are items or spells with known IDs. Trackable via buff/aura detection when mounted.

12. **Non-combat pet verification** — Pets like owl, cockroach, parrot, phoenix, prairie dog, snow rabbit, black cat, mechanical pets are summoned companion items with known IDs.

### What CAN be tracked via curated item ID lists (from Wowhead Classic DB)

The following challenges were originally flagged as "difficult" but are actually straightforward using a **curated list approach**. Wowhead Classic (e.g., https://www.wowhead.com/classic/items/armor/leather/slot:8) provides filters for item source (quest reward, vendor, crafted, etc.), so we can pre-build definitive item ID lists for each challenge type. Since this is a casual addon that only needs to check the **current state** of the character (not acquisition history), these are all fully trackable:

13. **Self-found** — Self-found is a **buff** on the character in WoW Classic. We can simply check for the buff's presence. Combined with curated lists of profession-crafted items, we can verify "self-made" requirements: if the player has the self-found buff AND the equipped item is on the crafted-items list for their profession, it's self-made. **Fully trackable.**

14. **"Self-made" crafted items** — Build curated item ID lists of all items craftable by each profession (Wowhead has "Created by" source filters). On PLAYER_EQUIPMENT_CHANGED, check if equipped items appear on the relevant profession's crafted list. No need to track crafting events. **Fully trackable via curated lists.**

15. **Quest reward detection (Renegade)** — Build a curated item ID list of all quest reward items from Wowhead (source filter: "Quest"). On equip, check if the item ID is in the quest-reward list. No need to hook QUEST_COMPLETE or QUEST_TURNED_IN. **Fully trackable via curated lists.**

16. **Vendor-purchased items (Off-the-shelf)** — Build a curated item ID list of all vendor-sold items from Wowhead (source filter: "Vendor"). On equip, check if the item ID is in the vendor list. No need to hook MERCHANT_SHOW. **Fully trackable via curated lists.**

17. **Stat thresholds (attack power, intellect, spirit)** — Requirements like "120 attack power (50)" mean unbuffed stats from gear only. Use `GetInventoryItemID` + tooltip scanning to sum up stat contributions from equipped items, excluding buffs. **Fully trackable.** (Note: `UnitAttackPower` / `UnitStat` include buffs and base stats, so we specifically want tooltip scanning for gear-only stats.)

18. **Companion "always summoned" enforcement** — We can detect if a pet is currently summoned, but enforcing "must always have pet out" is tricky (pet despawns on death, zoning, etc.). Best approach: periodic check + gentle reminder, not hard enforcement.

### What CANNOT be tracked (true blockers or limitations)

19. **Item visual appearance** — WoW Classic has no transmog API. We cannot programmatically determine what an item *looks like*. For "shell shield" (a shield that looks like a tortoise shell), we must pre-build the list of matching item IDs by manually reviewing items in a database. This is not a blocker (see point 9), just manual work.

### Design philosophy: current-state tracking only

This is a casual, fun addon — not an audit system. It only checks the **current state** of the character (what's equipped right now, current profession levels, current talent distribution, current zone, etc.). It does NOT attempt to track item acquisition history or enforce rules retroactively. This simplifies the entire design: no need for event-based acquisition logging, no "pre-addon-install" problem, no imperfect tracking caveats.

### Locale/Language Considerations

- **Item IDs are integers and locale-independent.** This is the biggest win. All item tracking should use IDs, never names.
- **Item type/subtype strings from GetItemInfo are localized** (e.g., "One-Handed Swords" in English vs. "Einhandschwerter" in German). For type-based checks, use `GetItemClassInfo(classID)` and `GetItemSubClassInfo(classID, subClassID)` with numeric class/subclass IDs, or compare item class/subclass IDs directly (returned as additional values from `GetItemInfo()`).
- **Profession names from GetSkillLineInfo are localized.** We'll need a small locale table mapping profession IDs or using the spell ID approach instead of name matching.
- **Zone names are localized** but `C_Map` uses numeric map IDs, which are locale-independent. Use map IDs for zone checks, not zone name strings.

**Bottom line: The addon should use numeric IDs everywhere possible. For the few places where string matching is needed (profession names), maintain a locale lookup table. The addon is fully buildable in English first, with localization as a follow-up.**

---

## Blockers / Decisions Needed

1. **Classic WoW database integration** — The dkpminus/Classic-Wow-Database repo: should we download and parse it as part of the build process, or manually extract the item IDs we need and hardcode them? The full DB is large; embedding it all would bloat the addon. Wowhead Classic DB filters can also be used for curation.

## Resolved Decisions

- **Item curation scope** — Start with placeholder lists for visual/thematic items; fill them in during curation phase (Milestone 7).
- **Self-found tracking** — Self-found is a buff; just check for it. Combined with curated profession-crafted item lists for "self-made" checks. No event-based acquisition tracking needed.
- **Profession level scaling formula** — Linear: 5 profession skill per player level (level 20 = 100, level 40 = 200, level 60 = 300).
- **Pre-addon history** — Not needed. Addon only checks current character state. It's a casual fun addon, not an audit system.
