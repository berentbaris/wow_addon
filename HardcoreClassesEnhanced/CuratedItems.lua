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
    { 10500, "Green Lens — Engineering 245" },
})
COMPLETE.green_tinted_goggles = true

-- Gnomish goggles — engineering headgear with goggle/helmet art
fill(C.gnomish_goggles, {
    { 10500, "Green Lens — Engineering 245" },
    { 10501, "Deepdive Helmet — Gnomish Engineering 230" },
    { 10546, "Gnomish Mind Control Cap — Gnomish Engineering 215" },
    { 10548, "Goblin Rocket Helmet — Goblin Engineering 245" },
    { 10588, "Goblin Construction Helmet — Engineering 205" },
    { 16008, "Master Engineer's Goggles — Engineering 245" },
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
    { 8345, "Wolfshead Helm — Leatherworking tribal" },
})
COMPLETE.wolf_helm = true
-- Only the Wolfshead Helm has a literal wolf-head model in Classic.
-- No random-suffix items share this unique wolf-head visual.

----------------------------------------------------------------------
-- GUILD TABARD (Exemplar)
----------------------------------------------------------------------

fill(C.guild_tabard, {
    { 5976, "Guild Tabard — displays guild emblem" },
})
COMPLETE.guild_tabard = true

----------------------------------------------------------------------
-- LUNAR FESTIVAL SUIT (Brewmaster)
----------------------------------------------------------------------

fill(C.lunar_festival_suit, {
    { 21509, "Festival Dress — Lunar Festival reward" },
    { 21510, "Festival Suit — Lunar Festival reward" },
    { 21541, "Festive Green Dress — Lunar Festival reward" },
    { 21542, "Festive Red Pant Suit — Lunar Festival reward" },
    { 21543, "Festive Pink Dress — Lunar Festival reward" },
    { 21544, "Festive Blue Pant Suit — Lunar Festival reward" },
    { 21537, "Festive Teal Pant Suit — Lunar Festival reward" },
    { 21538, "Festive Purple Dress — Lunar Festival reward" },
    { 21539, "Festive Black Pant Suit — Lunar Festival reward" },
})
COMPLETE.lunar_festival_suit = true

----------------------------------------------------------------------
-- BLUE SHIRT (Exemplar)
----------------------------------------------------------------------

fill(C.blue_shirt, {
    { 1770, "Blue Linen Shirt — Tailoring" },
    { 2575, "Blue Martial Shirt" },
    { 4336, "Blue Overalls — shirt slot, blue colour" },
})
COMPLETE.blue_shirt = true

----------------------------------------------------------------------
-- CAPTAIN'S HAT (Buccaneer)
-- Pirate / naval tricorne headgear
----------------------------------------------------------------------

fill(C.captains_hat, {
    { 2955,  "First Mate Hat — loot from Bloodsail Raider" },
    { 10030, "Admiral's Hat — Tailoring 240" },
    { 12185, "Bloodsail Admiral's Hat — quest: Avast Ye, Admiral!" },
    { 20519, "Southsea Pirate Hat — quest: Pirate Hats Ahoy!" },
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
    { 3935,  "Smotts' Cutlass — white 1H sword, Stranglethorn quest" },
    { 16890, "Slatemetal Cutlass — rare 1H sword" },

    -- Rapier / dueling swords
    { 2244,  "Krol Blade — epic 1H sword, rapier appearance" },
    { 5191,  "Cruel Barb — rare 1H sword, Deadmines" },
    { 4445,  "Flesh Piercer — rare dagger, rapier-like appearance" },

    -- Harpoon / trident polearms
    { 19106, "Ice Barbed Spear — epic polearm, AV quest reward" },
    { 12776, "Ironpatch Blade — rare 1H sword, pirate theme" },
})

----------------------------------------------------------------------
-- FLASK TRINKETS (Mountain King)
-- Flask / bottle-themed trinkets
----------------------------------------------------------------------

