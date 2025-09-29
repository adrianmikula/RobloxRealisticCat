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
	local catData = CatService.Components.CatManager:CreateCat(catId, profileType)
	CatService.ActiveCats[catId] = catData
	
	-- Initialize AI behavior
	CatService.Components.CatAI:InitializeCat(catId, catData)
	
	-- Notify clients
	CatService.Client.CatStateUpdate:FireAll(catId, "created", catData)
	
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