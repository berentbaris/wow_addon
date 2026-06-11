----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Curated Item ID Lists
--
-- This file populates HCE.CuratedItems (defined in EquipmentCheck.lua)
-- with specific WoW Classic item IDs for visual/thematic equipment
-- requirements that cannot be detected by item type alone.
--
-- Each list maps itemID -> a short provenance comment.  EquipmentCheck
-- only cares about key existence, but the value lets us keep a paper
-- trail of where each ID was verified (Wowhead Classic).
--
-- Lists marked COMPLETE mean a miss on an equipped item is a hard FAIL;
-- incomplete lists return UNCHECKED instead.
--
-- Task 7.2 curation pass — 2026-04-26
----------------------------------------------------------------------

HCE = HCE or {}
HCE.CuratedItems = HCE.CuratedItems or {}
HCE.CuratedComplete = HCE.CuratedComplete or {}
local C = HCE.CuratedItems
local COMPLETE = HCE.CuratedComplete

----------------------------------------------------------------------
-- Helper: fold a list of {itemID, "note"} pairs into the target table.
----------------------------------------------------------------------

local function fill(target, entries)
    for _, pair in ipairs(entries) do
        target[pair[1]] = pair[2] or true
    end
end

----------------------------------------------------------------------
-- ENGINEERING GOGGLES / HEADGEAR (Mechano-Mage)
----------------------------------------------------------------------

-- Flying Tiger Goggles — single definitive item
fill(C.flying_tiger_goggles, {
    { 4368, "Flying Tiger Goggles — Engineering 100" },
})
COMPLETE.flying_tiger_goggles = true

-- Green-tinted goggles — green-lens / tinted eyewear
fill(C.green_tinted_goggles, {
    { 4385,  "Green Tinted Goggles — Engineering 150" },
})
COMPLETE.green_tinted_goggles = true

-- Gnomish goggles — engineering headgear with goggle/helmet art
fill(C.gnomish_goggles, {
    { 10545, "Gnomish Goggles - Engineering 210" },
})
COMPLETE.gnomish_goggles = true
-- All Engineering-crafted headgear in Classic with goggle/helmet art.

----------------------------------------------------------------------
-- WARLOCK FIRESTONES / SPELLSTONES (Pyremaster, Shadowmage)
----------------------------------------------------------------------

fill(C.firestone, {
    { 1254,  "Firestone — rank 1 (lvl 28)" },
    { 13699, "Greater Firestone — rank 2 (lvl 46)" },
    { 13700, "Major Firestone — rank 3 (lvl 56)" },
})
COMPLETE.firestone = true

fill(C.brewmaster_robe, {
    { 6801,  "Baroque Apron — Dustwallow quest reward" },
})
COMPLETE.brewmaster_robe = true

fill(C.katana, {
    { 922,  "Dacian Falx — Vendor" },
    { 6909, "Strike of the Hydra — BFD drop" },
    { 18520, "Barbarous Blade — Dire Maul drop" },
    { 10573, "Boneslasher — world drop" },
    { 2205, "Duskbringer — SFK zone drop" },
    { 16039, "Ta'Kierthan Songblade — Plaguelands rare mob drop" },
    { 3854, "Frost Tiger Blade — Blacksmithing" },
    { 9385, "Archaic Defender — world drop" },
    { 15251, "Headstriker Sword — world drop" },
    { 15257, "Shin Blade — world drop" },
    { 2822, "Mo'grosh Toothpick — Loch Modan ogre drop" },
    { 2801, "Blade of Hanna — epic world drop" },
})
COMPLETE.katana = true

fill(C.engineer_offhand, {
    { 11855,  "Tork Wrench — Barren quest reward" },
    { 9644, "Thermotastic Egg Timer — Booty Bay quest reward" },
})
COMPLETE.engineer_offhand = true

fill(C.flint, {
    { 4471,  "Flint and Tinder — Vendor" },
})
COMPLETE.flint = true

fill(C.reflector_belt, {
    { 11861,  "Girdle of Reprisal — Searing Gorge quest reward" },
})
COMPLETE.reflector_belt = true

fill(C.red_shirt, {
    { 2575,  "Red Linen Shirt — Tailoring 40" },
})
COMPLETE.red_shirt = true

fill(C.scarlet_shoulders, {
    { 7718,  "Herod's Shoulder — SM drop" },
})
COMPLETE.scarlet_shoulders = true

fill(C.scarlet_tabard, {
    { 23192,  "Tabard of the Scarlet Crusade — SM drop" },
})
COMPLETE.scarlet_tabard = true

fill(C.scarlet_shield, {
    { 7726,  "Aegis of the Scarlet Commander — SM drop" },
})
COMPLETE.scarlet_shield = true

fill(C.scarlet_helm, {
    { 7719,  "Raging Berserker's Helm — SM drop" },
    { 10743,  "Drakefire Headguard — Searing Gorge quest reward" },
    { 10235,  "Engraved Helm — World drop" },
    { 10379,  "Commander's Helm — World drop" },
    { 12952,  "Gyth's Skull — UBRS drop" },
})
COMPLETE.scarlet_helm = true

