# Windows Testing Scripts

## 📋 Available Scripts

### PowerShell Scripts (.ps1)
- **`windows-verify.ps1`** - Verify Windows setup
- **`setup-testing.ps1`** - Set up testing environment

### Batch Files (.bat)
- **`run-tests.bat`** - Run all tests (double-click to run)

### Lua Scripts (.lua)
- **`windows-test-runner.lua`** - Windows-compatible test runner
- **`simple-test-runner.lua`** - Simple cross-platform runner
- **`test-runner.lua`** - Jest-Lua based runner (advanced)

## 🚀 Quick Start

### Option 1: Double-click (Easiest)
1. Navigate to `scripts/` folder
2. Double-click `run-tests.bat`

### Option 2: PowerShell
```powershell
# Run from project root
powershell -ExecutionPolicy Bypass -File scripts/windows-verify.ps1
scripts\run-tests.bat
```

### Option 3: Command Line
```cmd
cd /d E:\Games\Roblox\RobloxRealisticCat
scripts\run-tests.bat
```

## 🔧 Prerequisites

1. **Lune** - Download from https://lune.sh
   - Extract `lune.exe` to a folder
   - Add to PATH or use full path

2. **PowerShell** (for .ps1 scripts)
   - Windows 10/11 includes PowerShell 5.1+
   - Run as Administrator if needed

## 📁 Script Details

### `windows-verify.ps1`
- Checks Lune installation
- Verifies file paths
- Tests file permissions
- Provides troubleshooting tips

### `run-tests.bat`
- Simple double-click runner
- Checks Lune installation
- Runs Windows test runner
- Shows results in console

### `windows-test-runner.lua`
- Windows-compatible Lua test runner
- Uses Lune's `fs` module (not `io.open`)
- Tests `sum.lua` and other modules
- Clear pass/fail output

## 🐛 Troubleshooting

### "Lune is not recognized"
```powershell
# Check if Lune is in PATH
where lune

# If not, use full path
C:\path\to\lune.exe run scripts/windows-test-runner.lua
```

### PowerShell Execution Policy
```powershell
# Run with bypass (one-time)
powershell -ExecutionPolicy Bypass -File scripts/windows-verify.ps1

# Or set policy (requires Admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### File Not Found Errors
```powershell
# Check current directory
Get-Location

# List files
Get-ChildItem

# Navigate to project root
cd E:\Games\Roblox\RobloxRealisticCat
```

## 🎯 Expected Output

### Successful Test Run
```
🪟 Windows Lune Test Runner
===========================

📋 Sum Module
  • adds 1 + 2 to equal 3 ... ✅
  • adds 0 + 5 to equal 5 ... ✅
  • adds -1 + 1 to equal 0 ... ✅
  • adds 10 + 20 to equal 30 ... ✅

📊 Test Results:
---------------
Passed: 4
Failed: 0
Total:  4

✅ All tests passed!
```

## 🔄 Integration

### VS Code Tasks
Add to `.vscode/tasks.json`:
```json
{
    "label": "Run Windows Tests",
    "type": "shell",
    "command": "scripts\\run-tests.bat",
    "group": "test"
}
```

### Pre-commit Hook
Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
echo "Running tests before commit..."
scripts/run-tests.bat
if [ $? -ne 0 ]; then
    echo "❌ Tests failed - commit aborted"
    exit 1
fi
echo "✅ Tests passed - committing..."
```

## 📚 Documentation

- `docs/testing/WINDOWS_TESTING_GUIDE.md` - Complete Windows guide
- `docs/testing/CLI_TESTING_GUIDE.md` - General testing guide
- `docs/testing/TESTING_STRATEGY.md` - Testing strategy

## 🎉 Getting Help

If you encounter issues:
1. Run `windows-verify.ps1` first
2. Check error messages
3. Verify Lune installation
4. Check file paths

Windows testing should now work perfectly! 🪟