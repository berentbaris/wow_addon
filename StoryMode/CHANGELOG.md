# Changelog

## 1.9.4

### Classic Era
- **The List** now shows any named Scarlet figure you have already brought down, struck through, even when its stage has not been reached yet — earned names are never hidden

### Fixes
- Fixed a Lua error when tracking a story step whose guidance comes from a quest without an ID, such as **Test of Faith** for **Test of Lore**

### Maintenance
- Bumped addon metadata to `1.9.4`

## 1.9.3

### Burning Crusade Classic
- Added support for TBC Classic 2.5.6 interface `20506` while retaining `20505` compatibility

### Retail
- Added support for WoW Retail 12.1.0 interface `120100` while retaining `120005` and `120007` compatibility

### Maintenance
- Bumped addon metadata to `1.9.3`

## 1.9.2

### Classic Era
- Added support for WoW Classic Era 1.15.9 interface `11509` while retaining `11507` compatibility

### Maintenance
- Bumped addon metadata to `1.9.2`

## 1.9.1

### Classic Era
- Added a hidden secret to **The Scarlet Crusade**: slaying 100 Scarlet-named foes reveals **The Scarlet Crusader**, a fourth crimson journal tab telling the story of your private war, with a live tally that keeps counting
- Added **The List**, a hunt roster of the Crusade's named figures — names are struck through in crimson as you bring them down, and the roster grows in stages as the ledger deepens
- Added quiet ledger pages at higher tallies, saving the name **Voss** for a late reveal
- Added kill notes and a banner the first time each named figure falls, plus rare banners at the ledger's deepest milestones
- Added unattributed chat whispers that foreshadow the secret before it reveals itself
- Added a persistent chat link when the secret reveals itself, so the moment can be found again
- Added a shareable ledger countersign chat link that only other revealed Scarlet Crusaders can see as a link
- Added a capstone at five thousand: the ledger stops showing its number
- Localized the kill detection for all supported client languages and gated it to NPC kills only

### Localization
- Translated all Scarlet Crusader secret text into German, Spanish, French, Brazilian Portuguese, and Russian, using each locale's official NPC names
- Reworded the in-combat error to name Story Mode instead of "this UI" across all locales

### Fixes
- Guarded story and quest chat links against being linkified twice, which could render shared links with broken formatting

### Maintenance
- Bumped addon metadata to `1.9.1`

## 1.9.0

### Classic Era
- Corrected **Secrets of Uldaman** to use the Uldaman loading-screen cover and faction-appropriate first quest giver chapter portraits

### Retail
- Added **A Blue Dawn**, covering Kalecgos and the restored blue dragonflight questline
- Added retail short stories for **Rhea's Last Egg**, **Runas the Shamed**, **Stay a While**, and **Mourning Rise**
- Set new chapter portraits to the first quest giver's NPC face wherever each chapter begins
- Added full supported-locale coverage for the new retail story text
- Assigned explicit high-quality cover textures to the new retail stories, preferring dungeon loading screens where available
- Moved longer retail chains over ten quests from **Short Stories** into **Stories**
- Added Fuselight prerequisite tracking for **Rhea's Last Egg** when Rhea does not offer the opening quest yet
- Replaced **Runas the Shamed**'s low-resolution Eye of Azshara UI cover with a high-resolution Nightborne loading-screen cover

### Localization
- Replaced the Russian progress and level dividers with `|` to avoid a missing-glyph square in the Russian client font

### Maintenance
- Bumped addon metadata to `1.9.0`

## 1.8.9

### Retail
- Added support for WoW Retail 12.0.7 interface `120007` while retaining `120005` compatibility

### Maintenance
- Bumped addon metadata to `1.8.9`

## 1.8.8

### Classic Era
- Added **The Hakkari Trail**, covering Yeh'kinya, the Mosh'aru Tablets, Hakkar, and the road to Zul'Gurub
- Added **The Scythe of Elune** as an Alliance story linking Ashenvale, Velinde Starsong, Duskwood, and the worgen mystery
- Adjusted chapter portraits to prefer the first quest giver's face when NPC display data is available
- Corrected **Raene's Cleansing** to use the Blackfathom Deeps loading screen cover
- Corrected **The Scarlet Crusade** so **Tyr's Hand** uses Nathanos Blightcaller's Classic portrait
- Added **Scholomance** coverage for the Skeleton Key, Sarkhoff/Kirtonos chain, Ras Frostwhisper, and Barov inheritance quests
- Added **Maraudon** coverage for Vyle corruption, the Scepter of Celebras, Theradras, Zaetar, and the Seed of Life
- Added **Secrets of Uldaman** coverage for Hammertoe, the Shattered Necklace, the Tablet of Will, and the Platinum Discs
- Added full supported-locale coverage for the new Classic story text

### Quest Guidance
- Corrected **Compendium of the Fallen** so undead characters do not see it, while other Horde characters can pick it up without a prerequisite
- Clarified **Hearts of Zeal** chat guidance so **Going, Going, Guano!** is named as the prerequisite

### Localization
- Filled remaining supported-locale story and content fallbacks for German, Spanish, French, Portuguese, and Russian
- Fixed second-pass German and Spanish prose QA findings where generated translations left English source sentences in localized story text
- Removed invisible generated spacing artifacts from supported locale files
- Corrected mixed English title residues in localized prose, including Ebon Hold/Ebon Blade references, **The Way Forward**, **The Search for Baine**, **The Argent Crusade**, and Gracina Spiritmight name splits
- Updated **The Writhing Deep** title and recap text to official localized quest names in all supported locales

### Maintenance
- Added a dev-only localization fill tool and tightened the localization audit so English fallback keys fail validation
- Added dev-only localization quality-pass tooling for official quest-name lookups and glossary drift candidate reports
- Added a dev-only prose quality audit to catch source-sentence and embedded source-title residue in localized content
- Expanded localization validation to fail hidden Unicode spacing artifacts
- Hardened official quest-title QA to skip Wowhead English fallback names before suggesting replacements
- Bumped addon metadata to `1.8.8`

## 1.8.7

### Quest Guidance
- Corrected **Hearts of Zeal** guidance so it points players to complete **Going, Going, Guano!** before returning to Master Apothecary Faranell for the follow-up
- Renamed the Yenniku story to **Hunt for Yenniku** to keep the title focused on the search

### Maintenance
- Bumped addon metadata to `1.8.7`

## 1.8.6

### Classic Era
- Added **Nothing But The Truth** as a Classic/TBC Horde short story, covering the Forsaken agents at Beggar's Haunt and Stonard's prisoner
- Added **The Shady Rest Inn** as a Dustwallow Marsh short story for Alliance and Horde investigators, with faction-specific clue paths and the later hidden-hand chapter
- Corrected **Compendium of the Fallen** guidance so it points Horde players to retrieve the book from Scarlet Monastery, then return to Sage Truthseeker with linked and color-styled chat output

