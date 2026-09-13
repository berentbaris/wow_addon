local addonName, SM = ...

-- =============================================================================
-- Classic: The Missing Courier
-- Feathermoon's lost courier, a wrecked boat, and the first signs of silithid.
-- =============================================================================

SM.MissingCourierData = {
    title = "The Missing Courier",
    description = "Feathermoon Stronghold expected a courier from Thalanaar. He never arrived, and the coast of Feralas has a way of swallowing small boats and easy answers.\n\nSearch the wreckage, carry back what proof you can, and follow the signs inland if the sea is not the whole story.",
    zone = "Feralas / Darnassus",
    expansion = "Classic",
    recommendedLevel = { min = 43, max = 46 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.30, 0.48, 0.70 },
    icon = 134328,
    portraitDisplayID = 2035,
    adventureCoverTexture = 131878, -- Blackfathom Deeps: night elf coastal ruin mood closest to Feathermoon's investigation
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 4124, name = "The Missing Courier", npc = "Latronicus Moonspear", location = "Feathermoon Stronghold, Feralas" },
    startMapID = 69,
    startX = 0.3050,
    startY = 0.4620,

    npcLocations = {
        ["Latronicus Moonspear"] = { mapID = 69, x = 0.3050, y = 0.4620, location = "Feathermoon Stronghold, Feralas" },
        ["Ginro Hearthkindle"] = { mapID = 69, x = 0.3200, y = 0.4500, location = "upstairs in Feathermoon Stronghold, Feralas" },
        ["Wrecked Row Boat"] = { mapID = 69, x = 0.4564, y = 0.6500, location = "the Forgotten Coast, Feralas" },
        ["Quintis Jonespyre"] = { mapID = 69, x = 0.3200, y = 0.4400, location = "the upper treehouse, Feathermoon Stronghold" },
        ["Large Leather Backpacks"] = { mapID = 69, x = 0.7300, y = 0.5600, location = "a Woodpaw gnoll camp in southern Feralas" },
        ["Undelivered Parcel"] = { mapID = 69, x = 0.7300, y = 0.5600, location = "inside the Large Leather Backpacks, southern Feralas" },
        ["Zukk'ash Pod"] = { mapID = 69, x = 0.7200, y = 0.6400, location = "inside the Writhing Deep, southern Feralas" },
        ["Falfindel Waywarder"] = { mapID = 69, x = 0.8900, y = 0.4600, location = "Thalanaar, southeastern Feralas" },
        ["Shandris Feathermoon"] = { mapID = 69, x = 0.3050, y = 0.4620, location = "Feathermoon Stronghold, Feralas" },
        ["Gracina Spiritmight"] = { mapID = 89, x = 0.4100, y = 0.8500, location = "the Temple of the Moon, Darnassus" },
    },

    npcDisplayIDs = {
        ["Latronicus Moonspear"] = 2035,
        ["Ginro Hearthkindle"] = 6789,
        ["Quintis Jonespyre"] = 7232,
        ["Falfindel Waywarder"] = 6978,
        ["Shandris Feathermoon"] = 2035,
        ["Gracina Spiritmight"] = 3796,
    },

    chapterDisplayIDs = {
        ["Wreckage"] = 6789,
        ["The Knife"] = 7232,
        ["The Courier's Trail"] = 6789,
        ["The Writhing Deep"] = 2035,
    },

    chapterIcons = {
        ["Wreckage"] = 134327,
        ["The Knife"] = 135650,
        ["The Courier's Trail"] = 133639,
        ["The Writhing Deep"] = 136045,
    },

    chapters = {
        {
            chapter = "Wreckage",
            summary = "Latronicus sends you to Ginro Hearthkindle, who needs the Feralas coast searched for Raschal's missing boat.",
            recap = "The investigation began with resignation. Latronicus had already declared Raschal missing in action, and Ginro Hearthkindle had spent a week searching Feralas for nothing but gnoll teeth and disappointment. The wrecked row boat on the Forgotten Coast changed that. It was shredded almost in two, marked with Feathermoon's crest, and hiding one small clue in the mud: Raschal's knife.",
            quests = {
                { id = 4124, name = "The Missing Courier", displayName = "Ginro Hearthkindle", npc = "Latronicus Moonspear" },
                { id = 4125, name = "The Missing Courier", displayName = "Wrecked Row Boat", npc = "Ginro Hearthkindle" },
                { id = 4127, name = "Boat Wreckage", npc = "Wrecked Row Boat" },
            },
        },
        {
            chapter = "The Knife",
            summary = "Bring Raschal's knife to Quintis Jonespyre and let the blade show what ordinary searching could not.",
            recap = "Ginro's next idea was strange even by night elf standards: give the knife to Quintis Jonespyre and let psychometry do what ordinary tracking could not. Quintis saw Raschal taking two large leather backpacks inland, worrying over Woodpaw gnolls, and failing to notice water elementals forming behind him. The knife did not solve the mystery, but it gave the search a direction and a new fear: Raschal had found something worse than gnolls.",
            quests = {
                { id = 4129, name = "The Knife Revealed", npc = "Ginro Hearthkindle" },
                { id = 4130, name = "Psychometric Reading", npc = "Quintis Jonespyre" },
            },
        },
        {
            chapter = "The Courier's Trail",
            summary = "Search the Woodpaw camps for Raschal's missing packs and any sign of where his errand went next.",
            recap = "The Woodpaw trail looked at first like scavenging. Then you found Raschal's backpacks pinned to a tree, still bearing Feathermoon insignia. One parcel could be delivered to Thalanaar, a small duty completed in the middle of the search. The other evidence mattered more: a note about strange insect creatures south of the gnoll camps. Raschal had not merely been attacked. He had chosen to investigate a threat under Feralas.",
            quests = {
                { id = 4131, name = "The Woodpaw Gnolls", npc = "Ginro Hearthkindle" },
                { id = 4281, name = "Thalanaar Delivery", npc = "Undelivered Parcel", optional = true },
            },
        },
        {
            chapter = "The Writhing Deep",
            summary = "Follow the last sign into the hive and learn whether Raschal's errand can still be answered.",
            recap = "The Writhing Deep made the whole case larger. Raschal was alive, sealed inside an alien pod by the Zukk'ash, and his report confirmed that Feralas was facing something more dangerous than a local hive. Shandris Feathermoon sent the warning to Darnassus, where Gracina Spiritmight named the threat: silithid. What began as a missing courier ended as an early warning about the insect menace waiting beneath Azeroth's southern deserts.",
            quests = {
                { id = 4135, name = "The Writhing Deep", npc = "Large Leather Backpacks" },
                { id = 4265, name = "Freed from the Hive", npc = "Zukk'ash Pod" },
                { id = 4266, name = "A Hero's Welcome", npc = "Ginro Hearthkindle" },
                { id = 4267, name = "Rise of the Silithid", npc = "Shandris Feathermoon" },
            },
        },
    },
}
