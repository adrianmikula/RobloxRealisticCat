# Animation Upload and Setup Guide

This guide explains how to upload or re-upload animations so they work with your Roblox game project.

## Why Re-upload Animations?

Roblox requires that animations be owned by the same account or group as your game to work properly. If you're using animation IDs from other creators or the default Roblox animations, they may not play correctly.

## Step-by-Step: Uploading Animations

### Method 1: Using Roblox Studio (Recommended)

1. **Open Roblox Studio** with your game project

2. **Import Animation**
   - Go to the **Animation Editor** (View → Animation Editor)
   - Click **Import** or create a new animation
   - If you have an existing animation file, import it
   - If not, you can record a new animation using the Animation Editor

3. **Record or Edit Animation**
   - Use the Animation Editor to create/edit your animation
   - Test the animation in Studio to ensure it looks correct
   - Make sure the animation matches your cat model's rig type (R15 or R6)

4. **Publish Animation**
   - Click **Publish** in the Animation Editor
   - Give your animation a name (e.g., "CatIdle", "CatWalk")
   - Choose whether to publish to your account or a group
   - **Important**: Publish to the same account/group as your game

5. **Get Animation ID**
   - After publishing, the animation ID will be shown
   - Copy this ID (it's a number like `1234567890`)
   - Or find it later in your Roblox inventory under Animations

6. **Update Config**
   - Open `src/shared/config/animation-config.ts`
   - Replace the placeholder animation ID with your new ID:
   ```typescript
   export const ANIMATION_IDS: Record<string, string> = {
       Idle: "rbxassetid://YOUR_IDLE_ANIMATION_ID",
       Walk: "rbxassetid://YOUR_WALK_ANIMATION_ID",
       // ... etc
   };
   ```

### Method 2: Using Roblox Website

1. **Go to Roblox Create Page**
   - Visit [create.roblox.com](https://create.roblox.com)
   - Navigate to **Animations** in the left sidebar

2. **Upload Animation**
   - Click **Create** → **Animation**
   - Upload your animation file (FBX, BVH, or other supported formats)
   - Or create a new animation using the web editor

3. **Configure Animation**
   - Set animation name and description
   - Choose the rig type (R15 or R6)
   - Configure animation settings

4. **Publish**
   - Click **Publish**
   - Choose account or group (must match your game)
   - Copy the animation ID from the URL or asset page

5. **Update Config**
   - Update `src/shared/config/animation-config.ts` with the new IDs

## Required Animations

At minimum, you'll need these animations for cats to work properly:

### Essential Animations:
- **Idle**: Cat standing still
- **Walk**: Cat walking
- **Run**: Cat running (optional, can reuse walk)

### Optional Animations:
- **Jump**: Cat jumping
- **Sleep**: Cat sleeping/lying down
- **Eat**: Cat eating
- **Groom**: Cat grooming itself
- **Meow**: Cat meowing animation
- **RollOver**: Cat rolling over

## Animation Requirements

### Rig Compatibility
- Animations must match your cat model's rig type
- **R15**: 15 body parts (most modern models)
- **R6**: 6 body parts (older models)
- Check your model in Studio to determine rig type

### Animation Quality
- Animations should be smooth and loopable
- Idle and walk animations should loop seamlessly
- Test animations in Studio before publishing

## Updating Animation IDs

After uploading animations, update the config file:

```typescript
// src/shared/config/animation-config.ts
export const ANIMATION_IDS: Record<string, string> = {
    Idle: "rbxassetid://1234567890",     // Your idle animation ID
    Walk: "rbxassetid://0987654321",     // Your walk animation ID
    Run: "rbxassetid://1122334455",      // Your run animation ID
    // ... etc
};
```

Then rebuild:
```bash
npm run build
```

## Testing Animations

1. **Test in Studio**
   - Build your project: `npm run build`
   - Open your game in Roblox Studio
   - Spawn a cat and verify animations play

2. **Check Output Window**
   - Look for any animation loading errors
   - Verify animations are loading correctly

3. **Verify Animation Ownership**
   - Ensure animations are owned by the same account/group as your game
   - Check animation permissions in Roblox

## Troubleshooting

### Animations Still Not Playing?

1. **Check Ownership**
   - Verify animations are owned by your account/group
   - Check that your game is also owned by the same account/group

2. **Verify Animation IDs**
   - Double-check that animation IDs are correct
   - Ensure IDs are in format: `rbxassetid://[ID]`

3. **Check Rig Compatibility**
   - Verify animations match your model's rig type
   - R15 animations won't work on R6 models and vice versa

4. **Test Animation Directly**
   - Try loading the animation directly in Studio
   - If it doesn't work in Studio, it won't work in-game

5. **Check Model Structure**
   - Ensure your cat model has a Humanoid
   - Verify all parts are unanchored

## Using Existing Animations

If you want to use existing Roblox animations:

1. **Find Animation ID**
   - Go to the animation's Roblox page
   - Copy the ID from the URL

2. **Test in Studio**
   - Try loading the animation in Studio
   - If it works, you can use it (if owned by you/your group)

3. **Re-upload if Needed**
   - If animation doesn't work, you may need to re-upload it
   - Download the animation if possible, then re-upload under your account

## Animation Asset Spoofing

If you need to "spoof" or re-upload existing animations:

1. **Download Animation** (if possible)
   - Some animations can be downloaded from Roblox
   - Or use animation extraction tools (check Roblox ToS)

2. **Re-upload**
   - Upload the animation under your account
   - This creates a new asset ID that you own

3. **Update Config**
   - Use the new asset ID in your config

**Note**: Be careful with asset spoofing - ensure you have permission to use the animations and comply with Roblox's Terms of Service.

## Best Practices

1. **Organize Animations**
   - Name animations clearly (e.g., "CatIdle", "CatWalk")
   - Keep a list of your animation IDs

2. **Version Control**
   - Document which animations you're using
   - Keep backup copies of animation files

3. **Test Thoroughly**
   - Test all animations in Studio before deploying
   - Verify animations work with all your cat models

4. **Optimize Performance**
   - Use efficient animation files
   - Avoid overly complex animations that cause lag

## Quick Reference

- **Config File**: `src/shared/config/animation-config.ts`
- **Animation Handler**: `src/client/animation-handler.ts`
- **Rebuild Command**: `npm run build`
- **Roblox Create**: [create.roblox.com](https://create.roblox.com)

## Next Steps

1. Upload or re-upload your animations
2. Update `animation-config.ts` with your animation IDs
3. Rebuild the project: `npm run build`
4. Test in Roblox Studio
5. Verify animations play correctly

