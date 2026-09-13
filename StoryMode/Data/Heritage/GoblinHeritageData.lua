local addonName, SM = ...

SM.GoblinHeritageData = {
    title = "Heritage of Kezan",
    description = "Hobart Grapplehammer has a masterpiece, a deadline, and a former employer determined that neither will reach completion. Trade Prince Gallywix has eyes everywhere, and the workshop where the work has to happen is exactly as glamorous as Crapopolis sounds.\n\nReunite old allies, outplay better-funded saboteurs, and keep one bombastic invention from being seized, sold, stolen, exploded, or all four in sequence.",
    zone = "Stranglethorn / Crapopolis",
    expansion = "Battle for Azeroth",
    faction = "Horde",
    race = "Goblin",
    requiredLevel = 50,
    achievementName = "Heritage of Kezan",
    achievements = {},
    color = { 0.25, 0.72, 0.20 },
    icon = "Interface\\Icons\\inv_chest_armor_goblin_d_01",
    adventureGuideInstanceName = "The MOTHERLODE!!",
    startQuest = { id = 57043, name = "Old Friends, New Opportunities", npc = "Izzy", location = "Orgrimmar Embassy" },
    startMapID = 85,
    startX = 0.3790,
    startY = 0.8130,
    npcLocations = {
        ["Izzy"] = { mapID = 85, x = 0.3790, y = 0.8130, location = "Stranglethorn / Crapopolis" },
        ["Sassy Hardwrench"] = { mapID = 85, x = 0.3460, y = 0.2860 , location = "Stranglethorn / Crapopolis"},
        ["Hobart Grapplehammer"] = { mapID = 210, x = 0.5200, y = 0.5200 }, -- Crapopolis area (approx)
    },
    npcDisplayIDs = {
        ["Sassy Hardwrench"] = 33206,
        ["Hobart Grapplehammer"] = 92727,
        ["Izzy"] = 29482,
    },
    chapterIcons = {
        ["Heritage of Kezan"] = "Interface\\Icons\\inv_chest_armor_goblin_d_01",
    },
    chapterDisplayIDs = {
        ["Heritage of Kezan"] = 29482,
    },
    chapters = {
        {
            chapter = "Heritage of Kezan",
            summary = "Build, test, and defend the X-52 while goblin politics and greed explode all around you.",
            recap = "Business, betrayal, and big explosions: a proper goblin story. You helped Hobart finish the X-52, survived every reckless test, crushed Gallywix's takeover, and earned the right to wear the pride of Kezan.",
            quests = {
                { id = 57043, name = "Old Friends, New Opportunities", npc = "Izzy" },
                { id = 57045, name = "A Special Delivery", npc = "Sassy Hardwrench" },
                { id = 57047, name = "A Simple Experiment", npc = "Hobart Grapplehammer" },
                { id = 57048, name = "Shopping For Parts", npc = "Hobart Grapplehammer" },
                { id = 57051, name = "Debt Collection!", npc = "Crank Greasefuse", mapID = 210, x = 0.5200, y = 0.5200, location = "Heritage of Kezan, Stranglethorn / Crapopolis" },
                { id = 57052, name = "I've Got What You Need", npc = "Crank Greasefuse", mapID = 210, x = 0.5200, y = 0.5200, location = "Heritage of Kezan, Stranglethorn / Crapopolis" },
                { id = 57053, name = "Blunt Force Testing", npc = "Hobart Grapplehammer" },
                { id = 57058, name = "Fun With Landmines", npc = "Hobart Grapplehammer" },
                { id = 57059, name = "Let's Rumble!", npc = "Hobart Grapplehammer" },
                { id = 57077, name = "Buyers Wanted!", npc = "Hobart Grapplehammer" },
                { id = 57078, name = "The VIP List", npc = "Sassy Hardwrench" },
                { id = 57079, name = "Beat The Crapopolis Outta Him!", npc = "Sassy Hardwrench" },
                { id = 57080, name = "A Fitting Reward", npc = "Hobart Grapplehammer" },
            },
        },
    },
}

return SM
