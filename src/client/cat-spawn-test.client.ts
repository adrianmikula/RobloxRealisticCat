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

UserInputService.InputBegan.Connect((input, gameProcessed) => {
    if (gameProcessed) return;

    if (input.KeyCode === Enum.KeyCode.One) {
        spawnTestCat("Friendly");
    } else if (input.KeyCode === Enum.KeyCode.Two) {
        spawnTestCat("Playful");
    } else if (input.KeyCode === Enum.KeyCode.Three) {
        spawnTestCat("Independent");
    } else if (input.KeyCode === Enum.KeyCode.Four) {
        spawnMultipleCats(3, "Friendly");
    }
});

print("🐱 [TS] Cat Spawning Test Script Loaded!");
print("Keyboard Controls:");
print("   [1] - Spawn Friendly Cat");
print("   [2] - Spawn Playful Cat");
print("   [3] - Spawn Independent Cat");
print("   [4] - Spawn 3 Friendly Cats");
