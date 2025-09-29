local MoodVisualizer = {}

-- External dependencies
local CatService

-- Internal state
local MoodVisualizer = {
	MoodIndicators = {},
	MoodParticles = {},
	MoodSounds = {}
}

function MoodVisualizer:UpdateMoodVisual(catId, moodState)
	-- Update visual indicators for cat mood
	MoodVisualizer:UpdateMoodIndicator(catId, moodState)
	MoodVisualizer:UpdateMoodParticles(catId, moodState)
	MoodVisualizer:PlayMoodSound(catId, moodState)
	MoodVisualizer:UpdateBodyLanguage(catId, moodState)
end

function MoodVisualizer:UpdateMoodIndicator(catId, moodState)
	-- Update the mood indicator GUI
	local catVisual = MoodVisualizer:GetCatVisual(catId)
	if not catVisual then return end
	
	-- Find or create mood indicator
	local moodIndicator = MoodVisualizer.MoodIndicators[catId]
	if not moodIndicator then
		moodIndicator = MoodVisualizer:CreateMoodIndicator(catId)
		MoodVisualizer.MoodIndicators[catId] = moodIndicator
	end
	
	-- Update indicator content
	MoodVisualizer:UpdateIndicatorContent(moodIndicator, moodState)
end

function MoodVisualizer:CreateMoodIndicator(catId)
	-- Create a comprehensive mood indicator
	local moodIndicator = Instance.new("BillboardGui")
	moodIndicator.Name = "AdvancedMoodIndicator"
	moodIndicator.Size = UDim2.new(6, 0, 2, 0)
	moodIndicator.StudsOffset = Vector3.new(0, 4, 0)
	moodIndicator.AlwaysOnTop = true
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.BackgroundTransparency = 0.3
	mainFrame.BorderSizePixel = 0
	
	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.1, 0)
	corner.Parent = mainFrame
	
	-- Mood text
	local moodText = Instance.new("TextLabel")
	moodText.Name = "MoodText"
	moodText.Size = UDim2.new(1, 0, 0.5, 0)
	moodText.Position = UDim2.new(0, 0, 0, 0)
	moodText.BackgroundTransparency = 1
	moodText.TextColor3 = Color3.fromRGB(255, 255, 255)
	moodText.TextScaled = true
	moodText.Font = Enum.Font.GothamBold
	moodText.Parent = mainFrame
	
	-- Intensity bar
	local intensityBar = Instance.new("Frame")
	intensityBar.Name = "IntensityBar"
	intensityBar.Size = UDim2.new(0.9, 0, 0.2, 0)
	intensityBar.Position = UDim2.new(0.05, 0, 0.6, 0)
	intensityBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	intensityBar.BorderSizePixel = 0
	
	local intensityFill = Instance.new("Frame")
	intensityFill.Name = "IntensityFill"
	intensityFill.Size = UDim2.new(0, 0, 1, 0)
	intensityFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	intensityFill.BorderSizePixel = 0
	intensityFill.Parent = intensityBar
	
	local intensityCorner = Instance.new("UICorner")
	intensityCorner.CornerRadius = UDim.new(0.5, 0)
	intensityCorner.Parent = intensityBar
	
	intensityBar.Parent = mainFrame
	
	mainFrame.Parent = moodIndicator
	
	-- Attach to cat
	local catVisual = MoodVisualizer:GetCatVisual(catId)
	if catVisual then
		local head = catVisual:FindFirstChild("Head")
		if head then
			moodIndicator.Adornee = head
			moodIndicator.Parent = head
		end
	end
	
	return moodIndicator
end

function MoodVisualizer:UpdateIndicatorContent(moodIndicator, moodState)
	local mainFrame = moodIndicator:FindFirstChild("Frame")
	if not mainFrame then return end
	
	local moodText = mainFrame:FindFirstChild("MoodText")
	local intensityBar = mainFrame:FindFirstChild("IntensityBar")
	
	if moodText then
		moodText.Text = moodState.currentMood
		moodText.TextColor3 = MoodVisualizer:GetMoodColor(moodState.currentMood)
	end
	
	if intensityBar then
		local intensityFill = intensityBar:FindFirstChild("IntensityFill")
		if intensityFill then
			intensityFill.Size = UDim2.new(moodState.moodIntensity or 0.5, 0, 1, 0)
			intensityFill.BackgroundColor3 = MoodVisualizer:GetIntensityColor(moodState.moodIntensity or 0.5)
		end
	end
end

function MoodVisualizer:GetMoodColor(moodType)
	local moodColors = {
		Happy = Color3.fromRGB(76, 175, 80),    -- Green
		Curious = Color3.fromRGB(33, 150, 243), -- Blue
		Annoyed = Color3.fromRGB(255, 152, 0),  -- Orange
		Hungry = Color3.fromRGB(244, 67, 54),   -- Red
		Tired = Color3.fromRGB(156, 39, 176),   -- Purple
		Afraid = Color3.fromRGB(121, 85, 72),   -- Brown
		Playful = Color3.fromRGB(255, 193, 7)   -- Yellow
	}
	
	return moodColors[moodType] or Color3.fromRGB(189, 189, 189) -- Default gray
end

function MoodVisualizer:GetIntensityColor(intensity)
	-- Gradient from green (low) to red (high)
	if intensity < 0.33 then
		return Color3.fromRGB(76, 175, 80) -- Green
	elseif intensity < 0.66 then
		return Color3.fromRGB(255, 193, 7) -- Yellow
	else
		return Color3.fromRGB(244, 67, 54) -- Red
	end
