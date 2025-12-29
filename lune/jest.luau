local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local process = require("@lune/process")
local luau = require("@lune/luau")

-- =============================================================================
-- 1. Helpers & Mocks
-- =============================================================================

-- Helper to create a proper environment for loaded chunks
local function createEnv()
    local env = {
        -- Standard Lua/Luau globals
        assert = assert,
        error = error,
        getfenv = getfenv,
        getmetatable = getmetatable,
        ipairs = ipairs,
        loadstring = loadstring,
        next = next,
        pairs = pairs,
        pcall = pcall,
        print = print,
        rawequal = rawequal,
        rawget = rawget,
        rawset = rawset,
        select = select,
        setfenv = setfenv,
        setmetatable = setmetatable,
        tonumber = tonumber,
        tostring = tostring,
        type = type,
        unpack = unpack,
        xpcall = xpcall,
        -- Standard libraries
        bit32 = bit32,
        coroutine = coroutine,
        debug = debug,
        math = math,
        os = os,
        string = string,
        table = table,
        utf8 = utf8,
        task = task,
        -- Framework globals
        _G = _G, -- Crucial for RuntimeLib
    }
    return setmetatable(env, { __index = _G })
end

local roblox = require("@lune/roblox")
_G.CFrame = roblox.CFrame
_G.Vector3 = roblox.Vector3
_G.Vector2 = roblox.Vector2
_G.Color3 = roblox.Color3
_G.UDim2 = roblox.UDim2
_G.UDim = roblox.UDim
_G.Rect = roblox.Rect
_G.Region3 = roblox.Region3

_G.task = {
    delay = function(duration, cb) 
        -- For unit tests, we don't always want to wait, 
        -- but we also don't want to execute immediately if it affects the test state.
        -- We'll just ignore it for now unless we need it.
    end,
    wait = function(duration) return duration or 0 end,
    spawn = function(cb, ...) return cb(...) end,
    defer = function(cb, ...) return cb(...) end,
}

local function createInstance(className, name)
    if type(className) ~= "string" then error("createInstance className must be string, got " .. type(className)) end
    if name and type(name) ~= "string" then error("createInstance name must be string, got " .. type(name)) end
    
    local instance = {
        ClassName = className,
        Name = name or className,
        Parent = nil,
        _children = {},
        _events = {},
        _sourcePath = nil,
    }

    instance.IsA = function(self, checkClass) return self.ClassName == checkClass end
    
    instance.FindFirstChild = function(self, childName)
        return self._children[childName]
    end
    
    instance.WaitForChild = function(self, childName, timeout)
        local child = self._children[childName]
        if child then return child end
        error("WaitForChild(" .. tostring(childName) .. ") failed on " .. tostring(self.Name) .. " (Item not found)")
    end
    
    instance.GetChildren = function(self)
        local children = {}
        for _, child in pairs(self._children) do table.insert(children, child) end
        return children
    end
    
    instance.GetDescendants = function(self)
        local descendants = {}
        local function recurse(inst)
            for _, child in pairs(inst._children) do
                table.insert(descendants, child)
                recurse(child)
            end
        end
        recurse(self)
        return descendants
    end
    
    instance.Destroy = function(self)
        if self.Parent and self.Parent._children then
            self.Parent._children[self.Name] = nil
        end
        self.Parent = nil
    end

    -- Special methods for certain classes
    if className == "RemoteEvent" then
        local mockSignal = {
            Connect = function(_, cb) return { Disconnect = function() end } end,
            Wait = function() end
        }
        instance.FireAllClients = function() end
        instance.FireClient = function() end
        instance.FireServer = function() end
        instance.OnServerEvent = mockSignal
        instance.OnClientEvent = mockSignal
    elseif className == "RemoteFunction" then
        instance.InvokeServer = function() return nil end
        instance.InvokeClient = function() return nil end
        instance.OnServerInvoke = function() end
    elseif className == "BindableEvent" then
        local mockSignal = {
            Connect = function(_, cb) return { Disconnect = function() end } end,
            Wait = function() end
        }
        instance.Fire = function() end
        instance.Event = mockSignal
    elseif className == "Humanoid" then
        instance.GetAppliedDescription = function(self)
            return createInstance("HumanoidDescription")
        end
        instance.ApplyDescription = function(self, desc) end
    elseif className == "HumanoidDescription" then
        instance.HeightScale = 1
        instance.WidthScale = 1
        instance.DepthScale = 1
        instance.HeadScale = 1
    end

    local mt = {
        __index = function(t, k)
            if t._children[k] then return t._children[k] end
            if t._events[k] then return t._events[k] end
             if k == "Changed" or k:match("Changed") then
                return {
                    Connect = function(_, cb) return { Disconnect = function() end } end,
                    Fire = function() end
                }
            end
            return rawget(instance, k)
        end,
        __newindex = function(t, k, v)
            if k == "Parent" then
                -- Use rawget to get the Name string, avoiding metatable lookup
                local name = rawget(instance, "Name")
                if v == nil and t.Parent then
                    t.Parent._children[name] = nil
                elseif v then
                    if v._children[name] then
                        -- print(string.format("DEBUG: Replacing child %q on %s", name, v.Name))
                    end
                    v._children[name] = t
                end
                rawset(t, k, v)
            else
                rawset(t, k, v)
            end
        end,
        __tostring = function(t)
            return rawget(instance, "Name") or "Instance"
        end
    }
    setmetatable(instance, mt)
    return instance
