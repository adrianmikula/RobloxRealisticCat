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
	print("SPAWN ProximityPrompt triggered, firing remote events...")
    game.ReplicatedStorage.DoCreateCat:FireServer()
end)


