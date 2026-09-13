local addonName, SM = ...

-- =============================================================================
-- Classic: Poor Old Blanchy
-- A short Alliance Westfall story around the Furlbrows' broken road.
-- =============================================================================

SM.PoorOldBlanchyData = {
    title = "Poor Old Blanchy",
    description = "Verna Furlbrow and her husband left their farm in a hurry, only for their wagon to break near the road into Westfall. Behind them are thieves in the fields, a farmhouse they may never see again, and a few keepsakes left in the rush.\n\nRecover what the Furlbrows could not carry, then gather oats for Blanchy. It is a small kindness on the edge of a larger ruin.",
    zone = "Westfall",
    expansion = "Classic",
    recommendedLevel = { min = 9, max = 14 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.74, 0.55, 0.32 },
    icon = "Interface\\Icons\\INV_Misc_Food_Wheat_02",
    adventureCoverTexture = 131866, -- Ruined City: closest Classic loading screen for Westfall's broken road.
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 64, name = "The Forgotten Heirloom", npc = "Farmer Furlbrow", location = "Jansen Stead, Westfall" },
    startMapID = 52,
    startX = 0.5990,
    startY = 0.1940,

    npcLocations = {
        ["Farmer Furlbrow"] = { mapID = 52, x = 0.5990, y = 0.1930, location = "Jansen Stead, Westfall" },
        ["Verna Furlbrow"] = { mapID = 52, x = 0.5990, y = 0.1940, location = "Jansen Stead, Westfall" },
        ["Old Blanchy"] = { mapID = 52, x = 0.5980, y = 0.1910, location = "Jansen Stead, Westfall" },
    },

    chapterIcons = {
        ["What They Left Behind"] = "Interface\\Icons\\INV_Misc_Food_Wheat_02",
    },

    chapters = {
        {
            chapter = "What They Left Behind",
            summary = "Recover the Furlbrows' watch from the pumpkin farm, return any stolen deed you find, and gather oats for Old Blanchy.",
            recap = "The Furlbrows had fled their farm with a broken wagon, a hungry old horse, and too little room for memory. The pocket watch was only a small thing, but it carried a wedding day and a home they might never see again. The oats were just as small, yet for Old Blanchy and the people still trying to leave Westfall, they made the road feel possible again.",
            quests = {
                { id = 64, name = "The Forgotten Heirloom", npc = "Farmer Furlbrow" },
                { id = 151, name = "Poor Old Blanchy", npc = "Verna Furlbrow" },
                { id = 184, name = "Furlbrow's Deed", npc = "Furlbrow's Deed", mapID = 37, x = 0.7100, y = 0.8070, location = "Defias camps around Elwynn Forest", optional = true },
            },
        },
    },
}
