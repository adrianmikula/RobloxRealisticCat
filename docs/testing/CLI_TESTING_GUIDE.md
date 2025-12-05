# CLI Testing Guide for Roblox Development

## 🎯 Overview

This guide covers how to set up and run automated tests for Roblox development using command-line tools **without requiring Roblox Studio**. This enables fast development cycles and CI/CD integration.

## 📋 Current Testing Setup Status

### ✅ Already Configured
1. **Jest-Lua** - Installed via Wally (`dev-dependencies` in `wally.toml`)
2. **Test runners** - Multiple test runners available:
   - `scripts/test-runner.lua` - Full Jest-Lua runner with Roblox mocking
   - `scripts/simple-test-runner.lua` - Minimal test runner (no Jest dependency)
   - `scripts/test-lune-basic.lua` - Basic Lune verification test
3. **Test files** - Located in `src/__tests__/`:
   - `sum.spec.lua` - Basic Jest-Lua test
   - `math-utils.spec.lua` - Comprehensive math tests
4. **Package scripts** - `package.json` has npm scripts for testing
5. **Project structure** - Rojo configured with proper paths

### 🔧 What Needs Installation

1. **Lune** - Standalone Luau runtime (required for CLI testing)
2. **Node.js/npm** - For running npm scripts (optional but recommended)

## 🚀 Quick Start

### Option 1: Install Lune (Recommended)

**Windows (PowerShell):**
```powershell
# Download and install Lune
iwr https://github.com/lune-org/lune/releases/latest/download/lune-windows-x86_64.zip -OutFile lune.zip
Expand-Archive lune.zip -DestinationPath .
# Add to PATH or move lune.exe to a directory in your PATH
```

**macOS/Linux:**
```bash
# Download and install
curl -fsSL https://github.com/lune-org/lune/releases/latest/download/lune-macos-x86_64.tar.gz | tar -xz
sudo mv lune /usr/local/bin/

# Verify installation
lune --version
```

### Option 2: Verify Current Setup
```bash
# Run basic Lune test (verifies setup works)
lune run scripts/test-lune-basic.lua

# Run simple test runner (no Jest dependency)
lune run scripts/simple-test-runner.lua

# Run full Jest-Lua test runner
lune run scripts/test-runner.lua
```

### Option 3: Use npm scripts
```bash
# Install dependencies (if needed)
npm install

# Run tests
npm test

# Run tests with watch mode
npm run test:watch

# Run tests with verbose output
npm run test:verbose

# Run tests with coverage
npm run test:coverage
```

## 🧪 Writing Tests

### Jest-Lua Tests (Recommended)
Create files in `src/__tests__/` with `.spec.lua` extension:

```lua
local JestGlobals = require("@DevPackages/JestGlobals")
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local MyModule = require("@Project/MyModule")

describe("MyModule", function()
    it("should do something", function()
        expect(MyModule.doSomething()).toBe(expectedValue)
    end)
    
    it("should handle errors", function()
        expect(function()
            MyModule.throwError()
        end).toThrow("Error message")
    end)
end)
```

### Simple Tests (No Jest Dependency)
```lua
-- Use the simple test runner framework
local TestFramework = require("scripts/simple-test-runner").TestFramework

TestFramework.describe("MyModule", function()
    TestFramework.it("should work", function()
        TestFramework.expect(MyModule.doSomething()).toBe(expectedValue)
    end)
end)
```

## 🔧 Mocking Roblox APIs

Since tests run outside Roblox, you need to mock Roblox globals. The test runners include basic mocks:

### Basic Mock Setup
```lua
-- In your test file or a shared mock module
_G.game = {
    GetService = function(self, serviceName)
        return {
            Name = serviceName,
            -- Add service-specific methods as needed
        }
    end,
    Workspace = { Name = "Workspace" }
}

_G.workspace = { Name = "Workspace" }
_G.script = { Parent = { Parent = { Parent = { Name = "DataModel" } } } }
```

### Common Mock Patterns
```lua
-- Mock DataStoreService
local mockDataStoreService = {
    GetDataStore = function(name)
        return {
            GetAsync = function(key) return nil end,
            SetAsync = function(key, value) end,
            UpdateAsync = function(key, callback) return callback(nil) end
        }
    end
}

-- Mock Instance methods
local mockInstance = {
    Name = "TestInstance",
    Parent = nil,
    Clone = function() return mockInstance end,
    Destroy = function() end,
    FindFirstChild = function(name) return nil end,
    WaitForChild = function(name, timeout) 
        task.wait(timeout or 5)
        return nil 
    end
}
```

## ⚡ Performance Comparison

| Method | Setup Time | Test Run Time | Requires Studio | CI/CD Friendly |
|--------|------------|---------------|-----------------|----------------|
| **Lune + Jest-Lua** | 5-10 min | 1-5 seconds | ❌ No | ✅ Yes |
| **Roblox Studio** | 0 min | 30-60 seconds | ✅ Yes | ❌ No |
| **TestEZ + Open Cloud** | 15-30 min | 10-30 seconds | ❌ No | ✅ Yes |
| **Simple Lune Runner** | 2-5 min | <1 second | ❌ No | ✅ Yes |

