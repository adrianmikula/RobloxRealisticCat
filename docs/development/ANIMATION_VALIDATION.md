# Animation Validation

## Overview

The game now validates all animation IDs during startup to catch invalid animations early. This prevents runtime errors and makes it easier to identify configuration issues.

## When Validation Runs

Animation validation runs automatically during game startup, right after Knit initializes and before loading game content. You'll see it in the loading screen as "Validating animations...".

## What Gets Validated

1. **All animation IDs from `animation-config.ts`**
   - Every animation in `ANIMATION_IDS`
   - The `DEFAULT_ANIMATION`

2. **Format validation:**
   - Checks that IDs are in correct format: `rbxassetid://[ID]`
   - Verifies IDs are not empty or "0"
   - Validates basic structure

## Validation Output

### Success
```
[AnimationHandler] ✅ All 17 animations validated successfully!
```

### Errors
```
[AnimationHandler] Validation found 2 invalid animation(s):
  ❌ Walk: rbxassetid://81156765879428 - Invalid ID format (must be rbxassetid://[ID])
  ❌ Jump: rbxassetid://0 - Empty or invalid ID format
```

## What Validation Checks

1. **Format Check:**
   - ID must start with `rbxassetid://`
   - Must have a numeric ID after the prefix
   - Cannot be empty or "0"

2. **Structure Check:**
   - Animation instance can be created
   - Basic validation passes

## Limitations

**Note:** Full validation (checking if animations actually exist on Roblox) requires:
- Network access to check asset existence
- A humanoid to load the animation

The current validation checks format and structure. Full validation happens when animations are actually played, but format validation catches most common issues early.

## Manual Validation

You can also manually validate animations:

```typescript
import { AnimationHandler } from "./animation-handler";

// Validate all animations
const results = await AnimationHandler.ValidateAllAnimations((progress, message) => {
    print(`${(progress * 100).toFixed(0)}% - ${message}`);
});

print(`Valid: ${results.valid}, Invalid: ${results.invalid.size()}`);
```

## Fixing Invalid Animations

If validation finds invalid animations:

1. **Check the error message** - it will tell you what's wrong
2. **Update `animation-config.ts`** with correct IDs
3. **Rebuild:** `npm run build`
4. **Test again** - validation will run on next startup

## Common Issues

### "Empty or invalid ID format"
- Animation ID is empty, "0", or malformed
- **Fix:** Update the ID in `animation-config.ts`

### "Invalid ID format (must be rbxassetid://[ID])"
- ID doesn't start with `rbxassetid://`
- **Fix:** Ensure IDs are in format `rbxassetid://[NUMBER]`

### "Invalid numeric ID"
- ID has no number after `rbxassetid://`
- **Fix:** Check the ID format in `animation-config.ts`

## Integration with Loading Screen

The validation integrates with the loading screen:
- Shows progress: "Validating [AnimationName]..."
- Updates progress bar (50% to 55% of total loading)
- Reports results in output

## Benefits

✅ **Early Detection:** Catch invalid animations before they cause runtime errors
✅ **Clear Errors:** Know exactly which animations are invalid
✅ **Better UX:** Loading screen shows validation progress
✅ **Developer Friendly:** Easy to identify configuration issues

## Future Enhancements

Potential improvements:
- Network-based validation (check if assets actually exist)
- Model animation validation (check Animation objects in models)
- Validation report file generation
- Auto-fix suggestions for common issues

