import { KnitClient as Knit } from "@rbxts/knit";
import { Players, ReplicatedStorage } from "@rbxts/services";
import { CAT_BREEDS } from "shared/cat-profile-data";
import { CatServiceType } from "server/cat-service";

const UIController = Knit.CreateController({
    Name: "UIController",

    KnitStart() {
        print("UIController started");
        this.SetupSpawningUI();
    },

    SetupSpawningUI() {
        const player = Players.LocalPlayer;
        const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

        const screenGui = new Instance("ScreenGui");
        screenGui.Name = "CatSpawningUI";
        screenGui.ResetOnSpawn = false;

        const mainFrame = new Instance("Frame");
        mainFrame.Name = "MainFrame";
        mainFrame.Size = new UDim2(0, 200, 0, 400);
        mainFrame.Position = new UDim2(0, 20, 0.5, -200);
        mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
        mainFrame.BorderSizePixel = 0;
        mainFrame.Parent = screenGui;

        const corner = new Instance("UICorner");
        corner.CornerRadius = new UDim(0, 10);
        corner.Parent = mainFrame;

        const title = new Instance("TextLabel");
        title.Name = "Title";
        title.Size = new UDim2(1, 0, 0, 40);
        title.BackgroundTransparency = 1;
        title.Text = "Spawn a Cat";
        title.TextColor3 = Color3.fromRGB(255, 255, 255);
        title.TextSize = 20;
        title.Font = Enum.Font.GothamBold;
        title.Parent = mainFrame;

        const scrollingFrame = new Instance("ScrollingFrame");
        scrollingFrame.Name = "CatList";
        scrollingFrame.Size = new UDim2(1, -20, 1, -60);
        scrollingFrame.Position = new UDim2(0, 10, 0, 50);
        scrollingFrame.BackgroundTransparency = 1;
        scrollingFrame.CanvasSize = new UDim2(0, 0, 0, 0);
        scrollingFrame.ScrollBarThickness = 4;
        scrollingFrame.Parent = mainFrame;

        const listLayout = new Instance("UIListLayout");
        listLayout.Padding = new UDim(0, 5);
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
        listLayout.Parent = scrollingFrame;

        const padding = new Instance("UIPadding");
        padding.PaddingTop = new UDim(0, 5);
        padding.PaddingBottom = new UDim(0, 5);
        padding.Parent = scrollingFrame;

        const CatService = Knit.GetService("CatService") as unknown as {
            SpawnCat(profileType: string, position?: Vector3): Promise<string>;
        };

        for (const breed of CAT_BREEDS) {
            const button = new Instance("TextButton");
            button.Name = breed.name;
            button.Size = new UDim2(1, -10, 0, 40);
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60);
            button.Text = breed.name;
            button.TextColor3 = Color3.fromRGB(220, 220, 220);
            button.TextSize = 16;
            button.Font = Enum.Font.Gotham;
            button.Parent = scrollingFrame;

            const btnCorner = new Instance("UICorner");
            btnCorner.CornerRadius = new UDim(0, 6);
            btnCorner.Parent = button;

            button.MouseButton1Click.Connect(() => {
                print(`Spawning ${breed.name} (${breed.profileType})`);
                // Spawn near player
                const character = player.Character;
                if (character) {
                    const hrp = character.FindFirstChild("HumanoidRootPart") as Part;
                    if (hrp) {
                        const spawnPos = hrp.Position.add(new Vector3(math.random(-5, 5), 0, math.random(-5, 5)));
                        CatService.SpawnCat(breed.profileType, spawnPos);
                    }
                }
            });

            // Hover effects
            button.MouseEnter.Connect(() => {
                button.BackgroundColor3 = Color3.fromRGB(80, 80, 80);
            });
            button.MouseLeave.Connect(() => {
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60);
            });
        }

        // Auto-size canvas
        scrollingFrame.CanvasSize = new UDim2(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20);
        listLayout.GetPropertyChangedSignal("AbsoluteContentSize").Connect(() => {
            scrollingFrame.CanvasSize = new UDim2(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20);
        });

        screenGui.Parent = playerGui;
    },
});

export = UIController;
