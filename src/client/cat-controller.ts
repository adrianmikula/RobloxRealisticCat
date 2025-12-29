import { KnitClient as Knit } from "@rbxts/knit";
import { Players, RunService } from "@rbxts/services";
import { CatData } from "shared/cat-types";
import { CatRenderer } from "./cat-renderer";

// Define the service type for Knit
import type { CatService } from "server/cat-service";

export const CatController = Knit.CreateController({
    Name: "CatController",

    KnitInit() {
        print("CatController initialized");
    },

    KnitStart() {
        const CatService = Knit.GetService("CatService");

        // Listen for cat state updates from the server
        CatService.CatStateUpdate.Connect((catId: string, updateType: string, catData?: CatData) => {
            this.HandleCatStateUpdate(catId, updateType, catData);
        });

        // Initialize existing cats
        task.spawn(() => {
            task.wait(1);
            const allCats = CatService.GetAllCats();
            for (const [catId, catData] of pairs(allCats)) {
                this.HandleCatStateUpdate(catId as string, "created", catData as CatData);
            }
        });

        // Performance culling loop
        task.spawn(() => {
            while (true) {
                const player = Players.LocalPlayer;
                const character = player.Character;
                if (character && character.PrimaryPart) {
                    CatRenderer.CullDistantCats(character.PrimaryPart.Position);
                }
                task.wait(5);
            }
        });

        print("CatController started");
    },

    HandleCatStateUpdate(catId: string, updateType: string, catData?: CatData) {
        if (updateType === "created" && catData) {
            CatRenderer.CreateCatVisual(catId, catData);
        } else if (updateType === "removed") {
            CatRenderer.RemoveCatVisual(catId);
        } else if (updateType === "updated" && catData) {
            CatRenderer.UpdateCatVisual(catId, catData);
        }
    },
});
