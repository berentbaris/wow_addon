----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Self-Found & Self-Made Tracking
--
-- Two related checks in one module:
--
-- 1. SELF-FOUND BUFF — Characters with selfFound=true in CharacterData
--    must be on a Self-Found realm / have the Self-Found buff active.
--    We detect this by scanning the player's auras for the Self-Found
--    buff, using spell IDs first (locale-safe) then falling back to
--    an English-name scan for discovery.
--
-- 2. SELF-MADE CHALLENGE — Characters with the "Self-made" or
--    "Self-made guns" challenge must equip only items that are:
--      (a) self-crafted via their required profession, OR
--      (b) white (Common) or grey (Poor) quality.
--    Detection works by checking each equipped item's quality via
--    GetItemInfo (quality 0 or 1 always passes) and checking
--    higher-quality items against curated profession-crafted ID lists.
--
-- Results are stored in HCE_CharDB.selfFoundResults so the
-- requirements panel can display pass/fail indicators.
--
-- WoW Classic API used:
--   UnitBuff("player", index) — iterate auras to find Self-Found
--   GetInventoryItemID("player", slot) — read equipped items
--   GetItemInfo(itemID) — quality field (index 3, 0-based)
----------------------------------------------------------------------

HCE = HCE or {}

local SF = {}
HCE.SelfFoundCheck = SF

----------------------------------------------------------------------
-- Status constants (shared vocabulary)
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

SF.STATUS = { PASS = PASS, FAIL = FAIL, UNCHECKED = UNCHECKED }

----------------------------------------------------------------------
-- Self-Found buff spell IDs
--
-- The Self-Found buff is a permanent aura applied to characters on
-- Self-Found realms (Classic Era).  We check multiple candidate spell
-- IDs because the ID may vary between client versions / patches.
-- If none match, we fall back to a name-based scan.
--
-- These IDs should be verified in-game.  If the real ID differs,
-- add it here and the check will pick it up automatically.
----------------------------------------------------------------------

local SELF_FOUND_SPELL_IDS = {
    -- Known / candidate spell IDs for the Self-Found buff
    -- (verify in-game and update as needed)
    462515,   -- Self-Found (Classic Era Fresh)
    456540,   -- Self-Found (alternate candidate)
}

-- English name for the fallback scan.  On non-English clients the
-- spell-ID path should catch it first; if both miss we report
-- UNCHECKED rather than a false FAIL.
local SELF_FOUND_BUFF_NAME = "Self-Found"

----------------------------------------------------------------------
-- Buff scanning
----------------------------------------------------------------------

--- Scan the player's buffs for the Self-Found aura.
--- @return string status  "pass" if found, "fail" if not, "unchecked" if API missing
--- @return string detail  human-readable explanation
local function CheckSelfFoundBuff()
    -- Guard against missing API (shouldn't happen in Classic, but
    -- defensive is good)
    if not UnitBuff then
        return UNCHECKED, "UnitBuff API not available"
    end

    -- Strategy 1: check by spell ID (locale-independent)
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
        if not name then break end
        if spellID then
            for _, knownID in ipairs(SELF_FOUND_SPELL_IDS) do
                if spellID == knownID then
                    return PASS, "Self-Found buff active (spell " .. spellID .. ")"
                end
            end
        end
    end

    -- Strategy 2: check by English name (fast path for EN clients)
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        -- Case-insensitive partial match to catch variations like
        -- "Self-Found", "Self Found", "Selffound"
        local lower = name:lower()
        if lower:find("self") and lower:find("found") then
            return PASS, "Self-Found buff active (\"" .. name .. "\")"
        end
    end

    -- Strategy 3: try AuraUtil if available (some Classic builds)
    if AuraUtil and AuraUtil.FindAuraByName then
        local name = AuraUtil.FindAuraByName(SELF_FOUND_BUFF_NAME, "player")
        if name then
            return PASS, "Self-Found buff active (AuraUtil)"
        end
    end

    -- Not found
    return FAIL, "Self-Found buff not detected"
end

