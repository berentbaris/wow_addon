local addonName, SM = ...

-- =============================================================================
-- Classic: Linken's Adventure
-- A lost gnome, a broken sword, and Azeroth's longest wink at Hyrule.
-- =============================================================================

SM.LinkenData = {
    title = "Linken's Adventure",
    description = "A battered raft in Un'Goro holds a few odd belongings: a compass, a map, a key, and a photograph. No one stands nearby to explain them. Only the crater, the wreckage, and the sense that someone lost more than supplies.\n\nFollow the clues from Marshal's Refuge and help piece together what happened to their owner. The trail is strange, old-fashioned, and not eager to explain itself.",
    zone = "Un'Goro Crater / Tanaris / Felwood / Winterspring",
    expansion = "Classic",
    recommendedLevel = { min = 47, max = 56 },
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.30, 0.66, 0.34 },
    icon = 135346,
    portraitDisplayID = 8012,
    adventureCoverTexture = 131863, -- Raid loading screen: shared Classic/TBC adventure cover
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 3844, name = "It's a Secret to Everybody", npc = "A Wrecked Raft", location = "the Marshlands, Un'Goro Crater" },
    startMapID = 78,
    startX = 0.6300,
    startY = 0.6800,

    npcLocations = {
        ["A Wrecked Raft"] = { mapID = 78, x = 0.6300, y = 0.6800, location = "the Marshlands, Un'Goro Crater" },
        ["A Small Pack"] = { mapID = 78, x = 0.6300, y = 0.6900, location = "beside the wrecked raft, Un'Goro Crater" },
        ["Linken"] = { mapID = 78, x = 0.4450, y = 0.0810, location = "Marshal's Refuge, Un'Goro Crater" },
        ["J.D. Collie"] = { mapID = 78, x = 0.4192, y = 0.0270, location = "Marshal's Refuge, Un'Goro Crater" },
        ["Donova Snowden"] = { mapID = 83, x = 0.3100, y = 0.4500, location = "Frostfire Hot Springs, Winterspring" },
        ["Gaeriyan"] = { mapID = 71, x = 0.5300, y = 0.2900, location = "Gadgetzan, Tanaris" },
        ["Eridan Bluewind"] = { mapID = 77, x = 0.5100, y = 0.8200, location = "Emerald Sanctuary, Felwood" },
        ["Aquementas"] = { mapID = 78, x = 0.7100, y = 0.7600, location = "the lakes east of Fire Plume Ridge, Un'Goro Crater" },
        ["Blazerunner"] = { mapID = 78, x = 0.4900, y = 0.5100, location = "Fire Plume Ridge, Un'Goro Crater" },
    },

    npcDisplayIDs = {
        ["Linken"] = 8012,
        ["Donova Snowden"] = 8949,
        ["Gaeriyan"] = 8717,
        ["Eridan Bluewind"] = 9136,
        ["Aquementas"] = 5564,
        ["Blazerunner"] = 1204,
    },

    chapterDisplayIDs = {
        ["A Secret to Everybody"] = 8012,
        ["Linken's Memory"] = 9136,
        ["Aquementas"] = 5564,
        ["It's Dangerous to Go Alone"] = 1204,
    },

    chapterIcons = {
        ["A Secret to Everybody"] = 134269,
        ["Linken's Memory"] = 133738,
        ["Aquementas"] = 135861,
        ["It's Dangerous to Go Alone"] = 135346,
    },

    chapters = {
        {
            chapter = "A Secret to Everybody",
            summary = "Search the wrecked raft in Un'Goro and bring the small pack to Linken at Marshal's Refuge.",
            recap = "The raft in Un'Goro held a compass, a curled map, a lion-headed key, and a photograph of a gnome in green. Linken knew the belongings, but memory would not come with them. The crater had left him with fragments of an errand, a blade without its tale, and the sense that someone had once entrusted him with more than he could remember.",
            quests = {
                { id = 3844, name = "It's a Secret to Everybody", npc = "A Wrecked Raft" },
                { id = 3845, name = "It's a Secret to Everybody", npc = "A Small Pack" },
                { id = 3908, name = "It's a Secret to Everybody", npc = "Linken" },
            },
        },
        {
            chapter = "Linken's Memory",
            summary = "Follow Linken's memory through strange visions and help his sword remember what he cannot.",
            recap = "Linken's memory did not return like a clean answer. It came through strange errands, ghostly meetings, and a sword that changed in flashes of light. Donova, Gaeriyan, and the grave outside Gadgetzan turned the lost gnome's fragments into a rite of recovery. By the time the sword was reforged, Linken still did not fully understand himself, but the road was opening before him again.",
            quests = {
                { id = 3909, name = "The Videre Elixir", npc = "Donova Snowden" },
                { id = 3912, name = "Meet at the Grave", npc = "Donova Snowden" },
                { id = 3913, name = "A Grave Situation", npc = "Gaeriyan", mapID = 71, x = 0.5300, y = 0.2900, location = "the grave outside Gadgetzan, Tanaris" },
                { id = 3914, name = "Linken's Sword", npc = "A Conspicuous Gravestone", mapID = 71, x = 0.5300, y = 0.2900, location = "the grave outside Gadgetzan, Tanaris" },
                { id = 3941, name = "A Gnome's Assistance", npc = "Linken" },
                { id = 3942, name = "Linken's Memory", npc = "J.D. Collie" },
            },
        },
        {
            chapter = "Aquementas",
            summary = "Follow the next names in Linken's tale and prepare the totem he will need.",
            recap = "Felwood gave the search older magic. Eridan Bluewind understood the silver heart Linken had been trying to make and sent you into Winterspring's old forests before Aquementas rose in Un'Goro. The elemental's power became a silver totem, the key to stripping away the final guardian's protection. The errand had strange humor about it, but the ritual was real.",
            quests = {
                { id = 4084, name = "Silver Heart", npc = "Eridan Bluewind" },
                { id = 4005, name = "Aquementas", npc = "Eridan Bluewind" },
                { id = 3961, name = "Linken's Adventure", npc = "J.D. Collie" },
            },
        },
        {
            chapter = "It's Dangerous to Go Alone",
            summary = "Carry the Silver Totem into Linken's final trial and see whether the old adventure can be finished.",
            recap = "At Fire Plume Ridge, the strange tools finally proved their worth. The Silver Totem stripped Blazerunner's shield, the sword found its purpose, and the Golden Flame was carried back to Marshal's Refuge. Linken's memory was still imperfect, but the road had given him a shape to follow: hero, blade, flame, and a companion brave enough to see it done.",
            quests = {
                { id = 3962, name = "It's Dangerous to Go Alone", npc = "Linken" },
            },
        },
    },
}