end

-- =============================================================================
-- 2. Mock Roblox Environment
-- =============================================================================

local game = createInstance("DataModel", "Game")
local replicatedStorage = createInstance("ReplicatedStorage")
game.ReplicatedStorage = replicatedStorage

local tsShared = createInstance("Folder", "TS")
tsShared.Parent = replicatedStorage

game.StarterPlayer = createInstance("StarterPlayer")
game.StarterPlayerScripts = createInstance("StarterPlayerScripts")
game.StarterPlayer.StarterPlayerScripts = game.StarterPlayerScripts
local tsClient = createInstance("Folder", "TS")
tsClient.Parent = game.StarterPlayerScripts

local sss = createInstance("ServerScriptService")
game.ServerScriptService = sss
local tsServer = createInstance("Folder", "TS")
tsServer.Parent = sss

game.GetService = function(self, serviceName)
    if serviceName == "ReplicatedStorage" then return replicatedStorage end
    if serviceName == "ServerScriptService" then return sss end
    
    if serviceName == "RunService" then
        if not self._children["RunService"] then
             local rs = createInstance("RunService")
             local mockSignal = {
                 Connect = function(_, cb) return { Disconnect = function() end } end,
                 Wait = function() end
             }
             rs.Heartbeat = mockSignal
             rs.Stepped = mockSignal
             rs.RenderStepped = mockSignal
             rs.IsStudio = function() return false end
             rs.IsRunning = function() return false end
             rs.IsClient = function() return false end
             rs.IsServer = function() return true end
             rs.Parent = self
             self._children["RunService"] = rs
        end
        return self._children["RunService"]
    end
     if serviceName == "HttpService" then
        if not self._children["HttpService"] then
             local hs = createInstance("HttpService")
             hs.JSONEncode = function(_, v) return stdio.format(v) end
             hs.JSONDecode = function(_, v) return stdio.format(v) end 
             hs.GenerateGUID = function() return "GUID" end
             hs.Parent = self
             self._children["HttpService"] = hs
        end
        return self._children["HttpService"]
    end

    if not self._children[serviceName] then
        local service = createInstance(serviceName)
        service.Parent = self
        self._children[serviceName] = service
    end
    return self._children[serviceName]
end

_G.game = game
_G.script = createInstance("Script", "TestRunner")
_G.Instance = {
    new = function(className, parent)
        local inst = createInstance(className)
        if parent then inst.Parent = parent end
        return inst
    end
}

-- =============================================================================
-- 3. Require Hook & FS Mirroring
-- =============================================================================

local loadedModules = {}
local originalRequire = require
local runtimeLib -- Forward declare

