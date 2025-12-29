import { MathUtils } from "../math-utils";

export = () => {
    describe("MathUtils", () => {
        test("clamp", () => {
            expect(MathUtils.clamp(5, 0, 10)).toBe(5);
            expect(MathUtils.clamp(15, 0, 10)).toBe(10);
            expect(MathUtils.clamp(-5, 0, 10)).toBe(0);
        });

        test("lerp", () => {
            expect(MathUtils.lerp(0, 10, 0.5)).toBe(5);
            expect(MathUtils.lerp(0, 10, 0)).toBe(0);
            expect(MathUtils.lerp(0, 10, 1)).toBe(10);
        });

        test("map", () => {
            expect(MathUtils.map(5, 0, 10, 0, 100)).toBe(50);
            expect(MathUtils.map(0, 0, 10, 0, 100)).toBe(0);
            expect(MathUtils.map(10, 0, 10, 0, 100)).toBe(100);
        });

        test("isInRange", () => {
            expect(MathUtils.isInRange(5, 0, 10)).toBe(true);
            expect(MathUtils.isInRange(0, 0, 10)).toBe(true);
            expect(MathUtils.isInRange(10, 0, 10)).toBe(true);
            expect(MathUtils.isInRange(11, 0, 10)).toBe(false);
            expect(MathUtils.isInRange(-1, 0, 10)).toBe(false);
        });

        test("percentage", () => {
            expect(MathUtils.percentage(5, 10)).toBe(50);
            expect(MathUtils.percentage(0, 10)).toBe(0);
            expect(MathUtils.percentage(10, 10)).toBe(100);
            expect(MathUtils.percentage(5, 0)).toBe(0);
        });

        test("formatNumber", () => {
            expect(MathUtils.formatNumber(1000)).toBe("1,000");
            expect(MathUtils.formatNumber(1000000)).toBe("1,000,000");
            expect(MathUtils.formatNumber(100)).toBe("100");
        });

        test("distance", () => {
            expect(MathUtils.distance(0, 0, 3, 4)).toBe(5);
            expect(MathUtils.distance(0, 0, 0, 0, 3, 4)).toBe(1); // Distance between (0,0,3) and (0,0,4) is 1
            // distance(x1, y1, x2, y2, z1, z2)
            // Let's check 3D distance
            expect(MathUtils.distance(0, 0, 1, 1, 0, 1)).toBe(math.sqrt(3));
        });

        test("radToDeg and degToRad", () => {
            expect(MathUtils.radToDeg(math.pi)).toBe(180);
            expect(MathUtils.degToRad(180)).toBe(math.pi);
        });
    });
};
