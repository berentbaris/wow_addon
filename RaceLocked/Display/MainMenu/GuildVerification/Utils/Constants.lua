--- Shared constants for the Guild Verification tab.
--- Used by both View.lua (verification checklist) and RosterTable/View.lua
--- (the roster table). Constants used by only one of those files stay local
--- to that file so this stays a true shared surface, not a grab-bag.
RaceLocked_GuildVerification = RaceLocked_GuildVerification or {}

local V = RaceLocked_GuildVerification

-- Left/right inset for the tab content, shared so the checklist and the roster
-- table align against the same margin.
V.LIST_LEFT_OFFSET = 10
