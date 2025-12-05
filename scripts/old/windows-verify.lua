#!/usr/bin/env lune

-- Windows-specific verification script
print("🪟 Windows Test Setup Verification")
print("=================================")

-- Try to load fs module - it's built into Lune
local fs
local fsSuccess, fsError = pcall(function()
    fs = require("fs")
end)

if not fsSuccess then
    print("❌ Failed to load fs module:")
    print("   Error: " .. fsError)
    print("")
    print("💡 Lune's built-in modules should be available")
    print("💡 Try: lune --version to verify installation")
    print("💡 Make sure you're using the correct Lune version")
    os.exit(1)
end

print("\n1. Checking Lune installation...")
local luneVersion = os.execute("lune --version")
if luneVersion == 0 then
    print("   ✅ Lune is installed and in PATH")
else
    print("   ❌ Lune not found in PATH")
    print("   Download from: https://lune.sh")
    print("   Add to PATH or use full path to lune.exe")
end

print("\n2. Checking current directory...")
local currentDir = fs.cwd()
print("   Current directory: " .. currentDir)

print("\n3. Checking critical files...")
local filesToCheck = {
    "src/sum.lua",
    "scripts/windows-test-runner.lua",
    "scripts/simple-test-runner.lua",
    "src/__tests__/sum.spec.lua"
}

local allFilesExist = true
for _, file in ipairs(filesToCheck) do
    local exists = fs.exists(file)
    local status = exists and "✅" or "❌"
    print(string.format("   %s %s", status, file))
    if not exists then
        allFilesExist = false
        print("        Path: " .. fs.absolute(file) or "not found")
    end
end

print("\n4. Checking directory structure...")
local directories = {
    "src",
    "src/__tests__",
    "scripts",
    "src/ReplicatedStorage/SharedSource/Utilities"
}

for _, dir in ipairs(directories) do
    local exists = fs.exists(dir)
    local status = exists and "✅" or "❌"
    print(string.format("   %s %s/", status, dir))
end

print("\n5. Testing file reading...")
local testFile = "src/sum.lua"
if fs.exists(testFile) then
    local content = fs.readFile(testFile)
    if content then
        print("   ✅ Can read " .. testFile)
        print("   File size: " .. #content .. " bytes")
        print("   First line: " .. content:sub(1, math.min(50, #content)):gsub("\n", "\\n"))
    else
        print("   ❌ Cannot read " .. testFile)
        allFilesExist = false
    end
else
    print("   ❌ " .. testFile .. " not found")
    allFilesExist = false
end

print("\n6. Testing Lua execution...")
local success, errorMsg = pcall(function()
    -- Simple Lua code
    local result = 1 + 2
    if result == 3 then
        print("   ✅ Basic Lua execution works")
    else
        error("Basic math failed: 1 + 2 = " .. result)
    end
    
    -- Test load function
    local chunk = load("return function(a,b) return a+b end", "test", "t")
    if chunk then
        local add = chunk()
        if add(2, 3) == 5 then
            print("   ✅ load() function works")
        else
            error("load() produced incorrect function")
        end
    else
        error("load() failed")
    end
end)

if not success then
    print("   ❌ Lua execution test failed: " .. errorMsg)
    allFilesExist = false
end

print("\n🎯 Verification Summary")
print("=====================")
if allFilesExist then
    print("✅ All critical checks passed")
    print("✅ File system access works")
    print("✅ Lua execution works")
    print("\n🚀 Ready to run Windows test runner!")
    print("\nRun this command:")
    print("  lune run scripts/windows-test-runner.lua")
    print("\nOr try the simple runner:")
    print("  lune run scripts/simple-test-runner.lua")
    os.exit(0)
else
    print("❌ Some issues found")
    print("\n📋 Common Windows issues:")
    print("1. File paths - Use forward slashes (/) not backslashes (\\)")
    print("2. File permissions - Check if files are readable")
    print("3. Current directory - Run from project root")
    print("4. Lune PATH - Make sure lune.exe is in PATH")
    print("\n💡 Try running from PowerShell as Administrator")
    print("💡 Check file paths with: Get-ChildItem -Recurse")
    os.exit(1)
end