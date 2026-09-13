local addonName, SM = ...

-- =============================================================================
-- Classic: Hunt for Yenniku
-- Nimboya's search for the chief's son, from Bloodscalp trophies to Zanzil.
-- =============================================================================

SM.SavingYennikuData = {
    title = "Hunt for Yenniku",
    description = "At Grom'gol, Nimboya asks after Yenniku, youngest son of the Darkspear chief. The Bloodscalp trolls may know where he was taken, but Stranglethorn rarely gives up a captive cleanly.\n\nPress the jungle tribes for answers, listen when older spirits are called, and keep following the trail even when it turns toward magic no troll should take lightly.",
    zone = "Stranglethorn Vale",
    expansion = "Classic",
    recommendedLevel = { min = 30, max = 45 },
    faction = "Horde",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.28, 0.58, 0.32 },
    icon = "Interface\\Icons\\INV_Misc_Head_Troll_01",
    portraitDisplayID = 4663,
    adventureCoverTexture = 131886, -- Zul'Gurub loading screen: closest Classic troll-jungle cover for Yenniku's story
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 581, name = "Hunt for Yenniku", npc = "Nimboya", location = "Grom'gol Base Camp, Stranglethorn Vale" },
    startMapID = 50,
    startX = 0.3220,
    startY = 0.2780,

    npcLocations = {
        ["Nimboya"] = { mapID = 50, x = 0.3220, y = 0.2780, location = "Grom'gol Base Camp, Stranglethorn Vale" },
        ["Bubbling Cauldron"] = { mapID = 50, x = 0.3220, y = 0.2770, location = "beside Kin'weelay at Grom'gol Base Camp" },
        ["Kin'weelay"] = { mapID = 50, x = 0.3220, y = 0.2770, location = "beside the Bubbling Cauldron at Grom'gol Base Camp" },
        ["Bloodscalp Trolls"] = { mapID = 50, x = 0.2450, y = 0.1150, location = "the Bloodscalp ruins north of Grom'gol" },
        ["Gan'zulah and Nezzliok"] = { mapID = 50, x = 0.2380, y = 0.0900, location = "deep inside the Bloodscalp ruins north of Grom'gol" },
        ["Gan'zulah"] = { mapID = 50, x = 0.2380, y = 0.0900, location = "deep inside the Bloodscalp ruins north of Grom'gol" },
        ["Nezzliok the Dire"] = { mapID = 50, x = 0.2380, y = 0.0900, location = "deep inside the Bloodscalp ruins north of Grom'gol" },
        ["Skullsplitter Trophies"] = { mapID = 50, x = 0.4600, y = 0.3800, location = "the Skullsplitter ruins in eastern Stranglethorn Vale" },
        ["Crystalvein Mine"] = { mapID = 50, x = 0.4100, y = 0.5000, location = "Crystalvein Mine, southeastern Stranglethorn Vale" },
        ["Mai'Zoth"] = { mapID = 50, x = 0.5200, y = 0.2700, location = "deep inside the Mosh'Ogg Ogre Mound" },
        ["Mosh'Ogg Ogre Mound"] = { mapID = 50, x = 0.5200, y = 0.2700, location = "Mosh'Ogg Ogre Mound, northern Stranglethorn Vale" },
        ["Yenniku"] = { mapID = 50, x = 0.3900, y = 0.5800, location = "the Ruins of Aboraz, along the Crystal Shore" },
    },

    npcDisplayIDs = {
        ["Nimboya"] = 4569,
        ["Kin'weelay"] = 4475,
        ["Gan'zulah"] = 4582,
        ["Nezzliok the Dire"] = 4584,
        ["Mai'Zoth"] = 11546,
        ["Yenniku"] = 4663,
    },

    chapterDisplayIDs = {
        ["Bloodscalp Trail"] = 4569,
        ["Heads in the Cauldron"] = 4584,
        ["The Mind's Eye"] = 4475,
        ["Zanzil's Hold"] = 4663,
    },

    chapterIcons = {
        ["Bloodscalp Trail"] = "Interface\\Icons\\INV_Misc_Head_Troll_01",
        ["Heads in the Cauldron"] = "Interface\\Icons\\INV_Misc_Bowl_01",
        ["The Mind's Eye"] = "Interface\\Icons\\INV_Misc_Gem_Pearl_05",
        ["Zanzil's Hold"] = "Interface\\Icons\\Spell_Shadow_SoulGem",
    },

    chapters = {
        {
            chapter = "Bloodscalp Trail",
            summary = "Begin Nimboya's search by pressing the Bloodscalp trolls for any sign of Yenniku.",
            recap = "Nimboya's search began with a fear no Darkspear wanted confirmed. Yenniku, the chief's youngest son, had vanished after being given to the Gurubashi, and the Bloodscalp tribe looked like the only trail left. Tusks proved you could hunt them. Shrunken heads proved Yenniku was not among their trophies. Finally, Gan'zulah and Nezzliok had to die so their heads could be forced to answer from the cauldron at Grom'gol.",
            quests = {
                { id = 581, name = "Hunt for Yenniku", npc = "Nimboya" },
                { id = 582, name = "Headhunting", npc = "Nimboya" },
                { id = 584, name = "Bloodscalp Clan Heads", npc = "Nimboya" },
            },
        },
        {
            chapter = "Heads in the Cauldron",
            summary = "Bring the dead leaders to the cauldron and answer the price they demand before they speak.",
            recap = "Death did not make the Bloodscalp leaders cooperative. Nezzliok wanted trophy skulls stolen from the Skullsplitters. Gan'zulah wanted Ana'thek's broken armor and a tally of Skullsplitter hunters, headhunters, and berserkers. The spirits were not redeemed by the cauldron. They were bribed, threatened, and indulged until they finally gave up the truth: Yenniku had not died with the Bloodscalps. Zanzil the Outcast had taken him.",
            prerequisites = {
                { id = 584, name = "Bloodscalp Clan Heads", npc = "Nimboya" },
            },
            quests = {
                { id = 585, name = "Speaking with Nezzliok", npc = "Bubbling Cauldron" },
                { id = 586, name = "Speaking with Gan'zulah", npc = "Bubbling Cauldron", parallel = true },
            },
        },
        {
            chapter = "The Mind's Eye",
            summary = "Gather singing crystals and the Mind's Eye so Kin'weelay can make a Soul Gem for Yenniku.",
            recap = "Nezzliok's answer made the rescue feel almost impossible. Zanzil controlled Yenniku body and soul, and ordinary weapons could not solve that. Kin'weelay found one thin chance in the legends of Stranglethorn: the Mind's Eye. Pulsing blue shards from Crystalvein Mine prepared the ritual, and Mai'Zoth's ogres guarded the Eye itself inside the Mosh'Ogg mound. With both in hand, Kin'weelay could reshape the magic into a Soul Gem.",
            prerequisites = {
                { id = 585, name = "Speaking with Nezzliok", npc = "Bubbling Cauldron" },
                { id = 586, name = "Speaking with Gan'zulah", npc = "Bubbling Cauldron" },
            },
            quests = {
                { id = 588, name = "The Fate of Yenniku", npc = "Bubbling Cauldron" },
                { id = 589, name = "The Singing Crystals", npc = "Kin'weelay" },
                { id = 591, name = "The Mind's Eye", npc = "Kin'weelay" },
            },
        },
        {
            chapter = "Zanzil's Hold",
            summary = "Carry Kin'weelay's Soul Gem into the jungle and look for the moment to free Yenniku.",
            recap = "The last step was not to kill Yenniku, but to reach him. At the Ruins of Aboraz, beside Zanzil's servants and the haunted Crystal Shore, the Soul Gem turned violence into rescue. Yenniku's soul was pulled free of Zanzil's control and carried back to Nimboya. The work that had begun with trophies and cauldron smoke ended as a Darkspear promise: the tribe would remember the one who brought the chief's son home.",
            prerequisites = {
                { id = 591, name = "The Mind's Eye", npc = "Kin'weelay" },
            },
            quests = {
                { id = 592, name = "Saving Yenniku", npc = "Kin'weelay" },
            },
        },
    },
}
