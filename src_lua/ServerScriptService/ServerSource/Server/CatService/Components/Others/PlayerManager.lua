local PlayerManager = {}

-- External dependencies
local ProfileService

-- Internal state
local PlayerManager = {
	ActivePlayers = {},
	PlayerTools = {},
	PlayerSettings = {}
}

function PlayerManager:HandlePlayerAdded(player)
	-- Initialize player data
	PlayerManager.ActivePlayers[player.UserId] = {
		player = player,
		currentTool = "none",
		lastInteractionTime = 0,
		nearbyCats = {},
		toolCooldowns = {}
	}
	
	-- Load player settings from profile
	PlayerManager:LoadPlayerSettings(player)
	
	-- Initialize tool system
	PlayerManager:InitializePlayerTools(player)
	
	print("Player added to CatService:", player.Name)
end

function PlayerManager:HandlePlayerRemoved(player)
	-- Save player settings to profile
	PlayerManager:SavePlayerSettings(player)
	
	-- Clean up player data
	PlayerManager.ActivePlayers[player.UserId] = nil
	PlayerManager.PlayerTools[player.UserId] = nil
	PlayerManager.PlayerSettings[player.UserId] = nil
	
	print("Player removed from CatService:", player.Name)
end

function PlayerManager:LoadPlayerSettings(player)
	if not ProfileService then return end
	
	local profile = ProfileService:GetProfile(player)
	if not profile or not profile.Data then return end
	
	-- Load player settings
	PlayerManager.PlayerSettings[player.UserId] = profile.Data.playerSettings or {
		selectedTool = "none",
		autoInteract = false,
		catNotifications = true,
		visualPreferences = {
			showMoodIndicators = true,
			showRelationshipBars = true,
			animationQuality = "high"
		}
	}
	
	-- Load unlocked tools
	PlayerManager.PlayerTools[player.UserId] = profile.Data.unlockedTools or {
		basicFood = true,
		basicToys = true,
		premiumFood = false,
		premiumToys = false,
		groomingTools = false,
		medicalItems = false
	}
	
	print("Loaded settings for player:", player.Name)
end

function PlayerManager:SavePlayerSettings(player)
	if not ProfileService then return end
	
	local profile = ProfileService:GetProfile(player)
	if not profile or not profile.Data then return end
	
	-- Save player settings
	if PlayerManager.PlayerSettings[player.UserId] then
		profile.Data.playerSettings = PlayerManager.PlayerSettings[player.UserId]
	end
	
	-- Save unlocked tools
	if PlayerManager.PlayerTools[player.UserId] then
		profile.Data.unlockedTools = PlayerManager.PlayerTools[player.UserId]
	end
	
	print("Saved settings for player:", player.Name)
end

function PlayerManager:InitializePlayerTools(player)
	-- Define available tools
	local availableTools = {
		basicFood = {
			name = "Basic Food",
			type = "food",
			interactionType = "Feed",
			effectiveness = 1.0,
			cooldown = 5
		},
		basicToys = {
			name = "Basic Toy",
			type = "toy",
			interactionType = "Play",
			effectiveness = 1.0,
			cooldown = 3
		},
		premiumFood = {
			name = "Premium Food",
			type = "food",
			interactionType = "Feed",
			effectiveness = 1.5,
			cooldown = 5
		},
		premiumToys = {
			name = "Premium Toy",
			type = "toy",
			interactionType = "Play",
			effectiveness = 1.5,
			cooldown = 3
		},
		groomingTools = {
			name = "Grooming Tool",
			type = "grooming",
			interactionType = "Groom",
			effectiveness = 1.2,
			cooldown = 10
		},
		medicalItems = {
			name = "Medical Item",
			type = "medical",
			interactionType = "Heal",
			effectiveness = 2.0,
			cooldown = 30
		}
	}
	
	PlayerManager.PlayerTools[player.UserId] = PlayerManager.PlayerTools[player.UserId] or {}
	
	-- Ensure basic tools are always available
	PlayerManager.PlayerTools[player.UserId].basicFood = true
	PlayerManager.PlayerTools[player.UserId].basicToys = true
	
	print("Initialized tools for player:", player.Name)
end

