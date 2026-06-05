#!/usr/bin/env python3
"""
Scrape WoW Classic item source data from Wowhead and generate ItemSourceData.lua.

Usage:
    python scrape_wowhead_items.py

Output:
    ../ItemSourceData.lua  (overwrites the existing file)

Requirements:
    pip install requests

How it works:
    Wowhead embeds listview data as JavaScript in their HTML pages.
    This script fetches filtered item list pages, extracts the embedded
    JSON data, and collects item IDs by source type.

    Filters used:
      - Source = Quest (type 4): quest reward items
      - Source = Vendor (type 3): vendor-sold items
      - Item class = Armor (4) or Weapon (2): equippable only

    Wowhead paginates at around 500-1000 items per page.  We handle
    pagination by appending quality and level filters to keep each
    request under the limit.
"""

import requests
import re
import json
import time
import sys
import os

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
}

SESSION = requests.Session()
SESSION.headers.update(HEADERS)

# Delay between requests to be polite
REQUEST_DELAY = 1.5  # seconds

# Wowhead Classic base URL
BASE = "https://www.wowhead.com/classic/items"

# Level ranges to split requests (avoid Wowhead's 1000-item cap per page)
LEVEL_RANGES = [
    (1, 10), (11, 20), (21, 30), (31, 40),
    (41, 50), (51, 60), (61, 63),  # 61-63 catches some high-ilvl items
]

# ---------------------------------------------------------------------------
# Wowhead listview data extraction
# ---------------------------------------------------------------------------

# Wowhead embeds item data in JavaScript like:
#   new Listview({template: 'item', id: 'items', ...data: [{...}, ...]});
# or in a WH.Gatherer.addData format.
# We look for the data array in the listview.

LISTVIEW_PATTERN = re.compile(
    r'new Listview\(\{[^}]*?data:\s*(\[.*?\])\s*\}\)',
    re.DOTALL
)

# Alternative: WH.Gatherer.addData
GATHERER_PATTERN = re.compile(
    r"WH\.Gatherer\.addData\(\s*\d+\s*,\s*\d+\s*,\s*(\{.*?\})\s*\)",
    re.DOTALL
)

# Simpler: just find arrays of objects with "id" fields
DATA_ARRAY_PATTERN = re.compile(
    r'data:\s*(\[\{.*?\}\])',
    re.DOTALL
)


def extract_item_ids_from_page(html):
    """Extract item IDs from a Wowhead listview page."""
    item_ids = set()

    # Try the listview data pattern first
    for pattern in [DATA_ARRAY_PATTERN, LISTVIEW_PATTERN]:
        matches = pattern.findall(html)
        for match in matches:
            try:
                # Clean up JavaScript-style JSON (single quotes, trailing commas)
                cleaned = match.replace("'", '"')
                # Remove trailing commas before ] or }
                cleaned = re.sub(r',\s*([}\]])', r'\1', cleaned)
                data = json.loads(cleaned)
                if isinstance(data, list):
                    for item in data:
                        if isinstance(item, dict) and "id" in item:
                            item_ids.add(item["id"])
            except json.JSONDecodeError:
                continue

    # Fallback: scan for "id":NNNNN patterns in listview context
    if not item_ids:
        # Look for the data section between "data:" and the closing
        data_section = re.search(r'data:\s*\[(.+?)\]\s*\}', html, re.DOTALL)
        if data_section:
            id_matches = re.findall(r'"id"\s*:\s*(\d+)', data_section.group(1))
            for m in id_matches:
                item_ids.add(int(m))

    # Ultra-fallback: find item IDs from link patterns
    if not item_ids:
        # Wowhead item links: /classic/item=12345
        link_ids = re.findall(r'/classic/item[=/](\d+)', html)
        for lid in link_ids:
            item_ids.add(int(lid))

    return item_ids


