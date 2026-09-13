local addonName, SM = ...

-- Private tooltip: plain Frame, never touches the GameTooltip C layer so we
-- cannot taint MoneyFrame or EmbeddedItemTooltip arithmetic in Blizzard code.
do
    local TTPAD  = 10
    local TTLSP  = 2
    local TTWRAP = 380
    local TTMIN  = 220
    local DEFAULT_HEADER_COLOR = HIGHLIGHT_FONT_COLOR or { r = 1, g = 1, b = 1 }
    local DEFAULT_BODY_COLOR = NORMAL_FONT_COLOR or { r = 1, g = 0.82, b = 0 }
    local TOOLTIP_BACKDROP = BACKDROP_TOOLTIP_16_16_5555 or {
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    }

    local function ApplyLineFont(fs, isHeader)
        if not fs.SetFontObject then return end
        if isHeader and GameTooltipHeaderText then
            fs:SetFontObject(GameTooltipHeaderText)
        elseif GameTooltipText then
            fs:SetFontObject(GameTooltipText)
        end
    end

    local function ApplyColorObject(fs, color)
        if color and color.GetRGB then
            fs:SetTextColor(color:GetRGB())
        elseif color and color.r then
            fs:SetTextColor(color.r, color.g, color.b)
        else
            fs:SetTextColor(1, 1, 1)
        end
    end

    local function IsStoryModeBodyColor(r, g, b)
        return r and g and b
            and r > 0.88 and r < 0.95
            and g > 0.84 and g < 0.90
            and b > 0.72 and b < 0.80
    end

    local function ApplyLineColor(fs, isHeader, r, g, b)
        if r and g and b and not IsStoryModeBodyColor(r, g, b) then
            fs:SetTextColor(r, g, b)
            return
        end

        ApplyColorObject(fs, isHeader and DEFAULT_HEADER_COLOR or DEFAULT_BODY_COLOR)
    end

    local ok, tooltip = pcall(CreateFrame, "Frame", "StoryModeTooltip", UIParent, "TooltipBackdropTemplate")
    local usesTooltipBackdropTemplate = ok and tooltip and tooltip.NineSlice
    if not ok or not tooltip then
        tooltip = CreateFrame("Frame", "StoryModeTooltip", UIParent, "BackdropTemplate")
    end
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetToplevel(true)
    tooltip:SetClampedToScreen(true)
    tooltip:Hide()
    if usesTooltipBackdropTemplate then
        if NineSliceUtil and NineSliceUtil.GetLayout and NineSliceUtil.ApplyLayout then
            NineSliceUtil.ApplyLayout(tooltip.NineSlice, NineSliceUtil.GetLayout("TooltipDefaultLayout"))
        end
        if TOOLTIP_DEFAULT_BACKGROUND_COLOR and TOOLTIP_DEFAULT_BACKGROUND_COLOR.GetRGB then
            local r, g, b = TOOLTIP_DEFAULT_BACKGROUND_COLOR:GetRGB()
            tooltip:SetBackdropColor(r, g, b, 1)
        end
    else
        tooltip:SetBackdrop(TOOLTIP_BACKDROP)
        tooltip:SetBackdropColor(0, 0, 0, 1)
        tooltip:SetBackdropBorderColor(1, 1, 1, 1)
    end

    local ttLines = {}
    local ttLineN = 0
    local ttWraps = {}  -- parallel bool array: ttWraps[i] = true if line i wraps

    local function TTLine(i)
        if not ttLines[i] then
            local fs = tooltip:CreateFontString(nil, "OVERLAY", "GameTooltipText")
            fs:SetJustifyH("LEFT")
            ttLines[i] = fs
        end
        return ttLines[i]
    end

    local frameShow = tooltip.Show

    function tooltip:SetOwner(frame, anchor)
        self:ClearAllPoints()
        if anchor == "ANCHOR_LEFT" then
            self:SetPoint("TOPRIGHT", frame, "TOPLEFT", -5, 0)
        else
            self:SetPoint("TOPLEFT", frame, "TOPRIGHT", 5, 0)
        end
    end

    function tooltip:ClearLines()
        ttLineN = 0
        for _, fs in ipairs(ttLines) do fs:Hide() end
        ttWraps = {}
    end

    function tooltip:AddLine(text, r, g, b, wrap)
        ttLineN = ttLineN + 1
        local fs = TTLine(ttLineN)
        ApplyLineFont(fs, ttLineN == 1)
        ApplyLineColor(fs, ttLineN == 1, r, g, b)
        fs:SetWordWrap(wrap and true or false)
        fs:SetWidth(wrap and TTWRAP or 0)
        fs:SetText(text or "")
        ttWraps[ttLineN] = wrap and true or false
        fs:Show()
    end

    function tooltip:Show()
        local maxW = self._minW ~= nil and self._minW or TTMIN
        self._minW = nil
        for i = 1, ttLineN do
            local fs = ttLines[i]
            if fs and fs:IsShown() and not ttWraps[i] then
                local w = fs:GetStringWidth()
                if w > maxW then maxW = w end
            end
        end
        local innerW = math.min(maxW, TTWRAP)

        local yOff = -TTPAD
        for i = 1, ttLineN do
            local fs = ttLines[i]
            if fs and fs:IsShown() then
                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", self, "TOPLEFT", TTPAD, yOff)
                if ttWraps[i] then fs:SetWidth(innerW) end
                yOff = yOff - fs:GetStringHeight() - TTLSP
            end
        end

        self:SetWidth(innerW + TTPAD * 2)
        self:SetHeight(math.abs(yOff) - TTLSP + TTPAD)
        frameShow(self)
    end

    SM.Tooltip = tooltip
end
