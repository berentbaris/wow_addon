local addonName, SM = ...

-- =============================================================================
-- Legion Mage Campaign: The Tirisgarde
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.MageCampaignData = {
    title = "Archmage's Campaign",
    achievementName = "The Archmage's Campaign",
    achievements = { 42274, 10746, 10994, 11171, 11223 },
    description = "Beneath Dalaran lies the Hall of the Guardian, seat of the ancient Tirisgarde: mages sworn to protect Azeroth from magical threats that ordinary armies cannot understand.\n\nAs the order's newest Archmage, investigate hidden enemies, recover lost allies, and defend the Kirin Tor from dangers that wear familiar faces.",
    zone = "Hall of the Guardian / Broken Isles",
    expansion = "Legion",
    class = "MAGE",
    color = { 0.25, 0.78, 0.92 },  -- Mage light blue
    adventureGuideInstanceName = "Violet Hold",

    startQuest = { id = 41035, name = "Felstorm's Plea", npc = "Meryl Felstorm", location = "Dalaran" },
    startMapID = 627,
    startX = 0.4540,
    startY = 0.4730,

    npcLocations = {
        ["Archmage Ansirem Runeweaver"] = { mapID = 7502, x = 0.2880, y = 0.4920, location = "Dalaran" },
        ["Image of Kalec"] = { mapID = 7637, x = 0.3500, y = 0.8780, location = "Suramar" },
        ["Kalecgos"] = { mapID = 7637, x = 0.2920, y = 0.8760, location = "Suramar" },
        ["Meryl Felstorm"]              = { mapID = 734, x = 0.5200, y = 0.5100 },
        ["Millhouse Manastorm"]         = { mapID = 734, x = 0.5210, y = 0.5110 },
        ["The Great Akazamzarak"]       = { mapID = 627, x = 0.5320, y = 0.5580 },
        ["Archmage Kalec"]              = { mapID = 734, x = 0.5640, y = 0.3860 },
        ["Archmage Modera"]             = { mapID = 734, x = 0.5540, y = 0.4020 },
        ["Archmage Melis"]              = { mapID = 734, x = 0.8040, y = 0.6280 },
        ["Archmage Omniara"]            = { mapID = 734, x = 0.5100, y = 0.5300 },
        ["Ravandwyr"]                   = { mapID = 627, x = 0.6100, y = 0.5920 },
        ["Esara Verrinde"]              = { mapID = 627, x = 0.7320, y = 0.5880 },
        ["Archmage Khadgar"]            = { mapID = 627, x = 0.7140, y = 0.5600 },
        ["Archmage Vargoth"]            = { mapID = 734, x = 0.8240, y = 0.5500 },
        ["Aethas Sunreaver"]            = { mapID = 734, x = 0.2700, y = 0.5180 },
        ["Invoker Threadgold"]          = { mapID = 646, x = 0.4520, y = 0.6180 },
        ["Arcanist Ryanna"]             = { mapID = 646, x = 0.5580, y = 0.4200 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4450, y = 0.6250 },
    },

    npcDisplayIDs = {
        ["Meryl Felstorm"]              = 67760,
        ["The Great Akazamzarak"]       = 68004,
        ["Archmage Kalec"]              = 38491,
        ["Archmage Modera"]             = 63776,
        ["Archmage Melis"]              = 70585,
        ["Archmage Omniara"]            = 71053,
        ["Ravandwyr"]                   = 69642,
        ["Esara Verrinde"]              = 69626,
        ["Archmage Khadgar"]            = 65834,
        ["Archmage Vargoth"]            = 62303,
        ["Aethas Sunreaver"]            = 26770,
        ["Maiev Shadowsong"]            = 77009,
    },

    -- =========================================================================
    -- Main campaign chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Introduction
        {
            chapter = "The Tirisgarde Reborn",
            summary = "Meryl Felstorm, an ancient mage, pleads for help against a dreadlord. Together you reforge the Tirisgarde in the Hall of the Guardian.",
            recap = "Meryl Felstorm appeared with an urgent plea — Kathra'natir, a cunning dreadlord, had broken free of his prison and threatened all of Dalaran. You fought the demon back and descended into the Hall of the Guardian, an ancient sanctum beneath the city. There, Meryl revealed the Tirisgarde — an order of mage-hunters founded centuries ago. With a weapon of legend in hand and The Great Akazamzarak's theatrical assistance, you reforged the order and took your place as its champion.",
            quests = {
                { id = 41035, name = "Felstorm's Plea",            npc = "Meryl Felstorm" },
                { id = 41036, name = "The Dreadlord's Prize",       npc = "Meryl Felstorm" },
                { id = 41085, name = "A Mage's Weapon",             npc = "Meryl Felstorm" },
                { id = 41114, name = "The Champion's Return",       npc = "Meryl Felstorm" },
                { id = 41112, name = "The Great Akazamzarak",       npc = "Meryl Felstorm" },
                { id = 41113, name = "The Only Way to Travel",      npc = "The Great Akazamzarak" },
                { id = 41124, name = "The Tirisgarde Reborn",       npc = "Meryl Felstorm" },
                { id = 41141, name = "A Conjuror's Duty",           npc = "The Great Akazamzarak" },
            },
        },

        -- CHAPTER 2: Establishing the Order Hall
        {
            chapter = "Rise, Champions",
            summary = "Recruit Archmage Kalec and Archmage Modera as champions. Build the Tirisgarde's forces and establish operations.",
            recap = "The Tirisgarde needed power, and power came in the form of legends. Archmage Kalec — the blue dragon who once guarded the Sunwell — and Archmage Modera of the Council of Six both pledged their strength. Archmage Omniara trained troops while Archmage Melis provided the technical wizardry to keep the Hall of the Guardian running. The Tirisgarde was no longer a relic of history — it was a force.",
            quests = {
                { id = 42175, name = "Growing Power",              npc = "Meryl Felstorm" },
                { id = 42663, name = "Rise, Champions",             npc = "Meryl Felstorm" },
                { id = 42662, name = "Champion: Archmage Kalec",    npc = "Archmage Kalec" },
                { id = 42685, name = "Champion: Archmage Modera",   npc = "Archmage Modera" },
                { id = 42703, name = "Technical Wizardry",          npc = "Meryl Felstorm" },
                { id = 42126, name = "Archmage Omniara",            npc = "Archmage Melis" },
                { id = 42127, name = "Building Our Troops",         npc = "Archmage Melis" },
                { id = 42687, name = "Troops in the Field",         npc = "Archmage Melis" },
                { id = 42433, name = "Ancient Magic",               npc = "Archmage Vargoth" },
            },
        },

        -- CHAPTER 3: The Empyrean Society
        {
            chapter = "The Empyrean Society",
            summary = "A secret society of rogue mages is hoarding dangerous knowledge. Infiltrate their ranks with Ravandwyr and Esara Verrinde.",
            recap = "An unexpected visitor brought troubling news — a secret society called the Empyrean Society was gathering forbidden knowledge across the Broken Isles. Ravandwyr, apprentice to the missing Archmage Vargoth, led you on a covert infiltration of their ranks. With Esara Verrinde's help, you discovered the Society had been experimenting with powers far beyond their control. You shut them down from the inside, but the trail left behind raised a darker question — where was Archmage Vargoth?",
            quests = {
                { id = 42418, name = "An Unexpected Visitor",       npc = "Archmage Melis" },
                { id = 42434, name = "A Covert Operation",          npc = "Ravandwyr" },
                { id = 42435, name = "Prepare To Be Assimilated",   npc = "Ravandwyr" },
                { id = 42166, name = "What Is Going On Here?",      npc = "Ravandwyr" },
                { id = 42149, name = "Some Knowledge Shouldn't Be Shared", npc = "Esara Verrinde" },
                { id = 42206, name = "The Next Level Has Arrived",  npc = "Esara Verrinde" },
                { id = 42171, name = "Final Exit",                  npc = "Esara Verrinde" },
                { id = 42222, name = "Empyrean Society Report",     npc = "Ravandwyr" },
                { id = 42706, name = "Champion: Esara Verrinde",    npc = "Esara Verrinde" },
                { id = 42705, name = "Champion: Ravandwyr",         npc = "Ravandwyr" },
            },
        },

        -- CHAPTER 4: The Search for Vargoth
        {
            chapter = "The Search for Vargoth",
            summary = "Archmage Vargoth has vanished. Khadgar leads the search through his retreat, but a darker threat lurks behind his disappearance.",
            recap = "The Council convened to address Archmage Vargoth's disappearance. Khadgar led you to Vargoth's retreat, where the signs of struggle told a grim story. Following in his footsteps, you traced magical residue across the Broken Isles. Kalec's investigation revealed the truth was worse than anyone feared — Vargoth hadn't simply vanished. Something had taken him, and that something was connected to the dreadlord Kathra'natir.",
            quests = {
                { id = 42416, name = "The Council is in Session",   npc = "Archmage Khadgar" },
                { id = 42423, name = "Archmage Vargoth's Retreat",  npc = "Archmage Ansirem Runeweaver" },
                { id = 42424, name = "Following In His Footsteps",  npc = "Archmage Kalec" },
                { id = 42451, name = "Kalec's Plan",                npc = "Archmage Melis" },
                { id = 42508, name = "Not A Toothless Dragon",      npc = "Kalecgos" },
                { id = 42521, name = "The Enemy of My Enemy...",    npc = "Kalecgos" },
                { id = 42493, name = "Impending Dooooooom!",        npc = "Image of Kalec" },
                { id = 42520, name = "A Terrible Loss",             npc = "Image of Kalec" },
                { id = 42702, name = "Champion: Millhouse Manastorm", npc = "Millhouse Manastorm" },
            },
        },

        -- CHAPTER 5: Into the Oculus
        {
            chapter = "Into the Oculus",
            summary = "Kathra'natir has possessed Meryl Felstorm. Storm the Oculus with Khadgar to save the Tirisgarde's founder and destroy the dreadlord.",
            recap = "The dreadlord Kathra'natir had been one step ahead all along — and his final move was possessing Meryl Felstorm himself. With the Tirisgarde's founder corrupted from within, Khadgar rallied every resource: a magical affliction cured in the Eye of Azshara, the might of the Tirisgarde focused into a single strike. You stormed the Oculus and faced Kathra'natir in Meryl's body, tearing the demon free without destroying the mage. Meryl stood free, Vargoth was rescued, and your weapon was reforged. The Kirin Tor bestowed upon you the title of Archmage.",
            quests = {
                { id = 42707, name = "Eye of Azshara: A Magical Affliction", npc = "Archmage Khadgar" },
                { id = 44689, name = "The Might of the Tirisgarde", npc = "Archmage Khadgar" },
                { id = 42940, name = "When There's a Will, There's a Way", npc = "Archmage Khadgar" },
                { id = 42734, name = "Into the Oculus",             npc = "Archmage Khadgar" },
                { id = 42914, name = "Champion: Meryl Felstorm",    npc = "Meryl Felstorm" },
                { id = 43441, name = "A Second Weapon",             npc = "Meryl Felstorm" },
                { id = 42917, name = "Champion: Archmage Vargoth",  npc = "Archmage Vargoth" },
            },
        },

        -- CHAPTER 6: Broken Shore & Class Mount
        {
            chapter = "Return of the Archmage",
            summary = "The war moves to the Broken Shore. Aethas Sunreaver leads the Tirisgarde's assault, and you earn the Archmage's Prismatic Disc.",
            recap = "The Broken Shore demanded the Tirisgarde's full power. Aethas Sunreaver, once exiled from Dalaran, returned to lead the mage offensive. You uncovered a nightborne workshop hidden on the Shore, secured its secrets, and armed Dalaran's defenses against a Legion counterattack. When the dust settled, Khadgar entrusted you with one final task — recovering the legendary Discs of Norgannon. From their power, the Archmage's Prismatic Disc was forged — a flying platform that shifted between arcane, fire, and frost as you willed it.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45437, name = "An Urgent Situation",         npc = "Meryl Felstorm" },
                { id = 44766, name = "Backup Plan",                 npc = "Aethas Sunreaver" },
                { id = 46335, name = "The Vault of the Tirisgarde", npc = "Archmage Kalec" },
                { id = 45207, name = "The Nightborne Apprentice",   npc = "Aethas Sunreaver" },
                { id = 46705, name = "Retaliation",                 npc = "Arcanist Ryanna" },
                { id = 45614, name = "Lady Remor'za",               npc = "Aethas Sunreaver" },
                { id = 46000, name = "Arming Dalaran",              npc = "Aethas Sunreaver" },
                { id = 46290, name = "Return of the Archmage",      npc = "Aethas Sunreaver" },
                { id = 46043, name = "Champion: Aethas Sunreaver",  npc = "Aethas Sunreaver" },
                { id = 45844, name = "Avocation of Antonidas",      npc = "Invoker Threadgold" },
                { id = 45845, name = "Burning Within",              npc = "Archmage Kalec" },
                { id = 45354, name = "Dispersion of the Discs",     npc = "Archmage Kalec" },
            },
        },

        -- CHAPTER 7-9: Artifact Weapons
        {
            chapter = "Aluneth, Greatstaff of the Magna",
            summary = "Seek the staff of the Guardian Aegwynn — Aluneth, a weapon of pure arcane power that has a mind of its own.",
            recap = "Meryl Felstorm pointed you toward Aluneth — the Greatstaff of the Magna, once wielded by Aegwynn, Guardian of Tirisfal. The staff had been sealed away for good reason: it was sentient, willful, and dangerously powerful. You found it in an arcane vault crackling with unbound energy, and when you grasped it, Aluneth's voice echoed in your mind — condescending, impatient, and undeniably brilliant. You had a weapon. It had opinions.",
            quests = {
                { id = 42001, name = "Aluneth, Greatstaff of the Magna", npc = "Meryl Felstorm" },
            },
        },
        {
            chapter = "Felo'melorn",
            summary = "Recover Felo'melorn, the Flamestrike — the ancient blade of the Sunstrider dynasty, lost in the frozen halls of Icecrown.",
            recap = "An unexpected message revealed the location of Felo'melorn — the legendary sword of the Sunstrider dynasty, lost when Kael'thas fell. You traced it to the frozen depths of Icecrown, where it had lain since Arthas shattered it in single combat. You reforged the blade in phoenix fire and carried it from the ice, its flames burning hotter than ever — as if centuries of cold had only made it angrier.",
            quests = {
                { id = 40267, name = "An Unexpected Message",       npc = "Meryl Felstorm" },
            },
        },
        {
            chapter = "Ebonchill",
            summary = "Find Ebonchill, the staff of Alodi — the first Guardian of Tirisfal — frozen in time within a pocket dimension.",
            recap = "Meryl spoke of Ebonchill — the staff of Alodi, the very first Guardian of Tirisfal, sealed within a pocket dimension of frozen time. You breached the dimensional barrier and entered a world where time stood still, ice crystals hanging motionless in the air. At its heart, Ebonchill waited — cold, patient, and ancient beyond measure. When you took it, the pocket dimension shattered, and the staff's frost spread through your veins like a promise.",
            quests = {
                { id = 42452, name = "Finding Ebonchill",           npc = "Meryl Felstorm" },
            },
        },
    },
}