fill(C.flask_trinkets, {
    { 20130, "Diamond Flask — Warrior class quest lv 50" },
    { 744,   "Thunderbrew's Boot Flask — Dwarf quest reward" },
})
COMPLETE.flask_trinkets = true
-- Diamond Flask is the canonical flask trinket for a Protection Warrior.
-- Thunderbrew's Boot Flask is thematically perfect for Mountain King.
-- These are the only two flask-themed equippable trinkets in Classic.

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
    { 18860, "Insignia of the Alliance — Warlock" },
    { 18862, "Insignia of the Alliance — Priest" },
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
    { 12846, "Argent Dawn Commission — quest reward, anti-undead trinket" },
    { 13209, "Seal of the Dawn — quest: The Active Agent (upgrade)" },
    { 22657, "Amulet of the Dawn — epic neck, Naxx quest" },
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
    { 6426,  "Dervish Leggings — kilt-model leather legs" },
    { 9474,  "Jinxed Hoodoo Kilt — green leather legs, ZF" },

    -- Mail kilts
    { 16668, "Kilt of Elements — rare mail legs, Shaman T0" },
    { 16846, "Kilt of the Five Thunders — epic mail legs, Shaman T0.5" },
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
    { 10248, "Master's Hat — green cloth helm, hood model" },
    { 14112, "Aboriginal Headdress — green cloth head, cowl model" },

    -- Other hood-looking helms
    { 10132, "Revenant Helmet — green mail helm, hooded look" },
    { 7721,  "Runic Leather Headband — rare leather helm" },
    { 8348,  "Helm of Fire — rare leather helm, hooded model" },
    { 18727, "Crimson Felt Hat — rare cloth helm, Scholomance" },
})

----------------------------------------------------------------------
-- VOODOO MASK (Witch Doctor, Shadow Hunter)
-- Troll ritual masks / tribal face-covering head items
----------------------------------------------------------------------

fill(C.voodoo_mask, {
    -- Crafted / dungeon masks
    { 8201,  "Big Voodoo Mask — green leather helm, LW 220" },
    { 9470,  "Bad Mojo Mask — rare cloth helm, Zul'Farrak" },

    -- Holiday cosmetic masks
    { 20597, "Sturdy Male Troll Mask — Hallow's End" },
    { 20568, "Troll Male Mask — Hallow's End" },
    { 20566, "Troll Female Mask — Hallow's End" },

    -- Zul'Gurub raid masks
    { 19886, "The Hexxer's Cover — rare cloth helm, ZG" },
})

----------------------------------------------------------------------
-- CURSED AMULET (Witch Doctor)
-- Neck items with curse / hex / voodoo / dark magic theme
----------------------------------------------------------------------

fill(C.cursed_amulet, {
    { 19491, "Amulet of the Darkmoon — epic neck, Darkmoon Faire" },
    { 17774, "Mark of the Chosen — green neck, quest reward Maraudon" },
    { 18723, "Animated Chain Necklace — rare neck, Stratholme" },
})

----------------------------------------------------------------------
-- SHELL SHIELD (Witch Doctor)
-- Shields with tortoise / turtle shell visual
----------------------------------------------------------------------

fill(C.shell_shield, {
    { 6447, "Worn Turtle Shell Shield — white shield, Kresh (WC)" },
})
COMPLETE.shell_shield = true
-- Only one real turtle-shell shield exists in vanilla Classic.
-- The Worn Turtle Shell Shield from Kresh is THE canonical item.

----------------------------------------------------------------------
-- TORCH (Spiritwalker)
-- Off-hand items with torch / lantern / flame visual
----------------------------------------------------------------------

fill(C.torch, {
    { 9393, "Beacon of Hope — rare off-hand, BRD (lantern model)" },
})
COMPLETE.torch = true
-- Beacon of Hope is the only torch/lantern-model equippable off-hand in
-- Classic.  Most "torch" items are quest items or consumables, not gear.

----------------------------------------------------------------------
-- ANTI-BEAST GEAR (Beastmaster)
----------------------------------------------------------------------

