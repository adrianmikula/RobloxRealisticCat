-- Setup Test Environment Script
-- Creates the necessary workspace objects for testing the cat spawning system

local workspace = game:GetService("Workspace")

-- Function to create test objects
local function setupTestEnvironment()
    print("🔄 Setting up test environment...")
    
    -- Clean up existing test objects
    local existingTest = workspace:FindFirstChild("TEST")
    if existingTest then
        existingTest:Destroy()
    end
    
    local existingSpawn = workspace:FindFirstChild("SPAWN")
    if existingSpawn then
        existingSpawn:Destroy()
    end
    
    -- Create TEST part with ProximityPrompt
    local testPart = Instance.new("Part")
    testPart.Name = "TEST"
    testPart.Size = Vector3.new(4, 4, 4)
    testPart.Position = Vector3.new(0, 2, 0)
    testPart.Anchored = true
    testPart.BrickColor = BrickColor.new("Bright blue")
    testPart.Material = Enum.Material.Neon
    testPart.Parent = workspace
    
    local testPrompt = Instance.new("ProximityPrompt")
    testPrompt.Name = "ProximityPrompt"
    testPrompt.ActionText = "Run Tests"
    testPrompt.ObjectText = "Test Console"
    testPrompt.MaxActivationDistance = 10
    testPrompt.Parent = testPart
    
    -- Create SPAWN part with ProximityPrompt
    local spawnPart = Instance.new("Part")
    spawnPart.Name = "SPAWN"
    spawnPart.Size = Vector3.new(4, 4, 4)
    spawnPart.Position = Vector3.new(10, 2, 0)
    spawnPart.Anchored = true
    spawnPart.BrickColor = BrickColor.new("Bright green")
    spawnPart.Material = Enum.Material.Neon
    spawnPart.Parent = workspace
    
    local spawnPrompt = Instance.new("ProximityPrompt")
    spawnPrompt.Name = "ProximityPrompt"
    spawnPrompt.ActionText = "Spawn Cat"
    spawnPrompt.ObjectText = "Cat Spawner"
    spawnPrompt.MaxActivationDistance = 10
    spawnPrompt.Parent = spawnPart
    
    -- Create a simple spawn area
    local spawnArea = Instance.new("Part")
    spawnArea.Name = "SpawnArea"
    spawnArea.Size = Vector3.new(20, 1, 20)
    spawnArea.Position = Vector3.new(0, 0, 0)
    spawnArea.Anchored = true
    spawnArea.BrickColor = BrickColor.new("Dark green")
    spawnArea.Material = Enum.Material.Grass
    spawnArea.Parent = workspace
    
    print("✅ Test environment setup complete!")
    print("   - TEST part (blue): Run test commands")
    print("   - SPAWN part (green): Spawn cats")
    print("   - SpawnArea (grass): Cats will spawn here")
    print("")
    print("🎮 Testing Methods:")
    print("   1. Proximity Prompts: Interact with TEST and SPAWN parts")
    print("   2. Keyboard: Press 1-5 keys for spawn tests")
    print("   3. Chat Commands: /spawncat, /listcats, /clearcats, /testai")
end

-- Run setup when server starts
setupTestEnvironment()

return {
    SetupTestEnvironment = setupTestEnvironment
}