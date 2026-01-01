# Configuration Files

This folder contains all configurable constants for the game. These files are easy to find and tweak to customize cat behavior, models, and interactions.

## Files

### `model-config.ts`
**Model Configuration**
- `MODEL_MAPPING`: Maps cat profile types to model names in Workspace.Models
- `DEFAULT_MODEL`: Default model to use if profile-specific model is not found

**To customize:**
- Add new model mappings for different profile types
- Change which models are used for each personality type
- Set your default fallback model

### `personality-config.ts`
**Personality Configuration**
- `BASE_PROFILE`: Base template for all cats (default personality traits)
- `PERSONALITY_TYPES`: Personality type definitions (Friendly, Independent, Calico, Siamese)
- `CAT_BREEDS`: Breed definitions that map to personality types

**To customize:**
- Adjust base personality traits (curiosity, friendliness, playfulness, etc.)
- Modify existing personality types or add new ones
- Add new cat breeds
- Change behavior parameters (exploration range, social distance, etc.)

### `behavior-config.ts`
**Behavior Configuration**
- `MOOD_STATES`: Mood definitions and their effects (Happy, Curious, Annoyed, Hungry, Tired, Afraid, Playful)
- `INTERACTION_TYPES`: Interaction effects (Pet, Feed, Hold) with success chances and relationship changes

**To customize:**
- Adjust mood effects (movement modifiers, interaction chances, durations)
- Change interaction success rates
- Modify relationship change values
- Add new interaction types

## Usage

### Importing Config Values

```typescript
// Import from config files directly
import { MODEL_MAPPING, DEFAULT_MODEL } from "shared/config/model-config";
import { BASE_PROFILE, PERSONALITY_TYPES, CAT_BREEDS } from "shared/config/personality-config";
import { MOOD_STATES, INTERACTION_TYPES } from "shared/config/behavior-config";

// Or use backwards-compatible exports from cat-profile-data
import { BASE_PROFILE, PERSONALITY_TYPES, CAT_BREEDS, MOOD_STATES, INTERACTION_TYPES } from "shared/cat-profile-data";
```

## Examples

### Adding a New Model

1. Place your model in `Workspace.Models` in Roblox Studio
2. Edit `model-config.ts`:
```typescript
export const MODEL_MAPPING: Record<string, string> = {
    "Friendly": "Petra",
    "Independent": "GreyStripes",
    "Calico": "Jerald",
    "Siamese": "Siamese",
    "Playful": "YourNewModel",  // Add new mapping
};
```

### Adding a New Personality Type

1. Edit `personality-config.ts`:
```typescript
export const PERSONALITY_TYPES: Record<string, Partial<CatProfile>> = {
    // ... existing types ...
    Playful: {
        personality: {
            playfulness: 0.95,
            friendliness: 0.8,
            // ... other traits ...
        },
    },
};
```

2. Add a breed that uses it:
```typescript
export const CAT_BREEDS = [
    // ... existing breeds ...
    { name: "Bengal", profileType: "Playful" },
];
```

### Adjusting Interaction Success Rates

Edit `behavior-config.ts`:
```typescript
export const INTERACTION_TYPES: Record<string, InteractionEffect> = {
    Pet: {
        relationshipChange: 0.1,
        moodEffect: "Happy",
        energyCost: 5,
        successChance: 0.9,  // Increased from 0.8
    },
    // ...
};
```

## Best Practices

1. **Test Changes**: After modifying config values, test the game to ensure cats behave as expected
2. **Document Custom Values**: Add comments explaining why you changed specific values
3. **Version Control**: These files are tracked in git, so changes are versioned
4. **Backup Before Major Changes**: Consider backing up config files before making significant changes

## Notes

- All config files are in `src/shared/config` so they're accessible to both client and server code
- The old `cat-profile-data.ts` file re-exports these values for backwards compatibility
- Changes to config files require rebuilding the project (`npm run build`)

