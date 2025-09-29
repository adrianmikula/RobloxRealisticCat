local module = {}

-- External dependencies
local CatService

-- Cat interaction methods
function module:InteractWithCat(catId, interactionType, interactionData)
	if not CatService then
		return {success = false, message = "CatService not available"}
	end
	
	-- Validate interaction
	if not catId or not interactionType then
		return {success = false, message = "Invalid interaction parameters"}
	end
	
	-- Send interaction to server
	return CatService:InteractWithCat(catId, interactionType, interactionData)
end

function module:EquipTool(toolType)
	if not CatService then
		return {success = false, message = "CatService not available"}
	end
	
	-- Validate tool type
	local validTools = {"basicFood", "premiumFood", "basicToys", "premiumToys", "groomingTools", "medicalItems", "none"}
	local isValid = false
	for _, validTool in ipairs(validTools) do
		if toolType == validTool then
			isValid = true
			break
		end
	end
	
	if not isValid then
		return {success = false, message = "Invalid tool type: " .. toolType}
	end
	
	-- Equip tool through service
	return CatService:EquipTool(toolType)
end

function module:UnequipTool()
	if not CatService then
		return {success = false, message = "CatService not available"}
	end
	
	return CatService:UnequipTool()
end

-- Cat rendering and visual methods
function module:SpawnCatVisual(catId, catData)
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:SpawnCatVisual(catId, catData)
	end
	return false
end

function module:RemoveCatVisual(catId)
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:RemoveCatVisual(catId)
	end
	return false
end

function module:UpdateCatVisual(catId, catData)
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:UpdateCatVisual(catId, catData)
	end
	return false
end

-- Animation control methods
function module:PlayAnimation(catId, animationName, blendTime)
	local CatController = script.Parent.Parent.Parent
	local AnimationHandler = CatController.Components.AnimationHandler
	if AnimationHandler then
		return AnimationHandler:PlayAnimation(catId, animationName, blendTime)
	end
	return false
end

function module:StopAnimation(catId, animationName)
	local CatController = script.Parent.Parent.Parent
	local AnimationHandler = CatController.Components.AnimationHandler
	if AnimationHandler then
		return AnimationHandler:StopAnimation(catId, animationName)
	end
	return false
end

function module:BlendAnimations(catId, fromAnimation, toAnimation, blendTime)
	local CatController = script.Parent.Parent.Parent
	local AnimationHandler = CatController.Components.AnimationHandler
	if AnimationHandler then
		return AnimationHandler:BlendAnimations(catId, fromAnimation, toAnimation, blendTime)
	end
	return false
end

-- Action handling methods
function module:HandleAction(catId, actionType, actionData)
	local CatController = script.Parent.Parent.Parent
	local ActionHandler = CatController.Components.ActionHandler
	if ActionHandler then
		return ActionHandler:HandleAction(catId, actionType, actionData)
	end
	return false
end

function module:StopAction(catId)
	local CatController = script.Parent.Parent.Parent
	local ActionHandler = CatController.Components.ActionHandler
	if ActionHandler then
		return ActionHandler:StopAction(catId)
	end
	return false
end

-- Mood and visual effects methods
function module:UpdateMoodIndicator(catId, mood)
	local CatController = script.Parent.Parent.Parent
	local MoodVisualizer = CatController.Components.MoodVisualizer
	if MoodVisualizer then
		return MoodVisualizer:UpdateMoodIndicator(catId, mood)
	end
	return false
end

function module:PlayMoodEffect(catId, mood)
	local CatController = script.Parent.Parent.Parent
	local MoodVisualizer = CatController.Components.MoodVisualizer
	if MoodVisualizer then
		return MoodVisualizer:PlayMoodEffect(catId, mood)
	end
	return false
end

function module:StopMoodEffect(catId)
	local CatController = script.Parent.Parent.Parent
	local MoodVisualizer = CatController.Components.MoodVisualizer
	if MoodVisualizer then
		return MoodVisualizer:StopMoodEffect(catId)
	end
	return false
end

-- Input and interaction methods
function module:SetupInputs()
	local CatController = script.Parent.Parent.Parent
	local InputHandler = CatController.Components.InputHandler
	if InputHandler then
		return InputHandler:SetupInputs()
	end
	return false
end

function module:CleanupInputs()
	local CatController = script.Parent.Parent.Parent
	local InputHandler = CatController.Components.InputHandler
	if InputHandler then
		return InputHandler:CleanupInputs()
	end
	return false
end

-- Tool management methods
function module:CreateToolVisual(toolType)
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:CreateToolVisual(toolType)
	end
	return nil
end

function module:AttachToolToPlayer(toolInstance)
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:AttachToolToPlayer(toolInstance)
	end
	return false
end

function module:PlayToolEffect(toolType, success)
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:PlayUseEffect(toolType, success)
	end
	return false
end

-- Performance optimization methods
function module:SetPerformanceMode(mode)
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:SetPerformanceMode(mode)
	end
	return false
end

function module:UpdateLODForCat(catId, lodLevel)
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:UpdateLODForCat(catId, lodLevel)
	end
	return false
end

function module:CullDistantCats()
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:CullDistantCats()
	end
	return false
end

-- Cleanup methods
function module:CleanupAllActions()
	local CatController = script.Parent.Parent.Parent
	local ActionHandler = CatController.Components.ActionHandler
	if ActionHandler then
		return ActionHandler:CleanupAllActions()
	end
	return false
end

function module:CleanupAllTools()
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:CleanupAllTools()
	end
	return false
end

function module:CleanupAllVisuals()
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:CleanupAllVisuals()
	end
	return false
end

-- Notification and UI methods
function module:ShowNotification(message, duration)
	-- Simple notification system (placeholder)
	print("Notification:", message)
	
	-- This would interface with a proper UI system
	return true
end

function module:ShowInteractionResult(success, message)
	local color = success and "green" or "red"
	module:ShowNotification(message, 3)
	
	-- Play appropriate sound/effect
	if success then
		-- Play success sound
	else
		-- Play failure sound
	end
	
	return true
end

function module.Start()
	print("CatController Set() component started")
end

function module.Init()
	-- Get reference to CatService
	local CatController = script.Parent.Parent.Parent
	CatService = CatController.CatService
	
	print("CatController Set() component initialized")
end

return module
