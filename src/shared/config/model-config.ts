/**
 * Model Configuration
 * 
 * Configure which cat models to use for different profile types.
 * Models must be placed in Workspace.Models in Roblox Studio.
 * 
 * To add a new model:
 * 1. Place the model in Workspace.Models with the exact name
 * 2. Ensure it has a Humanoid and proper animations
 * 3. Add the mapping below: profileType -> modelName
 */

/**
 * Mapping of cat profile types to model names in Workspace.Models.
 * Only use high-quality models that have proper animations and rigging.
 */
export const MODEL_MAPPING: Record<string, string> = {
    // Profile types mapped to model names
    "Friendly": "Petra",        // Default friendly cat model
    "Independent": "GreyStripes",     // Independent cat model
    "Calico": "Jerald",           // Calico cat model
    "Siamese": "Siamese",          // Siamese cat model
    // Add more mappings as you add models:
    // "Playful": "PlayfulCatModel",
    // "Curious": "CuriousCatModel",
};

/**
 * Default model name to use if profile-specific model is not found.
 * This should be a reliable, high-quality model that always exists.
 */
export const DEFAULT_MODEL = "Petra";

