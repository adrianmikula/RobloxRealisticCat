import { CatAI } from "../cat-ai";
import { CatManager } from "../cat-manager";
import { CatData } from "shared/cat-types";
import { Workspace } from "@rbxts/services";

export = () => {
    describe("Cat Grounding & Clipping", () => {
        const catId = "grounding_cat";
        let catData: CatData;

        beforeEach(() => {
            CatManager.GetAllCats().clear();
            catData = CatManager.CreateCat(catId, "Friendly");
            CatAI.InitializeCat(catId, catData);

            // Clear any previous hooks
            (Workspace as unknown as Record<string, unknown>)._raycastHook = undefined;
        });

        test("Cat snaps to ground on initialization", () => {
            const spawnPos = new Vector3(0, 10, 0);
            catData.currentState.position = spawnPos;
            catData.timers.lastUpdate = 0; // Trigger "first update" logic

            // Mock a floor at Y=5
            (Workspace as unknown as Record<string, unknown>)._raycastHook = (origin: Vector3) => {
                return {
                    Position: new Vector3(origin.X, 5, origin.Z),
                    Instance: new Instance("Part"),
                    Normal: new Vector3(0, 1, 0),
                    Material: Enum.Material.Plastic,
                    Distance: 995,
                };
            };

            CatAI.UpdateCat(catId, catData);

            // Should be at ground (5) + offset (0.1)
            const finalPos = catData.currentState.position;
            // permissive check
            expect(math.abs(finalPos.Y - 5.1) < 0.1).toBe(true);
        });

        test("Exploration targets are grounded", () => {
            // Mock a floor at Y=2
            (Workspace as unknown as Record<string, unknown>)._raycastHook = (origin: Vector3) => {
                return {
                    Position: new Vector3(origin.X, 2, origin.Z),
                    Instance: new Instance("Part"),
                    Normal: new Vector3(0, 1, 0),
                    Material: Enum.Material.Plastic,
                    Distance: 998,
                };
            };

            // Force exploration
            catData.behaviorState.currentAction = "Explore";
            catData.behaviorState.isMoving = false;

            // Prevent the AI from reconsidering and picking "Idle"
            const aiData = CatAI.activeCats.get(catId);
            if (aiData) {
                aiData.currentGoal = "Explore";
                aiData.lastDecisionTime = os.time();
            }

            CatAI.UpdateCat(catId, catData);

            // Check if it's moving and grounded
            const target = catData.behaviorState.targetPosition;
            const moving = catData.behaviorState.isMoving as boolean;

            expect(moving).toBe(true);
            if (target) {
                expect(math.abs(target.Y - 2.1) < 0.1).toBe(true);
            }
        });

        test("Cat stays at current Y if no ground is found", () => {
            const spawnPos = new Vector3(0, 10, 0);
            catData.currentState.position = spawnPos;
            catData.timers.lastUpdate = 0;

            // Mock no hit
            (Workspace as unknown as Record<string, unknown>)._raycastHook = () => undefined;

            CatAI.UpdateCat(catId, catData);

            // Should stay at 10
            expect(catData.currentState.position.Y).toBe(10);
        });
    });
};
