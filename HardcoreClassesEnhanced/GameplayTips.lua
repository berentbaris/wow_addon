----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Gameplay Tips
--
-- Parses the free-text "gameplay" field on each character into
-- individual tips, maps them to expanded flavour descriptions, and
-- exposes them for the RequirementsPanel and a periodic "tip of the
-- moment" chat reminder.
--
-- These are NON-REQUIRED suggestions — roleplaying flavour, not rules.
-- The panel displays them in a distinct muted-blue style so they read
-- clearly as "nice to do" rather than "must do."
----------------------------------------------------------------------

HCE = HCE or {}

local Tips = {}
HCE.GameplayTips = Tips

----------------------------------------------------------------------
-- Tip database: known keywords → expanded flavour descriptions
----------------------------------------------------------------------
-- Keys are lowercase trimmed.  Some gameplay strings are compound
-- ("Beer, treasure") so we split on comma and match each fragment.

Tips.DB = {
    ["beer"] = {
        icon  = "\240\159\141\186",  -- 🍺
        title = "Drink Up",
        desc  = "Buy and drink beer/ale/mead from innkeepers and vendors whenever you rest. Your character appreciates a cold one after a long day of slaughter.",
    },
    ["treasure"] = {
        icon  = "\240\159\146\176",  -- 💰
        title = "Treasure Hunter",
        desc  = "Seek out treasure chests, lockboxes, and hidden caches in the world. Loot every container you find — you never know what's inside.",
    },
    ["darkmoon special"] = {
        icon  = "\240\159\142\170",  -- 🎪
        title = "Darkmoon Faire Regular",
        desc  = "Visit the Darkmoon Faire whenever it's in town. Buy Darkmoon Special Reserve and drink when sober.",
    },
    ["thistle tea"] = {
        icon  = "\240\159\141\181",  -- 🍵
        title = "Thistle Tea Connoisseur",
        desc  = "Keep Thistle Tea in your bags at all times. Brew it from Swiftthistle (Briarthorn/Mageroyal) via cooking. Your energy bar will thank you.",
    },
    ["self-made enchants"] = {
        icon  = "\226\156\168",  -- ✨
        title = "Self-Enchanted",
        desc  = "Only use enchantments you cast yourself. Level Enchanting and apply your own work to your gear — no borrowing other enchanters.",
    },
    ["scrolls"] = {
        icon  = "\240\159\147\156",  -- 📜
        title = "Scroll Scribe",
        desc  = "Buy and use scrolls (Scroll of Intellect, Scroll of Strength, etc.) as consumable buffs. They are sold by librarians in major cities.",
    },
    ["campfire"] = {
        icon  = "\240\159\148\165",  -- 🔥
        title = "Cremation Ritual",
        desc  = "Light a Basic Campfire under every fallen ally to cremate and honor their legacy with a funeral.",
    },
    ["melee weaving hunter"] = {
        icon  = "\226\154\148",  -- ⚔
        title = "Melee Weave",
        desc  = "Weave melee Raptor Strike between your shots. Step in, swing, step out.",
    },
    ["melee weaving caster"] = {
        icon  = "\226\154\148",  -- ⚔
        title = "Melee Weave",
        desc  = "Weave melee auto-attacks between your channeling spells. Use a fishing pole to avoid caster melee penalty.",
    },
    ["melee weaving dagger"] = {
        icon  = "\226\154\148",  -- ⚔
        title = "Melee Weave",
        desc  = "Weave melee auto-attacks between your instant spells. Use a < 1.5 speed dagger to spam instant spells and hit with your dagger simultaneously.",
    },
    ["/roar"] = {
        icon  = "\240\159\166\129",  -- 🦁
        title = "Battle Roar",
        desc  = "Use /roar (or /charge, /flex) before engaging elite mobs or entering dungeons. Announce your presence to the world.",
    },
    ["pro-nature"] = {
        icon  = "\240\159\140\191",  -- 🌿
        title = "Nature's Ally",
        desc  = "Quest in the Barrens, Stonetalon Mountains, and Stranglethorn Vale to fight against the Venture Company (the goblin cartel that drills/mines/chops Azeroth for profit).",
    },
    ["anti-undead"] = {
        title = "Undead Slayer",
        desc  = "Seek out undead-heavy zones (Plaguelands, Duskwood, Zul'Farrak) and purge the restless dead. Carry your Argent Dawn trinket with pride.",
    },
    ["rum"] = {
        icon  = "\240\159\143\180",  -- 🏴
        title = "Pirate's Grog",
        desc  = "Keep Rum (or Grog, or Stout) in your bags. Drink before every sea-adjacent zone or whenever you spot a boat.",
    },
    ["rare pets"] = {
        icon  = "\240\159\144\190",  -- 🐾
        title = "Exotic Collector",
        desc  = "Seek out rare-spawn tameable beasts. The Rake, Broken Tooth, Echeyakee — the rarer the better. Show off your collection.",
    },
    ["hooded cloak"] = {
        icon  = "\240\159\167\165",  -- 🧥
        title = "Always Hooded",
        desc  = "Wear a hooded cloak model at all times once available. The color of your hood and cloak must match.",
    },
    ["/sit and /meditate"] = {
        icon  = "\240\159\167\152",  -- 🧘
        title = "Meditative Pauses",
        desc  = "Use /sit or /kneel between fights to roleplay meditation. Take a breath. Centre yourself. Then resume the grind.",
    },
    ["stormwind hearthstone"] = {
        icon  = "\240\159\143\160",  -- 🏠 (house)
        title = "Capital Loyalist",
        desc  = "Keep your hearthstone set to Stormwind. For the Alliance!",
    },
    ["spirit tap + starshards"] = {
        icon  = "\226\173\144",  -- ⭐
        title = "Spirit Tap Rotation",
        desc  = "Boost your damage with Spirit Tap. Cast Starshards before the buff drops off for maximum utilization.",
    },
    ["pyroblast + arcane missiles"] = {
        icon  = "\240\159\146\165",  -- 💥
        title = "Pyroblast Opener",
        desc  = "Open every fight with Pyroblast + Arcane Missiles. This method spends all your mana at once, and allows for maximum mana regen, decreasing downtime.",
    },
    ["aoe-farmer"] = {
        icon  = "\240\159\140\128",  -- 🌀 (cyclone)
        title = "AoE Grinder",
        desc  = "Pull big packs and burn them down with AoE. Blizzard, Flamestrike, Arcane Explosion — the more mobs the better. High risk, high reward.",
    },
}

