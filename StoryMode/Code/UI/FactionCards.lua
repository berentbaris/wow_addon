-- ── Faction reputation cards (journal tab) ─────────────────────────────────
-- Uses the Housing Dashboard house-level reward card surface with Blizzard's
-- Journeys radial art:
--   house-upgrade-reward-large-tile-bg / -highlight
--   RenownCardButtonTemplate radial: ui-journeys-renown-radial-bar/fill
local _, SM = ...
local SMTooltip = SM.Tooltip
local C_BODY = SM.UIColors.body
local C_GOLD = SM.UIColors.gold
local C_DIM = SM.UIColors.dim
local SOLID = SM.SOLID_TEXTURE

local FactionUI = {
    CARD_W = 304,
    CARD_H = 88,
    TILE_SIZE = 112,
    CARD_ATLAS = "house-upgrade-reward-large-tile-bg",
    CARD_HOVER_ATLAS = "house-upgrade-reward-large-tile-bg-highlight",
    TILE_ATLASES = {
        "house-chest-list-item-default",
        "house-chest-list-Item-default",
    },
    cards = {},
    spacer = nil,
    iconOverrides = {
        [68] = 255143,     -- Exalted Champion of the Undercity
        [1098] = 236694,   -- Knights of the Ebon Blade
        [1106] = 236690,   -- Argent Crusader
        [1156] = 133441,   -- The Ashen Verdict
        [1228] = 877482,   -- Forest Hozen
        [1271] = 646324,   -- Order of the Cloud Serpent
        [1859] = 1394956,  -- Nightfallen faction icon
        [2103] = 2065579,  -- Zandalari Empire faction icon
        [2156] = 2065575,  -- Talanji's Expedition faction icon
        [2157] = 2486869,  -- Honorbound paragon cache
        [2159] = 2486868,  -- 7th Legion paragon cache
        [2160] = 2065573,  -- Proudmoore Admiralty faction icon
        [2161] = 2065572,  -- Order of Embers faction icon
        [2162] = 2065574,  -- Storm's Wake faction icon
        [2413] = 3540525,  -- Court of Harvesters
        [2439] = 3386971,  -- Sinstone, for The Avowed
    },
    achievementIconNames = {
        [68] = "Undercity",
        [1098] = "Knights of the Ebon Blade",
        [1106] = "Argent Crusade",
        [1156] = "The Ashen Verdict",
        [1228] = "Forest Hozen",
        [1271] = "Order of the Cloud Serpent",
        [1859] = "The Nightfallen",
        [2103] = "Zandalari Empire",
        [2156] = "Talanji's Expedition",
        [2157] = "The Honorbound",
        [2159] = "The 7th Legion",
        [2160] = "Proudmoore Admiralty",
        [2161] = "Order of Embers",
        [2162] = "Storm's Wake",
        [2413] = "Court of Harvesters",
        [2439] = "The Avowed",
    },
    achievementIconCache = {},
    colorOverrides = {
        [68] = {0.45, 0.78, 0.50},    -- Undercity
        [1098] = {0.42, 0.72, 0.62},  -- Knights of the Ebon Blade
        [1106] = {0.95, 0.72, 0.26},  -- Argent Crusade
        [1156] = {0.78, 0.85, 0.60},  -- The Ashen Verdict
        [1228] = {0.58, 0.76, 0.26},  -- Forest Hozen
        [1271] = {0.12, 0.72, 0.78},  -- Order of the Cloud Serpent
        [1859] = {0.62, 0.38, 0.95},  -- The Nightfallen
        [2103] = {0.91, 0.62, 0.12},  -- Zandalari Empire
        [2156] = {0.16, 0.72, 0.68},  -- Talanji's Expedition
        [2157] = {0.82, 0.22, 0.16},  -- The Honorbound
        [2159] = {0.32, 0.55, 0.95},  -- 7th Legion
        [2160] = {0.36, 0.62, 0.94},  -- Proudmoore Admiralty
        [2161] = {0.95, 0.48, 0.18},  -- Order of Embers
        [2162] = {0.28, 0.78, 0.68},  -- Storm's Wake
        [2413] = {0.74, 0.18, 0.28},  -- Court of Harvesters
        [2439] = {0.72, 0.62, 0.48},  -- The Avowed
    },
    descriptions = {
        [1859] = "These exiled Nightborne elves suffer withdrawals after being cut off from the Nightwell. They oppose their people's alliance with the Legion and fight for some kind of redemption.",
    },
}

