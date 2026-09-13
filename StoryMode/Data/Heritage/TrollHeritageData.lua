local addonName, SM = ...

SM.TrollHeritageData = {
    title = "Heritage of the Darkspear",
    description = "Return to the Echo Isles where the Darkspear first made landfall in exile, and listen for loa whose voices have grown quieter since the tribe took its place inside the Horde. The new generation has forgotten more than it realizes.\n\nSeek the loa where they still answer, perform the rites where they are still owed, and remember the Darkspear as a people with roots deeper than any banner.",
    zone = "Echo Isles / Northern Stranglethorn",
    expansion = "Dragonflight",
    faction = "Horde",
    race = "Troll",
    requiredLevel = 50,
    achievementName = "Heritage of the Darkspear",
    achievements = {},
    color = { 0.15, 0.55, 0.87 },
    icon = "Interface\\Icons\\inv_helm_armor_troll_d_01",
    adventureGuideInstanceName = "Atal'Dazar",
    startQuest = { id = 77869, name = "Return to the Echo Isles", npc = "Zi'guma", location = "Valley of Spirits, Orgrimmar" },
    startMapID = 85,
    startX = 0.3270,
    startY = 0.6470,
    npcLocations = {
        ["Zi'guma"] = { mapID = 85, x = 0.3270, y = 0.6470 },
        ["Rokhan"] = { mapID = 85, x = 0.5860, y = 0.6540 }, -- Valley of Spirits (approx)
        ["Master Gadrin"] = { mapID = 1, x = 0.6120, y = 0.6540 }, -- Echo Isles (approx)
    },
    npcDisplayIDs = {
        ["Zi'guma"] = 115696,
        ["Rokhan"] = 116250,
        ["Master Gadrin"] = 116153,
        ["Witch Doctor Tzadah"] = 114020,
        ["Kevo ya Siti"] = 113967,
        ["Lukou"] = 114061,
        ["Jani"] = 79821,
    },
    chapterIcons = {
        ["Heritage of the Darkspear"] = "Interface\\Icons\\inv_helm_armor_troll_d_01",
    },
    chapters = {
        {
            chapter = "Heritage of the Darkspear",
            summary = "Confront Mueh'zala's influence, recover forgotten loa, and complete a Trial of the Loa worthy of the Darkspear.",
            recap = "The Darkspear were pulled toward old fears and dark power, but chose another path. By restoring their ties to Kevo ya Siti, Lukou, and Jani, you helped your people remember who they are and what they stand for.",
            quests = {
                { id = 77869, name = "Return to the Echo Isles", npc = "Zi'guma" },
                { id = 77871, name = "De Old Loa", npc = "Master Gadrin" },
                { id = 77874, name = "De Loa of de Past", npc = "Rokhan" },
                { id = 77879, name = "Stalking the Stalker", npc = "Rokhan" },
                { id = 77881, name = "There is Another", npc = "Kevo ya Siti", mapID = 85, x = 0.3280, y = 0.6490, location = "Heritage of the Darkspear, Echo Isles / Northern Stranglethorn" },
                { id = 77880, name = "Looking for Lukou", npc = "Rokhan" },
                { id = 77877, name = "One with the Loa", npc = "Kevo ya Siti", mapID = 85, x = 0.3280, y = 0.6490, location = "Heritage of the Darkspear, Echo Isles / Northern Stranglethorn" },
                { id = 77882, name = "Stolen but Not Forgotten", npc = "Rokhan" },
                { id = 78875, name = "The Unkillable", npc = "Rokhan" },
                { id = 77894, name = "Heart of Lukou", npc = "Rokhan" },
                { id = 77898, name = "Honor and Tribute", npc = "Rokhan" },
                { id = 77899, name = "The Rush'kah", npc = "Witch Doctor Tzadah", mapID = 85, x = 0.3280, y = 0.6490, location = "Heritage of the Darkspear, Echo Isles / Northern Stranglethorn" },
                { id = 77900, name = "The Loa Trials", npc = "Rokhan" },
                { id = 77901, name = "Retraining the Trainees", npc = "Kevo ya Siti", mapID = 85, x = 0.3280, y = 0.6490, location = "Heritage of the Darkspear, Echo Isles / Northern Stranglethorn" },
                { id = 77902, name = "Ritual Recovery", npc = "Lukou", mapID = 85, x = 0.3280, y = 0.6490, location = "Heritage of the Darkspear, Echo Isles / Northern Stranglethorn" },
                { id = 77903, name = "De Power of Death", npc = "Rokhan" },
                { id = 77905, name = "Avatar of Mueh'zala", npc = "Rokhan" },
                { id = 77906, name = "De Darkspear Loa", npc = "Rokhan" },
            },
        },
    },
}

return SM
