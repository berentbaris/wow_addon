local addonName, SM = ...

SM.DwarfHeritageData = {
    title = "Heritage of the Bronzebeard",
    description = "Delve into Ironforge's deepest archives with Brann Bronzebeard, who has kept the chronicles longer than most dwarves have been alive. An old relic of the Bronzebeard line has been broken and scattered across roads with long memories.\n\nWalk those roads again, recover what was lost, and return to the great anvils where dwarven legacy is measured in craft, stubbornness, and stone.",
    zone = "Ironforge / Dun Morogh / Loch Modan",
    expansion = "Battle for Azeroth",
    faction = "Alliance",
    race = "Dwarf",
    requiredLevel = 50,
    achievementName = "Heritage of the Bronzebeard",
    achievements = {},
    color = { 0.73, 0.55, 0.31 },
    icon = "Interface\\Icons\\inv_misc_tournaments_banner_dwarf",
    adventureGuideInstanceName = "Uldaman",
    startQuest = { id = 53838, name = "Keep Yer Feet On The Ground", npc = "Digger Golad", location = "Stormwind Embassy" },
    npcLocations = {
        ["Digger Golad"] = { mapID = 84, x = 0.5220, y = 0.1350 }, -- Stormwind Embassy
        ["Brann Bronzebeard"] = { mapID = 87, x = 0.3500, y = 0.4880 },
        ["Advisor Belgrum"] = { mapID = 87, x = 0.3950, y = 0.5490 }, -- Ironforge (approx)
    },
    npcDisplayIDs = {
        ["Digger Golad"] = 89470,
    },
    chapterIcons = {
        ["Heritage of the Bronzebeard"] = "Interface\\Icons\\inv_misc_tournaments_banner_dwarf",
    },
    chapterDisplayIDs = {
        ["Heritage of the Bronzebeard"] = 89470,
    },
    chapters = {
        {
            chapter = "Heritage of the Bronzebeard",
            summary = "Recover, restore, and reforge an ancient Bronzebeard relic.",
            recap = "Through trogg-infested ruins, ancient records, and the heat of the forge, you helped restore a lost legacy and carry the mountain king's heritage into the present.",
            quests = {
                { id = 53838, name = "Keep Yer Feet On The Ground", npc = "Digger Golad" },
                { id = 53835, name = "Something Valuable, Perhaps?", npc = "Ancient Tablet", mapID = 84, x = 0.5220, y = 0.1350, location = "Stormwind Embassy" },
                { id = 53836, name = "Ancient Armor, Ancient Mystery", npc = "Brann Bronzebeard" },
                { id = 53837, name = "Watch Yer Back", npc = "Advisor Belgrum" },
                { id = 53839, name = "Aegrim's Study", npc = "Advisor Belgrum" },
                { id = 53841, name = "Shards of the Past", npc = "Armor Stand", mapID = 87, x = 0.3950, y = 0.5490, location = "the High Seat, Ironforge" },
                { id = 53840, name = "Interest Yah In A Pint?", npc = "Brann Bronzebeard" },
                { id = 53844, name = "Recruiting the Furnace Master", npc = "Brann Bronzebeard" },
                { id = 53842, name = "Earthen Blessing", npc = "Brann Bronzebeard" },
                { id = 53845, name = "Forging the Armor", npc = "Grumnus Steelshaper", mapID = 87, x = 0.3980, y = 0.5560, location = "the Great Forge, Ironforge" },
                { id = 53846, name = "Legacy of the Bronzebeard", npc = "Brann Bronzebeard" },
            },
        },
    },
}

return SM
