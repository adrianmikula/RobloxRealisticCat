local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KnitModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit")

-- Wait for Knit to initialize
repeat task.wait() until KnitModule:GetAttribute("KnitServer_Initialized")
local Knit = require(KnitModule)

-- Get the CatService
local CatService = Knit.GetService("CatService")

local testSign = workspace:WaitForChild("TEST")
local testPrompt = testSign:WaitForChild("ProximityPrompt")

-- Connect to the Triggered event for the TEST prompt
testPrompt.Triggered:Connect(function()
    print("TEST ProximityPrompt triggered, firing remote events...")
    game.ReplicatedStorage.RunTestEZ:FireServer()
end)

-- If you add a SIGN part with a ProximityPrompt in the future, you can use the following:

local spawnSign = workspace:WaitForChild("SPAWN")
local spawnPrompt = spawnSign:WaitForChild("ProximityPrompt")

spawnPrompt.Triggered:Connect(function()
	print("SPAWN ProximityPrompt triggered, calling CatService:SpawnCat...")
    
    -- Get player position for cat spawning
    local player = game.Players.LocalPlayer
    local character = player.Character
    local spawnPosition
    
    if character and character:FindFirstChild("HumanoidRootPart") then
        spawnPosition = character.HumanoidRootPart.Position + Vector3.new(5, 0, 5)
    else
        spawnPosition = Vector3.new(0, 5, 0)
    end
    
    -- Call the Knit service method to spawn a cat
    CatService:SpawnCat("Friendly", spawnPosition)
        :andThen(function(catId, catData)
            print("✅ Successfully spawned cat! ID:", catId)
            print("   Position:", catData.currentState.position)
            print("   Mood:", catData.moodState.currentMood)
        end)
        :catch(function(err)
            warn("❌ Failed to spawn cat:", err)
        end)
end)


