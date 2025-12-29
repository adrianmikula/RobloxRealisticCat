local GetComponent = {}

-- External dependencies
local CatService

function GetComponent:GetCat(catId)
	return CatService.ActiveCats[catId]
end

function GetComponent:GetAllCats()
	return CatService.ActiveCats
end

function GetComponent:GetCatCount()
	local count = 0
	for _ in pairs(CatService.ActiveCats) do
		count += 1
	end
	return count
end

function GetComponent:GetPlayerRelationship(player, catId)
	local RelationshipManager = CatService.Components.RelationshipManager
	if RelationshipManager then
		return RelationshipManager:GetRelationship(player, catId)
	end
	return nil
end

function GetComponent:GetAllPlayerRelationships(player)
	local RelationshipManager = CatService.Components.RelationshipManager
	if RelationshipManager then
		return RelationshipManager:GetAllPlayerRelationships(player)
	end
	return {}
end

function GetComponent:GetPlayerStats(player)
	local RelationshipManager = CatService.Components.RelationshipManager
	if RelationshipManager then
		return RelationshipManager:GetPlayerStats(player)
	end
	return {}
end

function GetComponent:GetNearbyCats(position, radius)
	local nearbyCats = {}
	
	for catId, catData in pairs(CatService.ActiveCats) do
		local catPosition = catData.currentState.position
		local distance = (position - catPosition).Magnitude
		
		if distance <= radius then
			table.insert(nearbyCats, {
				catId = catId,
				catData = catData,
				distance = distance
			})
		end
	end
	
	-- Sort by distance
	table.sort(nearbyCats, function(a, b) return a.distance < b.distance end)
	
	return nearbyCats
end

function GetComponent:GetCatProfile(catId)
	local catData = CatService.ActiveCats[catId]
	if catData then
		return catData.profile
	end
	return nil
end

function GetComponent:GetCatMood(catId)
	local catData = CatService.ActiveCats[catId]
	if catData then
		return catData.moodState
	end
	return nil
end

function GetComponent:GetCatPhysicalState(catId)
	local catData = CatService.ActiveCats[catId]
	if catData then
		return catData.physicalState
	end
	return nil
end

function GetComponent:GetCatBehavior(catId)
	local catData = CatService.ActiveCats[catId]
	if catData then
		return catData.behaviorState
	end
	return nil
end

function GetComponent:IsCatInteracting(catId)
	local catData = CatService.ActiveCats[catId]
	if catData then
		return catData.behaviorState.isInteracting
	end
	return false
end

function GetComponent:GetPlayerTools(player)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		return PlayerManager.PlayerTools[player.UserId] or {}
	end
	return {}
end

function GetComponent:GetPlayerSettings(player)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		return PlayerManager:GetPlayerSettings(player)
	end
	return {}
end

function GetComponent:GetCurrentTool(player)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		return PlayerManager:GetCurrentTool(player)
	end
	return "none"
end

function GetComponent:CanPlayerInteract(player, interactionType)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		return PlayerManager:CanInteract(player, interactionType)
	end
	return false
end

function GetComponent:GetServiceStats()
	return {
		totalCats = GetComponent:GetCatCount(),
		activePlayers = #CatService.Components.PlayerManager:GetAllActivePlayers(),
		serviceUptime = os.time() - (CatService.ServiceStartTime or os.time())
	}
end

-- Component initialization
function GetComponent.Init()
	-- Get reference to parent CatService
	CatService = script.Parent.Parent
	
	print("CatService GetComponent initialized")
end

function GetComponent.Start()
	print("CatService GetComponent started")
end

return GetComponent