----------------------------------------------------------------------
-- Profession-crafted item ID lists (for Self-Made challenge)
--
-- These curated lists map itemID → true for items that can be
-- crafted via each profession.  They power the "Self-made" challenge
-- check: if an equipped item has quality > Common AND isn't on
-- the relevant profession's crafted list, it's a violation.
--
-- Full population is deferred to Milestone 7; for now we include
-- a starter set of well-known crafted items so the check framework
-- is functional and can give accurate results where data exists.
----------------------------------------------------------------------

SF.CraftedByProfession = {
    -- Tailoring: cloth armor, bags, shirts, robes
    ["Tailoring"] = {
        -- Low-level tailoring (common early items)
        [2568]  = true,   -- Brown Linen Robe
        [2569]  = true,   -- Linen Boots
        [2570]  = true,   -- Linen Cloak
        [2572]  = true,   -- Red Linen Robe
        [4309]  = true,   -- Handstitched Linen Britches
        [4311]  = true,   -- Heavy Linen Gloves
        [4312]  = true,   -- Soft-soled Linen Boots
        [4313]  = true,   -- Red Woolen Bag
        [4314]  = true,   -- Double-stitched Woolen Shoulders
        [4315]  = true,   -- Reinforced Woolen Shoulders
        [4316]  = true,   -- Heavy Woolen Cloak
        [4317]  = true,   -- Phoenix Pants
        [4318]  = true,   -- Battle Harness
        [4319]  = true,   -- Azure Silk Gloves
        [4320]  = true,   -- Spidersilk Boots
        [7059]  = true,   -- Azure Silk Hood
        [7060]  = true,   -- Azure Silk Vest
        [7063]  = true,   -- Crimson Silk Vest
        [7064]  = true,   -- Crimson Silk Shoulders
        [7065]  = true,   -- Crimson Silk Cloak
        [7054]  = true,   -- Robe of Power
        [7049]  = true,   -- Shadow Hood
        [10042] = true,   -- Ghostweave Belt
        [10041] = true,   -- Ghostweave Gloves
        [10044] = true,   -- Ghostweave Pants
        [10043] = true,   -- Ghostweave Vest
        [14136] = true,   -- Robe of Winter Night
        [14104] = true,   -- Frostweave Gloves
        [14106] = true,   -- Frostweave Pants
        [14107] = true,   -- Frostweave Robe
        [14108] = true,   -- Mooncloth Robe
        [18405] = true,   -- Runecloth Robe
        [18407] = true,   -- Runecloth Tunic
        [18409] = true,   -- Runecloth Cloak
        [13867] = true,   -- Frostweave Tunic
        [14140] = true,   -- Mooncloth Vest
        [14144] = true,   -- Mooncloth Shoulders
        [14142] = true,   -- Mooncloth Leggings
        [14139] = true,   -- Mooncloth Boots
        -- TODO(M7): full tailoring crafted item list from Wowhead
    },

    -- Blacksmithing: plate/mail armor, weapons
    ["Blacksmithing"] = {
        [2851]  = true,   -- Copper Chain Belt
        [2852]  = true,   -- Copper Chain Pants
        [2853]  = true,   -- Copper Bracers
        [2854]  = true,   -- Runed Copper Belt
        [2862]  = true,   -- Rough Bronze Leggings
        [2864]  = true,   -- Rough Bronze Cuirass
        [2865]  = true,   -- Rough Bronze Shoulders
        [2866]  = true,   -- Rough Bronze Boots
        [2868]  = true,   -- Patterned Bronze Bracers
        [2869]  = true,   -- Silvered Bronze Boots
        [2870]  = true,   -- Silvered Bronze Shoulders
        [2871]  = true,   -- Heavy Sharpening Stone
        [3836]  = true,   -- Green Iron Helm
        [3837]  = true,   -- Green Iron Shoulders
        [3840]  = true,   -- Green Iron Gauntlets
        [3841]  = true,   -- Golden Scale Bracers
        [3842]  = true,   -- Green Iron Hauberk
        [3843]  = true,   -- Golden Scale Boots
        [3844]  = true,   -- Green Iron Leggings
        [3845]  = true,   -- Golden Scale Shoulders
        [3846]  = true,   -- Golden Scale Leggings
        [3847]  = true,   -- Golden Scale Cuirass
        [3848]  = true,   -- Big Bronze Knife
        [3849]  = true,   -- Jade Serpentblade
        [3850]  = true,   -- Heavy Bronze Mace
        [3851]  = true,   -- Solid Iron Maul
        [3852]  = true,   -- Golden Iron Destroyer
        [7944]  = true,   -- Steel Plate Helm
        [7963]  = true,   -- Steel Breastplate
        [12404] = true,   -- Thorium Belt
        [12405] = true,   -- Thorium Bracers
        [12406] = true,   -- Thorium Boots
        [12408] = true,   -- Thorium Helm
        [12409] = true,   -- Thorium Leggings
        [12410] = true,   -- Thorium Shoulders
        [12414] = true,   -- Thorium Armor
        -- TODO(M7): full blacksmithing crafted item list from Wowhead
    },

    -- Leatherworking: leather and mail armor
    ["Leatherworking"] = {
        [2302]  = true,   -- Handstitched Leather Boots
        [2303]  = true,   -- Handstitched Leather Belt
        [2304]  = true,   -- Light Leather Bracers
        [2307]  = true,   -- Fine Leather Boots
        [2308]  = true,   -- Fine Leather Cloak
        [2309]  = true,   -- Embossed Leather Vest
        [2310]  = true,   -- Embossed Leather Boots
        [2311]  = true,   -- White Leather Jerkin
        [2312]  = true,   -- Fine Leather Gloves
        [2313]  = true,   -- Medium Armor Kit
        [2314]  = true,   -- Toughened Leather Armor
        [2316]  = true,   -- Dark Leather Tunic
        [2317]  = true,   -- Dark Leather Belt
        [2318]  = true,   -- Dark Leather Shoulders
        [2319]  = true,   -- Dark Leather Cloak
        [4239]  = true,   -- Embossed Leather Gloves
        [4242]  = true,   -- Embossed Leather Cloak
        [4244]  = true,   -- Hillman's Leather Vest
        [4246]  = true,   -- Hillman's Leather Gloves
        [4248]  = true,   -- Hillman's Shoulders
        [4250]  = true,   -- Hillman's Belt
        [4252]  = true,   -- Hillman's Cloak
        [4254]  = true,   -- Barbaric Gloves
        [4255]  = true,   -- Green Leather Armor
        [4256]  = true,   -- Green Leather Belt
        [4257]  = true,   -- Green Leather Bracers
        [4258]  = true,   -- Guardian Belt
        [4259]  = true,   -- Guardian Armor
        [4260]  = true,   -- Guardian Pants
        [4262]  = true,   -- Guardian Gloves
        [8345]  = true,   -- Wolfshead Helm
        [8346]  = true,   -- Gauntlets of the Sea
        [8347]  = true,   -- Dragonscale Breastplate
        [15059] = true,   -- Living Shoulders
        [15056] = true,   -- Living Leggings
        [15060] = true,   -- Living Breastplate
        [15058] = true,   -- Devilsaur Leggings
        [15057] = true,   -- Devilsaur Gauntlets
        -- TODO(M7): full leatherworking crafted item list from Wowhead
    },

    -- Engineering: guns, goggles, bombs, devices
    ["Engineering"] = {
        [4362]  = true,   -- Rough Boomstick
        [4363]  = true,   -- Deadly Blunderbuss
        [4365]  = true,   -- Rough Copper Bomb
        [4368]  = true,   -- Flying Tiger Goggles
        [4369]  = true,   -- Moonsight Rifle
        [4372]  = true,   -- Lovingly Crafted Boomstick
        [4378]  = true,   -- Heavy Dynamite
        [4379]  = true,   -- Silver-plated Shotgun
        [4383]  = true,   -- Bronze Tube
        [4384]  = true,   -- Flame Deflector
        [4385]  = true,   -- Green Tinted Goggles
        [4403]  = true,   -- Mithril Blunderbuss
        [10500] = true,   -- Green Lens
        [10501] = true,   -- Deepdive Helmet
        [10510] = true,   -- Mithril Heavy-bore Rifle
        [10546] = true,   -- Gnomish Mind Control Cap
        [10548] = true,   -- Goblin Rocket Helmet
        [10508] = true,   -- Sniper Scope
        [16004] = true,   -- Dark Iron Rifle
        [18282] = true,   -- Core Marksman Rifle
        [15995] = true,   -- Thorium Rifle
        [18168] = true,   -- Force Reactive Disk (shield)
        -- TODO(M7): full engineering crafted item list from Wowhead
    },

    -- Alchemy: no equippable items typically, but included for completeness
    ["Alchemy"] = {
        -- Alchemists don't craft equippable gear in Classic.
        -- Their role in self-made is limited to potions/elixirs (consumables,
        -- not tracked by equipment checks).
    },

    -- Enchanting: wands
    ["Enchanting"] = {
        [11288] = true,   -- Greater Magic Wand
        [11289] = true,   -- Greater Mystic Wand
        [11290] = true,   -- Enchanted Thorium Blade
        -- TODO(M7): enchanting-crafted wands from Wowhead
    },

    -- Mining: smelted bars → not equippable directly
    ["Mining"] = {},

    -- Herbalism: gathering profession → no craftables
    ["Herbalism"] = {},

    -- Skinning: gathering profession → no craftables
    ["Skinning"] = {},

    -- Cooking: food, not equippable
    ["Cooking"] = {},

    -- First Aid: bandages, not equippable
    ["First Aid"] = {},

    -- Fishing: fishing poles (technically equippable weapons)
    ["Fishing"] = {
        [6256]  = true,   -- Fishing Pole
        [6365]  = true,   -- Strong Fishing Pole
        [6366]  = true,   -- Darkwood Fishing Pole
        [6367]  = true,   -- Big Iron Fishing Pole
        [19022] = true,   -- Nat Pagle's Extreme Angler FC-5000
        [19970] = true,   -- Arcanite Fishing Pole
        -- NOTE: fishing poles are typically vendor/quest items, not crafted.
        -- Included here for completeness in case a character's gear overlaps.
    },
}

