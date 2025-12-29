local InputHandler = {}

-- External dependencies
local CatService
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

-- Internal state
local InputHandler = {
	CurrentTool = "none",
	InteractionRange = 10, -- studs
	InputCooldowns = {},
	NearbyCats = {}
}

function InputHandler:SetupInputs()
	-- Setup keyboard/mouse inputs for cat interactions
	
	-- Tool selection keys
	ContextActionService:BindAction("SelectFoodTool", function()
		InputHandler:SelectTool("basicFood")
	end, false, Enum.KeyCode.One)
	
	ContextActionService:BindAction("SelectToyTool", function()
		InputHandler:SelectTool("basicToys")
	end, false, Enum.KeyCode.Two)
	
	ContextActionService:BindAction("SelectGroomTool", function()
		InputHandler:SelectTool("groomingTools")
	end, false, Enum.KeyCode.Three)
	
	-- Interaction key
	ContextActionService:BindAction("InteractWithCat", function(actionName, inputState, inputObject)
		if inputState == Enum.UserInputState.Begin then
			InputHandler:InteractWithNearestCat()
		end
	end, false, Enum.KeyCode.E)
	
	-- Mouse click for interaction
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			InputHandler:HandleMouseClick(input.Position)
		end
	end)
	
	-- Update nearby cats periodically
	InputHandler:StartNearbyCatUpdates()
	
	print("InputHandler: Inputs setup complete")
end

function InputHandler:SelectTool(toolType)
	if InputHandler:IsOnCooldown("ToolSelect") then return end
	
	-- Get parent controller
	local CatController = script.Parent.Parent.Parent
	
	-- Check if player has this tool unlocked
	local player = Players.LocalPlayer
	
	-- For testing, assume player has all tools
	local playerTools = {
		basicFood = true,
		basicToys = true,
		groomingTool = true
	}
	
	local hasTool = playerTools[toolType]
	
	if not hasTool then
		InputHandler:ShowNotification("Tool not unlocked: " .. toolType)
		return
	end
	
	-- Equip the tool (simplified for testing)
	InputHandler.CurrentTool = toolType
	InputHandler:ShowNotification("Equipped: " .. InputHandler:GetToolDisplayName(toolType))
	InputHandler:UpdateToolVisuals()
	
	-- Play equip sound/effect
	InputHandler:PlayToolEquipEffect(toolType)
	
	-- Set cooldown
	InputHandler:SetCooldown("ToolSelect", 0.5)
	
	print("Selected tool:", toolType)
end

function InputHandler:UnequipTool()
	local CatController = script.Parent.Parent.Parent
	CatController:UnequipTool()
	InputHandler.CurrentTool = "none"
	InputHandler:ShowNotification("Tool unequipped")
end

function InputHandler:InteractWithNearestCat()
	if InputHandler:IsOnCooldown("Interact") then return end
	
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	-- Find nearest cat
	local nearestCat = InputHandler:GetNearestCat(humanoidRootPart.Position)
	if not nearestCat then
		InputHandler:ShowNotification("No cats nearby")
		return
	end
	
	-- Determine interaction type based on current tool
	local interactionType = InputHandler:GetInteractionTypeForTool(InputHandler.CurrentTool)
	
	-- Perform interaction
	InputHandler:PerformInteraction(player, nearestCat.catId, interactionType)
	
	InputHandler:SetCooldown("Interact", 1.0)
end

function InputHandler:HandleMouseClick(mousePosition)
	if InputHandler:IsOnCooldown("MouseInteract") then return end
	
	local player = Players.LocalPlayer
	local mouseTarget = InputHandler:GetMouseTarget(mousePosition)
	
	if mouseTarget and string.find(mouseTarget.Name, "Cat_") then
		-- Extract cat ID from model name
		local catId = string.gsub(mouseTarget.Name, "Cat_", "")
		
		-- Determine interaction type
		local interactionType = InputHandler:GetInteractionTypeForTool(InputHandler.CurrentTool)
		
		-- Perform interaction
		InputHandler:PerformInteraction(player, catId, interactionType)
	end
	
	InputHandler:SetCooldown("MouseInteract", 0.5)
end

function InputHandler:PerformInteraction(player, catId, interactionType)
	if not interactionType then
		InputHandler:ShowNotification("Select a tool first")
		return
	end
	
	-- Prepare interaction data
	local interactionData = {
		toolType = InputHandler.CurrentTool,
		playerPosition = player.Character and player.Character.PrimaryPart.Position,
		timestamp = os.time()
	}
	
	-- Send interaction to server
	local CatController = script.Parent.Parent.Parent
	CatController:InteractWithCat(catId, interactionType, interactionData)
		:andThen(function(result)
			if result.success then
				InputHandler:ShowInteractionSuccess(interactionType, catId)
				InputHandler:PlayInteractionEffect(interactionType, true)
			else
				InputHandler:ShowInteractionFailure(result.message or "Interaction failed")
				InputHandler:PlayInteractionEffect(interactionType, false)
			end
		end)
		:catch(function(error)
			InputHandler:ShowNotification("Interaction error: " .. tostring(error))
		end)
	
	print("Player interacting with cat", catId, "using", interactionType)
end