function FactionUI:Create(parent)
    parent = parent or (SM.GetDetailChild and SM.GetDetailChild()) or UIParent
    local card = CreateFrame("Frame", nil, parent)
    card:SetSize(self.CARD_W, self.CARD_H)

    card.button = CreateFrame("Button", nil, card)
    card.button:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
    card.button:SetSize(self.CARD_W, self.CARD_H)

    card.button.Background = card.button:CreateTexture(nil, "BACKGROUND")
    card.button.Background:SetAllPoints(card.button)
    if not SM.SafeSetAtlas(card.button.Background, self.CARD_ATLAS, false) then
        SM.SetSolidTexture(card.button.Background, 0.075, 0.065, 0.055, 0.92)
    end

    card.button:SetScript("OnEnter", function(button)
        if card.tileMode then
            FactionUI:ApplyTileVisual(card, true)
        else
            FactionUI:SetCardAtlas(card, FactionUI:GetCardAtlas(card, true))
        end
        if card.tooltipTitle then
            SMTooltip:SetOwner(button, "ANCHOR_RIGHT")
            SMTooltip:ClearLines()
            SMTooltip:AddLine(card.tooltipTitle, 1, 1, 1)
            if card.tooltipStatus and card.tooltipStatus ~= "" then
                SMTooltip:AddLine(card.tooltipStatus, C_GOLD[1], C_GOLD[2], C_GOLD[3])
            end
            if card.tooltipDescription and card.tooltipDescription ~= "" then
                SMTooltip:AddLine(" ")
                SMTooltip:AddLine(card.tooltipDescription, C_BODY[1], C_BODY[2], C_BODY[3], true)
            end
            SMTooltip:Show()
        end
    end)
    card.button:SetScript("OnLeave", function()
        if card.tileMode then
            FactionUI:ApplyTileVisual(card, false)
        else
            FactionUI:SetCardAtlas(card, FactionUI:GetCardAtlas(card, false))
        end
        SMTooltip:Hide()
    end)
    card.button:SetScript("OnClick", nil)
    card.button:EnableMouse(true)

    if not card.button.IconFrame then
        card.button.IconFrame = CreateFrame("Frame", nil, card.button)
        card.button.IconFrame.Border = card.button.IconFrame:CreateTexture(nil, "BORDER")
        card.button.IconFrame.Border:SetAllPoints(card.button.IconFrame)
        card.button.IconFrame.Icon = card.button.IconFrame:CreateTexture(nil, "OVERLAY")
        card.button.IconFrame.Icon:SetPoint("CENTER", card.button.IconFrame, "CENTER", 0, 0)
        card.button.IconFrame.IconMask = card.button.IconFrame:CreateMaskTexture()
        card.button.IconFrame.IconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
            "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        card.button.IconFrame.IconMask:SetAllPoints(card.button.IconFrame.Icon)
        card.button.IconFrame.Icon:AddMaskTexture(card.button.IconFrame.IconMask)
    end

    if not card.button.RenownCardFactionName then
        card.button.RenownCardFactionName = SM.NoShadow(card.button:CreateFontString(nil, "OVERLAY", "GameFontNormal"))
        card.button.RenownCardFactionName:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 5, 5)
        card.button.RenownCardFactionName:SetSize(225, 20)
        card.button.RenownCardFactionName:SetJustifyH("LEFT")
    end

    if not card.button.RenownCardFactionLevel then
        card.button.RenownCardFactionLevel = SM.NoShadow(card.button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"))
        card.button.RenownCardFactionLevel:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 5, -15)
        card.button.RenownCardFactionLevel:SetSize(220, 15)
        card.button.RenownCardFactionLevel:SetJustifyH("LEFT")
    end

    if card.button.IconFrame then
        card.button.IconFrame:SetSize(60, 60)
        card.button.IconFrame:SetPoint("LEFT", card.button, "LEFT", 18, 0)
        card.progress = CreateFrame("Cooldown", nil, card.button.IconFrame, "CooldownFrameTemplate")
        card.progress:SetAllPoints(card.button.IconFrame)
        card.progress:SetDrawEdge(false)
        card.progress:SetDrawSwipe(true)
        card.progress:SetHideCountdownNumbers(true)
        card.progress:SetReverse(true)
        card.progress.noCooldownCount = true
        if card.progress.SetRotation then
            card.progress:SetRotation(math.pi)
        end
        card.fullRing = card.button.IconFrame:CreateTexture(nil, "ARTWORK", nil, 2)
        card.fullRing:SetAllPoints(card.button.IconFrame)
        card.fullRing:Hide()
        if card.button.IconFrame.Border then
            if SM.IsRetailClient() then
                card.button.IconFrame.Border:SetAtlas("ui-journeys-renown-radial-bar", false)
            elseif not SM.SafeSetAtlas(card.button.IconFrame.Border, "ui-journeys-renown-radial-bar", false) then
                card.button.IconFrame.Border:Hide()
            end
            card.button.IconFrame.Border:SetSize(60, 60)
        end
        card.icon = card.button.IconFrame.Icon
        card.icon:SetSize(40, 40)
    end

    card.nameLabel = card.button.RenownCardFactionName
    card.statusLabel = card.button.RenownCardFactionLevel
    card.nameLabel:ClearAllPoints()
    card.nameLabel:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 10, 0)
    card.nameLabel:SetPoint("RIGHT", card.button, "RIGHT", -14, 0)
    card.nameLabel:SetPoint("BOTTOM", card.button, "CENTER", 0, 0)
    card.nameLabel:SetJustifyH("LEFT")
    card.nameLabel:SetJustifyV("BOTTOM")
    card.nameLabel:SetScale(1.08)
    card.nameLabel:SetMaxLines(1)
    card.nameLabel:SetWordWrap(false)
    card.statusLabel:ClearAllPoints()
    card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, 0)
    card.statusLabel:SetPoint("RIGHT", card.nameLabel, "RIGHT", 0, 0)
    card.statusLabel:SetJustifyH("LEFT")
    card.statusLabel:SetScale(1.08)
    card.statusLabel:SetMaxLines(1)
    card.statusLabel:SetWordWrap(false)
    card.nameLabel:SetTextColor(1, 1, 1)
    card.statusLabel:SetTextColor(1.0, 0.82, 0.36)
    return card
