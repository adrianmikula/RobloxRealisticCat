import { CatData, AIData, BehaviorTree, MoodType } from "shared/cat-types";
import { CatProfileData } from "shared/cat-profile-data";
import { CatManager } from "./cat-manager";

export class CatAI {
    private static activeCats = new Map<string, AIData>();

    public static InitializeCat(catId: string, catData: CatData) {
        const aiData: AIData = {
            lastDecisionTime: 0,
            currentGoal: undefined,
            memory: new Map<string, unknown>(),
            behaviorTree: this.SetupBehaviorTree(catId, catData.profile.breed), // Use breed or profile as key
        };

        this.activeCats.set(catId, aiData);
    }

    /** @internal Testing hook */
    public static GetAIData(catId: string) {
        return this.activeCats.get(catId);
    }

    /** @internal Testing hook */
    public static ForceDecision(catId: string) {
        const aiData = this.activeCats.get(catId);
        if (aiData) aiData.lastDecisionTime = 0;
    }

    public static CleanupCat(catId: string) {
        this.activeCats.delete(catId);
    }

    public static UpdateCat(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        if (!aiData) return;

        const currentTime = os.time();

        // Update mood and physical state decay
        this.UpdateStateDecay(catId, catData);

        // Make decisions every 2-5 seconds based on personality
        const curiosity = catData.profile.personality.curiosity;
        const decisionFrequency = 2 + 3 * (1 - curiosity);

        if (currentTime - aiData.lastDecisionTime >= decisionFrequency) {
            this.MakeDecision(catId, catData);
            aiData.lastDecisionTime = currentTime;
        }

        // Execute current action
        this.ExecuteCurrentAction(catId, catData);
    }

    private static UpdateStateDecay(catId: string, catData: CatData) {
        const decayRate = 0.1; // per second
        const currentTime = os.time();
        const timePassed = currentTime - catData.timers.lastUpdate;

        if (timePassed > 0) {
            // Hunger increases over time
            catData.physicalState.hunger = math.clamp(catData.physicalState.hunger + decayRate * timePassed, 0, 100);

            // Energy decreases with activity
            const activityMultiplier = catData.behaviorState.isMoving ? 2 : 1;
            catData.physicalState.energy = math.clamp(
                catData.physicalState.energy - decayRate * activityMultiplier * timePassed,
                0,
                100,
            );

            // Mood duration decreases
            if (catData.moodState.moodDuration > 0) {
                catData.moodState.moodDuration = math.max(0, catData.moodState.moodDuration - timePassed);
                if (catData.moodState.moodDuration === 0) {
                    // Return to neutral mood
                    catData.moodState.currentMood = "Happy";
                    catData.moodState.moodIntensity = 0.5;
                }
            }

            catData.timers.lastUpdate = currentTime;
        }
    }

    private static MakeDecision(catId: string, catData: CatData) {
        const weights = this.CalculateDecisionWeights(catId, catData);

        let bestAction = "Idle";
        let bestWeight = -1;

        for (const [action, weight] of weights) {
            if (weight > bestWeight) {
                bestWeight = weight;
                bestAction = action;
            }
        }

        // Apply personality modifiers
        bestAction = this.ApplyPersonalityModifiers(catId, catData, bestAction);

        // Set the new action
        this.SetCatAction(catId, bestAction);
    }

    private static CalculateDecisionWeights(catId: string, catData: CatData): Map<string, number> {
        const weights = new Map<string, number>();
        weights.set("Idle", 1.0);
        weights.set("Explore", 0.5);
        weights.set("SeekFood", 0.0);
        weights.set("SeekRest", 0.0);
        weights.set("Play", 0.5);
        weights.set("Groom", 0.3);

        const moodEffects = CatProfileData.GetMoodEffects(catData.moodState.currentMood);
        if (moodEffects) {
            const explorationBoost = moodEffects.explorationBoost || 0;
            const playfulnessBoost = moodEffects.playfulnessBoost || 0;

            weights.set("Explore", weights.get("Explore")! * (1 + explorationBoost));
            weights.set("Play", weights.get("Play")! * (1 + playfulnessBoost));
        }

        const hunger = catData.physicalState.hunger;
        if (hunger > 70) {
            weights.set("SeekFood", 3.0 + (hunger - 70) * 0.1);
        } else if (hunger > 50) {
            weights.set("SeekFood", 1.0);
        } else {
            weights.set("SeekFood", 0.5);
        }

        const energy = catData.physicalState.energy;
        if (energy < 30) {
            weights.set("SeekRest", 4.0 + (30 - energy) * 0.1);
        } else if (energy < 50) {
            weights.set("SeekRest", 1.5);
        } else {
            weights.set("SeekRest", 0.5);
        }

        // Personality modifiers
        weights.set("Explore", weights.get("Explore")! * catData.profile.personality.curiosity);
        weights.set("Play", weights.get("Play")! * catData.profile.personality.playfulness);

        // Random variation
        weights.forEach((weight, action) => {
            if (weight > 0) {
                weights.set(action, weight * (0.8 + math.random() * 0.4));
            }
        });

        return weights;
    }

