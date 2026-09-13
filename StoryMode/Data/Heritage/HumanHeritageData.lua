local addonName, SM = ...

SM.HumanHeritageData = {
    title = "Lion's Heritage",
    description = "A Defias plot has surfaced inside Stormwind's own walls, and Master Shaw needs someone he can trust to follow it to the source. The old grievances that shaped the Deadmines have not vanished just because the kingdom moved on.\n\nTrace the conspiracy through Stormwind's streets and forgotten debts, and decide what kind of human history is worth honoring when the past asks to be heard again.",
    zone = "Stormwind / Westfall / Elwynn",
    expansion = "Dragonflight",
    faction = "Alliance",
    race = "Human",
    requiredLevel = 50,
    achievementName = "Lion's Heritage",
    achievements = {},
    color = { 0.22, 0.45, 0.86 },
    icon = "Interface\\Icons\\inv_misc_tournaments_banner_human",
    adventureGuideInstanceName = "Deadmines",
    adventureCoverTexture = 131833, -- Deadmines loading screen
    adventureCoverIsLoadingScreen = true,
    startQuest = { id = 72644, name = "An Urgent Matter", npc = "Agent Render", location = "Stormwind Embassy" },
    npcLocations = {
        ["Agent Render"] = { mapID = 84, x = 0.5220, y = 0.1350 }, -- Stormwind Embassy (approx)
        ["Master Mathias Shaw"] = { mapID = 84, x = 0.4660, y = 0.6680 }, -- SI:7 area (approx)
        ["Vanessa VanCleef"] = { mapID = 52, x = 0.4190, y = 0.6990 , location = "Stormwind / Westfall / Elwynn"}, -- Moonbrook (approx)
        ["Ragged John"] = { mapID = 52, x = 0.7260, y = 0.6460 }, -- Sentinel Hill area (approx)
        ["Cecilia Clessington"] = { mapID = 52, x = 0.4190, y = 0.6990 , location = "Stormwind / Westfall / Elwynn"}, -- Moonbrook (approx)
        ["Marshal McBride"] = { mapID = 37, x = 0.2760, y = 0.6700 }, -- Northshire (approx)
    },
    npcDisplayIDs = {
        ["Agent Render"] = 110648,
    },
    chapterIcons = {
        ["Lion's Heritage"] = "Interface\\Icons\\inv_misc_tournaments_banner_human",
    },
    chapterDisplayIDs = {
        ["Lion's Heritage"] = 110648,
    },
    chapters = {
        {
            chapter = "Lion's Heritage",
            summary = "Investigate conspiracy and betrayal tied to Stormwind's past and the Defias Brotherhood.",
            recap = "Stormwind's legacy was tested by old enemies and old mistakes. You followed the trail from the city to Westfall and Northshire, exposed the conspiracy, and helped preserve the honor of the kingdom.",
            quests = {
                { id = 72644, name = "An Urgent Matter", npc = "Agent Render" },
                { id = 72405, name = "An Unlikely Informant", npc = "Master Mathias Shaw" },
                { id = 72408, name = "A Window to the Past", npc = "Master Mathias Shaw" },
                { id = 72409, name = "Rotten Old Memories", npc = "Vanessa VanCleef" },
                { id = 72424, name = "Looking for Something Specific", npc = "Ragged John" },
                { id = 72426, name = "The New Clessington Estate", npc = "Master Mathias Shaw" },
                { id = 72430, name = "Misdeeds in Moonbrook", npc = "Vanessa VanCleef" },
                { id = 72431, name = "A Hungry Heritage", npc = "Vanessa VanCleef" },
                { id = 72432, name = "Supply Only the Finest Goons", npc = "Cecilia Clessington" },
                { id = 72453, name = "Betrayal of the Brotherhood", npc = "Vanessa VanCleef" },
                { id = 72445, name = "To Northshire", npc = "Master Mathias Shaw" },
                { id = 72446, name = "What's Their Problem?", npc = "Marshal McBride" },
                { id = 72449, name = "Knock It Off!", npc = "Master Mathias Shaw" },
                { id = 72450, name = "The Clessington Will", npc = "Cecilia Clessington" },
                { id = 72451, name = "Will to Survive", npc = "Master Mathias Shaw" },
                { id = 72452, name = "Go with Honor, Friend", npc = "Master Mathias Shaw" },
            },
        },
    },
}

return SM
