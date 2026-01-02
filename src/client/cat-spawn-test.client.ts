import { KnitClient as Knit } from "@rbxts/knit";
import { Players, UserInputService } from "@rbxts/services";

const player = Players.LocalPlayer;

function spawnTestCat(profileType: string) {
    const character = player.Character;
    let spawnPosition: Vector3;

    if (character && character.PrimaryPart) {
        spawnPosition = character.PrimaryPart.Position.add(new Vector3(5, 0, 5));
    } else {
        spawnPosition = new Vector3(0, 5, 0);
    }

    print(`🔄 [TS] Attempting to spawn cat with profile: ${profileType}`);

    const CatService = Knit.GetService("CatService");
    CatService.SpawnCat(profileType, spawnPosition);
}

function spawnMultipleCats(count: number, profileType: string) {
    print(`🔄 [TS] Spawning ${count} cats with profile: ${profileType}`);

    for (let i = 0; i < count; i++) {
        task.wait(0.5);
        spawnTestCat(profileType);
    }
}

// Hotkey-based cat spawning has been removed to allow keyboard numbers 1-4 to be used for tool activation
// Use the UI controller or chat commands (/spawncat) to spawn cats instead

print("🐱 [TS] Cat Spawning Test Script Loaded!");
print("Note: Hotkey spawning (1-4 keys) has been disabled. Use UI or /spawncat command instead.");
print("Keyboard Controls:");
print("   [1] - Spawn Friendly Cat");
print("   [2] - Spawn Playful Cat");
print("   [3] - Spawn Independent Cat");
print("   [4] - Spawn 3 Friendly Cats");