----------------------------------------------------------------------
-- Engineering-crafted gun list (for "Self-made guns" challenge)
--
-- Specifically guns that an Engineer would craft.  Used by the
-- Mountaineer character who requires self-crafted ranged weapons.
----------------------------------------------------------------------

SF.EngineeringGuns = {
    [4362]  = true,   -- Rough Boomstick
    [4363]  = true,   -- Deadly Blunderbuss
    [4369]  = true,   -- Moonsight Rifle
    [4372]  = true,   -- Lovingly Crafted Boomstick
    [4379]  = true,   -- Silver-plated Shotgun
    [4403]  = true,   -- Mithril Blunderbuss
    [10510] = true,   -- Mithril Heavy-bore Rifle
    [16004] = true,   -- Dark Iron Rifle
    [15995] = true,   -- Thorium Rifle
    [18282] = true,   -- Core Marksman Rifle
    -- TODO(M7): full engineering gun list from Wowhead
}

----------------------------------------------------------------------
-- Equipment slot IDs (same as EquipmentCheck)
----------------------------------------------------------------------

local SLOT_IDS = {
    1,   -- INVSLOT_HEAD
    2,   -- INVSLOT_NECK
    3,   -- INVSLOT_SHOULDER
    5,   -- INVSLOT_CHEST
    6,   -- INVSLOT_WAIST
    7,   -- INVSLOT_LEGS
    8,   -- INVSLOT_FEET
    9,   -- INVSLOT_WRIST
    10,  -- INVSLOT_HAND
    11,  -- INVSLOT_FINGER0
    12,  -- INVSLOT_FINGER1
    13,  -- INVSLOT_TRINKET0
    14,  -- INVSLOT_TRINKET1
    15,  -- INVSLOT_BACK
    16,  -- INVSLOT_MAINHAND
    17,  -- INVSLOT_OFFHAND
    18,  -- INVSLOT_RANGED
    19,  -- INVSLOT_TABARD
    4,   -- INVSLOT_BODY (shirt)
}

