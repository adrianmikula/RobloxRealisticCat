local MathUtils = {}

-- Basic math operations
function MathUtils.clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    end
    return value
end

-- Linear interpolation
function MathUtils.lerp(a, b, t)
    return a + (b - a) * t
end

-- Map value from one range to another
function MathUtils.map(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

-- Round to nearest multiple
function MathUtils.roundToNearest(value, multiple)
    return math.floor((value + multiple / 2) / multiple) * multiple
end

-- Check if value is within range (inclusive)
function MathUtils.isInRange(value, min, max)
    return value >= min and value <= max
end

-- Calculate percentage
function MathUtils.percentage(value, total)
    if total == 0 then
        return 0
    end
    return (value / total) * 100
end

-- Format number with commas
function MathUtils.formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then
            break
        end
    end
    return formatted
end

-- Calculate distance between two points (2D or 3D)
function MathUtils.distance(x1, y1, x2, y2, z1, z2)
    if z1 and z2 then
        -- 3D distance
        local dx = x2 - x1
        local dy = y2 - y1
        local dz = z2 - z1
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    else
        -- 2D distance
        local dx = x2 - x1
        local dy = y2 - y1
        return math.sqrt(dx * dx + dy * dy)
    end
end

-- Calculate angle between two points (in radians)
function MathUtils.angleBetween(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

-- Convert radians to degrees
function MathUtils.radToDeg(rad)
    return rad * (180 / math.pi)
end

-- Convert degrees to radians
function MathUtils.degToRad(deg)
    return deg * (math.pi / 180)
end

-- Generate random integer in range [min, max]
function MathUtils.randomInt(min, max)
    return math.random(min, max)
end

-- Generate random float in range [min, max]
function MathUtils.randomFloat(min, max)
    return min + math.random() * (max - min)
end

-- Check random chance (percentage)
function MathUtils.randomChance(percent)
    return math.random() * 100 <= percent
end

return MathUtils