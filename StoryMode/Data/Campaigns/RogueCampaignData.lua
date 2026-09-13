local addonName, SM = ...

-- =============================================================================
-- Legion Rogue Campaign: The Uncrowned
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.RogueCampaignData = {
    title = "Shadowblade's Campaign",
    achievementName = "The Shadowblade's Campaign",
    achievements = { 42279, 10746, 10994, 11171, 11223, 42295 },
    description = "A secret order of rogues operates from the shadows beneath Dalaran. The Uncrowned do not rule kingdoms, but they know where every kingdom keeps its secrets.\n\nAs the order's newest blade in the dark, gather legendary tools, follow a conspiracy through trusted halls, and learn who can still be trusted when everyone is trained to lie.",
    zone = "Dalaran / Broken Isles",
    expansion = "Legion",
    class = "ROGUE",
    color = { 0.25, 0.55, 0.65 },  -- Rogue shadow teal
    adventureGuideInstanceName = "Court of Stars",

    startQuest = { id = 40832, name = "Call of The Uncrowned", npc = "Ravenholdt Courier", location = "Dalaran" },
    startMapID = 626,
    startX = 0.4680,
    startY = 0.2880,

    npcLocations = {
        ["Ravenholdt Courier"]          = { mapID = 626, x = 0.4680, y = 0.2880 },
        ["Lord Jorach Ravenholdt"]      = { mapID = 626, x = 0.4220, y = 0.7700, location = "Dalaran / Broken Isles" },
        ["Garona Halforcen"]            = { mapID = 626, x = 0.3680, y = 0.5260, location = "Dalaran / Broken Isles" },
        ["Valeera Sanguinar"]           = { mapID = 626, x = 0.4220, y = 0.7700, location = "Dalaran / Broken Isles" },
        ["Fleet Admiral Tethys"]        = { mapID = 646, x = 0.5760, y = 0.6340, location = "Broken Shore" },
        ["Crackers"]                    = { mapID = 646, x = 0.5760, y = 0.6340, location = "Broken Shore" },
        ["Marin Noggenfogger"]          = { mapID = 626, x = 0.3080, y = 0.6940, location = "Dalaran / Broken Isles" },
        ["Nikki the Gossip"]            = { mapID = 626, x = 0.3740, y = 0.4420, location = "Dalaran / Broken Isles" },
        ["Vanessa VanCleef"]            = { mapID = 626, x = 0.4240, y = 0.6960, location = "Dalaran / Broken Isles" },
        ["Taoshi"]                      = { mapID = 626, x = 0.4220, y = 0.7700, location = "Dalaran / Broken Isles" },
        ["Princess Tess Greymane"]      = { mapID = 626, x = 0.4220, y = 0.7700, location = "Dalaran / Broken Isles" },
        ["Master Mathias Shaw"]         = { mapID = 626, x = 0.4220, y = 0.7700, location = "Dalaran / Broken Isles" },
        ["Apothecary Keever"]           = { mapID = 646, x = 0.4500, y = 0.6410 },
        ["Lilian Voss"]                 = { mapID = 646, x = 0.5760, y = 0.6340, location = "Broken Shore" },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4450, y = 0.6250 },
        ["Val'zuun"]                    = { mapID = 626, x = 0.6600, y = 0.6800 },
        ["Archmage Khadgar"]            = { mapID = 626, x = 0.6920, y = 0.4340 },
    },

    -- NPC creature display IDs for chapter portraits
    -- Used with SetPortraitTextureFromCreatureDisplayID()
    -- Look up on wowhead.com model viewer or /run print(UnitCreatureDisplayID("target"))
    npcDisplayIDs = {
        ["Ravenholdt Courier"]          = 67448,
        ["Lord Jorach Ravenholdt"]      = 69542,
        ["Garona Halforcen"]            = 69541,
        ["Valeera Sanguinar"]           = 26365,
        ["Fleet Admiral Tethys"]        = 67215,
        ["Marin Noggenfogger"]          = 67712,
        ["Nikki the Gossip"]            = 65623,
        ["Vanessa VanCleef"]            = 67671,
        ["Taoshi"]                      = 41792,
        ["Princess Tess Greymane"]      = 53598,
        ["Master Mathias Shaw"]         = 83274,
        ["Apothecary Keever"]           = 4111,
        ["Lilian Voss"]                 = 67721,
        ["Maiev Shadowsong"]            = 77009,
        ["Val'zuun"]                    = 69095,
    },

    -- =========================================================================
    -- Main campaign chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Introduction
        {
            chapter = "Call of The Uncrowned",
            summary = "A mysterious courier delivers an urgent summons to the sewers beneath Dalaran, where a secret order of assassins watches from the shadows.",
            recap = "A cryptic summons led you into the sewers beneath Dalaran, where Lord Jorach Ravenholdt revealed The Uncrowned — a secret order of assassins operating outside the law. You proved your worth in the shadows and claimed a blade befitting the order's newest operative.",
            quests = {
                { id = 40832, name = "Call of The Uncrowned",       npc = "Ravenholdt Courier" },
                { id = 40839, name = "The Final Shadow",            npc = "Lord Jorach Ravenholdt" },
                { id = 40840, name = "A Worthy Blade",              npc = "Lord Jorach Ravenholdt" },
            },
        },

        -- CHAPTER 2: Establishing the Order Hall
        {
            chapter = "Establishing The Uncrowned",
            summary = "Build the order hall's strength by recruiting legendary rogues as champions and establishing operations throughout the Broken Isles.",
            recap = "You built The Uncrowned from a whisper into a force, recruiting legendary rogues like Vanessa VanCleef and Garona Halforcen as champions. From the Chamber of Shadows beneath Dalaran, you established a network of operatives across the Broken Isles and ensured the order's school of roguery could train the next generation of shadows.",
            quests = {
                { id = 40950, name = "Honoring Success",            npc = "Lord Jorach Ravenholdt" },
                { id = 40996, name = "Delegation",                  npc = "Lord Jorach Ravenholdt" },
                { id = 40997, name = "Lethal Efficiency",           npc = "Nikki the Gossip" },
                { id = 43007, name = "Return to the Chamber of Shadows", npc = "Valeera Sanguinar" },
                { id = 42139, name = "Rise, Champions",             npc = "Lord Jorach Ravenholdt" },
                { id = 43261, name = "Champion: Vanessa VanCleef",  npc = "Vanessa VanCleef" },
                { id = 43262, name = "Champion: Garona Halforcen",  npc = "Garona Halforcen" },
                { id = 42140, name = "A More Wretched Hive of Scum and Villainy", npc = "Nikki the Gossip" },
                { id = 43013, name = "The School of Roguery",       npc = "Nikki the Gossip" },
                { id = 43014, name = "The Big Bad Wolfe",           npc = "Nikki the Gossip" },
                { id = 43015, name = "What Winstone Suggests",      npc = "Nikki the Gossip" },
            },
        },

        -- CHAPTER 3: The SI:7 Investigation
        {
            chapter = "Saga of the Shadowblade",
            summary = "Bodies are turning up across the Broken Isles, and the trail leads to a chilling conspiracy deep within SI:7 itself.",
            recap = "Bodies started appearing across the Broken Isles — agents killed with surgical precision. The trail led you through a web of betrayal reaching into SI:7 itself. Working with Fleet Admiral Tethys and Marin Noggenfogger, you gathered evidence and allies while throwing SI:7 off your scent, uncovering a conspiracy far deeper than anyone suspected.",
            quests = {
                { id = 43958, name = "A Body of Evidence",          npc = "Lord Jorach Ravenholdt" },
                { id = 43829, name = "Spy vs. Spy",                 npc = "Lord Jorach Ravenholdt" },
                { id = 44041, name = "The Bloody Truth",            npc = "Lord Jorach Ravenholdt" },
                { id = 44116, name = "Mystery at Citrine Bay",      npc = "Lord Jorach Ravenholdt" },
                { id = 44155, name = "Searching For Clues",         npc = "Fleet Admiral Tethys" },
                { id = 44117, name = "Time Flies When Yer Havin' Rum!", npc = "Fleet Admiral Tethys" },
                { id = 44177, name = "Dark Secrets and Shady Deals", npc = "Fleet Admiral Tethys" },
                { id = 44183, name = "Champion: Lord Jorach Ravenholdt", npc = "Lord Jorach Ravenholdt" },
                { id = 43841, name = "Convincin' Old Yancey",       npc = "Fleet Admiral Tethys" },
                { id = 43852, name = "Fancy Lads and Buccaneers",   npc = "Fleet Admiral Tethys" },
                { id = 44181, name = "Champion: Fleet Admiral Tethys", npc = "Fleet Admiral Tethys" },
                { id = 42684, name = "Throwing SI:7 Off the Trail", npc = "Valeera Sanguinar" },
                { id = 43468, name = "Blood for the Wolfe",         npc = "Valeera Sanguinar" },
                { id = 42730, name = "Noggenfogger's Reasonable Request", npc = "Valeera Sanguinar" },
                { id = 44178, name = "A Particularly Potent Potion", npc = "Marin Noggenfogger" },
                { id = 44180, name = "Champion: Marin Noggenfogger", npc = "Marin Noggenfogger" },
            },
        },

        -- CHAPTER 4: The Raven's Eye
        {
            chapter = "The Raven's Eye",
            summary = "An ancient vrykul artifact holds the key to unmasking the enemy. The search leads through the haunted halls of Black Rook Hold.",
            recap = "Valeera Sanguinar led you on a hunt for the Raven's Eye, an ancient vrykul artifact capable of piercing any disguise. Your search took you through the Maw of Souls and into the haunted depths of Black Rook Hold, where you retrieved the artifact and deciphered a letter that revealed the true scope of the enemy's infiltration.",
            quests = {
                { id = 43253, name = "Maw of Souls: Ancient Vrykul Legends", npc = "Valeera Sanguinar" },
                { id = 43249, name = "The Raven's Eye",             npc = "Valeera Sanguinar" },
                { id = 43250, name = "Off to Court",                npc = "Valeera Sanguinar" },
                { id = 43251, name = "In Search of the Eye",        npc = "Valeera Sanguinar" },
                { id = 43252, name = "Eternal Unrest",              npc = "Valeera Sanguinar" },
                { id = 42678, name = "Black Rook Hold: Into Black Rook Hold", npc = "Valeera Sanguinar" },
                { id = 42680, name = "Deciphering the Letter",      npc = "Valeera Sanguinar" },
                { id = 42800, name = "Champion: Valeera Sanguinar", npc = "Valeera Sanguinar" },
            },
        },

        -- CHAPTER 5: Rescuing Mathias Shaw
        {
            chapter = "The Captive Spymaster",
            summary = "Mathias Shaw, spymaster of SI:7, has gone missing. A daring rescue mission takes you deep behind enemy lines.",
            recap = "Mathias Shaw, spymaster of SI:7, had been captured and replaced by a dreadlord impostor. You infiltrated the enemy stronghold alongside Taoshi, cutting through guards and wards to reach Shaw's cell. The rescue was harrowing — but when the real Shaw stood free and the impostor was exposed, the conspiracy's days were numbered.",
            quests = {
                { id = 43469, name = "Where In the World is Mathias?", npc = "Taoshi" },
                { id = 43470, name = "Pruning the Garden",          npc = "Taoshi" },
                { id = 43479, name = "The World is Not Enough",     npc = "Taoshi" },
                { id = 43485, name = "A Burning Distraction",       npc = "Taoshi" },
                { id = 43508, name = "The Captive Spymaster",       npc = "Taoshi" },
                { id = 37666, name = "Picking a Fight",             npc = "Taoshi" },
                { id = 37448, name = "A Simple Plan",               npc = "Master Mathias Shaw" },
                { id = 37494, name = "Under Cover of Darkness",     npc = "Taoshi" },
                { id = 37689, name = "The Imposter",                npc = "Master Mathias Shaw" },
                { id = 43723, name = "Champion: Taoshi",            npc = "Taoshi" },
                { id = 43724, name = "Champion: Master Mathias Shaw", npc = "Master Mathias Shaw" },
            },
        },

        -- CHAPTER 6: Broken Shore & Class Mount
        {
            chapter = "Hiding In Plain Sight",
            gated = true,
            note = "Complete Armies of Legionfall on the Broken Shore, then return to the Hall of Shadows to begin the final class mount chapter.",
            summary = "The dreadlord has been hiding among your allies all along. The hunt ends on the Broken Shore in a final confrontation.",
            recap = "The final hunt led to the Broken Shore, where a dreadlord had been hiding among your allies in plain sight. With Lilian Voss at your side, you set the trap — false orders, planted evidence, and a trail that led the demon straight into your blade. The Uncrowned had done what armies could not: killed a devil wearing a friend's face.",
            prerequisites = {
                { id = 46730, name = "Armies of Legionfall", npc = "Archmage Khadgar" },
            },
            quests = {
                { id = 46322, name = "The Pirate's Bay",            npc = "Lord Jorach Ravenholdt" },
                { id = 46323, name = "What's the Cache?",           npc = "Lilian Voss" },
                { id = 46324, name = "False Orders",                npc = "Lilian Voss" },
                { id = 45073, name = "Loot and Plunder!",           npc = "Fleet Admiral Tethys" },
                { id = 45848, name = "Fit For a Pirate",            npc = "Crackers" },
                { id = 46326, name = "Jorach's Calling",            npc = "Lilian Voss" },
                { id = 45571, name = "A Bit of Espionage",          npc = "Lord Jorach Ravenholdt" },
                { id = 45576, name = "Rise Up",                     npc = "Lord Jorach Ravenholdt" },
                { id = 45629, name = "This Time, Leave a Trail",    npc = "Lilian Voss" },
                { id = 46827, name = "Meld Into the Shadows",       npc = "Lord Jorach Ravenholdt" },
                { id = 46103, name = "Dread Infiltrators",          npc = "Apothecary Keever" },
                { id = 46089, name = "Hiding In Plain Sight",       npc = "Lilian Voss" },
            },
        },

        -- CHAPTER 7-9: Artifact Weapons (can be done in any order, anytime)
        {
            chapter = "The Kingslayers",
            summary = "Track down the legendary assassination daggers once wielded by Garona Halforcen, hidden away after the fall of a king.",
            recap = "Princess Tess Greymane guided you through a web of coded messages and hidden vaults to recover the Kingslayers — Garona's legendary daggers, stained with the blood of a king. You infiltrated a Stormwind prison, broke codes, and retrieved the blades from their resting place, returning them to the hands of an assassin who knew their weight better than anyone.",
            quests = {
                { id = 42501, name = "Finishing the Job",           npc = "Princess Tess Greymane" },
                { id = 42502, name = "No Sanctuary",                npc = "Princess Tess Greymane" },
                { id = 42503, name = "Codebreaker",                 npc = "Princess Tess Greymane" },
                { id = 42539, name = "Cloak and Dagger",            npc = "Princess Tess Greymane" },
                { id = 42568, name = "Preparation",                 npc = "Garona Halforcen" },
                { id = 42504, name = "The Unseen Blade",            npc = "Garona Halforcen" },
            },
        },
        {
            chapter = "Fangs of the Devourer",
            summary = "Delve into a demonic vault to claim a pair of shadow-forged blades that hunger for souls.",
            recap = "Valeera Sanguinar tracked a pair of shadow-forged blades to a demonic vault hidden between worlds. You fought through the Twisting Nether itself, confronting the demon Val'zuun who guarded the Fangs of the Devourer. The blades pulsed with hunger as you claimed them — weapons that devoured souls and grew stronger with every kill.",
            quests = {
                { id = 41919, name = "The Shadows Reveal",          npc = "Valeera Sanguinar" },
                { id = 41920, name = "A Matter of Finesse",         npc = "Valeera Sanguinar" },
                { id = 41921, name = "Closing In",                  npc = "Valeera Sanguinar" },
                { id = 41922, name = "Traitor!",                    npc = "Valeera Sanguinar" },
                { id = 41924, name = "Fangs of the Devourer",       npc = "Val'zuun" },
            },
        },
        {
            chapter = "The Dreadblades",
            summary = "A pirate legend speaks of cursed cutlasses buried with their last captain. Fleet Admiral Tethys knows the way.",
            recap = "Fleet Admiral Tethys told the tale of the Dreadblades — cursed cutlasses that brought ruin to every captain who wielded them. You sailed to the burial site and pried them from the skeletal grip of their last owner, accepting the curse along with the power. The sea itself seemed to shudder as you brought them aboard.",
            quests = {
                { id = 40847, name = "A Friendly Accord",           npc = "Fleet Admiral Tethys" },
                { id = 40849, name = "The Dreadblades",             npc = "Fleet Admiral Tethys" },
            },
        },
    },
}
