----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Equipment Tracking
--
-- Watches PLAYER_EQUIPMENT_CHANGED and checks equipped items against
-- the selected character's equipment requirements.  For type-based
-- requirements (swords, shields, daggers, staves, etc.) uses item
-- classID / subclassID from GetItemInfo, which are locale-independent
-- integers.  For visual/thematic items (voodoo mask, wolf helm, etc.)
-- defers to curated item ID lists that will be filled in Milestone 7.
--
-- Tracking is current-state only — we inspect what's equipped RIGHT
-- NOW, not acquisition history.  Results are stored in HCE_CharDB so
-- the requirements panel can display pass/fail indicators.
----------------------------------------------------------------------

HCE = HCE or {}

local EQ = {}
HCE.EquipmentCheck = EQ

----------------------------------------------------------------------
-- WoW Classic inventory slot IDs
----------------------------------------------------------------------

local SLOT = {
    HEAD      =  1,
    NECK      =  2,
    SHOULDER  =  3,
    SHIRT     =  4,
    CHEST     =  5,
    WAIST     =  6,
    LEGS      =  7,
    FEET      =  8,
    WRIST     =  9,
    HANDS     = 10,
    FINGER0   = 11,
    FINGER1   = 12,
    TRINKET0  = 13,
    TRINKET1  = 14,
    BACK      = 15,
    MAINHAND  = 16,
    OFFHAND   = 17,
    RANGED    = 18,
    TABARD    = 19,
}

----------------------------------------------------------------------
-- Hidden tooltip for enchant / modification scanning
----------------------------------------------------------------------

local scanTip = CreateFrame("GameTooltip", "HCE_ScanTooltip", nil, "GameTooltipTemplate")
scanTip:SetOwner(WorldFrame, "ANCHOR_NONE")

--- Check whether any tooltip line for a slot contains a given pattern
--- (case-insensitive).  Returns the matched line text or nil.
local function slotTooltipHas(slotID, pattern)
    scanTip:ClearLines()
    scanTip:SetInventoryItem("player", slotID)
    local pat = pattern:lower()
    for i = 2, scanTip:NumLines() do
        local left = _G["HCE_ScanTooltipTextLeft" .. i]
        if left then
            local txt = left:GetText()
            if txt and txt:lower():find(pat) then
                return txt
            end
        end
    end
    return nil
end

----------------------------------------------------------------------
-- Item classID / subclassID constants (locale-independent)
----------------------------------------------------------------------

-- Weapon classID = 2
local WEAPON_CLASS = 2
local WEAPON_SUB = {
    AXE_1H       =  0,
    AXE_2H       =  1,
    BOW          =  2,
    GUN          =  3,
    MACE_1H      =  4,
    MACE_2H      =  5,
    POLEARM      =  6,
    SWORD_1H     =  7,
    SWORD_2H     =  8,
    STAFF        = 10,
    FIST         = 13,
    MISC         = 14,
    DAGGER       = 15,
    THROWN        = 16,
    CROSSBOW     = 18,
    WAND         = 19,
    FISHING_POLE = 20,
}

-- Armor classID = 4
local ARMOR_CLASS = 4
local ARMOR_SUB = {
    MISC    = 0,
    CLOTH   = 1,
    LEATHER = 2,
    MAIL    = 3,
    PLATE   = 4,
    SHIELD  = 6,
}

-- Convenience groupings
local SWORDS   = { [WEAPON_SUB.SWORD_1H] = true, [WEAPON_SUB.SWORD_2H] = true }
local MACES    = { [WEAPON_SUB.MACE_1H] = true, [WEAPON_SUB.MACE_2H] = true }
local AXES     = { [WEAPON_SUB.AXE_1H] = true, [WEAPON_SUB.AXE_2H] = true }
local DAGGERS  = { [WEAPON_SUB.DAGGER] = true }
local STAVES   = { [WEAPON_SUB.STAFF] = true }
local FISTS    = { [WEAPON_SUB.FIST] = true }
local GUNS     = { [WEAPON_SUB.GUN] = true }
local WANDS    = { [WEAPON_SUB.WAND] = true }
local POLEARMS = { [WEAPON_SUB.POLEARM] = true }
local THROWN   = { [WEAPON_SUB.THROWN] = true }
local BOWS     = { [WEAPON_SUB.BOW] = true }

-- Two-handed weapon subtypes
local TWO_HANDED = {
    [WEAPON_SUB.AXE_2H]   = true,
    [WEAPON_SUB.MACE_2H]  = true,
    [WEAPON_SUB.SWORD_2H] = true,
    [WEAPON_SUB.STAFF]    = true,
    [WEAPON_SUB.POLEARM]  = true,
}

-- Item equip locations that mean "robe" vs "chest"
local ROBE_EQUIPLOC = "INVTYPE_ROBE"

----------------------------------------------------------------------
-- Equipment state snapshot
----------------------------------------------------------------------

--- Read item info for a single inventory slot.
--- @return table|nil  { id, name, link, quality, classID, subclassID, equipLoc, speed }
local function readSlot(slotID)
    local itemID = GetInventoryItemID("player", slotID)
    if not itemID then return nil end

    local name, link, quality, _, _, itemType, itemSubType,
          _, equipLoc, _, _, classID, subclassID = GetItemInfo(itemID)

    -- GetItemInfo can return nil if the item isn't cached yet.
    -- We retry once on a short timer in the caller, but for now return
    -- whatever we have.
    if not classID then return nil end

    -- Attack speed (for "1.5 speed dagger" and similar checks)
    -- GetInventoryItemLink returns the instance link which has durability etc.
    local speed = nil
    -- In Classic, we can read weapon speed from the tooltip.  For the
    -- moment we store nil; speed-based rules will fall back to a
    -- "cannot verify" state until we add tooltip scanning in a later pass.

    -- Extract enchant ID from the item link.
    -- Classic item links: |Hitem:itemID:enchantID:...|h
    local enchantID = 0
    if link then
        local eID = link:match("|Hitem:%d+:(%d+)")
        enchantID = tonumber(eID) or 0
    end

    return {
        id         = itemID,
        name       = name or "",
        link       = link or "",
        quality    = quality or 0,    -- 0=poor/grey, 1=common/white, 2=uncommon, 3=rare, 4=epic
        classID    = classID,
        subclassID = subclassID,
        equipLoc   = equipLoc or "",
        speed      = speed,
        enchantID  = enchantID,
        slotID     = slotID,
    }
end

--- Take a snapshot of all equipped items.
--- @return table  slotID -> item info table (only occupied slots)
function EQ.Snapshot()
    local state = {}
    for name, id in pairs(SLOT) do
        local info = readSlot(id)
        if info then
            state[id] = info
        end
    end
    return state
end

----------------------------------------------------------------------
-- Rule helpers
----------------------------------------------------------------------

