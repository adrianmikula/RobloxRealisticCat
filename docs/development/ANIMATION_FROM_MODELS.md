# Using Animations from Cat Models

This guide explains how to use animations that are embedded in your cat models or reuse animations from other models.

## Reference: High-Quality Cat Animations

For inspiration and examples of professional cat animations:
- **Creator Spotlight: Animator Bavelly** - [How Animator Bavelly Brings Warrior Cats and Prehistoric Animals to Life](https://devforum.roblox.com/t/creator-spotlight-how-animator-bavelly-brings-warrior-cats-and-prehistoric-animals-to-life/3730925)
  - Showcases realistic, high-quality cat animations
  - Great reference for animation style and quality standards

## Understanding Keyframes vs Animation Objects

### Keyframes (Animation Editor Data)
- **Keyframes** are editing data stored in models
- They're used in the Animation Editor to create animations
- They are **NOT directly playable** - they need to be exported as Animation assets first

### Animation Objects (Playable)
- **Animation objects** are the actual playable animation assets
- These are what the game uses via `Humanoid.LoadAnimation()`
- They have asset IDs like `rbxassetid://1234567890`
- **The system can now automatically detect and use these!**

## Automatic Animation Detection

The system now automatically detects and uses Animation objects that are children of your cat models!

### How It Works

1. When a cat model is loaded, the system searches for Animation objects inside it
2. It matches Animation objects to states by name (e.g., "Idle", "Walk", "Run")
3. If found, it uses the model's animations instead of config file animations
4. Falls back to config file if no matching animation is found in the model

### Naming Your Animation Objects

For automatic detection to work, name your Animation objects to match the states:

**Exact Match (Recommended):**
- `Idle` → Used for Idle state
- `Walk` → Used for Walk state
- `Run` → Used for Run state
- `Jump` → Used for Jump state

**With Prefix:**
- `CatIdle` → Matches Idle state
- `CatWalk` → Matches Walk state

**Partial Match:**
- `Walking` → Matches Walk state
- `Running` → Matches Run state
- `Jumping` → Matches Jump state

## Option 1: Export Keyframes as Animation Assets

If you have keyframes in your model, you need to export them as Animation assets:

### Step 1: Open Animation Editor

1. In Roblox Studio, select your cat model (e.g., GreyStripes)
2. Go to **View → Animation Editor**
3. You should see your keyframes in the timeline

### Step 2: Export/Publish Animation

1. In the Animation Editor, select the animation you want to export
2. Click **Publish** (or **Export**)
3. Give it a descriptive name (e.g., "GreyStripesIdle", "GreyStripesWalk")
4. Choose to publish to your account or group
5. **Important**: Publish to the same account/group as your game

### Step 3: Get Animation Asset ID

After publishing:
- The animation ID will be shown in the Animation Editor
- Or find it in your Roblox inventory under **Animations**
- Copy the ID (it's a number like `1234567890`)

### Step 4: Add Animation Object to Model (Recommended)

Instead of using config file, you can add the Animation objects directly to your model:

1. In Roblox Studio, select your cat model
2. Create a new **Animation** object (Insert → Animation)
3. Set the **AnimationId** property to your published animation ID
4. Name it to match the state (e.g., "Idle", "Walk")
5. The system will automatically detect and use it!

### Step 5: Update Config (Alternative)

If you prefer to use the config file instead:

Open `src/shared/config/animation-config.ts` and update with your animation IDs:

```typescript
export const ANIMATION_IDS: Record<string, string> = {
    Idle: "rbxassetid://YOUR_IDLE_ANIMATION_ID",
    Walk: "rbxassetid://YOUR_WALK_ANIMATION_ID",
    // ... etc
};
```

## Option 2: Extract Animations from Models

If your model already has Animation objects inside it:

### Step 1: Find Animation Objects

1. In Roblox Studio, select your cat model
2. Look for **Animation** objects in the model hierarchy
3. They might be in folders like "Animations" or directly in the model

### Step 2: Verify Names

1. Check the Animation object names
2. Rename them to match states if needed (e.g., "Idle", "Walk")
3. The system will automatically detect and use them!

### Step 3: Verify Animation IDs

1. Select an Animation object
2. Check the **AnimationId** property in the Properties panel
3. Ensure the animation is owned by your account/group

**That's it!** The system will automatically use these animations.

## Option 3: Reuse Animations from Other Models

You can reuse animations from other models:

### Method A: Copy Animation Objects

1. Open the source model that has the animations you want
2. Find the **Animation** objects in that model
3. Copy them (Ctrl+C)
4. Paste them into your cat model (Ctrl+V)
5. Rename them to match states (e.g., "Idle", "Walk")
6. The system will automatically detect and use them!

**Note**: This only works if you own both models or have permission to use the animations.

### Method B: Re-upload Animations

If you want to use animations from another creator's model:

1. **Get the Animation ID** from the source model's Animation object
2. **Test if it works** - if you have permission, it might work directly
3. **If not**, you may need to re-upload it under your account (if you have permission)

## Priority Order

The system uses animations in this order:

1. **Model Animation Objects** (highest priority)
   - Searches for Animation objects in the model
   - Matches by name to the state
   - Uses the AnimationId from the object

2. **Config File** (fallback)
   - Uses animation IDs from `animation-config.ts`
   - Only used if no matching animation found in model

## Example: Setting Up GreyStripes Model

Let's say you have the GreyStripes model with keyframes:

1. **Export Keyframes**:
   - Open Animation Editor
   - Publish "Idle" keyframe → Get ID: `1234567890`
   - Publish "Walk" keyframe → Get ID: `117481489766845`
   - Publish "Jump" keyframe → Get ID: `75293643927731`

2. **Add Animation Objects to Model**:
   - In GreyStripes model, create Animation object named "Idle"
   - Set AnimationId to `rbxassetid://1234567890`
   - Create Animation object named "Walk"
   - Set AnimationId to `rbxassetid://117481489766845`
   - Create Animation object named "Jump"
   - Set AnimationId to `rbxassetid://75293643927731`

3. **Done!** The system will automatically use these animations when GreyStripes model is loaded.

## Troubleshooting

### Animations Still Not Playing?

1. **Check Animation Object Names**
   - Ensure Animation objects are named correctly (e.g., "Idle", "Walk")
   - Names are case-insensitive but should match state names

2. **Verify Animation IDs**
   - Check that AnimationId properties are set correctly
   - Format should be: `rbxassetid://[ID]`

3. **Check Ownership**
   - Animations must be owned by the same account/group as your game
   - Check animation permissions in Roblox

4. **Check Rig Compatibility**
   - Animations must match your model's rig type (R15/R6)
   - R15 animations won't work on R6 models

5. **Model Structure**
   - Animation objects can be anywhere in the model (direct children or in folders)
   - The system searches all descendants

### Keyframes Not Converting?

If you can't export keyframes:
1. Make sure you're in the Animation Editor
2. Select the keyframe sequence you want to export
3. Use **Publish** button (not just Save)
4. Check that you're logged into the correct Roblox account

## Best Practices

1. **Use Animation Objects in Models** (Recommended)
   - Add Animation objects directly to your models
   - Name them to match states
   - System will automatically detect and use them

2. **Organize Animations**
   - Create an "Animations" folder in your model
   - Keep all Animation objects organized there
   - System will still find them automatically

3. **Test in Studio**
   - Test animations in Studio before using in-game
   - Verify animations work with your specific models

4. **Use Consistent Naming**
   - Name Animation objects consistently
   - Match state names exactly for best results

## Current Implementation

The system now:
- ✅ Automatically detects Animation objects in models
- ✅ Matches animations by name to states
- ✅ Falls back to config file if no model animations found
- ✅ Supports flexible naming (exact, partial, with prefix)

## Next Steps

1. **Export your keyframes** as Animation assets (if you have keyframes)
2. **Add Animation objects** to your models with the animation IDs
3. **Name them correctly** (e.g., "Idle", "Walk", "Jump")
4. **Test** in Roblox Studio - animations should work automatically!

No need to update the config file if you add Animation objects to your models - the system will use them automatically!