----------------------------------------------------------------------
-- Parse a gameplay string into individual tip entries
----------------------------------------------------------------------

--- Split a gameplay string like "Beer, treasure" into individual tips,
--- look each up in the DB, and return a list of { icon, title, desc }.
--- Unknown fragments get a generic entry.
function Tips.Parse(gameplayStr)
    if not gameplayStr or gameplayStr == "" then return {} end

    local result = {}
    -- Split on comma
    for fragment in gameplayStr:gmatch("[^,]+") do
        local trimmed = strtrim(fragment)
        local key = trimmed:lower()

        -- Try exact match first
        local entry = Tips.DB[key]

        -- Try partial match if exact fails
        if not entry then
            for dbKey, dbEntry in pairs(Tips.DB) do
                if key:find(dbKey, 1, true) or dbKey:find(key, 1, true) then
                    entry = dbEntry
                    break
                end
            end
        end

        if entry then
            table.insert(result, {
                icon  = entry.icon,
                title = entry.title,
                desc  = entry.desc,
                raw   = trimmed,
            })
        else
            -- Unknown tip — show it plain
            table.insert(result, {
                icon  = "\194\183",  -- · (middle dot)
                title = trimmed,
                desc  = "Roleplay suggestion: " .. trimmed,
                raw   = trimmed,
            })
        end
    end

    return result
