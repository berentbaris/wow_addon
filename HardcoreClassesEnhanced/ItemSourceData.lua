----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Item Source Data
--
-- Curated item ID lists for item-source challenge checks:
--   Renegade  → quest_rewards (deny-list: these items are forbidden)
--   Off-the-shelf → vendor_items (allow-list: only these are permitted)
--   Partisan  → uses EXCLUSION: items not on vendor/quest/crafted lists
--              are presumed looted (no standalone looted_gear list needed)
--
-- Each table maps itemID → provenance string.  The checking logic in
-- ChallengeCheck.lua only tests key existence; the value is a paper
-- trail for the human curator.
--
-- Population status:
--   These are STARTER SEEDS from well-known Classic WoW items.  Full
--   curation is deferred to Milestone 7 where Wowhead Classic DB
--   filters (source: "Quest" / "Vendor") will generate exhaustive lists.
--
-- How to expand these lists (Milestone 7):
--   Quest rewards:
--     https://www.wowhead.com/classic/items?filter=128;1;0
--     (Source = Quest, grouped by zone/level range)
--   Vendor items:
--     https://www.wowhead.com/classic/items?filter=128;5;0
--     (Source = Vendor, grouped by NPC / item type)
--
-- All IDs are WoW Classic 1.13.x stable item IDs (same as vanilla).
----------------------------------------------------------------------

HCE = HCE or {}
HCE.CuratedItems = HCE.CuratedItems or {}
HCE.CuratedComplete = HCE.CuratedComplete or {}

local C = HCE.CuratedItems
local COMPLETE = HCE.CuratedComplete

----------------------------------------------------------------------
-- Helper
----------------------------------------------------------------------

local function fill(tbl, entries)
    for _, pair in ipairs(entries) do
        tbl[pair[1]] = pair[2] or true
    end
end

----------------------------------------------------------------------
-- Ensure the item-source tables exist (ChallengeCheck.lua creates
-- them too, but we load after ChallengeCheck so either order works)
----------------------------------------------------------------------

C.quest_rewards = C.quest_rewards or {}
C.vendor_items  = C.vendor_items  or {}
C.looted_gear   = C.looted_gear   or {}  -- kept for API compat; Partisan uses exclusion now

----------------------------------------------------------------------
-- QUEST REWARD ITEMS
--
-- Items awarded by quest completion in WoW Classic.  Used by the
-- Renegade challenge ("cannot equip quest reward gear").
--
-- Sourced from Wowhead Classic quest reward filters and cross-checked
-- against well-known levelling quest chains.
----------------------------------------------------------------------

