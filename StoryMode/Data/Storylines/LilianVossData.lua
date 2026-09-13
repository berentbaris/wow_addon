local addonName, SM = ...

-- =============================================================================
-- Lilian Voss: The Forsaken Daughter
-- A saga spanning Cataclysm, Mists of Pandaria, Battle for Azeroth,
-- and Shadowlands — from Deathknell to the dungeons of the Scarlet Crusade
-- to the shores of Kul Tiras, to the ruins of Undercity, and finally home.
-- =============================================================================

SM.LilianVossData = {
    -- Questline metadata
    title = "The Forsaken Daughter",
    description = "Lilian Voss was raised by the Scarlet Crusade to hate the undead, and then she died, rose, and became one. Trained from childhood to purify the Forsaken, she wakes in Deathknell as the very thing her father taught her to burn.\n\nFollow her from the cellars of the Crusade through Scholomance and the politics of Lordaeron, where vengeance, identity, and belonging keep asking for different answers.",
    zone = "Tirisfal Glades / Kul Tiras / Lordaeron",
    expansion = "Cataclysm — Shadowlands",
    achievements = {
        -- The Scarlet Halls
        7413,   -- Scarlet Halls (Normal)
        -- The Scarlet Monastery
        637,    -- Scarlet Monastery (Normal)
        -- Scholomance
        645,    -- Scholomance (Normal)
        -- Battle for Azeroth — war campaign arc (covers all BfA chapters)
        12509,  -- Ready for War (complete the 8.0 Horde war campaign)
        13466,  -- Tides of Vengeance - Horde (complete the 8.1 war campaign, includes Testing Loyalties)
        13924,  -- The Fourth War (complete the full BfA war story)
        -- Shadowlands
        15579,  -- Return to Lordaeron (Forsaken heritage questline)
    },
    faction = "Horde",
    color = { 0.75, 0.12, 0.18 },  -- Scarlet Crusade crimson
    factions = { 68, 2157 }, -- Undercity, The Honorbound
    portraitDisplayID = 85799,  -- Lilian Voss (BfA model) as card portrait
    adventureGuideInstanceName = "Scarlet Monastery",

    -- Start location: Caretaker Caice in Deathknell
    startQuest = { id = 24960, name = "The Wakening", npc = "Caretaker Caice", location = "Deathknell, Tirisfal Glades" },
    startMapID = 18,    -- Tirisfal Glades
    startX = 0.3060,
    startY = 0.7140,

    -- Key NPC locations for waypoint guidance (mapID, x, y)
    npcLocations = {
        -- Tirisfal Glades
        ["Caretaker Caice"]           = { mapID = 18,  x = 0.3060, y = 0.7140 },
        ["Novice Elreth"]             = { mapID = 18,  x = 0.2780, y = 0.6760 },
        ["Deathguard Simmer"]         = { mapID = 18,  x = 0.4470, y = 0.5350 },
        ["Executor Zygand"]           = { mapID = 18,  x = 0.6040, y = 0.5180 },
        ["High Executor Derrington"]  = { mapID = 18,  x = 0.8320, y = 0.6900 },
        ["Lieutenant Sanders"]        = { mapID = 18,  x = 0.8740, y = 0.4320 },
        -- Dungeons (interior — coordinates not meaningful)
        ["Hooded Crusader"]           = { mapID = 18,  x = 0.8540, y = 0.3100 },
        ["Talking Skull"]             = { mapID = 18,  x = 0.4800, y = 0.8560 },
        -- BfA — Zuldazar / Kul Tiras
        ["Nathanos Blightcaller"]     = { mapID = 862, x = 0.5840, y = 0.6260, location = "Tirisfal Glades / Kul Tiras / Lordaeron" },
        ["Lilian Voss"]               = { mapID = 862, x = 0.5840, y = 0.6260, location = "Tirisfal Glades / Kul Tiras / Lordaeron" },
        ["Rexxar"]                    = { mapID = 942, x = 0.5200, y = 0.3360 },
        ["Thomas Zelling"]            = { mapID = 942, x = 0.5956, y = 0.3070 },
        -- BfA — At the Bottom of the Sea
        ["Dread-Admiral Tattersail"]  = { mapID = 862, x = 0.5620, y = 0.6480 , location = "Tirisfal Glades / Kul Tiras / Lordaeron"},  -- Banshee's Wail, Port of Zandalar
        ["Hobart Grapplehammer"]      = { mapID = 862, x = 0.4160, y = 0.6740 , location = "Tirisfal Glades / Kul Tiras / Lordaeron"},
        -- BfA — Strike on Boralus / Testing Loyalties
        ["Captain Amalia Stone"]      = { mapID = 862, x = 0.5620, y = 0.6480 , location = "Tirisfal Glades / Kul Tiras / Lordaeron"},  -- VERIFY: Banshee's Wail / Stormsong
        ["Baine Bloodhoof"]           = { mapID = 862, x = 0.7660, y = 0.4300 , location = "Tirisfal Glades / Kul Tiras / Lordaeron"},
        ["Sylvanas Windrunner"]       = { mapID = 862, x = 0.5840, y = 0.6260, location = "Tirisfal Glades / Kul Tiras / Lordaeron" },
        ["Derek Proudmoore"]          = { mapID = 862, x = 0.5840, y = 0.6260, location = "Tirisfal Glades / Kul Tiras / Lordaeron" },
        -- 9.2.5 — Return to Lordaeron (Brill / Ruins of Lordaeron, Tirisfal)
        ["Calia Menethil"]            = { mapID = 18,  x = 0.5670, y = 0.5910 },  -- Brill
        ["Master Apothecary Faranell"]= { mapID = 18,  x = 0.5990, y = 0.6400 , location = "Tirisfal Glades / Kul Tiras / Lordaeron"},  -- House of Plagues / Undercity ruins
        ["Dark Ranger Velonara"]      = { mapID = 18,  x = 0.5990, y = 0.6400, location = "Tirisfal Glades / Kul Tiras / Lordaeron" },
        ["Bluffwatcher Proudscar"] = { mapID = 1165, x = 0.4980, y = 0.9600, location = "Dazar'alor" },
        ["Boss Mida"] = { mapID = 942, x = 0.5100, y = 0.3280, location = "Stormsong Valley" },
        ["Valeera Sanguinar"] = { mapID = 84, x = 0.8480, y = 0.3400, location = "Stormwind City" },
        ["Margrave Sin'dane"] = { mapID = 1536, x = 0.7460, y = 0.3360, location = "Maldraxxus" },
        ["Plague Deviser Marileth"] = { mapID = 1536, x = 0.7100, y = 0.7140, location = "Maldraxxus" },
    },

    -- NPC creature display IDs for chapter portraits
    -- Used with SetPortraitTextureFromCreatureDisplayID()
    -- Look up on wowhead.com model viewer or /run print(UnitCreatureDisplayID("target"))
    npcDisplayIDs = {
        -- Tirisfal Glades NPCs
        ["Caretaker Caice"]             = 3522,
        ["Novice Elreth"]               = 1593,
        ["Deathguard Simmer"]           = 1648,
        ["Executor Zygand"]             = 1649,
        ["High Executor Derrington"]    = 10150,
        ["Lieutenant Sanders"]          = 13090,
        -- Dungeon NPCs
        ["Hooded Crusader"]             = 43650,   -- Lilian in disguise
        ["Talking Skull"]               = 40322,
        -- BfA NPCs
        ["Lilian Voss"]                 = 67721,
        ["Nathanos Blightcaller"]       = 86219,
        ["Rexxar"]                      = 60766,
        ["Thomas Zelling"]              = 86134,
        ["Dread-Admiral Tattersail"]    = 64374,   -- VERIFY
        ["Hobart Grapplehammer"]        = 92727,   -- VERIFY: goblin tinker model
        ["Captain Amalia Stone"]        = 86073,   -- VERIFY
        ["Baine Bloodhoof"]             = 30272,   -- VERIFY: BfA Baine model
        ["Sylvanas Windrunner"]         = 102134,
        ["Derek Proudmoore"]            = 86396,   -- VERIFY: undead Derek model
        -- 9.2.5 NPCs
        ["Calia Menethil"]              = 67797,
        ["Master Apothecary Faranell"]  = 90372,   -- VERIFY
        ["Dark Ranger Velonara"]        = 105389,   -- VERIFY
    },
    chapterDisplayIDs = {
        ["The Wakening"]                  = 67721,  -- Lilian Voss
        ["What Comes After"]             = 85799,  -- Lilian Voss (BfA model)
    },
    chapterIcons = {
        ["The Wakening"] = 67721,
    },

    -- =========================================================================
    -- ACT I — TIRISFAL GLADES (Cataclysm)
    -- A daughter of the Scarlet Crusade is raised as the thing she was
    -- trained to destroy.
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Raised against her will
        {
            chapter = "The Wakening",
            summary = "The Val'kyr raise new Forsaken in the crypt of Deathknell. One of them is Lilian Voss — daughter of the Scarlet Crusade's High Priest, raised as the very thing she was trained to destroy.",
            recap = "You opened your eyes in the crypt of Deathknell, raised by the Val'kyr as one of the Forsaken. Among the newly risen was a young woman trembling with rage — Lilian Voss, daughter of the Scarlet Crusade's High Priest. While you accepted your new existence, she could not. She fled into the darkness, refusing to believe what she had become.",
            quests = {
                { id = 24960, name = "The Wakening",           npc = "Caretaker Caice" },
                { id = 24961, name = "The Truth of the Grave",  npc = "Novice Elreth" },
            },
        },

        -- CHAPTER 2: First contact with the Scarlet Crusade
        {
            chapter = "A Scarlet Letter",
            summary = "The Forsaken push into the farmlands of Tirisfal, where the Scarlet Crusade holds a fortified palisade. Someone from Deathknell has gone missing.",
            recap = "Pushing through the farmlands around Deathknell, you clashed with the Scarlet Crusade at their palisade. Inside the fortifications you found Lilian — captured by the zealots she once served. Her captors didn't care that she had been one of them. To the Crusade, she was just another undead abomination to be purged.",
            quests = {
                { id = 24978, name = "Reaping the Reapers",    npc = "Deathguard Simmer" },
                { id = 24979, name = "A Scarlet Letter",        npc = "Deathguard Simmer" },
                { id = 24980, name = "The Scarlet Palisade",    npc = "Deathguard Simmer" },
                { id = 24981, name = "A Thorn in Our Side",     npc = "Executor Zygand" },
            },
        },

        -- CHAPTER 3: Father and daughter, one last time
        {
            chapter = "A Daughter's Embrace",
            summary = "The trail leads to Crusader's Run and the tower of High Priest Benedictus Voss. A daughter has come a long way to find her father — and what he says to her will determine everything.",
            recap = "Something broke inside Lilian Voss. Shadow magic erupted from her hands as she tore through the crusaders with a fury that terrified even the Forsaken. She marched to the tower where her father, High Priest Benedictus Voss, waited — and when he condemned her as a monster, she killed him. Then she vanished, leaving nothing but silence and the smell of burning.",
            quests = {
                { id = 25009, name = "At War With The Scarlet Crusade", npc = "High Executor Derrington" },
                { id = 25010, name = "A Deadly New Ally",               npc = "High Executor Derrington" },
                { id = 25046, name = "A Daughter's Embrace",            npc = "Lieutenant Sanders" },
            },
        },

        -- =====================================================================
        -- ACT II — SCARLET HALLS, MONASTERY & SCHOLOMANCE (Mists of Pandaria)
        -- Lilian returns as a hooded infiltrator, hunting the Crusade's
        -- remnants through their own strongholds.
        -- =====================================================================

        -- CHAPTER 4: Infiltrating the Scarlet Halls
        {
            chapter = "The Scarlet Halls",
            summary = "A hooded figure is paying coin inside the Scarlet Halls — silver for Scarlet blood. She wants their membership records. She calls herself the Hooded Crusader, and she is very thorough.",
            recap = "Years passed before Lilian surfaced again — this time as a hooded figure lurking inside the Scarlet Halls. She hired you to slaughter your way through the Crusade's ranks and steal their membership records. Every name on that list was a target. Lilian Voss was no longer running from the Crusade — she was hunting them down, one by one.",
            quests = {
                { id = 31490, name = "Rank and File",                    npc = "Hooded Crusader" },
                { id = 31493, name = "Just for Safekeeping, Of Course",  npc = "Hooded Crusader" },
            },
        },

        -- CHAPTER 5: Destroying the Scarlet Monastery
        {
            chapter = "The Scarlet Monastery",
            summary = "The Hooded Crusader's campaign reaches the Scarlet Monastery. Two blessed blades rest within its halls — consecrated weapons anointed to destroy the undead. High Inquisitor Whitemane commands everything inside.",
            recap = "The Hooded Crusader's campaign reached the Scarlet Monastery itself. You retrieved the blessed blades of the Anointed — weapons consecrated to destroy the undead — and drove them into High Inquisitor Whitemane. The irony was not lost on Lilian: the Crusade's holiest weapons, wielded by the dead, against the Crusade's own champion.",
            quests = {
                { id = 31513, name = "Blades of the Anointed",           npc = "Hooded Crusader" },
                { id = 31514, name = "Unto Dust Thou Shalt Return",      npc = "Hooded Crusader" },
            },
        },

        -- CHAPTER 6: Scholomance — consumed by vengeance
        {
            chapter = "Scholomance",
            summary = "Lilian's hunt for dark knowledge leads her into the cursed academy of Scholomance. Within its halls she confronts Darkmaster Gandling — but the darkness she wields threatens to consume her entirely. She must destroy the forbidden tomes and end the suffering, or become the very evil she hunts.",
            recap = "Lilian's pursuit of power led her into Scholomance, the cursed academy of necromancy. Through a talking skull she guided you to destroy the Four Tomes of forbidden knowledge and end the suffering within those walls. But when she faced Darkmaster Gandling, the darkness she wielded nearly consumed her. She survived — but the line between hunter and monster grew thinner.",
            quests = {
                { id = 31440, name = "The Four Tomes",                   npc = "Talking Skull" },
                { id = 31447, name = "An End to the Suffering",          npc = "Talking Skull" },
            },
        },

        -- =====================================================================
        -- ACT III — HORDE WAR CAMPAIGN (Battle for Azeroth)
        -- Years later. Lilian serves the Horde on the shores of Kul Tiras,
        -- but the war forces her to confront what it means to be Forsaken.
        -- =====================================================================

        -- CHAPTER 7: Tiragarde Sound — The First Assault
        {
            chapter = "The First Assault",
            gated = true,
            note = "Complete the Horde War Campaign introduction and travel to Zuldazar to unlock this chapter.",
            summary = "Nathanos Blightcaller and Lilian Voss lead a covert strike into the heart of Tiragarde Sound. While Nathanos secures the mountain outpost, Lilian takes command of the Bridgeport operation — sabotaging Ashvane foundries, planting explosives, and riding through the chaos she created.",
            recap = "Years later, Lilian served the Horde on the shores of Kul Tiras. While Nathanos Blightcaller secured a mountain outpost, Lilian led you through Bridgeport — sabotaging foundries, planting explosives, and riding through the flames of your own making. She was efficient, ruthless, and completely in her element. The girl who once trembled in Deathknell was gone.",
            quests = {
                { id = 51589, name = "Breaking Kul Tiran Will",          npc = "Nathanos Blightcaller" },
                { id = 51590, name = "Into the Heart of Tiragarde",      npc = "Nathanos Blightcaller" },
                { id = 51591, name = "Our Mountain Now",                  npc = "Nathanos Blightcaller" },
                { id = 51592, name = "Making Ourselves at Home",          npc = "Nathanos Blightcaller" },
                { id = 51593, name = "Bridgeport Investigation",          npc = "Lilian Voss" },
                { id = 51594, name = "Explosives in the Foundry",         npc = "Lilian Voss" },
                { id = 51595, name = "Explosivity",                       npc = "Lilian Voss" },
                { id = 51596, name = "Ammunition Acquisition",            npc = "Lilian Voss" },
                { id = 51597, name = "Gunpowder Research",                npc = "Lilian Voss" },
                { id = 51598, name = "A Bit of Chaos",                    npc = "Lilian Voss" },
                { id = 51599, name = "Death Trap",                        npc = "Lilian Voss" },
                { id = 51601, name = "The Bridgeport Ride",               npc = "Lilian Voss" },
            },
        },

        -- CHAPTER 8: Drustvar — The Marshal's Grave
        {
            chapter = "The Marshal's Grave",
            summary = "The graveyards of Drustvar hold fallen Kul Tiran war heroes — soldiers too valuable to leave buried. Nathanos leads the expedition to unearth Marshal M. Valentine, while Lilian questions what separates the Horde's methods from the horrors she once suffered at the hands of the Scarlet Crusade.",
            recap = "Nathanos led an expedition to dig up a fallen Kul Tiran war hero for resurrection. As you searched the graveyards of Drustvar, Lilian grew quiet. Unearthing the dead, raising them against their will — it was exactly what had been done to her. She carried out her orders, but the questions in her eyes said everything her lips would not.",
            quests = {
                { id = 51784, name = "A Stroll Through a Cemetery",           npc = "Nathanos Blightcaller" },
                { id = 53065, name = "Operation: Grave Digger",               npc = "Nathanos Blightcaller", optional = true },
                { id = 51785, name = "Examining the Epitaphs",                npc = "Nathanos Blightcaller" },
                { id = 51786, name = "State of Unrest",                       npc = "Nathanos Blightcaller" },
                { id = 51787, name = "Our Lot in Life",                       npc = "Lilian Voss" },
                { id = 51788, name = "The Crypt Keeper",                      npc = "Nathanos Blightcaller" },
                { id = 51789, name = "What Remains of Marshal M. Valentine",  npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 9: Stormsong Valley — Death of a Tidesage
        {
            chapter = "Death of a Tidesage",
            summary = "The Horde needs a tidesage's power over the sea. Lilian and Rexxar track one down in Stormsong Valley — Thomas Zelling, a dying man willing to trade his humanity for a few more years with his family. When the ritual is done, Lilian must watch Zelling's wife recoil from the husband she no longer recognizes. The scene is painfully familiar.",
            recap = "Thomas Zelling was a dying tidesage who traded his humanity for undeath, desperate for a few more years with his family. You and Lilian performed the ritual that raised him — and then watched his wife recoil in horror from the husband she no longer recognized. Lilian stood in silence as the scene played out, seeing her own story reflected in Zelling's shattered face. To be Forsaken, she finally understood, was not just a curse of the body.",
            quests = {
                { id = 51797, name = "Tracking Tidesages",               npc = "Nathanos Blightcaller" },
                { id = 53066, name = "Operation: Water Wise",            npc = "Nathanos Blightcaller", optional = true },
                { id = 51798, name = "No Price Too High",                npc = "Rexxar" },
                { id = 51805, name = "They Will Know Fear",              npc = "Lilian Voss" },
                { id = 51818, name = "Commander and Captain",            npc = "Thomas Zelling" },
                { id = 51819, name = "Scattering Our Enemies",           npc = "Rexxar" },
                { id = 51830, name = "Zelling's Potential",              npc = "Thomas Zelling" },
                { id = 51837, name = "Whatever Will Be",                 npc = "Lilian Voss" },
                { id = 52122, name = "To Be Forsaken",                   npc = "Lilian Voss" },
            },
        },

        -- =====================================================================
        -- ACT IV — THE PROUDMOORE AFFAIR (Battle for Azeroth 8.1)
        -- The war delivers a prize: a Proudmoore heir, drowned and waiting.
        -- Sylvanas sees a weapon. Lilian sees a mirror.
        -- =====================================================================

        -- CHAPTER 10: At the Bottom of the Sea
        {
            chapter = "At the Bottom of the Sea",
            gated = true,
            note = "Complete the Horde War Campaign through Stormsong Valley to unlock this chapter.",
            summary = "The Horde's war at sea claims a significant prize: Derek Proudmoore, son of the Lord Admiral, goes down with his ship in the waters off Kul Tiras. Hobart Grapplehammer equips you with experimental diving gear as Dread-Admiral Tattersail leads the expedition into the deep. What Sylvanas intends to do with the body is not yet spoken aloud — but the silence on the ship ride home says enough.",
            recap = "The war at sea gave the Horde what blades on land could not: Derek Proudmoore, heir to Kul Tiras, dead at the bottom of the ocean. Hobart Grapplehammer put you in a diving suit and you went down. The ocean floor was littered with the wreckage of the battle — dog tags, sunken ships, the bones of sailors on both sides. You found Derek and hauled him up. No one said what Sylvanas would do with him. No one had to.",
            quests = {
                { id = 52764, name = "Journey to the Middle of Nowhere", npc = "Nathanos Blightcaller" },
                { id = 53067, name = "Operation: Bottom Feeder",         npc = "Nathanos Blightcaller", optional = true },
                { id = 52765, name = "Deep Dive",                        npc = "Nathanos Blightcaller" },
                { id = 52766, name = "Seafloor Shipwreck",               npc = "Hobart Grapplehammer" },
                { id = 52767, name = "Checking Dog Tags",                npc = "Hobart Grapplehammer" },
                { id = 52768, name = "The Sunken Graveyard",             npc = "Hobart Grapplehammer" },
                { id = 52769, name = "Captain By Captain",               npc = "Hobart Grapplehammer" },
                { id = 52770, name = "Biolumi-Nuisance",                 npc = "Hobart Grapplehammer" },
                { id = 52772, name = "The Undersea Ledge",               npc = "Hobart Grapplehammer" },
                { id = 52773, name = "Water-Breathing Dragon",           npc = "Hobart Grapplehammer" },
                { id = 52774, name = "Grab and Go",                      npc = "Hobart Grapplehammer" },
                { id = 53121, name = "Siege of Boralus",                 npc = "Lilian Voss", optional = true },
                { id = 52978, name = "With Prince in Tow",               npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 11: The Strike on Boralus
        {
            chapter = "The Strike on Boralus",
            summary = "Derek Proudmoore's body is put to use before Lilian ever gets her orders: the Horde deploys him as bait to draw Kul Tiran warships away from Boralus, then drives a strike force into Stormsong Monastery to seize the Abyssal Scepter. Thomas Zelling — raised against his will just weeks ago — now fights for the Horde from inside the monastery walls. Lilian watches what the war makes of people.",
            recap = "Derek Proudmoore had barely been hauled out of the sea before Sylvanas found a use for him — not as a weapon yet, but as bait. The Kul Tiran fleet chased his ghost while you and Nathanos hit Stormsong Monastery. Thomas Zelling, the tidesage whose raising Lilian had stood witness to, guided you from inside. He was doing what he was told. So was she. The Horde got its scepter. Lilian got her champion tabard. No one asked if any of it was right.",
            quests = {
                { id = 52183, name = "When a Plan Comes Together",       npc = "Nathanos Blightcaller" },
                { id = 53068, name = "Operation: Hook and Line",         npc = "Nathanos Blightcaller", optional = true },
                { id = 52186, name = "The Bulk of the Guard",            npc = "Nathanos Blightcaller" },
                { id = 52187, name = "Old Colleagues",                   npc = "Captain Amalia Stone" },
                { id = 52185, name = "A Well Placed Portal",             npc = "Nathanos Blightcaller" },
                { id = 52184, name = "Relics of Ritual",                 npc = "Thomas Zelling" },
                { id = 52188, name = "Tidesage Teachings",               npc = "Thomas Zelling" },
                { id = 52189, name = "Forfeit Souls",                    npc = "Thomas Zelling" },
                { id = 52190, name = "Gaining the Upper Hand",           npc = "Thomas Zelling" },
                { id = 52990, name = "Return to the Harbor",             npc = "Thomas Zelling" },
                { id = 52191, name = "Life Held Hostage",                npc = "Nathanos Blightcaller" },
                { id = 52192, name = "The Aid of the Tides",             npc = "Nathanos Blightcaller" },
                { id = 52861, name = "Champion: Lilian Voss",            npc = "Lilian Voss", optional = true },
                { id = 53003, name = "A Cycle of Hatred",                npc = "Nathanos Blightcaller" },
            },
        },

        -- CHAPTER 12: Testing Loyalties
        {
            chapter = "Testing Loyalties",
            summary = "Baine Bloodhoof has decided Derek Proudmoore cannot be used as a weapon against his own family and asks for your help freeing him. The plan runs through Plunder Harbor under false colors, with Thomas Zelling — the very tidesage Lilian helped raise — guiding the escape from the inside. When Baine and Zelling are punished for their defiance, Lilian says nothing to Sylvanas. She tells Zelling's family he died a hero. Then the War Campaign rolls on regardless — Warfang Hold needs securing, and Nathanos is already planning the next move.",
            recap = "Baine Bloodhoof looked at Derek Proudmoore — raised, hollowed out, aimed at his own kin — and decided he would not be part of it. He asked for your help. Thomas Zelling, the tidesage whose raising Lilian had stood witness to in Stormsong, helped guide Derek out from the inside. They freed him.\n\nSylvanas had Baine arrested and Zelling killed. Lilian said nothing aloud. Later, quietly, she went to Zelling's family and told them he had died a hero. It was not defiance. It was a choice. Small enough that no one noticed. Large enough that she did.\n\nAnd then the war moved on. Warfang Hold needed to be secured for a leadership summit. Boss Mida handled the SI:7 spies and the gate-crashers. Nathanos arrived to make a display of the Horde's strength. The machine kept turning, indifferent to what had just been lost.",
            quests = {
                { id = 54961, name = "Righting Wrongs",                  npc = "Bluffwatcher Proudscar" },
                { id = 55124, name = "Righting Wrongs",                  npc = "Bluffwatcher Proudscar" },
                { id = 54958, name = "Ships in the Night",               npc = "Baine Bloodhoof" },
                { id = 54959, name = "Under Lock and Keys",              npc = "Baine Bloodhoof" },
                { id = 54997, name = "Dead in the Water",                npc = "Baine Bloodhoof", optional = true },
                { id = 54960, name = "A Bitter Reunion",                 npc = "Baine Bloodhoof" },
                { id = 54999, name = "Under False Colors",               npc = "Thomas Zelling" },
                { id = 55034, name = "Under False Colors",               npc = "Thomas Zelling", optional = true },
                { id = 55047, name = "Securing Warfang Hold",            npc = "Dark Ranger Alina", mapID = 862, x = 0.5840, y = 0.6260, location = "Banshee's Wail, Dazar'alor" },
                { id = 55052, name = "Securing Warfang Hold",            npc = "Nathanos Blightcaller", mapID = 942, x = 0.4721, y = 0.3552, location = "Warfang Hold, Stormsong Valley" },
                { id = 55048, name = "Spy Games",                        npc = "Boss Mida", mapID = 942, x = 0.4721, y = 0.3552, location = "Warfang Hold, Stormsong Valley" },
                { id = 55049, name = "Communication Breakdown",          npc = "Boss Mida", mapID = 942, x = 0.4721, y = 0.3552, location = "Warfang Hold, Stormsong Valley" },
                { id = 55050, name = "Tickets, Please?",                 npc = "Kazit", mapID = 942, x = 0.4721, y = 0.3552, location = "Warfang Hold, Stormsong Valley" },
                { id = 55051, name = "A Display of Power",               npc = "Boss Mida" },
            },
        },

        -- CHAPTER 13: What Comes After
        {
            chapter = "What Comes After",
            gated = true,
            note = "Unlocks after defeating N'Zoth. Speak with Valeera Sanguinar in Zuldazar to begin.",
            summary = "Sylvanas is gone. The Horde's leaders gather to decide what it becomes without her — and Lilian Voss speaks for the Forsaken.",
            recap = "When the gate went quiet and Sylvanas left, Lilian Voss was already in the room. Baine, Lor'themar, Ji Firepaw — all the leaders who had waited out the war with their doubts held close — and the question nobody wanted to be first to say: what do they do about the Warchief's throne? Before the full council assembled, Lilian stepped away from the main hall to arrange a quieter meeting — Forsaken leadership, Calia Menethil, and Derek Proudmoore. Hidden, necessary, and entirely hers to broker. Then she came back into the room and made the case for leaving the throne empty. No single voice. A council, where every people kept their own weight and no one leader could burn the world on a private conviction. She had spent years being used by the powerful as a tool. She knew exactly what concentrated authority looked like from the receiving end. The others listened. They agreed. It was the first time Lilian Voss had spoken in a room full of power and been heard.",
            quests = {
                { id = 57198, name = "Sense of Obligation",      npc = "Lilian Voss", mapID = 862, x = 0.5840, y = 0.6260, location = "Dazar'alor, Zuldazar" },
                { id = 57376, name = "The Hidden Need",          npc = "Lilian Voss" },
                { id = 58672, name = "A Gathering of Champions", npc = "Valeera Sanguinar", mapID = 862, x = 0.5840, y = 0.6260, location = "Dazar'alor, Zuldazar" },
                { id = 58673, name = "Warchief of the Horde",    npc = "Valeera Sanguinar" },
            },
        },

        -- =====================================================================
        -- ACT V — RETURN TO LORDAERON (Shadowlands 9.2.5)
        -- Sylvanas is defeated. The war is over. The Dark Lady is gone.
        -- What remains is the city below the Blight, and the people who
        -- never stopped calling it home.
        -- =====================================================================

        -- CHAPTER 14: Return to Lordaeron
        {
            chapter = "Return to Lordaeron",
            gated = true,
            note = "Available to Horde players after completing the Shadowlands campaign.",
            summary = "With Sylvanas defeated and the war over, Lilian Voss and Calia Menethil lead the Forsaken back to Lordaeron. The city is choked with Blight, the halls of Undercity dark and half-collapsed. Together they fight to reclaim it — cleansing what can be saved, burying what cannot — and at the end, form the Desolate Council: a governing body the Forsaken chose for themselves.",
            recap = "The war ended. Sylvanas was gone. And Lilian Voss led the Forsaken home.\n\nThey came back to ruins — streets flooded with Blight, Undercity dark and broken. Calia Menethil walked beside her, daughter of the last king of Lordaeron, and between the two of them they held the Forsaken together through all of it: the plague work, the dead to bury, the city to reclaim room by room. At the end they formed the Desolate Council — Lilian, Calia, Velonara, Belmont, Faranell — not a Dark Lady, not a warchief. A council. Their own.\n\nLilian Voss, who had spent her whole life as something to be used and discarded, had become the person her people followed home.",
            quests = {
                { id = 65656, name = "Call to Lordaeron",                npc = "Calia Menethil" },
                { id = 65657, name = "Assemble the Forsaken",            npc = "Calia Menethil" },
                { id = 65658, name = "This Land is Ours",                npc = "Dark Ranger Velonara" },
                { id = 65659, name = "The Blight Congress",              npc = "Lilian Voss" },
                { id = 65660, name = "Walk of Faith",                    npc = "Calia Menethil" },
                { id = 65661, name = "Consulting Our Allies",            npc = "Lilian Voss" },
                { id = 65662, name = "House of Plagues",                 npc = "Margrave Sin'dane" },
                { id = 65663, name = "Feed the Eater",                   npc = "Calia Menethil" },
                { id = 65664, name = "Essence of Plague",                npc = "Plague Deviser Marileth" },
                { id = 65665, name = "Embodiment",                       npc = "Plague Deviser Marileth" },
                { id = 65666, name = "Return to Brill",                  npc = "Lilian Voss" },
                { id = 65667, name = "The Remedy of Lordaeron",          npc = "Calia Menethil" },
                { id = 65668, name = "The Desolate Council",             npc = "Lilian Voss" },
                { id = 66091, name = "Path of the Dark Rangers",         npc = "Dark Ranger Velonara" },
                { id = 65788, name = "A Walk with Ghosts",               npc = "Lilian Voss" },
            },
        },
    },
}
