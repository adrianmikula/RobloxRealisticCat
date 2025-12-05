#!/usr/bin/env lune

-- Debug test runner to help troubleshoot Jest-Lua setup
print("🔧 Debug Test Runner")
print("===================")

-- Check Lune version
print("\n1. Checking Lune version...")
local luneVersion = os.execute("lune --version")
print("   Lune available:", luneVersion == 0 and "✅ Yes" or "❌ No")

-- Check directory structure
print("\n2. Checking directory structure...")
local fs = require("fs")

local directories = {
    "src/__tests__",
    "DevPackages",
    "Packages",
    "scripts"
}

for _, dir in ipairs(directories) do
    local exists = fs.exists(dir)
    print(string.format("   %-20s: %s", dir, exists and "✅ Found" or "❌ Missing"))
end

-- Check test files
print("\n3. Checking test files...")
local testFiles = fs.readDir("src/__tests__") or {}
for _, file in ipairs(testFiles) do
    print("   Found:", file)
end

-- Check Jest-Lua packages
print("\n4. Checking Jest-Lua packages...")
local jestPath = "DevPackages/_Index/jsdotlua_jest@3.10.0/jest"
local jestGlobalsPath = "DevPackages/_Index/jsdotlua_jest-globals@3.10.0/jest-globals"

print("   Jest:", fs.exists(jestPath) and "✅ Found" or "❌ Missing")
print("   JestGlobals:", fs.exists(jestGlobalsPath) and "✅ Found" or "❌ Missing")

-- Try to load Jest-Lua
print("\n5. Trying to load Jest-Lua...")
local success, errorMsg = pcall(function()
    -- Add package paths
    package.path = package.path .. ";./?.lua;./src/?.lua;./DevPackages/_Index/?.lua;./Packages/_Index/?.lua"
    
    -- Mock basic globals
    _G.game = { GetService = function() return {} end }
    _G.workspace = {}
    _G.script = { Parent = {} }
    
    -- Try to require Jest
    local Jest = require("DevPackages/_Index/jsdotlua_jest@3.10.0/jest")
    local JestGlobals = require("DevPackages/_Index/jsdotlua_jest-globals@3.10.0/jest-globals")
    
    print("   ✅ Jest-Lua loaded successfully!")
    print("   Jest version: 3.10.0")
    
    -- Try to run a simple test
    print("\n6. Running a simple test...")
    
    local config = {
        rootDir = ".",
        roots = { "src/__tests__" },
        testMatch = { "**/*.spec.lua" },
        verbose = false,
        testEnvironment = "node"
    }
    
    local result = Jest.runCLI(config, { "src/__tests__" }):awaitStatus()
    
    if type(result) == "table" and result[1] == "Resolved" then
        local testResult = result[2]
        if testResult and testResult.results then
            local r = testResult.results
            print(string.format("   Test Suites: %d passed, %d failed", r.numPassedTestSuites, r.numFailedTestSuites))
            print(string.format("   Tests:       %d passed, %d failed", r.numPassedTests, r.numFailedTests))
            
            if r.numFailedTests == 0 then
                print("   ✅ All tests passed!")
            else
                print("   ❌ Some tests failed")
            end
        end
    else
        print("   ❌ Test execution failed")
        print("   Result:", result)
    end
end)

if not success then
    print("   ❌ Failed to load Jest-Lua:")
    print("   Error:", errorMsg)
    
    -- Try to get more details
    print("\n7. Debugging require paths...")
    print("   Package path:", package.path)
    
    -- Check if we can require a simple module
    local simpleSuccess, simpleError = pcall(function()
        local sum = require("src/sum")
        print("   ✅ Can load src/sum.lua")
        print("   sum(1, 2) =", sum(1, 2))
    end)
    
    if not simpleSuccess then
        print("   ❌ Cannot load src/sum.lua:", simpleError)
    end
end

print("\n🎯 Debug Summary")
print("================")
print("If Jest-Lua is not loading, try:")
print("1. Run: wally install")
print("2. Check DevPackages directory exists")
print("3. Verify wally.toml has Jest dependencies")
print("4. Try: lune run scripts/simple-test-runner.lua")
print("\nFor immediate testing, use the simple runner:")
print("  lune run scripts/simple-test-runner.lua")