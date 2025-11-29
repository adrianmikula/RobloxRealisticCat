-- Simple standalone test script for cat spawning
-- This avoids the component access issues

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for Knit to initialize
local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.OnStart():await()

print("🔧 [SimpleCatTest] Knit initialized, getting CatService...")

local CatService = Knit.GetService("CatService")

if not CatService then
    print("❌ [SimpleCatTest] ERROR: Could not get CatService")
    return
end

print("✅ [SimpleCatTest] CatService obtained successfully")

-- Simple test function that can be called from chat
local function HandleTestCommand(player, command, args)
    if command == "spawncat" then
        local profileType = args[1] or "Friendly"
        local count = tonumber(args[2]) or 1
        
        print("🔄 [SimpleCatTest] Starting spawn command")
        print("   - profileType:", profileType)
        print("   - count:", count)
        print("   - player:", player.Name)
        
        for i = 1, count do
            local catId = "simple_test_" .. player.UserId .. "_" .. i .. "_" .. os.time()
            
            print("🐾 [SimpleCatTest] Creating cat:", catId)
            
            -- Use the service method directly
            local catData = CatService:CreateCat(catId, profileType)
            
            if not catData then
                print("❌ [SimpleCatTest] ERROR: CatService:CreateCat returned nil")
                return false
            end
            
            print("✅ [SimpleCatTest] Cat created successfully")
            
            -- Position near player with proper ground detection
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local playerPos = character.HumanoidRootPart.Position
                local offset = Vector3.new(5 + i * 2, 0, 5 + i * 2)
                
                -- Use raycast to find ground height
                local rayOrigin = playerPos + offset + Vector3.new(0, 10, 0) -- Start above
                local rayDirection = Vector3.new(0, -20, 0) -- Cast downward
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {workspace.Terrain}
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                
                if raycastResult then
                    -- Position on ground with slight offset
                    catData.currentState.position = raycastResult.Position + Vector3.new(0, 2, 0)
                    print("📍 [SimpleCatTest] Positioned cat on ground:", catData.currentState.position)
                else
                    -- Fallback: position at player height
                    catData.currentState.position = playerPos + offset
                    print("📍 [SimpleCatTest] Positioned cat at player level:", catData.currentState.position)
                end
            else
                print("⚠️ [SimpleCatTest] No character found, using default position")
                catData.currentState.position = Vector3.new(0, 10, 0) -- Safe default
            end
            
            print("✅ [SimpleCatTest] Spawned test cat:", catId, "for player:", player.Name)
        end
        
        print("🎉 [SimpleCatTest] Spawn command completed successfully")
        return true
        
    elseif command == "listcats" then
        local allCats = CatService:GetAllCats()
        local count = 0
        for _ in pairs(allCats) do count = count + 1 end
        
        print("📊 [SimpleCatTest] Current cats in game:", count)
        
        for catId, catData in pairs(allCats) do
            print("   ", catId, "-", catData.moodState and catData.moodState.currentMood or "unknown", "-", catData.currentState and catData.currentState.position or "unknown")
        end
        
        return true
        
    elseif command == "clearcats" then
        local allCats = CatService:GetAllCats()
        local count = 0
        
        for catId in pairs(allCats) do
            CatService:RemoveCat(catId)
            count += 1
        end
        
        print("🧹 [SimpleCatTest] Cleared", count, "cats from the game")
        return true
        
    elseif command == "testai" then
        print("🤖 [SimpleCatTest] Testing AI system...")
        
        -- Spawn a test cat for AI testing
        local catId = "ai_test_" .. os.time()
        local catData = CatService:CreateCat(catId, "Curious")
        
        print("✅ [SimpleCatTest] Created AI test cat:", catId)
        print("   Initial state:", catData.behaviorState and catData.behaviorState.currentAction or "unknown")
        
        return true
        
    elseif command == "runtests" then
        print("🧪 [SimpleCatTest] Running CatAI unit tests...")
        
        -- Load and run the CatAITests component
        local catServiceFolder = script.Parent
        local catAITestsScript = catServiceFolder:FindFirstChild("Components"):FindFirstChild("Others"):FindFirstChild("CatAITests")
        
        if catAITestsScript then
            local catAITests = require(catAITestsScript)
            local success = catAITests:RunAllTests()
            
            if success then
                return "✅ All CatAI unit tests passed!"
            else
                return "❌ Some CatAI unit tests failed. Check console for details."
            end
        else
            return "❌ CatAITests component not found"
        end
    end
    
    return false
end

-- Register chat commands
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if string.sub(message, 1, 1) == "/" then
            local parts = string.split(string.sub(message, 2), " ")
            local command = parts[1]:lower()
            local args = {}
            
            for i = 2, #parts do
                table.insert(args, parts[i])
            end
            
            local success = HandleTestCommand(player, command, args)
            
            if success then
                print("✅ [SimpleCatTest] Executed test command:", command, "for player:", player.Name)
            else
                print("❌ [SimpleCatTest] Unknown test command:", command)
            end
        end
    end)
end)

print("🎯 [SimpleCatTest] LOADED AND READY - Chat commands available:")
print("   /spawncat [profile] [count] - Spawn test cats")
print("   /listcats - List all current cats")
print("   /clearcats - Remove all cats")
print("   /testai - Test AI system")

-- Test if we can access CatService methods
print("🧪 [SimpleCatTest] Testing CatService access...")
local testCats = CatService:GetAllCats()
if testCats then
    local catCount = 0
    for _ in pairs(testCats) do catCount = catCount + 1 end
    print("📊 [SimpleCatTest] Current cats in game:", catCount)
else
    print("❌ [SimpleCatTest] ERROR: CatService:GetAllCats returned nil")
end