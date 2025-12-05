-- Simple Lune test runner that doesn't depend on Jest-Lua
-- Good for getting started quickly
-- Run with: lune run scripts/simple-test-runner.lua

print("🐱 Simple Lune Test Runner")
print("==========================")

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
        end
    }
end

-- Load and test the sum module
local sum
local sumSuccess, sumError = pcall(function()
    -- Use Lune's fs module for file operations
    local fs = require("fs")
    
    -- Read the sum.lua file
    local sumPath = "src/sum.lua"
    if not fs.exists(sumPath) then
        error("Could not find " .. sumPath)
    end
    
    local sumCode = fs.readFile(sumPath)
    if not sumCode then
        error("Could not read " .. sumPath)
    end
    
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
    
    -- Verify it's a function
    if type(sum) ~= "function" then
        error("sum.lua should return a function, got " .. type(sum))
    end
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

-- Math utils tests
TestFramework.describe("Math Utilities", function()
    TestFramework.it("should calculate correctly", function()
        local mathUtils = {
            add = function(a, b) return a + b end,
            multiply = function(a, b) return a * b end,
            clamp = function(v, min, max)
                if v < min then return min end
                if v > max then return max end
                return v
            end
        }
        
        TestFramework.expect(mathUtils.add(2, 3)).toBe(5)
        TestFramework.expect(mathUtils.multiply(4, 5)).toBe(20)
        TestFramework.expect(mathUtils.clamp(15, 0, 10)).toBe(10)
        TestFramework.expect(mathUtils.clamp(-5, 0, 10)).toBe(0)
        TestFramework.expect(mathUtils.clamp(5, 0, 10)).toBe(5)
    end)
end)

-- Print results
print("\n📊 Test Results:")
print("---------------")
print(string.format("Passed: %d", TestFramework.passed))
print(string.format("Failed: %d", TestFramework.failed))
print(string.format("Total:  %d", TestFramework.passed + TestFramework.failed))

if TestFramework.failed == 0 then
    print("\n✅ All tests passed!")
    os.exit(0)
else
    print("\n❌ Some tests failed")
    os.exit(1)
end