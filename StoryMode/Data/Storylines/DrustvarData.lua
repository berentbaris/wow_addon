local addonName, SM = ...

-- =============================================================================
-- Battle for Azeroth: Drustvar — The Heartsbane Coven
-- Zone Storyline: "Drust Do It." (Achievement 12497)
-- =============================================================================

SM.DrustvarData = {
    title = "The Witchwood of Drustvar",
    achievementName = "Drust Do It.",
    achievements = {
        12497,  -- Drust Do It. (Drustvar zone story)
        "Explore Drustvar",
        -- Waycrest Manor
        12483,  -- Waycrest Manor (Normal)
        12783,  -- Gorak Tul kills (Normal Waycrest Manor)
    },
    description = "A dark curse has fallen over Drustvar. Lord Waycrest has vanished, his lady has withdrawn behind manor walls, and old stories about witches have begun walking through the woods again.\n\nJoin Lucille Waycrest and the Order of Embers as they follow the coven's trail through cursed villages, haunted fens, and a land where buried grudges have a way of clawing back to the surface.",
    zone = "Drustvar",
    expansion = "Battle for Azeroth",
    faction = "Alliance",
    color = { 0.55, 0.20, 0.55 },  -- Dark witch purple
    factions = { 2161 }, -- Order of Embers
    adventureGuideInstanceName = "Waycrest Manor",

    startQuest = { id = 48622, name = "The Vanishing Lord", npc = "Taelia", location = "Boralus" },
    startMapID = 895,
    startX = 0.3380,
    startY = 0.3050,

    npcLocations = {
        ["Taelia"]                      = { mapID = 1161, x = 0.6800, y = 0.2200 },
        ["Cyril White"]                 = { mapID = 896, x = 0.5580, y = 0.3500 },
        ["Lucille Waycrest"]            = { mapID = 896, x = 0.3500, y = 0.3100 },
        ["Marshal Everit Reade"]        = { mapID = 896, x = 0.3100, y = 0.2020 },
        ["Inquisitor Sterntide"]        = { mapID = 896, x = 0.3060, y = 0.2160 },
        ["Inquisitor Cleardawn"]        = { mapID = 896, x = 0.2500, y = 0.6400 },
        ["Inquisitor Notley"]           = { mapID = 896, x = 0.2900, y = 0.3900 },
        ["Evelyn Pare"]                 = { mapID = 896, x = 0.7000, y = 0.6020 },
        ["Warren Ashton"]               = { mapID = 896, x = 0.2060, y = 0.5740 },
        ["Angus Ballaster"]             = { mapID = 896, x = 0.2800, y = 0.4000 },
        ["Marten Webb"]                 = { mapID = 896, x = 0.2060, y = 0.5720 },
        ["Helena Gentle"]               = { mapID = 896, x = 0.6040, y = 0.3160 },
        ["Fallhaven Villager"]          = { mapID = 896, x = 0.6080, y = 0.3060 },
        ["Constable Henry Framer"]      = { mapID = 896, x = 0.7000, y = 0.4280 },
        ["Captain Lilian Nottley"]      = { mapID = 896, x = 0.3960, y = 0.5800 },
        ["Captive Villager"]            = { mapID = 896, x = 0.2620, y = 0.6640 },
        ["Samantha Sweet"]              = { mapID = 896, x = 0.2120, y = 0.5520 },
    },

    npcDisplayIDs = {
        ["Taelia"]                      = 81291,
        ["Cyril White"]                 = 77992,
        ["Lucille Waycrest"]            = 78452,
        ["Marshal Everit Reade"]        = 76670,
        ["Inquisitor Sterntide"]        = 81608,
        ["Inquisitor Cleardawn"]        = 81606,
        ["Inquisitor Notley"]           = 81604,
        ["Evelyn Pare"]                 = 78861,
        ["Warren Ashton"]               = 82701,
        ["Angus Ballaster"]             = 82283,
        ["Marten Webb"]                 = 81831,
    },

    -- =========================================================================
    -- Main storyline chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: The Final Effigy
        {
            chapter = "The Final Effigy",
            summary = "Lord Waycrest has vanished and a curse grips the village of Fallhaven. Lucille Waycrest enlists your help to hunt the witches responsible.",
            recap = "Taelia sent you to Drustvar, where Lord Waycrest had vanished and a dark curse was spreading. In Fallhaven, Cyril White led you through the signs of witchcraft — hexed villagers, twisted familiars, and effigies that pulsed with dark magic. You met Lucille Waycrest, the lord's daughter, who refused to sit idle while her land rotted. Together you hunted the witches through Fallhaven, cracking their curses and burning their effigies. The final effigy crumbled, but the witches' power ran far deeper than one village.",
            quests = {
                { id = 48622, name = "The Vanishing Lord",          npc = "Taelia" },
                { id = 47968, name = "Signs and Portents",          npc = "Cyril White" },
                { id = 47978, name = "The Wayward Crone",           npc = "Cyril White" },
                { id = 47979, name = "Witch Hunt",                  npc = "Helena Gentle" },
                { id = 47980, name = "Furious Familiars",           npc = "Fallhaven Villager" },
                { id = 47981, name = "Cracking the Curse",          npc = "Lucille Waycrest" },
                { id = 47982, name = "The Final Effigy",            npc = "Lucille Waycrest" },
            },
        },

        -- CHAPTER 2: The Burden of Proof
        {
            chapter = "The Burden of Proof",
            summary = "Lucille stands accused of witchcraft herself. Marshal Reade demands proof of her innocence through superstitious trials.",
            recap = "The witch hunt turned on Lucille herself — Marshal Everit Reade accused the Waycrest daughter of sorcery. In a land gripped by paranoid suspicion, even nobility was not above the trials. You gathered proof of Lucille's innocence through the marshal's superstitious tests: walking through the woods that watched, enduring ambush, and passing the trial by superstition. A pungent alchemical solution revealed the true witches hiding in plain sight. The burden of proof was met, but the experience left its mark — in Drustvar, trust was a luxury no one could afford.",
            quests = {
                { id = 48108, name = "The Waycrest Daughter",       npc = "Cyril White" },
                { id = 48283, name = "Standing Accused",            npc = "Constable Henry Framer" },
                { id = 48109, name = "The Woods Have Eyes",          npc = "Marshal Everit Reade" },
                { id = 48110, name = "In Case of Ambush",           npc = "Marshal Everit Reade" },
                { id = 48111, name = "Trial by Superstition",       npc = "Lucille Waycrest", mapID = 896, x = 0.7000, y = 0.4280, location = "Drustvar" },
                { id = 48113, name = "A Pungent Solution",          npc = "Lucille Waycrest" },
                { id = 48170, name = "Once Bitten, Twice Shy",      npc = "Lucille Waycrest" },
                { id = 48165, name = "Harmful If Swallowed",        npc = "Lucille Waycrest" },
                { id = 48198, name = "The Burden of Proof",         npc = "Lucille Waycrest" },
            },
        },

        -- CHAPTER 3: An Airtight Alibi
        {
            chapter = "An Airtight Alibi",
            summary = "Fletcher's Hollow is cursed — villagers turned to wicker constructs. Track the three witch sisters responsible and expose their matron.",
            recap = "Fletcher's Hollow was worse than Fallhaven. The curse here had turned villagers into wicker constructs — living husks of thorns and hatred. Lucille led you through the ruins, saving who you could and putting down those beyond help. The trail pointed to three witch sisters working in concert. You charmed the lifeless, followed a revealing missive, and tracked the murderous matron to her lair. With the coven cell destroyed and an airtight alibi for who was truly behind the corruption, the pattern became clear — this was no scattered curse. It was organized. It was a war.",
            quests = {
                { id = 48171, name = "The Curse of Fletcher's Hollow", npc = "Lucille Waycrest", mapID = 896, x = 0.7000, y = 0.4280, location = "Drustvar" },
                { id = 48518, name = "Save Who We Can",             npc = "Evelyn Pare" },
                { id = 49295, name = "Clear-Cutting",               npc = "Evelyn Pare" },
                { id = 48519, name = "Hope They Can't Swim",        npc = "Evelyn Pare" },
                { id = 48520, name = "The Three Sisters",           npc = "Evelyn Pare" },
                { id = 48521, name = "Charming the Lifeless",       npc = "Lucille Waycrest" },
                { id = 48522, name = "A Revealing Missive",         npc = "Lucille Waycrest" },
                { id = 48523, name = "The Murderous Matron",        npc = "Evelyn Pare" },
                { id = 48524, name = "Culling the Coven",           npc = "Evelyn Pare" },
                { id = 48538, name = "An Airtight Alibi",           npc = "Evelyn Pare" },
            },
        },

        -- CHAPTER 4: The Order of Embers
        {
            chapter = "The Order of Embers",
            summary = "In ancient Drust ruins, Lucille discovers the Order of Embers — an old organization of witch hunters. She vows to rebuild it.",
            recap = "Lucille realized that scattered witch hunting would never be enough. A slight detour through the mountains — past yetis and salvaged supplies — led to the ruins of Gol Var, where ancient bones whispered of the Order of Embers. Centuries ago, the Order had been Drustvar's shield against the Drust and their dark magic. Lucille read the histories carved in stone and rune-etched bone, and made her decision: the Order of Embers would rise again. She would lead it, and you would be her blade.",
            quests = {
                { id = 49259, name = "And Justice For All",          npc = "Lucille Waycrest" },
                { id = 48941, name = "A Slight Detour",             npc = "Lucille Waycrest" },
                { id = 48942, name = "Yeti to Rumble",              npc = "Lucille Waycrest" },
                { id = 48943, name = "Salvage Rights",              npc = "Lucille Waycrest" },
                { id = 48963, name = "Diversionary Tactics",        npc = "Lucille Waycrest" },
                { id = 48944, name = "Unlocking History",           npc = "Lucille Waycrest" },
                { id = 48945, name = "The Ruins of Gol Var",        npc = "Lucille Waycrest" },
                { id = 48946, name = "The Order of Embers",         npc = "Lucille Waycrest" },
            },
        },

        -- CHAPTER 5: A New Order
        {
            chapter = "A New Order",
            summary = "At Arom's Stand, recruit and train the first new Inquisitors. Learn the old ways of witch hunting — silver, fire, and sharp thinking.",
            recap = "Arom's Stand became the Order's new headquarters. Inquisitor Sterntide — one of the few who still remembered the old ways — gave you a crash course in witch hunting: silver weapons for the cursed, fire for the wicker, and sharp thinking for the witches themselves. You rooted out hidden dealings in the camp, exposed infiltrators wearing friendly faces, and trained new guards to replace the corrupted ones. When Lucille raised the Order's banner over Arom's Stand, the message was clear — the witches had hunted long enough. Now they were the prey.",
            quests = {
                { id = 48986, name = "Take the High Road",          npc = "Lucille Waycrest" },
                { id = 49443, name = "A Lesson in Witch Hunting",   npc = "Lucille Waycrest", mapID = 896, x = 0.3680, y = 0.5000, location = "Drustvar" },
                { id = 49804, name = "Sharp Thinking",              npc = "Lucille Waycrest", mapID = 896, x = 0.3680, y = 0.5000, location = "Drustvar" },
                { id = 49803, name = "Changing of the Guard",       npc = "Marshal Everit Reade", mapID = 896, x = 0.3680, y = 0.5000, location = "Drustvar" },
                { id = 49805, name = "Implements of Ill Intent",    npc = "Inquisitor Sterntide" },
                { id = 49806, name = "Hidden Dealings",             npc = "Inquisitor Sterntide" },
                { id = 49807, name = "A New Order",                 npc = "Lucille Waycrest" },
            },
        },

        -- CHAPTER 6: Drustfall (Southern Path)
        {
            chapter = "Drustfall",
            summary = "Inquisitor Cleardawn leads the southern campaign through the old roads, clearing Drust strongholds along the way.",
            recap = "Inquisitor Cleardawn took command of the southern front. Through the old roads you marched — ancient paths the Drust had walked millennia before. The pieces of history you uncovered told a chilling story: the Drust had not simply been defeated in the past. They had been driven into hiding, and they had been waiting. You gave their soldiers an honorable discharge — the permanent kind — and pushed through to a clear victory. But the Drust ruins at Gol Osigr loomed ahead, and the fall of the Drust was far from over.",
            quests = {
                { id = 48504, name = "Through the Old Roads",       npc = "Inquisitor Cleardawn" },
                { id = 48184, name = "Pieces of History",           npc = "Inquisitor Cleardawn" },
                { id = 48517, name = "Honorable Discharge",         npc = "Inquisitor Cleardawn" },
                { id = 49898, name = "Clear Victory",               npc = "Captain Lilian Nottley" },
                { id = 49890, name = "Drustfall",                   npc = "Inquisitor Cleardawn" },
            },
        },

        -- CHAPTER 7: Fighting With Fire
        {
            chapter = "Fighting With Fire",
            summary = "Falconhurst is under siege. Break the hag's hold on the village, forge weapons of old, and learn to fight the Drust with fire.",
            recap = "Falconhurst was overrun — a hag had enslaved the village, and wicker monsters patrolled the streets. Inquisitor Cleardawn led the charge: you broke the hag's spell, freed the villagers, and held the barricade against waves of cursed attackers. Warren Ashton, the village blacksmith, remembered the old ways — weapons of silver and iron, blessed in ember. You forged an arsenal from his teachings and learned the most important lesson of all: the Drust feared fire. With blessed blades and burning brands, you were ready for the Crimsonwood.",
            quests = {
                { id = 49896, name = "To Falconhurst!",             npc = "Inquisitor Cleardawn" },
                { id = 50001, name = "Breaking Hag",                npc = "Inquisitor Cleardawn" },
                { id = 50251, name = "Spell Bound",                 npc = "Captive Villager" },
                { id = 50177, name = "Hold The Barricade!",         npc = "Inquisitor Cleardawn" },
                { id = 49939, name = "So Long, Sister",             npc = "Inquisitor Cleardawn" },
                { id = 50036, name = "A Weapon of Old",             npc = "Warren Ashton" },
                { id = 50063, name = "Fighting With Fire",          npc = "Warren Ashton" },
            },
        },

        -- CHAPTER 8: Stick It To 'Em!
        {
            chapter = "Stick It To 'Em!",
            summary = "Enter the Crimsonwood, face Gorak Tul's grand rite, and drive a stake into the heart of the Drust king's power.",
            recap = "The Crimsonwood was the Drust king's domain — a forest so thick with dark magic that the trees themselves attacked. You saved Master Ashton from the thorns, gathered what you needed from the cursed woods, and went deeper. Inquisitor Cleardawn never flinched as you faced the matrons of the Crimsonwood one by one. At the heart of it all stood Gorak Tul's hall, where the grand rite would have brought the Drust back in full force. You stopped it — barely — and stuck the embers into the heart of his power. Gorak Tul retreated, wounded but not destroyed. Lucille was waiting.",
            quests = {
                { id = 50172, name = "Into the Crimsonwood",        npc = "Inquisitor Cleardawn" },
                { id = 50265, name = "Saving Master Ashton",        npc = "Inquisitor Cleardawn" },
                { id = 50306, name = "Odds and Ends",               npc = "Marten Webb" },
                { id = 50266, name = "Bittersweet",                 npc = "Samantha Sweet" },
                { id = 50370, name = "Deeper into the Woods",       npc = "Inquisitor Cleardawn" },
                { id = 50325, name = "Stopping the Grand Rite",     npc = "Inquisitor Cleardawn" },
                { id = 50445, name = "Controlling the Situation",    npc = "Warren Ashton" },
                { id = 50329, name = "Matrons of the Crimsonwood",  npc = "Warren Ashton" },
                { id = 50481, name = "In the Hall of the Drust King", npc = "Inquisitor Cleardawn" },
                { id = 50533, name = "Stick It To 'Em!",            npc = "Lucille Waycrest" },
            },
        },

        -- CHAPTER 9: Break On Through
        {
            chapter = "Break On Through",
            summary = "March on Corlain, the seat of House Waycrest. Forge an arsenal of witchrending weapons and break through the coven's magical barrier.",
            recap = "With the south secured, Marshal Reade led the march on Corlain — the ancestral seat of House Waycrest, now a fortress of the Heartsbane Coven. The first watch was grim: the town was sealed behind a magical barrier that killed anything that touched it. Inquisitor Notley scouted the approach while you gathered precious metals and crafted an improvised arsenal of witchrending weapons. Lucille herself struck the final blow against the barrier, shattering it with the Order's combined power. The road to Waycrest Manor was open.",
            quests = {
                { id = 49926, name = "The Road to Corlain",         npc = "Marshal Everit Reade" },
                { id = 50003, name = "The First Watch",             npc = "Marshal Everit Reade" },
                { id = 50149, name = "A Weather Eye",               npc = "Marshal Everit Reade" },
                { id = 50151, name = "A Steady Ballast",            npc = "Marshal Everit Reade" },
                { id = 50173, name = "Precious Metals",             npc = "Lucille Waycrest", mapID = 896, x = 0.3140, y = 0.3020, location = "Drustvar" },
                { id = 50253, name = "An Improvised Arsenal",       npc = "Lucille Waycrest", mapID = 896, x = 0.3140, y = 0.3020, location = "Drustvar" },
                { id = 50446, name = "Witchrending",                npc = "Lucille Waycrest" },
                { id = 50453, name = "Barrier Buster",              npc = "Angus Ballaster" },
                { id = 50457, name = "Break On Through",            npc = "Inquisitor Sterntide" },
            },
        },

        -- CHAPTER 10: Storming the Manor
        {
            chapter = "Storming the Manor",
            summary = "Fight through cursed Corlain, storm Waycrest Manor, and confront Lady Waycrest and Gorak Tul in the dungeon's depths.",
            recap = "Corlain was a nightmare — hexed citizens wandered the streets, ruinous rituals played out in every alley, and the coven's strongest witches guarded the approach to the manor. You cut through them all. Lucille led the final charge to the gates of Waycrest Manor itself, where her mother — Lady Waycrest, consumed by Gorak Tul's power — waited in the depths. In the dungeon beneath the manor, you faced the fallen mother and broke the Drust king's hold on her. The curse over Drustvar shattered like glass. Lucille knelt beside her mother's body, the heir of a house that would rebuild. The witchwood was silent at last.",
            quests = {
                { id = 50583, name = "To the Other Side",           npc = "Lucille Waycrest" },
                { id = 50585, name = "Hexecutioner",                npc = "Marshal Everit Reade" },
                { id = 50584, name = "Ruinous Rituals",             npc = "Marshal Everit Reade" },
                { id = 50588, name = "Storming the Manor",          npc = "Lucille Waycrest" },
                { id = 50639, name = "Waycrest Manor: The Fallen Mother", npc = "Lucille Waycrest" },
                { id = 52149, name = "Everburning",                 npc = "Lucille Waycrest" },
                { id = 53109, name = "House Waycrest",              npc = "Lucille Waycrest" },
            },
        },
    },
}
