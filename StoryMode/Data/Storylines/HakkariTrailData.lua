local addonName, SM = ...

-- =============================================================================
-- Classic: The Hakkari Trail
-- Yeh'kinya, the Mosh'aru Tablets, Hakkar, and the road to Zul'Gurub.
-- =============================================================================

SM.HakkariTrailData = {
    title = "The Hakkari Trail",
    description = "At Steamwheedle Port, Yeh'kinya asks for help with old troll spirits and older tablets. The work sounds archaeological at first, but the names on the tablets are not harmless history.\n\nFollow the trail from Feralas and Zul'Farrak to Jintha'Alor, the Temple of Atal'Hakkar, Blackrock Spire, and finally Yojamba Isle. What begins as a favor for a lone troll becomes a warning about the Soulflayer's return.",
    zone = "Tanaris / Feralas / Zul'Farrak / The Hinterlands / Sunken Temple / Blackrock Spire / Stranglethorn Vale",
    expansion = "Classic",
    recommendedLevel = { min = 40, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.82, 0.54, 0.18 },
    icon = 136127,
    adventureGuideInstanceName = "Zul'Farrak",
    adventureCoverTexture = 131886, -- Zul'Gurub loading screen: Hakkari and Zandalar payoff
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 3520, name = "Screecher Spirits", npc = "Yeh'kinya", location = "Steamwheedle Port, Tanaris" },
    startMapID = 71,
    startX = 0.6680,
    startY = 0.2290,

    npcLocations = {
        ["Yeh'kinya"] = { mapID = 71, x = 0.6680, y = 0.2290, location = "Steamwheedle Port, Tanaris" },
        ["Prospector Ironboot"] = { mapID = 71, x = 0.6680, y = 0.2450, location = "Steamwheedle Port, Tanaris" },
        ["Theka the Martyr"] = { mapID = 219, x = 0.4500, y = 0.4400, location = "Zul'Farrak" },
        ["Hydromancer Velratha"] = { mapID = 219, x = 0.6200, y = 0.2800, location = "Zul'Farrak, near Gahz'rilla's pool" },
        ["Ancient Egg"] = { mapID = 26, x = 0.6600, y = 0.6600, location = "the summit cave at Jintha'Alor, The Hinterlands" },
        ["Avatar of Hakkar"] = { mapID = 220, x = 0.3400, y = 0.7800, location = "the Sanctum of the Fallen God, Temple of Atal'Hakkar" },
        ["Mosh'aru Tablets"] = { mapID = 23, x = 0.7200, y = 0.1500, location = "Zul'Mashar, Eastern Plaguelands" },
        ["Smolderthorn Tablets"] = { mapID = 250, x = 0.4200, y = 0.6800, location = "Lower Blackrock Spire" },
        ["Molthor"] = { mapID = 50, x = 0.1500, y = 0.1500, location = "Yojamba Isle, Stranglethorn Vale" },
    },

    chapterDisplayIDs = {
        ["Screecher Spirits"] = 3733,
        ["The Prophecy of Mosh'aru"] = 11279,
        ["The God Hakkar"] = 7842,
        ["The Final Tablets"] = 9291,
        ["The Hand of Rastakhan"] = 15295,
    },

    chapterIcons = {
        ["Screecher Spirits"] = 136122,
        ["The Prophecy of Mosh'aru"] = 133741,
        ["The God Hakkar"] = 136127,
        ["The Final Tablets"] = 134459,
        ["The Hand of Rastakhan"] = 132117,
    },

    chapters = {
        {
            chapter = "Screecher Spirits",
            summary = "Yeh'kinya sends you into Feralas to question the spirits of Vale Screechers.",
            recap = "The first clue was not written on stone. Yeh'kinya's bramble drew memories from dead screechers in Feralas, and those spirits pointed toward an old troll prophecy. The errand had opened a door into Hakkari history.",
            quests = {
                { id = 3520, name = "Screecher Spirits", npc = "Yeh'kinya" },
            },
        },
        {
            chapter = "The Prophecy of Mosh'aru",
            summary = "Recover the first two Mosh'aru tablets from Zul'Farrak, then seek the ancient egg hidden in Jintha'Alor.",
            recap = "Zul'Farrak held the first tablets: one with Theka the Martyr, one near Hydromancer Velratha and the sacred pool. Their prophecy named an ancient egg, a relic from the age of troll empires. At Jintha'Alor, the egg waited behind the amphitheater at the top of the city, guarded by the kind of history that still had teeth.",
            quests = {
                { id = 3527, name = "The Prophecy of Mosh'aru", npc = "Yeh'kinya" },
                { id = 4787, name = "The Ancient Egg", npc = "Yeh'kinya" },
            },
        },
        {
            chapter = "The God Hakkar",
            summary = "Carry the egg into the Temple of Atal'Hakkar and bind the avatar's essence inside it.",
            recap = "The temple in the Swamp of Sorrows gave the prophecy its true weight. The egg was not merely a container for old magic; it was a vessel for Hakkar's essence. In the Sanctum of the Fallen God, the avatar rose, fell, and left behind power Yeh'kinya had asked you to gather.",
            quests = {
                { id = 3528, name = "The God Hakkar", npc = "Yeh'kinya" },
            },
        },
        {
            chapter = "The Final Tablets",
            summary = "Prospector Ironboot reveals the missing tablets and sends you to Eastern Plaguelands and Lower Blackrock Spire.",
            recap = "Prospector Ironboot saw the lie in the work Yeh'kinya had given you. There were six tablets, not two, and the rest changed the meaning of the prophecy. Zul'Mashar held the third and fourth; Lower Blackrock Spire held the final pair. Piece by piece, the tablets stopped sounding like a way to contain Hakkar and started sounding like a way to bring him back.",
            quests = {
                { id = 5065, name = "The Lost Tablets of Mosh'aru", npc = "Prospector Ironboot" },
                { id = 4788, name = "The Final Tablets", npc = "Prospector Ironboot" },
            },
        },
        {
            chapter = "The Hand of Rastakhan",
            summary = "Confront Yeh'kinya, then carry Ironboot's warning to Molthor on Yojamba Isle.",
            recap = "Yeh'kinya had not been preserving the world from Hakkar. He had sped the Soulflayer's return. The truth turned a long dungeon trail into a Zandalar summons, and Molthor received the warning on Yojamba Isle. The fight had moved beyond tablets and temples. Zul'Gurub was waiting.",
            quests = {
                { id = 8181, name = "Confront Yeh'kinya", npc = "Prospector Ironboot" },
                { id = 8182, name = "The Hand of Rastakhan", npc = "Prospector Ironboot" },
            },
        },
    },
}
