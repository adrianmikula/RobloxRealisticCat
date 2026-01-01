# Cat Model Setup Guide

This guide explains how to set up different high-quality cat models for different cat types.

## Overview

The system supports using different cat models based on the cat's profile type (Friendly, Independent, Calico, Siamese, etc.). This allows you to have visually distinct cats with different appearances while maintaining the same behavior system.

## Model Requirements

**Important:** Only use high-quality models that meet these requirements:

1. **Proper Rigging**: Model must have a Humanoid with correct bone structure
2. **Animations**: Model should support standard animations (Idle, Walk, Run, etc.)
3. **Consistent Structure**: Should have standard parts (Head, Torso, HumanoidRootPart, etc.)
4. **Performance**: Optimized models that won't cause lag

## Setting Up Models

### Step 1: Add Models to Workspace

1. In Roblox Studio, ensure you have a `Models` folder in Workspace
2. Place your high-quality cat models inside `Workspace.Models`
3. Name each model appropriately (e.g., "Petra", "CalicoCat", "Siamese", etc.)

### Example Structure:
```
Workspace
└── Models
    ├── Petra (default model)
    ├── CalicoCat (for Calico profile)
    ├── SiameseCat (for Siamese profile)
    └── IndependentCat (for Independent profile)
```

### Step 2: Configure Model Mapping

Edit `src/client/cat-renderer.ts` and update the `MODEL_MAPPING`:

```typescript
private static readonly MODEL_MAPPING: Record<string, string> = {
    "Friendly": "Petra",           // Friendly cats use Petra model
    "Independent": "IndependentCat", // Independent cats use IndependentCat model
    "Calico": "CalicoCat",          // Calico cats use CalicoCat model
    "Siamese": "SiameseCat",        // Siamese cats use SiameseCat model
};
```

### Step 3: Set Default Model

Update the `DEFAULT_MODEL` constant to your most reliable model:

```typescript
private static readonly DEFAULT_MODEL = "Petra";
```

This model will be used if:
- A profile type doesn't have a mapping
- The mapped model doesn't exist in Workspace.Models
- There's an error loading the specific model

## How Model Selection Works

The system determines which model to use in this order:

1. **Profile Type Mapping**: Checks `MODEL_MAPPING` for the cat's profile type
2. **Breed-Based**: If breed is set, maps breed name to profile type
3. **Personality Inference**: Infers profile type from personality traits:
   - High friendliness + playfulness → "Friendly"
   - High independence → "Independent"
   - High curiosity → "Calico"
   - High playfulness → "Siamese"
4. **Default Fallback**: Uses `DEFAULT_MODEL` if nothing else works

## Profile Types

Current profile types that can be mapped:
- `"Friendly"` - High friendliness and playfulness
- `"Independent"` - High independence, lower friendliness
- `"Calico"` - High curiosity
- `"Siamese"` - High playfulness

## Example: Adding a New Model

Let's say you want to add a "Persian" model for Persian cats:

1. **Add the model to Workspace**:
   - Place "PersianCat" model in `Workspace.Models`

2. **Update the mapping**:
   ```typescript
   private static readonly MODEL_MAPPING: Record<string, string> = {
       "Friendly": "Petra",
       "Independent": "PersianCat",  // Persian cats are independent
       "Calico": "CalicoCat",
       "Siamese": "SiameseCat",
   };
   ```

3. **Update breed mapping** (if needed):
   The `DetermineProfileType` function already maps "Persian" breed to "Independent" profile type, so it will automatically use "PersianCat" model.

## Model Validation

The system automatically:
- ✅ Checks if the mapped model exists before using it
- ✅ Falls back to default if model is missing
- ✅ Warns in console if a model is not found
- ✅ Uses any available model as last resort

## Troubleshooting

### Model not appearing?

1. **Check model name**: Ensure the model name in `MODEL_MAPPING` exactly matches the model name in Workspace.Models
2. **Check Models folder**: Verify `Workspace.Models` exists and contains your models
3. **Check console**: Look for warning messages about missing models
4. **Verify model structure**: Ensure the model has a Humanoid and proper parts

### All cats using the same model?

1. **Check mapping**: Verify `MODEL_MAPPING` has entries for different profile types
2. **Check profile types**: Ensure cats are being created with different profile types
3. **Check breed field**: If using breeds, ensure they're mapped correctly in `DetermineProfileType`

### Model has no animations?

- Ensure the model has a Humanoid
- Check that animations are properly configured
- The system uses standard Roblox animation IDs, so models should work with standard animations

## Best Practices

1. **Use consistent naming**: Name models clearly (e.g., "CalicoCat" not "cat1")
2. **Test models**: Verify each model works correctly before adding to mapping
3. **Keep default reliable**: Always ensure your default model exists and works
4. **Document models**: Note which models you're using in your project documentation
5. **Performance**: Use optimized models - avoid overly complex meshes

## Model Recommendations

For high-quality cat models with animations, consider:
- Roblox Avatar models (if available)
- Custom rigged models with proper bone structure
- Models from the Roblox library that support standard animations

## Example Setup

```
Workspace.Models/
├── Petra (default, friendly cat)
├── CalicoCat (calico pattern cat)
├── SiameseCat (siamese cat)
└── PersianCat (long-haired cat)
```

With mapping:
```typescript
"Friendly": "Petra"
"Calico": "CalicoCat"
"Siamese": "SiameseCat"
"Independent": "PersianCat"
```

This setup will automatically use the correct model based on each cat's profile type!