def fetch_items(source_type, item_class, level_min, level_max):
    """
    Fetch items from Wowhead with filters.

    source_type: 3=Vendor, 4=Quest
    item_class: 2=Weapon, 4=Armor
    level_min/max: required level range

    Wowhead filter format: filter=FILTER1:FILTER2;COMP1:COMP2;VAL1:VAL2
      Filter 16 = Source type (3=Vendor, 4=Quest)
      Filter 21 = Item class (2=Weapon, 4=Armor)
      Filter 152 = Required level (min)
      Filter 153 = Required level (max)... actually this isn't right.

    Wowhead URL format for filtered lists:
      /items/CLASS?filter=CRITERIA
      /items/armor?filter=16;4;0  (source = quest)
      /items/weapons?filter=16;3;0  (source = vendor)

    The filter system uses semicolons to separate filter ID, comparison, value.
    Multiple filters: filter=ID1:ID2;COMP1:COMP2;VAL1:VAL2

    Actually Wowhead's filter format is:
      ?filter=FilterID;Comparison;Value
    For multiple: ?filter=F1:F2;C1:C2;V1:V2
    Where comparison: 1=exact, 2=contains, 4=quest-reward, etc.
    For source: filter 128 with value 4 = quest, 5 = vendor

    Let me use the simpler class-based URL approach:
      /items/armor/quality:2:3:4?filter=128;1;SOURCE_TYPE#items;0+LEVEL_MIN;LEVEL_MAX
    """
    # Wowhead Classic URL format for item filtering by source
    # Filter 128 = Source, values: 1=crafted, 2=drop(treasure), 4=quest, 5=vendor, 6=trainer
    # Note: Wowhead uses different source IDs than what I assumed earlier

    class_slug = "armor" if item_class == 4 else "weapons"

    # Build filter: source + level range
    # filter=128:2;SOURCE:5;VALUE:LEVEL
    # Actually the level filter uses min-level and max-level params
    url = (
        f"{BASE}/{class_slug}"
        f"?filter=128;1;{source_type}"
        f"&minle={level_min}&maxle={level_max}"
    )

    try:
        print(f"  Fetching: {class_slug} source={source_type} levels {level_min}-{level_max} ...", end=" ", flush=True)
        resp = SESSION.get(url, timeout=30)
        resp.raise_for_status()
        ids = extract_item_ids_from_page(resp.text)
        print(f"found {len(ids)} items")
        return ids
    except Exception as e:
        print(f"ERROR: {e}")
        return set()


def fetch_all_items_for_source(source_type, source_name):
    """Fetch all equippable items for a given source type across all level ranges."""
    all_ids = set()

    for item_class in [4, 2]:  # Armor, Weapons
        class_name = "Armor" if item_class == 4 else "Weapons"
        print(f"\n  [{source_name}] {class_name}:")
        for lmin, lmax in LEVEL_RANGES:
            ids = fetch_items(source_type, item_class, lmin, lmax)
            all_ids.update(ids)
            time.sleep(REQUEST_DELAY)

    # Also fetch without level filter to catch items with no level req
    for item_class in [4, 2]:
        class_name = "Armor" if item_class == 4 else "Weapons"
        print(f"\n  [{source_name}] {class_name} (no level filter):")
        url = f"{BASE}/{'armor' if item_class == 4 else 'weapons'}?filter=128;1;{source_type}"
        try:
            print(f"  Fetching: {url} ...", end=" ", flush=True)
            resp = SESSION.get(url, timeout=30)
            resp.raise_for_status()
            ids = extract_item_ids_from_page(resp.text)
            print(f"found {len(ids)} items")
            all_ids.update(ids)
        except Exception as e:
            print(f"ERROR: {e}")
        time.sleep(REQUEST_DELAY)

    return all_ids


# ---------------------------------------------------------------------------
# Alternative approach: use Wowhead's search/suggest API
# ---------------------------------------------------------------------------

def try_wowhead_api_approach(source_type):
    """
    Try Wowhead's internal API endpoints.
    These return JSON directly without needing HTML parsing.
    """
    # Wowhead has an undocumented API at:
    # https://www.wowhead.com/classic/items?filter=128;1;SOURCE&data=json
    # or possibly through their nether subdomain
    pass


# ---------------------------------------------------------------------------
# Lua code generation
# ---------------------------------------------------------------------------

LUA_HEADER = '''----------------------------------------------------------------------
-- HardcoreClassesEnhanced — Item Source Data
--
-- AUTO-GENERATED by tools/scrape_wowhead_items.py
-- Date: {date}
--
-- Comprehensive item-source database from Wowhead Classic.
-- Three source tables:
--   quest_rewards — items awarded from quest completion
--   vendor_items  — items purchasable from NPC vendors
--   looted_gear   — kept for API compat (Partisan uses exclusion)
--
-- Quest reward count : {quest_count}
-- Vendor item count  : {vendor_count}
----------------------------------------------------------------------

HCE = HCE or {{}}
HCE.CuratedItems = HCE.CuratedItems or {{}}
HCE.CuratedComplete = HCE.CuratedComplete or {{}}

local C = HCE.CuratedItems
local COMPLETE = HCE.CuratedComplete

----------------------------------------------------------------------
-- Helper
----------------------------------------------------------------------

local function fill(tbl, ids)
    for i = 1, #ids do
        tbl[ids[i]] = true
    end
end

----------------------------------------------------------------------
-- Ensure the item-source tables exist
----------------------------------------------------------------------

C.quest_rewards = C.quest_rewards or {{}}
C.vendor_items  = C.vendor_items  or {{}}
C.looted_gear   = C.looted_gear   or {{}}

----------------------------------------------------------------------
-- QUEST REWARD ITEMS (auto-generated from Wowhead Classic)
----------------------------------------------------------------------

fill(C.quest_rewards, {{
{quest_ids}
}})
COMPLETE["quest_rewards"] = true

----------------------------------------------------------------------
-- VENDOR-SOLD ITEMS (auto-generated from Wowhead Classic)
----------------------------------------------------------------------

fill(C.vendor_items, {{
{vendor_ids}
}})
COMPLETE["vendor_items"] = true
'''