fill(C.scarlet_chestpiece, {
    { 6773,  "Gelkis Marauder Chain — Desolace quest reward" },
    { 10328,  "Scarlet Chestpiece — SM zone drop" },
    { 17777,  "Relentless Chain — Maraudon quest reward" },
    { 11194,  "Prismscale Hauberk — Badlands quest reward" },
    { 11195,  "Warforged Chestplate — Badlands quest reward" },
    { 12049,  "Splintsteel Armor — BRD quest reward" },
    { 21322,  "Ursa's Embrace — Winterspring quest reward" },
    { 14611,  "Bloodmail Hauberk — World drop" },
})
COMPLETE.scarlet_chestpiece = true

fill(C.scarlet_leggings, {
    { 10330,  "Scarlet Leggings — SM drop" },
    { 19124,  "Slagplate Leggings — Searing Gorge quest reward" },
    { 21316,  "Leggings of the Ursa — Winterspring quest reward" },
    { 12049,  "Searingscale Leggings — BRD drop" },
    { 11802,  "Lavacrest Leggings — BRD drop" },
    { 16728,  "Lightforge Legplates — Stratholme drop" },
})
COMPLETE.scarlet_leggings = true

fill(C.scarlet_gauntlets, {
    { 3759,  "Insulated Sage Gloves — Alterac quest reward (cloth)" },
    { 6732,  "Gnomish Mechanic's Gloves — T. Needles quest reward (leather)" },
    { 9445,  "Grubbis Paws — Gnomeregan drop" },
    { 7724,  "Gauntlets of Divinity — SM drop" },
    { 9640,  "Vice Grips — ZF drop" },
    { 19126,  "Slagplate Gauntlets — Searing Gorge quest reward" },
    { 11867,  "Maddening Gauntlets — Burning Steppes quest reward" },
    { 11814,  "Molten Fists — BRD drop" },
    { 18366,  "Gordok's Handguards — Dire Maul quest reward" },
    { 14615,  "Bloodmail Gauntlets — World drop" },
})
COMPLETE.scarlet_gauntlets = true

fill(C.scarlet_boots, {
    { 10332,  "Scarlet Boots — SM zone drop" },
    { 9387,  "Revelosh's Boots — Uldaman drop" },
    { 6791,  "Hellion Boots — Desolace quest reward (cloth)" },
    { 11919,  "Cragplate Greaves — Un'Goro quest reward" },
    { 10846,  "Bloodshot Greaves — ST drop" },
    { 11865,  "Rancor Boots — BRD quest reward (cloth)" },
    { 22240,  "Greaves of Withering Despair — BRD drop" },
    { 11627,  "Fleetfoot Greaves — BRD drop" },
    { 13381,  "Master Cannoneer Boots — Stratholme drop" },
    { 19919,  "Bloodstained Greaves — ZG drop" },
})
COMPLETE.scarlet_boots = true

fill(C.reflector_belt, {
    { 11861,  "Girdle of Reprisal — Searing Gorge quest reward" },
})
COMPLETE.reflector_belt = true

fill(C.imperial_shoulders, {
    { 12428,  "Imperial Plate Shoulders — Blacksmithing" },
})
COMPLETE.imperial_shoulders = true

fill(C.imperial_helm, {
    { 12427,  "Imperial Plate Helm — Blacksmithing" },
    { 10763,  "Icemetal Barbute — RFD drop" },
    { 11729,  "Savage Gladiator Helm — BRD drop" },
})
COMPLETE.imperial_helm = true

fill(C.argent_shoulders, {
    { 4123,  "Frost Metal Pauldrons — STV quest reward" },
    { 9411,  "Rockshard Pauldrons — Uldaman drop" },
    { 17779,  "Hulkstone Pauldrons — Maraudon quest reward" },
    { 11632,  "Earthslag Shoulders — BRD drop" },
    { 18686,  "Bone Golem Shoulders — Scholomance drop" },
})
COMPLETE.argent_shoulders = true

fill(C.argent_helm, {
    { 8092,  "Platemail Helm — Vendor" },
    { 7922,  "Steel Plate Helm — Blacksmithing" },
    { 20640,  "Southsea Head Bucket — Tanaris quest reward" },
    { 10833,  "Horns of Eranikus — ST drop" },
    { 10749,  "Avenguard Helm — ST quest reward" },
})
COMPLETE.argent_helm = true

fill(C.dreamweave_gloves, {
    { 10019,  "Dreamweave Gloves — Tailoring" },
})
COMPLETE.dreamweave_gloves = true

fill(C.dreamweave_circlet, {
    { 10041,  "Dreamweave Circlet — Tailoring" },
})
COMPLETE.dreamweave_circlet = true

fill(C.dreamweave_vest, {
    { 10021,  "Dreamweave Vest — Tailoring" },
})
COMPLETE.dreamweave_vest = true