function PlayerManager:EquipTool(player, toolType)
	if not PlayerManager:HasTool(player, toolType) then
		return {success = false, message = "Tool not unlocked"}
	end
	
	local playerData = PlayerManager.ActivePlayers[player.UserId]
	if not playerData then return {success = false, message = "Player not found"} end
	
	playerData.currentTool = toolType
	playerData.lastToolChange = os.time()
	
	print("Player", player.Name, "equipped tool:", toolType)
	
	return {success = true, message = "Tool equipped"}
end

function PlayerManager:UnequipTool(player)
	local playerData = PlayerManager.ActivePlayers[player.UserId]
	if not playerData then return end
	
	playerData.currentTool = "none"
	
	print("Player", player.Name, "unequipped tool")
end

function PlayerManager:GetCurrentTool(player)
	local playerData = PlayerManager.ActivePlayers[player.UserId]
	if not playerData then return nil end
	
	return playerData.currentTool
end

function PlayerManager:HasTool(player, toolType)
	local playerTools = PlayerManager.PlayerTools[player.UserId]
	if not playerTools then return false end
	
	return playerTools[toolType] == true
end

function PlayerManager:UnlockTool(player, toolType)
	local playerTools = PlayerManager.PlayerTools[player.UserId]
	if not playerTools then return false end
	
	playerTools[toolType] = true
	
	-- Save to profile
	PlayerManager:SavePlayerSettings(player)
	
	print("Player", player.Name, "unlocked tool:", toolType)
	
	return true
end

function PlayerManager:GetPlayerSettings(player)
	return PlayerManager.PlayerSettings[player.UserId] or {
		selectedTool = "none",
		autoInteract = false,
		catNotifications = true,
		visualPreferences = {
			showMoodIndicators = true,
			showRelationshipBars = true,
			animationQuality = "high"
		}
	}
end

function PlayerManager:UpdatePlayerSettings(player, newSettings)
	if not PlayerManager.PlayerSettings[player.UserId] then
		PlayerManager.PlayerSettings[player.UserId] = {}
	end
	
	-- Merge new settings
	for key, value in pairs(newSettings) do
		if type(value) == "table" and PlayerManager.PlayerSettings[player.UserId][key] then
			-- Merge nested tables
			for subKey, subValue in pairs(value) do
				PlayerManager.PlayerSettings[player.UserId][key][subKey] = subValue
			end
		else
			PlayerManager.PlayerSettings[player.UserId][key] = value
		end
	end
	
	-- Save to profile
	PlayerManager:SavePlayerSettings(player)
	
	print("Updated settings for player:", player.Name)
end

function PlayerManager:UpdateNearbyCats(player, catIds)
	local playerData = PlayerManager.ActivePlayers[player.UserId]
	if not playerData then return end
	
	playerData.nearbyCats = catIds or {}
	
	-- Notify client about nearby cats if enabled
	local settings = PlayerManager:GetPlayerSettings(player)
	if settings.catNotifications and #catIds > 0 then
		-- This would trigger a client notification
		print("Player", player.Name, "has", #catIds, "nearby cats")
	end
end

function PlayerManager:GetNearbyCats(player)
	local playerData = PlayerManager.ActivePlayers[player.UserId]
	if not playerData then return {} end
	
	return playerData.nearbyCats
end

function PlayerManager:CanInteract(player, interactionType)
	local playerData = PlayerManager.ActivePlayers[player.UserId]
	if not playerData then return false end
	
	-- Check cooldown
	local cooldownEnd = playerData.toolCooldowns[interactionType]
	if cooldownEnd and os.time() < cooldownEnd then
		return false
	end
	
	return true
end

function PlayerManager:SetInteractionCooldown(player, interactionType, duration)
	local playerData = PlayerManager.ActivePlayers[player.UserId]
	if not playerData then return end
	
	playerData.toolCooldowns[interactionType] = os.time() + duration
	
	-- Clean up old cooldowns
	for interaction, endTime in pairs(playerData.toolCooldowns) do
		if os.time() > endTime then
			playerData.toolCooldowns[interaction] = nil
		end
	end
end

function PlayerManager:GetAllActivePlayers()
	local activePlayers = {}
	
	for userId, playerData in pairs(PlayerManager.ActivePlayers) do
		table.insert(activePlayers, playerData.player)
	end
	
	return activePlayers
end

-- Component initialization
function PlayerManager.Init()
	-- Load dependencies
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Knit = require(ReplicatedStorage.Packages.Knit)
	ProfileService = Knit.GetService("ProfileService")
	
	print("PlayerManager component initialized")
end

function PlayerManager.Start()
	print("PlayerManager component started")
end

return PlayerManager