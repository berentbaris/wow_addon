#!/usr/bin/env python3
"""
Patch ItemSourceData.lua:
  1. Strip all 'nan' entries (caused by JS parseInt returning NaN)
  2. Add the looted_gear (drop) list from debug_items.json

Run from the tools/ directory:
    python patch_itemsource.py
"""

import os, json, re, math

script_dir = os.path.dirname(os.path.abspath(__file__))
debug_path = os.path.join(script_dir, "debug_items.json")
lua_path   = os.path.join(script_dir, "..", "ItemSourceData.lua")

# --- Step 1: Load drop IDs from debug_items.json ---

print("Loading debug_items.json...")
with open(debug_path) as f:
    data = json.load(f)

# Clean all lists (remove NaN)
for key in data:
    raw = data[key]
    data[key] = sorted(set(
        int(x) for x in raw
        if isinstance(x, (int, float)) and not (isinstance(x, float) and math.isnan(x)) and x > 0
    ))
    print(f"  {key}: {len(raw)} raw -> {len(data[key])} clean")

drop_ids = data.get("drop", [])
if not drop_ids:
    print("ERROR: No 'drop' key in debug_items.json!")
    exit(1)

print(f"\nDrop list: {len(drop_ids)} items")
print(f"  First 10: {drop_ids[:10]}")
print(f"  Last 10:  {drop_ids[-10:]}")

# --- Step 2: Read and patch ItemSourceData.lua ---

print(f"\nReading {lua_path}...")
with open(lua_path, "r", encoding="utf-8") as f:
    lua = f.read()

# Count nan occurrences before fix
nan_count = lua.count(",nan,") + lua.count(",nan\n") + lua.count("nan,")
print(f"  Found ~{nan_count} nan references")

# Strip nan entries: ",nan," -> ","  and handle edge cases
# Replace ,nan, with ,
lua = re.sub(r',nan(?=,)', '', lua)
# Replace nan, at start of line content
lua = re.sub(r'(?<=\{)\s*nan,', '', lua)
# Replace ,nan at end before }
lua = re.sub(r',nan(?=\s*\})', '', lua)
# Replace any remaining standalone nan in number lists
lua = re.sub(r'\bnan\b', '', lua)
# Clean up double commas left behind
while ',,' in lua:
    lua = lua.replace(',,', ',')
# Clean up leading comma after indent
lua = re.sub(r'^(\s+),', r'\1', lua, flags=re.MULTILINE)
# Clean up trailing comma before newline then closing brace
# (this is fine in Lua, trailing commas are allowed)

# --- Step 3: Format drop IDs ---

def fmt(ids, per_line=15):
    lines = []
    for i in range(0, len(ids), per_line):
        lines.append("    " + ",".join(str(x) for x in ids[i:i+per_line]) + ",")
    return "\n".join(lines)

drop_block = f"""----------------------------------------------------------------------
-- LOOTED / DROP ITEMS ({len(drop_ids):,} items)
----------------------------------------------------------------------

fill(C.looted_gear, {{
{fmt(drop_ids)}
}})
COMPLETE["looted_gear"] = true

"""

# --- Step 4: Insert drop block after crafted_items block ---

# Find the COMPLETE["crafted_items"] line and insert after it
marker = 'COMPLETE["crafted_items"] = true'
pos = lua.find(marker)
if pos == -1:
    print("ERROR: Could not find crafted_items COMPLETE marker!")
    exit(1)

# Find the end of that line
end_of_line = lua.find('\n', pos) + 1
lua = lua[:end_of_line] + "\n" + drop_block + lua[end_of_line:]

# --- Step 5: Update header comment ---

# Add drop count to header
lua = re.sub(
    r'(-- Crafted items\s+:\s+[\d,]+)',
    lambda m: m.group(0) + f'\n-- Looted (drop) items: {len(drop_ids):,}',
    lua
)

# --- Step 6: Update AllSourceListsComplete to include looted_gear ---

