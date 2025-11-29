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

function CatRenderer:SpawnCatVisual(catId, catData)
	return self:CreateCatVisual(catId, catData)
end

function CatRenderer:CreateCatVisual(catId, catData)
	-- Clone the Petra cat model from workspace
	local petraModel = game.Workspace.Models:FindFirstChild("Petra")
	if not petraModel then
		warn("Petra cat model not found in Workspace.Models")
		return nil
	end
	
	-- Clone the model for this cat
	local catVisual = petraModel:Clone()
	catVisual.Name = "Cat_" .. catId
	
	-- Configure humanoid for cat behavior
	local humanoid = catVisual:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = catData.profile.physical.movementSpeed
		humanoid.JumpPower = catData.profile.physical.jumpHeight
		
		-- Configure humanoid for cat-like behavior
		humanoid.AutoRotate = true
		humanoid.AutoJumpEnabled = false
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		
		-- Set up animations for cat behaviors
		self:SetupCatAnimations(catId, humanoid)
	end
	
	-- Position the cat in the world
	if catVisual.PrimaryPart then
		catVisual:SetPrimaryPartCFrame(CFrame.new(catData.currentState.position))
	else
		-- Fallback positioning
		local root = catVisual:FindFirstChild("Root") or catVisual:FindFirstChild("Torso")
		if root then
			root.CFrame = CFrame.new(catData.currentState.position)
		end
	end
	
	catVisual.Parent = workspace
	
	-- Store visual reference
	CatRenderer.CatVisuals[catId] = catVisual
	CatRenderer.CatModels[catId] = catData
	
	-- Create mood indicator
	CatRenderer:CreateMoodIndicator(catId, catData)
	
	print("Created visual for cat:", catId, "using Petra model")
	
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
	
	-- Update humanoid properties and movement
	local humanoid = catVisual:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = catData.profile.physical.movementSpeed
		humanoid.JumpPower = catData.profile.physical.jumpHeight
		
		-- Make the cat actually move to the target position
		if catData.behaviorState and catData.behaviorState.isMoving then
			local currentPos = catVisual.PrimaryPart and catVisual.PrimaryPart.Position or Vector3.new(0, 0, 0)
			local targetPos = catData.currentState.position
			
			-- Only move if we're not already at the target
			if (targetPos - currentPos).Magnitude > 1 then
				local direction = (targetPos - currentPos).Unit
				humanoid:MoveTo(targetPos)
				print("🐱 [CatRenderer] Cat", catId, "moving to:", targetPos)
			else
				humanoid:MoveTo(currentPos) -- Stop moving
			end
		else
			-- Stop moving if not supposed to be moving
			humanoid:MoveTo(catVisual.PrimaryPart and catVisual.PrimaryPart.Position or Vector3.new(0, 0, 0))
		end
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
		else
			-- Fallback: attach to torso
			local torso = catVisual:FindFirstChild("Torso")
			if torso then
				moodIndicator.Adornee = torso
				moodIndicator.Parent = torso
			end
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
	
	-- Attach to cat's head or torso
	local head = catVisual:FindFirstChild("Head")
	local torso = catVisual:FindFirstChild("Torso")
	local attachTo = head or torso
	
	if attachTo then
		particleEffect.Parent = attachTo
		
		-- Auto-destroy after duration
		task.delay(3, function()
			if particleEffect and particleEffect.Parent then
				particleEffect:Destroy()
			end
		end)
	end
	
	CatRenderer.ParticleEffects[catId] = particleEffect
end

function CatRenderer:SetupCatAnimations(catId, humanoid)
	-- Set up animation tracks for various cat behaviors
	-- These will be played by the AnimationHandler component
	
	-- Load default animations (placeholder IDs - replace with actual cat animations)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	-- Store animation tracks for later use
	CatRenderer.AnimationTracks = CatRenderer.AnimationTracks or {}
	CatRenderer.AnimationTracks[catId] = {
		Walk = nil,
		Run = nil,
		Idle = nil,
		Sit = nil,
		Sleep = nil,
		Play = nil,
		Eat = nil,
		Groom = nil
	}
	
	print("Set up animations for cat:", catId)
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
	
	print("CatRenderer component initialized")
end

function CatRenderer:CullDistantCats()
	-- Cull distant cats based on performance settings
	local player = game.Players.LocalPlayer
	local character = player.Character
	
	if not character or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	
	local playerPosition = character.HumanoidRootPart.Position
	
	-- Get all active cat visuals
	for catId, catVisual in pairs(CatRenderer.ActiveCatVisuals or {}) do
		if catVisual and catVisual.PrimaryPart then
			local distance = (catVisual.PrimaryPart.Position - playerPosition).Magnitude
			
			-- Simple distance-based culling
			if distance > 200 then -- Max render distance
				catVisual.Parent = nil -- Hide the cat
			else
				catVisual.Parent = workspace -- Show the cat
			end
		end
	end
	
	print("Culled distant cats based on player position")
end

function CatRenderer.Start()
	print("CatRenderer component started")
end

return CatRenderer