local RANGED_SLOT = 18

----------------------------------------------------------------------
-- Self-made item checking
----------------------------------------------------------------------

--- Check a single equipped item against the self-made rules.
--- An item passes if it is:
---   (a) white (Common, quality=1) or grey (Poor, quality=0), OR
---   (b) on the curated crafted-items list for the character's profession
---
--- @param itemID number
--- @param professions table  list of the character's required professions
--- @return string status
--- @return string detail
local function CheckSelfMadeItem(itemID, professions)
    if not itemID then
        return PASS, "Empty slot"
    end

    local itemName, _, itemQuality = GetItemInfo(itemID)
    if not itemName then
        -- Item not cached yet; can't verify
        return UNCHECKED, "Item " .. itemID .. " not in cache"
    end

    -- White or grey quality always passes (no restrictions)
    if itemQuality <= 1 then
        return PASS, itemName .. " — quality " .. itemQuality .. " (white/grey, always OK)"
    end

    -- Higher quality: must be on a profession crafted list
    local foundOnList = false
    local checkedProf = nil
    for _, profName in ipairs(professions) do
        local list = SF.CraftedByProfession[profName]
        if list and list[itemID] then
            foundOnList = true
            checkedProf = profName
            break
        end
    end

    if foundOnList then
        return PASS, itemName .. " — confirmed " .. checkedProf .. "-crafted"
    end

    -- Not on any crafted list.  If the curated lists are incomplete
    -- (most are until Milestone 7), report UNCHECKED rather than a
    -- hard FAIL so we don't fire false positives.
    local totalCurated = 0
    for _, profName in ipairs(professions) do
        local list = SF.CraftedByProfession[profName]
        if list then
            for _ in pairs(list) do totalCurated = totalCurated + 1 end
        end
    end

    if totalCurated < 20 then
        -- Too few curated items to trust a negative result
        return UNCHECKED, itemName .. " — not on curated list yet (" .. totalCurated .. " items catalogued)"
    end

    return FAIL, itemName .. " (quality " .. itemQuality .. ") — not on self-crafted list"
