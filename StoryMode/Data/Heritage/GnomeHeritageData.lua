local addonName, SM = ...

SM.GnomeHeritageData = {
    title = "Heritage of Gnomeregan",
    description = "Join the Gnomeregan Engineering and Aviation Reserve as it tests the most ambitious aircraft to leave a workshop since the Great War. Old Gnomeregan is still dangerous, and not every threat beneath the city is content to stay buried.\n\nRecruit specialists, salvage prototypes, and turn brilliant schematics into machines that actually fly, preferably with all limbs and eyebrows accounted for.",
    zone = "New Tinkertown / Borean Tundra / Storm Peaks",
    expansion = "Battle for Azeroth",
    faction = "Alliance",
    race = "Gnome",
    requiredLevel = 50,
    achievementName = "Heritage of Gnomeregan",
    achievements = {},
    color = { 0.75, 0.62, 0.27 },
    icon = "Interface\\Icons\\inv_cape_armor_gnome_d_01",
    adventureGuideInstanceName = "Gnomeregan",
    startQuest = { id = 54402, name = "Shifting Gears", npc = "Ace Pilot Stormcog", location = "Stormwind Embassy" },
    npcLocations = {
        ["Ace Pilot Stormcog"] = { mapID = 84, x = 0.5220, y = 0.1350 }, -- Stormwind Embassy
        ["Captain Tread Sparknozzle"] = { mapID = 27, x = 0.4180, y = 0.3140 },
        ["Fizzi Tinkerbow"] = { mapID = 114, x = 0.3800, y = 0.3400 },
        ["Cog Captain Winklespring"] = { mapID = 120, x = 0.3760, y = 0.6020 },
    },
    chapterIcons = {
        ["Heritage of Gnomeregan"] = "Interface\\Icons\\inv_cape_armor_gnome_d_01",
    },
    chapterDisplayIDs = {
        ["Heritage of Gnomeregan"] = 89819,
    },
    chapters = {
        {
            chapter = "Heritage of Gnomeregan",
            summary = "Lead G.E.A.R. through a high-tech campaign against old enemies and reclaim gnomish pride.",
            recap = "With clever engineering and fearless aerial operations, you dismantled a trogg-backed threat, defeated Sparkspanner, and proved Gnomeregan's ingenuity is stronger than ever.",
            quests = {
                { id = 54402, name = "Shifting Gears", npc = "Ace Pilot Stormcog" },
                { id = 54576, name = "Gnomeregan's Finest", npc = "Captain Tread Sparknozzle" },
                { id = 54577, name = "Shadowed Halls and Dusty Cogs", npc = "Captain Tread Sparknozzle" },
                { id = 54580, name = "A Tundra Conundrum", npc = "Captain Tread Sparknozzle" },
                { id = 54581, name = "Now With More Mechanical Fowl", npc = "Fizzi Tinkerbow" },
                { id = 54582, name = "Smarter Than Your Average Trogg", npc = "Automatic", mapID = 114, x = 0.4120, y = 0.5340, location = "New Tinkertown" },
                { id = 54579, name = "The Gnome Behind the Trogg", npc = "Fizzi Tinkerbow" },
                { id = 54639, name = "A Signal in Storm Peaks", npc = "Fizzi Tinkerbow" },
                { id = 54640, name = "Gnomercy!", npc = "Cog Captain Winklespring" },
                { id = 54850, name = "Operation: Troggageddon", npc = "Cog Captain Winklespring" },
                { id = 54641, name = "For Gnomeregan!", npc = "Cog Captain Winklespring" },
                { id = 54642, name = "G.E.A.R. Up", npc = "Cog Captain Winklespring" },
            },
        },
    },
}

return SM
