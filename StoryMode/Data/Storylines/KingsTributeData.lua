local addonName, SM = ...

-- =============================================================================
-- Classic: A King's Tribute
-- Sully Balloo's hidden letter, Sara Balloo's plea, and Magni's memorial.
-- =============================================================================

SM.KingsTributeData = {
    title = "A King's Tribute",
    description = "Under the broken Thandol Span, a dwarf's remains lie where few travelers think to look. Among them is a letter that never reached the woman waiting in Ironforge.\n\nCarry Sully Balloo's words home and let Sara Balloo decide what should be done with them. Some duties begin after the battle is already over.",
    zone = "Arathi Highlands / Ironforge / Hillsbrad Foothills",
    expansion = "Classic",
    recommendedLevel = { min = 26, max = 31 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.70, 0.52, 0.28 },
    icon = 133471,
    portraitDisplayID = 1670,
    adventureCoverTexture = 131824, -- Blackrock Depths: closest Classic dwarven stonework loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 637, name = "Sully Balloo's Letter", npc = "Waterlogged Envelope", location = "beneath the Thandol Span, Arathi Highlands" },
    startMapID = 14,
    startX = 0.4430,
    startY = 0.9290,

    npcLocations = {
        ["Waterlogged Envelope"] = { mapID = 14, x = 0.4430, y = 0.9290, location = "beneath the Thandol Span, Arathi Highlands" },
        ["Sara Balloo"] = { mapID = 87, x = 0.6380, y = 0.6760, location = "the Military Ward, Ironforge" },
        ["King Magni Bronzebeard"] = { mapID = 87, x = 0.3900, y = 0.5600, location = "the High Seat, Ironforge" },
        ["Grand Mason Marblesten"] = { mapID = 87, x = 0.3680, y = 0.8770, location = "near the Ironforge Visitor's Center, Ironforge" },
    },

    npcDisplayIDs = {
        ["Sara Balloo"] = 1670,
        ["King Magni Bronzebeard"] = 3597,
        ["Grand Mason Marblesten"] = 5410,
    },

    chapterDisplayIDs = {
        ["The Waterlogged Letter"] = 1670,
        ["The Memorial"] = 3597,
    },

    chapterIcons = {
        ["The Waterlogged Letter"] = 133471,
        ["The Memorial"] = 133739,
    },

    chapters = {
        {
            chapter = "The Waterlogged Letter",
            summary = "Recover the waterlogged letter beneath the Thandol Span and carry its last words home.",
            recap = "The trail began beneath the broken Thandol Span, beside a dwarf pinned in the riverbed. Sully Balloo's letter was not a weapon, a map, or a royal order. It was a husband's goodbye, written before war turned private love into public loss. Sara Balloo received the letter in Ironforge and asked for only one thing more: that her king know what had been given in his name.",
            quests = {
                { id = 637, name = "Sully Balloo's Letter", npc = "Waterlogged Envelope" },
                { id = 683, name = "Sara Balloo's Plea", npc = "Sara Balloo" },
            },
        },
        {
            chapter = "The Memorial",
            summary = "King Magni sends the letter on to Grand Mason Marblesten, who needs Alterac Granite before Sully's memorial can stand.",
            recap = "Magni could not answer Sara's grief with victory, so he answered with remembrance. Grand Mason Marblesten took the commission seriously, sending you into the Darrow Hill cave for Alterac Granite worthy of the memorial. When the stone was cut and the work was done, the tribute no longer belonged only to Sully Balloo. It stood for every soldier whose death had been reduced to orders, borders, and reports until someone stopped long enough to read the letter.",
            quests = {
                { id = 686, name = "A King's Tribute", displayName = "Magni's Commission", npc = "King Magni Bronzebeard" },
                { id = 689, name = "A King's Tribute", displayName = "Alterac Granite", npc = "Grand Mason Marblesten" },
                { id = 700, name = "A King's Tribute", displayName = "The Memorial", npc = "Grand Mason Marblesten" },
            },
        },
    },
}