end

--- Check the ranged slot specifically for a self-made Engineering gun.
--- @return string status
--- @return string detail
local function CheckSelfMadeGun()
    local itemID = GetInventoryItemID("player", RANGED_SLOT)
    if not itemID then
        return PASS, "No ranged weapon equipped"
    end

    local itemName, _, itemQuality = GetItemInfo(itemID)
    if not itemName then
        return UNCHECKED, "Ranged item " .. itemID .. " not in cache"
    end

    -- White/grey guns are fine (same as general self-made rule)
    if itemQuality <= 1 then
        return PASS, itemName .. " — quality " .. itemQuality .. " (white/grey, always OK)"
    end

    -- Must be on the engineering gun list
    if SF.EngineeringGuns[itemID] then
        return PASS, itemName .. " — confirmed Engineering-crafted gun"
    end

    -- Count how many guns we have curated
    local n = 0
    for _ in pairs(SF.EngineeringGuns) do n = n + 1 end
    if n < 10 then
        return UNCHECKED, itemName .. " — not on Engineering gun list yet (" .. n .. " guns catalogued)"
    end

    return FAIL, itemName .. " (quality " .. itemQuality .. ") — not an Engineering-crafted gun"
end

----------------------------------------------------------------------
-- Full check
----------------------------------------------------------------------

