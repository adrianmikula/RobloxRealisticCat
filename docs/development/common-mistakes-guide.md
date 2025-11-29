# Common Mistakes Guide - Roblox Cat AI Project

This document outlines the most frequent mistakes we've encountered during development and provides clear guidance on how to avoid them.

## 🚨 CRITICAL: Service Access Patterns

### ❌ WRONG: Direct Component Access
```lua
-- DON'T DO THIS:
local CatManager = CatService.Components.CatManager
local catData = CatManager:CreateCat(catId, profileType)
```

### ✅ CORRECT: Service Method Delegation
```lua
-- DO THIS INSTEAD:
local catData = CatService:CreateCat(catId, profileType)
-- OR if you must access components directly:
local catData = CatService.Components.CatManager:CreateCat(catId, profileType)
```

**Why this matters:** Components are loaded into the service's `Components` table by the framework. Direct access patterns break when components aren't properly initialized.

## 🚨 CRITICAL: Client-Server Communication

### ❌ WRONG: Client Components Accessing Services Directly
```lua
-- DON'T DO THIS (in client components):
local CatService = Knit.GetService("CatService")
local tools = CatService:GetPlayerTools()
```

### ✅ CORRECT: Use Parent Controller Methods
```lua
-- DO THIS INSTEAD (in client components):
local tools = CatController:GetPlayerTools()
```

**Why this matters:** Client components should only access services through their parent controller's wrapper methods to maintain proper architecture.

## 🚨 CRITICAL: Knit Framework Integration

### ❌ WRONG: Missing Instance Property
```lua
-- DON'T DO THIS:
local ServiceName = Knit.CreateService({
    Name = "ServiceName",
    -- Missing Instance = script
})
```

### ✅ CORRECT: Include Instance Property
```lua
-- DO THIS INSTEAD:
local ServiceName = Knit.CreateService({
    Name = "ServiceName",
    Instance = script,  -- REQUIRED for SuperbulletFrameworkV1-Knit
})
```

**Why this matters:** The `Instance = script` property is required for the framework to properly initialize components.

## 🚨 CRITICAL: Component Initialization Methods

### ❌ WRONG: Wrong Method Syntax
```lua
-- DON'T DO THIS (in components):
function ComponentName:KnitInit()  -- Wrong!
function ComponentName:KnitStart() -- Wrong!
```

### ✅ CORRECT: Use Dot Syntax for Components
```lua
-- DO THIS INSTEAD (in components):
function ComponentName.Init()  -- Correct!
function ComponentName.Start() -- Correct!
```

**Why this matters:** Components use `.Init()` and `.Start()` while main services use `:KnitInit()` and `:KnitStart()`.

## 🚨 CRITICAL: Method Order in Files

### ❌ WRONG: Incorrect Method Placement
```lua
-- DON'T DO THIS:
function ServiceName:KnitInit()
    -- initialization
end

function ServiceName:SomeMethod()
    -- regular method
end

function ServiceName:KnitStart()
    -- start logic
end

return ServiceName
```

### ✅ CORRECT: Proper Method Order
```lua
-- DO THIS INSTEAD:
function ServiceName:SomeMethod()
    -- regular method
end

function ServiceName:KnitStart()
    -- start logic
end

function ServiceName:KnitInit()
    -- initialization
end

return ServiceName
```

**Why this matters:** The framework expects `:KnitStart()` before `:KnitInit()` and both at the end of the file.

## 🚨 CRITICAL: Service Declaration Pattern

### ❌ WRONG: Missing Service Declarations
```lua
-- DON'T DO THIS:
-- No service declarations at top

function ServiceName:KnitInit()
    ProfileService = Knit.GetService("ProfileService") -- Error!
end
```

### ✅ CORRECT: Declare Services at Top
```lua
-- DO THIS INSTEAD:
---- Knit Services
local ProfileService

function ServiceName:KnitStart()
    -- start logic
end

function ServiceName:KnitInit()
    ProfileService = Knit.GetService("ProfileService")
end

return ServiceName
```

## 🚨 CRITICAL: Component Access in Test Scripts

