local addonName, SM = ...

-- =============================================================================
-- Legion: Runas the Shamed
-- The emotional heart of Defending Azurewing Repose.
-- =============================================================================

SM.RunasTheShamedData = {
    title = "Runas the Shamed",
    description = "Azurewing Repose is under pressure from withered nightborne, hungry leyline abuse, and a prince who sees dragons as a resource to drain. In the middle of it all is Runas, a withered exile who still has just enough wit, shame, and courage left to choose who he wants to be.\n\nBegin with Stellagosa's search for the missing whelpling and follow Runas through one last useful, heartbreaking day.",
    zone = "Azsuna",
    expansion = "Legion",
    recommendedLevel = { min = 10, max = 45 },
    achievements = {},
    color = { 0.42, 0.62, 0.95 },
    portraitDisplayID = 64545, -- Stellagosa
    adventureGuideInstanceName = "Court of Stars",
    adventureCoverTexture = 1477131, -- Court of Stars loading screen: high-resolution Nightborne arcane art for Runas' Nightborne threat
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 37957, name = "Runas the Shamed", npc = "Stellagosa", location = "Azurewing Repose, Azsuna" },
    startMapID = 630,
    startX = 0.4660,
    startY = 0.1580,

    npcLocations = {
        ["Stellagosa"] = { mapID = 630, x = 0.4660, y = 0.1580, location = "Azurewing Repose, Azsuna" },
        ["Mana-Drained Whelpling"] = { mapID = 630, x = 0.4940, y = 0.1560, location = "Azsuna" },
        ["Runas the Shamed"] = { mapID = 630, x = 0.5380, y = 0.1680, location = "Azsuna" },
        ["Projection of Senegos"] = { mapID = 630, x = 0.5340, y = 0.1620, location = "Azsuna" },
        ["Archmage Khadgar"] = { mapID = 630, x = 0.4960, y = 0.2680, location = "Azurewing Repose, Azsuna" },
    },

    npcDisplayIDs = {
        ["Stellagosa"] = 64545,
        ["Runas the Shamed"] = 67717,
        ["Projection of Senegos"] = 69857,
        ["Archmage Khadgar"] = 64045,
    },

    chapterDisplayIDs = {
        ["Runas the Shamed"] = 64545,
        ["The Nightborne Prince"] = 67717,
        ["Hunger's End"] = 64045,
    },

    chapterIcons = {
        ["Runas the Shamed"] = 134155,
        ["The Nightborne Prince"] = 463284,
        ["Hunger's End"] = 135739,
    },

    chapters = {
        {
            chapter = "Runas the Shamed",
            summary = "Stellagosa sends you after a missing whelpling and you meet Runas, a withered exile who knows the Repose's enemies better than anyone wants to admit.",
            recap = "Stellagosa's missing whelpling led you to Runas the Shamed, a withered nightborne with a sharp tongue and a hunger he could barely hold back. He had been cast out, diminished, and written off, but he still understood the leylines, the withered, and the danger gathering around Azurewing Repose.\n\nRunas helped you recover the whelpling and find Stellagosa, even as his own cravings returned. He was not safe. He knew it. Still, he kept choosing to help.",
            quests = {
                { id = 37957, name = "Runas the Shamed", npc = "Stellagosa" },
                { id = 37859, name = "The Consumed", npc = "Mana-Drained Whelpling" },
                { id = 37858, name = "Stellagosa", npc = "Projection of Senegos" },
                { id = 37857, name = "Runas Knows the Way", npc = "Runas the Shamed" },
                { id = 37959, name = "The Hunger Returns", npc = "Runas the Shamed" },
                { id = 37960, name = "Leyline Abuse", npc = "Projection of Senegos" },
            },
        },
        {
            chapter = "The Nightborne Prince",
            summary = "Runas guides you into the prince's territory, bargains with his own hunger, and helps expose what the nightborne are doing to the dragons.",
            recap = "Runas knew the prince's camp from the inside: the habits, the arrogance, and the weak points. With his guidance, you sabotaged the nightborne, stole what you needed, and found Stellagosa alive but endangered. Runas kept laughing, kept deflecting, and kept moving because stopping would mean feeling the pull of the hunger too clearly.\n\nBy the time you returned to Azurewing Repose, Runas had given the dragons what they needed most: a path to strike back before the prince could feast on them.",
            quests = {
                { id = 37860, name = "You Scratch My Back...", npc = "Runas the Shamed" },
                { id = 37861, name = "The Nightborne Prince", npc = "Projection of Senegos" },
                { id = 37862, name = "Still Alive", npc = "Stellagosa" },
            },
        },
        {
            chapter = "Hunger's End",
            summary = "Khadgar and Stellagosa rally the defense. Runas spends his last strength making sure his final hours matter.",
            recap = "The nightborne assault reached Azurewing Repose. Khadgar, Stellagosa, and the blue dragons fought to protect Senegos while the withered closed in. Runas was almost out of time. He knew what was coming, and he chose to spend his last clear moments helping instead of hiding.\n\nAt the end, he thanked you for letting his final hours mean something. Then the hunger took him. The victory at Azurewing Repose came with a quiet loss, and Runas the Shamed earned a better name than the one he had carried.",
            quests = {
                { id = 38014, name = "Feasting on the Dragon", npc = "Archmage Khadgar" },
                { id = 38015, name = "On the Brink", npc = "Stellagosa" },
                { id = 42567, name = "Cursed to Wither", npc = "Stellagosa" },
                { id = 42756, name = "Hunger's End", npc = "Runas the Shamed" },
            },
        },
    },
}
