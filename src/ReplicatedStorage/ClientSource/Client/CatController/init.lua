local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local CatController = Knit.CreateController({
	Name = "CatController",
	
	-- Controller properties
	ActiveCatInstances = {},
	CatVisuals = {},
	PlayerTools = {},
})

---- Components
--- component utilities
local componentsInitializer = require(ReplicatedStorage.SharedSource.Utilities.ScriptsLoader.ComponentsInitializer)
--- component folders
local componentsFolder = script:WaitForChild("Components", 5)
CatController.Components = {}
for _, v in pairs(componentsFolder:WaitForChild("Others", 10):GetChildren()) do
	CatController.Components[v.Name] = require(v)
end
CatController.GetComponent = require(componentsFolder["Get()"])
CatController.SetComponent = require(componentsFolder["Set()"])

---- Knit Services
local CatService

---- Knit Controllers

-- Cat rendering and animation methods
function CatController:CreateCatVisual(catId, catData)
	local catVisual = CatController.Components.CatRenderer:SpawnCatVisual(catId, catData)
	CatController.ActiveCatInstances[catId] = catVisual
	CatController.CatVisuals[catId] = catData
	
	return catVisual
end

function CatController:RemoveCatVisual(catId)
	if CatController.ActiveCatInstances[catId] then
		CatController.Components.CatRenderer:RemoveCatVisual(catId)
		CatController.ActiveCatInstances[catId] = nil
		CatController.CatVisuals[catId] = nil
	end
end

function CatController:UpdateCatAnimation(catId, animationState)
	CatController.Components.AnimationHandler:PlayAnimation(catId, animationState)
end

function CatController:UpdateCatMoodVisual(catId, moodState)
	CatController.Components.MoodVisualizer:UpdateMoodIndicator(catId, moodState)
end

-- Player interaction methods
function CatController:InteractWithCat(catId, interactionType, interactionData)
	local result = CatService:InteractWithCat(catId, interactionType, interactionData)
	return result
end

function CatController:EquipTool(toolType)
	CatController.Components.ToolManager:EquipTool(toolType)
end

function CatController:UnequipTool()
	CatController.Components.ToolManager:UnequipTool()
end

-- Input handling
function CatController:SetupInputHandling()
	CatController.Components.InputHandler:SetupInputs()
end

-- Server communication handlers
function CatController:HandleCatStateUpdate(catId, updateType, catData)
	if updateType == "created" then
		CatController:CreateCatVisual(catId, catData)
	elseif updateType == "removed" then
		CatController:RemoveCatVisual(catId)
	elseif updateType == "updated" then
		CatController.Components.CatRenderer:UpdateCatVisual(catId, catData)
		CatController:UpdateCatAnimation(catId, catData.currentAction)
		CatController:UpdateCatMoodVisual(catId, catData.currentMood)
	end
end

function CatController:HandleCatActionUpdate(catId, actionType, actionData)
	CatController.Components.ActionHandler:HandleAction(catId, actionType, actionData)
end

-- Performance optimization methods
function CatController:SetPerformanceMode(mode)
	CatController.Components.CatRenderer:SetPerformanceMode(mode)
end

function CatController:UpdateLODForCat(catId, lodLevel)
	CatController.Components.CatRenderer:UpdateLODForCat(catId, lodLevel)
end

function CatController:CullDistantCats()
	CatController.Components.CatRenderer:CullDistantCats()
end

-- Cleanup methods
function CatController:CleanupAllActions()
	CatController.Components.ActionHandler:CleanupAllActions()
end

-- Client method wrappers for components
function CatController:GetPlayerTools()
	if not CatService then return {} end
	return CatService:GetPlayerTools()
end

function CatController:EquipTool(toolType)
	if not CatService then 
		return {success = false, message = "CatService not available"}
	end
	return CatService:EquipTool(toolType)
end

function CatController:GetAllCats()
	if not CatService then return {} end
	return CatService:GetAllCats()
end

function CatController:CleanupAllTools()
	CatController.Components.ToolManager:CleanupAllTools()
end

function CatController:CleanupAllVisuals()
	CatController.Components.CatRenderer:CleanupAllVisuals()
end

function CatController:CleanupInputs()
	CatController.Components.InputHandler:CleanupInputs()
end

function CatController:KnitStart() 
	-- Setup input handling
	CatController:SetupInputHandling()
	
	-- Listen to server updates
	CatService.CatStateUpdate:Connect(function(catId, updateType, catData)
		CatController:HandleCatStateUpdate(catId, updateType, catData)
	end)
	
	CatService.CatActionUpdate:Connect(function(catId, actionType, actionData)
		CatController:HandleCatActionUpdate(catId, actionType, actionData)
	end)
	
	-- Initialize existing cats
	task.spawn(function()
		task.wait(2) -- Wait for server to be ready
		CatService:GetAllCats()
			:andThen(function(allCats)
				for catId, catData in pairs(allCats) do
					CatController:HandleCatStateUpdate(catId, "created", catData)
				end
			end)
			:catch(function(err)
				warn("Failed to get initial cats:", err)
			end)
	end)
	
	-- Start performance optimization loop
	task.spawn(function()
		while true do
			CatController:CullDistantCats()
			task.wait(5) -- Update LOD every 5 seconds
		end
	end)
	
	print("CatController started successfully")
end

function CatController:KnitInit() 
	CatService = Knit.GetService("CatService")
	
	-- Store CatService reference for components to access
	CatController.CatService = CatService
	
	componentsInitializer(script)
	
	print("CatController initialized successfully")
end

return CatController