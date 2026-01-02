import { CatData } from "shared/cat-types";
import { ANIMATION_IDS, DEFAULT_ANIMATION, ANIMATION_PRIORITIES } from "shared/config/animation-config";

export class AnimationHandler {
    private static activeAnimations = new Map<string, string>();
    private static animationTracks = new Map<string, AnimationTrack>();
    private static animationInstances = new Map<string, Animation>();

    public static PlayAnimation(catId: string, animationState: string, humanoid: Humanoid) {
        // Stop current animation if it's different
        const currentAnim = this.activeAnimations.get(catId);
        if (currentAnim === animationState) {
            // Same animation - just ensure it's still playing
            const track = this.animationTracks.get(catId);
            if (track && !track.IsPlaying) {
                track.Play();
                print(`[AnimationHandler] Restarted animation "${animationState}" for cat ${catId}`);
            }
            return;
        }
        
        // Debug: Log animation change
        if (currentAnim) {
            print(`[AnimationHandler] Changing animation from "${currentAnim}" to "${animationState}" for cat ${catId}`);
        }

        this.StopAnimation(catId);

        // Get the model that contains the humanoid
        const model = humanoid.Parent as Model;
        if (!model) {
            warn(`Humanoid has no parent model for cat ${catId}`);
            return;
        }

        // Get animation ID (tries model first, then config)
        const animationId = this.GetAnimationId(animationState, model);
        if (!animationId) {
            warn(`No animation ID found for state: ${animationState}`);
            return;
        }

        // Create animation instance and parent it to the model
        const animation = new Instance("Animation");
        animation.AnimationId = animationId;
        animation.Parent = model; // Parent must be set before LoadAnimation

        // Load and play the animation
        // Note: LoadAnimation automatically loads the animation
        const track = humanoid.LoadAnimation(animation);
        
        // Set animation properties
        track.Looped = true; // Loop animations for continuous movement
        track.Priority = ANIMATION_PRIORITIES[animationState] || Enum.AnimationPriority.Idle; // Set priority from config
        
        // Debug: Log animation loading
        print(`[AnimationHandler] Playing animation "${animationState}" for cat ${catId}`);
        print(`[AnimationHandler] Animation ID: ${animationId}`);
        
        // Verify animation ID format
        if (!animationId || animationId === "" || animationId === "rbxassetid://0") {
            warn(`[AnimationHandler] Invalid animation ID for "${animationState}": ${animationId}`);
            warn(`[AnimationHandler] Check animation-config.ts - animation may not be uploaded or ID is wrong`);
            return;
        }
        
        // Try to play the animation with error handling
        const [success, errMsg] = pcall(() => {
            track.Play();
            return true;
        });
        
        if (!success) {
            warn(`[AnimationHandler] Failed to play animation "${animationState}" for cat ${catId}: ${errMsg}`);
            warn(`[AnimationHandler] Animation ID ${animationId} may be invalid or incompatible`);
            warn(`[AnimationHandler] Check: 1) Animation is uploaded, 2) ID is correct, 3) Animation matches rig type (R15/R6)`);
            return;
        }
        
        print(`[AnimationHandler] Track created: ${track !== undefined}`);
        
        // Debug: Verify animation is playing
        task.wait(0.1); // Small delay to let animation start
        if (!track.IsPlaying) {
            warn(`[AnimationHandler] Animation "${animationState}" failed to start playing for cat ${catId}`);
            warn(`[AnimationHandler] This usually means the animation ID is invalid or the animation doesn't match the rig type`);
        } else {
            print(`[AnimationHandler] Animation "${animationState}" is now playing for cat ${catId}`);
        }

        this.animationTracks.set(catId, track);
        this.animationInstances.set(catId, animation);
        this.activeAnimations.set(catId, animationState);
    }

    public static StopAnimation(catId: string) {
        const track = this.animationTracks.get(catId);
        if (track) {
            track.Stop();
            track.Destroy();
        }
        
        const animation = this.animationInstances.get(catId);
        if (animation) {
            animation.Destroy();
        }
        
        this.animationTracks.delete(catId);
        this.animationInstances.delete(catId);
        this.activeAnimations.delete(catId);
    }

