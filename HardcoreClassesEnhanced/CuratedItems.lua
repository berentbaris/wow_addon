----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Curated Item ID Lists
--
-- This file populates HCE.CuratedItems (defined in EquipmentCheck.lua)
-- with specific WoW Classic item IDs for visual/thematic equipment
-- requirements that cannot be detected by item type alone.
--
-- Each list maps itemID -> a short provenance comment.  EquipmentCheck
-- only cares about key existence, but the value lets us keep a paper
-- trail of where each ID was verified (Wowhead Classic filter/slug).
--
-- A "confirmed" item is one whose ID and visual/thematic fit have both
-- been verified.  A list that still reads "-- TODO(M7): ..." means the
-- equipment rule should continue returning UNCHECKED for that
-- requirement until curation finishes in Milestone 7.
--
-- Naming convention:  list name matches the key used in EQ.CURATED /
-- HCE.CuratedItems, so the rule registrations in EquipmentCheck don't
-- need to change.
----------------------------------------------------------------------

HCE = HCE or {}

-- Nothing to merge into if EquipmentCheck failed to load, but make a
-- defensive empty table so errors are loud and local rather than
-- silent nil-index explosions later.
HCE.CuratedItems = HCE.CuratedItems or {}
HCE.CuratedComplete = HCE.CuratedComplete or {}
local C = HCE.CuratedItems
local COMPLETE = HCE.CuratedComplete

----------------------------------------------------------------------
-- Helper: fold a list of {itemID, "note"} pairs into the target table.
----------------------------------------------------------------------

local function fill(target, entries)
    for _, pair in ipairs(entries) do
        target[pair[1]] = pair[2] or true
    end
end

----------------------------------------------------------------------
-- Engineering goggles / headgear (Mechano-Mage)
--
-- Engineering-crafted goggles are distinctive and finite; the full set
-- of "goggles"-looking headpieces is well-defined.  IDs verified
-- against Wowhead Classic (classic.wowhead.com).
----------------------------------------------------------------------

-- "Flying Tiger Goggles" requirement — the named recipe item.
-- Single definitive item; mark as complete.
fill(C.flying_tiger_goggles, {
    { 4368, "Flying Tiger Goggles — Engineering 135" },
})
COMPLETE.flying_tiger_goggles = true

-- "Green-tinted goggles" requirement — green-lens / tinted eyewear
fill(C.green_tinted_goggles, {
    { 4385, "Green Tinted Goggles — Engineering 80" },
    { 10500, "Green Lens — Gnomish Engineering" },
})

-- "Gnomish goggles" requirement — Gnomish / advanced engineering headgear
fill(C.gnomish_goggles, {
    { 10500, "Green Lens — Gnomish Engineering" },
    { 10501, "Deepdive Helmet — Gnomish Engineering" },
    { 10546, "Gnomish Mind Control Cap — Gnomish Engineering" },
    { 10548, "Goblin Rocket Helmet — Goblin Engineering" },
    -- TODO(M7): confirm remaining Gnomish/Goblin engineer helms with goggle art.
})

----------------------------------------------------------------------
-- Warlock Firestones / Spellstones (Pyremaster, Shadowmage)
--
-- Summoned off-hand items from warlock class spells.  IDs stable since
-- vanilla; only the three ranks exist in Classic.
----------------------------------------------------------------------

fill(C.firestone, {
    { 1254,  "Firestone — rank 1 (lvl 28)" },
    { 13699, "Greater Firestone — rank 2 (lvl 40)" },
    { 13700, "Major Firestone — rank 3 (lvl 50)" },
})
COMPLETE.firestone = true

fill(C.spellstone, {
    { 5522,  "Spellstone — rank 1 (lvl 30)" },
    { 13602, "Greater Spellstone — rank 2 (lvl 40)" },
    { 13603, "Major Spellstone — rank 3 (lvl 50)" },
})
COMPLETE.spellstone = true

----------------------------------------------------------------------
-- Wolf helm (Beastmaster)
--
-- Wolfshead Helm is the canonical wolf-themed helm in Classic: a
-- leatherworking-crafted druid set piece with a literal wolf's head
-- model.  A second loot-based wolf-appearance helm exists as well.
----------------------------------------------------------------------

