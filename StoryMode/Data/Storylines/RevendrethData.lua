local addonName, SM = ...

-- =============================================================================
-- Shadowlands: Revendreth — The Master of Revendreth
-- Zone Storyline: "The Master of Revendreth" (Achievement 13878)
-- =============================================================================

SM.RevendrethData = {
    title = "The Master of Revendreth",
    achievementID = 13878,
    achievements = {
        13878,  -- The Master of Revendreth (Revendreth zone story)
        "Explore Revendreth",
        14280,  -- Loremaster of Shadowlands
        14798,  -- Sojourner of Revendreth
        -- Halls of Atonement (dungeon)
        14370,  -- Halls of Atonement
        -- Sanguine Depths (dungeon)
        14197,  -- Sanguine Depths
        -- Castle Nathria (raid)
        14715,  -- Castle Nathria
    },
    description = "Revendreth is a gothic realm of sinstones, vampire courts, and ritual penance: the place where prideful souls are meant to be broken open, judged, and remade. Sent to seek anima for the starving Shadowlands, you arrive in a kingdom that is already fraying.\n\nPrince Renathal and the Court of Harvesters are gathering resistance, Sire Denathrius still rules from above, and every misted street carries another rumor about where Revendreth's loyalty truly lies.",
    zone = "Revendreth",
    expansion = "Shadowlands",
    color = { 0.70, 0.08, 0.12 },  -- Venthyr anima red
    icon = 3528288,                -- inv_cape_special_revendreth_d_03
    factions = { 2413, 2439 },      -- Court of Harvesters, The Avowed
    portraitDisplayID = 92797,     -- Sire Denathrius
    adventureGuideInstanceName = "Castle Nathria",

    startQuest = { id = 57025, name = "A Plea to Revendreth", npc = "Tal-Inara", location = "Oribos" },
    startMapID = 1670,
    startX = 0.3950,
    startY = 0.6900,

    npcLocations = {
        ["Tal-Inara"]              = { mapID = 1670, x = 0.3950, y = 0.6900 },
        ["Lord Chamberlain"]       = { mapID = 1525, x = 0.6320, y = 0.6210 },
        ["Rendle"]                 = { mapID = 1525, x = 0.7000, y = 0.8260 },
        ["Nadjia the Mistblade"]   = { mapID = 1525, x = 0.6050, y = 0.6100 },
        ["Mistress Mihaela"]       = { mapID = 1525, x = 0.6140, y = 0.6380 },
        ["Myskia"]                 = { mapID = 1525, x = 0.5850, y = 0.5200 },
        ["Sire Denathrius"]        = { mapID = 1525, x = 0.5340, y = 0.6400 },
        ["Echelon"]                = { mapID = 1525, x = 0.6480, y = 0.5020 },
        ["The Accuser"]            = { mapID = 1525, x = 0.5140, y = 0.5980, location = "Revendreth" },
        ["The Fearstalker"]        = { mapID = 1525, x = 0.5070, y = 0.7380 },
        ["Houndmaster Loksey"]     = { mapID = 1525, x = 0.5120, y = 0.7430, location = "Revendreth" },
        ["Flockmaster Sergio"]     = { mapID = 1525, x = 0.5120, y = 0.7430, location = "Revendreth" },
        ["Watchmaster Boromod"]    = { mapID = 1525, x = 0.5140, y = 0.5980, location = "Revendreth" },
        ["Stonehead"]              = { mapID = 1525, x = 0.3900, y = 0.6600 },
        ["Theotar"]                = { mapID = 1525, x = 0.3750, y = 0.6420 },
        ["Tubbins"]                = { mapID = 1525, x = 0.3100, y = 0.5760 },
        ["Prince Renathal"]        = { mapID = 1525, x = 0.3460, y = 0.1860 },
        ["General Draven"]         = { mapID = 1525, x = 0.4320, y = 0.7400, location = "Revendreth" },
        ["Remornia"]               = { mapID = 1525, x = 0.2600, y = 0.4360, location = "Revendreth" },
        ["Breakfist"] = { mapID = 1525, x = 0.3040, y = 0.4560, location = "Revendreth" },
        ["General Kaal"] = { mapID = 1525, x = 0.6040, y = 0.6080, location = "Revendreth" },
        ["Lost Sybille"] = { mapID = 1525, x = 0.3700, y = 0.6320, location = "Revendreth" },
        ["Projection of Prince Renathal"] = { mapID = 1525, x = 0.3200, y = 0.4140, location = "Revendreth" },
        ["Vorpalia"] = { mapID = 1699, x = 0.3240, y = 0.3960, location = "Sinfall" },
    },

    npcDisplayIDs = {
        ["Tal-Inara"]              = 98194,
        ["Lord Chamberlain"]       = 92394,
        ["Rendle"]                 = 92398,
        ["Nadjia the Mistblade"]   = 93210,
        ["Myskia"]                 = 95709,
        ["Sire Denathrius"]        = 92797,
        ["Echelon"]                = 95059,
        ["The Accuser"]            = 93103,
        ["The Fearstalker"]        = 93114,
        ["Stonehead"]              = 93218,
        ["Theotar"]                = 93223,
        ["Tubbins"]                = 93305,
        ["Prince Renathal"]        = 93575,
        ["General Draven"]         = 92399,
    },

    chapterDisplayIDs = {
        ["Welcome to Revendreth"]  = 92398,  -- Rendle
        ["The Master"]             = 92797,  -- Sire Denathrius
        ["The Accuser"]            = 93103,  -- The Accuser
        ["The Penitent Hunt"]      = 93114,  -- The Fearstalker
        ["The Mad Duke"]           = 93223,  -- Theotar
        ["Prince Renathal"]        = 93575,  -- Prince Renathal
        ["The Master of Lies"]     = 92797,  -- Sire Denathrius
        ["Castle Nathria's Aftermath"] = 92399, -- General Draven
    },

    -- =========================================================================
    -- Main storyline chapters (The Master of Revendreth achievement)
    -- =========================================================================
    chapters = {
        {
            chapter = "Welcome to Revendreth",
            gated = true,
            note = "Be careful with the Threads of Fate choice from Fatescribe Roh-Tahl in Oribos. Choosing Threads of Fate skips the Shadowlands leveling campaign and marks Revendreth's main story quests complete, so use the replay storyline option if you want to play this chapter.",
            summary = "The Winter Queen needs anima, and Revendreth is supposed to be the realm that knows how to harvest it. Your request begins in Darkhaven, where every sin has a stone.",
            recap = "Tal-Inara sent you toward Revendreth with a plea for aid: Ardenweald was starving, the Heart of the Forest was weakening, and Sire Denathrius was said to be a master of anima. Revendreth greeted you with teeth behind every smile. Rendle introduced the rules of the realm — sinstones, punishment, service, and the long work of repentance. Lord Chamberlain offered polished courtesy while rebels struck at the roads and Darkhaven buckled under the anima drought. The place looked like a vampire court and spoke like a church of atonement, but something in its foundations was already cracking.",
            quests = {
                { id = 57025, name = "A Plea to Revendreth",       npc = "Tal-Inara" },
                { id = 57026, name = "The Sinstone",               npc = "Rendle" },
                { id = 57007, name = "Invitation of the Master",   npc = "Lord Chamberlain" },
                { id = 56829, name = "Bottom Feeders",             npc = "Rendle" },
                { id = 57381, name = "The Greatest Duelist",       npc = "Nadjia the Mistblade" },
                { id = 56942, name = "On The Road Again",          npc = "Rendle" },
                { id = 56955, name = "Rebels on the Road",         npc = "Lord Chamberlain" },
                { id = 58433, name = "Anima Attrition",            npc = "Lord Chamberlain" },
                { id = 56978, name = "To Darkhaven",               npc = "Lord Chamberlain" },
            },
        },

        {
            chapter = "The Master",
            summary = "Lord Chamberlain escorts you toward Castle Nathria. Sire Denathrius receives your plea with perfect elegance — and asks you to help restore order first.",
            recap = "Darkhaven's crisis brought you into the shadow of Castle Nathria. Lord Chamberlain showed you the Stoneborn, Revendreth's gargoyle guardians, and carried your request to the Harvesters. Then you met Sire Denathrius: ancient, immaculate, and utterly certain of his own necessity. He promised aid, but only after you helped him discipline the rebellion tearing through his realm. His authority filled the court like perfume and poison. Revendreth's nobles bowed. The Stoneborn obeyed. And for the moment, you were expected to do the same.",
            quests = {
                { id = 57174, name = "The Stoneborn",              npc = "Lord Chamberlain" },
                { id = 58654, name = "A Plea to the Harvesters",   npc = "Mistress Mihaela" },
                { id = 57178, name = "The Master Awaits",          npc = "General Kaal" },
                { id = 57179, name = "The Authority of Revendreth", npc = "Sire Denathrius" },
            },
        },

        {
            chapter = "The Accuser",
            summary = "Denathrius sends you after the Accuser, a rebel Harvester whose sinstone may prove she is no righteous dissenter.",
            recap = "Sire Denathrius pointed you at the Accuser, one of the Harvesters standing against him. Lord Chamberlain's hunt was brutal and theatrical: tear through her followers, read the sinstones of her inquisitors, and use those names to drag the guilty into judgment. But the deeper you went, the less clean the story became. The Accuser had punished pride for ages, and she understood what Denathrius's court had become. When her own secret was revealed, it was not simple innocence that saved her — it was the terrible truth that Revendreth's ruler had turned repentance into control.",
            quests = {
                { id = 57161, name = "I Don't Get My Hands Dirty", npc = "Lord Chamberlain" },
                { id = 57173, name = "The Accuser's Sinstone",     npc = "Echelon" },
                { id = 58931, name = "Inquisitor Stelia's Sinstone", npc = "Lord Chamberlain" },
                { id = 58932, name = "Temel, the Sin Herald",      npc = "Echelon" },
                { id = 59021, name = "Herald Their Demise",        npc = "Echelon" },
                { id = 57175, name = "Inquisitor Vilhelm's Sinstone", npc = "Echelon" },
                { id = 59023, name = "Ending the Inquisitor",      npc = "Echelon" },
                { id = 57176, name = "Sinstone Delivery",          npc = "Echelon" },
                { id = 57180, name = "The Accuser's Secret",       npc = "Lord Chamberlain" },
                { id = 57182, name = "The Accuser's Fate",         npc = "Lord Chamberlain" },
                { id = 59232, name = "A Lesson in Humility",       npc = "Sire Denathrius" },
            },
        },

        {
            chapter = "The Penitent Hunt",
            summary = "In the Forest Ward, the Venthyr teach humility by giving souls hope and then hunting them down. The Accuser helps you see the cruelty beneath the lesson.",
            recap = "The Forest Ward revealed Revendreth at its most predatory. The Fearstalker and his hounds called it penance: let condemned souls glimpse escape, then chase them until pride broke under terror. You learned the ritual, stalked the quarry, and watched the Accuser's doubts harden into rebellion. The hunt was supposed to humble sinners, but it had become sport for nobles who fed on fear. By the time you reached Dredhollow and broke the Hopebreakers, the shape of the war was clear. This was not order against chaos. It was cruelty against the last pieces of Revendreth still trying to remember mercy.",
            quests = {
                { id = 57098, name = "The Grove of Terror",        npc = "Sire Denathrius" },
                { id = 58916, name = "Dread Priming",              npc = "The Fearstalker" },
                { id = 58941, name = "Alpha Bat",                  npc = "Flockmaster Sergio" },
                { id = 59014, name = "King of the Hill",           npc = "Flockmaster Sergio" },
                { id = 57131, name = "Let the Hunt Begin",         npc = "The Fearstalker" },
                { id = 57136, name = "The Penitent Hunt",          npc = "The Fearstalker" },
                { id = 57164, name = "Devour This",                npc = "The Fearstalker" },
                { id = 60506, name = "The Accuser",                npc = "The Accuser" },
                { id = 57159, name = "A Reflection of Truth",      npc = "The Accuser" },
                { id = 60313, name = "Dredhollow",                 npc = "The Accuser" },
                { id = 57189, name = "Breaking the Hopebreakers",  npc = "The Accuser" },
                { id = 57190, name = "They Won't Know What Hit Them", npc = "The Accuser" },
                { id = 59209, name = "Rebel Reinforcements",       npc = "General Draven" },
                { id = 59256, name = "The Fearstalker",            npc = "The Accuser" },
            },
        },

        {
            chapter = "The Mad Duke",
            summary = "Theotar, the Mad Duke, may know where Prince Renathal is. His ruined tea party leads through the Light-scarred Ember Ward and back to Sinfall.",
            recap = "The Accuser sent you to find Prince Renathal, and the trail led to Theotar, the Mad Duke. He was scattered, brilliant, and broken in a way that made perfect sense in Revendreth. His morning was a catastrophe of lost servants, forged warrants, forbidden research, and tea. Beneath the absurdity was the Ember Ward, a district burned by the Light so fiercely that even Venthyr feared its glow. You crossed that desiccated ruin, pieced together Theotar's memories, and secured Sinfall as a rebel refuge. Revendreth's comedy had teeth, but it also had a heart: the rebellion finally had a home.",
            quests = {
                { id = 57240, name = "Where is Prince Renathal?",  npc = "The Accuser" },
                { id = 57380, name = "Sign Your Own Death Warrant", npc = "Stonehead" },
                { id = 57405, name = "Chasing Madness",            npc = "Lost Sybille" },
                { id = 57426, name = "My Terrible Morning",        npc = "Theotar" },
                { id = 57428, name = "Theotar's Mission",          npc = "Theotar" },
                { id = 57427, name = "Unbearable Light",           npc = "Theotar" },
                { id = 57442, name = "Lost in the Desiccation",    npc = "Theotar" },
                { id = 57460, name = "Tubbins's Tea",              npc = "Tubbins" },
                { id = 57461, name = "An Uneventful Stroll",       npc = "Theotar" },
                { id = 60566, name = "Into the Light",             npc = "Theotar" },
                { id = 57724, name = "Securing Sinfall",           npc = "Breakfist" },
            },
        },

        {
            chapter = "Prince Renathal",
            summary = "With Sinfall secured, the rebellion moves to rescue Prince Renathal from the ruins of his failed uprising.",
            recap = "Sinfall gave the rebels a foothold, but they still needed their prince. In the ruins of his first rebellion, you found what Denathrius had left behind: cages, broken allies, and Renathal himself, imprisoned as an example. With Theotar, the Accuser, and General Draven at your side, you tore open the prison, stole the key, and pulled Renathal back from Torghast's shadow. The prince returned humbled but unbroken. He had lost a rebellion once. This time, he would not stand alone.",
            quests = {
                { id = 59327, name = "In the Ruin of Rebellion",  npc = "Theotar" },
                { id = 57689, name = "Prince Renathal",            npc = "Vorpalia" },
                { id = 57690, name = "Cages For All Occasions",    npc = "Prince Renathal" },
                { id = 57691, name = "A Royal Key",                npc = "Prince Renathal" },
                { id = 57693, name = "Torghast, Tower of the Damned", npc = "Prince Renathal" },
                { id = 57694, name = "Refuge of Revendreth",       npc = "Prince Renathal" },
            },
        },

        {
            chapter = "The Master of Lies",
            summary = "Renathal's rebellion marches on Castle Nathria. Denathrius reveals the truth: Revendreth's stolen anima is being sent into the Maw.",
            recap = "Renathal gathered the Harvesters and turned Sinfall's mirrors against Castle Nathria. Light cut across the ramparts, loyalists scattered, and the rebellion surged toward Denathrius. Then the Master stopped pretending. He had not failed to save the Shadowlands from the anima drought — he had helped cause it, hoarding the realm's lifeblood and pouring it into the Maw for the Jailer. Revendreth's gothic theater became something far larger and worse: the first clear proof that the machinery of Death itself had been betrayed. Denathrius retreated into Castle Nathria, and the fight for the Shadowlands changed forever.",
            quests = {
                { id = 59644, name = "Blinded By The Light",       npc = "Prince Renathal" },
                { id = 58086, name = "The Master of Lies",         npc = "Projection of Prince Renathal" },
            },
        },

        {
            chapter = "Castle Nathria's Aftermath",
            summary = "Denathrius's defeat leaves Revendreth with prisoners, old debts, and one last question: what does redemption mean for the realm's own master?",
            recap = "Castle Nathria fell, but Revendreth was not finished with its former ruler. In the Sanguine Depths, General Draven found Z'rali, the naaru whose Light had wounded the realm and whose mercy might yet help contain its sins. Then Remornia, Denathrius's living blade, became the prison that would hold him. The rebellion did not simply execute its master. It chose the harsher, stranger work Revendreth was built for: to bind arrogance, preserve what could still be redeemed, and let time do what vengeance could not.",
            quests = {
                { id = 60502, name = "Sanguine Depths: An Ally Within", npc = "General Draven", optional = true },
                { id = 60501, name = "Redemption for the Redeemer", npc = "Remornia", location = "General Draven at Sinfall", mapID = 1525, x = 0.2600, y = 0.4360 },
                { id = 63645, name = "The Dawnkeep Prisoner", npc = "Prince Renathal", optional = true, hideIf = 60501 },
            },
        },
    },
}
