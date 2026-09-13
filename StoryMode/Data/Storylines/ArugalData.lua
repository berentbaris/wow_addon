local addonName, SM = ...

-- =============================================================================
-- Classic: Arugal and Shadowfang Keep
-- Silverpine's worgen curse, Ambermill's Dalaran mages, and Arugal's fall.
-- =============================================================================

SM.ArugalData = {
    title = "Arugal and Shadowfang Keep",
    description = "The Sepulcher needs help holding Silverpine Forest. Worgen stalk the roads, Dalaran mages keep their own counsel at Ambermill, and rumors from Shadowfang Keep have not grown quieter.\n\nTake the Forsaken orders one by one and learn why the forest still refuses to be claimed.",
    zone = "Silverpine Forest / Shadowfang Keep",
    expansion = "Classic",
    recommendedLevel = { min = 9, max = 27 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.42, 0.48, 0.58 },
    icon = 136150,
    portraitDisplayID = 2353,
    adventureCoverTexture = 131869, -- Shadowfang Keep loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 421, name = "Prove Your Worth", npc = "Dalar Dawnweaver", location = "the Sepulcher, Silverpine Forest" },
    startMapID = 21,
    startX = 0.4430,
    startY = 0.3950,

    npcLocations = {
        ["Dalar Dawnweaver"] = { mapID = 21, x = 0.4430, y = 0.3950, location = "the Sepulcher, Silverpine Forest" },
        ["Shadow Priest Allister"] = { mapID = 21, x = 0.4340, y = 0.4100, location = "the Sepulcher, Silverpine Forest" },
        ["High Executor Hadrec"] = { mapID = 21, x = 0.4300, y = 0.4100, location = "the Sepulcher, Silverpine Forest" },
        ["Keeper Bel'dugur"] = { mapID = 90, x = 0.5300, y = 0.5400, location = "the Apothecarium, Undercity" },
        ["Dalaran Crate"] = { mapID = 21, x = 0.4989, y = 0.6033, location = "the Dalaran camp north of Pyrewood Village" },
        ["Pyrewood Village"] = { mapID = 21, x = 0.4600, y = 0.7350, location = "Pyrewood Village, Silverpine Forest" },
        ["Ambermill"] = { mapID = 21, x = 0.6100, y = 0.6400, location = "Ambermill, Silverpine Forest" },
        ["Shadowfang Keep"] = { mapID = 21, x = 0.4400, y = 0.6750, location = "Shadowfang Keep, Silverpine Forest" },
        ["Archmage Ataeric"] = { mapID = 21, x = 0.6120, y = 0.6400, location = "Ambermill, Silverpine Forest" },
        ["Archmage Arugal"] = { mapID = 310, x = 0.5120, y = 0.4820, location = "Shadowfang Keep" },
    },

    npcDisplayIDs = {
        ["Dalar Dawnweaver"] = 1278,
        ["Shadow Priest Allister"] = 1948,
        ["High Executor Hadrec"] = 3545,
        ["Keeper Bel'dugur"] = 5751,
        ["Archmage Ataeric"] = 3601,
        ["Archmage Arugal"] = 2353,
    },

    chapterDisplayIDs = {
        ["Arugal's Folly"] = 1278,
        ["Ambermill"] = 3601,
        ["Shadowfang Keep"] = 2353,
    },

    chapterIcons = {
        ["Arugal's Folly"] = 136150,
        ["Ambermill"] = 136096,
        ["Shadowfang Keep"] = 136163,
    },

    chapters = {
        {
            chapter = "Arugal's Folly",
            summary = "Dalar Dawnweaver asks you to thin the Moonrage worgen and recover signs of Arugal's magic.",
            recap = "Dalar Dawnweaver wanted proof that Arugal's curse still stained Silverpine. You hunted Moonrage worgen, recovered the Remedy of Arugal, and struck down those most touched by the mage's work.",
            quests = {
                { id = 421, name = "Prove Your Worth", npc = "Dalar Dawnweaver" },
                { id = 422, name = "Arugal's Folly", displayName = "The Remedy of Arugal", npc = "Dalar Dawnweaver" },
                { id = 423, name = "Arugal's Folly", displayName = "Moonrage Shackles", npc = "Dalar Dawnweaver" },
                { id = 424, name = "Arugal's Folly", displayName = "Grimson the Pale", npc = "Dalar Dawnweaver" },
                { id = 99, name = "Arugal's Folly", displayName = "Pyrewood Shackles", npc = "Dalar Dawnweaver" },
            },
        },
        {
            chapter = "Ambermill",
            summary = "Turn from worgen to Dalaran, gathering crates, pendants, and rune-work around Ambermill.",
            recap = "The Dalaran wizards at Ambermill were moving supplies and waking old ley-work beneath Silverpine. Shadow Priest Allister and Dalar Dawnweaver followed the evidence until Archmage Ataeric stood exposed.",
            quests = {
                { id = 477, name = "Border Crossings", npc = "Shadow Priest Allister" },
                { id = 478, name = "Maps and Runes", npc = "Dalaran Crate" },
                { id = 481, name = "Dalar's Analysis", npc = "Shadow Priest Allister" },
                { id = 482, name = "Dalaran's Intentions", npc = "Dalar Dawnweaver" },
                { id = 479, name = "Ambermill Investigations", npc = "Shadow Priest Allister" },
                { id = 480, name = "The Weaver", npc = "Shadow Priest Allister" },
            },
        },
        {
            chapter = "Shadowfang Keep",
            summary = "Enter Shadowfang Keep for the missing deathstalkers, the Book of Ur, and the mage who rules above the forest.",
            recap = "High Executor Hadrec's missing deathstalkers, Bel'dugur's forbidden book, and Dalar's demand all led into Shadowfang Keep. Arugal fell there, and the Sepulcher received the proof it required.",
            quests = {
                { id = 1098, name = "Deathstalkers in Shadowfang", npc = "High Executor Hadrec" },
                { id = 1013, name = "The Book of Ur", npc = "Keeper Bel'dugur", parallel = true },
                { id = 1014, name = "Arugal Must Die", npc = "Dalar Dawnweaver", parallel = true },
            },
        },
    },
}
