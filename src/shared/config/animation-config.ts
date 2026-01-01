/**
 * Animation Configuration
 * 
 * Configure animation IDs for cat behaviors.
 * 
 * IMPORTANT: Animations must be owned by the same account/group as your game
 * to work properly. If animations aren't playing, you may need to:
 * 
 * 1. Re-upload animations under your account/group
 * 2. Update the animation IDs below with your new asset IDs
 * 3. Ensure animations match your cat model's rig type (R15/R6)
 * 
 * To find animation IDs:
 * - Go to the animation asset page on Roblox
 * - The ID is in the URL: roblox.com/library/[ID]
 * - Or check the asset ID in Roblox Studio
 */

/**
 * Animation ID mappings for different cat behaviors.
 * 
 * These are placeholder IDs. Replace them with your own animation asset IDs
 * that are owned by your account/group.
 */
export const ANIMATION_IDS: Record<string, string> = {
    // Basic movement animations
    Idle: "rbxassetid://507766388",      // Idle animation - replace with your idle animation ID
    Walk: "rbxassetid://507767968",      // Walk animation - replace with your walk animation ID
    Run: "rbxassetid://507767714",       // Run animation - replace with your run animation ID
    Jump: "rbxassetid://507765000",      // Jump animation - replace with your jump animation ID
    Fall: "rbxassetid://507767968",      // Fall animation (can reuse walk)
    
    // Cat-specific behaviors
    // These can use the same animations as basic movements, or custom animations
    Sleep: "rbxassetid://507766388",     // Sleep/idle - replace with sleep animation if available
    Eat: "rbxassetid://507766388",       // Eat/idle - replace with eat animation if available
    Groom: "rbxassetid://507766388",     // Groom/idle - replace with groom animation if available
    Explore: "rbxassetid://507767968",   // Explore/walk - uses walk animation
    SeekFood: "rbxassetid://507767968",  // Seek food/walk - uses walk animation
    SeekRest: "rbxassetid://507766388",  // Seek rest/idle - uses idle animation
    Socialize: "rbxassetid://507766388", // Socialize/idle - uses idle animation
    Follow: "rbxassetid://507767968",   // Follow/walk - uses walk animation
    LookAt: "rbxassetid://507766388",    // Look at/idle - uses idle animation
    Meow: "rbxassetid://507766388",      // Meow/idle - replace with meow animation if available
    RollOver: "rbxassetid://507766388",  // Roll over/idle - replace with roll animation if available
    Purr: "rbxassetid://507766388",      // Purr/idle - uses idle animation
};

/**
 * Default animation to use if a specific animation isn't found.
 */
export const DEFAULT_ANIMATION = "rbxassetid://507766388"; // Idle animation

/**
 * Animation priority settings.
 * Higher priority animations will override lower priority ones.
 */
export const ANIMATION_PRIORITIES: Record<string, Enum.AnimationPriority> = {
    Idle: Enum.AnimationPriority.Idle,
    Walk: Enum.AnimationPriority.Movement,
    Run: Enum.AnimationPriority.Movement,
    Jump: Enum.AnimationPriority.Action,
    Sleep: Enum.AnimationPriority.Action,
    Eat: Enum.AnimationPriority.Action,
    Groom: Enum.AnimationPriority.Action,
    Meow: Enum.AnimationPriority.Action,
    RollOver: Enum.AnimationPriority.Action,
    Purr: Enum.AnimationPriority.Action,
};

