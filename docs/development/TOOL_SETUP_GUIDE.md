# Tool Setup Guide

This guide explains how to create and configure tools (food, toys, etc.) that players can pick up and use to interact with cats.

## Overview

The system supports two methods for identifying tools:
1. **CollectionService Tags** (Recommended) - More flexible and easier to manage
2. **Tool Names** (Legacy) - Simple naming convention

## Method 1: Using CollectionService Tags (Recommended)

### Step 1: Create Your Tool

1. In Roblox Studio, create a `Tool` object in your game (e.g., in StarterPack, Workspace, or a shop)
2. Design your tool model (food bowl, toy, etc.)

### Step 2: Add CollectionService Tags

1. Open the **Tag Editor** in Roblox Studio (View → Tag Editor)
2. Create the following tags if they don't exist:
   - `CatTool_BasicFood`
   - `CatTool_PremiumFood`
   - `CatTool_BasicToy`
   - `CatTool_PremiumToy`
   - `CatTool_GroomingTool`
   - `CatTool_MedicalItem`

3. Select your tool and add the appropriate tag:
   - For basic food: Add `CatTool_BasicFood`
   - For premium food: Add `CatTool_PremiumFood`
   - For basic toys: Add `CatTool_BasicToy`
   - For premium toys: Add `CatTool_PremiumToy`
   - For grooming tools: Add `CatTool_GroomingTool`
   - For medical items: Add `CatTool_MedicalItem`

### Step 3: Configure Tool Properties

Your tool should be a standard Roblox `Tool` object. The system will automatically detect it when:
- A player picks it up (it goes into their character)
- The player clicks/uses the tool

## Method 2: Using Tool Names (Legacy)

If you prefer not to use tags, you can name your tools with these exact names:

### Supported Tool Names:
- `BasicToy` → Detected as "basicToys"
- `PremiumToy` → Detected as "premiumToys"
- `BasicFood` → Detected as "basicFood"
- `PremiumFood` → Detected as "premiumFood"
- `GroomingTool` → Detected as "groomingTools"
- `MedicalItem` → Detected as "medicalItems"

**Note:** The system also supports case-insensitive partial matching, so "Basic Toy" or "basic_toy" would also work.

## Tool Types and Effects

### Food Tools
- **BasicFood**: Standard food, reduces hunger by 30
- **PremiumFood**: Premium food, reduces hunger by 45 (1.5x effectiveness)

### Toy Tools
- **BasicToy**: Standard toy, triggers "Play" interaction
- **PremiumToy**: Premium toy, triggers "Play" interaction with 1.5x effectiveness

### Other Tools
- **GroomingTool**: For grooming cats (1.2x effectiveness)
- **MedicalItem**: For healing cats (2.0x effectiveness)

## How It Works

1. **Player picks up tool**: When a player picks up a tool, it appears in their character
2. **Tool detection**: The system checks for:
   - CollectionService tags (if present)
   - Tool name (fallback)
3. **Tool usage**: When the player clicks/uses the tool:
   - The system identifies the tool type
   - Records tool usage for cat AI reactions
   - Cats can react to nearby players with tools

## Cat AI Reactions

Cats will react to players holding tools:
- **Food tools**: Hungry cats will approach players holding food
- **Toy tools**: Playful cats will react when players use toys near them
- **Distance-based**: Cats detect tools within 25-30 studs

## Example Setup

### Creating a Basic Food Bowl

1. Create a `Tool` in StarterPack
2. Name it "FoodBowl" (or any name)
3. Add the `CatTool_BasicFood` tag using Tag Editor
4. Create a model inside the tool (bowl + food visual)
5. Set the tool's `RequiresHandle` to `false` if you want custom visuals

### Creating a Toy

1. Create a `Tool` in StarterPack
2. Name it "FeatherWand" (or any name)
3. Add the `CatTool_BasicToy` tag using Tag Editor
4. Create a model inside the tool (wand visual)
5. Optionally add animations or effects

## Troubleshooting

### Tool not being detected?

1. **Check tags**: Ensure the tool has the correct `CatTool_*` tag
2. **Check name**: If using name-based detection, ensure exact name match
3. **Check tool type**: Verify the tool type exists in `PlayerManager.AVAILABLE_TOOLS`
4. **Check character**: Tool must be in the player's character (picked up)

### Tool detected but not working?

1. **Check tool unlock**: Players need to have the tool unlocked (basic tools are unlocked by default)
2. **Check cooldowns**: Tools have cooldowns between uses
3. **Check server sync**: Ensure the tool usage is being recorded on the server

## Advanced: Custom Tool Types

To add new tool types:

1. Add the tool config to `PlayerManager.AVAILABLE_TOOLS` in `src/server/player-manager.ts`
2. Add the tag mapping in `GetToolTypeFromTool` in `src/client/interaction-controller.ts`
3. Update the cat AI to react to the new tool type in `src/server/cat-ai.ts`

## Best Practices

1. **Use tags over names**: Tags are more flexible and don't require exact naming
2. **Consistent naming**: If using names, stick to the exact names listed above
3. **Visual feedback**: Add visual effects when tools are used
4. **Tool models**: Create visually distinct models for each tool type
5. **Testing**: Test tools in-game to ensure they're detected correctly

