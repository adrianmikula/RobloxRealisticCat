@echo off
REM Windows Batch file to run tests
echo ================================
echo 🪟 Windows Test Runner
echo ================================
echo.

REM Check if Lune is installed
echo 1. Checking Lune installation...
where lune >nul 2>nul
if %errorlevel% equ 0 (
    echo    ✅ Lune is installed
    lune --version
) else (
    echo    ❌ Lune not found in PATH
    echo    Download from: https://lune.sh
    echo    Add to PATH or use full path to lune.exe
    pause
    exit /b 1
)

echo.
echo 2. Checking current directory...
echo    Current directory: %cd%

echo.
echo 3. Running Windows test runner...
echo    Command: lune run scripts/windows-test-runner.lua
echo.

lune run scripts/windows-test-runner.lua
if %errorlevel% neq 0 (
    echo.
    echo ❌ Test runner failed with error code %errorlevel%
    echo.
    echo 💡 Try running the verification script:
    echo    powershell -ExecutionPolicy Bypass -File scripts/windows-verify.ps1
    pause
    exit /b %errorlevel%
)

echo.
echo ✅ Tests completed successfully!
echo.
echo 🎉 Windows testing is working!
echo.
echo Next steps:
echo 1. Write tests for your game utilities
echo 2. Set up pre-commit hooks
echo 3. Configure CI/CD pipeline
echo.
pause