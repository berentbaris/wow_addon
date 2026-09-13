local addonName, SM = ...

-- =============================================================================
-- Legion Shaman Campaign: The Earthen Ring
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.ShamanCampaignData = {
    title = "Farseer's Campaign",
    achievementName = "The Farseer's Campaign",
    achievements = { 42280, 10746, 10994, 11171, 11223 },
    description = "At the Maelstrom's edge, the Earthen Ring struggles to keep Azeroth from tearing apart. The elements are restless, wounded, and not always willing to answer.\n\nAs Farseer, seek the elemental lords, restore balance where the world is breaking, and hold the center while the Legion tries to pull everything apart.",
    zone = "The Maelstrom / Broken Isles",
    expansion = "Legion",
    class = "SHAMAN",
    color = { 0.00, 0.44, 0.87 },  -- Shaman blue
    adventureGuideInstanceName = "Throne of the Tides",

    startQuest = { id = 39746, name = "A Ring Unbroken", npc = "Thrall", location = "Dalaran" },
    startMapID = 627,
    startX = 0.2860,
    startY = 0.4870,

    npcLocations = {
        ["Baron Scaldius"] = { mapID = 8125, x = 0.2700, y = 0.8240, location = "Firelands" },
        ["Duke Hydraxis"] = { mapID = 7745, x = 0.2980, y = 0.3400, location = "The Maelstrom" },
        ["Lord Smolderon"] = { mapID = 8125, x = 0.4900, y = 0.3040, location = "Firelands" },
        ["Thrall"]                      = { mapID = 736, x = 0.4720, y = 0.3380 },
        ["Farseer Nobundo"]             = { mapID = 736, x = 0.3200, y = 0.5100 },
        ["Advisor Sevel"]               = { mapID = 736, x = 0.3300, y = 0.6000 },
        ["Stormcaller Mylra"]           = { mapID = 736, x = 0.4700, y = 0.5240 },
        ["Erunak Stonespeaker"]         = { mapID = 736, x = 0.4360, y = 0.6320 },
        ["Consular Celestos"]           = { mapID = 736, x = 0.3000, y = 0.5100 },
        ["Thunderaan"]                  = { mapID = 736, x = 0.5260, y = 0.7800 },
        ["Muln Earthfury"]              = { mapID = 736, x = 0.3200, y = 0.4900 },
        ["Rehgar Earthfury"]            = { mapID = 736, x = 0.3100, y = 0.5200 },
        ["Therazane"]                   = { mapID = 207, x = 0.5700, y = 0.1400 },
        ["Orono"]                       = { mapID = 646, x = 0.4460, y = 0.6160 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4460, y = 0.6340 },
        ["Firelord Smolderon"]          = { mapID = 736, x = 0.4900, y = 0.3040 },
        ["Elementalist Janai"]          = { mapID = 736, x = 0.3300, y = 0.5000 },
        ["Highlord Demitrian"]          = { mapID = 81, x = 0.2960, y = 0.1060 },
        ["Magatha Grimtotem"]           = { mapID = 646, x = 0.4220, y = 0.4520 },
        ["Odyn"]                        = { mapID = 695, x = 0.5840, y = 0.8300, location = "Skyhold" },
    },

    npcDisplayIDs = {
        ["Baron Scaldius"]              = 69829,
        ["Thrall"]                      = 61727,
        ["Farseer Nobundo"]             = 64939,
        ["Advisor Sevel"]               = 16385,
        ["Stormcaller Mylra"]           = 33020,
        ["Erunak Stonespeaker"]         = 30408,
        ["Consular Celestos"]           = 47254,
        ["Thunderaan"]                  = 71137,
        ["Muln Earthfury"]              = 38658,
        ["Rehgar Earthfury"]            = 64946,
        ["Therazane"]                   = 32913,
        ["Firelord Smolderon"]          = 38793,
        ["Lord Smolderon"]              = 38793,
        ["Elementalist Janai"]          = 36894,
        ["Highlord Demitrian"]          = 14395,
        ["Magatha Grimtotem"]           = 74531,
        ["Maiev Shadowsong"]            = 77009,
    },

    chapters = {
        {
            chapter = "A Ring Unbroken",
            summary = "Thrall calls you to the Maelstrom, where the Earthen Ring fights to keep the world from tearing apart.",
            recap = "Thrall's summons brought you to the edge of the Maelstrom — the wound in the world where Deathwing had nearly torn Azeroth asunder. The Earthen Ring was losing the fight to hold it together. Farseer Nobundo stood at the eye of the storm, channeling what remained of the ring's power. You claimed an artifact weapon attuned to the elements, and Stormcaller Mylra and Duke Hydraxis pledged themselves as your first champions. The elements were restless — and they were listening.",
            quests = {
                { id = 39746, name = "A Ring Unbroken",             npc = "Thrall" },
                { id = 41335, name = "The Elements Call...",         npc = "Thrall" },
                { id = 40225, name = "A Ring Reforged",              npc = "Stormcaller Mylra" },
                { id = 41510, name = "Azeroth Needs You",            npc = "Farseer Nobundo" },
                { id = 42114, name = "The Ritual of Tides",          npc = "Farseer Nobundo" },
                { id = 42383, name = "Rise, Champions",              npc = "Farseer Nobundo" },
                { id = 42198, name = "Champion: Stormcaller Mylra",  npc = "Stormcaller Mylra" },
                { id = 42197, name = "Champion: Duke Hydraxis",      npc = "Duke Hydraxis" },
                { id = 42141, name = "Summoner Morn",                npc = "Advisor Sevel" },
                { id = 42142, name = "Recruiting The Troops",        npc = "Advisor Sevel" },
            },
        },

        {
            chapter = "Return of the Windlord",
            summary = "The Maelstrom's Air Pillar weakens. Reforge the Blessed Blade of the Windseeker and return Thunderaan to power.",
            recap = "The Maelstrom's Air Pillar was failing, and only an elemental lord could restore it. Advisor Sevel tracked the Blessed Blade of the Windseeker — the key to freeing Thunderaan, Prince of Air. You journeyed to Highlord Demitrian, reforged the blade, and climbed to the skies above. There, you recharged the weapon and broke Thunderaan's bonds. The Windlord surged free, his winds howling across the Broken Isles. He swore an oath to the Earthen Ring, and Consular Celestos and Nobundo stood with you as the Air Pillar blazed back to life.",
            quests = {
                { id = 42977, name = "Servant of the Windseeker",   npc = "Advisor Sevel" },
                { id = 43002, name = "Blessed Blade of the Windseeker", npc = "Highlord Demitrian" },
                { id = 41770, name = "The Skies Above",              npc = "Advisor Sevel" },
                { id = 41771, name = "Recharging the Blade",         npc = "Consular Celestos" },
                { id = 41776, name = "Return of the Windlord",       npc = "Consular Celestos" },
                { id = 41901, name = "Oath of the Windlord",         npc = "Thunderaan" },
                { id = 41742, name = "Champion: Celestos",           npc = "Consular Celestos" },
                { id = 41743, name = "Champion: Nobundo",            npc = "Farseer Nobundo" },
            },
        },

        {
            chapter = "The Great Stonemother",
            summary = "Deepholm stirs with twilight corruption. Seek Therazane the Stonemother and purge the Twilight's Hammer from her domain.",
            recap = "Therazane the Stonemother sent a tremor through the Maelstrom — a cry for help. Deepholm, the elemental plane of earth, was being consumed by the Twilight's Hammer once more. You descended into the stone realm and found Therazane besieged, her domain crumbling. Together you destroyed the cult's forces, unmasked their master's plan, and unleashed the elements against them. Therazane promised the earth's strength to the Earthen Ring, and Muln Earthfury pledged himself as your champion.",
            quests = {
                { id = 41775, name = "The Great Stonemother",       npc = "Advisor Sevel" },
                { id = 42068, name = "The Return of Twilight",       npc = "Therazane" },
                { id = 41777, name = "Destroying the Cult",          npc = "Therazane" },
                { id = 41897, name = "The Master's Plan",            npc = "Therazane" },
                { id = 41898, name = "Unleashing the Elements",      npc = "Therazane" },
                { id = 41899, name = "Held Captive!",                npc = "Therazane" },
                { id = 42065, name = "The Twilight Master",          npc = "Muln Earthfury" },
                { id = 41900, name = "A Promise of Earth",           npc = "Therazane" },
                { id = 41746, name = "Champion: Muln Earthfury",     npc = "Muln Earthfury" },
            },
        },

        {
            chapter = "Allegiance of Flame",
            summary = "Enter the Firelands and negotiate with Smolderon, the new Firelord, to secure the fire elementals' allegiance.",
            recap = "With Air and Earth secured, Fire remained. You entered the Firelands — still scarred from Ragnaros' fall — and found a new Firelord reigning: Smolderon, younger and more calculating than his predecessor. Baron Scaldius served as intermediary while you proved yourself in trials of flame. The Brand of Damnation burned your skin as a mark of passage, and Smolderon's allegiance was won — grudgingly, but bound by elemental law. Rehgar Earthfury joined your champions, and your weapon was reforged with the power of all three elemental lords.",
            quests = {
                { id = 42208, name = "Return to the Firelands",     npc = "Advisor Sevel" },
                { id = 41772, name = "Ascendant of Flames",          npc = "Advisor Sevel" },
                { id = 41773, name = "The Firelord's Command",       npc = "Baron Scaldius" },
                { id = 41934, name = "The Brand of Damnation",       npc = "Lord Smolderon" },
                { id = 41888, name = "Allegiance of Flame",          npc = "Firelord Smolderon" },
                { id = 41744, name = "Champion: Rehgar Earthfury",   npc = "Rehgar Earthfury" },
                { id = 43425, name = "A Hero's Weapon",              npc = "Odyn" },
            },
        },

        {
            chapter = "Farseer's Raging Tempest",
            summary = "The war moves to the Broken Shore. Contend with Magatha Grimtotem, secure Smolderon's flame, and earn a mount of living storm.",
            recap = "The Broken Shore brought an unwelcome ally — Magatha Grimtotem, the elder crone who had murdered Cairne Bloodhoof. She demanded a place in the Earthen Ring in exchange for her considerable power, and the elements themselves seemed to agree. You worked alongside her through gritted teeth, breaking chains and quelling snakes, while Nobundo led the main assault. Firelord Smolderon's offense scorched the Legion's fortifications, and when the calm came after the storm, Consular Celestos summoned you to a gathering of storms — where a tempest given form became your mount, the Farseer's Raging Tempest.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45652, name = "A \"Humble\" Request",         npc = "Advisor Sevel" },
                { id = 45706, name = "The Power of Thousands",       npc = "Magatha Grimtotem" },
                { id = 45725, name = "Breaking Chains",              npc = "Magatha Grimtotem" },
                { id = 44800, name = "Against Magatha's Will",       npc = "Magatha Grimtotem" },
                { id = 45883, name = "The Firelord's Offense",       npc = "Therazane", mapID = 646, x = 0.6040, y = 0.5160, location = "Broken Shore" },
                { id = 46258, name = "The Calm After the Storm",     npc = "Farseer Nobundo" },
                { id = 46057, name = "Champion: Magatha Grimtotem",  npc = "Magatha Grimtotem" },
                { id = 46791, name = "Carried On the Wind",          npc = "Orono" },
                { id = 46792, name = "Gathering of the Storms",      npc = "Consular Celestos" },
            },
        },

        {
            chapter = "Doomhammer",
            summary = "Thrall passes the Doomhammer to you — the weapon of Orgrim Doomhammer, carried through two wars and across worlds.",
            recap = "Thrall could no longer hear the elements. The Doomhammer — Orgrim's weapon, carried through the First and Second Wars — had gone silent in his hands. He passed it to you, and the moment your fingers closed around the haft, thunder split the sky. The elements had chosen a new wielder. The Doomhammer was yours.",
            quests = {
                { id = 42931, name = "Where the Hammer Falls",      npc = "Stormcaller Mylra" },
            },
        },
        {
            chapter = "The Fist of Ra-den",
            summary = "Seek the Fist of Ra-den, a weapon forged by the titan keeper who tamed the storms of Azeroth.",
            recap = "Nobundo spoke of Ra-den, the titan keeper who had shaped Azeroth's storms. His weapon — the Fist of Ra-den — lay hidden in a vault sealed since the ordering of the world. You braved the coming storm to claim it, and when lightning struck the weapon in your hands, the power of a titan keeper surged through you.",
            quests = {
                { id = 43334, name = "The Coming Storm",            npc = "Rehgar Earthfury" },
            },
        },
        {
            chapter = "Sharas'dal, Scepter of Tides",
            summary = "Descend into the depths to recover Sharas'dal, a scepter that commands the tides themselves.",
            recap = "Erunak Stonespeaker called you to the deeps — Sharas'dal, the Scepter of Tides, had been sensed stirring beneath the ocean floor. You descended into the crushing darkness where water elementals guarded the weapon with fierce devotion. The Scepter of Tides chose to rise with you, and the seas themselves seemed to bow as you surfaced.",
            quests = {
                { id = 43644, name = "To the Deeps",                npc = "Erunak Stonespeaker" },
            },
        },
    },
}
