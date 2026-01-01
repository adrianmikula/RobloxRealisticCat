import { KnitClient as Knit } from "@rbxts/knit";
import { Players, Workspace } from "@rbxts/services";
import { CatData } from "shared/cat-types";

interface CatPrompts {
    pet: ProximityPrompt;
    hold: ProximityPrompt;
    feed: ProximityPrompt;
}

const InteractionController = Knit.CreateController({
    Name: "InteractionController",

    catPrompts: new Map<string, CatPrompts>(),

    KnitStart() {
        const CatService = Knit.GetService("CatService") as unknown as {
            InteractWithCat(catId: string, interactionType: string): Promise<{ success: boolean; message: string }>;
            CatStateUpdate: { Connect(callback: (catId: string, updateType: string, catData?: CatData) => void): void };
        };

        CatService.CatStateUpdate.Connect((catId, updateType, catData) => {
            if (updateType === "created" && catData) {
                // Wait a bit for visuals to be created by CatController
                task.delay(0.5, () => {
                    this.SetupInteractions(catId, catData);
                });
            } else if (updateType === "updated" && catData) {
                // Update prompts based on new cat state
                this.UpdatePrompts(catId, catData);
            } else if (updateType === "removed") {
                // Clean up prompts when cat is removed
                this.CleanupInteractions(catId);
            }
        });

        // Also handle existing cats on startup
        task.spawn(() => {
            task.wait(1);
            const localPlayer = Players.LocalPlayer;
            const CatServiceWithGetAll = CatService as unknown as {
                GetAllCats(player: Player): Record<string, Partial<CatData>>;
            };
            const allCats = CatServiceWithGetAll.GetAllCats(localPlayer);
            for (const [catId, catData] of pairs(allCats)) {
                // Only setup if we have enough data
                if (catData && catData.behaviorState && catData.moodState && catData.currentState) {
                    // Create a minimal CatData object for setup
                    const fullCatData = catData as unknown as CatData;
                    this.SetupInteractions(catId as string, fullCatData);
                }
            }
        });

        // Setup tool usage detection
        this.SetupToolUsageDetection();

        print("InteractionController started");
    },

    SetupToolUsageDetection() {
        const UserInputService = game.GetService("UserInputService");
        const Players = game.GetService("Players");
        const localPlayer = Players.LocalPlayer;

        // Detect when player clicks (uses tool)
        UserInputService.InputBegan.Connect((input, gameProcessed) => {
            if (gameProcessed) return;

            // Check for mouse click or touch
            if (input.UserInputType === Enum.UserInputType.MouseButton1 || 
                input.UserInputType === Enum.UserInputType.Touch) {
                
                const character = localPlayer.Character;
                if (!character) return;

                const hrp = character.FindFirstChild("HumanoidRootPart") as BasePart;
                if (!hrp) return;

                // Check if player has a tool equipped
                const CatService = Knit.GetService("CatService") as unknown as {
                    UseTool(toolType: string, position?: Vector3): void;
                    GetAllCats(player: Player): Record<string, Partial<CatData>>;
                };

                // Get current tool from server (we'll need to track this client-side too)
                // For now, we'll check if there's a tool in the character
                const tool = character.FindFirstChildOfClass("Tool");
                if (tool) {
                    // Determine tool type from tool name or use a mapping
                    const toolType = this.GetToolTypeFromName(tool.Name);
                    if (toolType) {
                        CatService.UseTool(toolType, hrp.Position);
                    }
                }
            }
        });
    },

    GetToolTypeFromName(toolName: string): string | undefined {
        // Map tool names to tool types
        const toolMapping: Record<string, string> = {
            "BasicToy": "basicToys",
            "PremiumToy": "premiumToys",
            "BasicFood": "basicFood",
            "PremiumFood": "premiumFood",
            "GroomingTool": "groomingTools",
            "MedicalItem": "medicalItems",
        };

        // Try exact match first
        if (toolMapping[toolName]) {
            return toolMapping[toolName];
        }

        // Try case-insensitive partial match
        const lowerName = toolName.lower();
        for (const [key, value] of pairs(toolMapping)) {
            if (lowerName.find(key.lower())[0] !== undefined) {
                return value;
            }
        }

        return undefined;
    },

    SetupInteractions(catId: string, catData: CatData) {
        const visual = Workspace.FindFirstChild(`Cat_${catId}`) as Model;
        if (!visual) {
            // Retry after a short delay if visual isn't ready yet
            task.delay(0.5, () => {
                this.SetupInteractions(catId, catData);
            });
            return;
        }

        // Find the best part to attach prompts to (prefer head, fallback to primary part)
        const head = visual.FindFirstChild("Head") as BasePart;
        const attachPart = head || visual.PrimaryPart || visual.FindFirstChildOfClass("BasePart");
        if (!attachPart) {
            warn(`Could not find attachment part for cat ${catId}`);
            return;
        }

        // Clean up any existing prompts first
        this.CleanupInteractions(catId);

        const prompts: CatPrompts = {
            pet: this.CreatePrompt(attachPart, "Pet", "Pet Cat", 6, () => {
                this.HandleInteraction(catId, "Pet");
            }),
            hold: this.CreatePrompt(attachPart, "Hold", "Pick Up", 6, () => {
                this.HandleInteraction(catId, "Hold");
            }),
            feed: this.CreatePrompt(attachPart, "Feed", "Feed Cat", 6, () => {
                this.HandleInteraction(catId, "Feed");
            }),
        };

        this.catPrompts.set(catId, prompts);

        // Update prompts based on initial state
        this.UpdatePrompts(catId, catData);
    },

    UpdatePrompts(catId: string, catData: CatData) {
        const prompts = this.catPrompts.get(catId);
        if (!prompts) return;

        const localPlayer = Players.LocalPlayer;
        const isHeldByPlayer = catData.behaviorState.heldByPlayerId === localPlayer.UserId;
        const isHeldByOther = catData.behaviorState.heldByPlayerId !== undefined && !isHeldByPlayer;

        // Update Hold prompt based on state
        if (isHeldByPlayer) {
            prompts.hold.ActionText = "Release";
            prompts.hold.Enabled = true;
        } else if (isHeldByOther) {
            prompts.hold.Enabled = false; // Can't pick up if someone else is holding
        } else {
            prompts.hold.ActionText = "Pick Up";
            prompts.hold.Enabled = true;
        }

        // Disable other prompts if cat is being held
        if (isHeldByPlayer || isHeldByOther) {
            prompts.pet.Enabled = false;
            prompts.feed.Enabled = false;
        } else {
            prompts.pet.Enabled = true;
            prompts.feed.Enabled = true;
        }
    },

    CleanupInteractions(catId: string) {
        const prompts = this.catPrompts.get(catId);
        if (prompts) {
            prompts.pet.Destroy();
            prompts.hold.Destroy();
            prompts.feed.Destroy();
            this.catPrompts.delete(catId);
        }
    },

    CreatePrompt(parent: BasePart, name: string, actionText: string, distance: number, callback: () => void): ProximityPrompt {
        const prompt = new Instance("ProximityPrompt");
        prompt.Name = name;
        prompt.ActionText = actionText;
        prompt.ObjectText = "Cat";
        prompt.MaxActivationDistance = distance;
        prompt.HoldDuration = 0.5;
        prompt.KeyboardKeyCode = Enum.KeyCode.E;
        prompt.GamepadKeyCode = Enum.KeyCode.ButtonX;
        prompt.ClickablePrompt = true;
        prompt.AutoLocalize = false;
        prompt.Parent = parent;

        prompt.Triggered.Connect(callback);

        return prompt;
    },

    async HandleInteraction(catId: string, interactionType: string) {
        const CatService = Knit.GetService("CatService") as unknown as {
            InteractWithCat(catId: string, interactionType: string): Promise<{ success: boolean; message: string }>;
        };

        try {
            const result = await CatService.InteractWithCat(catId, interactionType);
            
            // Show feedback to player
            if (result.success) {
                this.ShowInteractionFeedback(catId, interactionType, true, result.message);
            } else {
                this.ShowInteractionFeedback(catId, interactionType, false, result.message);
            }
        } catch (error) {
            warn(`Interaction failed: ${error}`);
            this.ShowInteractionFeedback(catId, interactionType, false, "Interaction failed");
        }
    },

    ShowInteractionFeedback(catId: string, interactionType: string, success: boolean, message: string) {
        const visual = Workspace.FindFirstChild(`Cat_${catId}`) as Model;
        if (!visual) return;

        // Create a temporary billboard to show feedback
        const head = visual.FindFirstChild("Head") as BasePart || visual.PrimaryPart;
        if (!head) return;

        const feedbackGui = new Instance("BillboardGui");
        feedbackGui.Name = "InteractionFeedback";
        feedbackGui.Size = new UDim2(0, 200, 0, 50);
        feedbackGui.StudsOffset = new Vector3(0, 2, 0);
        feedbackGui.AlwaysOnTop = true;
        feedbackGui.Adornee = head;
        feedbackGui.Parent = head;

        const frame = new Instance("Frame");
        frame.Size = new UDim2(1, 0, 1, 0);
        frame.BackgroundColor3 = success ? Color3.fromRGB(76, 175, 80) : Color3.fromRGB(244, 67, 54);
        frame.BackgroundTransparency = 0.3;
        frame.BorderSizePixel = 0;
        frame.Parent = feedbackGui;

        const label = new Instance("TextLabel");
        label.Size = new UDim2(1, 0, 1, 0);
        label.BackgroundTransparency = 1;
        label.Text = message;
        label.TextColor3 = Color3.fromRGB(255, 255, 255);
        label.TextScaled = true;
        label.Font = Enum.Font.GothamBold;
        label.Parent = frame;

        // Animate and destroy
        task.spawn(() => {
            for (let i = 0; i < 30; i++) {
                feedbackGui.StudsOffset = new Vector3(0, 2 + i * 0.1, 0);
                frame.BackgroundTransparency = 0.3 + i * 0.02;
                label.TextTransparency = i * 0.03;
                task.wait(0.03);
            }
            feedbackGui.Destroy();
        });
    },
});

export = InteractionController;
