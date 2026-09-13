local addonName, SM = ...

-- =============================================================================
-- Battle for Azeroth: Nazmir — The Dark Heart of Nazmir
-- Zone Storyline: "The Dark Heart of Nazmir" (Achievement 11868)
-- =============================================================================

SM.NazmirData = {
    title = "The Dark Heart of Nazmir",
    achievementName = "Bwon Voyage",
    achievements = {
        11868,  -- The Dark Heart of Nazmir (zone story)
        "Explore Nazmir",
        -- The Underrot (dungeon)
        12500,  -- Underrot
        -- Uldir
        12523,  -- Heart of Corruption (Mythrax, G'huun)
        12818,  -- G'huun kills (Normal Uldir)
        -- Battle of Dazar'alor
        13289,  -- Defense of Dazar'alor (Horde — Opulence, Conclave of the Chosen, King Rastakhan)
        13290,  -- Death's Bargain (Alliance perspective wing 3)
    },
    description = "Nazmir is a dying land: ancient, cursed, and crawling with blood trolls whose rituals stain the swamp red. Stranded among loa whose temples have fallen and whose followers have turned to darker powers, you will need help from gods who rarely give anything freely.\n\nForge uneasy bargains, follow the trail through fetid ruins and broken pacts, and learn why the oldest powers in Zandalar still fear what waits beneath the mud.",
    zone = "Nazmir",
    expansion = "Battle for Azeroth",
    faction = "Horde",
    color = { 0.30, 0.65, 0.45 },  -- Bwonsamdi swamp-teal
    icon = 2065614,                -- inv_nazmir (Bwon Voyage achievement)
    factions = { 2156, 2103 },      -- Talanji's Expedition, Zandalari Empire
    adventureGuideInstanceName = "The Underrot",

    startQuest = { id = 47512, name = "Nazmir", npc = "Princess Talanji", location = "Dazar'alor" },
    startMapID = 862,
    startX = 0.5560,
    startY = 0.3660,

    npcLocations = {
        ["Princess Talanji"]    = { mapID = 862, x = 0.4940, y = 0.5700 },  -- Dazar'alor
        ["Hanzabu"]             = { mapID = 863, x = 0.3660, y = 0.5380 },
        ["Witch Doctor Kejabu"] = { mapID = 863, x = 0.3960, y = 0.4380 },
        ["Rokhan"]              = { mapID = 863, x = 0.6740, y = 0.4220 },
        ["Lashk"]               = { mapID = 863, x = 0.6740, y = 0.4200 },
        ["Titan Keeper Hezrel"] = { mapID = 863, x = 0.6860, y = 0.3500 },
        ["Patch"]               = { mapID = 863, x = 0.7460, y = 0.3880 },
        ["Bwonsamdi"]           = { mapID = 863, x = 0.3940, y = 0.3020 },
        ["Krag'wa the Huge"]    = { mapID = 863, x = 0.7540, y = 0.5660 },
        ["Shadow Hunter Mutumba"] = { mapID = 863, x = 0.6740, y = 0.4180 },
        ["Ticker"]              = { mapID = 863, x = 0.7460, y = 0.3900 },
        ["Newt"]                = { mapID = 863, x = 0.8220, y = 0.2720 },
        ["Witch Doctor Zentimo"] = { mapID = 863, x = 0.6860, y = 0.4660 },
        ["Bloodseeker Jo'chunga"] = { mapID = 863, x = 0.3340, y = 0.4580 },
        ["Jo'chunga"]           = { mapID = 863, x = 0.3340, y = 0.4560 },
        ["Kisha"]               = { mapID = 863, x = 0.5560, y = 0.3940 },
    },

    npcDisplayIDs = {
        ["Princess Talanji"]    = 75898,
        ["Rokhan"]              = 116250,
        ["Hanzabu"]             = 76641,
        ["Bwonsamdi"]           = 75961,
        ["Witch Doctor Kejabu"] = 77153,
        ["Lashk"]               = 85218,
        ["Patch"]               = 30315,
        ["Krag'wa"]             = 76791,
        ["Titan Keeper Hezrel"] = 76851,
    },

    -- =========================================================================
    -- Main storyline chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Deep in the Swamp
        {
            chapter = "Deep in the Swamp",
            summary = "Nazmir is swallowed by blood and shadow. Princess Talanji leads the Horde into the swamp to find the loa and stop the blood troll advance.",
            recap = "Talanji brought you to Nazmir, the oldest and most cursed of the Zandalari lands. The swamp had been swallowed — blood trolls pressed inward from every angle, their offerings feeding something dark and hungry beneath the earth. Rokhan read the signs: to push back the blood tide, you'd need the loa. Ancient, capricious, and rarely willing to be asked. You cut through the blood troll front lines, took in the full scope of the devastation, and prepared to seek out the only powers old enough to matter in Nazmir.",
            quests = {
                { id = 47512, name = "Nazmir",                  npc = "Princess Talanji" },
                { id = 47103, name = "Journey to Nazmir",       npc = "Princess Talanji", mapID = 862, x = 0.4980, y = 0.4220, location = "Dazar'alor" },
                { id = 48535, name = "Nazmir, the Forbidden Swamp", npc = "Rokhan" },
                { id = 47262, name = "Ending the Blood Trolls", npc = "Princess Talanji" },
                { id = 47105, name = "Into The Darkness",       npc = "Princess Talanji" },
                { id = 47130, name = "Improper Burial",         npc = "Princess Talanji", mapID = 863, x = 0.4520, y = 0.7100, location = "Nazmir" },
                { id = 47264, name = "Leave None Standing",     npc = "Princess Talanji", mapID = 863, x = 0.4520, y = 0.7100, location = "Nazmir" },
                { id = 47263, name = "A Time of Revelation",   npc = "Princess Talanji" },
                { id = 47188, name = "The Aid of the Loa",     npc = "Princess Talanji" },
            },
        },

        -- CHAPTER 2: A Pact With Death
        {
            chapter = "A Pact With Death",
            summary = "Hanzabu leads you to Bwonsamdi, loa of death, deep in his Necropolis. He will fight the blood trolls — for one million souls.",
            recap = "Hanzabu, servant of the death loa, led you into Bwonsamdi's Necropolis — a place where the veil between the living and the dead was thin enough to talk through. Bwonsamdi was many things: charming, unsettling, and entirely in control of any room he entered. He had watched the blood trolls desecrate his death shrines and steal souls that were owed to him. He was not pleased. The deal he offered was simple — his power in exchange for one million souls delivered to his realm. You cleansed his temple of spirits who had fled to G'huun, repelled Grand Ma'da Ateena's interruption of the sealing ritual, and sealed the pact. A deal with a death loa is not something you walk back from.",
            quests = {
                { id = 47241, name = "The Shadow of Death",     npc = "Princess Talanji" },
                { id = 47244, name = "A Culling of Souls",      npc = "Hanzabu" },
                { id = 49278, name = "Spiritual Restoration",   npc = "Hanzabu", mapID = 863, x = 0.3960, y = 0.4380, location = "A Pact With Death, Nazmir" },
                { id = 47868, name = "The Necropolis",          npc = "Hanzabu" },
                { id = 47880, name = "A Tribute for Death",     npc = "Hanzabu" },
                { id = 47247, name = "That Which Haunts the Dead", npc = "Bwonsamdi", mapID = 863, x = 0.3660, y = 0.5380, location = "A Pact With Death, Nazmir" },
                { id = 47491, name = "Remnants of the Damned",  npc = "Bwonsamdi", mapID = 863, x = 0.3660, y = 0.5380, location = "A Pact With Death, Nazmir" },
                { id = 49348, name = "A Desecrated Temple",     npc = "Bwonsamdi", mapID = 863, x = 0.3660, y = 0.5380, location = "A Pact With Death, Nazmir" },
                { id = 49432, name = "The Forlorn Soul",        npc = "Keula", mapID = 863, x = 0.3660, y = 0.5380, location = "A Pact With Death, Nazmir" },
                { id = 47249, name = "Soulbound",               npc = "Bwonsamdi", mapID = 863, x = 0.3660, y = 0.5380, location = "A Pact With Death, Nazmir" },
                { id = 47250, name = "We'll Meet Again",        npc = "Bwonsamdi" },
            },
        },

        -- CHAPTER 3: Undercover Sista
        {
            chapter = "Undercover Sista",
            summary = "Infiltrate Zalamar disguised as a blood troll. The bat loa Hir'eek has been corrupted — you must end the corruption and the loa with it.",
            recap = "Witch Doctor Kejabu had a plan that required a certain willingness to look like the enemy. Disguised as blood trolls, you slipped into Zalamar, one of the blood cult's most fortified settlements. Inside you found something worse than blood trolls: Hir'eek, the bat loa, had turned. Corrupted by G'huun's influence, the loa now fed on his own people, demanding sacrifice. A corrupted loa was more dangerous than no loa at all. You poisoned the blood troll's brood, stripped away their rituals, and faced Hir'eek at the heart of his lair. The bat loa fell. It was not a victory to celebrate.",
            quests = {
                { id = 49440, name = "Blood Troll on the Outside", npc = "Witch Doctor Kejabu" },
                { id = 48699, name = "Sneaking into Zalamar",   npc = "Witch Doctor Kejabu" },
                { id = 48890, name = "How to Be a Blood Troll", npc = "Bloodseeker Jo'chunga" },
                { id = 48801, name = "Isolating Zalamar",       npc = "Bloodseeker Jo'chunga" },
                { id = 49078, name = "Poisoning the Brood",     npc = "Bloodseeker Jo'chunga" },
                { id = 48800, name = "Mark of the Bat",         npc = "Bloodseeker Jo'chunga" },
                { id = 49079, name = "Hir'eek, the Bat Loa",   npc = "Jo'chunga" },
                { id = 49081, name = "To Kill a Loa",           npc = "Jo'chunga", mapID = 863, x = 0.3120, y = 0.4680, location = "Nazmir" },
                { id = 49082, name = "Upward and Onward",       npc = "Jo'chunga", mapID = 863, x = 0.3120, y = 0.4680, location = "Nazmir" },
            },
        },

        -- CHAPTER 4: Turtle Power
        {
            chapter = "Turtle Power",
            summary = "Torga, ancient sea turtle loa of Nazmir, is dying. The blood trolls have bled him for decades. You arrive too late to save him — but not too late to release him.",
            recap = "Lashk brought you to Torga, and what you found broke something in the air around you. The sea turtle loa — ancient beyond reckoning, the kind of creature that outlasted empires — had been slowly bled by the blood trolls for years. He was almost gone when you arrived. You fought through the blood trolls claiming his shores, sought Bwonsamdi's intercession for a dying loa, and freed the souls trapped around him. Torga died. He just did it on his own terms, with the Horde at his side. Bwonsamdi, for once, was almost respectful. Lashk said nothing. Some losses don't require words.",
            quests = {
                { id = 49185, name = "Catching Up",             npc = "Princess Talanji" },
                { id = 49064, name = "Torga, the Turtle Loa",  npc = "Lashk" },
                { id = 49067, name = "Beseeching Bwonsamdi",   npc = "Princess Talanji", mapID = 863, x = 0.5840, y = 0.1380, location = "Nazmir" },
                { id = 49070, name = "Souls for the Death Loa", npc = "Bwonsamdi", mapID = 863, x = 0.3660, y = 0.5380, location = "Turtle Power, Nazmir" },
                { id = 49071, name = "Dreadtick Combustion",   npc = "Lashk" },
                { id = 49080, name = "Cease all Summoning",    npc = "Princess Talanji", mapID = 863, x = 0.5840, y = 0.1380, location = "Nazmir" },
                { id = 49120, name = "Speaking with the Dead", npc = "Bwonsamdi", mapID = 863, x = 0.3660, y = 0.5380, location = "Turtle Power, Nazmir" },
                { id = 49125, name = "Negative Blood",         npc = "Kisha" },
                { id = 49126, name = "Forcing Fate's Hand",    npc = "Kisha" },
                { id = 49130, name = "Loa-Free Diet",          npc = "Kisha" },
                { id = 49131, name = "Sanctifying Ground",     npc = "Princess Talanji", mapID = 863, x = 0.5840, y = 0.1380, location = "Nazmir" },
                { id = 49132, name = "Crushing the Skullcrushers", npc = "Lashk" },
                { id = 49136, name = "Jungo, Herald of G'huun", npc = "Princess Talanji", mapID = 863, x = 0.5840, y = 0.1380, location = "Nazmir" },
                { id = 49160, name = "Torga's Eternal Return", npc = "Lashk" },
            },
        },

        -- CHAPTER 5: Bring the Boom
        {
            chapter = "Bring the Boom",
            summary = "A goblin named Patch and a crew of demolitions experts blast a way through the blood troll defenses.",
            recap = "Subtlety had its limits in Nazmir. Patch — a goblin with strong opinions about explosives and personal safety — had a solution for the blood troll barricades that was loud, expensive, and effective. You wrangled his scattered crew, gathered everything they needed, and let them do what goblins do best. The blood troll fortifications that had blocked the advance for weeks turned to rubble in an afternoon. Talanji watched the smoke rise with something close to satisfaction. The path deeper into Nazmir was open.",
            quests = {
                { id = 47245, name = "Getting the Message",     npc = "Rokhan" },
                { id = 47631, name = "Rendezvous with the Libation", npc = "Rokhan" },
                { id = 47597, name = "No Goblin Left Behind",   npc = "Patch" },
                { id = 47599, name = "Revenge: Served Hot",     npc = "Ticker" },
                { id = 47596, name = "There Is No Plan \"B\"",  npc = "Ticker", mapID = 863, x = 0.8220, y = 0.2720, location = "Nazmir" },
                { id = 47711, name = "Head of the Viper",       npc = "Patch" },
                { id = 47598, name = "Pilfering and Fencing",   npc = "Newt" },
                { id = 47601, name = "Field Evaluation",        npc = "Patch" },
                { id = 47602, name = "Ready For Action",        npc = "Patch", mapID = 863, x = 0.8140, y = 0.2600, location = "Nazmir" },
            },
        },

        -- CHAPTER 6: A Friend of the Frogs
        {
            chapter = "A Friend of the Frogs",
            summary = "In Gloom Hollow, the great frog loa Krag'wa hungers — and he is willing to fight if you can earn his trust. Become a friend of the frogs.",
            recap = "Rokhan led you into Gloom Hollow, where the ancient frog loa Krag'wa brooded in the dark. The blood trolls had massacred his followers and desecrated his totems, and Krag'wa was in no mood for diplomacy. You hunted the hunters who had slaughtered his priests, restored his shrines, and prepared the kind of feast that only a frog loa the size of a temple could appreciate. Krag'wa was pleased. He was also terrifying. The agreement was simple enough: he would fight with the Horde against the blood trolls and G'huun. In Gloom Hollow, that counted as a warm welcome.",
            quests = {
                { id = 49902, name = "To Gloom Hollow",         npc = "Kisha" },
                { id = 47525, name = "Staying Hidden",          npc = "Shadow Hunter Mutumba" },
                { id = 47659, name = "Hunt the Hunter",         npc = "Witch Doctor Zentimo" },
                { id = 47660, name = "Fallen Idols",            npc = "Witch Doctor Zentimo" },
                { id = 52294, name = "Fallen Idols",            npc = "Krag'wa the Huge", optional = true },
                { id = 47623, name = "The Last Witch Doctor of Krag'wa", npc = "Krag'wa the Huge" },
                { id = 47621, name = "A True Loa Feast",        npc = "Krag'wa the Huge" },
                { id = 47622, name = "A Magical Glow",          npc = "Krag'wa the Huge" },
                { id = 47540, name = "Totemic Restoration",     npc = "Krag'wa the Huge" },
                { id = 47696, name = "Krag'wa the Terrible",   npc = "Krag'wa the Huge" },
            },
        },

        -- CHAPTER 7: Everything Contained
        {
            chapter = "Everything Contained",
            summary = "A damaged Titan Keeper has been protecting the swamp's darkest secret — a proto-god of blood and shadow sealed beneath the earth.",
            recap = "Titan Keeper Hezrel had been running containment protocols in Nazmir longer than any troll civilization had existed. His facility was damaged, his routines degraded, and the thing he was containing was actively working to get out. G'huun — a failed titan experiment, a blood god born in a lab and deemed too dangerous to destroy — had been sealed beneath Nazmir since before the trolls arrived. You helped Hezrel repair his systems, purified the corrupted earth, cleared the undead and void creatures that had crept into the facility, and restored the containment. For now. What had already escaped, and the blood trolls' true purpose — feeding G'huun until he broke free on his own terms — was only becoming clear.",
            quests = {
                { id = 49932, name = "Slumber No More",         npc = "Lashk" },
                { id = 49935, name = "How to Repair a Titan Keeper", npc = "Titan Keeper Hezrel" },
                { id = 49937, name = "Recovering Remnants",     npc = "Titan Keeper Hezrel" },
                { id = 49938, name = "Corrupted Earth",         npc = "Titan Keeper Hezrel" },
                { id = 49941, name = "Bone Procession",         npc = "Titan Keeper Hezrel" },
                { id = 49950, name = "Blood Purification",      npc = "Titan Keeper Hezrel" },
                { id = 49949, name = "Unwelcome Undead",        npc = "Titan Keeper Hezrel" },
                { id = 49955, name = "Not Fit for This Plane",  npc = "Titan Keeper Hezrel" },
                { id = 49956, name = "Void is Prohibited",      npc = "Titan Keeper Hezrel" },
                { id = 49957, name = "Protocol Recovery",       npc = "Titan Keeper Hezrel" },
                { id = 49980, name = "Containment Procedure",   npc = "Titan Keeper Hezrel" },
                { id = 49985, name = "Return to Gloom Hollow",  npc = "Titan Keeper Hezrel" },
            },
        },

        -- CHAPTER 8: Bleeding the Blood Trolls
        {
            chapter = "Bleeding the Blood Trolls",
            summary = "The final assault on Grand Ma'da Ateena. The Horde, the loa, and a death god march together into the Blood Gate. G'huun waits beneath.",
            recap = "Patch rallied the assault force at Bloodfire Ravine. Talanji stood at the front. The loa — Krag'wa, what remained of Bwonsamdi's power, even the memory of Torga — were with you. The blood trolls had held the Blood Gate as the last barrier between Nazmir and the heart of their god's prison. You blew through their defenses, toppled their totems, and drove a path of fire through their strongest ranks. Grand Ma'da Ateena fell. In the silence after, Titan Keeper Hezrel delivered the final revelation: G'huun still breathed beneath the earth. Nazmir had been reclaimed — but the blood god's prison was cracking. The raid on Uldir was no longer optional.",
            quests = {
                { id = 49569, name = "Down by the Riverside",   npc = "Princess Talanji", mapID = 863, x = 0.6740, y = 0.4220, location = "Nazmir" },
                { id = 50076, name = "Rally the Warriors",      npc = "Princess Talanji" },
                { id = 50138, name = "The Battle of Bloodfire Ravine", npc = "Princess Talanji" },
                { id = 50078, name = "Undying Totems",          npc = "Princess Talanji" },
                { id = 50079, name = "Boom Goes the Bomb",      npc = "Patch" },
                { id = 50081, name = "The Road of Pain",        npc = "Princess Talanji" },
                { id = 50082, name = "Target of Opportunity",   npc = "Princess Talanji" },
                { id = 50085, name = "A Message of Blood and Fire", npc = "Rokhan" },
                { id = 52073, name = "Petitioning Krag'wa",    npc = "Princess Talanji", mapID = 863, x = 0.6740, y = 0.4220, location = "Bleeding the Blood Trolls, Nazmir" },
                { id = 50087, name = "Ateena's Fall",           npc = "Princess Talanji" },
                { id = 51244, name = "What Rots Beneath",         npc = "Rokhan" },
                { id = 51302, name = "The Underrot: Sealing G'huun's Corruption", npc = "Titan Keeper Hezrel" },
                { id = 50808, name = "Halting the Empire's Fall",   npc = "Rokhan" },
            },
        },

        -- CHAPTER 9: Uldir — Blood From Stone
        {
            chapter = "Uldir — Blood From Stone",
            summary = "Deep beneath the earth, a titan research facility holds the worst mistake the Pantheon ever made. G'huun has to die.",
            recap = "The titans built Uldir to study the Old Gods — to understand the corruption before they tried to cure it. What they created instead was G'huun: a proto-god of blood and shadow, born in a lab, every safeguard bypassed. Sealed in stasis for millennia, fed by the blood trolls until he was strong enough to break containment himself. Uldir was not a dungeon. It was a prison that had started to answer back.\n\nYou fought through the facility's corrupted wards — past G'huun's lieutenants, through the experiments that had gone wrong in the age before trolls had language — and reached the heart of the prison. G'huun fell. The blood god's thousand-year campaign to break free ended in the same titan vault it began in. Nazmir would take generations to recover. The trolls who had given their lives feeding G'huun would never be fully redeemed. But the earth was quiet again, and the seal held.",
            achievementID = 40960,
            quests = {},
        },

        -- CHAPTER 10: The Battle of Dazar'alor
        {
            chapter = "The Battle of Dazar'alor",
            summary = "The Alliance strikes at the heart of the Zandalari empire. King Rastakhan calls on Bwonsamdi — and pays the price.",
            recap = "The Alliance fleet came while Dazar'alor was still recovering from everything the Horde had sacrificed to protect it. Jaina Proudmoore led the assault through the sacred pyramid, floor by floor, past every guardian the Zandalari could muster. King Rastakhan, knowing the city could not hold, made a desperate bargain — calling on Bwonsamdi's power directly, burning his own life force to drive the invaders back.\n\nBwonsamdi got his king in the end. Rastakhan fell. But the death loa was there to receive him, and the deal struck in Nazmir had never promised anything more than that — the power to fight, not the guarantee of survival. Talanji watched her father die holding a city that still stood. Bwonsamdi, for his part, was exactly as somber as a loa of death ever gets. The soul of a king is not nothing.",
            quests = {
                { id = 54282, name = "Battle of Dazar'alor",  npc = "Princess Talanji", mapID = 863, x = 0.3660, y = 0.5380, location = "The Battle of Dazar'alor, Nazmir" },
            },
        },
    },
}

return SM
