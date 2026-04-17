----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Profession Tracking
--
-- Watches SKILL_LINES_CHANGED (and PLAYER_LOGIN) and checks the
-- player's professions against the selected character's requirements.
--
-- Starting at level 5, the addon verifies:
--   1. The correct professions are learned
--   2. Profession rank is keeping pace with player level
--      Expected rank formula: 5 * playerLevel
--        Level 20 → 100 skill, Level 40 → 200, Level 60 → 300
--
-- Results are stored in HCE_CharDB.profResults so the requirements
-- panel can display a PROFESSIONS section with pass/fail indicators.
--
-- Chat warnings fire once when a profession first falls behind.
-- This does NOT fire the red forbidden-item toast — being behind on
-- a profession is a softer problem than equipping a forbidden item.
--
-- Locale handling: profession names from GetSkillLineInfo() are
-- localised.  We map each required profession (English) to the set
-- of known locale-independent learn-spell IDs.  On SKILL_LINES_CHANGED
-- we read the skill list by name AND cross-reference via spell IDs
-- so non-English clients still work.  As a fast-path fallback for
-- English clients, we also do a direct name compare.
----------------------------------------------------------------------

HCE = HCE or {}

local PC = {}
HCE.ProfessionCheck = PC

----------------------------------------------------------------------
-- Status constants (shared vocabulary with EquipmentCheck)
----------------------------------------------------------------------

local PASS      = "pass"
local FAIL      = "fail"
local UNCHECKED = "unchecked"

PC.STATUS = { PASS = PASS, FAIL = FAIL, UNCHECKED = UNCHECKED }

----------------------------------------------------------------------
-- Profession-learning spell IDs (locale-independent)
--
-- Each primary profession has a "learn" spell that teaches rank 1
-- (Apprentice).  These IDs are stable across all Classic clients.
-- Secondary professions (Cooking, First Aid, Fishing) are included
-- because some characters require them.
----------------------------------------------------------------------

local PROF_SPELL_IDS = {
    -- Primary professions
    ["Alchemy"]        = { 2259 },   -- Alchemy (Apprentice)
    ["Blacksmithing"]  = { 2018 },   -- Blacksmithing (Apprentice)
    ["Enchanting"]     = { 7411 },   -- Enchanting (Apprentice)
    ["Engineering"]    = { 4036 },   -- Engineering (Apprentice)
    ["Herbalism"]      = { 2366 },   -- Herbalism (Apprentice passive)
    ["Leatherworking"] = { 2108 },   -- Leatherworking (Apprentice)
    ["Mining"]         = { 2575 },   -- Mining (Apprentice)
    ["Skinning"]       = { 8613 },   -- Skinning (Apprentice)
    ["Tailoring"]      = { 3908 },   -- Tailoring (Apprentice)

    -- Secondary professions
    ["Cooking"]        = { 2550 },   -- Cooking (Apprentice)
    ["First Aid"]      = { 3273 },   -- First Aid (Apprentice)
    ["Fishing"]        = { 7620 },   -- Fishing (Apprentice)
}

----------------------------------------------------------------------
-- Build a reverse map: spellID → English profession name.
-- At runtime we check IsSpellKnown(spellID) as a locale-safe way
-- to determine which professions the player has learned.
----------------------------------------------------------------------

local SPELL_TO_PROF = {}
for profName, spellIDs in pairs(PROF_SPELL_IDS) do
    for _, id in ipairs(spellIDs) do
        SPELL_TO_PROF[id] = profName
    end
end

----------------------------------------------------------------------
-- English → localised name cache.  Populated on first scan by
-- reading the actual skill line names and pairing them with the
-- spell-ID match.  Falls through to the English name if no mapping
-- is found (works fine on English clients).
----------------------------------------------------------------------

local localeNameCache = {}

----------------------------------------------------------------------
-- Skill-line scanning
----------------------------------------------------------------------

