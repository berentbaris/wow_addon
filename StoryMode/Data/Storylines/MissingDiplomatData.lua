local addonName, SM = ...

-- =============================================================================
-- Classic: The Missing Diplomat
-- Stormwind intrigue, Defias evidence, Menethil, Theramore, and Jaina.
-- =============================================================================

SM.MissingDiplomatData = {
    title = "The Missing Diplomat",
    description = "Thomas has been asked to find an adventurer for Bishop DeLavey in Stormwind Keep. The bishop will not speak of the matter openly, only that discretion matters and the kingdom may have need of you.\n\nBegin in Stormwind and follow a quiet trail of favors, contacts, and rumors. What starts as a missing man soon points beyond a simple disappearance.",
    zone = "Stormwind / Duskwood / Wetlands / Dustwallow Marsh",
    expansion = "Classic",
    recommendedLevel = { min = 28, max = 38 },
    faction = "Alliance",
    gameVersions = { classicEra = true, tbc = true },
    achievements = {},
    color = { 0.22, 0.42, 0.78 },
    icon = 134328,
    adventureCoverTexture = 131870, -- Stockade: closest Classic loading screen for Stormwind intrigue and Defias fallout
    adventureCoverIsLoadingScreen = true,

    startQuest = { id = 1274, name = "The Missing Diplomat", npc = "Thomas", location = "Cathedral Square, Stormwind" },
    startMapID = 84,
    startX = 0.5000,
    startY = 0.4600,

    npcLocations = {
        ["Thomas"] = { mapID = 84, x = 0.4168, y = 0.3183, location = "Cathedral Square, Stormwind" },
        ["Bishop DeLavey"] = { mapID = 84, x = 0.7830, y = 0.2545, location = "Stormwind Keep" },
        ["Jorgen"] = { mapID = 84, x = 0.7300, y = 0.7800, location = "the Valley of Heroes, Stormwind" },
        ["Elling Trias"] = { mapID = 84, x = 0.5991, y = 0.6418, location = "Trias' Cheese, Trade District, Stormwind" },
        ["Watcher Backus"] = { mapID = 47, x = 0.7200, y = 0.3500, location = "the north road out of Darkshire, Duskwood" },
        ["Defias Docket"] = { mapID = 47, x = 0.2400, y = 0.7200, location = "the small house at Addle's Stead, Duskwood" },
        ["Dashel Stonefist"] = { mapID = 84, x = 0.7053, y = 0.4488, location = "Old Town, Stormwind" },
        ["Mikhail"] = { mapID = 56, x = 0.1000, y = 0.6000, location = "the Deepwater Tavern, Menethil Harbor" },
        ["Tapoke \"Slim\" Jahn"] = { mapID = 56, x = 0.1000, y = 0.6000, location = "the Deepwater Tavern, Menethil Harbor" },
        ["Commander Samaul"] = { mapID = 70, x = 0.6700, y = 0.4700, location = "Foothold Citadel, Theramore" },
        ["Archmage Tervosh"] = { mapID = 70, x = 0.6640, y = 0.4920, location = "Jaina's tower, Theramore Isle" },
        ["Private Hendel"] = { mapID = 70, x = 0.4500, y = 0.2500, location = "the tents northwest of Theramore" },
        ["Lady Jaina Proudmoore"] = { mapID = 70, x = 0.6600, y = 0.4900, location = "Theramore Isle" },
    },

    npcDisplayIDs = {
        ["Thomas"] = 262,
        ["Bishop DeLavey"] = 2961,
        ["Jorgen"] = 4469,
        ["Elling Trias"] = 3246,
        ["Watcher Backus"] = 2380,
        ["Dashel Stonefist"] = 3238,
        ["Mikhail"] = 2964,
        ["Tapoke \"Slim\" Jahn"] = 2963,
        ["Commander Samaul"] = 2965,
        ["Archmage Tervosh"] = 2969,
        ["Private Hendel"] = 2967,
        ["Lady Jaina Proudmoore"] = 30867,
    },

    chapterDisplayIDs = {
        ["A Discreet Matter"] = 2961,
        ["The Defias Docket"] = 2380,
        ["Fist"] = 3238,
        ["Slim's Confession"] = 2963,
        ["Hendel"] = 3387,
    },

    chapterIcons = {
        ["A Discreet Matter"] = 134328,
        ["The Defias Docket"] = 134943,
        ["Fist"] = 132938,
        ["Slim's Confession"] = 133471,
        ["Hendel"] = 132349,
    },

    chapters = {
        {
            chapter = "A Discreet Matter",
            summary = "Thomas sends you quietly to Bishop DeLavey in Stormwind Keep, where a missing envoy has become a private matter.",
            recap = "The investigation began with secrecy, not ceremony. Thomas found you near the Cathedral and sent you to Bishop DeLavey, who admitted that a diplomat sent to meet Jaina Proudmoore had disappeared. DeLavey suspected the Defias but could not prove it, so he pulled in people outside the usual channels: Jorgen by the Valley of Heroes, then Elling Trias above the cheese shop. The case had already moved from church business to spy work.",
            quests = {
                { id = 1274, name = "The Missing Diplomat", displayName = "Bishop DeLavey", npc = "Thomas" },
                { id = 1241, name = "The Missing Diplomat", displayName = "Jorgen", npc = "Bishop DeLavey" },
                { id = 1242, name = "The Missing Diplomat", displayName = "Elling Trias", npc = "Jorgen" },
                { id = 1243, name = "The Missing Diplomat", displayName = "Watcher Backus", npc = "Elling Trias" },
            },
        },
        {
            chapter = "The Defias Docket",
            summary = "Follow Watcher Backus to Addle's Stead and bring the Defias docket back to Trias.",
            recap = "Duskwood supplied the first hard evidence. Watcher Backus remembered Defias agents gathering around Addle's Stead, and the small farmhouse held the proof: a docket official enough to worry even a veteran watchman. Backus sent it back to Trias, and Trias saw the shape of the next lead in one familiar word: Fist.",
            quests = {
                { id = 1244, name = "The Missing Diplomat", displayName = "Addle's Stead", npc = "Watcher Backus" },
                { id = 1245, name = "The Missing Diplomat", displayName = "Back to Trias", npc = "Watcher Backus" },
            },
        },
        {
            chapter = "Fist",
            summary = "Trias sends you into Old Town after Dashel Stonefist, whose answers pull the matter beyond Stormwind.",
            recap = "Dashel Stonefist was exactly the sort of contact Trias expected: violent, useful, and unwilling to talk until persuaded. Once subdued, he admitted that his part had ended when the first plan failed. The backup plan involved someone from Menethil Harbor, a man called Slim. Trias knew enough to send you across the sea before the trail went cold.",
            quests = {
                { id = 1246, name = "The Missing Diplomat", displayName = "Find Dashel", npc = "Elling Trias" },
                { id = 1447, name = "The Missing Diplomat", displayName = "Subdue Dashel", npc = "Dashel Stonefist" },
                { id = 1247, name = "The Missing Diplomat", displayName = "Dashel's Lead", npc = "Dashel Stonefist" },
                { id = 1248, name = "The Missing Diplomat", displayName = "Menethil", npc = "Elling Trias" },
            },
        },
        {
            chapter = "Slim's Confession",
            summary = "At the Deepwater Tavern, follow the man who listens too closely and make Tapoke Jahn tell what he knows.",
            recap = "Menethil Harbor made the conspiracy plain. Mikhail noticed a listener by the tavern door, and Tapoke \"Slim\" Jahn tried to run before the questions reached him. When he broke, the case changed completely. The Defias had not taken a mere diplomat. They had taken Stormwind's king, and Slim had helped place Hendel aboard the king's ship. Mikhail could only send you to Theramore before the trail disappeared into military silence.",
            quests = {
                { id = 1249, name = "The Missing Diplomat", displayName = "Find Slim", npc = "Mikhail" },
                { id = 1250, name = "The Missing Diplomat", displayName = "Slim's Confession", npc = "Tapoke \"Slim\" Jahn" },
                { id = 1264, name = "The Missing Diplomat", displayName = "Commander Samaul", npc = "Mikhail" },
            },
        },
        {
            chapter = "Hendel",
            summary = "In Theramore, find Private Hendel near Sentry Point and bring him in alive if you can.",
            recap = "Theramore brought the mystery into the open without solving it. Commander Samaul sent you to Sentry Point, Archmage Tervosh guided you to Private Hendel, and Hendel's guard post became the last fight of the trail. When Hendel yielded, Jaina Proudmoore appeared to take charge of the prisoner and thank you quietly for services that could not be publicly named. You had exposed the kidnapping of King Varian Wrynn, but the larger wound remained open: the king was still missing, and someone powerful enough to use the Defias had not yet shown their face.",
            quests = {
                { id = 1265, name = "The Missing Diplomat", displayName = "Sentry Point", npc = "Commander Samaul" },
                { id = 1266, name = "The Missing Diplomat", displayName = "Private Hendel", npc = "Archmage Tervosh" },
                { id = 1324, name = "The Missing Diplomat", npc = "Private Hendel" },
                { id = 1267, name = "The Missing Diplomat", displayName = "Jaina Proudmoore", npc = "Archmage Tervosh" },
            },
        },
    },
}
