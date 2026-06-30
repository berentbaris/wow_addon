--- Classify inbox mail as player, auction house, game master, or NPC/system.
--- Uses GetInboxInvoiceInfo for AH detection (does not call GetInboxText).

local KIND_PLAYER = 'player'
local KIND_AUCTION_HOUSE = 'auction_house'
local KIND_GAME_MASTER = 'game_master'
local KIND_NPC = 'npc'

local KIND_LABELS = {
  [KIND_PLAYER] = 'player',
  [KIND_AUCTION_HOUSE] = 'auction house',
  [KIND_GAME_MASTER] = 'game master',
  [KIND_NPC] = 'NPC/system',
}

--- Returns the AH invoice type for this mail, or nil if it isn't AH mail.
--- (GetInboxInvoiceInfo returns its first value only for auction-house mail.)
--- @param inboxIndex number
--- @return string|nil invoiceType
local function getInvoiceType(inboxIndex)
  if not GetInboxInvoiceInfo then return nil end
  return GetInboxInvoiceInfo(inboxIndex)
end

--- @param inboxIndex number
--- @return table|nil info { kind, sender, canReply, isGM, invoiceType, label }
function RaceLocked_ClassifyInboxMail(inboxIndex)
  if not inboxIndex or not GetInboxHeaderInfo then return nil end

  local _, _, sender, _, _, _, _, _, _, _, _, canReply, isGM =
    GetInboxHeaderInfo(inboxIndex)

  if isGM and isGM ~= false and isGM ~= 0 then
    return {
      kind = KIND_GAME_MASTER,
      sender = sender,
      canReply = canReply,
      isGM = isGM,
      invoiceType = nil,
      label = KIND_LABELS[KIND_GAME_MASTER],
    }
  end

  local invoiceType = getInvoiceType(inboxIndex)
  if invoiceType ~= nil then
    return {
      kind = KIND_AUCTION_HOUSE,
      sender = sender,
      canReply = canReply,
      isGM = isGM,
      invoiceType = invoiceType,
      label = KIND_LABELS[KIND_AUCTION_HOUSE],
    }
  end

  -- Player-mail discriminator: GetInboxHeaderInfo reports canReply=true for
  -- mail originating from a real character (you can reply to them). System/NPC
  -- mail is not replyable. Assumption: any genuine player mail is replyable.
  -- If WoW ever delivers replyable=false player mail (e.g. exotic COD/system-
  -- wrapped cases), it would fall through to KIND_NPC and be allowed; no such
  -- case is currently known on Classic. Revisit here if one is found.
  if canReply and sender and sender ~= '' then
    return {
      kind = KIND_PLAYER,
      sender = sender,
      canReply = canReply,
      isGM = isGM,
      invoiceType = nil,
      label = KIND_LABELS[KIND_PLAYER],
    }
  end

  return {
    kind = KIND_NPC,
    sender = sender,
    canReply = canReply,
    isGM = isGM,
    invoiceType = nil,
    label = KIND_LABELS[KIND_NPC],
  }
end
