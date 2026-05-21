----------------------------------------------------------------------
-- HardcoreClassesEnhanced – Character Data
-- All 27 enhanced characters from the EnhancedClasses spreadsheet.
--
-- Fields per character:
--   class       : base WoW class (English, matches UnitClass 2nd return)
--   spec        : talent spec name
--   name        : character archetype name (display name, also used as key)
--   race        : required race, or "Any"
--   gender      : "Male", "Female", or "Any"
--   selfFound   : boolean — must play with Self-Found mode on
--   professions : list of required professions (may be empty)
--   equipment   : list of { desc, level } tables
--   challenges  : list of { desc, level } tables
--   companion   : { name, level } or nil
--   pet         : { desc, level } or nil   (hunter pet)
--   mount       : { desc, level } or nil
--   quests      : list of { name, level, questID } tables, or nil
--   gameplay    : free-text flavour/tips, or nil
----------------------------------------------------------------------

HCE = HCE or {}

-- Challenge type descriptions (from the Notes sheet)
HCE.ChallengeDescriptions = {
    ["Anti-undead"]     = "Level in undead-heavy zones (Tirisfal Glades, Plaguelands, Duskwood, Zul'Farrak)",
    ["Pro-nature"]      = "Complete quests against the Venture Company in the Barrens, Stonetalon Mountains, and Stranglethorn Vale",
    ["Homebound"]       = "Can't leave home continent",
    ["Anti-demon"]      = "Level in demon-heavy zones (Teldrassil, Darkshore, Blackfathom Deeps, Ashenvale, Felwood)",
    ["Diplomat"]        = "Must obtain another faction's mount",
    ["Renegade"]        = "Cannot equip quest reward gear",
    ["Aoe-farmer"]      = "Level mainly by aoe-farming in the open world",
    ["White knight"]    = "Can only equip white or grey gear",
    ["Partisan"]        = "Cannot equip looted gear",
    ["Drifter"]         = "Cannot use hearthstone or bank",
    ["Ephemeral"]       = "Cannot repair gear",
    ["Self-made"]       = "Can only equip self-crafted or white/grey items",
    ["Self-made armor"] = "Armor must be self-crafted or white/grey (jewelry, cloak, weapons exempt)",
    ["Self-made weapon & armor"] = "Weapons and armor must be self-crafted or white/grey (jewelry, cloak exempt)",
    ["Exotic"]          = "Cannot equip uncommon quality gear",
    ["Off-the-shelf"]   = "Can only equip gear sold by vendors",
    ["Faction leader"]  = "Become exalted with your own faction",
    ["Footman"]         = "Cannot equip rare or epic quality items",
    ["Grunt"]           = "Cannot equip rare or epic quality items",
    ["No professions"]  = "Cannot learn any professions",
    ["No demon"]        = "Cannot summon a demon pet",
    ["Mortal pets"]     = "Hunter pets that die stay dead — cannot revive or replace them",
    ["Cloth/leather"]   = "Can only wear cloth or leather armor",
    ["Leather/mail"]    = "Leather only until level 40, then leather or mail",
    ["Mail/plate"]      = "Must wear mail or plate in all possible slots",
    ["Imp"]             = "Must always use the Imp as your demon pet",
    ["Self-made guns"]  = "Ranged weapon must be self-crafted via Engineering",
    ["Demonic Sacrifice"] = "Must sacrifice your demon pet and maintain the Demonic Sacrifice buff",
    ["Purifier"]          = "Reach Honored reputation with Argent Dawn",
    ["Nocturnal"]         = "Must remain in towns or cities during daytime",
    ["Diurnal"]           = "Must remain in towns or cities during nighttime",
}

----------------------------------------------------------------------
-- Easy Mode exclusions
--
-- Maps character name -> set of challenge descriptions that are hidden
-- when Easy Mode is enabled.  Characters not listed (or with no
-- excluded challenges) have no easy mode.
----------------------------------------------------------------------

