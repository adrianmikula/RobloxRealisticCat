import { KnitClient as Knit } from "@rbxts/knit";
import { CollectionService, Players, Workspace } from "@rbxts/services";
import { CatData } from "shared/cat-types";
import type { CatServiceType } from "server/cat-service";

const InteractionController = Knit.CreateController({
    Name: "InteractionController",

    KnitStart() {
        const CatService = Knit.GetService("CatService") as unknown as {
            InteractWithCat(catId: string, interactionType: string): Promise<void>;
            CatStateUpdate: { Connect(callback: (catId: string, updateType: string, catData?: CatData) => void): void };
        };

        CatService.CatStateUpdate.Connect((catId, updateType, catData) => {
            if (updateType === "created" && catData) {
                // Wait a bit for visuals to be created by CatController
                task.delay(0.5, () => this.SetupInteractions(catId));
            }
        });

        print("InteractionController started");
    },

    SetupInteractions(catId: string) {
        const visual = Workspace.FindFirstChild(`Cat_${catId}`) as Model;
        if (!visual) return;

        const root = visual.PrimaryPart || visual.FindFirstChildOfClass("BasePart");
        if (!root) return;

        // Create Pet Prompt
        this.CreatePrompt(root, "Pet", "Pet Cat", 5, () => {
            const CatService = Knit.GetService("CatService") as unknown as {
                InteractWithCat(catId: string, interactionType: string): Promise<void>;
            };
            CatService.InteractWithCat(catId, "Pet");
        });

        // Create Hold Prompt
        this.CreatePrompt(root, "Hold", "Pick Up / Release", 5, () => {
            const CatService = Knit.GetService("CatService") as unknown as {
                InteractWithCat(catId: string, interactionType: string): Promise<void>;
            };
            CatService.InteractWithCat(catId, "Hold");
        });

        // Create Feed Prompt
        this.CreatePrompt(root, "Feed", "Feed Cat", 5, () => {
            const CatService = Knit.GetService("CatService") as unknown as {
                InteractWithCat(catId: string, interactionType: string): Promise<void>;
            };
            CatService.InteractWithCat(catId, "Feed");
        });
    },

    CreatePrompt(parent: Instance, name: string, actionText: string, distance: number, callback: () => void) {
        const prompt = new Instance("ProximityPrompt");
        prompt.Name = name;
        prompt.ActionText = actionText;
        prompt.ObjectText = "Cat";
        prompt.MaxActivationDistance = distance;
        prompt.HoldDuration = 0.5;
        prompt.Parent = parent;

        prompt.Triggered.Connect(callback);
    },
});

export = InteractionController;
