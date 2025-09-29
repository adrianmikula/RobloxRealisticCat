local CatPerformanceConfig = {}

-- Performance optimization settings
CatPerformanceConfig.LODSettings = {
	-- Level of Detail settings for cat rendering
	LOD1 = { -- High detail (close range)
		distance = 20, -- studs
		animationQuality = "high",
		particleEffects = true,
		soundEffects = true,
		detailMeshes = true,
		updateFrequency = 0.1 -- seconds
	},
	
	LOD2 = { -- Medium detail (medium range)
		distance = 50, -- studs
		animationQuality = "medium",
		particleEffects = false,
		soundEffects = false,
		detailMeshes = false,
		updateFrequency = 0.3 -- seconds
	},
	
	LOD3 = { -- Low detail (far range)
		distance = 100, -- studs
		animationQuality = "low",
		particleEffects = false,
		soundEffects = false,
		detailMeshes = false,
		updateFrequency = 1.0 -- seconds
	},
	
	LOD4 = { -- Culled (very far)
		distance = 200, -- studs
		animationQuality = "none",
		particleEffects = false,
		soundEffects = false,
		detailMeshes = false,
		updateFrequency = 5.0 -- seconds
	}
}

-- Network update optimization
CatPerformanceConfig.NetworkSettings = {
	-- Update frequency based on distance and importance
	HighPriority = {
		maxCats = 10,
		updateFrequency = 0.1,
		positionPrecision = 0.1,
		rotationPrecision = 0.05
	},
	
	MediumPriority = {
		maxCats = 30,
		updateFrequency = 0.3,
		positionPrecision = 0.5,
		rotationPrecision = 0.1
	},
	
	LowPriority = {
		maxCats = 60,
		updateFrequency = 1.0,
		positionPrecision = 1.0,
		rotationPrecision = 0.2
	},
	
	BackgroundPriority = {
		maxCats = 100,
		updateFrequency = 5.0,
		positionPrecision = 2.0,
		rotationPrecision = 0.5
	}
}

-- Animation optimization
CatPerformanceConfig.AnimationSettings = {
	-- Animation quality levels
	HighQuality = {
		blendTime = 0.2,
		frameRate = 30,
		interpolation = true,
		complexBlending = true
	},
	
	MediumQuality = {
		blendTime = 0.3,
		frameRate = 20,
		interpolation = true,
		complexBlending = false
	},
	
	LowQuality = {
		blendTime = 0.5,
		frameRate = 10,
		interpolation = false,
		complexBlending = false
	},
	
	MinimalQuality = {
		blendTime = 1.0,
		frameRate = 5,
		interpolation = false,
		complexBlending = false
	}
}

-- Performance modes for different hardware capabilities
CatPerformanceConfig.PerformanceModes = {
	Ultra = {
		maxCats = 100,
		LODDistanceMultiplier = 1.5,
		animationQuality = "HighQuality",
		networkPriority = "HighPriority",
		particleLimit = 100,
		soundLimit = 50
	},
	
	High = {
		maxCats = 75,
		LODDistanceMultiplier = 1.2,
		animationQuality = "HighQuality",
		networkPriority = "MediumPriority",
		particleLimit = 75,
		soundLimit = 30
	},
	
	Balanced = {
		maxCats = 50,
		LODDistanceMultiplier = 1.0,
		animationQuality = "MediumQuality",
		networkPriority = "MediumPriority",
		particleLimit = 50,
		soundLimit = 20
	},
	
	Performance = {
		maxCats = 30,
		LODDistanceMultiplier = 0.8,
		animationQuality = "LowQuality",
		networkPriority = "LowPriority",
		particleLimit = 25,
		soundLimit = 10
	},
	
	Minimal = {
		maxCats = 15,
		LODDistanceMultiplier = 0.5,
		animationQuality = "MinimalQuality",
		networkPriority = "BackgroundPriority",
		particleLimit = 10,
		soundLimit = 5
	}
}

-- Auto-detection settings for performance mode
CatPerformanceConfig.AutoDetection = {
	FPSThresholds = {
		Ultra = 60,
		High = 45,
		Balanced = 30,
		Performance = 20,
		Minimal = 15
	},
	
	MemoryThresholds = {
		Ultra = 2048, -- MB
		High = 1024,
		Balanced = 512,
		Performance = 256,
		Minimal = 128
	},
	
	CheckInterval = 10 -- seconds
}

-- Cat-specific optimization settings
CatPerformanceConfig.CatOptimization = {
	-- Maximum cats per player
	MaxCatsPerPlayer = 100,
	
	-- Distance-based culling
	CullingDistances = {
		minDistance = 5, -- Always render cats within this distance
		maxDistance = 200, -- Never render cats beyond this distance
		fadeDistance = 50 -- Distance where cats start fading out
	},
	
	-- Batch processing settings
	BatchSize = 10, -- Process cats in batches to avoid frame spikes
	BatchInterval = 0.1, -- Time between batch processing
	
	-- Memory management
	CacheSize = 50, -- Maximum cached cat models
	CleanupInterval = 30 -- Seconds between memory cleanup
}

-- Utility functions
function CatPerformanceConfig:GetLODLevel(distance)
	if distance <= self.LODSettings.LOD1.distance then
		return 1
	elseif distance <= self.LODSettings.LOD2.distance then
		return 2
	elseif distance <= self.LODSettings.LOD3.distance then
		return 3
	else
		return 4
	end
end

function CatPerformanceConfig:GetLODSettings(level)
	return self.LODSettings["LOD" .. level] or self.LODSettings.LOD4
end

function CatPerformanceConfig:GetPerformanceMode(modeName)
	return self.PerformanceModes[modeName] or self.PerformanceModes.Balanced
end

function CatPerformanceConfig:GetAnimationSettings(quality)
	return self.AnimationSettings[quality] or self.AnimationSettings.MediumQuality
end

function CatPerformanceConfig:GetNetworkSettings(priority)
	return self.NetworkSettings[priority] or self.NetworkSettings.MediumPriority
end

function CatPerformanceConfig:AutoDetectPerformanceMode()
	-- This would use actual performance metrics
	-- For now, return balanced as default
	return "Balanced"
end

function CatPerformanceConfig:ShouldRenderCat(distance, performanceMode)
	local modeSettings = self:GetPerformanceMode(performanceMode)
	local maxDistance = self.CatOptimization.CullingDistances.maxDistance * modeSettings.LODDistanceMultiplier
	
	return distance <= maxDistance
end

function CatPerformanceConfig:GetUpdateFrequency(distance, performanceMode)
	local lodLevel = self:GetLODLevel(distance)
	local lodSettings = self:GetLODSettings(lodLevel)
	local modeSettings = self:GetPerformanceMode(performanceMode)
	
	return lodSettings.updateFrequency * (1 / modeSettings.LODDistanceMultiplier)
end

return CatPerformanceConfig