function InputHandler:GetInteractionTypeForTool(toolType)
	local toolToInteraction = {
		basicFood = "Feed",
		premiumFood = "Feed",
		basicToys = "Play",
		premiumToys = "Play",
		groomingTools = "Groom",
		medicalItems = "Heal",
		none = "Pet" -- Default interaction when no tool equipped
	}
	
	return toolToInteraction[toolType]
end

function InputHandler:GetNearestCat(playerPosition)
	local nearestCat = nil
	local nearestDistance = math.huge
	
	for _, catInfo in pairs(InputHandler.NearbyCats) do
		local distance = (playerPosition - catInfo.position).Magnitude
		if distance < nearestDistance and distance <= InputHandler.InteractionRange then
			nearestDistance = distance
			nearestCat = catInfo
		end
	end
	
	return nearestCat
end

function InputHandler:GetMouseTarget(mousePosition)
	-- Raycast from mouse position to find target
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	
	if not camera then return nil end
	
	-- Create ray from mouse position
	local ray = camera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = {player.Character}
	
	local raycastResult = workspace:Raycast(ray.Origin, ray.Direction * 100, raycastParams)
	
	if raycastResult then
		return raycastResult.Instance
	end
	
	return nil
end

function InputHandler:StartNearbyCatUpdates()
	-- Periodically update list of nearby cats
	task.spawn(function()
		while true do
			InputHandler:UpdateNearbyCats()
			task.wait(1) -- Update every second
		end
	end)
end

function InputHandler:UpdateNearbyCats()
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	-- Get parent controller
	local CatController = script.Parent.Parent.Parent
	
	-- For testing, use empty nearby cats list
	-- TODO: Implement proper cat detection when cat system is working
	InputHandler.NearbyCats = {}
	
	-- Simulate some nearby cats for testing
	if #InputHandler.NearbyCats == 0 then
		-- Add a test cat for demonstration
		table.insert(InputHandler.NearbyCats, {
			catId = "test_cat_1",
			position = humanoidRootPart.Position + Vector3.new(5, 0, 5),
			distance = 7.07,
			catData = {
				currentState = {position = humanoidRootPart.Position + Vector3.new(5, 0, 5)},
				moodState = {currentMood = "Happy"},
				behaviorState = {currentAction = "Idle"}
			}
		})
	end
	
	-- Update UI with nearby cat count
	InputHandler:UpdateNearbyCatUI(#InputHandler.NearbyCats)
end

function InputHandler:UpdateNearbyCatUI(catCount)
	-- This would update a UI element showing nearby cats
	-- For now, just log it
	if catCount > 0 and math.random() < 0.01 then -- Log occasionally to avoid spam
		print("Nearby cats:", catCount)
	end
end

function InputHandler:ShowNotification(message)
	-- Show a notification to the player
	print("Notification:", message)
	
	-- This would display a proper UI notification
	-- For now, we'll just use print
end

function InputHandler:ShowInteractionSuccess(interactionType, catId)
	local successMessages = {
		Feed = "Cat enjoyed the food!",
		Play = "Cat had fun playing!",
		Groom = "Cat appreciated the grooming!",
		Pet = "Cat enjoyed the pets!",
		Heal = "Cat feels better!"
	}
	
	local message = successMessages[interactionType] or "Interaction successful!"
	InputHandler:ShowNotification(message)
end

function InputHandler:ShowInteractionFailure(message)
	InputHandler:ShowNotification(message or "The cat wasn't interested")
end

function InputHandler:PlayToolEquipEffect(toolType)
	-- Play sound/effect when equipping tool
	-- This would be implemented with actual sounds/particles
	print("Tool equip effect:", toolType)
end

function InputHandler:PlayInteractionEffect(interactionType, success)
	-- Play sound/effect for interaction result
	-- This would be implemented with actual sounds/particles
	print("Interaction effect:", interactionType, "Success:", success)
end

function InputHandler:UpdateToolVisuals()
	-- Update UI to show current tool
	-- This would update a tool indicator in the UI
	-- For now, just log the current tool
	print("Tool visuals updated:", InputHandler.CurrentTool)
end

function InputHandler:GetToolDisplayName(toolType)
	local toolNames = {
		basicFood = "Basic Food",
		premiumFood = "Premium Food",
		basicToys = "Basic Toy",
		premiumToys = "Premium Toy",
		groomingTools = "Grooming Tool",
		medicalItems = "Medical Kit",
		none = "None"
	}
	
	return toolNames[toolType] or toolType
end

function InputHandler:IsOnCooldown(actionType)
	local cooldownEnd = InputHandler.InputCooldowns[actionType]
	return cooldownEnd and os.time() < cooldownEnd
end

function InputHandler:SetCooldown(actionType, duration)
	InputHandler.InputCooldowns[actionType] = os.time() + duration
end

function InputHandler:CleanupInputs()
	-- Unbind all actions
	ContextActionService:UnbindAction("SelectFoodTool")
	ContextActionService:UnbindAction("SelectToyTool")
	ContextActionService:UnbindAction("SelectGroomTool")
	ContextActionService:UnbindAction("InteractWithCat")
	
	print("InputHandler: Inputs cleaned up")
end

-- Component initialization
function InputHandler.Init()
	print("InputHandler component initialized")
end

function InputHandler.Start()
	print("InputHandler component started")
end

return InputHandler