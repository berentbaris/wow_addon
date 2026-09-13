local _, SM = ...

function SM.ShowLoadingScreenBrowser()
    local colors = SM.UIColors or {}
    local C_GOLD = colors.gold or { 1, 0.82, 0 }
    local C_BODY = colors.body or { 0.922, 0.871, 0.761 }
    local SOLID = SM.SOLID_TEXTURE or "Interface\\Buttons\\WHITE8x8"

    if not SM.loadingScreenBrowser then
        local frame = CreateFrame("Frame", "StoryModeLoadingScreenBrowser", UIParent, "BackdropTemplate")
        frame:SetSize(860, 620)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("DIALOG")
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetBackdrop({
            bgFile = SOLID,
            edgeFile = SM.ClassicCardBorder,
            edgeSize = 14,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0.035, 0.030, 0.026, 0.96)
        frame:SetBackdropBorderColor(0.95, 0.72, 0.32, 0.85)

        local title = SM.NoShadow(frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"))
        title:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -16)
        title:SetText("Story Mode Loading Screens")
        title:SetTextColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])

        local hint = SM.NoShadow(frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
        hint:SetPoint("LEFT", title, "RIGHT", 18, 0)
        hint:SetText("/sm loadingscreens")
        hint:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)

        local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -48)
        scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 18)

        local child = CreateFrame("Frame", nil, scroll)
        child:SetWidth(780)
        scroll:SetScrollChild(child)

        frame.child = child
        frame.tiles = {}
        SM.loadingScreenBrowser = frame
    end

    local frame = SM.loadingScreenBrowser
    local child = frame.child
    local tileW, tileH = 374, 246
    local imageW, imageH = 348, 196
    local gapX, gapY = 18, 18
    local cols = 2

    for _, tile in ipairs(frame.tiles) do
        tile:Hide()
    end

    for i, choice in ipairs(SM.LoadingScreenChoices or {}) do
        local tile = SM.AcquirePooledFrame(frame.tiles, i, function()
            local newTile = CreateFrame("Button", nil, child, "BackdropTemplate")
            newTile:SetSize(tileW, tileH)
            newTile:SetBackdrop({
                bgFile = SOLID,
                edgeFile = SM.ClassicCardBorder,
                edgeSize = 10,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })
            newTile:SetBackdropColor(0.08, 0.07, 0.06, 0.92)
            newTile:SetBackdropBorderColor(0.75, 0.58, 0.30, 0.55)

            newTile.image = newTile:CreateTexture(nil, "ARTWORK")
            newTile.image:SetSize(imageW, imageH)
            newTile.image:SetPoint("TOP", newTile, "TOP", 0, -12)
            newTile.image:SetTexCoord(0, 1, SM.AdventureLoadingScreenTexTop, SM.AdventureLoadingScreenTexBottom)

            newTile.name = SM.NoShadow(newTile:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
            newTile.name:SetPoint("TOPLEFT", newTile.image, "BOTTOMLEFT", 0, -8)
            newTile.name:SetPoint("RIGHT", newTile.image, "RIGHT", 0, 0)
            newTile.name:SetJustifyH("LEFT")
            newTile.name:SetTextColor(1, 1, 1)

            newTile.textureName = SM.NoShadow(newTile:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
            newTile.textureName:SetPoint("TOPLEFT", newTile.name, "BOTTOMLEFT", 0, -3)
            newTile.textureName:SetPoint("RIGHT", newTile.image, "RIGHT", 0, 0)
            newTile.textureName:SetJustifyH("LEFT")
            newTile.textureName:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])

            newTile:SetScript("OnEnter", function(self)
                self:SetBackdropBorderColor(1.0, 0.82, 0.36, 0.95)
            end)
            newTile:SetScript("OnLeave", function(self)
                self:SetBackdropBorderColor(0.75, 0.58, 0.30, 0.55)
            end)

            return newTile
        end)

        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        tile:ClearAllPoints()
        tile:SetPoint("TOPLEFT", child, "TOPLEFT", col * (tileW + gapX), -row * (tileH + gapY))
        tile.name:SetText(choice.name or "")
        tile.textureName:SetText(tostring(choice.texture or ""))
        if not SM.SafeSetTexture(tile.image, choice.texture) then
            tile.image:SetColorTexture(0.08, 0.07, 0.06, 1)
            tile.textureName:SetText((choice.texture and tostring(choice.texture) or "") .. " (missing)")
        end
        tile:Show()
    end

    local rows = math.ceil(#(SM.LoadingScreenChoices or {}) / cols)
    child:SetHeight(math.max(1, rows * tileH + math.max(0, rows - 1) * gapY + 8))
    frame:Show()
end
