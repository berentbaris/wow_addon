local addonName, SM = ...

-- =============================================================================
-- Classic: Maraudon
-- Vyle corruption, the Scepter of Celebras, Theradras, and Zaetar's seed.
-- =============================================================================

SM.MaraudonData = {
    title = "Maraudon",
    description = "The crystal caverns beneath Desolace are holy ground, burial ground, and wound all at once. Satyrs, centaur spirits, corrupted plants, and an earth princess all pull at the same buried story.\n\nEnter Maraudon from the orange and purple passages, recover the Scepter of Celebras, and follow the descent to Princess Theradras and the remains of Zaetar.",
    zone = "Desolace / Maraudon / Moonglade",
    expansion = "Classic",
    recommendedLevel = { min = 39, max = 52 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.46, 0.66, 0.42 },
    icon = 134186,
    adventureGuideInstanceName = "Maraudon",
    adventureCoverTexture = 131882, -- Wailing Caverns: closest Classic cave-and-corruption loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 7067, name = "The Pariah's Instructions", npc = "Centaur Pariah", location = "southern Desolace" },
    startMapID = 66,
    startX = 0.4700,
    startY = 0.8700,

    npcLocations = {
        ["Centaur Pariah"] = { mapID = 66, x = 0.4700, y = 0.8700, location = "southern Desolace, near the Valley of Spears" },
        ["Willow"] = { mapID = 66, x = 0.6200, y = 0.3900, location = "Kormek's Hut, Desolace" },
        ["Talendria"] = { mapID = 66, x = 0.6800, y = 0.0800, location = "Nijel's Point, Desolace" },
        ["Vark Battlescar"] = { mapID = 66, x = 0.2300, y = 0.7000, location = "Shadowprey Village, Desolace" },
        ["Cavindra"] = { mapID = 280, x = 0.3000, y = 0.4300, location = "the orange crystal passage, Maraudon" },
        ["Celebras the Redeemed"] = { mapID = 280, x = 0.5200, y = 0.4800, location = "Maraudon" },
        ["Keeper Marandis"] = { mapID = 66, x = 0.6300, y = 0.1000, location = "Nijel's Point, Desolace" },
        ["Selendra"] = { mapID = 66, x = 0.2600, y = 0.7700, location = "south of Shadowprey Village, Desolace" },
        ["Zaetar's Spirit"] = { mapID = 280, x = 0.5000, y = 0.7600, location = "Earth Song Falls, Maraudon" },
        ["Keeper Remulos"] = { mapID = 80, x = 0.3600, y = 0.4100, location = "Nighthaven, Moonglade" },
    },

    chapterDisplayIDs = {
        ["The Pariah and the Prophet"] = 11797,
        ["Vyle Corruption"] = 11790,
        ["The Scepter of Celebras"] = 11789,
        ["Corruption of Earth and Seed"] = 12201,
    },

    chapterIcons = {
        ["The Pariah and the Prophet"] = 134123,
        ["Vyle Corruption"] = 134186,
        ["The Scepter of Celebras"] = 135139,
        ["Corruption of Earth and Seed"] = 136025,
    },

    chapters = {
        {
            chapter = "The Pariah and the Prophet",
            requiredLevel = 39,
            summary = "Follow the Centaur Pariah's instructions and heed Willow's request for Maraudon's carved crystals.",
            recap = "Before the inner caverns, Maraudon offered two warnings. The Centaur Pariah named the khans and the Nameless Prophet, a path through the centaur dead. Willow, far less trustworthy, wanted Theradric carvings from the same twisted place. Both errands made the caverns feel older than Desolace's current wars.",
            quests = {
                { id = 7067, name = "The Pariah's Instructions", npc = "Centaur Pariah", optional = true },
                { id = 7028, name = "Twisted Evils", npc = "Willow", optional = true },
            },
        },
        {
            chapter = "Vyle Corruption",
            requiredLevel = 41,
            summary = "Cleanse Vylestem vines in the orange caverns and gather shadowshards from the purple side.",
            recap = "Vyletongue's corruption was not only demonic; it had soaked into Maraudon's plants and crystals. Talendria or Vark sent you to fill a vial at the orange pool and draw the poison out plant by plant. The shadowshards outside the purple passage told the same story in stone: the caverns were sick, and the sickness had useful fragments for people outside.",
            quests = {
                { id = 7041, name = "Vyletongue Corruption", npc = "Talendria", faction = "Alliance" },
                { id = 7029, name = "Vyletongue Corruption", npc = "Vark Battlescar", faction = "Horde" },
                { id = 7068, name = "Shadowshard Fragments", npc = "Archmage Tervosh", faction = "Alliance", optional = true, mapID = 70, x = 0.6600, y = 0.4900, location = "Theramore, Dustwallow Marsh" },
                { id = 7070, name = "Shadowshard Fragments", npc = "Uthel'nay", faction = "Horde", optional = true, mapID = 85, x = 0.3900, y = 0.8600, location = "Valley of Spirits, Orgrimmar" },
            },
        },
        {
            chapter = "The Scepter of Celebras",
            requiredLevel = 41,
            summary = "Recover the Celebrian rod and diamond, free Celebras, and restore the scepter.",
            recap = "Cavindra's plea gave the dungeon its heart. Noxxion held the rod, Lord Vyletongue held the diamond, and Celebras himself wandered under corruption. Once the keeper was defeated and redeemed, the two pieces could become a scepter again, not only a shortcut through Maraudon but a sign that some part of the place could still be restored.",
            quests = {
                { id = 7044, name = "Legends of Maraudon", npc = "Cavindra" },
                { id = 7046, name = "The Scepter of Celebras", npc = "Celebras the Redeemed" },
            },
        },
        {
            chapter = "Corruption of Earth and Seed",
            requiredLevel = 45,
            summary = "Slay Princess Theradras, learn what became of Zaetar, and carry the Seed of Life to Remulos.",
            recap = "At the bottom of Maraudon, Princess Theradras guarded both destruction and grief. Zaetar's remains had fed the place into strange life, and his spirit asked for something gentler than vengeance: a seed carried to his brother in Moonglade. The dungeon ended not with a clean victory over the centaur's origin, but with proof that Zaetar had become part of the land.",
            quests = {
                { id = 7065, name = "Corruption of Earth and Seed", npc = "Keeper Marandis", faction = "Alliance" },
                { id = 7064, name = "Corruption of Earth and Seed", npc = "Selendra", faction = "Horde" },
                { id = 7066, name = "Seed of Life", npc = "Zaetar's Spirit" },
            },
        },
    },
}
