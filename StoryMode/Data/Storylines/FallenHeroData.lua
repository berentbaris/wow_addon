local addonName, SM = ...

-- =============================================================================
-- Classic: The Fallen Hero of the Horde
-- Swamp of Sorrows, Blasted Lands, Azshara, Felbane, and Razelikh.
-- =============================================================================

SM.FallenHeroData = {
    title = "A Tale of Sorrow",
    description = "At the edge of the Blasted Lands, a fallen hero still waits for orders that never came. His regiment is gone, and the demons beyond Nethergarde have had years to make use of what was left behind.\n\nListen to the dead man's account and follow the scattered trail of soldiers, relics, and old command. The road is long because the failure was not simple.",
    zone = "Swamp of Sorrows / Blasted Lands / Azshara / Stranglethorn Vale",
    expansion = "Classic",
    recommendedLevel = { min = 45, max = 60 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.64, 0.16, 0.10 },
    icon = 136189,
    adventureCoverTexture = 131872, -- Sunken Temple: closest Classic loading screen rooted in Swamp of Sorrows
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 2801, name = "A Tale of Sorrow", npc = "Fallen Hero of the Horde", location = "the road between Swamp of Sorrows and the Blasted Lands" },
    startMapID = 51,
    startX = 0.3400,
    startY = 0.6600,

    npcLocations = {
        ["Fallen Hero of the Horde"] = { mapID = 51, x = 0.3400, y = 0.6600, location = "the road between Swamp of Sorrows and the Blasted Lands" },
        ["Dispatch Commander Ruag"] = { mapID = 51, x = 0.4700, y = 0.5500, location = "Stonard, Swamp of Sorrows" },
        ["Bengor"] = { mapID = 51, x = 0.4550, y = 0.5700, location = "Stonard, Swamp of Sorrows" },
        ["Swamp Talker"] = { mapID = 51, x = 0.6500, y = 0.7750, location = "the murloc camps in southern Swamp of Sorrows" },
        ["Ambassador Ardalan"] = { mapID = 17, x = 0.6600, y = 0.1900, location = "Nethergarde Keep, Blasted Lands" },
        ["Corporal Thund Splithoof"] = { mapID = 51, x = 0.3620, y = 0.6540, location = "near the road into the Blasted Lands" },
        ["Spectral Lockbox"] = { mapID = 51, x = 0.3620, y = 0.6540, location = "beside Corporal Thund Splithoof" },
        ["Spirit of Kirith"] = { mapID = 17, x = 0.6300, y = 0.3200, location = "the Serpent's Coil, Blasted Lands" },
        ["Loramus Thalipedes"] = { mapID = 76, x = 0.6082, y = 0.6635, location = "the Bay of Storms, Azshara" },
        ["Lord Arkkoroc"] = { mapID = 76, x = 0.7700, y = 0.4200, location = "the Temple of Arkkoran, Azshara" },
        ["Galvan the Ancient"] = { mapID = 50, x = 0.5062, y = 0.2048, location = "northern Stranglethorn Vale" },
        ["Grol the Destroyer"] = { mapID = 17, x = 0.4100, y = 0.3400, location = "Dreadmaul Hold, Blasted Lands" },
        ["Archmage Allistarj"] = { mapID = 17, x = 0.6500, y = 0.2900, location = "the Serpent's Coil, Blasted Lands" },
        ["Lady Sevine"] = { mapID = 17, x = 0.4500, y = 0.1400, location = "near the Altar of Storms, Blasted Lands" },
        ["Razelikh the Defiler"] = { mapID = 17, x = 0.4700, y = 0.2300, location = "the Rise of the Defiler, Blasted Lands" },
    },

    npcDisplayIDs = {
        ["Fallen Hero of the Horde"] = 6775,
        ["Loramus Thalipedes"] = 6879,
        ["Lord Arkkoroc"] = 170,
        ["Grol the Destroyer"] = 10169,
        ["Archmage Allistarj"] = 6769,
        ["Lady Sevine"] = 6768,
        ["Razelikh the Defiler"] = 10543,
    },

    chapterDisplayIDs = {
        ["Orders That Never Came"] = 6775,
        ["A Tale of Sorrow"] = 6775,
        ["The Last Souls"] = 6775,
        ["Loramus and the Beast's Name"] = 6879,
        ["Felbane"] = 6879,
        ["Rakh'likh"] = 10543,
    },

    chapterIcons = {
        ["Orders That Never Came"] = 132343,
        ["A Tale of Sorrow"] = 136189,
        ["The Last Souls"] = 136123,
        ["Loramus and the Beast's Name"] = 136172,
        ["Felbane"] = 135343,
        ["Rakh'likh"] = 136121,
    },

    chapters = {
        {
            chapter = "Orders That Never Came",
            faction = "Horde",
            summary = "The Fallen Hero speaks of a regiment lost waiting for orders. Begin in Stonard and search the southern swamps for the command that never reached him.",
            recap = "The Fallen Hero's grief began with obedience. He led his soldiers toward the Blasted Lands and waited for orders that never came. Dispatch Commander Ruag remembered the lost message, Bengor remembered the ambush, and the Swamp Talker still held the Warchief's command. The truth was bitter: the regiment had been told to withdraw. The order never reached them.",
            quests = {
                { id = 2784, name = "Fall From Grace", npc = "Fallen Hero of the Horde" },
                { id = 2621, name = "The Disgraced One", npc = "Fallen Hero of the Horde" },
                { id = 2622, name = "The Missing Orders", npc = "Dispatch Commander Ruag" },
                { id = 2623, name = "The Swamp Talker", npc = "Bengor" },
            },
        },
        {
            chapter = "A Tale of Sorrow",
            summary = "Return with the lost command, or answer Nethergarde's summons, and hear what Razelikh did to the soldiers who crossed into the Blasted Lands.",
            recap = "From Stonard or Nethergarde, the road ended at the same ghost. The Fallen Hero told what waited beyond the swamp: Razelikh's servants took his fallen regiment, denied them rest, and bound them to stones of demonic power. His regret became an order of its own. If his soldiers could not live, they could still be set free.",
            quests = {
                { id = 2783, name = "Petty Squabbles", npc = "Ambassador Ardalan", faction = "Alliance" },
                { id = 2801, name = "A Tale of Sorrow", npc = "Fallen Hero of the Horde" },
                { id = 2681, name = "The Stones That Bind Us", npc = "Fallen Hero of the Horde" },
            },
        },
        {
            chapter = "The Last Souls",
            summary = "Break the Stones of Binding and seek the last names left to the Fallen Hero: Corporal Thund Splithoof and Lieutenant Kirith.",
            recap = "Breaking the Stones of Binding turned battle into mercy. One by one, the servants of Razelikh, Grol, Allistarj, and Sevine lost their anchors, and the dead soldiers were released from a fate worse than death. Corporal Thund Splithoof appeared long enough to honor the work and leave a token behind. Then one name remained: Lieutenant Kirith. Finding him in the Serpent's Coil revealed the next truth. Razelikh could not be reached until his protections were understood.",
            quests = {
                { id = 2701, name = "Heroes of Old", displayName = "Corporal Thund", npc = "Corporal Thund Splithoof" },
                { id = 2702, name = "Heroes of Old", displayName = "The Splithoof Shard", npc = "Fallen Hero of the Horde" },
                { id = 2721, name = "Kirith", npc = "Fallen Hero of the Horde" },
                { id = 2743, name = "The Cover of Darkness", npc = "Spirit of Kirith" },
            },
        },
        {
            chapter = "Loramus and the Beast's Name",
            summary = "Seek Loramus Thalipedes in Azshara. The demon hunter knows how Razelikh is warded, but he needs a name torn from the deep.",
            recap = "The fight moved from ghostly remorse to demon-hunter craft. Loramus Thalipedes understood Razelikh's ward, but knowledge had to be earned. Lord Arkkoroc gave up the beast's name only after Hetaera's heads were brought from the Bay of Storms, and Loramus used the blood to name the enemy properly. The demon's protections were no longer a mystery. Felbane had to be made.",
            quests = {
                { id = 2744, name = "The Demon Hunter", npc = "Fallen Hero of the Horde" },
                { id = 3141, name = "Loramus", npc = "Loramus Thalipedes" },
                { id = 3508, name = "Breaking the Ward", npc = "Loramus Thalipedes" },
                { id = 3509, name = "The Name of the Beast", displayName = "Lord Arkkoroc", npc = "Loramus Thalipedes" },
                { id = 3510, name = "The Name of the Beast", displayName = "Hetaera", npc = "Lord Arkkoroc" },
                { id = 3511, name = "The Name of the Beast", displayName = "Hetaera's Blood", npc = "Lord Arkkoroc" },
                { id = 3602, name = "Azsharite", npc = "Loramus Thalipedes" },
            },
        },
        {
            chapter = "Felbane",
            summary = "Carry the Azsharite to Galvan the Ancient so Felbane can be forged for the Blasted Lands.",
            recap = "The Azsharite was raw possibility: crystal from a dangerous coast, named by a demon hunter, and meant for a foe normal steel could not touch. Galvan the Ancient gave that possibility form. Felbane was not an heirloom or a trophy. It was a blade for one brutal task: wound Razelikh's protected servants, gather the shattered amulet, and open the way to the demon himself.",
            quests = {
                { id = 3621, name = "The Formation of Felbane", npc = "Loramus Thalipedes" },
                { id = 3625, name = "Enchanted Azsharite Fel Weaponry", npc = "Galvan the Ancient" },
                { id = 3626, name = "Return to the Blasted Lands", npc = "Galvan the Ancient" },
            },
        },
        {
            chapter = "Rakh'likh",
            summary = "With Felbane in hand, follow the last names the Fallen Hero gives you and prepare for the demon's reckoning.",
            recap = "The last climb belonged to the dead as much as the living. Grol the Destroyer, Archmage Allistarj, and Lady Sevine each held a piece of Razelikh's power, and Felbane made them mortal enough to fall. The united ward opened the Rise of the Defiler. There, above the ruined land that had swallowed a Horde regiment, Razelikh finally answered for the souls he chained. The Fallen Hero could not undo his failure, but he saw the demon broken and his soldiers released.",
            quests = {
                { id = 3627, name = "Uniting the Shattered Amulet", npc = "Fallen Hero of the Horde" },
                { id = 3628, name = "You Are Rakh'likh, Demon", npc = "Fallen Hero of the Horde" },
            },
        },
    },
}
