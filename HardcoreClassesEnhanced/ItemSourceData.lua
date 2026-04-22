----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Item Source Data
--
-- Curated item ID lists for item-source challenge checks:
--   Renegade  → quest_rewards (deny-list: these items are forbidden)
--   Off-the-shelf → vendor_items (allow-list: only these are permitted)
--   Partisan  → uses EXCLUSION: items not on vendor/quest/crafted lists
--              are presumed looted (no standalone looted_gear list needed)
--
-- Each table maps itemID → provenance string.  The checking logic in
-- ChallengeCheck.lua only tests key existence; the value is a paper
-- trail for the human curator.
--
-- Population status:
--   These are STARTER SEEDS from well-known Classic WoW items.  Full
--   curation is deferred to Milestone 7 where Wowhead Classic DB
--   filters (source: "Quest" / "Vendor") will generate exhaustive lists.
--
-- How to expand these lists (Milestone 7):
--   Quest rewards:
--     https://www.wowhead.com/classic/items?filter=128;1;0
--     (Source = Quest, grouped by zone/level range)
--   Vendor items:
--     https://www.wowhead.com/classic/items?filter=128;5;0
--     (Source = Vendor, grouped by NPC / item type)
--
-- All IDs are WoW Classic 1.13.x stable item IDs (same as vanilla).
----------------------------------------------------------------------

HCE = HCE or {}
HCE.CuratedItems = HCE.CuratedItems or {}
HCE.CuratedComplete = HCE.CuratedComplete or {}

local C = HCE.CuratedItems
local COMPLETE = HCE.CuratedComplete

----------------------------------------------------------------------
-- Helper
----------------------------------------------------------------------

local function fill(tbl, entries)
    for _, pair in ipairs(entries) do
        tbl[pair[1]] = pair[2] or true
    end
end

----------------------------------------------------------------------
-- Ensure the item-source tables exist (ChallengeCheck.lua creates
-- them too, but we load after ChallengeCheck so either order works)
----------------------------------------------------------------------

C.quest_rewards = C.quest_rewards or {}
C.vendor_items  = C.vendor_items  or {}
C.looted_gear   = C.looted_gear   or {}  -- kept for API compat; Partisan uses exclusion now

----------------------------------------------------------------------
-- QUEST REWARD ITEMS
--
-- Items awarded by quest completion in WoW Classic.  Used by the
-- Renegade challenge ("cannot equip quest reward gear").
--
-- Sourced from Wowhead Classic quest reward filters and cross-checked
-- against well-known levelling quest chains.
----------------------------------------------------------------------

