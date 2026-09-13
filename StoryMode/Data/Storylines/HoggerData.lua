local addonName, SM = ...

-- =============================================================================
-- Classic: Hogger
-- A short Alliance Elwynn story around Classic's earliest infamous elite.
-- =============================================================================

SM.HoggerData = {
    title = "Hogger",
    description = "Marshal Dughan has posted a bounty at Westbrook Garrison. A Riverpaw brute named Hogger is prowling the woods, and Stormwind wants proof that the roads are safer.\n\nTake the warrant, follow the ridge southwest, and see why the locals speak his name with more concern than a single gnoll should earn.",
    zone = "Elwynn Forest",
    expansion = "Classic",
    recommendedLevel = { min = 5, max = 11 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.78, 0.55, 0.28 },
    icon = "Interface\\Icons\\INV_Misc_MonsterClaw_04",
    portraitDisplayID = 384,
    adventureCoverTexture = 131838, -- Dungeon: darker Classic loading screen for Hogger's lair mood
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 176, name = "Wanted: \"Hogger\"", npc = "Wanted Poster", location = "Westbrook Garrison, Elwynn Forest" },
    startMapID = 37,
    startX = 0.2470,
    startY = 0.7900,

    npcLocations = {
        ["Wanted Poster"] = { mapID = 37, x = 0.2470, y = 0.7900, location = "Westbrook Garrison, Elwynn Forest" },
        ["Hogger"] = { mapID = 37, x = 0.2590, y = 0.8840, location = "Forest's Edge, Elwynn Forest" },
        ["Marshal Dughan"] = { mapID = 37, x = 0.4210, y = 0.6590, location = "Goldshire, Elwynn Forest" },
    },

    npcDisplayIDs = {
        ["Hogger"] = 384,
        ["Marshal Dughan"] = 1985,
    },

    chapterDisplayIDs = {
        ["The Scourge of Elwynn"] = 384,
    },

    chapterIcons = {
        ["The Scourge of Elwynn"] = "Interface\\Icons\\INV_Misc_MonsterClaw_04",
    },

    chapters = {
        {
            chapter = "The Scourge of Elwynn",
            summary = "Read the wanted poster outside Westbrook Garrison and hunt Hogger, the Riverpaw gnoll terrorizing southwestern Elwynn.",
            recap = "The notice at Westbrook Garrison named a gnoll and a claw. Forest's Edge taught the rest. Hogger stood among the Riverpaw with enough strength to make a simple bounty feel like a hard lesson in the wilds beyond Elwynn's roads. When Marshal Dughan received the claw, the border toward Westfall felt less like open countryside and more like a warning.",
            quests = {
                { id = 176, name = "Wanted: \"Hogger\"", npc = "Wanted Poster" },
            },
        },
    },
}
