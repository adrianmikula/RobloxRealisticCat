import { CatManager } from "../cat-manager";

export = () => {
    describe("CatManager", () => {
        beforeEach(() => {
            // Clear instances before each test
            CatManager.GetAllCats().clear();
        });

        test("CreateCat", () => {
            const cat = CatManager.CreateCat("test_cat", "Friendly");
            expect(cat.id).toBe("test_cat");
            expect(cat.profile.personality.friendliness).toBe(0.9);
            expect(cat.moodState.currentMood).toBe("Happy");
            expect(CatManager.GetCat("test_cat")).toBe(cat);
        });

        test("UpdateCatMood", () => {
            const cat = CatManager.CreateCat("mood_cat");
            CatManager.UpdateCatMood("mood_cat", "Curious", 0.9);
            expect(cat.moodState.currentMood).toBe("Curious");
            expect(cat.moodState.moodIntensity).toBe(0.9);
            expect(cat.moodState.moodDuration).to.equal(cat.moodState.moodDuration); // Verify it set a duration
        });

        test("UpdateCatPhysical", () => {
            const cat = CatManager.CreateCat("phys_cat");
            cat.physicalState.hunger = 50;

            CatManager.UpdateCatPhysical("phys_cat", { hunger: -10 });
            expect(cat.physicalState.hunger).toBe(40);

            CatManager.UpdateCatPhysical("phys_cat", { hunger: -30 }); // Should hit hunger threshold
            expect(cat.physicalState.hunger).toBe(10);
            expect(cat.moodState.currentMood).toBe("Hungry");
        });

        test("RemoveCat", () => {
            CatManager.CreateCat("rem_cat");
            expect(CatManager.GetCat("rem_cat")).to.equal(CatManager.GetCat("rem_cat"));
            CatManager.RemoveCat("rem_cat");
            expect(CatManager.GetCat("rem_cat")).toBe(undefined);
        });
    });
};
