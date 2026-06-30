local SELF_FOUND_SPELL_ID = 431567

function RaceLocked_PlayerHasSelfFoundBuff()
  for i = 1, 40 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitBuff('player', i)
    if not name then
      return false
    end
    if spellId == SELF_FOUND_SPELL_ID then
      return true
    end
  end
  return false
end
