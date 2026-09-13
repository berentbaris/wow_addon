local addonName, SM = ...

-- =============================================================================
-- Classic: Onyxia and the Black Dragonflight
-- Alliance and Horde attunements to Onyxia's Lair.
-- =============================================================================

SM.OnyxiaData = {
    title = "The Drakefire Amulet",
    description = "In the Burning Steppes, Helendis Riverhorn has orders for the Alliance against black dragonkin gathering near Morgan's Vigil. In Kargath, Warlord Goretooth has a command for the Horde that points into Blackrock Spire.\n\nTake the first report and follow your faction's chain of summons, proofs, and dangerous names. The amulet at the end of the road is not given to anyone who has only heard rumors of dragons.",
    zone = "Burning Steppes / Blackrock Mountain / Stormwind / Dustwallow Marsh",
    expansion = "Classic",
    recommendedLevel = { min = 48, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.78, 0.24, 0.08 },
    icon = 134153,
    adventureGuideInstanceName = "Onyxia's Lair",
    adventureCoverTexture = 131825, -- Blackrock Spire: closest Classic loading screen for the Rend/Drakkisath attunement path
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 4182, name = "Dragonkin Menace", npc = "Helendis Riverhorn", location = "Morgan's Vigil, Burning Steppes", faction = "Alliance" },
    startMapID = 36,
    startX = 0.8500,
    startY = 0.6900,

    npcLocations = {
        ["Helendis Riverhorn"] = { mapID = 36, x = 0.8500, y = 0.6900, location = "Morgan's Vigil, Burning Steppes" },
        ["Magistrate Solomon"] = { mapID = 49, x = 0.2900, y = 0.4400, location = "Lakeshire, Redridge Mountains" },
        ["Highlord Bolvar Fordragon"] = { mapID = 84, x = 0.7817, y = 0.1809, location = "Stormwind Keep" },
        ["Marshal Maxwell"] = { mapID = 36, x = 0.8400, y = 0.6900, location = "Morgan's Vigil, Burning Steppes" },
        ["Reginald Windsor"] = { mapID = 84, x = 0.6470, y = 0.7679, location = "Stormwind gates" },
        ["Ragged John"] = { mapID = 36, x = 0.6500, y = 0.2400, location = "north of the Ruins of Thaurissan, Burning Steppes" },
        ["Marshal Windsor"] = { mapID = 242, x = 0.4628, y = 0.9469, location = "the Detention Block, Blackrock Depths" },
        ["A Crumpled Up Note"] = { mapID = 242, x = 0.4800, y = 0.6200, location = "Blackrock Depths" },
        ["Squire Rowe"] = { mapID = 84, x = 0.6600, y = 0.3200, location = "Stormwind gates" },
        ["Haleh"] = { mapID = 83, x = 0.5400, y = 0.5100, location = "Mazthoril, Winterspring" },

        ["Warlord Goretooth"] = { mapID = 15, x = 0.0500, y = 0.4700, location = "Kargath, Badlands" },
        ["Eitrigg"] = { mapID = 85, x = 0.3200, y = 0.3800, location = "Grommash Hold, Orgrimmar" },
        ["Thrall"] = { mapID = 85, x = 0.3200, y = 0.3800, location = "Grommash Hold, Orgrimmar" },
        ["Rexxar"] = { mapID = 66, x = 0.2574, y = 0.7006, location = "the road through Desolace" },
        ["Myranda the Hag"] = { mapID = 22, x = 0.5100, y = 0.7800, location = "Sorrow Hill, Western Plaguelands" },
        ["Emberstrife"] = { mapID = 70, x = 0.5600, y = 0.8700, location = "Emberstrife's Den, Dustwallow Marsh" },
        ["Scryer"] = { mapID = 83, x = 0.5200, y = 0.5500, location = "southwest of Everlook, Winterspring" },
        ["Somnus"] = { mapID = 51, x = 0.7500, y = 0.6500, location = "southeastern Swamp of Sorrows" },
        ["Chronalis"] = { mapID = 71, x = 0.6500, y = 0.5000, location = "the Caverns of Time, Tanaris" },
        ["Axtroz"] = { mapID = 56, x = 0.8200, y = 0.4800, location = "the road to Grim Batol, Wetlands" },
        ["General Drakkisath"] = { mapID = 250, x = 0.6200, y = 0.3500, location = "Upper Blackrock Spire" },
    },

    npcDisplayIDs = {
        ["Highlord Bolvar Fordragon"] = 24879,
        ["Marshal Windsor"] = 8707,
        ["Reginald Windsor"] = 9052,
        ["Lady Katrana Prestor"] = 8769,
        ["Onyxia"] = 8570,
        ["Thrall"] = 61727,
        ["Rexxar"] = 60766,
        ["Emberstrife"] = 6374,
        ["General Drakkisath"] = 10115,
    },

    chapterDisplayIDs = {
        ["The True Masters"] = 5566,
        ["Marshal Windsor"] = 8707,
        ["The Great Masquerade"] = 8769,
        ["The Drakefire Amulet"] = 8570,
        ["For the Horde"] = 4527,
        ["Rexxar's Testament"] = 10182,
        ["The Test of Skulls"] = 6374,
        ["Blood of the Black Dragon Champion"] = 10115,
    },

    chapterIcons = {
        ["The True Masters"] = 134327,
        ["Marshal Windsor"] = 134943,
        ["The Great Masquerade"] = 134328,
        ["The Drakefire Amulet"] = 134153,
        ["For the Horde"] = 132349,
        ["Rexxar's Testament"] = 132320,
        ["The Test of Skulls"] = 134157,
        ["Blood of the Black Dragon Champion"] = 134153,
    },

    chapters = {
        {
            chapter = "The True Masters",
            faction = "Alliance",
            summary = "Begin in the Burning Steppes with Helendis Riverhorn and carry the black dragon reports between Lakeshire, Stormwind, and Morgan's Vigil.",
            recap = "The first signs of Onyxia's reach came from the Burning Steppes, where Helendis Riverhorn watched black dragonkin gathering strength. Magistrate Solomon treated the threat as a kingdom matter, Bolvar Fordragon weighed it from Stormwind Keep, and Marshal Maxwell became the Alliance's field anchor. The question was no longer whether dragons were moving. It was who in Stormwind had allowed the threat to spread.",
            quests = {
                { id = 4182, name = "Dragonkin Menace", npc = "Helendis Riverhorn" },
                { id = 4183, name = "The True Masters", displayName = "To Lakeshire", npc = "Helendis Riverhorn" },
                { id = 4184, name = "The True Masters", displayName = "To Stormwind", npc = "Magistrate Solomon" },
                { id = 4185, name = "The True Masters", displayName = "Back to Lakeshire", npc = "Highlord Bolvar Fordragon" },
                { id = 4186, name = "The True Masters", displayName = "To Morgan's Vigil", npc = "Highlord Bolvar Fordragon" },
                { id = 4223, name = "The True Masters", displayName = "Ragged John's Tale", npc = "Magistrate Solomon" },
                { id = 4224, name = "The True Masters", displayName = "Return to Maxwell", npc = "Marshal Maxwell" },
            },
        },
        {
            chapter = "Marshal Windsor",
            faction = "Alliance",
            summary = "Hear Ragged John's tale, find Marshal Windsor in Blackrock Depths, and recover the proof taken from him.",
            recap = "Ragged John gave the conspiracy a name and a survivor: Marshal Reginald Windsor. Finding Windsor in Blackrock Depths did not bring immediate victory. He had lost hope, and the proof had been torn away from him. A crumpled note and a shred of evidence changed that. Windsor remembered his duty, gathered the missing information, and prepared for the impossible part: walking out of Blackrock Depths alive.",
            quests = {
                { id = 4241, name = "Marshal Windsor", npc = "Marshal Maxwell" },
                { id = 4242, name = "Abandoned Hope", npc = "Marshal Windsor" },
                { id = 4264, name = "A Crumpled Up Note", npc = "A Crumpled Up Note" },
                { id = 4282, name = "A Shred of Hope", npc = "Marshal Windsor" },
                { id = 4322, name = "Jail Break!", npc = "Marshal Windsor" },
            },
        },
        {
            chapter = "The Great Masquerade",
            faction = "Alliance",
            summary = "Escort Marshal Windsor back to Stormwind and stand with him when his proof is finally heard.",
            recap = "Marshal Windsor's return turned suspicion into spectacle. At the gates of Stormwind, he gathered himself for one last duty and marched through the city toward the keep. The guards, nobles, and courtiers saw what the dragon had hidden from them: Lady Katrana Prestor was no noble advisor. She was Onyxia, broodmother of the black dragonflight. Windsor died exposing her, but his sacrifice broke the illusion around Bolvar and gave the Alliance a clear enemy at last.",
            quests = {
                { id = 6402, name = "Stormwind Rendezvous", npc = "Marshal Maxwell" },
                { id = 6403, name = "The Great Masquerade", npc = "Reginald Windsor" },
            },
        },
        {
            chapter = "The Drakefire Amulet",
            faction = "Alliance",
            summary = "Seek Haleh in Winterspring and bring her General Drakkisath's blood to make the Drakefire Amulet.",
            recap = "With Onyxia exposed, the Alliance still needed a way into her lair. Bolvar sent you to Haleh, hidden in Winterspring, and Haleh named the final price: the blood of General Drakkisath from Upper Blackrock Spire. The black dragonflight's own champion became the material for the Drakefire Amulet. The court conspiracy was over. The assault on Onyxia could begin.",
            quests = {
                { id = 6501, name = "The Dragon's Eye", npc = "Highlord Bolvar Fordragon" },
                { id = 6502, name = "Drakefire Amulet", npc = "Haleh" },
            },
        },
        {
            chapter = "For the Horde",
            faction = "Horde",
            summary = "In Kargath, take Warlord Goretooth's orders into Blackrock Spire and bring Rend Blackhand's command to Thrall.",
            recap = "The Horde's road to Onyxia began with Blackrock command papers and the old wound of the Blackhand name. Warlord Goretooth demanded proof from Lower Blackrock Spire, Eitrigg weighed the report in Orgrimmar, and Thrall sent you to kill Warchief Rend Blackhand. Rend's death was a declaration that the Horde would not bow to a false warchief propped up by dragons.",
            quests = {
                { id = 4903, name = "Warlord's Command", npc = "Warlord Goretooth" },
                { id = 4941, name = "Eitrigg's Wisdom", npc = "Warlord Goretooth" },
                { id = 4974, name = "For The Horde!", npc = "Thrall" },
                { id = 6566, name = "What the Wind Carries", npc = "Thrall" },
            },
        },
        {
            chapter = "Rexxar's Testament",
            faction = "Horde",
            summary = "Find Rexxar and follow the trials he sets before the amulet can be completed.",
            recap = "Thrall knew Onyxia's threat reached beyond Blackrock Mountain, so he sent you to Rexxar. The champion of the Horde carried old knowledge and a hard road: find Myranda, wear an illusion, gather dragon eyes in Upper Blackrock Spire, and use that disguise to reach Emberstrife. Where the Alliance exposed a dragon in court, the Horde had to deceive a dragon servant into opening the next gate.",
            quests = {
                { id = 6567, name = "The Champion of the Horde", npc = "Thrall" },
                { id = 6568, name = "The Testament of Rexxar", displayName = "Mistress of Deception", npc = "Rexxar" },
                { id = 6569, name = "Oculus Illusions", npc = "Myranda the Hag" },
                { id = 6570, name = "Emberstrife", npc = "Myranda the Hag" },
            },
        },
        {
            chapter = "The Test of Skulls",
            faction = "Horde",
            summary = "Emberstrife demands the skulls of four dragons: Scryer, Somnus, Chronalis, and Axtroz.",
            recap = "Emberstrife's tests scattered the Horde across Azeroth. Scryer waited in Winterspring, Somnus haunted Swamp of Sorrows, Chronalis guarded the Caverns of Time, and Axtroz patrolled the road to Grim Batol. Each skull was trophy, key, and proof of strength. By the time the fourth dragon fell, Emberstrife's amulet was ready for the last transformation.",
            quests = {
                { id = 6582, name = "The Test of Skulls, Scryer", npc = "Emberstrife" },
                { id = 6583, name = "The Test of Skulls, Somnus", npc = "Emberstrife" },
                { id = 6584, name = "The Test of Skulls, Chronalis", npc = "Emberstrife" },
                { id = 6585, name = "The Test of Skulls, Axtroz", npc = "Emberstrife" },
                { id = 6601, name = "Ascension...", npc = "Emberstrife" },
            },
        },
        {
            chapter = "Blood of the Black Dragon Champion",
            faction = "Horde",
            summary = "Bring General Drakkisath's blood to Rexxar and complete the Drakefire Amulet.",
            recap = "The final proof came from General Drakkisath himself. His blood completed the amulet's power, and Rexxar turned the long road of commands, disguises, skulls, and trials into a single key. The Horde had its answer to Onyxia: strength tested across the world and deep inside Blackrock Spire.",
            quests = {
                { id = 6602, name = "Blood of the Black Dragon Champion", npc = "Rexxar" },
            },
        },
    },
}