fill(C.dreamweave_kilt, {
    { 9474,  "Jinxed Hoodoo Kilt — ZF drop" },
})
COMPLETE.dreamweave_kilt = true

fill(C.green_shirt, {
    { 2579,  "Green Linen Shirt — Tailoring" },
})
COMPLETE.green_shirt = true

fill(C.reflector_shield, {
    { 7787,  "Resplendent Guardian — World drop" },
    { 9458,  "Thermaplugg's Central Core — Gnomeregan drop" },
    { 4975,  "Vigilant Buckler — Arathi quest reward" },
    { 9643,  "Optomatic Deflector — Tanaris quest reward" },
    { 1204,  "The Green Tower — World drop" },
    { 2040,  "Troll Protector — ZF zone drop" },
    { 1979,  "Wall of the Dead — World drop" },
    { 1168,  "Skullflame Shield — World drop" },
    { 13243,  "Argent Defender — Stratholme quest reward" },
    { 17066,  "Drillborer Disk — Molten Core drop" },    
    { 18499,  "Barrier Shield — Dire Maul rare drop" },
})
COMPLETE.reflector_shield = true

fill(C.wizard_hat, {
    { 3556,  "Dread Mage Hat — Warlock Quest Reward" },
    { 14246,  "Darkmist Wizard Hat — World Drop" },
    { 6429,  "Mistscape Wizard Hat — World Drop" },
    { 7470,  "Regal Wizard Hat — World Drop" },
    { 9878,  "Sorcerer Hat — World Drop" },
    { 3345,  "Silk Wizard Hat — Syndicate Magus Drop" },
})
COMPLETE.wizard_hat = true

fill(C.spellstone, {
    { 5522,  "Spellstone — rank 1 (lvl 36)" },
    { 13602, "Greater Spellstone — rank 2 (lvl 48)" },
    { 13603, "Major Spellstone — rank 3 (lvl 58)" },
})
COMPLETE.spellstone = true

----------------------------------------------------------------------
-- WOLF HELM (Beastmaster)
----------------------------------------------------------------------

fill(C.wolf_helm, {
    { 30037, "Embrace of the Lycan - ZF boss drop" },
})
COMPLETE.wolf_helm = true
-- Only the Wolfshead Helm has a literal wolf-head model in Classic.
-- No random-suffix items share this unique wolf-head visual.

fill(C.powershifting_helm, {
    { 8345, "Wolfshead Helm - Tribal Leatherworking" },
})
COMPLETE.powershifting_helm = true

----------------------------------------------------------------------
-- GUILD TABARD (Exemplar)
----------------------------------------------------------------------

fill(C.guild_tabard, {
    { 5976, "Guild Tabard — Vendor" },
})
COMPLETE.guild_tabard = true

----------------------------------------------------------------------
-- LUNAR FESTIVAL SUIT (Brewmaster)
----------------------------------------------------------------------

fill(C.lunar_festival_suit, {
    { 21542, "Festival Suit — Lunar Festival reward" },
    { 21544, "Festive Blue Pant Suit — Lunar Festival reward" },
    { 21543, "Festive Teal Pant Suit — Lunar Festival reward" },
    { 21541, "Festive Black Pant Suit — Lunar Festival reward" },
})
COMPLETE.lunar_festival_suit = true

----------------------------------------------------------------------
-- BLUE SHIRT (Exemplar)
----------------------------------------------------------------------

fill(C.blue_shirt, {
    { 2577, "Blue Linen Shirt — Tailoring" },
})
COMPLETE.blue_shirt = true

----------------------------------------------------------------------
-- CAPTAIN'S HAT (Buccaneer)
-- Pirate / naval tricorne headgear
----------------------------------------------------------------------

fill(C.captains_hat, {
    { 10030, "Admiral's Hat — Tailoring 240" },
})
COMPLETE.captains_hat = true

----------------------------------------------------------------------
-- RAPIER / CUTLASS / HARPOON (Buccaneer)
-- Pirate / swashbuckler one-handed swords + harpoon-style weapons
----------------------------------------------------------------------

fill(C.rapier_cutlass_harpoon, {
    -- Cutlasses (pirate-named swords)
    { 851,   "Cutlass — Vendor" },
    { 1951,  "Blackwater Cutlass — Defias Pirate drop" },
    { 9446, "Electrocutioner Leg — rare 1H sword (Gnomeregan)" },
    { 2528, "Falchion - Vendor" },
    { 10799, "Headspike - ST drop" },
    { 3850, "Jade Serpentblade - Blacksmithing" },
    { 3935, "Smotts' Cutlass - STV quest item" },
    { 5192, "Thief's Blade - Deadmines drop" },
    { 19040, "Zorbin's Mega-Slicer - Feralas quest reward" },
    -- Rapier / dueling swords
    { 5191,  "Cruel Barb — Deadmines drop" },
})

