import { Workspace, Players } from "@rbxts/services";
import { CatData, MoodState } from "shared/cat-types";
import { AnimationHandler } from "./animation-handler";
import { PhysicsService } from "@rbxts/services";
import { MODEL_MAPPING, DEFAULT_MODEL } from "shared/config/model-config";

export class CatRenderer {
    private static catVisuals = new Map<string, Model>();
    private static moodIndicators = new Map<string, BillboardGui>();
    private static previousActions = new Map<string, string>();

    /**
     * Get the model name for a given cat profile type.
     * Falls back to default if profile type not found or model doesn't exist.
     */
    private static GetModelNameForProfile(profileType: string, modelsFolder: Instance): string {
        // Try to get the mapped model name
        const mappedModelName = MODEL_MAPPING[profileType];
        
        if (mappedModelName) {
            // Check if the model exists
            const model = modelsFolder.FindFirstChild(mappedModelName) as Model;
            if (model) {
                return mappedModelName;
            } else {
                warn(`Model "${mappedModelName}" for profile type "${profileType}" not found, using default`);
            }
        }
        
        // Fall back to default model
        const defaultModel = modelsFolder.FindFirstChild(DEFAULT_MODEL) as Model;
        if (defaultModel) {
            return DEFAULT_MODEL;
        }
        
        // If default doesn't exist, try any model in the folder
        const anyModel = modelsFolder.FindFirstChildOfClass("Model");
        if (anyModel) {
            warn(`Default model "${DEFAULT_MODEL}" not found, using "${anyModel.Name}"`);
            return anyModel.Name;
        }
        
        return DEFAULT_MODEL; // Return name even if not found, will error later
    }

    public static CreateCatVisual(catId: string, catData: CatData): Model | undefined {
        const modelsFolder = Workspace.FindFirstChild("Models");
        if (!modelsFolder) {
            warn("Models folder not found in Workspace");
            return;
        }

        // Determine which model to use based on profile type
        // The profile type is stored in the breed field or can be inferred from personality
        // For now, we'll use a simple mapping based on the profile's breed or personality
        const profileType = this.DetermineProfileType(catData);
        const modelName = this.GetModelNameForProfile(profileType, modelsFolder);
        
        const catModel = modelsFolder.FindFirstChild(modelName) as Model | undefined;
        if (!catModel) {
            warn(`Cat model "${modelName}" not found in Workspace.Models for profile type "${profileType}"`);
            return;
        }

        const catVisual = catModel.Clone();
        catVisual.Name = `Cat_${catId}`;

        const humanoid = catVisual.FindFirstChildOfClass("Humanoid");
        if (humanoid) {
            humanoid.WalkSpeed = catData.profile.physical.movementSpeed;
            humanoid.JumpPower = catData.profile.physical.jumpHeight;
            humanoid.AutoRotate = true;
            humanoid.AutoJumpEnabled = false;
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None;
        }

        if (catVisual.PrimaryPart) {
            catVisual.SetPrimaryPartCFrame(new CFrame(catData.currentState.position));
        } else {
            const root = catVisual.FindFirstChild("Root") as BasePart || catVisual.FindFirstChild("Torso") as BasePart;
            if (root) {
                root.CFrame = new CFrame(catData.currentState.position);
            }
        }

        for (const d of catVisual.GetDescendants()) {
            if (d.IsA("BasePart")) {
                d.Anchored = false;
                d.CanCollide = true;
                d.Massless = false;
                // PhysicsService.SetPartCollisionGroup(d, "Cats");
            }
        }

        catVisual.Parent = Workspace;
        this.catVisuals.set(catId, catVisual);

        this.CreateMoodIndicator(catId, catData);

        return catVisual;
    }

    public static RemoveCatVisual(catId: string) {
        const visual = this.catVisuals.get(catId);
        if (visual) {
            AnimationHandler.StopAnimation(catId);
            
            // Stop purring sound if playing
            this.StopPurringSound(catId);
            
            visual.Destroy();
            this.catVisuals.delete(catId);
        }

        const indicator = this.moodIndicators.get(catId);
        if (indicator) {
            indicator.Destroy();
            this.moodIndicators.delete(catId);
        }

        // Clean up previous action tracking
        this.previousActions.delete(catId);
    }

