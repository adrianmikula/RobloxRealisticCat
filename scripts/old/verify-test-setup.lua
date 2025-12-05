#!/usr/bin/env lune

-- Quick verification that test setup is ready
print("🔍 Verifying Test Setup")
print("======================")

local fs = require("fs")

-- Check critical files
local criticalFiles = {
    "src/sum.lua",
    "scripts/simple-test-runner.lua",
    "scripts/test-runner.lua",
    "scripts/debug-test-runner.lua",
    "src/__tests__/sum.spec.lua",
    "src/__tests__/math-utils.spec.lua",
    "src/__tests__/math-utils-game.spec.lua"
}

print("\n📁 Checking critical files:")
local allFilesExist = true
for _, file in ipairs(criticalFiles) do
    local exists = fs.exists(file)
    local status = exists and "✅" or "❌"
    print(string.format("  %s %-40s %s", status, file, exists and "Found" or "Missing"))
    if not exists then
        allFilesExist = false
    end
end

-- Check test directory
print("\n📂 Checking test directory structure:")
local testDir = "src/__tests__"
if fs.exists(testDir) then
    print("  ✅ src/__tests__ directory exists")
    local files = fs.readDir(testDir)
    print(string.format("  Found %d test files:", #files))
    for _, file in ipairs(files) do
        print("    - " .. file)
    end
else
    print("  ❌ src/__tests__ directory missing")
    allFilesExist = false
end

-- Check scripts directory
print("\n📜 Checking scripts directory:")
local scriptsDir = "scripts"
if fs.exists(scriptsDir) then
    print("  ✅ scripts directory exists")
    local files = fs.readDir(scriptsDir)
    print(string.format("  Found %d script files:", #files))
    for _, file in ipairs(files) do
        print("    - " .. file)
    end
else
    print("  ❌ scripts directory missing")
    allFilesExist = false
end

-- Check if we can run a simple test
print("\n🧪 Testing basic Lua execution:")
local success, errorMsg = pcall(function()
    -- Mock globals
    _G.game = { GetService = function() return {} end }
    _G.workspace = {}
    
    -- Try to load sum.lua
    local sumCode = fs.readFile("src/sum.lua")
    local chunk = load(sumCode, "sum.lua", "t", {require = require})
    local sum = chunk()
    
    -- Test it
    if sum(1, 2) == 3 then
        print("  ✅ sum.lua loads and works correctly")
        print("     sum(1, 2) = " .. sum(1, 2))
    else
        print("  ❌ sum.lua doesn't work correctly")
        allFilesExist = false
    end
end)

if not success then
    print("  ❌ Failed to load sum.lua: " .. errorMsg)
    allFilesExist = false
end

-- Summary
print("\n🎯 Verification Summary")
print("=====================")
if allFilesExist then
    print("✅ All critical files exist")
    print("✅ Basic Lua execution works")
    print("✅ Test setup appears ready")
    print("")
    print("🚀 Ready to run tests!")
    print("")
    print("Try these commands:")
    print("  lune run scripts/simple-test-runner.lua")
    print("  lune run scripts/test-runner.lua")
    print("  lune run scripts/debug-test-runner.lua")
    print("")
    print("Or use npm if configured:")
    print("  npm test")
    os.exit(0)
else
    print("❌ Some issues found")
    print("")
    print("📋 Next steps:")
    print("1. Check missing files above")
    print("2. Run debug test runner:")
    print("   lune run scripts/debug-test-runner.lua")
    print("3. Check wally packages:")
    print("   wally install")
    print("4. Verify Lune installation:")
    print("   lune --version")
    os.exit(1)
end