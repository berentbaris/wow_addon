local addonName, SM = ...

SM.BloodElfHeritageData = {
    title = "Heritage of the Sin'dorei",
    description = "Walk with Lor'themar through the memory of Quel'Thalas and what the Sin'dorei lost when Arthas marched on Silvermoon. The grief is older than many kingdoms, and the silence the Scourge left behind still has weight.\n\nStand where names are remembered, face old wounds with care, and honor the heritage of a people whose line endured even when the kingdom nearly did not.",
    zone = "Silvermoon / Ghostlands / Isle of Quel'Danas",
    expansion = "Battle for Azeroth",
    faction = "Horde",
    race = "BloodElf",
    requiredLevel = 50,
    achievementName = "Heritage of the Sin'dorei",
    achievements = {},
    color = { 0.78, 0.16, 0.10 },
    icon = 2459464,
    adventureGuideInstanceName = "Sunwell Plateau",
    startQuest = { id = 53791, name = "The Pride of the Sin'dorei", npc = "Ambassador Dawnsworn", location = "Orgrimmar Embassy" },
    startMapID = 85,
    startX = 0.3790,
    startY = 0.8130,
    npcLocations = {
        ["Ambassador Dawnsworn"] = { mapID = 85, x = 0.3790, y = 0.8130 },
        ["Lor'themar Theron"] = { mapID = 110, x = 0.5380, y = 0.2050 }, -- Silvermoon (approx)
        ["Lady Liadrin"] = { mapID = 122, x = 0.4800, y = 0.3500 }, -- Isle of Quel'Danas (approx)
    },
    npcDisplayIDs = {
        ["Lor'themar Theron"] = 17122,
        ["Lady Liadrin"] = 61971,
        ["Ambassador Dawnsworn"] = 89162,
    },
    chapterIcons = {
        ["Heritage of the Sin'dorei"] = 2459464,
    },
    chapterDisplayIDs = {
        ["Heritage of the Sin'dorei"] = 89162,
    },
    chapters = {
        {
            chapter = "Heritage of the Sin'dorei",
            summary = "Retrace the Scourge invasion and witness the memories that shaped the blood elves.",
            recap = "The Sin'dorei remember through ritual, grief, and endurance. You carried the Sunwell's flame through Ghostlands and Quel'Danas, stood witness to the fall of legends, and helped preserve the memory that still defines your people.",
            quests = {
                { id = 53791, name = "The Pride of the Sin'dorei", npc = "Ambassador Dawnsworn" },
                { id = 53734, name = "Walk Among Ghosts", npc = "Lor'themar Theron" },
                { id = 53882, name = "Writing on the Wall", npc = "Lor'themar Theron" },
                { id = 53735, name = "The First to Fall", npc = "Lor'themar Theron" },
                { id = 53736, name = "Lament of the Highborne", npc = "Lor'themar Theron" },
                { id = 53737, name = "The Day Hope Died", npc = "Lor'themar Theron" },
                { id = 53738, name = "Defense of Quel'Danas", npc = "Lor'themar Theron" },
                { id = 53725, name = "A People Shattered", npc = "Lady Liadrin" },
                { id = 53853, name = "The Setting Sun", npc = "Lady Liadrin" },
                { id = 54096, name = "The Fall of the Sunwell", npc = "Lady Liadrin" },
            },
        },
    },
}

return SM
