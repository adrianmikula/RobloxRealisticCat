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
            return ((CatServiceObj as unknown) as Record<string, (p: Player, t: string, v?: Vector3) => string>).SpawnCat(
                player,
                profileType,
                position,
            );
        },

        InteractWithCat(player: Player, catId: string, interactionType: string, interactionData?: unknown): unknown {
            return InteractionHandler.HandleInteraction(player, catId, interactionType, interactionData);
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

    CreateCat(catId: string, profileType: string) {
        const catData = CatManager.CreateCat(catId, profileType);
        CatAI.InitializeCat(catId, catData);

        this.Client.CatStateUpdate.FireAll(catId, "created", catData);
        return catData;
    },

    SpawnCat(player: Player, profileType: string, position?: Vector3) {
        const catId = `player_cat_${player.UserId}_${os.time()}`;
        const catData = this.CreateCat(catId, profileType || "Friendly");

        if (position) {
            catData.currentState.position = position;
        }

        return catId;
    },

    RemoveCat(catId: string) {
        CatAI.CleanupCat(catId);
        CatManager.RemoveCat(catId);
        this.Client.CatStateUpdate.FireAll(catId, "removed", undefined);
    },
});

export const CatService = CatServiceObj;
export type CatServiceType = typeof CatServiceObj;
