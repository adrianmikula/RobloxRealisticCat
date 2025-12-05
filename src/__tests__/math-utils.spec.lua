local JestGlobals = require("@DevPackages/JestGlobals")

local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

-- Mock module for testing
local MathUtils = {
    add = function(a, b)
        return a + b
    end,
    
    subtract = function(a, b)
        return a - b
    end,
    
    multiply = function(a, b)
        return a * b
    end,
    
    divide = function(a, b)
        if b == 0 then
            error("Division by zero")
        end
        return a / b
    end,
    
    clamp = function(value, min, max)
        if value < min then
            return min
        elseif value > max then
            return max
        end
        return value
    end,
    
    lerp = function(a, b, t)
        return a + (b - a) * t
    end
}

describe("MathUtils", function()
    describe("add", function()
        it("should add positive numbers", function()
            expect(MathUtils.add(2, 3)).toBe(5)
            expect(MathUtils.add(10, 20)).toBe(30)
        end)
        
        it("should add negative numbers", function()
            expect(MathUtils.add(-2, 3)).toBe(1)
            expect(MathUtils.add(5, -10)).toBe(-5)
        end)
        
        it("should add zero", function()
            expect(MathUtils.add(0, 5)).toBe(5)
            expect(MathUtils.add(10, 0)).toBe(10)
        end)
    end)
    
    describe("subtract", function()
        it("should subtract numbers", function()
            expect(MathUtils.subtract(10, 3)).toBe(7)
            expect(MathUtils.subtract(5, 10)).toBe(-5)
        end)
    end)
    
    describe("multiply", function()
        it("should multiply numbers", function()
            expect(MathUtils.multiply(3, 4)).toBe(12)
            expect(MathUtils.multiply(-2, 5)).toBe(-10)
        end)
        
        it("should multiply by zero", function()
            expect(MathUtils.multiply(10, 0)).toBe(0)
            expect(MathUtils.multiply(0, 5)).toBe(0)
        end)
    end)
    
    describe("divide", function()
        it("should divide numbers", function()
            expect(MathUtils.divide(10, 2)).toBe(5)
            expect(MathUtils.divide(9, 3)).toBe(3)
        end)
        
        it("should handle division by zero", function()
            expect(function()
                MathUtils.divide(10, 0)
            end).toThrow("Division by zero")
        end)
    end)
    
    describe("clamp", function()
        it("should clamp values within range", function()
            expect(MathUtils.clamp(5, 0, 10)).toBe(5)
            expect(MathUtils.clamp(15, 0, 10)).toBe(10)
            expect(MathUtils.clamp(-5, 0, 10)).toBe(0)
        end)
        
        it("should handle edge cases", function()
            expect(MathUtils.clamp(0, 0, 10)).toBe(0)
            expect(MathUtils.clamp(10, 0, 10)).toBe(10)
        end)
    end)
    
    describe("lerp", function()
        it("should interpolate between values", function()
            expect(MathUtils.lerp(0, 10, 0.5)).toBe(5)
            expect(MathUtils.lerp(0, 10, 0)).toBe(0)
            expect(MathUtils.lerp(0, 10, 1)).toBe(10)
            expect(MathUtils.lerp(10, 20, 0.3)).toBe(13)
        end)
    end)
end)