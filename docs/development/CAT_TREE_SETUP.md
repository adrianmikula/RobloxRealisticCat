# Cat Tree Setup Guide

This guide explains how to set up cat trees in your Roblox game so that cats can interact with them.

## Overview

Cats can now interact with objects tagged as "CatTree" using Roblox's CollectionService. Cats will:
- **Approach** cat trees when they're curious or exploring
- **Climb** cat trees to reach the top platform
- **Rest/Sleep** on cat trees to restore energy

## Setting Up Cat Trees

### Step 1: Create or Import a Cat Tree Model

1. In Roblox Studio, create or import a cat tree model
2. The model should have:
   - A base/platform at the bottom
   - Climbing surfaces (posts, ramps, etc.)
   - A top platform where cats can rest
   - All parts should be properly welded/anchored

### Step 2: Tag the Cat Tree

1. Select your cat tree model in the Explorer
2. In the Properties panel, find the **Tags** section
3. Click the **+** button to add a new tag
4. Type `CatTree` (case-sensitive) and press Enter
5. Alternatively, you can use CollectionService in a script:
   ```lua
   local CollectionService = game:GetService("CollectionService")
   CollectionService:AddTag(catTreeModel, "CatTree")
   ```

### Step 3: Verify the Setup

- The cat tree should be visible in the Workspace
- The tag "CatTree" should be applied to the model
- The model should have a PrimaryPart set (or the system will find the highest part)

## How It Works

### Detection

Cats automatically detect cat trees within their exploration range using CollectionService. The system:
- Finds all objects tagged with "CatTree"
- Determines the nearest cat tree to each cat
- Calculates the top platform position (highest part in the model)

### Behavior Triggers

Cats will interact with cat trees based on:

1. **ApproachCatTree** (Distance: 5-50 studs)
   - Triggered by: High curiosity, independence
   - Weight increases with personality traits

2. **ClimbCatTree** (Distance: 2-8 studs)
   - Triggered by: Curiosity, independence
   - Cats move towards the top platform
   - Consumes energy while climbing

3. **RestOnCatTree** (Distance: < 3 studs)
   - Triggered by: Low energy, independence
   - Cats rest on the top platform
   - Restores energy over time
   - Cats rest for ~10 seconds, then decide to explore or continue resting

### Personality Influence

- **Curious cats** are more likely to approach and climb cat trees
- **Independent cats** prefer cat trees over other rest spots
- **Low energy cats** prioritize resting on cat trees

## Best Practices

### Model Design

1. **Clear Top Platform**: Ensure there's a clear, flat surface at the top
2. **Proper Size**: Cat trees should be appropriately sized (not too small or too large)
3. **Stable Structure**: All parts should be properly anchored and welded
4. **Accessible**: Make sure cats can reach the top (not too high or blocked)

### Placement

1. **Scatter Around**: Place cat trees in various locations for exploration
2. **Not Too Dense**: Don't place too many cat trees close together
3. **Accessible Areas**: Place in areas where cats naturally explore

### Tagging

- Tag the entire Model, not individual parts
- Use the exact tag name: `CatTree` (case-sensitive)
- You can have multiple cat trees in your game

## Troubleshooting

### Cats Not Approaching Cat Trees?

1. **Check Tag**: Verify the model has the "CatTree" tag
2. **Check Distance**: Cat trees must be within the cat's exploration range (default: 50 studs)
3. **Check Personality**: Very social cats might prefer player interaction over cat trees
4. **Check Energy**: Cats with high energy might prefer exploring over resting

### Cats Getting Stuck While Climbing?

1. **Check Model Structure**: Ensure there's a clear path to the top
2. **Check Top Platform**: Verify there's a part at the highest point
3. **Check Size**: Very large cat trees might cause pathfinding issues

### Cats Not Resting on Cat Tree?

1. **Check Position**: Cats need to be very close to the top (< 3 studs)
2. **Check Energy**: Cats with high energy might not rest as long
3. **Check Action**: The cat might be transitioning between actions

## Example Setup Script

You can use this script to automatically tag cat trees:

```lua
local CollectionService = game:GetService("CollectionService")

-- Tag all models in a folder
local catTreesFolder = workspace:FindFirstChild("CatTrees")
if catTreesFolder then
    for _, model in ipairs(catTreesFolder:GetChildren()) do
        if model:IsA("Model") then
            CollectionService:AddTag(model, "CatTree")
        end
    end
end
```

## Advanced: Custom Cat Tree Behaviors

The cat tree system is extensible. You can:
- Modify decision weights in `src/server/cat-ai.ts`
- Adjust rest duration and energy restoration rates
- Add new cat tree interaction types
- Create different types of cat trees with different tags

## Notes

- Cat trees use the same CollectionService system as tools
- Multiple cats can use the same cat tree (they'll take turns or use different platforms)
- Cat trees are detected in real-time, so you can add/remove them dynamically
- The system automatically finds the highest part as the rest platform

