local ProfileTemplate = {
	-- Player-cat relationship data
	catRelationships = {
		-- Structure: [catId] = relationship data
		-- Example:
		-- ["cat_001"] = {
		--     trustLevel = 0.75,
		--     interactionHistory = {},
		--     lastInteraction = 0,
		--     favoriteActivities = {},
		--     relationshipScore = 0
		-- }
	},
	
	-- Player preferences and settings
	playerSettings = {
		selectedTool = "none",
		autoInteract = false,
		catNotifications = true,
		visualPreferences = {
			showMoodIndicators = true,
			showRelationshipBars = true,
			animationQuality = "high"
		}
	},
	
	-- Player statistics
	playerStats = {
		totalCatsInteracted = 0,
		uniqueCatsMet = 0,
		longestRelationship = 0,
		totalPlayTime = 0,
		favoriteCat = ""
	},
	
	-- Unlocked tools and items
	unlockedTools = {
		basicFood = true,
		basicToys = true,
		premiumFood = false,
		premiumToys = false,
		groomingTools = false,
		medicalItems = false
	}
}

return ProfileTemplate