end

function FactionUI:Get(idx, parent)
    if self.cards[idx] then return self.cards[idx] end
    self.cards[idx] = self:Create(parent)
    return self.cards[idx]
end

function FactionUI:Resize(card, width)
    local scale = math.min(1, width / self.CARD_W)
    card:SetSize(width, self.CARD_H * scale)
    card.button:SetScale(scale)
    return self.CARD_H * scale
end

function FactionUI:SetAtlas(tex, atlas, useAtlasSize)
    if not tex or not atlas then return false end
    if C_Texture and C_Texture.GetAtlasInfo and not C_Texture.GetAtlasInfo(atlas) then
        return false
    end
    local ok = pcall(tex.SetAtlas, tex, atlas, useAtlasSize)
    return ok and (not tex.GetAtlas or tex:GetAtlas() == atlas)
end

function FactionUI:ApplyTileVisual(card, isHover)
    if not card or not card.button or not card.tileMode then return false end
    local button = card.button
    local function SetCatalogTileAtlas(tex)
        for _, atlas in ipairs(self.TILE_ATLASES) do
            if self:SetAtlas(tex, atlas, false) then
                return true
            end
        end
        return false
    end

    if button.TileBg then button.TileBg:Hide() end
    if button.TileBorder then
        for _, tex in ipairs(button.TileBorder) do
            tex:Hide()
        end
    end

    if button.Background then
        button.Background:ClearAllPoints()
        button.Background:SetAllPoints(button)
        if SetCatalogTileAtlas(button.Background) then
            button.Background:SetVertexColor(1, 1, 1, 1)
        else
            button.Background:SetTexture(SOLID)
            button.Background:SetVertexColor(0.015, 0.012, 0.010, 0.96)
        end
        button.Background:SetAlpha(1)
        button.Background:SetDesaturated(false)
        button.Background:Show()

        if not button.HoverBackground then
            button.HoverBackground = button:CreateTexture(nil, "BACKGROUND", nil, 1)
            button.HoverBackground:SetBlendMode("ADD")
        end
        button.HoverBackground:ClearAllPoints()
        button.HoverBackground:SetAllPoints(button)
        if SetCatalogTileAtlas(button.HoverBackground) then
            button.HoverBackground:SetAlpha(isHover and 0.45 or 0)
            button.HoverBackground:SetVertexColor(1, 1, 1, 1)
            button.HoverBackground:SetShown(isHover)
        else
            button.HoverBackground:Hide()
        end
        return true
    end

    return false