    public static UpdateCatVisual(catId: string, catData: CatData) {
        const visual = this.catVisuals.get(catId);
        if (!visual) return;

        const humanoid = visual.FindFirstChildOfClass("Humanoid");
        if (humanoid) {
            humanoid.WalkSpeed = catData.profile.physical.movementSpeed;
            humanoid.JumpPower = catData.profile.physical.jumpHeight;

            const action = catData.behaviorState.currentAction;
            const targetPos = catData.behaviorState.targetPosition;
            const currentPos = visual.PrimaryPart?.Position || new Vector3();

            // Stop purring if action changed from Purr to something else
            const previousAction = this.previousActions.get(catId);
            if (previousAction === "Purr" && action !== "Purr") {
                this.StopPurringSound(catId);
            }
            this.previousActions.set(catId, action);

            if (catData.behaviorState.isMoving && targetPos) {
                if (targetPos.sub(currentPos).Magnitude > 0.5) {
                    humanoid.MoveTo(targetPos);
                    AnimationHandler.PlayAnimation(catId, "Walk", humanoid);
                } else {
                    humanoid.MoveTo(currentPos);
                    AnimationHandler.PlayAnimation(catId, "Idle", humanoid);
                }
            } else {
                humanoid.MoveTo(currentPos);
                AnimationHandler.PlayAnimation(catId, action || "Idle", humanoid);

                // Special handling for Purr: look at the player who petted
                if (action === "Purr") {
                    const actionData = catData.behaviorState.actionData as { reactingToPlayerId?: number } | undefined;
                    if (actionData?.reactingToPlayerId) {
                        const player = Players.GetPlayerByUserId(actionData.reactingToPlayerId);
                        const char = player?.Character;
                        const playerHRP = char?.FindFirstChild("HumanoidRootPart") as Part;
                        if (playerHRP) {
                            const playerPos = playerHRP.Position;
                            const lookVector = playerPos.sub(currentPos).Unit;
                            const flatLookVector = new Vector3(lookVector.X, 0, lookVector.Z).Unit;
                            if (flatLookVector.Magnitude > 0) {
                                visual.SetPrimaryPartCFrame(CFrame.lookAt(currentPos, currentPos.add(flatLookVector)));
                            }
                            // Play purring sound effect
                            this.PlayPurringSound(catId, visual);
                        }
                    } else if (targetPos) {
                        // Fallback to targetPos if no player data
                        const lookVector = targetPos.sub(currentPos).Unit;
                        const flatLookVector = new Vector3(lookVector.X, 0, lookVector.Z).Unit;
                        if (flatLookVector.Magnitude > 0) {
                            visual.SetPrimaryPartCFrame(CFrame.lookAt(currentPos, currentPos.add(flatLookVector)));
                        }
                        this.PlayPurringSound(catId, visual);
                    }
                } else {
                    // Rotation for LookAt/Follow/Meow/RollOver
                    if ((action === "LookAt" || action === "Follow" || action === "Meow" || action === "RollOver") && targetPos) {
                        const lookVector = targetPos.sub(currentPos).Unit;
                        const flatLookVector = new Vector3(lookVector.X, 0, lookVector.Z).Unit;
                        if (flatLookVector.Magnitude > 0) {
                            visual.SetPrimaryPartCFrame(CFrame.lookAt(currentPos, currentPos.add(flatLookVector)));
                        }
                    }
                }
            }

            // Special Meow visual
            if (action === "Meow") {
                this.ShowTemporaryMoodText(catId, "Meow!", Color3.fromRGB(255, 255, 255));
            }

            // Special Purr visual
            if (action === "Purr") {
                this.ShowTemporaryMoodText(catId, "Purr...", Color3.fromRGB(255, 200, 255));
            }
        }

        this.UpdateMoodIndicator(catId, catData.moodState);
        this.UpdateHoldingState(catId, visual, catData);
    }

    private static UpdateHoldingState(catId: string, visual: Model, catData: CatData) {
        const heldById = catData.behaviorState.heldByPlayerId;
        const currentWeld = visual.FindFirstChild("HoldingWeld") as Weld;

        if (heldById !== undefined) {
            const player = Players.GetPlayerByUserId(heldById);
            const character = player?.Character;
            const targetPart = character?.FindFirstChild("RightHand") as BasePart
                || character?.FindFirstChild("Right Arm") as BasePart
                || character?.FindFirstChild("HumanoidRootPart") as BasePart;

            if (targetPart && !currentWeld) {
                const weld = new Instance("Weld");
                weld.Name = "HoldingWeld";
                weld.Part0 = targetPart;
                weld.Part1 = visual.PrimaryPart || visual.FindFirstChildOfClass("BasePart");
                weld.C0 = new CFrame(new Vector3(0, -0.5, -1)); // Position offset
                weld.Parent = visual;

                const humanoid = visual.FindFirstChildOfClass("Humanoid");
                if (humanoid) {
                    humanoid.PlatformStand = true;
                }
            }
        } else if (currentWeld) {
            currentWeld.Destroy();
            const humanoid = visual.FindFirstChildOfClass("Humanoid");
            if (humanoid) {
                humanoid.PlatformStand = false;
            }
        }
    }

    private static CreateMoodIndicator(catId: string, catData: CatData) {
        const visual = this.catVisuals.get(catId);
        if (!visual) return;

        const indicator = new Instance("BillboardGui");
        indicator.Name = "MoodIndicator";
        indicator.Size = new UDim2(4, 0, 1, 0);
        indicator.StudsOffset = new Vector3(0, 3, 0);
        indicator.AlwaysOnTop = true;

        const frame = new Instance("Frame");
        frame.Size = new UDim2(1, 0, 1, 0);
        frame.BackgroundTransparency = 1;
        frame.Parent = indicator;

        const label = new Instance("TextLabel");
        label.Size = new UDim2(1, 0, 1, 0);
        label.BackgroundTransparency = 1;
        label.Text = catData.moodState.currentMood;
        label.TextColor3 = this.GetMoodColor(catData.moodState.currentMood);
        label.TextScaled = true;
        label.Font = Enum.Font.GothamBold;
        label.Parent = frame;

        const head = visual.FindFirstChild("Head") as BasePart || visual.FindFirstChild("Torso") as BasePart;
        if (head) {
            indicator.Adornee = head;
            indicator.Parent = head;
        }

        this.moodIndicators.set(catId, indicator);
    }