### ❌ WRONG: Direct Component Path Access
```lua
-- DON'T DO THIS:
local CatManager = require(script.Parent.Parent.Components.Others.CatManager)
-- OR:
local catData = CatService:CreateCat(catId, profileType) -- When CatService is a folder reference
```

### ✅ CORRECT: Use Service Component Access
```lua
-- DO THIS INSTEAD:
-- Option 1: Access through service's Components table
local catData = CatService.Components.CatManager:CreateCat(catId, profileType)

-- Option 2: Store component references during Init
function Component.Init()
    Component.CatManager = script.Parent.Parent.Parent.Components.CatManager
    Component.ActiveCats = script.Parent.Parent.Parent.ActiveCats
end
```

## 🚨 CRITICAL: Client-Side Promise Handling

### ❌ WRONG: Direct Method Calls
```lua
-- DON'T DO THIS (client-side):
local result = CatService:SomeMethod()
```

### ✅ CORRECT: Use Promise Methods
```lua
-- DO THIS INSTEAD (client-side):
CatService:SomeMethod():andThen(function(result)
    -- handle result
end):catch(function(err)
    warn("Error:", err)
end)
```

## 🚨 CRITICAL: File Path References

### ❌ WRONG: Hardcoded Path Chains
```lua
-- DON'T DO THIS:
local component = require(script.Parent.Parent.Parent.Parent.Components.Others.ComponentName)
```

### ✅ CORRECT: Use Framework Access
```lua
-- DO THIS INSTEAD:
local component = ServiceName.Components.ComponentName
```

## 🚨 CRITICAL: Testing Framework Issues

### ❌ WRONG: Duplicate Function Definitions
```lua
-- DON'T DO THIS (in TestEZ tests):
return function()
    return function()
        -- test code
    end
end
```

### ✅ CORRECT: Single Function Definition
```lua
-- DO THIS INSTEAD:
return function()
    -- test code
end
```

## 🚨 CRITICAL: Component Structure

### ❌ WRONG: Logic in Main Service File
```lua
-- DON'T DO THIS (in init.lua):
function ServiceName:ComplexLogic()
    -- lots of business logic here
end
```

### ✅ CORRECT: Delegate to Components
```lua
-- DO THIS INSTEAD:
function ServiceName:ComplexLogic()
    return ServiceName.Components.LogicModule:ComplexLogic()
end
```

## Quick Reference Checklist

Before committing any code, verify:

- [ ] Services have `Instance = script` property
- [ ] Components use `.Init()` and `.Start()` (dot syntax)
- [ ] Services use `:KnitInit()` and `:KnitStart()` (colon syntax)
- [ ] Method order: regular methods → :KnitStart() → :KnitInit() → return
- [ ] Client components access services through parent controller
- [ ] Service declarations are at top with `---- Knit Services` comment
- [ ] No hardcoded path chains for component access
- [ ] Client-side service calls use Promise methods
- [ ] Test files have proper function structure
- [ ] Business logic is in components, not main service files

## Common Error Messages and Solutions

### "X is not a valid member of Folder"
**Cause:** Direct component access instead of service method delegation
**Fix:** Use service methods or proper component access through service.Components

### "CreateCat is not a valid member of ModuleScript"
**Cause:** Trying to call service methods on a folder reference instead of the actual service instance
**Fix:** Use component access through the service's Components table or store component references during Init

### "Expected <eof>, got 'end'"
**Cause:** Missing or extra `end` statements, often from method order issues
**Fix:** Check method structure and ensure proper nesting

### "CatService is not a valid member"
**Cause:** Client components trying to access services directly
**Fix:** Use parent controller wrapper methods instead

### "Malformed string" in TestEZ
**Cause:** Incorrect test function structure
**Fix:** Ensure tests return a single function, not nested functions

## Prevention Strategy

1. **Always read the template files** before creating new systems
2. **Follow established patterns** from working components
3. **Test incrementally** to catch issues early
4. **Use this guide** as a reference during development
5. **Review existing working code** when unsure about patterns

By following these guidelines, we can significantly reduce development time spent on debugging common architectural issues.