--- Check if the item in a slot is a weapon with a given subclass.
local function slotHasWeaponSub(state, slotID, subSet)
    local item = state[slotID]
    if not item then return false end
    if item.classID ~= WEAPON_CLASS then return false end
    return subSet[item.subclassID] == true
end

--- Check if any weapon slot (main hand, off hand) satisfies a subclass set.
local function anyWeaponIs(state, subSet)
    return slotHasWeaponSub(state, SLOT.MAINHAND, subSet)
        or slotHasWeaponSub(state, SLOT.OFFHAND, subSet)
end

--- Check if ALL weapon slots that have items satisfy a subclass set.
local function allWeaponsAre(state, subSet)
    local mh = state[SLOT.MAINHAND]
    local oh = state[SLOT.OFFHAND]
    -- At least one weapon must be equipped
    if not mh and not oh then return false end
    if mh and mh.classID == WEAPON_CLASS and not subSet[mh.subclassID] then return false end
    -- Off-hand can be a shield or held-in-off-hand (armor), only check if it's a weapon
    if oh and oh.classID == WEAPON_CLASS and not subSet[oh.subclassID] then return false end
    return true
end

--- Check if a slot is empty.
local function slotEmpty(state, slotID)
    return state[slotID] == nil
end

--- Check if the item in a slot is a shield.
local function slotHasShield(state, slotID)
    local item = state[slotID]
    if not item then return false end
    return item.classID == ARMOR_CLASS and item.subclassID == ARMOR_SUB.SHIELD
end

--- Check if the chest slot has a robe (INVTYPE_ROBE).
local function chestIsRobe(state)
    local item = state[SLOT.CHEST]
    if not item then return false end
    return item.equipLoc == ROBE_EQUIPLOC
end

----------------------------------------------------------------------
-- Rule results
----------------------------------------------------------------------

-- Each rule function returns:
--   status: "pass" | "fail" | "unchecked"
--     pass      = requirement satisfied
--     fail      = requirement violated
--     unchecked = can't verify (needs curated item IDs or tooltip scanning)
--   detail: string explaining the result (shown on hover in panel)

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

----------------------------------------------------------------------
-- Rule registry
--
-- Maps equipment requirement description strings (from CharacterData)
-- to checker functions.  Each function receives (state, playerLevel)
-- and returns (status, detail).
--
-- Matching is case-insensitive.  If no rule matches, the requirement
-- defaults to "unchecked".
----------------------------------------------------------------------

local rules = {}

--- Register a rule for a requirement description.
local function R(pattern, fn)
    rules[pattern:lower()] = fn
end

----------------------------------------------------------------------
-- WEAPON TYPE RULES (reliable via classID/subclassID)
----------------------------------------------------------------------

R("Swords", function(state)
    if allWeaponsAre(state, SWORDS) then
        return PASS, "Wielding swords"
    end
    -- Check if any weapon slot has a non-sword weapon
    local mh = state[SLOT.MAINHAND]
    local oh = state[SLOT.OFFHAND]
    local violations = {}
    if mh and mh.classID == WEAPON_CLASS and not SWORDS[mh.subclassID] then
        table.insert(violations, "main hand: " .. (mh.name or "?"))
    end
    if oh and oh.classID == WEAPON_CLASS and not SWORDS[oh.subclassID] then
        table.insert(violations, "off hand: " .. (oh.name or "?"))
    end
    if #violations > 0 then
        return FAIL, "Non-sword weapon: " .. table.concat(violations, ", ")
    end
    -- No weapons equipped at all
    return FAIL, "No weapon equipped"
end)

R("Daggers", function(state)
    if allWeaponsAre(state, DAGGERS) then
        return PASS, "Wielding daggers"
    end
    -- Check if any weapon slot has a non-sword weapon
    local mh = state[SLOT.MAINHAND]
    local oh = state[SLOT.OFFHAND]
    local violations = {}
    if mh and mh.classID == WEAPON_CLASS and not DAGGERS[mh.subclassID] then
        table.insert(violations, "main hand: " .. (mh.name or "?"))
    end
    if oh and oh.classID == WEAPON_CLASS and not DAGGERS[oh.subclassID] then
        table.insert(violations, "off hand: " .. (oh.name or "?"))
    end
    if #violations > 0 then
        return FAIL, "Non-dagger weapon: " .. table.concat(violations, ", ")
    end
    -- No weapons equipped at all
    return FAIL, "No weapon equipped"
end)

R("Maces", function(state)
    if allWeaponsAre(state, MACES) then
        return PASS, "Wielding maces"
    end
    -- Check if any weapon slot has a non-sword weapon
    local mh = state[SLOT.MAINHAND]
    local oh = state[SLOT.OFFHAND]
    local violations = {}
    if mh and mh.classID == WEAPON_CLASS and not MACES[mh.subclassID] then
        table.insert(violations, "main hand: " .. (mh.name or "?"))
    end
    if oh and oh.classID == WEAPON_CLASS and not MACES[oh.subclassID] then
        table.insert(violations, "off hand: " .. (oh.name or "?"))
    end
    if #violations > 0 then
        return FAIL, "Non-mace weapon: " .. table.concat(violations, ", ")
    end
    -- No weapons equipped at all
    return FAIL, "No weapon equipped"
end)

R("Sword", function(state)
    if anyWeaponIs(state, SWORDS) then
        return PASS, "Wielding a sword"
    end
    if not state[SLOT.MAINHAND] then
        return FAIL, "No weapon equipped"
    end
    return FAIL, "Not wielding a sword"
end)

R("Mace", function(state)
    if anyWeaponIs(state, MACES) then
        return PASS, "Wielding a mace"
    end
    if not state[SLOT.MAINHAND] then
        return FAIL, "No weapon equipped"
    end
    return FAIL, "Not wielding a mace"
end)

R("Staff", function(state)
    if slotHasWeaponSub(state, SLOT.MAINHAND, STAVES) then
        return PASS, "Wielding a staff"
    end
    if not state[SLOT.MAINHAND] then
        return FAIL, "No weapon equipped"
    end
    return FAIL, "Not wielding a staff"
end)

R("Fist weapons", function(state)
    if allWeaponsAre(state, FISTS) then
        return PASS, "Wielding fist weapons"
    end
    local mh = state[SLOT.MAINHAND]
    if mh and mh.classID == WEAPON_CLASS and not FISTS[mh.subclassID] then
        return FAIL, "Main hand is not a fist weapon: " .. (mh.name or "?")
    end
    return FAIL, "No fist weapon equipped"
end)

R("Dagger", function(state)
    if anyWeaponIs(state, DAGGERS) then
        return PASS, "Wielding a dagger"
    end
    return FAIL, "No dagger equipped"
end)

R("Gun", function(state)
    if slotHasWeaponSub(state, SLOT.RANGED, GUNS) then
        return PASS, "Gun equipped"
    end
    if not state[SLOT.RANGED] then
        return FAIL, "No ranged weapon equipped"
    end
    return FAIL, "Ranged weapon is not a gun"
end)

