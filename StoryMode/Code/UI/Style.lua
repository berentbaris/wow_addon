local _, SM = ...

local SOLID = "Interface\\Buttons\\WHITE8x8"
SM.SOLID_TEXTURE = SOLID
SM.StoryModeIconTexture = "Interface\\AddOns\\StoryMode\\Art\\Icons\\storymode_icon"
SM.StoryModeBgTexture = "Interface\\AddOns\\StoryMode\\Art\\Hero\\storymode_bg"
SM.StoryModeLayoutTexture = "Interface\\AddOns\\StoryMode\\Art\\Hero\\storymode_layout"
SM.CoverFadeMaskTexture = "Interface\\AddOns\\StoryMode\\Art\\Masks\\CoverFadeMask"
SM.ClassicCardTexture = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
SM.ClassicCardBorder = "Interface\\Tooltips\\UI-Tooltip-Border"
SM.ClassicPortraitRing = "Interface\\Common\\portrait-ring-withbg"
SM.ClassicPortraitRingFallback = "Interface\\Buttons\\GoldRing64"
SM.PanelScrollTopInset = 4
SM.PanelScrollBottomInset = 4

local C_BODY = {0.922, 0.871, 0.761}
local C_GOLD = {1,     0.82,  0}
local C_DIM  = {0.50,  0.50,  0.50}
local C_DIVIDER = {1.0, 0.80, 0.45}
SM.UIColors = {
    body = C_BODY,
    gold = C_GOLD,
    dim = C_DIM,
    divider = C_DIVIDER,
}

function SM.HexColor(r, g, b)
    return string.format("%02x%02x%02x",
        math.min(255, math.floor(r * 255)),
        math.min(255, math.floor(g * 255)),
        math.min(255, math.floor(b * 255)))
end

function SM.NoShadow(fs) fs:SetShadowOffset(0,0); return fs end

function SM.SafeSetTexture(tex, path)
    if not tex or not path then return false end
    local ok = pcall(tex.SetTexture, tex, path)
    return ok and tex:GetTexture() ~= nil
end

function SM.SafeSetAtlas(tex, atlas, useAtlasSize)
    if not tex or not tex.SetAtlas or not atlas then return false end
    if SM.IsClassicClient() then return false end
    if C_Texture and C_Texture.GetAtlasInfo and not C_Texture.GetAtlasInfo(atlas) then
        return false
    end

    local ok = pcall(tex.SetAtlas, tex, atlas, useAtlasSize)
    return ok and (not tex.GetAtlas or tex:GetAtlas() == atlas)
end

function SM.SetSolidTexture(tex, r, g, b, a)
    tex:SetTexture(SOLID)
    tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
end

function SM.SafeSetButtonHighlight(button, atlas, alpha)
    if button.SetHighlightAtlas and SM.SafeSetAtlas(button, atlas, false) then
        local highlight = button:GetHighlightTexture()
        if highlight then
            highlight:SetAllPoints()
            if alpha then highlight:SetAlpha(alpha) end
        end
        return true
    end

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    SM.SetSolidTexture(highlight, 1, 0.82, 0.35, alpha or 0.18)
    highlight:SetAllPoints(button)
    button:SetHighlightTexture(highlight)
    return false
end

function SM.SetStoryArrowTexture(tex, direction, large)
    if not tex then return end
    tex:SetRotation(0)

    if large == "money" then
        if direction == "left" then
            SM.SafeSetTexture(tex, "Interface\\MoneyFrame\\Arrow-Left-Up")
        else
            SM.SafeSetTexture(tex, "Interface\\MoneyFrame\\Arrow-Right-Up")
        end
        return
    end

    if large or (SM.IsRetailClient()) then
        if direction == "left" and SM.IsClassicClient() then
            if SM.SafeSetTexture(tex, "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up") then
                return
            end
            if SM.SafeSetAtlas(tex, "common-icon-backarrow", false) then
                return
            end
            SM.SafeSetTexture(tex, "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            tex:SetRotation(math.pi)
            return
        end

        if not SM.SafeSetAtlas(tex, "common-icon-forwardarrow", false) then
            SM.SafeSetTexture(tex, "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        end
        if direction == "left" then
            tex:SetRotation(math.pi)
        elseif direction == "down" then
            tex:SetRotation(-math.pi / 2)
        end
        return
    end

    SM.SafeSetTexture(tex, "Interface\\RAIDFRAME\\UI-RAIDFRAME-ARROW")
    if direction == "down" then
        tex:SetRotation(-math.pi / 2)
    elseif direction == "left" then
        tex:SetRotation(math.pi)
    end
end

function SM.CreateSimpleBorder(parent, thickness, level)
    local border = {}
    thickness = thickness or 1
    level = level or "OVERLAY"

    border.top = parent:CreateTexture(nil, level)
    border.top:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    border.top:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    border.top:SetHeight(thickness)

    border.bottom = parent:CreateTexture(nil, level)
    border.bottom:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    border.bottom:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    border.bottom:SetHeight(thickness)

    border.left = parent:CreateTexture(nil, level)
    border.left:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    border.left:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    border.left:SetWidth(thickness)

    border.right = parent:CreateTexture(nil, level)
    border.right:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    border.right:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    border.right:SetWidth(thickness)

    return border
end

function SM.SetSimpleBorder(border, r, g, b, a)
    if not border then return end
    for _, tex in pairs(border) do
        SM.SetSolidTexture(tex, r, g, b, a)
    end
end

function SM.ApplyClassicCardBackdrop(frame, bgAlpha, borderAlpha)
    if not frame or not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = SOLID,
        edgeFile = SM.ClassicCardBorder,
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.035, 0.030, 0.026, bgAlpha or 0.46)
    frame:SetBackdropBorderColor(0.72, 0.56, 0.30, borderAlpha or 0.62)
end

function SM.ClearCardFillTexture(tex)
    if not tex then return end
    tex:SetTexture(SOLID)
    tex:SetVertexColor(0, 0, 0, 0)
end

function SM.SetSubtleCardHover(button, mask)
    if not button then return end
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    if not SM.SafeSetTexture(highlight, "Interface\\QuestFrame\\UI-QuestLogTitleHighlight") then
        SM.SetSolidTexture(highlight, 0.92, 0.82, 0.58, 0.08)
    end
    highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
    highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
    highlight:SetVertexColor(0.92, 0.82, 0.58, 0.10)
    if mask then highlight:AddMaskTexture(mask) end
    button:SetHighlightTexture(highlight)
end

function SM.CreateInsetCardShade(parent, alpha, subLevel)
    if not parent then return nil end
    local shade = parent:CreateTexture(nil, "BACKGROUND", nil, subLevel or 1)
    SM.SetSolidTexture(shade, 0, 0, 0, alpha or 0.16)
    shade:SetPoint("TOPLEFT", parent, "TOPLEFT", 3, -3)
    shade:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -3, 3)
    shade:SetVertexColor(0, 0, 0, alpha or 0.16)
    return shade
