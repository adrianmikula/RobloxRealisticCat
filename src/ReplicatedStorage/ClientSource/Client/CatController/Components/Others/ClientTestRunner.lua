local ClientTestRunner = {}

-- External dependencies
local CatController

-- Test results storage
local ClientTestRunner = {
    TestResults = {},
    CurrentTest = nil,
    TestSuite = {}
}

-- Test utilities
function ClientTestRunner:Assert(condition, message)
    if not condition then
        error("Assertion failed: " .. (message or "No message"))
    end
end

function ClientTestRunner:AssertEqual(actual, expected, message)
    if actual ~= expected then
        error("Assertion failed: " .. (message or "Expected " .. tostring(expected) .. " but got " .. tostring(actual)))
    end
end

function ClientTestRunner:AssertNotNil(value, message)
    if value == nil then
        error("Assertion failed: " .. (message or "Value is nil"))
    end
end

function ClientTestRunner:AssertType(value, expectedType, message)
    if type(value) ~= expectedType then
        error("Assertion failed: " .. (message or "Expected type " .. expectedType .. " but got " .. type(value)))
    end
end

-- Test suite definition
function ClientTestRunner:DefineTestSuite()
    ClientTestRunner.TestSuite = {
        {
            name = "Component Access Tests",
            tests = {
                {
                    name = "All Components Loaded",
                    func = function()
                        ClientTestRunner:AssertNotNil(CatController.Components, "Components table should exist")
                        ClientTestRunner:AssertType(CatController.Components, "table", "Components should be a table")
                        
                        local expectedComponents = {
                            "CatRenderer",
                            "AnimationHandler", 
                            "ActionHandler",
                            "MoodVisualizer",
                            "ToolManager",
                            "InputHandler",
                            "UIController"
                        }
                        
                        for _, componentName in ipairs(expectedComponents) do
                            ClientTestRunner:AssertNotNil(
                                CatController.Components[componentName], 
                                "Component should exist: " .. componentName
                            )
                        end
                        
                        return "✅ All components loaded test passed"
                    end
                },
                {
                    name = "Get and Set Components",
                    func = function()
                        ClientTestRunner:AssertNotNil(CatController.GetComponent, "Get component should exist")
                        ClientTestRunner:AssertNotNil(CatController.SetComponent, "Set component should exist")
                        
                        ClientTestRunner:AssertType(CatController.GetComponent, "table", "Get component should be a table")
                        ClientTestRunner:AssertType(CatController.SetComponent, "table", "Set component should be a table")
                        
                        return "✅ Get and Set components test passed"
                    end
                }
            }
        },
        {
            name = "Method Availability Tests",
            tests = {
                {
                    name = "Controller Methods Available",
                    func = function()
                        local requiredMethods = {
                            "GetPlayerTools",
                            "EquipTool", 
                            "GetAllCats",
                            "InteractWithCat",
                            "UnequipTool",
                            "SetupInputHandling",
                            "CullDistantCats"
                        }
                        
                        for _, methodName in ipairs(requiredMethods) do
                            ClientTestRunner:AssertNotNil(
                                CatController[methodName],
                                "Controller method should exist: " .. methodName
                            )
                            ClientTestRunner:AssertType(
                                CatController[methodName], 
                                "function",
                                "Controller method should be function: " .. methodName
                            )
                        end
                        
                        return "✅ Controller methods test passed"
                    end
                },
                {
                    name = "Component Methods Available",
                    func = function()
                        local componentMethods = {
                            CatRenderer = {"SpawnCatVisual", "RemoveCatVisual", "UpdateCatVisual", "CullDistantCats"},
                            AnimationHandler = {"PlayAnimation", "StopAnimation"},
                            ActionHandler = {"HandleAction", "StopAction"},
                            ToolManager = {"EquipTool", "UnequipTool"},
                            InputHandler = {"SetupInputs", "CleanupInputs"}
                        }
                        
                        for componentName, methods in pairs(componentMethods) do
                            local component = CatController.Components[componentName]
                            ClientTestRunner:AssertNotNil(component, "Component should exist: " .. componentName)
                            
                            for _, methodName in ipairs(methods) do
                                ClientTestRunner:AssertNotNil(
                                    component[methodName],
                                    "Component method should exist: " .. componentName .. "." .. methodName
                                )
                            end
                        end
                        
                        return "✅ Component methods test passed"
                    end
                }
            }
        },
        {
            name = "Input System Tests",
            tests = {
                {
                    name = "Input Handler Setup",
                    func = function()
                        local inputHandler = CatController.Components.InputHandler
                        ClientTestRunner:AssertNotNil(inputHandler, "InputHandler should exist")
                        
                        -- Test that setup method exists
                        ClientTestRunner:AssertNotNil(inputHandler.SetupInputs, "SetupInputs method should exist")
                        
                        -- Test that input handler has required properties
                        ClientTestRunner:AssertNotNil(inputHandler.CurrentTool, "CurrentTool should exist")
                        ClientTestRunner:AssertNotNil(inputHandler.InteractionRange, "InteractionRange should exist")
                        
                        return "✅ Input handler setup test passed"
                    end
                },
                {
                    name = "Tool Manager Setup",
                    func = function()
                        local toolManager = CatController.Components.ToolManager
                        ClientTestRunner:AssertNotNil(toolManager, "ToolManager should exist")
                        
                        -- Test tool manager properties
                        ClientTestRunner:AssertNotNil(toolManager.EquippedTool, "EquippedTool should exist")
                        ClientTestRunner:AssertNotNil(toolManager.ToolInstances, "ToolInstances should exist")
                        
                        -- Test tool methods
                        ClientTestRunner:AssertNotNil(toolManager.EquipTool, "EquipTool method should exist")
                        ClientTestRunner:AssertNotNil(toolManager.UnequipTool, "UnequipTool method should exist")
                        
                        return "✅ Tool manager setup test passed"
                    end
                }
            }
        },
        {
            name = "Visual System Tests",
            tests = {
                {
                    name = "Cat Renderer Setup",
                    func = function()
                        local catRenderer = CatController.Components.CatRenderer
                        ClientTestRunner:AssertNotNil(catRenderer, "CatRenderer should exist")
                        
                        -- Test renderer properties
                        ClientTestRunner:AssertNotNil(catRenderer.ActiveCatVisuals, "ActiveCatVisuals should exist")
                        ClientTestRunner:AssertNotNil(catRenderer.CatModels, "CatModels should exist")
                        
                        -- Test renderer methods
                        ClientTestRunner:AssertNotNil(catRenderer.SpawnCatVisual, "SpawnCatVisual method should exist")
                        ClientTestRunner:AssertNotNil(catRenderer.RemoveCatVisual, "RemoveCatVisual method should exist")
                        ClientTestRunner:AssertNotNil(catRenderer.UpdateCatVisual, "UpdateCatVisual method should exist")
                        
                        return "✅ Cat renderer setup test passed"
                    end
                },
                {
                    name = "Animation Handler Setup",
                    func = function()
                        local animationHandler = CatController.Components.AnimationHandler
                        ClientTestRunner:AssertNotNil(animationHandler, "AnimationHandler should exist")
                        
                        -- Test animation handler properties
                        ClientTestRunner:AssertNotNil(animationHandler.ActiveAnimations, "ActiveAnimations should exist")
                        ClientTestRunner:AssertNotNil(animationHandler.AnimationTracks, "AnimationTracks should exist")
                        
                        -- Test animation methods
                        ClientTestRunner:AssertNotNil(animationHandler.PlayAnimation, "PlayAnimation method should exist")
                        ClientTestRunner:AssertNotNil(animationHandler.StopAnimation, "StopAnimation method should exist")
                        
                        return "✅ Animation handler setup test passed"
                    end
                }
            }
        }
    }
