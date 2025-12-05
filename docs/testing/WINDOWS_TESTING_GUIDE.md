# Windows Testing Guide for Roblox Development

## 🪟 Windows-Specific Setup

### Prerequisites
1. **Lune** - Download from https://lune.sh
   - Choose Windows download (lune-windows-x86_64.zip)
   - Extract and add to PATH or use full path to `lune.exe`
   - Verify: `lune --version`

2. **PowerShell** - Use PowerShell (not Command Prompt)
   - Better path handling
   - Better Unicode support
   - Modern features

### Common Windows Issues & Solutions

#### ❌ Issue: "attempt to index nil with 'open'"
**Cause**: Using `io.open()` which doesn't work in Lune on Windows
**Solution**: Use Lune's `fs` module instead
```lua
-- WRONG (won't work on Windows)
local file = io.open("path/to/file.lua", "r")

-- CORRECT (works on Windows)
local fs = require("fs")
local content = fs.readFile("path/to/file.lua")
```

#### ❌ Issue: File path errors
**Cause**: Backslash vs forward slash issues
**Solution**: Always use forward slashes in Lua code
```lua
-- WRONG (might fail)
local path = "src\\sum.lua"

-- CORRECT (always works)
local path = "src/sum.lua"
```

#### ❌ Issue: "module not found" errors
**Cause**: `require` path issues on Windows
**Solution**: Use absolute paths or check current directory
```lua
-- Check current directory
local fs = require("fs")
print("Current dir:", fs.cwd())

-- Use absolute paths if needed
local absolutePath = fs.absolute("src/sum.lua")
```

## 🚀 Quick Start for Windows

### Step 1: Verify Your Setup
```powershell
# Run from project root in PowerShell
lune run scripts/windows-verify.lua
```

### Step 2: Run Windows Test Runner
```powershell
lune run scripts/windows-test-runner.lua
```

### Step 3: Run Simple Test Runner
```powershell
lune run scripts/simple-test-runner.lua
```

## 📁 Windows-Compatible Test Files

### 1. `scripts/windows-test-runner.lua`
- **Purpose**: Main Windows-compatible test runner
- **Features**:
  - Uses Lune's `fs` module (not `io.open`)
  - Handles Windows file paths correctly
  - Tests multiple modules
  - Clear error messages
- **Run**: `lune run scripts/windows-test-runner.lua`

### 2. `scripts/windows-verify.lua`
- **Purpose**: Verify Windows setup
- **Checks**:
  - Lune installation
  - File paths
  - Directory structure
  - File permissions
- **Run**: `lune run scripts/windows-verify.lua`

### 3. `scripts/simple-test-runner.lua` (Updated)
- **Purpose**: Simple cross-platform runner
- **Now uses**: Lune's `fs` module
- **Run**: `lune run scripts/simple-test-runner.lua`

## 🔧 PowerShell Commands

### Basic Navigation
```powershell
# Change to project directory
cd E:\Games\Roblox\RobloxRealisticCat

# List files
Get-ChildItem

# List recursively
Get-ChildItem -Recurse

# Check if file exists
Test-Path src/sum.lua
```

### Running Tests
```powershell
# Run Windows test runner
lune run scripts/windows-test-runner.lua

# Run verification
lune run scripts/windows-verify.lua

# Run simple runner
lune run scripts/simple-test-runner.lua

# Run debug runner
lune run scripts/debug-test-runner.lua
```

### Debugging File Issues
```powershell
# Check current directory
$pwd

# Check if Lune is in PATH
Get-Command lune

# Check file contents
Get-Content src/sum.lua -Raw

# Check file encoding
[System.Text.Encoding]::Default.GetString([System.IO.File]::ReadAllBytes("src/sum.lua"))
```

## 🐛 Troubleshooting Windows Issues

### Problem: "lune is not recognized"
**Solution**:
1. Download Lune from https://lune.sh
2. Extract to a folder (e.g., `C:\lune`)
3. Add to PATH:
   ```powershell
   # Temporary (current session)
   $env:Path += ";C:\lune"
   
   # Permanent (system)
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\lune", "User")
   ```
4. Restart PowerShell

