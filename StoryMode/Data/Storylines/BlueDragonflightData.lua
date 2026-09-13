local addonName, SM = ...

-- =============================================================================
-- Dragonflight: A Blue Dawn
-- Kalecgos reunites the scattered blue dragonflight.
-- =============================================================================

SM.BlueDragonflightData = {
    title = "A Blue Dawn",
    achievementName = "A Blue Dawn",
    achievements = { 17773 },
    description = "The blue dragonflight survived Malygos, the Nexus War, and years of grief by scattering across Azeroth. Kalecgos can lead an Aspect's flight again, but only if the blues choose to become a family instead of a memory.\n\nAnswer Kalecgos's call, search for the lost blue dragons, and help each branch decide whether there is still a home worth returning to.",
    zone = "The Azure Span / Thaldraszus / Azeroth",
    expansion = "Dragonflight",
    recommendedLevel = { min = 60, max = 70 },
    color = { 0.28, 0.50, 0.95 },
    portraitDisplayID = 75614, -- Kalecgos
    adventureGuideInstanceName = "The Azure Vault",
    adventureCoverTexture = 4566643, -- The Azure Vault loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 72900, name = "Keeper of the Ossuary", npc = "Kalecgos", location = "The Azure Archives, The Azure Span" },
    startMapID = 2024,
    startX = 0.3940,
    startY = 0.6300,

    npcLocations = {
        ["Kalecgos"] = { mapID = 2024, x = 0.3940, y = 0.6300, location = "The Azure Archives, The Azure Span" },
        ["Senegos"] = { mapID = 2025, x = 0.6700, y = 0.1180, location = "Algeth'ar Academy, Thaldraszus" },
        ["Azuregos"] = { mapID = 114, x = 0.2240, y = 0.2380, location = "Borean Tundra" },
        ["Lanigosa"] = { mapID = 127, x = 0.9140, y = 0.5720, location = "Crystalsong Forest" },
        ["Surigosa"] = { mapID = 70, x = 0.6700, y = 0.5460, location = "Dustwallow Marsh" },
        ["Zeros"] = { mapID = 210, x = 0.4280, y = 0.7400, location = "Booty Bay, The Cape of Stranglethorn" },
        ["Blixrez Goodstitch"] = { mapID = 210, x = 0.4280, y = 0.7400, location = "Booty Bay, The Cape of Stranglethorn" },
        ["Kirygosa"] = { mapID = 371, x = 0.4580, y = 0.4360, location = "The Jade Forest" },
        ["Haleh"] = { mapID = 83, x = 0.4800, y = 0.5900, location = "Mazthoril, Winterspring" },
        ["Sindragosa"] = { mapID = 2024, x = 0.3940, y = 0.6300, location = "The Azure Archives, The Azure Span" },
    },

    npcDisplayIDs = {
        ["Kalecgos"] = 75614,
        ["Senegos"] = 105703,
        ["Azuregos"] = 68826,
        ["Lanigosa"] = 110573,
        ["Surigosa"] = 110851,
        ["Zeros"] = 61886,
        ["Blixrez Goodstitch"] = 7186,
        ["Kirygosa"] = 111360,
        ["Haleh"] = 19806,
        ["Sindragosa"] = 104535,
    },

    chapterDisplayIDs = {
        ["Keeper of the Ossuary"] = 75614,
        ["The Search for Blue Dragons"] = 75614,
        ["Those We Left Behind"] = 110573,
        ["No Such Thing as Bad Luck"] = 61886,
        ["Warm Winds and Water"] = 75614,
        ["A Protector of Magic"] = 104535,
        ["Reunited Again"] = 75614,
    },

    chapterIcons = {
        ["Keeper of the Ossuary"] = 134155,
        ["The Search for Blue Dragons"] = 134155,
        ["Those We Left Behind"] = 463570,
        ["No Such Thing as Bad Luck"] = 134374,
        ["Warm Winds and Water"] = 132845,
        ["A Protector of Magic"] = 135750,
        ["Reunited Again"] = 463565,
    },

    chapters = {
        {
            chapter = "Keeper of the Ossuary",
            summary = "Kalecgos begins at the Veiled Ossuary, where memories of Sindragosa, Malygos, Azuregos, and Senegos show how much the blue dragonflight has lost.",
            recap = "Kalecgos called you to the Veiled Ossuary to help tend the memories of the blue dragonflight. With Senegos and Azuregos drawn into the work, the archives became more than a vault. They became a place to face what the blues had survived: Malygos, Sindragosa, exile, war, and the long habit of grieving separately.\n\nBy the time the first memories returned, Kalecgos understood the real task. The flight could not be restored by duty alone. The missing blues had to be found, heard, and invited home.",
            quests = {
                { id = 72900, name = "Keeper of the Ossuary", npc = "Kalecgos" },
                { id = 72921, name = "On the Trail Again", npc = "Senegos" },
                { id = 72933, name = "Rolling Out", npc = "Senegos" },
                { id = 72934, name = "Lest We Forget", npc = "Senegos" },
                { id = 72935, name = "Archives Return", npc = "Senegos" },
                { id = 72936, name = "Azuregos's Support", npc = "Kalecgos" },
                { id = 72937, name = "Unusual Disruptions", npc = "Azuregos" },
                { id = 72938, name = "Archival Arrival", npc = "Azuregos" },
                { id = 72940, name = "Where in the World is a Lost Blue Dragon?", npc = "Kalecgos" },
                { id = 73069, name = "Sindragosa and Malygos's Rest", npc = "Senegos" },
                { id = 75023, name = "Memories of Sindragosa and Malygos", npc = "Senegos" },
            },
        },
        {
            chapter = "The Search for Blue Dragons",
            summary = "Kalecgos begins the search in earnest, naming the scattered blues and sending you across Azeroth to bring their stories back together.",
            recap = "The archives gave Kalecgos names, but names were not enough. The missing blues had built separate lives, separate loyalties, and separate ways of surviving. Some were hiding from pain. Some were trapped in old debts. Some had made peace with never returning.\n\nKalecgos chose to ask rather than command. The blue dragonflight's renewal would be a gathering, not a summons.",
            quests = {
                { id = 73399, name = "The Search for Blue Dragons", npc = "Kalecgos" },
                { id = 73404, name = "Lost Blue Dragons", npc = "Kalecgos" },
                { id = 73405, name = "A Pair of Blue Dragons", npc = "Kalecgos" },
                { id = 73406, name = "The Last Missing Blue Dragon", npc = "Kalecgos" },
            },
        },
        {
            chapter = "Those We Left Behind",
            summary = "Lanigosa and Surigosa carry the cost of the Nexus War. Help them face a legacy that was never only history.",
            recap = "Lanigosa's branch of the search led to Crystalsong Forest and Dustwallow Marsh, where grief had hardened around the Nexus War. The losses were personal, not abstract: shattered legacy, arcane echoes, old banners, and survivors who had learned to keep moving because stopping hurt too much.\n\nWith Surigosa and Kalecgos, you helped turn remembrance into release. The past was not erased, but it no longer had to be a prison.",
            quests = {
                { id = 72670, name = "Those We Left Behind", npc = "Lanigosa" },
                { id = 72674, name = "A Shattered Legacy", npc = "Lanigosa" },
                { id = 72679, name = "An Arcane Requiem", npc = "Lanigosa" },
                { id = 72831, name = "Creative Solutions", npc = "Kalecgos" },
                { id = 72832, name = "Aftershocks", npc = "Surigosa" },
                { id = 74783, name = "The Sound of Silence", npc = "Lanigosa" },
                { id = 72833, name = "Breaking the Cycle", npc = "Surigosa" },
                { id = 73090, name = "Regrets in Crystal", npc = "Kalecgos" },
                { id = 73188, name = "The Sullied Banner", npc = "Kalecgos" },
                { id = 74335, name = "A Moment of Reflection", npc = "Surigosa" },
            },
        },
        {
            chapter = "No Such Thing as Bad Luck",
            summary = "Zeros has a debt problem in Booty Bay, which means the blue dragonflight's reunion briefly becomes paperwork, bribery, and goblin accounting.",
            recap = "Zeros did not need a grand speech. He needed out of debt. Booty Bay wrapped the search in ledgers, bribes, crystals, and the kind of bargaining that makes dragons wonder why mortals invented money.\n\nSenegos treated the mess with surprising patience, and Zeros eventually found a path back that did not involve running forever. Even the ridiculous errands served the larger truth: every scattered blue had a different reason to stay away.",
            quests = {
                { id = 72527, name = "No Such Thing as Bad Luck", npc = "Zeros" },
                { id = 72529, name = "Information is King", npc = "Blixrez Goodstitch" },
                { id = 72530, name = "Anyway, I Started Bribing", npc = "Zeros" },
                { id = 73181, name = "Zeroing Debt", npc = "Senegos" },
                { id = 72532, name = "Money, Money, Money!", npc = "Zeros" },
                { id = 72533, name = "Crystals Shmystals", npc = "Zeros" },
                { id = 72534, name = "Settled with the Baron", npc = "Zeros" },
                { id = 72988, name = "The Booty Bay Journal", npc = "Senegos" },
                { id = 73026, name = "Booty Bay", npc = "Senegos" },
            },
        },
        {
            chapter = "Warm Winds and Water",
            summary = "Kalecgos visits Kirygosa in the Jade Forest, where care, quiet work, and old friendship matter more than speeches.",
            recap = "Kirygosa's life in the Jade Forest was not a problem to solve. It was a life she had made. Kalecgos helped with carp, deliveries, and simple comforts because asking someone to come home means respecting the home they already have.\n\nThe visit became a gentle reminder that the blue dragonflight could be wider than one place. Returning did not have to mean abandoning what had healed them.",
            quests = {
                { id = 72650, name = "Warm Winds and Water", npc = "Kalecgos" },
                { id = 72651, name = "Carp Care", npc = "Kirygosa" },
                { id = 72652, name = "Self Care", npc = "Kalecgos" },
                { id = 72653, name = "Local Deliveries", npc = "Kirygosa" },
                { id = 72654, name = "Up, Up, and Home", npc = "Kirygosa" },
                { id = 72655, name = "A Drink with Kalecgos", npc = "Kalecgos" },
            },
        },
        {
            chapter = "A Protector of Magic",
            summary = "Sindragosa's simulacrum sends you to Winterspring, where Haleh and old arcane tests reconnect another piece of blue dragon history.",
            recap = "The Winterspring branch carried a colder kind of memory. Sindragosa's simulacrum guided the search, Haleh guarded her own piece of the flight's story, and the work moved through tests, artifacts, and old magic rather than open confession.\n\nStill, the pattern held. The scattered blues were not being collected. They were being remembered, respected, and invited to stand together again.",
            quests = {
                { id = 72656, name = "Winterspring", npc = "Kalecgos" },
                { id = 72657, name = "A Protector of Magic", npc = "Sindragosa" },
                { id = 72659, name = "Test Subject", npc = "Haleh" },
                { id = 72660, name = "Owl of a Sudden", npc = "Haleh" },
                { id = 72661, name = "A Wyrm Rest", npc = "Sindragosa" },
                { id = 73227, name = "Jade Forest", npc = "Kalecgos" },
                { id = 74291, name = "Blue is My Favorite Color", npc = "Kalecgos" },
                { id = 74354, name = "Artifacts Abound", npc = "Haleh" },
                { id = 74356, name = "Back with the Blues", npc = "Sindragosa" },
            },
        },
        {
            chapter = "Reunited Again",
            summary = "The final trouble at the Veiled Ossuary brings the blues home, not as Malygos left them, but as a flight ready to choose its own future.",
            recap = "The Veiled Ossuary's final crisis forced the reunited blues to act together. Azuregos, Senegos, Sindragosa's memory, Kalecgos, and the scattered branches all carried different hurts, but they were no longer isolated by them.\n\nWhen the last conflict ended, the farewell was peaceful. The blue dragonflight did not return to the past. It stepped into a new dawn with grief acknowledged, bonds restored, and Kalecgos no longer trying to hold the flight together alone.",
            quests = {
                { id = 72942, name = "Veiled Trouble", npc = "Kalecgos" },
                { id = 72946, name = "Veiled Ossuary Chaos", npc = "Azuregos" },
                { id = 72947, name = "Memories of Old", npc = "Azuregos" },
                { id = 72948, name = "What Still Remains", npc = "Azuregos" },
                { id = 72949, name = "Swiftly to the Archives", npc = "Azuregos" },
                { id = 75244, name = "Reunited Again", npc = "Kalecgos" },
                { id = 72950, name = "The Last Conflict", npc = "Sindragosa" },
                { id = 72951, name = "A Peaceful Farewell", npc = "Senegos" },
            },
        },
    },
}