HCE.EasyModeExclusions = {
    ["Brewmaster"]           = { ["Exotic"] = true },
    ["Demon Hunter"]         = { ["Renegade"] = true },
    ["Berserker"]            = { ["Partisan"] = true },
    ["Warden"]               = { ["Homebound"] = true },
    ["Runemaster"]           = { ["Off-the-shelf"] = true },
    ["Pyremaster"]           = { ["Exotic"] = true },
    ["Necromancer"]          = { ["Self-made armor"] = true },
    ["Druid of the Claw"]    = { ["Ephemeral"] = true },
    ["Savagekin"]            = { ["Homebound"] = true },
    ["Buccaneer"]            = { ["Renegade"] = true },
    ["Beastmaster"]          = { ["Mortal pets"] = true },
    ["Mountaineer"]          = { ["Partisan"] = true },
    ["Earthcaller"]      = { ["Exotic"] = true },
    ["Witch Doctor"]         = { ["Renegade"] = true },
    ["Spiritwalker"]         = { ["Self-made armor"] = true },
    ["Exemplar"]             = { ["Mail/plate"] = true },
    ["Templar"]              = { ["Homebound"] = true },
    ["Sister of Steel"]      = { ["Self-made weapon & armor"] = true },
    ["Priestess of the Moon"]= { ["Partisan"] = true },
    ["Apothecary"]           = { ["Homebound"] = true },
    ["Bloodmage"]            = { ["White knight"] = true },
    ["Mechano-Mage"]         = { ["Renegade"] = true },
    ["Warmage"]              = { ["Grunt"] = true },
    ["Tinker"]              = { ["Footman"] = true },
    ["Blademaster"]              = { ["Exotic"] = true },
    ["Mountain King"]              = { ["No professions"] = true },
    ["Brave"]              = { ["Leather/mail"] = true },
    ["Death Knight"]              = { ["Drifter"] = true },
    ["Plagueshifter"]              = { ["Diurnal"] = true },
    ["Shadow Hunter"]              = { ["Nocturnal"] = true },
}

-- Quest theme descriptions (displayed under the QUESTS header)
HCE.QuestThemeDescriptions = {
    ["Anti-demon"]         = "",
    ["Pro-nature"]         = "",
    ["Anti-scourge"]        = "",
    ["Big Game Hunter"]    = "",
    ["Ironforge Loyalist"] = "",
    ["Stormwind Loyalist"] = "",
    ["Plague-brewer"]      = "",
    ["Darkspear Loyalist"] = "",
    ["Gadgetist"]          = "",
}

----------------------------------------------------------------------
-- Helpers to build requirement entries.
--   E("Fist weapons", 10)      → active from level 10 onward
--   E("Goggles", 20, 29)       → active only at levels 20–29
--   Q("Quest Name", 18, 4763)  → quest due by level 18, WoW questID 4763
----------------------------------------------------------------------
local function E(desc, level, endLevel)
    return { desc = desc, level = level or 1, endLevel = endLevel or nil }
end

local function Q(name, level, questID)
    return { name = name, level = level or 1, questID = questID }
end

