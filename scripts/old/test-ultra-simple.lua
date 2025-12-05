-- Ultra simple test runner - no require, no fs module
print("🧪 ULTRA SIMPLE TEST RUNNER")
print("===========================")

-- Mock basic globals (not actually needed for this test)
_G.game = { GetService = function() return {} end }
_G.workspace = {}
_G.script = {}

print("")
print("1. Testing basic Lua...")
print("   1 + 2 = " .. (1 + 2))
print("   'hello' .. ' world' = " .. "hello" .. " world")

print("")
print("2. Testing if we can load sum.lua...")

-- Try to read sum.lua using io.open (might work in some Lune environments)
local sumFile = io.open("src/sum.lua", "r")
if sumFile then
    local sumCode = sumFile:read("*a")
    sumFile:close()
    
    -- Try to load it
    local chunk = load(sumCode, "sum.lua", "t", {})
    if chunk then
        local sum = chunk()
        print("   ✅ Loaded sum.lua")
        print("   sum(1, 2) = " .. sum(1, 2))
        print("   sum(10, 20) = " .. sum(10, 20))
        
        if sum(1, 2) == 3 and sum(10, 20) == 30 then
            print("   ✅ sum.lua works correctly!")
        else
            print("   ❌ sum.lua returned wrong values")
        end
    else
        print("   ❌ Failed to load sum.lua code")
    end
else
    print("   ❌ Could not open src/sum.lua")
    print("   Current directory: " .. (io.popen("cd"):read("*a") or "unknown"))
end

print("")
print("3. Testing file existence check...")

-- Try different ways to check if file exists
local function fileExists(path)
    -- Try io.open
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    
    -- Try os.execute (Windows)
    if os.execute("dir \"" .. path .. "\" >nul 2>nul") == 0 then
        return true
    end
    
    return false
end

if fileExists("src/sum.lua") then
    print("   ✅ src/sum.lua exists (checked with io.open)")
else
    print("   ❌ src/sum.lua not found")
end

print("")
print("🎯 TEST COMPLETE")
print("================")
print("")
print("If you see:")
print("✅ Loaded sum.lua")
print("✅ sum.lua works correctly")
print("")
print("Then basic testing works!")
print("")
print("Next: Try the Windows test runner again")
print("  lune run scripts/windows-test-runner.lua")