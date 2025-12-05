-- Direct test - no fancy stuff
print("DIRECT TEST")
print("===========")

-- Just test basic Lua
print("1. Basic Lua works: " .. (1 + 2))

-- Try to read sum.lua with io.open
print("")
print("2. Trying to read src/sum.lua...")

local file = io.open("src/sum.lua", "r")
if file then
    print("   SUCCESS: File opened")
    local content = file:read("*a")
    file:close()
    
    print("   File size: " .. #content .. " bytes")
    
    -- Try to execute it
    local chunk = load(content, "sum.lua", "t", {})
    if chunk then
        print("   SUCCESS: Code loaded")
        local sum = chunk()
        local result1 = sum(1, 2)
        local result2 = sum(10, 20)
        
        print("   sum(1, 2) = " .. result1)
        print("   sum(10, 20) = " .. result2)
        
        if result1 == 3 and result2 == 30 then
            print("   SUCCESS: sum.lua works correctly!")
        else
            print("   ERROR: sum.lua returned wrong values")
        end
    else
        print("   ERROR: Could not load code")
    end
else
    print("   ERROR: Could not open file")
    print("   Current dir: " .. (io.popen("cd"):read("*a") or "unknown"))
end

print("")
print("TEST COMPLETE")
print("If you see 'SUCCESS: sum.lua works correctly!' then testing works!")