R("Mace or axe", function(state)
    local combined = { [WEAPON_SUB.MACE_1H] = true, [WEAPON_SUB.AXE_1H] = true }
    if allWeaponsAre(state, combined) then
        return PASS, "Wielding 1H mace or axe"
    end
    local mh = state[SLOT.MAINHAND]
    if mh and mh.classID == WEAPON_CLASS and not combined[mh.subclassID] then
        return FAIL, "Main hand is not a 1H mace or axe: " .. (mh.name or "?")
    end
    return FAIL, "No 1H mace or axe equipped"
end)

R("Sword or mace", function(state)
    local combined = { [WEAPON_SUB.SWORD_1H] = true, [WEAPON_SUB.MACE_1H] = true }
    if allWeaponsAre(state, combined) then
        return PASS, "Wielding 1H sword or mace"
    end
    local mh = state[SLOT.MAINHAND]
    if mh and mh.classID == WEAPON_CLASS and not combined[mh.subclassID] then
        return FAIL, "Main hand is not a 1H sword or mace: " .. (mh.name or "?")
    end
    return FAIL, "No 1H sword or mace equipped"
end)

R("Dagger and sword", function(state)
    local mh = state[SLOT.MAINHAND]
    local oh = state[SLOT.OFFHAND]
    if not mh or not oh then
        return FAIL, "Need both main hand and off hand equipped"
    end
    if mh.classID ~= WEAPON_CLASS or oh.classID ~= WEAPON_CLASS then
        return FAIL, "Both slots must be weapons"
    end
    -- Dagger + sword in either arrangement
    local mhDag = DAGGERS[mh.subclassID]
    local mhSwd = SWORDS[mh.subclassID]
    local ohDag = DAGGERS[oh.subclassID]
    local ohSwd = SWORDS[oh.subclassID]
    if (mhDag and ohSwd) or (mhSwd and ohDag) then
        return PASS, "Dagger + sword equipped"
    end
    return FAIL, "Need one dagger and one sword"
end)

R("2h weapon", function(state)
    local mh = state[SLOT.MAINHAND]
    if not mh then return FAIL, "No weapon equipped" end
    if mh.classID == WEAPON_CLASS and TWO_HANDED[mh.subclassID] then
        return PASS, "Two-handed weapon equipped"
    end
    return FAIL, "Not wielding a two-handed weapon"
end)

R("2h axe", function(state)
    local mh = state[SLOT.MAINHAND]
    if not mh then return FAIL, "No weapon equipped" end
    if mh.classID == WEAPON_CLASS and mh.subclassID == WEAPON_SUB.AXE_2H then
        return PASS, "Two-handed axe equipped"
    end
    return FAIL, "Not wielding a two-handed axe"
end)

R("2h sword", function(state)
    local mh = state[SLOT.MAINHAND]
    if not mh then return FAIL, "No weapon equipped" end
    if mh.classID == WEAPON_CLASS and mh.subclassID == WEAPON_SUB.SWORD_2H then
        return PASS, "Two-handed sword equipped"
    end
    return FAIL, "Not wielding a two-handed sword"
end)

R("1h axe", function(state)
    local mh = state[SLOT.MAINHAND]
    if mh and mh.classID == WEAPON_CLASS and mh.subclassID == WEAPON_SUB.AXE_1H then
        return PASS, "One-handed axe equipped"
    end
    return FAIL, "Not wielding a one-handed axe"
end)

----------------------------------------------------------------------
-- RANGED TYPE RULES
----------------------------------------------------------------------

R("Thrown", function(state)
    -- We can verify it's thrown; "axe" specifically is a visual check
    -- that needs curated IDs (Milestone 7).  For now, check thrown type.
    if slotHasWeaponSub(state, SLOT.RANGED, THROWN) then
        return PASS, "Thrown weapon equipped"
    end
    if not state[SLOT.RANGED] then
        return FAIL, "No ranged weapon equipped"
    end
    return FAIL, "Ranged weapon is not a thrown weapon"
end)

R("Scope", function(state)
    local item = state[SLOT.RANGED]
    if not item then
        return FAIL, "No ranged weapon equipped"
    end
    -- Scan tooltip for scope text (green enchant line)
    local match = slotTooltipHas(SLOT.RANGED, "scope")
    if match then
        return PASS, item.name .. " has " .. match
    end
    return FAIL, (item.name or "?") .. " — no scope detected"
end)

----------------------------------------------------------------------
-- ARMOR / SLOT RULES
----------------------------------------------------------------------

R("Shield", function(state)
    if slotHasShield(state, SLOT.OFFHAND) then
        return PASS, "Shield equipped"
    end
    return FAIL, "No shield in off-hand"
end)

R("Robe", function(state)
    if chestIsRobe(state) then
        return PASS, "Wearing a robe"
    end
    local item = state[SLOT.CHEST]
    if not item then
        return FAIL, "No chest armor equipped"
    end
    return FAIL, "Chest armor is not a robe: " .. (item.name or "?")
end)

R("Show helm", function(state)
    if ShowingHelm() then
        return PASS, "Helm is shown"
    end
    return FAIL, "Helm is hidden — must show helm"
end)

R("Hide helm", function(state)
    if not ShowingHelm() then
        return PASS, "Helm is hidden"
    end
    return FAIL, "Helm is shown — must hide helm"
end)

R("Show cloak", function(state)
    if ShowingCloak() then
        return PASS, "Cloak is shown"
    end
    return FAIL, "Cloak is hidden — must show cloak"
end)

R("Hide cloak", function(state)
    if not ShowingCloak() then
        return PASS, "Cloak is hidden"
    end
    return FAIL, "Cloak is shown — must hide cloak"
end)

R("No chest", function(state)
    local chest = state[SLOT.CHEST]
    local shirt = state[SLOT.SHIRT]
    if not chest and not shirt then
        return PASS, "No chest armor or shirt (good)"
    end
    if chest and shirt then
        return FAIL, "Chest/shirt equipped: " .. (chest.name or "?") .. ", " .. (shirt.name or "?")
    end
    local worn = chest or shirt
    return FAIL, "Chest/shirt equipped: " .. (worn.name or "?")
end)

R("No robes", function(state)
    if not chestIsRobe(state) then
        return PASS, "Not wearing a robe"
    end
    local item = state[SLOT.CHEST]
    return FAIL, "Wearing a robe: " .. (item and item.name or "?") .. " — robes are forbidden"
end)

R("No wands", function(state)
    if slotHasWeaponSub(state, SLOT.RANGED, WANDS) then
        local item = state[SLOT.RANGED]
        return FAIL, "Wand equipped: " .. (item and item.name or "?") .. " — wands are forbidden"
    end
    return PASS, "No wand equipped"
end)

