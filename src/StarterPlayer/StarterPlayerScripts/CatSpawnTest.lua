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

-- Input handling for testing
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.One then
        -- Press 1 to spawn a friendly cat
        spawnTestCat("Friendly")
    elseif input.KeyCode == Enum.KeyCode.Two then
        -- Press 2 to spawn a playful cat
        spawnTestCat("Playful")
    elseif input.KeyCode == Enum.KeyCode.Three then
        -- Press 3 to spawn an independent cat
        spawnTestCat("Independent")
    elseif input.KeyCode == Enum.KeyCode.Four then
        -- Press 4 to spawn 3 cats
        spawnMultipleCats(3, "Friendly")
    elseif input.KeyCode == Enum.KeyCode.Five then
        -- Press 5 to test cat removal (if implemented)
        print("⚠️ Cat removal test not yet implemented")
    end
end)

-- Print instructions
print("🐱 Cat Spawning Test Script Loaded!")
print("Keyboard Controls:")
print("   [1] - Spawn Friendly Cat")
print("   [2] - Spawn Playful Cat")
print("   [3] - Spawn Independent Cat")
print("   [4] - Spawn 3 Friendly Cats")
print("   [5] - Test Cat Removal (Not implemented)")
print("")
print("Check the output window for spawn results!")