local addonName, SM = ...

-- =============================================================================
-- Classic: Battle of Hillsbrad
-- The Forsaken campaign against Hillsbrad, Azureload Mine, and Dun Garok.
-- =============================================================================

SM.BattleOfHillsbradData = {
    title = "Battle of Hillsbrad",
    description = "High Executor Darthalia has work for anyone willing to serve Tarren Mill. The humans of Hillsbrad still farm, trade, and guard the roads as if the Forsaken claim means nothing.\n\nReport for orders and carry the campaign from the fields to the mines and beyond. Darthalia will tell you who must fall next.",
    zone = "Hillsbrad Foothills",
    expansion = "Classic",
    recommendedLevel = { min = 19, max = 32 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.54, 0.44, 0.36 },
    icon = 132349,
    portraitDisplayID = 1645,
    adventureCoverTexture = 131867, -- Ruins of Lordaeron battleground loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 527, name = "Battle of Hillsbrad", npc = "High Executor Darthalia", location = "Tarren Mill, Hillsbrad Foothills" },
    startMapID = 25,
    startX = 0.6200,
    startY = 0.1950,

    npcLocations = {
        ["High Executor Darthalia"] = { mapID = 25, x = 0.6200, y = 0.1950, location = "Tarren Mill, Hillsbrad Foothills" },
        ["Deathguard Samsa"] = { mapID = 25, x = 0.6200, y = 0.2000, location = "Tarren Mill, Hillsbrad Foothills" },
        ["WANTED"] = { mapID = 25, x = 0.6250, y = 0.1970, location = "the wanted poster outside the inn in Tarren Mill" },
        ["Varimathras"] = { mapID = 90, x = 0.5600, y = 0.9200, location = "the Royal Quarter, Undercity" },
        ["Hillsbrad Fields"] = { mapID = 25, x = 0.3200, y = 0.4500, location = "Hillsbrad Fields, Hillsbrad Foothills" },
        ["Hillsbrad Town"] = { mapID = 25, x = 0.3100, y = 0.4200, location = "Hillsbrad, Hillsbrad Foothills" },
        ["Azureload Mine"] = { mapID = 25, x = 0.3000, y = 0.5800, location = "Azureload Mine, Hillsbrad Foothills" },
        ["Dun Garok"] = { mapID = 25, x = 0.6900, y = 0.7600, location = "Dun Garok, Hillsbrad Foothills" },
    },

    npcDisplayIDs = {
        ["High Executor Darthalia"] = 1645,
        ["Varimathras"] = 11658,
    },

    chapterDisplayIDs = {
        ["Hillsbrad Fields"] = 1645,
        ["Town and Mine"] = 1645,
        ["Dun Garok"] = 11658,
    },

    chapterIcons = {
        ["Hillsbrad Fields"] = 132349,
        ["Town and Mine"] = 134708,
        ["Dun Garok"] = 132355,
    },

    chapters = {
        {
            chapter = "Hillsbrad Fields",
            summary = "Report to High Executor Darthalia and carry her first orders against the farms of Hillsbrad.",
            recap = "Darthalia's first orders were plain: strike the farms, kill those who worked them, and leave the town afraid. Tarren Mill's campaign had begun.",
            quests = {
                { id = 527, name = "Battle of Hillsbrad", displayName = "The Northern Farms", npc = "High Executor Darthalia" },
                { id = 528, name = "Battle of Hillsbrad", displayName = "The Peasants", npc = "High Executor Darthalia" },
                { id = 546, name = "Souvenirs of Death", npc = "Deathguard Samsa", optional = true, showIf = 527 },
            },
        },
        {
            chapter = "Town and Mine",
            summary = "Move from fields to town records, workers, leaders, and the mine that keeps Hillsbrad supplied.",
            recap = "Hillsbrad's strength lay in its smithy, leaders, registry, and mine. Darthalia sent you against each in turn, breaking the town by removing the people and records that held it together.",
            quests = {
                { id = 529, name = "Battle of Hillsbrad", displayName = "The Blacksmith", npc = "High Executor Darthalia" },
                { id = 532, name = "Battle of Hillsbrad", displayName = "The Town Hall", npc = "High Executor Darthalia" },
                { id = 567, name = "Dangerous!", npc = "WANTED", optional = true },
                { id = 539, name = "Battle of Hillsbrad", displayName = "Azureload Mine", npc = "High Executor Darthalia" },
            },
        },
        {
            chapter = "Dun Garok",
            summary = "March on Dun Garok and bring Darthalia the victory she needs for her sealed commendation.",
            recap = "Dun Garok stood as the last hard point in Darthalia's campaign. When its mountaineers, priests, riflemen, and Captain Ironhill were dead, her commendation could be carried to Varimathras.",
            quests = {
                { id = 541, name = "Battle of Hillsbrad", displayName = "Dun Garok", npc = "High Executor Darthalia" },
                { id = 550, name = "Battle of Hillsbrad", displayName = "Darthalia's Commendation", npc = "High Executor Darthalia" },
            },
        },
    },
}
