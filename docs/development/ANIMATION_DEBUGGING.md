# Animation Debugging Guide

## Problem: Animations Not Playing

If your cat models aren't animating, follow these steps to debug:

## Step 1: Check Debug Output

I've added debug logging to help identify the issue. When you run the game, check the output for:

```
[CatRenderer] Cat [id] is moving - triggering Walk animation
[AnimationHandler] Playing animation "Walk" for cat [id]
[AnimationHandler] Animation ID: rbxassetid://...
[AnimationHandler] Track created: true/false
[AnimationHandler] Animation "Walk" is now playing for cat [id]
```

### What to Look For:

1. **Are animations being triggered?**
   - Look for `[CatRenderer] Cat [id] is moving` messages
   - If you don't see these, the cat might not be moving or `UpdateCatVisual` isn't being called

2. **Are animations loading?**
   - Look for `[AnimationHandler] Playing animation` messages
   - Check if the Animation ID is correct

3. **Are animations playing?**
   - Look for `Animation "[name]" is now playing` messages
   - If you see "failed to play", there's an issue with the animation

## Step 2: Verify Animation IDs

Check your `src/shared/config/animation-config.ts`:

```typescript
export const ANIMATION_IDS: Record<string, string> = {
    Walk: "rbxassetid://YOUR_WALK_ID",
    Idle: "rbxassetid://YOUR_IDLE_ID",
    // ... etc
};
```

**Important Checks:**
- ✅ Animation IDs are in correct format: `rbxassetid://[ID]`
- ✅ Animation IDs are owned by your account/group
- ✅ Animation IDs match your model's rig type (R15/R6)

## Step 3: Test Animation IDs Directly

In Roblox Studio:

1. Select your cat model
2. Find the Humanoid
3. Create a new Animation object
4. Set AnimationId to one of your animation IDs
5. Use `Humanoid:LoadAnimation(animation):Play()` in the command bar
6. If it doesn't play, the animation ID is wrong or incompatible

## Step 4: Check Model Setup

Verify your cat model has:

1. **Humanoid** - Required for animations
   - Check: `model:FindFirstChildOfClass("Humanoid")`

2. **All parts unanchored** - Required for animations to move parts
   - Check: All BaseParts should have `Anchored = false`
   - The code automatically unanchors parts, but verify

3. **PrimaryPart set** - Required for movement
   - Check: `model.PrimaryPart` should be set

## Step 5: Check Update Frequency

Animations are triggered when `UpdateCatVisual` is called. This happens when:

1. Server sends a state update (`CatStateUpdate` signal)
2. Cat's state changes (action, position, etc.)

**If animations aren't updating:**
- The server might not be sending updates frequently enough
- Check if cats are actually moving (watch their position)

## Step 6: Common Issues

### Issue 1: Animation ID Format Wrong

**Symptom:** `[AnimationHandler] No animation ID found for state: Walk`

**Fix:** Check animation-config.ts - IDs should be `rbxassetid://[ID]`, not just `[ID]`

### Issue 2: Animation Not Owned

**Symptom:** Animation loads but doesn't play, or errors about permissions

**Fix:** Re-upload animations under your account/group

### Issue 3: Rig Type Mismatch

**Symptom:** Animation loads but model doesn't move

**Fix:** Ensure animations match your model's rig type (R15 vs R6)

### Issue 4: Parts Are Anchored

**Symptom:** Animation plays but model doesn't move

**Fix:** Ensure all parts are unanchored (code should do this automatically)

### Issue 5: UpdateCatVisual Not Called

**Symptom:** No debug messages at all

**Fix:** Check if server is sending state updates. Cats need to change state (move, change action) to trigger updates.

## Step 7: Manual Test

To test if animations work at all:

1. In Roblox Studio, select a cat model
2. Open Command Bar (View → Command Bar)
3. Run:
   ```lua
   local humanoid = workspace.Cat_XXX:FindFirstChildOfClass("Humanoid")
   local animation = Instance.new("Animation")
   animation.AnimationId = "rbxassetid://YOUR_WALK_ID"
   animation.Parent = workspace.Cat_XXX
   local track = humanoid:LoadAnimation(animation)
   track.Looped = true
   track:Play()
   ```

If this works, the issue is in the code. If it doesn't, the issue is with the animation ID or model setup.

## Step 8: Check Animation Objects in Model

If you added Animation objects to your model:

1. Check they're named correctly (e.g., "Walk", "Idle")
2. Check their AnimationId properties are set
3. The system will use these automatically if found

## Next Steps

After checking the debug output:

1. **If you see "triggering Walk animation" but no "Playing animation":**
   - Check if `PlayAnimation` is being called
   - Check for errors in the output

2. **If you see "Playing animation" but "failed to play":**
   - Check animation ID format
   - Check animation ownership
   - Check rig compatibility

3. **If you don't see any debug messages:**
   - Check if `UpdateCatVisual` is being called
   - Check if server is sending state updates
   - Check if cats are actually moving

## Removing Debug Logs

Once animations are working, you can remove the debug print statements from:
- `src/client/animation-handler.ts`
- `src/client/cat-renderer.ts`

Or comment them out for future debugging.

