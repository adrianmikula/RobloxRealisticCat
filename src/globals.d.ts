declare global {
    function describe(name: string, callback: () => void): void;
    function test(name: string, callback: () => void): void;
    function it(name: string, callback: () => void): void;
    function beforeEach(callback: () => void): void;
    function afterEach(callback: () => void): void;
    function expect(value: unknown): {
        to: {
            equal(expected: unknown): void;
        };
        toBe(expected: unknown): void;
        toThrow(expected?: string): void;
        toBeLessThan(expected: number): void;
        toBeGreaterThan(expected: number): void;
        toBeGreaterThanOrEqual(expected: number): void;
        toBeUndefined(): void;
        toBeDefined(): void;
    };
}

// Knit type augmentations
declare global {
    interface KnitServices {
        CatService: import("server/cat-service").CatServiceType;
    }
    interface KnitControllers {
        CatController: typeof import("client/cat-controller").CatController;
    }
}

export { };
