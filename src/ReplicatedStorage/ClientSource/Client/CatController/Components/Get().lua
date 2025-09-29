local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local module = {}

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()

---- Utilities


---- Knit Controllers

---- Knit Services
local CatService


---- Datas


---- Assets

-- Cat data accessors
function module:GetCatState(catId)
	if not CatService then return nil end
	return CatService:GetCatState(catId)
end

function module:GetAllCats()
	if not CatService then return {} end
	return CatService:GetAllCats()
end

function module:GetNearbyCats(playerPosition, range)
	local allCats = module:GetAllCats()
	local nearbyCats = {}
	
	for catId, catData in pairs(allCats) do
		local catPosition = catData.currentState.position
		local distance = (playerPosition - catPosition).Magnitude
		
		if distance <= (range or 50) then
			nearbyCats[catId] = {
				catId = catId,
				position = catPosition,
				distance = distance,
				catData = catData
			}
		end
	end
	
	return nearbyCats
end

function module:GetCatVisual(catId)
	-- Get the visual model for a cat
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:GetCatVisual(catId)
	end
	return nil
end

function module:GetActiveAction(catId)
	-- Get current action for a cat
	local CatController = script.Parent.Parent.Parent
	local ActionHandler = CatController.Components.ActionHandler
	if ActionHandler then
		return ActionHandler:GetActiveAction(catId)
	end
	return nil
end

function module:IsActionActive(catId)
	-- Check if cat has an active action
	local CatController = script.Parent.Parent.Parent
	local ActionHandler = CatController.Components.ActionHandler
	if ActionHandler then
		return ActionHandler:IsActionActive(catId)
	end
	return false
end

-- Player data accessors
function module:GetPlayerTools(player)
	if not CatService then return {} end
	return CatService:GetPlayerTools(player)
end

function module:GetPlayerSettings(player)
	if not CatService then return {} end
	return CatService:GetPlayerSettings(player)
end

function module:GetPlayerStats(player)
	if not CatService then return {} end
	return CatService:GetPlayerStats(player)
end

function module:GetEquippedTool()
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:GetEquippedTool()
	end
	return "none"
end

function module:HasToolEquipped()
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:HasToolEquipped()
	end
	return false
end

function module:GetToolEffectiveness(toolType)
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:GetToolEffectiveness(toolType)
	end
	return 1.0
end

function module:GetToolCooldown(toolType)
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:GetToolCooldown(toolType)
	end
	return 5
end

function module:IsToolOnCooldown(toolType)
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:IsToolOnCooldown(toolType)
	end
	return false
end

function module:GetRemainingCooldown(toolType)
	local CatController = script.Parent.Parent.Parent
	local ToolManager = CatController.Components.ToolManager
	if ToolManager then
		return ToolManager:GetRemainingCooldown(toolType)
	end
	return 0
end

-- Animation accessors
function module:GetCurrentAnimation(catId)
	local CatController = script.Parent.Parent.Parent
	local AnimationHandler = CatController.Components.AnimationHandler
	if AnimationHandler then
		return AnimationHandler:GetCurrentAnimation(catId)
	end
	return nil
end

function module:IsAnimationPlaying(catId, animationName)
	local CatController = script.Parent.Parent.Parent
	local AnimationHandler = CatController.Components.AnimationHandler
	if AnimationHandler then
		return AnimationHandler:IsAnimationPlaying(catId, animationName)
	end
	return false
end

-- Mood and visual accessors
function module:GetCatMood(catId)
	local catState = module:GetCatState(catId)
	if catState then
		return catState.currentMood
	end
	return "neutral"
end

function module:GetMoodColor(mood)
	local moodColors = {
		happy = Color3.fromRGB(100, 255, 100),
		content = Color3.fromRGB(200, 255, 100),
		neutral = Color3.fromRGB(255, 255, 100),
		anxious = Color3.fromRGB(255, 200, 100),
		stressed = Color3.fromRGB(255, 100, 100),
		scared = Color3.fromRGB(200, 100, 200),
		angry = Color3.fromRGB(255, 50, 50)
	}
	
	return moodColors[mood] or Color3.fromRGB(255, 255, 255)
end

function module:GetMoodIndicator(catId)
	local CatController = script.Parent.Parent.Parent
	local MoodVisualizer = CatController.Components.MoodVisualizer
	if MoodVisualizer then
		return MoodVisualizer:GetMoodIndicator(catId)
	end
	return nil
end

-- Performance and optimization accessors
function module:GetActiveCatCount()
	local allCats = module:GetAllCats()
	return #allCats
end

function module:GetVisibleCatCount()
	-- Count cats that are currently rendered/visible
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:GetRenderedCatCount()
	end
	return 0
end

function module:GetPerformanceMode()
	-- Get current performance optimization mode
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:GetPerformanceMode()
	end
	return "balanced"
end

function module:GetLODLevel(catId)
	-- Get current LOD level for a cat
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:GetLODLevel(catId)
	end
	return 1
end

function module.Start()
	print("CatController Get() component started")
end

function module.Init()
	-- Get reference to CatService
	local CatController = script.Parent.Parent.Parent
	CatService = CatController.CatService
	
	print("CatController Get() component initialized")
end

return module