fill(C.quest_rewards, {
    -- =================================================================
    -- STARTER ZONES (1-12)
    -- =================================================================

    -- Elwynn Forest (Human 1-12)
    { 1388,  "Stormwind Guard Leggings — Bounty on Garrick Padfoot" },
    { 1360,  "Stormwind Chain Gloves — A Threat Within" },
    { 1992,  "Swiftness Potion Schematic — reward (skipped: recipe)" },

    -- Dun Morogh (Dwarf/Gnome 1-12)
    { 2218,  "Craftsman's Dagger — Tundra MacGrann's Stolen Stash" },
    { 3107,  "Dwarven Tree Chopper — Protecting the Herd" },
    { 6186,  "Trogg Slicer — The Public Servant" },

    -- Teldrassil (Night Elf 1-12)
    { 5593,  "Feral Blade — Zenn's Bidding" },
    { 5594,  "Thornroot Club — Crown of the Earth" },
    { 5595,  "Thicket Hammer — The Emerald Dreamcatcher" },

    -- Tirisfal Glades (Undead 1-12)
    { 3265,  "Rattlecage Buckler — Scourge of the Downs" },
    { 3264,  "Duskbat Cape — Proof of Demise" },
    { 3446,  "Darkshire Mail Leggings — At War With The Scarlet Crusade 4" },

    -- Durotar (Orc/Troll 1-12)
    { 4942,  "Tiger Hide Boots — Thwarting Kolkar Aggression" },
    { 4941,  "Vile Familiar Hide — Vile Familiars" },
    { 4940,  "Burning Blade Cultist reward — Burning Blade Medallion" },

    -- Mulgore (Tauren 1-12)
    { 4909,  "Kodo Hunter's Leggings — The Kodo" },
    { 5392,  "Tomahawk — Rite of Strength" },

    -- =================================================================
    -- LEVEL 10-20 ZONES
    -- =================================================================

    -- Westfall (Human 10-20)
    { 2041,  "Tunic of Westfall — The Defias Brotherhood (Westfall finale)" },
    { 2042,  "Staff of Westfall — The Defias Brotherhood (Westfall finale)" },
    { 2037,  "Dusty Mining Gloves — Oh Brother... (Deadmines prequest)" },
    { 2074,  "Solid Shortblade — Red Silk Bandanas (Westfall)" },
    { 1640,  "Watchman Pauldrons — The People's Militia (Westfall 3/3)" },
    { 2089,  "Venom Web Fang — The Collector" },
    { 2043,  "Ring of the Brotherhood — The Defias Brotherhood" },

    -- Loch Modan (Dwarf 10-20)
    { 3207,  "Ironband's Hammer — Ironband's Excavation" },
    { 2910,  "Dwarven Magestaff — Bingles' Missing Supplies" },
    { 3154,  "Thelsamar Axe — In Defense of the King's Lands 3" },
    { 3155,  "Ironhide Pauldrons — Thelsamar Blood Sausages" },

    -- Darkshore / Auberdine (Night Elf 10-20)
    { 5399,  "Bands of Serra'kis — Blackfathom Deeps quest" },
    { 5400,  "Gravestone Scepter — Blackfathom Villainy" },
    { 5421,  "Firestarter — For Love Eternal" },
    { 5606,  "Seafarer's Pantaloons — WANTED: Murkdeep" },
    { 5813,  "Elder's Mantle — The Fall of Ameth'Aran" },

    -- Silverpine Forest (Undead 10-20)
    { 3451,  "Berard's Breastplate — Arugal Must Die" },
    { 3449,  "Mystic Shawl — The Dead Fields" },
    { 6319,  "Silverlaine's Family Seal — Deathstalkers in Shadowfang" },

    -- The Barrens (Horde 10-25)
    { 5279,  "Harpy Skinner — Harpy Raiders (Barrens)" },
    { 5322,  "Demolition Hammer — Samophlange (Barrens)" },
    { 6505,  "Crescent of Forlorn Spirits — Consumed by Hatred (Barrens)" },
    { 5321,  "Moonsteel Broadsword — The Angry Scytheclaws" },
    { 5314,  "Boar Hunter's Cape — Echeyakee" },
    { 5275,  "Binding Girdle — Tribes at War" },
    { 5316,  "Serpent's Kiss Crossbow — Wharfmaster Dizzywig" },

    -- Deadmines (instance 15-21)
    { 2874,  "Chausses of Westfall — Deadmines quest" },
    { 6087,  "Chestnut Mantle — Deadmines quest" },

    -- Wailing Caverns (instance 15-25)
    { 10657, "Talbar Mantle — Deviate Eradication" },
    { 6505,  "Crescent of Forlorn Spirits — Leaders of the Fang" },

    -- Shadowfang Keep (instance 18-25)
    { 6320,  "Commander's Crest — Deathstalkers in Shadowfang" },
    { 6323,  "Seal of Sylvanas — Arugal Must Die" },

    -- =================================================================
    -- LEVEL 20-30 ZONES
    -- =================================================================

    -- Redridge Mountains (Alliance 15-25)
    { 3562,  "Belt of the Gladiator — Blackrock Bounty (Redridge)" },
    { 3563,  "Robe of Solomon — Solomon chain finale" },
    { 3564,  "Barbed Club — Tharil'zun" },
    { 3566,  "Gnoll Punisher — Assessing the Threat" },

    -- Duskwood (Alliance 20-30)
    { 4534,  "Sparkmetal Coif — The Legend of Stalvan (Duskwood finale)" },
    { 2059,  "Sentry Cloak — The Night Watch (Duskwood)" },
    { 2903,  "Darktide Blade — Lightforge Ingot" },
    { 4535,  "Band of the Stalvan — Legend of Stalvan" },
    { 1315,  "Lei of Lilies — Sven's Revenge" },

    -- Wetlands (Alliance 20-30)
    { 3681,  "Ironplate Buckler — Apprentice's Duties" },
    { 4505,  "Swampwalker Boots — James Hyal" },

    -- Stonetalon / Ashenvale (Horde 18-30)
    { 5248,  "Flash Rifle — Gerenzo Wrenchwhistle (Stonetalon)" },
    { 5250,  "Charred Leather Tunic — Boulderslide Ravine (Stonetalon)" },
    { 5249,  "Blazing Wand — Elemental War (Stonetalon)" },
    { 6676,  "Tigerbane — Ashenvale Hunt" },
    { 5815,  "Glacial Stone — Raene's Cleansing (Ashenvale)" },

    -- Hillsbrad Foothills (20-30)
    { 3755,  "Fish Gutter — Crushridge Warmongers (Hillsbrad)" },
    { 4197,  "Break of Dawn — Battle of Hillsbrad (finale)" },
    { 3760,  "Band of the Undercity — Souvenirs of Death" },
    { 4196,  "Ravager's Cloak — Dangerous!" },

    -- Thousand Needles (25-35)
    { 9587,  "Windchaser Orb — Hypercapacitor Gizmo" },
    { 9588,  "Nogg's Gold Ring — Martek the Exiled" },

    -- Blackfathom Deeps (instance 20-27)
    { 7003,  "Gravestone Scepter — Blackfathom quest" },
    { 7001,  "Nimbus Boots — Baron Aquanis" },

    -- =================================================================
    -- LEVEL 30-40 ZONES
    -- =================================================================

    -- Arathi Highlands (30-40)
    { 4976,  "Mistspray Kilt — Foul Magics" },
    { 4977,  "Sword of Hammerfall — Hammerfall chain" },
    { 4978,  "Raptor Hide Belt — Raptor Mastery (Arathi)" },

    -- Stranglethorn Vale (30-45)
    { 4113,  "Nimbly Handled — Investigate the Camp (STV)" },
    { 4114,  "Darktide Cape — The Bloodsail Buccaneers (STV)" },
    { 2163,  "Dull Blade of the Troll — Headhunting (STV)" },
    { 4128,  "Silver Spade — Venture Company Mining (STV)" },
    { 4134,  "Naga Battle Gloves — Mok'thardin's Enchantment" },
    { 4108,  "Skullsplitter Helm — Skullsplitter Tusks" },
    { 4135,  "Amulet of Ogre Might — Mai'Zoth" },
    { 6830,  "Bracers of the People's Militia — Kurzen chains" },
    { 4112,  "Jungle Boots — Jungle quest chain" },
    { 6829,  "Sword of Serenity — Kurzen's Mystery" },
    { 6831,  "Black Ogre Kickers — Bloodscalp Clan Heads" },

    -- Desolace (30-40)
    { 6804,  "Staff of the Purifier — Sceptre of Light (Desolace)" },
    { 6795,  "Kodo Riding Crop — Bone Collector" },

    -- Scarlet Monastery (instance 30-40)
    { 6802,  "Sword of Omen — In the Name of the Light" },
    { 6803,  "Prophetic Cane — In the Name of the Light" },
    { 6804,  "Windweaver Staff — In the Name of the Light" },
    { 10708, "Bonebiter — Into the Scarlet Monastery (Horde)" },

    -- Razorfen Downs (instance 35-40)
    { 10710, "Skullbreaker — Bring the End" },

    -- Dustwallow Marsh (35-45)
    { 4505,  "Swampwalker Boots — Jarl Needs Eyes" },
    { 17707, "Blade of Reckoning — The Missing Diplomat" },

    -- =================================================================
    -- LEVEL 35-45 ZONES
    -- =================================================================

    -- Badlands / Uldaman (35-45)
    { 9626,  "Shaleskin Cape — Badlands Reagent Run" },
    { 9585,  "Wirt's Third Leg — Lost Uldaman reference" },
    { 9627,  "Explorers' League Commendation — Uldaman quest" },
    { 9522,  "Energized Stone Circle — Power Stones" },
    { 9386,  "Excavator's Brand — Uldaman quest chain" },

    -- Swamp of Sorrows (35-45)
    { 9651,  "Gryphon Mail Breastplate — Cortello's Riddle" },

    -- Feralas (40-50)
    { 9608,  "Resurgence Rod — The Ruins of Solarsal" },
    { 9606,  "Woodseed Hoop — Ancient Spirit" },
    { 15463, "Stormshroud Armor — Ogre Warbeads" },

    -- Tanaris / Zul'Farrak (40-50)
    { 9643,  "Optomatic Deflector — Zul'Farrak quest chain" },
    { 9030,  "Inferno Gloves — Thistleshrub Valley" },
    { 9029,  "Gloves of the Atal'ai Prophet — quest reward" },
    { 9609,  "Thermotastic Plate — Wastewander Justice" },

    -- Hinterlands (40-50)
    { 9651,  "Gryphon Mail Breastplate — Gryphon Master" },
    { 9654,  "Ragged John's Necklace — Snapjaws Mon!" },
    { 9653,  "Saddlebag of Stomping — Gammerita quest" },

    -- Maraudon (instance 40-50)
    { 17710, "Charstone Dirk — Maraudon quest chain" },
    { 17711, "Zealot's Robe — Maraudon quest chain" },
    { 17705, "Thrash Blade — Maraudon quest" },
    { 17780, "Blade of Eternal Darkness — Maraudon (rare)" },

    -- =================================================================
    -- LEVEL 45-55 ZONES
    -- =================================================================

    -- Searing Gorge / Burning Steppes (45-55)
    { 11866, "Smoking Heart of the Mountain — Incendius (BRD prequest)" },
    { 11865, "Commander's Crest — Marshal Windsor (BRD)" },
    { 11870, "Lava Core Boots — At the Bottom of the Slag Pit" },

    -- Sunken Temple (instance 50-55)
    { 10847, "Dragon's Eye — The Temple of Atal'Hakkar" },
    { 10838, "Might of Hakkar — Into the Depths" },

    -- Felwood (48-55)
    { 15706, "Hunt Tracker Blade — Winterfall Activity" },
    { 11863, "White Bone Band — Forces of Jaedenar" },
    { 11864, "Shimmering Jewel — Corrupted Sabers" },

    -- Un'Goro Crater (48-55)
    { 11905, "Linken's Sword of Mastery — It's Dangerous to Go Alone" },
    { 11906, "Linken's Boomerang — It's Dangerous to Go Alone" },
    { 11869, "Volcanic Rock Ring — Finding the Source" },

    -- Azshara (45-55)
    { 11870, "Arcane Crystal Pendant — Azshara quest chain" },

    -- Blackrock Depths (instance 48-56)
    { 12113, "Foresight Girdle — General Drakkisath's Command (LBRS)" },
    { 11869, "Naglering — Ring reward from BRD" },
    { 11871, "Smoking Heart of the Mountain — BRD quest" },

    -- =================================================================
    -- LEVEL 50-60 ZONES
    -- =================================================================

    -- Winterspring (50-60)
    { 15706, "Hunt Tracker Blade — Winterfall Activity (Winterspring)" },
    { 18169, "Flame Sprocket — Winterfall E'ko chain" },

    -- Western / Eastern Plaguelands (50-60)
    { 13209, "Seal of the Dawn — Argent Dawn quest chain" },
    { 15411, "Mark of Resolution — Heroes of Darrowshire (E. Plaguelands)" },
    { 13243, "Argent Avenger — Argent Dawn commision" },
    { 13244, "Argent Crusader — Argent Dawn" },
    { 13246, "Argent Defender — Argent Dawn" },
    { 15412, "Green Dragonskin Cloak — All Along the Watchtowers" },

    -- Silithus (55-60)
    { 21515, "Mark of Remulos — Cenarion quest chain" },
    { 20698, "Thick Silithid Chestguard — Cenarion Hold reward" },
    { 20699, "Cenarion Reservist's Legplates — Cenarion Hold reward" },

    -- Class quests (multi-class, lv 50-60)
    { 6504,  "Weathered Buckler — Warrior class quest (Stormwind)" },
    { 15443, "Vile Protector — Priest class quest (lv 50)" },
    { 18468, "Royal Seal of Eldre'Thalas — Dire Maul class book" },
    { 18469, "Royal Seal of Eldre'Thalas — Dire Maul class book" },

    -- Sunken Temple class quests (lv 50)
    { 20083, "Helm of Exile — warrior quest chain" },
    { 20036, "Fire Hardened Hauberk — hunter quest chain" },
    { 20037, "Arcane Infused Gem — mage quest chain" },

    -- Lower Blackrock Spire (instance 53-60)
    { 15873, "Ragged John's Necklace — LBRS quest" },

    -- Upper Blackrock Spire (instance 55-60)
    { 12590, "Felstriker — UBRS quest chain reward" },

    -- Dire Maul (instance 55-60)
    { 18420, "Bonecreeper Stylus — Dire Maul tribute" },
    { 18421, "Sedge Boots — Dire Maul quest" },

    -- Scholomance / Stratholme (instance 55-60)
    { 14023, "Barovian Family Sword — Scholomance quest chain" },
    { 15853, "Windreaper — Ramstein quest chain (Stratholme)" },
    { 14024, "Barovian Family Axe — Scholomance quest chain" },
    { 16311, "Scholar's Boots — Plagued Hatchlings" },

    -- Onyxia attunement chain
    { 15858, "Dragonslayer's Signet — Drakefire Amulet chain" },
    { 15859, "Drakefire Amulet — Onyxia attunement" },

    -- =================================================================
    -- DUNGEON FINALE / RAID ATTUNEMENT QUEST REWARDS
    -- =================================================================

    -- UBRS key chain
    { 12382, "Key to the City — Stratholme quest" },

    -- Molten Core attunement
    { 19021, "Cloudrunner Girdle — MC attunement reward" },

    -- BWL attunement
    { 19002, "Head of Nefarian quest — Master Dragonslayer's Orb" },

    -- AQ quest rewards
    { 21504, "Charm of the Shifting Sands — AQ chain" },
    { 21507, "Amulet of the Shifting Sands — AQ chain" },

    -- Tier 0.5 quest chain rewards (Dungeon Set 2)
    { 22114, "Darkmantle Cap — D2 quest chain" },
    { 22113, "Darkmantle Tunic — D2 quest chain" },
    { 22090, "Beastmaster's Cap — D2 quest chain" },
    { 22089, "Beastmaster's Tunic — D2 quest chain" },

    -- Epic mount quest rewards (warlock, paladin)
    { 13584, "Charger — Paladin epic mount quest reward" },
    { 13335, "Dreadsteed — Warlock epic mount quest reward" },
})
-- NOT marked complete — comprehensive seed covering all level ranges
-- and major quest chains.  Missing: many minor side quests per zone.