R("No shield", function(state)
    if slotHasShield(state, SLOT.OFFHAND) then
        return FAIL, "Shield equipped"
    end
    return PASS, "No shield in off-hand"
end)

R("No daggers", function(state)
    if anyWeaponIs(state, DAGGERS) then
        local violations = {}
        local mh = state[SLOT.MAINHAND]
        local oh = state[SLOT.OFFHAND]
        if mh and mh.classID == WEAPON_CLASS and DAGGERS[mh.subclassID] then
            table.insert(violations, mh.name or "?")
        end
        if oh and oh.classID == WEAPON_CLASS and DAGGERS[oh.subclassID] then
            table.insert(violations, oh.name or "?")
        end
        return FAIL, "Dagger equipped: " .. table.concat(violations, ", ") .. " — daggers are forbidden"
    end
    return PASS, "No daggers equipped"
end)

R("No guns", function(state)
    if slotHasWeaponSub(state, SLOT.RANGED, GUNS) then
        local item = state[SLOT.RANGED]
        return FAIL, "Gun equipped: " .. (item and item.name or "?") .. " — guns are forbidden"
    end
    return PASS, "No gun equipped"
end)

----------------------------------------------------------------------
-- QUALITY-AWARE RULES (for challenge-adjacent equipment checks)
-- Note: the main quality-based CHALLENGES (White Knight, Exotic,
-- Footman, Grunt) are tracked in the challenge engine (Milestone 5).
-- These rules here are for equipment requirements that mention quality.
----------------------------------------------------------------------

-- (none yet — quality checks currently live on challenges, not equipment)

----------------------------------------------------------------------
-- SPECIFIC / CURATED ITEM RULES (need item ID lists from Milestone 7)
-- These return "unchecked" until the curated lists are added.
----------------------------------------------------------------------

-- Curated item ID tables.  Empty for now; Milestone 7 will populate these.
-- Each table maps itemID (number) -> true.
local CURATED = {
    flask_trinkets      = {},   -- Flask of the Titans, etc.
    lunar_festival_suit = {},   -- Festive suits from Lunar Festival
    kilt                = {},   -- Leg items that look like kilts
    firestone           = {},   -- Firestone off-hand
    wizard_hat           = {},   -- Firestone off-hand
    spellstone          = {},   -- Spellstone off-hand
    cowl                = {},   -- Head items that look like cowls
    captains_hat        = {},   -- Captain-themed head items
    rapier_cutlass_harpoon = {}, -- Rapier/cutlass/harpoon weapons
    wolf_helm           = {},   -- Wolf-themed helms
    powershifting_helm  = {},   -- Powershifting helms (e.g. Wolfshead Helm)
    pole                = {},   -- Fishing poles / poles
    lantern             = {},   -- Torch / lantern off-hand items
    anti_beast_cloak    = {},   -- Anti-beast cloaks (e.g. skinning-related)
    anti_beast_gloves   = {},   -- Anti-beast gloves
    anti_beast_melee    = {},   -- Anti-beast melee weapons
    anti_beast_ranged   = {},   -- Anti-beast ranged weapons
    voodoo_mask         = {},   -- Voodoo-style masks
    cursed_amulet       = {},   -- Cursed neck items
    shell_shield        = {},   -- Shields that look like turtle shells
    torch               = {},   -- Torch off-hand items
    engineer_offhand    = {},
    guild_tabard        = {},   -- Guild tabard
    blue_shirt          = {},   -- Blue shirt items
    insignia            = {},   -- Insignia trinkets
    argent_dawn_trinket = {},   -- Argent Dawn Commission etc.
    herb_pouch          = {},   -- Herb bags
    unholy_weapon       = {},   -- Unholy-themed weapons
    shadow_fire_wand    = {},   -- Shadow or fire damage wands
    flying_tiger_goggles = { [4368] = true },   -- Flying Tiger Goggles (Engineering)
    green_tinted_goggles = { [4385] = true },   -- Green Tinted Goggles (Engineering)
    gnomish_goggles      = { [10545] = true },   -- Gnomish Goggles (various)
    jungle_remedy        = {},   -- Jungle Remedy item
    restoration_potion   = {},   -- Restoration Potion item
    armored_weapon       = {},   -- Armored-looking weapons
    armored_offhand      = {},   -- Armored-looking off-hand
    armored_rings        = {},   -- Armored-looking rings
    staff_like_offhand   = {},   -- Off-hand items that look like staves
    mechanical_companion = {},   -- Mechanical non-combat pets
    skull_offhand        = {},
    vial_offhand         = {},
    witch_doctor_staff   = {},
    dragonbreath_chili   = {},
    horned_helm          = {},
    armored_trinket      = {},
    katana               = {},
    brewmaster_robe      = {},
}

-- Expose the curated tables so other files can populate them
HCE.CuratedItems = CURATED

-- Map equipment requirement desc → curated list key, so the panel can
-- look up approved items for tooltip display.
HCE.CuratedKeyForDesc = {
    ["Flask trinket"]               = "flask_trinkets",
    ["Lunar festival suit"]         = "lunar_festival_suit",
    ["Kilt"]                        = "kilt",
    ["Firestone"]                   = "firestone",
    ["Necromancer hat"]                   = "wizard_hat",
    ["Spellstone"]                  = "spellstone",
    ["Cowl"]                        = "cowl",
    ["Captain's hat"]               = "captains_hat",
    ["Rapier, cutlass, or harpoon"] = "rapier_cutlass_harpoon",
    ["Wolf helm"]                   = "wolf_helm",
    ["Powershifting helm"]          = "powershifting_helm",
    ["Pole"]                        = "pole",
    ["Anti-beast cloak"]            = "anti_beast_cloak",
    ["Anti-beast gloves"]           = "anti_beast_gloves",
    ["Anti-beast melee weapon"]     = "anti_beast_melee",
    ["Anti-beast ranged weapon"]    = "anti_beast_ranged",
    ["Voodoo mask"]                 = "voodoo_mask",
    ["Cursed amulet"]               = "cursed_amulet",
    ["Shell shield"]                = "shell_shield",
    ["Lantern"]                     = "lantern",
    ["Guild tabard"]                = "guild_tabard",
    ["Blue shirt"]                  = "blue_shirt",
    ["Insignia"]                    = "insignia",
    ["Argent Dawn trinket"]         = "argent_dawn_trinket",
    ["Herb pouch"]                  = "herb_pouch",
    ["Unholy weapon"]               = "unholy_weapon",
    ["Shadow or fire wand"]         = "shadow_fire_wand",
    ["Flying Tiger Goggles"]        = "flying_tiger_goggles",
    ["Green-tinted goggles"]        = "green_tinted_goggles",
    ["Gnomish goggles"]             = "gnomish_goggles",
    ["Jungle remedy"]               = "jungle_remedy",
    ["Armored weapon"]              = "armored_weapon",
    ["Armored off-hand"]            = "armored_offhand",
    ["Armored rings"]               = "armored_rings",
    ["Armored ring"]                = "armored_rings",
    ["Staff-like off-hand"]         = "staff_like_offhand",
    ["Skull off-hand"]         = "skull_offhand",
    ["Vial off-hand"]         = "vial_offhand",
    ["Witch doctor staff"]      = "witch_doctor_staff",
    ["Dragonbreath chili"]        = "dragonbreath_chili",
    ["Horned helm"]                 = "horned_helm",
    ["Armored trinket"]             = "armored_trinket",
    ["Engineer off-hand"]           = "engineer_offhand",
    ["Katana"]                      = "katana",
    ["Brewmaster robe"]             = "brewmaster_robe",
}

