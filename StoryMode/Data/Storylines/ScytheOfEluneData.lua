local addonName, SM = ...

-- =============================================================================
-- Classic: The Scythe of Elune
-- Velinde Starsong, the missing scythe, and the worgen trail to Duskwood.
-- =============================================================================

SM.ScytheOfEluneData = {
    title = "The Scythe of Elune",
    description = "Near Ashenvale's northern border, the Howling Vale is full of wolf-men that should not be there. Sentinel Melyria Frostshadow believes the Tome of Mel'Thandris may explain why.\n\nFollow Velinde Starsong's trail from Ashenvale to Darnassus, Ratchet, Booty Bay, and Duskwood. The scythe's story is not tidy, but it is one of Classic's clearest windows into the first mysteries of the worgen.",
    zone = "Ashenvale / Darnassus / The Barrens / Stranglethorn Vale / Duskwood",
    expansion = "Classic",
    recommendedLevel = { min = 28, max = 35 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.42, 0.54, 0.78 },
    icon = 135139,
    adventureCoverTexture = 131869, -- Shadowfang Keep: closest Classic cover for the worgen trail into Duskwood
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1022, name = "The Howling Vale", npc = "Sentinel Melyria Frostshadow", location = "Forest Song, Ashenvale" },
    startMapID = 63,
    startX = 0.8600,
    startY = 0.4400,

    npcLocations = {
        ["Sentinel Melyria Frostshadow"] = { mapID = 63, x = 0.8600, y = 0.4400, location = "Forest Song, Ashenvale" },
        ["Tome of Mel'Thandris"] = { mapID = 63, x = 0.5000, y = 0.3900, location = "the Howling Vale, Ashenvale" },
        ["Thyn'tel Bladeweaver"] = { mapID = 89, x = 0.6200, y = 0.3900, location = "the Warrior's Terrace, Darnassus" },
        ["Velinde's Chest"] = { mapID = 89, x = 0.6200, y = 0.8100, location = "the Sentinels' bunkhouse, Darnassus" },
        ["Wharfmaster Dizzywig"] = { mapID = 10, x = 0.6300, y = 0.3800, location = "Ratchet, The Barrens" },
        ["Caravaneer Ruzzgot"] = { mapID = 50, x = 0.2700, y = 0.7400, location = "Booty Bay, Stranglethorn Vale" },
        ["Clerk Daltry"] = { mapID = 47, x = 0.7230, y = 0.4660, location = "Darkshire Town Hall, Duskwood" },
        ["Jonathan Carevin"] = { mapID = 47, x = 0.7530, y = 0.4890, location = "Darkshire, Duskwood" },
        ["Mound of Dirt"] = { mapID = 47, x = 0.7300, y = 0.7900, location = "Roland's Doom, Duskwood" },
    },

    npcDisplayIDs = {
        ["Sentinel Melyria Frostshadow"] = 1957,
        ["Thyn'tel Bladeweaver"] = 7275,
        ["Clerk Daltry"] = 1720,
        ["Jonathan Carevin"] = 4338,
    },

    chapterIcons = {
        ["The Howling Vale"] = 136172,
        ["Velinde Starsong"] = 134331,
        ["Across the Sea"] = 132270,
        ["The Carevin Family"] = 132203,
        ["Answered Questions"] = 135139,
    },

    chapters = {
        {
            chapter = "The Howling Vale",
            summary = "Study the Tome of Mel'Thandris and learn why worgen have appeared near the Felwood border.",
            recap = "The Tome of Mel'Thandris did not give a plain report. It showed Velinde Starsong praying for help against demons and receiving the Scythe of Elune in answer. The worgen in the Howling Vale were no local accident. They were tied to a night elf priestess, a weapon, and a call that had gone wrong.",
            quests = {
                { id = 1022, name = "The Howling Vale", npc = "Sentinel Melyria Frostshadow" },
            },
        },
        {
            chapter = "Velinde Starsong",
            summary = "Carry Melyria's concern to Darnassus and search Velinde's stored effects.",
            recap = "Darnassus remembered Velinde as a trusted priestess, not a villain. Thyn'tel Bladeweaver opened her stored belongings, and the journal inside changed the search from a military report into a missing-person trail. Velinde had used the scythe, lost control of the worgen, and disappeared while seeking help far from Ashenvale.",
            quests = {
                { id = 1037, name = "Velinde Starsong", npc = "Sentinel Melyria Frostshadow" },
                { id = 1038, name = "Velinde's Effects", npc = "Thyn'tel Bladeweaver" },
            },
        },
        {
            chapter = "Across the Sea",
            summary = "Follow Velinde's travel records from Ratchet to Booty Bay and onto the roads north.",
            recap = "Velinde's journal sent the trail across the world instead of deeper into Ashenvale. Ratchet remembered her passage to Booty Bay, and Booty Bay's caravan records pointed north toward Duskwood. The scythe had crossed continents, leaving only ship ledgers, goblin memory, and a road through dangerous country.",
            quests = {
                { id = 1039, name = "The Barrens Port", npc = "Thyn'tel Bladeweaver" },
                { id = 1040, name = "Passage to Booty Bay", npc = "Wharfmaster Dizzywig" },
                { id = 1041, name = "The Caravan Road", npc = "Caravaneer Ruzzgot" },
            },
        },
        {
            chapter = "The Carevin Family",
            summary = "Ask Darkshire's records and the Carevin family what they know about worgen in Duskwood.",
            recap = "Darkshire had no clean record of Velinde, but it had worgen. Clerk Daltry pointed to Jonathan Carevin, whose family made a business of hunting the forest's monsters. Carevin's suspicion gave way to a practical bargain: if the trail led into Roland's Doom, then any answer found there should be shared with Darkshire.",
            quests = {
                { id = 1042, name = "The Carevin Family", npc = "Clerk Daltry" },
                { id = 1043, name = "The Scythe of Elune", npc = "Jonathan Carevin" },
            },
        },
        {
            chapter = "Answered Questions",
            summary = "Return to Darnassus with what the Duskwood cave revealed about Velinde and the scythe.",
            recap = "Roland's Doom gave no triumphant recovery, only signs of what the scythe had unleashed and where Velinde's trail had broken. Thyn'tel accepted the report with gratitude and unease. The worgen could be contained for now, but the Scythe of Elune remained out of night elf hands, waiting for another chapter.",
            quests = {
                { id = 1044, name = "Answered Questions", npc = "Jonathan Carevin" },
            },
        },
    },
}
