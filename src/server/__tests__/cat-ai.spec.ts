import { CatAI } from "../cat-ai";
import { CatManager } from "../cat-manager";

export = () => {
    describe("CatAI", () => {
        const catId = "ai_cat";

        beforeEach(() => {
            CatManager.GetAllCats().clear();
            const catData = CatManager.CreateCat(catId);
            CatAI.InitializeCat(catId, catData);
            math.randomseed(1234); // Deterministic randomness
        });

        test("State Decay - Hunger", () => {
            const catData = CatManager.GetCat(catId)!;
            const initialHunger = catData.physicalState.hunger;

            // Mock time passed
            catData.timers.lastUpdate = os.time() - 10;
            CatAI.UpdateCat(catId, catData);

            expect(catData.physicalState.hunger > initialHunger).toBe(true);
        });

        test("State Decay - Energy", () => {
            const catData = CatManager.GetCat(catId)!;
            const initialEnergy = catData.physicalState.energy;

            catData.behaviorState.isMoving = true;
            catData.timers.lastUpdate = os.time() - 10;
            CatAI.UpdateCat(catId, catData);

            expect(catData.physicalState.energy < initialEnergy).toBe(true);
        });

        test("Decision Making - High Hunger", () => {
            const catData = CatManager.GetCat(catId)!;
            catData.physicalState.hunger = 95;
            catData.profile.personality.curiosity = 0.1; // Low curiosity to avoid exploration priority

            // Force a decision
            CatAI.ForceDecision(catId);

            CatAI.UpdateCat(catId, catData);

            expect(catData.behaviorState.currentAction).toBe("SeekFood");
        });

        test("Decision Making - Low Energy", () => {
            const catData = CatManager.GetCat(catId)!;
            catData.physicalState.energy = 10;

            CatAI.ForceDecision(catId);

            CatAI.UpdateCat(catId, catData);

            expect(catData.behaviorState.currentAction).toBe("SeekRest");
        });

        test("Action Execution - Explore", () => {
            const catData = CatManager.GetCat(catId)!;
            catData.behaviorState.currentAction = "Explore";
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                aiData.currentGoal = "Explore";
                aiData.lastDecisionTime = os.time(); // Prevent new decision during this update
            }

            CatAI.UpdateCat(catId, catData);

            // Should have set a target position and started moving
            expect(catData.behaviorState.isMoving).toBe(true);
            expect(catData.behaviorState.targetPosition !== undefined).toBe(true);
        });
    });
};
