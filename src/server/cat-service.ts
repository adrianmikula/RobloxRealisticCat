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

        GetAllCats(player: Player): Map<string, Partial<CatData>> {
            const safeCats = new Map<string, Partial<CatData>>();
            CatManager.GetAllCats().forEach((catData, catId) => {
                safeCats.set(catId, {
                    currentState: catData.currentState,
                    moodState: catData.moodState,
                    behaviorState: catData.behaviorState,
                    profile: {
                        personality: catData.profile.personality,
                        breed: catData.profile.breed,
                        // ... other profile fields if needed
                    } as any,
                });
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
        while (true) {
            task.wait(0.1);
            CatManager.GetAllCats().forEach((catData, catId) => {
                CatAI.UpdateCat(catId, catData);
            });
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
