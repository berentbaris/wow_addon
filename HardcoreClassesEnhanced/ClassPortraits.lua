----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Class Background Art
--
-- Maps each enhanced class to a background image (talent-tree style).
-- Images are .tga files in the Backgrounds/ subfolder of the addon.
--
-- WoW requires .tga (or .blp) for addon textures.
-- Recommended dimensions: 256 x 256 pixels (or 256 x 512 for tall).
--   - Power-of-two sizes are required by WoW's texture system.
--   - The image will be stretched to fill the scroll area, so square
--     or slightly tall works best.
--   - Use dark, moody art — it will be shown at ~15% opacity behind
--     white/gold text.
--
-- To add a new image:
--   1. Save your art as a .tga file (32-bit, uncompressed or RLE)
--   2. Put it in: HardcoreClassesEnhanced/Backgrounds/
--   3. Add an entry below mapping the character name to the path
--
-- The path format is:
--   "Interface\\AddOns\\HardcoreClassesEnhanced\\Backgrounds\\filename"
--   (no .tga extension — WoW finds it automatically)
----------------------------------------------------------------------

HCE = HCE or {}

local BG = "Interface\\AddOns\\HardcoreClassesEnhanced\\Backgrounds\\"

--- Map of character name → background texture path.
--- Characters not listed here will show no background image.
HCE.ClassBackgrounds = {
    -- WARRIOR
    ["Mountain King"]   = BG .. "Mountain_king",
    ["Brewmaster"]      = BG .. "brewmaster",
    ["Blademaster"]     = BG .. "Moogul",
    ["Brave"]           = BG .. "brave",
    ["Berserker"]       = BG .. "berserker",
    ["Runemaster"]       = BG .. "Runemaster",
    -- ROGUE
    ["Demon Hunter"]       = BG .. "Demonhunterfem",
    ["Warden"]          = BG .. "warden",
    ["Buccaneer"]       = BG .. "Buccaneer",
    -- ["Dark Ranger"]     = BG .. "DarkRanger",
    ["Tinker"]    = BG .. "tinker",
    ["Prospector"]      = BG .. "Dwarvenprospector",
    -- HUNTER
    ["Elven Ranger"]    = BG .. "ElvenRanger",
    ["Beastmaster"]     = BG .. "Orcbeastmaster",
    ["Mountaineer"]     = BG .. "Mountaineer",
    ["Wilderness Stalker"] = BG .. "Wildernessstalker",
    -- MAGE
    ["Bloodmage"]       = BG .. "Bloodmage",
    ["Techno-mage"]     = BG .. "Techno-mage",
    ["Spellblade"]      = BG .. "Spellblade",
    ["Hedge Wizard"]    = BG .. "Hedgewizard",
    -- WARLOCK
    ["Pyremaster"]      = BG .. "Pyremaster",
    ["Death Knight"]    = BG .. "Death_Knight",
    ["Necromancer"]     = BG .. "Necromancer",
    -- DRUID
    ["Druid of the Claw"] = BG .. "Claw",
    ["Plagueshifter"]   = BG .. "Plagueshifter",
    ["Savagekin"]       = BG .. "Savagekin",
    -- PRIEST
    ["Priestess of the Moon"] = BG .. "Moon",
    ["Apothecary"]      = BG .. "Apothecary",
    ["Shadow Hunter"]   = BG .. "ShadowHunter",
    ["Lightslayer"]     = BG .. "Lightslayer",
    -- SHAMAN
    ["Earthcaller"]     = BG .. "Earthcaller",
    ["Witch Doctor"]    = BG .. "WitchDoctor",
    ["Spiritwalker"]    = BG .. "Spirit",
    -- PALADIN
    ["Exemplar"]        = BG .. "Exemplar",
    ["Templar"]         = BG .. "Templar",
    ["Sister of Steel"] = BG .. "Sistersteel",
}
