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

local R = function(name, tab, rank, level)
    return { name = name, tab = tab, rank = rank, level = level }
end

HCE.TalentRequirements = {

    ---------- WARRIOR ----------

    ["Mountain King"] = {   -- Protection
        R("Last Stand",      3, 1, 20),
        R("Concussion Blow", 3, 1, 30),
        R("Shield Slam",     3, 1, 40),
        R("Anger Management", 1, 1, 51),
    },

    ["Brewmaster"] = {      -- Arms
        R("Impale",        1, 2, 26),
        R("Mortal Strike", 1, 1, 40),
        R("Last Stand", 3, 1, 51),
    },

    ["Demon Hunter"] = {    -- Fury
        R("Dual Wield Specialization", 2, 5, 29),
        R("Flurry",                    2, 5, 41),
    },

    ---------- ROGUE ----------

    ["Berserker"] = {       -- Assassination
        R("Remorseless Attacks",  1, 2, 11),
        R("Improved Backstab",    2, 3, 19),  -- Combat tree (cross-spec)
        R("Lethality",            1, 5, 33),
        R("Improved Kidney Shot", 1, 3, 41),
        R("Opportunity",          3, 5, 53),  -- Subtlety tree (cross-spec)
    },

    ["Warden"] = {          -- Combat
        R("Riposte",             2, 1, 22),
        R("Lightning Reflexes",  2, 5, 25),
        R("Sword Specialization",2, 5, 35),
        R("Ghostly Strike",      3, 1, 53),  -- Subtlety tree (cross-spec)
        R("Setup",               3, 2, 59),  -- Subtlety tree (cross-spec)
    },

    ["Runemaster"] = {      -- Subtlety
        R("Initiative",    3, 3, 24),
        R("Hemorrhage",    3, 1, 33),
        R("Dirty Deeds",   3, 2, 36),
        R("Premeditation", 3, 1, 42),
    },

    ---------- WARLOCK ----------

    ["Pyremaster"] = {      -- Destruction
        R("Improved Imp",     2, 3, 23),  -- Demonology tree (cross-spec)
        R("Improved Firebolt",3, 2, 25),
        R("Ruin",             3, 1, 33),
        R("Emberstorm",       3, 5, 44),
    },

    ["Death Knight"] = {    -- Affliction
        R("Improved Drain Life", 1, 5, 21),
        R("Fel Concentration",   1, 5, 27),
        R("Shadow Mastery",      1, 5, 39),
    },

    ["Shadowmage"] = {      -- Demonology
        R("Soul Link", 2, 1, 40),
        R("Bane",      3, 5, 50),  -- Destruction tree (cross-spec)
    },

    ---------- DRUID ----------

    ["Druid of the Claw"] = {  -- Feral
        R("Feral Charge",       2, 1, 21),
        R("Primal Fury",        2, 2, 27),
        R("Faerie Fire (Feral)",2, 1, 31),
        R("Leader of the Pack", 2, 1, 41),
    },

    ["Plagueshifter"] = {   -- Restoration
        R("Insect Swarm",      1, 1, 21),  -- Balance tree (cross-spec)
        R("Nature's Swiftness",3, 1, 31),
        R("Swiftmend",         3, 1, 41),
    },

    ["Savagekin"] = {       -- Balance
        R("Improved Moonfire", 1, 5, 20),
        R("Vengeance",         1, 5, 29),
        R("Moonkin Form",      1, 1, 40),
    },

    ---------- HUNTER ----------

    ["Buccaneer"] = {       -- Survival
        R("Savage Strikes", 3, 2, 16),
        R("Counterattack",  3, 1, 30),
        R("Wyvern Sting",   3, 1, 40),
    },

    ["Beastmaster"] = {     -- Beast Mastery
        R("Endurance Training", 1, 5, 14),
        R("Ferocity",          1, 5, 31),
        R("Spirit Bond",       1, 2, 33),
        R("Frenzy",            1, 5, 41),
    },

    ["Mountaineer"] = {     -- Marksmanship
        R("Aimed Shot",                  2, 1, 20),
        R("Mortal Shots",                2, 5, 29),
        R("Ranged Weapon Specialization",2, 5, 39),
        R("Improved Aspect of the Hawk", 1, 5, 45),  -- BM tree (cross-spec)
    },

    ---------- SHAMAN ----------

    ["Spirit Champion"] = { -- Enhancement
        R("Shield Specialization", 2, 5, 14),
        R("Parry",                 2, 1, 30),
        R("Anticipation",         2, 5, 40),
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

    ---------- PALADIN ----------

    ["Exemplar"] = {        -- Holy
        R("Divine Intellect", 1, 5, 14),
        R("Healing Light",    1, 3, 23),
        R("Divine Favor",     1, 1, 30),
        R("Holy Power",       1, 5, 39),
    },

    ["Templar"] = {         -- Protection
        R("Redoubt",                 2, 5, 14),
        R("Improved Righteous Fury", 2, 3, 22),
        R("Consecration",           1, 1, 33),  -- Holy tree (cross-spec)
        R("Shield Specialization",  2, 3, 37),
        R("Blessing of Sanctuary",  2, 1, 41),
        R("Holy Shield",            2, 1, 51),
    },

    ["Sister of Steel"] = { -- Retribution
        R("Seal of Command",                    3, 1, 20),
        R("Conviction",                         3, 5, 27),
        R("Two-Handed Weapon Specialization",   3, 3, 33),
        R("Vengeance",                          3, 5, 39),
    },

    ---------- PRIEST ----------

    ["Priestess of the Moon"] = {  -- Holy
        R("Spirit Tap",          3, 5, 20),  -- Shadow tree (cross-spec)
        R("Divine Fury",         2, 5, 24),
        R("Holy Specialization", 2, 5, 27),
        R("Searing Light",       2, 2, 31),
        R("Spiritual Guidance",  2, 5, 39),
        R("Spirit of Redemption",2, 1, 40),
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

    ---------- MAGE ----------

    ["Bloodmage"] = {       -- Fire
        R("Improved Fireball", 2, 5, 17),
        R("Critical Mass",    2, 3, 36),
        R("Fire Power",       2, 5, 42),
    },

    ["Mechano-Mage"] = {    -- Arcane
        R("Improved Arcane Missiles", 1, 5, 14),
        R("Arcane Resilience",        1, 1, 20),
        R("Impact",                   2, 5, 27),  -- Fire tree (cross-spec)
        R("Pyroblast",                2, 1, 33),  -- Fire tree (cross-spec)
        R("Presence of Mind",         1, 1, 41),
        R("Arcane Power",             1, 1, 51),
    },

    ["Warmage"] = {         -- Frost
        R("Permafrost",        3, 3, 19),
        R("Improved Blizzard", 3, 3, 23),
        R("Ice Block",         3, 1, 30),
        R("Ice Barrier",       3, 1, 40),
    },
}
