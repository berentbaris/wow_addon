local addonName, SM = ...

-- =============================================================================
-- Legion Druid Campaign: The Dreamgrove
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.DruidCampaignData = {
    title = "Archdruid's Campaign",
    achievementName = "The Archdruid's Campaign",
    achievements = { 42272, 10746, 10994, 11171, 11223 },
    description = "Through the Emerald Dreamway, you discover the Dreamgrove: a sanctuary of nature hidden in Val'sharah. The Legion's war is spreading into places that should have been beyond its reach.\n\nAs Archdruid of the Cenarion Circle, heal the wounds of the Nightmare, gather ancient allies, and call on powers older than any mortal battlefield.",
    zone = "The Dreamgrove / Broken Isles",
    expansion = "Legion",
    class = "DRUID",
    color = { 1.00, 0.49, 0.04 },  -- Druid orange
    adventureGuideInstanceName = "The Emerald Nightmare",

    startQuest = { id = 40643, name = "A Summons From Moonglade", npc = "Archdruid Hamuul Runetotem", location = "Dalaran" },
    startMapID = 627,
    startX = 0.7200,
    startY = 0.4600,

    npcLocations = {
        ["Broll Bearmantle"] = { mapID = 7558, x = 0.5700, y = 0.7120, location = "Val'sharah" },
        ["Delandros Shimmermoon"] = { mapID = 7558, x = 0.7320, y = 0.4260, location = "Val'sharah" },
        ["Sylendra Gladesong"] = { mapID = 7558, x = 0.5680, y = 0.7140, location = "Val'sharah" },
        ["Archdruid Hamuul Runetotem"]  = { mapID = 627, x = 0.5620, y = 0.3200 },
        ["Malfurion Stormrage"]         = { mapID = 641, x = 0.5200, y = 0.5100 },
        ["Keeper Remulos"]              = { mapID = 641, x = 0.6040, y = 0.2360 },
        ["Rensar Greathoof"]            = { mapID = 747, x = 0.5200, y = 0.5100 },
        ["Skylord Omnuron"]             = { mapID = 747, x = 0.5000, y = 0.4800 },
        ["Brightwing"]                  = { mapID = 747, x = 0.3760, y = 0.4280 },
        ["Image of Kalec"]              = { mapID = 627, x = 0.2680, y = 0.4040 },
        ["Naralex"]                     = { mapID = 747, x = 0.4480, y = 0.5160 },
        ["Mylune"]                      = { mapID = 747, x = 0.5700, y = 0.4720 },
        ["Malorne"]                     = { mapID = 747, x = 0.6600, y = 0.6660 },
        ["Thisalee Crow"]               = { mapID = 646, x = 0.4480, y = 0.5140 },
        ["Grovewarden Proudhorn"]       = { mapID = 646, x = 0.4380, y = 0.6300 },
        ["Lea Stonepaw"]                = { mapID = 747, x = 0.5400, y = 0.5100 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4450, y = 0.6250 },
    },

    npcDisplayIDs = {
        ["Archdruid Hamuul Runetotem"]  = 31605,
        ["Malfurion Stormrage"]         = 35095,
        ["Keeper Remulos"]              = 11906,
        ["Rensar Greathoof"]            = 67016,
        ["Skylord Omnuron"]             = 32245,
        ["Naralex"]                     = 68026,
        ["Mylune"]                      = 72120,
        ["Malorne"]                     = 72123,
        ["Thisalee Crow"]               = 32254,
        ["Lea Stonepaw"]                = 68584,
        ["Maiev Shadowsong"]            = 77009,
    },

    -- =========================================================================
    -- Main campaign chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Introduction
        {
            chapter = "The Dreamgrove",
            summary = "Hamuul Runetotem sends an urgent summons. Through the Emerald Dreamway, you discover the Dreamgrove and take up a weapon of legend.",
            recap = "Archdruid Hamuul Runetotem's summons led you to Moonglade, where Malfurion Stormrage revealed the Emerald Dreamway — ancient paths woven through the Dream itself. Keeper Remulos guided you through to the Dreamgrove, a sanctuary hidden in Val'sharah. There, Rensar Greathoof asked you to claim an artifact weapon and plant the Seed of Ages, binding your fate to the land. You ascended the Cenarion Circle as its newest Archdruid.",
            quests = {
                { id = 40643, name = "A Summons From Moonglade",   npc = "Archdruid Hamuul Runetotem" },
                { id = 41106, name = "Call of the Wilds",           npc = "Archdruid Hamuul Runetotem" },
                { id = 40644, name = "The Dreamway",                npc = "Archdruid Hamuul Runetotem" },
                { id = 40645, name = "To The Dreamgrove",           npc = "Malfurion Stormrage" },
                { id = 40646, name = "Weapons of Legend",           npc = "Rensar Greathoof" },
                { id = 41255, name = "Sowing The Seed",             npc = "Rensar Greathoof" },
                { id = 40651, name = "The Seed of Ages",            npc = "Rensar Greathoof" },
                { id = 41332, name = "Ascending The Circle",        npc = "Rensar Greathoof" },
            },
        },

        -- CHAPTER 2: Establishing the Order Hall
        {
            chapter = "Branching Out",
            summary = "Strengthen the Dreamgrove by recruiting champions, training troops, and establishing flight paths through the ancient dreamways.",
            recap = "The Dreamgrove needed defenders. Rensar Greathoof tasked you with growing the order's power — recruiting champions to stand at your side and training troops drawn from every corner of Azeroth's wilds. Skylord Omnuron opened new paths through the Dreamway, connecting the Dreamgrove to the wider world. With each branch that grew, the sanctuary's roots dug deeper.",
            quests = {
                { id = 40652, name = "Word on the Winds",          npc = "Malfurion Stormrage" },
                { id = 40653, name = "Making Trails",               npc = "Skylord Omnuron" },
                { id = 42516, name = "Growing Power",               npc = "Rensar Greathoof" },
                { id = 42583, name = "Rise, Champions",             npc = "Rensar Greathoof" },
                { id = 42585, name = "Recruiting the Troops",       npc = "Skylord Omnuron" },
                { id = 42586, name = "A Glade Defense",             npc = "Skylord Omnuron" },
                { id = 42588, name = "Branching Out",               npc = "Skylord Omnuron" },
            },
        },

        -- CHAPTER 3: Idol of the Wilds
        {
            chapter = "Idol of the Wilds",
            summary = "The Emerald Nightmare spreads unchecked. Naralex leads you into the corrupted wilds to find the Idol of the Wilds before the Nightmare claims it.",
            recap = "Naralex, the druid who once fell to the Nightmare in the Wailing Caverns, sensed dire growth spreading through the Dream. Together you ventured into nightmare-twisted lands, sampling the corruption to understand its nature. In Malorne's Refuge you found the great stag's sanctuary under siege. You tracked the source of the corruption to its heart and recovered the Idol of the Wilds — an ancient artifact that could turn the tide against the Nightmare.",
            quests = {
                { id = 42031, name = "Dire Growth",                npc = "Skylord Omnuron" },
                { id = 42032, name = "Sampling the Nightmare",     npc = "Skylord Omnuron" },
                { id = 42033, name = "Malorne's Refuge",            npc = "Rensar Greathoof" },
                { id = 42034, name = "Grip of Nightmare",           npc = "Broll Bearmantle" },
                { id = 42035, name = "Tracking the Enemy",          npc = "Sylendra Gladesong" },
                { id = 42036, name = "Idol of the Wilds",           npc = "Sylendra Gladesong" },
            },
        },

        -- CHAPTER 4: A New Beginning
        {
            chapter = "A New Beginning",
            summary = "With the Idol recovered, recruit Hamuul and Mylune as champions and power the Dreamgrove's portal to prepare for the final battle.",
            recap = "The Idol of the Wilds breathed new life into the Dreamgrove. Archdruid Hamuul Runetotem and the irrepressible Mylune pledged themselves as champions, along with the spirited Brightwing. Together you focused the Dreamgrove's energies into its portal, strengthening the connection between the waking world and the Dream. The Cenarion Circle stood united — and the Nightmare would feel its wrath.",
            quests = {
                { id = 42046, name = "A New Beginning",             npc = "Keeper Remulos" },
                { id = 42047, name = "Champion: Hamuul Runetotem",  npc = "Archdruid Hamuul Runetotem" },
                { id = 42048, name = "Champion: Mylune",            npc = "Mylune" },
                { id = 43368, name = "Champion: Brightwing",        npc = "Brightwing" },
                { id = 42049, name = "Powering the Portal",         npc = "Keeper Remulos" },
                { id = 42365, name = "Focusing the Energies",       npc = "Keeper Remulos" },
                { id = 43403, name = "Defending the Isles",         npc = "Keeper Remulos" },
            },
        },

        -- CHAPTER 5: The Demi-God's Return
        {
            chapter = "The Demi-God's Return",
            summary = "Enter the Nightmare itself to relive the War of the Ancients and awaken Malorne, the great white stag, to fight once more.",
            recap = "The time had come to strike at the Nightmare's heart. Keeper Remulos guided you through a rift into the Dream's darkest depths, where you relived the War of the Ancients — watching Archimonde the Defiler lay waste to the world ten thousand years ago. In that crucible of memory and shadow, you reached Malorne himself. The great white stag stirred, rose, and returned to the waking world. With the demi-god reborn and your weapon forged anew, the Cenarion Circle had become a force even the Legion feared.",
            quests = {
                { id = 42051, name = "Enter Nightmare",             npc = "Rensar Greathoof" },
                { id = 42050, name = "Defenders of the Dream",      npc = "Archdruid Hamuul Runetotem" },
                { id = 42053, name = "The War of the Ancients",     npc = "Keeper Remulos" },
                { id = 42054, name = "Archimonde, The Defiler",     npc = "Keeper Remulos" },
                { id = 42055, name = "The Demi-God's Return",       npc = "Malorne" },
                { id = 43409, name = "A Hero's Weapon",             npc = "Rensar Greathoof" },
                { id = 42056, name = "Champion: Remulos",           npc = "Keeper Remulos" },
                { id = 42045, name = "Communing With Malorne",      npc = "Archdruid Hamuul Runetotem" },
            },
        },

        -- CHAPTER 6: Broken Shore & Class Mount
        {
            chapter = "You Can't Take the Sky from Me",
            summary = "The war reaches the Broken Shore. Defend the wilds, recruit Thisalee Crow, and earn the Archdruid's Lunarwing flight form.",
            recap = "The Broken Shore demanded the Dreamgrove's strength. Thisalee Crow, fierce and fearless, joined your cause as the war escalated. Rensar Greathoof channeled the Dreamgrove's power to aid the Legionfall assault, granting you the ability to call upon nature even in the most fel-scarred land. When the battle was won, Thisalee brought word of Aviana under attack — you rushed to defend the mother of flight and earned the Lunarwing form, soaring above the world as only an Archdruid could.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 44869, name = "Talon Terror",                npc = "Thisalee Crow" },
                { id = 46044, name = "Champion: Thisalee Crow",     npc = "Thisalee Crow" },
                { id = 45425, name = "Grovebound",                  npc = "Rensar Greathoof" },
                { id = 43496, name = "The Power Within",            npc = "Image of Kalec" },
                { id = 46317, name = "Talon's Call",                npc = "Grovewarden Proudhorn" },
                { id = 46318, name = "Defense of Aviana",           npc = "Thisalee Crow" },
                { id = 46319, name = "You Can't Take the Sky from Me", npc = "Thisalee Crow" },
            },
        },

        -- CHAPTER 7-10: Artifact Weapons
        {
            chapter = "The Scythe of Elune",
            summary = "Seek the Scythe of Elune, a weapon of terrible power tied to the worgen curse and the moon goddess herself.",
            recap = "Naralex revealed the location of the Scythe of Elune — an artifact of immense power forged from Elune's staff and the Fang of Goldrinn. You journeyed through cursed lands to claim it, feeling the pull of both the moon's light and the beast within. The Scythe chose you, and with it came the weight of every druid who had wielded it before.",
            quests = {
                { id = 40783, name = "The Scythe of Elune",        npc = "Naralex" },
            },
        },
        {
            chapter = "Fangs of Ashamane",
            summary = "Track down the Fangs of Ashamane, twin daggers imbued with the spirit of the wild god of feral druids.",
            recap = "The Fangs of Ashamane — twin daggers blessed by the wild god of the hunt — had been lost in the wilds of Val'sharah. You tracked them through ancient feral grounds, facing guardians left by Ashamane herself. When you grasped the Fangs, the spirit of the great cat surged through you, and the wilds themselves seemed to sharpen around your senses.",
            quests = {
                { id = 42430, name = "The Fangs of Ashamane",      npc = "Delandros Shimmermoon" },
            },
        },
        {
            chapter = "Claws of Ursoc",
            summary = "Recover the Claws of Ursoc, the great bear god's weapons, from the nightmares that have claimed them.",
            recap = "Lea Stonepaw told of the Claws of Ursoc — weapons that carried the strength of the bear god who had given his life defending Azeroth. You entered the nightmare-touched dens where the Claws had been hidden and fought through the corruption to reclaim them. The weight of Ursoc's sacrifice settled into your hands along with the weapons — a guardian's burden, willingly carried.",
            quests = {
                { id = 41468, name = "Mistress of the Claw",       npc = "Rensar Greathoof" },
            },
        },
        {
            chapter = "G'Hanir, the Mother Tree",
            summary = "Journey deep into the Emerald Dream to recover G'Hanir, the branch from which all world trees grew.",
            recap = "Keeper Remulos spoke of G'Hanir — the mother branch from which Nordrassil, Teldrassil, and every world tree had grown. It slumbered deep in the Emerald Dream, and the Nightmare sought to consume it. You ventured into the Dream's purest heart and returned with G'Hanir in hand, its leaves still green with the life of an entire world.",
            quests = {
                { id = 41436, name = "In Deep Slumber",            npc = "Naralex" },
            },
        },
    },
}
