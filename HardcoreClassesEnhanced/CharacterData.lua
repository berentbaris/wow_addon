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
--   challenges  : list of { desc, level } tables (non-optional, always active)
--   optionalChallenges : list of { desc, level } tables (player picks one or none)
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
    ["Pro-nature"]      = "Complete quests against those who want to pillage and pollute Azeroth",
    ["Homebound"]       = "Can't leave home continent — focus on encroaching threats at home",
    ["Anti-demon"]      = "Level in demon-heavy zones (Darkshore, Blackfathom Deeps, Ashenvale, Felwood)",
    ["Diplomat"]        = "Must obtain another faction's mount",
    ["Scavenger"]        = "Cannot equip quest reward gear (except for white/grey items)",
    ["Aoe-farmer"]      = "Level mainly by aoe-farming in the open world",
    ["White knight"]    = "Can only equip white or grey gear",
    ["Partisan"]        = "Cannot equip looted gear (except for white/grey items)",
    ["Drifter"]         = "Cannot use hearthstone or bank — outsiders don't use city amenities",
    ["Ephemeral"]       = "Cannot repair gear",
    ["Self-made"]       = "Can only equip self-crafted or white/grey items (jewelry, cloak exempt)",
    ["Expeditionary"]       = "Can only equip items earned via group content or white/grey items",
    ["Exotic"]          = "Cannot equip green quality gear — exotic heros wear exotic armor",
    ["Off-the-shelf"]   = "Can only equip gear sold by vendors or white/grey items",
    ["Faction leader"]  = "Become exalted with your own faction",
    ["Scout"]         = "Cannot equip rare or epic quality items",
    ["No nonsense"]  = "Cannot learn any professions — Mountain Kings live only for battle",
    ["No demons"]        = "Cannot summon a demon pet or mount",
    ["Mortal pets"]     = "Hunter pets that die stay dead — cannot revive them",
    ["Cloth/leather"]   = "Cloth only until level 40, then cloth or leather",
    ["Cloth"]   = "Can only wear cloth armor",
    ["Leather/mail"]    = "Leather only until level 40, then leather or mail",
    ["Mail/plate"]      = "Must wear mail or plate in all possible slots",
    ["Imp"]             = "Must always use the Imp as your demon pet",
    ["Voidwalker"]             = "Cannot summon any demons besides the Voidwalker",
    ["Self-made guns"]  = "Ranged weapon must be self-crafted via Engineering",
    ["Demonic Sacrifice"] = "Must sacrifice your demon pet and maintain the Demonic Sacrifice buff",
    ["Purifier"]          = "Reach Honored reputation with Argent Dawn",
    ["Nocturnal"]         = "Must remain in towns or cities during daytime",
    ["Diurnal"]           = "Must remain in towns or cities during nighttime",
    ["Pyromancer"]        = "Cannot cast Frost spells — Bloodmages abandon frost magic",
    ["Cryomancer"]        = "Cannot cast Fire spells — Spellblades abandon fire magic",
    ["Light of Elune"]    = "Cannot cast Shadow spells — servants of Elune reject the void",
    ["All-out Assault"]             = "Cannot switch to Defensive Stance — Runemasters fight with brute force",
    ["Shadow Ascendant"]             = "Cannot use Holy abilities — Lightslayers fight against the light",
    ["Self-taught"]             = "Cannot use Arcane abilities — Hedge Wizards lack formal education",
    ["Overt"]             = "Cannot use Stealth or Vanish — Tinkers aren't so covert",
    ["Lone Wolf"]             = "Cannot summon a pet — Elven Archers don't have animal companions",
    ["Old Horde"]             = "Mustn't become Revered with Orgrimmar — Death Knights support the Old Horde, not Thrall's New Horde",
    ["Agnostic"]             = "Cannot use Holy spells — Sisters of Steel aren't devout believers",
    ["Truecaster"]             = "Cannot shapeshift — Not all druids pray to wild gods",
    ["Windfury Weapon"]             = "Cannot use any other weapon enchant",
    ["Voodoo Ritual"]               = "Perform a dark dance at the peak of Jintha'Alor while wearing 3 cursed items",
    ["Gnomish Justice"]             = "Use Gnomish Universal Remote on Clunk, then defeat Trade Master Kovic",
    ["Scarlet Redemption"]           = "Destroy the Scarlet Tabard at Light's Hope Chapel — renounce the Crusade",
    ["The New Plague"]               = "Destroy Nightglow Concoction near the Southshore inn while under Nature Protection Potion",
    ["Rockbiter Weapon"]             = "Cannot use any other weapon enchant",
    ["Cult of the Damned"]             = "Must be at war with the Argent Dawn — Necromancers work for the Cult of the Damned",
    ["Explorer"]            = "Explore the world — required exploration % scales with level",
    ["Lockdown"]            = "Can only use Cheap Shot as a stealth opener — cannot use Ambush or Garrote",
    ["Spirit of Ursa"]            = "Cannot shapeshift into Cat Form — Druids of the Claw worship only the Spirit of Ursa",
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
            E("No nonsense", 1),
        },
        optionalChallenges = {
            E("Partisan", 1),
            E("Expeditionary", 1),
            E("Mail/plate", 1),
        },
        equipment   = {
            E("Show helm", 1),
            E("Mace or axe", 1),
            E("Shield", 5),
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

    ["Sister of Steel"] = {
        class       = "WARRIOR",
        spec        = "Protection",
        name        = "Sister of Steel",
        race        = "Dwarf",
        gender      = "Female",
        selfFound   = true,
        professions = { "Blacksmithing" },
        challenges  = {
            E("Self-made", 1),
        },
        optionalChallenges = {
            E("Homebound", 1),
            E("Ephemeral", 1),
        },
        questsByHomebound = { 
            default = {
                Q("Supplying the Front", 16, 1578),
                Q("Jarl Needs a Blade", 35, 1203),
                Q("Expert Blacksmith!", 45, 2765),
                Q("Did You Lose This?", 50, 3321),
            },
            homebound = {
                Q("Supplying the Front", 16, 1578),
                Q("Gearing Redridge", 20, 1618),
                Q("Expert Blacksmith!", 45, 2765),
                Q("The Art of the Armorsmith", 50, 5283),
            },
        },
        questTheme  = "The Mithril Order",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "epic hammer",
    },

    ["Brewmaster"] = {
        class       = "WARRIOR",
        spec        = "Fury",
        name        = "Brewmaster",
        race        = "Any race",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Alchemy", "Cooking" },
        challenges  = {},
        optionalChallenges = {
            E("Exotic", 1),
            E("Scavenger", 1),
            E("Leather/mail", 1),
        },
        equipment   = {
            E("Hide helm", 1),
            E("Show cloak", 1),
            E("Robe", 5),
            E("Staff", 10),
            E("Dragonbreath chili", 40),
            E("Flask trinket", 50),
        },
        questsByFaction = {
            Alliance = {
                Q("The Perfect Stout", 9, 315),
                Q("Dry Times", 15, 116),
                Q("... and Bugs", 40, 1258),
                Q("Sweet Amber", 44, 53),
                Q("Report Back to Fizzlebub", 44, 1122),
                Q("Lost Thunderbrew Recipe", 55, 4134),
            },
            Horde = {
                Q("Chen's Empty Keg", 24, 822),
                Q("Smart Drinks", 20, 1491),
                Q("Report Back to Fizzlebub", 44, 1122),
                Q("Lost Thunderbrew Recipe", 55, 4134),
                Q("The Love Potion", 58, 4201),
            },
        },
        questTheme  = "Brew Guzzler",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "darkmoon special, dragonbreath",
    },

    ["Runemaster"] = {
        class       = "WARRIOR",
        spec        = "Fury",
        name        = "Runemaster",
        race        = "Tauren",
        gender      = "Any gender",
        selfFound   = false,
        professions = { "Enchanting" },
        challenges  = {
            E("All-out Assault", 1),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Scavenger", 1),
            E("Expeditionary", 1),
            E("Leather/mail", 1),
        },
        equipment   = {
            E("Hide helm", 1),
            E("Hide cloak", 1),
            E("No chest", 1),
            E("Fist weapons", 10),
            E("Kilt", 25),
        },
        quests      = {
            Q("The Venture Co.", 10, 764),
            Q("Keeper of the Flame", 20, 103),
            Q("The Weaver", 22, 480),
            Q("Revenge of Gann", 26, 849),
            Q("Hostile Takeover", 36, 213),
            Q("Venture Company Mining", 41, 600),
            Q("Summoning the Princess", 50, 656),
        },
        questTheme  = "Naturalist Scribe",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Self-made enchants, scrolls, pro-nature",
    },

    ["Berserker"] = {
        class       = "WARRIOR",
        spec        = "Protection",
        name        = "Berserker",
        race        = "Troll",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Alchemy" },
        challenges  = {},
        optionalChallenges = {
            E("Scout", 1),
            E("Partisan", 1),
            E("Expeditionary", 1),
        },
        equipment   = {
            E("Hide cloak", 1),
            E("Hide helm", 1),
            E("Axes", 10),
            E("Thrown", 10),
            E("Rage potion", 25),
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
        gameplay    = "rage pot",
    },

    ["Blademaster"] = {
        class       = "WARRIOR",
        spec        = "Arms",
        name        = "Blademaster",
        race        = "Orc",
        gender      = "Any gender",
        selfFound   = false,
        professions = {},
        recommendedProfession = {
            name = "Enchanting",
            reason = "90 Enchanting is needed to blaze your weapon with Minor Beastslaying.",
        },
        equipment   = {
            E("Hide helm", 1),
            E("Hide cloak", 1),
            E("No chest", 1),
            E("2h sword", 10),
            E("Blazing weapon", 20),
            E("Katana", 21),
        },
        challenges  = {},
        optionalChallenges = {
            E("Exotic", 1),
            E("Partisan", 1),
            E("Expeditionary", 1),
            E("Leather/mail", 1),
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
        gameplay    = "/sit and /meditate",
    },

    ["Brave"] = {
        class       = "WARRIOR",
        spec        = "Arms",
        name        = "Brave",
        race        = "Tauren",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Hide cloak", 1),
            E("Hide helm", 1),
            E("No shirt", 1),
            E("War harness", 8),
            E("Polearm", 24),
        },
        challenges  = {},
        optionalChallenges = {
            E("Scout", 1),
            E("Partisan", 1),
            E("Homebound", 1),
            E("Leather/mail", 1),
        },
        questsByHomebound = { 
            default = {
                Q("Rites of the Earthmother", 14, 776),
                Q("Earthen Arise", 20, 6481),
                Q("Grimtotem Spying", 28, 5064),
                Q("Final Passage", 36, 1394),
                Q("Zukk'ash Report", 48, 7732),
                Q("Glyphed Oaken Branch", 56, 4986),
            },
            homebound = {
                Q("Rites of the Earthmother", 14, 776),
                Q("Earthen Arise", 20, 6481),
                Q("Grimtotem Spying", 28, 5064),
                Q("Zukk'ash Report", 48, 7732),
                Q("Morrowgrain Research", 50, 3786),
                Q("Past Endeavors", 59, 5057),
            },
        },
        questTheme  = "Thunderbluff Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ---------- ROGUE ----------

    ["Tinker"] = {
        class       = "ROGUE",
        spec        = "Combat",
        name        = "Tinker",
        race        = "Gnome",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Engineering" },
        equipment   = {
            E("Show helm", 1),
            E("Maces", 10),
            E("Gun", 10),
            E("Flying tiger goggles", 20, 29),
            E("Green-tinted goggles", 30, 39),
            E("Engineering trinkets", 35),
            E("Discombobulator ray", 35),
            E("Gnomish goggles", 40),
        },
        challenges  = {
            E("Overt", 1),
            E("Gnomish Justice", 45),
        },
        optionalChallenges = {
            E("Scavenger", 1),
            E("Expeditionary", 1),
            E("Off-the-shelf", 1),
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
        gameplay    = nil,
    },

    ["Prospector"] = {
        class       = "ROGUE",
        spec        = "Subtlety",
        name        = "Prospector",
        race        = "Dwarf",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Mining" },
        equipment   = {
            E("Show helm", 1),
            E("Dagger", 10),
            E("Gun", 10),
            E("Prospector headgear", 32),
            E("Prospector's pick", 35),
        },
        challenges  = {
            E("Explorer", 1),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Scavenger", 1),
            E("Expeditionary", 1),
        },
        quests      = {
            Q("Cave Mushrooms", 17, 947),
            Q("Collecting Memories", 18, 168),
            Q("Search for Incendicite", 22, 466),
            Q("Rethban Ore", 24, 347),
            Q("A King's Tribute", 31, 700),
            Q("Favor for Krazek", 37, 627),
            Q("Restoring the Necklace", 44, 2361),
            Q("Delivering the Relic", 45, 2871),
            Q("The Mighty U'cha", 55, 4301),
        },
        questTheme  = "Dungeoneer",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "pick",
    },

    ["Buccaneer"] = {
        class       = "ROGUE",
        spec        = "Assassination",
        name        = "Buccaneer",
        race        = "Any race",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Fishing" },
        recommendedProfession = {
            name = "Tailoring",
            reason = "Needed to craft Captain's Hat, which requires 240 Tailoring.",
        },
        equipment   = {
            E("Show helm", 1),
            E("Dagger", 10),
            E("Gun", 10),
            E("Pirate blade", 20),
            E("Pirate shirt", 20),
            E("Pirate belt", 40),
            E("Captain's hat", 45),
        },
        challenges  = {
            E("Explorer", 1),
            E("Lockdown", 1),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Scavenger", 1),
            E("Expeditionary", 1),
        },
        questsByFaction = {
            Alliance = {
                Q("Stolen Booty", 16, 888),
                Q("Deep Ocean, Vast Sea", 17, 982),
                Q("Trouble at the Docks", 19, 959),
                Q("The Cursed Crew", 29, 289),
                Q("Claim Rackmore's Treasure!", 36, 6161),
                Q("Pearl Diving", 37, 705),
                Q("Deep Sea Salvage", 40, 662),
                Q("Cuergo's Gold", 45, 2882),
                Q("Whiskey Slim's Lost Grog", 50, 580),
            },
            Horde = {
                Q("From The Wreckage....", 8, 825),
                Q("Stolen Booty", 16, 888),
                Q("Trouble at the Docks", 19, 959),
                Q("Claim Rackmore's Treasure!", 36, 6161),
                Q("Catch of the Day", 37, 5386),
                Q("Pearl Diving", 37, 705),
                Q("Deep Sea Salvage", 40, 662),
                Q("Cuergo's Gold", 45, 2882),
                Q("Whiskey Slim's Lost Grog", 50, 580),
            },
        },
        questTheme  = "Treasure Hunter",
        companion   = E("Parrot", 15),
        pet         = nil,
        mount       = nil,
        gameplay    = "Rum",
    },

    ["Warden"] = {
        class       = "ROGUE",
        spec        = "Assassination",
        name        = "Warden",
        race        = "Night Elf",
        gender      = "Female",
        selfFound   = true,
        professions = {},
        challenges  = {
            E("Lockdown", 1),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Partisan", 1),
            E("Self-made", 1),
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

    ["Demon Hunter"] = {
        class       = "ROGUE",
        spec        = "Combat",
        name        = "Demon Hunter",
        race        = "Night Elf",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        challenges  = {},
        optionalChallenges = {
            E("Exotic", 1),
            E("Scavenger", 1),
            E("Homebound", 1),
            E("Self-made", 1),
        },
        equipment   = {
            E("Hide cloak", 1),
            E("Hide helm", 1),
            E("No chest", 1),
            E("Swords", 10),
            E("Kilt", 25),
        },
        questsByHomebound = { 
            default = {
                Q("The Blackwood Corrupted", 18, 4763),
                Q("The Tower of Althalaxx", 31, 981),
                Q("Satyr Slaying!", 32, 1032),
                Q("A Land Filled with Hatred", 47, 5536),
                Q("Ancient Spirit", 56, 4261),
                Q("A Final Blow", 58, 5242),
                Q("You Are Rakh'likh, Demon", 60, 3628),
            },
            homebound = {
                Q("The Blackwood Corrupted", 18, 4763),
                Q("The Tower of Althalaxx", 31, 981),
                Q("Satyr Slaying!", 32, 1032),
                Q("A Land Filled with Hatred", 47, 5536),
                Q("Ancient Spirit", 56, 4261),
                Q("A Final Blow", 58, 5242),
            },
        },
        questTheme  = "The Legion Shall Fall",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-demon, /bow",
    },

    ["Dark Ranger"] = {
        class       = "ROGUE",
        spec        = "Subtlety",
        name        = "Dark Ranger",
        race        = "Undead",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Tailoring",
            reason = "A modest level of Tailoring is required to craft the Azure Silk Hood (125 Tailoring).",
        },
        weaponProficiency = { E("Bows", 15) },
        challenges  = {},
        optionalChallenges = {
            E("Scout", 1),
            E("Partisan", 1),
        },
        equipment   = {
            E("Show cloak", 1),
            E("Show helm", 1),
            E("Dagger and sword", 10),
            E("Bow", 12),
            E("Ranger cape", 25),
            E("Ranger hood", 25),
        },
        quests      = {
            Q("Arachnophobia", 21, 6284),
            Q("Bloodfury Bloodline", 26, 6283),
            Q("Arikara", 28, 5088),
            Q("Hypercapacitor Gizmo", 30, 5151),
            Q("Vorrel's Revenge", 33, 1051),
            Q("Excelsior", 38, 628),
            Q("Big Game Hunter", 43, 208),
            Q("Facing Negolash", 50, 8554),
            Q("Past Endeavors", 59, 5057),
        },
        questTheme  = "Test of the Solo Archer",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "bow kiting",
    },

    ---------- WARLOCK ----------

    ["Pyremaster"] = {
        class       = "WARLOCK",
        spec        = "Destruction",
        name        = "Pyremaster",
        race        = "Orc",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Cooking" },
        challenges  = {
            E("Imp", 1),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Partisan", 1),
            E("Homebound", 1),
            E("Self-made", 1),
        },
        equipment   = {
            E("No wands", 1),
            E("Flint and tinder", 10),
            E("1.5 speed dagger", 15),
            E("Firestone", 25),
            E("Dragonbreath chili", 40),
        },
        questsByHomebound = { 
            default = {
                Q("Keeper of the Flame", 21, 103),
                Q("Dangerous!", 28, 567),
                Q("The Sacred Flame", 29, 1197),
                Q("Rig Wars", 35, 2841),
                Q("Extinguishing the Idol", 37, 3525),
                Q("Volcanic Activity", 55, 4502),
                Q("A Taste of Flame", 58, 4024),
            },
            homebound = {
                Q("The Demon Seed", 14, 924),
                Q("Hidden Enemies", 16, 5730),
                Q("The Corrupter", 37, 1488),
                Q("The Sacred Flame", 29, 1197),
                Q("Extinguishing the Idol", 37, 3525),
                Q("Volcanic Activity", 55, 4502),
            },
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
            E("Old Horde", 1),
            E("Voidwalker", 10),
        },
        optionalChallenges = {
            E("Expeditionary", 1),
            E("Drifter", 1),
        },
        equipment   = {
            E("Show cloak", 1),
            E("Hide helm", 1),
            E("No wands", 1),
            E("Sword", 10, 33),
            E("Armored weapon/off-hand", 34),
            E("140 stamina", 40),
            E("Armored rings", 45),
            E("Armored trinket", 45),
            E("180 stamina", 50),
        },
        quests      = {
            Q("The Book of Ur", 26, 1013),
            Q("The Star, the Hand and the Heart", 44, 736),
            Q("Set Them Ablaze!", 52, 3463),
            Q("Helcular's Revenge", 55, 553),
            Q("A Taste of Flame", 58, 4024),
        },
        questTheme  = "Serving the Old Horde",
        companion   = nil,
        pet         = nil,
        mount       = E("Skeletal horse", 44),
        gameplay    = "tank, sacrifice",
    },

    ["Necromancer"] = {
        class       = "WARLOCK",
        spec        = "Affliction",
        name        = "Necromancer",
        race        = "Any race",
        gender      = "Any gender",
        selfFoundByFaction = {
            Alliance = true,
            Horde    = false,
        },
        professions = {},
        challenges  = {
            E("No demons", 1),
            E("Cult of the Damned", 30),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Scavenger", 1),
            E("Expeditionary", 1),
        },
        equipment   = {
            E("Show helm", 1),
            E("Robe", 1),
            E("Shadow wand", 15),
            E("Necromancer hat", 30),
            E("Skull off-hand", 30, 59),
            E("Necromancer robe", 40),
            E("Book of necromancy", 60),
        },
        questsByFaction = {
            Alliance = {
                Q("Knowledge in the Deeps", 23, 971),
                Q("A Noble Brew", 30, 336),
                Q("The Star, the Hand and the Heart", 44, 735),
                Q("The God Hakkar", 53, 3528),
            },
            Horde = {
                Q("The Book of Ur", 26, 1013),
                Q("The Star, the Hand and the Heart", 44, 736),
                Q("The God Hakkar", 53, 3528),
                Q("Helcular's Revenge", 55, 553),
            },
        },
        questTheme  = "Nihilist",
        companion   = E("Cat", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Graven One"] = {
        class       = "WARLOCK",
        spec        = "Affliction",
        name        = "Graven One",
        race        = "Undead",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Fishing",
            reason = "Need a high leveling of fishing to avoid caster melee penalty when attacking with a fishing pole + lure.",
        },
        challenges  = {
            E("No demons", 1),
        },
        optionalChallenges = {
            E("Self-made", 1),
            E("Drifter", 1),
        },
        equipment   = {
            E("Shadow wand", 15),
            E("Pole", 44, 59),
            E("120 attack power", 50),
            E("Book of necromancy", 60),
        },
        quests      = {
            Q("The Book of Ur", 26, 1013),
            Q("The Star, the Hand and the Heart", 44, 736),
            Q("The God Hakkar", 53, 3528),
            Q("Helcular's Revenge", 55, 553),
            Q("Shadowshard Fragments", 42, 7068),
            Q("Snapjaws, Mon!", 44, 7815),
            Q("A Grim Discovery", 45, 2976),
            Q("Bone-Bladed Weapons", 51, 4300),
            Q("Job Opening: Guard Captain of Revantusk Village", 52, 7862),
        },
        questGroups = {
            { theme = "Nihilist", count = 4 },
            { theme = "Building Attack Power", count = 5 },
        },
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "melee weaving caster lock, pole weaving",
    },

    ---------- DRUID ----------

    ["Druid of the Claw"] = {
        class       = "DRUID",
        spec        = "Feral",
        name        = "Druid of the Claw",
        race        = "Night Elf",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Alchemy",
            reason = "Needed to craft Elixir of Fortitude (175 Alchemy) for Reception from Tyrande.",
        },
        challenges  = {
            E("Spirit of Ursa", 1),
        },
        optionalChallenges = {
            E("Drifter", 1),
            E("Partisan", 1),
            E("Expeditionary", 1),
        },
        equipment   = {
            E("Armored weapon/off-hand", 25),
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

    ["Dragonsworn"] = {
        class       = "DRUID",
        spec        = "Balance",
        name        = "Dragonsworn",
        race        = "Night Elf",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Alchemy, Tailoring",
            reason = "Go Alchemy first to get the 2x Elixir of Fortitude required for Faerie Dragon pet. Then switch to Tailoring to craft the Dreamweave armor set.",
        },
        challenges  = {
            E("Truecaster", 1),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Self-made", 1),
            E("Cloth", 1),
        },
        equipment   = {
            E("Green shirt", 10),
            E("Dreamweave gloves", 45),
            E("Dreamweave vest", 45),
            E("Dreamweave kilt", 48),
            E("Dreamweave circlet", 50),
        },
        quests      = {
            Q("The Sleeper Has Awakened", 20, 5321),
            Q("In Nightmares", 25, 3370),
            Q("Satyr Slaying!", 32, 1032),
            Q("Extinguishing the Idol", 37, 3525),
            Q("Becoming a Parent", 48, 4298),
            Q("Further Corruption", 54, 4906),
            Q("In Eranikus' Own Words", 55, 3512),
        },
        questTheme  = "Serving the Green Dragonflight",
        companion   = E("Faerie dragon", 48),
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Ley Walker"] = {
        class       = "DRUID",
        spec        = "Balance",
        name        = "Ley Walker",
        race        = "Any race",
        gender      = "Any gender",
        selfFound   = false,
        professions = { "Enchanting" },
        recommendedProfession = {
            name = "Tailoring",
            reason = "High level of Tailoring is required to craft the Robe of Power.",
        },
        challenges  = {
            E("Truecaster", 1),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Self-made", 1),
            E("Cloth", 1),
        },
        equipment   = {
            E("Staff", 1),
            E("Robe of power", 45),
        },
        questsByFaction = {
            Alliance = {
                Q("Cleansing of the Infected", 16, 2138),
                Q("The Escape", 18, 863),
                Q("Keeper of the Flame", 20, 103),
                Q("Hostile Takeover", 36, 213),
                Q("Venture Company Mining", 41, 600),
                Q("Verifying the Corruption", 54, 5156),
                Q("Arcane Runes", 52, 3449),
                Q("Cleansing Felwood", 55, 4101),
            },
            Horde = {
                Q("The Venture Co.", 10, 764),
                Q("Keeper of the Flame", 20, 103),
                Q("Samophlange", 16, 902),
                Q("Shredding Machines", 23, 1068),
                Q("Gerenzo Wrenchwhistle", 27, 1096),
                Q("Hostile Takeover", 36, 213),
                Q("Venture Company Mining", 41, 600),
            },
        },
        questTheme  = "Naturalist Scribe",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Plagueshifter"] = {
        class       = "DRUID",
        spec        = "Restoration",
        name        = "Plagueshifter",
        race        = "Tauren",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Leatherworking",
            reason = "Needed to craft Powershifting helm (Wolfshead Helm), which requires 225 Leatherworking.",
        },
        equipment   = {
            E("Hide helm", 1),
            E("Show cloak", 1),
            E("80 strength", 30),
            E("Jungle remedy", 35),
            E("Plagueshifter robes", 35),
            E("100 strength & intellect", 40),
            E("Plagueshifter shoulders", 40),
            E("Powershifting helm", 45),
            E("Plagueshifter cloak", 45),
            E("200 intellect", 50),
        },
        challenges  = {
            E("Purifier", 60),
        },
        optionalChallenges = {
            E("Partisan", 1),
            E("Expeditionary", 1),
            E("Self-made", 1),
        },
        quests      = {
            Q("The Family Crypt", 13, 408),
            Q("Assault on Fenris Isle", 24, 442),
            Q("An Unholy Alliance", 36, 6521),
            Q("Ghost-o-plasm Round Up", 39, 6134),
            Q("Spiritual Unrest", 47, 5535),
            Q("Poisoned Water", 56, 6804),
            Q("Mission Accomplished!", 58, 5238),
            Q("The Argent Hold", 60, 5265),
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
        race        = "Any race",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("125 intellect", 40),
            E("Armored ring", 45),
            E("200 intellect", 50),
        },
        challenges  = {
            E("Drifter", 1),
        },
        optionalChallenges = {
            E("Scavenger", 1),
            E("Homebound", 1),
            E("Self-made", 1),
        },
        questsByFaction = {
            Alliance = {
                default = {
                    Q("Cleansing of the Infected", 16, 2138),
                    Q("The Escape", 18, 863),
                    Q("Insane Druids", 32, 1012),
                    Q("Hostile Takeover", 36, 213),
                    Q("Venture Company Mining", 41, 600),
                    Q("Rise of the Silithid", 49, 162),
                    Q("Verifying the Corruption", 54, 5156),
                    Q("Cleansing Felwood", 55, 4101),
                }, 
                homebound = {
                    Q("Cleansing of the Infected", 16, 2138),
                    Q("The Escape", 18, 863),
                    Q("Insane Druids", 32, 1012),
                    Q("Rise of the Silithid", 49, 162),
                    Q("Verifying the Corruption", 54, 5156),
                    Q("Cleansing Felwood", 55, 4101),
                },
            },
            Horde = {
                default = {
                    Q("The Venture Co.", 10, 764),
                    Q("Samophlange", 16, 902),
                    Q("Samophlange Manual", 19, 3924),
                    Q("Shredding Machines", 23, 1068),
                    Q("Gerenzo Wrenchwhistle", 27, 1096),
                    Q("Hostile Takeover", 36, 213),
                    Q("Venture Company Mining", 41, 600),
                }, 
                homebound = {
                    Q("The Venture Co.", 10, 764),
                    Q("Samophlange", 16, 902),
                    Q("Samophlange Manual", 19, 3924),
                    Q("Shredding Machines", 23, 1068),
                    Q("Gerenzo Wrenchwhistle", 27, 1096),
                },
            },
        },
        questTheme  = "Naturalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Pro-nature, savage",
    },

    ---------- HUNTER ----------

    ["Beastmaster"] = {
        class       = "HUNTER",
        spec        = "Beast Mastery",
        name        = "Beastmaster",
        race        = "Orc",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Leatherworking" },
        equipment   = {
            E("Show helm", 1),
            E("No guns", 1),
            E("Beastslaying cloak", 20),
            E("Beastslaying gloves", 30),
            E("Beastslaying melee weapon", 35),
            E("Wolf helm", 45),
            E("Beastslaying ranged weapon", 50),
        },
        challenges  = {
            E("Mortal pets", 1),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Scavenger", 1),
            E("Expeditionary", 1),
        },
        quests      = {
            Q("Isha Awak", 27, 873),
            Q("Big Game Hunter", 43, 208),
            Q("Message in a Bottle", 51, 630),
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
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Engineering" },
        equipment   = {
            E("Show cloak", 1),
            E("Show helm", 1),
            E("Gun", 1),
            E("2h axe", 10),
            E("Scope", 15),
            E("Mountaineer cape", 40),
            E("Mountaineer hood", 50),
        },
        challenges  = {
            E("Self-made guns", 10),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Partisan", 1),
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
        gameplay    = nil,
    },

    ["Elven Ranger"] = {
        class       = "HUNTER",
        spec        = "Survival",
        name        = "Elven Ranger",
        race        = "Night Elf",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Tailoring",
            reason = "A modest level of Tailoring is required to craft the Azure Silk Hood & Cloak (175 Tailoring).",
        },
        challenges  = {
            E("Lone Wolf", 1),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Partisan", 1),
            E("Expeditionary", 1),
            E("Cloth/leather", 1),
        },
        equipment   = {
            E("Show cloak", 1),
            E("Show helm", 1),
            E("Bow", 1),
            E("Swords", 20),
            E("Ranger cape", 25),
            E("Ranger hood", 25),
        },
        quests      = {
            Q("Sathrah's Sacrifice", 12, 2520),
            Q("Answered Questions", 30, 1044),
            Q("Rise of the Silithid", 46, 4267),
            Q("The Mystery of Morrowgrain", 50, 3791),
            Q("Wildkin of Elune", 57, 4902),
        },
        questTheme  = "Darnassus Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Wilderness Stalker"] = {
        class       = "HUNTER",
        spec        = "Survival",
        name        = "Wilderness Stalker",
        race        = "Troll",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        weaponProficiency = { E("Thrown", 10) },
        equipment   = {
            E("Axes", 1),
            E("Thrown", 10),
        },
        challenges  = {
            E("Drifter", 1),
        },
        optionalChallenges = {
            E("Partisan", 1),
            E("Homebound", 1),
            E("Self-made", 1),
            E("Cloth/leather", 1),
        },
        questsByHomebound = { 
            default = {
                Q("Zalazane", 10, 826),
                Q("Troll Charm", 24, 6462),
                Q("Other Fish to Fry", 36, 6143),
                Q("Trol'kalar", 42, 646),
                Q("Saving Yenniku", 46, 592),
            },
            homebound = {
                Q("Zalazane", 10, 826),
                Q("Troll Charm", 24, 6462),
                Q("Other Fish to Fry", 36, 6143),
                Q("Weapons of Spirit", 50, 3129),
            },
        },
        questTheme = "Darkspear Loyalist",
        companion   = nil,
        pet         = E("Wolf", 10),
        mount       = nil,
        gameplay    = nil,
    },

    ---------- SHAMAN ----------

    ["Earthcaller"] = {
        class       = "SHAMAN",
        spec        = "Enhancement",
        name        = "Earthcaller",
        race        = "Any race",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Shield", 5),
            E("1200 armor", 30),
            E("3000 armor", 50),
        },
        challenges  = {
            E("Rockbiter Weapon", 2),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Expeditionary", 1),
            E("Self-made", 1),
        },
        quests      = {
            Q("Earthen Arise", 20, 6481),
            Q("A New Ore Sample", 29, 1153),
            Q("Test of Strength", 30, 1151),
            Q("Bracers of Binding", 34, 557),
            Q("Study of the Elements: Rock", 42, 712),
            Q("Summoning the Princess", 50, 656),
            Q("Corruption of Earth and Seed", 51, 7064),
        },
        questTheme  = "Earthbender",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "tank tour",
    },

    ["Witch Doctor"] = {
        class       = "SHAMAN",
        spec        = "Restoration",
        name        = "Witch Doctor",
        race        = "Troll",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Alchemy" },
        equipment   = {
            E("Show helm", 1),
            E("Herb pouch", 10),
            E("Witch doctor staff", 11),
            E("Voodoo mask", 45),
            E("Cursed amulet", 45),
        },
        challenges  = {
            E("Voodoo Ritual", 50),
        },
        optionalChallenges = {
            E("Expeditionary", 1),
            E("Cloth/leather", 1),
            E("Drifter", 1),
        },
        quests      = {
            Q("Jin'Zil's Forest Magic", 26, 1058),
            Q("Stranglethorn Fever", 45, 348),
            Q("Weapons of Spirit", 50, 3129),
            Q("Luck Be With You", 59, 969),
        },
        questTheme  = "Voodoo Magic",
        companion   = E("Frog", 30),
        pet         = nil,
        mount       = nil,
        gameplay    = "cursed necklace",
    },

    ["Spiritwalker"] = {
        class       = "SHAMAN",
        spec        = "Elemental",
        name        = "Spiritwalker",
        race        = "Tauren",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Hide helm", 1),
            E("1h axe", 10),
            E("Lantern", 24),
        },
        challenges  = {
            E("Explorer", 1),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Self-made", 1),
        },
        quests      = {
            Q("The Warsong Reports", 19, 6543),
            Q("Weapons of Choice", 24, 893),
            Q("Final Passage", 36, 1394),
            Q("Cuergo's Gold", 45, 2882),
            Q("Cortello's Riddle", 51, 626),
            Q("It's Dangerous to Go Alone", 56, 3962),
        },
        questTheme  = "Wander the land",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Spirit Champion"] = {
        class       = "SHAMAN",
        spec        = "Enhancement",
        name        = "Spirit Champion",
        race        = "Orc",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Hide helm", 1),
            E("Hide cloak", 1),
            E("No chest", 1),
            E("2h axe/mace", 20),
        },
        challenges  = {
            E("Windfury Weapon", 30),
        },
        optionalChallenges = {
            E("Scavenger", 1),
            E("Expeditionary", 1),
            E("Cloth/leather", 1),
        },
        quests      = {
            Q("Weapons of Choice", 24, 893),
            Q("Final Passage", 36, 1394),
            Q("Threat From the Sea", 43, 1427),
            Q("Mok'thardin's Enchantment", 44, 573),
            Q("Weapons of Spirit", 50, 3129),
            Q("The Perfect Poison", 60, 9023),
        },
        questTheme  = "Choose Your Weapon",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "/sit and /meditate",
    },

    ---------- PALADIN ----------

    ["Scarlet Champion"] = {
        class       = "PALADIN",
        spec        = "Protection",
        name        = "Scarlet Champion",
        race        = "Human",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Tailoring",
            reason = "A very modest level of skill is required to craft the Red Linen Shirt (Tailoring 40).",
        },
        equipment   = {
            E("Show helm", 1),
            E("Hide cloak", 1),
            E("Red shirt", 10),
            E("Scarlet tabard", 40, 59),
            E("Scarlet shoulders", 40),
            E("Scarlet helm", 40),
            E("Scarlet shield", 44),
            E("Scarlet chestpiece", 46),
            E("Scarlet leggings", 46),
            E("Scarlet gauntlets", 46),
            E("Scarlet boots", 50),
        },
        challenges  = {
            E("Purifier", 60),
            E("Scarlet Redemption", 60),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Scavenger", 1),
            E("Homebound", 1),
        },
        questsByHomebound = { 
            default = {
                Q("Collecting Memories", 18, 168),
                Q("Cleansing the Eye", 30, 293),
                Q("Bride of the Embalmer", 30, 253),
                Q("Mythology of the Titans", 38, 1050),
                Q("Spiritual Unrest", 47, 5535),
                Q("The Remains of Trey Lightforge", 57, 5385),
                Q("Unfinished Business", 58, 6025),
                Q("In Dreams", 59, 5944),
            },
            homebound = {
                Q("Collecting Memories", 18, 168),
                Q("Cleansing the Eye", 30, 293),
                Q("Bride of the Embalmer", 30, 253),
                Q("Mythology of the Titans", 38, 1050),
                Q("Voodoo Dues", 44, 609),
                Q("Unfinished Business", 58, 6025),
                Q("In Dreams", 59, 5944),
            },
        },
        questTheme  = "Leaving the Cult",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Exemplar"] = {
        class       = "PALADIN",
        spec        = "Retribution",
        name        = "Exemplar",
        race        = "Human",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Tailoring, Blacksmithing",
            reason = "A very modest level of Tailoring skill is required to craft the Blue Linen Shirt. Forge the rest of your armor with Blacksmithing.",
        },
        challenges  = {
            E("Faction leader", 60),
        },
        optionalChallenges = {
            E("Partisan", 1),
            E("Expeditionary", 1),
            E("Self-made", 1),
        },
        equipment   = {
            E("Sword or mace", 5),
            E("Blue shirt", 10),
            E("Guild tabard", 20),
            E("Insignia", 30),
            E("Imperial helm", 45),
            E("Imperial shoulders", 53),
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
        gameplay    = "Stormwind hearthstone, tank tour, sw tabard",
    },

    ["Templar"] = {
        class       = "PALADIN",
        spec        = "Holy",
        name        = "Templar",
        race        = "Any race",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        challenges  = {
            E("Purifier", 60),
        },
        optionalChallenges = {
            E("Homebound", 1),
            E("Mail/plate", 1),
        },
        equipment   = {
            E("Show helm", 1),
            E("Sword or mace", 5),
            E("Guild tabard", 20),
            E("Argent shoulders", 42),
            E("Argent helm", 45),
            E("Argent Dawn trinket", 50),
        },
        questsByHomebound = { 
            default = {
                Q("Collecting Memories", 18, 168),
                Q("Cleansing the Eye", 30, 293),
                Q("Bride of the Embalmer", 30, 253),
                Q("Voodoo Dues", 44, 609),
                Q("Spiritual Unrest", 47, 5535),
                Q("The Remains of Trey Lightforge", 57, 5385),
                Q("The Argent Hold", 60, 5265),
            },
            homebound = {
                Q("Collecting Memories", 18, 168),
                Q("Cleansing the Eye", 30, 293),
                Q("Bride of the Embalmer", 30, 253),
                Q("Voodoo Dues", 44, 609),
                Q("Mission Accomplished!", 58, 5237),
                Q("The Argent Hold", 60, 5265),
            },
        },
        questTheme  = "Purging the Undead",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-undead, argent tabard",
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
        questsByHomebound = { 
            default = {
                Q("Sathrah's Sacrifice", 12, 2520),
                Q("Answered Questions", 30, 1044),
                Q("Rise of the Silithid", 46, 4267),
                Q("The Mystery of Morrowgrain", 50, 3791),
                Q("Wildkin of Elune", 57, 4902),
            },
            homebound = {
                Q("Sathrah's Sacrifice", 12, 2520),
                Q("Raene's Cleansing", 30, 1046),
                Q("Rise of the Silithid", 46, 4267),
                Q("The Mystery of Morrowgrain", 50, 3791),
                Q("Ancient Spirit", 56, 4261),
            },
        },
        questTheme  = "Darnassus Loyalist",
        challenges  = {
            E("Light of Elune", 1),
        },
        optionalChallenges = {
            E("Partisan", 1),
            E("Homebound", 1),
            E("Self-made", 1),
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
        gender      = "Any gender",
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
            E("The New Plague", 55),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Partisan", 1),
            E("Homebound", 1),
        },
        questsByHomebound = { 
            default = {
                Q("A New Plague", 11, 492),
                Q("A Recipe For Death", 18, 451),
                Q("Elixir of Suffering", 22, 499),
                Q("Elixir of Pain", 24, 502),
                Q("Elixir of Agony", 30, 524),
                Q("Zanzil's Secret", 44, 621),
                Q("Venom to the Undercity", 55, 2938),
            },
            homebound = {
                Q("A New Plague", 11, 492),
                Q("A Recipe For Death", 18, 451),
                Q("Elixir of Suffering", 22, 499),
                Q("Elixir of Pain", 24, 502),
                Q("Elixir of Agony", 30, 524),
                Q("Zanzil's Secret", 44, 621),
                Q("Venom to the Undercity", 55, 2938),
            },
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
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        recommendedProfession = {
            name = "Fishing",
            reason = "Need a high leveling of fishing to avoid caster melee penalty when attacking with a fishing pole + lure.",
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
            E("Faction leader", 60),
        },
        optionalChallenges = {
            E("Partisan", 1),
            E("Self-made", 1),
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
        gameplay    = "Melee weaving caster 1, pole weaving",
    },

    ["Lightslayer"] = {
        class       = "PRIEST",
        spec        = "Shadow",
        name        = "Lightslayer",
        race        = "Undead",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Dagger", 10),
            E("Shadow wand", 15),
        },
        challenges  = {
            E("Shadow Ascendant", 1),
        },
        optionalChallenges = {
            E("Scavenger", 1),
            E("Homebound", 1),
            E("Self-made", 1),
            E("Nocturnal", 1),
        },
        questsByHomebound = { 
            default = {
                Q("At War With The Scarlet Crusade", 12, 372),
                Q("Vorrel's Revenge", 33, 1051),
                Q("Hearts of Zeal", 33, 1113),
                Q("Into The Scarlet Monastery", 42, 1048),
                Q("Unfinished Business", 58, 6025),
            },
            homebound = {
                Q("At War With The Scarlet Crusade", 12, 372),
                Q("Vorrel's Revenge", 33, 1051),
                Q("Into The Scarlet Monastery", 42, 1048),
                Q("Unfinished Business", 58, 6025),
                Q("The Scarlet Oracle, Demetria", 60, 6148),
            },
        },
        questTheme  = "Cult of the Forgotten Shadow",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ---------- MAGE ----------

    ["Bloodmage"] = {
        class       = "MAGE",
        spec        = "Fire",
        name        = "Bloodmage",
        race        = "Undead",
        gender      = "Any gender",
        selfFound   = false,
        professions = { "Enchanting" },
        equipment   = {
            E("Shadow or fire wand", 15),
            E("Unholy weapon", 55),
        },
        challenges  = {
            E("Pyromancer", 1),
        },
        optionalChallenges = {
            E("Exotic", 1),
            E("Scavenger", 1),
            E("Homebound", 1),
            E("Self-made", 1),
        },
        questsByHomebound = { 
            default = {
                Q("The Guns of Northwatch", 20, 891),
                Q("Free From the Hold", 20, 898),
                Q("The Den", 29, 1089),
                Q("Ripple Delivery", 48, 81),
                Q("Xylem's Payment to Jediga", 52, 3565),
            },
            homebound = {
                Q("The Family Crypt", 13, 408),
                Q("Assault on Fenris Isle", 24, 442),
                Q("A Boar's Vitality", 50, 2583),
                Q("Snickerfang Jowls", 50, 2581),
                Q("The Decisive Striker", 50, 2585),
                Q("Vulture's Vigor", 50, 2603),
                Q("The Basilisk's Bite", 50, 2601),
            },
        },
        questTheme  = "For Quel'Thalas!",
        companion   = E("Phoenix", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = "Self-made enchants",
    },

    ["Techno-mage"] = {
        class       = "MAGE",
        spec        = "Arcane",
        name        = "Techno-mage",
        race        = "Gnome",
        gender      = "Any gender",
        selfFound   = true,
        professions = { "Engineering" },
        equipment   = {
            E("Show helm", 1),
            E("Flying tiger goggles", 20, 29),
            E("Green-tinted goggles", 30, 39),
            E("Engineering trinkets", 35),
            E("Discombobulator ray", 35),
            E("Gnomish goggles", 40),
            E("Engineer off-hand", 48),
        },
        challenges  = {
            E("Gnomish Justice", 45),
        },
        optionalChallenges = {
            E("Scavenger", 1),
            E("Homebound", 1),
        },
        questsByHomebound = { 
            default = {
                Q("Bingles' Missing Supplies", 15, 2038),
                Q("A Dark Threat Looms", 20, 283),
                Q("Data Rescue", 30, 2930),
                Q("Show Your Work", 47, 3641),
                Q("An OOX of Your Own", 50, 3721),
            },
            homebound = {
                Q("Bingles' Missing Supplies", 15, 2038),
                Q("A Dark Threat Looms", 20, 283),
                Q("Data Rescue", 30, 2930),
                Q("Gnome Improvement", 35, 2948),
                Q("Show Your Work", 47, 3641),
            },
        },
        questTheme  = "Gadgetist",
        companion   = E("Mechanical", 45),
        pet         = nil,
        mount       = nil,
        gameplay    = "Pyroblast + arcane missiles",
    },

    ["Spellblade"] = {
        class       = "MAGE",
        spec        = "Frost",
        name        = "Spellblade",
        race        = "Any race",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("No robes", 1),
            E("Sword", 5),
            E("Staff-like off-hand", 20),
            E("Frost wand", 35),
            E("Armored ring", 45),
        },
        challenges  = {
            E("Cryomancer", 1),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Scavenger", 1),
            E("Self-made", 1),
        },
        questsByFaction = {
            Alliance = {
                Q("Tramping Paws", 21, 276),
                Q("The Night Watch", 26, 57),
                Q("Worgen in the Woods", 31, 222),
                Q("Syndicate Assassins", 33, 505),
                Q("Hints of a New Plague?", 37, 661),
                Q("Clear the Way", 52, 5092),
            },
            Horde = {
                Q("Souvenirs of Death", 25, 546),
                Q("Battle of Hillsbrad", 32, 550),
                Q("To Steal From Thieves", 36, 1164),
                Q("Into The Scarlet Monastery", 42, 1048),
                Q("Continued Threat", 45, 1428),
                Q("Melding of Influences", 55, 4642),
            },
        },
        questTheme  = "Crowd Control",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Aoe-farmer",
    },

    ["Hedge Wizard"] = {
        class       = "MAGE",
        spec        = "Fire",
        name        = "Hedge Wizard",
        race        = "Troll",
        gender      = "Any gender",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Fire wand", 15),
        },
        challenges  = {
            E("Self-taught", 1),
        },
        optionalChallenges = {
            E("Scout", 1),
            E("Scavenger", 1),
            E("Self-made", 1),
        },
        quests      = {
            Q("The Weaver", 22, 480),
            Q("Dalaran Patrols", 35, 545),
        },
        questTheme  = "Infiltrating Dalaran",
        companion   = E("Crimson snake", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Archmage of Kirin Tor"] = {
        class       = "MAGE",
        spec        = "Frost",
        name        = "Archmage of Kirin Tor",
        race        = "Human",
        gender      = "Any gender",
        selfFound   = false,
        professions = { "Enchanting" },
        equipment   = {
            E("Staff", 1),
            E("Kirin Tor robes", 22),
            E("Archmage shoulders", 34),
            E("Archmage circlet", 52),
        },
        challenges  = {},
        optionalChallenges = {
            E("Exotic", 1),
            E("Partisan", 1),
        },
        quests      = {
            Q("Investigate the Blue Recluse", 16, 1920),
            Q("Ur's Treatise on Shadow Magic", 28, 1938),
            Q("The Curse of the Tides", 40, 611),
            Q("Mage's Wand", 40, 1952),
            Q("Celestial Power", 40, 1958),
            Q("Destroy Morphaz", 52, 8253),
        },
        questTheme  = "Formal Education",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
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
    ["Any race"]      = "Any race",
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
            local raceOK   = char.raceSet["Any race"] or char.raceSet[playerRace]
            local genderOK = (char.gender == "Any gender") or (char.gender == playerGender)
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

--- Check whether the player has the Homebound challenge active.
--- @return boolean
function HCE.IsHomeboundActive()
    return HCE_CharDB and HCE_CharDB.selectedChallenge == "Homebound"
end

--- Resolve a quest source that may be a flat array or a { default, homebound } table.
--- @param source table|nil  either a quest array or { default = {...}, homebound = {...} }
--- @return table
local function resolveHomebound(source)
    if not source then return {} end
    -- If the source has a "default" key, it's a homebound-aware table
    if source.default then
        if HCE.IsHomeboundActive() and source.homebound then
            return source.homebound
        end
        return source.default
    end
    -- Otherwise it's a plain quest array
    return source
end

--- Get the resolved quest list for a character, handling faction and
--- homebound variants.
---
--- Supported data shapes:
---   char.quests = { Q(...), ... }                        -- simple
---   char.questsByHomebound = { default = {...}, homebound = {...} }
---   char.questsByFaction = { Alliance = {...}, Horde = {...} }
---   char.questsByFaction = { Alliance = { default = {...}, homebound = {...} },
---                            Horde   = { default = {...}, homebound = {...} } }
--- @param char table
--- @return table
function HCE.GetCharQuests(char)
    if char.questsByFaction then
        local faction = UnitFactionGroup("player")
        local factionQuests = char.questsByFaction[faction] or {}
        return resolveHomebound(factionQuests)
    end
    if char.questsByHomebound then
        return resolveHomebound(char.questsByHomebound)
    end
    return char.quests or {}
end

--- Get the display name for a character, handling faction variants.
--- @param char table
--- @return string
function HCE.GetCharDisplayName(char)
    if char.nameByFaction then
        local faction = UnitFactionGroup("player")
        return char.nameByFaction[faction] or char.name
    end
    return char.name
end

--- Get the quest theme for a character, handling faction variants.
--- @param char table
--- @return string|nil
function HCE.GetCharQuestTheme(char)
    if char.questThemeByFaction then
        local faction = UnitFactionGroup("player")
        return char.questThemeByFaction[faction] or char.questTheme
    end
    return char.questTheme
end

--- Get the resolved selfFound value for a character, handling faction variants.
--- Returns true, false, or nil.
--- @param char table
--- @return boolean|nil
function HCE.GetCharSelfFound(char)
    if char.selfFoundByFaction then
        local faction = UnitFactionGroup("player")
        return char.selfFoundByFaction[faction]
    end
    return char.selfFound
end

--- Get the active challenges for a character: non-optional challenges plus
--- the player's selected optional challenge (if any).
--- @param char table  character data table
--- @return table  array of { desc, level [, endLevel] } entries
function HCE.GetActiveChallenges(char)
    local active = {}
    -- Insert selected optional challenge first so it appears at the top
    local sel = HCE_CharDB and HCE_CharDB.selectedChallenge
    if sel and char.optionalChallenges then
        for _, ch in ipairs(char.optionalChallenges) do
            if ch.desc == sel then
                table.insert(active, ch)
                break
            end
        end
    end
    -- Then append the non-optional challenges
    for _, ch in ipairs(char.challenges or {}) do
        table.insert(active, ch)
    end
    return active
end
