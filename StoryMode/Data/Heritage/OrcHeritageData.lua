local addonName, SM = ...

SM.OrcHeritageData = {
    title = "Heritage of Draenor",
    description = "Stand with Eitrigg, Aggra, and the clans as the Kosh'harg, the great festival of clan and ancestor, is reborn on Azeroth. The Horde has crossed worlds and survived wars, but some rites still need hands to carry them forward.\n\nWalk through Durotar and Nagrand with shamans and young initiates, hear the names of forebears spoken aloud, and remember that orc heritage is more than fang or blade.",
    zone = "Orgrimmar / Durotar",
    expansion = "Dragonflight",
    faction = "Horde",
    race = "Orc",
    requiredLevel = 50,
    achievementName = "Heritage of Draenor",
    achievements = {},
    color = { 0.65, 0.20, 0.15 },
    icon = 4898329,
    adventureGuideInstanceName = "Siege of Orgrimmar",
    startQuest = { id = 72462, name = "A People in Need of Healing", npc = "Eitrigg", location = "Grommash Hold, Orgrimmar" },
    npcLocations = {
        ["Eitrigg"] = { mapID = 85, x = 0.4860, y = 0.7600 }, -- Grommash Hold (approx)
        ["Aggra"] = { mapID = 85, x = 0.4870, y = 0.7580 }, -- Grommash Hold (approx)
        ["Farseer Aggralan"] = { mapID = 1, x = 0.5240, y = 0.4320 }, -- Durotar (approx)
        ["Thrall"] = { mapID = 1, x = 0.5260, y = 0.4300 }, -- Durotar/Kosh'harg area (approx)
    },
    chapterIcons = {
        ["Heritage of Draenor"] = 82115,
    },
    chapterDisplayIDs = {
        ["Heritage of Draenor"] = 82115,
    },
    chapters = {
        {
            chapter = "Heritage of Draenor",
            summary = "Revive old rites and prove yourself to the spirit of orcish tradition.",
            recap = "The clans gathered once more, and old ways found new meaning. Through trials of land, clan, and ancestors, you helped the orcs reclaim identity not as they were, but as they choose to be now.",
            quests = {
                { id = 73703, name = "A Summon to Orgrimmar", npc = "Automatic", mapID = 85, x = 0.4860, y = 0.7600, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 72462, name = "A People in Need of Healing", npc = "Eitrigg" },
                { id = 72464, name = "The Kosh'harg", npc = "Aggra" },
                { id = 72467, name = "The Blessing of the Clan", npc = "Farseer Aggralan" },
                { id = 74581, name = "The Long Knives", npc = "Thega Graveblade", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 72474, name = "Tracking a Killer", npc = "Kaltunk", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 72475, name = "Cornering Gor'krosh", npc = "Kaltunk", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 72465, name = "The Blessing of the Land", npc = "Farseer Aggralan" },
                { id = 72466, name = "The Spirit of Thunder Ridge", npc = "The Spirit of Thunder Ridge", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 72476, name = "The Blessing of the Ancestors", npc = "Farseer Aggralan" },
                { id = 72463, name = "Galgar's Cactus Apple Surprise...", npc = "Bag of Cactus Apples", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 74374, name = "An Important Heirloom", npc = "Cook Torka", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 72477, name = "Orcish Groceries", npc = "Cook Torka", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 74415, name = "A Worthy Offering", npc = "Durak", mapID = 1, x = 0.5240, y = 0.4320, location = "Heritage of Draenor, Orgrimmar / Durotar" },
                { id = 72478, name = "Honor and Glory", npc = "Farseer Aggralan" },
                { id = 72479, name = "Aka'magosh", npc = "Thrall" },
            },
        },
    },
}

return SM