-- Lists that the curator considers COMPLETE.  For lists in this set, a
-- miss on an equipped item is a hard FAIL.  For lists NOT in this set
-- (partial/ongoing curation) a miss returns UNCHECKED so the player
-- isn't told "your item is wrong" when the truth is "we haven't
-- confirmed your item yet."  Update the set as each list is finalised.
HCE.CuratedComplete = HCE.CuratedComplete or {}
local COMPLETE = HCE.CuratedComplete

--- Count entries in a curated list.
local function curatedCount(list)
    if not list then return 0 end
    local n = 0
    for _ in pairs(list) do n = n + 1 end
    return n
end

--- Helper: resolve a display name for an item, using the curated note as fallback.
local function itemDisplayName(item, list)
    if item.name and item.name ~= "" then return item.name end
    local note = list and list[item.id]
    if type(note) == "string" then return note end
    return "Item #" .. item.id
end

--- Helper: check if an item in a specific slot is in a curated list.
local function slotInCurated(state, slotID, listName)
    local list = CURATED[listName]
    if not list then return UNCHECKED, "Curated list '" .. listName .. "' not defined" end
    local count = curatedCount(list)
    if count == 0 then
        return UNCHECKED, "Needs curated item IDs (Milestone 7)"
    end
    local item = state[slotID]
    if not item then
        return FAIL, "Nothing equipped in this slot"
    end
    if list[item.id] then
        return PASS, itemDisplayName(item, list) .. " is on the approved list"
    end
    -- Partial curation: treat a miss as UNCHECKED, not FAIL.
    local dname = itemDisplayName(item, list)
    if not COMPLETE[listName] then
        return UNCHECKED, string.format(
            "%s isn't on the curated list yet (%d item%s approved so far)",
            dname, count, count == 1 and "" or "s"
        )
    end
    return FAIL, dname .. " is not on the approved list"
end

--- Helper: check if any of several slots has an item in a curated list.
local function anySlotInCurated(state, slotIDs, listName)
    local list = CURATED[listName]
    if not list then return UNCHECKED, "Curated list not defined" end
    local count = curatedCount(list)
    if count == 0 then
        return UNCHECKED, "Needs curated item IDs (Milestone 7)"
    end
    for _, sid in ipairs(slotIDs) do
        local item = state[sid]
        if item and list[item.id] then
            return PASS, itemDisplayName(item, list) .. " is on the approved list"
        end
    end
    -- Partial curation: UNCHECKED rather than FAIL.
    if not COMPLETE[listName] then
        return UNCHECKED, string.format(
            "No approved item found yet (%d item%s curated so far)",
            count, count == 1 and "" or "s"
        )
    end
    return FAIL, "No matching item found in checked slots"
end

-- Register curated rules (all return UNCHECKED until lists are populated)

R("Flask trinket", function(state)
    return anySlotInCurated(state, { SLOT.TRINKET0, SLOT.TRINKET1 }, "flask_trinkets")
end)

R("Lunar festival suit", function(state)
    return slotInCurated(state, SLOT.CHEST, "lunar_festival_suit")
end)

R("Kilt", function(state)
    return slotInCurated(state, SLOT.LEGS, "kilt")
end)

R("Firestone", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "firestone")
end)

R("Necromancer hat", function(state)
    return slotInCurated(state, SLOT.HEAD, "wizard_hat")
end)

R("Spellstone", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "spellstone")
end)

R("Cowl", function(state)
    return slotInCurated(state, SLOT.HEAD, "cowl")
end)

R("Captain's hat", function(state)
    return slotInCurated(state, SLOT.HEAD, "captains_hat")
end)

R("Rapier, cutlass, or harpoon", function(state)
    return anySlotInCurated(state, { SLOT.MAINHAND, SLOT.OFFHAND }, "rapier_cutlass_harpoon")
end)

R("Wolf helm", function(state)
    return slotInCurated(state, SLOT.HEAD, "wolf_helm")
end)

R("Powershifting helm", function(state)
    return slotInCurated(state, SLOT.HEAD, "powershifting_helm")
end)

R("Pole", function(state)
    return slotInCurated(state, SLOT.MAINHAND, "pole")
end)

R("Anti-beast cloak", function(state)
    return slotInCurated(state, SLOT.BACK, "anti_beast_cloak")
end)

R("Anti-beast gloves", function(state)
    return slotInCurated(state, SLOT.HANDS, "anti_beast_gloves")
end)

R("Anti-beast melee weapon", function(state)
    return anySlotInCurated(state, { SLOT.MAINHAND, SLOT.OFFHAND }, "anti_beast_melee")
end)

R("Anti-beast ranged weapon", function(state)
    return slotInCurated(state, SLOT.RANGED, "anti_beast_ranged")
end)

R("Voodoo mask", function(state)
    return slotInCurated(state, SLOT.HEAD, "voodoo_mask")
end)

R("Cursed amulet", function(state)
    return slotInCurated(state, SLOT.NECK, "cursed_amulet")
end)

R("Shell shield", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "shell_shield")
end)

R("Torch", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "torch")
end)

R("Guild tabard", function(state)
    return slotInCurated(state, SLOT.TABARD, "guild_tabard")
end)

R("Blue shirt", function(state)
    return slotInCurated(state, SLOT.SHIRT, "blue_shirt")
end)

R("Insignia", function(state)
    return anySlotInCurated(state, { SLOT.TRINKET0, SLOT.TRINKET1 }, "insignia")
end)

R("Engineer off-hand", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "engineer_offhand")
end)

R("Argent Dawn trinket", function(state)
    return anySlotInCurated(state, { SLOT.TRINKET0, SLOT.TRINKET1 }, "argent_dawn_trinket")
end)

