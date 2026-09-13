local addonName, SM = ...

-- =============================================================================
-- The War Within: Mourning Rise
-- Korgran's final work as caretaker of Mourning Rise.
-- =============================================================================

SM.MourningRiseData = {
    title = "Mourning Rise",
    description = "Korgran has cared for Mourning Rise longer than his failing memory can reliably hold. The memorial grounds still need tending, kobolds have begun looting the dead, and Urtago is trying to help him hand over a duty he is not ready to lose.\n\nFollow Korgran through the last traditions of his post: honoring the fallen, forging a lantern, and choosing how an earthen says farewell.",
    zone = "Isle of Dorn",
    expansion = "The War Within",
    recommendedLevel = { min = 70, max = 80 },
    achievements = {},
    color = { 0.74, 0.58, 0.36 },
    portraitDisplayID = 117255, -- Korgran
    adventureGuideInstanceName = "The Stonevault",
    adventureCoverTexture = 5795799, -- The Stonevault loading screen
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 78743, name = "Before I Depart", npc = "Korgran", location = "Mourning Rise, Isle of Dorn" },
    startMapID = 2248,
    startX = 0.5740,
    startY = 0.4300,

    npcLocations = {
        ["Korgran"] = { mapID = 2248, x = 0.5740, y = 0.4300, location = "Mourning Rise, Isle of Dorn" },
        ["Urtago"] = { mapID = 2248, x = 0.6160, y = 0.4160, location = "Mourning Rise, Isle of Dorn" },
    },

    npcDisplayIDs = {
        ["Korgran"] = 117255,
        ["Urtago"] = 117256,
    },

    chapterDisplayIDs = {
        ["Before I Depart"] = 117255,
    },

    chapterIcons = {
        ["Before I Depart"] = 134929,
    },

    chapters = {
        {
            chapter = "Before I Depart",
            note = "Optional breadcrumb: To Mourning Rise may point you here first. The story itself begins with Korgran at Mourning Rise.",
            summary = "Korgran knows his mind is fading, but the Rise still needs a caretaker. Help him and Urtago drive out the kobolds, honor the fallen, and prepare the lantern that will carry his final choice.",
            recap = "Korgran still called himself caretaker of Mourning Rise, even as Urtago quietly did more and more of the work. Together you cleared kobolds from the memorial, recovered what they had stolen, and saw how often Korgran lost the thread of the present. The duties that defined him were slipping away.\n\nWhen the time came, Korgran chose one more tradition. He forged a lantern, searched for a lost earthen, cleaned ashes from the memorial, and walked toward the coast with Urtago beside him. His farewell was not treated as defeat. It was a final act of care, made in the place he had guarded for so long.",
            quests = {
                { id = 78743, name = "Before I Depart", npc = "Korgran" },
                { id = 78744, name = "Honor Their Memories", npc = "Urtago" },
                { id = 78745, name = "You No Take Plunder!", npc = "Urtago" },
                { id = 78746, name = "Laws Apply to All", npc = "Urtago" },
                { id = 78747, name = "The Great Collapse", npc = "Urtago" },
                { id = 78748, name = "Cutting the Wick", npc = "Urtago" },
                { id = 78749, name = "Who Runs This Fine Establishment?", npc = "Urtago" },
                { id = 79335, name = "One More Tradition", npc = "Korgran" },
                { id = 79336, name = "The Forging of Memories", npc = "Korgran" },
                { id = 79337, name = "The Last Journey", npc = "Korgran" },
                { id = 79338, name = "The Lost Earthen", npc = "Urtago" },
                { id = 79339, name = "A Change of Tradition", npc = "Urtago" },
                { id = 79340, name = "Tools of Declaration", npc = "Urtago" },
                { id = 79341, name = "Cleansing Ashes", npc = "Urtago" },
                { id = 79342, name = "As He Departs", npc = "Urtago" },
                { id = 82895, name = "The Weight of Duty", npc = "Urtago" },
            },
        },
    },
}