----------------------------------------------------------------------
-- Character table
----------------------------------------------------------------------
HCE.Characters = {

    ---------- WARRIOR ----------

    ["Mountain King"] = {
        class       = "WARRIOR",
        spec        = "Protection",
        name        = "Mountain King",
        race        = "Dwarf",
        gender      = "Male",
        selfFound   = true,
        professions = {},
        challenges  = {
            E("No professions", 1),
        },
        equipment   = {
            E("Show helm", 1),
            E("Mace/axe/shield", 5),
            E("Flask trinket", 44),
            E("Horned helm", 44),
        },
        quests      = {
            Q("In Defense of the King's Lands", 17, 217),
            Q("The Absent Minded Prospector", 24, 943),
            Q("Defeat Nek'rosh", 32, 474),
            Q("The Lost Tablets of Will", 45, 1139),
            Q("Rise, Obsidion!", 52, 3566),
            Q("The Princess's Surprise", 59, 4363),
        },
        questTheme  = "Ironforge Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Beer, treasure, tank tour",
    },

    ["Brewmaster"] = {
        class       = "WARRIOR",
        spec        = "Fury",
        name        = "Brewmaster",
        race        = "Human",
        gender      = "Any",
        selfFound   = true,
        professions = { "Alchemy", "Cooking" },
        challenges  = {
            E("Exotic", 1),
        },
        equipment   = {
            E("Hide helm", 1),
            E("Show cloak", 1),
            E("Staff", 5),
            E("Robe", 5),
            E("Brewmaster robe", 40),
            E("Dragonbreath chili", 40),
            E("Flask trinket", 50),
        },
        quests      = {
            Q("The Perfect Stout", 9, 315),
            Q("Dry Times", 15, 116),
            Q("... and Bugs", 40, 1258),
            Q("Report Back to Fizzlebub", 44, 1122),
            Q("Sweet Amber", 44, 53),
            Q("Lost Thunderbrew Recipe", 55, 4134),
        },
        questTheme  = "Brew Guzzler",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "darkmoon special, dragonbreath, exotic",
    },

    ["Demon Hunter"] = {
        class       = "WARRIOR",
        spec        = "Fury",
        name        = "Demon Hunter",
        race        = "Night Elf",
        gender      = "Male",
        selfFound   = true,
        professions = {},
        challenges  = {
            E("Renegade", 1),
        },
        equipment   = {
            E("Hide cloak", 1),
            E("Hide helm", 1),
            E("Swords", 1),
            E("No chest", 1),
            E("Kilt", 25),
        },
        quests      = {
            Q("The Blackwood Corrupted", 18, 4763),
            Q("The Tower of Althalaxx", 31, 981),
            Q("A Land Filled with Hatred", 47, 5536),
            Q("A Final Blow", 58, 5242),
        },
        questTheme  = "The Legion Shall Fall",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-demon",
    },

    ["Tinker"] = {
        class       = "WARRIOR",
        spec        = "Protection",
        name        = "Tinker",
        race        = "Gnome",
        gender      = "Any",
        selfFound   = true,
        professions = { "Engineering" },
        equipment   = {
            E("Show helm", 1),
            E("Shield", 1),
            E("Mace", 5),
            E("Flying tiger goggles", 20, 29),
            E("Green-tinted goggles", 30, 39),
            E("Gnomish goggles", 40),
        },
        challenges  = {
            E("Footman", 1),
        },
        quests      = {
            Q("A Dark Threat Looms", 20, 283),
            Q("Data Rescue", 30, 2930),
            Q("Show Your Work", 47, 3641),
            Q("An OOX of Your Own", 50, 3721),
        },
        questTheme  = "Gadgetist",
        companion   = E("Mechanical", 45),
        pet         = nil,
        mount       = nil,
        gameplay    = "tank tour",
    },

    ["Blademaster"] = {
        class       = "WARRIOR",
        spec        = "Arms",
        name        = "Blademaster",
        race        = "Orc",
        gender      = "Any",
        selfFound   = false,
        professions = {},
        equipment   = {
            E("Hide helm", 1),
            E("Hide cloak", 1),
            E("No chest", 1),
            E("2h sword", 5),
            E("Katana", 21),
        },
        challenges  = {
            E("Exotic", 1),
        },
        quests      = {
            Q("Hidden Enemies", 16, 5730),
            Q("King of the Foulweald", 26, 6621),
            Q("The Corrupter", 37, 1488),
            Q("Service to the Horde", 40, 7541),
            Q("Continued Threat", 45, 1428),
            Q("The Princess Saved?", 59, 4004),
        },
        questTheme  = "Orgrimmar Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "/sit and /meditate, exotic",
    },

    ["Brave"] = {
        class       = "WARRIOR",
        spec        = "Arms",
        name        = "Brave",
        race        = "Tauren",
        gender      = "Any",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Hide cloak", 1),
            E("Hide helm", 1),
            E("No shirt", 1),
            E("War harness", 8),
            E("Polearm", 20),
        },
        challenges  = {
            E("Leather/mail", 1),
        },
        quests      = {
            Q("Rites of the Earthmother", 14, 776),
            Q("Earthen Arise", 20, 6481),
            Q("Grimtotem Spying", 28, 5064),
            Q("Final Passage", 36, 1394),
            Q("Zukk'ash Report", 48, 7732),
            Q("Glyphed Oaken Branch", 56, 4986),
        },
        questTheme  = "Thunderbluff Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ---------- ROGUE ----------

    ["Berserker"] = {
        class       = "ROGUE",
        spec        = "Assassination",
        name        = "Berserker",
        race        = "Troll",
        gender      = "Any",
        selfFound   = true,
        professions = { "Alchemy" },
        recommendedProfession = {
            name = "Cooking",
            reason = "Needed to craft Thistle Tea (60 Cooking).",
        },
        challenges  = {
            E("Partisan", 1),
        },
        equipment   = {
            E("Hide cloak", 1),
            E("Dagger and sword", 10),
            E("Thrown", 10),
            E("Thistle tea", 20),
        },
        quests      = {
            Q("Zalazane", 10, 826),
            Q("Troll Charm", 24, 6462),
            Q("Trol'kalar", 42, 646),
            Q("Saving Yenniku", 46, 592),
        },
        questTheme = "Darkspear Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Thistle tea",
    },

    ["Warden"] = {
        class       = "ROGUE",
        spec        = "Subtlety",
        name        = "Warden",
        race        = "Night Elf",
        gender      = "Female",
        selfFound   = true,
        professions = {},
        challenges  = {
            E("Homebound", 1),
        },
        equipment   = {
            E("Show cloak", 1),
            E("Daggers", 1),
            E("Robe", 5),
            E("Thrown", 10),
        },
        quests      = {
            Q("Sathrah's Sacrifice", 12, 2520),
            Q("Raene's Cleansing", 30, 1046),
            Q("Rise of the Silithid", 46, 4267),
            Q("The Mystery of Morrowgrain", 50, 3791),
            Q("Calm Before the Storm", 54, 4508),
        },
        questTheme  = "Darnassus Loyalist",
        companion   = E("Owl", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Runemaster"] = {
        class       = "ROGUE",
        spec        = "Combat",
        name        = "Runemaster",
        race        = "Dwarf",
        gender      = "Male",
        selfFound   = false,
        professions = { "Enchanting" },
        challenges  = {
            E("Off-the-shelf", 1),
        },
        equipment   = {
            E("Hide cloak", 1),
            E("No chest", 1),
            E("Maces", 5),
            E("Kilt", 25),
        },
        quests      = {
            Q("Keeper of the Flame", 16, 103),
            Q("Summoning the Princess", 50, 656),
            Q("Arcane Runes", 52, 3449),
            Q("Runecloth", 55, 6031),
        },
        questTheme  = "Runes and Furbolgs",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Self-made enchants, scrolls, Timbermaw mace",
    },

    ---------- WARLOCK ----------

    ["Pyremaster"] = {
        class       = "WARLOCK",
        spec        = "Destruction",
        name        = "Pyremaster",
        race        = "Orc",
        gender      = "Any",
        selfFound   = true,
        professions = { "Cooking" },
        recommendedProfession = {
            name = "Tailoring",
            reason = "Needed to craft Robes of Arcana (150 Tailoring) for The Completed Robe.",
        },
        challenges  = {
            E("Exotic", 1),
            E("Imp", 1),
        },
        equipment   = {
            E("No wands", 1),
            E("1.5 speed dagger", 15),
            E("Firestone", 25),
            E("Dragonbreath chili", 40),
        },
        quests      = {
            Q("Keeper of the Flame", 22, 103),
            Q("Dangerous!", 28, 567),
            Q("The Sacred Flame", 29, 1197),
            Q("The Completed Robe", 38, 4786),
            Q("A Taste of Flame", 58, 4024),
        },
        questTheme  = "Fiery Garments & Rituals",
        companion   = nil,
        pet         = nil,
        mount       = E("Wolf", 44),
        gameplay    = "Campfire, melee weaving dagger, dragonbreath, melee weaving dagger 2",
    },

    ["Death Knight"] = {
        class       = "WARLOCK",
        spec        = "Demonology",
        name        = "Death Knight",
        race        = "Undead",
        gender      = "Male",
        selfFound   = true,
        professions = {},
        challenges  = {
            E("Drifter", 1),
            E("Voidwalker", 10),
        },
        equipment   = {
            E("No wands", 1),
            E("Armored weapon", 34),
            E("140 stamina", 40),
            E("Armored rings", 45),
            E("Armored trinket", 45),
            E("180 stamina", 50),
        },
        quests      = {
            Q("A Husband's Revenge", 20, 530),
            Q("Consumed by Hatred", 20, 899),
            Q("Vorrel's Revenge", 33, 1051),
            Q("Helcular's Revenge", 55, 553),
        },
        questTheme  = "Vigilante",
        companion   = nil,
        pet         = nil,
        mount       = E("Skeletal horse", 44),
        gameplay    = "tank",
    },

    ["Necromancer"] = {
        class       = "WARLOCK",
        spec        = "Affliction",
        name        = "Necromancer",
        race        = "Human",
        gender      = "Any",
        selfFound   = true,
        professions = { "Tailoring" },
        challenges  = {
            E("Self-made armor", 1),
            E("Drifter", 1),
            E("No demon", 1),
        },
        equipment   = {
            E("Show helm", 1),
            E("Robe", 1),
            E("Shadow wand", 15),
            E("Skull off-hand", 30),
            E("Necromancer hat", 30),
        },
        companion   = E("Cat", 10),
        pet         = nil,
        mount       = E("Horse", 44),
        gameplay    = "wizard hat",
    },

    ---------- DRUID ----------

    ["Druid of the Claw"] = {
        class       = "DRUID",
        spec        = "Feral",
        name        = "Druid of the Claw",
        race        = "Night Elf",
        gender      = "Male",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Alchemy",
            reason = "Needed to craft Elixir of Fortitude (175 Alchemy) for Reception from Tyrande.",
        },
        challenges  = {
            E("Ephemeral", 1),
            E("Drifter", 1),
        },
        equipment   = {
            E("Armored off-hand", 25),
            E("Armored weapon", 34),
            E("Armored rings", 45),
        },
        quests      = {
            Q("The Escape", 18, 863),
            Q("Reception from Tyrande", 28, 1081),
            Q("Hostile Takeover", 36, 213),
            Q("Venture Company Mining", 41, 600),
        },
        questTheme  = "Naturalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "/roar, pro-nature, tank tour",
    },

    ["Plagueshifter"] = {
        class       = "DRUID",
        spec        = "Restoration",
        name        = "Plagueshifter",
        race        = "Tauren",
        gender      = "Female",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Leatherworking",
            reason = "Needed to craft Powershifting helm (Wolfshead Helm), which required 225 Leatherworking.",
        },
        equipment   = {
            E("Show helm", 1),
            E("80 strength", 30),
            E("Jungle remedy", 35),
            E("80 strength & intellect", 40),
            E("Powershifting helm", 45),
            E("200 intellect", 50),
        },
        challenges  = {
            E("Diurnal", 1),
            E("Purifier", 60),
        },
        quests      = {
            Q("The Family Crypt", 13, 408),
            Q("Assault on Fenris Isle", 24, 442),
            Q("Mission Accomplished!", 58, 5238),
            Q("Hameya's Plea", 59, 6024),
        },
        questTheme  = "Purging the Undead",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-undead, powershifting",
    },

    ["Savagekin"] = {
        class       = "DRUID",
        spec        = "Balance",
        name        = "Savagekin",
        race        = "Tauren",
        gender      = "Any",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("125 intellect", 40),
            E("Armored ring", 45),
            E("200 intellect", 50),
        },
        challenges  = {
            E("Homebound", 1),
            E("Drifter", 1),
        },
        quests      = {
            Q("The Venture Co.", 10, 764),
            Q("Samophlange", 16, 902),
            Q("Samophlange Manual", 19, 3924),
            Q("Shredding Machines", 23, 1068),
            Q("Gerenzo Wrenchwhistle", 27, 1096),
        },
        questTheme  = "Naturalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Pro-nature",
    },

    ---------- HUNTER ----------

    ["Buccaneer"] = {
        class       = "HUNTER",
        spec        = "Survival",
        name        = "Buccaneer",
        race        = "Any",
        gender      = "Any",
        selfFound   = true,
        professions = { "Tailoring", "Fishing" },
        equipment   = {
            E("Show helm", 1),
            E("Gun", 10),
            E("Rapier, cutlass, or harpoon", 20),
            E("Captain's hat", 45),
        },
        challenges  = {
            E("Renegade", 1),
        },
        quests      = {
            Q("Stolen Booty", 16, 888),
            Q("Claim Rackmore's Treasure!", 36, 6161),
            Q("Sunken Treasure", 40, 670),
            Q("Cuergo's Gold", 45, 2882),
        },
        questTheme  = "Treasure Hunter",
        companion   = E("Parrot", 15),
        pet         = E("Jungle cat", 15),
        mount       = nil,
        gameplay    = "Rum, melee weaving hunter",
    },

    ["Beastmaster"] = {
        class       = "HUNTER",
        spec        = "Beast Mastery",
        name        = "Beastmaster",
        race        = "Orc",
        gender      = "Any",
        selfFound   = true,
        professions = { "Leatherworking" },
        equipment   = {
            E("Show helm", 1),
            E("No guns", 1),
            E("Anti-beast cloak", 20),
            E("Anti-beast gloves", 30),
            E("Anti-beast melee weapon", 35),
            E("Wolf helm", 45),
            E("Anti-beast ranged weapon", 50),
        },
        challenges  = {
            E("Mortal pets", 1),
        },
        quests      = {
            Q("Isha Awak", 27, 873),
            Q("Big Game Hunter", 43, 208),
            Q("The Bait for Lar'korwi", 56, 4292),
            Q("Past Endeavors", 59, 5057),
        },
        questTheme  = "Big Game Hunter",
        companion   = E("Prairie dog", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = "Rare pets",
    },

    ["Mountaineer"] = {
        class       = "HUNTER",
        spec        = "Marksmanship",
        name        = "Mountaineer",
        race        = "Dwarf",
        gender      = "Any",
        selfFound   = true,
        professions = { "Engineering" },
        equipment   = {
            E("Show cloak", 1),
            E("Show helm", 1),
            E("Gun", 1),
            E("2h axe", 10),
            E("Scope", 15),
        },
        challenges  = {
            E("Partisan", 1),
            E("Self-made guns", 10),
        },
        quests      = {
            Q("In Defense of the King's Lands", 17, 217),
            Q("The Absent Minded Prospector", 24, 943),
            Q("Defeat Nek'rosh", 32, 474),
            Q("The Lost Tablets of Will", 45, 1139),
            Q("Rise, Obsidion!", 52, 3566),
            Q("The Princess's Surprise", 59, 4363),
        },
        questTheme  = "Ironforge Loyalist",
        companion   = nil,
        pet         = E("Bear", 10),
        mount       = nil,
        gameplay    = "Hooded cloak",
    },

    ---------- SHAMAN ----------

    ["Earthcaller"] = {
        class       = "SHAMAN",
        spec        = "Enhancement",
        name        = "Earthcaller",
        race        = "Orc",
        gender      = "Any",
        selfFound   = true,
        professions = { "Mining" },
        equipment   = {
            E("Shield", 5),
            E("1200 armor", 30),
            E("3000 armor", 50),
        },
        challenges  = {
            E("Exotic", 1),
        },
        quests      = {
            Q("Earthen Arise", 20, 6481),
            Q("Study of the Elements: Rock", 42, 712),
            Q("Mok'thardin's Enchantment", 44, 573),
            Q("Corruption of Earth and Seed", 51, 7064),
        },
        questTheme  = "Earth Bender",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "tank tour, exotic",
    },

    ["Witch Doctor"] = {
        class       = "SHAMAN",
        spec        = "Restoration",
        name        = "Witch Doctor",
        race        = "Troll",
        gender      = "Female",
        selfFound   = true,
        professions = { "Alchemy" },
        equipment   = {
            E("Show helm", 1),
            E("No shield", 1),
            E("Herb pouch", 10),
            E("Witch doctor staff", 11),
            E("Voodoo mask", 45),
            E("Cursed amulet", 45),
        },
        challenges  = {
            E("Renegade", 1),
            E("Cloth/leather", 1),
        },
        quests      = {
            Q("Jin'Zil's Forest Magic", 26, 1058),
            Q("Stranglethorn Fever", 45, 348),
            Q("Weapons of Spirit", 50, 3129),
            Q("Luck Be With You", 59, 969),
        },
        questTheme  = "Voodoo Magic",
        companion   = nil,
        pet         = E("Frog", 30),
        mount       = nil,
        gameplay    = "cursed necklace",
    },

    ["Spiritwalker"] = {
        class       = "SHAMAN",
        spec        = "Elemental",
        name        = "Spiritwalker",
        race        = "Tauren",
        gender      = "Any",
        selfFound   = true,
        professions = { "Leatherworking" },
        equipment   = {
            E("Hide helm", 1),
            E("1h axe", 10),
            E("Lantern", 24),
        },
        challenges  = {
            E("Self-made armor", 1),
        },
        quests      = {
            Q("Weapons of Choice", 24, 893),
            Q("Final Passage", 36, 1394),
            Q("Cortello's Riddle", 51, 626),
            Q("It's Dangerous to Go Alone", 56, 3962),
        },
        questTheme  = "Wander the land",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ---------- PALADIN ----------

    ["Exemplar"] = {
        class       = "PALADIN",
        spec        = "Holy",
        name        = "Exemplar",
        race        = "Human",
        gender      = "Female",
        selfFound   = true,
        equipment   = {
            E("Shield", 5),
            E("Guild tabard", 10),
            E("Blue shirt", 10),
            E("Insignia", 30),
        },
        challenges  = {
            E("Mail/plate", 1),
        },
        quests      = {
            Q("Missing In Action", 25, 219),
            Q("An Audience with the King", 31, 396),
            Q("The Missing Diplomat", 38, 1267),
            Q("Mai'Zoth", 46, 206),
            Q("The Great Masquerade", 59, 6403),
        },
        questTheme  = "Stormwind Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Stormwind hearthstone",
    },

    ["Templar"] = {
        class       = "PALADIN",
        spec        = "Protection",
        name        = "Templar",
        race        = "Human",
        gender      = "Male",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Sword or mace", 5),
            E("Shield", 5),
            E("Argent Dawn trinket", 50),
        },
        challenges  = {
            E("Homebound", 1),
            E("Purifier", 60),
        },
        quests      = {
            Q("Collecting Memories", 18, 168),
            Q("Bride of the Embalmer", 30, 253),
            Q("Mission Accomplished!", 58, 5237),
            Q("Hameya's Plea", 59, 6024),
        },
        questTheme  = "Purging the Undead",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-undead, tank tour",
    },

    ["Sister of Steel"] = {
        class       = "PALADIN",
        spec        = "Retribution",
        name        = "Sister of Steel",
        race        = "Dwarf",
        gender      = "Female",
        selfFound   = true,
        professions = { "Blacksmithing" },
        challenges  = {
            E("Self-made weapon & armor", 1),
        },
        quests      = {
            Q("Supplying the Front", 12, 1578),
            Q("Jarl Needs a Blade", 35, 1203),
            Q("Expert Blacksmith!", 45, 2765),
            Q("Did You Lose This?", 50, 3321),
        },
        questTheme  = "The Mithril Order",
        companion   = nil,
        pet         = nil,
        mount       = E("Ram", 44),
        gameplay    = nil,
    },

    ---------- PRIEST ----------

    ["Priestess of the Moon"] = {
        class       = "PRIEST",
        spec        = "Holy",
        name        = "Priestess of the Moon",
        race        = "Night Elf",
        gender      = "Female",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Robe", 1),
            E("Arcane wand", 13),
            E("180 spirit", 40),
            E("250 spirit", 50),
        },
        quests      = {
            Q("Sathrah's Sacrifice", 12, 2520),
            Q("Answered Questions", 30, 1044),
            Q("Rise of the Silithid", 46, 4267),
            Q("The Mystery of Morrowgrain", 50, 3791),
            Q("Wildkin of Elune", 57, 4902),
        },
        questTheme  = "Darnassus Loyalist",
        challenges  = {
            E("Partisan", 1),
        },
        companion   = nil,
        pet         = nil,
        mount       = E("Frostsaber", 44),
        gameplay    = "Spirit tap + starshards",
    },

    ["Apothecary"] = {
        class       = "PRIEST",
        spec        = "Discipline",
        name        = "Apothecary",
        race        = "Undead",
        gender      = "Any",
        selfFound   = true,
        professions = { "Alchemy" },
        equipment   = {
            E("Robe", 1),
            E("Dagger", 5),
            E("Herb pouch", 10),
            E("Vial off-hand", 18),
            E("Nature wand", 30),
        },
        challenges  = {
            E("Homebound", 1),
        },
        quests      = {
            Q("A New Plague", 11, 492),
            Q("A Recipe For Death", 18, 451),
            Q("Elixir of Suffering", 22, 499),
            Q("Elixir of Pain", 24, 502),
            Q("Elixir of Agony", 30, 524),
            Q("Venom to the Undercity", 55, 2938),
        },
        questTheme  = "Plague-brewer",
        companion   = E("Cockroach", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Shadow Hunter"] = {
        class       = "PRIEST",
        spec        = "Shadow",
        name        = "Shadow Hunter",
        race        = "Troll",
        gender      = "Any",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Fishing",
            reason = "Need a high leveling of fishing to avoid caster melee penalty when attacking with a fishing pole.",
        },
        equipment   = {
            E("Show helm", 1),
            E("No robes", 1),
            E("No wands", 1),
            E("Pole", 44),
            E("Voodoo mask", 45),
            E("120 attack power", 50),
        },
        challenges  = {
            E("Nocturnal", 1),
            E("Faction leader", 60),
        },
        quests      = {
            Q("Zalazane", 10, 826),
            Q("Troll Charm", 24, 6462),
            Q("Trol'kalar", 42, 646),
            Q("Saving Yenniku", 46, 592),
            Q("Shadowshard Fragments", 42, 7068),
            Q("Snapjaws, Mon!", 44, 7815),
            Q("A Grim Discovery", 45, 2976),
            Q("Bone-Bladed Weapons", 51, 4300),
            Q("Job Opening: Guard Captain of Revantusk Village", 52, 7862),
        },
        questGroups = {
            { theme = "Darkspear Loyalist", count = 4 },
            { theme = "Building Attack Power", count = 5 },
        },
        questTheme  = nil,
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Melee weaving caster 1",
    },

    ---------- MAGE ----------

    ["Bloodmage"] = {
        class       = "MAGE",
        spec        = "Fire",
        name        = "Bloodmage",
        race        = "Undead",
        gender      = "Female",
        selfFound   = false,
        professions = { "Enchanting" },
        equipment   = {
            E("Shadow or fire wand", 15),
            E("Unholy weapon", 55),
        },
        challenges  = {
            E("White knight", 1),
            E("Drifter", 1),
        },
        quests      = {
            Q("The Guns of Northwatch", 20, 891),
            Q("Free From the Hold", 20, 898),
            Q("The Den", 29, 1089),
            Q("Ripple Delivery", 48, 81),
            Q("Xylem's Payment to Jediga", 52, 3565),
        },
        questTheme  = "For Quel'Thalas!",
        companion   = E("Phoenix", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = "Self-made enchants",
    },

    ["Mechano-Mage"] = {
        class       = "MAGE",
        spec        = "Arcane",
        name        = "Mechano-Mage",
        race        = "Gnome",
        gender      = "Any",
        selfFound   = true,
        professions = { "Engineering" },
        equipment   = {
            E("Show helm", 1),
            E("Flying tiger goggles", 20, 29),
            E("Green-tinted goggles", 30, 39),
            E("Gnomish goggles", 40),
            E("Engineer off-hand", 48),
        },
        challenges  = {
            E("Renegade", 1),
        },
        quests      = {
            Q("A Dark Threat Looms", 20, 283),
            Q("Data Rescue", 30, 2930),
            Q("Show Your Work", 47, 3641),
            Q("An OOX of Your Own", 50, 3721),
        },
        questTheme  = "Gadgetist",
        companion   = E("Mechanical", 45),
        pet         = nil,
        mount       = nil,
        gameplay    = "Pyroblast + arcane missiles, engineer off-hand",
    },

    ["Warmage"] = {
        class       = "MAGE",
        spec        = "Frost",
        name        = "Warmage",
        race        = "Human",
        gender      = "Male",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Sword", 1),
            E("Frost wand", 15),
            E("Staff-like off-hand", 20),
            E("Armored ring", 45),
        },
        challenges  = {
            E("Footman", 1),
        },
        quests      = {
            Q("Tramping Paws", 21, 276),
            Q("The Night Watch", 26, 57),
            Q("Worgen in the Woods", 31, 222),
            Q("Syndicate Assassins", 33, 505),
            Q("Hints of a New Plague?", 37, 661),
            Q("Clear the Way", 52, 5092),
        },
        questTheme  = "Crowd Control",
        companion   = E("Snow rabbit", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = "Aoe-farmer",
    },
}

