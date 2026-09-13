local addonName, SM = ...

SM.NightElfHeritageData = {
    title = "Heritage of the Kaldorei",
    description = "Answer the Clarion Call from Maiev Shadowsong, who has heard rumors of demonic activity older than the Burning Legion's last invasion. The trail leads into Felwood and the Emerald Dream's borderlands, where corruption has roots ten thousand years deep.\n\nFollow the Wardens into old shadows, face threats tied to ancient Kaldorei memory, and stand with a people still carrying loss beneath the light of Elune.",
    zone = "Stormwind / Felwood",
    expansion = "Dragonflight",
    faction = "Alliance",
    race = "NightElf",
    requiredLevel = 50,
    achievementName = "Heritage of the Kaldorei",
    achievements = {},
    color = { 0.46, 0.40, 0.78 },
    icon = 255131,
    adventureGuideInstanceName = "Darkheart Thicket",
    startQuest = { id = 75890, name = "The Clarion Call", npc = "Automatic / Sealed Kaldorei Scroll", location = "Stormwind Embassy", mapID = 77, x = 0.4350, y = 0.6270, location = "Stormwind / Felwood" },
    npcLocations = {
        ["Maiev Shadowsong"] = { mapID = 77, x = 0.3600, y = 0.5880 }, -- Felwood (approx)
        ["Arko'narin Starshade"] = { mapID = 77, x = 0.3800, y = 0.4620 }, -- Felwood (approx)
        ["Lysander Starshade"] = { mapID = 77, x = 0.3660, y = 0.5160 }, -- Felwood (approx)
    },
    chapterDisplayIDs = {
        ["Heritage of the Kaldorei"] = 112157,
    },
    chapterIcons = {
        ["Heritage of the Kaldorei"] = 112157,
    },
    chapters = {
        {
            chapter = "Heritage of the Kaldorei",
            summary = "Join Maiev and the Wardens against old corruption and reclaim a symbol of night elf devotion.",
            recap = "The kaldorei endured calamity without abandoning duty. By hunting corruption in Felwood and standing beside the Wardens, you helped preserve the legacy of Elune's people.",
            quests = {
                { id = 75890, name = "The Clarion Call", npc = "Automatic / Sealed Kaldorei Scroll", mapID = 77, x = 0.4350, y = 0.6270, location = "Heritage of the Kaldorei, Stormwind / Felwood" },
                { id = 75891, name = "Ancient Curses", npc = "Arko'narin Starshade" },
                { id = 76194, name = "A Grim Portent", npc = "Maiev Shadowsong" },
                { id = 76195, name = "Countering Corruption", npc = "Lysander Starshade" },
                { id = 76196, name = "Mercy or Misery", npc = "Arko'narin Starshade" },
                { id = 76203, name = "Stepping into the Shadows", npc = "Maiev Shadowsong" },
                { id = 76197, name = "A Glimpse of Terror", npc = "Maiev Shadowsong" },
                { id = 76205, name = "Balancing the Scales", npc = "Maiev Shadowsong" },
                { id = 76206, name = "Heart of the Issue", npc = "Lysander Starshade" },
                { id = 76207, name = "Wardens' Wrath", npc = "Arko'narin Starshade" },
                { id = 76212, name = "A Mark For A Protector", npc = "Maiev Shadowsong" },
                { id = 76213, name = "Honor of the Goddess", npc = "Maiev Shadowsong" },
            },
        },
    },
}

return SM
