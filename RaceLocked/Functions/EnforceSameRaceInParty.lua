
local function EnforceSameRaceInParty()
    local playerRace = UnitRace("player")
    if not playerRace then
        return
    end
    -- In Classic, party units are addressed as party1..partyN.
    local partyCount = GetNumSubgroupMembers()
    for i = 1, partyCount do
        local memberUnit = "party" .. i
        local memberName = UnitName(memberUnit)
        local memberRace = UnitRace(memberUnit)

        if memberName and memberRace then
            if memberRace ~= playerRace then
                print("|cfff44336[Race Locked]|r Leaving party because " .. memberName .. " is not the same race as me.")
                LeaveParty()
            end
        end
    end
end

EnforceSameRaceInPartyFrame = CreateFrame('Frame')

EnforceSameRaceInPartyFrame:RegisterEvent('GROUP_ROSTER_UPDATE')

EnforceSameRaceInPartyFrame:SetScript('OnEvent', function(self, event, ...)
    if event == "GROUP_ROSTER_UPDATE" then
        EnforceSameRaceInParty()
    end
end)
