local addonName, SM = ...

-- =============================================================================
-- Dragonflight: Veritistrasz
-- A quiet short story at the Ruby Lifeshrine.
-- =============================================================================

SM.VeritistraszData = {
    title = "Stay a While",
    description = "At the Ruby Lifeshrine, Veritistrasz asks for something rare in an adventurer's life: time. No army waits, no world-ending machine is counting down, and no one needs a hundred trophies from the local wildlife.\n\nSit with an old red dragon in dwarf form, listen to what he remembers, and help him face the name he has spent ages trying not to say.",
    zone = "The Waking Shores",
    expansion = "Dragonflight",
    recommendedLevel = { min = 60, max = 70 },
    achievements = {},
    color = { 0.78, 0.25, 0.18 },
    portraitDisplayID = 108383, -- Veritistrasz
    adventureGuideInstanceName = "Ruby Life Pools",
    adventureCoverTexture = 4550300, -- Ruby Life Pools loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 70132, name = "Stay a While", npc = "Veritistrasz", location = "Ruby Lifeshrine, The Waking Shores" },
    startMapID = 2022,
    startX = 0.5780,
    startY = 0.6680,

    npcLocations = {
        ["Veritistrasz"] = { mapID = 2022, x = 0.5780, y = 0.6680, location = "Ruby Lifeshrine, The Waking Shores" },
        ["Partially Destroyed Diary"] = { mapID = 2022, x = 0.2550, y = 0.5650, location = "Obsidian Citadel, The Waking Shores" },
    },

    npcDisplayIDs = {
        ["Veritistrasz"] = 108383,
    },

    chapterDisplayIDs = {
        ["Stay a While"] = 108383,
    },

    chapterIcons = {
        ["Stay a While"] = 1394891,
    },

    chapters = {
        {
            chapter = "Stay a While",
            summary = "Veritistrasz only asks you to sit, listen, and look out over the Waking Shores. What begins as memory becomes grief, and a hidden diary gives him one last truth to carry.",
            recap = "Veritistrasz sat at the Ruby Lifeshrine and asked you to stay. His stories moved gently at first: old homes, old meals, the strange way places change when you are gone too long. Then the memories turned toward the black dragonflight, toward the friend he loved, and toward the betrayal that broke both his family and his certainty.\n\nLater, a damaged diary from the Obsidian Citadel brought the name he could not reach: Distyia. It did not undo what happened, but it gave his grief shape. Veritistrasz remembered the person beneath the corruption, and for a moment the old wound was not quite so alone.",
            quests = {
                { id = 70132, name = "Stay a While", npc = "Veritistrasz" },
                { id = 70134, name = "Memories", npc = "Veritistrasz" },
                { id = 70268, name = "Memories Revived", npc = "Partially Destroyed Diary", location = "Obsidian Citadel, The Waking Shores" },
            },
        },
    },
}
