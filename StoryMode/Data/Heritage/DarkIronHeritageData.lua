local addonName, SM = ...

SM.DarkIronHeritageData = {
    title = "Heritage o' the Dark Iron",
    description = "Stand with Moira Thaurissan as the Dark Iron clan steps out of Blackrock's shadow and claims its place beside the other dwarven clans. Old pride still smolders in the forges, and old enemies still know the names of the halls beneath the mountain.\n\nWalk through places where fire shaped a people, recover what was scattered, and prove that Dark Iron loyalty is earned in heat, craft, and memory.",
    zone = "Stormwind Embassy / Blackrock Depths",
    expansion = "Shadowlands",
    faction = "Alliance",
    race = "DarkIronDwarf",
    requiredLevel = 50,
    achievementID = 13076,
    achievementName = "Heritage o' the Dark Iron",
    achievements = { 13076 },
    color = { 0.45, 0.28, 0.22 },
    adventureGuideInstanceName = "Blackrock Depths",
    startQuest = { id = 51483, name = "Heritage o' the Dark Iron", npc = "Automatic", location = "Alliance city call-up", mapID = 242, x = 0.3500, y = 0.3800, location = "Stormwind Embassy / Blackrock Depths" },
    npcLocations = {
        ["Moira Thaurissan"] = { mapID = 87, x = 0.2460, y = 0.5350 }, -- Hall of Explorers / Ironforge area (approx)
        ["Anvil-Thane Thurgaden"] = { mapID = 242, x = 0.5700, y = 0.3180 }, -- Blackrock Depths (approx)
        ["Kasea Angerforge"] = { mapID = 242, x = 0.4780, y = 0.4640 }, -- Blackrock Depths (approx)
    },
    chapterIcons = {
        ["Heritage o' the Dark Iron"] = "Interface\\Icons\\inv_helm_plate_raidwarrior_p_01",
    },
    chapterDisplayIDs = {
        ["Heritage o' the Dark Iron"] = 85249,
    },
    chapters = {
        {
            chapter = "Heritage o' the Dark Iron",
            summary = "Win back the Anvil-Thane's designs and reforge Dark Iron pride through craft and grit.",
            recap = "The Dark Iron legacy is forged, not inherited. By proving your worth in brawls, smithing, and service, you helped secure the clan's heritage for a new era.",
            quests = {
                { id = 51483, name = "Heritage o' the Dark Iron", npc = "Automatic", mapID = 242, x = 0.3500, y = 0.3800, location = "Heritage o' the Dark Iron, Stormwind Embassy / Blackrock Depths" },
                { id = 63494, name = "The Anvil-Thane's Designs", npc = "Anvil-Thane Thurgaden" },
                { id = 63498, name = "Brawl or Brew", npc = "Strongarm Jarden", mapID = 242, x = 0.3500, y = 0.3800, location = "Heritage o' the Dark Iron, Stormwind Embassy / Blackrock Depths" },
                { id = 63501, name = "It's Called Borrowing", npc = "Thurgaden's Designs", mapID = 242, x = 0.3500, y = 0.3800, location = "Heritage o' the Dark Iron, Stormwind Embassy / Blackrock Depths" },
                { id = 63502, name = "Weapons o' the Dark Iron", npc = "Anvil-Thane Thurgaden" },
                { id = 65563, name = "Delivery for Kasea", npc = "Anvil-Thane Thurgaden" },
                { id = 65564, name = "Good Fiery Boy", npc = "Kasea Angerforge" },
            },
        },
    },
}

return SM