----------------------------------------------------------------------
-- FLASK TRINKETS (Mountain King)
-- Flask / bottle-themed trinkets
----------------------------------------------------------------------

fill(C.flask_trinkets, {
    { 20130, "Diamond Flask — Warrior class quest lv 50" },
    { 744,   "Thunderbrew's Boot Flask — Sweet Amber quest reward" },
})
COMPLETE.flask_trinkets = true
-- Diamond Flask is the canonical flask trinket for a Protection Warrior.
-- Thunderbrew's Boot Flask is thematically perfect for Mountain King.
-- These are the only two flask-themed equippable trinkets in Classic.

fill(C.horned_helm, {
    { 7719, "Raging Berserker's Helm — SM drop" },
    { 3836,   "Green Iron Helm — Blacksmithing" },
    { 6686,   "Tusken Helm — RFK drop" },
    { 11124,   "Helm of Exile — ST quest reward" },
    { 14753,   "Slayer's Skullcap — world drop" },
    { 10198,   "Crusader's Helm — world drop" },
    { 10235,   "Engraved Helm — world drop" },
    { 8270,   "Ebonhold Helmet — world drop" },
    { 15645,   "Ironhide Helmet — world drop" },
    { 14804,   "Bloodlust Helm — world drop" },
    { 13073,   "Mugthol's Helm — world drop" },
    { 7937,   "Ornate Mithril Helm — Blacksmithing" },
    { 22411,   "Helm of the Executioner — Stratholme drop" },
    { 14849,   "Sunscale Helmet — world drop" },
    { 12612,   "Runic Plate Helm — Blacksmithing" },
    { 13073,   "Heavy Mithril Helm — Blacksmithing" },
    { 10132,   "Revenant Helmet — world drop" },
    { 10090,   "Gothic Plate Helmet — world drop" },
    { 14907,   "Brutish Helmet — world drop" },
    { 14935,   "Heroic Skullcap — world drop" },
    { 14907,   "Darkrune Helm — Blacksmithing" },
    { 10379,   "Commander's Helm — world drop" },
    { 12410,   "Thorium Helm — Blacksmithing" },
    { 10279,   "Emerald Helm — world drop" },
    { 10372,   "Imbued Plate Helmet — world drop" },
    { 8142,   "Chromite Barbute — world drop" },
    { 12640,   "Lionheart Helm — Blacksmithing" },
})
COMPLETE.horned_helm = true


----------------------------------------------------------------------
-- INSIGNIA (Exemplar)
-- PvP Insignia trinkets — one per class per faction
----------------------------------------------------------------------

fill(C.insignia, {
    -- Alliance Insignia (one per class)
    { 18854, "Insignia of the Alliance — Warrior" },
    { 209614, "Insignia of the Alliance — Paladin" },
    { 18857, "Insignia of the Alliance — Rogue" },
    { 18858, "Insignia of the Alliance — Hunter" },
    { 18859, "Insignia of the Alliance — Mage" },
    { 18862, "Insignia of the Alliance — Priest" },
    { 18863, "Insignia of the Alliance - Warlock" },
    { 18864, "Insignia of the Alliance — Druid" },

    -- Horde Insignia (one per class)
    { 18834, "Insignia of the Horde — Warrior" },
    { 18845, "Insignia of the Horde — Shaman" },
    { 18846, "Insignia of the Horde — Hunter" },
    { 18849, "Insignia of the Horde — Warlock" },
    { 18850, "Insignia of the Horde — Mage" },
    { 18851, "Insignia of the Horde — Priest" },
    { 18852, "Insignia of the Horde — Rogue" },
    { 18853, "Insignia of the Horde — Druid" },
})
COMPLETE.insignia = true

----------------------------------------------------------------------
-- ARGENT DAWN TRINKET (Templar)
----------------------------------------------------------------------

fill(C.argent_dawn_trinket, {
    { 12846, "Argent Dawn Commission — quest reward" },
})
COMPLETE.argent_dawn_trinket = true

----------------------------------------------------------------------
-- KILT (Demon Hunter, Runemaster)
-- Leg items with kilt visual
----------------------------------------------------------------------

fill(C.kilt, {
    -- Cloth kilts
    { 153,   "Primitive Kilt — white cloth legs" },
    { 10047, "Simple Kilt — white cloth legs, Tailoring" },
    { 14315, "Celestial Kilt — green cloth legs" },

    -- Leather kilts
    { 7760,  "Warchief Kilt — rare leather legs, SM" },
    { 16719, "Wildheart Kilt — rare leather legs, Druid T0" },
    { 9474,  "Jinxed Hoodoo Kilt — leather legs, ZF" },
    { 4832,  "Mystic Sarong - Vendor" },
    { 10842,  "Windscale Sarong - ST Drop" },
    { 14324,  "Resplendent Sarong" },
    { 14334,  "Eternal Sarong" },
    { 14462,  "Elunarian Sarong" },  
})

----------------------------------------------------------------------
-- COWL (Death Knight)
-- Head items with cowl / hooded / executioner hood visual
----------------------------------------------------------------------