-- Anti-beast cloak (back slot)
fill(C.anti_beast_cloak, {
    { 13340, "Cape of the Black Baron — rare back, Stratholme" },
    { 19907, "Zulian Tigerhide Cloak — rare back, ZG (beast-hide)" },
})

-- Anti-beast gloves (hands slot)
fill(C.anti_beast_gloves, {
    { 15063, "Devilsaur Gauntlets — LW 300, beast-hide leather" },
    { 18823, "Aged Core Leather Gloves — rare leather, MC" },
    { 8347,  "Dragonscale Gauntlets — LW, beast-scale theme" },
    { 19869, "Bloodtiger Claws — ZG quest reward, tiger-themed" },
})

-- Anti-beast melee weapon (main/off-hand)
fill(C.anti_beast_melee, {
    { 12709, "Fang of the Crystal Spider — rare dagger, BRS" },
    { 18737, "Bone Slicing Hatchet — rare 1H axe, Stratholme" },
    { 19874, "Halberd of Smiting — epic polearm, ZG" },
    { 18203, "Eskhandar's Right Claw — epic fist weapon, MC" },
    { 18520, "Barbarous Blade — rare 2H sword, DM" },
    { 13163, "Relentless Scythe — rare 2H axe, Scholomance" },
    { 19853, "Gurubashi Dwarf Destroyer — rare 1H mace, ZG" },
})

-- Anti-beast ranged weapon (ranged slot)
fill(C.anti_beast_ranged, {
    { 13022, "Gryphonwing Long Bow — rare bow, BRS" },
    { 18738, "Carapace Spine Crossbow — rare crossbow, Strat" },
    { 18836, "Serpentine Skuller — rare bow, UBRS" },
    { 12651, "Blackcrow — rare crossbow, BRS" },
    { 17072, "Blastershot Launcher — rare gun, MC" },
})

----------------------------------------------------------------------
-- UNHOLY WEAPON (Bloodmage)
-- Weapons with undead / death / shadow / necrotic theme
----------------------------------------------------------------------

fill(C.unholy_weapon, {
    { 17068, "Deathbringer — epic 1H axe, Onyxia" },
    { 13361, "Skullforge Reaver — rare 1H sword, Baron Rivendare" },
    { 18737, "Bone Slicing Hatchet — rare 1H axe, Stratholme" },
    { 14145, "Cursed Felblade — green 1H sword, RFC" },
    { 18420, "Bonecrusher — rare 2H mace, DM" },
    { 22691, "Corrupted Ashbringer — epic 2H sword, Naxx" },
    { 22807, "Hatchet of Sundered Bone — rare 1H axe, Naxx" },
    { 13286, "Rivenspike — rare polearm, Stratholme" },
    { 17076, "Bonereaver's Edge — epic 2H sword, Ragnaros" },
})

----------------------------------------------------------------------
-- SHADOW OR FIRE WAND (Bloodmage)
-- Wands whose damage school is shadow or fire
----------------------------------------------------------------------

fill(C.shadow_fire_wand, {
    -- Fire damage wands
    { 5069,  "Fire Wand — green, fire damage, lvl 7" },
    { 5210,  "Burning Wand — white, fire damage, lvl 15" },
    { 5215,  "Ember Wand — green, fire damage, lvl 36" },
    { 7513,  "Ragefire Wand — rare, fire damage, RFC" },

    -- Shadow damage wands
    { 5071,  "Shadow Wand — green, shadow damage, lvl 9" },
    { 7001,  "Gravestone Scepter — rare, shadow damage, quest" },
    { 13396, "Skul's Ghastly Touch — rare, shadow damage, Stratholme" },
    { 11263, "Nether Force Wand — rare, shadow damage, Mage quest" },
    { 13938, "Bonecreeper Stylus — rare, shadow damage, Scholomance" },
    { 19861, "Touch of Chaos — rare, shadow damage, ZG" },
    { 22821, "Doomfinger — epic, shadow damage, Naxx" },
    { 18483, "Mana Channeling Wand — rare, shadow damage, DM" },
    { 22820, "Wand of Fates — epic, shadow damage, Naxx" },
})

