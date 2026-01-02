-- Cat Spawning Test Script
-- This script provides a simple way to test cat spawning functionality

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local KnitModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit")

-- Wait for Knit to initialize
repeat task.wait() until KnitModule:GetAttribute("KnitServer_Initialized")
local Knit = require(KnitModule)

-- Get the CatService
local CatService = Knit.GetService("CatService")

local player = Players.LocalPlayer

-- Function to spawn a test cat
local function spawnTestCat(profileType)
    local character = player.Character
    local spawnPosition
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        spawnPosition = character.HumanoidRootPart.Position + Vector3.new(5, 0, 5)
    else
        spawnPosition = Vector3.new(0, 5, 0)
    end
    
    print("🔄 Attempting to spawn cat with profile:", profileType or "Friendly")
    
    CatService:SpawnCat(profileType or "Friendly", spawnPosition)
        :andThen(function(catId, catData)
            print("✅ Successfully spawned cat!")
            print("   ID:", catId)
            print("   Position:", catData.currentState.position)
            print("   Mood:", catData.moodState.currentMood)
            print("   Personality:", catData.profile.personality.friendliness)
        end)
        :catch(function(err)
            warn("❌ Failed to spawn cat:", err)
        end)
end

-- Function to spawn multiple test cats
local function spawnMultipleCats(count, profileType)
    print("🔄 Spawning", count, "cats with profile:", profileType or "Friendly")
    
    for i = 1, count do
        task.wait(0.5) -- Small delay between spawns
        spawnTestCat(profileType)
    end
end

-- Hotkey-based cat spawning has been removed to allow keyboard numbers 1-4 to be used for tool activation
-- Use the UI controller or chat commands (/spawncat) to spawn cats instead

-- Print instructions
print("🐱 Cat Spawning Test Script Loaded!")
print("Note: Hotkey spawning (1-4 keys) has been disabled.")
print("Use the UI controller or /spawncat command to spawn cats instead.")
print("")
print("Check the output window for spawn results!")