end

function FactionUI:SetCardAtlas(card, atlas)
    if not card or not atlas then return end
    if card.tileMode and self:ApplyTileVisual(card, false) then
        return true
    end
    if type(atlas) == "table" then
        for _, candidate in ipairs(atlas) do
            if self:SetCardAtlas(card, candidate) then
                return true
            end
        end
        return false
    end
    if card.button and card.button.Background then
        return self:SetAtlas(card.button.Background, atlas, false)
    elseif card.button and card.button.bg then
        return self:SetAtlas(card.button.bg, atlas, false)
    end
    return false
end

function FactionUI:GetCardAtlas(card, isHover)
    return isHover and self.CARD_HOVER_ATLAS or self.CARD_ATLAS
end

function FactionUI:GetAchievementIcon(factionID)
    if self.achievementIconCache[factionID] ~= nil then
        return self.achievementIconCache[factionID] or nil
    end

    local targetName = self.achievementIconNames[factionID]
    if not targetName then
        self.achievementIconCache[factionID] = false
        return nil
    end

    for id = 1, 50000 do
        local _, name, _, _, _, _, _, _, _, icon = GetAchievementInfo(id)
        if name == targetName and icon then
            self.achievementIconCache[factionID] = icon
            return icon
        end
    end

    self.achievementIconCache[factionID] = false
    return nil
end

function FactionUI:GetFactionIcon(factionID, entry)
    return (entry and entry.icon) or self.iconOverrides[factionID] or self:GetAchievementIcon(factionID)
end

function FactionUI:SetIcon(tex, atlas, texture)
    if not tex then return end
    tex:Hide()
    tex:SetTexture(nil)
    if atlas and self:SetAtlas(tex, atlas, false) then
        tex:SetTexCoord(0, 1, 0, 1)
        tex:SetVertexColor(1, 1, 1)
        tex:Show()
        return
    end
    tex:SetTexture(texture)
    if texture and tex:GetTexture() then
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        tex:SetVertexColor(1, 1, 1)
    end
    if not tex:GetTexture() then
        tex:SetTexture(236681) -- Achievement_Reputation_01
        if tex:GetTexture() then
            tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            tex:SetVertexColor(1, 1, 1)
        end
    end
    if tex:GetTexture() then
        tex:Show()
    end
end

function FactionUI:GetAccentColor(factionID, entry, majorFactionData, reputationInfo)
    if entry and entry.color then
        return entry.color[1], entry.color[2], entry.color[3]
    end
    local override = self.colorOverrides[factionID]
    if override then
        return override[1], override[2], override[3]
    end
    if majorFactionData and majorFactionData.factionFontColor and majorFactionData.factionFontColor.color then
        return majorFactionData.factionFontColor.color:GetRGB()
    end
    if reputationInfo and FACTION_BAR_COLORS then
        local standingColor = FACTION_BAR_COLORS[reputationInfo.reaction or 4]
        if standingColor then
            return standingColor.r, standingColor.g, standingColor.b
        end
    end
    return C_GOLD[1], C_GOLD[2], C_GOLD[3]
end

function FactionUI:ApplyAccentColor(card, r, g, b)
    if card.progress then card.progress:SetSwipeColor(r, g, b, 1) end
    if card.fullRing then card.fullRing:SetVertexColor(r, g, b, 1) end
    if card.button and card.button.IconFrame and card.button.IconFrame.Border then
        card.button.IconFrame.Border:SetVertexColor(r, g, b)
    end
end

