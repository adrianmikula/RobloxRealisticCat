// cat-social-behaviors.spec.ts
// Tests for cat AI social behavior decision weights and execution

import { CatAI } from "../cat-ai";
import { CatData, BehaviorState, MoodState, PhysicalState, Profile } from "../../shared/cat-types";
import { RelationshipManager } from "../relationship-manager";
import { Players } from "@rbxts/services";

// Helper to create a minimal cat data object
function createCatData(overrides?: Partial<CatData>): CatData {
    const defaultData: CatData = {
        catId: "testCat",
        profile: {
            breed: "Tabby",
            personality: {
                friendliness: 0.5,
                playfulness: 0.5,
                curiosity: 0.5,
                independence: 0.5,
                shyness: 0.5,
            },
            behavior: {
                explorationRange: 20,
                movementSpeed: 10,
                jumpHeight: 15,
            },
        } as Profile,
        currentState: {
            position: new Vector3(0, 5, 0),
        },
        moodState: { currentMood: "Happy", moodIntensity: 0.5, moodDuration: 0 } as MoodState,
        physicalState: { hunger: 0, energy: 100, grooming: 0 } as PhysicalState,
        behaviorState: {
            currentAction: "Idle",
            isMoving: false,
        } as BehaviorState,
        timers: { lastUpdate: 0 },
    };
    return { ...defaultData, ...overrides } as CatData;
}

// Mock a player and relationship
function mockPlayer(userId: number, position: Vector3) {
    const player = Players.GetPlayerByUserId(userId) as any;
    if (!player) {
        // Create a dummy player object if not existent (Roblox environment may not allow direct creation)
        // For test purposes we rely on the Players service returning undefined; we will stub RelationshipManager directly.
        return { UserId: userId, Character: { HumanoidRootPart: { Position: position } } } as any;
    }
    return player;
}

describe("CatAI Social Behavior Decision Weights", () => {
    it("gives higher Follow weight when trust is high and distance > 10", () => {
        const cat = createCatData();
        const playerId = 12345;
        // Stub RelationshipManager to return high trust
        const originalGetRelationship = RelationshipManager.GetRelationship;
        (RelationshipManager as any).GetRelationship = (player: any, catId: string) => ({ trustLevel: 0.8 } as any);
        // Stub Players service to return a player at distance 20
        const originalPlayers = Players.GetPlayers;
        (Players as any).GetPlayers = () => [{ UserId: playerId, Character: { HumanoidRootPart: { Position: new Vector3(20, 5, 0) } } }];

        const weights = (CatAI as any).CalculateDecisionWeights("testCat", cat);
        expect(weights.get("Follow")).toBeGreaterThan(0);

        // Restore stubs
        (RelationshipManager as any).GetRelationship = originalGetRelationship;
        (Players as any).GetPlayers = originalPlayers;
    });

    it("gives LookAt weight when player is within 20 studs", () => {
        const cat = createCatData();
        const playerId = 54321;
        const originalGetRelationship = RelationshipManager.GetRelationship;
        (RelationshipManager as any).GetRelationship = (player: any, catId: string) => ({ trustLevel: 0.3 } as any);
        const originalPlayers = Players.GetPlayers;
        (Players as any).GetPlayers = () => [{ UserId: playerId, Character: { HumanoidRootPart: { Position: new Vector3(10, 5, 0) } } }];

        const weights = (CatAI as any).CalculateDecisionWeights("testCat", cat);
        expect(weights.get("LookAt")).toBeGreaterThan(0);

        (RelationshipManager as any).GetRelationship = originalGetRelationship;
        (Players as any).GetPlayers = originalPlayers;
    });

    it("assigns Meow weight when hunger is high or trust is high", () => {
        const cat = createCatData({ physicalState: { hunger: 70, energy: 80, grooming: 0 } as PhysicalState });
        const playerId = 11111;
        const originalGetRelationship = RelationshipManager.GetRelationship;
        (RelationshipManager as any).GetRelationship = (player: any, catId: string) => ({ trustLevel: 0.9 } as any);
        const originalPlayers = Players.GetPlayers;
        (Players as any).GetPlayers = () => [{ UserId: playerId, Character: { HumanoidRootPart: { Position: new Vector3(5, 5, 0) } } }];

        const weights = (CatAI as any).CalculateDecisionWeights("testCat", cat);
        expect(weights.get("Meow")).toBeGreaterThan(0);

        (RelationshipManager as any).GetRelationship = originalGetRelationship;
        (Players as any).GetPlayers = originalPlayers;
    });

    it("assigns RollOver weight only for very high trust and close distance", () => {
        const cat = createCatData();
        const playerId = 22222;
        const originalGetRelationship = RelationshipManager.GetRelationship;
        (RelationshipManager as any).GetRelationship = (player: any, catId: string) => ({ trustLevel: 0.95 } as any);
        const originalPlayers = Players.GetPlayers;
        (Players as any).GetPlayers = () => [{ UserId: playerId, Character: { HumanoidRootPart: { Position: new Vector3(5, 5, 0) } } }];

        const weights = (CatAI as any).CalculateDecisionWeights("testCat", cat);
        expect(weights.get("RollOver")).toBeGreaterThan(0);

        (RelationshipManager as any).GetRelationship = originalGetRelationship;
        (Players as any).GetPlayers = originalPlayers;
    });
});
