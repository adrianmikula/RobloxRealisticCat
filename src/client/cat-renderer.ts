import { Workspace, Players } from "@rbxts/services";
import { CatData, MoodState } from "shared/cat-types";

export class CatRenderer {
    private static catVisuals = new Map<string, Model>();
    private static moodIndicators = new Map<string, BillboardGui>();

    public static CreateCatVisual(catId: string, catData: CatData): Model | undefined {
        const modelsFolder = Workspace.FindFirstChild("Models");
        if (!modelsFolder) {
            warn("Models folder not found in Workspace");
            return;
        }

        const petraModel = modelsFolder.FindFirstChild("Petra") as Model;
        if (!petraModel) {
            warn("Petra cat model not found in Workspace.Models");
            return;
        }

        const catVisual = petraModel.Clone();
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

        catVisual.Parent = Workspace;
        this.catVisuals.set(catId, catVisual);

        this.CreateMoodIndicator(catId, catData);

        return catVisual;
    }

    public static RemoveCatVisual(catId: string) {
        const visual = this.catVisuals.get(catId);
        if (visual) {
            visual.Destroy();
            this.catVisuals.delete(catId);
        }

        const indicator = this.moodIndicators.get(catId);
        if (indicator) {
            indicator.Destroy();
            this.moodIndicators.delete(catId);
        }
    }

    public static UpdateCatVisual(catId: string, catData: CatData) {
        const visual = this.catVisuals.get(catId);
        if (!visual) return;

        const humanoid = visual.FindFirstChildOfClass("Humanoid");
        if (humanoid) {
            humanoid.WalkSpeed = catData.profile.physical.movementSpeed;
            humanoid.JumpPower = catData.profile.physical.jumpHeight;

            if (catData.behaviorState.isMoving) {
                const targetPos = catData.currentState.position;
                const currentPos = visual.PrimaryPart?.Position || new Vector3();

                if (targetPos.sub(currentPos).Magnitude > 1) {
                    humanoid.MoveTo(targetPos);
                } else {
                    humanoid.MoveTo(currentPos);
                }
            } else {
                humanoid.MoveTo(visual.PrimaryPart?.Position || new Vector3());
            }
        }

        this.UpdateMoodIndicator(catId, catData.moodState);
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
        if (label) {
            label.Text = moodState.currentMood;
            label.TextColor3 = this.GetMoodColor(moodState.currentMood);
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