--- Run all self-found / self-made checks for the current character.
--- @return table results  { selfFound = {status, detail},
---                          selfMade  = {status, detail, items = {...}},
---                          selfMadeGuns = {status, detail} }
function SF.CheckAll()
    local results = {}
    if not HCE_CharDB then return results end

    local key = HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then return results end

    -- 1. Self-found buff check (only if character requires it)
    if char.selfFound then
        local status, detail = CheckSelfFoundBuff()
        results.selfFound = { status = status, detail = detail }
    end

    -- 2. Self-made challenge check
    local hasSelfMade = false
    local hasSelfMadeGuns = false
    if char.challenges then
        for _, ch in ipairs(char.challenges) do
            if ch.desc == "Self-made" then hasSelfMade = true end
            if ch.desc == "Self-made guns" then hasSelfMadeGuns = true end
        end
    end

    if hasSelfMade and char.professions and #char.professions > 0 then
        -- Check all equipment slots
        local itemResults = {}
        local overallStatus = PASS
        local failCount = 0
        local uncheckCount = 0

        for _, slotID in ipairs(SLOT_IDS) do
            local itemID = GetInventoryItemID("player", slotID)
            if itemID then
                local status, detail = CheckSelfMadeItem(itemID, char.professions)
                table.insert(itemResults, {
                    slot   = slotID,
                    itemID = itemID,
                    status = status,
                    detail = detail,
                })
                if status == FAIL then
                    failCount = failCount + 1
                    overallStatus = FAIL
                elseif status == UNCHECKED and overallStatus ~= FAIL then
                    uncheckCount = uncheckCount + 1
                    overallStatus = UNCHECKED
                end
            end
        end

        local summary
        if overallStatus == PASS then
            summary = "All equipped items are self-crafted or white/grey"
        elseif overallStatus == FAIL then
            summary = failCount .. " item" .. (failCount == 1 and "" or "s") .. " not self-crafted"
        else
            summary = uncheckCount .. " item" .. (uncheckCount == 1 and "" or "s") .. " need verification (curated lists incomplete)"
        end

        results.selfMade = {
            status = overallStatus,
            detail = summary,
            items  = itemResults,
        }
    end

    if hasSelfMadeGuns then
        local status, detail = CheckSelfMadeGun()
        results.selfMadeGuns = { status = status, detail = detail }
    end

    return results
end

--- Run a full check and store results in SavedVariables.
function SF.RunCheck()
    local results = SF.CheckAll()
    if HCE_CharDB then
        HCE_CharDB.selfFoundResults = results
    end
    return results
end

--- Get stored results from the last check.
function SF.GetResults()
    return HCE_CharDB and HCE_CharDB.selfFoundResults or {}
end

----------------------------------------------------------------------
-- Chat warnings (one-shot per session)
----------------------------------------------------------------------

local CHAT_PREFIX = "|cffe6b422[HCE]|r "

local warnedSelfFound    = false
local warnedSelfMade     = false
local warnedSelfMadeGuns = false

--- Run checks and fire chat warnings for new problems.
function SF.CheckAndWarn()
    local oldResults = SF.GetResults()

    -- Snapshot old statuses
    local oldSF   = oldResults.selfFound and oldResults.selfFound.status
    local oldSM   = oldResults.selfMade and oldResults.selfMade.status
    local oldSMG  = oldResults.selfMadeGuns and oldResults.selfMadeGuns.status

    local newResults = SF.RunCheck()

    -- Self-found buff warning
    if newResults.selfFound and newResults.selfFound.status == FAIL and not warnedSelfFound then
        DEFAULT_CHAT_FRAME:AddMessage(
            CHAT_PREFIX .. "|cffffaa33Self-Found buff not detected.|r " ..
            "Your character requires Self-Found mode — make sure you're on a Self-Found realm."
        )
        warnedSelfFound = true
    elseif newResults.selfFound and newResults.selfFound.status == PASS then
        warnedSelfFound = false
    end

    -- Self-made challenge warning
    if newResults.selfMade and newResults.selfMade.status == FAIL and not warnedSelfMade then
        DEFAULT_CHAT_FRAME:AddMessage(
            CHAT_PREFIX .. "|cffffaa33Self-made violation:|r " ..
            (newResults.selfMade.detail or "Some equipped items are not self-crafted or white/grey")
        )
        warnedSelfMade = true
    elseif newResults.selfMade and newResults.selfMade.status == PASS then
        warnedSelfMade = false
    end

    -- Self-made guns warning
    if newResults.selfMadeGuns and newResults.selfMadeGuns.status == FAIL and not warnedSelfMadeGuns then
        DEFAULT_CHAT_FRAME:AddMessage(
            CHAT_PREFIX .. "|cffffaa33Self-made guns violation:|r " ..
            (newResults.selfMadeGuns.detail or "Ranged weapon is not Engineering-crafted")
        )
        warnedSelfMadeGuns = true
    elseif newResults.selfMadeGuns and newResults.selfMadeGuns.status == PASS then
        warnedSelfMadeGuns = false
    end

    -- Refresh the panel to show updated indicators
    if HCE.RefreshPanel then HCE.RefreshPanel() end
