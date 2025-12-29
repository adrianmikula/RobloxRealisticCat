-- Lightweight Knit Mock for Lune Testing
local Knit = {}

local services = {}
local controllers = {}

-- Mock RemoteSignal
local RemoteSignal = {}
RemoteSignal.__index = RemoteSignal

function RemoteSignal.new()
    return setmetatable({
        _listeners = {}
    }, RemoteSignal)
end

function RemoteSignal:Connect(fn)
    table.insert(self._listeners, fn)
    return {
        Disconnect = function()
            for i, listener in ipairs(self._listeners) do
                if listener == fn then
                    table.remove(self._listeners, i)
                    break
                end
            end
        end
    }
end

function RemoteSignal:Fire(...)
    for _, listener in ipairs(self._listeners) do
        listener(...)
    end
end

function RemoteSignal:FireAll(...)
    self:Fire(...)
end

function RemoteSignal:FireClient(player, ...)
    self:Fire(...)
end

function RemoteSignal:Wait()
    -- No-op in mock
end

-- Mock RemoteProperty
local RemoteProperty = {}
RemoteProperty.__index = RemoteProperty

function RemoteProperty.new(value)
    return setmetatable({
        Value = value,
        _listeners = {}
    }, RemoteProperty)
end

function RemoteProperty:Get()
    return self.Value
end

function RemoteProperty:Set(value)
    self.Value = value
    for _, listener in ipairs(self._listeners) do
        listener(value)
    end
end

function RemoteProperty:Observe(fn)
    table.insert(self._listeners, fn)
    fn(self.Value)
    return {
        Disconnect = function()
             for i, listener in ipairs(self._listeners) do
                if listener == fn then
                    table.remove(self._listeners, i)
                    break
                end
            end
        end
    }
end

-- Knit API
function Knit.CreateService(serviceDef)
    services[serviceDef.Name] = serviceDef
    return serviceDef
end

function Knit.GetService(name)
    return services[name]
end

function Knit.CreateController(controllerDef)
    controllers[controllerDef.Name] = controllerDef
    return controllerDef
end

function Knit.GetController(name)
    return controllers[name]
end

function Knit.Start()
    -- Mock Promise
    return {
        await = function() end,
        andThen = function(self, fn) fn() return self end,
        catch = function(self) return self end,
    }
end

function Knit.OnStart()
     return {
        await = function() end,
        andThen = function(self, fn) fn() return self end,
        catch = function(self) return self end,
    }
end

-- Export both for KnitServer/KnitClient compatibility
return {
    KnitServer = Knit,
    KnitClient = Knit,
    RemoteSignal = RemoteSignal,
    RemoteProperty = RemoteProperty,
}
