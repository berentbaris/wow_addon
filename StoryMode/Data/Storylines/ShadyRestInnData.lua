local addonName, SM = ...

-- =============================================================================
-- Dustwallow: The Shady Rest Inn
-- A burned-inn mystery with faction-specific investigations.
-- =============================================================================

SM.ShadyRestInnData = {
    title = "The Shady Rest Inn",
    description = "On the road between Dustwallow Marsh and the Barrens, the Shady Rest Inn is nothing but ash, hoofprints, a scorched shield, and a guard badge that should not be there.\n\nFollow the clues before faction blame buries the truth. What begins as a burned waystation becomes an investigation through evidence that may have been left to tell too simple a story.",
    zone = "Dustwallow Marsh",
    expansion = "World of Warcraft",
    recommendedLevel = { min = 30, max = 39 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.66, 0.52, 0.34 },
    icon = "Interface\\Icons\\INV_Misc_Note_01",
    adventureCoverTexture = 131871, -- Stratholme loading screen: burned-city mood for the Shady Rest investigation
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1284, name = "Suspicious Hoofprints", npc = "Hoofprints", location = "the ruins of the Shady Rest Inn, Dustwallow Marsh", mapID = 70, x = 0.2970, y = 0.4770 },
    startMapID = 70,
    startX = 0.2970,
    startY = 0.4770,

    npcLocations = {
        ["Adjutant Tesoran"] = { mapID = 70, x = 0.6810, y = 0.4820, location = "Foothold Citadel, Theramore Isle" },
        ["Balos Jacken"] = { mapID = 70, x = 0.3540, y = 0.5400, location = "Lost Point, Dustwallow Marsh" },
        ["Black Shield"] = { mapID = 70, x = 0.2960, y = 0.4860, location = "the ruins of the Shady Rest Inn, Dustwallow Marsh" },
        ["Captain Darill"] = { mapID = 70, x = 0.4700, y = 0.2400, location = "North Point Tower, Dustwallow Marsh" },
        ["Captain Garran Vimes"] = { mapID = 70, x = 0.6820, y = 0.4860, location = "Foothold Citadel, Theramore Isle" },
        ["Caz Twosprocket"] = { mapID = 70, x = 0.6450, y = 0.5040, location = "the Theramore blacksmith, Dustwallow Marsh" },
        ["Do'gol"] = { mapID = 70, x = 0.3600, y = 0.3100, location = "Brackenwall Village, Dustwallow Marsh" },
        ["Guard Byron"] = { mapID = 70, x = 0.6620, y = 0.4560, location = "Theramore Isle, Dustwallow Marsh" },
        ["Hoofprints"] = { mapID = 70, x = 0.2970, y = 0.4770, location = "outside the ruins of the Shady Rest Inn, Dustwallow Marsh" },
        ["Krog"] = { mapID = 70, x = 0.3640, y = 0.3180, location = "Brackenwall Village, Dustwallow Marsh" },
        ["Mosarn"] = { mapID = 88, x = 0.5560, y = 0.7960, location = "Thunder Bluff" },
        ["Ogron"] = { mapID = 70, x = 0.4000, y = 0.3600, location = "Brackenwall Village, Dustwallow Marsh" },
        ["Tabetha"] = { mapID = 70, x = 0.4600, y = 0.5710, location = "Tabetha's Farm, Dustwallow Marsh" },
        ["Theramore Guard Badge"] = { mapID = 70, x = 0.2980, y = 0.4820, location = "inside the ruins of the Shady Rest Inn, Dustwallow Marsh" },
    },

    chapterIcons = {
        ["The Ruins"] = "Interface\\Icons\\Ability_Tracking",
        ["The Black Shield"] = "Interface\\Icons\\INV_Shield_09",
        ["Paval Reethe"] = "Interface\\Icons\\INV_Misc_Note_01",
        ["The Hidden Hand"] = "Interface\\Icons\\Spell_Nature_EarthBindTotem",
    },

    chapters = {
        {
            chapter = "The Ruins",
            faction = "Alliance",
            summary = "Captain Garran Vimes sends you to the burned inn, where the first clues point in several uncomfortable directions.",
            recap = "The ruins did not offer a clean answer. Hoofprints marked the ash outside the inn, a blackened shield suggested a tauren hand, and a Theramore badge tied the scene to Lieutenant Paval Reethe. Even Smiling Jim's grief only sharpened the question: who wanted everyone looking at the wrong enemy?",
            quests = {
                { id = 11123, name = "Inspecting the Ruins", npc = "Captain Garran Vimes", gameVersions = { tbc = true } },
                { id = 1284, name = "Suspicious Hoofprints", npc = "Hoofprints" },
                { id = 1282, name = "They Call Him Smiling Jim", npc = "Guard Byron", optional = true },
            },
        },
        {
            chapter = "The Black Shield",
            faction = "Alliance",
            summary = "Follow the scorched shield from the ruined fireplace back through Theramore's smiths.",
            recap = "The black shield looked like the simplest clue, and so it became the most dangerous one. Caz Twosprocket could tell it was not made in Theramore, and the size suggested a tauren bearer, but certainty stayed out of reach. The clue was real, yet it still felt planted to push anger toward the Horde.",
            quests = {
                { id = 1253, name = "The Black Shield", npc = "Black Shield" },
                { id = 1319, name = "The Black Shield", displayName = "The Black Shield: Caz Twosprocket", npc = "Captain Garran Vimes" },
                { id = 1320, name = "The Black Shield", displayName = "The Black Shield: Vimes' Report", npc = "Caz Twosprocket" },
            },
        },
        {
            chapter = "Paval Reethe",
            faction = "Alliance",
            summary = "Trace the Theramore Guard badge to Paval Reethe and the deserters at Lost Point.",
            recap = "The guard badge led away from the inn and into Theramore's own troubles. Paval Reethe had deserted, and Balos Jacken's men at Lost Point had little love left for their old command. Reethe looked guilty enough to be useful, but not guilty enough to be the answer.",
            quests = {
                { id = 1252, name = "Lieutenant Paval Reethe", npc = "Theramore Guard Badge" },
                { id = 1259, name = "Lieutenant Paval Reethe", displayName = "Lieutenant Paval Reethe: Records", npc = "Captain Garran Vimes" },
                { id = 1285, name = "Daelin's Men", npc = "Adjutant Tesoran" },
                { id = 1286, name = "The Deserters", displayName = "The Deserters: Lost Point", npc = "Captain Garran Vimes" },
                { id = 1287, name = "The Deserters", displayName = "The Deserters: Balos' Account", npc = "Balos Jacken" },
            },
        },
        {
            chapter = "The Hidden Hand",
            faction = "Alliance",
            gameVersions = { tbc = true },
            summary = "The evidence carries you north to one more camp, then south to Tabetha for a clearer look at the hand behind the fire.",
            recap = "The missing piece was not a deserter or a city guard, but a Grimtotem move meant to poison Theramore and the Horde against each other. Captain Darill's evidence exposed Blackhoof Village as part of the plot, while Tabetha pointed to Direhorn Post as the real source of the attack. When the camp burned, the Shady Rest finally had an answer.",
            quests = {
                { id = 11143, name = "A Grim Connection", npc = "Captain Garran Vimes" },
                { id = 11144, name = "Confirming the Suspicion", npc = "Captain Darill" },
                { id = 11148, name = "Arms of the Grimtotems", npc = "Captain Darill", parallel = true },
                { id = 11149, name = "Tabetha's Assistance", npc = "Captain Darill" },
                { id = 11150, name = "Raze Direhorn Post!", npc = "Tabetha" },
                { id = 11151, name = "Justice for the Hyals", npc = "Tabetha" },
                { id = 11152, name = "Peace at Last", npc = "Captain Garran Vimes" },
            },
        },
        {
            chapter = "The Ruins",
            faction = "Horde",
            summary = "Krog has orders to investigate the burned inn, but the real clues are waiting in the ash.",
            recap = "The ruins were not merely Alliance grief. Hoofprints, a scorched shield, and a Theramore badge could all be read as accusations, and Krog wanted the Horde's answers before Theramore wrote the story for everyone. The evidence pointed at tauren ironwork and Paval Reethe, but neither trail felt complete.",
            quests = {
                { id = 11124, name = "Inspecting the Ruins", npc = "Krog", gameVersions = { tbc = true } },
                { id = 1268, name = "Suspicious Hoofprints", npc = "Hoofprints" },
            },
        },
        {
            chapter = "The Black Shield",
            faction = "Horde",
            summary = "Carry the blackened shield through Brackenwall and Thunder Bluff until Mosarn can place the craft.",
            recap = "The shield should have settled the matter, but it only made the case stranger. Krog, Do'gol, and Mosarn could follow the iron's story, yet the shield alone did not prove who set the fire. It was a clue with enough truth to be useful and enough ambiguity to start a war.",
            quests = {
                { id = 1251, name = "The Black Shield", npc = "Black Shield" },
                { id = 1321, name = "The Black Shield", displayName = "The Black Shield: Do'gol", npc = "Krog" },
                { id = 1322, name = "The Black Shield", displayName = "The Black Shield: Do'gol's Findings", npc = "Do'gol" },
                { id = 1323, name = "The Black Shield", displayName = "The Black Shield: Return to Krog", npc = "Do'gol" },
                { id = 1276, name = "The Black Shield", displayName = "The Black Shield: Mosarn", npc = "Krog" },
            },
        },
        {
            chapter = "Paval Reethe",
            faction = "Horde",
            summary = "Track Paval Reethe with Ogron's help and see why the badge was left behind.",
            recap = "Paval Reethe was real, cornered, and dangerous, but the speed of his death made him look less like the murderer and more like a man someone needed silenced. The badge at the inn had not solved the case. It had revealed how badly someone wanted a convenient suspect.",
            quests = {
                { id = 1269, name = "Lieutenant Paval Reethe", npc = "Theramore Guard Badge" },
                { id = 1273, name = "Questioning Reethe", npc = "Ogron" },
            },
        },
        {
            chapter = "The Hidden Hand",
            faction = "Horde",
            gameVersions = { tbc = true },
            summary = "Mosarn's new lead brings the investigation back to Krog, then south to Tabetha for a clearer look at the hand behind the fire.",
            recap = "Mosarn's memory reopened the case and pulled the scattered clues into one line: the Grimtotem had used the inn to inflame Theramore and the Horde. Krog's evidence and Tabetha's certainty led to Direhorn Post. Burning it down did not restore the Shady Rest, but it stopped the lie from doing more work.",
            quests = {
                { id = 11204, name = "Return to Krog", npc = "Mosarn" },
                { id = 11200, name = "More than Coincidence", npc = "Krog" },
                { id = 11201, name = "The Grimtotem Plot", npc = "Krog", parallel = true },
                { id = 11203, name = "Seek Out Tabetha", npc = "Krog" },
                { id = 11205, name = "Raze Direhorn Post!", npc = "Tabetha" },
                { id = 11206, name = "Justice Dispensed", npc = "Tabetha" },
            },
        },
    },
}
