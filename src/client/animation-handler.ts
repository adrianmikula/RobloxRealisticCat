import { CatData } from "shared/cat-types";

export class AnimationHandler {
    private static activeAnimations = new Map<string, string>();
    private static animationTracks = new Map<string, AnimationTrack>();

    public static PlayAnimation(catId: string, animationState: string, humanoid: Humanoid) {
        // Stop current animation if it's different
        const currentAnim = this.activeAnimations.get(catId);
        if (currentAnim === animationState) return;

        this.StopAnimation(catId);

        const animationId = this.GetAnimationId(animationState);
        if (!animationId) return;

        const animation = new Instance("Animation");
        animation.AnimationId = animationId;

        const track = humanoid.LoadAnimation(animation);
        track.Play();

        this.animationTracks.set(catId, track);
        this.activeAnimations.set(catId, animationState);
    }

    public static StopAnimation(catId: string) {
        const track = this.animationTracks.get(catId);
        if (track) {
            track.Stop();
            track.Destroy();
        }
        this.animationTracks.delete(catId);
        this.activeAnimations.delete(catId);
    }

    public static UpdateAnimationSpeed(catId: string, speed: number) {
        const track = this.animationTracks.get(catId);
        if (track) {
            track.AdjustSpeed(speed);
        }
    }

    private static GetAnimationId(state: string): string {
        // Mapping based on the original Lua AnimationHandler
        const placeholderMap: Record<string, string> = {
            Idle: "rbxassetid://507766666",
            Walk: "rbxassetid://507767714",
            Run: "rbxassetid://507767714",
            Jump: "rbxassetid://507765000",
            Sleep: "rbxassetid://507766388",
            Eat: "rbxassetid://507766388",
            Groom: "rbxassetid://507766388",
            Explore: "rbxassetid://507767714",
            SeekFood: "rbxassetid://507767714",
            SeekRest: "rbxassetid://507766388",
            Socialize: "rbxassetid://507766666",
            Follow: "rbxassetid://507767714",
            LookAt: "rbxassetid://507766666",
            Meow: "rbxassetid://507766666",
            RollOver: "rbxassetid://507766388",
        };

        return placeholderMap[state] || placeholderMap.Idle;
    }

    public static Cleanup() {
        this.animationTracks.forEach((track) => {
            track.Stop();
            track.Destroy();
        });
        this.animationTracks.clear();
        this.activeAnimations.clear();
    }
}
