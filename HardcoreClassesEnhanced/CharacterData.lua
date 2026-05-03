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
    ["Diplomat"]        = "Must obtain another faction's mount before reaching 60",
    ["Renegade"]        = "Cannot equip quest reward gear",
    ["Aoe-farmer"]      = "Level mainly by aoe-farming in the open world",
    ["White knight"]    = "Can only equip white or grey gear",
    ["Partisan"]        = "Cannot equip looted gear",
    ["Drifter"]         = "Cannot use hearthstone or bank",
    ["Ephemeral"]       = "Cannot repair gear",
    ["Self-made"]       = "Can only equip self-crafted or white/grey items",
    ["Exotic"]          = "Cannot equip uncommon quality gear",
    ["Off-the-shelf"]   = "Can only equip gear sold by vendors",
    ["Faction leader"]  = "Become exalted with your own faction before reaching 60",
    ["Footman"]         = "Cannot equip rare or epic quality items",
    ["Grunt"]           = "Cannot equip rare or epic quality items",
    ["No professions"]  = "Cannot learn any professions",
    ["No demon"]        = "Cannot summon a demon pet",
    ["Mortal pets"]     = "Hunter pets that die stay dead — cannot revive or replace them",
    ["Cloth/leather"]   = "Can only wear cloth or leather armor",
    ["Mail/plate"]      = "Must wear mail or plate in all possible slots",
    ["Imp"]             = "Must always use the Imp as your demon pet",
    ["Self-made guns"]  = "Ranged weapon must be self-crafted via Engineering",
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
            E("Mace or axe", 1),
            E("Shield", 5),
            E("Flask trinkets", 50),
        },
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Beer, treasure",
    },

    ["Brewmaster"] = {
        class       = "WARRIOR",
        spec        = "Arms",
        name        = "Brewmaster",
        race        = "Tauren",
        gender      = "Male",
        selfFound   = true,
        professions = { "Alchemy", "Cooking" },
        challenges  = {
            E("Exotic", 1),
        },
        equipment   = {
            E("Staff", 1),
            E("Lunar festival suit", 10),
        },
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Drunk, darkmoon special",
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
        questTheme  = "Anti-demon",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-demon",
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
        challenges  = {
            E("Grunt", 1),
        },
        equipment   = {
            E("Dagger and sword", 10),
            E("Thrown", 10),
        },
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Thistle tea",
    },

    ["Warden"] = {
        class       = "ROGUE",
        spec        = "Combat",
        name        = "Warden",
        race        = "Night Elf",
        gender      = "Female",
        selfFound   = true,
        professions = {},
        challenges  = {
            E("Homebound", 1),
        },
        equipment   = {
            E("Swords", 1),
            E("Robe", 10),
            E("Thrown", 10),
        },
        companion   = E("Owl", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
    },

    ["Runemaster"] = {
        class       = "ROGUE",
        spec        = "Subtlety",
        name        = "Runemaster",
        race        = "Dwarf",
        gender      = "Male",
        selfFound   = false,
        professions = { "Enchanting" },
        challenges  = {
            E("Off-the-shelf", 1),
        },
        equipment   = {
            E("Fist weapons", 1),
            E("No chest", 1),
            E("Kilt", 25),
        },
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Self-made enchants, scrolls",
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
        challenges  = {
            E("Exotic", 1),
            E("Imp", 1),
        },
        equipment   = {
            E("No wands", 1),
            E("1.5 speed dagger", 15),
            E("Firestone", 25),
        },
        companion   = nil,
        pet         = nil,
        mount       = E("Wolf", 44),
        gameplay    = "Campfire, melee weaving dagger",
    },

    ["Death Knight"] = {
        class       = "WARLOCK",
        spec        = "Affliction",
        name        = "Death Knight",
        race        = "Undead",
        gender      = "Male",
        selfFound   = true,
        professions = { "Fishing" },
        challenges  = {
            E("No demon", 1),
        },
        equipment   = {
            E("No robes", 1),
            E("No wands", 1),
            E("Sword", 5, 43),
            E("Cowl", 25),
            E("Pole", 44),
            E("120 attack power", 50),
        },
        companion   = nil,
        pet         = nil,
        mount       = E("Skeletal horse", 44),
        gameplay    = "Melee weaving caster",
    },

    ["Shadowmage"] = {
        class       = "WARLOCK",
        spec        = "Demonology",
        name        = "Shadowmage",
        race        = "Gnome",
        gender      = "Female",
        selfFound   = true,
        professions = { "Tailoring" },
        challenges  = {
            E("Self-made", 1),
            E("Drifter", 1),
        },
        equipment   = {
            E("Robe", 1),
            E("Spellstone", 40),
        },
        companion   = E("Black cat", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
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
        challenges  = {
            E("Ephemeral", 1),
            E("Drifter", 1),
        },
        equipment   = {
            E("Armored off-hand", 25),
            E("Armored weapon", 35),
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
        gameplay    = "/roar, pro-nature",
    },

    ["Plagueshifter"] = {
        class       = "DRUID",
        spec        = "Restoration",
        name        = "Plagueshifter",
        race        = "Tauren",
        gender      = "Female",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Jungle remedy", 35),
        },
        challenges  = {
            E("Partisan", 1),
        },
        quests      = {
            Q("The Family Crypt", 13, 408),
            Q("Assault on Fenris Isle", 24, 442),
            Q("Mission Accomplished!", 58, 5237),
            Q("Hameya's Plea", 59, 6024),
        },
        questTheme  = "Purifier",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-undead",
    },

    ["Savagekin"] = {
        class       = "DRUID",
        spec        = "Balance",
        name        = "Savagekin",
        race        = "Tauren",
        gender      = "Male",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("180 intellect", 40),
            E("Armored ring", 45),
            E("250 intellect", 50),
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
            E("Gun", 1),
            E("Rapier, cutlass, or harpoon", 20),
            E("Captain's hat", 45),
        },
        challenges  = {
            E("Renegade", 1),
        },
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
            E("Anti-beast cloak", 20),
            E("Anti-beast gloves", 30),
            E("Anti-beast melee weapon", 35),
            E("Wolf helm", 45),
            E("Anti-beast ranged weapon", 50),
            E("No guns", 1),
        },
        challenges  = {
            E("Mortal pets", 1),
        },
        quests      = {
            Q("Isha Awak", 27, 873),
            Q("Big Game Hunter", 43, 208),
            Q("The Bait for Lar'korwi", 56, 4292),
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
            E("Gun", 1),
            E("2h axe", 1),
            E("Scope", 5),
        },
        challenges  = {
            E("Partisan", 1),
            E("Self-made guns", 1),
        },
        quests      = {
            Q("In Defense of the King's Lands", 17, 217),
            Q("Defeat Nek'rosh", 32, 474),
            Q("The Princess's Surprise", 59, 4363),
        },
        questTheme  = "Ironforge Loyalist",
        companion   = nil,
        pet         = E("Bear", 10),
        mount       = nil,
        gameplay    = "Hooded cloak",
    },

    ---------- SHAMAN ----------

    ["Spirit Champion"] = {
        class       = "SHAMAN",
        spec        = "Enhancement",
        name        = "Spirit Champion",
        race        = "Orc",
        gender      = "Any",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Shield", 5),
        },
        challenges  = {
            E("Exotic", 1),
        },
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "/sit and /meditate",
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
            E("Shell shield", 20),
            E("Voodoo mask", 45),
            E("Cursed amulet", 45),
        },
        challenges  = {
            E("Renegade", 1),
            E("Cloth/leather", 1),
        },
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = nil,
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
            E("1h axe", 5),
            E("Torch", 10),
        },
        challenges  = {
            E("Self-made", 1),
        },
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
            E("Partisan", 1),
            E("Mail/plate", 1),
        },
        quests      = {
            Q("Missing In Action", 25, 219),
            Q("The Missing Diplomat", 38, 1267),
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
        },
        quests      = {
            Q("Collecting Memories", 18, 168),
            Q("Bride of the Embalmer", 30, 253),
            Q("Mission Accomplished!", 58, 5238),
            Q("Hameya's Plea", 59, 6024),
        },
        questTheme  = "Purifier",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Anti-undead",
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
            E("Self-made", 1),
        },
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
        professions = { "Tailoring" },
        equipment   = {
            E("Robe", 1),
            E("180 spirit", 40),
            E("250 spirit", 50),
        },
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
            E("Dagger", 1),
            E("Robe", 1),
            E("Herb pouch", 10),
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
        },
        questTheme  = "Plague-brewer",
        companion   = E("Cockroach", 10),
        pet         = nil,
        mount       = nil,
        gameplay    = "Plague-brewer",
    },

    ["Shadow Hunter"] = {
        class       = "PRIEST",
        spec        = "Shadow",
        name        = "Shadow Hunter",
        race        = "Troll",
        gender      = "Any",
        selfFound   = true,
        professions = { "Fishing" },
        equipment   = {
            E("No robes", 1),
            E("No wands", 1),
            E("Staff", 5, 43),
            E("Pole", 44),
            E("Voodoo mask", 45),
            E("120 attack power", 50),
        },
        challenges  = {
            E("Faction leader", 59),
        },
        quests      = {
            Q("Zalazane", 10, 826),
            Q("Trol'kalar", 42, 646),
            Q("Saving Yenniku", 46, 592),
        },
        questTheme  = "Darkspear Loyalist",
        companion   = nil,
        pet         = nil,
        mount       = nil,
        gameplay    = "Melee weaving caster",
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
            E("Unholy weapon", 45),
        },
        challenges  = {
            E("White knight", 1),
            E("Drifter", 1),
        },
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
            E("Flying Tiger Goggles", 20, 29),
            E("Green-tinted goggles", 30, 39),
            E("Gnomish goggles", 40),
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
        companion   = E("Mechanical", 30),
        pet         = nil,
        mount       = nil,
        gameplay    = "Pyroblast + arcane missiles",
    },

    ["Warmage"] = {
        class       = "MAGE",
        spec        = "Frost",
        name        = "Warmage",
        race        = "Human",
        gender      = "Any",
        selfFound   = true,
        professions = {},
        equipment   = {
            E("Sword", 1),
            E("Staff-like off-hand", 5),
            E("Armored rings", 45),
        },
        challenges  = {
            E("Footman", 1),
        },
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

-- Precompute a normalised race field on each character
for _, char in pairs(HCE.Characters) do
    char.raceNorm = RACE_ALIASES[char.race] or char.race
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
            local raceOK   = (char.raceNorm == "Any") or (char.raceNorm == playerRace)
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
