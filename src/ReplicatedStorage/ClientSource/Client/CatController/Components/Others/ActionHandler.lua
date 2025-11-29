local ActionHandler = {}

-- External dependencies
local CatService

-- Internal state
local ActionHandler = {
	ActiveActions = {},
	ActionCallbacks = {},
	ActionTimers = {}
}

function ActionHandler:HandleAction(catId, actionType, actionData)
	-- Handle different types of cat actions
	print("Handling action for cat", catId, ":", actionType)
	
	-- Stop any current action for this cat
	ActionHandler:StopAction(catId)
	
	-- Execute the new action
	if actionType == "Explore" then
		ActionHandler:HandleExploreAction(catId, actionData)
	elseif actionType == "SeekFood" then
		ActionHandler:HandleSeekFoodAction(catId, actionData)
	elseif actionType == "SeekRest" then
		ActionHandler:HandleSeekRestAction(catId, actionData)
	elseif actionType == "Play" then
		ActionHandler:HandlePlayAction(catId, actionData)
	elseif actionType == "Groom" then
		ActionHandler:HandleGroomAction(catId, actionData)
	elseif actionType == "Socialize" then
		ActionHandler:HandleSocializeAction(catId, actionData)
	elseif actionType == "Idle" then
		ActionHandler:HandleIdleAction(catId, actionData)
	else
		ActionHandler:HandleGenericAction(catId, actionType, actionData)
	end
	
	-- Store active action
	ActionHandler.ActiveActions[catId] = {
		type = actionType,
		data = actionData,
		startTime = os.time()
	}
end

function ActionHandler:StopAction(catId)
	local activeAction = ActionHandler.ActiveActions[catId]
	if not activeAction then return end
	
	-- Stop any running timers
	local timer = ActionHandler.ActionTimers[catId]
	if timer then
		timer:Cancel()
		ActionHandler.ActionTimers[catId] = nil
	end
	
	-- Clear callbacks
	ActionHandler.ActionCallbacks[catId] = nil
	
	-- Clear active action
	ActionHandler.ActiveActions[catId] = nil
	
	print("Stopped action for cat:", catId)
end

function ActionHandler:HandleExploreAction(catId, actionData)
	-- Exploration behavior - random movement
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual then return end
	
	-- Start exploration movement
	ActionHandler:StartExplorationMovement(catId)
	
	-- Set up exploration completion
	local exploreDuration = math.random(10, 30) -- seconds
	ActionHandler:ScheduleActionCompletion(catId, exploreDuration)
end

function ActionHandler:HandleSeekFoodAction(catId, actionData)
	-- Food-seeking behavior
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual then return end
	
	-- Move toward food source (simulated)
	ActionHandler:StartFoodSeekingMovement(catId)
	
	-- Set up eating sequence
	local seekDuration = math.random(5, 15)
	ActionHandler:ScheduleActionCompletion(catId, seekDuration, function()
		-- Transition to eating
		ActionHandler:PlayEatingAnimation(catId)
		
		-- Complete eating after delay
		task.delay(3, function()
			ActionHandler:CompleteAction(catId)
		end)
	end)
end

function ActionHandler:HandleSeekRestAction(catId, actionData)
	-- Resting behavior
	ActionHandler:PlayRestingAnimation(catId)
	
	-- Rest for a duration
	local restDuration = math.random(20, 60)
	ActionHandler:ScheduleActionCompletion(catId, restDuration)
end

function ActionHandler:HandlePlayAction(catId, actionData)
	-- Playful behavior
	ActionHandler:StartPlayfulMovement(catId)
	
	-- Play for a duration
	local playDuration = math.random(15, 45)
	ActionHandler:ScheduleActionCompletion(catId, playDuration)
end

function ActionHandler:HandleGroomAction(catId, actionData)
	-- Grooming behavior
	ActionHandler:PlayGroomingAnimation(catId)
	
	-- Groom for a duration
	local groomDuration = math.random(10, 30)
	ActionHandler:ScheduleActionCompletion(catId, groomDuration)