### Problem: "Could not find src/sum.lua"
**Solution**:
```powershell
# Check current directory
$pwd

# List files
Get-ChildItem

# Navigate to correct directory
cd E:\Games\Roblox\RobloxRealisticCat
```

### Problem: File permission errors
**Solution**:
```powershell
# Run PowerShell as Administrator
# Check file permissions
Get-Acl src/sum.lua

# If needed, take ownership (Admin required)
takeown /f src/sum.lua
icacls src/sum.lua /grant Users:F
```

### Problem: Unicode/encoding issues
**Solution**:
```powershell
# Save files as UTF-8 without BOM
# In VS Code: File → Save with Encoding → UTF-8

# Check file encoding
$bytes = [System.IO.File]::ReadAllBytes("src/sum.lua")
$encoding = [System.Text.Encoding]::UTF8.GetString($bytes)
```

## 📊 Expected Output

### Successful Test Run
```
🪟 Windows Lune Test Runner
===========================

📋 Sum Module
  • adds 1 + 2 to equal 3 ... ✅
  • adds 0 + 5 to equal 5 ... ✅
  • adds -1 + 1 to equal 0 ... ✅
  • adds 10 + 20 to equal 30 ... ✅

📋 Math Utilities
  • should load MathUtils module ... ✅

📋 Test Files
  • should have test files ... ✅
  • should load sum.spec.lua ... ✅

📊 Test Results:
---------------
Passed: 7
Failed: 0
Total:  7

✅ All tests passed!
```

### Verification Output
```
🪟 Windows Test Setup Verification
=================================

1. Checking Lune installation...
   ✅ Lune is installed and in PATH

2. Checking current directory...
   Current directory: E:/Games/Roblox/RobloxRealisticCat

3. Checking critical files...
   ✅ src/sum.lua
   ✅ scripts/windows-test-runner.lua
   ✅ scripts/simple-test-runner.lua
   ✅ src/__tests__/sum.spec.lua

🎯 Verification Summary
=====================
✅ All critical checks passed
✅ File system access works
✅ Lua execution works

🚀 Ready to run Windows test runner!
```

## 🎯 Best Practices for Windows

### 1. Use Forward Slashes
```lua
-- GOOD
local path = "src/ReplicatedStorage/SharedSource/Utilities/MathUtils/init.lua"

-- BAD (might fail)
local path = "src\\ReplicatedStorage\\SharedSource\\Utilities\\MathUtils\\init.lua"
```

### 2. Use Lune's fs Module
```lua
local fs = require("fs")

-- Check if file exists
if fs.exists("src/sum.lua") then
    -- Read file
    local content = fs.readFile("src/sum.lua")
end
```

### 3. Handle Errors Gracefully
```lua
local success, errorMsg = pcall(function()
    -- Your code here
end)

if not success then
    print("Error:", errorMsg)
    -- Provide helpful Windows-specific advice
end
```

### 4. Check Current Directory
```lua
local fs = require("fs")
print("Running from:", fs.cwd())
```

## 🔄 Integration with VS Code

### Launch Configuration
```json
// .vscode/launch.json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "lune",
            "request": "launch",
            "name": "Run Windows Tests",
            "program": "${workspaceFolder}/scripts/windows-test-runner.lua",
            "cwd": "${workspaceFolder}"
        }
    ]
}
```

### Tasks Configuration
```json
// .vscode/tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "lune run scripts/windows-test-runner.lua",
            "group": "test",
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            }
        }
    ]
}
```

## 📚 Additional Resources

- [Lune Windows Documentation](https://lune-org.github.io/docs/getting-started/installation#windows)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [Windows File Paths](https://docs.microsoft.com/en-us/dotnet/standard/io/file-path-formats)
- [UTF-8 in Windows](https://docs.microsoft.com/en-us/windows/apps/design/globalizing/use-utf8-code-page)

## 🎉 Success Checklist

- [ ] Lune installed and in PATH
- [ ] Running PowerShell as Administrator (if needed)
- [ ] In correct project directory
- [ ] `windows-verify.lua` runs successfully
- [ ] `windows-test-runner.lua` runs successfully
- [ ] Tests pass with ✅

Now you can develop and test Roblox code completely from the command line on Windows! 🪟🚀