R("Herb pouch", function(state)
    -- Herb pouches are bags (bag slots 1-4 in Classic).
    -- GetInventoryItemID doesn't reliably return IDs for bag slots in
    -- 1.15.x, so we try multiple approaches:
    --   1. Parse item ID from GetInventoryItemLink (bag inventory slots)
    --   2. Match bag name via C_Container.GetBagName
    local list = CURATED.herb_pouch
    local count = curatedCount(list)
    if count == 0 then
        return UNCHECKED, "Needs curated item IDs"
    end

    -- Build a set of approved bag names for name-based matching
    local approvedNames = {}
    for id, note in pairs(list) do
        if type(id) == "number" then
            local name = GetItemInfo(id)
            if name then approvedNames[name:lower()] = id end
        end
    end

    for bag = 1, 4 do
        -- Method 1: item link from inventory slot (slots 20-23)
        local invSlot = bag + 19
        local link = GetInventoryItemLink("player", invSlot)
        if link then
            local linkID = tonumber(link:match("item:(%d+)"))
            if linkID and list[linkID] then
                local name = GetItemInfo(linkID)
                return PASS, (name or "item " .. linkID) .. " equipped in bag slot " .. bag
            end
        end
        -- Method 2: bag name via C_Container
        if C_Container and C_Container.GetBagName then
            local bagName = C_Container.GetBagName(bag)
            if bagName and approvedNames[bagName:lower()] then
                return PASS, bagName .. " equipped in bag slot " .. bag
            end
        end
    end
    if COMPLETE.herb_pouch then
        return FAIL, "No herb pouch found in any bag slot"
    end
    return UNCHECKED, string.format("No herb pouch found (%d item%s on approved list)", count, count == 1 and "" or "s")
end)

R("Unholy weapon", function(state)
    -- Check main-hand and off-hand via tooltip scanning
    for _, slotID in ipairs({ SLOT.MAINHAND, SLOT.OFFHAND }) do
        local item = state[slotID]
        if item then
            local match = slotTooltipHas(slotID, "unholy")
            if match then
                return PASS, item.name .. " has " .. match
            end
        end
    end
    local mh = state[SLOT.MAINHAND]
    local oh = state[SLOT.OFFHAND]
    if not mh and not oh then
        return FAIL, "No weapon equipped"
    end
    local weapName = mh and mh.name or (oh and oh.name or "?")
    return FAIL, weapName .. " — no Unholy Weapon enchant detected"
end)

R("Shadow or fire wand", function(state)
    if not slotHasWeaponSub(state, SLOT.RANGED, WANDS) then
        return FAIL, "No wand equipped"
    end
    local item = state[SLOT.RANGED]
    local shadow = slotTooltipHas(SLOT.RANGED, "shadow damage")
    if shadow then
        return PASS, (item.name or "?") .. " — " .. shadow
    end
    local fire = slotTooltipHas(SLOT.RANGED, "fire damage")
    if fire then
        return PASS, (item.name or "?") .. " — " .. fire
    end
    return FAIL, (item.name or "?") .. " — not a shadow or fire wand"
end)

R("Shadow wand", function(state)
    if not slotHasWeaponSub(state, SLOT.RANGED, WANDS) then
        return FAIL, "No wand equipped"
    end
    local item = state[SLOT.RANGED]
    local shadow = slotTooltipHas(SLOT.RANGED, "shadow damage")
    if shadow then
        return PASS, (item.name or "?") .. " — " .. shadow
    end
    return FAIL, (item.name or "?") .. " — not a shadow wand"
end)

R("Nature wand", function(state)
    if not slotHasWeaponSub(state, SLOT.RANGED, WANDS) then
        return FAIL, "No wand equipped"
    end
    local item = state[SLOT.RANGED]
    local nature = slotTooltipHas(SLOT.RANGED, "nature damage")
    if nature then
        return PASS, (item.name or "?") .. " — " .. nature
    end
    return FAIL, (item.name or "?") .. " — not a nature wand"
end)

R("Frost wand", function(state)
    if not slotHasWeaponSub(state, SLOT.RANGED, WANDS) then
        return FAIL, "No wand equipped"
    end
    local item = state[SLOT.RANGED]
    local frost = slotTooltipHas(SLOT.RANGED, "frost damage")
    if frost then
        return PASS, (item.name or "?") .. " — " .. frost
    end
    return FAIL, (item.name or "?") .. " — not a frost wand"
end)

R("Arcane wand", function(state)
    if not slotHasWeaponSub(state, SLOT.RANGED, WANDS) then
        return FAIL, "No wand equipped"
    end
    local item = state[SLOT.RANGED]
    local arcane = slotTooltipHas(SLOT.RANGED, "arcane damage")
    if arcane then
        return PASS, (item.name or "?") .. " — " .. arcane
    end
    return FAIL, (item.name or "?") .. " — not a arcane wand"
end)

R("Flying Tiger Goggles", function(state)
    return slotInCurated(state, SLOT.HEAD, "flying_tiger_goggles")
end)

R("Green-tinted goggles", function(state)
    return slotInCurated(state, SLOT.HEAD, "green_tinted_goggles")
end)

R("Gnomish goggles", function(state)
    return slotInCurated(state, SLOT.HEAD, "gnomish_goggles")
end)

R("Witch doctor staff", function(state)
    return slotInCurated(state, SLOT.MAINHAND, "witch_doctor_staff")
end)

R("Brewmaster robe", function(state)
    return slotInCurated(state, SLOT.CHEST, "brewmaster_robe")
end)

R("Jungle remedy", function(state)
    -- Jungle Remedy is a consumable carried in bags.
    -- Scan all bag slots for the item.
    local list = CURATED.jungle_remedy
    local count = curatedCount(list)
    if count == 0 then
        return UNCHECKED, "Needs curated item IDs"
    end
    local getBagItem = (C_Container and C_Container.GetContainerItemID)
                       or GetContainerItemID
    if getBagItem then
        for bag = 0, 4 do
            local numSlots = 0
            if C_Container and C_Container.GetContainerNumSlots then
                numSlots = C_Container.GetContainerNumSlots(bag) or 0
            elseif GetContainerNumSlots then
                numSlots = GetContainerNumSlots(bag) or 0
            end
            for slot = 1, numSlots do
                local itemID = getBagItem(bag, slot)
                if itemID and list[itemID] then
                    local name = GetItemInfo(itemID)
                    return PASS, (name or "item " .. itemID) .. " found in bags"
                end
            end
        end
    end
    if COMPLETE.jungle_remedy then
        return FAIL, "No Jungle Remedy found in bags"
    end
    return UNCHECKED, "No Jungle Remedy found in bags (list may be incomplete)"
end)

R("Dragonbreath chili", function(state)
    -- Scan all bag slots for the item.
    local list = CURATED.dragonbreath_chili
    local count = curatedCount(list)
    if count == 0 then
        return UNCHECKED, "Needs curated item IDs"
    end
    local getBagItem = (C_Container and C_Container.GetContainerItemID)
                       or GetContainerItemID
    if getBagItem then
        for bag = 0, 4 do
            local numSlots = 0
            if C_Container and C_Container.GetContainerNumSlots then
                numSlots = C_Container.GetContainerNumSlots(bag) or 0
            elseif GetContainerNumSlots then
                numSlots = GetContainerNumSlots(bag) or 0
            end
            for slot = 1, numSlots do
                local itemID = getBagItem(bag, slot)
                if itemID and list[itemID] then
                    local name = GetItemInfo(itemID)
                    return PASS, (name or "item " .. itemID) .. " found in bags"
                end
            end
        end
    end
    if COMPLETE.dragonbreath_chili then
        return FAIL, "No Dragonbreath chili found in bags"
    end
    return UNCHECKED, "No Dragonbreath chili found in bags (list may be incomplete)"
end)

