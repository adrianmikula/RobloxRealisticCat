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
    Walk: "rbxassetid://117481489766845",      // Walk animation - replace with your walk animation ID
    Run: "rbxassetid://117481489766845",       // Run animation - replace with your run animation ID
    Jump: "rbxassetid://75293643927731",      // Jump animation - replace with your jump animation ID
    Fall: "rbxassetid://75293643927731",      // Fall animation (can reuse walk)
    
    // Cat-specific behaviors
    // These can use the same animations as basic movements, or custom animations
    Sleep: "rbxassetid://507766388",     // Sleep/idle - replace with sleep animation if available
    Eat: "rbxassetid://507766388",       // Eat/idle - replace with eat animation if available
    Groom: "rbxassetid://507766388",     // Groom/idle - replace with groom animation if available
    Explore: "rbxassetid://117481489766845",   // Explore/walk - uses walk animation
    SeekFood: "rbxassetid://117481489766845",  // Seek food/walk - uses walk animation
    SeekRest: "rbxassetid://117481489766845",  // Seek rest/idle - uses idle animation
    Socialize: "rbxassetid://507766388", // Socialize/idle - uses idle animation
    Follow: "rbxassetid://117481489766845",   // Follow/walk - uses walk animation
    LookAt: "rbxassetid://507766388",    // Look at/idle - uses idle animation
    Meow: "rbxassetid://507766388",      // Meow/idle - replace with meow animation if available
    RollOver: "rbxassetid://507766388",  // Roll over/idle - replace with roll animation if available
    Purr: "rbxassetid://507766388",      // Purr/idle - uses idle animation
};

/**
 * Reference: High-Quality Cat Animations
 * 
 * For inspiration and examples of professional cat animations, see:
 * https://devforum.roblox.com/t/creator-spotlight-how-animator-bavelly-brings-warrior-cats-and-prehistoric-animals-to-life/3730925
 * 
 * This DevForum post showcases realistic, high-quality cat animations and can serve as
 * a reference for animation style and quality standards.
 */

// GreyStripes model animations NEW IDS
// - Jump: 121623131444074
// - Walk: 81156765879428
// - Tail down: 138926122904491
// - Tail up:  97294340795959

// GreyStripes model animations OLD IDS
// - Jump: 75293643927731 
// - Walk: 117481489766845 
// - Tail down: 95703588784434
// - Tail up: 85958022702535

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

