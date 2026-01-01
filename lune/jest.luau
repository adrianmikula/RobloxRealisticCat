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
        print = print or function(...) stdio.write(table.concat({...}, " ") .. "\n") end,
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
        script = _G.script,
    }
    
    if env.script then
        -- print(string.format("ENV: script=%s parent=%s", tostring(env.script), tostring(env.script.Parent)))
    end

    return setmetatable(env, { __index = _G })
end

local roblox = require("@lune/roblox")
_G.CFrame = roblox.CFrame
_G.Vector3 = roblox.Vector3
-- Improve Vector3 equality for tests
-- We use a raw metatable approach for the global Vector3 table's'metatable
pcall(function()
    local mt = {
        __eq = function(a, b)
            return (a - b).Magnitude < 1e-4
        end
    }
    debug.setmetatable(_G.Vector3.new(), mt)
end)
_G.Vector2 = roblox.Vector2
_G.stdio = stdio
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
    if className == "RaycastParams" then
        return {
            FilterDescendantsInstances = {},
            FilterType = 0,
            IgnoreWater = true,
            new = function() return { FilterDescendantsInstances = {}, FilterType = 0, IgnoreWater = true } end
        }
    end
    _G.RaycastParams = {
        new = function() return createInstance("RaycastParams") end
    }

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
    
    instance.Raycast = function(self, origin, direction, params)
        if self._raycastHook then
            local result = self._raycastHook(origin, direction, params)
            if result and result.Position then
                -- Use _G.Vector3 because local roblox.Vector3 might not be the same one TS uses
                result.Position = _G.Vector3.new(result.Position.X, result.Position.Y, result.Position.Z)
            end
            return result
        end
        return nil -- Mock: no hit by default
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
            if k == "Value" then return rawget(t, "_value") end
            if k == "Parent" then return rawget(t, "Parent") end
            return rawget(instance, k)
        end,
        __newindex = function(t, k, v)
            if k == "Value" then
                rawset(t, "_value", v)
                return
            end
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
    
    if serviceName == "Players" then
        if not self._children["Players"] then
            local playersService = createInstance("Players")
            local playersList = {} -- Track players by UserId
            local playersArray = {} -- Array for GetPlayers()
            
            -- Mock PlayerAdded and PlayerRemoving events
            local playerAddedListeners = {}
            local playerRemovingListeners = {}
            
            playersService.PlayerAdded = {
                Connect = function(_, cb)
                    table.insert(playerAddedListeners, cb)
                    return { Disconnect = function() end }
                end
            }
            
            playersService.PlayerRemoving = {
                Connect = function(_, cb)
                    table.insert(playerRemovingListeners, cb)
                    return { Disconnect = function() end }
                end
            }
            
            -- GetPlayers() returns array of all players
            -- Use rawset to ensure method is directly on the table, bypassing metatable
            rawset(playersService, "GetPlayers", function(self)
                return playersArray
            end)
            
            -- GetPlayerByUserId(userId) finds player by UserId
            rawset(playersService, "GetPlayerByUserId", function(self, userId)
                return playersList[userId]
            end)
            
            -- Helper to add a player (called by PlayerManager or tests)
            rawset(playersService, "_addPlayer", function(self, player)
                if player and player.UserId and not playersList[player.UserId] then
                    playersList[player.UserId] = player
                    table.insert(playersArray, player)
                    -- Fire PlayerAdded event
                    for _, listener in ipairs(playerAddedListeners) do
                        pcall(listener, player)
                    end
                end
            end)
            
            -- Helper to remove a player
            rawset(playersService, "_removePlayer", function(self, player)
                if playersList[player.UserId] then
                    playersList[player.UserId] = nil
                    for i, p in ipairs(playersArray) do
                        if p.UserId == player.UserId then
                            table.remove(playersArray, i)
                            break
                        end
                    end
                    -- Fire PlayerRemoving event
                    for _, listener in ipairs(playerRemovingListeners) do
                        pcall(listener, player)
                    end
                end
            end)
            
            playersService.Parent = self
            self._children["Players"] = playersService
        end
        return self._children["Players"]
    end

    if not self._children[serviceName] then
        local service = createInstance(serviceName)
        service.Parent = self
        self._children[serviceName] = service
    end
    return self._children[serviceName]
end