function FactionUI:ApplyArt(card, expansionID, textureKit)
    self:SetCardAtlas(card, self:GetCardAtlas(card, false))

    if card.button and card.button.IconFrame and card.button.IconFrame.Border then
        if SM.IsRetailClient() then
            card.button.IconFrame.Border:SetAtlas("ui-journeys-renown-radial-bar", false)
        elseif not self:SetAtlas(card.button.IconFrame.Border, "ui-journeys-renown-radial-bar", false) then
            card.button.IconFrame.Border:Hide()
        end
        card.button.IconFrame.Border:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3])
        card.button.IconFrame.Border:Show()
    end

    local fillAtlas = "ui-journeys-renown-radial-fill"
    local fillInfo = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(fillAtlas)
    if fillInfo then
        if card.progress then
            card.progress:SetSwipeTexture(fillInfo.file or fillInfo.filename)
            if card.progress.SetTexCoordRange then
                card.progress:SetTexCoordRange(
                    { x = fillInfo.leftTexCoord, y = fillInfo.topTexCoord },
                    { x = fillInfo.rightTexCoord, y = fillInfo.bottomTexCoord }
                )
            end
            card.progress:SetSwipeColor(1, 0.82, 0.1, 1)
        end
        if card.fullRing then
            card.fullRing:SetTexture(fillInfo.file or fillInfo.filename)
            card.fullRing:SetTexCoord(
                fillInfo.leftTexCoord, fillInfo.rightTexCoord,
                fillInfo.topTexCoord, fillInfo.bottomTexCoord
            )
        end
        if card.fullRing then card.fullRing:SetVertexColor(1, 0.82, 0.1, 1) end
    else
        if card.progress then
            card.progress:SetSwipeColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0.95)
        end
        if card.fullRing then card.fullRing:SetVertexColor(C_GOLD[1], C_GOLD[2], C_GOLD[3], 0.95) end
    end
end

function FactionUI:SetProgress(card, pct)
    pct = math.max(0, math.min(1, pct or 0))
    local isFull = pct >= 0.999
    if card.fullRing then
        card.fullRing:SetShown(isFull)
    end
    if card.progress then
        card.progress:SetShown(pct > 0 and not isFull)
        if pct > 0 and not isFull then
            if CooldownFrame_SetDisplayAsPercentage then
                CooldownFrame_SetDisplayAsPercentage(card.progress, pct)
            else
                local DURATION = 1000
                card.progress:SetCooldown(GetTime() - pct * DURATION, DURATION)
                if card.progress.Pause then card.progress:Pause() end
            end
        end
    end
end

function FactionUI:LayoutLeftCardText(card)
    if not card or not card.leftContext or not card.nameLabel or not card.statusLabel then return end
    if card.tileMode then
        local textW = math.max(70, (card:GetWidth() or self.TILE_SIZE) - 16)
        card.nameLabel:SetWidth(textW)
        card.statusLabel:SetWidth(textW)
        local nameH = math.ceil(math.max(14, card.nameLabel:GetStringHeight() or 14))
        local statusH = math.ceil(math.max(12, card.statusLabel:GetStringHeight() or 12))

        card.nameLabel:ClearAllPoints()
        card.nameLabel:SetPoint("TOP", card.button.IconFrame, "BOTTOM", 0, -6)
        card.nameLabel:SetPoint("LEFT", card, "LEFT", 8, 0)
        card.nameLabel:SetPoint("RIGHT", card, "RIGHT", -8, 0)
        card.nameLabel:SetHeight(nameH)
        card.nameLabel:SetJustifyH("CENTER")
        card.nameLabel:SetJustifyV("TOP")
        card.statusLabel:ClearAllPoints()
        card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, 0)
        card.statusLabel:SetPoint("RIGHT", card.nameLabel, "RIGHT", 0, 0)
        card.statusLabel:SetHeight(statusH)
        card.statusLabel:SetJustifyH("CENTER")
        return
    end
    if not card.textGroup then
        card.textGroup = CreateFrame("Frame", nil, card.button)
    end

    local textGap = 1
    local textW = math.max(80, (card.button:GetWidth() or ((SM.LeftWidth or 274) - 32)) - 84)
    card.nameLabel:SetWidth(textW)
    card.statusLabel:SetWidth(textW)
    local nameH = math.ceil(math.max(14, card.nameLabel:GetStringHeight() or 14))
    local statusH = math.ceil(math.max(12, card.statusLabel:GetStringHeight() or 12))
    local blockH = nameH + textGap + statusH

    card.textGroup:ClearAllPoints()
    card.textGroup:SetPoint("LEFT", card.button.IconFrame, "RIGHT", 10, 0)
    card.textGroup:SetPoint("RIGHT", card.button, "RIGHT", -12, 0)
    card.textGroup:SetPoint("TOP", card.button, "CENTER", 0, blockH / 2)
    card.textGroup:SetHeight(blockH)

    card.nameLabel:ClearAllPoints()
    card.nameLabel:SetPoint("TOPLEFT", card.textGroup, "TOPLEFT", 0, 0)
    card.nameLabel:SetPoint("RIGHT", card.textGroup, "RIGHT", 0, 0)
    card.nameLabel:SetHeight(nameH)
    card.nameLabel:SetJustifyV("TOP")
    card.statusLabel:ClearAllPoints()
    card.statusLabel:SetPoint("TOPLEFT", card.nameLabel, "BOTTOMLEFT", 0, -textGap)
    card.statusLabel:SetPoint("RIGHT", card.textGroup, "RIGHT", 0, 0)
    card.statusLabel:SetHeight(statusH)
