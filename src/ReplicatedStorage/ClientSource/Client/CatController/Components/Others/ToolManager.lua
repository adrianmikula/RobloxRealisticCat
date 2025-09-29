local ToolManager = {}

-- External dependencies
local CatService
local Players = game:GetService("Players")

-- Internal state
local ToolManager = {
	EquippedTool = "none",
	ToolInstances = {},
	ToolEffects = {},
	ToolCooldowns = {}
}

function ToolManager:EquipTool(toolType)
	-- Unequip current tool first
	ToolManager:UnequipTool()
	
	-- Check if player has this tool
	local player = Players.LocalPlayer
	local hasTool = CatService:GetPlayerTools(player)[toolType]
	
	if not hasTool then
		ToolManager:ShowNotification("Tool not unlocked: " .. toolType)
		return false
	end
	
	-- Create tool visual
	local toolInstance = ToolManager:CreateToolVisual(toolType)
	if not toolInstance then
		ToolManager:ShowNotification("Failed to create tool: " .. toolType)
		return false
	end
	
	-- Equip the tool to player
	ToolManager:AttachToolToPlayer(toolInstance)
	
	-- Store tool reference
	ToolManager.EquippedTool = toolType
	ToolManager.ToolInstances[toolType] = toolInstance
	
	-- Play equip effect
	ToolManager:PlayEquipEffect(toolType)
	
	ToolManager:ShowNotification("Equipped: " .. ToolManager:GetToolDisplayName(toolType))
	
	print("Tool equipped:", toolType)
	return true
end

function ToolManager:UnequipTool()
	if ToolManager.EquippedTool == "none" then return end
	
	-- Remove tool visual
	local toolInstance = ToolManager.ToolInstances[ToolManager.EquippedTool]
	if toolInstance then
		toolInstance:Destroy()
		ToolManager.ToolInstances[ToolManager.EquippedTool] = nil
	end
	
	-- Clean up effects
	ToolManager:CleanupToolEffects()
	
	-- Reset equipped tool
	ToolManager.EquippedTool = "none"
	
	ToolManager:ShowNotification("Tool unequipped")
	
	print("Tool unequipped")
end

function ToolManager:CreateToolVisual(toolType)
	-- Create visual representation of the tool
	local toolModel = Instance.new("Model")
	toolModel.Name = "Tool_" .. toolType
	
	-- Different tools have different appearances
	if toolType == "basicFood" or toolType == "premiumFood" then
		-- Food bowl or food item
		local bowl = Instance.new("Part")
		bowl.Name = "FoodBowl"
		bowl.Size = Vector3.new(1, 0.2, 1)
		bowl.BrickColor = BrickColor.new("Bright blue")
		bowl.Material = Enum.Material.Plastic
		bowl.Parent = toolModel
		
		-- Add food contents
		local food = Instance.new("Part")
		food.Name = "Food"
		food.Size = Vector3.new(0.8, 0.1, 0.8)
		food.BrickColor = toolType == "premiumFood" and BrickColor.new("Bright yellow") or BrickColor.new("Bright orange")
		food.Material = Enum.Material.Neon
		food.Position = Vector3.new(0, 0.15, 0)
		food.Parent = toolModel
		
	elseif toolType == "basicToys" or toolType == "premiumToys" then
		-- Toy (feather wand or ball)
		local toy = Instance.new("Part")
		toy.Name = "Toy"
		toy.Size = Vector3.new(0.2, 1, 0.2)
		toy.BrickColor = toolType == "premiumToys" and BrickColor.new("Hot pink") or BrickColor.new("Bright green")
		toy.Material = Enum.Material.Neon
		toy.Parent = toolModel
		
		-- Add feather or attachment
		local attachment = Instance.new("Part")
		attachment.Name = "Attachment"
		attachment.Size = Vector3.new(0.5, 0.1, 0.5)
		attachment.BrickColor = BrickColor.new("White")
		attachment.Position = Vector3.new(0, 0.6, 0)
		attachment.Parent = toolModel
		
	elseif toolType == "groomingTools" then
		-- Brush or comb
		local brush = Instance.new("Part")
		brush.Name = "Brush"
		brush.Size = Vector3.new(0.3, 0.1, 1)
		brush.BrickColor = BrickColor.new("Bright violet")
		brush.Material = Enum.Material.Plastic
		brush.Parent = toolModel
		
		-- Add bristles
		for i = 1, 5 do
			local bristle = Instance.new("Part")
			bristle.Name = "Bristle" .. i
			bristle.Size = Vector3.new(0.25, 0.3, 0.05)
			bristle.BrickColor = BrickColor.new("White")
			bristle.Position = Vector3.new(0, 0.2, -0.4 + (i * 0.2))
			bristle.Parent = toolModel
		end
		
	elseif toolType == "medicalItems" then
		-- Medical kit
		local kit = Instance.new("Part")
		kit.Name = "MedicalKit"
		kit.Size = Vector3.new(0.5, 0.3, 0.8)
		kit.BrickColor = BrickColor.new("Bright red")
		kit.Material = Enum.Material.Plastic
		kit.Parent = toolModel
		
		-- Add cross symbol
		local cross = Instance.new("Part")
		cross.Name = "Cross"
		cross.Size = Vector3.new(0.4, 0.1, 0.1)
		cross.BrickColor = BrickColor.new("White")
		cross.Position = Vector3.new(0, 0.2, 0)
		cross.Parent = toolModel
		
		local crossVertical = cross:Clone()
		crossVertical.Size = Vector3.new(0.1, 0.1, 0.4)
		crossVertical.Parent = toolModel
	end
	
	-- Make tool non-collidable
	for _, part in ipairs(toolModel:GetDescendants()) do
		if part:IsA("Part") then
			part.CanCollide = false
			part.Anchored = false
		end
	end
	
	return toolModel
