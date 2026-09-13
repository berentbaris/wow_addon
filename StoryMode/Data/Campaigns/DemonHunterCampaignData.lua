local addonName, SM = ...

-- =============================================================================
-- Legion Demon Hunter Campaign: The Illidari
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.DemonHunterCampaignData = {
    title = "Slayer's Campaign",
    achievementName = "The Slayer's Campaign",
    achievements = { 42271, 10746, 10994, 11171, 11223 },
    description = "From the Fel Hammer on Mardum, the Illidari wage war against the Burning Legion with the very weapons of the enemy. Their methods are feared, their purpose is absolute, and their enemies know them well.\n\nAs the chosen Slayer, unite the demon hunters, reclaim old ground, and carry the fight into places where fel fire has ruled for ages.",
    zone = "The Fel Hammer / Broken Isles",
    expansion = "Legion",
    class = "DEMONHUNTER",
    color = { 0.64, 0.19, 0.79 },  -- Demon Hunter purple
    adventureGuideInstanceName = "Black Temple",

    startQuest = { id = 39261, name = "Call of the Illidari", npc = "Kor'vas Bloodthorn", location = "Dalaran" },
    startMapID = 627,
    startX = 0.7200,
    startY = 0.4900,

    npcLocations = {
        ["Altruis the Sufferer"] = { mapID = 7502, x = 0.7480, y = 0.4860, location = "Dalaran" },
        ["Archmage Khadgar"] = { mapID = 7502, x = 0.2880, y = 0.4840, location = "Dalaran" },
        ["Archmage Lan'dalock"] = { mapID = 7502, x = 0.2880, y = 0.4840, location = "Dalaran" },
        ["Emmarel Shadewarden"] = { mapID = 7502, x = 0.4740, y = 0.4860, location = "Dalaran" },
        ["Kor'vas Bloodthorn"]          = { mapID = 720, x = 0.5900, y = 0.5100 },
        ["Kayn Sunfury"]                = { mapID = 720, x = 0.7460, y = 0.4860 },
        ["Jace Darkweaver"]             = { mapID = 720, x = 0.7400, y = 0.5140 },
        ["Allari the Souleater"]        = { mapID = 720, x = 0.5700, y = 0.5300 },
        ["Matron Mother Malevolence"]    = { mapID = 720, x = 0.5600, y = 0.5100 },
        ["Battlelord Gaardoun"]         = { mapID = 720, x = 0.5800, y = 0.4900 },
        ["Belath Dawnblade"]            = { mapID = 720, x = 0.6100, y = 0.5200 },
        ["Malace Shade"]                = { mapID = 634, x = 0.6480, y = 0.5900 },
        ["Lady S'theno"]                = { mapID = 646, x = 0.6180, y = 0.5460 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4450, y = 0.6250 },
        ["Illidari Enforcer"]           = { mapID = 646, x = 0.4400, y = 0.6260 },
    },

    npcDisplayIDs = {
        ["Kor'vas Bloodthorn"]          = 66159,
        ["Kayn Sunfury"]                = 61698,
        ["Jace Darkweaver"]             = 60791,
        ["Allari the Souleater"]        = 60079,
        ["Matron Mother Malevolence"]    = 70953,
        ["Battlelord Gaardoun"]         = 61903,
        ["Belath Dawnblade"]            = 60090,
        ["Malace Shade"]                = 70624,
        ["Lady S'theno"]                = 60790,
        ["Maiev Shadowsong"]            = 77009,
    },

    chapters = {
        {
            chapter = "Call of the Illidari",
            summary = "Kor'vas Bloodthorn calls you to the Fel Hammer on Mardum, where the Illidari prepare for war against the Legion.",
            recap = "Kor'vas Bloodthorn found you in Dalaran with an urgent message — the Illidari needed a leader. You answered the call and claimed a weapon forged from the demons' own power. On Mardum, the Fel Hammer became your stronghold — a Legion command ship turned against its former masters. With Kayn Sunfury at your side, you gazed through the Hunter's Gaze across the Broken Isles and directed the Illidari's wrath.",
            quests = {
                { id = 39261, name = "Call of the Illidari",        npc = "Kor'vas Bloodthorn" },
                { id = 40814, name = "The Power to Survive",        npc = "Kayn Sunfury" },
                { id = 42869, name = "Eternal Vigil",               npc = "Kor'vas Bloodthorn" },
                { id = 42872, name = "Securing the Way",            npc = "Jace Darkweaver" },
                { id = 41221, name = "Return to Mardum",            npc = "Matron Mother Malevolence" },
                { id = 41037, name = "Unbridled Power",             npc = "Kayn Sunfury" },
                { id = 41062, name = "Spoils of Victory",           npc = "Kayn Sunfury" },
                { id = 41066, name = "The Hunter's Gaze",           npc = "Allari the Souleater" },
                { id = 41067, name = "Time is of the Essence",      npc = "Allari the Souleater" },
                { id = 41069, name = "Direct Our Wrath",            npc = "Kayn Sunfury" },
            },
        },

        {
            chapter = "Rise, Champions",
            summary = "Build the Illidari's strength on the Fel Hammer. Recruit champions, train troops, and prove yourself leader of the demon hunters.",
            recap = "The Fel Hammer needed to become more than a ship — it needed to become an army. Battlelord Gaardoun helped recruit champions while Kor'vas organized the broken warriors scattered across the Broken Isles. You proved your immortal soul was strong enough to lead, and the Illidari acknowledged you as their commander. The demon hunters were no longer scattered outcasts — they were a blade pointed at the Legion's heart.",
            quests = {
                { id = 42671, name = "Rise, Champions",             npc = "Battlelord Gaardoun" },
                { id = 42677, name = "Things Gaardoun Needs",       npc = "Kor'vas Bloodthorn" },
                { id = 42679, name = "Broken Warriors",             npc = "Kor'vas Bloodthorn" },
                { id = 42681, name = "Loramus, Is That You?",       npc = "Kor'vas Bloodthorn" },
                { id = 42683, name = "Demonic Improvements",        npc = "Kor'vas Bloodthorn" },
                { id = 42682, name = "Additional Accoutrements",    npc = "Matron Mother Malevolence" },
                { id = 37447, name = "The Blood of Demons",         npc = "Kor'vas Bloodthorn" },
                { id = 42510, name = "Immortal Soul",               npc = "Kayn Sunfury" },
                { id = 42522, name = "Leader of the Illidari",      npc = "Kayn Sunfury" },
            },
        },

        {
            chapter = "Back in Black",
            summary = "Return to the Black Temple to confront echoes of the past and secure reinforcements from Illidan's former stronghold.",
            recap = "The Arcane Way opened a path back to the Black Temple — Illidan's fortress, now empty and echoing with memories. Belath Dawnblade led you through its halls where the ghosts of the Illidari's past still lingered. A confrontation with the temple's remaining defenses proved that the demon hunters had grown beyond what they once were. New recruits joined from among the temple's guards, and the Fel Hammer's ranks swelled.",
            quests = {
                { id = 42593, name = "The Arcane Way",              npc = "Matron Mother Malevolence" },
                { id = 42594, name = "Move Like No Other",          npc = "Archmage Lan'dalock" },
                { id = 42801, name = "Back in Black",               npc = "Belath Dawnblade" },
                { id = 42921, name = "Confrontation at the Black Temple", npc = "Matron Mother Malevolence" },
                { id = 42665, name = "Into Our Ranks",              npc = "Kayn Sunfury" },
                { id = 42131, name = "Unexpected Visitors",         npc = "Matron Mother Malevolence" },
                { id = 42802, name = "Securing Mardum",             npc = "Matron Mother Malevolence" },
            },
        },

        {
            chapter = "The Invasion of Niskara",
            summary = "Hunt a Legion commander through Stormheim, prepare the Fel Hammer for interdimensional travel, and invade the demon world Niskara.",
            recap = "Belath's intelligence pointed to a Legion commander hiding in Stormheim. Malace Shade tracked the demon through vrykul lands while you disrupted their rune networks. The trail led to Niskara — a demon world that could only be reached by jumping the Fel Hammer through a portal. You forged deadlier warglaives, fueled the ship's engines with demonic power, and launched the invasion. On Niskara, you cut through the Legion's defenses, destroyed their command structure, and earned the title of Slayer — the demon hunters' highest honor.",
            quests = {
                { id = 42787, name = "Deal With It Personally",     npc = "Belath Dawnblade" },
                { id = 42735, name = "Malace in Vrykul Land",       npc = "Belath Dawnblade" },
                { id = 42736, name = "Rune Ruination",              npc = "Malace Shade" },
                { id = 42749, name = "Strange Bedfellows",          npc = "Malace Shade" },
                { id = 42775, name = "The Crux of the Plan",        npc = "Belath Dawnblade" },
                { id = 42669, name = "Preparations for Invasion",   npc = "Allari the Souleater" },
                { id = 42732, name = "Deadlier Warglaives",         npc = "Allari the Souleater" },
                { id = 42733, name = "A Very Special Kind of Fuel", npc = "Allari the Souleater" },
                { id = 42754, name = "Jump-Capable",                npc = "Jace Darkweaver" },
                { id = 42810, name = "A Final Offer",               npc = "Jace Darkweaver" },
                { id = 42920, name = "The Invasion of Niskara",     npc = "Jace Darkweaver" },
                { id = 43186, name = "I Am the Slayer!",            npc = "Kayn Sunfury" },
                { id = 43423, name = "A Hero's Weapon",             npc = "Emmarel Shadewarden" },
            },
        },

        {
            chapter = "To Fel and Back",
            summary = "Lead the Illidari to the Broken Shore. Defend the Fel Hammer, recruit Lady S'theno, and earn the Slayer's Felbroken Shrieker.",
            recap = "The Broken Shore was crawling with demons, and Kor'vas coordinated the Illidari's assault from the Fel Hammer itself. When the Legion counterattacked, you defended the ship in a desperate battle above the battlefield. Lady S'theno, a naga exile who had fought demons for millennia, joined your cause after you restored balance to the Broken Shore's ley lines. When the war was won, a felbat — the Felbroken Shrieker — recognized you as its master, and the Slayer took to the skies.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45301, name = "Taking Charge",               npc = "Kor'vas Bloodthorn" },
                { id = 45330, name = "Scouting Party",              npc = "Kor'vas Bloodthorn" },
                { id = 45329, name = "Operation: Portals",          npc = "Kor'vas Bloodthorn" },
                { id = 45339, name = "Defense of the Fel Hammer",   npc = "Kor'vas Bloodthorn" },
                { id = 45385, name = "We Must be Prepared!",        npc = "Kor'vas Bloodthorn" },
                { id = 45764, name = "Restoring Equilibrium",       npc = "Lady S'theno" },
                { id = 45798, name = "War'zuul the Provoker",       npc = "Lady S'theno", mapID = 646, x = 0.5200, y = 0.2120, location = "Broken Shore" },
                { id = 46266, name = "Return of the Slayer",        npc = "Lady S'theno" },
                { id = 45391, name = "Champion: Lady S'theno",      npc = "Lady S'theno" },
                { id = 46333, name = "Livin' on the Ledge",         npc = "Illidari Enforcer" },
                { id = 46334, name = "To Fel and Back",             npc = "Matron Mother Malevolence" },
            },
        },

        {
            chapter = "Twinblades of the Deceiver",
            summary = "Hunt down the Twinblades of the Deceiver — warglaives forged in felfire and wielded by a champion of the Legion.",
            recap = "Kayn Sunfury arranged the hunt for the Twinblades of the Deceiver — a pair of warglaives crackling with felfire, wielded by one of the Legion's own champions. You tracked the demon through shadowed ruins and claimed the blades in combat. They burned in your hands, eager for the blood of their former masters.",
            quests = {
                { id = 41120, name = "Making Arrangements",         npc = "Altruis the Sufferer" },
                { id = 41121, name = "By Any Means",                npc = "Altruis the Sufferer" },
                { id = 41119, name = "The Hunt",                    npc = "Altruis the Sufferer" },
            },
        },
        {
            chapter = "Aldrachi Warblades",
            summary = "Seek the Aldrachi Warblades, weapons of a race that defeated a demon lord and chose death over servitude.",
            recap = "Jace Darkweaver told the story of the Aldrachi — a warrior race so fierce they defeated the demon lord Sargeras sent to enslave them. Rather than serve, they fell on their own blades. Those weapons had been lost for millennia, but Jace had found a lead. You followed it through a series of trials, establishing a connection to the blades through sheer will. The Aldrachi Warblades chose you — the first wielder since the race that forged them chose extinction over submission.",
            quests = {
                { id = 41803, name = "Asking a Favor",              npc = "Altruis the Sufferer" },
                { id = 41804, name = "Ask and You Shall Receive",   npc = "Archmage Khadgar" },
                { id = 41807, name = "Establishing a Connection",   npc = "Jace Darkweaver" },
                { id = 40249, name = "Vengeance Will Be Ours",      npc = "Kayn Sunfury" },
            },
        },
    },
}
