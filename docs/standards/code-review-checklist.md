# Code Review Checklist - Roblox Cat AI Project

This checklist should be used for every code review to catch common mistakes before they cause runtime errors.

## 🚨 CRITICAL CHECKS (Must Verify Every Time)

### 1. Service/Controller Structure
- [ ] **Service has `Instance = script` property** in `Knit.CreateService/CreateController`
- [ ] **Method order is correct**: regular methods → :KnitStart() → :KnitInit() → return
- [ ] **Service declarations** are at top with `---- Knit Services` comment
- [ ] **Components use `.Init()` and `.Start()`** (dot syntax)
- [ ] **Services use `:KnitInit()` and `:KnitStart()`** (colon syntax)

### 2. Component Access Patterns
- [ ] **Client components NEVER access services directly** - use parent controller methods
- [ ] **Server components use proper component access** through service.Components
- [ ] **NO hardcoded path chains** like `script.Parent.Parent.Parent.Components`
- [ ] **Component references stored during Init** for cross-component access

### 3. Client-Server Communication
- [ ] **Client-side service calls use Promise methods** (`:andThen()` and `:catch()`)
- [ ] **Server-side client methods defined** for all client-accessible functionality
- [ ] **Proper error handling** for all client-server interactions

### 4. Syntax and Structure
- [ ] **All functions properly closed** with `end` statements
- [ ] **No duplicate function definitions** or nested return statements
- [ ] **Proper table structure** - no malformed tables or missing commas
- [ ] **All methods exist** - no calls to undefined methods

## 🔍 SPECIFIC ERROR PREVENTION

### Common Error: "X is not a valid member"
**Check for:**
- [ ] Direct component access instead of service method delegation
- [ ] Client components trying to access server services
- [ ] Missing method definitions in parent controller

### Common Error: "Expected <eof>, got 'end'"
**Check for:**
- [ ] Missing `end` statements in complex functions
- [ ] Improperly nested conditional statements
- [ ] Malformed table structures

### Common Error: "Malformed string" (TestEZ)
**Check for:**
- [ ] Nested function definitions in test files
- [ ] Incorrect test structure (should return single function)

### Common Error: "CreateCat is not a valid member"
**Check for:**
- [ ] Trying to call service methods on folder references
- [ ] Missing component references during Init
- [ ] Incorrect service access patterns

## 📋 QUICK REFERENCE PATTERNS

### ✅ CORRECT: Component Access
```lua
-- Store references during Init
function Component.Init()
    Component.CatManager = script.Parent.Parent.Parent.Components.CatManager
end

-- Use stored references
function Component:SomeMethod()
    local catData = Component.CatManager:CreateCat(catId, profileType)
end
```

### ✅ CORRECT: Client-Server Communication
```lua
-- Client-side
CatService:SomeMethod():andThen(function(result)
    -- handle result
end):catch(function(err)
    warn("Error:", err)
end)

-- Server-side
function Service.Client:SomeMethod(player, ...)
    return Service:SomeMethod(player, ...)
end
```

### ✅ CORRECT: Method Order
```lua
-- Regular methods first
function Service:SomeMethod()
    -- implementation
end

-- :KnitStart() second
function Service:KnitStart()
    -- start logic
end

-- :KnitInit() last
function Service:KnitInit()
    -- initialization
end

return Service
```

## 🎯 PRE-COMMIT VERIFICATION

Before committing any code, run through this checklist:

1. **Structural Integrity**
   - [ ] All services have proper Knit structure
   - [ ] All components follow component patterns
   - [ ] Method order is correct in all files

2. **Access Patterns**
   - [ ] No client components accessing services directly
   - [ ] No hardcoded path chains
   - [ ] All cross-component access uses stored references

3. **Error Prevention**
   - [ ] All called methods exist
   - [ ] No syntax errors in complex functions
   - [ ] Proper Promise handling for client-server calls

4. **Testing Readiness**
   - [ ] Chat commands work without errors
   - [ ] Keyboard controls function properly
   - [ ] No runtime errors in console

## 📝 COMMON MISTAKES TO WATCH FOR

- ❌ **Client components calling `Knit.GetService()`** - Should use parent controller
- ❌ **Missing `Instance = script`** in service/controller creation
- ❌ **Wrong method syntax** (components using `:` instead of `.`)
- ❌ **Direct component path access** instead of framework access
- ❌ **Missing method definitions** in parent controllers
- ❌ **Improper Promise handling** on client-side
- ❌ **Malformed table structures** in complex functions

By following this checklist, we can prevent the most common runtime errors and maintain a stable, working codebase.