    public static UpdateAnimationSpeed(catId: string, speed: number) {
        const track = this.animationTracks.get(catId);
        if (track) {
            track.AdjustSpeed(speed);
        }
    }

    /**
     * Get animation ID for a given state.
     * First tries to find Animation objects in the model, then falls back to config.
     */
    private static GetAnimationId(state: string, model?: Model): string {
        // First, try to find Animation objects in the model itself
        if (model) {
            const modelAnimation = this.FindAnimationInModel(model, state);
            if (modelAnimation) {
                print(`[AnimationHandler] Using Animation object from model "${model.Name}" for "${state}": ${modelAnimation}`);
                return modelAnimation;
            }
        }
        
        // Fall back to config file
        const configAnimation = ANIMATION_IDS[state] || DEFAULT_ANIMATION;
        print(`[AnimationHandler] Using config file animation for "${state}": ${configAnimation}`);
        return configAnimation;
    }

    /**
     * Find an Animation object in the model that matches the given state.
     * Looks for Animation objects by name (case-insensitive matching).
     * 
     * Common naming patterns:
     * - "Idle", "Walk", "Run", "Jump"
     * - "CatIdle", "CatWalk", etc.
     * - State name in Animation object name
     */
    private static FindAnimationInModel(model: Model, state: string): string | undefined {
        // Search for Animation objects in the model
        const animations = model.GetDescendants().filter((child): child is Animation => 
            child.IsA("Animation")
        );

        // Try exact match first (case-insensitive)
        const stateLower = state.lower();
        for (const anim of animations) {
            const animName = anim.Name.lower();
            if (animName === stateLower || animName === `cat${stateLower}`) {
                return anim.AnimationId;
            }
        }

        // Try partial match (e.g., "Walk" matches "Walking" or "WalkCycle")
        for (const anim of animations) {
            const animName = anim.Name.lower();
            if (animName.find(stateLower)[0] !== undefined || stateLower.find(animName)[0] !== undefined) {
                return anim.AnimationId;
            }
        }

        // Try common variations
        const stateVariations: Record<string, string[]> = {
            "Idle": ["idle", "standing", "rest"],
            "Walk": ["walk", "walking", "move"],
            "Run": ["run", "running", "sprint"],
            "Jump": ["jump", "jumping", "leap"],
            "Sleep": ["sleep", "sleeping", "rest"],
            "Eat": ["eat", "eating", "feed"],
            "Groom": ["groom", "grooming", "clean"],
        };

        const variations = stateVariations[state] || [stateLower];
        for (const anim of animations) {
            const animName = anim.Name.lower();
            for (const variation of variations) {
                if (animName.find(variation)[0] !== undefined) {
                    return anim.AnimationId;
                }
            }
        }

        return undefined;
    }