----------------------------------------------------------------------
-- VENDOR-SOLD ITEMS
--
-- Items purchasable from NPC vendors in WoW Classic.  Used by the
-- Off-the-shelf challenge ("can only equip vendor gear").
--
-- NOTE: White/grey (quality 0-1) items auto-pass the Off-the-shelf
-- check since nearly all vendor gear is white quality.  This list is
-- specifically for GREEN+ quality items sold by vendors:
--   - Limited-supply greens from weapon/armor vendors
--   - PvP reward vendors (honor quartermasters)
--   - Reputation vendors
--   - Speciality NPC vendors
----------------------------------------------------------------------

fill(C.vendor_items, {
    -- =================================================================
    -- NOTE: White/grey (quality 0-1) items auto-pass the Off-the-shelf
    -- check since nearly all basic vendor gear is white.  This list
    -- covers GREEN+ quality items sold by NPC vendors.
    -- =================================================================

    -- =================================================================
    -- LIMITED-SUPPLY GREEN WEAPONS (various city/town vendors)
    -- =================================================================

    -- Stormwind limited-supply
    { 2535,  "War Knife — Stormwind weapon vendor (limited)" },
    { 2534,  "Rondel — Stormwind weapon vendor (limited)" },

    -- Ironforge limited-supply
    { 4778,  "Derby Felt Hat — limited supply, Ironforge hat vendor" },
    { 4567,  "Vendetta — Ironforge weapon vendor (limited)" },

    -- Orgrimmar limited-supply
    { 4794,  "Wolf Rider's Wristbands — Orgrimmar armor vendor (limited)" },
    { 4817,  "Blessed Claymore — Orgrimmar weapon vendor (limited)" },
    { 4565,  "Simple Blouse — Orgrimmar cloth vendor (limited)" },

    -- Undercity limited-supply
    { 4793,  "Sylvan Cloak — Undercity armor vendor (limited)" },

    -- Thunder Bluff limited-supply
    { 4795,  "Emblazoned Bracers — Thunder Bluff vendor (limited)" },

    -- Darnassus limited-supply
    { 4797,  "Fiery Cloak — Darnassus vendor (limited)" },

    -- =================================================================
    -- LIMITED-SUPPLY GREEN ARMOR (zone vendors)
    -- =================================================================

    -- Westfall / Sentinel Hill
    { 4788,  "Armor of the Fang — limited supply vendor" },
    { 4790,  "Inferno Cloak — limited supply vendor" },

    -- Lakeshire
    { 4791,  "Enchanted Moonstalker Cloak — limited supply (Redridge)" },

    -- Darkshore
    { 4792,  "Spirit Cloak — limited supply vendor (Darkshore)" },

    -- Stonetalon
    { 4796,  "Owl Bracers — limited supply vendor" },

    -- Booty Bay (neutral)
    { 4827,  "Wizard's Belt — limited supply, Booty Bay" },
    { 4828,  "Nightwind Belt — limited supply, Booty Bay" },
    { 4829,  "Dreamer's Belt — Booty Bay vendor (limited)" },

    -- Ratchet (neutral)
    { 4826,  "Sanguine Cape — limited supply, Ratchet" },

    -- Everlook (neutral, Winterspring)
    { 16215, "Formula: Enchant Boots (Agility) — Everlook vendor" },

    -- Gadgetzan (neutral)
    { 15808, "Fine Light Crossbow — Gadgetzan weapon vendor (limited)" },

    -- =================================================================
    -- PVP HONOR VENDORS (Alliance)
    -- =================================================================

    -- Alliance PvP rank-based gear (Officer's / Marshal's sets)
    { 16391, "Knight-Captain's Leather Chestpiece — PvP vendor" },
    { 16392, "Knight-Captain's Leather Leggings — PvP vendor" },
    { 16393, "Knight-Captain's Chain Hauberk — PvP vendor" },
    { 16401, "Knight-Lieutenant's Leather Grips — PvP vendor" },
    { 16403, "Knight-Lieutenant's Chain Gauntlets — PvP vendor" },
    { 16405, "Knight-Lieutenant's Plate Gauntlets — PvP vendor" },
    { 16406, "Knight-Captain's Plate Chestguard — PvP vendor" },
    { 16407, "Knight-Captain's Plate Leggings — PvP vendor" },
    { 16409, "Knight-Lieutenant's Silk Gloves — PvP vendor" },
    { 16413, "Knight-Captain's Silk Raiment — PvP vendor" },
    { 16414, "Knight-Captain's Silk Leggings — PvP vendor" },

    -- Alliance PvP weapons
    { 18825, "Grand Marshal's Claymore — Alliance PvP vendor" },
    { 18826, "Grand Marshal's Longsword — Alliance PvP vendor" },
    { 18827, "Grand Marshal's Aegis — Alliance PvP vendor (shield)" },
    { 18828, "Grand Marshal's Bullseye — Alliance PvP vendor (bow)" },
    { 18831, "Grand Marshal's Demolisher — Alliance PvP vendor (mace)" },
    { 18833, "Grand Marshal's Handcannon — Alliance PvP vendor (gun)" },
    { 18835, "Grand Marshal's Punisher — Alliance PvP vendor (1H mace)" },
    { 18838, "Grand Marshal's Right Hand Blade — Alliance PvP vendor" },
    { 18840, "Grand Marshal's Stave — Alliance PvP vendor" },
    { 18843, "Grand Marshal's Sunderer — Alliance PvP vendor (axe)" },
    { 18847, "Grand Marshal's Dirk — Alliance PvP vendor (dagger)" },

    -- =================================================================
    -- PVP HONOR VENDORS (Horde)
    -- =================================================================

    -- Horde PvP rank-based gear (Blood Guard's / Warlord's sets)
    { 16484, "Blood Guard's Leather Treads — PvP vendor" },
    { 16485, "Blood Guard's Chain Gauntlets — PvP vendor" },
    { 16487, "Blood Guard's Plate Gloves — PvP vendor" },
    { 16489, "Blood Guard's Silk Gloves — PvP vendor" },
    { 16494, "Legionnaire's Chain Breastplate — PvP vendor" },
    { 16496, "Legionnaire's Plate Armor — PvP vendor" },
    { 16498, "Legionnaire's Silk Robes — PvP vendor" },
    { 16502, "Champion's Chain Headguard — PvP vendor" },
    { 16504, "Champion's Plate Helm — PvP vendor" },
    { 16506, "Champion's Silk Hood — PvP vendor" },

    -- Horde PvP weapons
    { 18860, "High Warlord's Claymore — Horde PvP vendor" },
    { 18861, "High Warlord's Blade — Horde PvP vendor" },
    { 18862, "High Warlord's Shield Wall — Horde PvP vendor (shield)" },
    { 18863, "High Warlord's Crossbow — Horde PvP vendor" },
    { 18864, "High Warlord's Destroyer — Horde PvP vendor (2H mace)" },
    { 18866, "High Warlord's Bludgeon — Horde PvP vendor (1H mace)" },
    { 18868, "High Warlord's Cleaver — Horde PvP vendor (axe)" },
    { 18869, "High Warlord's Battle Axe — Horde PvP vendor (2H axe)" },
    { 18871, "High Warlord's Pig Sticker — Horde PvP vendor (polearm)" },
    { 18874, "High Warlord's Street Sweeper — Horde PvP vendor (gun)" },
    { 18876, "High Warlord's Razor — Horde PvP vendor (dagger)" },
    { 18877, "High Warlord's War Staff — Horde PvP vendor (staff)" },

    -- =================================================================
    -- BATTLEGROUND REPUTATION VENDORS
    -- =================================================================

    -- Warsong Gulch rewards (Silverwing / Warsong Outriders)
    { 19505, "Warsong Gulch reward — Protector's Band (Exalted)" },
    { 19506, "Warsong Gulch reward — Protector's Band (Exalted)" },
    { 19587, "Forest Stalker's Bracers — WSG rep vendor" },
    { 19588, "Outrider's Chain Leggings — WSG rep vendor" },
    { 19578, "Berserker Bracers — WSG rep vendor" },
    { 19589, "Forestlord Striders — WSG rep vendor" },

    -- Arathi Basin rewards (League of Arathor / Defilers)
    { 19579, "Arathi Basin vendor reward — Talisman of Arathor" },
    { 19580, "Arathi Basin vendor reward — Talisman of Arathor" },
    { 20041, "Highlander's Chain Girdle — AB rep vendor" },
    { 20042, "Highlander's Plate Girdle — AB rep vendor" },
    { 20043, "Highlander's Cloth Girdle — AB rep vendor" },
    { 20044, "Highlander's Leather Girdle — AB rep vendor" },
    { 20049, "Defiler's Chain Girdle — AB rep vendor" },
    { 20050, "Defiler's Plate Girdle — AB rep vendor" },
    { 20051, "Defiler's Cloth Girdle — AB rep vendor" },
    { 20052, "Defiler's Leather Girdle — AB rep vendor" },

    -- Alterac Valley rewards (Stormpike / Frostwolf)
    { 19312, "Lei of the Lifegiver — AV rep vendor (Exalted)" },
    { 19315, "Therazane's Touch — AV rep vendor (Exalted)" },
    { 19321, "The Immovable Object — AV rep vendor (shield, Exalted)" },
    { 19322, "The Unstoppable Force — AV rep vendor (2H mace, Exalted)" },
    { 19324, "The Lobotomizer — AV rep vendor (dagger, Exalted)" },
    { 19325, "Don Julio's Band — AV rep vendor (ring, Exalted)" },

    -- =================================================================
    -- FACTION REPUTATION VENDORS
    -- =================================================================

    -- Argent Dawn (Friendly through Exalted)
    { 13209, "Seal of the Dawn — Argent Dawn (Honored trinket)" },
    { 22401, "Blessed Sunfruit — Argent Dawn vendor (consumable)" },
    { 13245, "Argent Defender — Argent Dawn vendor" },

    -- Timbermaw Hold
    { 21326, "Defender of the Timbermaw — Timbermaw Hold Exalted" },
    { 21325, "Deathdealer's Helm — Timbermaw Hold Exalted" },

    -- Thorium Brotherhood
    { 17051, "Sulfuron Hammer — Thorium Brotherhood recipe product" },
    { 17014, "Dark Iron Bracers — Thorium Brotherhood vendor plan" },

    -- Cenarion Circle (Silithus)
    { 22209, "Cenarion rep vendor item" },
    { 21186, "Rockfury Bracers — Cenarion Exalted" },
    { 21190, "Wrath of Cenarius — Cenarion Exalted (ring)" },

    -- Zandalar Tribe (ZG rep)
    { 19825, "Band of Jin — Zandalar Friendly" },
    { 19829, "Zandalar Signet of Might — Zandalar Exalted" },
    { 19830, "Zandalar Signet of Serenity — Zandalar Exalted" },
    { 19831, "Zandalar Signet of Mojo — Zandalar Exalted" },
    { 20076, "Zandalar Demoniac's Robe — ZG rep vendor" },
    { 20077, "Zandalar Demoniac's Wraps — ZG rep vendor" },

    -- Hydraxian Waterlords
    { 17333, "Aqual Quintessence — Hydraxian vendor" },

    -- Brood of Nozdormu (AQ rep)
    { 21205, "Signet Ring of the Bronze Dragonflight — Brood rep" },
    { 21206, "Signet Ring of the Bronze Dragonflight — Brood rep" },

    -- Wintersaber Trainers (Alliance only)
    { 13086, "Winterspring Frostsaber — Wintersaber Trainers Exalted mount" },

    -- =================================================================
    -- SPECIALTY / TRADE NPC VENDORS
    -- =================================================================

    -- Cooking recipe vendors (recipes, not equippable — skip)
    -- Weapon Master trainers (training, not equippable — skip)

    -- Ravenholdt Manor limited supply
    { 7298,  "Blade of Cunning — Ravenholdt vendor (limited)" },

    -- Light's Hope Chapel vendors
    { 13216, "Badge of the Dawn — Light's Hope vendor" },

    -- Dire Maul vendors (inside instance)
    { 18487, "Rhok'delar — epic quest reward (hunter class)" },

    -- Libram / relic vendors
    { 22400, "Libram of Rapidity — DM vendor" },
    { 22399, "Libram of Voracity — DM vendor" },

    -- =================================================================
    -- TRAINER-PURCHASED ITEMS (class trainers sell some equippables)
    -- =================================================================

    -- Paladin trainers sell various librams at different levels
    -- Warlock trainers sell summoning reagents (not equippable)
    -- No equippable trainer-sold items significant enough to list

})
-- NOT marked complete — comprehensive seed covering PvP vendors,
-- limited-supply greens, and faction reputation vendors.  Missing:
-- some obscure limited-supply items in remote zone vendors.

