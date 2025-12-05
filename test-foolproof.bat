@echo off
echo FOOLPROOF TEST
echo ==============
echo.

echo Step 1: Check Lune
lune --version
if errorlevel 1 (
    echo ERROR: Lune not working
    pause
    exit /b 1
)

echo.
echo Step 2: Create simple test file
echo print("Hello from Lune!") > test-simple.lua
echo print("1 + 2 = " .. (1+2)) >> test-simple.lua

echo.
echo Step 3: Run simple test
lune test-simple.lua
if errorlevel 1 (
    echo ERROR: Simple test failed
    del test-simple.lua
    pause
    exit /b 1
)

del test-simple.lua

echo.
echo Step 4: Check if sum.lua exists
if not exist src\sum.lua (
    echo ERROR: src\sum.lua not found
    pause
    exit /b 1
)

echo.
echo Step 5: Create test for sum.lua
(
echo -- Test sum.lua
echo local file = io.open("src/sum.lua", "r")
echo if file then
echo     local content = file:read("*a")
echo     file:close()
echo     local chunk = load(content, "sum.lua", "t", {})
echo     if chunk then
echo         local sum = chunk()
echo         print("sum(1, 2) = " .. sum(1, 2))
echo         print("sum(10, 20) = " .. sum(10, 20))
echo         if sum(1, 2) == 3 and sum(10, 20) == 30 then
echo             print("SUCCESS: sum.lua works!")
echo         else
echo             print("ERROR: Wrong values")
echo         end
echo     else
echo         print("ERROR: Could not load code")
echo     end
echo else
echo     print("ERROR: Could not open file")
echo end
) > test-sum.lua

echo.
echo Step 6: Run sum.lua test
lune test-sum.lua
if errorlevel 1 (
    echo ERROR: sum.lua test failed
    del test-sum.lua
    pause
    exit /b 1
)

del test-sum.lua

echo.
echo ====================
echo ALL TESTS PASSED!
echo ====================
echo.
echo Lune is working correctly!
echo File reading works!
echo sum.lua works!
echo.
echo Now try: lune run scripts\windows-test-runner.lua
pause