    private static ApplyPersonalityModifiers(catId: string, catData: CatData, action: string): string {
        if (action === "Socialize" && catData.profile.personality.independence > 0.7) {
            return math.random() < 0.3 ? "Explore" : "Idle";
        }

        if (action === "Socialize" && catData.profile.personality.shyness > 0.6) {
            return math.random() < 0.4 ? "Groom" : "Idle";
        }

        return action;
    }

    private static SetCatAction(catId: string, actionType: string) {
        const aiData = this.activeCats.get(catId);
        if (!aiData) return;

        const catData = CatManager.GetCat(catId);
        if (catData) {
            catData.behaviorState.currentAction = actionType;
        }

        aiData.currentGoal = actionType;
    }

    private static ExecuteCurrentAction(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        if (!aiData || !aiData.currentGoal) return;

        const action = aiData.currentGoal;

        if (action === "Explore") {
            this.ExecuteExplore(catId, catData);
        } else if (action === "SeekFood") {
            this.ExecuteSeekFood(catId, catData);
        } else if (action === "SeekRest") {
            this.ExecuteSeekRest(catId, catData);
        } else if (action === "Play") {
            this.ExecutePlay(catId, catData);
        } else if (action === "Groom") {
            this.ExecuteGroom(catId, catData);
        } else {
            this.ExecuteIdle(catId, catData);
        }
    }

    private static ExecuteExplore(catId: string, catData: CatData) {
        const explorationRange = catData.profile.behavior.explorationRange;
        const currentPos = catData.currentState.position;

        if (!catData.behaviorState.isMoving) {
            const rx = (math.random() - 0.5) * explorationRange * 2;
            const rz = (math.random() - 0.5) * explorationRange * 2;
            const targetPos = currentPos.add(new Vector3(rx, 0, rz));
            catData.behaviorState.targetPosition = targetPos;
            catData.behaviorState.isMoving = true;
            print(`[CatAI] Started exploring to ${targetPos} (offset: ${rx}, ${rz})`);
        }

        if (catData.behaviorState.isMoving && catData.behaviorState.targetPosition) {
            const targetPos = catData.behaviorState.targetPosition;
            const diff = targetPos.sub(currentPos);

            if (diff.Magnitude < 2) {
                print(`[CatAI] Arrived at ${targetPos} (distance: ${diff.Magnitude})`);
                catData.behaviorState.isMoving = false;
                catData.behaviorState.targetPosition = undefined;
            } else {
                const direction = diff.Unit;
                const speed = catData.profile.physical.movementSpeed * 0.1;
                catData.currentState.position = currentPos.add(direction.mul(speed));
            }
        }
    }

    private static ExecuteSeekFood(catId: string, catData: CatData) {
        this.ExecuteExplore(catId, catData);
        if (!catData.behaviorState.isMoving) {
            catData.physicalState.hunger = math.max(0, catData.physicalState.hunger - 20);
        }
    }

    private static ExecuteSeekRest(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
        catData.physicalState.energy = math.min(100, catData.physicalState.energy + 5);
    }

    private static ExecutePlay(catId: string, catData: CatData) {
        this.ExecuteExplore(catId, catData);
        catData.physicalState.energy = math.max(0, catData.physicalState.energy - 2);
    }

    private static ExecuteGroom(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
        catData.physicalState.grooming = math.min(100, catData.physicalState.grooming + 3);
    }

    private static ExecuteIdle(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
    }

    private static SetupBehaviorTree(catId: string, profileName: string): BehaviorTree {
        const nodes = new Map<string, any>();
        nodes.set("Selector", {
            type: "selector",
            children: ["UrgentNeeds", "MoodDriven", "PersonalityDriven", "Idle"],
        });

        return {
            root: "Selector",
            nodes: nodes,
        };
    }
}
