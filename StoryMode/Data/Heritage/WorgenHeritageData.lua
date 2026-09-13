local addonName, SM = ...

SM.WorgenHeritageData = {
    title = "Heritage of Gilneas",
    description = "Answer Tess Greymane's call when the Nightbane begin to reappear in Duskwood and near the borders of the Emerald Dream. The Gilneans are a kingdom in exile, and the curse that gave them a second face has not stopped reshaping them.\n\nHunt through fog and shadow, confront the pull of the worgen curse, and uphold the discipline that has kept Gilnean tradition alive since Greymane Wall fell.",
    zone = "Stormwind / Duskwood / Emerald Dream (phased)",
    expansion = "Battle for Azeroth",
    faction = "Alliance",
    race = "Worgen",
    requiredLevel = 50,
    achievementName = "Heritage of Gilneas",
    achievements = { 19719 },  -- Reclamation of Gilneas
    color = { 0.37, 0.43, 0.56 },
    icon = "Interface\\Icons\\inv_helm_armor_worgen_c_01",
    adventureGuideInstanceName = "Shadowfang Keep",
    startQuest = { id = 54976, name = "The Shadow of Gilneas", npc = "Courier Claridge", location = "Stormwind Embassy" },
    npcLocations = {
        ["Courier Claridge"] = { mapID = 84, x = 0.5220, y = 0.1350 }, -- Stormwind Embassy
        ["Mia Greymane"] = { mapID = 84, x = 0.8240, y = 0.2800 , location = "Stormwind / Duskwood / Emerald Dream (phased)"},
        ["Vassandra Stormclaw"] = { mapID = 47, x = 0.1820, y = 0.5720 },
        ["Princess Tess Greymane"] = { mapID = 84, x = 0.4640, y = 0.3700 , location = "Stormwind / Duskwood / Emerald Dream (phased)"},
    },
    chapterIcons = {
        ["Heritage of Gilneas"] = "Interface\\Icons\\inv_helm_armor_worgen_c_01",
    },
    chapterDisplayIDs = {
        ["Heritage of Gilneas"] = 90670,
    },
    chapters = {
        {
            chapter = "Heritage of Gilneas",
            summary = "Stand with Tess and the Gilneans to face the Nightbane and reaffirm your people's resolve.",
            recap = "Gilneas survived exile through loyalty, discipline, and the will to endure. By facing the darkness within and without, you helped carry that legacy forward.",
            quests = {
                { id = 54976, name = "The Shadow of Gilneas", npc = "Courier Claridge" },
                { id = 54977, name = "Into Duskwood", npc = "Mia Greymane" },
                { id = 54980, name = "Bane of the Nightbane", npc = "Vassandra Stormclaw" },
                { id = 54981, name = "Cry to the Moon", npc = "Vassandra Stormclaw" },
                { id = 54982, name = "The Spirit of the Hunter", npc = "Vassandra Stormclaw" },
                { id = 54983, name = "Waking a Dreamer", npc = "Vassandra Stormclaw" },
                { id = 54984, name = "Let Sleeping Wolves Lie", npc = "Goldrinn", mapID = 47, x = 0.7400, y = 0.4680, location = "Twilight Grove, Duskwood" },
                { id = 54990, name = "The New Guard", npc = "Princess Tess Greymane" },
            },
        },
    },
}

return SM