## 🔄 Development Workflow

### 1. Fast Iteration with Lune
```bash
# Write test
code src/__tests__/my-feature.spec.lua

# Run test immediately
lune run scripts/test-runner.lua

# Or with npm
npm test
```

### 2. Pre-commit Hook
Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
echo "Running tests before commit..."
lune run scripts/test-runner.lua
if [ $? -ne 0 ]; then
    echo "❌ Tests failed - commit aborted"
    exit 1
fi
echo "✅ Tests passed - committing..."
```

### 3. VS Code Integration
Create `.vscode/launch.json`:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "type": "lune",
            "request": "launch",
            "name": "Run Tests",
            "program": "${workspaceFolder}/scripts/test-runner.lua"
        }
    ]
}
```

## 🏗️ Testing Real Game Code

### Example: Testing a Cat Service Component
```lua
-- src/__tests__/cat-manager.spec.lua
local JestGlobals = require("@DevPackages/JestGlobals")
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

-- Mock Roblox services
_G.game = {
    GetService = function(self, serviceName)
        if serviceName == "Workspace" then
            return {
                Name = "Workspace",
                cats = {}
            }
        end
        return { Name = serviceName }
    end
}

-- Mock the CatManager module
local CatManager = {
    spawnCat = function(name, position)
        return {
            name = name,
            position = position,
            health = 100,
            isAlive = true
        }
    end,
    
    getCatCount = function()
        return #(_G.game:GetService("Workspace").cats or {})
    end
}

describe("CatManager", function()
    it("should spawn a cat with correct properties", function()
        local cat = CatManager.spawnCat("Whiskers", {x=0, y=0, z=0})
        
        expect(cat.name).toBe("Whiskers")
        expect(cat.health).toBe(100)
        expect(cat.isAlive).toBe(true)
    end)
    
    it("should track cat count", function()
        -- Mock workspace cats
        _G.game:GetService("Workspace").cats = {
            {name = "Cat1"},
            {name = "Cat2"}
        }
        
        expect(CatManager.getCatCount()).toBe(2)
    end)
end)
```

## 🐛 Troubleshooting

### Common Issues

1. **"Module not found" errors**
   ```bash
   # Make sure Wally packages are installed
   wally install
   
   # Check DevPackages directory exists
   ls DevPackages/
   ```

2. **Lune not found**
   ```bash
   # Verify Lune is installed
   lune --version
   
   # If not found, add to PATH or use full path
   ./lune run scripts/test-runner.lua
   ```

3. **Roblox API errors in tests**
   - Ensure all Roblox globals are mocked
   - Check test runner mocks Roblox services
   - Use `pcall` for error handling

4. **Jest-Lua configuration issues**
   ```lua
   -- Check jest.config.lua
   return {
       testMatch = { "**/*.spec" },
       moduleNameMapper = {
           ["^@DevPackages/(.+)$"] = "DevPackages/_Index/jsdotlua_$1@3.10.0/$1",
           ["^@Project/(.+)$"] = "src/$1"
       }
   }
   ```

## 📊 Test Coverage

To add coverage reporting:

1. Install coverage tool:
```bash
wally add jsdotlua/jest-coverage --dev
```

2. Update test runner configuration:
```lua
local config = {
    collectCoverage = true,
    coverageDirectory = "coverage",
    coverageReporters = { "text", "html" }
}
```

3. Run with coverage:
```bash
npm run test:coverage
```

## 🚀 CI/CD Integration

### GitHub Actions Example
Create `.github/workflows/test.yml`:
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: lune-org/setup-lune@v1
      - run: wally install
      - run: lune run scripts/test-runner.lua
```

## 🎯 Best Practices

1. **Keep tests fast** - Each test should run in milliseconds
2. **Mock external dependencies** - Don't rely on actual Roblox services
3. **Test behavior, not implementation** - Focus on what code does, not how
4. **Use descriptive test names** - "should calculate damage correctly" not "test1"
5. **Isolate tests** - Each test should be independent
6. **Add edge cases** - Test boundaries, errors, and unusual inputs
7. **Run tests frequently** - After every code change

## 🔗 Resources

- [Lune Documentation](https://lune-org.github.io/docs)
- [Jest-Lua Documentation](https://jsdotlua.github.io/jest-lua/)
- [Wally Package Manager](https://wally.run)
- [Rojo Documentation](https://rojo.space/docs)
- [Roblox Testing Guide](https://create.roblox.com/docs/scripting/testing)

## 📝 Next Steps

1. **Install Lune** if not already installed
2. **Run the basic test** to verify setup: `lune run scripts/test-lune-basic.lua`
3. **Write tests for core game modules** starting with simple utilities
4. **Set up pre-commit hooks** to run tests automatically
5. **Integrate with CI/CD** for automated testing on every push

With this setup, you can develop and test Roblox code **10-20x faster** than using Roblox Studio alone!