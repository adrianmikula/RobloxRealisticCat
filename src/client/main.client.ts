import { KnitClient as Knit } from "@rbxts/knit";

// Import controllers to ensure they are registered
import "./cat-controller";

Knit.Start()
    .andThen(() => {
        print("Knit started on client");
    })
    .catch((err) => {
        warn("Knit failed to start on client:", err);
    });