end

function ActionHandler:HandleSocializeAction(catId, actionData)
	-- Social behavior (with other cats or players)
	ActionHandler:PlaySocialAnimation(catId)
	
	-- Socialize for a duration
	local socialDuration = math.random(10, 25)
	ActionHandler:ScheduleActionCompletion(catId, socialDuration)
end

function ActionHandler:HandleIdleAction(catId, actionData)
	-- Idle behavior - minimal movement
	ActionHandler:PlayIdleAnimation(catId)
	
	-- Idle for a duration
	local idleDuration = math.random(5, 20)
	ActionHandler:ScheduleActionCompletion(catId, idleDuration)
end

function ActionHandler:HandleGenericAction(catId, actionType, actionData)
	-- Fallback for unknown actions
	print("Handling generic action:", actionType, "for cat:", catId)
	
	-- Play appropriate animation
	ActionHandler:PlayGenericAnimation(catId, actionType)
	
	-- Default duration
	local duration = actionData and actionData.duration or 10
	ActionHandler:ScheduleActionCompletion(catId, duration)
end

function ActionHandler:StartExplorationMovement(catId)
	-- Simulate exploration movement
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual then return end
	
	-- Get cat data for movement speed
	local catData = ActionHandler:GetCatData(catId)
	if not catData then return end
	
	-- Start periodic movement updates
	ActionHandler.ActionTimers[catId] = task.spawn(function()
		while ActionHandler.ActiveActions[catId] and ActionHandler.ActiveActions[catId].type == "Explore" do
			-- Move cat in random direction
			ActionHandler:MoveCatRandomly(catId, catData.profile.physical.movementSpeed)
			task.wait(1) -- Update every second
		end
	end)
end

function ActionHandler:StartFoodSeekingMovement(catId)
	-- Simulate food-seeking movement
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual then return end
	
	local catData = ActionHandler:GetCatData(catId)
	if not catData then return end
	
	ActionHandler.ActionTimers[catId] = task.spawn(function()
		while ActionHandler.ActiveActions[catId] and ActionHandler.ActiveActions[catId].type == "SeekFood" do
			-- Move with purpose (straighter paths)
			ActionHandler:MoveCatPurposefully(catId, catData.profile.physical.movementSpeed)
			task.wait(0.8) -- Faster updates for purposeful movement
		end
	end)
end

function ActionHandler:StartPlayfulMovement(catId)
	-- Simulate playful movement (erratic, bouncy)
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual then return end
	
	local catData = ActionHandler:GetCatData(catId)
	if not catData then return end
	
	ActionHandler.ActionTimers[catId] = task.spawn(function()
		while ActionHandler.ActiveActions[catId] and ActionHandler.ActiveActions[catId].type == "Play" do
			-- Erratic, playful movement
			ActionHandler:MoveCatPlayfully(catId, catData.profile.physical.movementSpeed * 1.2)
			task.wait(0.5) -- Very frequent updates for playful movement
		end
	end)
end

function ActionHandler:MoveCatRandomly(catId, speed)
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual or not catVisual.PrimaryPart then return end
	
	-- Random direction change
	local currentPos = catVisual.PrimaryPart.Position
	local randomDirection = Vector3.new(
		(math.random() - 0.5) * 2,
		0,
		(math.random() - 0.5) * 2
	).Unit
	
	local newPos = currentPos + randomDirection * speed * 0.1
	catVisual:SetPrimaryPartCFrame(CFrame.new(newPos))
end

function ActionHandler:MoveCatPurposefully(catId, speed)
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual or not catVisual.PrimaryPart then return end
	
	-- More purposeful movement (less random)
	local currentPos = catVisual.PrimaryPart.Position
	local direction = Vector3.new(
		(math.random() - 0.3) * 2, -- Bias forward
		0,
		(math.random() - 0.3) * 2
	).Unit
	
	local newPos = currentPos + direction * speed * 0.15
	catVisual:SetPrimaryPartCFrame(CFrame.new(newPos))
