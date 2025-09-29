local SetComponent = {}

-- External dependencies
local CatService

function SetComponent:CreateCat(catId, profileType)
	local CatManager = CatService.Components.CatManager
	if CatManager then
		return CatManager:CreateCat(catId, profileType)
	end
	return nil
end

function SetComponent:RemoveCat(catId)
	local CatManager = CatService.Components.CatManager
	if CatManager then
		CatManager:RemoveCat(catId)
		
		-- Notify clients
		CatService.Client.CatStateUpdate:FireAll(catId, "removed", nil)
	end
end

function SetComponent:UpdateCatState(catId, newState)
	local CatManager = CatService.Components.CatManager
	if CatManager then
		CatManager:UpdateCatState(catId, newState)
		
		-- Notify clients of state update
		local catData = CatManager:GetCat(catId)
		if catData then
			CatService.Client.CatStateUpdate:FireAll(catId, "updated", catData)
		end
	end
end

function SetComponent:UpdateCatMood(catId, moodType, intensity)
	local CatManager = CatService.Components.CatManager
	if CatManager then
		CatManager:UpdateCatMood(catId, moodType, intensity)
		
		-- Notify clients of mood change
		local catData = CatManager:GetCat(catId)
		if catData then
			CatService.Client.CatStateUpdate:FireAll(catId, "mood_updated", catData)
		end
	end
end

function SetComponent:UpdateCatPhysical(catId, physicalChanges)
	local CatManager = CatService.Components.CatManager
	if CatManager then
		CatManager:UpdateCatPhysical(catId, physicalChanges)
		
		-- Notify clients of physical state change
		local catData = CatManager:GetCat(catId)
		if catData then
			CatService.Client.CatStateUpdate:FireAll(catId, "physical_updated", catData)
		end
	end
end

function SetComponent:SetCatAction(catId, actionType, actionData)
	local CatManager = CatService.Components.CatManager
	if CatManager then
		CatManager:SetCatAction(catId, actionType, actionData)
		
		-- Notify clients of action
		CatService.Client.CatActionUpdate:FireAll(catId, actionType, actionData)
	end
end

function SetComponent:ClearCatAction(catId)
	local CatManager = CatService.Components.CatManager
	if CatManager then
		CatManager:ClearCatAction(catId)
		
		-- Notify clients
		CatService.Client.CatActionUpdate:FireAll(catId, "idle", {})
	end
end

function SetComponent:UpdatePlayerRelationship(player, catId, change)
	local RelationshipManager = CatService.Components.RelationshipManager
	if RelationshipManager then
		RelationshipManager:UpdateRelationship(player, catId, change)
	end
end

function SetComponent:EquipPlayerTool(player, toolType)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		return PlayerManager:EquipTool(player, toolType)
	end
	return {success = false, message = "PlayerManager not available"}
end

function SetComponent:UnequipPlayerTool(player)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		PlayerManager:UnequipTool(player)
	end
end

function SetComponent:UnlockPlayerTool(player, toolType)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		return PlayerManager:UnlockTool(player, toolType)
	end
	return false
end

function SetComponent:UpdatePlayerSettings(player, newSettings)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		PlayerManager:UpdatePlayerSettings(player, newSettings)
	end
end

function SetComponent:UpdateNearbyCats(player, catIds)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		PlayerManager:UpdateNearbyCats(player, catIds)
	end
end

function SetComponent:SetInteractionCooldown(player, interactionType, duration)
	local PlayerManager = CatService.Components.PlayerManager
	if PlayerManager then
		PlayerManager:SetInteractionCooldown(player, interactionType, duration)
	end
end

function SetComponent:ForceCatBehavior(catId, behaviorType, behaviorData)
	-- Force a specific behavior on a cat (for debugging or special events)
	local CatAI = CatService.Components.CatAI
	if CatAI then
		-- This would override the normal AI decision making
		SetComponent:SetCatAction(catId, behaviorType, behaviorData)
		
		print("Forced behavior on cat", catId, ":", behaviorType)
	end
end

function SetComponent:ResetCat(catId)
	-- Reset a cat to its initial state
	local CatManager = CatService.Components.CatManager
	if CatManager then
		local catData = CatManager:GetCat(catId)
		if catData then
			-- Reset physical state
			catData.physicalState = {
				hunger = 50,
				energy = 100,
				health = 100,
				grooming = 80
			}
			
			-- Reset mood
			catData.moodState = {
				currentMood = "Happy",
				moodIntensity = 0.5,
				moodDuration = 0
			}
			
			-- Reset behavior
			catData.behaviorState = {
				currentAction = "Idle",
				targetPosition = nil,
				isMoving = false,
				isInteracting = false
			}
			
			-- Notify clients
			CatService.Client.CatStateUpdate:FireAll(catId, "reset", catData)
			
			print("Reset cat:", catId)
		end
	end
end

function SetComponent:SpawnTestCats(count, profileType)
	-- Spawn multiple test cats for debugging
	for i = 1, count do
		local catId = "test_cat_" .. i
		SetComponent:CreateCat(catId, profileType or "Friendly")
	end
	
	print("Spawned", count, "test cats with profile:", profileType or "Friendly")
end

function SetComponent:CleanupAllCats()
	-- Remove all cats (for testing or server cleanup)
	for catId in pairs(CatService.ActiveCats) do
		SetComponent:RemoveCat(catId)
	end
	
	print("Cleaned up all cats")
end

-- Component initialization
function SetComponent.Init()
	-- Get reference to parent CatService
	CatService = script.Parent.Parent
	
	print("CatService SetComponent initialized")
end

function SetComponent.Start()
	print("CatService SetComponent started")
end

return SetComponent