local addonName, SM = ...

-- =============================================================================
-- Legion Monk Campaign: Order of the Broken Temple
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.MonkCampaignData = {
    title = "Grandmaster's Campaign",
    achievementName = "The Grandmaster's Campaign",
    achievements = { 42275, 10746, 10994, 11171, 11223 },
    description = "When the Peak of Serenity falls to the Legion, the monks rally at the Temple of Five Dawns on the Wandering Isle. Their order bends, breathes, and returns to its center.\n\nAs Grandmaster, defend sacred training grounds, recruit legendary warriors, and seek the old brews and older lessons that turn discipline into strength.",
    zone = "Wandering Isle / Broken Isles",
    expansion = "Legion",
    class = "MONK",
    color = { 0.00, 0.78, 0.44 },  -- Monk jade green
    adventureGuideInstanceName = "Temple of the Jade Serpent",

    startQuest = { id = 12103, name = "Before the Storm", npc = "Initiate Da-Nel", location = "Dalaran" },
    startMapID = 627,
    startX = 0.5200,
    startY = 0.5700,

    npcLocations = {
        ["Hiro"] = { mapID = 7902, x = 0.5180, y = 0.4960, location = "The Wandering Isle" },
        ["Sylara Steelsong"] = { mapID = 7902, x = 0.5180, y = 0.4960, location = "The Wandering Isle" },
        ["Initiate Da-Nel"]             = { mapID = 627, x = 0.5200, y = 0.5700 },
        ["Fearsome Jang"]               = { mapID = 709, x = 0.5100, y = 0.4800 },
        ["Iron-Body Ponshu"]            = { mapID = 709, x = 0.5200, y = 0.4900 },
        ["Chen Stormstout"]             = { mapID = 709, x = 0.5000, y = 0.5100 },
        ["Li Li Stormstout"]            = { mapID = 709, x = 0.5000, y = 0.5200 },
        ["The Monkey King"]             = { mapID = 709, x = 0.5300, y = 0.5000 },
        ["Taran Zhu"]                   = { mapID = 709, x = 0.5100, y = 0.5300 },
        ["Master Hsu"]                  = { mapID = 709, x = 0.5280, y = 0.5960 },
        ["Instructor Myang"]            = { mapID = 709, x = 0.3820, y = 0.2580 },
        ["High Elder Cloudfall"]        = { mapID = 709, x = 0.5100, y = 0.5000 },
        ["Angus Ironfist"]              = { mapID = 634, x = 0.5800, y = 0.5400 },
        ["Aegira"]                      = { mapID = 634, x = 0.6300, y = 0.2120 },
        ["Brewmaster Blanche"]          = { mapID = 646, x = 0.5140, y = 0.4860 },
        ["Brewer Almai"]                = { mapID = 646, x = 0.5360, y = 0.5340 },
        ["Master Bu"]                   = { mapID = 646, x = 0.3220, y = 0.4320 },
        ["Yiska"]                       = { mapID = 646, x = 0.4480, y = 0.6200 },
        ["Waterspeaker Ryuli"]          = { mapID = 379, x = 0.7420, y = 0.8880, location = "Kun-Lai Summit" },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4460, y = 0.6340 },
    },

    npcDisplayIDs = {
        ["Initiate Da-Nel"]             = 45418,
        ["Fearsome Jang"]               = 41461,
        ["Iron-Body Ponshu"]            = 41568,
        ["Chen Stormstout"]             = 39698,
        ["Li Li Stormstout"]            = 44514,
        ["The Monkey King"]             = 46707,
        ["Taran Zhu"]                   = 41827,
        ["Master Hsu"]                  = 45005,
        ["Instructor Myang"]            = 42621,
        ["High Elder Cloudfall"]        = 39706,
        ["Angus Ironfist"]              = 68654,
        ["Aegira"]                      = 68959,
        ["Brewmaster Blanche"]          = 42067,
        ["Master Bu"]                   = 76007,
    },

    chapters = {
        {
            chapter = "Before the Storm",
            summary = "The Peak of Serenity falls to the Legion. Rally the surviving monks at the Temple of Five Dawns on the Wandering Isle.",
            recap = "The unthinkable happened — the Peak of Serenity, the monks' sacred mountain, fell to a Legion assault. As smoke rose from the ruins, you gathered the survivors and led them to the Temple of Five Dawns on the Wandering Isle. There, Fearsome Jang named you Grandmaster of the order, and you claimed an artifact weapon to carry into the war ahead. Iron-Body Ponshu began organizing the scattered monks into a fighting force.",
            quests = {
                { id = 12103, name = "Before the Storm",           npc = "Initiate Da-Nel" },
                { id = 40236, name = "The Dawning Light",           npc = "Fearsome Jang" },
                { id = 40636, name = "Prepare To Strike",           npc = "Iron-Body Ponshu" },
                { id = 42187, name = "Rise, Champions",             npc = "Iron-Body Ponshu" },
                { id = 41115, name = "Champion: Chen Stormstout",   npc = "Chen Stormstout" },
                { id = 40704, name = "Champion: Li Li Stormstout",  npc = "Li Li Stormstout" },
                { id = 42186, name = "Growing Power",               npc = "Iron-Body Ponshu" },
                { id = 42210, name = "Scrolls of Knowledge",        npc = "Master Hsu" },
                { id = 42191, name = "Tech It Up A Notch",          npc = "Master Hsu" },
            },
        },

        {
            chapter = "Defense of Tian Monastery",
            summary = "Tian Monastery is under siege. Fight alongside Taran Zhu and The Monkey King to drive back the Legion and rebuild the order.",
            recap = "Iron-Body Ponshu received a desperate report — Tian Monastery was under attack. You rushed to its defense alongside Taran Zhu, the grim Shado-Pan lord, and The Monkey King, whose tricks proved as deadly as any blade. Instructor Myang held the line while you slowed the Legion's spread, and together you struck down the Hand of Keletress who led the assault. High Elder Cloudfall oversaw the monastery's rebuilding, and both Taran Zhu and The Monkey King pledged themselves as your champions.",
            quests = {
                { id = 41905, name = "Report from Tian Monastery", npc = "Iron-Body Ponshu" },
                { id = 41728, name = "The Defense of Tian Monastery", npc = "Iron-Body Ponshu" },
                { id = 41729, name = "Slowing the Spread",         npc = "Instructor Myang" },
                { id = 41730, name = "Desperate Strike",            npc = "Taran Zhu" },
                { id = 41731, name = "Storm, Earth, and Fire",      npc = "Taran Zhu" },
                { id = 41732, name = "The Hand of Keletress",       npc = "The Monkey King" },
                { id = 41733, name = "Rebuilding the Order",        npc = "High Elder Cloudfall" },
                { id = 43319, name = "The Way of the Tiger",        npc = "Iron-Body Ponshu" },
                { id = 41734, name = "Champion: Taran Zhu",         npc = "Taran Zhu" },
                { id = 41735, name = "Champion: The Monkey King",   npc = "The Monkey King" },
            },
        },

        {
            chapter = "The Iron Fist",
            summary = "Rescue monks captured by the vrykul in Stormheim. Recruit Angus Ironfist, Hiro, and Sylara Steelsong as champions.",
            recap = "Word came of monks captured by the vrykul in Stormheim. Angus Ironfist, a massive Pandaren brawler, led you into the frozen north where your brothers and sisters were being held. You quelled the tide of enemies, rebuilt the shattered defenses brick by brick, and freed every last monk. Hiro — a humble fighter who became a hero that day — and Sylara Steelsong joined your growing roster of champions. No monk would be left behind.",
            quests = {
                { id = 41849, name = "The Iron Fist",               npc = "Iron-Body Ponshu" },
                { id = 41850, name = "The Master of Swords",        npc = "Angus Ironfist" },
                { id = 41851, name = "Quelling the Tide",           npc = "Angus Ironfist" },
                { id = 41852, name = "No Monk Left Behind",         npc = "Angus Ironfist" },
                { id = 41853, name = "Zero to Hiro",                npc = "Angus Ironfist" },
                { id = 41854, name = "Brick By Brick",              npc = "Angus Ironfist" },
                { id = 41736, name = "Champion: Angus Ironfist",    npc = "Angus Ironfist" },
                { id = 41738, name = "Champion: Sylara Steelsong",  npc = "Sylara Steelsong" },
                { id = 41737, name = "Champion: Hiro",              npc = "Hiro" },
            },
        },

        {
            chapter = "Storm Brew",
            summary = "Seek out Aegira, a vrykul brewmaster in the Halls of Valor, and brew the legendary Storm Brew to empower your forces.",
            recap = "Iron-Body Ponshu spoke of a legend — the Storm Brew, a drink of such power it could turn the tide of any battle. The recipe was held by Aegira, a vrykul brewmaster who had perfected her craft in the Halls of Valor over centuries. You entered Odyn's domain, earned the right to brew alongside Aegira, and retrieved the ingredients from Odyn's own cauldron. The Storm Brew was unlike anything brewed on Azeroth — and with it, your weapon was reforged to its full power. The Grandmaster's campaign was complete.",
            quests = {
                { id = 41038, name = "The Mead Master",             npc = "Iron-Body Ponshu" },
                { id = 41039, name = "Stolen Knowledge",            npc = "Aegira" },
                { id = 41040, name = "Halls of Valor: The Brewmaster", npc = "Aegira" },
                { id = 41059, name = "Halls of Valor: Odyn's Cauldron", npc = "Aegira" },
                { id = 41087, name = "Storm Brew",                  npc = "Iron-Body Ponshu" },
                { id = 41739, name = "Champion: Aegira",            npc = "Aegira" },
            },
        },

        {
            chapter = "Ban-Lu, Grandmaster's Companion",
            summary = "On the Broken Shore, brew a cure for a fallen brewmaster, then follow the trail of Ban-Lu — a legendary celestial tiger.",
            recap = "Brewmaster Blanche fell to a Legion poison on the Broken Shore, her spirit lingering to guide you. You brewed a cure from fel ingredients, saved who you could, and secured the Shore for the monks. Then came word of Ban-Lu — a celestial tiger who had served every Grandmaster since the order's founding. Master Bu led you across Pandaria following the tiger's trail through history: his shadow in the Jade Forest, his river in the Valley, his trial at the peak. When Ban-Lu finally appeared, he spoke — and declared you worthy. The Grandmaster had found a companion.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45440, name = "A Brewing Situation",          npc = "Brewmaster Blanche" },
                { id = 45404, name = "Panic at the Brewery",        npc = "Brewer Almai" },
                { id = 45574, name = "Fel Ingredients",              npc = "Brewer Almai" },
                { id = 45545, name = "Barrel Toss",                  npc = "Brewer Almai" },
                { id = 45449, name = "Alchemist Korlya",            npc = "Brewer Almai" },
                { id = 46320, name = "Hope For a Cure",             npc = "Brewer Almai" },
                { id = 46353, name = "Master Who?",                  npc = "Yiska" },
                { id = 46341, name = "The Tale of Ban-Lu",           npc = "Master Bu" },
                { id = 46350, name = "The Trial of Ban-Lu",          npc = "Waterspeaker Ryuli" },
            },
        },

        {
            chapter = "Fu Zan, the Wanderer's Companion",
            summary = "Seek Fu Zan, a legendary staff carried by monks across the ages, now lost in the wilds.",
            recap = "Iron-Body Ponshu told you of Fu Zan — a simple-looking staff that had been passed from wanderer to wanderer since the dawn of the monk tradition. It looked like a walking stick, but those who carried it found that no enemy could stand against them. You tracked it through remote monasteries and dangerous wilds, and when you took it up, it felt like an old friend settling into your hand.",
            quests = {
                { id = 42762, name = "The Wanderer's Companion",    npc = "Iron-Body Ponshu" },
            },
        },
        {
            chapter = "Sheilun, Staff of the Mists",
            summary = "Recover Sheilun, the staff of Emperor Shaohao, who shrouded Pandaria in mist for ten thousand years.",
            recap = "Iron-Body Ponshu revealed that Sheilun — the staff of Emperor Shaohao himself — had been hidden since the emperor used it to shroud Pandaria in mist ten thousand years ago. You followed the trail of ancient magic to its resting place, where Shaohao's mists still swirled protectively around the staff. When you claimed Sheilun, the mists parted willingly — as if the emperor had been waiting for someone to carry his burden.",
            quests = {
                { id = 41003, name = "The Emperor's Gift",          npc = "Iron-Body Ponshu" },
            },
        },
        {
            chapter = "Fists of the Heavens",
            summary = "Claim the Fists of the Heavens, a pair of enchanted handwraps charged with the fury of storms.",
            recap = "In the wake of the Peak of Serenity's fall, you prepared to strike back. The Fists of the Heavens — enchanted handwraps that crackled with storm energy — were said to channel the very fury of the skies. You fought through the Legion's forces to claim them, and with each punch, thunder rolled across the battlefield.",
            quests = {
                { id = 40636, name = "Prepare To Strike",           npc = "Iron-Body Ponshu" },
            },
        },
    },
}
