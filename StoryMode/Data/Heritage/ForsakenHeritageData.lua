local addonName, SM = ...

-- =============================================================================
-- Forsaken (Undead) Heritage Armor Quest Database
-- Questline: Heritage of the Forsaken (Patch 10.1.7)
-- Race-locked: Undead (race token "Scourge")
--
-- Notes:
-- - This file intentionally contains ONLY the heritage armor chain.
-- - "Return to Lordaeron" is a prerequisite achievement, not part of this chain here.
-- - There is a small optional epilogue quest for Sylvanas loyalists ("The Long Hunt").
-- =============================================================================

SM.ForsakenHeritageData = {
    title = "Heritage of the Forsaken",
    description = "Lordaeron is in Forsaken hands again, but old enemies still haunt the forests beyond its walls. The Scarlet Crusade clings to its strongholds, Gilneas has not forgotten, and a former queen's absence leaves difficult questions behind.\n\nLilian Voss has a mission in Silverpine, and she needs someone who knows what it means to be Forsaken: to stand at a graveside, remember, and choose again what the second life is for.",
    zone = "Tirisfal Glades / Silverpine Forest",
    expansion = "Dragonflight",

    -- Identity filtering (StoryMode.lua uses these fields)
    faction = "Horde",
    race = "Scourge", -- Undead (Forsaken) only
    requiredLevel = 50,

    -- Achievement resolver will fill achievementID at runtime if needed
    achievementName = "Heritage of the Forsaken",
    achievements = { 15579 },  -- Return to Lordaeron

    color = { 0.38, 0.40, 0.42 }, -- cold grey
    -- Use a Forsaken-themed icon for the questline card instead of a character portrait.
    icon = "Interface\\Icons\\inv_misc_tabard_forsaken",
    adventureGuideInstanceName = "Scarlet Monastery",
    adventureCoverTexture = 131867, -- Ruins of Lordaeron battleground loading screen
    adventureCoverIsLoadingScreen = true,

    -- Start location: Lilian Voss at the Ruins of Lordaeron (Dragonflight phased area)
    startQuest = { id = 76530, name = "Unliving Summons", npc = "Lilian Voss", location = "Ruins of Lordaeron" },
    startMapID = 2070, -- Ruins of Lordaeron
    startX = 0.6380,
    startY = 0.6820,

    npcLocations = {
        -- Ruins of Lordaeron (#2070)
        ["Lilian Voss"] = { mapID = 2070, x = 0.6380, y = 0.6820 },
        ["Deathstalker Commander Belmont"] = { mapID = 2070, x = 0.6120, y = 0.8260 },

        -- Silverpine Forest (classic mapID 21)
        ["Dark Ranger Velonara"] = { mapID = 21, x = 0.7040, y = 0.1820 , location = "Tirisfal Glades / Silverpine Forest"}, -- Sepulcher area (approx)
        ["Master Apothecary Faranell"] = { mapID = 21, x = 0.4500, y = 0.4200 , location = "Tirisfal Glades / Silverpine Forest"}, -- Sepulcher area (approx)

        -- Fenris Isle / Scarlet camp (Silverpine)
        ["Quartermaster Newlem"] = { mapID = 21, x = 0.6600, y = 0.3000 }, -- Fenris Isle (approx)

        -- Loyalist-only epilogue
        ["Dori'thur"] = { mapID = 2070, x = 0.6400, y = 0.6800 }, -- appears near completion (approx)
        ["Calia Menethil"] = { mapID = 21, x = 0.4540, y = 0.4160, location = "Silverpine Forest" },
    },

    npcDisplayIDs = {
        -- These are non-critical (used for portraits if your UI chooses to).
        -- Leaving unknowns as 0 is fine.
        ["Lilian Voss"] = 67721,
        ["Deathstalker Commander Belmont"] = 114139,
        ["Dark Ranger Velonara"] = 105389,
        ["Master Apothecary Faranell"] = 90372,
        ["Quartermaster Newlem"] = 113266,
        ["Dori'thur"] = 90230,
    },
    chapterDisplayIDs = {
        ["Heritage of the Forsaken"] = 67721, -- Lilian Voss
        ["Epilogue (Sylvanas Loyalists)"] = 38801, -- Dori'thur
    },
    chapterIcons = {
        ["Heritage of the Forsaken"] = 67721,
        ["Epilogue (Sylvanas Loyalists)"] = "Interface\\Icons\\inv_misc_tabard_forsaken",
    },

    chapters = {
        {
            chapter = "Heritage of the Forsaken",
            summary = "The Scarlet Crusade has returned to Silverpine Forest. Lilian Voss needs a champion to go in quietly, earn their trust, and open the way for the Forsaken to strike.",
            recap = "With Lordaeron newly reclaimed, old enemies resurfaced. The Scarlet Crusade established a foothold in Silverpine Forest, determined to purge the Forsaken from their ancestral lands. Under Lilian Voss's guidance, you gathered alchemical weapons, donned a stolen disguise, slipped into the enemy’s ranks, and opened the way for the Forsaken to strike back in force. When the dust settled, you stood as a proven champion — Forsaken by death, but not by purpose.",
            quests = {
                { id = 76530, name = "Unliving Summons", npc = "Lilian Voss" },
                { id = 72854, name = "Our Enemies Abound", npc = "Lilian Voss" },
                { id = 72855, name = "To the Sepulcher", npc = "Deathstalker Commander Belmont" },

                -- Gathering reagents (these can be offered in parallel)
                { id = 72856, name = "Nothing Like the Classic", npc = "Master Apothecary Faranell" },
                { id = 72857, name = "Boom Weed", npc = "Master Apothecary Faranell" },
                { id = 72858, name = "Acid Beats Paper", npc = "Dark Ranger Velonara" },

                -- Set up infiltration
                { id = 72859, name = "A Proper Disguise", npc = "Calia Menethil" },
                { id = 72860, name = "Fear is Our Weapon", npc = "Lilian Voss" },
                { id = 72861, name = "The Scarlet Spy", npc = "Lilian Voss" },

                -- Fenris Isle
                { id = 72862, name = "Among Us", npc = "Quartermaster Newlem" },
                { id = 72863, name = "The Flight of the Banshee", npc = "Dark Ranger Velonara" },
                { id = 72864, name = "Death to the Living", npc = "Deathstalker Commander Belmont" },
                { id = 72865, name = "This is the Hour of the Forsaken", npc = "Lilian Voss" },

                -- Wrap up
                { id = 72866, name = "Return to Lordaeron", npc = "Lilian Voss" },
                { id = 72867, name = "I Am Forsaken", npc = "Lilian Voss" },
            },
        },
        {
            chapter = "Epilogue (Sylvanas Loyalists)",
            gated = true,
            note = "Complete the Forsaken Heritage questline as an Undead character. Requires having sided with Sylvanas during the war campaign.",
            summary = "Not everyone who followed the Banshee Queen has made peace with what came after. A message finds its way to the ruins of Lordaeron for those who haven't.",
            recap = "For those who once swore loyalty to the Banshee Queen, a final message arrives — not to excuse the past, but to acknowledge it. The Forsaken move forward, but the echoes of old vows still linger in the ruins of Lordaeron.",
            quests = {
                { id = 75519, name = "The Long Hunt", npc = "Dori'thur", optional = true },
            },
        },
    },
}

return SM
