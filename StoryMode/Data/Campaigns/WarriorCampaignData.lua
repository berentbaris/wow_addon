local addonName, SM = ...

-- =============================================================================
-- Legion Warrior Campaign: The Valarjar
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.WarriorCampaignData = {
    title = "Battlelord's Campaign",
    achievementName = "The Battlelord's Campaign",
    achievements = { 42282, 10746, 10994, 11171, 11223 },
    description = "Chosen by Odyn himself, you ascend to Skyhold: the legendary warrior paradise above the clouds. The Valarjar measure worth in courage, scars, and the battles a champion is still willing to fight.\n\nAs Battlelord, recover ancient symbols of war, seek alliances with titan-forged powers, and lead warriors who believe glory is something earned in motion.",
    zone = "Skyhold / Broken Isles",
    expansion = "Legion",
    class = "WARRIOR",
    color = { 0.78, 0.61, 0.43 },  -- Warrior brown
    adventureGuideInstanceName = "Halls of Valor",

    startQuest = { id = 39654, name = "Odyn and the Valarjar", npc = "Danica the Reclaimer", location = "Dalaran" },
    startMapID = 627,
    startX = 0.7430,
    startY = 0.4540,

    npcLocations = {
        ["Danica the Reclaimer"]        = { mapID = 627, x = 0.5900, y = 0.2940 },
        ["Odyn"]                        = { mapID = 695, x = 0.5840, y = 0.8300 },
        ["Hymdall"]                     = { mapID = 695, x = 0.5620, y = 0.8320 },
        ["Skyseer Ghrent"]              = { mapID = 695, x = 0.5920, y = 0.1340 },
        ["Svergan Stormcloak"]          = { mapID = 634, x = 0.7080, y = 0.3820 },
        ["Jarum Skymane"]               = { mapID = 650, x = 0.5380, y = 0.8780 },
        ["Finna Bjornsdottir"]          = { mapID = 695, x = 0.6160, y = 0.3500 },
        ["Ragnvald Drakeborn"]          = { mapID = 695, x = 0.5700, y = 0.2800 },
        ["Dvalen Ironrune"]             = { mapID = 695, x = 0.5740, y = 0.7560 },
        ["Thorim"]                      = { mapID = 695, x = 0.5840, y = 0.7500 },
        ["Hodir"]                       = { mapID = 695, x = 0.5900, y = 0.7700 },
        ["Aerylia"]                     = { mapID = 695, x = 0.3460, y = 0.2880 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4450, y = 0.6250 },
        ["Valarjar Warsinger"]          = { mapID = 646, x = 0.4700, y = 0.6300 },
    },

    -- NPC creature display IDs for chapter portraits
    npcDisplayIDs = {
        ["Danica the Reclaimer"]        = 73300,
        ["Odyn"]                        = 67230,
        ["Hymdall"]                     = 67773,
        ["Skyseer Ghrent"]              = 72034,
        ["Svergan Stormcloak"]          = 67925,
        ["Jarum Skymane"]               = 69544,
        ["Finna Bjornsdottir"]          = 67923,
        ["Ragnvald Drakeborn"]          = 72036,
        ["Dvalen Ironrune"]             = 25754,
        ["Thorim"]                      = 71648,
        ["Hodir"]                       = 71647,
        ["Aerylia"]                     = 67161,
        ["Maiev Shadowsong"]            = 77009,
        ["Valarjar Warsinger"]          = 65678,
    },

    -- =========================================================================
    -- Main campaign chapters (in story order)
    -- =========================================================================
    chapters = {
        -- CHAPTER 1: Introduction & Skyhold
        {
            chapter = "Odyn and the Valarjar",
            summary = "A val'kyr claims you worthy of Odyn's attention. You ascend to Skyhold, the warrior paradise above the clouds, and take up a weapon of legend.",
            recap = "Danica the Reclaimer appeared to you in Dalaran bearing a message from Odyn himself — the All-Father had been watching, and he found you worthy. You ascended to Skyhold, the legendary warrior paradise suspended above the clouds, where Odyn named you champion of the Valarjar and bade you claim an artifact weapon fit for the battles ahead.",
            quests = {
                { id = 39654, name = "Odyn and the Valarjar",      npc = "Danica the Reclaimer" },
                { id = 40579, name = "Weapons of Legend",           npc = "Odyn" },
                { id = 39214, name = "The Eye of Odyn",             npc = "Danica the Reclaimer" },
                { id = 40585, name = "Thus Begins the War",         npc = "Skyseer Ghrent" },
            },
        },

        -- CHAPTER 2: Establishing the Order Hall
        {
            chapter = "Champions of Skyhold",
            summary = "Odyn summons the greatest warriors to serve under your command. Build your forces and prepare Skyhold for war against the Legion.",
            recap = "At Odyn's command, you rallied the finest warriors the world had to offer. Finna Bjornsdottir and Ragnvald Drakeborn pledged their blades to your cause. Under Skyseer Ghrent's guidance, you recruited troops, dispatched them to the Broken Isles, and established Skyhold as a true war machine — Einar the Runecaster fortifying your forces with ancient vrykul magic.",
            quests = {
                { id = 42597, name = "Odyn's Summons",             npc = "Danica the Reclaimer" },
                { id = 42598, name = "Champions of Skyhold",        npc = "Odyn" },
                { id = 42606, name = "Champion: Finna Bjornsdottir", npc = "Finna Bjornsdottir" },
                { id = 42605, name = "Champion: Ragnvald Drakeborn", npc = "Ragnvald Drakeborn" },
                { id = 42607, name = "Captain Stahlstrom",          npc = "Skyseer Ghrent" },
                { id = 42609, name = "Recruiting the Troops",       npc = "Skyseer Ghrent" },
                { id = 42610, name = "Troops in the Field",         npc = "Skyseer Ghrent" },
                { id = 42611, name = "Einar the Runecaster",        npc = "Skyseer Ghrent" },
            },
        },

        -- CHAPTER 3: The Gjallarhorn
        {
            chapter = "The Gjallarhorn",
            summary = "The Gjallarhorn — the horn that calls the worthy to battle — has been stolen. Hunt down the thieves across Stormheim and reclaim it.",
            recap = "Odyn called you to battle, but the Gjallarhorn — the sacred horn that summons the Valarjar to war — had been stolen. Hymdall sent you into Stormheim where you found Svergan Stormcloak, a vrykul king whose honor had been stripped by the thieves. Together you broke his chains, recovered the horn, and tracked a massive worm to the summit of Highmountain. With Svergan's oath sworn and the beast Jorhuttam slain, the Valarjar stood ready for war once more.",
            quests = {
                { id = 43750, name = "The Call of Battle",          npc = "Skyseer Ghrent" },
                { id = 42193, name = "The Gjallarhorn",             npc = "Hymdall" },
                { id = 42194, name = "Stolen Honor",                npc = "Svergan Stormcloak" },
                { id = 42650, name = "Break the Bonds",             npc = "Svergan Stormcloak" },
                { id = 42651, name = "Svergan's Promise",           npc = "Svergan Stormcloak" },
                { id = 42614, name = "Champion: Svergan Stormcloak", npc = "Svergan Stormcloak" },
                { id = 42107, name = "On the Trail of the Great Worm", npc = "Hymdall" },
                { id = 42110, name = "To the Summit!",              npc = "Hymdall" },
                { id = 42202, name = "Revenge, Served Cold",        npc = "Jarum Skymane" },
                { id = 42204, name = "Jorhuttam",                   npc = "Jarum Skymane" },
                { id = 43585, name = "Preparing For War",           npc = "Odyn" },
                { id = 43975, name = "Recruiting Shieldmaidens",    npc = "Skyseer Ghrent" },
            },
        },

        -- CHAPTER 4: Ulduar's Oath
        {
            chapter = "Ulduar's Oath",
            summary = "Odyn reaches out to old allies in Ulduar and sends you to deliver a message to Helya in the Maw of Souls. Titan keepers join the fight.",
            recap = "Odyn sent you into the Maw of Souls with a defiant message for Helya — the Valarjar would not be broken. In the ancient halls of Ulduar, you rallied the titan keepers to the cause. Dvalen Ironrune, steadfast guardian of the forge, and Thorim, Odyn's own son, pledged themselves to the Valarjar. You retrieved Ymiron's broken blade from the Maw as proof that even the mightiest of Helya's champions could fall.",
            quests = {
                { id = 43586, name = "Maw of Souls: Message to Helya", npc = "Odyn" },
                { id = 43090, name = "Ulduar's Oath",               npc = "Odyn" },
                { id = 43604, name = "Maw of Souls: Ymiron's Broken Blade", npc = "Odyn" },
                { id = 42616, name = "Champion: Dvalen Ironrune",   npc = "Dvalen Ironrune" },
                { id = 42618, name = "Champion: Thorim",            npc = "Thorim" },
            },
        },

        -- CHAPTER 5: Will of the Valarjar
        {
            chapter = "A Hero's Weapon",
            summary = "The final test. Decipher demonic runes, rescue Hodir from a Legion prison world, and prove yourself worthy of the Battlelord title.",
            recap = "The final campaign began with demonic runes appearing across the Broken Isles — the Legion was closing in. You deciphered their meaning in Black Rook Hold, captured a Legion gateway, and stormed Niskara to rescue Hodir, imprisoned by demons since the war began. With every titan keeper free and every rune decoded, Odyn forged your weapon anew and declared you Battlelord of the Valarjar — a title not bestowed in ten thousand years.",
            quests = {
                { id = 44667, name = "Will of the Valarjar",        npc = "Odyn" },
                { id = 42918, name = "Demonic Runes",               npc = "Odyn" },
                { id = 43506, name = "Black Rook Hold: Greater Power", npc = "Odyn" },
                { id = 43577, name = "Capturing the Gateway",       npc = "Odyn" },
                { id = 42974, name = "The Fate of Hodir",           npc = "Odyn" },
                { id = 42619, name = "Champion: Hodir",             npc = "Hodir" },
                { id = 43425, name = "A Hero's Weapon",             npc = "Odyn" },
            },
        },

        -- CHAPTER 6: Broken Shore & Class Mount
        {
            chapter = "Return of the Battlelord",
            summary = "The war moves to the Broken Shore. Rally the Valarjar for a final push, brave the depths of Helheim, and earn your war wyrm.",
            recap = "The Broken Shore burned with felfire, and Odyn sent you to lead the Valarjar into the heart of the assault. You recruited new forces, armed them for the battles ahead, and ventured into Helheim itself to recover stolen souls and claim Helya's own horn as a trophy. When Kvaldir raiders answered your call and the last of the missing champions returned, Odyn summoned you for one final trial — the Trial of Rage. You emerged victorious, and a bloodthirsty war wyrm knelt before its new master.",
            quests = {
                { id = 46173, name = "Tactical Planning",           npc = "Odyn" },
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 44849, name = "Recruitment Drive",            npc = "Odyn" },
                { id = 44850, name = "Arming the Army",             npc = "Aerylia" },
                { id = 45834, name = "Stolen Souls",                npc = "Aerylia" },
                { id = 45118, name = "Helya's Horn",                npc = "Aerylia" },
                { id = 45128, name = "A Glorious Reunion",          npc = "Aerylia" },
                { id = 44889, name = "Resource Management",         npc = "Odyn" },
                { id = 45634, name = "Kvaldir on Call",             npc = "Danica the Reclaimer" },
                { id = 46267, name = "Return of the Battlelord",    npc = "Danica the Reclaimer" },
                { id = 46208, name = "A Godly Invitation",          npc = "Valarjar Warsinger" },
                { id = 46207, name = "The Trial of Rage",           npc = "Odyn" },
            },
        },

        -- CHAPTER 7-9: Artifact Weapons (can be done in any order)
        {
            chapter = "Strom'kar, the Warbreaker",
            summary = "Journey to the Broken Shore and the ruins of Stromgarde to claim the legendary two-handed sword once wielded by the troll-slaying king.",
            recap = "Odyn spoke of Strom'kar, the Warbreaker — a blade forged in the ancient empire of Arathor and wielded by King Thoradin against the Amani trolls. You traveled to the ruins of Stromgarde and fought through the shadows to reclaim the sword from its cursed resting place. The blade hummed with ancient power as you raised it — a weapon worthy of the Battlelord.",
            quests = {
                { id = 41105, name = "The Sword of Kings",          npc = "Odyn" },
            },
        },
        {
            chapter = "Warswords of the Valarjar",
            summary = "Hunt the legendary hero-slayer in Stormheim to claim a pair of rune-etched swords forged for the fury of battle.",
            recap = "The Warswords of the Valarjar called to you — twin blades said to contain the fury of a hundred battles. Odyn sent you to Stormheim to hunt the hero-slayer who had stolen them. Through storm and fire, you tracked the thief to their lair and pried the swords from their grip. The runes along the blades blazed to life in your hands, as if they had been waiting.",
            quests = {
                { id = 40043, name = "The Hunter of Heroes",        npc = "Odyn" },
            },
        },
        {
            chapter = "Scale of the Earth-Warder",
            summary = "Seek out a shield forged from a scale of Neltharion himself, hidden deep within the mountains where the earth remembers.",
            recap = "Deep in the mountains of Highmountain lay a shield forged from a scale of Neltharion, the Earth-Warder — before madness claimed him and he became Deathwing. You braved the ancient caverns and faced the guardians left behind to protect it. The Scale of the Earth-Warder was heavier than any shield you had ever held, but it was unyielding — and so were you.",
            quests = {
                { id = 39191, name = "Legacy of the Icebreaker",    npc = "Odyn" },
            },
        },
    },
}
