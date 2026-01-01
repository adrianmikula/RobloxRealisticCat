import { KnitClient as Knit } from "@rbxts/knit";
import { LoadingScreen } from "./loading-screen";

// Show loading screen immediately (before any blocking operations)
LoadingScreen.Initialize();
LoadingScreen.SetProgress(0.05, "Loading game scripts...");

// Import controllers to ensure they are registered
// These imports are fast and don't block significantly
import "./cat-controller";
import "./ui-controller";
import "./interaction-controller";

// Start initialization asynchronously to prevent blocking
task.spawn(() => {
    LoadingScreen.SetProgress(0.1, "Initializing game systems...");
    
    // Small delay to allow UI to render
    task.wait(0.1);
    
    LoadingScreen.SetProgress(0.2, "Starting Knit framework...");
    
    Knit.Start()
        .andThen(() => {
            print("Knit started on client");
            LoadingScreen.SetProgress(0.4, "Connecting to server...");
            
            // Wait a moment for services to be ready
            task.wait(0.3);
            LoadingScreen.SetProgress(0.6, "Loading game content...");
            
            // Give time for initial cat loading (CatController will update progress)
            task.wait(0.5);
            LoadingScreen.SetProgress(0.8, "Finalizing...");
            
            // Small delay to ensure everything is ready
            task.wait(0.3);
            LoadingScreen.SetProgress(0.95, "Almost ready...");
            
            // Final check - wait a bit more for any async operations
            task.wait(0.5);
            LoadingScreen.SetProgress(1, "Ready!");
            
            // Hide loading screen after a brief moment
            task.wait(0.2);
            LoadingScreen.Hide();
        })
        .catch((err) => {
            warn("Knit failed to start on client:", err);
            LoadingScreen.SetProgress(1, "Error loading game");
            // Hide loading screen even on error after a delay
            task.wait(2);
            LoadingScreen.Hide();
        });
});