_G.require = function(module)
    if type(module) == "table" then
        if module._sourcePath then
            if loadedModules[module._sourcePath] then
                return loadedModules[module._sourcePath]
            end
            
            print("Requiring: " .. module.Name .. " from " .. module._sourcePath)

            local content = fs.readFile(module._sourcePath)
            local bytecode = luau.compile(content)
            local chunk = luau.load(bytecode, { debugName = module.Name })
            setfenv(chunk, createEnv())
            
             -- Inject TS runtime for loaded modules
            if runtimeLib then
                _G[module] = runtimeLib
            else
                 -- If runtimeLib is nil, we might be loading RuntimeLib itself or Promise
                 -- print("Warning: runtimeLib not available for " .. module.Name)
            end

            local oldScript = _G.script
            _G.script = module
            local result = chunk()
            _G.script = oldScript
            
            loadedModules[module._sourcePath] = result
            return result
        end
        return module
    end
    return originalRequire(module)
end

local require = _G.require

function populateMocks(dir, parentInst)
    if not fs.isDir(dir) then return end
    for _, childName in fs.readDir(dir) do
        local fullPath = dir .. "/" .. childName
        local nameWithoutExt = childName:gsub("%.luau$", ""):gsub("%.lua$", "")
        local isInit = nameWithoutExt == "init"
        
        if fs.isDir(fullPath) then
            local initPath = fullPath .. "/init.lua"
             if not fs.isFile(initPath) then initPath = fullPath .. "/init.luau" end -- Check .luau too

            if fs.isFile(initPath) then
                 local mod = createInstance("ModuleScript", childName)
                 mod.Parent = parentInst
                 mod._sourcePath = initPath
                 populateMocks(fullPath, mod) 
            else
                local folder = createInstance("Folder", childName)
                folder.Parent = parentInst
                populateMocks(fullPath, folder)
            end
        elseif string.match(childName, "%.lua") then
             if not isInit then 
                local mod = createInstance("ModuleScript", nameWithoutExt)
                mod.Parent = parentInst
                mod._sourcePath = fullPath
             end
        end
    end
end

-- =============================================================================
-- 4. Environment Setup (Dependencies)
-- =============================================================================

local includeFolder = createInstance("Folder", "include")
includeFolder.Parent = replicatedStorage

local runtimeScript = createInstance("ModuleScript", "RuntimeLib")
runtimeScript.Parent = includeFolder
runtimeScript._sourcePath = "include/RuntimeLib.lua"

local promiseScript = createInstance("ModuleScript", "Promise")
promiseScript.Parent = includeFolder
promiseScript._sourcePath = "include/Promise.lua"

local nodeModules = createInstance("Folder", "node_modules")
nodeModules.Parent = includeFolder -- Reverted: Must be in include for compiled code
local rbxts = createInstance("Folder", "@rbxts")
rbxts.Parent = nodeModules

local jestFolder -- Forward declare for Section 5

-- Map @rbxts packages
if fs.isDir("node_modules/@rbxts") then
    for _, pkgName in fs.readDir("node_modules/@rbxts") do
        local pkgPath = "node_modules/@rbxts/" .. pkgName
        if fs.isDir(pkgPath) then
            -- Determine source path (init.lua, init.luau, or out/init.luau)
            local sourcePath = nil
            if fs.isFile(pkgPath .. "/init.luau") then sourcePath = pkgPath .. "/init.luau"
            elseif fs.isFile(pkgPath .. "/init.lua") then sourcePath = pkgPath .. "/init.lua"
            elseif fs.isDir(pkgPath .. "/out") then
                if fs.isFile(pkgPath .. "/out/init.luau") then sourcePath = pkgPath .. "/out/init.luau"
                elseif fs.isFile(pkgPath .. "/out/init.lua") then sourcePath = pkgPath .. "/out/init.lua"
                end
            end

            -- Special case for the "jest" package name which we want to map to rbxts-jest
            local childDir = pkgPath .. "/out"
            if not fs.isDir(childDir) then childDir = pkgPath end

            if pkgName == "jest" then
                sourcePath = "node_modules/@rbxts/rbxts-jest/out/init.luau"
                childDir = "node_modules/@rbxts/rbxts-jest/out"
            end

            if sourcePath then
                local mod = createInstance("ModuleScript", pkgName)
                mod.Parent = rbxts
                mod._sourcePath = sourcePath
                
                if pkgName == "jest" then jestFolder = mod end

                -- Populate children if it has an 'out' or project structure
                populateMocks(childDir, mod)
            end
        end
    end
end

-- Mirror Project Output
if fs.isDir("out/shared") then populateMocks("out/shared", tsShared) end
if fs.isDir("out/server") then populateMocks("out/server", tsServer) end
if fs.isDir("out/client") then populateMocks("out/client", tsClient) end