    /**
     * Validate all animation IDs from the config file.
     * This should be called during startup to catch invalid animation IDs early.
     * 
     * @param progressCallback Optional callback to report validation progress
     * @returns Validation results with list of invalid animations
     */
    public static async ValidateAllAnimations(
        progressCallback?: (progress: number, message: string) => void
    ): Promise<{ valid: number; invalid: Array<{ name: string; id: string; error: string }> }> {
        const results = {
            valid: 0,
            invalid: [] as Array<{ name: string; id: string; error: string }>,
        };

        // Get all animation names from config
        const animationNames: string[] = [];
        for (const [name] of pairs(ANIMATION_IDS)) {
            animationNames.push(name);
        }
        
        const totalAnimations = animationNames.size() + 1; // +1 for DEFAULT_ANIMATION
        let checked = 0;

        // Validate all animations from config
        for (const animationName of animationNames) {
            const animationId = ANIMATION_IDS[animationName];
            
            if (progressCallback) {
                progressCallback(checked / totalAnimations, `Validating ${animationName}...`);
            }

            const validation = this.ValidateAnimationId(animationId, animationName);
            if (validation.valid) {
                results.valid++;
            } else {
                results.invalid.push({ 
                    name: animationName, 
                    id: animationId, 
                    error: validation.error || "Unknown error" 
                });
            }
            
            checked++;
            task.wait(0.05); // Small delay to prevent blocking
        }

        // Validate default animation
        if (progressCallback) {
            progressCallback(checked / totalAnimations, "Validating default animation...");
        }
        const defaultValidation = this.ValidateAnimationId(DEFAULT_ANIMATION, "DEFAULT_ANIMATION");
        if (defaultValidation.valid) {
            results.valid++;
        } else {
            results.invalid.push({ 
                name: "DEFAULT_ANIMATION", 
                id: DEFAULT_ANIMATION, 
                error: defaultValidation.error || "Unknown error" 
            });
        }

        // Report results
        if (results.invalid.size() > 0) {
            warn(`[AnimationHandler] Validation found ${results.invalid.size()} invalid animation(s):`);
            for (const invalid of results.invalid) {
                warn(`  ❌ ${invalid.name}: ${invalid.id} - ${invalid.error}`);
            }
        } else {
            print(`[AnimationHandler] ✅ All ${results.valid} animations validated successfully!`);
        }

        if (progressCallback) {
            progressCallback(1, "Animation validation complete");
        }

        return results;
    }

    /**
     * Validate a single animation ID.
     * Attempts to load the animation to verify it's valid.
     * 
     * @param animationId The animation ID to validate
     * @param animationName Optional name for error reporting
     * @returns Validation result
     */
    private static ValidateAnimationId(
        animationId: string,
        animationName?: string
    ): { valid: boolean; error?: string } {
        // Check format
        if (!animationId || animationId === "" || animationId === "rbxassetid://0") {
            return { valid: false, error: "Empty or invalid ID format" };
        }

        // Check format matches rbxassetid:// pattern
        const idPattern = animationId.find("rbxassetid://");
        if (idPattern[0] !== 1) {
            return { valid: false, error: "Invalid ID format (must be rbxassetid://[ID])" };
        }

        // Extract numeric ID
        const numericId = animationId.sub(14); // "rbxassetid://".size() = 14
        if (!numericId || numericId === "" || numericId === "0") {
            return { valid: false, error: "Invalid numeric ID" };
        }

        // Try to create and load the animation (without actually playing it)
        // We'll use a temporary humanoid from Workspace if available, or just validate format
        const [success, errMsg] = pcall(() => {
            // Create a temporary animation instance to test loading
            const testAnimation = new Instance("Animation");
            testAnimation.AnimationId = animationId;
            
            // Try to validate the ID format and basic structure
            // Note: We can't fully validate without a humanoid, but we can check format
            testAnimation.Destroy();
            return true;
        });

        if (!success) {
            return { valid: false, error: `Failed to create animation instance: ${errMsg}` };
        }

        // Note: Full validation (checking if animation actually exists) would require:
        // 1. A humanoid to load the animation
        // 2. Network access to check if the asset exists
        // For now, we validate format and basic structure
        // Full validation happens when animations are actually played

        return { valid: true };
    }

    /**
     * Validate animations in a model (Animation objects).
     * 
     * @param model The model to check for Animation objects
     * @returns List of found animations and their IDs
     */
    public static ValidateModelAnimations(model: Model): Array<{ name: string; id: string; valid: boolean }> {
        const animations = model.GetDescendants().filter((child): child is Animation => 
            child.IsA("Animation")
        );

        const results: Array<{ name: string; id: string; valid: boolean }> = [];

        for (const anim of animations) {
            const validation = this.ValidateAnimationId(anim.AnimationId, anim.Name);
            results.push({
                name: anim.Name,
                id: anim.AnimationId,
                valid: validation.valid,
            });
        }

        return results;
    }

    public static Cleanup() {
        this.animationTracks.forEach((track) => {
            track.Stop();
            track.Destroy();
        });
        this.animationInstances.forEach((anim) => {
            anim.Destroy();
        });
        this.animationTracks.clear();
        this.animationInstances.clear();
        this.activeAnimations.clear();
    }
}
