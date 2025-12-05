-- Test to diagnose require() issues in Lune
print("🔧 TESTING REQUIRE() IN LUNE")
print("============================")

print("")
print("1. Testing basic require...")

-- Try to require built-in modules
local modulesToTest = {
    "fs",
    "os",
    "io",
    "string",
    "table",
    "math",
    "debug"
}

for _, moduleName in ipairs(modulesToTest) do
    local success, result = pcall(require, moduleName)
    if success then
        print("   ✅ require('" .. moduleName .. "') works")
        print("      Type: " .. type(result))
    else
        print("   ❌ require('" .. moduleName .. "') failed")
        print("      Error: " .. result)
    end
end

print("")
print("2. Testing package.path...")
print("   package.path = " .. (package.path or "nil"))

print("")
print("3. Testing _G table...")
print("   _G type: " .. type(_G))
local count = 0
for k, v in pairs(_G) do
    if type(k) == "string" and k:sub(1, 1) ~= "_" then
        count = count + 1
        if count <= 5 then  -- Show first 5
            print("   _G['" .. k .. "'] = " .. type(v))
        end
    end
end
if count > 5 then
    print("   ... and " .. (count - 5) .. " more")
end

print("")
print("4. Testing if fs is available differently...")

-- Check if fs is in _G
if _G.fs then
    print("   ✅ fs is in _G")
    print("   Type: " .. type(_G.fs))
else
    print("   ❌ fs not in _G")
end

-- Check if there's a global fs
if fs then
    print("   ✅ fs is a global")
    print("   Type: " .. type(fs))
else
    print("   ❌ fs not a global")
end

print("")
print("5. Testing file operations without require...")

-- Try to use io module directly
if io then
    print("   ✅ io module available")
    print("   Type: " .. type(io))
    
    -- Try to open a file
    local file = io.open("src/sum.lua", "r")
    if file then
        print("   ✅ io.open works")
        local content = file:read("*a")
        file:close()
        print("   File size: " .. #content .. " bytes")
        
        -- Try to load it
        local chunk = load(content, "sum.lua", "t", {})
        if chunk then
            local sum = chunk()
            print("   ✅ Can load sum.lua")
            print("   sum(3, 4) = " .. sum(3, 4))
        else
            print("   ❌ Cannot load sum.lua code")
        end
    else
        print("   ❌ io.open failed")
    end
else
    print("   ❌ io module not available")
end

print("")
print("🎯 DIAGNOSIS COMPLETE")
print("====================")
print("")
print("Based on the output:")
print("• If require() works → Use require('fs')")
print("• If require() fails → Use io module instead")
print("• If io works → We can read files without fs")
print("")
print("This will tell us how to fix the test runners!")