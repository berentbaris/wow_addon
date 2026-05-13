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

fill(C.wizard_hat, {
    { 3556,  "Dread Mage Hat — Warlock Quest Reward" },
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
    { 851,   "Cutlass — white 1H sword" },
    { 1951,  "Blackwater Cutlass — green 1H sword, Defias Pirate drop" },
    { 9446, "Electrocutioner Leg — rare 1H sword (Gnomeregan)" },
    { 2528, "Falchion - Vendor" },
    { 10799, "Headspike" },


    -- Rapier / dueling swords
    { 5191,  "Cruel Barb — rare 1H sword, Deadmines" },
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
    { 7719, "Raging Berserker's Helm — Sm drop" },
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
    { 18856, "Insignia of the Alliance — Paladin" },
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
    -- Leather cowls (rogue / druid tier)
    { 16707, "Shadowcraft Cap — rare leather helm, Rogue T0" },
    { 22005, "Darkmantle Cap — epic leather helm, Rogue T0.5" },

    -- Cloth hoods
    { 3732, "Hooded Cowl - quest rewards from Hillsbrad" },
    { 4322, "Enchanter's Cowl" },
    { 4039, "Nightsky Cowl" },
    { 7432, "Twilight Cowl" },
    { 4041, "Aurora Cowl" },
    { 8115, "Hibernal Cowl" },
    { 5608, "Living Cowl" },
    { 22302, "Ironweave Cowl" },
    { 22225, "Dragonskin Cowl" },
    { 7048, "Azure Silk Hood - tailoring 125" },
    { 4323, "Shadow Hood" },
    { 9849, "Conjurer's Hood" },
    { 9940, "Abjurer's Hood" },
    { 14111, "Felcloth Hood" },
    { 10782, "Hakkari Shroud" },
    { 7691, "Embalmed Shroud" },
    { 2620, "Augural Shroud" },
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
    { 15945, "Runic Stave - world drop" },
    { 7609, "Elder's Amber Stave - world drop" },
    { 15925, "Journeyman's Stave - world drop" },
    { 7611, "Mistscape Stave - world drop" },
    { 15967, "Highborne Star - world drop" },
    { 15942, "Master's Rod - world drop" },
    { 15989, "Eternal Rod - world drop" },
    { 15947, "Sanguine Star - world drop" },
    { 15963, "Stonecloth Branch - world drop" },
    { 15974, "Pagan Rod - world drop" },
    { 15982, "Bloodwoven Rod - world drop" },
    { 15971, "Aboriginal Rod - world drop" },
    { 15928, "Silver-thread Rod - world drop" },
    { 15979, "Embersilk Stave - world drop" },
    { 15978, "Geomancer's Rod - world drop" },
    { 15962, "Satyr's Rod - world drop" },
    { 15934, "Sage's Stave - world drop" },
})

----------------------------------------------------------------------
-- Nat Pagle's Pole (Death Knight & Shadow Hunter)
-------------------------------

fill(C.pole, {
    { 19022, "Nat Pagle's Extreme Angler FC-5000" },

})

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
    { 4984,  "Skull of Impending Doom — Vendor/Badlands quest reward" },
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
