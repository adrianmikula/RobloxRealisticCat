local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Knit = require(ReplicatedStorage.Packages.Knit)

local CatService = Knit.CreateService({
	Name = "CatService",
	Client = {
		CatStateUpdate = Knit.CreateSignal(),
		CatActionUpdate = Knit.CreateSignal(),
		PlayerInteraction = Knit.CreateSignal(),
	},

	-- Service properties
	ActiveCats = {},
	CatProfiles = {},
	PlayerCatRelationships = {},
})

---- Datas
local sharedDatas = ReplicatedStorage:WaitForChild("SharedSource").Datas
local CatProfileData = require(sharedDatas.CatProfileData)

---- Utilities
local Utilities = ReplicatedStorage:WaitForChild("SharedSource").Utilities

---- Knit Services
local ProfileService

---- Components
--- component utilities
local componentsInitializer = require(ReplicatedStorage.SharedSource.Utilities.ScriptsLoader.ComponentsInitializer)
--- component folders
local componentsFolder = script:WaitForChild("Components", 5)
CatService.Components = {}
for _, v in pairs(componentsFolder:WaitForChild("Others", 10):GetChildren()) do
	CatService.Components[v.Name] = require(v)
end
local self_GetComponent = require(componentsFolder["Get()"])
CatService.GetComponent = self_GetComponent
CatService.SetComponent = require(componentsFolder["Set()"])

-- Cat management methods
function CatService:CreateCat(catId, profileType)
	print("🔧 [CreateCat] Starting - catId:", catId, "profileType:", profileType)
	
	-- Check if CatManager component exists
	if not CatService.Components.CatManager then
		print("❌ [CreateCat] ERROR: CatManager component not found in CatService.Components")
		print("   Available components:", table.concat(table.keys(CatService.Components or {}), ", "))
		return nil
	end
	
	print("✅ [CreateCat] CatManager component found")
	
	-- Create cat data
	local catData = CatService.Components.CatManager:CreateCat(catId, profileType)
	
	if not catData then
		print("❌ [CreateCat] ERROR: CatManager:CreateCat returned nil")
		return nil
	end
	
	print("✅ [CreateCat] Cat data created successfully")
	print("   - catId:", catId)
	print("   - mood:", catData.moodState and catData.moodState.currentMood or "unknown")
	print("   - position:", catData.currentState and catData.currentState.position or "unknown")
	
	-- Store in active cats
	CatService.ActiveCats[catId] = catData
	print("✅ [CreateCat] Added to ActiveCats table")
	
	-- Initialize AI behavior
	if CatService.Components.CatAI then
		CatService.Components.CatAI:InitializeCat(catId, catData)
		print("✅ [CreateCat] AI initialized")
	else
		print("⚠️ [CreateCat] WARNING: CatAI component not found")
	end
	
	-- Notify clients
	CatService.Client.CatStateUpdate:FireAll(catId, "created", catData)
	print("✅ [CreateCat] Client notification sent")
	
	print("🎉 [CreateCat] COMPLETED SUCCESSFULLY - cat:", catId)
	return catData
end

function CatService:RemoveCat(catId)
	if CatService.ActiveCats[catId] then
		CatService.Components.CatAI:CleanupCat(catId)
		CatService.ActiveCats[catId] = nil
		CatService.Client.CatStateUpdate:FireAll(catId, "removed", nil)
	end
end

function CatService:GetCatState(catId)
	return CatService.ActiveCats[catId]
end

function CatService:GetAllCats()
	return CatService.ActiveCats
end

-- Player interaction methods
function CatService.Client:InteractWithCat(player, catId, interactionType, interactionData)
	local result = CatService.Components.InteractionHandler:HandleInteraction(player, catId, interactionType, interactionData)
	return result
end

-- Client method for spawning cats
function CatService.Client:SpawnCat(player, profileType, position)
	-- Generate a unique cat ID
	local catId = "player_cat_" .. player.UserId .. "_" .. os.time()
	
	-- Create the cat on the server
	local catData = CatService:CreateCat(catId, profileType or "Friendly")
	
	-- Set position if provided
	if position then
		catData.currentState.position = position
	end
	
	print("Spawned cat for player", player.Name, "cat ID:", catId, "profile:", profileType or "Friendly")
	
	return catId, catData
end

-- Client method for getting all cats
function CatService.Client:GetAllCats(player)
	-- Return a safe copy of active cats (without sensitive data)
	local safeCats = {}
	
	for catId, catData in pairs(CatService.ActiveCats) do
		safeCats[catId] = {
			currentState = catData.currentState,
			moodState = catData.moodState,
			behaviorState = catData.behaviorState,
			profile = {
				personality = catData.profile.personality,
				breed = catData.profile.breed
			}
		}
	end
	
	return safeCats
end

-- Client method for getting player tools
function CatService.Client:GetPlayerTools(player)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		return PlayerManager.PlayerTools[player.UserId] or {}
	end
	return {}
end

-- Client method for equipping tools
function CatService.Client:EquipTool(player, toolType)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		local success = PlayerManager:EquipTool(player, toolType)
		if success then
			return {success = true, message = "Tool equipped: " .. toolType}
		else
			return {success = false, message = "Failed to equip tool: " .. toolType}
		end
	end
	return {success = false, message = "PlayerManager not available"}
end

function CatService:UpdatePlayerRelationship(player, catId, relationshipChange)
	CatService.Components.RelationshipManager:UpdateRelationship(player, catId, relationshipChange)
end

-- AI update loop
function CatService:StartAIUpdates()
	while true do
		task.wait(0.1) -- Update 10 times per second for performance
		
		for catId, catData in pairs(CatService.ActiveCats) do
			CatService.Components.CatAI:UpdateCat(catId, catData)
		end
	end
end

function CatService:KnitStart()
	-- Start AI update loop
	task.spawn(function()
		CatService:StartAIUpdates()
	end)
	
	-- Handle player connections
	Players.PlayerAdded:Connect(function(player)
		CatService.Components.PlayerManager:HandlePlayerAdded(player)
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		CatService.Components.PlayerManager:HandlePlayerRemoved(player)
	end)
end

function CatService:KnitInit()
	ProfileService = Knit.GetService("ProfileService")
	
	componentsInitializer(script)
end

return CatService