local addonName, SM = ...

-- =============================================================================
-- Classic: Mankrik's Wife
-- A short Barrens story with one of Classic's most remembered quest texts.
-- =============================================================================

SM.MankriksWifeData = {
    title = "Lost in Battle",
    description = "At the Crossroads, Mankrik is looking for his wife. He last saw her on the Gold Road, and the Barrens offers little comfort to anyone searching through quillboar territory.\n\nTake his question with you into the heat and dust. What you find, if you find anything, belongs first to the husband still waiting.",
    zone = "The Barrens",
    expansion = "Classic",
    recommendedLevel = { min = 14, max = 20 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.72, 0.52, 0.24 },
    icon = 133469,
    portraitDisplayID = 3855,
    adventureCoverTexture = 131882, -- Wailing Caverns: closest Classic loading screen rooted in The Barrens
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 4921, name = "Lost in Battle", npc = "Mankrik", location = "the Crossroads, The Barrens" },
    startMapID = 10,
    startX = 0.5520,
    startY = 0.4100,

    npcLocations = {
        ["Mankrik"] = { mapID = 10, x = 0.5195, y = 0.3158, location = "the Crossroads, The Barrens" },
    },

    npcDisplayIDs = {
        ["Mankrik"] = 3855,
    },

    chapterDisplayIDs = {
        ["Lost in Battle"] = 3855,
    },

    chapterIcons = {
        ["Lost in Battle"] = 133469,
    },

    chapters = {
        {
            chapter = "Lost in Battle",
            summary = "Mankrik survived a quillboar attack on the Gold Road, but Olgra did not return. Search the road south of the Crossroads for his wife.",
            recap = "Mankrik's request was painfully plain: find his wife. The Barrens offered little direction and less mercy, only a long road south of the Crossroads and quillboar waiting in the dust. When Olgra was found, the search became grief. Mankrik had asked for hope and received a body. What followed was the only answer his pain could bear: Bristleback tusks, brought back one by one.",
            quests = {
                { id = 4921, name = "Lost in Battle", npc = "Mankrik" },
                { id = 899, name = "Consumed by Hatred", npc = "Mankrik" },
            },
        },
    },
}