_G.Enum = {
    RaycastFilterType = {
        Include = 0,
        Exclude = 1,
    },
    Material = {
        Plastic = 0,
        Neon = 1,
    }
}
_G.Workspace = game:GetService("Workspace")
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
            
            -- Inject TS runtime for loaded modules
            if runtimeLib then
                _G[module] = runtimeLib
            end

            local oldScript = _G.script
            _G.script = module
            setfenv(chunk, createEnv())
            local result = chunk()
            _G.script = oldScript
            
            -- Hook PlayerManager to auto-register players with Players service
            -- Check if this is the player-manager module
            if string.match(module._sourcePath or "", "player%-manager") then
                if result and type(result) == "table" then
                    -- Check for PlayerManager class export (result.PlayerManager)
                    if result.PlayerManager and type(result.PlayerManager) == "table" then
                        local playerManager = result.PlayerManager
                        if playerManager.HandlePlayerAdded then
                            local originalHandlePlayerAdded = playerManager.HandlePlayerAdded
                            playerManager.HandlePlayerAdded = function(self, player)
                                originalHandlePlayerAdded(self, player)
                                -- Also register with Players service mock
                                local playersService = game:GetService("Players")
                                if playersService and playersService._addPlayer then
                                    playersService._addPlayer(player)
                                end
                            end
                        end
                    -- Check if result itself is PlayerManager class (direct export)
                    elseif result.HandlePlayerAdded then
                        local originalHandlePlayerAdded = result.HandlePlayerAdded
                        result.HandlePlayerAdded = function(self, player)
                            originalHandlePlayerAdded(self, player)
                            -- Also register with Players service mock
                            local playersService = game:GetService("Players")
                            if playersService and playersService._addPlayer then
                                playersService._addPlayer(player)
                            end
                        end
                        -- Also check __index for class methods
                        if result.__index and result.__index.HandlePlayerAdded then
                            local originalHandlePlayerAdded = result.__index.HandlePlayerAdded
                            result.__index.HandlePlayerAdded = function(self, player)
                                originalHandlePlayerAdded(self, player)
                                local playersService = game:GetService("Players")
                                if playersService and playersService._addPlayer then
                                    playersService._addPlayer(player)
                                end
                            end
                        end
                    end
                end
            end
            
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
                 -- If this is an init file, its Parent should be parentInst, 
                 -- and its children should also be siblings in the folder?
                 -- Actually, if we're IN a folder and found init.lua, 
                 -- the ModuleScript IS the folder in Roblox's eyes.
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
            -- Determine source path
            local sourcePath = nil
            if fs.isFile(pkgPath .. "/init.luau") then sourcePath = pkgPath .. "/init.luau"
            elseif fs.isFile(pkgPath .. "/init.lua") then sourcePath = pkgPath .. "/init.lua"
            elseif fs.isDir(pkgPath .. "/out") then
                if fs.isFile(pkgPath .. "/out/init.luau") then sourcePath = pkgPath .. "/out/init.luau"
                elseif fs.isFile(pkgPath .. "/out/init.lua") then sourcePath = pkgPath .. "/out/init.lua"
                end
            elseif fs.isDir(pkgPath .. "/" .. pkgName:sub(1, 1):upper() .. pkgName:sub(2)) then
                -- Handle @rbxts/knit -> Knit/init.lua pattern
                local nestedDir = pkgPath .. "/" .. pkgName:sub(1,1):upper() .. pkgName:sub(2)
                if fs.isFile(nestedDir .. "/init.lua") then sourcePath = nestedDir .. "/init.lua"
                elseif fs.isFile(nestedDir .. "/init.luau") then sourcePath = nestedDir .. "/init.luau"
                end
            end

            -- Special case for package name mapping
            local normalizedName = pkgName:lower()
            local instName = pkgName
            
            if normalizedName == "knit" then
                -- Use custom mock for Knit to avoid engine dependencies
                -- Structue: @rbxts/knit (Folder) -> Knit (ModuleScript)
                local pkgFolder = createInstance("Folder", "knit")
                pkgFolder.Parent = rbxts
                
                local mod = createInstance("ModuleScript", "Knit")
                mod.Parent = pkgFolder
                mod._sourcePath = "lune/mocks/KnitMock.luau"
            elseif sourcePath then
                local mod = createInstance("ModuleScript", instName)
                mod.Parent = rbxts
                mod._sourcePath = sourcePath
                
                if normalizedName == "jest" or normalizedName == "rbxts-jest" then jestFolder = mod end

                local childDir = pkgPath .. "/out"
                if not fs.isDir(childDir) then childDir = pkgPath end
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

-- Add global helper to register players with Players service for tests
_G.registerTestPlayer = function(player)
    local playersService = game:GetService("Players")
    if playersService and playersService._addPlayer then
        playersService._addPlayer(player)
    end
end


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
    
    -- Add missing matchers that tests need
    ret.toBeLessThan = function(selfStub, expected)
        if type(val) ~= "number" or type(expected) ~= "number" then
            error(string.format("toBeLessThan: Expected numbers, got %s and %s", type(val), type(expected)), 2)
        end
        if val >= expected then
            error(string.format("Expected %s to be less than %s", tostring(val), tostring(expected)), 2)
        end
    end
    
    ret.toBeGreaterThan = function(selfStub, expected)
        if type(val) ~= "number" or type(expected) ~= "number" then
            error(string.format("toBeGreaterThan: Expected numbers, got %s and %s", type(val), type(expected)), 2)
        end
        if val <= expected then
            error(string.format("Expected %s to be greater than %s", tostring(val), tostring(expected)), 2)
        end
    end
    
    ret.toBeGreaterThanOrEqual = function(selfStub, expected)
        if type(val) ~= "number" or type(expected) ~= "number" then
            error(string.format("toBeGreaterThanOrEqual: Expected numbers, got %s and %s", type(val), type(expected)), 2)
        end
        if val < expected then
            error(string.format("Expected %s to be greater than or equal to %s", tostring(val), tostring(expected)), 2)
        end
    end
    
    ret.toBeUndefined = function(selfStub)
        if val ~= nil then
            error(string.format("Expected %s to be undefined (nil)", tostring(val)), 2)
        end
    end
    
    ret.toBeDefined = function(selfStub)
        if val == nil then
            error("Expected value to be defined (not nil)", 2)
        end
    end
    
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
