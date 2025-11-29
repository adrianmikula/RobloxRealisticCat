local AnimationHandler = {}

-- External dependencies
local CatService

-- Internal state
local AnimationHandler = {
	ActiveAnimations = {},
	AnimationTracks = {},
	AnimationCache = {}
}

function AnimationHandler:PlayAnimation(catId, animationState)
	local catVisual = AnimationHandler:GetCatVisual(catId)
	if not catVisual then return end
	
	local humanoid = catVisual:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	-- Stop current animation
	AnimationHandler:StopAnimation(catId)
	
	-- Get animation ID based on state
	local animationId = AnimationHandler:GetAnimationId(animationState)
	if not animationId or animationId == "" then
		-- Use placeholder animations for now
		animationId = AnimationHandler:GetPlaceholderAnimation(animationState)
	end
	
	-- Load and play animation
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	
	local animationTrack = humanoid:LoadAnimation(animation)
	animationTrack:Play()
	
	-- Store animation track
	AnimationHandler.AnimationTracks[catId] = animationTrack
	AnimationHandler.ActiveAnimations[catId] = animationState
	
	print("Playing animation for cat", catId, ":", animationState)
end

function AnimationHandler:StopAnimation(catId)
	local animationTrack = AnimationHandler.AnimationTracks[catId]
	if animationTrack then
		animationTrack:Stop()
		AnimationHandler.AnimationTracks[catId] = nil
		AnimationHandler.ActiveAnimations[catId] = nil
	end
end

function AnimationHandler:GetAnimationId(animationState)
	-- Map animation states to actual animation IDs
	-- These would be replaced with actual cat animation IDs
	local animationMap = {
		Idle = "rbxassetid://",
		Walk = "rbxassetid://",
		Run = "rbxassetid://",
		Jump = "rbxassetid://",
		Climb = "rbxassetid://",
		Sleep = "rbxassetid://",
		Eat = "rbxassetid://",
		Groom = "rbxassetid://",
		Play = "rbxassetid://",
		Hiss = "rbxassetid://",
		Purr = "rbxassetid://",
		Explore = "Walk",
		SeekFood = "Walk",
		SeekRest = "Walk",
		Socialize = "Idle"
	}
	
	-- Handle aliases
	local actualState = animationMap[animationState] or animationState
	
	-- Return the actual animation ID
	if animationMap[actualState] then
		return animationMap[actualState]
	end
	
	return "" -- No animation available
end

function AnimationHandler:GetPlaceholderAnimation(animationState)
	-- Placeholder animations using default Roblox animations
	-- These are temporary until proper cat animations are added
	local placeholderMap = {
		Idle = "rbxassetid://507766666", -- Default idle
		Walk = "rbxassetid://507767714", -- Default walk
		Run = "rbxassetid://507767714",  -- Use walk for run (temporary)
		Jump = "rbxassetid://507765000", -- Default jump
		Sleep = "rbxassetid://507766388", -- Default sit (temporary for sleep)
		Eat = "rbxassetid://507766388",  -- Default sit (temporary for eat)
		Groom = "rbxassetid://507766388", -- Default sit (temporary for groom)
		Play = "rbxassetid://507767714", -- Walk for play (temporary)
		Explore = "rbxassetid://507767714", -- Walk for explore
		SeekFood = "rbxassetid://507767714", -- Walk for seek food
		SeekRest = "rbxassetid://507766388", -- Sit for seek rest
		Socialize = "rbxassetid://507766666" -- Idle for socialize
	}
	
	return placeholderMap[animationState] or "rbxassetid://507766666" -- Default to idle
end

function AnimationHandler:UpdateAnimationSpeed(catId, speedMultiplier)
	local animationTrack = AnimationHandler.AnimationTracks[catId]
	if animationTrack then
		animationTrack:AdjustSpeed(speedMultiplier)
	end
end

function AnimationHandler:BlendAnimation(catId, fromState, toState, blendTime)
	-- Smoothly transition between animations
	blendTime = blendTime or 0.3
	
	-- Fade out current animation
	local currentTrack = AnimationHandler.AnimationTracks[catId]
	if currentTrack then
		currentTrack:Stop(blendTime)
	end
	
	-- Play new animation after delay
	task.delay(blendTime, function()
		AnimationHandler:PlayAnimation(catId, toState)
	end)
end

function AnimationHandler:PlayEmoteAnimation(catId, emoteType)
	-- Play short emote animations (meow, purr, hiss, etc.)
	local catVisual = AnimationHandler:GetCatVisual(catId)
	if not catVisual then return end
	
	local humanoid = catVisual:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	-- Stop current animation temporarily
	AnimationHandler:StopAnimation(catId)
	
	-- Play emote animation
	local emoteAnimation = AnimationHandler:GetEmoteAnimation(emoteType)
	if emoteAnimation then
		local animation = Instance.new("Animation")
		animation.AnimationId = emoteAnimation
		
		local animationTrack = humanoid:LoadAnimation(animation)
		animationTrack:Play()
		
		-- Restore previous animation after emote
		task.delay(2, function()
			if animationTrack then
				animationTrack:Stop()
			end
			
			-- Get current cat state and play appropriate animation
			local catData = AnimationHandler:GetCatData(catId)
			if catData then
				AnimationHandler:PlayAnimation(catId, catData.behaviorState.currentAction)
			end
		end)
		
		print("Playing emote for cat", catId, ":", emoteType)
	end
end

function AnimationHandler:GetEmoteAnimation(emoteType)
	local emoteMap = {
		Meow = "rbxassetid://",
		Purr = "rbxassetid://",
		Hiss = "rbxassetid://",
		Scratch = "rbxassetid://",
		Stretch = "rbxassetid://"
	}
	
	-- Placeholder emotes using default animations
	local placeholderEmotes = {
		Meow = "rbxassetid://507766388", -- Sit
		Purr = "rbxassetid://507766388", -- Sit
		Hiss = "rbxassetid://507766388", -- Sit
		Scratch = "rbxassetid://507766388", -- Sit
		Stretch = "rbxassetid://507766388" -- Sit
	}
	
	return placeholderEmotes[emoteType]
end

function AnimationHandler:GetCatVisual(catId)
	-- Get reference to CatRenderer
	local CatController = script.Parent.Parent.Parent
	local CatRenderer = CatController.Components.CatRenderer
	if CatRenderer then
		return CatRenderer:GetCatVisual(catId)
	end
	return nil
end

function AnimationHandler:GetCatData(catId)
	-- Get cat data from parent controller
	local CatController = script.Parent.Parent.Parent
	if CatController and CatController.CatVisuals then
		return CatController.CatVisuals[catId]
	end
	return nil
end

function AnimationHandler:IsAnimationPlaying(catId)
	local animationTrack = AnimationHandler.AnimationTracks[catId]
	return animationTrack and animationTrack.IsPlaying
end

function AnimationHandler:GetCurrentAnimation(catId)
	return AnimationHandler.ActiveAnimations[catId]
end

function AnimationHandler:CleanupAnimations()
	-- Stop all animations and clean up
	for catId, animationTrack in pairs(AnimationHandler.AnimationTracks) do
		if animationTrack then
			animationTrack:Stop()
		end
	end
	
	AnimationHandler.AnimationTracks = {}
	AnimationHandler.ActiveAnimations = {}
	
	print("Cleaned up all animations")
end

-- Component initialization
function AnimationHandler.Init()
	print("AnimationHandler component initialized")
end

function AnimationHandler.Start()
	print("AnimationHandler component started")
end

return AnimationHandler