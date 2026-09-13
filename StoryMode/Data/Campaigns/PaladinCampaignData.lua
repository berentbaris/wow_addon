local addonName, SM = ...

-- =============================================================================
-- Legion Paladin Campaign: Knights of the Silver Hand
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.PaladinCampaignData = {
    title = "Highlord's Campaign",
    achievementName = "The Highlord's Campaign",
    achievements = { 42276, 10746, 10994, 11171, 11223 },
    description = "Beneath Light's Hope Chapel lies the Sanctum of Light, where the Knights of the Silver Hand reform under your command. The Legion threatens every oath the order was built to keep.\n\nAs Highlord, unite paladins of many traditions, investigate demonic plans, and bring the Light into battles where hope has started to thin.",
    zone = "Sanctum of Light / Broken Isles",
    expansion = "Legion",
    class = "PALADIN",
    color = { 0.96, 0.55, 0.73 },  -- Paladin pink
    adventureGuideInstanceName = "Cathedral of Eternal Night",

    startQuest = { id = 38710, name = "An Urgent Gathering", npc = "Lord Maxwell Tyrosus", location = "Dalaran" },
    startMapID = 627,
    startX = 0.4600,
    startY = 0.4400,

    npcLocations = {
        ["Lord Maxwell Tyrosus"]        = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Lord Grayson Shadowbreaker"]  = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Lady Liadrin"]                = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Aponi Brightmane"]            = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Justicar Julia Celeste"]      = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Vindicator Boros"]            = { mapID = 630, x = 0.4580, y = 0.5160 },
        ["Delas Moonfang"]              = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Nerus Moonfang"]              = { mapID = 646, x = 0.7760, y = 0.4600, location = "Broken Shore" },
        ["Champion Cyssa Dawnrose"]     = { mapID = 646, x = 0.4380, y = 0.6300, location = "Broken Shore" },
        ["Arator"]                      = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Arator the Redeemer"]         = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Lothraxion"]                  = { mapID = 24, x = 0.7640, y = 0.5170, location = "Sanctum of Light / Broken Isles" },
        ["Prophet Velen"]               = { mapID = 627, x = 0.4660, y = 0.2660 },
        ["Archmage Khadgar"]            = { mapID = 627, x = 0.2860, y = 0.4870 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4460, y = 0.6340 },
    },

    npcDisplayIDs = {
        ["Lord Maxwell Tyrosus"]        = 62762,
        ["Lord Grayson Shadowbreaker"]  = 62304,
        ["Lady Liadrin"]                = 61971,
        ["Aponi Brightmane"]            = 62788,
        ["Justicar Julia Celeste"]      = 23035,
        ["Vindicator Boros"]            = 63585,
        ["Delas Moonfang"]              = 50541,
        ["Arator the Redeemer"]         = 21782,
        ["Lothraxion"]                  = 71813,
        ["Prophet Velen"]               = 67048,
        ["Archmage Khadgar"]            = 65834,
    },

    chapters = {
        {
            chapter = "An Urgent Gathering",
            summary = "Lord Maxwell Tyrosus calls paladins from every order to the Sanctum of Light beneath Light's Hope Chapel.",
            recap = "Lord Maxwell Tyrosus issued an urgent summons — the Silver Hand was reforming, and Light's Hope Chapel would be its heart. You descended into the Sanctum of Light, hidden beneath the chapel for centuries, where paladins of every faith gathered. Tyrosus named you champion, and you claimed a weapon of legend. Lady Liadrin pledged the Blood Knights' strength, and the Silver Hand rode again.",
            quests = {
                { id = 38710, name = "An Urgent Gathering",        npc = "Lord Maxwell Tyrosus" },
                { id = 40408, name = "Weapons of Legend",           npc = "Lord Maxwell Tyrosus" },
                { id = 42811, name = "We Meet at Light's Hope",     npc = "Lord Maxwell Tyrosus" },
                { id = 38566, name = "A United Force",              npc = "Lord Maxwell Tyrosus" },
                { id = 38933, name = "Logistical Matters",          npc = "Lord Maxwell Tyrosus" },
                { id = 39756, name = "A Sound Plan",                npc = "Lord Grayson Shadowbreaker" },
                { id = 42844, name = "Growing Power",               npc = "Justicar Julia Celeste" },
                { id = 39696, name = "Rise, Champions",             npc = "Lord Maxwell Tyrosus" },
                { id = 42881, name = "Champion: Lady Liadrin",      npc = "Lady Liadrin" },
            },
        },

        {
            chapter = "To Faronaar",
            summary = "The Legion has established a foothold in Azsuna. Lead the Silver Hand to Faronaar and recruit new champions in battle.",
            recap = "The Legion's grip on Faronaar in Azsuna was tightening. Lord Grayson Shadowbreaker dispatched you to break it. With Vindicator Boros at your side, you cut through demon ranks and destroyed their communication orbs. Justicar Julia Celeste fought with a fury that earned her a place among your champions. The Codex of Command — a Legion tactical manual — was recovered from the battlefield, but its contents were locked behind demonic encryption.",
            quests = {
                { id = 42886, name = "To Faronaar",                 npc = "Lord Grayson Shadowbreaker" },
                { id = 42887, name = "This Is Retribution",         npc = "Vindicator Boros" },
                { id = 42888, name = "Communication Orbs",          npc = "Justicar Julia Celeste" },
                { id = 42890, name = "The Codex of Command",        npc = "Justicar Julia Celeste" },
                { id = 42848, name = "Recruiting the Troops",       npc = "Lord Grayson Shadowbreaker" },
                { id = 42849, name = "Wrath and Justice",           npc = "Lord Grayson Shadowbreaker" },
                { id = 42850, name = "Tech It Up a Notch",          npc = "Lord Grayson Shadowbreaker" },
                { id = 42852, name = "Champion: Justicar Julia Celeste", npc = "Justicar Julia Celeste" },
                { id = 42851, name = "Champion: Vindicator Boros",  npc = "Vindicator Boros" },
            },
        },

        {
            chapter = "Cracking the Codex",
            summary = "Decipher the Legion's Codex of Command. The Violet Hold holds a demon who can translate it — but at what cost?",
            recap = "Aponi Brightmane studied the Codex of Command but needed a demon's mind to crack its encryption. The answer came from an unlikely source — a demon prisoner in the Violet Hold. Delas Moonfang, a night elf priestess drawn to the paladin's path, helped translate the demonic text. What you found inside chilled your blood: the Legion had captured Aponi Brightmane and was holding her on Niskara. The invasion plans were clear — and so was your next move.",
            quests = {
                { id = 43486, name = "Cracking the Codex",          npc = "Aponi Brightmane" },
                { id = 43487, name = "Assault on Violet Hold: The Fel Lexicon", npc = "Delas Moonfang" },
                { id = 43488, name = "Blood of Our Enemy",          npc = "Delas Moonfang" },
                { id = 43535, name = "Translation: Danger!",        npc = "Delas Moonfang" },
                { id = 43493, name = "Black Rook Hold: Lord Ravencrest", npc = "Lord Grayson Shadowbreaker" },
            },
        },

        {
            chapter = "United As One",
            summary = "Storm the demon world of Niskara to rescue Aponi Brightmane and strike at the Legion's command structure.",
            recap = "The Silver Hand marshaled for war. You led the assault on Niskara — a demon world where Aponi Brightmane was held captive. Through waves of demons you fought, Aponi's libram serving as a beacon. When you found her, she was wounded but unbroken. Together with Delas Moonfang — who chose to become a paladin that day — you shattered the Legion's forces on Niskara. The mind of the enemy lay open, and the Silver Hand's unity was forged in fire.",
            quests = {
                { id = 43489, name = "To Felblaze Ingress",         npc = "Lord Grayson Shadowbreaker" },
                { id = 43490, name = "Aponi's Trail",                npc = "Lord Grayson Shadowbreaker" },
                { id = 43491, name = "Allies of the Light",          npc = "Aponi Brightmane" },
                { id = 43540, name = "The Mind of the Enemy",        npc = "Aponi Brightmane" },
                { id = 43541, name = "United As One",                npc = "Lord Grayson Shadowbreaker" },
                { id = 43492, name = "Champion: Aponi Brightmane",   npc = "Aponi Brightmane" },
                { id = 43933, name = "Champion: Delas Moonfang",     npc = "Delas Moonfang" },
            },
        },

        {
            chapter = "Warriors of Light",
            summary = "Complete the Silver Hand's reformation. Recruit Arator and Lothraxion, and accept the title of Highlord.",
            recap = "With Niskara shattered, the Silver Hand stood triumphant. Arator the Redeemer — son of Turalyon and Alleria — joined your order, his half-elven heritage bridging every divide. Then came Lothraxion, a nathrezim infused with the Light itself — living proof that even demons could be redeemed. Lord Maxwell Tyrosus forged your weapon anew and bestowed the title of Highlord upon you — the first since the Lich King destroyed the original Silver Hand. A light in the darkness, brighter than ever.",
            quests = {
                { id = 43699, name = "Defenders of the World",      npc = "Lord Grayson Shadowbreaker" },
                { id = 43700, name = "A Light in the Darkness",      npc = "Lord Grayson Shadowbreaker" },
                { id = 43697, name = "Warriors of Light",            npc = "Lord Maxwell Tyrosus" },
                { id = 43424, name = "A Hero's Weapon",              npc = "Lord Maxwell Tyrosus" },
                { id = 43785, name = "Champion: Arator the Redeemer", npc = "Arator" },
                { id = 43701, name = "Champion: Lothraxion",         npc = "Lothraxion" },
            },
        },

        {
            chapter = "Highlord's Golden Charger",
            summary = "The war reaches the Broken Shore. Break a family curse, then forge the Highlord's Golden Charger at the Hammer of Dalaran.",
            recap = "On the Broken Shore, Lady Liadrin led the Silver Hand's assault. Delas Moonfang's past caught up with her — an ancestor's curse threatened her family. You broke the curse, freed Nerus Moonfang from his torment, and earned another champion for the order. When the Shore was secured, Lord Grayson Shadowbreaker sent you to the Hammer of Dalaran — the legendary forge — where Alard Schmied crafted armor worthy of a Highlord. In the shadows beneath the city, a golden charger waited, and it carried you into the light.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45143, name = "Judgment Awaits",              npc = "Lady Liadrin" },
                { id = 45890, name = "Ancestors and Enemies",        npc = "Delas Moonfang" },
                { id = 45148, name = "Oath Breaker",                 npc = "Nerus Moonfang" },
                { id = 45149, name = "Ending the Crescent Curse",    npc = "Nerus Moonfang" },
                { id = 46045, name = "Champion: Nerus Moonfang",     npc = "Nerus Moonfang" },
                { id = 46069, name = "Worthy of the Title",          npc = "Champion Cyssa Dawnrose" },
                { id = 46070, name = "Preparations Underway",        npc = "Lord Grayson Shadowbreaker" },
                { id = 45770, name = "Stirring in the Shadows",      npc = "Lord Grayson Shadowbreaker" },
            },
        },

        {
            chapter = "The Ashbringer",
            summary = "Claim the Ashbringer, the legendary blade that burned with holy fire and shattered the Scourge.",
            recap = "Lord Maxwell Tyrosus spoke the name that every paladin knew — the Ashbringer. The blade that had burned with holy fire in Alexandros Mograine's hands, that had been corrupted and redeemed, that had shattered the Scourge at Light's Hope Chapel. You sought guidance and followed the weapon's trail to its resting place. When you drew the Ashbringer, holy fire erupted along its edge, and the weight of every paladin who had carried it settled onto your shoulders.",
            quests = {
                { id = 42770, name = "Seeking Guidance",             npc = "Lord Maxwell Tyrosus" },
            },
        },
        {
            chapter = "The Silver Hand",
            summary = "Recover the Silver Hand, the holy mace of the original paladins, lost since the founding of the order.",
            recap = "A mysterious paladin appeared with word of the Silver Hand — the holy mace wielded by the first paladins of Lordaeron. You followed the trail through ancient crypts and sacred sites, facing trials that tested your faith as much as your strength. The Silver Hand pulsed with warmth when you finally held it, and the spirits of the original knights seemed to nod in approval.",
            quests = {
                { id = 42231, name = "The Mysterious Paladin",       npc = "Lord Maxwell Tyrosus" },
            },
        },
        {
            chapter = "Truthguard",
            summary = "Seek Truthguard, a titan-forged shield that protects the worthy and strikes down the false.",
            recap = "Lord Maxwell Tyrosus pointed you toward Truthguard — a shield forged by the titans themselves, imbued with the power to protect the righteous and shatter the deceitful. You traveled to the Shrine of the Truthguard and faced the shield's ancient tests. Truthguard weighed nothing in the hands of the pure — and everything in the hands of the unworthy. It chose you.",
            quests = {
                { id = 42000, name = "Seeker of Truth",              npc = "Lord Maxwell Tyrosus" },
            },
        },
    },
}
