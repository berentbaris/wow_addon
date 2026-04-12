----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Selection UI
--
-- A frame that lets the player browse enhanced classes and pick one.
-- Auto-opens on login when multiple race/class/gender matches exist,
-- and is also reachable via /hce pick (with no argument) or /hce ui.
--
-- Layout:
--   +------------------------------------------------+
--   | Hardcore Classes Enhanced         [?]    [X]   |
--   | Pick your enhanced class                       |
--   |   ( ) Only ones that match my character        |
--   |   ( ) All enhanced classes for <Class>         |
--   | +-------------------+  +---------------------+ |
--   | | [entry]           |  | Mountain King       | |
--   | | [entry]  <-sel    |  | Protection Warrior  | |
--   | | [entry]           |  | Dwarf, Male         | |
--   | | [entry]           |  |                     | |
--   | | ...               |  | Equipment:  ...     | |
--   | +-------------------+  | Challenges: ...     | |
--   |                        +---------------------+ |
--   |                       [ Select ]   [ Cancel ]  |
--   +------------------------------------------------+
----------------------------------------------------------------------

HCE = HCE or {}

local UI            = {}
HCE.UI              = UI

local ROW_HEIGHT    = 34
local LIST_ROWS     = 9
local LIST_WIDTH    = 240
local FRAME_WIDTH   = 640
local FRAME_HEIGHT  = 470

-- Class text colours (Blizzard defaults for Classic)
local CLASS_COLORS = {
    WARRIOR = "c79c6e", ROGUE   = "fff569", MAGE    = "69ccf0",
    WARLOCK = "9482c9", PRIEST  = "ffffff", PALADIN = "f58cba",
    DRUID   = "ff7d0a", SHAMAN  = "0070de", HUNTER  = "abd473",
}

local function classColor(classToken)
    return CLASS_COLORS[classToken or ""] or "ffd100"
end

local function titleCase(s)
    if not s or s == "" then return "" end
    return s:sub(1, 1):upper() .. s:sub(2):lower()
end

----------------------------------------------------------------------
-- State
----------------------------------------------------------------------

UI.selectedKey  = nil     -- currently highlighted entry in the list (not yet committed)
UI.filterMode   = "match" -- "match" or "class"
UI.entries      = {}      -- array of character refs currently shown

----------------------------------------------------------------------
-- Build the frame
----------------------------------------------------------------------

local frame