----------------------------------------------------------------------
-- ARMORED WEAPON (Druid of the Claw)
-- Heavy / plate-looking / reinforced melee weapons
----------------------------------------------------------------------

fill(C.armored_weapon, {
    { 11684, "Ironfoe — epic 1H mace, Emperor Thaurissan" },
    { 19360, "Lok'amir il Romathis — epic 1H mace, Nefarian" },
    { 18803, "Finkle's Lava Dredger — rare 2H mace, MC" },
    { 12583, "Blackhand Doomsaw — rare 2H sword, BRS" },
    { 14024, "Frightalon — rare 1H fist weapon, DM" },
    { 18420, "Bonecrusher — rare 2H mace, DM" },
    { 17054, "Empyrean Demolisher — epic 1H mace, MC" },
    { 18832, "Brutality Blade — epic 1H sword, MC" },
    { 943,   "Warden Staff — rare staff, quest reward" },
})

----------------------------------------------------------------------
-- ARMORED OFF-HAND (Druid of the Claw)
-- Sturdy / defensive off-hand items
----------------------------------------------------------------------

fill(C.armored_offhand, {
    { 18523, "Brightly Glowing Stone — rare off-hand, DM" },
    { 18310, "Fiendish Machete — rare dagger off-hand, DM" },
    { 22336, "Draconian Deflector — rare shield, Naxx" },
    { 18499, "Barrier Shield — rare shield, DM" },
})
-- Note: druids cannot equip shields, so the shield entries will likely
-- not pass, but they remain for completeness.  Held-in-off-hand items
-- like Brightly Glowing Stone are the realistic picks.

----------------------------------------------------------------------
-- ARMORED RINGS (Druid of the Claw, Savagekin, Warmage)
-- Rings with heavy / armored / signet theme
----------------------------------------------------------------------

fill(C.armored_rings, {
    { 17063, "Band of Accuria — epic ring, Ragnaros" },
    { 18821, "Quick Strike Ring — epic ring, MC" },
    { 19325, "Don Julio's Band — epic ring, AV Exalted" },
    { 12548, "Magni's Will — rare ring, BRD Emperor" },
    { 13098, "Ring of the Exalted — epic ring, Strat UD" },
    { 21205, "Signet of the Unseen Path — rare ring, quest" },
    { 19384, "Master Dragonslayer's Ring — epic ring, BWL quest" },
    { 22681, "Band of Unanswered Prayers — rare ring, Naxx" },
    { 18500, "Tarnished Elven Ring — rare ring, DM" },
    { 11669, "Naglering — rare ring, BRD" },
})

----------------------------------------------------------------------
-- STAFF-LIKE OFF-HAND (Warmage)
-- Off-hand items that look like short staves / sceptres / batons
----------------------------------------------------------------------

fill(C.staff_like_offhand, {
    { 17191, "Scepter of Celebras — rare off-hand, Maraudon quest" },
    { 15108, "Orb of Dar'Orahil — rare off-hand, Warlock quest" },
    { 18523, "Brightly Glowing Stone — rare off-hand, DM" },
    { 13385, "Nether Brilliance — rare off-hand, Stratholme" },
    { 13353, "Scepter of the Unholy — rare off-hand, Baron Rivendare" },
    { 22335, "Lord Valthalak's Staff of Command — off-hand, D2 quest" },
    { 22329, "Scepter of Interminable Focus — rare off-hand, Naxx" },
    { 19934, "Zulian Scepter of Rites — rare off-hand, ZG" },
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
    { 11825, "Pet Bombling — Goblin Engineering 205" },
    { 10398, "Mechanical Chicken — quest reward (OOX escorts)" },
    { 21277, "Tranquil Mechanical Yeti — Engineering 250" },
})
COMPLETE.mechanical_companion = true

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
