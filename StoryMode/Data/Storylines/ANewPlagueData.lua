local addonName, SM = ...

-- =============================================================================
-- Classic: A New Plague
-- The Royal Apothecary Society's early plague research, from Brill to Hillsbrad.
-- =============================================================================

SM.ANewPlagueData = {
    title = "A New Plague",
    description = "Apothecary Johaan has work in Brill, and it is not the sort of work the living would approve of. The Forsaken need samples, records, and willing hands if they are to learn what can still kill the dead.\n\nBegin with the Royal Apothecary Society's errands in Tirisfal and follow the plague work into Silverpine and Hillsbrad. Each vial answers one question and raises another.",
    zone = "Tirisfal Glades / Silverpine Forest / Hillsbrad Foothills",
    expansion = "Classic",
    recommendedLevel = { min = 6, max = 32 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.45, 0.72, 0.36 },
    icon = 136066,
    portraitDisplayID = 1565,
    adventureCoverTexture = 131868, -- Scholomance loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 367, name = "A New Plague", npc = "Apothecary Johaan", location = "Gallows' End Tavern, Brill" },
    startMapID = 18,
    startX = 0.5945,
    startY = 0.5240,

    npcLocations = {
        ["Apothecary Johaan"] = { mapID = 18, x = 0.5945, y = 0.5240, location = "Gallows' End Tavern, Brill" },
        ["Captured Mountaineer"] = { mapID = 18, x = 0.5900, y = 0.5200, location = "cellar of Gallows' End Tavern, Brill" },
        ["Apothecary Renferrel"] = { mapID = 21, x = 0.4290, y = 0.4090, location = "the Sepulcher, Silverpine Forest" },
        ["Master Apothecary Faranell"] = { mapID = 90, x = 0.4800, y = 0.6900, location = "the Apothecarium, Undercity" },
        ["Apothecary Lydon"] = { mapID = 25, x = 0.6160, y = 0.1900, location = "Tarren Mill, Hillsbrad Foothills" },
        ["Umpi"] = { mapID = 25, x = 0.6160, y = 0.1900, location = "Apothecary Lydon's room, Tarren Mill" },
        ["Stanley"] = { mapID = 25, x = 0.3200, y = 0.3500, location = "the northern farm in Hillsbrad Fields" },
        ["Berard's Journal"] = { mapID = 21, x = 0.4300, y = 0.7300, location = "Pyrewood Village Inn, Silverpine Forest" },
        ["Nethander Stead"] = { mapID = 25, x = 0.6400, y = 0.6200, location = "Nethander Stead, Hillsbrad Foothills" },
        ["Dun Garok"] = { mapID = 25, x = 0.7100, y = 0.8000, location = "Dun Garok, southeastern Hillsbrad Foothills" },
        ["Dusty Rug"] = { mapID = 25, x = 0.6200, y = 0.1800, location = "upstairs in the Tarren Mill inn" },
    },

    npcDisplayIDs = {
        ["Apothecary Johaan"] = 1565,
        ["Apothecary Renferrel"] = 1661,
        ["Master Apothecary Faranell"] = 1680,
        ["Apothecary Lydon"] = 1660,
        ["Umpi"] = 901,
        ["Stanley"] = 855,
        ["Captured Mountaineer"] = 11426,
    },

    chapterDisplayIDs = {
        ["Johaan's Formula"] = 1565,
        ["A Recipe for Death"] = 1661,
        ["Tarren Mill Trials"] = 1660,
        ["Plagued Brew"] = 1660,
    },

    chapterIcons = {
        ["Johaan's Formula"] = 136066,
        ["A Recipe for Death"] = 134941,
        ["Tarren Mill Trials"] = 136067,
        ["Plagued Brew"] = 132792,
    },

    chapters = {
        {
            chapter = "Johaan's Formula",
            summary = "Gather Johaan's ingredients around Brill and bring the mixture to the prisoner in the Gallows' End Tavern.",
            recap = "Apothecary Johaan began with blood, scales, and venom gathered from the creatures near Brill. In the tavern cellar, a captured mountaineer became the first proof that the new plague could be more than theory.",
            quests = {
                { id = 367, name = "A New Plague", displayName = "Darkhound Blood", npc = "Apothecary Johaan" },
                { id = 368, name = "A New Plague", displayName = "Vile Fin Scales", npc = "Apothecary Johaan" },
                { id = 369, name = "A New Plague", displayName = "Night Web Venom", npc = "Apothecary Johaan" },
                { id = 492, name = "A New Plague", displayName = "Johaan's Special Drink", npc = "Apothecary Johaan" },
                { id = 445, name = "Delivery to Silverpine Forest", npc = "Apothecary Johaan" },
            },
        },
        {
            chapter = "A Recipe for Death",
            summary = "Take Johaan's work to Silverpine, recover Berard's research, and bring Faranell the samples he requires.",
            recap = "Renferrel and Faranell carried the work beyond Brill. Berard's journal, Pyrewood's danger, and the samples from Lake Lordamere gave the apothecaries older knowledge to add to their new recipe.",
            quests = {
                { id = 447, name = "A Recipe For Death", npc = "Apothecary Renferrel" },
                { id = 450, name = "A Recipe For Death", displayName = "Berard's Journal", npc = "Master Apothecary Faranell" },
                { id = 451, name = "A Recipe For Death", displayName = "Lake Lordamere Samples", npc = "Apothecary Renferrel" },
            },
        },
        {
            chapter = "Tarren Mill Trials",
            summary = "Report to Apothecary Lydon in Hillsbrad and gather what he needs for his next field trials.",
            recap = "Lydon's work in Tarren Mill turned research into local experiment. Tongues, ichor, and mountain lion blood became elixirs, and the tests on Umpi and Stanley showed how cruelly effective they could be.",
            quests = {
                { id = 496, name = "Elixir of Suffering", npc = "Apothecary Lydon" },
                { id = 499, name = "Elixir of Suffering", displayName = "Umpi", npc = "Apothecary Lydon" },
                { id = 501, name = "Elixir of Pain", npc = "Apothecary Lydon" },
                { id = 502, name = "Elixir of Pain", displayName = "Stanley", npc = "Apothecary Lydon" },
            },
        },
        {
            chapter = "Plagued Brew",
            summary = "Help Lydon finish the Elixir of Agony and find a way to deliver it to the captured farmers upstairs.",
            recap = "The Elixir of Agony passed from blossom to composite, from Faranell's decay to Lydon's final activation. With Dun Garok stout as the vessel, the inn itself became the last test.",
            quests = {
                { id = 509, name = "Elixir of Agony", displayName = "Mudsnout Blossoms", npc = "Apothecary Lydon" },
                { id = 513, name = "Elixir of Agony", displayName = "Mudsnout Composite", npc = "Apothecary Lydon" },
                { id = 515, name = "Elixir of Agony", displayName = "Faranell's Mixture", npc = "Master Apothecary Faranell" },
                { id = 517, name = "Elixir of Agony", displayName = "Shindigger Stout", npc = "Apothecary Lydon" },
                { id = 524, name = "Elixir of Agony", displayName = "Tainted Keg", npc = "Apothecary Lydon" },
            },
        },
    },
}