end

function ToolManager:AttachToolToPlayer(toolModel)
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then return end
	
	local rightArm = character:FindFirstChild("RightHand")
	if not rightArm then
		-- Fallback to humanoid root part
		rightArm = character:FindFirstChild("HumanoidRootPart")
	end
	
	if rightArm then
		-- Create weld to attach tool
		local weld = Instance.new("Weld")
		weld.Part0 = rightArm
		weld.Part1 = toolModel.PrimaryPart or toolModel:FindFirstChildOfClass("Part")
		
		-- Position tool appropriately
		if string.find(toolModel.Name, "Food") then
			weld.C0 = CFrame.new(0, 0, -1) * CFrame.Angles(0, math.rad(90), 0)
		elseif string.find(toolModel.Name, "Toy") then
			weld.C0 = CFrame.new(0, 0, -1.5) * CFrame.Angles(0, math.rad(45), 0)
		else
			weld.C0 = CFrame.new(0, 0, -1)
		end
		
		weld.Parent = toolModel
		toolModel.Parent = character
	end
end

function ToolManager:PlayEquipEffect(toolType)
	-- Play sound and particle effect when equipping tool
	
	-- Sound effect
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" -- Placeholder sound ID
	sound.Volume = 0.3
	sound.Parent = workspace
	sound:Play()
	
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	
	-- Particle effect
	local player = Players.LocalPlayer
	local character = player.Character
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			local particles = Instance.new("ParticleEmitter")
			particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			particles.Lifetime = NumberRange.new(0.5, 1)
			particles.Rate = 20
			particles.SpreadAngle = Vector2.new(45, 45)
			particles.Parent = humanoidRootPart
			
			task.delay(1, function()
				particles:Destroy()
			end)
		end
	end
	
	print("Played equip effect for tool:", toolType)
end

function ToolManager:PlayUseEffect(toolType, success)
	-- Play effect when using tool
	local effectColor = success and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
	
	local player = Players.LocalPlayer
	local character = player.Character
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			local particles = Instance.new("ParticleEmitter")
			particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			particles.Lifetime = NumberRange.new(0.3, 0.7)
			particles.Rate = 15
			particles.SpreadAngle = Vector2.new(30, 30)
			particles.Color = ColorSequence.new(effectColor)
			particles.Parent = humanoidRootPart
			
			task.delay(0.5, function()
				particles:Destroy()
			end)
		end
	end
	
	-- Play sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" -- Placeholder
	sound.Volume = 0.4
	sound.Parent = workspace
	sound:Play()
	
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