### Localization
- Added full supported-locale coverage for **The Shady Rest Inn**

### UI
- Improved minimap button compatibility with minimap button grabbers and broker-style collectors
- Kept the Story Mode minimap icon visible instead of fading it out when idle
- Refreshed quest-card tooltips in place when Blizzard finishes loading quest data so first-hover details can fill in without hovering again
- Corrected Shaman Farseer campaign chapter art so chapter nodes use the first quest giver portrait
- Made manual chapter watched/played flags character-specific so new characters start with fresh chapter state
- Kept optional-only chapters unfinished until their optional quest is actually completed
- Prevented account-wide achievements from marking quest-based chapters complete on fresh characters
- Limited quest checkmarks to exact character quest completion while allowing required chapter progress to infer passed chain steps
- Refreshed the selected chapter node immediately after marking a chapter watched or played
- Corrected Castle Nathria's Aftermath so its dungeon side quest stays optional without blocking chapter completion
- Added prerequisite-style guidance to manual watched/played and branch-gated chapters so players know where to view, replay, or continue them
- Set the Sylvanas manual/replay/branch guidance chapters to use rectangle chapter nodes
- Stabilized story and quest chat-link opens so first-time Classic clicks build the window before selecting the linked page

### Maintenance
- Bumped addon metadata to `1.8.6`

## 1.8.5

### Classic Era
- Added **Poor Old Blanchy** as a Classic/TBC Alliance short story
- Expanded **Poor Old Blanchy** into a small Furlbrow family arc with **The Forgotten Heirloom** and optional **Furlbrow's Deed** context
- Added optional **Test of Lore** coverage to **The Scarlet Crusade**, with guidance that sends players to the **Test of Faith** chain starter first
- Updated Classic/TBC short-story cover art: **Poor Old Blanchy** now uses Ruined City, **Hogger** uses Dungeon, and **A New Plague** uses Scholomance

### UI
- Aligned Story Mode's private tooltip styling with Blizzard tooltip templates while keeping the taint-safe custom tooltip behavior
- Hardened Story Mode chat filters so non-Story Mode chat messages pass through with their original arguments untouched

### Maintenance
- Bumped addon metadata to `1.8.5`

## 1.8.4

### Classic Era
- Removed **Chen's Empty Keg** from the Short Stories collection
- Removed **Timbermaw Hold** from the Classic story collection
- Added **A King's Tribute** as a Classic Alliance short story
- Aligned **Cortello's Riddle** and **Linken's Adventure** cover art with Classic/TBC-safe loading screens
- Reworked Classic story descriptions, summaries, recaps, and intro copy to better match the tone of original Classic quest text while avoiding heavy spoilers
- Added refreshed Classic story text translations across supported locales

### UI
- Added shift-click sharing for story and quest cards, with Story Mode users seeing clickable chat links and other players seeing readable plain text
- Updated Story Mode quest chat prints to include clickable quest links while preserving the original print colors
- Updated shared story and quest links so clicking them opens the correct story page and chapter
- Rebuilt the Story Mode intro/card artwork around split background and layout images, with a smaller card overlay and no extra card text/icon overlay
- Refined the Story Mode intro and completed-overview copy
- Added a hover glow for the borderless minimap icon style
- Brightened the Retail Story Mode card artwork while keeping its native frame treatment

### Retail
- Updated **Lion's Heritage** to use the Deadmines loading screen as its cover art

### Maintenance
- Updated release packaging so CurseForge and Wago receive only the current version's changelog notes
- Updated GitHub Actions packaging checkout to `actions/checkout@v5`
- Refreshed the CurseForge project description for the current Story Mode pitch
- Bumped addon metadata to `1.8.4`

## 1.8.3

### Classic Era
- Added **Hunt for Yenniku**, a Horde Stranglethorn Vale story for the level 30-45 gap
- Added **Souvenirs of Death** and **Dangerous!** as optional **Battle of Hillsbrad** side quests, with **Dangerous!** placed in the town-and-mine chapter
- Improved **Arugal and Shadowfang Keep** guidance so parallel dungeon quests point players to their actual quest givers

### UI
- Added a right-click minimap icon style menu so players can choose between the current borderless icon and Blizzard's default AddOn border
- Updated the minimap tooltip to show both left-click open and right-click style actions
- Tuned the bordered minimap icon layout separately for Retail and Classic/TBC so the masked icon sits centered in the default border
- Expanded Retail story panel scroll areas slightly on the left panel top/bottom and right panel bottom while leaving Classic/TBC spacing unchanged
- Moved Classic/TBC suggested level text onto the adventure cover under the title divider
- Kept gated chapter nodes circular on Classic clients while preserving square gated nodes on Retail
- Removed the disabled **More Coming Soon** category from all clients

### Maintenance
- Bumped addon metadata to `1.8.3`

## 1.8.2

### UI
- Fixed Russian and other non-Latin clients showing square glyphs in Story Mode's custom tooltips by using Blizzard's locale-aware tooltip font

### Localization
- Added Spanish locale coverage for European and Latin American Spanish clients (`esES`/`esMX`)
- Added Brazilian Portuguese locale coverage (`ptBR`)
- Added Spanish and Brazilian Portuguese TOC notes and included the new locales in localization audit tooling
- Closed the remaining Classic recap translation gaps across German, Spanish, French, Brazilian Portuguese, and Russian

### Maintenance
- Added GitHub Actions packaging for tag-driven GitHub, CurseForge, and Wago releases, plus `.pkgmeta` release-zip rules
- Refactored story list card construction into focused helpers without changing the visible layout
- Centralized story category assignment so localization and registration share the same content registry
- Tightened localization and recap coverage audits and added `_Dev/tools/prepare-release.mjs` for repeatable release checks
- Bumped addon metadata to `1.8.2`

## 1.8.1

### UI
- Added an **Active Stories** section below the Story Mode intro card for stories with quests currently in the player's quest log
- Active stories are temporarily removed from their normal categories while pinned, avoiding duplicate cards in the story list
- Refreshed the left story list when quest-log changes alter the active story set while preserving the selected story and scroll position

### Maintenance
- Added localized **Active Stories** category labels for German, Spanish, French, Brazilian Portuguese, and Russian clients
- Bumped addon metadata to `1.8.1`

## 1.8.0

### Classic Era
- Fixed the Classic/TBC rogue poisons story to point Alliance players to Master Mathias Shaw and Horde players to Shenthul instead of a generic rogue trainer
- Fixed Classic/TBC class quest starter guidance across class stories, including more specific trainer/NPC routing where the quest does not come from every trainer
- Added **Deathstalkers in Shadowfang** to the Classic/TBC **Arugal and Shadowfang Keep** dungeon chapter

