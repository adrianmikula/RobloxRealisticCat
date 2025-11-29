local TestCommands = {}

-- External dependencies
local CatService

-- Test command to spawn cats via chat
function TestCommands:HandleTestCommand(player, command, args)
    if command == "spawncat" then
        local profileType = args[1] or "Friendly"
        local count = tonumber(args[2]) or 1
        
        print("🔄 Test command: Spawning", count, "cats with profile:", profileType)
        
        for i = 1, count do
            local catId = "test_cmd_" .. player.UserId .. "_" .. i .. "_" .. os.time()
            local catData = CatService.Components.CatManager:CreateCat(catId, profileType)
            CatService.ActiveCats[catId] = catData
            
            -- Position near player
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                catData.currentState.position = character.HumanoidRootPart.Position + Vector3.new(5 + i * 2, 0, 5 + i * 2)
            end
            
            print("✅ Spawned test cat:", catId, "for player:", player.Name)
        end
        
        return true
        
    elseif command == "listcats" then
        local allCats = CatService.ActiveCats
        local count = 0
        for _ in pairs(allCats) do count = count + 1 end
        
        print("📊 Current cats in game:", count)
        
        for catId, catData in pairs(allCats) do
            print("   ", catId, "-", catData.moodState.currentMood, "-", catData.currentState.position)
        end
        
        return true
        
    elseif command == "clearcats" then
        local allCats = CatService.ActiveCats
        local count = 0
        
        for catId in pairs(allCats) do
            CatService.ActiveCats[catId] = nil
            count += 1
        end
        
        print("🧹 Cleared", count, "cats from the game")
        return true
        
    elseif command == "testai" then
        print("🤖 Testing AI system...")
        
        -- Spawn a test cat for AI testing
        local catId = "ai_test_" .. os.time()
        local catData = CatService.Components.CatManager:CreateCat(catId, "Curious")
        CatService.ActiveCats[catId] = catData
        
        print("✅ Created AI test cat:", catId)
        print("   Initial state:", catData.behaviorState.currentAction)
        
        return true
    elseif command == "runtests" then
        -- Forward to CatTestRunner
        local CatTestRunner = require(script.Parent.CatTestRunner)
        if CatTestRunner then
            CatTestRunner:RunAllTests()
            return true
        else
            print("❌ CatTestRunner not available")
            return false
        end
    elseif command == "clienttests" then
        print("🎮 Client tests should be run from client-side")
        print("   Type /clienttests in chat to run client tests")
        print("   Note: Client tests run on the player's device")
        return true
    end
    
    return false
end

-- Register chat commands
function TestCommands:SetupChatCommands()
    local Players = game:GetService("Players")
    
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            if string.sub(message, 1, 1) == "/" then
                local parts = string.split(string.sub(message, 2), " ")
                local command = parts[1]:lower()
                local args = {}
                
                for i = 2, #parts do
                    table.insert(args, parts[i])
                end
                
                local success = TestCommands:HandleTestCommand(player, command, args)
                
                if success then
                    print("✅ Executed test command:", command, "for player:", player.Name)
                else
                    print("❌ Unknown test command:", command)
                end
            end
        end)
    end)
end

-- Component initialization
function TestCommands.Init()
    -- Get reference to parent CatService
    CatService = script.Parent.Parent.Parent
    
    print("TestCommands component initialized")
end

function TestCommands.Start()
    -- Setup chat commands
    TestCommands:SetupChatCommands()
    
    print("TestCommands component started - Chat commands available:")
    print("   /spawncat [profile] [count] - Spawn test cats")
    print("   /listcats - List all current cats")
    print("   /clearcats - Remove all cats")
    print("   /testai - Test AI system")
end

return TestCommands