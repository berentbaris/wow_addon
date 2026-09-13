local addonName, SM = ...

-- =============================================================================
-- Classic: Raene's Cleansing
-- Astranaar, Dartol's Rod, and the corrupted furbolg of Ashenvale.
-- =============================================================================

SM.RaenesCleansingData = {
    title = "Raene's Cleansing",
    description = "Raene Wolfrunner sends you west from Astranaar to look for Teronis, who went searching for answers to the furbolg attacks and did not return.\n\nFollow his trail through Ashenvale's moonwells, ruins, and old magic. If the forest is being changed, Raene wants to know how, and who is helping it spread.",
    zone = "Ashenvale",
    expansion = "Classic",
    recommendedLevel = { min = 18, max = 30 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.42, 0.58, 0.36 },
    icon = 135139,
    portraitDisplayID = 1980,
    adventureCoverTexture = 131823, -- Blackfathom Deeps: Ashenvale's dungeon cover for Raene's zone story
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 991, name = "Raene's Cleansing", displayName = "Finding Teronis", npc = "Raene Wolfrunner", location = "Astranaar, Ashenvale" },
    startMapID = 63,
    startX = 0.3620,
    startY = 0.4980,

    npcLocations = {
        ["Raene Wolfrunner"] = { mapID = 63, x = 0.3620, y = 0.4980, location = "Astranaar, Ashenvale" },
        ["Teronis' Corpse"] = { mapID = 63, x = 0.2020, y = 0.4250, location = "Lake Falathim, Ashenvale" },
        ["Shael'dryn"] = { mapID = 63, x = 0.5354, y = 0.4622, location = "the moonwell east of Iris Lake, Ashenvale" },
        ["Hidden Shrine"] = { mapID = 63, x = 0.5600, y = 0.4900, location = "the hidden shrine southeast of Shael'dryn" },
        ["Krolg"] = { mapID = 63, x = 0.5084, y = 0.7508, location = "southeast of Mystral Lake, Ashenvale" },
        ["Ran Bloodtooth"] = { mapID = 63, x = 0.5200, y = 0.3800, location = "the furbolg camp near Mystral Lake, Ashenvale" },
    },

    npcDisplayIDs = {
        ["Raene Wolfrunner"] = 1980,
        ["Shael'dryn"] = 2721,
        ["Krolg"] = 1010,
        ["Ran Bloodtooth"] = 1012,
    },

    chapterDisplayIDs = {
        ["Teronis' Journal"] = 1980,
        ["Dartol's Rod"] = 2721,
        ["The Uncorrupted Furbolg"] = 1010,
    },

    chapterIcons = {
        ["Teronis' Journal"] = 133741,
        ["Dartol's Rod"] = 135139,
        ["The Uncorrupted Furbolg"] = 132183,
    },

    chapters = {
        {
            chapter = "Teronis' Journal",
            summary = "Search for Teronis near Lake Falathim and return with whatever remains of his work.",
            recap = "Raene Wolfrunner feared for Teronis, and Ashenvale answered with a corpse. The murlocs near Lake Falathim had killed him, but his journal survived, along with the trail to a glowing gem. Returning both to Astranaar changed the task. Teronis had died looking for a way to slow the furbolg attacks, and Raene asked you to carry that hope forward.",
            quests = {
                { id = 991, name = "Raene's Cleansing", displayName = "Find Teronis", npc = "Raene Wolfrunner" },
                { id = 1023, name = "Raene's Cleansing", displayName = "Teronis' Journal", npc = "Teronis' Corpse" },
                { id = 1024, name = "Raene's Cleansing", displayName = "Find Shael'dryn", npc = "Raene Wolfrunner" },
            },
        },
        {
            chapter = "Dartol's Rod",
            summary = "Follow Shael'dryn's guidance through old Ashenvale magic and the work left unfinished by Teronis.",
            recap = "Shael'dryn knew what Teronis had been chasing: Dartol's Rod, broken into pieces and hidden across Ashenvale's corrupted places. The iron shaft lay behind a key carried by twisted treants near Felwood. The iron pommel had passed through Dor'danil's dead and into the slime. When the rod was remade, a hidden shrine gave it power again. By then, Teronis' errand had become something stranger: not a weapon, but a way to speak across the line between the uncorrupted and the lost.",
            quests = {
                { id = 1026, name = "Raene's Cleansing", displayName = "Iron Shaft", npc = "Shael'dryn" },
                { id = 1027, name = "Raene's Cleansing", displayName = "Iron Pommel", npc = "Shael'dryn" },
                { id = 1028, name = "Raene's Cleansing", displayName = "Hidden Shrine", npc = "Shael'dryn" },
                { id = 1029, name = "Raene's Cleansing", displayName = "Return to Raene", npc = "Shael'dryn" },
            },
        },
        {
            chapter = "The Uncorrupted Furbolg",
            summary = "Use Dartol's Rod to reach Krolg and turn against Ran Bloodtooth's corrupted furbolg.",
            recap = "The rod transformed more than your shape. It let you approach Krolg, an uncorrupted furbolg who still carried grief and anger for what had happened to his people. Krolg blamed the night elves, but he also knew Ran Bloodtooth had become a threat no one could ignore. Killing Ran and his guards did not cleanse Ashenvale, but it proved Teronis had not died for nothing. Raene kept the skull and the rod as proof that the forest could still be defended.",
            quests = {
                { id = 1030, name = "Raene's Cleansing", displayName = "Find Krolg", npc = "Raene Wolfrunner" },
                { id = 1045, name = "Raene's Cleansing", displayName = "Ran Bloodtooth", npc = "Krolg" },
                { id = 1046, name = "Raene's Cleansing", displayName = "Return to Raene", npc = "Krolg" },
            },
        },
    },
}
