#!/usr/bin/env lune

-- Lune + Jest-Lua test runner
-- Run with: lune run scripts/test-runner.lua

-- Enhanced mock Roblox globals for Lune environment
local mockGlobals = {
    game = {
        GetService = function(self, serviceName)
            local services = {
                Workspace = { Name = "Workspace" },
                Players = {
                    Name = "Players",
                    PlayerAdded = { Connect = function() return { Disconnect = function() end } end },
                    PlayerRemoving = { Connect = function() return { Disconnect = function() end } end }
                },
                ReplicatedStorage = { Name = "ReplicatedStorage" },
                ServerScriptService = { Name = "ServerScriptService" },
                ServerStorage = { Name = "ServerStorage" },
                StarterGui = { Name = "StarterGui" },
                StarterPlayer = { Name = "StarterPlayer" },
                RunService = {
                    Name = "RunService",
                    Heartbeat = { Connect = function() return { Disconnect = function() end } end },
                    Stepped = { Connect = function() return { Disconnect = function() end } end },
                    RenderStepped = { Connect = function() return { Disconnect = function() end } end }
                },
                HttpService = {
                    Name = "HttpService",
                    JSONEncode = function(t) return "{}" end,
                    JSONDecode = function(s) return {} end
                },
                DataStoreService = {
                    Name = "DataStoreService",
                    GetDataStore = function(name)
                        return {
                            GetAsync = function(key) return nil end,
                            SetAsync = function(key, value) end,
                            UpdateAsync = function(key, callback) return callback(nil) end
                        }
                    end
                }
            }
            return services[serviceName] or { Name = serviceName }
        end,
        Workspace = { Name = "Workspace" },
        Players = { Name = "Players" }
    },
    workspace = { Name = "Workspace" },
    script = {
        Name = "TestRunner",
        Parent = {
            Name = "Scripts",
            Parent = {
                Name = "ServerScriptService",
                Parent = {
                    Name = "DataModel"
                }
            }
        }
    },
    require = function(module)
        -- Handle @DevPackages and @Project aliases
        if module == "@DevPackages/Jest" then
            return require("DevPackages/_Index/jsdotlua_jest@3.10.0/jest")
        elseif module == "@DevPackages/JestGlobals" then
            return require("DevPackages/_Index/jsdotlua_jest-globals@3.10.0/jest-globals")
        elseif module == "@Project/Sum" then
            return require("src/sum")
        end
        return require(module)
    end
}

-- Inject mock globals into global scope
for key, value in pairs(mockGlobals) do
    _G[key] = value
end

-- Also mock package.path for require to work correctly
package.path = package.path .. ";./?.lua;./src/?.lua;./DevPackages/_Index/?.lua;./Packages/_Index/?.lua"

print("🚀 Running tests with Lune + Jest-Lua...")
print("=========================================")
print("Mocked globals: game, workspace, script, require")
print("")

-- Try to load Jest-Lua with error handling
local Jest, JestGlobals
local success, errorMsg = pcall(function()
    Jest = require("@DevPackages/Jest")
    JestGlobals = require("@DevPackages/JestGlobals")
end)

if not success then
    print("❌ Failed to load Jest-Lua:")
    print("   Error:", errorMsg)
    print("")
    print("💡 Try running: wally install")
    print("💡 Make sure DevPackages directory exists")
    os.exit(1)
end

-- Configure Jest
local config = {
    rootDir = ".",
    roots = { "src/__tests__" },
    testMatch = { "**/*.spec.lua" },
    verbose = true,
    testEnvironment = "node",
    moduleNameMapper = {
        ["^@DevPackages/(.+)$"] = "DevPackages/_Index/jsdotlua_$1@3.10.0/$1",
        ["^@Project/(.+)$"] = "src/$1",
        ["^@Shared/(.+)$"] = "src/ReplicatedStorage/SharedSource/$1"
    }
}

-- Run tests
local status, result = pcall(function()
    return Jest.runCLI(config, { "src/__tests__" }):awaitStatus()
end)

if not status then
    print("❌ Test runner failed:")
    print("   Error:", result)
    os.exit(1)
end

local testStatus, testResult = result, nil
if type(result) == "table" and result.results then
    testResult = result
elseif type(result) == "table" and result[1] and result[2] then
    testStatus, testResult = result[1], result[2]
end

if testStatus == "Resolved" and testResult then
    local results = testResult.results
    print("\n📊 Test Results:")
    print("---------------")
    print(string.format("Test Suites: %d passed, %d failed, %d total", 
        results.numPassedTestSuites, results.numFailedTestSuites, results.numTotalTestSuites))
    print(string.format("Tests:       %d passed, %d failed, %d total", 
        results.numPassedTests, results.numFailedTests, results.numTotalTests))
    print(string.format("Time:        %.2fs", results.startTime and (os.time() - results.startTime) or 0))
    
    if results.numFailedTestSuites == 0 and results.numFailedTests == 0 then
        print("\n✅ All tests passed!")
        os.exit(0)
    else
        print("\n❌ Some tests failed")
        -- Print failure details
        for _, testSuite in ipairs(results.testResults or {}) do
            if testSuite.failureMessage then
                print("\nSuite:", testSuite.name)
                print(testSuite.failureMessage)
            end
        end
        os.exit(1)
    end
else
    print("❌ Test runner returned unexpected result:")
    print("   Status:", testStatus)
    print("   Result type:", type(testResult))
    os.exit(1)
end