local InteractionHandler = {}

-- External dependencies
local CatProfileData

-- Internal state
local InteractionHandler = {
	PendingInteractions = {},
	InteractionCooldowns = {}
}

function InteractionHandler:HandleInteraction(player, catId, interactionType, interactionData)
	-- Check cooldown
	if InteractionHandler:IsOnCooldown(player, catId, interactionType) then
		return {success = false, message = "Interaction on cooldown"}
	end
	
	-- Get cat data
	local CatService = script.Parent.Parent.Parent
	local catData = CatService.GetComponent:GetCat(catId)
	if not catData then
		return {success = false, message = "Cat not found"}
	end
	
	-- Get interaction effects
	local interactionEffects = CatProfileData.GetInteractionEffects(interactionType)
	
	-- Calculate success chance based on relationship and mood
	local successChance = InteractionHandler:CalculateSuccessChance(player, catId, interactionType, catData)
	
	-- Determine outcome
	local success = math.random() <= successChance
	local result = {
		success = success,
		interactionType = interactionType,
		effects = {}
	}
	
	if success then
		-- Apply successful interaction effects
		result.effects = InteractionHandler:ApplySuccessfulInteraction(player, catId, interactionType, catData, interactionEffects)
		result.message = "Interaction successful!"
	else
		-- Apply failed interaction effects
		result.effects = InteractionHandler:ApplyFailedInteraction(player, catId, interactionType, catData)
		result.message = "Interaction failed - cat was not interested"
	end
	
	-- Set cooldown
	InteractionHandler:SetCooldown(player, catId, interactionType)
	
	-- Log interaction
	InteractionHandler:LogInteraction(player, catId, interactionType, success, result.effects)
	
	print(string.format("Interaction: %s with cat %s - Success: %s", interactionType, catId, success))
	
	return result
end

function InteractionHandler:CalculateSuccessChance(player, catId, interactionType, catData)
	local baseChance = CatProfileData.GetInteractionEffects(interactionType).successChance or 0.5
	
	-- Relationship modifier
	local relationship = InteractionHandler:GetPlayerRelationship(player, catId)
	local relationshipModifier = 0.5 + (relationship.trustLevel or 0.5)
	
	-- Mood modifier
	local moodEffects = CatProfileData.GetMoodEffects(catData.moodState.currentMood)
	local moodModifier = moodEffects.interactionChance or 1.0
	
	-- Personality modifier
	local personality = catData.profile.personality
	local personalityModifier = 1.0
	
	if interactionType == "Pet" then
		personalityModifier = personality.friendliness
	elseif interactionType == "Play" then
		personalityModifier = personality.playfulness
	elseif interactionType == "Feed" then
		personalityModifier = 1.0 -- All cats like food
	end
	
	-- Final success chance
	local successChance = baseChance * relationshipModifier * moodModifier * personalityModifier
	
	-- Clamp between 0.1 and 0.95
	return math.clamp(successChance, 0.1, 0.95)
end

function InteractionHandler:ApplySuccessfulInteraction(player, catId, interactionType, catData, interactionEffects)
	local effects = {}
	
	-- Update relationship
	local relationshipChange = interactionEffects.relationshipChange or 0.1
	InteractionHandler:UpdateRelationship(player, catId, relationshipChange)
	effects.relationshipChange = relationshipChange
	
	-- Update mood
	if interactionEffects.moodEffect then
		local CatService = script.Parent.Parent.Parent
		CatService.SetComponent:UpdateCatMood(catId, interactionEffects.moodEffect, 0.7)
		effects.moodEffect = interactionEffects.moodEffect
	end
	
	-- Update physical state
	if interactionEffects.hungerReduction then
		catData.physicalState.hunger = math.max(0, catData.physicalState.hunger - interactionEffects.hungerReduction)
		effects.hungerReduction = interactionEffects.hungerReduction
	end
	
	if interactionEffects.energyCost then
		catData.physicalState.energy = math.max(0, catData.physicalState.energy - interactionEffects.energyCost)
		effects.energyCost = interactionEffects.energyCost
	end
	
	-- Update cat's current action
	catData.behaviorState.currentAction = interactionType
	catData.behaviorState.isInteracting = true
	
	-- Set interaction timeout
	task.delay(3, function()
		catData.behaviorState.isInteracting = false
		if catData.behaviorState.currentAction == interactionType then
			catData.behaviorState.currentAction = "Idle"
		end
	end)
	
	return effects