end

-- Test execution
function ClientTestRunner:RunTest(test)
    ClientTestRunner.CurrentTest = test.name
    
    print("🧪 Running client test: " .. test.name)
    
    local success, result = pcall(test.func)
    
    if success then
        ClientTestRunner.TestResults[test.name] = {
            success = true,
            message = result
        }
        print("✅ Client test passed: " .. test.name)
        print("   " .. result)
    else
        ClientTestRunner.TestResults[test.name] = {
            success = false,
            message = result
        }
        print("❌ Client test failed: " .. test.name)
        print("   Error: " .. result)
    end
    
    ClientTestRunner.CurrentTest = nil
end

function ClientTestRunner:RunTestSuite(suite)
    print("\n📋 Running client test suite: " .. suite.name)
    print("=" .. string.rep("=", #suite.name + 25))
    
    local passed = 0
    local failed = 0
    
    for _, test in ipairs(suite.tests) do
        ClientTestRunner:RunTest(test)
        
        if ClientTestRunner.TestResults[test.name].success then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end
    
    print("\n📊 Client Suite Results: " .. suite.name)
    print("✅ Passed: " .. passed)
    print("❌ Failed: " .. failed)
    print("")
    
    return passed, failed
end

function ClientTestRunner:RunAllTests()
    print("🚀 Starting Client-Side Cat System Tests")
    print("========================================")
    
    ClientTestRunner:DefineTestSuite()
    
    local totalPassed = 0
    local totalFailed = 0
    
    for _, suite in ipairs(ClientTestRunner.TestSuite) do
        local passed, failed = ClientTestRunner:RunTestSuite(suite)
        totalPassed = totalPassed + passed
        totalFailed = totalFailed + failed
    end
    
    print("🎯 CLIENT TEST SUMMARY")
    print("=====================")
    print("✅ Total Passed: " .. totalPassed)
    print("❌ Total Failed: " .. totalFailed)
    print("📊 Success Rate: " .. string.format("%.1f%%", (totalPassed / (totalPassed + totalFailed)) * 100))
    
    if totalFailed == 0 then
        print("🎉 All client tests passed! The client system is working correctly.")
    else
        print("💥 Some client tests failed. Check the output above for details.")
    end
    
    return totalPassed, totalFailed
end

-- Chat command integration
function ClientTestRunner:HandleTestCommand(player, command)
    if command == "clienttests" then
        print("🧪 Player " .. player.Name .. " requested client test run")
        ClientTestRunner:RunAllTests()
        return true
    elseif command == "clientstatus" then
        print("📊 Current client test status:")
        for testName, result in pairs(ClientTestRunner.TestResults) do
            local status = result.success and "✅" or "❌"
            print("   " .. status .. " " .. testName)
        end
        return true
    end
    
    return false
end

-- Component initialization
function ClientTestRunner.Init()
    -- Get reference to parent CatController
    CatController = script.Parent.Parent.Parent
    
    print("ClientTestRunner component initialized")
end

function ClientTestRunner.Start()
    -- Setup test chat commands
    local Players = game:GetService("Players")
    
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            if string.sub(message, 1, 1) == "/" then
                local command = string.sub(message, 2):lower()
                ClientTestRunner:HandleTestCommand(player, command)
            end
        end)
    end)
    
    print("ClientTestRunner component started")
    print("   Client chat commands available:")
    print("   - /clienttests - Run all client-side tests")
    print("   - /clientstatus - Show current client test results")
end

return ClientTestRunner