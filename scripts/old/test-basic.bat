@echo off
echo ================================
echo 🧪 Basic Lua Test
echo ================================
echo.

echo 1. Testing Lua execution...
echo    Creating test.lua...
(
echo print("Hello from Lua!")
echo print("1 + 2 = " .. (1 + 2))
echo print("Testing complete!")
) > test.lua

echo    Running test.lua with Lune...
lune test.lua

if %errorlevel% neq 0 (
    echo ❌ Lua test failed
    del test.lua
    pause
    exit /b 1
)

echo    ✅ Basic Lua execution works
del test.lua

echo.
echo 2. Testing file reading...
echo    Creating test file...
(
echo return function(a, b)
echo     return a + b
echo end
) > test-sum.lua

echo    Loading and testing test-sum.lua...
(
echo local fs = require("fs")
echo local code = fs.readFile("test-sum.lua")
echo local chunk = load(code, "test-sum.lua", "t", {})
echo local sum = chunk()
echo print("sum(2, 3) = " .. sum(2, 3))
echo if sum(2, 3) == 5 then
echo     print("✅ File reading and execution works!")
echo else
echo     print("❌ File reading test failed")
echo end
) > test-file.lua

lune test-file.lua

if %errorlevel% neq 0 (
    echo ❌ File reading test failed
    del test-sum.lua
    del test-file.lua
    pause
    exit /b 1
)

echo    ✅ File reading works
del test-sum.lua
del test-file.lua

echo.
echo 3. Testing actual sum.lua...
if exist src\sum.lua (
    echo    Found src\sum.lua, testing...
    (
    echo local fs = require("fs")
    echo local code = fs.readFile("src/sum.lua")
    echo local chunk = load(code, "sum.lua", "t", {})
    echo local sum = chunk()
    echo print("Testing sum.lua:")
    echo "sum(1, 2) = " .. sum(1, 2)
    echo "sum(10, 20) = " .. sum(10, 20)
    echo if sum(1, 2) == 3 and sum(10, 20) == 30 then
    echo     print("✅ sum.lua works correctly!")
    echo else
    echo     print("❌ sum.lua test failed")
    echo end
    ) > test-actual.lua
    
    lune test-actual.lua
    del test-actual.lua
    
    if %errorlevel% neq 0 (
        echo ❌ Actual sum.lua test failed
        pause
        exit /b 1
    )
    
    echo    ✅ Actual sum.lua works
) else (
    echo    ⚠️ src\sum.lua not found
)

echo.
echo ================================
echo 🎉 All basic tests passed!
echo ================================
echo.
echo Next: Try the full test runner:
echo   scripts\run-tests.bat
echo.
pause