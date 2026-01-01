# Animation Setup Guide

This guide explains how to ensure cat animations work properly in your Roblox game.

## Overview

The animation system uses Roblox's standard animation system with Humanoid.LoadAnimation. Animations are automatically played based on the cat's current action (Idle, Walk, Run, etc.).

## Current Implementation

### Animation Handler

The `AnimationHandler` class manages all cat animations:
- Automatically loads animations when cats change actions
- Loops animations for continuous movement
- Properly cleans up animations when cats are removed
- Parents animations to the model before loading (required by Roblox)

### Key Features

1. **Automatic Animation Selection**: Animations are selected based on the cat's current action
2. **Animation Looping**: All animations are set to loop for continuous movement
3. **Proper Cleanup**: Animations are destroyed when cats are removed or animations change

## Animation IDs

The system uses standard Roblox animation IDs. These are standard Roblox animations that work with R15 and R6 rigs:

- **Idle**: `rbxassetid://507766388`
- **Walk**: `rbxassetid://507767968`
- **Run**: `rbxassetid://507767714`
- **Jump**: `rbxassetid://507765000`

## Troubleshooting

### Animations Not Playing

If animations aren't working, check the following:

1. **Model Has Humanoid**
   - Ensure your cat model has a Humanoid object
   - The Humanoid must be a direct child of the model

2. **Parts Are Unanchored**
   - All BaseParts in the model must be unanchored (`Anchored = false`)
   - Anchored parts cannot be moved by animations
   - The system automatically unanchors all parts when creating cat visuals

3. **Animation IDs Are Valid**
   - Verify the animation IDs exist and are accessible
   - Check that you have permission to use the animations
   - Test animations in Roblox Studio first

4. **Rig Compatibility**
   - Ensure animations match your model's rig type (R15 vs R6)
   - The default animations work with both R15 and R6
   - Custom models may need custom animations

5. **Humanoid Settings**
   - `AutoRotate` should be `true` (set automatically)
   - `PlatformStand` should be `false` (unless cat is being held)
   - `DisplayDistanceType` is set to `None` to hide name tags

### Common Issues

#### Limbs Frozen in Place

**Cause**: Parts are anchored or animations aren't loading properly.

**Solution**:
1. Check that all parts are unanchored (the system does this automatically)
2. Verify the Humanoid exists and is properly configured
3. Check the Output window for animation loading errors

#### Animations Not Looping

**Cause**: Animation tracks aren't set to loop.

**Solution**: The system automatically sets `track.Looped = true` for all animations.

#### Wrong Animation Playing

**Cause**: Animation state mapping is incorrect.

**Solution**: Check `src/client/animation-handler.ts` - the `GetAnimationId` function maps actions to animation IDs.

## Custom Animations

To use custom animations:

1. **Upload Your Animation**
   - Create or import your animation in Roblox Studio
   - Upload it to Roblox (or use an existing animation ID)

2. **Update Animation IDs**
   - Edit `src/client/animation-handler.ts`
   - Update the `GetAnimationId` function with your animation IDs:
   ```typescript
   private static GetAnimationId(state: string): string {
       const animationMap: Record<string, string> = {
           Idle: "rbxassetid://YOUR_IDLE_ANIMATION_ID",
           Walk: "rbxassetid://YOUR_WALK_ANIMATION_ID",
           // ... etc
       };
       return animationMap[state] || animationMap.Idle;
   }
   ```

3. **Test in Studio**
   - Build the project: `npm run build`
   - Test in Roblox Studio to verify animations work

## Animation States

The system maps cat actions to animation states:

| Action | Animation State | Description |
|--------|----------------|-------------|
| Idle | Idle | Cat is standing still |
| Explore | Walk | Cat is exploring |
| SeekFood | Walk | Cat is looking for food |
| Follow | Walk | Cat is following a player |
| SeekRest | Idle | Cat is resting |
| Sleep | Idle | Cat is sleeping |
| Purr | Idle | Cat is purring |
| Meow | Idle | Cat is meowing |

## Best Practices

1. **Use Compatible Animations**: Ensure animations match your model's rig type
2. **Test Thoroughly**: Test animations in both Studio and live game
3. **Optimize Performance**: Don't create too many animation instances
4. **Clean Up Properly**: The system automatically cleans up animations, but verify in testing

## Debugging

To debug animation issues:

1. **Check Output Window**: Look for warnings about missing animations or Humanoids
2. **Verify Model Structure**: Ensure model has Humanoid and proper parts
3. **Test Animation IDs**: Try loading animations directly in Studio to verify they work
4. **Check Animation Tracks**: Use Developer Console to inspect active animation tracks

## Notes

- Animations are loaded on the client side (in `CatRenderer`)
- Each cat has its own animation tracks
- Animations are automatically cleaned up when cats are removed
- The system prevents duplicate animations from playing

