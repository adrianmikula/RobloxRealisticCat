/**
 * Loading Screen Controller
 * 
 * Manages the loading screen UI with progress bar during game initialization.
 * Shows progress as various systems initialize and assets load.
 */

import { Players, StarterGui, TweenService } from "@rbxts/services";

export class LoadingScreen {
    private static screenGui: ScreenGui | undefined;
    private static progressBar: Frame | undefined;
    private static progressText: TextLabel | undefined;
    private static isVisible = false;
    private static currentProgress = 0;

    /**
     * Initialize the loading screen UI.
     * Should be called early in the client initialization.
     */
    public static Initialize() {
        const player = Players.LocalPlayer;
        const playerGui = player.WaitForChild("PlayerGui") as PlayerGui;

        // Create the loading screen GUI
        const screenGui = new Instance("ScreenGui");
        screenGui.Name = "LoadingScreen";
        screenGui.ResetOnSpawn = false;
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
        screenGui.IgnoreGuiInset = true;
        screenGui.DisplayOrder = 1000; // Always on top
        screenGui.Parent = playerGui;

        // Create background overlay
        const background = new Instance("Frame");
        background.Name = "Background";
        background.Size = new UDim2(1, 0, 1, 0);
        background.Position = new UDim2(0, 0, 0, 0);
        background.BackgroundColor3 = Color3.fromRGB(20, 20, 30);
        background.BorderSizePixel = 0;
        background.Parent = screenGui;

        // Create loading container
        const container = new Instance("Frame");
        container.Name = "Container";
        container.Size = new UDim2(0, 400, 0, 200);
        container.Position = new UDim2(0.5, -200, 0.5, -100);
        container.BackgroundColor3 = Color3.fromRGB(30, 30, 40);
        container.BorderSizePixel = 0;
        container.Parent = screenGui;

        // Add corner radius
        const corner = new Instance("UICorner");
        corner.CornerRadius = new UDim(0, 12);
        corner.Parent = container;

        // Create title
        const title = new Instance("TextLabel");
        title.Name = "Title";
        title.Size = new UDim2(1, -40, 0, 40);
        title.Position = new UDim2(0, 20, 0, 20);
        title.BackgroundTransparency = 1;
        title.Text = "Loading Game...";
        title.TextColor3 = Color3.fromRGB(255, 255, 255);
        title.TextSize = 24;
        title.Font = Enum.Font.GothamBold;
        title.TextXAlignment = Enum.TextXAlignment.Left;
        title.Parent = container;

        // Create progress text
        const progressText = new Instance("TextLabel");
        progressText.Name = "ProgressText";
        progressText.Size = new UDim2(1, -40, 0, 20);
        progressText.Position = new UDim2(0, 20, 0, 60);
        progressText.BackgroundTransparency = 1;
        progressText.Text = "Initializing...";
        progressText.TextColor3 = Color3.fromRGB(200, 200, 200);
        progressText.TextSize = 14;
        progressText.Font = Enum.Font.Gotham;
        progressText.TextXAlignment = Enum.TextXAlignment.Left;
        progressText.Parent = container;

        // Create progress bar background
        const progressBg = new Instance("Frame");
        progressBg.Name = "ProgressBackground";
        progressBg.Size = new UDim2(1, -40, 0, 20);
        progressBg.Position = new UDim2(0, 20, 0, 100);
        progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60);
        progressBg.BorderSizePixel = 0;
        progressBg.Parent = container;

        const progressBgCorner = new Instance("UICorner");
        progressBgCorner.CornerRadius = new UDim(0, 10);
        progressBgCorner.Parent = progressBg;

        // Create progress bar fill
        const progressBar = new Instance("Frame");
        progressBar.Name = "ProgressBar";
        progressBar.Size = new UDim2(0, 0, 1, 0);
        progressBar.Position = new UDim2(0, 0, 0, 0);
        progressBar.BackgroundColor3 = Color3.fromRGB(0, 162, 255);
        progressBar.BorderSizePixel = 0;
        progressBar.Parent = progressBg;

        const progressBarCorner = new Instance("UICorner");
        progressBarCorner.CornerRadius = new UDim(0, 10);
        progressBarCorner.Parent = progressBar;

        // Create progress percentage text
        const percentageText = new Instance("TextLabel");
        percentageText.Name = "Percentage";
        percentageText.Size = new UDim2(1, -40, 0, 20);
        percentageText.Position = new UDim2(0, 20, 0, 130);
        percentageText.BackgroundTransparency = 1;
        percentageText.Text = "0%";
        percentageText.TextColor3 = Color3.fromRGB(150, 150, 150);
        percentageText.TextSize = 12;
        percentageText.Font = Enum.Font.Gotham;
        percentageText.TextXAlignment = Enum.TextXAlignment.Right;
        percentageText.Parent = container;

        // Store references
        this.screenGui = screenGui;
        this.progressBar = progressBar;
        this.progressText = progressText;
        this.isVisible = true;

        // Hide StarterGui elements during loading
        StarterGui.SetCoreGuiEnabled(Enum.CoreGuiType.All, false);
    }

    /**
     * Update the loading progress (0-1).
     */
    public static SetProgress(progress: number, message?: string) {
        if (!this.screenGui || !this.progressBar || !this.progressText) return;

        this.currentProgress = math.clamp(progress, 0, 1);

        // Update progress bar
        this.progressBar.Size = new UDim2(this.currentProgress, 0, 1, 0);

        // Update text
        if (message) {
            this.progressText.Text = message;
        }

        // Update percentage
        const percentageLabel = this.screenGui.FindFirstChild("Container")?.FindFirstChild("Percentage") as TextLabel;
        if (percentageLabel) {
            percentageLabel.Text = `${math.floor(this.currentProgress * 100)}%`;
        }
    }

    /**
     * Hide the loading screen with a fade-out effect.
     */
    public static Hide() {
        if (!this.screenGui || !this.isVisible) return;

        this.isVisible = false;

        // Fade out animation
        task.spawn(() => {
            const container = this.screenGui?.FindFirstChild("Container") as Frame;
            if (container) {
                const fadeOut = TweenService.Create(
                    container,
                    new TweenInfo(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { BackgroundTransparency: 1 }
                );

                const background = this.screenGui?.FindFirstChild("Background") as Frame;
                if (background) {
                    const bgFadeOut = TweenService.Create(
                        background,
                        new TweenInfo(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundTransparency: 1 }
                    );
                    bgFadeOut.Play();
                }

                fadeOut.Play();
                fadeOut.Completed.Connect(() => {
                    // Re-enable StarterGui
                    StarterGui.SetCoreGuiEnabled(Enum.CoreGuiType.All, true);
                    
                    // Destroy loading screen
                    if (this.screenGui) {
                        this.screenGui.Destroy();
                        this.screenGui = undefined;
                        this.progressBar = undefined;
                        this.progressText = undefined;
                    }
                });
            } else {
                // Fallback: just destroy immediately
                StarterGui.SetCoreGuiEnabled(Enum.CoreGuiType.All, true);
                if (this.screenGui) {
                    this.screenGui.Destroy();
                    this.screenGui = undefined;
                    this.progressBar = undefined;
                    this.progressText = undefined;
                }
            }
        });
    }

    /**
     * Check if the loading screen is currently visible.
     */
    public static IsVisible(): boolean {
        return this.isVisible;
    }

    /**
     * Get current progress (0-1).
     */
    public static GetProgress(): number {
        return this.currentProgress;
    }
}