----------------------------------------------------------------------
-- COMBINED SOURCE CHECKER
--
-- Utility function used by the Partisan challenge (exclusion approach).
-- Checks whether an item ID appears on ANY known non-loot source list.
-- Returns (isKnownSource, sourceName) so callers can report what source
-- cleared the item.
----------------------------------------------------------------------

function HCE.CheckItemSource(itemID)
    if not itemID then return false, nil end

    -- 1. Vendor items
    if C.vendor_items and C.vendor_items[itemID] then
        return true, "vendor"
    end

    -- 2. Quest rewards
    if C.quest_rewards and C.quest_rewards[itemID] then
        return true, "quest reward"
    end

    -- 3. Profession-crafted items (from SelfFoundCheck)
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.CraftedByProfession then
        for profName, list in pairs(HCE.SelfFoundCheck.CraftedByProfession) do
            if list[itemID] then
                return true, profName .. "-crafted"
            end
        end
    end

    return false, nil
end

----------------------------------------------------------------------
-- SOURCE COMPLETENESS
--
-- Reports whether all non-loot source lists have been fully curated.
-- Used by the Partisan checker to decide between UNCHECKED and FAIL
-- when an item isn't found on any known list.
----------------------------------------------------------------------

function HCE.AllSourceListsComplete()
    return COMPLETE["quest_rewards"]
       and COMPLETE["vendor_items"]
       -- Crafted lists from SelfFoundCheck are per-profession;
       -- we'd need all of them marked complete.  For now, false.
       and false
