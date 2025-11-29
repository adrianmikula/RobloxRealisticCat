# Cat Game Testing Documentation

This document provides comprehensive information about the testing infrastructure for the Roblox realistic cat AI game.

## Overview

The project has a multi-layered testing approach:

1. **In-Game Test Runners** - Live testing during gameplay
2. **TestEZ Unit Tests** - Automated testing framework
3. **Manual Testing** - Chat commands and keyboard controls
4. **Performance Testing** - System optimization verification

## Quick Start Guide

### Running In-Game Tests

**Server-Side Tests:**
- Type `/runtests` in chat to run comprehensive server tests
- Type `/teststatus` to see current test results

**Client-Side Tests:**
- Type `/clienttests` in chat to run client tests
- Type `/clientstatus` to see client test results

### Manual Testing Commands

```lua
/spawncat [profile] [count]  -- Spawn test cats
/listcats                    -- List all current cats
/clearcats                   -- Remove all cats
/testai                     -- Test AI system
```

### Keyboard Controls for Testing

- **1-9**: Select different tools
- **E**: Equip/unequip current tool
- **F**: Interact with nearby cats
- **R**: Spawn test cat at cursor position

## Test Architecture

### Server-Side Testing (`CatTestRunner`)

Location: `src/ServerScriptService/ServerSource/Server/CatService/Components/Others/CatTestRunner.lua`

**Test Suites:**
- Cat Creation Tests
- Cat State Management Tests
- Cat Removal Tests
- Component Integration Tests

**Key Features:**
- Comprehensive assertion library
- Test result tracking
- Automatic cleanup between tests
- Chat command integration

### Client-Side Testing (`ClientTestRunner`)

Location: `src/ReplicatedStorage/ClientSource/Client/CatController/Components/Others/ClientTestRunner.lua`

**Test Suites:**
- Component Access Tests
- Method Availability Tests
- Input System Tests
- Visual System Tests

**Key Features:**
- Component validation
- Method existence checking
- Input handler verification
- Visual system testing

### TestEZ Unit Tests

**Server Tests:** `src/ServerScriptService/ServerSource/Tests/CatServiceTests.spec.lua`
- Cat creation and removal
- State management
- Player interactions
- Performance and scaling
- Error handling

**Client Tests:** `src/ReplicatedStorage/SharedSource/Tests/CatControllerTests.spec.lua`
- Cat visual management
- Player interaction
- Animation management
- Action handling
- Performance optimization

**Data Tests:** `src/ReplicatedStorage/SharedSource/Tests/CatDataTests.spec.lua`
- Personality types
- Mood states
- Breed types
- Performance configuration

## Test Runner Configuration

### Main Test Runner

Location: `src/ServerScriptService/ServerSource/Server/TestRunner.server.lua`

**Features:**
- Automatic test execution in Studio mode
- Test suite selection
- Performance testing
- CI/CD integration via TestService

**Configuration:**
```lua
local TEST_CONFIG = {
    VERBOSE = true,        -- Print detailed test results
    SHOW_ERRORS = true,    -- Show error details
    STOP_ON_FAILURE = false -- Continue running tests even if some fail
}
```

## Test Commands Component

Location: `src/ServerScriptService/ServerSource/Server/CatService/Components/Others/TestCommands.lua`

**Available Commands:**
- `/spawncat [profile] [count]` - Spawn test cats with specified profile
- `/listcats` - Display all active cats and their states
- `/clearcats` - Remove all cats from the game
- `/testai` - Test AI system with a dedicated test cat

## Testing Best Practices

### Writing New Tests

1. **Use the Template:** Copy from existing test files
2. **Follow Naming:** Use descriptive test names
3. **Isolate Tests:** Each test should be independent
4. **Clean Up:** Always clean up test data
5. **Assert Properly:** Use appropriate assertion methods

### Test Structure

```lua
it("should do something specific", function()
    -- Setup
    local testData = createTestData()
    
    -- Execute
    local result = systemUnderTest:doSomething(testData)
    
    -- Verify
    expect(result).to.be.ok()
    expect(result.property).to.equal(expectedValue)
    
    -- Cleanup
    cleanupTestData(testData)
end)
```

### Performance Testing

- Test with multiple cats (5, 10, 20+)
- Monitor frame rates and memory usage
- Test under different performance modes (High, Balanced, Low)

## Current Test Status

### ✅ Working Tests
- Cat creation and removal
- Component access and validation
- Method availability checks
- Basic AI functionality
- Chat command integration

### ⚠️ Known Issues
- TestEZ framework shows "Malformed string" error
- Some animation IDs are placeholders
- Performance tests need optimization

### 🔧 Areas Needing Improvement
- More comprehensive integration tests
- Better error handling tests
- Performance benchmarking
- Network latency testing

## Troubleshooting

### Common Issues

**"Malformed string" error in TestEZ:**
- This is a known issue with the TestEZ framework
- In-game test runners work independently
- Manual testing via chat commands is recommended

**Tests not running:**
- Ensure you're in Studio mode
- Check console for initialization messages
- Verify all components are loaded

**Chat commands not working:**
- Wait for game initialization (2-3 seconds)
- Check console for component startup messages
- Ensure you're using the correct command syntax

## Future Testing Plans

1. **Integration Tests:** Test client-server communication
2. **Performance Tests:** Benchmark system under load
3. **UI Tests:** Automated GUI testing
4. **Network Tests:** Latency and synchronization testing
5. **Regression Tests:** Ensure existing functionality isn't broken

For questions or issues, check the console output or refer to the component-specific documentation.