R("Restoration potion", function(state)
    -- Restorative Potion is a consumable carried in bags.
    local list = CURATED.restoration_potion
    local count = curatedCount(list)
    if count == 0 then
        return UNCHECKED, "Needs curated item IDs"
    end
    local getBagItem = (C_Container and C_Container.GetContainerItemID)
                       or GetContainerItemID
    if getBagItem then
        for bag = 0, 4 do
            local numSlots = 0
            if C_Container and C_Container.GetContainerNumSlots then
                numSlots = C_Container.GetContainerNumSlots(bag) or 0
            elseif GetContainerNumSlots then
                numSlots = GetContainerNumSlots(bag) or 0
            end
            for slot = 1, numSlots do
                local itemID = getBagItem(bag, slot)
                if itemID and list[itemID] then
                    local name = GetItemInfo(itemID)
                    return PASS, (name or "item " .. itemID) .. " found in bags"
                end
            end
        end
    end
    if COMPLETE.restoration_potion then
        return FAIL, "No Restorative Potion found in bags"
    end
    return UNCHECKED, "No Restorative Potion found in bags (list may be incomplete)"
end)

R("Armored weapon", function(state)
    return anySlotInCurated(state, { SLOT.MAINHAND, SLOT.OFFHAND }, "armored_weapon")
end)

R("Armored off-hand", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "armored_offhand")
end)

R("Armored rings", function(state)
    local list = CURATED.armored_rings
    if not list then return UNCHECKED, "Curated list not defined" end
    local count = curatedCount(list)
    if count == 0 then
        return UNCHECKED, "Needs curated item IDs (Milestone 7)"
    end
    local r0 = state[SLOT.FINGER0]
    local r1 = state[SLOT.FINGER1]
    local ok0 = r0 and list[r0.id]
    local ok1 = r1 and list[r1.id]
    if ok0 and ok1 then
        return PASS, (r0.name or "?") .. " + " .. (r1.name or "?") .. " — both armored"
    end
    if not COMPLETE.armored_rings then
        local found = (ok0 or ok1) and 1 or 0
        return UNCHECKED, found .. " of 2 armored rings verified (" .. count .. " items curated)"
    end
    if ok0 or ok1 then
        local good = ok0 and r0 or r1
        local bad  = ok0 and r1 or r0
        return FAIL, (good.name or "?") .. " is armored, but " .. (bad and bad.name or "empty slot") .. " is not"
    end
    return FAIL, "Neither ring is on the armored list"
end)

R("Armored ring", function(state)
    return anySlotInCurated(state, { SLOT.FINGER0, SLOT.FINGER1 }, "armored_rings")
end)

R("Staff-like off-hand", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "staff_like_offhand")
end)

R("Skull off-hand", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "skull_offhand")
end)

R("Horned helm", function(state)
    return slotInCurated(state, SLOT.HEAD, "horned_helm")
end)

R("Vial off-hand", function(state)
    return slotInCurated(state, SLOT.OFFHAND, "vial_offhand")
end)

R("Katana", function(state)
    return slotInCurated(state, SLOT.MAINHAND, "katana")
end)

R("Armored trinket", function(state)
    return anySlotInCurated(state, { SLOT.TRINKET0, SLOT.TRINKET1 }, "armored_trinket")
end)

----------------------------------------------------------------------
-- STAT THRESHOLD RULES
----------------------------------------------------------------------
-- WoW API:
--   UnitStat("player", statIndex)  → stat, effectiveStat, ...
--     1=Str, 2=Agi, 3=Sta, 4=Int, 5=Spi
--   UnitAttackPower("player")      → base, posBuff, negBuff
--   UnitArmor("player")            → base, effectiveArmor, ...

local function checkStat(statIndex, threshold, statName)
    local stat = select(2, UnitStat("player", statIndex))
    if not stat then return UNCHECKED, statName .. " data unavailable" end
    stat = math.floor(stat)
    if stat >= threshold then
        return PASS, statName .. ": " .. stat .. " / " .. threshold
    else
        return FAIL, statName .. ": " .. stat .. " / " .. threshold .. " (need " .. (threshold - stat) .. " more)"
    end
end

local function checkAP(threshold)
    local base, posBuff, negBuff = UnitAttackPower("player")
    if not base then return UNCHECKED, "Attack power data unavailable" end
    local total = base + posBuff + negBuff
    total = math.floor(total)
    if total >= threshold then
        return PASS, "Attack power: " .. total .. " / " .. threshold
    else
        return FAIL, "Attack power: " .. total .. " / " .. threshold .. " (need " .. (threshold - total) .. " more)"
    end
end

local function checkArmor(threshold)
    local _, effective = UnitArmor("player")
    if not effective then return UNCHECKED, "Armor data unavailable" end
    effective = math.floor(effective)
    if effective >= threshold then
        return PASS, "Armor: " .. effective .. " / " .. threshold
    else
        return FAIL, "Armor: " .. effective .. " / " .. threshold .. " (need " .. (threshold - effective) .. " more)"
    end
end

R("120 attack power", function(state)
    return checkAP(120)
end)

R("180 intellect", function(state)
    return checkStat(4, 180, "Intellect")
end)

R("250 intellect", function(state)
    return checkStat(4, 250, "Intellect")
end)

R("180 spirit", function(state)
    return checkStat(5, 180, "Spirit")
end)

R("250 spirit", function(state)
    return checkStat(5, 250, "Spirit")
end)

R("1200 armor", function(state)
    return checkArmor(1200)
end)

R("3000 armor", function(state)
    return checkArmor(3000)
end)

R("800 armor", function(state)
    return checkArmor(800)
end)

R("100 strength & spirit", function(state)
    local r1, m1 = checkStat(1, 100, "Strength")
    local r2, m2 = checkStat(5, 100, "Spirit")
    if r1 == FAIL or r2 == FAIL then
        return FAIL, m1 .. " | " .. m2
    end
    if r1 == UNCHECKED or r2 == UNCHECKED then
        return UNCHECKED, m1 .. " | " .. m2
    end
    return PASS, m1 .. " | " .. m2
end)

R("150 strength & spirit", function(state)
    local r1, m1 = checkStat(1, 150, "Strength")
    local r2, m2 = checkStat(5, 150, "Spirit")
    if r1 == FAIL or r2 == FAIL then
        return FAIL, m1 .. " | " .. m2
    end
    if r1 == UNCHECKED or r2 == UNCHECKED then
        return UNCHECKED, m1 .. " | " .. m2
    end
    return PASS, m1 .. " | " .. m2
end)

