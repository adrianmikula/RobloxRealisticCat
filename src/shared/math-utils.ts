export namespace MathUtils {
    /**
     * Clamp value between min and max
     */
    export function clamp(value: number, min: number, max: number): number {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }

    /**
     * Linear interpolation
     */
    export function lerp(a: number, b: number, t: number): number {
        return a + (b - a) * t;
    }

    /**
     * Map value from one range to another
     */
    export function map(value: number, inMin: number, inMax: number, outMin: number, outMax: number): number {
        return ((value - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
    }

    /**
     * Round to nearest multiple
     */
    export function roundToNearest(value: number, multiple: number): number {
        return math.floor((value + multiple / 2) / multiple) * multiple;
    }

    /**
     * Check if value is within range (inclusive)
     */
    export function isInRange(value: number, min: number, max: number): boolean {
        return value >= min && value <= max;
    }

    /**
     * Calculate percentage
     */
    export function percentage(value: number, total: number): number {
        if (total === 0) return 0;
        return (value / total) * 100;
    }

    /**
     * Format number with commas
     */
    export function formatNumber(num: number): string {
        let formatted = tostring(num);
        while (true) {
            const [newFormatted, count] = formatted.gsub("^(-?%d+)(%d%d%d)", "%1,%2");
            formatted = newFormatted;
            if (count === 0) break;
        }
        return formatted;
    }

    /**
     * Calculate distance between two points (2D or 3D)
     */
    export function distance(x1: number, y1: number, x2: number, y2: number, z1?: number, z2?: number): number {
        if (z1 !== undefined && z2 !== undefined) {
            const dx = x2 - x1;
            const dy = y2 - y1;
            const dz = z2 - z1;
            return math.sqrt(dx * dx + dy * dy + dz * dz);
        } else {
            const dx = x2 - x1;
            const dy = y2 - y1;
            return math.sqrt(dx * dx + dy * dy);
        }
    }

    /**
     * Calculate angle between two points (in radians)
     */
    export function angleBetween(x1: number, y1: number, x2: number, y2: number): number {
        return math.atan2(y2 - y1, x2 - x1);
    }

    /**
     * Convert radians to degrees
     */
    export function radToDeg(rad: number): number {
        return rad * (180 / math.pi);
    }

    /**
     * Convert degrees to radians
     */
    export function degToRad(deg: number): number {
        return deg * (math.pi / 180);
    }

    /**
     * Generate random integer in range [min, max]
     */
    export function randomInt(min: number, max: number): number {
        return math.random(min, max);
    }

    /**
     * Generate random float in range [min, max]
     */
    export function randomFloat(min: number, max: number): number {
        return min + math.random() * (max - min);
    }

    /**
     * Check random chance (percentage)
     */
    export function randomChance(percent: number): boolean {
        return math.random() * 100 <= percent;
    }
}