### Localization
- Added locale loading for German (`deDE`), French (`frFR`), and Russian (`ruRU`)
- Added translated addon UI strings for German, French, and Russian clients, with English fallback for untranslated story content
- Added localized TOC notes for German, French, and Russian clients
- Added German, French, and Russian translations for addon-owned story titles, descriptions, summaries, notes, and recap text
- Added `_Dev/tools/localization-audit.mjs` to track locale coverage and placeholder safety across locale files
- Added `_Dev/tools/recap-coverage.mjs` to verify recap translation coverage across supported locales

### Maintenance
- Exposed a small quest-accepted suppression API so companion addons can avoid restyling Story Mode quest accepted lines
- Added quest guidance audits for missing NPC locations, map/location mismatches, class/faction availability, and chain holes, plus documented exceptions for intentionally curated quest paths
- Completed the quest-audit cleanup pass so active quest audit findings are zero, with curated order, chain, and source limitations tracked through documented exception files
- Aligned quest-card clicks with **Begin This Story** and **Continue Story** behavior so direct quest-card tracking uses the same location guidance, map opening, and completed-quest messages
- Added native guidance snapshots and availability aliases to catch bad map targets such as Legion Dalaran vs. class hall submaps
- Bumped addon metadata to `1.8.0`

### Retail
- Audited and corrected quest starters, NPC locations, map targets, and criteria handoffs across Retail campaigns, heritage stories, and storylines
- Corrected audited NPC portrait display IDs across Retail campaigns, heritage stories, and storylines to match the quest-starter models used by Wowhead
- Corrected **A Tea Party** guidance so **Teddies and Tea** points to the quest location players see in-game
- Fixed Suramar/Insurrection startup guidance so Archmage Khadgar points to the Violet Citadel in Legion Dalaran instead of the Hall of Shadows
- Marked completed Suramar Nightfallen prerequisite chapters through **Nightfallen But Not Forgotten** so completed characters are not sent back to **Khadgar's Discovery**
- Updated the Retail story-card selected state to reuse the native hover highlight while the Story Mode window is open

## 1.7.0

### Classic Era
- Added four lower-level Classic/TBC storylines: **Arugal and Shadowfang Keep**, **The Tower of Althalaxx**, **Raene's Cleansing**, and **Battle of Hillsbrad**
- Added Classic/TBC story level guidance using minimum required quest level through maximum quest level, shown on story cards and story introductions
- Sorted stories within each category by their lowest suggested level so earlier Classic stories appear higher in the list
- Added **Consumed by Hatred** to the **Lost in Battle** Mankrik story
- Fixed **Continue Story** on Classic/TBC so quests already in the player's log open the selected quest log entry instead of only printing chat guidance

### Maintenance
- Split Classic level-guide formatting into `Code/Core/LevelGuide.lua` and loaded it from all TOCs
- Split questline registration and story-data normalization into `Code/Core/Registry.lua`
- Added stable story IDs for saved selection, progress-cache invalidation, and normalized quest metadata
- Cached chapter, campaign, and next-quest progress calculations between quest-log events
- Returned structured tracking results from quest tracking while preserving existing chat behavior
- Split event, slash-command, and quest-completion handling into `Code/Core/Events.lua`
- Added registry-backed story quest lookup indexes for quest IDs and quest names
- Added UI refresh hooks for story cards/current detail plus coalesced detail layout scheduling
- Added Classic faction IDs for Timbermaw Hold and Brood of Nozdormu to the metadata audit map
- Added shared keyed scheduling/debounce helpers, story-state snapshots, and a reusable UI frame-pool helper
- Split the loading-screen browser and achievement/story-state resolution out of `StoryMode.lua`
- Split story-list card building, selection, scroll restore, and targeted row refresh into `Code/UI/StoryList.lua`
- Updated quest accepted/completed events to refresh the affected story row when the changed story is known
- Fixed Retail login-time story registration so faction/race/class stories are not filtered before player identity is ready
- Fixed Retail expansion availability so stories are not hidden by an early or unstable expansion-level API value during login
- Fixed Retail story registration so Classic/TBC-only data gaps do not stop later Retail stories from appearing
- Fixed the Classic/TBC **Begin Story** button by using the normal click path there instead of the Retail secure waypoint overlay
- Centralized Classic/Retail client checks behind compatibility helpers and refreshed story state on level-up
- Added `_Dev/tools/check-core-behavior.mjs` to guard TOC module loading and the `StoryMode.lua` local-count budget
- Added `_Dev/tools/validate-story-data.mjs` for local story schema and TOC coverage checks
- Refactored `StoryMode.lua` to reduce main-scope locals and avoid Lua's 200-local limit
- Bumped addon metadata to `1.7.0`

## 1.6.6

### Classic Era
- Added five Classic/TBC storylines: **The Battle of Darrowshire**, **Linken's Adventure**, **The Princess of Ironforge**, **Timbermaw Hold**, and **The Scepter of the Shifting Sands**
- Added a `/sm loadingscreens` browser for available loading-screen cover art, then updated several Classic story covers with closer matches including Caverns of Time, Blackwing Lair, Ahn'Qiraj, Zul'Gurub, Maraudon, Blackrock Depths, Ruins of Lordaeron, and Naxxramas
- Corrected Classic story NPC portrait display IDs across Darrowshire, Linken, Timbermaw, Princess Moira, Shifting Sands, Duskwood, Onyxia, Fallen Hero, Missing Diplomat, Defias, and Mankrik's Wife
- Fixed the Horde rogue poisons class quest zone label so it no longer points Horde players to Westfall
- Hid the Journal faction card section on Classic/TBC clients while keeping Retail faction cards unchanged

### UI
- Added Story Mode quest-accept chat messages for story quests, including the accepted quest name and the story it belongs to, while hiding Blizzard's default accepted line for those story quests
- Aligned quest-click chat messages with the Story Mode prefix, arrow styling, and yellow quest-name treatment used elsewhere
- Added the quest name to pickup guidance messages and removed mixed quotation/color styling around quest names
- Fixed Classic left-panel flicker when switching stories from Progress or Journal tabs by avoiding empty contextual panel swaps

### Maintenance
- Bumped addon metadata to `1.6.6`

## 1.6.5

### Classic Era
- Added **The Brazier of Invocation** as a Classic/TBC epic storyline for the Dungeon Set 2 upgrade chain, including level gating, class-specific quest variants, faction-specific starting cities, chapter portraits, and Blackrock-themed cover art
- Added **The Agamand Family** as a Classic/TBC short story covering Brill, the Agamand Mills, and the family crypt
- Expanded Classic/TBC story coverage for **The Scarlet Crusade**, **The Long Watch**, **The Missing Diplomat**, and **The Defias Brotherhood** with additional quest steps, corrected quest names, NPCs, locations, and portrait sources
- Refined Classic/TBC class quest cards with more specific zone labels and class-flavored dungeon or raid cover art, including Blackrock Depths for warriors, Wailing Caverns for druids, Dire Maul for mages and warlocks, Molten Core for priests and hunters, Scholomance for paladins, Stockade for rogues, and Sunken Temple for shamans

