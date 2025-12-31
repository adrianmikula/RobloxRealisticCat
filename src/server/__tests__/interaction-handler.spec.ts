import { InteractionHandler } from "../interaction-handler";
import { CatManager } from "../cat-manager";
import { RelationshipManager } from "../relationship-manager";

export = () => {
    describe("InteractionHandler", () => {
        const mockPlayer = { UserId: 1, Name: "Player1" } as Player;
        const otherPlayer = { UserId: 2, Name: "Player2" } as Player;
        const catId = "interact_cat";

        beforeEach(() => {
            CatManager.GetAllCats().clear();
            CatManager.CreateCat(catId);
        });

        test("Successful Pet interaction", () => {
            const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
            // Verification that it ran and updated history
            const rel = RelationshipManager.GetRelationship(mockPlayer, catId);
            expect(rel.interactionHistory.size()).toBe(1);
            expect(result.interactionType).to.equal("Pet");
        });

        test("Cooldown check", () => {
            InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
            const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
            expect(result.success).toBe(false);
            expect(result.message).toBe("Interaction on cooldown");
        });

        test("Cat not found", () => {
            const result = InteractionHandler.HandleInteraction(mockPlayer, "non_existent", "Pet");
            expect(result.success).toBe(false);
            expect(result.message).toBe("Cat not found");
        });

        test("Feed interaction reduces hunger", () => {
            const catData = CatManager.GetCat(catId);
            if (catData) {
                const initialHunger = catData.physicalState.hunger;
                const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Feed");
                
                // Feed has high success chance, so it should succeed
                expect(result.success).toBe(true);
                expect(result.interactionType).to.equal("Feed");
                
                const updatedCatData = CatManager.GetCat(catId);
                if (updatedCatData) {
                    // Hunger should be reduced (by 30 based on INTERACTION_TYPES)
                    expect(updatedCatData.physicalState.hunger).toBeLessThan(initialHunger);
                }
            }
        });

        test("Hold interaction sets heldByPlayerId", () => {
            const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Hold");
            
            const catData = CatManager.GetCat(catId);
            if (catData && result.success) {
                expect(catData.behaviorState.heldByPlayerId).toBe(mockPlayer.UserId);
                expect(catData.behaviorState.isMoving).toBe(false);
            }
        });

        test("Release cat when already held by same player", () => {
            // First hold the cat
            InteractionHandler.HandleInteraction(mockPlayer, catId, "Hold");
            
            // Then release it
            const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Hold");
            
            expect(result.success).toBe(true);
            expect(result.message).toBe("Released cat");
            
            const catData = CatManager.GetCat(catId);
            if (catData) {
                expect(catData.behaviorState.heldByPlayerId).toBeUndefined();
            }
        });

        test("Cannot hold cat already held by another player", () => {
            // First player holds the cat
            InteractionHandler.HandleInteraction(mockPlayer, catId, "Hold");
            
            // Second player tries to hold
            const result = InteractionHandler.HandleInteraction(otherPlayer, catId, "Hold");
            
            expect(result.success).toBe(false);
            expect(result.message).toBe("Cat is already being held");
            
            const catData = CatManager.GetCat(catId);
            if (catData) {
                expect(catData.behaviorState.heldByPlayerId).toBe(mockPlayer.UserId);
            }
        });

        test("Invalid interaction type", () => {
            const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "InvalidAction");
            expect(result.success).toBe(false);
            expect(result.message).toBe("Invalid interaction type");
        });

        test("Successful interaction updates relationship", () => {
            const initialRel = RelationshipManager.GetRelationship(mockPlayer, catId);
            const initialTrust = initialRel.trustLevel;
            
            const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
            
            if (result.success) {
                const updatedRel = RelationshipManager.GetRelationship(mockPlayer, catId);
                // Relationship should increase (Pet gives +0.1)
                expect(updatedRel.trustLevel).toBeGreaterThan(initialTrust);
            }
        });

        test("Failed interaction decreases relationship", () => {
            // Set up a cat with low friendliness to increase failure chance
            const catData = CatManager.GetCat(catId);
            if (catData) {
                catData.profile.personality.friendliness = 0.1;
                catData.moodState.currentMood = "Annoyed";
                
                const initialRel = RelationshipManager.GetRelationship(mockPlayer, catId);
                const initialTrust = initialRel.trustLevel;
                
                // Try multiple times to get a failure (low friendliness + annoyed mood)
                let result;
                for (let i = 0; i < 10; i++) {
                    result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
                    if (!result.success) break;
                    task.wait(2.1); // Wait for cooldown
                }
                
                if (result && !result.success) {
                    const updatedRel = RelationshipManager.GetRelationship(mockPlayer, catId);
                    // Failed interaction should decrease relationship by 0.05
                    expect(updatedRel.trustLevel).toBeLessThan(initialTrust);
                }
            }
        });

        test("Successful interaction updates mood", () => {
            const catData = CatManager.GetCat(catId);
            if (catData) {
                catData.moodState.currentMood = "Hungry";
                
                const result = InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
                
                if (result.success) {
                    const updatedCatData = CatManager.GetCat(catId);
                    if (updatedCatData) {
                        // Pet interaction should change mood to Happy
                        expect(updatedCatData.moodState.currentMood).toBe("Happy");
                    }
                }
            }
        });

        test("Feed interaction has high success chance", () => {
            // Feed has 0.95 base success chance, so it should almost always succeed
            let successCount = 0;
            const attempts = 10;
            
            for (let i = 0; i < attempts; i++) {
                CatManager.GetAllCats().clear();
                CatManager.CreateCat(`feed_test_${i}`);
                const result = InteractionHandler.HandleInteraction(mockPlayer, `feed_test_${i}`, "Feed");
                if (result.success) successCount++;
                task.wait(2.1); // Wait for cooldown
            }
            
            // Feed should succeed most of the time (at least 8/10 with 0.95 chance)
            expect(successCount).toBeGreaterThanOrEqual(8);
        });

        test("Hold interaction respects personality", () => {
            const catData = CatManager.GetCat(catId);
            if (catData) {
                // Very shy cat should have lower success chance for holding
                catData.profile.personality.shyness = 0.9;
                catData.profile.personality.friendliness = 0.1;
                
                let successCount = 0;
                const attempts = 10;
                
                for (let i = 0; i < attempts; i++) {
                    CatManager.GetAllCats().clear();
                    CatManager.CreateCat(`hold_test_${i}`);
                    const testCat = CatManager.GetCat(`hold_test_${i}`);
                    if (testCat) {
                        testCat.profile.personality.shyness = 0.9;
                        testCat.profile.personality.friendliness = 0.1;
                    }
                    const result = InteractionHandler.HandleInteraction(mockPlayer, `hold_test_${i}`, "Hold");
                    if (result.success) successCount++;
                    task.wait(2.1);
                }
                
                // Shy cats should have lower success rate for holding
                expect(successCount).toBeLessThan(attempts / 2);
            }
        });

        test("Interaction history is recorded", () => {
            InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
            InteractionHandler.HandleInteraction(mockPlayer, catId, "Feed");
            
            task.wait(2.1); // Wait for cooldown
            InteractionHandler.HandleInteraction(mockPlayer, catId, "Hold");
            
            const rel = RelationshipManager.GetRelationship(mockPlayer, catId);
            // Should have at least 3 interactions recorded
            expect(rel.interactionHistory.size()).toBeGreaterThanOrEqual(3);
        });

        test("Cooldown is per interaction type", () => {
            // Pet and Feed should have separate cooldowns
            InteractionHandler.HandleInteraction(mockPlayer, catId, "Pet");
            const feedResult = InteractionHandler.HandleInteraction(mockPlayer, catId, "Feed");
            
            // Feed should not be on cooldown even though Pet was just used
            expect(feedResult.success !== false || feedResult.message !== "Interaction on cooldown").toBe(true);
        });
    });
};