--- Scan the player's skill list and return a table of
--- professions the player currently knows.
--- @return table  { [englishName] = { rank = N, maxRank = M, localName = "..." }, ... }
local function ScanProfessions()
    local found = {}

    -- Pass 1: use spell IDs for locale-safe detection
    for profName, spellIDs in pairs(PROF_SPELL_IDS) do
        for _, spellID in ipairs(spellIDs) do
            if IsSpellKnown and IsSpellKnown(spellID) then
                -- We know the player has this profession.  Now find
                -- the matching skill line to read the current rank.
                found[profName] = { rank = 0, maxRank = 0, localName = profName }
                break
            end
        end
    end

    -- Pass 2: iterate skill lines to read rank numbers.
    -- GetNumSkillLines / GetSkillLineInfo exist in Classic 1.15.x.
    local numSkills = GetNumSkillLines and GetNumSkillLines() or 0
    for i = 1, numSkills do
        local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
        if not isHeader and name then
            -- Try direct English match first (fast path)
            if PROF_SPELL_IDS[name] and found[name] then
                found[name].rank     = rank or 0
                found[name].maxRank  = maxRank or 0
                found[name].localName = name
                localeNameCache[name] = name
            else
                -- Check if this line matches any spell-detected prof
                -- by looking for a profession we detected via spell ID
                -- but haven't yet found a rank for (rank still 0).
                for profName, info in pairs(found) do
                    if info.rank == 0 then
                        -- Heuristic: the localised name should start
                        -- with similar characters — but this is fragile.
                        -- Instead, if we haven't matched anything yet
                        -- and this is a non-header line with a rank,
                        -- see if the cached locale name matches.
                        if localeNameCache[profName] and localeNameCache[profName] == name then
                            info.rank    = rank or 0
                            info.maxRank = maxRank or 0
                            info.localName = name
                        end
                    end
                end
            end
        end
    end

    -- Pass 3: for any profession still at rank 0, do a second sweep
    -- matching by position heuristic.  In Classic the skill window
    -- groups professions under a "Professions" or locale-equivalent
    -- header.  We iterate again and match unmatched professions to
    -- unmatched skill lines with rank > 0.
    --
    -- We also build the locale cache here: if we've detected N
    -- professions via spells and there are exactly N non-header skill
    -- lines in the professions section, pair them up.
    local unmatchedProfs = {}
    for profName, info in pairs(found) do
        if info.rank == 0 then
            table.insert(unmatchedProfs, profName)
        end
    end

    if #unmatchedProfs > 0 then
        local unmatchedLines = {}
        local inProfSection = false
        for i = 1, numSkills do
            local name, isHeader, _, rank, _, _, maxRank = GetSkillLineInfo(i)
            if isHeader then
                -- In Classic, profession headers are localised.
                -- We can't reliably detect "Professions" vs "Trade Skills"
                -- in all locales, so we just flag any header as a potential
                -- section boundary.
                inProfSection = true
            elseif name and rank and rank > 0 then
                -- Check if this line is already matched
                local alreadyMatched = false
                for _, info in pairs(found) do
                    if info.localName == name and info.rank > 0 then
                        alreadyMatched = true
                        break
                    end
                end
                if not alreadyMatched then
                    table.insert(unmatchedLines, { name = name, rank = rank, maxRank = maxRank or 0 })
                end
            end
        end

        -- Pair up: if there's exactly one unmatched prof and one
        -- unmatched line, we have a strong match.  If counts differ
        -- we can still try, but mark results as less confident.
        if #unmatchedProfs == 1 and #unmatchedLines >= 1 then
            -- Take the first unmatched line as the match
            local profName = unmatchedProfs[1]
            local line = unmatchedLines[1]
            found[profName].rank      = line.rank
            found[profName].maxRank   = line.maxRank
            found[profName].localName = line.name
            localeNameCache[profName] = line.name
        elseif #unmatchedProfs > 0 and #unmatchedLines == #unmatchedProfs then
            -- Same count — pair by order (best we can do)
            for idx, profName in ipairs(unmatchedProfs) do
                local line = unmatchedLines[idx]
                if line then
                    found[profName].rank      = line.rank
                    found[profName].maxRank   = line.maxRank
                    found[profName].localName = line.name
                    localeNameCache[profName] = line.name
                end
            end
        end
    end

    return found
end

----------------------------------------------------------------------
-- Expected rank formula
----------------------------------------------------------------------

--- What rank should a profession be at for a given player level?
--- Linear: 5 * playerLevel, clamped to [1, 300].
--- Returns 0 below level 5 (no profession expected yet).
local function ExpectedRank(playerLevel)
    if playerLevel < 5 then return 0 end
    local expected = 5 * playerLevel
    if expected > 300 then expected = 300 end
    return expected
end

----------------------------------------------------------------------
-- Checking logic
----------------------------------------------------------------------