-- LOAD RUNTIME LIB explicitly
print("Initializing RuntimeEnv...")

-- Load Promise First
if fs.isFile(promiseScript._sourcePath) then
    local b = luau.compile(fs.readFile(promiseScript._sourcePath))
    local c = luau.load(b, {debugName="Promise"})
    setfenv(c, createEnv())
    local old = _G.script
    _G.script = promiseScript
    local result = c()
    -- Promise lib usually doesn't return TS, just the library.
    -- But RuntimeLib requires it.
    -- My require hook handles 'module == promiseScript' by loading via _sourcePath!
    -- Wait, if I manually load it here, I should cache it?
    -- No, 'require' hook checks 'loadedModules[path]'.
    -- So simply calling require(promiseScript) is enough!
    
    -- Actually, RuntimeLib will require it properly.
end

-- Load RuntimeLib
-- require(runtimeScript) will use my hook, load it, and return result
runtimeLib = require(runtimeScript)

if not runtimeLib then
    print("CRITICAL ERROR: RuntimeLib failed to load")
    process.exit(1)
end
print("RuntimeLib loaded successfully")


-- =============================================================================
-- 5. Run Tests (rbxts-jest)
-- =============================================================================

print("🚀 Loading Specs...")

local Jest = require(jestFolder)

-- Inject Globals
local beforeEachHooks = {}
_G.beforeEach = function(fn)
    table.insert(beforeEachHooks, fn)
end

_G.afterEach = function(fn)
    -- Not implemented yet but placeholder to avoid nil errors
end

local originalTest = Jest.test
_G.test = function(name, fn)
    -- Capture a copy of the CURRENT hooks to ensure isolation between files
    local hooks = {}
    for i, h in ipairs(beforeEachHooks) do hooks[i] = h end
    
    originalTest(name, function()
        for _, hook in ipairs(hooks) do
            hook()
        end
        fn()
    end)
end

-- Shim expect to support both Jest and TestEz syntax
local originalExpect = Jest.expect
_G.expect = function(val)
    local ret = originalExpect(val)
    
    -- Add TestEz compatibility (.to.equal)
    ret.to = {
        equal = function(selfStub, other)
            -- Map equal to toBe
            ret.toBe(nil, other) 
        end
    }
    
    -- Also handle .to.be.equal if needed? TestEz has to.be.equal / to.equal
    -- For now just .to.equal based on compiled output `to:equal(3)`
    
    return ret
end

_G.describe = function(name, fn)
    print("Suite: " .. name)
    fn()
end

-- Hook warn to detect failures
local failureCount = 0
local originalWarn = warn
_G.warn = function(...)
    failureCount = failureCount + 1
    local args = {...}
    for i, v in ipairs(args) do args[i] = tostring(v) end
    print(stdio.color("red") .. "WARN: " .. table.concat(args, " ") .. stdio.color("reset"))
end

local function loadSpecs(dir)
    -- ... (this function seems unused in previous code, runSpecsInHierarchy replaces it)
end

local function runSpecsInHierarchy(inst)
    for _, child in pairs(inst._children) do
        if child.ClassName == "ModuleScript" then 
             if string.match(child.Name, "spec") or string.match(child._sourcePath or "", "spec%.lua") then
                print("Loading spec: " .. child.Name)
                -- Clear hooks for the new spec file
                for k in pairs(beforeEachHooks) do beforeEachHooks[k] = nil end
                
                local m = require(child)
                if type(m) == "function" then
                    m()
                end
             end
             -- Also recurse inside ModuleScript (it can have children)
             runSpecsInHierarchy(child) 
        elseif child.ClassName == "Folder" then
            runSpecsInHierarchy(child)
        end
    end
end

runSpecsInHierarchy(tsShared)
runSpecsInHierarchy(tsServer)
runSpecsInHierarchy(tsClient)

print("🚀 Running Tests...")
Jest.runTests()

if failureCount > 0 then
    print(stdio.color("red") .. "Tests Failed: " .. failureCount .. stdio.color("reset"))
    process.exit(1)
else
    print(stdio.color("green") .. "All Tests Passed" .. stdio.color("reset"))
    process.exit(0)
end
