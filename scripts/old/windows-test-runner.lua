-- Windows-compatible test runner for Lune
-- Uses Lune's fs module instead of io.open
-- Run with: lune run scripts/windows-test-runner.lua

print("🪟 Windows Lune Test Runner")
print("===========================")

-- Try to load Lune's fs module
local fs
local fsSuccess, fsError = pcall(function()
    fs = require("fs")
end)

if not fsSuccess then
    print("❌ Failed to load fs module:")
    print("   Error: " .. fsError)
    print("")
    print("💡 Lune's built-in 'fs' module should be available")
    print("💡 Try: lune --version to verify installation")
    os.exit(1)
end

-- Mock basic Roblox globals
_G.game = {
    GetService = function(serviceName)
        return { Name = serviceName }
    end
}

_G.workspace = { Name = "Workspace" }
_G.script = { Parent = { Parent = { Parent = { Name = "DataModel" } } } }

-- Simple test framework
local TestFramework = {
    tests = {},
    passed = 0,
    failed = 0
}

function TestFramework.describe(name, fn)
    print("\n📋 " .. name)
    fn()
end

function TestFramework.it(description, fn)
    io.write("  • " .. description .. " ... ")
    local success, err = pcall(fn)
    if success then
        print("✅")
        TestFramework.passed = TestFramework.passed + 1
    else
        print("❌")
        print("    Error: " .. tostring(err))
        TestFramework.failed = TestFramework.failed + 1
    end
end

function TestFramework.expect(value)
    return {
        toBe = function(expected)
            if value ~= expected then
                error("Expected " .. tostring(value) .. " to be " .. tostring(expected))
            end
        end,
        toEqual = function(expected)
            -- Simple deep equality for tables
            if type(value) == "table" and type(expected) == "table" then
                for k, v in pairs(value) do
                    if expected[k] ~= v then
                        error("Tables not equal at key " .. tostring(k))
                    end
                end
                for k, v in pairs(expected) do
                    if value[k] ~= v then
                        error("Tables not equal at key " .. tostring(k))
                    end
                end
            elseif value ~= expected then
                error("Expected " .. tostring(value) .. " to equal " .. tostring(expected))
            end
        end,
        toBeGreaterThan = function(expected)
            if value <= expected then
                error("Expected " .. tostring(value) .. " to be greater than " .. tostring(expected))
            end
        end,
        toBeLessThan = function(expected)
            if value >= expected then
                error("Expected " .. tostring(value) .. " to be less than " .. tostring(expected))
            end
        end,
        toBeGreaterThanOrEqual = function(expected)
            if value < expected then
                error("Expected " .. tostring(value) .. " to be greater than or equal to " .. tostring(expected))
            end
        end,
        toBeLessThanOrEqual = function(expected)
            if value > expected then
                error("Expected " .. tostring(value) .. " to be less than or equal to " .. tostring(expected))
            end
        end
    }
end

-- Load and test the sum module
local sum
local sumSuccess, sumError = pcall(function()
    -- Check if file exists
    if not fs.exists("src/sum.lua") then
        error("Could not find src/sum.lua")
    end
    
    -- Read the file using Lune's fs module
    local sumCode = fs.readFile("src/sum.lua")
    
    -- Create a sandbox to execute the code
    local sandbox = {
        require = require,
        game = _G.game,
        script = _G.script
    }
    
    local chunk = load(sumCode, "sum.lua", "t", sandbox)
    if not chunk then
        error("Failed to load sum.lua")
    end
    
    sum = chunk()
end)

if not sumSuccess then
    print("❌ Failed to load sum module:")
    print("   " .. sumError)
    os.exit(1)
end

-- Run tests
TestFramework.describe("Sum Module", function()
    TestFramework.it("adds 1 + 2 to equal 3", function()
        TestFramework.expect(sum(1, 2)).toBe(3)
    end)
    
    TestFramework.it("adds 0 + 5 to equal 5", function()
        TestFramework.expect(sum(0, 5)).toBe(5)
    end)
    
    TestFramework.it("adds -1 + 1 to equal 0", function()
        TestFramework.expect(sum(-1, 1)).toBe(0)
    end)
    
    TestFramework.it("adds 10 + 20 to equal 30", function()
        TestFramework.expect(sum(10, 20)).toBe(30)
    end)
end)

-- Test MathUtils if it exists
TestFramework.describe("Math Utilities", function()
    -- Check if MathUtils exists
    local mathUtilsPath = "src/ReplicatedStorage/SharedSource/Utilities/MathUtils/init.lua"
    if fs.exists(mathUtilsPath) then
        TestFramework.it("should load MathUtils module", function()
            local mathUtilsCode = fs.readFile(mathUtilsPath)
            local sandbox = {
                require = require,
                game = _G.game,
                script = _G.script
            }
            local chunk = load(mathUtilsCode, "MathUtils.lua", "t", sandbox)
            local MathUtils = chunk()
            
            -- Test a few functions
            TestFramework.expect(MathUtils.clamp(5, 0, 10)).toBe(5)
            TestFramework.expect(MathUtils.clamp(15, 0, 10)).toBe(10)
            TestFramework.expect(MathUtils.clamp(-5, 0, 10)).toBe(0)
            
            TestFramework.expect(MathUtils.lerp(0, 10, 0.5)).toBe(5)
            TestFramework.expect(MathUtils.lerp(0, 10, 0)).toBe(0)
            TestFramework.expect(MathUtils.lerp(0, 10, 1)).toBe(10)
            
            print("      ✅ MathUtils loaded and basic functions work")
        end)
    else
        TestFramework.it("MathUtils not found (skipping)", function()
            print("      ⚠️  MathUtils not found at " .. mathUtilsPath)
        end)
    end
end)

-- Test test files
TestFramework.describe("Test Files", function()
    local testDir = "src/__tests__"
    if fs.exists(testDir) then
        local testFiles = fs.readDir(testDir)
        TestFramework.it("should have test files", function()
            TestFramework.expect(#testFiles).toBeGreaterThan(0)
            print("      ✅ Found " .. #testFiles .. " test files")
        end)
        
        for _, file in ipairs(testFiles) do
            if file:match("%.spec%.lua$") then
                TestFramework.it("should load " .. file, function()
                    local filePath = testDir .. "/" .. file
                    local fileContent = fs.readFile(filePath)
                    -- Just check if we can read it
                    TestFramework.expect(type(fileContent)).toBe("string")
                    TestFramework.expect(#fileContent).toBeGreaterThan(0)
                    print("      ✅ " .. file .. " is readable")
                end)
            end
        end
    else
        TestFramework.it("test directory not found", function()
            print("      ⚠️  Test directory not found at " .. testDir)
        end)
    end
end)

-- Print results
print("\n📊 Test Results:")
print("---------------")
print(string.format("Passed: %d", TestFramework.passed))
print(string.format("Failed: %d", TestFramework.failed))
print(string.format("Total:  %d", TestFramework.passed + TestFramework.failed))

if TestFramework.failed == 0 then
    print("\n✅ All tests passed!")
    print("\n🎉 Windows Lune testing is working!")
    print("\nNext steps:")
    print("1. Try: lune run scripts/simple-test-runner.lua")
    print("2. Try: npm test (if configured)")
    print("3. Write more tests for your game code")
    os.exit(0)
else
    print("\n❌ Some tests failed")
    print("\n💡 Debug tips:")
    print("1. Check if files exist at the expected paths")
    print("2. Run: lune run scripts/verify-test-setup.lua")
    print("3. Check file permissions")
    os.exit(1)
end