end

function SM.CreateCompletionRibbon(parent)
    local ribbon = CreateFrame("Frame", nil, parent)
    ribbon:SetSize(34, 42)
    ribbon:SetFrameLevel((parent:GetFrameLevel() or 0) + 20)

    local flag = ribbon:CreateTexture(nil, "OVERLAY", nil, 1)
    flag:SetAllPoints()
    flag:SetVertexColor(1, 1, 1)
    local hasFlag = SM.SafeSetAtlas(flag, "housing-dashboard-tasks-listitem-flag", false)
    if not hasFlag then
        flag:Hide()
    end

    local check = ribbon:CreateTexture(nil, "OVERLAY", nil, 2)
    if not SM.SafeSetAtlas(check, "common-icon-checkmark", false) then
        SM.SafeSetTexture(check, "Interface\\Buttons\\UI-CheckBox-Check")
    end
    if hasFlag then
        check:SetSize(14, 14)
        check:SetPoint("CENTER", ribbon, "CENTER", 0, 3)
    else
        check:SetSize(24, 24)
        check:SetPoint("CENTER", ribbon, "CENTER", 0, 0)
    end
    check:SetVertexColor(0.45, 0.90, 0.35)

    return ribbon
end

local PERKS_LAYOUT = {
    TopLeftCorner     = { atlas = "Perks-List-NineSlice-CornerTopLeft", x = -31, y = 31 },
    TopRightCorner    = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = 31, y = 31 },
    BottomLeftCorner  = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = -31, y = -31 },
    BottomRightCorner = { atlas = "Perks-List-NineSlice-CornerTopLeft", mirrorLayout = true, x = 31, y = -31 },
    TopEdge           = { atlas = "_Perks-List-NineSlice-EdgeTop" },
    BottomEdge        = { atlas = "_Perks-List-NineSlice-EdgeTop", mirrorLayout = true },
    LeftEdge          = { atlas = "!Perks-List-NineSlice-EdgeLeft" },
    RightEdge         = { atlas = "!Perks-List-NineSlice-EdgeLeft", mirrorLayout = true },
    Center            = { atlas = "Perks-List-NineSlice-Center" },
}

function SM.CreateStoryPanel(section)
    local useRetailArt = SM.IsRetailClient()
    local template = (useRetailArt and NineSliceUtil) and "NineSlicePanelTemplate" or "BackdropTemplate"
    local f = CreateFrame("Frame", nil, section, template)
    f:SetAllPoints(section)
    f:SetFrameLevel(section:GetFrameLevel())
    if useRetailArt and NineSliceUtil then
        local ok = pcall(NineSliceUtil.ApplyLayout, f, PERKS_LAYOUT)
        if ok then
            local br, bg, bb = 1.0, 1.0, 1.0
            for _, key in ipairs({"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
                                  "TopEdge","BottomEdge","LeftEdge","RightEdge"}) do
                if f[key] then f[key]:SetVertexColor(br, bg, bb) end
            end
            return f
        end
    end

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile = SOLID,
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        f:SetBackdropColor(0.040, 0.035, 0.030, 0.76)
        f:SetBackdropBorderColor(1.0, 1.0, 1.0, 0.68)
    else
        local bg = f:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        SM.SetSolidTexture(bg, 0.040, 0.035, 0.030, 0.76)
    end
    return f
