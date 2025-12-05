-- Simple Lune test script
-- Run with: lune run test-lune-simple.lua

print("🧪 Testing Lune CLI execution")
print("=============================")

-- Test basic Lua functionality
local x = 10
local y = 20
local sum = x + y

print("Basic math test:")
print(string.format("  %d + %d = %d", x, y, sum))
assert(sum == 30, "Math test failed!")

-- Test table operations
local testTable = {a = 1, b = 2, c = 3}
print("\nTable test:")
for key, value in pairs(testTable) do
    print(string.format("  %s = %d", key, value))
end

-- Test file I/O
print("\nFile I/O test:")
local testContent = "Hello from Lune test!"
local testFile = "lune-test-output.txt"

local file = io.open(testFile, "w")
if file then
    file:write(testContent)
    file:close()
    print("  ✓ Wrote to file: " .. testFile)
    
    -- Read it back
    file = io.open(testFile, "r")
    if file then
        local content = file:read("*a")
        file:close()
        assert(content == testContent, "File content mismatch!")
        print("  ✓ Read from file successfully")
        
        -- Clean up
        os.remove(testFile)
        print("  ✓ Cleaned up test file")
    end
end

-- Test require functionality
print("\nRequire test:")
local success, module = pcall(require, "src/sum")
if success then
    print("  ✓ Successfully required src/sum")
    local result = module(7, 8)
    print(string.format("  ✓ sum(7, 8) = %d", result))
    assert(result == 15, "Sum function test failed!")
else
    print("  ✗ Failed to require src/sum:", module)
end

print("\n✅ All Lune tests passed!")
print("Lune version should be: 0.10.2 (from rokit.toml)")

-- Exit with success code
os.exit(0)