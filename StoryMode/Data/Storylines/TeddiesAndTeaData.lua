local addonName, SM = ...

-- =============================================================================
-- A Tea Party
-- A short story in Drustvar. Four quests. Starts sweet. Ends badly.
-- =============================================================================

SM.TeddiesAndTeaData = {
    title       = "A Tea Party",
    description = "A little girl stands alone at Glenbrook Homestead, singing a nursery rhyme about her empty village. The chimneys are still warm, the tables are still set, and the silence feels much too fresh.\n\nShe only wants help preparing a tea party: a few toys, a missing cat, and one more guest. In Drustvar, even the smallest errands can carry a shadow longer than the road ahead.",
    zone        = "Drustvar",
    expansion   = "Battle for Azeroth",
    achievements = {},
    color       = { 0.40, 0.62, 0.30 },   -- Drustvar deep forest green
    factions    = { 2161 },                -- Order of Embers
    portraitDisplayID = 76515,             -- Abby Lewis
    adventureGuideInstanceName = "Waycrest Manor",

    startQuest = { id = 47289, name = "Teddies and Tea", npc = "Abby Lewis", location = "Glenbrook Homestead, Drustvar" },
    startMapID = 896,
    startX     = 0.5440,
    startY     = 0.3935,

    npcLocations = {
        ["Abby Lewis"]    = { mapID = 896, x = 0.5440, y = 0.3935, location = "Glenbrook Homestead, Drustvar" },
        ["Annie Warren"]  = { mapID = 896, x = 0.4580, y = 0.7450 },
        ["Mangled Body"] = { mapID = 896, x = 0.5460, y = 0.4900, location = "Drustvar" },
    },

    npcDisplayIDs = {
        ["Abby Lewis"]   = 76515,
        ["Annie Warren"] = 79761,
    },
    chapterDisplayIDs = {
        ["Teddies and Tea"] = 76515,
        ["A Tea Party"]     = 79761,
    },
    chapterIcons = {
        ["Teddies and Tea"] = 76515,
        ["A Tea Party"]     = 79761,
    },

    chapters = {
        {
            chapter = "Teddies and Tea",
            summary = "A girl is singing by herself at an empty homestead. She asks you to find her stuffed animals for a tea party. As you collect each one, she recites little rhymes about what happened to the people who used to live here. The rhymes are not comforting.",
            recap = "Abby Lewis stood alone at Glenbrook Homestead, singing softly to herself. The houses were abandoned. The village was silent. She said she just wanted friends for a tea party — three stuffed animals: Mr. Munchykins, Trunksy, and Mayor Striggs. You found them, each one near a place where something had clearly gone very wrong. Abby appeared each time to recite a cheerful little rhyme. The rhymes were about the dead.",
            quests = {
                { id = 47289, name = "Teddies and Tea", npc = "Abby Lewis" },
                { id = 47428, name = "Kitty?",          npc = "Abby Lewis" },
            },
        },
        {
            chapter = "A Tea Party",
            summary = "Abby has vanished. You find a village register — nearly every name crossed out. Three people may still be alive: the Hayeses and Samuel Hawthorne. They are not. Then Abby reappears, lights the candles, pours the tea, and introduces the last guest.",
            recap = "When Smoochums was found in the woods, Abby was gone. In her place: a register listing every Glenbrook villager — most names struck through. Jonathan Hayes had his heart removed for a ritual. Samuel Hawthorne lay dead in the trees. Mary Hayes had turned witch and killed her own husband. Only Annie Warren survived, barely, imprisoned in a cave.\n\nAbby came back. She led you to a circle of candles with Smoochums — the cat, now sacrificed — at the center. She poured the tea. She said there was one more guest to meet. Then she ran, and the Conjured Horror arrived in her place.",
            quests = {
                { id = 53464, name = "The Village of Glenbrook", npc = "Annie Warren" },
                { id = 53465, name = "Tea Party",                npc = "Mangled Body" },
            },
        },
    },
}
