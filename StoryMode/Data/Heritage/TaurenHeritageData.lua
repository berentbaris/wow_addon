local addonName, SM = ...

SM.TaurenHeritageData = {
    title = "Heritage of the Shu'halo",
    description = "Answer Baine Bloodhoof's call as the spirit realm and the living world begin to drift dangerously out of alignment. Across Mulgore and Thunder Bluff, the elders still remember an age before the Horde, and the ancestors have not gone silent.\n\nWalk with the spiritwalkers, restore rites interrupted by years of war, and listen for the balance between the living, the dead, and the land beneath your hooves.",
    zone = "Thunder Bluff / Mulgore / Stonetalon",
    expansion = "Battle for Azeroth",
    faction = "Horde",
    race = "Tauren",
    requiredLevel = 50,
    achievementName = "Heritage of the Shu'halo",
    achievements = {},
    color = { 0.62, 0.42, 0.24 },
    icon = "Interface\\Icons\\inv_armor_tauren_d_01shoulder",
    adventureGuideInstanceName = "Wailing Caverns",
    startQuest = { id = 54759, name = "When Spirits Whisper", npc = "Spiritwalker Isahi", location = "Orgrimmar Embassy" },
    npcLocations = {
        ["Spiritwalker Isahi"] = { mapID = 85, x = 0.3790, y = 0.8130 }, -- Orgrimmar Embassy
        ["Baine Bloodhoof"] = { mapID = 88, x = 0.6010, y = 0.5110 }, -- Thunder Bluff (approx)
        ["Spiritwalker Ussoh"] = { mapID = 7, x = 0.4880, y = 0.5890 }, -- Mulgore (approx)
    },
    npcDisplayIDs = {
        ["Spiritwalker Isahi"] = 90196,
    },
    chapterDisplayIDs = {
        ["Heritage of the Shu'halo"] = 90196,
    },
    chapterIcons = {
        ["Heritage of the Shu'halo"] = "Interface\\Icons\\inv_armor_tauren_d_01shoulder",
    },
    chapters = {
        {
            chapter = "Heritage of the Shu'halo",
            summary = "Cross into the spirit realm, face unrest among the ancestors, and protect Thunder Bluff.",
            recap = "The spirits called, and you answered. By walking between worlds and standing with Baine and the spiritwalkers, you helped the Shu'halo restore harmony and honor their ancestors.",
            quests = {
                { id = 54759, name = "When Spirits Whisper", npc = "Spiritwalker Isahi" },
                { id = 54760, name = "The Spiritwalkers", npc = "Baine Bloodhoof" },
                { id = 54761, name = "Spirit Guide", npc = "Spiritwalker Ussoh" },
                { id = 54762, name = "A Small Retreat", npc = "Spiritwalker Ussoh" },
                { id = 54763, name = "Crossing Over", npc = "Spiritwalker Ussoh" },
                { id = 54764, name = "Storm in Bloodhoof", npc = "Spiritwalker Ussoh" },
                { id = 54766, name = "Answer the Call", npc = "Baine Bloodhoof" },
                { id = 54765, name = "Thank Your Guide", npc = "Baine Bloodhoof" },
            },
        },
    },
}

return SM