end

local SCROLL_STEP = 40

function SM.EnableMouseWheelScroll(scrollFrame)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local range = self:GetVerticalScrollRange() or 0
        if range <= 0 then return end
        local cur = self:GetVerticalScroll() or 0
        local new = math.max(0, math.min(range, cur - delta * SCROLL_STEP))
        self:SetVerticalScroll(new)
    end)
end

function SM.GetScrollBar(scrollFrame)
    if not scrollFrame then return nil end
    return scrollFrame.ScrollBar
        or scrollFrame.Scrollbar
        or (scrollFrame.GetName and scrollFrame:GetName() and _G[scrollFrame:GetName() .. "ScrollBar"])
end

function SM.UpdateScrollbarVisibility(scrollFrame)
    local scrollbar = SM.GetScrollBar(scrollFrame)
    if not scrollbar then return end

    local range = scrollFrame:GetVerticalScrollRange() or 0
    if SM.IsRetailClient() then
        if range > 1 then
            scrollbar:Show()
        else
            scrollFrame:SetVerticalScroll(0)
            scrollbar:Hide()
        end
    else
        if range <= 1 then scrollFrame:SetVerticalScroll(0) end
        scrollbar:Hide()
    end
end

function SM.StyleStoryScrollbar(scrollFrame)
    if SM.IsClassicClient() then return end
    local scrollbar = SM.GetScrollBar(scrollFrame)
    if not scrollbar then return end

    scrollbar:SetWidth(8)
    if not scrollbar.storyModeTrack then
        scrollbar.storyModeTrack = scrollbar:CreateTexture(nil, "BACKGROUND")
        scrollbar.storyModeTrack:SetPoint("TOP", scrollbar, "TOP", 0, -2)
        scrollbar.storyModeTrack:SetPoint("BOTTOM", scrollbar, "BOTTOM", 0, 2)
        scrollbar.storyModeTrack:SetWidth(4)
        SM.SetSolidTexture(scrollbar.storyModeTrack, 0.0, 0.0, 0.0, 0.48)
    end

    local thumb = (scrollbar.GetThumbTexture and scrollbar:GetThumbTexture()) or scrollbar.ThumbTexture
    if thumb then
        SM.SetSolidTexture(thumb, 0.72, 0.58, 0.32, 0.88)
        thumb:SetWidth(8)
    end

    for _, region in ipairs({ scrollbar:GetRegions() }) do
        if region ~= thumb and region.SetAlpha then region:SetAlpha(0.12) end
    end

    for _, child in ipairs({ scrollbar:GetChildren() }) do
        if child.SetAlpha then child:SetAlpha(0.45) end
        if child.SetSize then child:SetSize(12, 12) end
    end
end

function SM.CreateMajorDivider(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight((SM.IsRetailClient()) and 16 or 8)
    local tex = f:CreateTexture(nil, "ARTWORK")
    if SM.IsRetailClient() and tex.SetAtlas then
        pcall(tex.SetAtlas, tex, "ui-journeys-renown-divider", false)
        tex:SetPoint("LEFT",  f, "LEFT",  0, 0)
        tex:SetPoint("RIGHT", f, "RIGHT", 0, 0)
        tex:SetHeight(16)
        return f
    end

    tex:SetTexture(SOLID)
    tex:SetPoint("LEFT",  f, "LEFT",  0, 0)
    tex:SetPoint("RIGHT", f, "CENTER", 0, 0)
    tex:SetHeight(1)
    tex:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.34))

    local texR = f:CreateTexture(nil, "ARTWORK")
    texR:SetTexture(SOLID)
    texR:SetPoint("LEFT",  f, "CENTER", 0, 0)
    texR:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    texR:SetHeight(1)
    texR:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.34),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0))
    return f
end

function SM.CreateCatDivider(parent, text, yOff)
    local CAT_H = 26
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(CAT_H)
    f:SetPoint("TOPLEFT",  parent, "TOPLEFT",  4, yOff)
    f:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -4, yOff)

    local lbl = SM.NoShadow(f:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
    lbl:SetPoint("CENTER", f, "CENTER", 0, 0)
    lbl:SetJustifyH("CENTER")
    lbl:SetText(text)
    lbl:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
    f.label = lbl

    local lineL = f:CreateTexture(nil, "BACKGROUND")
    lineL:SetTexture(SOLID)
    lineL:SetHeight(1)
    lineL:SetPoint("LEFT",  f,   "LEFT",  6, 0)
    lineL:SetPoint("RIGHT", lbl, "LEFT", -8, 0)
    lineL:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.5))

    local lineR = f:CreateTexture(nil, "BACKGROUND")
    lineR:SetTexture(SOLID)
    lineR:SetHeight(1)
    lineR:SetPoint("LEFT",  lbl, "RIGHT", 8, 0)
    lineR:SetPoint("RIGHT", f,   "RIGHT", -6, 0)
    lineR:SetGradient("HORIZONTAL",
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0.5),
        CreateColor(C_DIVIDER[1], C_DIVIDER[2], C_DIVIDER[3], 0))

    return CAT_H, f
end