R("140 stamina", function(state)
    return checkStat(3, 140, "Stamina")
end)

R("180 stamina", function(state)
    return checkStat(3, 180, "Stamina")
end)

----------------------------------------------------------------------
-- WEAPON SPEED RULES
----------------------------------------------------------------------

R("1.5 speed dagger", function(state)
    -- Check both weapon slots for a dagger with 1.50 speed
    for _, slotID in ipairs({ SLOT.MAINHAND, SLOT.OFFHAND }) do
        local item = state[slotID]
        if item and item.classID == WEAPON_CLASS and DAGGERS[item.subclassID] then
            -- Scan tooltip for "Speed X.XX" line
            local speedLine = slotTooltipHas(slotID, "speed")
            if speedLine then
                local spd = speedLine:match("(%d+%.?%d*)")
                if spd and tonumber(spd) == 1.5 then
                    return PASS, item.name .. " — Speed 1.50"
                elseif spd then
                    return FAIL, item.name .. " — Speed " .. spd .. " (need 1.50)"
                end
            end
            -- Couldn't parse speed from tooltip
            return FAIL, item.name .. " — could not read weapon speed"
        end
    end
    return FAIL, "No dagger equipped"
end)

----------------------------------------------------------------------
-- Rule lookup and execution
----------------------------------------------------------------------

--- Look up the rule for an equipment requirement description.
--- @param desc string  The requirement description from CharacterData
--- @return function|nil  The rule checker, or nil if no rule matches
function EQ.FindRule(desc)
    if not desc then return nil end
    return rules[desc:lower()]
end

--- Run all equipment requirement checks for the current character.
--- Returns a table of results keyed by equipment index (matching the
--- order in char.equipment).
--- @return table  { [index] = { status, detail, desc } }
function EQ.CheckAll()
    local results = {}
    if not HCE_CharDB then return results end

    local key = HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then return results end

    local playerLevel = UnitLevel("player") or 1
    local state = EQ.Snapshot()

    for i, eq in ipairs(char.equipment or {}) do
        if eq.endLevel and playerLevel > eq.endLevel then
            -- Superseded by the next tier
            results[i] = { status = "inactive", detail = "Superseded (was lv " .. eq.level .. "-" .. eq.endLevel .. ")", desc = eq.desc }
        elseif playerLevel >= eq.level then
            -- This requirement is active — check it
            local rule = EQ.FindRule(eq.desc)
            if rule then
                local status, detail = rule(state)
                results[i] = { status = status, detail = detail, desc = eq.desc }
            else
                results[i] = { status = UNCHECKED, detail = "No rule defined for this requirement", desc = eq.desc }
            end
        else
            -- Not yet active — skip
            results[i] = { status = "inactive", detail = "Unlocks at level " .. eq.level, desc = eq.desc }
        end
    end

    return results
end

----------------------------------------------------------------------
-- Persistent state: store last check results in HCE_CharDB so the
-- requirements panel can display them without re-scanning.
----------------------------------------------------------------------

--- Run a full check and store results.  Returns the results table.
function EQ.RunCheck()
    local results = EQ.CheckAll()
    if HCE_CharDB then
        HCE_CharDB.equipResults = results
    end
    return results
end

--- Get stored results (from last check).
function EQ.GetResults()
    return HCE_CharDB and HCE_CharDB.equipResults or {}
end

----------------------------------------------------------------------
-- Chat warning for violations
----------------------------------------------------------------------

local CHAT_PREFIX = "|cffe6b422[HCE]|r "

local function warnViolation(desc, detail)
    if HCE.ChatWarningsEnabled and not HCE.ChatWarningsEnabled() then return end
    DEFAULT_CHAT_FRAME:AddMessage(
        CHAT_PREFIX .. "|cffff5555Equipment violation:|r " .. desc ..
        (detail and (" — " .. detail) or "")
    )
end

--- Run checks and print warnings for any newly-failed requirements.
--- Compares against previous results to avoid spamming the same warning
--- repeatedly on every equipment change.  New violations also trigger
--- a forbidden-item toast + screen-edge flash via ForbiddenAlert.
function EQ.CheckAndWarn()
    local oldResults = EQ.GetResults()
    -- Snapshot the old results before RunCheck() overwrites them.
    -- pairs() gives a live view into HCE_CharDB.equipResults, and
    -- RunCheck() writes into that same table, so we copy the status
    -- values we need up front.
    local oldStatus = {}
    for i, r in pairs(oldResults) do oldStatus[i] = r.status end

    local newResults = EQ.RunCheck()

    -- Collect NEW violations (fail now, not failing before).  We batch
    -- them through ForbiddenAlert so a first-login with multiple bad
    -- items doesn't fire a strobe of flashes + chimes.
    local newViolations = {}
    for i, res in pairs(newResults) do
        if res.status == FAIL then
            local was = oldStatus[i]
            if was ~= FAIL then
                warnViolation(res.desc, res.detail)
                table.insert(newViolations, { desc = res.desc, detail = res.detail })
            end
        end
    end

    if #newViolations > 0 and HCE.ForbiddenAlert and HCE.ForbiddenAlert.FireBatch then
        HCE.ForbiddenAlert.FireBatch(newViolations)
    end

    -- Refresh the panel to show updated indicators
    if HCE.RefreshPanel then HCE.RefreshPanel() end
end

----------------------------------------------------------------------
-- Expose status constants for other modules (RequirementsPanel)
----------------------------------------------------------------------

EQ.STATUS = {
    PASS      = PASS,
    FAIL      = FAIL,
    UNCHECKED = UNCHECKED,
}

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eventFrame:RegisterEvent("BAG_UPDATE")

-- Track whether we've done the initial check (defer until data is ready)
local initialCheckDone = false

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer so SavedVariables, CharacterData, and item cache are ready.
        -- GetItemInfo may return nil for uncached items on first login,
        -- so we do a second pass after a longer delay.
        C_Timer.After(2.0, function()
            EQ.RunCheck()
            initialCheckDone = true
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
        -- Second pass to catch any items that weren't cached
        C_Timer.After(5.0, function()
            EQ.CheckAndWarn()
        end)

    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if not initialCheckDone then return end
        -- Small delay to let GetItemInfo cache the new item
        C_Timer.After(0.3, function()
            EQ.CheckAndWarn()
        end)

    elseif event == "BAG_UPDATE" then
        if not initialCheckDone then return end
        -- Bag contents changed — re-check bag-item requirements
        -- (herb pouch, jungle remedy, restoration potion).
        -- Use a slightly longer delay so rapid bag shuffles coalesce.
        C_Timer.After(0.5, function()
            EQ.RunCheck()
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
    end
end)
