@echo off
echo Testing Lune installation...
echo.

REM Test 1: Check if Lune is in PATH
where lune >nul 2>nul
if errorlevel 1 (
    echo ❌ Lune not found in PATH
    echo.
    echo Please download Lune from: https://lune.sh
    echo Extract lune.exe and add to PATH
    pause
    exit /b 1
)

echo ✅ Lune found in PATH

REM Test 2: Check Lune version
echo Checking Lune version...
lune --version
if errorlevel 1 (
    echo ❌ Lune version check failed
    pause
    exit /b 1
)

echo ✅ Lune version check passed

REM Test 3: Simple Lua execution
echo.
echo Testing simple Lua execution...
echo print("Hello from Lua! 1+2=" .. (1+2)) > test-simple.lua
REM lune test-simple.lua
lune run ..\src\sum.lua
if errorlevel 1 (
    echo ❌ Simple Lua execution failed
    del test-simple.lua
    pause
    exit /b 1
)
del test-simple.lua

echo ✅ Simple Lua execution works

REM Test 4: Check if we can read files
echo.
echo Testing file reading...
(
echo local fs = require("fs")
echo print("Testing fs module...")
echo if fs then
echo     print("✅ fs module loaded")
echo else
echo     print("❌ fs module not loaded")
echo end
) > test-fs.lua

lune test-fs.lua
if errorlevel 1 (
    echo ❌ File system test failed
    del test-fs.lua
    pause
    exit /b 1
)
del test-fs.lua

echo ✅ File system test passed

echo.
echo ================================
echo 🎉 Lune is working correctly!
echo ================================
echo.
echo Next steps:
echo 1. Run: scripts\test-basic.bat
echo 2. Run: scripts\run-tests.bat
echo.
pause