local addonName, SM = ...

-- =============================================================================
-- Classic: Secrets of Uldaman
-- Hammertoe, the Shattered Necklace, the Tablet of Will, and the Platinum Discs.
-- =============================================================================

SM.UldamanData = {
    title = "Secrets of Uldaman",
    description = "The Badlands dig site is more than a ruin full of troggs and Dark Iron dwarves. Uldaman holds titan records, old dwarven fears, and relics that both factions are willing to chase through the dust.\n\nFollow Hammertoe's warning, the Shattered Necklace, and the Platinum Discs to uncover what the Titans left beneath the stone.",
    zone = "Badlands / Ironforge / Orgrimmar / Thunder Bluff / Uldaman",
    zoneByFaction = {
        Alliance = "Badlands / Ironforge / Uldaman",
        Horde = "Badlands / Orgrimmar / Thunder Bluff / Uldaman",
    },
    expansion = "Classic",
    recommendedLevel = { min = 35, max = 47 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.64, 0.54, 0.34 },
    icon = 134459,
    adventureGuideInstanceName = "Uldaman",
    adventureCoverTexture = 131876, -- Uldaman loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 720, name = "A Sign of Hope", npc = "Crumpled Map", location = "Hammertoe's Digsite, Badlands", faction = "Alliance" },
    startMapID = 15,
    startX = 0.5300,
    startY = 0.3300,

    npcLocations = {
        ["Crumpled Map"] = { mapID = 15, x = 0.5300, y = 0.3300, location = "Hammertoe's Digsite, Badlands" },
        ["Prospector Ryedol"] = { mapID = 15, x = 0.5300, y = 0.4300, location = "Hammertoe's Digsite, Badlands" },
        ["Hammertoe Grez"] = { mapID = 15, x = 0.5400, y = 0.5800, location = "the outer Uldaman caves, Badlands" },
        ["Magregan Deepshadow"] = { mapID = 15, x = 0.5400, y = 0.5800, location = "the outer Uldaman caves, Badlands" },
        ["Historian Karnik"] = { mapID = 87, x = 0.7700, y = 0.1100, location = "the Hall of Explorers, Ironforge" },
        ["Advisor Belgrum"] = { mapID = 87, x = 0.7700, y = 0.1100, location = "the Hall of Explorers, Ironforge" },
        ["Ambassador Infernus"] = { mapID = 15, x = 0.4600, y = 0.3500, location = "Angor Fortress, Badlands" },
        ["Tablet of Will"] = { mapID = 230, x = 0.5200, y = 0.6200, location = "Galgann Firehammer's chamber, Uldaman" },
        ["Talvash del Kissel"] = { mapID = 87, x = 0.3600, y = 0.0400, location = "the Mystic Ward, Ironforge" },
        ["Dran Droffers"] = { mapID = 85, x = 0.5900, y = 0.3600, location = "Droffers and Son Salvage, Orgrimmar" },
        ["Remains of a Paladin"] = { mapID = 230, x = 0.3900, y = 0.3000, location = "near Revelosh's chamber, Uldaman" },
        ["Jarkal Mossmeld"] = { mapID = 15, x = 0.0200, y = 0.4700, location = "Kargath, Badlands" },
        ["Discs of Norgannon"] = { mapID = 230, x = 0.7200, y = 0.3000, location = "the treasure chamber beyond Archaedas, Uldaman" },
        ["High Explorer Magellas"] = { mapID = 87, x = 0.6993, y = 0.1855, location = "the Hall of Explorers, Ironforge" },
        ["Dinita Stonemantle"] = { mapID = 87, x = 0.3300, y = 0.6000, location = "the Vault, Ironforge" },
        ["Sage Truthseeker"] = { mapID = 88, x = 0.3400, y = 0.4700, location = "Thunder Bluff" },
        ["Bena Winterhoof"] = { mapID = 88, x = 0.4600, y = 0.3300, location = "Thunder Bluff" },
    },

    npcDisplayIDs = {
        ["Prospector Ryedol"] = 4900,
        ["Talvash del Kissel"] = 5647,
        ["Dran Droffers"] = 5769,
    },

    chapterDisplayIDs = {
        ["Hammertoe's Warning"] = 1265,
        ["The Shattered Necklace"] = 1466,
        ["The Platinum Discs"] = 6589, -- Stone Watcher of Norgannon
    },

    chapterIcons = {
        ["Hammertoe's Warning"] = 134332,
        ["The Shattered Necklace"] = 133315,
        ["The Platinum Discs"] = 134459,
    },

    chapters = {
        {
            chapter = "Hammertoe's Warning",
            faction = "Alliance",
            requiredLevel = 35,
            summary = "Find Hammertoe Grez, stop the Shadowforge search, and recover the titan-inscribed Tablet of Will.",
            recap = "A crumpled map turned a dig-site rumor into a rescue. Hammertoe Grez had been taken into Uldaman because he knew too much about titan relics and Dark Iron plans. His amulet reached Ironforge, Belgrum sent you against Ambassador Infernus, and the Tablet of Will was recovered before the Shadowforge could turn titan knowledge into stronger golems.",
            quests = {
                { id = 720, name = "A Sign of Hope", npc = "Crumpled Map" },
                { id = 721, name = "A Sign of Hope", npc = "Prospector Ryedol" },
                { id = 722, name = "Amulet of Secrets", npc = "Hammertoe Grez" },
                { id = 723, name = "Prospect of Faith", npc = "Hammertoe Grez" },
                { id = 724, name = "Prospect of Faith", npc = "Prospector Ryedol" },
                { id = 725, name = "Passing Word of a Threat", npc = "Historian Karnik" },
                { id = 726, name = "Passing Word of a Threat", npc = "Advisor Belgrum" },
                { id = 762, name = "An Ambassador of Evil", npc = "Advisor Belgrum" },
                { id = 1139, name = "The Lost Tablets of Will", npc = "Advisor Belgrum" },
            },
        },
        {
            chapter = "The Shattered Necklace",
            requiredLevel = 37,
            summary = "Trace the broken necklace through Uldaman's gems, journals, and power source.",
            recap = "The shattered necklace made Uldaman personal in two different ways. Alliance characters traced Talvash's old work and restored the piece through gems and Archaedas' power source. Horde characters followed Droffers and Son Salvage into a bargain with Jarkal Mossmeld. Either way, the dungeon became a puzzle of ruby, sapphire, topaz, and a construct's heart.",
            quests = {
                { id = 2198, name = "The Shattered Necklace", npc = "Shattered Necklace", faction = "Alliance", mapID = 230, x = 0.3900, y = 0.3000, location = "Uldaman" },
                { id = 2199, name = "Lore for a Price", npc = "Talvash del Kissel", faction = "Alliance" },
                { id = 2200, name = "Back to Uldaman", npc = "Talvash del Kissel", faction = "Alliance" },
                { id = 2201, name = "Find the Gems", npc = "Talvash del Kissel", faction = "Alliance" },
                { id = 2204, name = "Restoring the Necklace", npc = "Talvash del Kissel", faction = "Alliance" },
                { id = 2283, name = "Necklace Recovery", npc = "Dran Droffers", faction = "Horde" },
                { id = 2284, name = "Necklace Recovery, Take 2", npc = "Dran Droffers", faction = "Horde" },
                { id = 2318, name = "Translating the Journal", npc = "Remains of a Paladin", faction = "Horde" },
                { id = 2338, name = "Translating the Journal", npc = "Jarkal Mossmeld", faction = "Horde" },
                { id = 2339, name = "Find the Gems and Power Source", npc = "Jarkal Mossmeld", faction = "Horde" },
                { id = 2340, name = "Deliver the Gems", npc = "Jarkal Mossmeld", faction = "Horde" },
                { id = 2341, name = "Necklace Recovery, Take 3", npc = "Dran Droffers", faction = "Horde" },
            },
        },
        {
            chapter = "The Platinum Discs",
            requiredLevel = 40,
            summary = "Defeat Archaedas, consult the stone watcher, and carry the miniature discs to your faction's scholar.",
            recap = "Behind Archaedas, the Discs of Norgannon spoke with the calm weight of titan memory. They named the Creators, the Earthen, and the deep history beneath dwarven stone. The portable discs went from Uldaman to Ironforge or Thunder Bluff, where scholars understood that the find was not only treasure. It was origin.",
            quests = {
                { id = 2278, name = "The Platinum Discs", npc = "Discs of Norgannon" },
                { id = 2439, name = "The Platinum Discs", npc = "High Explorer Magellas", faction = "Alliance" },
                { id = 2440, name = "The Platinum Discs", npc = "Sage Truthseeker", faction = "Horde" },
            },
        },
    },
}
