local addonName, SM = ...

-- =============================================================================
-- Legion Hunter Campaign: The Unseen Path
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.HunterCampaignData = {
    title = "Huntmaster's Campaign",
    achievementName = "The Huntmaster's Campaign",
    achievements = { 42273, 10746, 10994, 11171, 11223 },
    description = "From Trueshot Lodge high in the mountains, the Unseen Path watches over Azeroth. Its hunters know the old trails, the hidden passes, and the signs most armies march past without seeing.\n\nAs the order's newest champion, recruit legendary trackers, root out Legion threats, and defend the wild places and cities that still need sharp eyes on the horizon.",
    zone = "Trueshot Lodge / Broken Isles",
    expansion = "Legion",
    class = "HUNTER",
    color = { 0.67, 0.83, 0.45 },  -- Hunter green
    adventureGuideInstanceName = "Halls of Valor",

    startQuest = { id = 40384, name = "Needs of the Hunters", npc = "Snowfeather", location = "Dalaran" },
    startMapID = 627,
    startX = 0.5500,
    startY = 0.6200,

    npcLocations = {
        ["Huntsman Blake"] = { mapID = 7541, x = 0.8020, y = 0.6620, location = "Stormheim" },
        ["Loren Stormhoof"] = { mapID = 7877, x = 0.5200, y = 0.5560, location = "Trueshot Lodge" },
        ["Snowfeather"]                 = { mapID = 627, x = 0.4160, y = 0.5980 },
        ["Emmarel Shadewarden"]         = { mapID = 739, x = 0.5980, y = 0.5300 },
        ["Tactician Tinderfell"]        = { mapID = 739, x = 0.4500, y = 0.5000 },
        ["Altar Keeper Biehn"]          = { mapID = 739, x = 0.4400, y = 0.4600 },
        ["Hudson Crawford"]             = { mapID = 634, x = 0.4160, y = 0.6000, location = "Trueshot Lodge / Broken Isles" },
        ["Beastmaster Hilaire"]         = { mapID = 634, x = 0.3460, y = 0.4160, location = "Trueshot Lodge / Broken Isles" },
        ["Rexxar"]                      = { mapID = 650, x = 0.4400, y = 0.3700 },
        ["Halduron Brightwing"]         = { mapID = 739, x = 0.5020, y = 0.6600 },
        ["Shandris Feathermoon"]        = { mapID = 646, x = 0.4640, y = 0.3460 },
        ["D'Bynn"]                      = { mapID = 646, x = 0.5220, y = 0.4880 },
        ["Archmage Khadgar"]            = { mapID = 627, x = 0.3300, y = 0.5700 },
        ["Kira Iresoul"]                = { mapID = 630, x = 0.6080, y = 0.3060 },
        ["Hemet Nesingwary"]            = { mapID = 650, x = 0.4000, y = 0.5200 },
        ["Nighthuntress Syrenne"]       = { mapID = 646, x = 0.4500, y = 0.6500 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4450, y = 0.6250 },
        ["Nimi Brightcastle"]           = { mapID = 646, x = 0.4600, y = 0.6300 },
    },

    npcDisplayIDs = {
        ["Snowfeather"]                 = 67694,
        ["Emmarel Shadewarden"]         = 66672,
        ["Tactician Tinderfell"]        = 67962,
        ["Altar Keeper Biehn"]          = 67913,
        ["Hudson Crawford"]             = 69938,
        ["Beastmaster Hilaire"]         = 69138,
        ["Rexxar"]                      = 60766,
        ["Halduron Brightwing"]         = 19707,
        ["Shandris Feathermoon"]        = 2035,
        ["Archmage Khadgar"]            = 65834,
        ["Kira Iresoul"]                = 68731,
        ["Hemet Nesingwary"]            = 63995,
        ["Nighthuntress Syrenne"]       = 66261,
        ["Maiev Shadowsong"]            = 77009,
        ["Nimi Brightcastle"]           = 63552,
    },

    -- =========================================================================
    -- Main campaign chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Introduction
        {
            chapter = "The Unseen Path",
            summary = "An eagle leads you to Trueshot Lodge, where the Unseen Path — an ancient order of hunters — calls you to serve as champion.",
            recap = "Snowfeather, a majestic eagle, arrived in Dalaran bearing an urgent summons. You followed the bird to Trueshot Lodge high in the mountains, where Emmarel Shadewarden revealed the Unseen Path — a secret order of hunters that had watched over Azeroth for generations. You swore the Oath of Service, claimed a weapon of legend, and took your place among their ranks.",
            quests = {
                { id = 40384, name = "Needs of the Hunters",       npc = "Snowfeather" },
                { id = 41415, name = "The Hunter's Call",           npc = "Emmarel Shadewarden" },
                { id = 40618, name = "Weapons of Legend",           npc = "Emmarel Shadewarden" },
                { id = 40953, name = "On Eagle's Wings",            npc = "Emmarel Shadewarden" },
                { id = 40954, name = "The Unseen Path",             npc = "Emmarel Shadewarden" },
                { id = 40955, name = "Oath of Service",             npc = "Emmarel Shadewarden" },
                { id = 40958, name = "Tactical Matters",            npc = "Emmarel Shadewarden" },
                { id = 40959, name = "The Campaign Begins",         npc = "Tactician Tinderfell" },
            },
        },

        -- CHAPTER 2: Establishing the Order
        {
            chapter = "Rise, Champions",
            summary = "Recruit the first champions of the Unseen Path and send troops into the field across the Broken Isles.",
            recap = "With the Unseen Path established, you set about building its strength. Loren Stormhoof was the first to answer the call, pledging as champion. Tactician Tinderfell organized scouts and soldiers, dispatching them across the Broken Isles to gather intelligence and hold the line while you prepared for the greater battles ahead.",
            quests = {
                { id = 42519, name = "Rise, Champions",            npc = "Altar Keeper Biehn" },
                { id = 42409, name = "Champion: Loren Stormhoof",   npc = "Loren Stormhoof" },
                { id = 40957, name = "A Strong Right Hand",         npc = "Emmarel Shadewarden" },
                { id = 42523, name = "Making Contact",              npc = "Tactician Tinderfell" },
                { id = 42524, name = "Recruiting The Troops",       npc = "Tactician Tinderfell" },
                { id = 42525, name = "Troops in the Field",         npc = "Tactician Tinderfell" },
                { id = 42526, name = "Tech It Up A Notch",          npc = "Tactician Tinderfell" },
            },
        },

        -- CHAPTER 3: Watchers in the Wild I
        {
            chapter = "Watchers in the Wild",
            summary = "Scouting reports reveal Legion assassins targeting the Unseen Path. Track them across Stormheim while recruiting Rexxar and Hilaire.",
            recap = "Scouting reports painted a grim picture — Legion assassins had infiltrated the Broken Isles, targeting the Unseen Path's agents. You tracked them through Stormheim, rescuing Hudson Crawford from an ambush and calling Beastmaster Hilaire home from the wilds. In Highmountain, you found Rexxar living among the beasts and convinced the legendary hunter to join your cause. With new champions at your side, the Unseen Path's eyes grew sharper.",
            quests = {
                { id = 42384, name = "Scouting Reports",           npc = "Tactician Tinderfell" },
                { id = 42385, name = "Lending a Hand",              npc = "Emmarel Shadewarden" },
                { id = 42386, name = "Rising Troubles",             npc = "Hudson Crawford" },
                { id = 42387, name = "Assassin Entrapment",         npc = "Hudson Crawford" },
                { id = 42388, name = "Urgent Summons",              npc = "Snowfeather" },
                { id = 42389, name = "Calling Hilaire Home",        npc = "Emmarel Shadewarden" },
                { id = 42391, name = "Bite of the Beast",           npc = "Beastmaster Hilaire" },
                { id = 42393, name = "Homecoming",                  npc = "Beastmaster Hilaire" },
                { id = 42411, name = "Champion: Beastmaster Hilaire", npc = "Beastmaster Hilaire" },
                { id = 42390, name = "Recruiting Rexxar",           npc = "Emmarel Shadewarden" },
                { id = 43335, name = "Survival Skills",             npc = "Rexxar" },
                { id = 42392, name = "Survive the Night",           npc = "Rexxar" },
                { id = 42410, name = "Champion: Rexxar",            npc = "Rexxar" },
                { id = 42395, name = "Signaling Trouble",           npc = "Emmarel Shadewarden" },
            },
        },

        -- CHAPTER 4: Watchers in the Wild II
        {
            chapter = "The Nature of the Beast",
            summary = "The trail leads to Azsuna, where a leyworm infestation masks something far more dangerous. Hemet Nesingwary lends his expertise.",
            recap = "Hemet Nesingwary joined the hunt in Highmountain, his expertise invaluable as you tracked the Legion's movements. But the true threat emerged in Azsuna — leyworms corrupted by demonic energy, twisting the beasts of the land into weapons. Working with Kira Iresoul, you lured out the source of the corruption and tamed it, proving that a hunter's bond with nature was stronger than any demon's magic.",
            quests = {
                { id = 42394, name = "Unseen Protection",          npc = "Emmarel Shadewarden" },
                { id = 42403, name = "Highmountain Hunters",        npc = "Tactician Tinderfell" },
                { id = 42134, name = "Recruiting More Troops",      npc = "Tactician Tinderfell" },
                { id = 42413, name = "Champion: Hemet Nesingwary",  npc = "Hemet Nesingwary" },
                { id = 42397, name = "Baron and the Huntsman",      npc = "Emmarel Shadewarden" },
                { id = 42398, name = "Awakening the Senses",        npc = "Huntsman Blake" },
                { id = 42412, name = "Champion: Huntsman Blake",    npc = "Huntsman Blake" },
                { id = 42400, name = "Missing Mages",               npc = "Emmarel Shadewarden" },
                { id = 42401, name = "The Scent of Magic",          npc = "Archmage Khadgar" },
                { id = 42404, name = "Assisting the Archmage",      npc = "Archmage Khadgar" },
                { id = 42689, name = "Knowing Our Enemy",           npc = "Emmarel Shadewarden" },
                { id = 42691, name = "Leyworm Lure",                npc = "Kira Iresoul" },
                { id = 42406, name = "To Tame the Beast",           npc = "Kira Iresoul" },
                { id = 42407, name = "The Nature of the Beast",     npc = "Kira Iresoul" },
            },
        },

        -- CHAPTER 5: In Defense of Dalaran
        {
            chapter = "In Defense of Dalaran",
            summary = "The Legion launches a direct assault on Dalaran through the Violet Hold. Rally the Unseen Path's champions for the final defense.",
            recap = "All the threads came together when the Legion launched a full assault on Dalaran itself, breaching the Violet Hold with demonic forces. Halduron Brightwing helped you forge new weapons and prepare defenses, while Shandris Feathermoon rallied reinforcements. You led the Unseen Path into the Violet Hold and faced Hakkar the Houndmaster in a battle that shook the city. When the demon fell, Emmarel Shadewarden bestowed upon you the title of Huntmaster — the highest honor the Unseen Path could give.",
            quests = {
                { id = 42402, name = "Requesting Reinforcements",  npc = "Emmarel Shadewarden" },
                { id = 42405, name = "Informing Our Allies",        npc = "Emmarel Shadewarden" },
                { id = 42654, name = "Darkheart Thicket: Nightmare Oak", npc = "Halduron Brightwing" },
                { id = 44680, name = "Leading by Example",          npc = "Emmarel Shadewarden" },
                { id = 42657, name = "Meeting in Moonclaw Vale",    npc = "Shandris Feathermoon" },
                { id = 42415, name = "Champion: Halduron Brightwing", npc = "Halduron Brightwing" },
                { id = 42659, name = "In Defense of Dalaran",       npc = "Emmarel Shadewarden" },
                { id = 44090, name = "Pledge of Loyalty",           npc = "Snowfeather" },
            },
        },

        -- CHAPTER 6: Broken Shore & Class Mount
        {
            chapter = "Night of the Wilds",
            summary = "The war moves to the Broken Shore. Lead the Unseen Path against the Legion's corrupted beasts and earn the trust of a loyal wolfhawk.",
            recap = "On the Broken Shore, the Legion had corrupted wild beasts into felbound monstrosities. Shandris Feathermoon coordinated the assault while Nighthuntress Syrenne led you deep into enemy territory to soothe the wounded creatures and strike at the source of the corruption. When the Broken Shore was secured, you answered a final call — the Night of the Wilds, where a wolfhawk tested your worth as a hunter. It found you worthy, and pledged its loyalty to the Huntmaster.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45551, name = "Devastating Effects",         npc = "Shandris Feathermoon" },
                { id = 45552, name = "Soothing Wounds",             npc = "D'Bynn" },
                { id = 45553, name = "The Nighthuntress Beckons",   npc = "D'Bynn" },
                { id = 45554, name = "Taking Control",              npc = "Nighthuntress Syrenne" },
                { id = 45555, name = "Felbound Beasts",             npc = "Nighthuntress Syrenne" },
                { id = 45556, name = "Ready to Strike",             npc = "Nighthuntress Syrenne" },
                { id = 45557, name = "Unnatural Consequences",      npc = "Nighthuntress Syrenne" },
                { id = 46060, name = "Salvation",                   npc = "Nighthuntress Syrenne" },
                { id = 46048, name = "Champion: Nighthuntress Syrenne", npc = "Nighthuntress Syrenne" },
                { id = 46336, name = "A Golden Ticket",             npc = "Nimi Brightcastle" },
                { id = 46337, name = "Night of the Wilds",          npc = "Nimi Brightcastle" },
            },
        },

        -- CHAPTER 7-9: Artifact Weapons
        {
            chapter = "Titanstrike",
            summary = "Track down Titanstrike, a legendary rifle forged by the titan keeper Mimiron, lost in the wilds of Ulduar.",
            recap = "Grif Wildheart spoke of Titanstrike — a rifle of immense power forged by Mimiron himself in the halls of Ulduar. You embarked on a beastly expedition to recover the weapon, facing titan constructs and wild guardians. When you finally held Titanstrike, its mechanisms hummed with the power of a thousand storms.",
            quests = {
                { id = 41541, name = "A Beastly Expedition",        npc = "Emmarel Shadewarden" },
            },
        },
        {
            chapter = "Thas'dorah, Legacy of the Windrunners",
            summary = "Recover the ancient bow of the Windrunner family, lost when Alleria Windrunner vanished beyond the Dark Portal.",
            recap = "A courier brought word of Thas'dorah — the ancestral bow of the Windrunner family, carried by Alleria into the Twisting Nether and lost for decades. You followed the trail through ancient elven ruins, fighting off demons who sought to claim its power. The bow sang in your hands when you drew it, as if it had been waiting for a worthy archer all along.",
            quests = {
                { id = 41540, name = "Rendezvous with the Courier", npc = "Emmarel Shadewarden" },
            },
        },
        {
            chapter = "Talonclaw",
            summary = "Seek the ancient eagle spear Talonclaw in the peaks of Highmountain, a weapon sacred to the hunters of old.",
            recap = "Apata Highmountain told the tale of Talonclaw — an eagle spear wielded by the greatest hunters of Highmountain since the age of the titans. You climbed into the highest peaks and proved yourself in trials of survival, tracking, and combat. When you claimed Talonclaw from its ancient resting place, the spirits of past hunters looked on with approval.",
            quests = {
                { id = 41542, name = "Preparation for the Hunt",    npc = "Emmarel Shadewarden" },
            },
        },
    },
}
