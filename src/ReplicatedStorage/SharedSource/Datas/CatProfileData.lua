local CatProfileData = {
	-- Base cat profile template
	BaseProfile = {
		personality = {
			curiosity = 0.5,
			friendliness = 0.5,
			aggression = 0.1,
			playfulness = 0.5,
			independence = 0.5,
			shyness = 0.3
		},
		preferences = {
			favoriteFoods = {"fish", "chicken"},
			favoriteToys = {"ball", "feather"},
			dislikedItems = {"water", "loud_noises"},
			preferredRestingSpots = {"sunny_spots", "high_places"}
		},
		behavior = {
			sleepSchedule = {22, 6}, -- hours
			explorationRange = 50, -- studs
			socialDistance = 10, -- studs from other cats
			patrolFrequency = 0.3, -- 0-1 scale
			groomingFrequency = 0.7 -- 0-1 scale
		},
		physical = {
			movementSpeed = 16, -- studs/second
			jumpHeight = 8, -- studs
			climbAbility = 0.8, -- 0-1 scale
			maxEnergy = 100,
			maxHunger = 100
		}
	},

	-- Personality archetypes
	PersonalityTypes = {
		Friendly = {
			personality = {
				friendliness = 0.9,
				curiosity = 0.7,
				playfulness = 0.8,
				aggression = 0.05
			},
			preferences = {
				favoriteFoods = {"tuna", "salmon"},
				favoriteToys = {"laser_pointer", "string"}
			}
		},
		
		Independent = {
			personality = {
				independence = 0.9,
				friendliness = 0.3,
				curiosity = 0.6,
				shyness = 0.4
			},
			behavior = {
				socialDistance = 20,
				patrolFrequency = 0.7
			}
		},
		
		Playful = {
			personality = {
				playfulness = 0.9,
				curiosity = 0.8,
				friendliness = 0.7
			},
			physical = {
				movementSpeed = 20,
				jumpHeight = 10
			}
		},
		
		Curious = {
			personality = {
				curiosity = 0.9,
				playfulness = 0.6,
				friendliness = 0.5
			},
			behavior = {
				explorationRange = 80,
				patrolFrequency = 0.8
			}
		}
	},

	-- Mood states and their effects
	MoodStates = {
		Happy = {
			movementModifier = 1.2,
			interactionChance = 0.8,
			playfulnessBoost = 0.3,
			duration = {300, 600} -- seconds
		},
		
		Curious = {
			movementModifier = 1.1,
			explorationBoost = 0.4,
			attentionSpan = 0.7,
			duration = {180, 300}
		},
		
		Annoyed = {
			movementModifier = 0.8,
			interactionChance = 0.2,
			aggressionBoost = 0.3,
			duration = {120, 240}
		},
		
		Hungry = {
			movementModifier = 0.9,
			foodSeekingBoost = 0.8,
			patienceReduction = 0.5,
			duration = {300, 600}
		},
		
		Tired = {
			movementModifier = 0.6,
			restSeekingBoost = 0.9,
			activityReduction = 0.7,
			duration = {240, 480}
		},
		
		Afraid = {
			movementModifier = 1.3,
			hidingBoost = 0.9,
			fleeChance = 0.8,
			duration = {60, 180}
		},
		
		Playful = {
			movementModifier = 1.4,
			playfulnessBoost = 0.6,
			energyConsumption = 1.5,
			duration = {180, 360}
		}
	},

	-- Interaction types and their effects
	InteractionTypes = {
		Pet = {
			relationshipChange = 0.1,
			moodEffect = "Happy",
			energyCost = 5,
			successChance = 0.8
		},
		
		Feed = {
			relationshipChange = 0.3,
			moodEffect = "Happy",
			hungerReduction = 30,
			successChance = 0.95
		},
		
		Play = {
			relationshipChange = 0.2,
			moodEffect = "Playful",
			energyCost = 15,
			successChance = 0.7
		},
		
		Groom = {
			relationshipChange = 0.15,
			moodEffect = "Happy",
			energyCost = 8,
			successChance = 0.6
		},
		
		Startle = {
			relationshipChange = -0.4,
			moodEffect = "Afraid",
			successChance = 0.9
		}
	},

	-- Animation mappings
	Animations = {
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
		Purr = "rbxassetid://"
	}
}

-- Helper function to create a cat profile
function CatProfileData.CreateProfile(profileType, customSettings)
	local baseProfile = CatProfileData.BaseProfile
	local personalityType = CatProfileData.PersonalityTypes[profileType] or {}
	
	-- Merge base profile with personality type
	local profile = {
		personality = CatProfileData.MergeTables(baseProfile.personality, personalityType.personality or {}),
		preferences = CatProfileData.MergeTables(baseProfile.preferences, personalityType.preferences or {}),
		behavior = CatProfileData.MergeTables(baseProfile.behavior, personalityType.behavior or {}),
		physical = CatProfileData.MergeTables(baseProfile.physical, personalityType.physical or {})
	}
	
	-- Apply custom settings if provided
	if customSettings then
		profile = CatProfileData.MergeTables(profile, customSettings)
	end
	
	return profile
end

-- Helper function to merge tables
function CatProfileData.MergeTables(t1, t2)
	local result = {}
	
	for k, v in pairs(t1) do
		result[k] = v
	end
	
	for k, v in pairs(t2) do
		if type(v) == "table" and type(result[k]) == "table" then
			result[k] = CatProfileData.MergeTables(result[k], v)
		else
			result[k] = v
		end
	end
	
	return result
end

-- Helper function to get mood effects
function CatProfileData.GetMoodEffects(moodType)
	return CatProfileData.MoodStates[moodType] or CatProfileData.MoodStates.Happy
end

-- Helper function to get interaction effects
function CatProfileData.GetInteractionEffects(interactionType)
	return CatProfileData.InteractionTypes[interactionType] or CatProfileData.InteractionTypes.Pet
end

return CatProfileData