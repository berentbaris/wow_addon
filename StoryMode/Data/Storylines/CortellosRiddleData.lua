local addonName, SM = ...

-- =============================================================================
-- Classic: Cortello's Riddle
-- A pirate-ship scroll that turns into a three-zone treasure hunt.
-- =============================================================================

SM.CortellosRiddleData = {
    title = "Cortello's Riddle",
    description = "A small scroll waits aboard a Bloodsail ship south of Booty Bay. It bears no proper patron, only a riddle and enough direction to make you wonder what was hidden.\n\nTake Cortello's words seriously and follow the clues wherever they send you. The treasure is not marked for anyone who wants a straight road.",
    zone = "Stranglethorn Vale / Swamp of Sorrows / Dustwallow Marsh / The Hinterlands",
    expansion = "Classic",
    recommendedLevel = { min = 43, max = 51 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.29, 0.54, 0.63 },
    icon = 134331,
    adventureCoverTexture = 131886, -- Zul'Gurub loading screen: shared Classic/TBC jungle cover
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 624, name = "Cortello's Riddle", npc = "Cortello's Riddle", location = "the Bloodsail ships off the Wild Shore, Stranglethorn Vale" },
    startMapID = 50,
    startX = 0.3000,
    startY = 0.8900,

    npcLocations = {
        ["Cortello's Riddle"] = { mapID = 50, x = 0.3000, y = 0.8900, location = "the Bloodsail ships off the Wild Shore, Stranglethorn Vale" },
        ["A Soggy Scroll"] = { mapID = 51, x = 0.2200, y = 0.4800, location = "under the first wooden bridge west of Stonard, Swamp of Sorrows" },
        ["Cortello's Treasure"] = { mapID = 26, x = 0.8100, y = 0.4700, location = "under the great eastern waterfall, The Hinterlands" },
    },

    chapterIcons = {
        ["The Soggy Scroll"] = 134331,
        ["Bloodfen Burrow"] = 134939,
        ["Under the Great Falls"] = 133634,
    },

    chapters = {
        {
            chapter = "The Soggy Scroll",
            summary = "Read the scroll found aboard the Bloodsail ship and follow only the clue Cortello left behind.",
            recap = "The first scroll waited in the hold of a Bloodsail ship with no one to explain it. Its verse led you beneath a bridge in the Swamp of Sorrows, where the next clue lay in the mud.",
            quests = {
                { id = 624, name = "Cortello's Riddle", npc = "Cortello's Riddle" },
            },
        },
        {
            chapter = "Bloodfen Burrow",
            summary = "Take the soggy clue at its word and look for the next scrap where the riddle says it waits.",
            recap = "The second clue turned the riddle into a journey across the sea. In Dustwallow, among Bloodfen raptors, another scrap waited for anyone stubborn enough to keep reading.",
            quests = {
                { id = 625, name = "Cortello's Riddle", npc = "A Soggy Scroll" },
            },
        },
        {
            chapter = "Under the Great Falls",
            summary = "Trust the musty scroll's final verse and search where Cortello chose to hide his prize.",
            recap = "The final clue led to the great falls on the Hinterlands coast. Under the water, after pirates, mud, and raptors, Cortello's chest waited with a reward fit for a traveler.",
            quests = {
                { id = 626, name = "Cortello's Riddle", npc = "Musty Scroll", mapID = 70, x = 0.3100, y = 0.6600, location = "Bloodfen Burrow, southwestern Dustwallow Marsh" },
            },
        },
    },
}