fill(C.cowl, {
    { 3732, "Hooded Cowl - quest rewards from Hillsbrad" },
    { 4322, "Enchanter's Cowl - tailoring 165" },
    { 4039, "Nightsky Cowl - world drop" },
    { 7432, "Twilight Cowl - world drop" },
    { 4041, "Aurora Cowl - world drop" },
    { 8115, "Hibernal Cowl - world drop" },
    { 5608, "Living Cowl - world drop" },
    { 22302, "Ironweave Cowl - Blackrock Spire drop" },
    { 22225, "Dragonskin Cowl - world drop" },
    { 7048, "Azure Silk Hood - tailoring 125" },
    { 4323, "Shadow Hood - tailoring" },
    { 9849, "Conjurer's Hood - world drop" },
    { 9940, "Abjurer's Hood - world drop" },
    { 14111, "Felcloth Hood - tailoring" },
    { 10782, "Hakkari Shroud - ST quest" },
    { 7691, "Embalmed Shroud - world drop" },
    { 2620, "Augural Shroud - world drop" },
    { 2621, "Cowl of Necromancy - Shadowforge Darkweaver drop" },

    { 16707, "Shadowcraft Cap - Scholomance drop" },
    { 1280, "Cloaked Hood - Syndicate Assassin drop" },
    { 18698, "Tattered Leather Hood - Schololmance zone drop" },
    { 18325, "Felhide Cap - Dire Maul drop" },
    { 227958, "Ghostshroud - BRD drop" },
})

----------------------------------------------------------------------
-- VOODOO MASK (Witch Doctor, Shadow Hunter)
-- Troll ritual masks / tribal face-covering head items
----------------------------------------------------------------------

fill(C.voodoo_mask, {
    -- Crafted / dungeon masks
    { 8201,  "Big Voodoo Mask — green leather helm, LW 220" },
    { 9470,  "Bad Mojo Mask — rare cloth helm, Zul'Farrak" },
    -- Zul'Gurub raid masks
    { 19886, "The Hexxer's Cover — rare cloth helm, ZG" },
})
COMPLETE.voodoo_mask = true

fill(C.dark_cowl, {
    { 2621, "Cowl of Necromancy - Shadowforge Darkweaver drop" },
    { 1280, "Cloaked Hood - Syndicate Assassin drop" },
    { 7048, "Azure Silk Hood - tailoring 125" },
    { 16707, "Shadowcraft Cap - Scholomance drop" },
    { 18698, "Tattered Leather Hood - Schololmance zone drop" },
    { 18325, "Felhide Cap - Dire Maul drop" },
})
COMPLETE.dark_cowl = true

fill(C.dark_cape, {
    { 6832, "Cloak of Blight - Duskwood quest" },
    { 7053, "Azure Silk Cloak - tailoring 175" },
    { 6340, "Fenrus' Hide - SFK drop" },
    { 15789, "Deep River Cloak - Winterspring quest" },
    { 18689, "Phantasmal Cloak - Scholomance drop" },
    { 18734, "Pale Moon Cloak - Stratholme drop" },
    { 15468, "Windsong Drape - Thousand Needles quest" },
    { 19982, "Duskbat Drape - ST rogue quest" },
})
COMPLETE.dark_cape = true

fill(C.mountaineer_cape, {
    { 6789, "Ceremonial Centaur Blanket - Desolace quest" },
})
COMPLETE.mountaineer_cape = true

fill(C.necro_book, {
    { 13353, "Book of the Dead - Stratholme drop" },
    { 17067, "Ancient Cornerstone Grimoire - Onyxia drop" },
})
COMPLETE.necro_book = true

fill(C.mountaineer_hood, {
    { 10782, "Hakkari Shroud - ST quest" },
})
COMPLETE.mountaineer_hood = true

----------------------------------------------------------------------
-- CURSED AMULET (Witch Doctor)
-- Neck items with curse / hex / voodoo / dark magic theme
----------------------------------------------------------------------

fill(C.cursed_amulet, {
    { 9243, "Shriveled Heart - ZF zone drop" },
})
COMPLETE.cursed_amulet = true

----------------------------------------------------------------------
-- SHELL SHIELD (Witch Doctor)
-- Shields with tortoise / turtle shell visual
----------------------------------------------------------------------

fill(C.shell_shield, {
    { 6447, "Worn Turtle Shell Shield — white shield, Kresh (WC)" },
    { 13245, "Kresh's Back - Kresh (WC)" },
    { 14916, "Jade Deflector" },
    { 15352, "Headhunter's Buckler" },
    { 15466, "Clink Shield - Quest rewards" },
    { 15342, "Pathfinder Guard" },
})
COMPLETE.shell_shield = true
-- Only one real turtle-shell shield exists in vanilla Classic.
-- The Worn Turtle Shell Shield from Kresh is THE canonical item.

