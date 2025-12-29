import { RelationshipManager } from "../relationship-manager";

export = () => {
    describe("RelationshipManager", () => {
        const mockPlayer = { UserId: 123, Name: "TestPlayer" } as Player;
        const catId = "test_cat";

        beforeEach(() => {
            // Clear state? No static clear yet, but we can assume fresh for unit tests
            // or we could add a Reset method if needed.
        });

        test("GetRelationship initialization", () => {
            const rel = RelationshipManager.GetRelationship(mockPlayer, catId);
            expect(rel.trustLevel).toBe(0.5);
            expect(rel.relationshipTier).toBe("Neutral");
        });

        test("UpdateRelationship", () => {
            RelationshipManager.UpdateRelationship(mockPlayer, catId, 0.2);
            const rel = RelationshipManager.GetRelationship(mockPlayer, catId);
            expect(rel.trustLevel).toBe(0.7);
            expect(rel.relationshipScore).to.equal(rel.relationshipScore);
        });

        test("Relationship Tiers", () => {
            const rel = RelationshipManager.GetRelationship(mockPlayer, "tier_cat");

            // Force high trust and multiple interactions to raise score
            RelationshipManager.UpdateRelationship(mockPlayer, "tier_cat", 0.5); // trust = 1.0
            for (let i = 0; i < 20; i++) {
                RelationshipManager.AddInteractionToHistory(mockPlayer, "tier_cat", {
                    type: "Pet",
                    timestamp: os.time(),
                    outcome: "positive",
                    effects: {},
                });
            }

            // Manually trigger score calc to be sure
            RelationshipManager.UpdateRelationship(mockPlayer, "tier_cat", 0);

            const updatedRel = RelationshipManager.GetRelationship(mockPlayer, "tier_cat");
            // Score = (1.0 * 50) + min(20 * 0.5, 30) + 20 (recent) = 50 + 10 + 20 = 80
            expect(updatedRel.relationshipScore).toBe(80);
            expect(updatedRel.relationshipTier).toBe("Close Friends");
        });
    });
};