end

function InteractionHandler:ApplyFailedInteraction(player, catId, interactionType, catData)
	local effects = {}
	
	-- Small negative relationship impact
	local relationshipChange = -0.05
	InteractionHandler:UpdateRelationship(player, catId, relationshipChange)
	effects.relationshipChange = relationshipChange
	
	-- Possible mood change to annoyed
	if math.random() < 0.3 then
		local CatService = script.Parent.Parent.Parent
		CatService.SetComponent:UpdateCatMood(catId, "Annoyed", 0.4)
		effects.moodEffect = "Annoyed"
	end
	
	return effects
end

function InteractionHandler:GetPlayerRelationship(player, catId)
	-- Get the parent CatService to access relationship manager
	local CatService = script.Parent.Parent.Parent
	return CatService.GetComponent:GetPlayerRelationship(player, catId) or {
		trustLevel = 0.5,
		interactionHistory = {},
		lastInteraction = 0
	}
end

function InteractionHandler:UpdateRelationship(player, catId, change)
	-- Get the parent CatService to update relationship
	local CatService = script.Parent.Parent.Parent
	CatService.SetComponent:UpdatePlayerRelationship(player, catId, change)
end

function InteractionHandler:IsOnCooldown(player, catId, interactionType)
	local key = player.UserId .. "_" .. catId .. "_" .. interactionType
	local cooldownEnd = InteractionHandler.InteractionCooldowns[key]
	
	if cooldownEnd and os.time() < cooldownEnd then
		return true
	end
	
	return false
end

function InteractionHandler:SetCooldown(player, catId, interactionType)
	local key = player.UserId .. "_" .. catId .. "_" .. interactionType
	local cooldownDuration = 2 -- seconds
	
	InteractionHandler.InteractionCooldowns[key] = os.time() + cooldownDuration
	
	-- Clean up old cooldowns
	for k, endTime in pairs(InteractionHandler.InteractionCooldowns) do
		if os.time() > endTime then
			InteractionHandler.InteractionCooldowns[k] = nil
		end
	end
end

function InteractionHandler:LogInteraction(player, catId, interactionType, success, effects)
	local relationship = InteractionHandler:GetPlayerRelationship(player, catId)
	
	-- Add to interaction history
	table.insert(relationship.interactionHistory, {
		type = interactionType,
		timestamp = os.time(),
		outcome = success and "positive" or "negative",
		effects = effects
	})
	
	-- Keep only last 50 interactions
	if #relationship.interactionHistory > 50 then
		table.remove(relationship.interactionHistory, 1)
	end
	
	relationship.lastInteraction = os.time()
	
	-- Update favorite activities
	if success then
		InteractionHandler:UpdateFavoriteActivities(relationship, interactionType)
	end
end

function InteractionHandler:UpdateFavoriteActivities(relationship, interactionType)
	relationship.favoriteActivities = relationship.favoriteActivities or {}
	
	-- Count frequency of successful interactions
	local activityCounts = {}
	for _, interaction in ipairs(relationship.interactionHistory) do
		if interaction.outcome == "positive" then
			activityCounts[interaction.type] = (activityCounts[interaction.type] or 0) + 1
		end
	end
	
	-- Get top 3 favorite activities
	local favorites = {}
	for activity, count in pairs(activityCounts) do
		table.insert(favorites, {activity = activity, count = count})
	end
	
	table.sort(favorites, function(a, b) return a.count > b.count end)
	
	relationship.favoriteActivities = {}
	for i = 1, math.min(3, #favorites) do
		table.insert(relationship.favoriteActivities, favorites[i].activity)
	end
end

-- Component initialization
function InteractionHandler.Init()
	-- Load dependencies
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local sharedDatas = ReplicatedStorage:WaitForChild("SharedSource").Datas
	CatProfileData = require(sharedDatas.CatProfileData)
	
	print("InteractionHandler component initialized")
end

function InteractionHandler.Start()
	print("InteractionHandler component started")
end

return InteractionHandler