fill(C.wolf_helm, {
    { 8345, "Wolfshead Helm — Leatherworking" },
    -- TODO(M7): add Wolfmane Wristguards? No — wrists, not helm.
    -- TODO(M7): add "Worg Pup" cosmetic? No — companion item.
})

----------------------------------------------------------------------
-- Guild tabard (Exemplar)
--
-- The generic guild-rank tabard is a single known item.  Custom /
-- special-event tabards (PvP, faction, etc.) are deliberately NOT
-- included here — the Exemplar requirement is specifically about
-- wearing your own guild's colours.
----------------------------------------------------------------------

fill(C.guild_tabard, {
    { 5976, "Guild Tabard — worn to display guild tabard" },
})
COMPLETE.guild_tabard = true

----------------------------------------------------------------------
-- Lunar Festival suit (Brewmaster)
--
-- Holiday event reward from Elders during Lunar Festival.  Items are
-- simple cosmetic / white-quality formal wear with lanterns.
----------------------------------------------------------------------

fill(C.lunar_festival_suit, {
    { 21509, "Festival Dress — Lunar Festival reward" },
    { 21510, "Festival Suit — Lunar Festival reward" },
    -- TODO(M7): confirm IDs for Pink Festival Suit / Red Festival Dress variants.
})

----------------------------------------------------------------------
-- Blue shirt (Exemplar)
--
-- "Blue" here means colour of the shirt model.  Shirt slot (slot 4) is
-- cosmetic only.  List restricted to items whose visible colour reads
-- as clearly blue.
----------------------------------------------------------------------

fill(C.blue_shirt, {
    { 1770, "Blue Linen Shirt" },
    { 2575, "Blue Martial Shirt" },
    -- TODO(M7): add Azure Silk Vest (if classified as shirt), Bold Blue Shirt, etc.
})

----------------------------------------------------------------------
-- Captain's hat (Buccaneer) — pirate / naval tricorne headgear
--
-- The "captain" theme in Classic covers pirate-tricorne items and
-- naval-style hats.  Population starts with First Mate Hat (a known
-- pirate quest reward).  The rest are TODO(M7).
----------------------------------------------------------------------

fill(C.captains_hat, {
    { 12251, "First Mate Hat — Blackwater Raiders quest reward" },
    -- TODO(M7): Admiral's Hat, Buccaneer's Bandana, Tricorne variants
})

----------------------------------------------------------------------
-- Rapier / cutlass / harpoon (Buccaneer)
--
-- Pirate / swashbuckler one-handed weapons.  Cutlass-named and
-- Rapier-named swords count; Harpoon is a specific thrown/polearm.
----------------------------------------------------------------------

fill(C.rapier_cutlass_harpoon, {
    -- TODO(M7): populate with confirmed Wowhead Classic IDs for:
    --   Common Cutlass, Corsair's Overshirt (no — chest), Krol Blade,
    --   "Harpoon" thrown weapon, Rapier of the Nobles.
})

----------------------------------------------------------------------
-- Flask trinkets (Mountain King) — alchemy flask / bottle themed trinkets
----------------------------------------------------------------------

fill(C.flask_trinkets, {
    -- TODO(M7): populate with bottle-/flask-appearance trinket IDs.
})

----------------------------------------------------------------------
-- Insignia (Exemplar) — PvP insignia trinket
--
-- The horde/alliance PvP "Insignia" trinket is a well-known named item
-- that breaks CC.  Faction determines which one applies.
----------------------------------------------------------------------

fill(C.insignia, {
    -- TODO(M7): add Alliance / Horde PvP Insignia IDs once confirmed.
    --   Medallion of the Alliance ranks + Insignia of the Alliance (QM)
    --   Medallion of the Horde ranks + Insignia of the Horde (QM)
})

----------------------------------------------------------------------
-- Argent Dawn trinket (Templar)
--
-- Argent Dawn Commission is the canonical trinket for anti-undead work
-- in Classic.  There are also a few Argent Dawn Valor / Service
-- trinkets from quest reputation chains.
----------------------------------------------------------------------

fill(C.argent_dawn_trinket, {
    -- TODO(M7): add Argent Dawn Commission + faction-rank trinkets.
})

