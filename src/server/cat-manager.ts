import { CatData, CatProfile, MoodType } from "shared/cat-types";
import { CatProfileData } from "shared/cat-profile-data";

export class CatManager {
    private static catCounter = 0;
    private static catInstances = new Map<string, CatData>();

    public static CreateCat(catId?: string, profileType = "Friendly"): CatData {
        if (!catId) {
            this.catCounter++;
            catId = `cat_${string.format("%03d", this.catCounter)}`;
        }

        const catProfile = CatProfileData.CreateProfile(profileType);

        const catData: CatData = {
            id: catId,
            profile: catProfile,
            currentState: {
                position: new Vector3(0, 0, 0),
                rotation: new Vector3(0, 0, 0),
                velocity: new Vector3(0, 0, 0),
            },
            moodState: {
                currentMood: "Happy",
                moodIntensity: 0.5,
                moodDuration: 0,
                moodTriggers: [],
            },
            physicalState: {
                hunger: 50,
                energy: 100,
                health: 100,
                grooming: 80,
            },
            behaviorState: {
                currentAction: "Idle",
                currentPath: [],
                isMoving: false,
                isInteracting: false,
            },
            socialState: {
                playerRelationships: new Map<number, number>(),
                catRelationships: new Map<string, number>(),
                lastInteraction: 0,
            },
            timers: {
                lastUpdate: os.time(),
                nextActionTime: 0,
                moodChangeTime: 0,
            },
        };

        this.catInstances.set(catId, catData);
        return catData;
    }

    public static RemoveCat(catId: string) {
        this.catInstances.delete(catId);
    }

    public static GetCat(catId: string): CatData | undefined {
        return this.catInstances.get(catId);
    }

    public static GetAllCats(): Map<string, CatData> {
        return this.catInstances;
    }

    public static UpdateCatMood(catId: string, moodType: MoodType, intensity = 0.5) {
        const catData = this.catInstances.get(catId);
        if (!catData) return;

        const moodEffects = CatProfileData.GetMoodEffects(moodType);

        catData.moodState.currentMood = moodType;
        catData.moodState.moodIntensity = intensity;
        catData.moodState.moodDuration = math.random(moodEffects.duration[0], moodEffects.duration[1]);
        catData.moodState.moodTriggers = [];
    }

    public static UpdateCatPhysical(catId: string, physicalChanges: Partial<{ hunger: number; energy: number; health: number; grooming: number }>) {
        const catData = this.catInstances.get(catId);
        if (!catData) return;

        if (physicalChanges.hunger !== undefined) {
            catData.physicalState.hunger = math.clamp(catData.physicalState.hunger + physicalChanges.hunger, 0, 100);
        }
        if (physicalChanges.energy !== undefined) {
            catData.physicalState.energy = math.clamp(catData.physicalState.energy + physicalChanges.energy, 0, 100);
        }
        if (physicalChanges.health !== undefined) {
            catData.physicalState.health = math.clamp(catData.physicalState.health + physicalChanges.health, 0, 100);
        }
        if (physicalChanges.grooming !== undefined) {
            catData.physicalState.grooming = math.clamp(catData.physicalState.grooming + physicalChanges.grooming, 0, 100);
        }

        // Auto-trigger mood changes based on physical state
        if (catData.physicalState.hunger < 20) {
            this.UpdateCatMood(catId, "Hungry", 0.8);
        } else if (catData.physicalState.energy < 20) {
            this.UpdateCatMood(catId, "Tired", 0.7);
        }
    }
}
