import { CatService } from "../cat-service";
import { CatManager } from "../cat-manager";
import { PlayerManager } from "../player-manager";

export = () => {
    describe("CatService", () => {
        const playerName = "TestPlayer";
        let mockPlayer: Player;

        beforeEach(() => {
            CatManager.GetAllCats().clear();
            // Use any cast to mock Player since new Instance("Player") is prohibited by rbxtsc
            mockPlayer = {
                Name: playerName,
                UserId: 123456,
                ClassName: "Player"
            } as any;

            PlayerManager.HandlePlayerAdded(mockPlayer);
        });

        test("SpawnCat creates cat data and returns ID", () => {
            const returnedCatId = CatService.SpawnCat(mockPlayer, "Friendly");

            expect(returnedCatId !== undefined).toBe(true);
            expect(returnedCatId.find("player_cat_123456")[0] !== undefined).toBe(true);

            const catData = CatManager.GetCat(returnedCatId);
            expect(catData !== undefined).toBe(true);
            if (catData && catData.profile) {
                expect(catData.profile.personality.friendliness > 0.4).toBe(true);
            }
        });

        test("SpawnCat with position sets correct initial position", () => {
            const targetPos = new Vector3(10, 20, 30);
            const returnedCatId = CatService.SpawnCat(mockPlayer, "Playful", targetPos);

            const catData = CatManager.GetCat(returnedCatId);
            if (catData) {
                expect(catData.currentState.position.X).toBe(targetPos.X);
                expect(catData.currentState.position.Y).toBe(targetPos.Y);
                expect(catData.currentState.position.Z).toBe(targetPos.Z);
            }
        });

        test("RemoveCat cleans up data", () => {
            const catId = CatService.SpawnCat(mockPlayer, "Independent");
            expect(CatManager.GetCat(catId) !== undefined).toBe(true);

            CatService.RemoveCat(catId);
            expect(CatManager.GetCat(catId) === undefined).toBe(true);
        });

        test("GetAllCats returns map of active cats", () => {
            CatService.SpawnCat(mockPlayer, "Friendly");

            const otherPlayer = {
                Name: "OtherPlayer",
                UserId: 999999,
                ClassName: "Player"
            } as any;
            CatService.SpawnCat(otherPlayer, "Playful");

            const allCats = CatService.Client.GetAllCats(mockPlayer);
            expect(allCats.size()).toBe(2);
        });
    });
};
