-- Simple standalone test script for cat spawning
-- This avoids the component access issues

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for Knit to initialize
local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.OnStart():await()

local CatService = Knit.GetService("CatService")

-- Simple test function that can be called from chat
local function HandleTestCommand(player, command, args)
    if command == "spawncat" then
        local profileType = args[1] or "Friendly"
        local count = tonumber(args[2]) or 1
        
        print("🔄 Simple test: Spawning", count, "cats with profile:", profileType)
        
        for i = 1, count do
            local catId = "simple_test_" .. player.UserId .. "_" .. i .. "_" .. os.time()
            
            -- Use the service method directly
            local catData = CatService:CreateCat(catId, profileType)
            
            -- Position near player
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                catData.currentState.position = character.HumanoidRootPart.Position + Vector3.new(5 + i * 2, 0, 5 + i * 2)
            end
            
            print("✅ Spawned test cat:", catId, "for player:", player.Name)
        end
        
        return true
        
    elseif command == "listcats" then
        local allCats = CatService:GetAllCats()
        local count = 0
        for _ in pairs(allCats) do count = count + 1 end
        
        print("📊 Current cats in game:", count)
        
        for catId, catData in pairs(allCats) do
            print("   ", catId, "-", catData.moodState.currentMood, "-", catData.currentState.position)
        end
        
        return true
        
    elseif command == "clearcats" then
        local allCats = CatService:GetAllCats()
        local count = 0
        
        for catId in pairs(allCats) do
            CatService:RemoveCat(catId)
            count += 1
        end
        
        print("🧹 Cleared", count, "cats from the game")
        return true
        
    elseif command == "testai" then
        print("🤖 Testing AI system...")
        
        -- Spawn a test cat for AI testing
        local catId = "ai_test_" .. os.time()
        local catData = CatService:CreateCat(catId, "Curious")
        
        print("✅ Created AI test cat:", catId)
        print("   Initial state:", catData.behaviorState.currentAction)
        
        return true
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
                print("✅ Executed simple test command:", command, "for player:", player.Name)
            else
                print("❌ Unknown test command:", command)
            end
        end
    end)
end)

print("SimpleCatTest loaded - Chat commands available:")
print("   /spawncat [profile] [count] - Spawn test cats")
print("   /listcats - List all current cats")
print("   /clearcats - Remove all cats")
print("   /testai - Test AI system")