end

----------------------------------------------------------------------
-- Get tips for the currently selected character
----------------------------------------------------------------------

function Tips.GetCurrent()
    local key = HCE_CharDB and HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key)
    if not char then return {} end
    return Tips.Parse(char.gameplay)
end

----------------------------------------------------------------------
-- Periodic "tip of the moment" chat reminder
----------------------------------------------------------------------
-- Every 15 minutes (if enabled and tips exist), print a random tip
-- in chat as a gentle roleplay nudge.

local TIP_INTERVAL = 900  -- 15 minutes in seconds
local tipTimer = nil

local function fireTipReminder()
    -- Respect chat warnings toggle
    if HCE_GlobalDB and HCE_GlobalDB.chatWarningsEnabled == false then return end
    if HCE_GlobalDB and HCE_GlobalDB.gameplayTipsEnabled == false then return end

    local tips = Tips.GetCurrent()
    if #tips == 0 then return end

    local tip = tips[math.random(#tips)]
    local GOLD_HEX = "e6c73f"
    local DIM_HEX  = "a0a0a0"
    HCE.Print("|cff" .. GOLD_HEX .. "Gameplay tip:|r " .. tip.icon .. " " .. tip.title
        .. " — |cff" .. DIM_HEX .. tip.desc .. "|r")
end

function Tips.StartReminder()
    if tipTimer then return end  -- already running
    tipTimer = C_Timer.NewTicker(TIP_INTERVAL, fireTipReminder)
end

function Tips.StopReminder()
    if tipTimer then
        tipTimer:Cancel()
        tipTimer = nil
    end
end

----------------------------------------------------------------------
-- Slash command: /hce gameplay
----------------------------------------------------------------------

function Tips.PrintStatus()
    local key = HCE_CharDB and HCE_CharDB.selectedCharacter
    if not key then
        HCE.Print("No enhanced class selected. Type |cffffd100/hce pick|r to choose one.")
        return
    end
    local char = HCE.GetCharacter and HCE.GetCharacter(key)
    if not char then
        HCE.Print("Character data not found.")
        return
    end

    if not char.gameplay or char.gameplay == "" then
        HCE.Print("Your enhanced class has no gameplay suggestions.")
        return
    end

    local tips = Tips.Parse(char.gameplay)
    local GOLD_HEX = "e6c73f"
    local classStr = char.class:sub(1, 1) .. char.class:sub(2):lower()
    HCE.Print("--- " .. char.name .. " (" .. char.spec .. " " .. classStr .. ") Gameplay Tips ---")
    HCE.Print("|cff888888These are flavour suggestions, not requirements.|r")

    for _, tip in ipairs(tips) do
        HCE.Print("  " .. tip.icon .. " |cff" .. GOLD_HEX .. tip.title .. "|r")
        HCE.Print("     " .. tip.desc)
    end

    -- Reminder toggle status
    local enabled = (HCE_GlobalDB and HCE_GlobalDB.gameplayTipsEnabled ~= false)
    if enabled then
        HCE.Print("|cff888888Periodic tip reminders: |cff00ff00ON|r (every 15 min). Toggle: /hce tips|r")
    else
        HCE.Print("|cff888888Periodic tip reminders: |cffff5555OFF|r. Toggle: /hce tips|r")
    end
end

----------------------------------------------------------------------
-- Init: start the reminder ticker on PLAYER_LOGIN (deferred)
----------------------------------------------------------------------

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    C_Timer.After(10, function()
        -- Only start if the player has tips and hasn't disabled them
        if HCE_GlobalDB and HCE_GlobalDB.gameplayTipsEnabled == false then return end
        local tips = Tips.GetCurrent()
        if #tips > 0 then
            Tips.StartReminder()
        end
    end)
end)
