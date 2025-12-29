import { PlayerData, PlayerSettings, ToolConfig } from "shared/cat-types";

export class PlayerManager {
    private static activePlayers = new Map<number, PlayerData>();
    private static playerUnlockedTools = new Map<number, Map<string, boolean>>();
    private static playerSettings = new Map<number, PlayerSettings>();

    public static readonly AVAILABLE_TOOLS: Record<string, ToolConfig> = {
        basicFood: {
            name: "Basic Food",
            type: "food",
            interactionType: "Feed",
            effectiveness: 1.0,
            cooldown: 5,
        },
        basicToys: {
            name: "Basic Toy",
            type: "toy",
            interactionType: "Play",
            effectiveness: 1.0,
            cooldown: 3,
        },
        premiumFood: {
            name: "Premium Food",
            type: "food",
            interactionType: "Feed",
            effectiveness: 1.5,
            cooldown: 5,
        },
        premiumToys: {
            name: "Premium Toy",
            type: "toy",
            interactionType: "Play",
            effectiveness: 1.5,
            cooldown: 3,
        },
        groomingTools: {
            name: "Grooming Tool",
            type: "grooming",
            interactionType: "Groom",
            effectiveness: 1.2,
            cooldown: 10,
        },
        medicalItems: {
            name: "Medical Item",
            type: "medical",
            interactionType: "Heal",
            effectiveness: 2.0,
            cooldown: 30,
        },
    };

    public static HandlePlayerAdded(player: Player) {
        this.activePlayers.set(player.UserId, {
            player,
            currentTool: "none",
            lastInteractionTime: 0,
            nearbyCats: [],
            toolCooldowns: new Map<string, number>(),
        });

        this.InitializePlayerTools(player);
        this.InitializePlayerSettings(player);
    }

    public static HandlePlayerRemoved(player: Player) {
        this.activePlayers.delete(player.UserId);
        this.playerUnlockedTools.delete(player.UserId);
        this.playerSettings.delete(player.UserId);
    }

    private static InitializePlayerSettings(player: Player) {
        this.playerSettings.set(player.UserId, {
            selectedTool: "none",
            autoInteract: false,
            catNotifications: true,
            visualPreferences: {
                showMoodIndicators: true,
                showRelationshipBars: true,
                animationQuality: "high",
            },
        });
    }

    private static InitializePlayerTools(player: Player) {
        const unlocked = new Map<string, boolean>();
        unlocked.set("basicFood", true);
        unlocked.set("basicToys", true);
        this.playerUnlockedTools.set(player.UserId, unlocked);
    }

    public static EquipTool(player: Player, toolType: string) {
        if (!this.HasTool(player, toolType)) {
            return { success: false, message: "Tool not unlocked" };
        }

        const playerData = this.activePlayers.get(player.UserId);
        if (!playerData) return { success: false, message: "Player not found" };

        playerData.currentTool = toolType;
        playerData.lastToolChange = os.time();

        return { success: true, message: "Tool equipped" };
    }

    public static UnequipTool(player: Player) {
        const playerData = this.activePlayers.get(player.UserId);
        if (playerData) {
            playerData.currentTool = "none";
        }
    }

    public static GetCurrentTool(player: Player): string | undefined {
        return this.activePlayers.get(player.UserId)?.currentTool;
    }

    public static HasTool(player: Player, toolType: string): boolean {
        return this.playerUnlockedTools.get(player.UserId)?.has(toolType) || false;
    }

    public static UnlockTool(player: Player, toolType: string): boolean {
        const unlocked = this.playerUnlockedTools.get(player.UserId);
        if (!unlocked) return false;

        unlocked.set(toolType, true);
        return true;
    }

    public static GetPlayerSettings(player: Player): PlayerSettings | undefined {
        return this.playerSettings.get(player.UserId);
    }

    public static UpdatePlayerSettings(player: Player, newSettings: Partial<PlayerSettings>) {
        const current = this.playerSettings.get(player.UserId);
        if (!current) return;

        // Simple merge for top-level properties
        if (newSettings.selectedTool !== undefined) current.selectedTool = newSettings.selectedTool;
        if (newSettings.autoInteract !== undefined) current.autoInteract = newSettings.autoInteract;
        if (newSettings.catNotifications !== undefined) current.catNotifications = newSettings.catNotifications;

        if (newSettings.visualPreferences) {
            const vis = current.visualPreferences;
            const newVal = newSettings.visualPreferences;
            if (newVal.showMoodIndicators !== undefined) vis.showMoodIndicators = newVal.showMoodIndicators;
            if (newVal.showRelationshipBars !== undefined) vis.showRelationshipBars = newVal.showRelationshipBars;
            if (newVal.animationQuality !== undefined) vis.animationQuality = newVal.animationQuality;
        }
    }

    public static UpdateNearbyCats(player: Player, catIds: string[]) {
        const playerData = this.activePlayers.get(player.UserId);
        if (!playerData) return;

        playerData.nearbyCats = catIds;
    }

    public static GetNearbyCats(player: Player): string[] {
        return this.activePlayers.get(player.UserId)?.nearbyCats || [];
    }

    public static CanInteract(player: Player, interactionType: string): boolean {
        const playerData = this.activePlayers.get(player.UserId);
        if (!playerData) return false;

        const cooldownEnd = playerData.toolCooldowns.get(interactionType);
        return cooldownEnd === undefined || os.time() >= cooldownEnd;
    }

    public static SetInteractionCooldown(player: Player, interactionType: string, duration: number) {
        const playerData = this.activePlayers.get(player.UserId);
        if (playerData) {
            playerData.toolCooldowns.set(interactionType, os.time() + duration);
        }
    }

    public static GetAllActivePlayers(): Player[] {
        const players: Player[] = [];
        this.activePlayers.forEach((data) => players.push(data.player));
        return players;
    }
}
