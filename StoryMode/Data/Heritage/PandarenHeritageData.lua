local addonName, SM = ...

SM.PandarenHeritageData = {
    title = "Pandaren Heritage",
    description = "Follow old friends across Pandaria, retracing the journey that shaped the Wandering Isle and the pandaren who left it behind. The mists have lifted, the war has moved on, and a new generation needs to understand what its elders carried into exile.\n\nWalk the slopes of Kun-Lai, sit at the brewmaster's hearth in the Valley of the Four Winds, and listen to stories the rest of the world has only just begun to hear.",
    zone = "Pandaria / Wandering Isle",
    expansion = "The War Within",
    race = "Pandaren",
    requiredLevel = 50,
    achievementName = "Heritage of the Wandering Isle",
    achievements = {},
    color = { 0.71, 0.31, 0.28 },
    icon = 630617,
    adventureGuideInstanceName = "Temple of the Jade Serpent",
    -- Faction-specific openers exist; this serves as a consistent StoryMode entry anchor.
    startQuest = { id = 84442, name = "Invitation to the Spirit Festival", npc = "Automatic / Ji Firepaw", location = "Stormwind or Orgrimmar Embassy" },
    npcLocations = {
        ["Ji Firepaw"] = { mapID = 85, x = 0.2860, y = 0.4260 }, -- Orgrimmar Embassy (approx)
        ["Aysa Cloudsinger"] = { mapID = 84, x = 0.3020, y = 0.4160 }, -- Stormwind Embassy (approx)
        ["Li Li Stormstout"] = { mapID = 376, x = 0.5160, y = 0.4620 }, -- Valley of the Four Winds (approx)
        ["Chen Stormstout"] = { mapID = 376, x = 0.6960, y = 0.6740 }, -- Valley of the Four Winds (approx)
        ["Lorewalker Cho"] = { mapID = 376, x = 0.5240, y = 0.1920 }, -- Seat of Knowledge (approx)
    },
    chapterDisplayIDs = {
        ["Heritage of the Wandering Isle"] = 40962,
    },
    chapterIcons = {
        ["Heritage of the Wandering Isle"] = 40962,
    },
    chapters = {
        {
            chapter = "Heritage of the Wandering Isle",
            summary = "Take part in the Spirit Festival and walk both Tushui and Huojin threads of pandaren heritage.",
            recap = "Pandaren heritage lives in stories carried by many voices. Through festival rites, old memories, and shared traditions, you helped weave those voices into a new legacy.",
            quests = {
                -- Faction-specific openers (both included)
                { id = 84442, name = "Invitation to the Spirit Festival", npc = "Automatic (Alliance)", mapID = 376, x = 0.5570, y = 0.5820, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84444, name = "Invitation to the Spirit Festival", npc = "Ji Firepaw (Horde)", mapID = 85, x = 0.3920, y = 0.8110, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84451, name = "The Wanderers", npc = "Li Li Stormstout", mapID = 376, x = 0.5580, y = 0.5830, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84452, name = "The Wanderers", npc = "Li Li Stormstout", mapID = 376, x = 0.5580, y = 0.5830, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },

                -- Shared and branch steps
                { id = 84453, name = "To Dai-Lo Farmstead", npc = "Chen Stormstout" },
                { id = 84454, name = "Tide of Virmen", npc = "Chen Stormstout" },
                { id = 84455, name = "Big Bertha", npc = "Chon Po Stormstout", mapID = 376, x = 0.5570, y = 0.5820, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84468, name = "Brew You One Better", npc = "Chen Stormstout" },
                { id = 84456, name = "To Morning Breeze", npc = "Aysa Cloudsinger", mapID = 84, x = 0.5180, y = 0.1360, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84457, name = "To Morning Breeze", npc = "Ji Firepaw", mapID = 85, x = 0.3920, y = 0.8110, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84458, name = "Devil's in the Details", npc = "Aysa Cloudsinger" },
                { id = 84459, name = "Scamps Ain't It!", npc = "Ji Firepaw" },
                { id = 84460, name = "Red Hand or Herring?", npc = "Aysa Cloudsinger" },
                { id = 84461, name = "It's Not a Spirit Festival Without Spirits", npc = "Mr. Crane", mapID = 84, x = 0.5180, y = 0.1360, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84462, name = "Patterns in Static", npc = "Li Li Stormstout" },
                { id = 84463, name = "Codependency", npc = "Jojo Ironbrow", mapID = 376, x = 0.5580, y = 0.5830, location = "Heritage of the Wandering Isle, Pandaria / Wandering Isle" },
                { id = 84464, name = "Lost My Spark", npc = "Li Li Stormstout" },
                { id = 84465, name = "Of Water and Blood", npc = "Li Li Stormstout" },
                { id = 84466, name = "Thousands of Years Ago...", npc = "Li Li Stormstout" },
                { id = 84467, name = "This Was Home", npc = "Lorewalker Cho" },
                { id = 92030, name = "A New Tradition", npc = "Lorewalker Cho" },
            },
        },
    },
}

return SM
