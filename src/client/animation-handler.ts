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
            // Ensure the current animation is still playing
            const track = this.animationTracks.get(catId);
            if (track && !track.IsPlaying) {
                track.Play();
            }
            return;
        }

        this.StopAnimation(catId);

        const animationId = this.GetAnimationId(animationState);
        if (!animationId) {
            warn(`No animation ID found for state: ${animationState}`);
            return;
        }

        // Get the model that contains the humanoid
        const model = humanoid.Parent as Model;
        if (!model) {
            warn(`Humanoid has no parent model for cat ${catId}`);
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
        
        // Play the animation
        track.Play();

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

    private static GetAnimationId(state: string): string {
        // Get animation ID from config, fallback to default
        return ANIMATION_IDS[state] || DEFAULT_ANIMATION;
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
