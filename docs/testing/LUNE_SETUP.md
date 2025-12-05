# Lune + Jest-Lua Setup Guide

## 🚀 Quick Start

### 1. Install Lune
Download Lune from [lune.sh](https://lune.sh) and add it to your PATH:

**Windows:**
```powershell
# Download Lune binary
iwr https://github.com/lune-org/lune/releases/latest/download/lune-windows-x86_64.zip -OutFile lune.zip
Expand-Archive lune.zip -DestinationPath .
# Add to PATH or move to a directory in PATH
```

**macOS/Linux:**
```bash
# Download and install
curl -fsSL https://github.com/lune-org/lune/releases/latest/download/lune-macos-x86_64.tar.gz | tar -xz
sudo mv lune /usr/local/bin/
```

Verify installation:
```bash
lune --version
```

### 2. Install Project Dependencies
```bash
# Install Wally packages (if not already installed)
wally install

# Install Rojo (if needed)
npm install -g @rojo-rbx/rojo
```

### 3. Run Tests
```bash
# Run all tests
npm test

# Or directly with Lune
lune run scripts/test-runner.lua

# Run with watch mode (auto-rerun on changes)
npm run test:watch

# Run with verbose output
npm run test:verbose
```

## 📁 Project Structure

```
realistic-cat-game/
├── src/
│   ├── __tests__/
│   │   ├── sum.spec.lua          # Existing test
│   │   └── math-utils.spec.lua   # New test example
│   ├── sum.lua                   # Existing module
│   └── jest.config.lua           # Jest configuration
├── scripts/
│   └── test-runner.lua           # Lune test runner
├── package.json                  # NPM scripts
├── wally.toml                    # Wally dependencies
└── default.project.json          # Rojo configuration
```

## 🧪 Writing Tests

### Basic Test Structure
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

### Available Matchers
- `.toBe(value)` - Strict equality
- `.toEqual(value)` - Deep equality
- `.toThrow(errorMessage)` - Expect function to throw
- `.toBeTruthy()` / `.toBeFalsy()`
- `.toBeGreaterThan(value)` / `.toBeLessThan(value)`
- `.toContain(item)` - For arrays/tables
- `.toHaveLength(length)` - For arrays/strings

## 🔧 Mocking Roblox APIs

Since Lune runs outside Roblox, you need to mock Roblox globals. The test runner includes basic mocks, but you may need to extend them:

### Example Mock Setup
```lua
-- In your test file or a shared mock module
local mockGame = {
    GetService = function(self, serviceName)
        return {
            Name = serviceName,
            -- Add service-specific methods as needed
        }
    end,
    Workspace = {
        Name = "Workspace"
    }
}

-- Use in tests
local originalGame = _G.game
_G.game = mockGame

-- Run tests...

-- Restore original
_G.game = originalGame
```

### Common Mock Patterns
```lua
-- Mock Instance
local mockInstance = {
    Name = "TestInstance",
    Parent = nil,
    Clone = function() return mockInstance end,
    Destroy = function() end,
    FindFirstChild = function(name) return nil end,
    WaitForChild = function(name) return nil end
}

-- Mock DataStoreService
local mockDataStoreService = {
    GetDataStore = function(name)
        return {
            GetAsync = function(key) return nil end,
            SetAsync = function(key, value) end,
            UpdateAsync = function(key, callback) end
        }
    end
}
```

## ⚡ Performance Benefits

**Lune vs Roblox Studio Testing:**
- **Lune**: 1-5 seconds per test run (local)
- **Roblox Studio**: 30-60 seconds (requires Studio launch + sync)
- **CI/CD**: Lune enables fast GitHub Actions workflows

## 🔄 Integration with Development Workflow

### 1. Pre-commit Hook
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

### 2. VS Code Integration
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

### 3. GitHub Actions
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

## 🐛 Debugging Tips

### 1. Verbose Output
```bash
lune run scripts/test-runner.lua --verbose
```

### 2. Debug Specific Test
```lua
-- Add to test file
local debug = true
if debug then
    print("Debug info:", variable)
end
```

### 3. Check Mock Coverage
```lua
-- Add to test runner
print("Mocked globals:")
for key, _ in pairs(_G) do
    if type(_G[key]) == "table" then
        print("  " .. key)
    end
end
```

## 📊 Test Coverage

To add coverage reporting:

1. Install coverage tool:
```bash
wally add jsdotlua/jest-coverage --dev
```

2. Update test runner:
```lua
local config = {
    -- ... existing config ...
    collectCoverage = true,
    coverageDirectory = "coverage"
}
```

3. Run with coverage:
```bash
npm run test:coverage
```

## 🎯 Best Practices

1. **Keep tests fast** - Each test should run in milliseconds
2. **Mock external dependencies** - Don't rely on actual Roblox services
3. **Test behavior, not implementation** - Focus on what code does, not how
4. **Use descriptive test names** - "should calculate damage correctly" not "test1"
5. **Isolate tests** - Each test should be independent
6. **Add edge cases** - Test boundaries, errors, and unusual inputs

## 🔗 Resources

- [Lune Documentation](https://lune-org.github.io/docs)
- [Jest-Lua Documentation](https://jsdotlua.github.io/jest-lua/)
- [Roblox Testing Guide](https://create.roblox.com/docs/scripting/testing)
- [Wally Package Manager](https://wally.run)
- [Rojo Documentation](https://rojo.space/docs)