--- Run profession checks for the current character.
--- @return table  { [profName] = { status, detail, rank, expected } }
function PC.CheckAll()
    local results = {}
    if not HCE_CharDB then return results end

    local key = HCE_CharDB.selectedCharacter
    local char = key and HCE.GetCharacter and HCE.GetCharacter(key) or nil
    if not char then return results end
    if not char.professions or #char.professions == 0 then return results end

    local playerLevel = UnitLevel("player") or 1

    -- Not yet level 5: everything is inactive
    if playerLevel < 5 then
        for _, profName in ipairs(char.professions) do
            results[profName] = {
                status   = "inactive",
                detail   = "Profession tracking starts at level 5",
                rank     = 0,
                expected = 0,
            }
        end
        return results
    end

    local known = ScanProfessions()
    local expected = ExpectedRank(playerLevel)

    for _, profName in ipairs(char.professions) do
        local info = known[profName]
        if not info then
            -- Profession not learned at all
            results[profName] = {
                status   = FAIL,
                detail   = profName .. " not learned yet",
                rank     = 0,
                expected = expected,
            }
        else
            if info.rank >= expected then
                results[profName] = {
                    status   = PASS,
                    detail   = string.format(
                        "%s rank %d / %d (expected %d at lv %d)",
                        info.localName or profName, info.rank, info.maxRank, expected, playerLevel
                    ),
                    rank     = info.rank,
                    expected = expected,
                }
            else
                -- Behind pace
                local delta = expected - info.rank
                results[profName] = {
                    status   = FAIL,
                    detail   = string.format(
                        "%s rank %d — %d point%s behind (expected %d at lv %d)",
                        info.localName or profName, info.rank,
                        delta, delta == 1 and "" or "s",
                        expected, playerLevel
                    ),
                    rank     = info.rank,
                    expected = expected,
                }
            end
        end
    end

    return results
end

--- Run a full check and store results in SavedVariables.
function PC.RunCheck()
    local results = PC.CheckAll()
    if HCE_CharDB then
        HCE_CharDB.profResults = results
    end
    return results
end

--- Get stored results from the last check.
function PC.GetResults()
    return HCE_CharDB and HCE_CharDB.profResults or {}
end

----------------------------------------------------------------------
-- Chat warnings (one-shot per profession per state transition)
----------------------------------------------------------------------

local CHAT_PREFIX = "|cffe6b422[HCE]|r "

-- Track which professions we've already warned about so we only
-- warn once per session per transition (not-learned, or falling behind).
local warnedNotLearned  = {}
local warnedBehind      = {}

--- Run checks and fire chat warnings for new problems.
--- Does NOT fire the ForbiddenAlert toast — profession shortfalls
--- are a softer warning than equipping a forbidden item.
function PC.CheckAndWarn()
    local oldResults = PC.GetResults()

    -- Snapshot old statuses before RunCheck overwrites them
    local oldStatus = {}
    for prof, r in pairs(oldResults) do oldStatus[prof] = r.status end

    local newResults = PC.RunCheck()

    for prof, res in pairs(newResults) do
        if res.status == FAIL then
            local was = oldStatus[prof]
            if res.rank == 0 and not warnedNotLearned[prof] then
                -- Profession not learned
                DEFAULT_CHAT_FRAME:AddMessage(
                    CHAT_PREFIX .. "|cffffaa33Profession needed:|r " .. prof ..
                    " — should be learned by now (you're level " ..
                    (UnitLevel("player") or "?") .. ")"
                )
                warnedNotLearned[prof] = true
            elseif res.rank > 0 and was ~= FAIL and not warnedBehind[prof] then
                -- Falling behind
                DEFAULT_CHAT_FRAME:AddMessage(
                    CHAT_PREFIX .. "|cffffaa33Profession falling behind:|r " ..
                    res.detail
                )
                warnedBehind[prof] = true
            end
        elseif res.status == PASS then
            -- Clear the warning flags so we can re-warn if they fall
            -- behind again later
            warnedNotLearned[prof] = nil
            warnedBehind[prof]     = nil
        end
    end

    -- Refresh the panel to show updated indicators
    if HCE.RefreshPanel then HCE.RefreshPanel() end
end

--- Reset one-shot warning state.  Called when a new character is
--- selected so stale warnings from a previous pick don't block.
function PC.ResetWarnings()
    warnedNotLearned = {}
    warnedBehind     = {}
end

----------------------------------------------------------------------
-- Events
----------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("SKILL_LINES_CHANGED")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

local initialCheckDone = false

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Defer so SavedVariables and CharacterData are ready,
        -- and the skill list has populated.
        C_Timer.After(2.5, function()
            PC.RunCheck()
            initialCheckDone = true
            if HCE.RefreshPanel then HCE.RefreshPanel() end
        end)
        -- Second pass to catch late-loading skill data
        C_Timer.After(5.5, function()
            PC.CheckAndWarn()
        end)

    elseif event == "SKILL_LINES_CHANGED" then
        if not initialCheckDone then return end
        -- Small delay to let the skill data settle
        C_Timer.After(0.3, function()
            PC.CheckAndWarn()
        end)

    elseif event == "PLAYER_LEVEL_UP" then
        if not initialCheckDone then return end
        -- Re-check on level up because the expected rank changes
        C_Timer.After(0.5, function()
            PC.CheckAndWarn()
        end)
    end
end)