----------------------------------------------------------------------
-- Visual/thematic lists still awaiting Milestone 7 curation
--
-- These remain intentionally empty.  EquipmentCheck returns UNCHECKED
-- when its slot is passed a list whose key-count is zero, and the
-- requirements panel shows "? needs curation" in the hover tooltip.
----------------------------------------------------------------------

-- Kilt (Demon Hunter, Runemaster) — legs slot with kilt visual
-- TODO(M7): Barbaric Iron Breastplate is chest; need kilt-appearance legs list.

-- Cowl (Death Knight) — head slot with cowl / executioner hood visual
-- TODO(M7): Shadowcraft Cap, Deathbone Gauntlets (no, hands)...

-- Voodoo mask (Witch Doctor, Shadow Hunter) — troll ritual mask head item
-- TODO(M7): Jin'do's masks from ZG, Predator's Mask, ritual mask pool.

-- Cursed amulet (Witch Doctor) — neck item with curse/hex theme
-- TODO(M7): Cursed Amulets, Vile Fin amulets.

-- Shell shield (Witch Doctor) — shield slot with tortoise-shell visual
-- TODO(M7): Shellshield, Aged Tortoise Shield, Turtle Scale Shield.

-- Torch (Spiritwalker) — off-hand torch visual
-- TODO(M7): Torch of Holy Flame, Sentinel Torch, etc.

-- Anti-beast gear (Beastmaster) — items whose theme is bestial/skinning
-- TODO(M7): Anti-beast items are thematic-only; start with cloaks/gloves/
-- weapons that mention Beast Slaying / skinning synergy.

-- Shadow or fire wand (Bloodmage) — wand whose damage school is shadow/fire
-- TODO(M7): wands like Lavishly Jeweled Ring (no — ring)... Servo Arm
-- cannot be wand.  Real fire wands: Thuzadin Tailoring Apparatus (no).
-- Actual fire-school wands in Classic: Charred Ancient Wand, Servo Arm
-- of Flame.  Shadow wands: Ghoul Sliver... Needs DB check.

-- Unholy weapon (Bloodmage) — weapons with undead/ghoul/death theme
-- TODO(M7): Crypt Fiend weapons, Scourge blades, etc.

-- Armored weapon / off-hand / rings (Druid of the Claw, Savagekin, Warmage)
-- TODO(M7): "Armored" here implies heavy-looking plate weapons and bulky
-- ring/off-hand art.  Druid-appropriate items specifically.

-- Staff-like off-hand (Warmage) — items shown in off-hand slot that look
-- like short staves / wands / batons (visual staves that aren't the
-- staff weapon slot).
-- TODO(M7): Sceptre of Celebras, Orb-on-stick off-hands.

-- Herb pouch (Apothecary) — bag item, not equipment
-- This is detected via bag-slot scanning, not the equipment rule.
-- TODO(M7): Herb Pouch (5441), Herb Satchel, bag IDs with herbalism bonus.

-- Jungle Remedy / Restoration Potion (Plagueshifter) — consumables
-- These are bag-scanned, not equipment-scanned.
-- TODO(M7): Jungle Remedy (exact Classic ID), Restoration Potion (859/1710).

-- Mechanical companion (Mechano-Mage) — non-combat pets from Engineering
-- TODO(M7): Mechanical Chicken (10822), Mechanical Squirrel (4401),
-- Lil' Smoky (10720), Pet Bombling (10725).

----------------------------------------------------------------------
-- Summary counter (diagnostic)
--
-- Used by the requirements-panel tooltip to tell the player how many
-- items the curator has confirmed for each list.  Exposed on HCE so
-- other modules can read it without poking the private `C` upvalue.
----------------------------------------------------------------------

function HCE.CuratedCount(listName)
    local list = C[listName]
    if not list then return 0 end
    local n = 0
    for _ in pairs(list) do n = n + 1 end
    return n
end

--- Iterate all curated lists and return a {name = count} map.  Useful
--- for a future `/hce curated` diagnostic slash command.
function HCE.CuratedSummary()
    local summary = {}
    for name, list in pairs(C) do
        local n = 0
        for _ in pairs(list) do n = n + 1 end
        summary[name] = n
    end
    return summary
end
