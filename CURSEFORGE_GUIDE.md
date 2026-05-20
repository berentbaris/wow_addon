# Publishing HardcoreClassesEnhanced on CurseForge — Step by Step

## Step 1: Create the zip file

Open PowerShell, navigate to your addon's parent folder, and run:

```powershell
cd C:\Users\beren\Objet\wow_addon
Compress-Archive -Path .\HardcoreClassesEnhanced\*.lua, .\HardcoreClassesEnhanced\*.toc -DestinationPath .\HardcoreClassesEnhanced-0.1.0.zip
```

This creates `HardcoreClassesEnhanced-0.1.0.zip` containing only the .lua and .toc files (no dev scripts, no tools folder, no markdown files).

**Important:** CurseForge expects the zip to contain a folder named exactly `HardcoreClassesEnhanced` with the files inside it. The command above puts them at the root. To fix this, use this instead:

```powershell
cd C:\Users\beren\Objet\wow_addon

# Create a temp staging folder
$staging = "$env:TEMP\HardcoreClassesEnhanced"
Remove-Item $staging -Recurse -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $staging | Out-Null

# Copy only addon files (no tools, no dev files)
Copy-Item .\HardcoreClassesEnhanced\*.lua $staging
Copy-Item .\HardcoreClassesEnhanced\*.toc $staging

# Create the zip
Remove-Item .\HardcoreClassesEnhanced-0.1.0.zip -ErrorAction SilentlyContinue
Compress-Archive -Path $staging -DestinationPath .\HardcoreClassesEnhanced-0.1.0.zip

# Clean up
Remove-Item $staging -Recurse

Write-Host "Created HardcoreClassesEnhanced-0.1.0.zip"
```

## Step 2: Create a CurseForge account (if you don't have one)

1. Go to https://www.curseforge.com
2. Click "Sign Up" in the top right
3. You can sign up with Twitch, Google, or email

## Step 3: Create the project

1. Go to https://authors.curseforge.com
2. If this is your first project, you may need to agree to the author terms
3. Click **"Create Project"**
4. Fill in the form:

| Field | Value |
|-------|-------|
| **Project Name** | Hardcore Classes Enhanced |
| **Project Type** | World of Warcraft Addon |
| **Category** | Roleplay & Names (primary), or Unit Frames / HUDs |
| **Game Version** | WoW Classic (pick the latest Classic Era / Season of Discovery version) |
| **Description** | Paste the contents of `CURSEFORGE_DESCRIPTION.md` (the file in your addon folder). CurseForge supports markdown formatting. |
| **Project URL/Slug** | `hardcore-classes-enhanced` (auto-generated from name, you can customise) |
| **License** | All Rights Reserved (default), or pick MIT/GPL if you want it open source |
| **Source URL** | Leave blank unless you have a GitHub repo |
| **Issues URL** | Leave blank for now |

5. Click **"Create Project"**

## Step 4: Upload the file

1. After creating the project, you'll be on the project management page
2. Click the **"Files"** tab
3. Click **"Upload File"**
4. Fill in:

| Field | Value |
|-------|-------|
| **File** | Select `HardcoreClassesEnhanced-0.1.0.zip` |
| **Display Name** | `0.1.0` |
| **Game Version** | Select the Classic Era / SoD version (1.15.x) |
| **Release Type** | Beta (for first release; change to Release when stable) |
| **Changelog** | "Initial release — 27 lore-based enhanced classes with equipment tracking, challenge monitoring, quest milestones, talent requirements, and more." |

5. Click **"Upload"**
6. CurseForge will process the file (usually takes a few minutes for approval on first upload)

## Step 5: Add the Buy Me a Coffee link

CurseForge project descriptions support markdown links. The description file already includes the link at the bottom. Make sure it's visible:

```
**[Support the addon — Buy Me a Coffee](https://buymeacoffee.com/berentbaris)**
```

You can also add it to:
- The **"Donation URL"** field in Project Settings (some CurseForge pages show this as a button)
- The project's sidebar info if CurseForge offers a donation link field

## Step 6: After approval

Once approved (usually within a few hours for new projects):

- Your addon will be searchable on CurseForge
- Players using the CurseForge app can install it directly
- The project page will show your description with the BMC link

## Updating the addon later

For future updates:

1. Bump the version in both `HardcoreClassesEnhanced.toc` (the `## Version:` line) and `HardcoreClassesEnhanced.lua` (`HCE.version = "X.Y.Z"`)
2. Re-run the zip command from Step 1 (change the filename to match the new version)
3. Go to your project's Files tab and upload the new zip
4. Add a changelog describing what changed

## File checklist

Files that should be in the zip (24 files):

- HardcoreClassesEnhanced.toc
- HardcoreClassesEnhanced.lua
- CharacterData.lua
- SelectionUI.lua
- RequirementsPanel.lua
- LevelAlert.lua
- EquipmentCheck.lua
- CuratedItems.lua
- ForbiddenAlert.lua
- ProfessionCheck.lua
- TalentRequirements.lua
- TalentCheck.lua
- SelfFoundCheck.lua
- ZoneCheck.lua
- BehavioralCheck.lua
- ChallengeCheck.lua
- ItemSourceData.lua
- QuestCheck.lua
- CompanionCheck.lua
- HunterPetCheck.lua
- MountCheck.lua
- SettingsPanel.lua
- ProgressSummary.lua
- LevelUpSummary.lua
- GameplayTips.lua

Files that should NOT be in the zip:

- tools/ folder (scraper scripts, debug JSON)
- test_edge_cases.py
- README.md
- CURSEFORGE_DESCRIPTION.md
- CURSEFORGE_GUIDE.md