    private static UpdateMoodIndicator(catId: string, moodState: MoodState) {
        const indicator = this.moodIndicators.get(catId);
        if (!indicator) return;

        const label = indicator.FindFirstChild("Frame")?.FindFirstChild("TextLabel") as TextLabel;
        if (label && label.GetAttribute("IsTemporary") !== true) {
            label.Text = moodState.currentMood;
            label.TextColor3 = this.GetMoodColor(moodState.currentMood);
        }
    }

    private static ShowTemporaryMoodText(catId: string, text: string, color: Color3) {
        const indicator = this.moodIndicators.get(catId);
        if (!indicator) return;

        const label = indicator.FindFirstChild("Frame")?.FindFirstChild("TextLabel") as TextLabel;
        if (label) {
            label.Text = text;
            label.TextColor3 = color;
            label.SetAttribute("IsTemporary", true);

            task.delay(1.5, () => {
                if (label.Parent) {
                    label.SetAttribute("IsTemporary", false);
                }
            });
        }
    }

    private static GetMoodColor(moodType: string): Color3 {
        const colors: Record<string, Color3> = {
            Happy: Color3.fromRGB(76, 175, 80),
            Curious: Color3.fromRGB(33, 150, 243),
            Annoyed: Color3.fromRGB(255, 152, 0),
            Hungry: Color3.fromRGB(244, 67, 54),
            Tired: Color3.fromRGB(156, 39, 176),
            Afraid: Color3.fromRGB(121, 85, 72),
            Playful: Color3.fromRGB(255, 193, 7),
        };
        return colors[moodType] || Color3.fromRGB(189, 189, 189);
    }

    /**
     * Determine the profile type from cat data.
     * Uses breed if available, otherwise infers from personality traits.
     */
    private static DetermineProfileType(catData: CatData): string {
        // First, try to use the breed field
        if (catData.profile.breed && catData.profile.breed !== "Default") {
            // Map breed names to profile types
            const breedToProfile: Record<string, string> = {
                "Tabby": "Friendly",
                "Black Cat": "Independent",
                "Calico": "Calico",
                "Siamese": "Siamese",
                "Maine Coon": "Friendly",
                "Persian": "Independent",
                "Bengal": "Siamese",
            };
            
            const profileType = breedToProfile[catData.profile.breed];
            if (profileType) {
                return profileType;
            }
        }
        
        // Infer from personality traits
        const personality = catData.profile.personality;
        
        // High friendliness + high playfulness = Friendly
        if (personality.friendliness > 0.7 && personality.playfulness > 0.7) {
            return "Friendly";
        }
        
        // High independence = Independent
        if (personality.independence > 0.7) {
            return "Independent";
        }
        
        // High curiosity = Calico
        if (personality.curiosity > 0.8) {
            return "Calico";
        }
        
        // High playfulness = Siamese
        if (personality.playfulness > 0.8) {
            return "Siamese";
        }
        
        // Default to Friendly
        return "Friendly";
    }

    private static purringSounds = new Map<string, Sound>();

    private static StopPurringSound(catId: string) {
        const sound = this.purringSounds.get(catId);
        if (sound && sound.Parent) {
            sound.Stop();
        }
        this.purringSounds.delete(catId);
    }

    private static PlayPurringSound(catId: string, visual: Model) {
        // Only play sound if not already playing
        if (this.purringSounds.has(catId)) return;

        const head = visual.FindFirstChild("Head") as BasePart || visual.PrimaryPart;
        if (!head) return;

        // Check if sound already exists
        let sound = head.FindFirstChild("PurringSound") as Sound;
        if (!sound) {
            sound = new Instance("Sound");
            sound.Name = "PurringSound";
            // Using a placeholder sound ID - replace with actual purring sound asset ID
            // You can find cat purring sounds in the Roblox library or upload your own
            sound.SoundId = "rbxassetid://131961136"; // Placeholder: replace with actual cat purr sound
            sound.Volume = 0.4;
            sound.Looped = true;
            sound.Parent = head;
        }

        if (!sound.IsPlaying) {
            sound.Play();
            this.purringSounds.set(catId, sound);

            // Stop sound after 3 seconds (when purr action ends)
            task.delay(3, () => {
                this.StopPurringSound(catId);
            });
        }
    }

    public static CullDistantCats(playerPosition: Vector3) {
        this.catVisuals.forEach((visual, catId) => {
            if (visual.PrimaryPart) {
                const distance = visual.PrimaryPart.Position.sub(playerPosition).Magnitude;
                if (distance > 200) {
                    visual.Parent = undefined;
                } else {
                    visual.Parent = Workspace;
                }
            }
        });
    }
}
