import { KnitServer as Knit } from "@rbxts/knit";

// Import services to ensure they are registered
import "./cat-service";

Knit.Start()
    .andThen(() => {
        print("Knit started on server");
    })
    .catch((err) => {
        warn("Knit failed to start on server:", err);
    });
