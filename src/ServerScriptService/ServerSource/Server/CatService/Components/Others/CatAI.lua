local CatAI = {}

-- External dependencies
local CatProfileData

-- Internal state
local CatAI = {
	ActiveCats = {},
	DecisionWeights = {},
	EnvironmentData = {}
}

function CatAI:InitializeCat(catId, catData)
	CatAI.ActiveCats[catId] = {
		catData = catData,
		lastDecisionTime = 0,
		currentGoal = nil,
		behaviorTree = {},
		memory = {}
	}
	
	-- Initialize behavior tree based on personality
	CatAI:SetupBehaviorTree(catId, catData.profile)
	
	print("CatAI initialized for cat:", catId)
end

function CatAI:CleanupCat(catId)
	CatAI.ActiveCats[catId] = nil
	print("CatAI cleaned up for cat:", catId)
end

function CatAI:UpdateCat(catId, catData)
	local aiData = CatAI.ActiveCats[catId]
	if not aiData then return end
	
	local currentTime = os.time()
	
	-- Update mood and physical state decay
	CatAI:UpdateStateDecay(catId, catData)
	
	-- Make decisions every 2-5 seconds based on personality
	local decisionFrequency = 2 + (3 * (1 - catData.profile.personality.curiosity))
	if currentTime - aiData.lastDecisionTime >= decisionFrequency then
		CatAI:MakeDecision(catId, catData)
		aiData.lastDecisionTime = currentTime
	end
	
	-- Execute current action
	CatAI:ExecuteCurrentAction(catId, catData)
end

function CatAI:UpdateStateDecay(catId, catData)
	-- Natural decay of physical states
	local decayRate = 0.1 -- per second
	local timePassed = os.time() - catData.timers.lastUpdate
	
	if timePassed > 0 then
		-- Hunger increases over time
		catData.physicalState.hunger = math.clamp(
			catData.physicalState.hunger + (decayRate * timePassed),
			0, 100
		)
		
		-- Energy decreases with activity
		local activityMultiplier = catData.behaviorState.isMoving and 2 or 1
		catData.physicalState.energy = math.clamp(
			catData.physicalState.energy - (decayRate * activityMultiplier * timePassed),
			0, 100
		)
		
		-- Mood duration decreases
		if catData.moodState.moodDuration > 0 then
			catData.moodState.moodDuration = math.max(0, catData.moodState.moodDuration - timePassed)
			if catData.moodState.moodDuration == 0 then
				-- Return to neutral mood
				catData.moodState.currentMood = "Happy"
				catData.moodState.moodIntensity = 0.5
			end
		end
		
		catData.timers.lastUpdate = os.time()
	end
end

function CatAI:MakeDecision(catId, catData)
	-- Calculate decision weights based on current state
	local decisionWeights = CatAI:CalculateDecisionWeights(catId, catData)
	
	-- Select highest priority action
	local bestAction = "Idle"
	local bestWeight = -math.huge
	
	for action, weight in pairs(decisionWeights) do
		if weight > bestWeight then
			bestWeight = weight
			bestAction = action
		end
	end
	
	-- Apply personality modifiers
	bestAction = CatAI:ApplyPersonalityModifiers(catId, catData, bestAction)
	
	-- Set the new action
	CatAI:SetCatAction(catId, bestAction)
	
	print("Cat", catId, "decided to:", bestAction, "(weight:", bestWeight, ")")
end

function CatAI:CalculateDecisionWeights(catId, catData)
	local weights = {
		Idle = 1.0,
		Explore = 0.5,
		SeekFood = 0.0,
		SeekRest = 0.0,
		Play = 0.0,
		Socialize = 0.0,
		Groom = 0.3
	}
	
	-- Mood-based weights
	local moodEffects = CatProfileData.GetMoodEffects(catData.moodState.currentMood)
	weights.Explore *= (1 + moodEffects.explorationBoost or 0)
	weights.Play *= (1 + moodEffects.playfulnessBoost or 0)
	
	-- Physical state weights
	if catData.physicalState.hunger > 70 then
		weights.SeekFood = 3.0 + (catData.physicalState.hunger - 70) * 0.1
	elseif catData.physicalState.hunger > 50 then
		weights.SeekFood = 1.0
	end
	
	if catData.physicalState.energy < 30 then
		weights.SeekRest = 4.0 + (30 - catData.physicalState.energy) * 0.1
	elseif catData.physicalState.energy < 50 then
		weights.SeekRest = 1.5
	end
	
	-- Personality weights
	weights.Explore *= catData.profile.personality.curiosity
	weights.Play *= catData.profile.personality.playfulness
	weights.Socialize *= catData.profile.personality.friendliness
	
	-- Random variation
	for action, weight in pairs(weights) do
		if weight > 0 then
			weights[action] = weight * (0.8 + math.random() * 0.4)
		end
	end
	
	return weights
end

function CatAI:ApplyPersonalityModifiers(catId, catData, action)
	-- Independent cats are less likely to socialize
	if action == "Socialize" and catData.profile.personality.independence > 0.7 then
		return math.random() < 0.3 and "Explore" or "Idle"
	end
	
	-- Shy cats avoid social interactions
	if action == "Socialize" and catData.profile.personality.shyness > 0.6 then
		return math.random() < 0.4 and "Groom" or "Idle"
	end
	
	return action
