import { KnitServer as Knit } from "@rbxts/knit";

// Import services to ensure they are registered
import "./cat-service";

import { PhysicsService } from "@rbxts/services";

// Start Knit asynchronously to prevent blocking
task.spawn(() => {
    Knit.Start()
        .andThen(() => {
            print("Knit started on server");
            
            // Initialize collision groups asynchronously
            task.spawn(() => {
                pcall(() => PhysicsService.CreateCollisionGroup("Cats"));
            });
        })
        .catch((err) => {
            warn("Knit failed to start on server:", err);
        });
});
PhysicsService.CollisionGroupSetCollidable("Cats", "Cats", false);