import { InteractionHandler } from "../interaction-handler";
import { CatManager } from "../cat-manager";
import { RelationshipManager } from "../relationship-manager";

export = () => {
    describe("InteractionHandler", () => {
        const mockPlayer = { UserId: 1, Name: "Player1" } as Player;
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
    });
};
