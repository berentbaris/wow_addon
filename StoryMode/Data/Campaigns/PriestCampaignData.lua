local addonName, SM = ...

-- =============================================================================
-- Legion Priest Campaign: The Conclave
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.PriestCampaignData = {
    title = "High Priest's Campaign",
    achievementName = "The High Priest's Campaign",
    achievements = { 42277, 10746, 10994, 11171, 11223 },
    description = "In Netherlight Temple, priests of the Light and the Void unite under one banner. Faith, shadow, discipline, and doubt all have a place when the world is facing annihilation.\n\nAs High Priest, bridge old divides, investigate zealots and lost allies, and hold together a conclave built from powers that do not always agree they should stand side by side.",
    zone = "Netherlight Temple / Broken Isles",
    expansion = "Legion",
    class = "PRIEST",
    color = { 0.90, 0.90, 0.90 },  -- Priest white/silver
    adventureGuideInstanceName = "The Seat of the Triumvirate",

    startQuest = { id = 40705, name = "Priestly Matters", npc = "Hooded Priestess", location = "Dalaran" },
    startMapID = 627,
    startX = 0.4700,
    startY = 0.4800,

    npcLocations = {
        ["Hooded Priestess"]            = { mapID = 627, x = 0.4700, y = 0.4800 },
        ["Alonsus Faol"]                = { mapID = 702, x = 0.5100, y = 0.4900 },
        ["Prophet Velen"]               = { mapID = 702, x = 0.4640, y = 0.2080 },
        ["Calia Menethil"]              = { mapID = 702, x = 0.5000, y = 0.5100 },
        ["Moira Thaurissan"]            = { mapID = 702, x = 0.5300, y = 0.5200 },
        ["Lord Maxwell Tyrosus"]        = { mapID = 702, x = 0.4890, y = 0.6370 },
        ["Zabra Hexx"]                  = { mapID = 630, x = 0.5860, y = 0.3720 },
        ["Yalia Sagewhisper"]           = { mapID = 630, x = 0.4800, y = 0.4300 },
        ["Delas Moonfang"]              = { mapID = 702, x = 0.5100, y = 0.5200 },
        ["Natalie Seline"]              = { mapID = 702, x = 0.2420, y = 0.3780 },
        ["Mariella Ward"]               = { mapID = 702, x = 0.5540, y = 0.4060 },
        ["Mariella the Heretic"]        = { mapID = 702, x = 0.7140, y = 0.7180 },
        ["Micah Belford"]               = { mapID = 702, x = 0.2430, y = 0.3790 },
        ["Aelthalyste"]                 = { mapID = 646, x = 0.2980, y = 0.5580 },
        ["Aponi Brightmane"]            = { mapID = 702, x = 0.4880, y = 0.6360 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4460, y = 0.6340 },
        ["Grand Priest"]                = { mapID = 646, x = 0.4440, y = 0.6360 },
        ["Betild Deepanvil"]            = { mapID = 702, x = 0.5040, y = 0.2180 },
    },

    npcDisplayIDs = {
        ["Hooded Priestess"]            = 67598,
        ["Alonsus Faol"]                = 67043,
        ["Prophet Velen"]               = 67048,
        ["Calia Menethil"]              = 67797,
        ["Moira Thaurissan"]            = 28025,
        ["Zabra Hexx"]                  = 71567,
        ["Yalia Sagewhisper"]           = 41874,
        ["Delas Moonfang"]              = 50541,
        ["Natalie Seline"]              = 71568,
        ["Mariella Ward"]               = 71952,
        ["Aelthalyste"]                 = 10723,
        ["Aponi Brightmane"]            = 62788,
    },

    chapters = {
        {
            chapter = "Netherlight Temple",
            summary = "A hooded priestess summons you to Netherlight Temple, where Alonsus Faol — the founder of the priesthood — reveals himself.",
            recap = "A mysterious priestess led you through a portal to Netherlight Temple, a sanctuary floating in the Twisting Nether between the forces of Light and Void. There, Alonsus Faol — the man who had founded the original priesthood of Lordaeron — revealed he had survived as an undead, guiding the faith from the shadows for centuries. Prophet Velen stood beside him, and together they asked you to lead a new Conclave. Calia Menethil and High Priestess Ishanah pledged as your first champions.",
            quests = {
                { id = 40705, name = "Priestly Matters",            npc = "Hooded Priestess" },
                { id = 40706, name = "A Legend You Can Hold",        npc = "Alonsus Faol" },
                { id = 40938, name = "The Light and the Void",       npc = "Prophet Velen" },
                { id = 41019, name = "Actions on Azeroth",           npc = "Alonsus Faol" },
                { id = 43270, name = "Rise, Champions",              npc = "Alonsus Faol" },
                { id = 43271, name = "Champion: Calia Menethil",     npc = "Calia Menethil" },
                { id = 43272, name = "Champion: High Priestess Ishanah", npc = "Alonsus Faol" },
                { id = 43273, name = "Spread the Word",              npc = "Alonsus Faol" },
                { id = 43275, name = "Recruiting the Troops",        npc = "Alonsus Faol" },
                { id = 43276, name = "Troops in the Field",          npc = "Alonsus Faol" },
                { id = 43277, name = "Tech It Up A Notch",           npc = "Alonsus Faol" },
            },
        },

        {
            chapter = "Whispers in the Void",
            summary = "Investigate void disturbances in Azsuna alongside Zabra Hexx and Yalia Sagewhisper.",
            recap = "Alonsus Faol sensed whispers in the Void — disturbances emanating from Azsuna that threatened the balance of Netherlight Temple itself. Prophet Velen sent his best: Zabra Hexx, a shadow priest of the Darkspear, and Yalia Sagewhisper, a Pandaren healer of quiet wisdom. Together you investigated the source, dealing with murloc mind control and disrupted ley lines. Both proved their worth and joined your Conclave as champions.",
            quests = {
                { id = 43372, name = "Whispers in the Void",        npc = "Alonsus Faol" },
                { id = 43373, name = "The Best and Brightest",       npc = "Prophet Velen" },
                { id = 43374, name = "Murloc Mind Control",          npc = "Zabra Hexx" },
                { id = 43375, name = "An Ample Supply",              npc = "Zabra Hexx" },
                { id = 43376, name = "Problem Salver",               npc = "Yalia Sagewhisper" },
                { id = 42137, name = "Champion: Yalia Sagewhisper",  npc = "Yalia Sagewhisper" },
                { id = 42138, name = "Champion: Zabra Hexx",         npc = "Zabra Hexx" },
            },
        },

        {
            chapter = "Scarlet Redemption",
            summary = "Infiltrate the Scarlet Onslaught, the fanatical remnant of the Scarlet Crusade, and recruit a defector to your cause.",
            recap = "The Scarlet Onslaught — fanatical remnants of the Crusade — were gathering strength, and Faol saw an opportunity. You infiltrated their ranks disguised as an envoy, walking among zealots who would have burned you alive. Deep inside, you found Mariella — a heretic within their own ranks who had seen through the madness. You liberated her fellow apostates and brought Mariella Ward into the Conclave, her faith tempered by hard truth rather than blind fury.",
            quests = {
                { id = 43385, name = "Infiltrating Our Enemies",    npc = "Alonsus Faol" },
                { id = 43386, name = "Onslaught Envoy",             npc = "Alonsus Faol" },
                { id = 43387, name = "Scarlet Redemption",          npc = "Mariella the Heretic" },
                { id = 43388, name = "Apostate Liberation",         npc = "Mariella the Heretic" },
                { id = 43389, name = "Unexpected Guests",           npc = "Mariella Ward" },
                { id = 43381, name = "Champion: Mariella Ward",     npc = "Mariella Ward" },
            },
        },

        {
            chapter = "Forgotten Shadows",
            summary = "Recover Natalie Seline, a priest who delved too deep into the Void, from the shadow realm where she has been lost.",
            recap = "Alonsus Faol spoke of Natalie Seline — a brilliant priest who had studied the Void so deeply that it had consumed her. She was trapped in a shadow realm between worlds, and only you could reach her. With Micah Belford guiding you through the darkness, you entered the Void itself and found Seline — transformed, but not lost. She returned to the Conclave carrying shadows that whispered secrets even the Light could not reveal.",
            quests = {
                { id = 43390, name = "Forgotten Shadows",           npc = "Alonsus Faol" },
                { id = 43391, name = "Secrets of the Void",          npc = "Micah Belford" },
                { id = 43392, name = "Into the Void",                npc = "Micah Belford" },
                { id = 43382, name = "Champion: Natalie Seline",     npc = "Natalie Seline" },
                { id = 43393, name = "Rising Shadows",               npc = "Natalie Seline" },
            },
        },

        {
            chapter = "High Priest of Netherlight",
            summary = "Lead the united Conclave to Niskara, rescue captured allies, and earn the title of High Priest.",
            recap = "The Conclave was united — Light and Shadow standing together for the first time. The final test came on Niskara, a Legion prison world where priests and paladins alike were held captive. With Aponi Brightmane and Lord Maxwell Tyrosus lending their strength, you crossed Legion lines and broke the chains. United as one, the Conclave shattered the demon garrison. Alonsus Faol himself pledged as your champion, and Moira Thaurissan forged your weapon anew. You were named High Priest of Netherlight — a title that carried the weight of every faith you had united.",
            quests = {
                { id = 43394, name = "Crossing Legion Lines",       npc = "Lord Maxwell Tyrosus" },
                { id = 43396, name = "The Mind of the Enemy",        npc = "Aponi Brightmane" },
                { id = 43395, name = "Allies of the Light",          npc = "Aponi Brightmane" },
                { id = 43397, name = "United As One",                npc = "Alonsus Faol" },
                { id = 43399, name = "Fortifying the Temple",        npc = "Alonsus Faol" },
                { id = 43401, name = "A Light in the Darkness",      npc = "Alonsus Faol" },
                { id = 43398, name = "Champion: Alonsus Faol",       npc = "Alonsus Faol" },
                { id = 43402, name = "High Priest of Netherlight",   npc = "Alonsus Faol" },
                { id = 43420, name = "A Hero's Weapon",              npc = "Alonsus Faol" },
            },
        },

        {
            chapter = "The Sunken Vault",
            summary = "A contagion strikes the Broken Shore. Cure the plague, recruit Aelthalyste, and seek the High Priest's Seeker mount.",
            recap = "A curious contagion swept the Broken Shore — a plague that twisted both body and spirit. Aelthalyste, a banshee who had rediscovered her faith, helped you trace the disease to its source, craft a cure, and administer it to the fallen. With the contagion contained and Aelthalyste as your newest champion, you answered a final call to the Sunken Vault, where a creature of pure Light awaited — the High Priest's Seeker, a mount that would carry you above the battlefield.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45343, name = "A Curious Contagion",          npc = "Alonsus Faol" },
                { id = 45344, name = "Sampling the Source",          npc = "Aelthalyste" },
                { id = 45347, name = "Crafting a Cure",              npc = "Aelthalyste" },
                { id = 45349, name = "To the Broken Shore",          npc = "Alonsus Faol" },
                { id = 45350, name = "Countering the Contagion",     npc = "Aelthalyste" },
                { id = 46034, name = "Champion: Aelthalyste",        npc = "Aelthalyste" },
                { id = 45788, name = "The Speaker Awaits",           npc = "Grand Priest" },
                { id = 45789, name = "The Sunken Vault",             npc = "Betild Deepanvil" },
            },
        },

        {
            chapter = "T'uure, Beacon of the Naaru",
            summary = "Seek T'uure, a crystal beacon forged by the naaru, whose light has guided the faithful through the darkest ages.",
            recap = "Alonsus Faol spoke of T'uure — a crystal of pure Light created by the naaru themselves, said to be a beacon that could pierce any darkness. You followed a vindicator's plea to its resting place and fought through the shadows to claim it. When T'uure's light filled the room, every wound healed, every doubt faded, and the darkness recoiled.",
            quests = {
                { id = 41957, name = "The Vindicator's Plea",       npc = "Alonsus Faol" },
            },
        },
        {
            chapter = "Light's Wrath",
            summary = "Recover Light's Wrath, a staff of terrible holy power sealed away in the Nexus Vault because it was too dangerous to wield.",
            recap = "Faol warned you about Light's Wrath — a staff of such devastating holy power that the Kirin Tor had sealed it in the Nexus Vault, deeming it too dangerous for any mortal. But desperate times demanded desperate weapons. You breached the Vault's defenses and claimed the staff, feeling its barely contained fury surge through you. Light's Wrath was not a gentle weapon — it was the Light's anger given form.",
            quests = {
                { id = 41625, name = "The Light's Wrath",           npc = "Alonsus Faol" },
            },
        },
        {
            chapter = "Xal'atath, Blade of the Black Empire",
            summary = "Claim Xal'atath, a dagger that whispers with the voice of the Void and remembers the Black Empire that ruled before the titans.",
            recap = "In twilight shadows, Faol revealed the existence of Xal'atath — a blade forged in the age of the Black Empire, before even the titans came to Azeroth. The dagger whispered constantly, its voice ancient and knowing, full of secrets that could drive lesser minds mad. You claimed it from a twilight cult's grasp, and from that moment on, the whispers never stopped. Xal'atath remembered everything — and it wanted you to know.",
            quests = {
                { id = 40710, name = "Blade in Twilight",            npc = "Alonsus Faol" },
            },
        },
    },
}
