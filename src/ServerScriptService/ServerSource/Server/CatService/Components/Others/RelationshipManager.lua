local RelationshipManager = {}

-- External dependencies
local ProfileService

-- Internal state
local RelationshipManager = {
	PlayerRelationships = {} -- [playerUserId][catId] = relationshipData
}

function RelationshipManager:UpdateRelationship(player, catId, change)
	local relationship = RelationshipManager:GetRelationship(player, catId)
	
	-- Update trust level
	local oldTrust = relationship.trustLevel or 0.5
	local newTrust = math.clamp(oldTrust + change, 0, 1)
	
	relationship.trustLevel = newTrust
	relationship.lastInteraction = os.time()
	
	-- Calculate relationship score based on trust and interaction history
	relationship.relationshipScore = RelationshipManager:CalculateRelationshipScore(relationship)
	
	-- Save to player profile
	RelationshipManager:SaveRelationshipToProfile(player, catId, relationship)
	
	print(string.format("Relationship updated: %s with cat %s - Trust: %.2f (change: %.2f)", 
		player.Name, catId, newTrust, change))
	
	return relationship
end

function RelationshipManager:GetRelationship(player, catId)
	local userId = player.UserId
	
	-- Initialize player relationships if needed
	if not RelationshipManager.PlayerRelationships[userId] then
		RelationshipManager.PlayerRelationships[userId] = {}
	end
	
	-- Initialize cat relationship if needed
	if not RelationshipManager.PlayerRelationships[userId][catId] then
		RelationshipManager.PlayerRelationships[userId][catId] = RelationshipManager:CreateNewRelationship()
		
		-- Try to load from profile
		RelationshipManager:LoadRelationshipFromProfile(player, catId)
	end
	
	return RelationshipManager.PlayerRelationships[userId][catId]
end

function RelationshipManager:GetAllPlayerRelationships(player)
	local userId = player.UserId
	return RelationshipManager.PlayerRelationships[userId] or {}
end

function RelationshipManager:CreateNewRelationship()
	return {
		trustLevel = 0.5,
		relationshipScore = 0,
		interactionHistory = {},
		lastInteraction = 0,
		firstInteraction = os.time(),
		favoriteActivities = {},
		relationshipTier = "Neutral"
	}
end

function RelationshipManager:CalculateRelationshipScore(relationship)
	local score = 0
	
	-- Base score from trust level (0-50 points)
	score += relationship.trustLevel * 50
	
	-- Bonus for interaction frequency (0-30 points)
	local interactionCount = #relationship.interactionHistory
	local frequencyBonus = math.min(interactionCount * 0.5, 30)
	score += frequencyBonus
	
	-- Bonus for recent interactions (0-20 points)
	local timeSinceLast = os.time() - relationship.lastInteraction
	local recencyBonus = math.max(0, 20 - (timeSinceLast / 3600)) -- decays over hours
	score += recencyBonus
	
	-- Cap at 100
	return math.min(score, 100)
end

function RelationshipManager:GetRelationshipTier(relationship)
	local score = relationship.relationshipScore or 0
	
	if score >= 90 then
		return "Best Friends"
	elseif score >= 75 then
		return "Close Friends"
	elseif score >= 60 then
		return "Friends"
	elseif score >= 40 then
		return "Acquaintances"
	elseif score >= 20 then
		return "Neutral"
	else
		return "Strangers"
	end
end

function RelationshipManager:SaveRelationshipToProfile(player, catId, relationship)
	if not ProfileService then return end
	
	local profile = ProfileService:GetProfile(player)
	if not profile then return end
	
	-- Update profile data
	profile.Data.catRelationships[catId] = {
		trustLevel = relationship.trustLevel,
		relationshipScore = relationship.relationshipScore,
		interactionHistory = relationship.interactionHistory,
		lastInteraction = relationship.lastInteraction,
		firstInteraction = relationship.firstInteraction,
		favoriteActivities = relationship.favoriteActivities,
		relationshipTier = RelationshipManager:GetRelationshipTier(relationship)
	}
	
	-- Update relationship tier
	relationship.relationshipTier = RelationshipManager:GetRelationshipTier(relationship)
end