### UI
- Added clickable quest cards: clicking an in-log quest opens the quest log, clicking a missing quest prints pickup guidance, clicking a completed quest prints a completion message, and Story Mode closes before handing control back to the game
- Added Classic story-card active styling with persistent gold borders, brighter border hover, and the original subtle fill hover
- Updated Classic chapter navigation arrows to use the native spellbook previous/next page textures instead of rotating the right arrow for the left arrow
- Improved quest-card state display so quests already in the log stay visually active, including alternate quest IDs
- Replaced UI-generated straight quotation marks around quest names with curly quotes

### Fixes
- Fixed the hidden locked-story tracking overlay so its tooltip no longer bleeds over other screens after leaving a locked story
- Removed the experimental lock overlay from locked story cards and restored the cleaner card presentation

## 1.6.0

### Fixes
- Fixed a taint error caused by the "Begin This Story" map ping reparenting an insecure frame onto the secure WorldMap canvas, which propagated into AreaPOI tooltip widget setup (`secret number` arithmetic on `textHeight`). The ping is now a proper `MapCanvasDataProvider` with a `StoryModePingPinTemplate`, registered through `WorldMapFrame:AddDataProvider`
- Pings now land on the actual quest icon by querying Blizzard's live pin location (`C_QuestLog.GetNextWaypointForMap` for tracked quests, `C_QuestLog.GetQuestsOnMap` for offered quests), falling back to hardcoded `npcLocations` only when the engine doesn't know the position
- Fixed Adventure Guide tier lookup taint by wrapping `EJ_SelectTier` calls in `securecall`, preventing later loot tooltip money-frame errors after Story Mode searches for cover art
- Hid the Story Mode window automatically when combat starts to avoid protected-frame interaction during lockdown
- Fixed Classic Era "Begin This Story" errors by skipping retail-only world-map waypoint and ping behavior on Classic/TBC clients
- Fixed story card completion badges for stories with lore-only, replayable, achievement, or optional chapters, including **The Banshee Queen** and its optional Windrunner Spire epilogue
- Optional chapters now remain visible in the chapter track without blocking the main story from reaching **Story Finished**
- Fixed Classic story data quest givers for Scarlet Crusade, Defias, Duskwood, Fallen Hero, Missing Diplomat, and Onyxia chains after auditing against Classic quest data
- Fixed Scarlet Crusade's Deathknell chapter to start from Executor Arren, including its starting location, recap text, and chapter portrait source

### Maintenance
- Restructured addon files into root TOC metadata, `Code/`, `Data/`, `Locales/`, `Art/`, and `_Dev/tools/` folders to prepare for additional game-version TOCs and localization work
- Added a Plumber-style localization loader with the current English UI strings in `Locales/enUS.lua`
- Added the current English dataset content strings to the localization table and localize questline data at load time, preparing story titles, descriptions, chapters, recaps, notes, quest names, NPC labels, zones, expansions, and lookup keys for future locale files
- Added client-specific TOCs for Classic Era (`StoryMode_Vanilla.toc`, interface `11507`) and Burning Crusade Classic (`StoryMode_TBC.toc`, interface `20505`)
- Added `Code/Core/Compatibility.lua` for older client fallbacks around quest completion, quest log lookup, objective text, achievements, addon loading, reputation data, minimap tracking, and map pings
- Added client expansion filtering so Classic Era and TBC load the addon shell while hiding story datasets from later expansions until version-specific content is added
- Limited Classic/TBC TOCs to shared addon code plus Classic-compatible story data, avoiding later-expansion datasets on older clients

### UI
- Reworked the chat tracking messages: yellow `Story Mode` prefix with a chevron separator, narrator-voice phrasing (`Now following …`, `Seek <npc> in <zone> to begin …`, `Your next chapter is … with … in …`), no more stacked colons or em-dashes
- Added Classic/TBC-specific frame fallbacks for missing retail atlas art while preserving the existing retail presentation
- Reworked Classic story cards, quest cards, progress view, and chapter track styling with Classic-safe borders, solid hover/backdrop layers, hidden scrollbars, and larger circular chapter portrait rings
- Updated Classic tracking guidance to avoid map-pin language, reference the quest name, and include readable NPC locations such as Northshire Abbey, Sentinel Hill, Lakeshire, and Stormwind districts
- Restored the retail Journeys texture divider while keeping Classic/TBC on their simpler divider fallback
- Updated the main Story Mode card to receive a completion ribbon when every visible story is finished, with a new completion message for players who have cleared the full curated library
- Matched the two main Story Mode panel borders to the default Trading Post frame color instead of the brighter custom gold tint
- Refined Classic window borders, story card sizing, minimap button scale, chapter arrows, track navigation arrows, quest-card arrows, and story card zone text truncation
- Added the completed-story intro state to the Story Mode overview and tightened Classic left-panel scroll insets so content no longer touches the frame border
- Added Classic chapter-level requirements to quest cards and the story start button so locked class quest chapters use the same level-gate behavior as retail story locks
- Updated the Classic "quest already in log" message to say the quest was already picked up and nudge the player to read the quest log for the next objective
- Restored completed Adventure pages to show the disabled **Story Finished** button instead of the **Campaign Complete** checkmark text
- Preserved the left story list scroll position when selecting story cards

