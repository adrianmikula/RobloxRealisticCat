local CatTestRunner = {}

-- External dependencies
local CatService

-- Test results storage
local CatTestRunner = {
    TestResults = {},
    CurrentTest = nil,
    TestSuite = {}
}

-- Test utilities
function CatTestRunner:Assert(condition, message)
    if not condition then
        error("Assertion failed: " .. (message or "No message"))
    end
end

function CatTestRunner:AssertEqual(actual, expected, message)
    if actual ~= expected then
        error("Assertion failed: " .. (message or "Expected " .. tostring(expected) .. " but got " .. tostring(actual)))
    end
end

function CatTestRunner:AssertNotNil(value, message)
    if value == nil then
        error("Assertion failed: " .. (message or "Value is nil"))
    end
end

function CatTestRunner:AssertType(value, expectedType, message)
    if type(value) ~= expectedType then
        error("Assertion failed: " .. (message or "Expected type " .. expectedType .. " but got " .. type(value)))
    end
end

-- Test suite definition
function CatTestRunner:DefineTestSuite()
    CatTestRunner.TestSuite = {
        {
            name = "Cat Creation Tests",
            tests = {
                {
                    name = "Create Cat with Valid Profile",
                    func = function()
                        local catId = "test_cat_creation_" .. os.time()
                        local catData = CatService:CreateCat(catId, "Friendly")
                        
                        CatTestRunner:AssertNotNil(catData, "Cat data should not be nil")
                        CatTestRunner:AssertType(catData, "table", "Cat data should be a table")
                        CatTestRunner:AssertNotNil(catData.currentState, "Current state should exist")
                        CatTestRunner:AssertNotNil(catData.moodState, "Mood state should exist")
                        CatTestRunner:AssertNotNil(catData.behaviorState, "Behavior state should exist")
                        CatTestRunner:AssertNotNil(catData.profile, "Profile should exist")
                        
                        -- Clean up
                        CatService:RemoveCat(catId)
                        
                        return "✅ Cat creation test passed"
                    end
                },
                {
                    name = "Create Cat with Different Profiles",
                    func = function()
                        local profiles = {"Friendly", "Curious", "Playful", "Independent"}
                        
                        for _, profile in ipairs(profiles) do
                            local catId = "test_profile_" .. profile .. "_" .. os.time()
                            local catData = CatService:CreateCat(catId, profile)
                            
                            CatTestRunner:AssertNotNil(catData, "Cat data should not be nil for profile: " .. profile)
                            CatTestRunner:AssertEqual(catData.profile.personality, profile, "Profile should match: " .. profile)
                            
                            -- Clean up
                            CatService:RemoveCat(catId)
                        end
                        
                        return "✅ Multiple profile creation test passed"
                    end
                }
            }
        },
        {
            name = "Cat State Management Tests",
            tests = {
                {
                    name = "Get Cat State",
                    func = function()
                        local catId = "test_state_" .. os.time()
                        local catData = CatService:CreateCat(catId, "Friendly")
                        
                        local retrievedState = CatService:GetCatState(catId)
                        CatTestRunner:AssertNotNil(retrievedState, "Retrieved state should not be nil")
                        CatTestRunner:AssertEqual(retrievedState, catData, "Retrieved state should match created state")
                        
                        -- Clean up
                        CatService:RemoveCat(catId)
                        
                        return "✅ Get cat state test passed"
                    end
                },
                {
                    name = "Get All Cats",
                    func = function()
                        local initialCats = CatService:GetAllCats()
                        local initialCount = 0
                        for _ in pairs(initialCats) do initialCount = initialCount + 1 end
                        
                        -- Create a test cat
                        local catId = "test_all_cats_" .. os.time()
                        CatService:CreateCat(catId, "Friendly")
                        
                        local allCats = CatService:GetAllCats()
                        local newCount = 0
                        for _ in pairs(allCats) do newCount = newCount + 1 end
                        
                        CatTestRunner:AssertEqual(newCount, initialCount + 1, "Cat count should increase by 1")
                        CatTestRunner:AssertNotNil(allCats[catId], "New cat should be in all cats")
                        
                        -- Clean up
                        CatService:RemoveCat(catId)
                        
                        return "✅ Get all cats test passed"
                    end
                }
            }
        },
        {
            name = "Cat Removal Tests",
            tests = {
                {
                    name = "Remove Existing Cat",
                    func = function()
                        local catId = "test_remove_" .. os.time()
                        CatService:CreateCat(catId, "Friendly")
                        
                        local initialCats = CatService:GetAllCats()
                        local initialCount = 0
                        for _ in pairs(initialCats) do initialCount = initialCount + 1 end
                        
                        CatService:RemoveCat(catId)
                        
                        local finalCats = CatService:GetAllCats()
                        local finalCount = 0
                        for _ in pairs(finalCats) do finalCount = finalCount + 1 end
                        
                        CatTestRunner:AssertEqual(finalCount, initialCount - 1, "Cat count should decrease by 1")
                        CatTestRunner:AssertNil(finalCats[catId], "Removed cat should not be in all cats")
                        
                        return "✅ Cat removal test passed"
                    end
                },
                {
                    name = "Remove Non-Existent Cat",
                    func = function()
                        local nonExistentCatId = "non_existent_cat_" .. os.time()
                        
                        -- This should not throw an error
                        CatService:RemoveCat(nonExistentCatId)
                        
                        return "✅ Remove non-existent cat test passed"
                    end
                }
            }
        },
        {
            name = "Component Integration Tests",
            tests = {
                {
                    name = "CatManager Component",
                    func = function()
                        local catId = "test_component_" .. os.time()
                        local catData = CatService.Components.CatManager:CreateCat(catId, "Friendly")
                        
                        CatTestRunner:AssertNotNil(catData, "CatManager should create cat data")
                        CatTestRunner:AssertType(catData.currentState.position, "Vector3", "Cat should have position")
                        CatTestRunner:AssertType(catData.moodState.currentMood, "string", "Cat should have mood")
                        CatTestRunner:AssertType(catData.behaviorState.currentAction, "string", "Cat should have action")
                        
                        -- Clean up
                        CatService:RemoveCat(catId)
                        
                        return "✅ CatManager component test passed"
                    end
                },
                {
                    name = "CatAI Component",
                    func = function()
                        local catId = "test_ai_" .. os.time()
                        local catData = CatService:CreateCat(catId, "Friendly")
                        
                        -- Test AI initialization
                        CatService.Components.CatAI:InitializeCat(catId, catData)
                        
                        -- Test AI update
                        CatService.Components.CatAI:UpdateCat(catId, catData)
                        
                        -- Should have updated state
                        CatTestRunner:AssertNotNil(catData.behaviorState.currentAction, "AI should set current action")
                        CatTestRunner:AssertNotNil(catData.behaviorState.targetPosition, "AI should set target position")
                        
                        -- Clean up
                        CatService.Components.CatAI:CleanupCat(catId)
                        CatService:RemoveCat(catId)
                        
                        return "✅ CatAI component test passed"
                    end
                }
            }
        }
    }