LUA_FOOTER = '''
----------------------------------------------------------------------
-- COMBINED SOURCE CHECKER
----------------------------------------------------------------------

function HCE.CheckItemSource(itemID)
    if not itemID then return false, nil end

    -- 1. Vendor items
    if C.vendor_items and C.vendor_items[itemID] then
        return true, "vendor"
    end

    -- 2. Quest rewards
    if C.quest_rewards and C.quest_rewards[itemID] then
        return true, "quest reward"
    end

    -- 3. Profession-crafted items (from SelfFoundCheck)
    if HCE.SelfFoundCheck and HCE.SelfFoundCheck.CraftedByProfession then
        for profName, list in pairs(HCE.SelfFoundCheck.CraftedByProfession) do
            if list[itemID] then
                return true, profName .. "-crafted"
            end
        end
    end

    return false, nil
end

----------------------------------------------------------------------
-- SOURCE COMPLETENESS
----------------------------------------------------------------------

function HCE.AllSourceListsComplete()
    return COMPLETE["quest_rewards"]
       and COMPLETE["vendor_items"]
end

----------------------------------------------------------------------
-- ITEM SOURCE SLASH COMMAND HELPER
----------------------------------------------------------------------

local SLOT_NAMES = {
    [1]  = "Head",     [2]  = "Neck",     [3]  = "Shoulder",
    [5]  = "Chest",    [6]  = "Waist",    [7]  = "Legs",
    [8]  = "Feet",     [9]  = "Wrist",    [10] = "Hands",
    [11] = "Ring 1",   [12] = "Ring 2",   [13] = "Trinket 1",
    [14] = "Trinket 2",[15] = "Back",     [16] = "Main Hand",
    [17] = "Off Hand", [18] = "Ranged",   [19] = "Tabard",
}

local GEAR_SLOTS = {
    1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
}

local QUALITY_LABELS = {
    [0] = "poor", [1] = "common", [2] = "uncommon",
    [3] = "rare", [4] = "epic",   [5] = "legendary",
}

function HCE.PrintItemSources()
    if not HCE_CharDB or not HCE_CharDB.selectedCharacter then
        HCE.Print("No enhanced class selected.")
        return
    end

    HCE.Print("Item source breakdown (equipped gear):")

    local checked, unknown, vendorN, questN, craftedN = 0, 0, 0, 0, 0

    for _, slotID in ipairs(GEAR_SLOTS) do
        local itemID = GetInventoryItemID("player", slotID)
        if itemID then
            checked = checked + 1
            local name, _, quality = GetItemInfo(itemID)
            name = name or ("item:" .. itemID)
            quality = quality or 0
            local qLabel = QUALITY_LABELS[quality] or ("q" .. quality)
            local slotLabel = SLOT_NAMES[slotID] or ("Slot " .. slotID)

            if quality <= 1 then
                DEFAULT_CHAT_FRAME:AddMessage(
                    "  " .. slotLabel .. ": |cff888888" .. name .. " (" .. qLabel .. ")|r — basic item"
                )
            else
                local found, source = HCE.CheckItemSource(itemID)
                if found then
                    if source == "vendor" then vendorN = vendorN + 1
                    elseif source == "quest reward" then questN = questN + 1
                    else craftedN = craftedN + 1 end
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "  " .. slotLabel .. ": |cff00ff00" .. name .. "|r — " .. source
                    )
                else
                    unknown = unknown + 1
                    DEFAULT_CHAT_FRAME:AddMessage(
                        "  " .. slotLabel .. ": |cffffaa33" .. name .. " (" .. qLabel .. ")|r — unknown source (assumed loot drop)"
                    )
                end
            end
        end
    end

    HCE.Print(string.format(
        "Summary: %d checked — %d vendor, %d quest, %d crafted, %d unknown/loot",
        checked, vendorN, questN, craftedN, unknown
    ))
end
'''


