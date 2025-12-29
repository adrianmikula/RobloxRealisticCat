# Reliable Roblox Coding Best Practices

This document outlines the patterns and lessons learned during the development of the **Roblox Realistic Cat** project, focusing on type safety, testability, and architecture.

## 1. Type Safety with `roblox-ts`

### Avoid `any` at all costs
The `roblox-ts` compiler is strict. Using `any` often breaks type inference downstream. If you must bypass a type check (e.g., for a mock), prefer `unknown` followed by a specific cast.

```typescript
// Good: Type-safe bypass
const mockPlayer = { Name: "Test" } as unknown as Player;

// Bad: Lose all safety
const mockPlayer = { Name: "Test" } as any;
```

### Global Augmentation
For frameworks like Knit, use `globals.d.ts` to augment standard interfaces. This provides project-wide intellisense for services and controllers.

```typescript
declare global {
    interface KnitServices {
        CatService: CatServiceType;
    }
}
```

## 2. Architecture: The Knit Framework

### Service vs. Controller
- **Services (Server)**: Own the "Source of Truth" (e.g., `CatManager`). Handle data, AI logic, and persistence.
- **Controllers (Client)**: Handle visuals, inputs, and UI. They should be "thin" and rely on the server for state.

### Effective Networking
Roblox does **not** support `Map` or `Set` objects across the network. Always convert these to standard Tables (TypeScript `Record<string, T>`) or Arrays before returning them from a `RemoteFunction` or firing a `RemoteSignal`.

### The Knit Service Proxy Context Gotcha
When defining Knit services in `roblox-ts`, if you call a server-side method from within the `Client` proxy block, you **must** manually preserve the service context (`this`).

**The Problem**: Knit passes the `Player` object as the context to the proxy function. If you call `this.SomeMethod()`, `this` might refer to the Player, not the Service.

```typescript
// ❌ WRONG: 'this' will be the Player object at runtime
Client: {
    SpawnCat(player: Player) {
        return this.ServerMethod(); // 'this' is Player! Throws error.
    }
}

// ✅ CORRECT: Explicitly pass the Service object as the 'self' context
Client: {
    SpawnCat(player: Player) {
        return (CatService as any).SpawnCat(CatService, player);
    }
}
```

## 3. CLI Unit Testing with Lune & Jest

### The Mock Environment
Since Lune does not run the Roblox Engine, you must mock every service and instance your code touches.
- **KnitMock**: Use a lightweight mock for `Knit.CreateService` and `RemoteSignals` to test business logic without the framework overhead.
- **Instance Mocks**: Ensure your mock instances support properties like `.Parent`, `.Value` (for ValueObjects), and basic methods like `:FindFirstChild()`.

### Handling `script` and Paths
Many Roblox modules use `script.Parent` to find siblings. Your test runner must inject a valid mock `script` object into each module's environment and correctly set its `Parent` property to mirror the project structure.

## 4. Testing "Game Dynamics"

### Deterministic Physics
In-game movement is often non-deterministic. To test it:
1. **Mock DT**: Use a fixed DeltaTime if possible.
2. **Block AI Decisions**: In unit tests, manually set the `lastDecisionTime` of an AI component to a high value so it doesn't change state while you are testing a specific movement cycle.
3. **Threshold Asserts**: Instead of checking for exact positions, check if the cat moved "towards" a target or within a reasonable range.

```typescript
// Example: Testing movement towards a target
const initialDist = posA.sub(target).Magnitude;
CatAI.Update(cat);
const finalDist = posB.sub(target).Magnitude;
expect(finalDist < initialDist).toBe(true);
```

## 5. Performance & Culling

### Client-Side Visuals
Always implement distance-based culling for expensive visuals (like BillboardGuis or complex models).
- Use `task.wait()` loops (e.g., every 5 seconds) to hide visuals that are 200+ studs away.
- Ensure the server still tracks the cat's "ghost" position so it can re-appear seamlessly when the player returns.