lua = lua.replace(
    '''function HCE.AllSourceListsComplete()
    return COMPLETE["quest_rewards"]
       and COMPLETE["vendor_items"]
       and COMPLETE["crafted_items"]
end''',
    '''function HCE.AllSourceListsComplete()
    return COMPLETE["quest_rewards"]
       and COMPLETE["vendor_items"]
       and COMPLETE["crafted_items"]
       and COMPLETE["looted_gear"]
end'''
)

# --- Step 7: Update CheckItemSource to include looted_gear ---

old_check = '''    if C.crafted_items and C.crafted_items[itemID] then
        return true, "crafted"
    end
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.CraftedByProfession then
        for profName, list in pairs(HCE.SelfFoundCheck.CraftedByProfession) do
            if list[itemID] then
                return true, profName .. "-crafted"
            end
        end
    end
    return false, nil'''

new_check = '''    if C.crafted_items and C.crafted_items[itemID] then
        return true, "crafted"
    end
    if C.looted_gear and C.looted_gear[itemID] then
        return true, "loot drop"
    end
    return false, nil'''

if old_check in lua:
    lua = lua.replace(old_check, new_check)
    print("  Updated CheckItemSource (removed SelfFoundCheck.CraftedByProfession fallback)")
else:
    print("  WARNING: Could not find old CheckItemSource pattern to replace")
    # Try simpler replacement
    if 'return false, nil\nend' in lua and 'looted_gear' not in lua.split('CheckItemSource')[1].split('end')[0]:
        print("  Attempting simpler insertion...")

# --- Step 8: Add HCE.IsLootDrop helper if not present ---

if 'function HCE.IsLootDrop' not in lua:
    insert_after = 'function HCE.AllSourceListsComplete()'
    # Find the end of AllSourceListsComplete function
    aslc_pos = lua.find(insert_after)
    if aslc_pos != -1:
        # Find the 'end' that closes this function
        end_pos = lua.find('\nend', aslc_pos) + 4
        lua = lua[:end_pos] + """

function HCE.IsLootDrop(itemID)
    if not itemID then return false end
    return C.looted_gear and C.looted_gear[itemID] or false
end""" + lua[end_pos:]
        print("  Added HCE.IsLootDrop helper")

# --- Step 9: Update PrintItemSources to show loot drops ---

lua = lua.replace(
    'local checked, unknown, vendorN, questN, craftedN = 0, 0, 0, 0, 0',
    'local checked, unknown, vendorN, questN, craftedN, lootedN = 0, 0, 0, 0, 0, 0'
)
lua = lua.replace(
    '                    else craftedN = craftedN + 1 end',
    '                    elseif source == "loot drop" then lootedN = lootedN + 1\n                    else craftedN = craftedN + 1 end'
)
lua = lua.replace(
    '"Summary: %d checked — %d vendor, %d quest, %d crafted, %d unknown/loot"',
    '"Summary: %d checked — %d vendor, %d quest, %d crafted, %d looted, %d unknown"'
)
lua = lua.replace(
    'checked, vendorN, questN, craftedN, unknown',
    'checked, vendorN, questN, craftedN, lootedN, unknown'
)
lua = lua.replace(
    '— unknown source (assumed loot drop)',
    '— unknown source'
)

# --- Write patched file ---

print(f"\nWriting patched {lua_path}...")
with open(lua_path, "w", encoding="utf-8") as f:
    f.write(lua)

# Verify no nan remains
with open(lua_path, "r") as f:
    content = f.read()
remaining = len(re.findall(r'\bnan\b', content))
print(f"  Remaining nan references: {remaining}")
print(f"  Total lines: {content.count(chr(10))}")

print("\nDone! ItemSourceData.lua patched successfully.")
print("  - All nan values stripped")
print(f"  - looted_gear list added ({len(drop_ids):,} items)")
print("  - CheckItemSource updated to check looted_gear")
print("  - IsLootDrop helper added")
print("  - AllSourceListsComplete updated")
print("  - PrintItemSources updated")
