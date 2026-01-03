import { KnitClient as Knit } from "@rbxts/knit";
import { CollectionService, Players, Workspace } from "@rbxts/services";
import { CatData } from "shared/cat-types";

type ToolType = "none" | "basicFood" | "premiumFood" | "basicToys" | "premiumToys" | "groomingTools" | "medicalItems";

interface CatPrompts {
    pet: ProximityPrompt;
    hold: ProximityPrompt;
    feed: ProximityPrompt;
    pickUp: ProximityPrompt; // Separate prompt for pick up/put down with Q key
}

const InteractionController = Knit.CreateController({
    Name: "InteractionController",

    catPrompts: new Map<string, CatPrompts>(),
    currentTool: "none" as ToolType,

    KnitStart() {
        const CatService = Knit.GetService("CatService") as unknown as {
            InteractWithCat(catId: string, interactionType: string): Promise<{ success: boolean; message: string }>;
            CatStateUpdate: { Connect(callback: (catId: string, updateType: string, catData?: CatData) => void): void };
            GetCurrentTool(): string;
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
        
        // Setup tool equip/unequip detection
        this.SetupToolEquipDetection();
        
        // Periodically update prompts based on current tool
        this.SetupPromptUpdateLoop();
        
        // Setup global Q key handler for putting down held cats
        this.SetupGlobalPickUpHandler();

        print("InteractionController started");
    },

    SetupGlobalPickUpHandler() {
        const UserInputService = game.GetService("UserInputService");
        const Players = game.GetService("Players");
        const localPlayer = Players.LocalPlayer;

        UserInputService.InputBegan.Connect((input, gameProcessed) => {
            if (gameProcessed) return;

            // Check for Q key press
            if (input.KeyCode === Enum.KeyCode.Q) {
                // Check if player is holding any cat
                const CatService = Knit.GetService("CatService") as unknown as {
                    GetAllCats(player: Player): Record<string, Partial<CatData>>;
                    InteractWithCat(catId: string, interactionType: string): Promise<{ success: boolean; message: string }>;
                };
                
                const allCats = CatService.GetAllCats(localPlayer);
                
                // Find any cat being held by this player
                for (const [catId, catData] of pairs(allCats)) {
                    if (catData && catData.behaviorState && catData.behaviorState.heldByPlayerId === localPlayer.UserId) {
                        // Player is holding this cat, put it down
                        CatService.InteractWithCat(catId as string, "Hold");
                        break; // Only put down one cat at a time
                    }
                }
            }
        });
    },

    SetupPromptUpdateLoop() {
        const CatService = Knit.GetService("CatService") as unknown as {
            GetCurrentTool(): string;
        };
        
        task.spawn(() => {
            while (true) {
                const newTool = CatService.GetCurrentTool();
                if (newTool !== this.currentTool) {
                    this.currentTool = newTool as ToolType;
                    // Update all prompts for all cats
                    this.UpdateAllPrompts();
                }
                task.wait(0.5); // Check every 0.5 seconds
            }
        });
    },

    UpdateAllPrompts() {
        const CatService = Knit.GetService("CatService") as unknown as {
            GetAllCats(player: Player): Record<string, Partial<CatData>>;
        };
        const localPlayer = Players.LocalPlayer;
        const allCats = CatService.GetAllCats(localPlayer);
        
        for (const [catId, catData] of pairs(allCats)) {
            if (catData && catData.behaviorState && catData.moodState && catData.currentState) {
                const fullCatData = catData as unknown as CatData;
                this.UpdatePrompts(catId as string, fullCatData);
            }
        }
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
                    // Determine tool type from tag (preferred) or name (fallback)
                    const toolType = this.GetToolTypeFromTool(tool);
                    if (toolType) {
                        CatService.UseTool(toolType, hrp.Position);
                    }
                }
            }
        });
    },

    SetupToolEquipDetection() {
        const Players = game.GetService("Players");
        const localPlayer = Players.LocalPlayer;
        let lastToolCheck: Tool | undefined = undefined;
        let characterConnection: RBXScriptConnection | undefined = undefined;

        const CatService = Knit.GetService("CatService") as unknown as {
            EquipTool(toolType: string): { success: boolean; message: string };
            UnequipTool(): void;
        };

        // Check for tools and sync to server
        const checkForTools = () => {
            const character = localPlayer.Character;
            if (!character) {
                // Character is gone, unequip tool
                if (lastToolCheck) {
                    CatService.UnequipTool();
                    lastToolCheck = undefined;
                }
                return;
            }

            const tool = character.FindFirstChildOfClass("Tool");
            
            // Tool was equipped
            if (tool && tool !== lastToolCheck) {
                // Use pcall to handle any errors from tool scripts
                const [success, toolType] = pcall(() => {
                    return this.GetToolTypeFromTool(tool);
                });
                
                if (success && toolType) {
                    CatService.EquipTool(toolType);
                    lastToolCheck = tool;
                    this.currentTool = toolType as ToolType;
                    
                    // Immediately update all prompts
                    this.UpdateAllPrompts();
                    
                    // Also listen for when this tool is removed
                    tool.AncestryChanged.Connect(() => {
                        if (!tool.Parent || tool.Parent !== character) {
                            // Tool was removed
                            CatService.UnequipTool();
                            lastToolCheck = undefined;
                            this.currentTool = "none";
                            // Immediately update all prompts
                            this.UpdateAllPrompts();
                        }
                    });
                } else if (!success) {
                    // Tool has an error, but we can still try to use it if it has a recognizable name
                    warn(`Tool "${tool.Name}" has script errors, but attempting to detect type anyway`);
                    const fallbackType = this.GetToolTypeFromName(tool.Name);
                    if (fallbackType) {
                        CatService.EquipTool(fallbackType);
                        lastToolCheck = tool;
                    }
                }
            }
            // Tool was unequipped
            else if (!tool && lastToolCheck) {
                CatService.UnequipTool();
                lastToolCheck = undefined;
                this.currentTool = "none";
                // Immediately update all prompts
                this.UpdateAllPrompts();
            }
        };

        // Check when character is added
        localPlayer.CharacterAdded.Connect((character) => {
            task.wait(0.5); // Wait for character to fully load
            checkForTools();
            
            // Listen for child added/removed to detect tools immediately
            if (characterConnection) {
                characterConnection.Disconnect();
            }
            
            characterConnection = character.ChildAdded.Connect((child) => {
                if (child.IsA("Tool")) {
                    task.wait(0.1); // Small delay to ensure tool is fully loaded
                    checkForTools();
                }
            });
            
            character.ChildRemoved.Connect((child) => {
                if (child.IsA("Tool") && child === lastToolCheck) {
                    CatService.UnequipTool();
                    lastToolCheck = undefined;
                }
            });
        });

        // Check periodically for tool changes (fallback)
        task.spawn(() => {
            while (true) {
                checkForTools();
                task.wait(1); // Check every second as fallback
            }
        });
        
        // Initial check
        if (localPlayer.Character) {
            task.wait(0.5);
            checkForTools();
        }
    },

    /**
     * Get tool type from a Tool instance.
     * First checks CollectionService tags, then falls back to name-based detection.
     * 
     * Supported tags:
     * - "CatTool_BasicFood", "CatTool_PremiumFood" → food tools
     * - "CatTool_BasicToy", "CatTool_PremiumToy" → toy tools
     * - "CatTool_GroomingTool" → grooming tools
     * - "CatTool_MedicalItem" → medical items
     * 
     * Or name the tool: "BasicToy", "PremiumToy", "BasicFood", "PremiumFood", "GroomingTool", "MedicalItem"
     */
    GetToolTypeFromTool(tool: Tool): string | undefined {
        // First, check for CollectionService tags (preferred method)
        const tags = CollectionService.GetTags(tool);
        for (const tag of tags) {
            // Check for CatTool_* tags (tags start with "CatTool_")
            const findResult = tag.find("CatTool_");
            if (findResult[0] === 1) {
                // Extract the tool type name after "CatTool_" (9 characters)
                const toolTypeName = tag.sub(9);
                const toolType = this.MapToolTypeNameToId(toolTypeName);
                if (toolType) {
                    return toolType;
                }
            }
        }

        // Fallback to name-based detection
        return this.GetToolTypeFromName(tool.Name);
    },

    /**
     * Map tool type names (from tags or names) to internal tool type IDs
     */
    MapToolTypeNameToId(toolTypeName: string): string | undefined {
        const mapping: Record<string, string> = {
            "BasicToy": "basicToys",
            "PremiumToy": "premiumToys",
            "BasicFood": "basicFood",
            "PremiumFood": "premiumFood",
            "GroomingTool": "groomingTools",
            "MedicalItem": "medicalItems",
        };

        // Try exact match first
        if (mapping[toolTypeName]) {
            return mapping[toolTypeName];
        }

        // Try case-insensitive match
        const lowerName = toolTypeName.lower();
        for (const [key, value] of pairs(mapping)) {
            if (lowerName === key.lower()) {
                return value;
            }
        }

        return undefined;
    },

    /**
     * Get tool type from tool name (legacy method, maintained for backward compatibility)
     */
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

        // Get current tool to set initial prompt text
        const CatService = Knit.GetService("CatService") as unknown as {
            GetCurrentTool(): string;
        };
        const currentTool = CatService.GetCurrentTool();
        this.currentTool = currentTool as ToolType;
        
        // Determine initial prompt text based on tool
        const isFoodTool = currentTool === "basicFood" || currentTool === "premiumFood";
        const isToyTool = currentTool === "basicToys" || currentTool === "premiumToys";
        const feedPromptText = isFoodTool ? "Feed" : (isToyTool ? "Play" : "Feed");
        const feedInteractionType = isToyTool ? "Play" : "Feed";

        const prompts: CatPrompts = {
            pet: this.CreatePrompt(attachPart, "Pet", "Pet Cat", 6, () => {
                this.HandleInteraction(catId, "Pet");
            }),
            hold: this.CreatePrompt(attachPart, "Hold", "Pick Up", 6, () => {
                this.HandleInteraction(catId, "Hold");
            }),
            feed: this.CreatePrompt(attachPart, "Feed", feedPromptText, 6, () => {
                // Dynamically determine interaction type based on current tool
                const CatServiceForTool = Knit.GetService("CatService") as unknown as {
                    GetCurrentTool(): string;
                };
                const tool = CatServiceForTool.GetCurrentTool();
                const interactionType = (tool === "basicToys" || tool === "premiumToys") ? "Play" : "Feed";
                this.HandleInteraction(catId, interactionType);
            }),
            pickUp: this.CreatePickUpPrompt(attachPart, catId, catData),
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

        // Get current tool to determine prompt text
        const CatService = Knit.GetService("CatService") as unknown as {
            GetCurrentTool(): string;
        };
        const currentTool = CatService.GetCurrentTool();
        this.currentTool = currentTool as ToolType;
        
        // Determine tool type from tool ID
        // Food tools: basicFood, premiumFood
        // Toy tools: basicToys, premiumToys
        const isFoodTool = currentTool === "basicFood" || currentTool === "premiumFood";
        const isToyTool = currentTool === "basicToys" || currentTool === "premiumToys";

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

        // Update Pick Up prompt (Q key) based on state
        if (isHeldByPlayer) {
            prompts.pickUp.ActionText = "Put Down";
            prompts.pickUp.Enabled = true;
            prompts.pickUp.MaxActivationDistance = 10; // Can put down from further away
        } else if (isHeldByOther) {
            prompts.pickUp.Enabled = false; // Can't pick up if someone else is holding
        } else {
            prompts.pickUp.ActionText = "Pick Up";
            prompts.pickUp.Enabled = true;
            prompts.pickUp.MaxActivationDistance = 6;
        }

        // Disable other prompts if cat is being held
        if (isHeldByPlayer || isHeldByOther) {
            prompts.pet.Enabled = false;
            prompts.feed.Enabled = false;
        } else {
            prompts.pet.Enabled = true;
            
            // Update feed/play prompt based on current tool
            // Note: We can't easily disconnect/reconnect ProximityPrompt.Triggered,
            // so we'll use a wrapper function that checks the current tool at trigger time
            // The prompt text is updated above, and HandleInteraction will use the correct type
            if (isFoodTool) {
                // Player is holding food - show "Feed" prompt
                prompts.feed.ActionText = "Feed";
                prompts.feed.Enabled = true;
            } else if (isToyTool) {
                // Player is holding toy - show "Play" prompt
                prompts.feed.ActionText = "Play";
                prompts.feed.Enabled = true;
            } else {
                // No tool - show default "Feed" prompt
                prompts.feed.ActionText = "Feed";
                prompts.feed.Enabled = true;
            }
        }
    },

    CleanupInteractions(catId: string) {
        const prompts = this.catPrompts.get(catId);
        if (prompts) {
            prompts.pet.Destroy();
            prompts.hold.Destroy();
            prompts.feed.Destroy();
            prompts.pickUp.Destroy();
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

    CreatePickUpPrompt(parent: BasePart, catId: string, catData: CatData): ProximityPrompt {
        const localPlayer = Players.LocalPlayer;
        const isHeldByPlayer = catData.behaviorState.heldByPlayerId === localPlayer.UserId;
        const actionText = isHeldByPlayer ? "Put Down" : "Pick Up";
        
        const prompt = new Instance("ProximityPrompt");
        prompt.Name = "PickUp";
        prompt.ActionText = actionText;
        prompt.ObjectText = "Cat";
        prompt.MaxActivationDistance = isHeldByPlayer ? 10 : 6; // Can put down from further away
        prompt.HoldDuration = 0.3; // Faster for pick up/put down
        prompt.KeyboardKeyCode = Enum.KeyCode.Q; // Q key for pick up/put down
        prompt.GamepadKeyCode = Enum.KeyCode.ButtonY;
        prompt.ClickablePrompt = true;
        prompt.AutoLocalize = false;
        prompt.Parent = parent;

        prompt.Triggered.Connect(() => {
            this.HandleInteraction(catId, "Hold");
        });

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

        // Map interaction types to simple words/emojis
        const feedbackText = this.GetInteractionFeedbackText(interactionType, success);

        const feedbackGui = new Instance("BillboardGui");
        feedbackGui.Name = "InteractionFeedback";
        feedbackGui.Size = new UDim2(0, 150, 0, 60);
        feedbackGui.StudsOffset = new Vector3(0, 4, 0); // Higher up to not overlap with status
        feedbackGui.AlwaysOnTop = true;
        feedbackGui.Adornee = head;
        feedbackGui.Parent = head;

        const frame = new Instance("Frame");
        frame.Size = new UDim2(1, 0, 1, 0);
        frame.BackgroundTransparency = 1; // No background for cleaner look
        frame.BorderSizePixel = 0;
        frame.Parent = feedbackGui;

        const label = new Instance("TextLabel");
        label.Size = new UDim2(1, 0, 1, 0);
        label.BackgroundTransparency = 1;
        label.Text = feedbackText;
        label.TextColor3 = success ? Color3.fromRGB(255, 200, 255) : Color3.fromRGB(255, 150, 150);
        label.TextScaled = true;
        label.Font = Enum.Font.GothamBold;
        label.TextStrokeTransparency = 0.3;
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0);
        label.Parent = frame;

        // Animate and destroy
        task.spawn(() => {
            for (let i = 0; i < 40; i++) {
                feedbackGui.StudsOffset = new Vector3(0, 4 + i * 0.15, 0);
                label.TextTransparency = i * 0.025;
                label.TextStrokeTransparency = 0.3 + i * 0.0175;
                task.wait(0.03);
            }
            feedbackGui.Destroy();
        });
    },

    /**
     * Get simple feedback text/emoji for interaction types.
     */
    GetInteractionFeedbackText(interactionType: string, success: boolean): string {
        if (!success) {
            return "❌";
        }

        const feedbackMap: Record<string, string> = {
            "Pet": "❤️", // Heart emoji for petting
            "Feed": "🍽️", // Food emoji
            "Play": "🎾", // Toy emoji
            "Groom": "✨", // Sparkle emoji
            "Hold": "🤗", // Hug emoji
            "Heal": "💊", // Medicine emoji
        };

        // Try to get emoji first, fallback to word
        const emoji = feedbackMap[interactionType];
        if (emoji) {
            return emoji;
        }

        // Fallback to simple word
        const wordMap: Record<string, string> = {
            "Pet": "purr",
            "Feed": "eat",
            "Play": "play",
            "Groom": "groom",
            "Hold": "hold",
            "Heal": "heal",
        };

        return wordMap[interactionType] || interactionType.lower();
    },
});

export = InteractionController;
