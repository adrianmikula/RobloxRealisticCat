import { KnitClient as Knit } from "@rbxts/knit";
import { Players, RunService } from "@rbxts/services";
import { CatData } from "shared/cat-types";
import { CatRenderer } from "./cat-renderer";
import { LoadingScreen } from "./loading-screen";

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

        // Initialize existing cats asynchronously with progress updates
        task.spawn(() => {
            task.wait(0.5); // Small delay to ensure service is ready
            
            LoadingScreen.SetProgress(0.6, "Loading cats...");
            
            const allCats = CatService.GetAllCats();
            const catArray: Array<[string, CatData]> = [];
            
            // Convert map to array for progress tracking
            for (const [catId, catData] of pairs(allCats)) {
                catArray.push([catId as string, catData as CatData]);
            }
            
            // Load cats with progress updates
            const totalCats = catArray.size();
            if (totalCats > 0) {
                for (let i = 0; i < totalCats; i++) {
                    const [catId, catData] = catArray[i];
                    this.HandleCatStateUpdate(catId, "created", catData);
                    
                    // Update progress (0.6 to 0.8 for cat loading)
                    const catProgress = 0.6 + (0.2 * (i + 1) / totalCats);
                    LoadingScreen.SetProgress(catProgress, `Loading cat ${i + 1}/${totalCats}...`);
                    
                    // Small delay between cats to prevent blocking
                    task.wait(0.05);
                }
            } else {
                LoadingScreen.SetProgress(0.8, "No cats to load");
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
