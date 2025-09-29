local CatRenderer = {}

-- External dependencies
local CatService

-- Internal state
local CatRenderer = {
	CatVisuals = {},
	CatModels = {},
	MoodIndicators = {},
	ParticleEffects = {}
}

function CatRenderer:CreateCatVisual(catId, catData)
	-- Create a visual representation of the cat
	local catVisual = Instance.new("Model")
	catVisual.Name = "Cat_" .. catId
	
	-- Create cat body parts (simplified for now)
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.BrickColor = BrickColor.new("Bright orange")
	head.Parent = catVisual
	
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 1.5, 4)
	body.BrickColor = BrickColor.new("Bright orange")
	body.Parent = catVisual
	
	-- Position body parts
	local headWeld = Instance.new("Weld")
	headWeld.Part0 = body
	headWeld.Part1 = head
	headWeld.C0 = CFrame.new(0, 1, 2)
	headWeld.Parent = head
	
	-- Add humanoid for animations
	local humanoid = Instance.new("Humanoid")
	humanoid.WalkSpeed = catData.profile.physical.movementSpeed
	humanoid.JumpPower = catData.profile.physical.jumpHeight
	humanoid.Parent = catVisual
	
	-- Position the cat in the world
	catVisual.PrimaryPart = body
	catVisual:SetPrimaryPartCFrame(CFrame.new(catData.currentState.position))
	catVisual.Parent = workspace
	
	-- Store visual reference
	CatRenderer.CatVisuals[catId] = catVisual
	CatRenderer.CatModels[catId] = catData
	
	-- Create mood indicator
	CatRenderer:CreateMoodIndicator(catId, catData)
	
	print("Created visual for cat:", catId)
	
	return catVisual
end

function CatRenderer:DestroyCatVisual(catId)
	if CatRenderer.CatVisuals[catId] then
		CatRenderer.CatVisuals[catId]:Destroy()
		CatRenderer.CatVisuals[catId] = nil
		CatRenderer.CatModels[catId] = nil
		
		-- Clean up mood indicator
		if CatRenderer.MoodIndicators[catId] then
			CatRenderer.MoodIndicators[catId]:Destroy()
			CatRenderer.MoodIndicators[catId] = nil
		end
		
		print("Destroyed visual for cat:", catId)
	end
end

function CatRenderer:UpdateCatVisual(catId, catData)
	local catVisual = CatRenderer.CatVisuals[catId]
	if not catVisual then return end
	
	-- Update position
	if catVisual.PrimaryPart then
		catVisual:SetPrimaryPartCFrame(CFrame.new(catData.currentState.position))
	end
	
	-- Update humanoid properties
	local humanoid = catVisual:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = catData.profile.physical.movementSpeed
		humanoid.JumpPower = catData.profile.physical.jumpHeight
	end
	
	-- Update stored data
	CatRenderer.CatModels[catId] = catData
	
	-- Update mood indicator
	CatRenderer:UpdateMoodIndicator(catId, catData.moodState)
end

function CatRenderer:CreateMoodIndicator(catId, catData)
	-- Create a billboard GUI to show mood
	local moodIndicator = Instance.new("BillboardGui")
	moodIndicator.Name = "MoodIndicator"
	moodIndicator.Size = UDim2.new(4, 0, 1, 0)
	moodIndicator.StudsOffset = Vector3.new(0, 3, 0)
	moodIndicator.AlwaysOnTop = true
	
	local moodFrame = Instance.new("Frame")
	moodFrame.Size = UDim2.new(1, 0, 1, 0)
	moodFrame.BackgroundTransparency = 1
	moodFrame.Parent = moodIndicator
	
	local moodLabel = Instance.new("TextLabel")
	moodLabel.Size = UDim2.new(1, 0, 1, 0)
	moodLabel.BackgroundTransparency = 1
	moodLabel.Text = catData.moodState.currentMood
	moodLabel.TextColor3 = CatRenderer:GetMoodColor(catData.moodState.currentMood)
	moodLabel.TextScaled = true
	moodLabel.Font = Enum.Font.GothamBold
	moodLabel.Parent = moodFrame
	
	-- Attach to cat's head
	local catVisual = CatRenderer.CatVisuals[catId]
	if catVisual then
		local head = catVisual:FindFirstChild("Head")
		if head then
			moodIndicator.Adornee = head
			moodIndicator.Parent = head
		end
	end
	
	CatRenderer.MoodIndicators[catId] = moodIndicator
end

function CatRenderer:UpdateMoodIndicator(catId, moodState)
	local moodIndicator = CatRenderer.MoodIndicators[catId]
	if not moodIndicator then return end
	
	local moodLabel = moodIndicator:FindFirstChild("Frame"):FindFirstChild("TextLabel")
	if moodLabel then
		moodLabel.Text = moodState.currentMood
		moodLabel.TextColor3 = CatRenderer:GetMoodColor(moodState.currentMood)
	end
end

function CatRenderer:GetMoodColor(moodType)
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

function CatRenderer:PlayParticleEffect(catId, effectType)
	-- Create particle effects for various cat behaviors
	local catVisual = CatRenderer.CatVisuals[catId]
	if not catVisual then return end
	
	local particleEffect = Instance.new("ParticleEmitter")
	particleEffect.Name = effectType .. "Effect"
	
	-- Configure based on effect type
	if effectType == "Eat" then
		particleEffect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEffect.Lifetime = NumberRange.new(0.5, 1.5)
		particleEffect.Rate = 20
		particleEffect.SpreadAngle = Vector2.new(45, 45)
		particleEffect.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
	elseif effectType == "Play" then
		particleEffect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEffect.Lifetime = NumberRange.new(0.3, 0.8)
		particleEffect.Rate = 30
		particleEffect.SpreadAngle = Vector2.new(90, 90)
		particleEffect.Color = ColorSequence.new(Color3.fromRGB(255, 200, 100))
	end
	
	-- Attach to cat's head
	local head = catVisual:FindFirstChild("Head")
	if head then
		particleEffect.Parent = head
		
		-- Auto-destroy after duration
		task.delay(3, function()
			if particleEffect and particleEffect.Parent then
				particleEffect:Destroy()
			end
		end)
	end
	
	CatRenderer.ParticleEffects[catId] = particleEffect
end

function CatRenderer:GetCatVisual(catId)
	return CatRenderer.CatVisuals[catId]
end

function CatRenderer:GetAllCatVisuals()
	return CatRenderer.CatVisuals
end

function CatRenderer:IsCatVisible(catId)
	local catVisual = CatRenderer.CatVisuals[catId]
	return catVisual and catVisual.Parent ~= nil
end

function CatRenderer:SetCatVisibility(catId, visible)
	local catVisual = CatRenderer.CatVisuals[catId]
	if catVisual then
		catVisual.Parent = visible and workspace or nil
		
		-- Also hide/show mood indicator
		local moodIndicator = CatRenderer.MoodIndicators[catId]
		if moodIndicator then
			moodIndicator.Enabled = visible
		end
	end
end

-- Component initialization
function CatRenderer.Init()
	-- Get reference to parent CatController
	local CatController = script.Parent.Parent.Parent
	CatService = CatController.CatService
	
	print("CatRenderer component initialized")
end

function CatRenderer.Start()
	print("CatRenderer component started")
end

return CatRenderer