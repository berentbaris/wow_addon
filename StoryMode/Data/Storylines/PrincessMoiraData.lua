local addonName, SM = ...

-- =============================================================================
-- Classic: Princess Moira
-- Ironforge, Thrall, and the succession crisis hidden in Blackrock Depths.
-- =============================================================================

SM.PrincessMoiraData = {
    title = "The Princess of Ironforge",
    description = "In Blackrock Depths, rumors about Princess Moira Bronzebeard have become too serious for Ironforge to ignore. The Dark Irons say one thing, the kingdom fears another, and no one outside the mountain has the full truth.\n\nEnter the depths on your faction's orders and find out what became of the princess. Rescue may not be as simple as it sounds.",
    zone = "Blackrock Depths / Ironforge / Orgrimmar",
    expansion = "Classic",
    recommendedLevel = { min = 48, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.76, 0.48, 0.28 },
    icon = 133416,
    portraitDisplayID = 8705,
    adventureGuideInstanceName = "Blackrock Depths",
    adventureCoverTexture = 131824,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 3702, name = "The Smoldering Ruins of Thaurissan", npc = "Royal Historian Archesonus", location = "Ironforge", faction = "Alliance" },
    startMapID = 87,
    startX = 0.3900,
    startY = 0.5600,

    npcLocations = {
        ["King Magni Bronzebeard"] = { mapID = 87, x = 0.3900, y = 0.5600, location = "the High Seat, Ironforge" },
        ["Royal Historian Archesonus"] = { mapID = 87, x = 0.3800, y = 0.5500, location = "the High Seat, Ironforge" },
        ["Kharan Mighthammer"] = { mapID = 242, x = 0.4552, y = 0.8656, location = "the Detention Block, Blackrock Depths" },
        ["Princess Moira Bronzebeard"] = { mapID = 242, x = 0.7657, y = 0.0923, location = "the Imperial Seat, Blackrock Depths" },
        ["Galamav the Marksman"] = { mapID = 15, x = 0.0500, y = 0.4700, location = "Kargath, Badlands" },
        ["Commander Gor'shak"] = { mapID = 242, x = 0.4392, y = 0.9023, location = "the Detention Block, Blackrock Depths" },
        ["Thrall"] = { mapID = 85, x = 0.3200, y = 0.3800, location = "Grommash Hold, Orgrimmar" },
    },

    npcDisplayIDs = {
        ["King Magni Bronzebeard"] = 3597,
        ["Royal Historian Archesonus"] = 8171,
        ["Kharan Mighthammer"] = 8708,
        ["Princess Moira Bronzebeard"] = 8705,
        ["Galamav the Marksman"] = 8334,
        ["Commander Gor'shak"] = 8703,
        ["Thrall"] = 61727,
    },

    chapterDisplayIDs = {
        ["Kharan's Tale"] = 8708,
        ["The Royal Rescue"] = 8705,
        ["The Warchief's Rescue"] = 4527,
    },

    chapterIcons = {
        ["Kharan's Tale"] = 133739,
        ["The Royal Rescue"] = 133416,
        ["The Warchief's Rescue"] = 132349,
    },

    chapters = {
        {
            chapter = "Kharan's Tale",
            faction = "Alliance",
            summary = "Hear the old tale of Thaurissan, then enter Blackrock Depths to learn what the mountain is hiding.",
            recap = "Moira's disappearance led backward to old Thaurissan and the War of the Three Hammers. Ironforge's old wound led straight into Blackrock Depths, where Kharan Mighthammer's prison cell held the news Magni did not want to hear. Moira was in the heart of the Dark Iron kingdom, and the rescue he wanted was already tangled in questions of love, control, succession, and inherited hatred.",
            quests = {
                { id = 3702, name = "The Smoldering Ruins of Thaurissan", npc = "Royal Historian Archesonus" },
                { id = 3701, name = "The Smoldering Ruins of Thaurissan", displayName = "Burning Steppes", npc = "Royal Historian Archesonus" },
                { id = 4341, name = "Kharan Mighthammer", npc = "King Magni Bronzebeard" },
                { id = 4342, name = "Kharan's Tale", npc = "Kharan Mighthammer" },
                { id = 4361, name = "The Bearer of Bad News", npc = "Kharan Mighthammer" },
            },
        },
        {
            chapter = "The Royal Rescue",
            faction = "Alliance",
            summary = "Magni orders a rescue, but Blackrock Depths may make it more complicated than an ordinary fight.",
            recap = "The order sounded simple because grief needed it to be simple: kill Thaurissan, spare Moira, bring the princess home. Blackrock Depths answered with something crueler. When the emperor fell, Moira did not thank her rescuers. She mourned her husband, named her unborn child heir to Ironforge, and sent Magni a future he could not command away.",
            quests = {
                { id = 4362, name = "The Fate of the Kingdom", npc = "King Magni Bronzebeard" },
                { id = 4363, name = "The Princess's Surprise", npc = "Princess Moira Bronzebeard" },
            },
        },
        {
            chapter = "The Warchief's Rescue",
            faction = "Horde",
            summary = "Commander Gor'shak's message pulls the Horde into Blackrock Depths, where Moira's captivity may shape more than one kingdom.",
            recap = "The Horde path entered the same crisis through a different door: a commander in chains, a prisoner with information, and Thrall reading the politics beneath the dungeon walls. Freeing Moira was not mercy alone. It was strategy. If a Dark Iron child could inherit Ironforge, then Blackrock Depths was not only a prison. It was a future capital waiting in the dark.",
            quests = {
                { id = 3981, name = "Commander Gor'shak", npc = "Galamav the Marksman" },
                { id = 3982, name = "What Is Going On?", npc = "Commander Gor'shak" },
                { id = 4001, name = "What Is Going On?", npc = "Commander Gor'shak" },
                { id = 4002, name = "The Eastern Kingdom", displayName = "The Eastern Kingdoms", npc = "Thrall" },
                { id = 4003, name = "The Royal Rescue", npc = "Thrall" },
                { id = 4004, name = "The Princess Saved?", npc = "Princess Moira Bronzebeard" },
            },
        },
    },
}