local function BuildFrame()
    if frame then return frame end

    frame = CreateFrame("Frame", "HCE_SelectionFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()

    -- Title text inside the header bar
    frame.TitleText:SetText("Hardcore Classes Enhanced")

    -- Subheading
    local heading = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOPLEFT", 16, -32)
    heading:SetText("Choose your enhanced class")
    frame.heading = heading

    -- Subtitle / instructions
    local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -4)
    subtitle:SetPoint("RIGHT", frame, "RIGHT", -16, 0)
    subtitle:SetJustifyH("LEFT")
    subtitle:SetText("Pick a lore-flavoured archetype for this hardcore run. Your choice is saved for this character.")
    frame.subtitle = subtitle

    -- Filter: "match" vs "class"
    local matchBtn = CreateFrame("CheckButton", "HCE_FilterMatch", frame, "UIRadioButtonTemplate")
    matchBtn:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -10)
    matchBtn.text:SetText("Matches for my character")
    matchBtn.text:SetFontObject("GameFontNormal")
    frame.matchBtn = matchBtn

    local classBtn = CreateFrame("CheckButton", "HCE_FilterClass", frame, "UIRadioButtonTemplate")
    classBtn:SetPoint("LEFT", matchBtn.text, "RIGHT", 16, 0)
    classBtn.text:SetText("All archetypes for my class")
    classBtn.text:SetFontObject("GameFontNormal")
    frame.classBtn = classBtn

    matchBtn:SetScript("OnClick", function()
        UI.filterMode = "match"
        UI:Refresh()
    end)
    classBtn:SetScript("OnClick", function()
        UI.filterMode = "class"
        UI:Refresh()
    end)

    ---------- Left: list of entries with a scroll frame ----------
    local listBG = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    listBG:SetPoint("TOPLEFT", matchBtn, "BOTTOMLEFT", -4, -10)
    listBG:SetSize(LIST_WIDTH + 28, ROW_HEIGHT * LIST_ROWS + 14)
    frame.listBG = listBG

    local scroll = CreateFrame("ScrollFrame", "HCE_SelectionScroll", listBG, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() UI:RefreshList() end)
    end)
    frame.scroll = scroll

    -- Pre-create row buttons
    frame.rows = {}
    for i = 1, LIST_ROWS do
        local row = CreateFrame("Button", nil, listBG)
        row:SetHeight(ROW_HEIGHT)
        if i == 1 then
            row:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, 0)
        else
            row:SetPoint("TOPLEFT", frame.rows[i - 1], "BOTTOMLEFT", 0, 0)
            row:SetPoint("TOPRIGHT", frame.rows[i - 1], "BOTTOMRIGHT", 0, 0)
        end

        -- Highlight texture
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetColorTexture(1, 1, 1, 0.12)

        -- Selection texture (shown when this row is the selected one)
        local sel = row:CreateTexture(nil, "BACKGROUND")
        sel:SetAllPoints()
        sel:SetColorTexture(1, 0.82, 0, 0.18)
        sel:Hide()
        row.selTex = sel

        -- Name
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        name:SetPoint("TOPLEFT", 8, -4)
        name:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        name:SetJustifyH("LEFT")
        row.nameText = name

        -- Subtext (spec + race)
        local sub = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        sub:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -1)
        sub:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        sub:SetJustifyH("LEFT")
        row.subText = sub

        row:SetScript("OnClick", function(self)
            local entry = self.entry
            if entry then
                UI.selectedKey = entry.name
                UI:Refresh()
            end
        end)

        row:SetScript("OnDoubleClick", function(self)
            local entry = self.entry
            if entry then
                UI.selectedKey = entry.name
                UI:Commit()
            end
        end)

        frame.rows[i] = row
    end

    ---------- Right: details panel ----------
    local detail = CreateFrame("Frame", nil, frame, "InsetFrameTemplate")
    detail:SetPoint("TOPLEFT", listBG, "TOPRIGHT", 10, 0)
    detail:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 60)
    frame.detail = detail

    local dName = detail:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    dName:SetPoint("TOPLEFT", 12, -12)
    dName:SetPoint("RIGHT", detail, "RIGHT", -12, 0)
    dName:SetJustifyH("LEFT")
    frame.dName = dName

    local dSub = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dSub:SetPoint("TOPLEFT", dName, "BOTTOMLEFT", 0, -2)
    dSub:SetPoint("RIGHT", detail, "RIGHT", -12, 0)
    dSub:SetJustifyH("LEFT")
    frame.dSub = dSub

    local divider = detail:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", dSub, "BOTTOMLEFT", 0, -6)
    divider:SetPoint("RIGHT", detail, "RIGHT", -12, 0)
    divider:SetHeight(1)
    divider:SetColorTexture(1, 0.82, 0, 0.35)

    -- Scrolling body for the long requirement text
    local bodyScroll = CreateFrame("ScrollFrame", nil, detail, "UIPanelScrollFrameTemplate")
    bodyScroll:SetPoint("TOPLEFT", divider, "BOTTOMLEFT", 0, -6)
    bodyScroll:SetPoint("BOTTOMRIGHT", detail, "BOTTOMRIGHT", -26, 10)

    local bodyContent = CreateFrame("Frame", nil, bodyScroll)
    bodyContent:SetSize(1, 1)
    bodyScroll:SetScrollChild(bodyContent)

    local dBody = bodyContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    dBody:SetPoint("TOPLEFT", 0, 0)
    dBody:SetWidth(FRAME_WIDTH - LIST_WIDTH - 120)
    dBody:SetJustifyH("LEFT")
    dBody:SetSpacing(3)
    frame.dBody        = dBody
    frame.dBodyScroll  = bodyScroll
    frame.dBodyContent = bodyContent

    ---------- Footer buttons ----------
    local selectBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    selectBtn:SetSize(130, 24)
    selectBtn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 16)
    selectBtn:SetText("Select")
    selectBtn:SetScript("OnClick", function() UI:Commit() end)
    frame.selectBtn = selectBtn

    local cancelBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    cancelBtn:SetSize(100, 24)
    cancelBtn:SetPoint("RIGHT", selectBtn, "LEFT", -8, 0)
    cancelBtn:SetText("Cancel")
    cancelBtn:SetScript("OnClick", function() frame:Hide() end)
    frame.cancelBtn = cancelBtn

    -- Hint on the bottom-left explaining double-click
    local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 22)
    hint:SetText("Tip: double-click an entry to select it instantly.")
    frame.hint = hint

    frame:SetScript("OnShow", function() UI:Refresh() end)
    frame:SetScript("OnHide", function()
        -- Nothing persistent; selection isn't committed until the button is clicked
    end)

    return frame
