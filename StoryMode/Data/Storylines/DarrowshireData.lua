local addonName, SM = ...

-- =============================================================================
-- Classic: Darrowshire
-- Pamela Redpath, Chromie, and the battle that never stopped echoing.
-- =============================================================================

SM.DarrowshireData = {
    title = "The Battle of Darrowshire",
    description = "Marlene Redpath asks you to find her niece Pamela in Darrowshire. In the ruins, a lonely child is still waiting for family and trying to remember where her doll has gone.\n\nBegin with Pamela's small request and follow the Redpath family through old grief, missing records, and the question of what really happened on Darrowshire's last night.",
    zone = "Western Plaguelands / Eastern Plaguelands",
    expansion = "Classic",
    recommendedLevel = { min = 50, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.68, 0.62, 0.48 },
    icon = 134331,
    portraitDisplayID = 7069,
    adventureCoverTexture = 131859,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 5142, altIds = { 5601 }, name = "Little Pamela", npc = "Marlene Redpath", location = "Sorrow Hill, Western Plaguelands" },
    startMapID = 22,
    startX = 0.4900,
    startY = 0.7800,

    npcLocations = {
        ["Marlene Redpath"] = { mapID = 22, x = 0.4900, y = 0.7800, location = "Sorrow Hill, Western Plaguelands" },
        ["Jessica Redpath"] = { mapID = 83, x = 0.6100, y = 0.3900, location = "Everlook, Winterspring" },
        ["Pamela Redpath"] = { mapID = 23, x = 0.3600, y = 0.9000, location = "Darrowshire, Eastern Plaguelands" },
        ["Chromie"] = { mapID = 22, x = 0.3900, y = 0.6600, location = "the ruined inn of Andorhal, Western Plaguelands" },
        ["Carlin Redpath"] = { mapID = 23, x = 0.8100, y = 0.5900, location = "Light's Hope Chapel, Eastern Plaguelands" },
    },

    npcDisplayIDs = {
        ["Marlene Redpath"] = 10232,
        ["Jessica Redpath"] = 11512,
        ["Pamela Redpath"] = 10445,
        ["Chromie"] = 10008,
        ["Carlin Redpath"] = 10476,
    },

    chapterDisplayIDs = {
        ["Pamela's Doll"] = 10445,
        ["The Annals of Darrowshire"] = 10008,
        ["The Redpath Relics"] = 10476,
        ["Darrowshire Rewritten"] = 10445,
    },

    chapterIcons = {
        ["Pamela's Doll"] = 134506,
        ["The Annals of Darrowshire"] = 133739,
        ["The Redpath Relics"] = 134331,
        ["Darrowshire Rewritten"] = 135994,
    },

    chapters = {
        {
            chapter = "Pamela's Doll",
            summary = "Find Pamela Redpath in Darrowshire and help gather the pieces of the doll she has lost.",
            recap = "Marlene's request led you to Pamela Redpath, alone among the ruins and still asking after her doll. Returning the pieces brought comfort, and also the first hard truth of Darrowshire.",
            quests = {
                { id = 5142, altIds = { 5601 }, name = "Little Pamela", npc = "Marlene Redpath" },
                { id = 5149, name = "Pamela's Doll", npc = "Pamela Redpath" },
            },
        },
        {
            chapter = "The Annals of Darrowshire",
            summary = "Follow Pamela's family trail to Marlene, Carlin, and Chromie, who seeks the Annals of Darrowshire.",
            recap = "Pamela's family was scattered by grief: Marlene near Andorhal, Jessica far away, and Carlin at Light's Hope. Chromie gave their sorrow a shape by asking for the Annals of Darrowshire.",
            quests = {
                { id = 5152, name = "Auntie Marlene", npc = "Pamela Redpath" },
                { id = 5153, name = "A Strange Historian", npc = "Marlene Redpath" },
                { id = 5154, name = "The Annals of Darrowshire", npc = "Chromie" },
                { id = 5241, name = "Uncle Carlin", npc = "Pamela Redpath", optional = true },
                { id = 5211, name = "Defenders of Darrowshire", npc = "Carlin Redpath", optional = true },
                { id = 5210, name = "Brother Carlin", npc = "Chromie" },
            },
        },
        {
            chapter = "The Redpath Relics",
            summary = "Recover the relics and skulls tied to Darrowshire's old defenders, villains, and marauders.",
            recap = "Carlin and Chromie needed names made into relics: Horgus, Marduk, Davil, Joseph, and the marauders who joined the slaughter. Each recovered piece brought the last battle closer to being answered.",
            quests = {
                { id = 5181, name = "Villains of Darrowshire", npc = "Carlin Redpath" },
                { id = 5168, name = "Heroes of Darrowshire", npc = "Carlin Redpath" },
                { id = 5206, name = "Marauders of Darrowshire", npc = "Carlin Redpath" },
                { id = 5941, name = "Return to Chromie", npc = "Carlin Redpath" },
            },
        },
        {
            chapter = "Darrowshire Rewritten",
            summary = "Return to Darrowshire with Chromie's relic bundle and stand with the town in its final battle.",
            recap = "The dead of Darrowshire rose to fight again. You held the line, faced the corrupted Joseph Redpath, and gave Pamela the peace of knowing her father had come home.",
            quests = {
                { id = 5721, name = "The Battle of Darrowshire", npc = "Chromie" },
                { id = 5942, name = "Hidden Treasures", npc = "Pamela Redpath" },
            },
        },
    },
}
