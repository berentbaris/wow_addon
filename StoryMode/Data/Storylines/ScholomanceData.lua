local addonName, SM = ...

-- =============================================================================
-- Classic: Scholomance
-- The Skeleton Key, the Sarkhoffs, Ras Frostwhisper, and the Barov inheritance.
-- =============================================================================

SM.ScholomanceData = {
    title = "Scholomance",
    description = "Caer Darrow's ruined school is locked behind more than a door. The Scourge has made Scholomance a place of experiments, ghosts, noble inheritance, and old betrayals that refuse to stay buried.\n\nForge the Skeleton Key, then follow the stories waiting inside: Eva Sarkhoff's revenge, Kirtonos, Ras Frostwhisper's lost humanity, and the Barov family's poisoned fortune.",
    zone = "Western Plaguelands / Tanaris / Un'Goro Crater / Scholomance",
    zoneByFaction = {
        Alliance = "Western Plaguelands / Tanaris / Un'Goro Crater / Scholomance",
        Horde = "Tirisfal Glades / Western Plaguelands / Tanaris / Un'Goro Crater / Scholomance",
    },
    expansion = "Classic",
    requiredLevel = 52,
    recommendedLevel = { min = 52, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.38, 0.48, 0.58 },
    icon = 134459,
    adventureGuideInstanceName = "Scholomance",
    adventureCoverTexture = 131868,
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 5533, name = "Scholomance", npc = "Commander Ashlam Valorfist", location = "Chillwind Camp, Western Plaguelands", faction = "Alliance" },
    startMapID = 22,
    startX = 0.4300,
    startY = 0.8400,

    npcLocations = {
        ["Commander Ashlam Valorfist"] = { mapID = 22, x = 0.4300, y = 0.8400, location = "Chillwind Camp, Western Plaguelands" },
        ["High Executor Derrington"] = { mapID = 22, x = 0.8300, y = 0.6900, location = "the Bulwark, Tirisfal Glades" },
        ["Alchemist Arbington"] = { mapID = 22, x = 0.4300, y = 0.8400, location = "Chillwind Camp, Western Plaguelands" },
        ["Apothecary Dithers"] = { mapID = 22, x = 0.8300, y = 0.6900, location = "the Bulwark, Tirisfal Glades" },
        ["Krinkle Goodsteel"] = { mapID = 71, x = 0.5150, y = 0.2800, location = "Gadgetzan, Tanaris" },
        ["Araj the Summoner"] = { mapID = 22, x = 0.4500, y = 0.6900, location = "the ruins of Andorhal, Western Plaguelands" },
        ["Eva Sarkhoff"] = { mapID = 22, x = 0.7000, y = 0.7300, location = "Caer Darrow, Western Plaguelands" },
        ["Magistrate Marduke"] = { mapID = 22, x = 0.7000, y = 0.7300, location = "Caer Darrow, Western Plaguelands" },
        ["Artist Renfray"] = { mapID = 22, x = 0.6500, y = 0.7500, location = "Caer Darrow, Western Plaguelands" },
        ["Eva's Remains"] = { mapID = 476, x = 0.4700, y = 0.5200, location = "Doctor Theolen Krastinov's room, Scholomance" },
        ["Kirtonos the Herald"] = { mapID = 476, x = 0.3800, y = 0.3700, location = "the Chamber of Summoning, Scholomance" },
        ["Ras Frostwhisper"] = { mapID = 476, x = 0.7000, y = 0.4600, location = "Scholomance" },
        ["Alexi Barov"] = { mapID = 22, x = 0.8300, y = 0.6900, location = "near the Bulwark, Tirisfal Glades" },
        ["Weldon Barov"] = { mapID = 22, x = 0.4300, y = 0.8400, location = "Chillwind Camp, Western Plaguelands" },
    },

    chapterDisplayIDs = {
        ["The Skeleton Key"] = 10876,
        ["The Sarkhoffs"] = 10729,
        ["Ras Frostwhisper"] = 10689,
        ["Barov Family Fortune"] = 10740,
    },

    chapterIcons = {
        ["The Skeleton Key"] = 134459,
        ["The Sarkhoffs"] = 136122,
        ["Ras Frostwhisper"] = 135852,
        ["Barov Family Fortune"] = 133731,
    },

    chapters = {
        {
            chapter = "The Skeleton Key",
            requiredLevel = 55,
            summary = "After proving yourself in the Plaguelands, forge the Skeleton Key that opens Scholomance.",
            recap = "Scholomance was not simply entered. Arbington or Dithers sent you through bones from Andorhal, a costly goblin mold in Gadgetzan, a forging at Fire Plume Ridge, and Araj's scarab in the ruined city. The finished Skeleton Key turned Caer Darrow's locked academy from a rumor into a place you could finally confront.",
            quests = {
                { id = 5533, name = "Scholomance", npc = "Commander Ashlam Valorfist", faction = "Alliance" },
                { id = 838, name = "Scholomance", npc = "High Executor Derrington", faction = "Horde" },
                { id = 5537, name = "Skeletal Fragments", npc = "Alchemist Arbington", faction = "Alliance" },
                { id = 964, name = "Skeletal Fragments", npc = "Apothecary Dithers", faction = "Horde" },
                { id = 5538, name = "Mold Rhymes With...", npc = "Alchemist Arbington", faction = "Alliance" },
                { id = 5514, name = "Mold Rhymes With...", npc = "Apothecary Dithers", faction = "Horde" },
                { id = 5801, name = "Fire Plume Forged", npc = "Krinkle Goodsteel", faction = "Alliance" },
                { id = 5802, name = "Fire Plume Forged", npc = "Krinkle Goodsteel", faction = "Horde" },
                { id = 5803, name = "Araj's Scarab", npc = "Alchemist Arbington", faction = "Alliance" },
                { id = 5804, name = "Araj's Scarab", npc = "Apothecary Dithers", faction = "Horde" },
                { id = 5505, name = "The Key to Scholomance", npc = "Alchemist Arbington", faction = "Alliance" },
                { id = 5511, name = "The Key to Scholomance", npc = "Apothecary Dithers", faction = "Horde" },
            },
        },
        {
            chapter = "The Sarkhoffs",
            requiredLevel = 55,
            summary = "Eva Sarkhoff asks you to punish Krastinov, recover his bag, and summon Kirtonos.",
            recap = "Eva Sarkhoff's grief had been waiting outside the school. Doctor Theolen Krastinov had butchered her family, and Jandice Barov guarded the next proof. When the Blood of Innocents called Kirtonos to the balcony, Scholomance answered with one of its own monsters, and Eva's vengeance finally had form.",
            quests = {
                { id = 5382, name = "Doctor Theolen Krastinov, the Butcher", npc = "Eva Sarkhoff" },
                { id = 5515, name = "Krastinov's Bag of Horrors", npc = "Eva Sarkhoff" },
                { id = 5384, name = "Kirtonos the Herald", npc = "Eva Sarkhoff" },
            },
        },
        {
            chapter = "Ras Frostwhisper",
            requiredLevel = 57,
            summary = "Learn who Ras Frostwhisper was, restore the memory of his death, and face the lich in Scholomance.",
            recap = "Ras Frostwhisper was not born a lich. Magistrate Marduke and Artist Renfray helped recover the human truth beneath the monster: a keepsake, a memory at Menethil's Gift, and a ritual strong enough to pull Ras back toward mortality. In Scholomance, the keepsake made him vulnerable. Killing him ended a lich and returned a human head to Caer Darrow.",
            quests = {
                { id = 5461, name = "The Human, Ras Frostwhisper", npc = "Magistrate Marduke" },
                { id = 5462, name = "The Dying, Ras Frostwhisper", npc = "Magistrate Marduke" },
                { id = 5463, name = "Menethil's Gift", npc = "Artist Renfray" },
                { id = 5464, name = "Menethil's Gift", npc = "Menethil's Gift", mapID = 22, x = 0.7000, y = 0.7300, location = "Caer Darrow, Western Plaguelands" },
                { id = 5465, name = "Soulbound Keepsake", npc = "Magistrate Marduke" },
                { id = 5466, name = "The Lich, Ras Frostwhisper", npc = "Magistrate Marduke" },
            },
        },
        {
            chapter = "Barov Family Fortune",
            requiredLevel = 52,
            summary = "Recover the Barov deeds from Scholomance, then choose which heir becomes the last Barov.",
            recap = "The Barov fortune was scattered through Scholomance in deeds to Brill, Tarren Mill, Southshore, and Caer Darrow. Alexi and Weldon each claimed the inheritance and each wanted the other dead. When the papers were recovered, the family matter became murder by proxy, and one brother's claim ended at the other's feet.",
            quests = {
                { id = 5343, name = "Barov Family Fortune", npc = "Weldon Barov", faction = "Alliance" },
                { id = 5341, name = "Barov Family Fortune", npc = "Alexi Barov", faction = "Horde" },
                { id = 5344, name = "The Last Barov", npc = "Weldon Barov", faction = "Alliance" },
                { id = 5342, name = "The Last Barov", npc = "Alexi Barov", faction = "Horde" },
            },
        },
    },
}