### Content
- Added **The Defias Brotherhood** as the first Classic/TBC storyline, covering the Alliance Westfall investigation, Deadmines finale, Unsent Letter, Stockade riot, Lescovar conspiracy, and audience with King Varian Wrynn
- Expanded **The Defias Brotherhood** to begin in Northshire and Elwynn with **Brotherhood of Thieves**, **Milly Osworth**, **Milly's Harvest**, **Bounty on Garrick Padfoot**, **Fine Linen Goods**, **The Collector**, and **Manhunt**
- Added Classic NPC display IDs, area labels, and chapter/story portrait sources for the Defias storyline
- Added **The Scarlet Crusade** as a Classic/TBC epic storyline with Horde Forsaken war chapters, Alliance Monastery lead-in quests, Scarlet Monastery dungeon chapters, and the Tirion/Taelan Fordring Plaguelands finale
- Added **The Long Watch** as a Classic/TBC Alliance Duskwood storyline, covering the Night Watch, Raven Hill, Mor'Ladim, Stalvan, worgen, Morbent Fel, Abercrombie, and Stitches
- Added **The Fallen Hero of the Horde** as a Classic/TBC epic storyline, covering the Horde and Alliance lead-ins to the Blasted Lands, Loramus, Felbane, Razelikh, and the full **You Are Rakh'likh, Demon** chain
- Added **The Missing Diplomat** as a Classic/TBC Alliance epic storyline, following the investigation from Stormwind and Duskwood to Menethil, Theramore, Jaina, and the disappearance of King Varian
- Added **Onyxia and the Black Dragonflight** as a Classic/TBC cross-faction epic storyline, covering the Alliance Windsor/Prestor reveal, the Horde Rexxar/Emberstrife tests, and both Drakefire Amulet attunement paths
- Added **Mankrik's Wife** as a Classic/TBC Horde short story for the Barrens **Lost in Battle** quest
- Added Classic/TBC class quest storylines for druids, hunters, mages, paladins, priests, rogues, shamans, warlocks, and warriors, including iconic ability, tool, mount, and epic weapon chains
- Updated Classic/TBC cover art to use closer dungeon or zone loading screens for the current Classic story set, including Barrens-adjacent art for Mankrik's Wife and Swamp of Sorrows-adjacent art for Fallen Hero
- Retitled several Classic story cards to shorter in-game-flavored names, including **Lost in Battle**, **A Tale of Sorrow**, and **The Drakefire Amulet**
- Expanded **The Banshee Queen** with the Shadowlands Sylvanas bridge from Torghast visions through Chains of Domination, Sanctum of Domination, Shattered Legacies, Domination's Grasp, Crown of Wills, Sepulcher of the First Ones, and Judgment, plus the War Within **The Warning** campaign with Arator in the Maw
- Extended **The Banshee Queen** through the post-Jailer aftermaths with **Silent Vigil**, the loyalist **The Long Hunt** epilogue, and an optional **Windrunner Spire** chapter using the normal dungeon achievement
- Refined **The Banshee Queen** chapter text, cover art, warning-chain quest giver data, and Sepulcher flow, including the **Heart of the Sepulcher** handoff and the Windrunner Spire loading screen cover
- Expanded **The Master of Revendreth** with Castle Nathria aftermath quests, the Redemption for the Redeemer beat, and corrected Sire Denathrius achievement tracking
- Added exploration achievements to Drustvar, The Jade Forest, Nazmir, Revendreth, and Suramar adventure achievement lists
- Removed **The Klaxxi** from Epic Storylines after playtesting showed the flow was not strong enough for the curated story list
- Audited quest IDs, titles, NPCs, locations, chapter portraits, achievement IDs, and faction reputation IDs across the current story set with repeatable local validation tools
- Fixed stale Suramar Insurrection and Nightfallen quest IDs, including Arcway/Court of Stars optional steps, Crafting War faction variants, and the Kel'danath/Waning Crescent side flow
- Corrected stale or mismatched achievement entries for Nazmir, Jade Forest, and the Battle for Lordaeron replay chapter

## 1.5.0

### Maintenance
- Bumped addon version to `1.5.0`
- Updated addon metadata with the plain **Story Mode** title, refreshed notes text, and the new addon icon asset
- Split quest progress helpers and waypoint tracking helpers out of `StoryMode.lua` into `Core/Progress.lua` and `Core/Tracking.lua`
- Cleaned storyline achievement lists to keep story-relevant achievements only, using normal/base dungeon and raid clears plus normal boss kills where applicable
- Cleaned chapter hint behavior so notes only appear on gated/squared chapters with actionable unlock steps; removed misleading legacy Wrath notes
- Added gated hints for Rogue "Hiding In Plain Sight" and the Forsaken loyalist epilogue so squared chapters always explain their prerequisite
- Added faction-aware achievement selection so faction-specific story achievements, including The Jade Forest's Upjade Complete, resolve to the player's faction variant

### Content
- **The Master of Revendreth** — new epic storyline for the Revendreth zone (Shadowlands). Covers the full seven-chapter zone campaign: arrival in Darkhaven, Denathrius and the Court of Harvesters, the Accuser, the Penitent Hunt, Theotar and the Ember Ward, Prince Renathal's rescue, and the reveal that Denathrius is funneling anima to the Maw
- Added Revendreth story and chapter portraits using verified display IDs for Denathrius, Rendle, the Accuser, the Fearstalker, Theotar, and Prince Renathal
- Added Revendreth-related achievements for Loremaster, Sojourner, Halls of Atonement, Sanguine Depths, and Castle Nathria
- Refreshed story, campaign, and heritage descriptions and linked each track to a thematically matching Encounter Journal cover source
- Re-enabled **The Klaxxi** in Epic Storylines and positioned it after **What Is Worth Fighting For**
- Fixed **The Klaxxi** starting guidance so "Begin This Story" points to Bowmistress Li on the Serpent's Spine instead of opening the Dread Wastes map without a waypoint, added a first-chapter note about the wall/rope route and Zidormi phasing, and set Bowmistress Li as the first chapter portrait
- Added faction reputation data to story journals across the current story set, including The Klaxxi, What Is Worth Fighting For, Suramar, BfA zone stories, Revendreth, Frozen Throne, Lilian Voss, Sylvanas, and A Tea Party
- Renamed the Jade Forest story to **What Is Worth Fighting For** so the adventure title reflects the campaign's theme instead of repeating the zone name
- Added the **What Is Worth Fighting For** dungeon finale quest **Deep Doubts, Deep Wisdom** and corrected **Restoring Jade's Purity** to Priestess Summerpetal, including her chapter portrait display ID