function RelationshipManager:LoadRelationshipFromProfile(player, catId)
	if not ProfileService then return end
	
	local profile = ProfileService:GetProfile(player)
	if not profile or not profile.Data then return end
	
	local savedRelationship = profile.Data.catRelationships[catId]
	if not savedRelationship then return end
	
	-- Load relationship data
	local currentRelationship = RelationshipManager:GetRelationship(player, catId)
	
	currentRelationship.trustLevel = savedRelationship.trustLevel or 0.5
	currentRelationship.relationshipScore = savedRelationship.relationshipScore or 0
	currentRelationship.interactionHistory = savedRelationship.interactionHistory or {}
	currentRelationship.lastInteraction = savedRelationship.lastInteraction or 0
	currentRelationship.firstInteraction = savedRelationship.firstInteraction or os.time()
	currentRelationship.favoriteActivities = savedRelationship.favoriteActivities or {}
	currentRelationship.relationshipTier = savedRelationship.relationshipTier or "Neutral"
	
	print(string.format("Loaded relationship for %s with cat %s - Tier: %s", 
		player.Name, catId, currentRelationship.relationshipTier))
end

function RelationshipManager:GetPlayerStats(player)
	local relationships = RelationshipManager:GetAllPlayerRelationships(player)
	local stats = {
		totalCatsInteracted = 0,
		uniqueCatsMet = 0,
		longestRelationship = 0,
		averageTrustLevel = 0,
		mostTrustedCat = "",
		highestRelationshipScore = 0
	}
	
	local totalTrust = 0
	local catCount = 0
	
	for catId, relationship in pairs(relationships) do
		catCount += 1
		stats.totalCatsInteracted += #relationship.interactionHistory
		stats.uniqueCatsMet += 1
		
		totalTrust += relationship.trustLevel
		
		-- Check for longest relationship
		local relationshipDuration = os.time() - relationship.firstInteraction
		if relationshipDuration > stats.longestRelationship then
			stats.longestRelationship = relationshipDuration
		end
		
		-- Check for highest relationship score
		if relationship.relationshipScore > stats.highestRelationshipScore then
			stats.highestRelationshipScore = relationship.relationshipScore
			stats.mostTrustedCat = catId
		end
	end
	
	if catCount > 0 then
		stats.averageTrustLevel = totalTrust / catCount
	end
	
	return stats
end

function RelationshipManager:HandlePlayerAdded(player)
	-- Load all relationships for this player
	RelationshipManager:LoadAllPlayerRelationships(player)
	
	print("Loaded relationships for player:", player.Name)
end

function RelationshipManager:HandlePlayerRemoved(player)
	local userId = player.UserId
	
	-- Save all relationships before player leaves
	for catId, relationship in pairs(RelationshipManager.PlayerRelationships[userId] or {}) do
		RelationshipManager:SaveRelationshipToProfile(player, catId, relationship)
	end
	
	-- Clear from memory
	RelationshipManager.PlayerRelationships[userId] = nil
	
	print("Saved and cleared relationships for player:", player.Name)
end

function RelationshipManager:LoadAllPlayerRelationships(player)
	if not ProfileService then return end
	
	local profile = ProfileService:GetProfile(player)
	if not profile or not profile.Data then return end
	
	for catId, savedRelationship in pairs(profile.Data.catRelationships or {}) do
		-- Ensure relationship exists in memory
		local currentRelationship = RelationshipManager:GetRelationship(player, catId)
		
		-- Update with saved data
		currentRelationship.trustLevel = savedRelationship.trustLevel or 0.5
		currentRelationship.relationshipScore = savedRelationship.relationshipScore or 0
		currentRelationship.interactionHistory = savedRelationship.interactionHistory or {}
		currentRelationship.lastInteraction = savedRelationship.lastInteraction or 0
		currentRelationship.firstInteraction = savedRelationship.firstInteraction or os.time()
		currentRelationship.favoriteActivities = savedRelationship.favoriteActivities or {}
		currentRelationship.relationshipTier = savedRelationship.relationshipTier or "Neutral"
	end
	
	print(string.format("Loaded %d relationships for player %s", 
		#profile.Data.catRelationships, player.Name))
end

-- Component initialization
function RelationshipManager.Init()
	-- Load dependencies
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Knit = require(ReplicatedStorage.Packages.Knit)
	ProfileService = Knit.GetService("ProfileService")
	
	print("RelationshipManager component initialized")
end

function RelationshipManager.Start()
	print("RelationshipManager component started")
end

return RelationshipManager