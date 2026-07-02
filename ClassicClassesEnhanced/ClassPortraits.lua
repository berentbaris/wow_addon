----------------------------------------------------------------------
-- ClassicClassesEnhanced — Class Background Art
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
--   2. Put it in: ClassicClassesEnhanced/Backgrounds/
--   3. Add an entry below mapping the character name to the path
--
-- The path format is:
--   "Interface\\AddOns\\ClassicClassesEnhanced\\Backgrounds\\filename"
--   (no .tga extension — WoW finds it automatically)
----------------------------------------------------------------------

CCE = CCE or {}

local BG = "Interface\\AddOns\\ClassicClassesEnhanced\\Backgrounds\\"

--- Map of character name → background texture path.
--- Characters not listed here will show no background image.
CCE.ClassBackgrounds = {
    -- WARRIOR
    ["Mountain King"]   = BG .. "mountain_king",
    ["Brewmaster"]      = BG .. "brewmaster",
    ["Blademaster"]     = BG .. "blademaster",
    ["Brave"]           = BG .. "brave",
    ["Berserker"]       = BG .. "berserker",
    ["Runemaster"]       = BG .. "Runemaster",
    ["Sister of Steel"] = BG .. "Sistersteel",
    ["Tinker"]    = BG .. "tinker",
    -- ROGUE
    ["Demon Hunter"]       = BG .. "DH",
    ["Warden"]          = BG .. "warden",
    ["Buccaneer"]       = BG .. "Buccaneer",
    ["Barbarian"]    = BG .. "barbarian",
    ["Prospector"]      = BG .. "pros",
    ["Ranger"]      = BG .. "dark_ranger",
    -- HUNTER
    ["Elven Archer"]    = BG .. "ElvenRanger",
    ["Beastmaster"]     = BG .. "Orcbeastmaster",
    ["Mountaineer"]     = BG .. "Mountaineer",
    ["Wilderness Stalker"] = BG .. "Wildernessstalker",
    -- MAGE
    ["Bloodmage"]       = BG .. "Bloodmage",
    ["Techno-mage"]     = BG .. "Techno-mage",
    ["Spellblade"]      = BG .. "Spellblade",
    ["Hedge Wizard"]    = BG .. "Hedgewizard",
    ["Archmage of Kirin Tor"]    = BG .. "kirin_tor",
    -- WARLOCK
    ["Pyremaster"]      = BG .. "Pyremaster",
    ["Death Knight"]    = BG .. "Death_Knight",
    ["Necromancer"]     = BG .. "Necromancer",
    -- DRUID
    ["Druid of the Claw"] = BG .. "Claw",
    ["Plagueshifter"]   = BG .. "Plagueshifter",
    ["Savagekin"]       = BG .. "Savagekin",
    ["Ley Walker"]     = BG .. "ley",
    -- PRIEST
    ["Priestess of the Moon"] = BG .. "Moon",
    ["Apothecary"]      = BG .. "Apothecary",
    ["Shadow Hunter"]   = BG .. "shadow_hunter",
    ["Lightslayer"]     = BG .. "Lightslayer",
    -- SHAMAN
    ["Earthcaller"]     = BG .. "Earthcaller",
    ["Witch Doctor"]    = BG .. "witch_doctor",
    ["Spiritwalker"]    = BG .. "spirit_walk",
    ["Spirit Champion"]    = BG .. "spirit_champ",
    -- PALADIN
    ["Exemplar"]        = BG .. "Exemplar",
    ["Templar"]         = BG .. "Templar",
    ["Scarlet Champion"]         = BG .. "scarlet_champ",
}