end

-- Helper function for AssertNil
function CatTestRunner:AssertNil(value, message)
    if value ~= nil then
        error("Assertion failed: " .. (message or "Value is not nil"))
    end
end

-- Test execution
function CatTestRunner:RunTest(test)
    CatTestRunner.CurrentTest = test.name
    
    print("🧪 Running test: " .. test.name)
    
    local success, result = pcall(test.func)
    
    if success then
        CatTestRunner.TestResults[test.name] = {
            success = true,
            message = result
        }
        print("✅ Test passed: " .. test.name)
        print("   " .. result)
    else
        CatTestRunner.TestResults[test.name] = {
            success = false,
            message = result
        }
        print("❌ Test failed: " .. test.name)
        print("   Error: " .. result)
    end
    
    CatTestRunner.CurrentTest = nil
end

function CatTestRunner:RunTestSuite(suite)
    print("\n📋 Running test suite: " .. suite.name)
    print("=" .. string.rep("=", #suite.name + 20))
    
    local passed = 0
    local failed = 0
    
    for _, test in ipairs(suite.tests) do
        CatTestRunner:RunTest(test)
        
        if CatTestRunner.TestResults[test.name].success then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end
    
    print("\n📊 Suite Results: " .. suite.name)
    print("✅ Passed: " .. passed)
    print("❌ Failed: " .. failed)
    print("")
    
    return passed, failed
end

function CatTestRunner:RunAllTests()
    print("🚀 Starting Comprehensive Cat System Tests")
    print("==========================================")
    
    CatTestRunner:DefineTestSuite()
    
    local totalPassed = 0
    local totalFailed = 0
    
    for _, suite in ipairs(CatTestRunner.TestSuite) do
        local passed, failed = CatTestRunner:RunTestSuite(suite)
        totalPassed = totalPassed + passed
        totalFailed = totalFailed + failed
    end
    
    print("🎯 TEST SUMMARY")
    print("===============")
    print("✅ Total Passed: " .. totalPassed)
    print("❌ Total Failed: " .. totalFailed)
    print("📊 Success Rate: " .. string.format("%.1f%%", (totalPassed / (totalPassed + totalFailed)) * 100))
    
    if totalFailed == 0 then
        print("🎉 All tests passed! The cat system is working correctly.")
    else
        print("💥 Some tests failed. Check the output above for details.")
    end
    
    return totalPassed, totalFailed
end

-- Chat command integration
function CatTestRunner:HandleTestCommand(player, command)
    if command == "runtests" then
        print("🧪 Player " .. player.Name .. " requested test run")
        CatTestRunner:RunAllTests()
        return true
    elseif command == "teststatus" then
        print("📊 Current test status:")
        for testName, result in pairs(CatTestRunner.TestResults) do
            local status = result.success and "✅" or "❌"
            print("   " .. status .. " " .. testName)
        end
        return true
    end
    
    return false
end

-- Component initialization
function CatTestRunner.Init()
    -- Get reference to parent CatService
    CatService = script.Parent.Parent.Parent
    
    print("CatTestRunner component initialized")
end

function CatTestRunner.Start()
    -- Setup test chat commands
    local Players = game:GetService("Players")
    
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            if string.sub(message, 1, 1) == "/" then
                local command = string.sub(message, 2):lower()
                CatTestRunner:HandleTestCommand(player, command)
            end
        end)
    end)
    
    print("CatTestRunner component started")
    print("   Chat commands available:")
    print("   - /runtests - Run all automated tests")
    print("   - /teststatus - Show current test results")
end

return CatTestRunner