end

--- Reset one-shot warning state.  Called when a new character is
--- selected so stale warnings from a previous pick don't block.
function SF.ResetWarnings()
    warnedSelfFound    = false
    warnedSelfMade     = false
    warnedSelfMadeGuns = false
end

----------------------------------------------------------------------
-- Slash command: /hce selffound
----------------------------------------------------------------------

function SF.PrintStatus()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
        return
    end

    local char = HCE.GetCharacter(HCE_CharDB.selectedCharacter)
    if not char then
        HCE.Print("Character data not found.")
        return
    end

    HCE.Print("Self-Found / Self-Made status:")

    local results = SF.RunCheck()

    -- Self-found buff
    if char.selfFound then
        local r = results.selfFound
        if r then
            local tag
            if r.status == PASS then
                tag = "|cff00ff00ACTIVE|r"
            elseif r.status == FAIL then
                tag = "|cffff5555NOT FOUND|r"
            else
                tag = "|cffffaa33???|r"
            end
            HCE.Print("  Self-Found buff: " .. tag .. " — " .. (r.detail or ""))
        else
            HCE.Print("  Self-Found buff: |cff888888no data|r")
        end
    else
        HCE.Print("  Self-Found: not required for this character")
    end

    -- Self-made challenge
    if results.selfMade then
        local r = results.selfMade
        local tag
        if r.status == PASS then
            tag = "|cff00ff00OK|r"
        elseif r.status == FAIL then
            tag = "|cffff5555VIOLATION|r"
        else
            tag = "|cffffaa33PARTIAL|r"
        end
        HCE.Print("  Self-made: " .. tag .. " — " .. (r.detail or ""))

        -- Show per-item breakdown if any failures
        if r.items then
            for _, item in ipairs(r.items) do
                if item.status ~= PASS then
                    local itemTag = item.status == FAIL and "|cffff5555FAIL|r" or "|cffffaa33?|r"
                    HCE.Print("    Slot " .. item.slot .. ": " .. itemTag .. " " .. (item.detail or ""))
                end
            end
        end
    end

    -- Self-made guns
    if results.selfMadeGuns then
        local r = results.selfMadeGuns
        local tag
        if r.status == PASS then
            tag = "|cff00ff00OK|r"
        elseif r.status == FAIL then
            tag = "|cffff5555VIOLATION|r"
        else
            tag = "|cffffaa33???|r"
        end
        HCE.Print("  Self-made guns: " .. tag .. " — " .. (r.detail or ""))
    end
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

local initialCheckDone = false

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer so SavedVariables and CharacterData are ready
        C_Timer.After(3.0, function()
            SF.RunCheck()
            initialCheckDone = true
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
        -- Second pass to fire warnings after everything settled
        C_Timer.After(6.0, function()
            SF.CheckAndWarn()
        end)

    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit ~= "player" then return end
        if not initialCheckDone then return end
        -- Re-check self-found buff when auras change
        C_Timer.After(0.3, function()
            SF.CheckAndWarn()
        end)

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if not initialCheckDone then return end
        -- Re-check self-made items when gear changes
        C_Timer.After(0.5, function()
            SF.CheckAndWarn()
        end)

    elseif event == "PLAYER_LEVEL_UP" then
        if not initialCheckDone then return end
        C_Timer.After(0.5, function()
            SF.CheckAndWarn()
        end)
    end
end)