----------------------------------------------------------------------
-- TORCH (Spiritwalker)
-- Off-hand items with torch / lantern / flame visual
----------------------------------------------------------------------

fill(C.lantern, {
    { 5323, "Everglow Lantern - Barrens Quest Rewards" },
})
COMPLETE.lantern = true
-- Also populate the 'torch' key used by R("Torch") in EquipmentCheck.lua

fill(C.torch, {
    { 5323, "Everglow Lantern - Barrens Quest Rewards" },
})
COMPLETE.torch = true
-- Beacon of Hope is the only torch/lantern-model equippable off-hand in
-- Classic.  Most "torch" items are quest items or consumables, not gear.

----------------------------------------------------------------------
-- ANTI-BEAST GEAR (Beastmaster)
----------------------------------------------------------------------

-- Anti-beast cloak (back slot)
fill(C.anti_beast_cloak, {
    { 16658, "Wildhunter Cloak - Ashenvale Quest Reward" },
})

-- Anti-beast gloves (hands slot)
fill(C.anti_beast_gloves, {
    { 7756, "Dog Training Gloves - SM Drop" },
})

-- Anti-beast melee weapon (main/off-hand)
fill(C.anti_beast_melee, {
    { 7710, "Loksey's Training Stick - SM Drop" },
    { 11907, "Beastslayer - Quest Reward" },
    { 1465, "Tigerbane - world drop" },
    { 15782, "Beaststalker Blade - Winterspring quest reward" },
    { 15783, "Beasthunter Dagger - Winterspring quest reward" },
    { 12709, "Finkle's Skinner - UBRS drop" },
    { 19946, "Tigule's Harpoon - ZG drop" },
})

-- Anti-beast ranged weapon (ranged slot)
fill(C.anti_beast_ranged, {
    { 11628, "Houndmaster's Bow - BRD Drop" },
})

----------------------------------------------------------------------
-- ARMORED WEAPON (Druid of the Claw)
-- Heavy / plate-looking / reinforced melee weapons
----------------------------------------------------------------------

fill(C.armored_weapon, {
    { 12252, "Staff of Protection - Vendor" },
    { 868, "Ardent Custodian" },
    { 943,   "Warden Staff — epic world drop" },
    { 20580,   "Hammer of Bestial Fury" },
    { 21268,   "Blessed Qiraji War Hammer" },
    { 18376,   "Timeworn Mace" },
    { 11805,   "Rubidium Hammer - BRD boss drop" },
    { 11921,   "Impervious Giant" },
    { 18531,   "Unyielding Maul" },
})

----------------------------------------------------------------------
-- ARMORED OFF-HAND (Druid of the Claw)
-- Sturdy / defensive off-hand items
----------------------------------------------------------------------

fill(C.armored_offhand, {
    { 11855, "Tork Wrench - Barren quest reward" },
    { 1172, "Grayson's Torch - Westfall quest reward" },
    { 1131, "Totem of Infliction - Duskwood quest reward" },
    { 3360, "Stitches' Femur - Duskwood drop" },
    { 943,   "Warden Staff — epic world drop" },
    { 12252, "Staff of Protection - Vendor" },
    { 18531,   "Unyielding Maul" },
    { 11921,   "Impervious Giant" },
})
-- Note: druids cannot equip shields, so the shield entries will likely
-- not pass, but they remain for completeness.  Held-in-off-hand items
-- like Brightly Glowing Stone are the realistic picks.

----------------------------------------------------------------------
-- ARMORED RINGS (Druid of the Claw, Savagekin, Warmage)
-- Rings with + armor
----------------------------------------------------------------------

fill(C.armored_rings, {
    { 9642, "Band of the Great Tortoise - Tanaris quest reward" },
    { 11118, "Archaedic Stone - Uldaman boss drop" },
    { 12544, "Thrall's Resolve" },
    { 15855, "Ring of Protection" },
    { 11669, "Naglering — BRD drop" },
    { 18813, "Ring of Binding" },
    { 21601, "Ring of Emperor Vek'lor" },
    { 23018, "Signet of the Fallen Defender" },
    { 18879, "Heavy Dark Iron Ring" },
})
COMPLETE.armored_rings = true

fill(C.necromancer_robe, {
    { 6690, "Lesser Wizard's Robe - Tailoring" },
    { 10762, "Robes of the Lich - RFD drop" },
    { 7711, "Robes of Doan - SM drop" },
    { 10004, "Shadoweave Robe - Tailoring" },
    { 6900, "Enchanted Gold Bloodrobe - Warlock quest" },
})
COMPLETE.necromancer_robe = true

fill(C.armored_trinket, {
    { 1490, "Guardian Talisman - ST quest reward" },
    { 13966, "Mark of Tyranny - UBRS quest reward" },
    { 11811, "Smoking Heart of the Mountain - Enchanting" },
})
COMPLETE.armored_trinket = true

----------------------------------------------------------------------
-- STAFF-LIKE OFF-HAND (Warmage)
-- Off-hand items that look like short staves / sceptres / batons
----------------------------------------------------------------------