end

function MoodVisualizer:UpdateMoodParticles(catId, moodState)
	-- Add particle effects based on mood
	local catVisual = MoodVisualizer:GetCatVisual(catId)
	if not catVisual then return end
	
	-- Clean up existing particles
	MoodVisualizer:CleanupMoodParticles(catId)
	
	-- Create new particles based on mood
	local particleEffect = MoodVisualizer:CreateMoodParticles(moodState.currentMood)
	if particleEffect then
		local head = catVisual:FindFirstChild("Head")
		if head then
			particleEffect.Parent = head
			MoodVisualizer.MoodParticles[catId] = particleEffect
		end
	end
end

function MoodVisualizer:CreateMoodParticles(moodType)
	local particleEffect = Instance.new("ParticleEmitter")
	particleEffect.Name = "MoodParticles"
	
	-- Configure particles based on mood
	if moodType == "Happy" then
		particleEffect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEffect.Lifetime = NumberRange.new(1, 2)
		particleEffect.Rate = 10
		particleEffect.SpreadAngle = Vector2.new(30, 30)
		particleEffect.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
		particleEffect.LightEmission = 0.5
		
	elseif moodType == "Playful" then
		particleEffect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEffect.Lifetime = NumberRange.new(0.5, 1)
		particleEffect.Rate = 20
		particleEffect.SpreadAngle = Vector2.new(60, 60)
		particleEffect.Color = ColorSequence.new(Color3.fromRGB(255, 200, 100))
		particleEffect.LightEmission = 0.3
		
	elseif moodType == "Afraid" then
		particleEffect.Texture = "rbxasset://textures/particles/smoke_main.dds"
		particleEffect.Lifetime = NumberRange.new(0.5, 1)
		particleEffect.Rate = 15
		particleEffect.SpreadAngle = Vector2.new(20, 20)
		particleEffect.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
		particleEffect.LightEmission = 0.1
	end
	
	return particleEffect
end

function MoodVisualizer:CleanupMoodParticles(catId)
	local particleEffect = MoodVisualizer.MoodParticles[catId]
	if particleEffect then
		particleEffect:Destroy()
		MoodVisualizer.MoodParticles[catId] = nil
	end
end

function MoodVisualizer:PlayMoodSound(catId, moodState)
	-- Play sound effects based on mood
	local catVisual = MoodVisualizer:GetCatVisual(catId)
	if not catVisual then return end
	
	-- Only play sounds occasionally to avoid spam
	if math.random() > 0.1 then return end
	
	local soundId = MoodVisualizer:GetMoodSound(moodState.currentMood)
	if soundId then
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 0.3
		sound.Parent = catVisual
		
		sound:Play()
		
		-- Clean up after playing
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
end

function MoodVisualizer:GetMoodSound(moodType)
	-- Placeholder sound IDs - these would be replaced with actual cat sounds
	local soundMap = {
		Happy = "rbxassetid://",    -- Purr sound
		Playful = "rbxassetid://",  -- Meow sound
		Curious = "rbxassetid://",  -- Soft meow
		Annoyed = "rbxassetid://",  -- Hiss sound
		Afraid = "rbxassetid://",   -- Scared meow
		Hungry = "rbxassetid://"    -- Demanding meow
	}
	
	return soundMap[moodType]
end

function MoodVisualizer:UpdateBodyLanguage(catId, moodState)
	-- Update cat's body language based on mood
	local catVisual = MoodVisualizer:GetCatVisual(catId)
	if not catVisual then return end
	
	-- This would involve adjusting the cat model's pose, tail position, etc.
	-- For now, we'll just log the mood change
	
	print("Cat", catId, "body language updated for mood:", moodState.currentMood)
end

function MoodVisualizer:GetCatVisual(catId)
	-- Get reference to CatRenderer
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:GetCatVisual(catId)
	end
	return nil
end

function MoodVisualizer:CleanupMoodVisuals(catId)
	-- Clean up all mood visuals for a cat
	MoodVisualizer:CleanupMoodParticles(catId)
	
	local moodIndicator = MoodVisualizer.MoodIndicators[catId]
	if moodIndicator then
		moodIndicator:Destroy()
		MoodVisualizer.MoodIndicators[catId] = nil
	end
	
	-- Clean up any mood sounds
	local catVisual = MoodVisualizer:GetCatVisual(catId)
	if catVisual then
		for _, sound in ipairs(catVisual:GetDescendants()) do
			if sound:IsA("Sound") and sound.Name == "MoodSound" then
				sound:Destroy()
			end
		end
	end
end

function MoodVisualizer:SetMoodVisibility(catId, visible)
	-- Show/hide mood visuals
	local moodIndicator = MoodVisualizer.MoodIndicators[catId]
	if moodIndicator then
		moodIndicator.Enabled = visible
	end
	
	local particleEffect = MoodVisualizer.MoodParticles[catId]
	if particleEffect then
		particleEffect.Enabled = visible
	end
end

-- Component initialization
function MoodVisualizer.Init()
	-- Get reference to parent CatController
	local CatController = script.Parent.Parent.Parent
	CatService = CatController.CatService
	
	print("MoodVisualizer component initialized")
end

function MoodVisualizer.Start()
	print("MoodVisualizer component started")
end

return MoodVisualizer