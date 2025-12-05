local JestGlobals = require("@DevPackages/JestGlobals")
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

-- Mock require to handle our module path
local originalRequire = require
local mockRequire = function(module)
    if module == "@Project/MathUtils" then
        -- Load the actual MathUtils module
        local fs = require("fs")
        local code = fs.readFile("src/ReplicatedStorage/SharedSource/Utilities/MathUtils/init.lua")
        local chunk = load(code, "MathUtils", "t", {require = mockRequire})
        return chunk()
    end
    return originalRequire(module)
end

-- Temporarily replace require
local _G = _G
_G.require = mockRequire

-- Load MathUtils
local MathUtils = require("@Project/MathUtils")

-- Restore original require
_G.require = originalRequire

describe("Game MathUtils", function()
    describe("clamp", function()
        it("should clamp values within range", function()
            expect(MathUtils.clamp(5, 0, 10)).toBe(5)
            expect(MathUtils.clamp(15, 0, 10)).toBe(10)
            expect(MathUtils.clamp(-5, 0, 10)).toBe(0)
        end)
        
        it("should handle edge cases", function()
            expect(MathUtils.clamp(0, 0, 10)).toBe(0)
            expect(MathUtils.clamp(10, 0, 10)).toBe(10)
            expect(MathUtils.clamp(5, 5, 5)).toBe(5)
        end)
    end)
    
    describe("lerp", function()
        it("should interpolate between values", function()
            expect(MathUtils.lerp(0, 10, 0.5)).toBe(5)
            expect(MathUtils.lerp(0, 10, 0)).toBe(0)
            expect(MathUtils.lerp(0, 10, 1)).toBe(10)
            expect(MathUtils.lerp(10, 20, 0.3)).toBe(13)
        end)
        
        it("should handle negative values", function()
            expect(MathUtils.lerp(-10, 10, 0.5)).toBe(0)
            expect(MathUtils.lerp(10, -10, 0.5)).toBe(0)
        end)
    end)
    
    describe("map", function()
        it("should map values between ranges", function()
            expect(MathUtils.map(5, 0, 10, 0, 100)).toBe(50)
            expect(MathUtils.map(2.5, 0, 5, 0, 10)).toBe(5)
            expect(MathUtils.map(0, -10, 10, 0, 100)).toBe(50)
        end)
    end)
    
    describe("roundToNearest", function()
        it("should round to nearest multiple", function()
            expect(MathUtils.roundToNearest(7, 5)).toBe(5)
            expect(MathUtils.roundToNearest(8, 5)).toBe(10)
            expect(MathUtils.roundToNearest(12, 10)).toBe(10)
            expect(MathUtils.roundToNearest(15, 10)).toBe(20)
        end)
    end)
    
    describe("isInRange", function()
        it("should check if value is in range", function()
            expect(MathUtils.isInRange(5, 0, 10)).toBe(true)
            expect(MathUtils.isInRange(15, 0, 10)).toBe(false)
            expect(MathUtils.isInRange(0, 0, 10)).toBe(true)
            expect(MathUtils.isInRange(10, 0, 10)).toBe(true)
        end)
    end)
    
    describe("percentage", function()
        it("should calculate percentage", function()
            expect(MathUtils.percentage(50, 100)).toBe(50)
            expect(MathUtils.percentage(25, 100)).toBe(25)
            expect(MathUtils.percentage(0, 100)).toBe(0)
            expect(MathUtils.percentage(100, 100)).toBe(100)
        end)
        
        it("should handle zero total", function()
            expect(MathUtils.percentage(50, 0)).toBe(0)
        end)
    end)
    
    describe("formatNumber", function()
        it("should format numbers with commas", function()
            expect(MathUtils.formatNumber(1000)).toBe("1,000")
            expect(MathUtils.formatNumber(1000000)).toBe("1,000,000")
            expect(MathUtils.formatNumber(123456789)).toBe("123,456,789")
        end)
        
        it("should handle negative numbers", function()
            expect(MathUtils.formatNumber(-1000)).toBe("-1,000")
            expect(MathUtils.formatNumber(-1234567)).toBe("-1,234,567")
        end)
        
        it("should not format small numbers", function()
            expect(MathUtils.formatNumber(999)).toBe("999")
            expect(MathUtils.formatNumber(100)).toBe("100")
            expect(MathUtils.formatNumber(0)).toBe("0")
        end)
    end)
    
    describe("distance", function()
        it("should calculate 2D distance", function()
            expect(MathUtils.distance(0, 0, 3, 4)).toBe(5) -- 3-4-5 triangle
            expect(MathUtils.distance(1, 1, 4, 5)).toBe(5) -- 3-4-5 triangle
        end)
        
        it("should calculate 3D distance", function()
            expect(MathUtils.distance(0, 0, 0, 3, 4, 0)).toBe(5)
            expect(MathUtils.distance(0, 0, 0, 1, 2, 2)).toBe(3) -- 1² + 2² + 2² = 9, sqrt = 3
        end)
    end)
    
    describe("angleBetween", function()
        it("should calculate angle between points", function()
            -- 45 degree angle
            local angle = MathUtils.angleBetween(0, 0, 1, 1)
            expect(math.abs(angle - math.pi/4)).toBeLessThan(0.0001)
            
            -- 90 degree angle (straight up)
            local angle90 = MathUtils.angleBetween(0, 0, 0, 1)
            expect(math.abs(angle90 - math.pi/2)).toBeLessThan(0.0001)
        end)
    end)
    
    describe("conversion functions", function()
        it("should convert radians to degrees", function()
            expect(MathUtils.radToDeg(math.pi)).toBe(180)
            expect(MathUtils.radToDeg(math.pi/2)).toBe(90)
            expect(MathUtils.radToDeg(math.pi/4)).toBe(45)
        end)
        
        it("should convert degrees to radians", function()
            expect(MathUtils.degToRad(180)).toBe(math.pi)
            expect(MathUtils.degToRad(90)).toBe(math.pi/2)
            expect(MathUtils.degToRad(45)).toBe(math.pi/4)
        end)
    end)
    
    describe("random functions", function()
        it("should generate random integers in range", function()
            -- Test multiple times to ensure range is respected
            for i = 1, 100 do
                local value = MathUtils.randomInt(1, 10)
                expect(value).toBeGreaterThanOrEqual(1)
                expect(value).toBeLessThanOrEqual(10)
                expect(math.floor(value)).toBe(value) -- Ensure it's an integer
            end
        end)
        
        it("should generate random floats in range", function()
            for i = 1, 100 do
                local value = MathUtils.randomFloat(0, 1)
                expect(value).toBeGreaterThanOrEqual(0)
                expect(value).toBeLessThanOrEqual(1)
            end
        end)
        
        it("should check random chance", function()
            -- Test with 0% chance (should always be false)
            for i = 1, 100 do
                expect(MathUtils.randomChance(0)).toBe(false)
            end
            
            -- Test with 100% chance (should always be true)
            for i = 1, 100 do
                expect(MathUtils.randomChance(100)).toBe(true)
            end
        end)
    end)
end)