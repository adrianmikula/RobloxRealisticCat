@echo off
echo Testing Lune CLI execution...
echo =============================

REM Check if Rokit is available
where rokit >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Rokit not found in PATH
    echo Please install Rokit first: https://github.com/rojo-rbx/rokit
    pause
    exit /b 1
)

echo ✅ Rokit found

REM Check if Lune is installed via Rokit
rokit run lune --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Lune not found via Rokit
    echo Trying to install Lune via Rokit...
    rokit add lune-org/lune@0.10.2
)

echo ✅ Lune available via Rokit

REM Run the simple test
echo.
echo Running Lune test script...
rokit run lune run test-lune-simple.lua

if %errorlevel% equ 0 (
    echo.
    echo ✅ Lune test completed successfully!
) else (
    echo.
    echo ❌ Lune test failed with error code: %errorlevel%
)

pause