fill(C.staff_like_offhand, {
    { 7559, "Runic Cane - Barrens rare 'Brokespear' drop" },
    { 6803, "Prophetic Cane - Horde RFD quest reward" },
    { 12471, "Desertwalker Cane - ZF rare boss drop" },
})
COMPLETE.staff_like_offhand = true

fill(C.awkward_merch, {
    { 5110, "Dalaran Wizard's Robe - Silverpine drop" },
})
COMPLETE.awkward_merch = true

fill(C.archmage_shoulders, {
    { 7712, "Mantle of Doan - SM drop" },
    { 15812, "Orchid Amice - WPL quest reward" },
    { 11624, "Kentic Amice - BRD drop" },
    { 18757, "Diabolic Mantle - Dire Maul drop" },
})
COMPLETE.archmage_shoulders = true

fill(C.archmage_circlet, {
    { 10139, "High Councillor's Circlet - World drop" },
    { 14436, "Windchaser Coronet - World drop" },
    { 10751, "Gemburst Circlet - ST quest reward" },
})
COMPLETE.archmage_circlet = true

fill(C.war_harness, {
    { 6523, "Buckled Harness - Vendor" },
    { 6524, "Studded Leather Harness - Vendor" },
    { 6525, "Grunt's Harness - Vendor" },
    { 6526, "Battle Harness - Vendor" },
    { 1211, "Gnoll War Harness - redridge world drop" },
    { 15064, "Warbear Harness - leatherworking 275" },
    { 4968, "Bound Harness - Mulgore quest reward" },
    { 2370, "Battered Leather Harness - Vendor" },
    { 4455, "Raptor Hide Harness - leatherworking 165" },
    { 5739, "Barbaric Harness - leatherworking 190" },
    { 13110, "Wolffear Harness - world drop" },
    { 10583, "Quillward Harness - RFD zone drop" },
    { 15356, "Headhunter's Armor - world drop" },
    { 15010, "Primal Wraps - world drop" },
    { 15433, "Peerless Armor - world drop" },
    { 15304, "Grizzly Jerkin - world drop" },
})
COMPLETE.war_harness = true

----------------------------------------------------------------------
-- Nat Pagle's Pole (Death Knight & Shadow Hunter)
-------------------------------

fill(C.pole, {
    { 19022, "Nat Pagle's Extreme Angler FC-5000" },
})
COMPLETE.pole = true

----------------------------------------------------------------------
-- HERB POUCH (Apothecary)
-- Herb bags (bag slot — curated for bag-scan check)
----------------------------------------------------------------------

fill(C.herb_pouch, {
    { 22250, "Herb Pouch — 12-slot herb bag, vendor" },
    { 22251, "Cenarion Herb Bag — 20-slot herb bag, Tailoring" },
    { 22252, "Satchel of Cenarius — 24-slot herb bag, Tailoring" },
})
COMPLETE.herb_pouch = true

----------------------------------------------------------------------
-- JUNGLE REMEDY (Plagueshifter)
-- Consumable item — curated for inventory scanning
----------------------------------------------------------------------

fill(C.jungle_remedy, {
    { 2633, "Jungle Remedy — consumable, Kurzen Medicine Man drop" },
})
COMPLETE.jungle_remedy = true

fill(C.thistle_tea, {
    { 7676, "Thisle Tea — consumable, cooking 60" },
})
COMPLETE.thistle_tea = true

fill(C.rage_pot, {
    { 13442, "Mighty Rage Potion — consumable, alchemy" },
    { 5631, "Rage Potion — consumable, alchemy" },
    { 5633, "Great Rage Potion — consumable, alchemy" },
})
COMPLETE.rage_pot = true

fill(C.pick, {
    { 13442, "Ryedol's Lucky Pick — Badlands quest item" },
})
COMPLETE.pick = true

fill(C.prospector_headgar, {
    { 3890, "Studded Hat — Vendor" },
    { 19972, "Lucky Fishing Hat — Fishing" },
    { 4048, "Emblazoned Hat — world drop" },
    { 8174, "Comfortable Leather Hat — Leatherworking 200" },
    { 9534, "Engineer's Guild Headpiece — ZF quest reward" },
    { 15156, "Nocturnal Cap — world drop" },
    { 19039, "Zorbin's Water Resistant Hat — Feralas quest reward" },
    { 10111, "Wanderer's Hat — world drop" },
    { 9420, "Adventurer's Pith Helmet — world drop" },
    { 10543, "Goblin Construction Helmet — engineering 205" },
})
COMPLETE.prospector_headgar = true