----------------------------------------------------------------------
-- Lookup helpers
----------------------------------------------------------------------

-- Race names as returned by UnitRace (English client)
-- WoW returns "Night Elf" (with space), "Undead" for Forsaken, etc.
-- We normalise the spreadsheet data to match.
local RACE_ALIASES = {
    ["Nelf"]     = "Night Elf",
    ["Forsaken"] = "Undead",
    ["Tauren"]   = "Tauren",
    ["Dwarf"]    = "Dwarf",
    ["Human"]    = "Human",
    ["Gnome"]    = "Gnome",
    ["Orc"]      = "Orc",
    ["Troll"]    = "Troll",
    ["Any"]      = "Any",
}

-- Precompute a normalised race set on each character.
-- Supports comma-separated lists like "Dwarf, Human".
for _, char in pairs(HCE.Characters) do
    char.raceSet = {}
    for entry in char.race:gmatch("[^,]+") do
        local trimmed = entry:match("^%s*(.-)%s*$")
        local norm = RACE_ALIASES[trimmed] or trimmed
        char.raceSet[norm] = true
    end
end

--- Find all characters that match the player's class, race, and gender.
--- @return table list of character table references
function HCE.FindMatchingCharacters()
    local _, playerClass = UnitClass("player")  -- e.g. "WARRIOR"
    local playerRace     = UnitRace("player")   -- e.g. "Night Elf"
    local playerSex      = UnitSex("player")    -- 2=male, 3=female

    local playerGender
    if playerSex == 3 then
        playerGender = "Female"
    else
        playerGender = "Male"
    end

    local matches = {}
    for key, char in pairs(HCE.Characters) do
        if char.class == playerClass then
            local raceOK   = char.raceSet["Any"] or char.raceSet[playerRace]
            local genderOK = (char.gender == "Any") or (char.gender == playerGender)
            if raceOK and genderOK then
                table.insert(matches, char)
            end
        end
    end
    return matches
end

--- Get a character by its archetype name (table key).
--- @param name string
--- @return table|nil
function HCE.GetCharacter(name)
    return HCE.Characters[name]
end