fill(C.quest_rewards, {
    -- === Westfall (Human 10-20) ===
    { 2041,  "Tunic of Westfall — The Defias Brotherhood (Westfall finale)" },
    { 2042,  "Staff of Westfall — The Defias Brotherhood (Westfall finale)" },
    { 2037,  "Dusty Mining Gloves — Oh Brother... (Deadmines prequest)" },
    { 2074,  "Solid Shortblade — Red Silk Bandanas (Westfall)" },
    { 1640,  "Watchman Pauldrons — The People's Militia (Westfall 3/3)" },

    -- === Darkshore / Auberdine (Night Elf 10-20) ===
    { 5399,  "Bands of Serra'kis — Blackfathom Deeps quest" },
    { 5400,  "Gravestone Scepter — Blackfathom Villainy" },

    -- === The Barrens (Horde 10-25) ===
    { 5279,  "Harpy Skinner — Harpy Raiders (Barrens)" },
    { 5322,  "Demolition Hammer — Samophlange (Barrens)" },
    { 6505,  "Crescent of Forlorn Spirits — Consumed by Hatred (Barrens)" },

    -- === Redridge Mountains (Alliance 15-25) ===
    { 3562,  "Belt of the Gladiator — Blackrock Bounty (Redridge)" },

    -- === Duskwood (Alliance 20-30) ===
    { 4534,  "Sparkmetal Coif — The Legend of Stalvan (Duskwood finale)" },
    { 2059,  "Sentry Cloak — The Night Watch (Duskwood)" },

    -- === Stonetalon / Ashenvale (Horde 18-30) ===
    { 5248,  "Flash Rifle — Gerenzo Wrenchwhistle (Stonetalon)" },
    { 5250,  "Charred Leather Tunic — Boulderslide Ravine (Stonetalon)" },

    -- === Hillsbrad / Arathi (20-35) ===
    { 3755,  "Fish Gutter — Crushridge Warmongers (Hillsbrad)" },
    { 4197,  "Break of Dawn — Battle of Hillsbrad (finale)" },

    -- === Stranglethorn Vale (30-45) ===
    { 4113,  "Nimbly Handled — Investigate the Camp (STV)" },
    { 4114,  "Darktide Cape — The Bloodsail Buccaneers (STV)" },
    { 2163,  "Dull Blade of the Troll — Headhunting (STV)" },

    -- === Scarlet Monastery quest rewards ===
    { 6802,  "Sword of Omen — In the Name of the Light" },
    { 6803,  "Prophetic Cane — In the Name of the Light" },
    { 6804,  "Windweaver Staff — In the Name of the Light" },

    -- === Badlands / Uldaman (35-45) ===
    { 9626,  "Shaleskin Cape — Badlands Reagent Run" },

    -- === Tanaris / Zul'Farrak (40-50) ===
    { 9643,  "Optomatic Deflector — Zul'Farrak quest chain" },

    -- === Sunken Temple (50-55) ===
    { 10847, "Dragon's Eye — The Temple of Atal'Hakkar" },

    -- === Searing Gorge / Burning Steppes (45-55) ===
    { 11866, "Smoking Heart of the Mountain — Incendius (BRD prequest)" },

    -- === Winterspring / Felwood (50-58) ===
    { 15706, "Hunt Tracker Blade — Winterfall Activity (Winterspring)" },

    -- === Western / Eastern Plaguelands (50-60) ===
    { 13209, "Seal of the Dawn — Argent Dawn quest chain" },
    { 15411, "Mark of Resolution — Heroes of Darrowshire (E. Plaguelands)" },

    -- === Class quests (multi-class) ===
    { 6504,  "Weathered Buckler — Warrior class quest (Stormwind)" },
    { 15443, "Vile Protector — Priest class quest (lv 50)" },

    -- === Maraudon quest rewards ===
    { 17710, "Charstone Dirk — Maraudon quest chain" },
    { 17711, "Zealot's Robe — Maraudon quest chain" },

    -- === Blackrock Depths / LBRS quest rewards ===
    { 11865, "Commander's Crest — Marshal Windsor (BRD)" },
    { 12113, "Foresight Girdle — General Drakkisath's Command (LBRS)" },

    -- === Dire Maul quest rewards ===
    { 18420, "Bonecreeper Stylus — Dire Maul tribute" },

    -- === Scholomance / Stratholme quest rewards ===
    { 14023, "Barovian Family Sword — Scholomance quest chain" },
    { 15853, "Windreaper — Ramstein quest chain (Stratholme)" },

    -- === Onyxia attunement chain ===
    { 15858, "Dragonslayer's Signet — Drakefire Amulet chain" },

    -- More quest reward IDs to be added in Milestone 7 via Wowhead
    -- Classic source-filter export.
})
-- NOT marked complete — these are a seed, not exhaustive.

----------------------------------------------------------------------
-- VENDOR-SOLD ITEMS
--
-- Items purchasable from NPC vendors in WoW Classic.  Used by the
-- Off-the-shelf challenge ("can only equip vendor gear").
--
-- NOTE: White/grey (quality 0-1) items auto-pass the Off-the-shelf
-- check since nearly all vendor gear is white quality.  This list is
-- specifically for GREEN+ quality items sold by vendors:
--   - Limited-supply greens from weapon/armor vendors
--   - PvP reward vendors (honor quartermasters)
--   - Reputation vendors
--   - Speciality NPC vendors
----------------------------------------------------------------------

fill(C.vendor_items, {
    -- === Basic white weapons (weapon merchants in every major city) ===
    -- White items auto-pass, so these are here for completeness only.
    -- The Off-the-shelf logic already handles quality 0-1 gracefully.

    -- === Green+ quality vendor items (limited supply / special NPCs) ===

    -- Stormwind / Ironforge limited-supply vendors
    { 4778,  "Derby Felt Hat — limited supply, Ironforge vendor" },
    { 4788,  "Armor of the Fang — limited supply vendor" },
    { 4790,  "Inferno Cloak — limited supply vendor" },

    -- Orgrimmar / Thunder Bluff / UC vendors
    { 4794,  "Wolf Rider's Wristbands — limited supply vendor" },
    { 4817,  "Blessed Claymore — limited supply vendor" },

    -- Booty Bay vendors (neutral)
    { 4827,  "Wizard's Belt — limited supply, Booty Bay" },
    { 5772,  "Pattern: Red Woolen Bag — vendor (not equippable, skip)" },

    -- Faction vendors with green+ gear
    { 19505, "Warsong Gulch vendor reward (Exalted)" },
    { 19506, "Warsong Gulch vendor reward (Exalted)" },
    { 19579, "Arathi Basin vendor reward" },
    { 19580, "Arathi Basin vendor reward" },

    -- Argent Dawn reputation vendor
    { 22401, "Blessed Sunfruit — Argent Dawn vendor (consumable)" },

    -- Timbermaw Hold reputation vendor
    { 21326, "Defender of the Timbermaw — Timbermaw Hold Exalted" },

    -- Thorium Brotherhood reputation vendor
    { 17051, "Sulfuron Hammer — Thorium Brotherhood (crafted/vendor)" },

    -- Cenarion Circle reputation vendor
    { 22209, "Plans/Pattern from Cenarion rep vendor" },

    -- Winterspring vendor (Everlook)
    { 19227, "Ace of Warlords — vendor shuffle item" },

    -- More vendor IDs to be added in Milestone 7 via Wowhead Classic
    -- source-filter export.
})
-- NOT marked complete — these are a seed, not exhaustive.

