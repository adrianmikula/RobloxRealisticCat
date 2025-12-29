import { CatAI } from "../cat-ai";
import { CatManager } from "../cat-manager";
import { CatData } from "shared/cat-types";

export = () => {
    describe("Cat Dynamics", () => {
        const catId = "dynamic_cat";
        let catData: CatData;

        beforeEach(() => {
            CatManager.GetAllCats().clear();
            catData = CatManager.CreateCat(catId, "Friendly");
            CatAI.InitializeCat(catId, catData);
        });

        test("Cat moves towards target when ExecuteExplore is called", () => {
            const initialPos = catData.currentState.position;

            // Block decisions during this test
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                (aiData as unknown as Record<string, unknown>).lastDecisionTime = os.time() + 1000;
                (aiData as unknown as Record<string, unknown>).currentGoal = "Explore";
            }

            // Force exploration
            catData.behaviorState.targetPosition = initialPos.add(new Vector3(10, 0, 10));
            catData.behaviorState.isMoving = true;
            catData.behaviorState.currentAction = "Explore";

            // Run multiple updates to see progression
            for (let i = 0; i < 5; i++) {
                CatAI.UpdateCat(catId, catData);
                // print(`Step ${i}: pos=${catData.currentState.position}`);
            }

            const newPos = catData.currentState.position;
            const distanceMoved = newPos.sub(initialPos).Magnitude;

            expect(distanceMoved > 0).toBe(true);
            expect(distanceMoved < 15).toBe(true); // Should move but not teleport
        });

        test("Cat hunger increases over time", () => {
            const initialHunger = catData.physicalState.hunger;

            // Simulate 100 seconds passing
            catData.timers.lastUpdate = os.time() - 100;

            CatAI.UpdateCat(catId, catData);

            expect(catData.physicalState.hunger > initialHunger).toBe(true);
        });

        test("Energy decays faster when moving", () => {
            const stationaryCat = CatManager.CreateCat("stationary", "Friendly");
            const movingCat = CatManager.CreateCat("moving", "Friendly");

            CatAI.InitializeCat("stationary", stationaryCat);
            CatAI.InitializeCat("moving", movingCat);

            movingCat.behaviorState.isMoving = true;

            const timeJump = 50;
            stationaryCat.timers.lastUpdate = os.time() - timeJump;
            movingCat.timers.lastUpdate = os.time() - timeJump;

            CatAI.UpdateCat("stationary", stationaryCat);
            CatAI.UpdateCat("moving", movingCat);

            const stationaryLoss = 100 - stationaryCat.physicalState.energy;
            const movingLoss = 100 - movingCat.physicalState.energy;

            expect(movingLoss > stationaryLoss).toBe(true);
        });

        test("Mood intensity affects weight calculation", () => {
            // This is a bit of a white-box test because we're testing internal weights indirectly
            // but it's important for dynamics.

            // Set high hunger manually
            catData.physicalState.hunger = 95;

            // In CatAI, high hunger should heavily weight towards SeekFood
            // We can check if it makes that decision
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);

            expect(catData.behaviorState.currentAction).toBe("SeekFood");
        });
    });
};