end

----------------------------------------------------------------------
-- Data gathering
----------------------------------------------------------------------

local function collectEntries()
    local _, playerClass = UnitClass("player")
    local results = {}

    if UI.filterMode == "match" then
        for _, char in ipairs(HCE.FindMatchingCharacters()) do
            table.insert(results, char)
        end
        -- If there are zero matches we silently fall through to the class
        -- list so the player is never stuck with an empty frame.
        if #results == 0 then
            for _, char in pairs(HCE.Characters) do
                if char.class == playerClass then
                    table.insert(results, char)
                end
            end
        end
    else
        for _, char in pairs(HCE.Characters) do
            if char.class == playerClass then
                table.insert(results, char)
            end
        end
    end

    table.sort(results, function(a, b) return a.name < b.name end)
    return results
end

----------------------------------------------------------------------
-- Details pane builder
----------------------------------------------------------------------

local function buildDetails(char)
    if not char then return "Select an enhanced class to see its requirements." end

    local lines = {}
    local function add(line) lines[#lines + 1] = line end

    add("|cffaaaaaaRace:|r " .. char.race
        .. "   |cffaaaaaaGender:|r " .. char.gender
        .. "   |cffaaaaaaSelf-found:|r " .. (char.selfFound and "Yes" or "No"))

    if char.professions and #char.professions > 0 then
        add("|cffaaaaaaProfessions:|r " .. table.concat(char.professions, ", "))
    else
        add("|cffaaaaaaProfessions:|r none required")
    end

    add(" ")

    if char.equipment and #char.equipment > 0 then
        add("|cffffd100Equipment|r")
        for _, eq in ipairs(char.equipment) do
            add("  |cff888888[" .. eq.level .. "]|r " .. eq.desc)
        end
        add(" ")
    end

    if char.challenges and #char.challenges > 0 then
        add("|cffffd100Challenges|r")
        for _, ch in ipairs(char.challenges) do
            local detail = ""
            if HCE.ChallengeDescriptions and HCE.ChallengeDescriptions[ch.desc] then
                detail = "  |cff888888— " .. HCE.ChallengeDescriptions[ch.desc] .. "|r"
            end
            add("  |cff888888[" .. ch.level .. "]|r " .. ch.desc .. detail)
        end
        add(" ")
    end

    if char.companion then
        add("|cffffd100Companion|r  |cff888888[" .. char.companion.level .. "]|r " .. char.companion.desc)
    end
    if char.pet then
        add("|cffffd100Hunter pet|r  |cff888888[" .. char.pet.level .. "]|r " .. char.pet.desc)
    end
    if char.mount then
        add("|cffffd100Mount|r  |cff888888[" .. char.mount.level .. "]|r " .. char.mount.desc)
    end

    if char.gameplay and char.gameplay ~= "" then
        add(" ")
        add("|cffffd100Gameplay|r  |cffcccccc" .. char.gameplay .. "|r")
    end

    return table.concat(lines, "\n")
end

----------------------------------------------------------------------
-- Rendering
----------------------------------------------------------------------

function UI:RefreshList()
    if not frame or not frame:IsShown() then return end

    local total = #UI.entries
    FauxScrollFrame_Update(frame.scroll, total, LIST_ROWS, ROW_HEIGHT)
    local offset = FauxScrollFrame_GetOffset(frame.scroll)

    for i = 1, LIST_ROWS do
        local row   = frame.rows[i]
        local idx   = offset + i
        local entry = UI.entries[idx]

        if entry then
            row.entry = entry
            local color = classColor(entry.class)
            row.nameText:SetText("|cff" .. color .. entry.name .. "|r")
            row.subText:SetText(entry.spec .. " · " .. entry.race .. " " .. entry.gender)
            row:Show()
            if entry.name == UI.selectedKey then
                row.selTex:Show()
            else
                row.selTex:Hide()
            end
        else
            row.entry = nil
            row:Hide()
        end
    end
end

function UI:RefreshDetails()
    if not frame then return end
    local char = UI.selectedKey and HCE.Characters[UI.selectedKey] or nil

    if char then
        local color = classColor(char.class)
        frame.dName:SetText("|cff" .. color .. char.name .. "|r")
        frame.dSub:SetText(char.spec .. " " .. titleCase(char.class))
        frame.selectBtn:Enable()
    else
        frame.dName:SetText("|cffaaaaaaNo selection|r")
        frame.dSub:SetText("")
        frame.selectBtn:Disable()
    end

    local text = buildDetails(char)
    frame.dBody:SetText(text)
    -- Resize the scroll child so scrolling works correctly
    local _, _, _, _, h = frame.dBody:GetBoundsRect()
    h = h or frame.dBody:GetStringHeight()
    frame.dBodyContent:SetHeight(math.max(1, (h or 0) + 4))
end

function UI:Refresh()
    if not frame then return end

    -- Sync radio buttons
    frame.matchBtn:SetChecked(UI.filterMode == "match")
    frame.classBtn:SetChecked(UI.filterMode == "class")

    UI.entries = collectEntries()

    -- If the currently selected key is no longer in the list, clear it
    local stillThere = false
    for _, e in ipairs(UI.entries) do
        if e.name == UI.selectedKey then stillThere = true break end
    end
    if not stillThere then
        UI.selectedKey = UI.entries[1] and UI.entries[1].name or nil
    end

    self:RefreshList()
    self:RefreshDetails()
end

----------------------------------------------------------------------
-- Commit
----------------------------------------------------------------------

function UI:Commit()
    if not UI.selectedKey then return end
    local char = HCE.Characters[UI.selectedKey]
    if not char then return end

    HCE_CharDB.selectedCharacter = char.name
    HCE_CharDB.manualOverride    = true

    HCE.Print("Selected enhanced class: |cffffd100" .. char.name .. "|r (" .. char.spec .. ")")

    if HCE.ResyncLevelAlerts then HCE.ResyncLevelAlerts() end
    if HCE.RefreshPanel then HCE.RefreshPanel() end
    if frame then frame:Hide() end
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

--- Show the selection UI. If the player already has matches, prefer the
--- "match" filter; otherwise fall back to the full class list.
function HCE.ShowSelectionUI()
    BuildFrame()

    -- Decide initial filter based on how many matches the player has
    local matches = HCE.FindMatchingCharacters()
    if #matches > 0 then
        UI.filterMode = "match"
    else
        UI.filterMode = "class"
    end

    -- Preselect the currently saved character if it's still valid
    if HCE_CharDB and HCE_CharDB.selectedCharacter and HCE.Characters[HCE_CharDB.selectedCharacter] then
        UI.selectedKey = HCE_CharDB.selectedCharacter
    else
        UI.selectedKey = nil
    end

    frame:Show()
    UI:Refresh()
end

function HCE.HideSelectionUI()
    if frame then frame:Hide() end
end

function HCE.ToggleSelectionUI()
    if frame and frame:IsShown() then
        frame:Hide()
    else
        HCE.ShowSelectionUI()
    end
end
