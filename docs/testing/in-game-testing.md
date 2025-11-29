# In-Game Testing Guide

This guide covers the comprehensive in-game testing system for the realistic cat AI game.

## Overview

The in-game testing system provides live testing capabilities during gameplay, allowing developers to verify functionality, test edge cases, and debug issues in real-time.

## Test Runners

### Server-Side Test Runner (`CatTestRunner`)

**Location:** `src/ServerScriptService/ServerSource/Server/CatService/Components/Others/CatTestRunner.lua`

**Features:**
- Automated test suite execution
- Real-time test result reporting
- Chat command integration
- Test result persistence

**Available Commands:**
```lua
/runtests     -- Run all automated tests
/teststatus   -- Show current test results
```

**Test Suites:**

#### 1. Cat Creation Tests
- **Create Cat with Valid Profile:** Verifies cat creation with proper profile data
- **Create Cat with Different Profiles:** Tests all personality types (Friendly, Curious, Playful, Independent)

#### 2. Cat State Management Tests
- **Get Cat State:** Tests state retrieval functionality
- **Get All Cats:** Verifies cat enumeration and counting

#### 3. Cat Removal Tests
- **Remove Existing Cat:** Tests cat removal and cleanup
- **Remove Non-Existent Cat:** Verifies graceful handling of invalid removals

#### 4. Component Integration Tests
- **CatManager Component:** Tests core cat management functionality
- **CatAI Component:** Verifies AI system initialization and updates

### Client-Side Test Runner (`ClientTestRunner`)

**Location:** `src/ReplicatedStorage/ClientSource/Client/CatController/Components/Others/ClientTestRunner.lua`

**Features:**
- Client component validation
- Method availability checking
- Input system verification
- Visual system testing

**Available Commands:**
```lua
/clienttests   -- Run all client-side tests
/clientstatus  -- Show client test results
```

**Test Suites:**

#### 1. Component Access Tests
- **All Components Loaded:** Verifies all required components exist
- **Get and Set Components:** Tests component access patterns

#### 2. Method Availability Tests
- **Controller Methods Available:** Verifies all controller methods exist
- **Component Methods Available:** Tests individual component methods

#### 3. Input System Tests
- **Input Handler Setup:** Validates input system initialization
- **Tool Manager Setup:** Tests tool management system

#### 4. Visual System Tests
- **Cat Renderer Setup:** Verifies visual rendering system
- **Animation Handler Setup:** Tests animation management

## Manual Testing Commands

### Chat Commands (`TestCommands`)

**Location:** `src/ServerScriptService/ServerSource/Server/CatService/Components/Others/TestCommands.lua`

**Available Commands:**

```lua
/spawncat [profile] [count]
  -- Spawn test cats with specified profile
  -- profile: Friendly, Curious, Playful, Independent (default: Friendly)
  -- count: Number of cats to spawn (default: 1)
  -- Example: /spawncat Curious 3

/listcats
  -- Display all active cats and their current states
  -- Shows: Cat ID, Mood, Position

/clearcats
  -- Remove all cats from the game
  -- Useful for cleanup between tests

/testai
  -- Test AI system with a dedicated test cat
  -- Creates a cat and monitors AI behavior
```

### Keyboard Controls

**Location:** `src/ReplicatedStorage/ClientSource/Client/CatController/Components/Others/InputHandler.lua`

**Available Controls:**

```lua
1-9 Keys: Select different tools
  -- 1: Basic Food
  -- 2: Basic Toys
  -- 3-9: Additional tools (if implemented)

E Key: Equip/Unequip Current Tool
  -- Toggles tool equipped state
  -- Shows/hides tool visual

F Key: Interact with Nearby Cats
  -- Uses currently equipped tool
  -- Range: 10 studs

R Key: Spawn Test Cat
  -- Spawns cat at cursor position
  -- Uses default profile
```

## Test Environment Setup

### Automatic Setup

The test environment is automatically configured when the game starts:

1. **Component Initialization:** All test components initialize automatically
2. **Chat Command Registration:** Commands are registered for all players
3. **Test Suite Definition:** Test suites are defined and ready to run

### Manual Setup (if needed)

If automatic setup fails, you can manually trigger initialization:

```lua
-- Server-side initialization
local CatService = Knit.GetService("CatService")
CatService.Components.CatTestRunner:RunAllTests()

-- Client-side initialization  
local CatController = Knit.GetController("CatController")
CatController.Components.ClientTestRunner:RunAllTests()
```

## Test Results and Reporting

### Console Output

Tests provide detailed console output:

```
🧪 Running test: Create Cat with Valid Profile
✅ Test passed: Create Cat with Valid Profile
   Cat creation test passed

📊 Suite Results: Cat Creation Tests
✅ Passed: 2
❌ Failed: 0

🎯 TEST SUMMARY
===============
✅ Total Passed: 8
❌ Total Failed: 0
📊 Success Rate: 100.0%
🎉 All tests passed! The cat system is working correctly.
```

### Test Result Structure

Each test result includes:
- **Test Name:** Descriptive test identifier
- **Status:** ✅ Passed or ❌ Failed
- **Message:** Detailed result information
- **Timestamp:** When the test was run

### Persistent Results

Test results are stored and can be queried:

```lua
-- Check current test status
CatTestRunner.TestResults["Test Name"]
-- Returns: { success = true, message = "Test passed" }
```

## Testing Best Practices

### Running Tests

1. **Start Small:** Run individual test suites first
2. **Monitor Performance:** Watch for frame rate drops
3. **Check Console:** Review detailed output for issues
4. **Clean Up:** Use `/clearcats` between test sessions

### Writing Custom Tests

You can extend the test system by adding new tests:

```lua
-- Add to existing test suite
local newTest = {
    name = "Your Custom Test",
    func = function()
        -- Test implementation
        CatTestRunner:Assert(condition, "Test failed message")
        return "✅ Custom test passed"
    end
}

table.insert(CatTestRunner.TestSuite[1].tests, newTest)
```

### Debugging Tips

1. **Use Chat Commands:** Quick manual testing
2. **Check Component State:** Verify components are loaded
3. **Monitor Network:** Watch for client-server communication
4. **Performance Profiling:** Use Roblox Studio profiler

## Troubleshooting

### Common Issues

**Tests Not Running:**
- Check if components are initialized
- Verify chat commands are registered
- Check console for error messages

**"CatService is not a valid member" Error:**
- Ensure client components use controller wrapper methods
- Check component initialization order

**Performance Issues:**
- Use `/clearcats` to remove test cats
- Monitor with fewer cats initially
- Check performance mode settings

**Chat Commands Not Working:**
- Wait for game initialization
- Check player chat permissions
- Verify command syntax

### Debug Commands

Additional debugging commands (if implemented):

```lua
/debug cats      -- Show detailed cat information
/debug components -- Show component status
/debug performance -- Show performance metrics
```

## Integration with Development Workflow

### Continuous Testing

1. **On Game Start:** Basic system validation
2. **During Development:** Manual testing via commands
3. **Before Commits:** Run full test suite
4. **Performance Testing:** Load testing with multiple cats

### Test-Driven Development

The test system supports TDD:

1. Write test for new feature
2. Run test (should fail)
3. Implement feature
4. Run test (should pass)
5. Refactor and verify

This comprehensive in-game testing system ensures the cat AI game remains stable and functional throughout development.