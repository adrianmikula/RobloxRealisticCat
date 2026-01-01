import { KnitServer as Knit, RemoteSignal } from "@rbxts/knit";
import { Players, RunService } from "@rbxts/services";
import { CatData, MoodType } from "shared/cat-types";
import { CatManager } from "./cat-manager";
import { CatAI } from "./cat-ai";
import { PlayerManager } from "./player-manager";
import { InteractionHandler } from "./interaction-handler";
import { RelationshipManager } from "./relationship-manager";

declare const script: Instance;

const CatServiceObj = Knit.CreateService({
    Name: "CatService",

    Client: {
        CatStateUpdate: new RemoteSignal<(catId: string, updateType: string, catData: CatData | undefined) => void>(),
        CatActionUpdate: new RemoteSignal<(catId: string, actionType: string, actionData: unknown) => void>(),
        PlayerInteraction: new RemoteSignal<(catId: string, interactionType: string, result: unknown) => void>(),

        SpawnCat(player: Player, profileType: string, position?: Vector3): string {
            return (CatServiceObj as unknown as { SpawnCat: (self: unknown, p: Player, t: string, v?: Vector3) => string }).SpawnCat(
                CatServiceObj,
                player,
                profileType,
                position,
            );
        },

        InteractWithCat(player: Player, catId: string, interactionType: string, interactionData?: unknown): unknown {
            return InteractionHandler.HandleInteraction(player, catId, interactionType, interactionData);
        },

        UseTool(player: Player, toolType: string, position?: Vector3): void {
            const char = player.Character;
            const hrp = char?.FindFirstChild("HumanoidRootPart") as Part;
            const toolPosition = position || hrp?.Position;
            PlayerManager.RecordToolUsage(player, toolType, toolPosition);
        },

        EquipTool(player: Player, toolType: string): { success: boolean; message: string } {
            return PlayerManager.EquipTool(player, toolType);
        },

        UnequipTool(player: Player): void {
            PlayerManager.UnequipTool(player);
        },

        GetAllCats(player: Player): Record<string, Partial<CatData>> {
            const safeCats: Record<string, Partial<CatData>> = {};
            CatManager.GetAllCats().forEach((catData, catId) => {
                safeCats[catId] = {
                    currentState: catData.currentState,
                    moodState: catData.moodState,
                    behaviorState: catData.behaviorState,
                    profile: {
                        personality: catData.profile.personality,
                        breed: catData.profile.breed,
                        // ... other profile fields if needed
                    } as any,
                };
            });
            return safeCats;
        },
    },

    KnitInit() {
        print("CatService initialized");
    },

    KnitStart() {
        print("CatService started");

        // Start AI update loop
        task.spawn(() => {
            this.StartAIUpdates();
        });

        // Handle player connections
        Players.PlayerAdded.Connect((player) => {
            PlayerManager.HandlePlayerAdded(player);
        });

        Players.PlayerRemoving.Connect((player) => {
            PlayerManager.HandlePlayerRemoved(player);
        });

        // Handle players already in the game
        for (const player of Players.GetPlayers()) {
            PlayerManager.HandlePlayerAdded(player);
        }
    },

    StartAIUpdates() {
        let lastSyncTime = 0;
        const syncInterval = 0.2; // Sync every 0.2s to balance performance and smoothness

        while (true) {
            const dt = task.wait(0.1);
            const currentTime = os.clock();
            const shouldSync = currentTime - lastSyncTime >= syncInterval;

            CatManager.GetAllCats().forEach((catData, catId) => {
                CatAI.UpdateCat(catId, catData);

                if (shouldSync) {
                    this.Client.CatStateUpdate.FireAll(catId, "updated", catData);
                }
            });

            if (shouldSync) {
                lastSyncTime = currentTime;
            }
        }
    },

    CreateCat(catId: string, profileType: string, position?: Vector3) {
        const catData = CatManager.CreateCat(catId, profileType);
        CatAI.InitializeCat(catId, catData);

        // Set position if provided, otherwise use random spawn position
        if (position) {
            catData.currentState.position = position;
        } else {
            catData.currentState.position = this.GenerateRandomSpawnPosition();
        }

        // Ground the position
        catData.currentState.position = CatAI.FindGroundPosition(catData.currentState.position);
        
        // If grounding failed (no ground found), add a small Y offset as fallback
        if (catData.currentState.position.Y === 0) {
            catData.currentState.position = catData.currentState.position.add(new Vector3(0, 2.5, 0));
        }

        this.Client.CatStateUpdate.FireAll(catId, "created", catData);
        return catData;
    },

    SpawnCat(player: Player, profileType: string, position?: Vector3) {
        const catId = `player_cat_${player.UserId}_${os.time()}`;
        // CreateCat now handles random positioning if no position is provided
        const catData = this.CreateCat(catId, profileType || "Friendly", position);

        return catId;
    },

    /**
     * Generate a random spawn position for cats.
     * Tries to avoid spawning too close to existing cats or players.
     */
    GenerateRandomSpawnPosition(): Vector3 {
        const Workspace = game.GetService("Workspace");
        const Players = game.GetService("Players");
        
        // Default spawn area (can be configured)
        const spawnRadius = 50; // Spawn within 50 studs of origin
        const minDistanceFromOthers = 5; // Minimum distance from other cats/players
        
        let attempts = 0;
        const maxAttempts = 20;
        
        while (attempts < maxAttempts) {
            // Generate random position in a circle
            const angle = math.random() * math.pi * 2;
            const distance = math.random() * spawnRadius;
            const x = math.cos(angle) * distance;
            const z = math.sin(angle) * distance;
            const y = 0; // Will be adjusted by FindGroundPosition
            
            const candidatePos = new Vector3(x, y, z);
            
            // Check if position is too close to existing cats
            let tooClose = false;
            CatManager.GetAllCats().forEach((catData) => {
                const dist = catData.currentState.position.sub(candidatePos).Magnitude;
                if (dist < minDistanceFromOthers) {
                    tooClose = true;
                }
            });
            
            // Check if position is too close to players
            if (!tooClose) {
                for (const player of Players.GetPlayers()) {
                    const char = player.Character;
                    const hrp = char?.FindFirstChild("HumanoidRootPart") as Part;
                    if (hrp) {
                        const dist = hrp.Position.sub(candidatePos).Magnitude;
                        if (dist < minDistanceFromOthers) {
                            tooClose = true;
                            break;
                        }
                    }
                }
            }
            
            if (!tooClose) {
                return candidatePos;
            }
            
            attempts++;
        }
        
        // If we couldn't find a good position after max attempts, use a random position anyway
        // (FindGroundPosition will handle placing it on the ground)
        const angle = math.random() * math.pi * 2;
        const distance = math.random() * spawnRadius;
        const x = math.cos(angle) * distance;
        const z = math.sin(angle) * distance;
        return new Vector3(x, 0, z);
    },

    RemoveCat(catId: string) {
        CatAI.CleanupCat(catId);
        CatManager.RemoveCat(catId);
        this.Client.CatStateUpdate.FireAll(catId, "removed", undefined);
    },
});

export const CatService = CatServiceObj;
export type CatServiceType = typeof CatServiceObj;
