----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Per-Character Talent Requirements
--
-- On top of the spec-plurality rule (majority of points in the
-- character's native tree), each character may require specific
-- talents at specific levels.
--
-- Data format per entry:
--   name  = English talent name (matched via GetTalentInfo scan)
--   tab   = talent tab index (1/2/3), locale-independent
--   rank  = minimum points required in this talent
--   level = player level at which this requirement activates
--
-- Tab reference:
--   Warrior:  1=Arms,       2=Fury,       3=Protection
--   Rogue:    1=Assassination, 2=Combat,  3=Subtlety
--   Warlock:  1=Affliction,  2=Demonology, 3=Destruction
--   Druid:    1=Balance,     2=Feral,      3=Restoration
--   Hunter:   1=Beast Mastery, 2=Marksmanship, 3=Survival
--   Shaman:   1=Elemental,   2=Enhancement, 3=Restoration
--   Paladin:  1=Holy,        2=Protection,  3=Retribution
--   Priest:   1=Discipline,  2=Holy,        3=Shadow
--   Mage:     1=Arcane,      2=Fire,        3=Frost
----------------------------------------------------------------------

HCE = HCE or {}

local R = function(name, tab, rank, level, endLevel)
    return { name = name, tab = tab, rank = rank, level = level, endLevel = endLevel or nil }
end

HCE.TalentRequirements = {

    ---------- WARRIOR ----------

    ["Mountain King"] = {   -- Protection
        R("Last Stand",      3, 1, 20),
        R("Improved Shield Block",      3, 1, 21),
        R("Concussion Blow", 3, 1, 30),
        R("Shield Slam",     3, 1, 40),
        R("Anger Management", 1, 1, 51),
    },

    ["Brewmaster"] = {      -- Arms
        R("Improved Cleave",        2, 3, 23),
        R("Improved Slam",        2, 5, 35),
        R("Flurry",        2, 5, 41),
    },

    ["Runemaster"] = {    -- Fury
        R("Cruelty", 2, 5, 14),
        R("Blood Craze", 2, 3, 23),
        R("Enrage", 2, 5, 29),
        R("Flurry", 2, 5, 39),
        R("Bloodthirst", 2, 1, 40),
        R("Dual Wield Specialization", 2, 5, 41),
    },

    ["Berserker"] = {   -- Protection
        R("Cruelty", 2, 5, 14),
        R("Blood Craze", 2, 3, 23),
        R("Enrage", 2, 5, 29),
        R("Flurry", 2, 5, 39),
        R("Bloodthirst", 2, 1, 40),
        R("Dual Wield Specialization", 2, 5, 41),
        R("Last Stand", 3, 1, 52),
        R("Defiance",     3, 5, 57),
    },

    ["Sister of Steel"] = {   -- Protection
        R("Last Stand", 3, 1, 20),
        R("Improved Shield Block",      3, 1, 21),
        R("Improved Charge", 1, 2, 28),
        R("Improved Overpower", 1, 2, 33),
        R("Tactical Mastery", 1, 5, 35),
        R("Deflection", 1, 5, 39),
        R("Sweeping Strikes",     1, 1, 42),
        R("Defiance",     3, 5, 47),
        R("Concussion Blow", 3, 1, 51),
    },

    ["Blademaster"] = {      -- Arms
        R("Improved Overpower",        1, 2, 21),
        R("Impale",        1, 2, 26),
        R("Sword Specialization",        1, 5, 35),
        R("Two-Handed Weapon Specialization",        1, 5, 37),
        R("Mortal Strike", 1, 1, 40),
    },

    ["Brave"] = {      -- Slam
        R("Improved Overpower",        1, 2, 21),
        R("Impale",        1, 2, 26),
        R("Two-Handed Weapon Specialization",        1, 5, 37),
        R("Polearm Specialization",        1, 5, 39),
        R("Mortal Strike", 1, 1, 40),
    },

    ---------- ROGUE ----------

    ["Tinker"] = {       -- Assassination
        R("Riposte",             2, 1, 22),
        R("Mace Specialization",2, 5, 35),
        R("Aggression",2, 3, 40),
        R("Dual Wield Specialization",2, 5, 41),
    },

    ["Prospector"] = {       -- Assassination
        R("Remorseless Attacks",  1, 2, 11),
        R("Opportunity",    3, 5, 16),
        R("Improved Ambush",   3, 3, 25),
        R("Improved Sap",   3, 3, 34),
        R("Premeditation", 3, 1, 42),
    },

    ["Buccaneer"] = {       -- Survival
        R("Remorseless Attacks",  1, 2, 11),
        R("Improved Gouge",  2, 3, 16),
        R("Improved Backstab",    2, 3, 19),  -- Combat tree (cross-spec)
        R("Lethality",            1, 5, 33),
        R("Improved Kidney Shot", 1, 3, 41),
        R("Seal Fate", 1, 5, 47),
        R("Opportunity",          3, 5, 53),  -- Subtlety tree (cross-spec)
    },

    ["Demon Hunter"] = {          -- Combat
        R("Riposte",             2, 1, 22),
        R("Lightning Reflexes",  2, 5, 25),
        R("Sword Specialization",2, 5, 35),
        R("Weapon Expertise",2, 2, 37),
        R("Dual Wield Specialization",2, 5, 38),
        R("Ghostly Strike",      3, 1, 53),  -- Subtlety tree (cross-spec)
        R("Setup",               3, 2, 59),  -- Subtlety tree (cross-spec)
    },

    ["Warden"] = {      -- Subtlety
        R("Remorseless Attacks",  1, 2, 11),
        R("Improved Gouge",  2, 3, 16),
        R("Improved Backstab",    2, 3, 19),  -- Combat tree (cross-spec)
        R("Lethality",            1, 5, 33),
        R("Improved Poisons",            1, 5, 39),
        R("Vile Poisons",            1, 5, 44),
        R("Seal Fate", 1, 5, 50),
        R("Opportunity",          3, 5, 55),  -- Subtlety tree (cross-spec)
        R("Improved Kidney Shot", 1, 3, 58),
    },

    ["Dark Ranger"] = {      -- Subtlety
        R("Remorseless Attacks",  1, 2, 11),
        R("Improved Gouge",  2, 3, 14),
        R("Opportunity",    3, 5, 19),
        R("Camouflage",    3, 5, 24),
        R("Improved Ambush",   3, 3, 28),
        R("Improved Sap",   3, 3, 37),
        R("Premeditation", 3, 1, 45),
    },

    ---------- WARLOCK ----------

    ["Pyremaster"] = {      -- Destruction
        R("Improved Imp",     2, 3, 12),  -- Demonology tree (cross-spec)
        R("Improved Corruption",     1, 5, 17),
        R("Improved Firebolt",3, 2, 29),
        R("Ruin",             3, 1, 38),
        R("Emberstorm",       3, 5, 49),
    },

    ["Necromancer"] = {    -- Affliction
        R("Improved Corruption", 1, 5, 14),
        R("Improved Drain Life", 1, 5, 21),
        R("Fel Concentration",   1, 5, 27),
        R("Shadow Mastery",      1, 5, 39),
    },

    ["Graven One"] = {    -- Affliction
        R("Improved Corruption", 1, 5, 14),
        R("Improved Drain Life", 1, 5, 21),
        R("Fel Concentration",   1, 5, 27),
        R("Shadow Mastery",      1, 5, 39),
    },

    ["Death Knight"] = {      -- Demonology
        R("Demonic Embrace", 2, 5, 14),
        R("Improved Voidwalker", 2, 3, 17),
        R("Unholy Power", 2, 5, 32),
        R("Master Demonologist", 2, 5, 39),
        R("Soul Link", 2, 1, 40),
        R("Improved Corruption", 1, 5, 45),
        R("Shadowburn",   3, 1, 56),
    },

    ---------- DRUID ----------

    ["Druid of the Claw"] = {  -- Feral
        R("Feral Charge",       2, 1, 21),
        R("Primal Fury",        2, 2, 27),
        R("Faerie Fire (Feral)",2, 1, 31),
        R("Leader of the Pack", 2, 1, 41),
    },

    ["Plagueshifter"] = {   -- Restoration
        R("Omen of Clarity",         1, 1, 20),
        R("Ferocity",         2, 5, 25),
        R("Furor",      3, 5, 30),
        R("Improved Healing Touch",3, 5, 35),
        R("Reflection",         3, 3, 38),
        R("Natural Shapeshifter",         1, 3, 41),
        R("Nature's Swiftness",         3, 1, 49),
        R("Improved Tranquility",         3, 2, 51),
    },

    ["Savagekin"] = {       -- Balance
        R("Improved Moonfire", 1, 5, 20),
        R("Vengeance",         1, 5, 29),
        R("Moonkin Form",      1, 1, 40),
    },

    ["Ley Walker"] = {       -- Balance
        R("Improved Nature's Grasp", 1, 4, 14),
        R("Improved Moonfire", 1, 5, 19),
        R("Improved Starfire", 1, 5, 29),
        R("Vengeance",         1, 5, 35),
        R("Moonfury",      1, 5, 43),
    },

    ["Dragonsworn"] = {       -- Balance
        R("Improved Wrath", 1, 5, 15),
        R("Improved Healing Touch",      3, 5, 25),
        R("Reflection",      3, 3, 29),
        R("Nature's Swiftness",      3, 1, 36),
        R("Swiftmend",      3, 1, 46),
    },

    ---------- HUNTER ----------

    ["Elven Ranger"] = {       -- Survival
        R("Savage Strikes", 3, 2, 16),
        R("Entrapment", 3, 5, 21),
        R("Clever Traps", 3, 2, 24),
        R("Trap Mastery", 3, 2, 26),
        R("Counterattack",  3, 1, 30),
        R("Killer Instinct",   3, 3, 33),
    }, 

    ["Beastmaster"] = {     -- Beast Mastery
        R("Endurance Training", 1, 5, 14),
        R("Ferocity",          1, 5, 31),
        R("Spirit Bond",       1, 2, 33),
        R("Frenzy",            1, 5, 41),
        R("Monster Slaying",            3, 3, 44),
    },

    ["Mountaineer"] = {     -- Marksmanship
        R("Aimed Shot",                  2, 1, 20),
        R("Mortal Shots",                2, 5, 29),
        R("Ranged Weapon Specialization",2, 5, 39),
        R("Improved Aspect of the Hawk", 1, 5, 45),  -- BM tree (cross-spec)
    },

    ["Wilderness Stalker"] = {
        R("Savage Strikes", 3, 2, 16),
        R("Entrapment", 3, 5, 21),
        R("Clever Traps", 3, 2, 24),
        R("Trap Mastery", 3, 2, 26),
        R("Counterattack",  3, 1, 30),
        R("Killer Instinct",   3, 3, 33),
    },

    ---------- SHAMAN ----------

    ["Earthcaller"] = { -- Enhancement
        R("Shield Specialization", 2, 5, 14),
        R("Flurry", 2, 5, 29),
        R("Parry",                 2, 1, 30),
        R("Stormstrike",         2, 1, 40),
        R("Reverberation",         1, 5, 56),
    },

    ["Witch Doctor"] = {    -- Restoration
        R("Improved Healing Wave", 3, 5, 14),
        R("Totemic Focus",        3, 5, 19),
        R("Totemic Mastery",      3, 1, 20),
        R("Restorative Totems",   3, 5, 29),
        R("Mana Tide Totem",      3, 1, 40),
    },

    ["Spiritwalker"] = {    -- Elemental
        R("Call of Thunder",       1, 5, 25),
        R("Improved Healing Wave", 3, 5, 30),  -- Restoration tree (cross-spec)
        R("Elemental Fury",        1, 1, 35),
        R("Lightning Mastery",     1, 5, 44),
    },

    ["Spirit Champion"] = { -- Enhancement
        R("Two-Handed Axes and Maces", 2, 1, 20),
        R("Thundering Strikes", 2, 5, 22),
        R("Enhancing Totems",                 2, 2, 24),
        R("Flurry",                 2, 5, 29),
        R("Elemental Weapons",                 2, 3, 33),
        R("Stormstrike",         2, 1, 40),
        R("Call of Flame",         1, 3, 48),
        R("Elemental Devastation",         1, 3, 58),
    },

    ---------- PALADIN ----------

    ["Templar"] = {        -- Holy
        R("Divine Intellect", 1, 5, 14),
        R("Improved Seal of Righteousness", 1, 5, 19),
        R("Consecration", 1, 1, 20),
        R("Healing Light",    1, 3, 23),
        R("Divine Favor",     1, 1, 30),
        R("Redoubt",       2, 5, 35),
        R("Improved Righteous Fury",       2, 3, 43),
        R("Shield Specialization",       2, 3, 46),
        R("Holy Shock",       1, 1, 56),
    },

    ["Scarlet Champion"] = {         -- Protection
        R("Consecration",           1, 1, 20),
        R("Redoubt",                 2, 5, 25),
        R("Improved Righteous Fury", 2, 3, 33),
        R("Shield Specialization",  2, 3, 37),
        R("Blessing of Sanctuary",  2, 1, 41),
        R("Reckoning",  2, 5, 46),
        R("Holy Shield",            2, 1, 51),
    },

    ["Exemplar"] = { -- Retribution
        R("Seal of Command",                    3, 1, 20),
        R("Conviction",                         3, 5, 27),
        R("Deflection",                              3, 5, 29),
        R("Vengeance",                          3, 5, 39),
        R("Precision",                          2, 3, 48),
        R("Divine Strength",                    1, 5, 56),
    },

    ---------- PRIEST ----------

    ["Priestess of the Moon"] = {  -- Holy
        R("Spirit Tap",          3, 5, 14),  -- Shadow tree (cross-spec)
        R("Divine Fury",         2, 5, 24),
        R("Holy Specialization", 2, 5, 27),
        R("Searing Light",       2, 2, 31),
        R("Spiritual Guidance",  2, 5, 39),
        R("Meditation",1, 3, 53),
        R("Divine Spirit",1, 1, 60),
    },

    ["Apothecary"] = {      -- Discipline
        R("Wand Specialization", 1, 5, 14),
        R("Inner Focus",         1, 1, 25),
        R("Divine Spirit",       1, 1, 35),
        R("Power Infusion",      1, 1, 46),
    },

    ["Shadow Hunter"] = {   -- Shadow
        R("Mind Flay",        3, 1, 20),
        R("Vampiric Embrace", 3, 1, 30),
        R("Shadowform",       3, 1, 40),
    },

    ["Lightslayer"] = {   -- Shadow
        R("Mind Flay",        3, 1, 20),
        R("Vampiric Embrace", 3, 1, 30),
        R("Shadowform",       3, 1, 40),
        R("Shadow Weaving",       3, 5, 45),
        R("Improved Mind Blast",       3, 5, 50),
        R("Shadow Affinity",       3, 3, 55),
    },

    ---------- MAGE ----------

    ["Bloodmage"] = {       -- Fire
        R("Improved Fireball", 2, 5, 17),
        R("Blast Wave", 2, 1, 33),
        R("Critical Mass",    2, 3, 36),
        R("Fire Power",       2, 5, 42),
    },

    ["Techno-mage"] = {    -- Arcane
        R("Improved Arcane Missiles", 1, 5, 14),
        R("Arcane Resilience",        1, 1, 20),
        R("Impact",                   2, 5, 27),  -- Fire tree (cross-spec)
        R("Pyroblast",                2, 1, 33),  -- Fire tree (cross-spec)
        R("Presence of Mind",         1, 1, 41),
        R("Arcane Power",             1, 1, 51),
    },

    ["Spellblade"] = {         -- Frost
        R("Permafrost",        3, 3, 19),
        R("Improved Blizzard", 3, 3, 23),
        R("Ice Block",         3, 1, 30),
        R("Ice Barrier",       3, 1, 40),
    },

    ["Archmage of Kirin Tor"] = {       -- Frostfire
        R("Improved Fireball", 2, 5, 14),
        R("Elemental Precision", 3, 3, 17),
        R("Ignite", 2, 5, 22),
        R("Blast Wave", 2, 1, 33),
        R("Frostbite", 3, 3, 38),
        R("Shatter", 3, 5, 50),
        R("Critical Mass",    2, 3, 53),
        R("Combustion",       2, 1, 60),
    },

    ["Hedge Wizard"] = {       -- Fire
        R("Impact", 2, 5, 14),
        R("Elemental Precision", 3, 3, 17),
        R("Ignite", 2, 5, 22),
        R("Incinerate", 2, 2, 24),
        R("Improved Scorch", 2, 3, 30),
        R("Blast Wave", 2, 1, 33),
        R("Master of Elements", 2, 3, 37),
        R("Combustion",       2, 1, 43),
    },
}
