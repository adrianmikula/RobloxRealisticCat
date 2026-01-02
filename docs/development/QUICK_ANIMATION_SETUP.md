# Quick Animation Setup Guide

**TL;DR**: Keyframes need to be exported as Animation assets, then you can either:
1. Add Animation objects to your model (recommended - automatic detection)
2. Update the config file with animation IDs

## The Problem

**Keyframes ≠ Playable Animations**

- Keyframes are editing data in the Animation Editor
- They need to be **exported/published** as Animation assets first
- Then you can use them in your game

## Quick Solution: Export Keyframes

### Step 1: Export Your Keyframes

1. In Roblox Studio, select your cat model (e.g., GreyStripes)
2. Go to **View → Animation Editor**
3. You'll see your keyframe sequences
4. For each animation you want:
   - Select the keyframe sequence
   - Click **Publish** (top right of Animation Editor)
   - Name it (e.g., "GreyStripesIdle", "GreyStripesWalk")
   - Publish to your account/group
   - **Copy the Animation ID** that appears

### Step 2: Add Animation Objects to Model (Easiest!)

1. In Roblox Studio, select your cat model
2. Insert → **Animation** (or right-click model → Insert Object → Animation)
3. Name it to match the state: **"Idle"**, **"Walk"**, **"Jump"**, etc.
4. In Properties, set **AnimationId** to your published animation ID
5. Repeat for each animation

**That's it!** The system will automatically detect and use these animations.

### Alternative: Update Config File

If you prefer to use the config file instead:

1. Open `src/shared/config/animation-config.ts`
2. Update the animation IDs:
   ```typescript
   export const ANIMATION_IDS: Record<string, string> = {
       Idle: "rbxassetid://YOUR_IDLE_ID",
       Walk: "rbxassetid://YOUR_WALK_ID",
       // ... etc
   };
   ```
3. Rebuild: `npm run build`

## Reusing Animations from Other Models

### Copy Animation Objects

1. Open the model with animations you want
2. Find the **Animation** objects
3. Copy them (Ctrl+C)
4. Paste into your cat model (Ctrl+V)
5. Rename to match states (e.g., "Idle", "Walk")
6. Done! System will use them automatically

**Note**: Only works if you own both models or have permission.

## Your GreyStripes Animations

Based on your config file, you already have these animation IDs:
- Walk: `117481489766845`
- Jump: `75293643927731`

To use them:

### Option A: Add to Model (Recommended)
1. In GreyStripes model, create Animation object named "Walk"
2. Set AnimationId to `rbxassetid://117481489766845`
3. Create Animation object named "Jump"
4. Set AnimationId to `rbxassetid://75293643927731`
5. System will automatically use them!

### Option B: Update Config
The config file already has these IDs, so they should work if the animations are owned by your account.

## Testing

1. Build: `npm run build`
2. Test in Roblox Studio
3. Spawn a cat using GreyStripes model
4. Watch for animations - they should play automatically!

## Troubleshooting

**Animations still not playing?**

1. **Check ownership**: Animations must be owned by your account/group
2. **Verify IDs**: Make sure animation IDs are correct
3. **Check names**: Animation objects should be named "Idle", "Walk", etc.
4. **Test in Studio**: Try loading animations directly in Studio first

## Summary

- ✅ Export keyframes as Animation assets
- ✅ Add Animation objects to your model (named correctly)
- ✅ System automatically detects and uses them
- ✅ No config file changes needed if using model animations!