end

----------------------------------------------------------------------
-- ITEM SOURCE SLASH COMMAND HELPER
--
-- Prints a per-slot breakdown of equipped items and their detected
-- source (vendor / quest reward / crafted / unknown).
----------------------------------------------------------------------

local SLOT_NAMES = {
    [1]  = "Head",     [2]  = "Neck",     [3]  = "Shoulder",
    [5]  = "Chest",    [6]  = "Waist",    [7]  = "Legs",
    [8]  = "Feet",     [9]  = "Wrist",    [10] = "Hands",
    [11] = "Ring 1",   [12] = "Ring 2",   [13] = "Trinket 1",
    [14] = "Trinket 2",[15] = "Back",     [16] = "Main Hand",
    [17] = "Off Hand", [18] = "Ranged",   [19] = "Tabard",
}

local GEAR_SLOTS = {
    1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
}

local QUALITY_LABELS = {
    [0] = "poor", [1] = "common", [2] = "uncommon",
    [3] = "rare", [4] = "epic",   [5] = "legendary",
}

function HCE.PrintItemSources()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected.")
        return
    end

    HCE.Print("Item source breakdown (equipped gear):")

    local checked, unknown, vendorN, questN, craftedN = 0, 0, 0, 0, 0

    for _, slotID in ipairs(GEAR_SLOTS) do
        local itemID = GetInventoryItemID("player", slotID)
        if itemID then
            checked = checked + 1
            local name, _, quality = GetItemInfo(itemID)
            name = name or ("item:" .. itemID)
            quality = quality or 0
            local qLabel = QUALITY_LABELS[quality] or ("q" .. quality)
            local slotLabel = SLOT_NAMES[slotID] or ("Slot " .. slotID)

            if quality <= 1 then
                -- White/grey auto-passes all item-source challenges
                DEFAULT_CHAT_FRAME:AddMessage(
                    "  " .. slotLabel .. ": |cff888888" .. name .. " (" .. qLabel .. ")|r — basic item"
                )
            else
                local found, source = HCE.CheckItemSource(itemID)
                if found then
                    if source == "vendor" then vendorN = vendorN + 1
                    elseif source == "quest reward" then questN = questN + 1
                    else craftedN = craftedN + 1 end
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "  " .. slotLabel .. ": |cff00ff00" .. name .. "|r — " .. source
                    )
                else
                    unknown = unknown + 1
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "  " .. slotLabel .. ": |cffffaa33" .. name .. " (" .. qLabel .. ")|r — source unknown"
                    )
                end
            end
        end
    end

    if checked == 0 then
        HCE.Print("  No gear equipped.")
    else
        HCE.Print(string.format(
            "  Summary: %d items checked — %d vendor, %d quest, %d crafted, %d unknown",
            checked, vendorN, questN, craftedN, unknown
        ))
    end
end
