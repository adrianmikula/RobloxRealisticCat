local CatManager = {}

-- External dependencies
local CatProfileData

-- Internal state
local CatManager = {
	CatCounter = 0,
	CatInstances = {}
}

function CatManager:CreateCat(catId, profileType)
	-- Generate cat ID if not provided
	if not catId then
		CatManager.CatCounter += 1
		catId = "cat_" .. string.format("%03d", CatManager.CatCounter)
	end
	
	-- Create cat profile
	local catProfile = CatProfileData.CreateProfile(profileType or "Friendly")
	
	-- Initialize cat data
	local catData = {
		id = catId,
		profile = catProfile,
		currentState = {
			position = Vector3.new(0, 0, 0),
			rotation = Vector3.new(0, 0, 0),
			velocity = Vector3.new(0, 0, 0)
		},
		moodState = {
			currentMood = "Happy",
			moodIntensity = 0.5,
			moodDuration = 0,
			moodTriggers = {}
		},
		physicalState = {
			hunger = 50,
			energy = 100,
			health = 100,
			grooming = 80
		},
		behaviorState = {
			currentAction = "Idle",
			targetPosition = nil,
			currentPath = {},
			isMoving = false,
			isInteracting = false
		},
		socialState = {
			playerRelationships = {},
			catRelationships = {},
			lastInteraction = 0
		},
		timers = {
			lastUpdate = os.time(),
			nextActionTime = 0,
			moodChangeTime = 0
		}
	}
	
	-- Store cat instance
	CatManager.CatInstances[catId] = catData
	
	print("Created cat:", catId, "with profile:", profileType)
	
	return catData
end

function CatManager:RemoveCat(catId)
	if CatManager.CatInstances[catId] then
		CatManager.CatInstances[catId] = nil
		print("Removed cat:", catId)
	end
end

function CatManager:GetCat(catId)
	return CatManager.CatInstances[catId]
end

function CatManager:GetAllCats()
	return CatManager.CatInstances
end

function CatManager:UpdateCatState(catId, newState)
	local catData = CatManager.CatInstances[catId]
	if not catData then return end
	
	-- Update state
	for key, value in pairs(newState) do
		if catData.currentState[key] ~= nil then
			catData.currentState[key] = value
		end
	end
	
	catData.timers.lastUpdate = os.time()
end

function CatManager:UpdateCatMood(catId, moodType, intensity)
	local catData = CatManager.CatInstances[catId]
	if not catData then return end
	
	local moodEffects = CatProfileData.GetMoodEffects(moodType)
	
	catData.moodState.currentMood = moodType
	catData.moodState.moodIntensity = intensity or 0.5
	catData.moodState.moodDuration = math.random(moodEffects.duration[1], moodEffects.duration[2])
	catData.moodState.moodTriggers = {}
	
	print("Cat", catId, "mood changed to:", moodType, "intensity:", intensity)
end

function CatManager:UpdateCatPhysical(catId, physicalChanges)
	local catData = CatManager.CatInstances[catId]
	if not catData then return end
	
	for stat, change in pairs(physicalChanges) do
		if catData.physicalState[stat] ~= nil then
			catData.physicalState[stat] = math.clamp(
				catData.physicalState[stat] + change, 
				0, 
				100
			)
		end
	end
	
	-- Auto-trigger mood changes based on physical state
	if catData.physicalState.hunger < 20 then
		CatManager:UpdateCatMood(catId, "Hungry", 0.8)
	elseif catData.physicalState.energy < 20 then
		CatManager:UpdateCatMood(catId, "Tired", 0.7)
	end
end

function CatManager:SetCatAction(catId, actionType, actionData)
	local catData = CatManager.CatInstances[catId]
	if not catData then return end
	
	catData.behaviorState.currentAction = actionType
	catData.behaviorState.actionData = actionData
	catData.behaviorState.isInteracting = true
	
	print("Cat", catId, "started action:", actionType)
end

function CatManager:ClearCatAction(catId)
	local catData = CatManager.CatInstances[catId]
	if not catData then return end
	
	catData.behaviorState.currentAction = "Idle"
	catData.behaviorState.actionData = nil
	catData.behaviorState.isInteracting = false
	
	print("Cat", catId, "action cleared")
end

-- Component initialization
function CatManager.Init()
	-- Load dependencies
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local sharedDatas = ReplicatedStorage:WaitForChild("SharedSource").Datas
	CatProfileData = require(sharedDatas.CatProfileData)
	
	print("CatManager component initialized")
end

function CatManager.Start()
	print("CatManager component started")
end

return CatManager