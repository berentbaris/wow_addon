local addonName, SM = ...

-- =============================================================================
-- Classic: Nothing But The Truth
-- A short Horde story around Beggar's Haunt, Stonard, and Forsaken secrecy.
-- =============================================================================

SM.NothingButTheTruthData = {
    title = "Nothing But The Truth",
    description = "North of the road into Deadwind Pass, two Forsaken agents keep a quiet post at Beggar's Haunt. A human infiltrator has seen too much, and Stonard's orcs have taken him alive before the matter could be settled.\n\nWork with Deathstalker Zraedus and Apothecary Faustin on a serum meant to draw out the truth. They are very particular about whose truth reaches the Horde.",
    zone = "Duskwood / Swamp of Sorrows / Desolace",
    expansion = "Classic",
    recommendedLevel = { min = 37, max = 42 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.46, 0.62, 0.36 },
    icon = 136066,
    portraitDisplayID = 4342,
    adventureCoverTexture = 131869, -- Shadowfang Keep: closest Classic loading screen for Duskwood's gothic tone.
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1372, name = "Nothing But The Truth", npc = "Deathstalker Zraedus", location = "Beggar's Haunt, Duskwood" },
    startMapID = 47,
    startX = 0.8760,
    startY = 0.3550,

    npcLocations = {
        ["Deathstalker Zraedus"] = { mapID = 47, x = 0.8760, y = 0.3550, location = "Beggar's Haunt, Duskwood" },
        ["Apothecary Faustin"] = { mapID = 47, x = 0.8740, y = 0.3550, location = "Beggar's Haunt, Duskwood" },
        ["Infiltrator Marksen"] = { mapID = 51, x = 0.4450, y = 0.5250, location = "Stonard, Swamp of Sorrows" },
        ["Mire Lord"] = { mapID = 51, x = 0.0560, y = 0.3140, location = "Misty Valley, Swamp of Sorrows" },
        ["Shadow Panthers"] = { mapID = 51, x = 0.7600, y = 0.3100, location = "eastern Swamp of Sorrows" },
        ["Deepstrider Giants"] = { mapID = 66, x = 0.3500, y = 0.2700, location = "the coast near Ethel Rethor, Desolace" },
    },

    npcDisplayIDs = {
        ["Deathstalker Zraedus"] = 4342,
        ["Apothecary Faustin"] = 4341,
        ["Infiltrator Marksen"] = 4557,
    },

    chapterDisplayIDs = {
        ["Beggar's Haunt"] = 4342,
    },

    chapterIcons = {
        ["Beggar's Haunt"] = 136066,
    },

    chapters = {
        {
            chapter = "Beggar's Haunt",
            summary = "Meet the Forsaken agents hidden in Duskwood and help prepare a truth serum for Stonard's prisoner.",
            recap = "Zraedus and Faustin called it help for their orcish allies, but every errand served the same purpose: keep the captive in Stonard from saying too much. The serum needed panther hearts, rare fungus, and a giant's tumor before Faustin could finish it. By the time Marksen drank the disguised brew, the truth was already losing its chance to be heard.",
            quests = {
                { id = 1372, name = "Nothing But The Truth", displayName = "Zraedus's Request", npc = "Deathstalker Zraedus" },
                { id = 1383, name = "Nothing But The Truth", displayName = "Faustin's Serum", npc = "Apothecary Faustin" },
                { id = 1388, name = "Nothing But The Truth", displayName = "The Truth Serum", npc = "Apothecary Faustin" },
                { id = 1391, name = "Nothing But The Truth", displayName = "Stonard's Prisoner", npc = "Deathstalker Zraedus" },
            },
        },
    },
}