### UI
- Removed the portrait border from the Introduction card so only the flame icon is shown
- Adjusted the left story list scroll area to use the full panel height with only border-width top/bottom padding
- Greyed incomplete achievement borders while keeping the square frame crisp and layered above the icon
- Renamed the first detail tab to Adventure and moved completed chapter recaps into a new Journal tab after Progress
- Swapped Adventure cover art to use high-resolution dungeon and raid loading screen textures when a matching instance loading screen is available, falling back to Encounter Journal art otherwise
- Added large Adventure cover art sourced from Blizzard's Encounter Journal images for story, campaign, and heritage pages, with a soft fade mask and title overlay
- Updated the left adventure list cards to show the selected adventure's cover image as the active card background, with white title text, yellow zone text, and no separate custom gradient overlay
- Replaced the left adventure completion badge with a Housing Dashboard-style ribbon using Blizzard's task flag and checkmark atlases
- Fixed the Jade Forest "Orchard and Quarry" chapter portrait so it uses Old Man Misteye instead of falling through to Shao the Defiant
- Fixed the Jade Forest "The Temple of the Jade Serpent" chapter portrait so it uses Foreman Raike's verified display ID
- Added Journal faction cards with Housing Dashboard card art, circular reputation progress, faction standing text, hover states, and reputation tooltips
- Added a "Factions" section heading to the Journal tab and removed the Journal/Achievements hero title block for a cleaner content-first layout
- Removed the Progress tab portrait while keeping the story title and tightened its title, summary, and chapter-track spacing
- Replaced the intro page flame icon with custom Story Mode hero art, refreshed the intro copy, and updated the intro card to use the custom addon icon
- Updated the left intro divider to greet the current character by name
- Updated the minimap button to use the custom addon icon without the fake shadow layer
- Hid the detail scrollbar when the active view has no scrollable overflow
- Laid out the left Achievements section with up to five icons per row spanning the same width as the faction grid, with each row independently centered
- Shrunk the faction card name and status label fonts and tightened the spacing between them while increasing the gap from the icon
- Made faction cards clickable: closes Story Mode and opens the matching Renown UI for major factions or the Reputation tab for legacy factions, expanding any collapsed headers and scrolling the list to the selected faction
- Fixed faction-card clicks failing to reopen the reputation window on subsequent attempts by deferring the panel toggle and only re-toggling when the target panel is hidden
- Allowed story achievement entries to be specified by name and resolved case-insensitively at runtime, and added Stay Klaxxi and Amber Is the Color of My Energy to the Klaxxi storyline
- Story list cover art now renders for every card (selected and unselected) at full alpha, with selection feedback handled solely by the highlight overlay
- Held the Achievements and Factions grid widths to the panel's fixed content width to prevent layout jumps when the window is reopened after a faction-card click
- Added a start-quest coordinate fallback so stories with `startMapID`, `startX`, and `startY` can still set a native waypoint when a specific NPC location is missing

---

## 1.4.0

### Fixes
- Fixed taint propagation from the Track button — resolved `attempt to perform arithmetic on a secret number value` error originating from Blizzard_MoneyFrame when hovering world-quest tooltips. Track now routes through a secure macro (`SecureActionButtonTemplate`) so OpenWorldMap, quest watch, and waypoint calls execute in a trusted context
- Fixed `Cannot anchor protected frames to regions` error — the secure overlay is now a sibling of sTrackBtn (parented to detailChild) rather than a child of it, so sTrackBtn itself remains anchor-eligible for FontString layout
- Combat guard on UI toggle — attempting to open or close Story Mode while in combat now shows an error hint at the top of the screen instead of silently failing or tainting the frame
- **Quest counts now match chapter sums** — story card totals were inflated because `GetCampaignProgress` counted every raw quest regardless of faction, optional, or hidden status. Now applies the same three filters as chapter progress: `IsQuestForPlayer`, `not q.optional`, `not ShouldHideQuest`
- **Story complete banner now fires reliably** — the chapter/story completion check was running synchronously on `QUEST_TURNED_IN` before `IsQuestFlaggedCompleted` was guaranteed to be updated; moved inside the existing 0.1s timer
- **Story card checkmark updates live** — checkmark on the left panel story card was only set at window build time and required a `/reload` to appear after finishing a story; now updated immediately when the story completes
- **Story complete detection no longer blocked by loreOnly/achievement chapters** — `allDone` check was treating chapters with `t == 0` (no trackable quests) as incomplete; skips them correctly now
- Fixed achievement tooltip rewards that return boolean values from Blizzard's API, preventing a crash when hovering achievements such as Temple of the Jade Serpent Guild Run
- Restored visible hover feedback on dimmed chapter nodes and the Continue Story button

### New
- **Replayable chapters** — chapters marked `replayable = true` show a "Mark as Played" button backed by `StoryModeDB.playedChapters`; hides quest cards and the achievement row so the button is the sole interaction. Applied to "The Battle for Lordaeron" (Archivist Sylvia replay)
- `ShouldHideQuest` helper — `showIf` / `hideIf` conditions now filter quest cards and progress counting, not just completion checks

### Maintenance
- Split self-contained systems out of `StoryMode.lua` into `Core/SavedVariables.lua` and focused `UI/*` modules for the private tooltip, minimap button, and completion banners. This reduces the main Lua chunk's local-variable count and prevents WoW's Lua 5.1 `main function has more than 200 local variables` load error from recurring during small refactors

### Content
- **The Jade Forest** — new epic storyline for the Jade Forest zone (Mists of Pandaria), rebuilt as a full guided campaign with separate Alliance and Horde openings, faction-specific quest flow, shared Dawn's Blossom / Tian Monastery / Jade Serpent chapters, zone achievements, and a Temple of the Jade Serpent dungeon finale using the dungeon achievement art
- **The Klaxxi** — new epic storyline for the Dread Wastes zone (Mists of Pandaria). Five chapters: awakening the first paragons at Klaxxi'vess, amber crafting at Kypari Zar, Skeer the Bloodseeker and Kaz'tik's kunchong, the maritime chaos of Soggy's Gamble, and the final assault on the Heart of Fear. Includes a note on the SoO betrayal payoff
- **The Dark Heart of Nazmir** — new Horde-only epic storyline for the Nazmir zone (Battle for Azeroth). Covers all 8 achievement chapters: meeting Bwonsamdi and forging the pact for one million souls, the bat loa Hir'eek's corruption, Torga's death, Krag'wa in Gloom Hollow, the Titan Keeper facility and G'huun containment, and the final assault on Grand Ma'da Ateena. Parallel to The Witchwood of Drustvar
- **Sylvanas — The Banshee Queen** extended through Dragonflight 10.1.7: added "Stay of Execution", "Breaking the Cycle", "What Comes After", "The Long Hunt", and "A Chilling Summons" chapters; Shadowlands intro now has separate Horde/Alliance entry quests with faction filtering
- **Lilian Voss** — added "What Comes After" chapter covering the Horde Council formation quests (including The Hidden Need, 57376); updated BfA portrait to display ID 85799
- **The Frozen Throne** — Saronite Mines chapter updated to use Darkspeaker R'khem; added Intelligence Gathering and The Grand Admiral's Plan chest quests; significant quest chain expansion
- **Jade Forest, Allies of the Forest** — corrected first Horde quest giver from Shademaster Kiryn to Sergeant Gorrok; added Gorrok to `npcDisplayIDs` (39047); extended chapter recap with bridge into Chapter 3

---

## 1.3.4

### Fixes
- Fixed quest cards for mixed Alliance/Horde chapters — opposing-faction quests are now hidden and the positioning chain skips them cleanly
- Fixed Tides of Vengeance achievement in Lilian Voss showing the Alliance variant — corrected to Horde (13466)
- Removed a misidentified Quel'delar quest from the Banshee Queen Frozen Halls chapter
- Changed chapter icon from 30721 to 341221