function ToolManager:GetToolDisplayName(toolType)
	local toolNames = {
		basicFood = "Basic Food Bowl",
		premiumFood = "Premium Food Bowl",
		basicToys = "Basic Toy Wand",
		premiumToys = "Premium Toy Wand",
		groomingTools = "Grooming Brush",
		medicalItems = "Medical Kit",
		none = "Empty Hands"
	}
	
	return toolNames[toolType] or toolType
end

function ToolManager:GetToolEffectiveness(toolType)
	local effectiveness = {
		basicFood = 1.0,
		premiumFood = 1.5,
		basicToys = 1.0,
		premiumToys = 1.5,
		groomingTools = 1.2,
		medicalItems = 2.0,
		none = 0.8
	}
	
	return effectiveness[toolType] or 1.0
end

function ToolManager:GetToolCooldown(toolType)
	local cooldowns = {
		basicFood = 5,
		premiumFood = 5,
		basicToys = 3,
		premiumToys = 3,
		groomingTools = 10,
		medicalItems = 30,
		none = 2
	}
	
	return cooldowns[toolType] or 5
end

function ToolManager:IsToolOnCooldown(toolType)
	local cooldownEnd = ToolManager.ToolCooldowns[toolType]
	return cooldownEnd and os.time() < cooldownEnd
end

function ToolManager:SetToolCooldown(toolType)
	local cooldownDuration = ToolManager:GetToolCooldown(toolType)
	ToolManager.ToolCooldowns[toolType] = os.time() + cooldownDuration
end

function ToolManager:GetRemainingCooldown(toolType)
	local cooldownEnd = ToolManager.ToolCooldowns[toolType]
	if not cooldownEnd then return 0 end
	
	local remaining = cooldownEnd - os.time()
	return math.max(0, remaining)
end

function ToolManager:CleanupToolEffects()
	-- Clean up any active tool effects
	for _, effect in pairs(ToolManager.ToolEffects) do
		if effect and effect.Parent then
			effect:Destroy()
		end
	end
	ToolManager.ToolEffects = {}
end

function ToolManager:ShowNotification(message)
	-- Show UI notification (placeholder)
	print("ToolManager Notification:", message)
end

function ToolManager:GetEquippedTool()
	return ToolManager.EquippedTool
end

function ToolManager:HasToolEquipped()
	return ToolManager.EquippedTool ~= "none"
end

function ToolManager:UpdateToolUI()
	-- Update UI to show current tool and cooldowns
	-- This would interface with a proper UI system
	
	local toolName = ToolManager:GetToolDisplayName(ToolManager.EquippedTool)
	local cooldown = ToolManager:GetRemainingCooldown(ToolManager.EquippedTool)
	
	if cooldown > 0 then
		print("Tool:", toolName, "Cooldown:", cooldown, "seconds")
	else
		print("Tool:", toolName, "Ready")
	end
end

function ToolManager:CleanupAllTools()
	-- Clean up all tool instances
	ToolManager:UnequipTool()
	
	for toolType, toolInstance in pairs(ToolManager.ToolInstances) do
		if toolInstance and toolInstance.Parent then
			toolInstance:Destroy()
		end
	end
	
	ToolManager.ToolInstances = {}
	ToolManager.ToolCooldowns = {}
	ToolManager.EquippedTool = "none"
	
	print("ToolManager: All tools cleaned up")
end

-- Component initialization
function ToolManager.Init()
	-- Get reference to parent CatController
	local CatController = script.Parent.Parent.Parent
	CatService = CatController.CatService
	
	print("ToolManager component initialized")
end

function ToolManager.Start()
	print("ToolManager component started")
	
	-- Start cooldown update loop
	task.spawn(function()
		while true do
			ToolManager:UpdateToolUI()
			task.wait(1) -- Update every second
		end
	end)
end

return ToolManager