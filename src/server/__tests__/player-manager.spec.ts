import { PlayerManager } from "../player-manager";

export = () => {
    describe("PlayerManager", () => {
        const mockPlayer = { UserId: 1001, Name: "Player1001" } as Player;

        beforeEach(() => {
            // Clear state for each test if possible
            // For now just add the player
            PlayerManager.HandlePlayerAdded(mockPlayer);
        });

        test("Player initialization", () => {
            expect(PlayerManager.GetCurrentTool(mockPlayer)).toBe("none");
            expect(PlayerManager.HasTool(mockPlayer, "basicFood")).toBe(true);
            expect(PlayerManager.HasTool(mockPlayer, "premiumFood")).toBe(false);
        });

        test("Equip/Unequip tools", () => {
            const equipResult = PlayerManager.EquipTool(mockPlayer, "basicFood");
            expect(equipResult.success).toBe(true);
            expect(PlayerManager.GetCurrentTool(mockPlayer)).toBe("basicFood");

            PlayerManager.UnequipTool(mockPlayer);
            expect(PlayerManager.GetCurrentTool(mockPlayer)).toBe("none");
        });

        test("Unlock tools", () => {
            expect(PlayerManager.HasTool(mockPlayer, "premiumFood")).toBe(false);
            PlayerManager.UnlockTool(mockPlayer, "premiumFood");
            expect(PlayerManager.HasTool(mockPlayer, "premiumFood")).toBe(true);
        });

        test("Settings updates", () => {
            const settings = PlayerManager.GetPlayerSettings(mockPlayer)!;
            expect(settings.autoInteract).toBe(false);

            PlayerManager.UpdatePlayerSettings(mockPlayer, { autoInteract: true });
            expect(PlayerManager.GetPlayerSettings(mockPlayer)!.autoInteract).toBe(true);
        });

        test("Cooldowns", () => {
            expect(PlayerManager.CanInteract(mockPlayer, "Feed")).toBe(true);
            PlayerManager.SetInteractionCooldown(mockPlayer, "Feed", 10);
            expect(PlayerManager.CanInteract(mockPlayer, "Feed")).toBe(false);
        });
    });
};