### New
- Per-quest faction filtering — quests tagged `faction = "Alliance"` or `faction = "Horde"` are invisible to the opposing side in progress tracking, next-quest suggestions, and the quest card list
- All faction variants in The Frozen Throne are now tagged (Dragonblight prelude, Angrathar, Icecrown Vanguard, Gates of Icecrown, Sindragosa's Fall, Frozen Halls arc)
- Broken Shore chapter (Banshee Queen) expanded from 2 to 6 quests — added the Legion Returns muster quest and three optional Illidari follow-up quests in Orgrimmar
- Per-chapter faction filtering — chapters tagged `faction` are only shown to matching faction players

### Content
- Updated Frozen Halls entry note — no Chromie Time needed, just land in Northrend Dalaran
- Updated Broken Shore entry note — removed "Horde only" since Alliance players won't see this storyline anyway
- Added achievements across all storylines: Suramar (Nighthold wings + prestige kills + Glory meta), Lilian Voss (Scarlet dungeons + bonus achievements + BfA war campaign), Banshee Queen (Frozen Halls dungeons + bonus + BfA campaign + Zereth Mortis), Jaina (Kul Tiras zone story + four dungeons + Battle of Dazar'alor), Drustvar (Waycrest Manor dungeon completions + bonus)
- **The Frozen Throne (Arthas) rebuild** — restructured the entire storyline:
  - Restructured chapters 1-7: Recruiting the Taunka, Destroy the Nerubians, Annexing the Taunka, The Forsaken Plague, The Red Dragonflight, Victory Over the Scourge, The Betrayal
  - Added full Dragonblight Alliance campaign (Wintergarde) with its own chapter and separate Alliance versions of Red Dragonflight and Victory Over the Scourge
  - Removed obsolete "The Betrayal" chapter (quests no longer obtainable)
  - Added portraitDisplayID to each chapter and story-level chapterDisplayIDs table for faction-split portrait rendering
  - Updated chapter portraits: Emissary Brighthoof (23805) for Recruiting the Taunka, Overlord Agmar (23806) for Nerubians/Chapters 2/5, Icemist (23976) for Annexing, Middleton (23875) for Forsaken Plague, Saurfang (23034) for Victory Over Scourge, Fordragon (24879) for Alliance chapters, Foehammer (24351) for Dragonblight Campaign
  - Rewrote all chapter recaps in narrative style matching the Banshee Queen storyline
  - Recaps now include the Forsaken betrayal and blight attack at the Wrathgate

---

## 1.3.3

### Fixes
- Fixed quests falsely marked complete while actively in-progress — chain inference now stops if any earlier quest is still in the player's log
- Fixed all Banshee Queen chapters showing as complete during active questing
- Fixed quest card checkmarks not updating until `/reload` — detail panel now re-renders immediately on `QUEST_TURNED_IN`

### Content
- **The Banshee Queen (Sylvanas) full rebuild** — removed three unplayable limited-time chapters and a fabricated chapter with made-up quest IDs; replaced with four fully playable chapters spanning five expansions:
  - **The Frozen Halls** (Wrath) — Forge of Souls → Pit of Saron → Halls of Reflection dungeon chain
  - **The War for Silverpine** (Cataclysm) — Forsaken march into Silverpine; Sylvanas raises the dead against Garrosh's orders
  - **Cities in Dust** (Cataclysm) — Ruins of Gilneas campaign and Godfrey's resurrection
  - **The Broken Shore** (Legion) — Vol'jin names Sylvanas Warchief in his final moments
- Extended **Testing Loyalties** chapter (Lilian Voss) — added six quests following "Under False Colors" through the Warfang Hold summit
- Rewrote all chapter requirement messages to be actionable — version numbers replaced with plain instructions on where to go and what to do

### New
- Story completion screen: when the final chapter of a storyline is finished, a center-screen message fades in with the story title and "Story Finished", with gold gradient lines above and below
- Quest and chapter completion banners fire on `QUEST_TURNED_IN` in real time
- Test commands: `/sm banner`, `/sm chapter`, `/sm complete`

---

## 1.3.2

### Fixes
- Fixed persistent taint errors ("secret number value") when hovering world-quest POIs — replaced the private `GameTooltip` frame with a plain `BackdropTemplate` frame that has no connection to the GameTooltip C layer, eliminating both the `EmbeddedItemTooltip` and `MoneyFrame` taint chains for good
- Fixed tooltip crash (`GetWordWrap` nil value) caused by FontString not exposing that method — wrap state is now tracked in a parallel table
- Fixed Lua "more than 200 local variables" error — tooltip helpers are scoped inside a `do/end` block

### Polish
- Tooltip minimum width raised to 220px; minimap tooltip sizes to content only

---

## 1.3.1

### Fixes
- Corrected addon name casing: "StoryMode" → "Story Mode" in all user-facing chat messages and tooltips
- Minimap button tooltip now reads "Click to open" instead of "Click to toggle"

### Organisation
- Moved **Daughter of the Sea** (Jaina) and **Sylvanas** from Epic Storylines → Character Stories
- Zone labels on story cards now show at most two zones (truncated with … when there are more)

---

## 1.3.0

### New Content
- Added a new Epic Storyline: **Daughter of the Sea** (Jaina Proudmoore) — four chapters spanning Battle for Azeroth
  - A Nation Divided — Jaina returns to Kul Tiras in chains
  - Enemies Within — Priscilla Ashvane's conspiracy in Tiragarde Sound
  - The Pride of Kul Tiras — recovering the lost fleet across four dungeons; Jaina becomes Lord Admiral
  - The Fog of War — Jaina leads the Alliance assault on Zuldazar (8.1)
- Added new **Short Stories** category
- Added first Short Story: **A Tea Party** (Drustvar) — Abby Lewis's tea party in Glenbrook Homestead

### Fixes
- Fixed `EmbeddedItemTooltip` taint error ("secret number value") when hovering world quest POIs — StoryMode now uses a private `GameTooltip` frame and no longer touches the shared global
- Fixed ping frame strata (`TOOLTIP` → `HIGH`) to prevent world map frame layout interference
- Fixed Lilian Voss — The Marshal's Grave: "Operation: Grave Digger" and "Operation: Water Wise" moved to optional and no longer block chapter entry; chains now start from the correct in-zone quest

---

## 1.2.3

### Fixes
- Fixed MoneyFrame taint error ("secret number value") when hovering world quest POIs or bag items while StoryMode is loaded — tooltip now uses a named `GameTooltip` frame instead of the shared global
- Fixed scrollbar position in the detail pane — shifted 8px to align correctly within the panel
- Added 2px inset around right-panel content so text no longer sits flush against the border

### Content
- Added Nighthold achievement (42030) to the Insurrection (Suramar) achievements list
- Marked Drustvar as Alliance-only — Horde players cannot access the full zone storyline without Chromie Time

---

## 1.2.2

### Fixes
- Fixed completed quests showing stale `0/N` objective counters in tooltips — objectives are now hidden for completed quests
- Fixed detail pane content being clipped by 8px on the right and bottom edges
- Removed reputation indicators from chapter notes, quest lock tooltips, and track-node hover tooltips

### Content
- Added achievement 42628 to the Insurrection (Suramar) achievements list

### Organisation
- Moved all data files into category subfolders: `Heritage/`, `Campaigns/`, `Storylines/`
- Updated `StoryMode.toc` load order to reflect new paths

---

## 1.2.1

### Fixes
- Replaced custom tooltip implementation with native `GameTooltip` — eliminates clipping, missing titles, and incorrect sizing
- Marked "Feed Valtrois" in Suramar's Feeding Shal'Aran chapter as optional — no longer blocks chapter completion or shows as "not yet available" when skipped
- Added generic `optional = true` quest flag support: optional quests are excluded from chapter progress totals and rendered with a distinct dimmed style

---

## 1.2.0

### New Content
- Added a new Epic Storyline: **The Banshee Queen** (Sylvanas Windrunner) — seven chapters spanning Battle for Azeroth and Shadowlands
  - The March on Darkshore (War of Thorns, Week 1)
  - The Burning of Teldrassil (War of Thorns, Week 2)
  - The Battle for Lordaeron
  - The Fate of Saurfang (8.1)
  - Before the Gates of Orgrimmar — Mak'gora (8.2.5)
  - Death Rising — pre-patch Scourge invasion and Helm shattering
  - Judgment — Sylvanas faces Tyrande's verdict in Zereth Mortis (9.2)

### Fixes
- Fixed wrong achievements showing in Suramar Insurrection — removed chapter-level achievement IDs (10757–10766) that pointed to unrelated content (cooking achievements, Azsuna quests)
- Fixed duplicate "Might of Dragonblight" in The Frozen Throne — Alliance (35) and Horde (1359) are faction variants of the same achievement; removed both
- Trimmed Suramar to five core chapters — removed five side recruitment chapters (Moon Guard Stronghold, Tidying Tel'anor, Breaking The Lightbreaker, Jandvik's Jarl, Eminent Grow-main)
- Achievements tab is now hidden for story chains that have no associated achievements; switching to such a chain while on the tab falls back to Story

### Improvements
- Achievement row tooltip now shows full description, all criteria with completion icons, reward text, and earned date
- Clicking an achievement row opens the Achievement UI, navigates to that achievement, and closes the StoryMode window
- All twelve Legion class campaigns now include four shared cross-class achievements: Glory of the Legion Hero (10746), Breaching the Tomb (10994), Legionfall Commander (11171), Defender of the Broken Isles (11223)
- Rogue class campaign additionally includes Hidden Potential of the Shadowblade (42295)
- Added heritage achievements: Forsaken — Return to Lordaeron (15579), Worgen — Reclamation of Gilneas (19719)
- Row hover now shows a subtle gradient fade instead of the default highlight texture
- Section divider gradient opacity reduced from 0.8 → 0.2
- Achievement icon border switched to `talents-node-square-gray` atlas, tinted gold

### Packaging
- Bumped addon version to `1.2.0`
- Added `SylvanasData.lua` to load order in `StoryMode.toc`

---

## 1.1.0

### New
- Added a major new Epic Storyline: **The Frozen Throne** (Arthas Menethil)
- Added a dedicated campaign data module: `FrozenThroneData.lua`
- Added broad Wrath narrative coverage including:
  - Culling of Stratholme
  - Wrathgate arc and Dragonblight prelude quests
  - Core Icecrown war chapters
  - Frozen Halls lead-in through Halls of Reflection

### Data Updates
- Expanded quest coverage for the Arthas campaign to include narrative prerequisites and faction variants where applicable
- Removed the non-narrative completionist ledger chapter to keep the campaign story-focused
- Updated key NPC portrait display IDs for accuracy: High Commander Halford Wyrmbane, Crusade Commander Entari, Thassarian, Matthias Lehner

### UI / Organization
- Registered **The Frozen Throne** under `Epic Storylines`
- Updated campaign listing documentation in `README.md`

### Packaging
- Bumped addon version to `1.1.0`
- Added `FrozenThroneData.lua` to load order in `StoryMode.toc`

---

## 1.0.2

### Fixes
- Fixed quest state detection for in-progress campaign steps so active quests are no longer incorrectly marked completed
- Fixed completion handling for final chapter quests by removing cross-chapter completion inference that caused false positives in optional/out-of-order content
- Fixed left-panel story card selection mapping so each card opens the correct storyline after category layout changes
- Fixed completed-campaign card rendering and progress consistency so finished stories show complete state across cards, header text, and totals

### UI
- Added a new `Character Stories` category and moved the Lilian Voss storyline into it
- Updated journal header copy to show `Your Story` when a storyline is finished (`Your Story So Far` while in progress)

### Packaging
- Bumped addon version to `1.0.2`

---

## 1.0.1

### Heritage Image Corrections
- Fixed heritage story card portraits so race entries no longer reuse stale images from previously viewed stories
- Fixed heritage chapter portrait rendering logic to prevent question-mark carryover and ensure per-chapter portrait updates apply correctly
- Corrected portrait source priority for heritage chapters (explicit chapter IDs/icons, then first-quest NPC portrait, then fallback path)
- Corrected multiple race-specific heritage card and chapter image IDs based on validation (Blood Elf, Orc, Tauren, Gnome, Worgen, Draenei, Pandaren, Night Elf, Dwarf, Dark Iron Dwarf, Goblin, Forsaken)
- Added/updated explicit heritage chapter portrait mappings where needed to stabilize first chapter visuals
- Improved heritage card image selection so configured card icons are respected in the list view

### Packaging
- Bumped addon version to `1.0.1`

---

## 1.0.0

### New
- Added race-based Heritage Armor questlines under the `Identity` category: Blood Elf, Dark Iron Dwarf, Draenei, Dwarf, Forsaken, Gnome, Goblin, Human, Night Elf, Orc, Pandaren, Tauren, Troll, Worgen
- Added chapter prerequisite handling so locked chapters now surface the exact required quest
- Added reputation requirement support on chapters (currently used in Suramar chapters)

### Improved
- Improved next-step tracking so chapter locks and prerequisites are shown clearly in chat guidance
- Improved chapter detail notes to display unmet prerequisite quests and reputation gates
- Improved chapter tooltips to include current reputation progress when a chapter has rep requirements
- Added race filtering so questlines only appear for characters that can actually do them
- Added fallback chapter generation for lightweight questline data that only defines a start quest
- Updated category naming from `Class Identity` to `Identity`

### Data Updates
- Updated Suramar NPC portrait display IDs for better portrait accuracy
- Added prerequisite requirement for the Rogue campaign chapter **Hiding In Plain Sight** (`Armies of Legionfall`)

### Packaging
- Updated addon version to `1.0.0`