end

function CatAI:SetCatAction(catId, actionType)
	local catData = CatAI.ActiveCats[catId].catData
	
	-- Get the parent CatService to call SetComponent
	local CatService = script.Parent.Parent.Parent
	CatService.SetComponent:SetCatAction(catId, actionType, {})
	
	-- Store action data
	CatAI.ActiveCats[catId].currentGoal = actionType
end

function CatAI:ExecuteCurrentAction(catId, catData)
	local aiData = CatAI.ActiveCats[catId]
	if not aiData or not aiData.currentGoal then return end
	
	local action = aiData.currentGoal
	
	-- Simple action execution (will be expanded with pathfinding)
	if action == "Explore" then
		CatAI:ExecuteExplore(catId, catData)
	elseif action == "SeekFood" then
		CatAI:ExecuteSeekFood(catId, catData)
	elseif action == "SeekRest" then
		CatAI:ExecuteSeekRest(catId, catData)
	elseif action == "Play" then
		CatAI:ExecutePlay(catId, catData)
	elseif action == "Groom" then
		CatAI:ExecuteGroom(catId, catData)
	else
		-- Idle or socialize - just wait
		CatAI:ExecuteIdle(catId, catData)
	end
end

function CatAI:ExecuteExplore(catId, catData)
	-- Simple random movement within exploration range
	local explorationRange = catData.profile.behavior.explorationRange
	local currentPos = catData.currentState.position
	
	if not catData.behaviorState.isMoving then
		-- Choose a random target position
		local targetPos = currentPos + Vector3.new(
			(math.random() - 0.5) * explorationRange * 2,
			0,
			(math.random() - 0.5) * explorationRange * 2
		)
		
		-- Update cat state
		catData.behaviorState.targetPosition = targetPos
		catData.behaviorState.isMoving = true
		
		print("Cat", catId, "exploring to:", targetPos)
	end
	
	-- Simple movement simulation (will be replaced with proper pathfinding)
	if catData.behaviorState.isMoving then
		local targetPos = catData.behaviorState.targetPosition
		local direction = (targetPos - currentPos).Unit
		local speed = catData.profile.physical.movementSpeed * 0.1 -- Scale for simulation
		
		catData.currentState.position = currentPos + direction * speed
		
		-- Check if reached target
		if (targetPos - catData.currentState.position).Magnitude < 2 then
			catData.behaviorState.isMoving = false
			catData.behaviorState.targetPosition = nil
			print("Cat", catId, "reached exploration target")
		end
	end
end

function CatAI:ExecuteSeekFood(catId, catData)
	-- Similar to explore but with food-seeking behavior
	CatAI:ExecuteExplore(catId, catData)
	
	-- When "finding food", reduce hunger
	if not catData.behaviorState.isMoving then
		catData.physicalState.hunger = math.max(0, catData.physicalState.hunger - 20)
		print("Cat", catId, "found and ate food")
	end
end

function CatAI:ExecuteSeekRest(catId, catData)
	-- Resting behavior - stop moving and recover energy
	catData.behaviorState.isMoving = false
	catData.physicalState.energy = math.min(100, catData.physicalState.energy + 5)
	
	if math.random() < 0.1 then
		print("Cat", catId, "is resting and recovering energy")
	end
end

function CatAI:ExecutePlay(catId, catData)
	-- Playful behavior - random movements with higher energy cost
	CatAI:ExecuteExplore(catId, catData)
	
	-- Higher energy consumption during play
	catData.physicalState.energy = math.max(0, catData.physicalState.energy - 2)
end

function CatAI:ExecuteGroom(catId, catData)
	-- Grooming behavior - stay in place and improve grooming state
	catData.behaviorState.isMoving = false
	catData.physicalState.grooming = math.min(100, catData.physicalState.grooming + 3)
	
	if math.random() < 0.05 then
		print("Cat", catId, "is grooming itself")
	end
end

function CatAI:ExecuteIdle(catId, catData)
	-- Basic idle behavior
	catData.behaviorState.isMoving = false
	
	-- Occasional random looks around
	if math.random() < 0.02 then
		print("Cat", catId, "is idling and looking around")
	end
end

function CatAI:SetupBehaviorTree(catId, profile)
	-- Basic behavior tree setup based on personality
	local behaviorTree = {
		root = "Selector",
		nodes = {
			Selector = {
				type = "selector",
				children = {"UrgentNeeds", "MoodDriven", "PersonalityDriven", "Idle"}
			},
			UrgentNeeds = {
				type = "sequence",
				children = {"CheckHunger", "CheckEnergy", "CheckHealth"}
			},
			MoodDriven = {
				type = "selector",
				children = {"MoodActions"}
			},
			PersonalityDriven = {
				type = "selector",
				children = {"PersonalityActions"}
			},
			Idle = {
				type = "action",
				action = "Idle"
			}
		}
	}
	
	CatAI.ActiveCats[catId].behaviorTree = behaviorTree
end

-- Component initialization
function CatAI.Init()
	-- Load dependencies
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local sharedDatas = ReplicatedStorage:WaitForChild("SharedSource").Datas
	CatProfileData = require(sharedDatas.CatProfileData)
	
	print("CatAI component initialized")
end

function CatAI.Start()
	print("CatAI component started")
end

return CatAI