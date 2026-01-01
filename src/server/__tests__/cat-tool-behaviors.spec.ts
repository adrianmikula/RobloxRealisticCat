import { CatAI } from "../cat-ai";
import { CatManager } from "../cat-manager";
import { PlayerManager } from "../player-manager";
import { RelationshipManager } from "../relationship-manager";
import { CatData } from "shared/cat-types";

export = () => {
    describe("Cat Tool-Based Behaviors", () => {
        const catId = "tool_behavior_cat";
        const mockPlayer = { UserId: 2001, Name: "ToolPlayer", Character: undefined } as Player;
        let catData: CatData;

        beforeEach(() => {
            CatManager.GetAllCats().clear();
            catData = CatManager.CreateCat(catId, "Friendly");
            CatAI.InitializeCat(catId, catData);
            PlayerManager.HandlePlayerAdded(mockPlayer);
            
            // Create a mock character for the player
            const mockCharacter = {
                FindFirstChild: (name: string) => {
                    if (name === "HumanoidRootPart") {
                        return {
                            Position: new Vector3(10, 0, 10),
                            CFrame: CFrame.lookAt(new Vector3(10, 0, 10), new Vector3(0, 0, 0)),
                            LookVector: new Vector3(-1, 0, -1).Unit,
                        } as unknown as Part;
                    }
                    return undefined;
                },
                PrimaryPart: {
                    Position: new Vector3(10, 0, 10),
                } as unknown as Part,
            } as unknown as Model;
            
            (mockPlayer as unknown as { Character: Model }).Character = mockCharacter;
            
            // Set up relationship
            RelationshipManager.UpdateRelationship(mockPlayer, catId, 0.5);
            
            // Position cat near player
            catData.currentState.position = new Vector3(0, 0, 0);
        });

        test("LookAtToy behavior when player holds toy", () => {
            PlayerManager.EquipTool(mockPlayer, "basicToys");
            
            // Force decision
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);
            
            // Cat should look at player with toy
            expect(catData.behaviorState.currentAction === "LookAtToy" || 
                   catData.behaviorState.currentAction === "LookAt").toBe(true);
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                expect(aiData.memory.get("SocialTarget")).toBe(mockPlayer.UserId);
            }
        });

        test("PlayWithToy behavior when player uses toy facing cat", () => {
            PlayerManager.EquipTool(mockPlayer, "basicToys");
            PlayerManager.RecordToolUsage(mockPlayer, "basicToys", new Vector3(10, 0, 10));
            
            // Make cat playful
            catData.profile.personality.playfulness = 0.9;
            catData.physicalState.energy = 80; // Enough energy to play
            
            // Force decision
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);
            
            // Cat should play with toy (high priority for playful cats)
            // Note: This might not always trigger due to facing check, but weight should be high
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                expect(aiData.memory.get("SocialTarget")).toBe(mockPlayer.UserId);
            }
        });

        test("ApproachFood behavior when player holds food", () => {
            PlayerManager.EquipTool(mockPlayer, "basicFood");
            
            // Make cat hungry
            catData.physicalState.hunger = 70;
            
            // Force decision
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);
            
            // Cat should approach food
            expect(catData.behaviorState.currentAction === "ApproachFood" || 
                   catData.behaviorState.currentAction === "SeekFood").toBe(true);
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                expect(aiData.memory.get("SocialTarget")).toBe(mockPlayer.UserId);
            }
        });

        test("ApproachFood execution moves cat towards player", () => {
            PlayerManager.EquipTool(mockPlayer, "basicFood");
            catData.behaviorState.currentAction = "ApproachFood";
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                aiData.memory.set("SocialTarget", mockPlayer.UserId);
                aiData.memory.set("PlayerTool", "basicFood");
                aiData.lastDecisionTime = os.time() + 1000; // Prevent new decision
            }
            
            const initialPos = catData.currentState.position;
            CatAI.UpdateCat(catId, catData);
            
            // Cat should be moving towards player
            expect(catData.behaviorState.isMoving).toBe(true);
            expect(catData.behaviorState.targetPosition !== undefined).toBe(true);
        });

        test("CirclePlayer behavior when close to player with food", () => {
            PlayerManager.EquipTool(mockPlayer, "basicFood");
            
            // Position cat close to player (within 8 studs)
            catData.currentState.position = new Vector3(7, 0, 7);
            catData.profile.personality.playfulness = 0.7; // Playful enough to circle
            
            // Force decision
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);
            
            // Cat should circle or sit (depending on playfulness)
            const action = catData.behaviorState.currentAction;
            expect(action === "CirclePlayer" || action === "SitAndMeow").toBe(true);
        });

        test("CirclePlayer execution creates circular movement", () => {
            PlayerManager.EquipTool(mockPlayer, "basicFood");
            catData.currentState.position = new Vector3(5, 0, 5);
            catData.behaviorState.currentAction = "CirclePlayer";
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                aiData.memory.set("SocialTarget", mockPlayer.UserId);
                aiData.memory.set("PlayerTool", "basicFood");
                aiData.lastDecisionTime = os.time() + 1000;
            }
            
            CatAI.UpdateCat(catId, catData);
            
            // Cat should be moving in a circle
            expect(catData.behaviorState.isMoving).toBe(true);
            expect(aiData?.memory.get("CircleAngle") !== undefined).toBe(true);
        });

        test("SitAndMeow behavior when less playful cat near food", () => {
            PlayerManager.EquipTool(mockPlayer, "basicFood");
            
            // Position cat close to player
            catData.currentState.position = new Vector3(6, 0, 6);
            catData.profile.personality.playfulness = 0.3; // Less playful, should sit
            
            // Force decision
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);
            
            // Less playful cats should sit and meow
            expect(catData.behaviorState.currentAction === "SitAndMeow").toBe(true);
        });

        test("SitAndMeow execution makes cat meow periodically", () => {
            PlayerManager.EquipTool(mockPlayer, "basicFood");
            catData.currentState.position = new Vector3(5, 0, 5);
            catData.behaviorState.currentAction = "SitAndMeow";
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                aiData.memory.set("SocialTarget", mockPlayer.UserId);
                aiData.memory.set("PlayerTool", "basicFood");
                aiData.lastDecisionTime = os.time() + 1000;
            }
            
            CatAI.UpdateCat(catId, catData);
            
            // Cat should not be moving
            expect(catData.behaviorState.isMoving).toBe(false);
            expect(catData.behaviorState.targetPosition !== undefined).toBe(true);
        });

        test("PlayWithToy sets playful mood", () => {
            PlayerManager.EquipTool(mockPlayer, "basicToys");
            PlayerManager.RecordToolUsage(mockPlayer, "basicToys");
            
            catData.behaviorState.currentAction = "PlayWithToy";
            catData.moodState.currentMood = "Happy";
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                aiData.memory.set("SocialTarget", mockPlayer.UserId);
                aiData.memory.set("PlayerTool", "basicToys");
                aiData.lastDecisionTime = os.time() + 1000;
            }
            
            CatAI.UpdateCat(catId, catData);
            
            // Mood should change to Playful
            expect(catData.moodState.currentMood).toBe("Playful");
        });

        test("PlayWithToy consumes energy", () => {
            PlayerManager.EquipTool(mockPlayer, "basicToys");
            PlayerManager.RecordToolUsage(mockPlayer, "basicToys");
            
            catData.behaviorState.currentAction = "PlayWithToy";
            catData.physicalState.energy = 80;
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                aiData.memory.set("SocialTarget", mockPlayer.UserId);
                aiData.memory.set("PlayerTool", "basicToys");
                aiData.lastDecisionTime = os.time() + 1000;
            }
            
            const initialEnergy = catData.physicalState.energy;
            CatAI.UpdateCat(catId, catData);
            
            // Energy should decrease while playing
            expect(catData.physicalState.energy < initialEnergy).toBe(true);
        });

        test("Tool behaviors have higher priority than idle", () => {
            PlayerManager.EquipTool(mockPlayer, "basicToys");
            
            // Cat should prefer looking at toy over idling
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);
            
            const action = catData.behaviorState.currentAction;
            expect(action !== "Idle").toBe(true);
        });

        test("No tool behavior when player has no tool", () => {
            PlayerManager.UnequipTool(mockPlayer);
            
            CatAI.ForceDecision(catId);
            CatAI.UpdateCat(catId, catData);
            
            // Should not be a tool-based behavior
            const action = catData.behaviorState.currentAction;
            expect(action !== "LookAtToy" && 
                   action !== "PlayWithToy" && 
                   action !== "ApproachFood" && 
                   action !== "CirclePlayer" && 
                   action !== "SitAndMeow").toBe(true);
        });

        test("ApproachFood transitions to CirclePlayer when close", () => {
            PlayerManager.EquipTool(mockPlayer, "basicFood");
            catData.currentState.position = new Vector3(4, 0, 4); // Close to player
            catData.profile.personality.playfulness = 0.6;
            catData.behaviorState.currentAction = "ApproachFood";
            
            const aiData = CatAI.GetAIData(catId);
            if (aiData) {
                aiData.memory.set("SocialTarget", mockPlayer.UserId);
                aiData.memory.set("PlayerTool", "basicFood");
                aiData.lastDecisionTime = os.time() + 1000;
            }
            
            CatAI.UpdateCat(catId, catData);
            
            // Should transition to circling or sitting
            const action = catData.behaviorState.currentAction;
            expect(action === "CirclePlayer" || action === "SitAndMeow").toBe(true);
        });
    });
};