def format_id_list(ids, items_per_line=15):
    """Format a sorted list of item IDs as Lua array entries."""
    sorted_ids = sorted(ids)
    lines = []
    for i in range(0, len(sorted_ids), items_per_line):
        chunk = sorted_ids[i:i + items_per_line]
        lines.append("    " + ",".join(str(x) for x in chunk) + ",")
    return "\n".join(lines)


def generate_lua(quest_ids, vendor_ids, output_path):
    """Generate the ItemSourceData.lua file."""
    from datetime import datetime

    lua = LUA_HEADER.format(
        date=datetime.now().strftime("%Y-%m-%d %H:%M"),
        quest_count=len(quest_ids),
        vendor_count=len(vendor_ids),
        quest_ids=format_id_list(quest_ids),
        vendor_ids=format_id_list(vendor_ids),
    )
    lua += LUA_FOOTER

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(lua)

    print(f"\nWrote {output_path}")
    print(f"  Quest rewards: {len(quest_ids)} items")
    print(f"  Vendor items:  {len(vendor_ids)} items")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    print("=" * 60)
    print("Wowhead Classic Item Source Scraper")
    print("=" * 60)

    # Determine output path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "..", "ItemSourceData.lua")

    # Test connectivity
    print("\nTesting Wowhead connectivity...")
    try:
        resp = SESSION.get("https://www.wowhead.com/classic/items/armor?filter=128;1;4&maxle=10", timeout=15)
        resp.raise_for_status()
        test_ids = extract_item_ids_from_page(resp.text)
        print(f"  Connection OK — test query returned {len(test_ids)} items")
        if len(test_ids) == 0:
            print("  WARNING: No items extracted from test page.")
            print("  Wowhead may have changed their page format.")
            print("  Trying alternative extraction...")
            # Debug: save page for inspection
            debug_path = os.path.join(script_dir, "debug_page.html")
            with open(debug_path, "w", encoding="utf-8") as f:
                f.write(resp.text)
            print(f"  Saved debug page to {debug_path}")
            print("  Inspect the HTML to find the data format, then update the script.")

            # Try to find ANY data patterns in the page
            print("\n  Looking for data patterns in the page...")
            patterns_found = []
            if "Listview" in resp.text:
                patterns_found.append("Listview constructor found")
            if "WH.Gatherer" in resp.text:
                patterns_found.append("WH.Gatherer found")
            if '"id":' in resp.text or "'id':" in resp.text:
                patterns_found.append("id fields found")
            if "/classic/item=" in resp.text:
                patterns_found.append("item links found")

            id_from_links = re.findall(r'/classic/item[=/](\d+)', resp.text)
            if id_from_links:
                patterns_found.append(f"{len(id_from_links)} item IDs from links")

            for p in patterns_found:
                print(f"    - {p}")

            if not patterns_found:
                print("    No recognizable patterns found. Page may be JS-rendered.")
                print("    You may need to use a headless browser (Playwright/Selenium).")
                sys.exit(1)
    except Exception as e:
        print(f"  FAILED: {e}")
        print("  Check your internet connection and try again.")
        sys.exit(1)

    time.sleep(REQUEST_DELAY)

    # Fetch quest reward items (source type 4 on Wowhead)
    print("\n" + "=" * 60)
    print("Fetching QUEST REWARD items...")
    print("=" * 60)
    quest_ids = fetch_all_items_for_source(4, "Quest")

    # Fetch vendor items (source type 5 on Wowhead)
    # Note: Wowhead source IDs — 5 is "Vendor" on their filter
    print("\n" + "=" * 60)
    print("Fetching VENDOR items...")
    print("=" * 60)
    vendor_ids = fetch_all_items_for_source(5, "Vendor")

    # If source 5 returned nothing, try source 3
    if len(vendor_ids) == 0:
        print("\n  Source type 5 returned nothing, trying type 3...")
        vendor_ids = fetch_all_items_for_source(3, "Vendor")

    # Report
    print("\n" + "=" * 60)
    print("RESULTS")
    print("=" * 60)
    print(f"  Quest reward items: {len(quest_ids)}")
    print(f"  Vendor items:       {len(vendor_ids)}")

    if len(quest_ids) == 0 and len(vendor_ids) == 0:
        print("\n  ERROR: No items found at all!")
        print("  Wowhead may be blocking automated requests or changed their format.")
        print("  Try running with a headless browser instead.")
        sys.exit(1)

    # Generate the Lua file
    print("\nGenerating ItemSourceData.lua...")
    generate_lua(quest_ids, vendor_ids, output_path)
    print("\nDone! Copy the generated file to your addon folder if needed.")


if __name__ == "__main__":
    main()
