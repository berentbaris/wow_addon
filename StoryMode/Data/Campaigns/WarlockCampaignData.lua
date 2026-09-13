local addonName, SM = ...

-- =============================================================================
-- Legion Warlock Campaign: Council of the Black Harvest
-- Class Order Hall + Artifact Weapons + Class Mount
-- =============================================================================

SM.WarlockCampaignData = {
    title = "Netherlord's Campaign",
    achievementName = "The Netherlord's Campaign",
    achievements = { 42281, 10746, 10994, 11171, 11223 },
    description = "From Dreadscar Rift, a pocket of the Twisting Nether claimed by force, the Council of the Black Harvest commands demons to fight demons. It is dangerous work, which is exactly why warlocks are suited to it.\n\nAs Netherlord, rebuild the council, bargain with powers that should not be trusted, and prove that a stolen weapon can still be aimed.",
    zone = "Dreadscar Rift / Broken Isles",
    expansion = "Legion",
    class = "WARLOCK",
    color = { 0.53, 0.53, 0.93 },  -- Warlock purple
    adventureGuideInstanceName = "Tomb of Sargeras",

    startQuest = { id = 40716, name = "The Sixth", npc = "Ritssyn Flamescowl", location = "Dalaran" },
    startMapID = 627,
    startX = 0.5700,
    startY = 0.6400,

    npcLocations = {
        ["Revil Kost"] = { mapID = 47, x = 0.7740, y = 0.3620, location = "Duskwood" },
        ["Ritssyn Flamescowl"]          = { mapID = 717, x = 0.5800, y = 0.3500 },
        ["Calydus"]                     = { mapID = 717, x = 0.3760, y = 0.3160 },
        ["Gakin the Darkbinder"]        = { mapID = 717, x = 0.6660, y = 0.4600 },
        ["Kira Iresoul"]                = { mapID = 630, x = 0.6080, y = 0.3060 },
        ["Jubeka Shadowbreaker"]        = { mapID = 717, x = 0.5600, y = 0.3500 },
        ["Shinfel Blightsworn"]         = { mapID = 717, x = 0.6000, y = 0.3600 },
        ["Lulubelle Fizzlebang"]        = { mapID = 634, x = 0.5480, y = 0.3920 },
        ["Ernest Carlisle"]             = { mapID = 641, x = 0.3920, y = 0.6260 },
        ["Zinnin Smythe"]               = { mapID = 717, x = 0.5800, y = 0.3700 },
        ["Kanrethad Ebonlocke"]         = { mapID = 646, x = 0.5580, y = 0.3440 },
        ["Mor'zul Bloodbringer"]        = { mapID = 717, x = 0.3540, y = 0.3820 },
        ["Elithys Firestorm"]           = { mapID = 646, x = 0.4380, y = 0.6320 },
        ["Maiev Shadowsong"]            = { mapID = 646, x = 0.4460, y = 0.6340 },
    },

    npcDisplayIDs = {
        ["Ritssyn Flamescowl"]          = 65975,
        ["Calydus"]                     = 64476,
        ["Gakin the Darkbinder"]        = 4867,
        ["Kira Iresoul"]                = 68731,
        ["Jubeka Shadowbreaker"]        = 46572,
        ["Shinfel Blightsworn"]         = 65979,
        ["Lulubelle Fizzlebang"]        = 67425,
        ["Ernest Carlisle"]             = 68720,
        ["Zinnin Smythe"]               = 65985,
        ["Kanrethad Ebonlocke"]         = 46573,
        ["Mor'zul Bloodbringer"]        = 14565,
    },

    chapters = {
        {
            chapter = "The Sixth",
            summary = "Ritssyn Flamescowl needs a sixth member for the Council of the Black Harvest. You are chosen — but the seat comes with a price.",
            recap = "Ritssyn Flamescowl appeared in Dalaran with a proposition — the Council of the Black Harvest needed a sixth member, and you had been chosen. The Council operated from Dreadscar Rift, a pocket of the Twisting Nether they had ripped from demonic control and claimed as their own. You proved your worth, claimed an artifact weapon steeped in dark power, and took your seat on the Council. Calydus — a demon bound to serve the warlocks — helped establish the Rift as your base of operations.",
            quests = {
                { id = 40716, name = "The Sixth",                   npc = "Ritssyn Flamescowl" },
                { id = 40729, name = "The New Blood",                npc = "Ritssyn Flamescowl" },
                { id = 40684, name = "The Tome of Blighted Implements", npc = "Calydus" },
                { id = 40731, name = "The Heart of the Dreadscar",   npc = "Calydus" },
                { id = 40823, name = "Rebuilding the Council",       npc = "Calydus" },
                { id = 40824, name = "The Path of the Dreadscar",    npc = "Ritssyn Flamescowl" },
                { id = 42608, name = "Rise, Champions",              npc = "Calydus" },
            },
        },

        {
            chapter = "An Unlikely Ally",
            summary = "Investigate bloodstone corruption in Azsuna. Kira Iresoul proves her worth as the Council recruits new champions.",
            recap = "Gakin the Darkbinder dispatched troops while Ritssyn uncovered troubling archives — bloodstones were appearing across the Broken Isles, corrupting the land with fel energy. You traveled to Azsuna where Kira Iresoul was already investigating. Together you traced the bloodstone bandits to their source, tested a theory on the stones' hunger for blood, and repaid the debt with fire. Jubeka Shadowbreaker and Zinnin Smythe joined the Council as champions. A daring rescue followed — the Council looked after its own.",
            quests = {
                { id = 42603, name = "Information at Any Cost",      npc = "Gakin the Darkbinder" },
                { id = 41797, name = "Recruiting The Troops",        npc = "Gakin the Darkbinder" },
                { id = 42602, name = "Troops in the Field",          npc = "Gakin the Darkbinder" },
                { id = 42097, name = "Searching the Archives",       npc = "Ritssyn Flamescowl" },
                { id = 41759, name = "An Unlikely Ally",             npc = "Ritssyn Flamescowl" },
                { id = 39179, name = "Bloodstone Bandit",            npc = "Kira Iresoul" },
                { id = 39389, name = "It Hungers for Blood",         npc = "Kira Iresoul" },
                { id = 39142, name = "Testing a Theory",             npc = "Kira Iresoul" },
                { id = 40218, name = "Debt Repaid",                  npc = "Kira Iresoul" },
                { id = 41767, name = "A Daring Rescue",              npc = "Ritssyn Flamescowl" },
                { id = 41753, name = "Champion: Jubeka Shadowbreaker", npc = "Jubeka Shadowbreaker" },
                { id = 41752, name = "Champion: Zinnin Smythe",      npc = "Zinnin Smythe" },
            },
        },

        {
            chapter = "One Who's Worthy",
            summary = "Empower the Council's soul reserves. Dungeon delves, mad alchemists, and the question: who is truly worthy of power?",
            recap = "The Council needed more power — souls to fuel the Dreadscar Rift's defenses. You retrieved an unclaimed soul from Black Rook Hold, built a soul beacon to gather energy, and recruited Ernest Carlisle — a mad alchemist who turned goat herding into an art form. Shinfel Blightsworn and Kira Iresoul earned their champion marks, and the Council debated who among them was truly worthy of the power they wielded. The Vault of the Wardens provided the answer: power belonged to those who could take it and hold it.",
            quests = {
                { id = 42098, name = "Black Rook Hold: An Unclaimed Soul", npc = "Ritssyn Flamescowl" },
                { id = 41768, name = "Soul Beacon",                  npc = "Ritssyn Flamescowl" },
                { id = 41769, name = "Mad Ernie the Alchemist",      npc = "Ritssyn Flamescowl" },
                { id = 41781, name = "Herding Goats",                npc = "Ernest Carlisle" },
                { id = 41780, name = "Doom and Gloom",               npc = "Ernest Carlisle" },
                { id = 41784, name = "Borrowed Time",                npc = "Ernest Carlisle" },
                { id = 41754, name = "Champion: Shinfel Blightsworn", npc = "Shinfel Blightsworn" },
                { id = 41751, name = "Champion: Kira Iresoul",       npc = "Kira Iresoul" },
                { id = 42102, name = "One Who's Worthy",             npc = "Ritssyn Flamescowl" },
                { id = 42660, name = "Vault of the Wardens: Matters of the Heart", npc = "Kira Iresoul" },
            },
        },

        {
            chapter = "Selecting a Sixth",
            summary = "Find Lulubelle Fizzlebang in Stormheim, coerce a demon confession, and complete the Council's final selection.",
            recap = "The Council's sixth seat remained contested — and the answer lay with Lulubelle Fizzlebang, a gnome warlock with more ambition than common sense. You found her in Stormheim, coerced a confession from a captured demon, and cleaned up someone else's mess along the way. Lulubelle proved her worth through sheer stubborn brilliance, and the Summoning of the Sisters sealed the pact. With all six members chosen and your weapon forged to its full dark potential, the Council of the Black Harvest was complete. You were named Netherlord.",
            quests = {
                { id = 41785, name = "Finding Fizzlebang",           npc = "Ritssyn Flamescowl" },
                { id = 41788, name = "Coercing a Confession",        npc = "Lulubelle Fizzlebang" },
                { id = 41787, name = "Someone Else's Mess",          npc = "Lulubelle Fizzlebang" },
                { id = 41793, name = "Lulubelle on Loan",            npc = "Lulubelle Fizzlebang" },
                { id = 41755, name = "Champion: Lulubelle Fizzlebang", npc = "Lulubelle Fizzlebang" },
                { id = 41795, name = "Summoning the Sisters",        npc = "Ritssyn Flamescowl" },
                { id = 41796, name = "Selecting a Sixth",            npc = "Ritssyn Flamescowl" },
                { id = 43414, name = "A Hero's Weapon",              npc = "Ritssyn Flamescowl" },
            },
        },

        {
            chapter = "The Wrathsteed of Xoroth",
            summary = "On the Broken Shore, rescue Kanrethad Ebonlocke from imprisonment and earn the Netherlord's Chaotic Wrathsteed.",
            recap = "The Broken Shore held a prisoner the Council had long sought — Kanrethad Ebonlocke, the warlock who had tried to bind a pit lord and paid the price with his freedom. Shinfel and Jubeka led the search while you culled the Legion cult guarding him and contained the fel crystals keeping him sealed. Kanrethad was freed, scarred but unbroken, and joined as your newest champion. Then came the final rite — Mor'zul Bloodbringer opened a portal to Xoroth, where a wrathsteed of chaotic fire waited. You broke its will and bent it to yours, and the Netherlord's Chaotic Wrathsteed carried you from the flames.",
            quests = {
                { id = 47137, name = "Champions of Legionfall",     npc = "Maiev Shadowsong" },
                { id = 45021, name = "Answers Unknown",              npc = "Shinfel Blightsworn" },
                { id = 45024, name = "Cult Culling",                 npc = "Jubeka Shadowbreaker" },
                { id = 45025, name = "Stealing the Source of Power", npc = "Jubeka Shadowbreaker" },
                { id = 45028, name = "The Fate of Kanrethad",        npc = "Jubeka Shadowbreaker" },
                { id = 46020, name = "Crystal Containment",          npc = "Jubeka Shadowbreaker" },
                { id = 46047, name = "Champion: Kanrethad Ebonlocke", npc = "Kanrethad Ebonlocke" },
                { id = 46237, name = "Bloodbringer's Missive",       npc = "Elithys Firestorm" },
                { id = 46239, name = "Fel to the Core",              npc = "Mor'zul Bloodbringer" },
                { id = 46240, name = "Give Me Fuel, Give Me Fire",   npc = "Mor'zul Bloodbringer" },
                { id = 46243, name = "The Wrathsteed of Xoroth",     npc = "Mor'zul Bloodbringer" },
            },
        },

        {
            chapter = "Ulthalesh, the Deadwind Harvester",
            summary = "Seek Ulthalesh, a scythe that reaps souls from the living and binds them in eternal torment.",
            recap = "Calydus pointed you toward Ulthalesh — the Deadwind Harvester, a scythe of terrible power that had reaped souls for millennia. You followed the curse through Deadwind Pass, where the Dark Riders still haunted the roads. In their shadowed lair, you tore Ulthalesh from their grasp. The scythe's whispers joined the chorus in your mind — a weapon that was never truly silent.",
            quests = {
                { id = 40931, name = "Following the Curse",          npc = "Revil Kost" },
            },
        },
        {
            chapter = "Skull of the Man'ari",
            summary = "Recover the Skull of the Man'ari, a demonic focus of immense summoning power used by the eredar lords.",
            recap = "Calydus spoke of the Skull of the Man'ari — an eredar artifact of staggering summoning power. The ritual reagents alone were dangerous enough to kill a lesser warlock. You gathered them, performed the summoning, and wrested the Skull from the eredar lord who guarded it. The Skull's eyes glowed with malevolent intelligence, as if the demon trapped within was already planning its next move.",
            quests = {
                { id = 42128, name = "Ritual Reagents",              npc = "Calydus" },
            },
        },
        {
            chapter = "Scepter of Sargeras",
            summary = "Find the Scepter of Sargeras, a weapon that can tear rifts between worlds with a single strike.",
            recap = "Calydus revealed the location of the Scepter of Sargeras — a weapon capable of tearing holes between dimensions, wielded by the Dark Titan's own lieutenants. You found it sealed in a vault warded against mortal hands. But a warlock's hands were never quite mortal. You broke the wards, claimed the Scepter, and felt the fabric of reality shudder around you. The power to break worlds was now in your grip.",
            quests = {
                { id = 43100, name = "Finding the Scepter",          npc = "Calydus" },
            },
        },
    },
}