----------------------------------------------------------------------
-- COMBINED SOURCE CHECKER
--
-- Utility function used by the Partisan challenge (exclusion approach).
-- Checks whether an item ID appears on ANY known non-loot source list.
-- Returns (isKnownSource, sourceName) so callers can report what source
-- cleared the item.
----------------------------------------------------------------------

function HCE.CheckItemSource(itemID)
    if not itemID then return false, nil end

    -- 1. Vendor items
    if C.vendor_items and C.vendor_items[itemID] then
        return true, "vendor"
    end

    -- 2. Quest rewards
    if C.quest_rewards and C.quest_rewards[itemID] then
        return true, "quest reward"
    end

    -- 3. Profession-crafted items (from SelfFoundCheck)
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.CraftedByProfession then
        for profName, list in pairs(HCE.SelfFoundCheck.CraftedByProfession) do
            if list[itemID] then
                return true, profName .. "-crafted"
            end
        end
    end

    return false, nil
end

----------------------------------------------------------------------
-- SOURCE COMPLETENESS
--
-- Reports whether all non-loot source lists have been fully curated.
-- Used by the Partisan checker to decide between UNCHECKED and FAIL
-- when an item isn't found on any known list.
----------------------------------------------------------------------

function HCE.AllSourceListsComplete()
    return COMPLETE["quest_rewards"]
       and COMPLETE["vendor_items"]
       -- Crafted lists from SelfFoundCheck are per-profession;
       -- we'd need all of them marked complete.  For now, false.
       and false
end

----------------------------------------------------------------------
-- ITEM SOURCE SLASH COMMAND HELPER
--
-- Prints a per-slot breakdown of equipped items and their detected
-- source (vendor / quest reward / crafted / unknown).
----------------------------------------------------------------------

local SLOT_NAMES = {
    [1]  = "Head",     [2]  = "Neck",     [3]  = "Shoulder",
    [5]  = "Chest",    [6]  = "Waist",    [7]  = "Legs",
    [8]  = "Feet",     [9]  = "Wrist",    [10] = "Hands",
    [11] = "Ring 1",   [12] = "Ring 2",   [13] = "Trinket 1",
    [14] = "Trinket 2",[15] = "Back",     [16] = "Main Hand",
    [17] = "Off Hand", [18] = "Ranged",   [19] = "Tabard",
}

local GEAR_SLOTS = {
    1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
}

local QUALITY_LABELS = {
    [0] = "poor", [1] = "common", [2] = "uncommon",
    [3] = "rare", [4] = "epic",   [5] = "legendary",
}

function HCE.PrintItemSources()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected.")
        return
    end

    HCE.Print("Item source breakdown (equipped gear):")

    local checked, unknown, vendorN, questN, craftedN = 0, 0, 0, 0, 0

    for _, slotID in ipairs(GEAR_SLOTS) do
        local itemID = GetInventoryItemID("player", slotID)
        if itemID then
            checked = checked + 1
            local name, _, quality = GetItemInfo(itemID)
            name = name or ("item:" .. itemID)
            quality = quality or 0
            local qLabel = QUALITY_LABELS[quality] or ("q" .. quality)
            local slotLabel = SLOT_NAMES[slotID] or ("Slot " .. slotID)

            if quality <= 1 then
                -- White/grey auto-passes all item-source challenges
                DEFAULT_CHAT_FRAME:AddMessage(
                    "  " .. slotLabel .. ": |cff888888" .. name .. " (" .. qLabel .. ")|r — basic item"
                )
            else
                local found, source = HCE.CheckItemSource(itemID)
                if found then
                    if source == "vendor" then vendorN = vendorN + 1
                    elseif source == "quest reward" then questN = questN + 1
                    else craftedN = craftedN + 1 end
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "  " .. slotLabel .. ": |cff00ff00" .. name .. "|r — " .. source
                    )
                else
                    unknown = unknown + 1
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "  " .. slotLabel .. ": |cffffaa33" .. name .. " (" .. qLabel .. ")|r — source unknown"
                    )
                end
            end
        end
    end

    if checked == 0 then
        HCE.Print("  No gear equipped.")
    else
        HCE.Print(string.format(
            "  Summary: %d items checked — %d vendor, %d quest, %d crafted, %d unknown",
            checked, vendorN, questN, craftedN, unknown
        ))
    end
end
