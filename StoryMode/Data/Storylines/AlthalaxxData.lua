local addonName, SM = ...

-- =============================================================================
-- Classic: The Tower of Althalaxx
-- Darkshore and Ashenvale's Cult of the Dark Strand chain.
-- =============================================================================

SM.AlthalaxxData = {
    title = "The Tower of Althalaxx",
    description = "Auberdine's watchers have seen trouble near the Tower of Althalaxx. Speak with Balthule Shadowstrike and learn what the Cult of the Dark Strand is doing on the northern coast.\n\nWhat begins as a report from Darkshore pulls you toward Ashenvale, where parchments, gems, and old corruption point to a threat still gathering strength.",
    zone = "Darkshore / Ashenvale",
    expansion = "Classic",
    recommendedLevel = { min = 13, max = 31 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.38, 0.50, 0.64 },
    icon = 136145,
    portraitDisplayID = 4413,
    adventureCoverTexture = 131878, -- Blackfathom Deeps loading screen; closest dark Night Elf ruin art
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 965, name = "The Tower of Althalaxx", npc = "Sentinel Elissa Starbreeze", location = "Auberdine, Darkshore" },
    startMapID = 62,
    startX = 0.3700,
    startY = 0.4400,

    npcLocations = {
        ["Sentinel Elissa Starbreeze"] = { mapID = 62, x = 0.3700, y = 0.4400, location = "Auberdine, Darkshore" },
        ["Balthule Shadowstrike"] = { mapID = 62, x = 0.5500, y = 0.2400, location = "near the Tower of Althalaxx, Darkshore" },
        ["Delgren the Purifier"] = { mapID = 63, x = 0.2660, y = 0.3830, location = "Maestra's Post, Ashenvale" },
        ["Ordil'Aran"] = { mapID = 63, x = 0.3100, y = 0.3100, location = "Ordil'Aran, Ashenvale" },
        ["Fire Scar Shrine"] = { mapID = 63, x = 0.2500, y = 0.6100, location = "Fire Scar Shrine, Ashenvale" },
        ["Night Run"] = { mapID = 63, x = 0.6600, y = 0.5600, location = "Night Run, Ashenvale" },
        ["Satyrnaar"] = { mapID = 63, x = 0.8100, y = 0.4900, location = "Satyrnaar, Ashenvale" },
        ["Athrikus Narassin"] = { mapID = 62, x = 0.5500, y = 0.2400, location = "the Tower of Althalaxx, Darkshore" },
    },

    npcDisplayIDs = {
        ["Sentinel Elissa Starbreeze"] = 2529,
        ["Balthule Shadowstrike"] = 2530,
        ["Delgren the Purifier"] = 2531,
        ["Athrikus Narassin"] = 4413,
    },

    chapterDisplayIDs = {
        ["The Dark Strand"] = 2530,
        ["Ashenvale Soul Gems"] = 2531,
        ["Athrikus Narassin"] = 4413,
    },

    chapterIcons = {
        ["The Dark Strand"] = 136145,
        ["Ashenvale Soul Gems"] = 136157,
        ["Athrikus Narassin"] = 136163,
    },

    chapters = {
        {
            chapter = "The Dark Strand",
            summary = "Find Balthule Shadowstrike near the Tower of Althalaxx and learn what gathers on Darkshore's northern coast.",
            recap = "Sentinel Elissa's missing scout was alive, but Balthule's report was grave. Warlocks held the tower, their parchments spoke of the Dark Strand, and the warning had to reach Ashenvale.",
            quests = {
                { id = 965, name = "The Tower of Althalaxx", displayName = "Find Balthule", npc = "Sentinel Elissa Starbreeze" },
                { id = 966, name = "The Tower of Althalaxx", displayName = "Worn Parchments", npc = "Balthule Shadowstrike" },
                { id = 967, name = "The Tower of Althalaxx", displayName = "Letter to Delgren", npc = "Balthule Shadowstrike" },
            },
        },
        {
            chapter = "Ashenvale Soul Gems",
            summary = "Carry Balthule's warning to Delgren and follow the Dark Strand's trail through Ashenvale.",
            recap = "Delgren sent you after the cult's soul gems and writings from Ordil'Aran to Fire Scar Shrine and Satyrnaar. Each recovered piece loosened the hold of the power behind Althalaxx.",
            quests = {
                { id = 970, name = "The Tower of Althalaxx", displayName = "Glowing Soul Gem", npc = "Delgren the Purifier" },
                { id = 973, name = "The Tower of Althalaxx", displayName = "Ilkrud Magthrull's Tome", npc = "Delgren the Purifier" },
                { id = 1140, name = "The Tower of Althalaxx", displayName = "Highborne Souls", npc = "Delgren the Purifier" },
                { id = 1167, name = "The Tower of Althalaxx part 7", displayName = "Return to Balthule", npc = "Delgren the Purifier" },
            },
        },
        {
            chapter = "Athrikus Narassin",
            summary = "Return to the tower with Balthule's command and face Athrikus Narassin at the summit.",
            recap = "With Athrikus Narassin weakened, Balthule sent you back into Althalaxx. You climbed past the warlocks of the Dark Strand and ended their master where he had gathered them.",
            quests = {
                { id = 1143, name = "The Tower of Althalaxx part 8", displayName = "Athrikus Narassin", npc = "Balthule Shadowstrike" },
                { id = 981, name = "The Tower of Althalaxx", displayName = "Report to Delgren", npc = "Balthule Shadowstrike" },
            },
        },
    },
}
