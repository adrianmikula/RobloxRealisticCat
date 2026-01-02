# Handling Scripts in Cat Models

## Problem

Some cat models come with scripts (like "NightLights") that can cause errors when cloned. These scripts are often designed for specific use cases and may not work correctly in our game.

## Current Solution

The system automatically **disables** all `Script` and `LocalScript` objects when cloning cat models. This prevents errors while preserving the model structure.

## What Gets Disabled

- ✅ **Script** objects - Disabled (won't run)
- ✅ **LocalScript** objects - Disabled (won't run)
- ⚠️ **ModuleScript** objects - Left as-is (they don't run unless required)

## If You Want to Keep a Script

If you have a script in your model that you want to keep active:

### Option 1: Whitelist Specific Scripts

We can modify the code to whitelist certain scripts. For example:

```typescript
// In CreateCatVisual, before disabling scripts:
const whitelistedScripts = ["MyCustomScript", "AnotherScript"];
if (!whitelistedScripts.includes(descendant.Name)) {
    descendant.Enabled = false;
}
```

### Option 2: Fix the Script

If you want to fix the "NightLights" script:

1. Open the script in Roblox Studio
2. Find the line causing the error (line 73)
3. The error suggests something is returning a boolean when it should return an object
4. Check what `AddSubDataLayer` is being called on
5. Add a nil/type check before calling it

Example fix:
```lua
-- Before (causing error):
someObject:AddSubDataLayer(...)

-- After (with check):
if someObject and typeof(someObject) == "Instance" then
    someObject:AddSubDataLayer(...)
end
```

### Option 3: Remove the Script

If you don't need the script:

1. Open your cat model in Roblox Studio
2. Find the "NightLights" script
3. Delete it from the model
4. The script won't be cloned with future cats

## Common Model Script Issues

### NightLights Script Error

**Error**: `attempt to index boolean with 'AddSubDataLayer'`

**Cause**: The script is trying to use a feature that doesn't exist or has changed in Roblox, or a property is returning a boolean instead of the expected object.

**Solution**: 
- Script is automatically disabled (current solution)
- Or fix the script to check types before calling methods
- Or remove the script from the model

### Other Script Errors

If you encounter other script errors:

1. Check the error message to identify the script
2. Decide if you need the script
3. If needed, fix it or whitelist it
4. If not needed, remove it from the model or let it be disabled

## Testing

After making changes:

1. Build: `npm run build`
2. Test in Roblox Studio
3. Spawn a cat and check for errors
4. Verify the cat still works correctly

## Summary

- ✅ Scripts are automatically disabled to prevent errors
- ✅ You can whitelist scripts if needed
- ✅ You can fix scripts if you want to keep them
- ✅ You can remove scripts from the model if not needed

