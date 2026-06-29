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
    ["Mountain King"]   = BG .. "mountain_king",
    ["Brewmaster"]      = BG .. "brewmaster",
    ["Blademaster"]     = BG .. "blademaster",
    ["Brave"]           = BG .. "brave",
    ["Berserker"]       = BG .. "berserker",
    ["Runemaster"]       = BG .. "Runemaster",
    ["Sister of Steel"] = BG .. "Sistersteel",
    -- ROGUE
    ["Demon Hunter"]       = BG .. "DH",
    ["Warden"]          = BG .. "warden",
    ["Buccaneer"]       = BG .. "Buccaneer",
    ["Dark Ranger"]     = BG .. "dark_ranger",
    ["Tinker"]    = BG .. "tinker",
    ["Barbarian"]    = BG .. "barbarian",
    ["Prospector"]      = BG .. "pros",
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
    ["Archmage of Kirin Tor"]    = BG .. "kirin_tor",
    -- WARLOCK
    ["Pyremaster"]      = BG .. "Pyremaster",
    ["Death Knight"]    = BG .. "Death_Knight",
    ["Necromancer"]     = BG .. "Necromancer",
    ["Graven One"]     = BG .. "graven",
    -- DRUID
    ["Druid of the Claw"] = BG .. "Claw",
    ["Plagueshifter"]   = BG .. "Plagueshifter",
    ["Savagekin"]       = BG .. "Savagekin",
    ["Dragonsworn"]     = BG .. "dragonsworn",
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