end

function ActionHandler:MoveCatPlayfully(catId, speed)
	local catVisual = ActionHandler:GetCatVisual(catId)
	if not catVisual or not catVisual.PrimaryPart then return end
	
	-- Erratic, playful movement
	local currentPos = catVisual.PrimaryPart.Position
	local direction = Vector3.new(
		(math.random() - 0.5) * 4, -- More extreme changes
		0,
		(math.random() - 0.5) * 4
	).Unit
	
	local newPos = currentPos + direction * speed * 0.08
	catVisual:SetPrimaryPartCFrame(CFrame.new(newPos))
end

function ActionHandler:ScheduleActionCompletion(catId, duration, completionCallback)
	-- Schedule action completion after duration
	ActionHandler.ActionCallbacks[catId] = completionCallback
	
	task.delay(duration, function()
		if ActionHandler.ActiveActions[catId] then
			if completionCallback then
				completionCallback()
			else
				ActionHandler:CompleteAction(catId)
			end
		end
	end)
end

function ActionHandler:CompleteAction(catId)
	-- Action completed naturally
	ActionHandler:StopAction(catId)
	
	-- Notify that action is complete (server will assign new action)
	print("Action completed for cat:", catId)
end

function ActionHandler:PlayEatingAnimation(catId)
	local AnimationHandler = ActionHandler:GetAnimationHandler()
	if AnimationHandler then
		AnimationHandler:PlayAnimation(catId, "Eat")
	end
end

function ActionHandler:PlayRestingAnimation(catId)
	local AnimationHandler = ActionHandler:GetAnimationHandler()
	if AnimationHandler then
		AnimationHandler:PlayAnimation(catId, "Sleep")
	end
end

function ActionHandler:PlayGroomingAnimation(catId)
	local AnimationHandler = ActionHandler:GetAnimationHandler()
	if AnimationHandler then
		AnimationHandler:PlayAnimation(catId, "Groom")
	end
end

function ActionHandler:PlaySocialAnimation(catId)
	local AnimationHandler = ActionHandler:GetAnimationHandler()
	if AnimationHandler then
		AnimationHandler:PlayAnimation(catId, "Idle") -- Use idle for social for now
	end
end

function ActionHandler:PlayIdleAnimation(catId)
	local AnimationHandler = ActionHandler:GetAnimationHandler()
	if AnimationHandler then
		AnimationHandler:PlayAnimation(catId, "Idle")
	end
end

function ActionHandler:PlayGenericAnimation(catId, actionType)
	local AnimationHandler = ActionHandler:GetAnimationHandler()
	if AnimationHandler then
		AnimationHandler:PlayAnimation(catId, actionType)
	end
end

function ActionHandler:GetCatVisual(catId)
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:GetCatVisual(catId)
	end
	return nil
end

function ActionHandler:GetCatData(catId)
	-- Get cat data from parent controller
	local CatController = script.Parent.Parent.Parent
	if CatController and CatController.CatVisuals then
		return CatController.CatVisuals[catId]
	end
	return nil
end

function ActionHandler:GetAnimationHandler()
	local CatController = script.Parent.Parent.Parent
	return CatController.Components.AnimationHandler
end

function ActionHandler:GetActiveAction(catId)
	return ActionHandler.ActiveActions[catId]
end

function ActionHandler:IsActionActive(catId)
	return ActionHandler.ActiveActions[catId] ~= nil
end

function ActionHandler:CleanupAllActions()
	-- Stop all active actions
	for catId in pairs(ActionHandler.ActiveActions) do
		ActionHandler:StopAction(catId)
	end
	
	print("Cleaned up all actions")
end

-- Component initialization
function ActionHandler.Init()
	print("ActionHandler component initialized")
end

function ActionHandler.Start()
	print("ActionHandler component started")
end

return ActionHandler