end

function FactionUI:NormalizeEntry(entry)
    if type(entry) == "table" then
        return entry
    end
    return { id = entry }
end

function FactionUI:Update(card, entry, storyData)
    entry = self:NormalizeEntry(entry)
    local factionID = entry.id or entry.factionID
    if not factionID then card:Hide(); return false end

    local pct, name, status, description = 0, nil, "", entry.description

    local mf = C_MajorFactions and C_MajorFactions.GetMajorFactionData
        and C_MajorFactions.GetMajorFactionData(factionID)
    if mf and mf.name then
        name = mf.name
        description = description or mf.description or self.descriptions[factionID]
        local cur = mf.renownReputationEarned or 0
        local need = mf.renownLevelThreshold or 0
        if need > 0 then pct = math.max(0, math.min(1, cur / need)) end
        local maxLevel = 0
        if C_MajorFactions.GetRenownLevels then
            local levels = C_MajorFactions.GetRenownLevels(factionID)
            if levels then maxLevel = #levels end
        end
        if maxLevel > 0 and (mf.renownLevel or 0) >= maxLevel then
            pct = 1
        end
        status = maxLevel > 0
            and string.format("Renown %d/%d", mf.renownLevel or 0, maxLevel)
            or string.format("Renown %d", mf.renownLevel or 0)
        self:ApplyArt(card, mf.expansionID, mf.textureKit)
        self:SetIcon(card.icon, entry.iconAtlas or (mf.textureKit and ("majorfactions_icons_" .. mf.textureKit .. "512")), self:GetFactionIcon(factionID, entry))
        self:ApplyAccentColor(card, self:GetAccentColor(factionID, entry, mf, nil))
    else
        local info = SM.GetFactionDataByID(factionID)
        if not info or not info.name then card:Hide(); return false end
        name = info.name
        description = description or info.description or self.descriptions[factionID]
        local reaction = info.reaction or 4
        local minRep   = info.currentReactionThreshold or 0
        local maxRep   = info.nextReactionThreshold or (minRep + 1)
        local cur      = info.currentStanding or 0
        if reaction >= 8 or (info.nextReactionThreshold == nil and cur >= minRep) then
            pct = 1
        elseif maxRep > minRep then
            pct = math.max(0, math.min(1, (cur - minRep) / (maxRep - minRep)))
        end
        status = _G["FACTION_STANDING_LABEL" .. reaction] or ""
        self:ApplyArt(card, entry.expansionID, entry.textureKit)
        self:SetIcon(card.icon, entry.iconAtlas, self:GetFactionIcon(factionID, entry))
        self:ApplyAccentColor(card, self:GetAccentColor(factionID, entry, nil, info))
    end

    card.factionID = factionID
    card.isMajorFaction = (mf and mf.name) and true or false
    if card.nameLabel then card.nameLabel:SetText(name) end
    if card.statusLabel then card.statusLabel:SetText(status) end
    self:LayoutLeftCardText(card)
    if card.leftContext and C_Timer then
        C_Timer.After(0, function()
            FactionUI:LayoutLeftCardText(card)
        end)
    end
    card.tooltipTitle = name
    card.tooltipStatus = status
    card.tooltipDescription = description
    self:SetProgress(card, pct)
    card:Show()
    return true
end

function FactionUI:HideAll()
    for _, c in ipairs(self.cards) do c:Hide() end
    if self.spacer then self.spacer:Hide() end
end


SM.FactionUI = FactionUI