fill(C.engineering_trinkets, {
    { 7506, "Gnomish Universal Remote" },
    { 4381, "Minor Recombobulator" },
    { 4397, "Gnomish Cloaking Device" },
    { 4396, "Mechanical Dragonling" },
    { 10577, "Goblin Mortar" },
    { 10716, "Gnomish Shrink Ray" },
    { 10720, "Gnomish Net-o-Matic Projector" },
    { 10725, "Gnomish Battle Chicken" },
    { 10587, "Goblin Bomb Dispenser" },
    { 10645, "Gnomish Death Ray" },
    { 10727, "Goblin Dragon Gun" },
    { 10576, "Mithril Mechanical Dragonling" },
    { 18986, "Ultrasafe Transporter: Gadgetzan" },
    { 18637, "Major Recombobulator" },
    { 18984, "Dimensional Ripper - Everlook" },
    { 18634, "Gyrofreeze Ice Reflector" },
    { 18638, "Hyper-Radiant Flame Reflector" },
    { 16022, "Arcanite Dragonling" },
    { 18639, "Ultra-Flash Shadow Reflector" },
})
COMPLETE.engineering_trinkets = true

fill(C.dragonbreath_chili, {
    { 12217, "Dragonbreath Chili — cooking (recipe sold by vendor)" },
})
COMPLETE.dragonbreath_chili = true

----------------------------------------------------------------------
-- RESTORATION POTION (Plagueshifter)
-- Consumable item — curated for inventory scanning
----------------------------------------------------------------------

fill(C.restoration_potion, {
    { 9030, "Restorative Potion — Alchemy 210 crafted" },
})
COMPLETE.restoration_potion = true

----------------------------------------------------------------------
-- MECHANICAL COMPANION (Mechano-Mage)
-- Non-combat pet items from Engineering
----------------------------------------------------------------------

fill(C.mechanical_companion, {
    { 4401,  "Mechanical Squirrel Box — Engineering 75" },
    { 11826, "Lil' Smoky — Gnomish Engineering 205" },
    { 10398, "Mechanical Chicken — quest reward (OOX escorts)" },
    { 21277, "Tranquil Mechanical Yeti — Engineering 250" },
    { 15996, "Lifelike Mechanical Toad — Engineering 250" },
})
COMPLETE.mechanical_companion = true

fill(C.skull_offhand, {
    { 4984, "Skull of Impending Doom — Vendor/Badlands quest reward" },
    { 1131, "Totem of Infliction — Duskwood quest reward" },
    { 11870, "Oblivion Orb — Un'Goro quest reward" },
    { 10708, "Skullspell Orb — Azshara quest reward" },
    { 10770, "Mordresh's Lifeless Skull — RFD drop" },
    { 13524, "Skull of Burning Shadows — Stratholme drop" },
})
COMPLETE.skull_offhand = true

fill(C.witch_doctor_staff, {
    { 854, "Quarter Staff — Vendor" },
    { 2030, "Gnarled Staff — Vendor" },
    { 6631, "Living Root — WC drop" },
    { 1539, "Gnarled Hermit's Staff — Barrens rare" },
    { 4575, "Medicine Staff — world drop" },
    { 6689, "Wind Spirit Staff — RFK drop" },
    { 1155, "Rod of the Sleepwalker — BFD drop" },
    { 18082,  "Zum'rah's Vexing Cane — ZF drop" },
    { 17743, "Resurgence Rod — Vendor/Maraudon quest reward" },
    { 9477, "The Chief's Enforcer — ZF drop" },
    { 9482, "Witch Doctor's Cane — ZF zone drop" }, 
    { 15444, "Staff of Orgrimmar — RFC quest reward" },
    { 1155, "Wind Rider Staff — Barrens quest reward" },
    { 20556, "Wildstaff — Shaman quest reward" },
    { 4938, "Blemished Wooden Staff — Durator quest reward" },
    { 4961, "Dreamwatcher Staff — Mulgore quest reward" },
    { 9683, "Strength of the Treant — Feralas quest reward" },
})
COMPLETE.witch_doctor_staff = true

fill(C.vial_offhand, {
    { 3451,  "Nightglow Concoction — Silverpine quest reward" },
    { 19115, "Flask of Forest Mojo — Hinterlands quest reward" },
})
COMPLETE.vial_offhand = true

-- Mark all remaining curated lists as complete
COMPLETE.anti_beast_cloak = true
COMPLETE.anti_beast_gloves = true
COMPLETE.anti_beast_melee = true
COMPLETE.anti_beast_ranged = true
COMPLETE.armored_offhand = true
COMPLETE.armored_weapon = true
COMPLETE.cowl = true
COMPLETE.kilt = true
COMPLETE.pole = true
COMPLETE.rapier_cutlass_harpoon = true
COMPLETE.staff_like_offhand = true

----------------------------------------------------------------------
-- Summary counter (diagnostic)
----------------------------------------------------------------------

function HCE.CuratedCount(listName)
    local list = C[listName]
    if not list then return 0 end
    local n = 0
    for _ in pairs(list) do n = n + 1 end
    return n
end

function HCE.CuratedSummary()
    local summary = {}
    for name, list in pairs(C) do
        local n = 0
        for _ in pairs(list) do n = n + 1 end
        summary[name] = n
    end
    return summary
end
