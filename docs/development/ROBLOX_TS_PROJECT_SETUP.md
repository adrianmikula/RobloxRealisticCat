# Roblox-TS Project Setup Guide

This document outlines the correct configuration for a professional `roblox-ts` project, specifically addressing common build errors related to "Could not find Rojo data" and dependency resolution.

## 1. Prerequisites
- **Node.js** & **npm**
- **Rokit** (Toolchain manager)
- **Roblox-TS** (`npm i -g roblox-ts` or use via `npx`)

## 2. Project Initialization
Run the standard initialization command:
```bash
npm init roblox-ts
```

## 3. Critical Configuration Files

### `default.project.json`
**CRITICAL**: You must explicitly map the `node_modules` folder for `roblox-ts` to correctly resolve packages like `@rbxts` or `@flamework`. The standard `rbxts_include` mapping is often insufficient if the compiler expects explicit scope mapping.

**Recommended Structure:**
```json
{
  "name": "my-game",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "include": {
        "$path": "include",
        "node_modules": {
          "@rbxts": {
            "$path": "node_modules/@rbxts"
          },
          // Add other scopes here if needed (e.g., @flamework)
          // "@flamework": { "$path": "node_modules/@flamework" }
        }
      },
      "TS": {
        "$path": "out/shared"
      }
    },
    "ServerScriptService": {
      "TS": {
        "$path": "out/server"
      }
    },
    "StarterPlayer": {
      "StarterPlayerScripts": {
        "TS": {
          "$path": "out/client"
        }
      }
    }
  }
}
```

### `tsconfig.json`
Ensure `strict` mode is enabled and `moduleDetection` is set to `force`.

```json
{
  "compilerOptions": {
    "allowSyntheticDefaultImports": true,
    "downlevelIteration": true,
    "jsx": "react",
    "jsxFactory": "Roact.createElement",
    "jsxFragmentFactory": "Roact.createFragment",
    "module": "commonjs",
    "moduleResolution": "Node",
    "noLib": true,
    "resolveJsonModule": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "rootDir": "src",
    "outDir": "out",
    "baseUrl": "src",
    "strict": true,
    "moduleDetection": "force",
    "target": "ESNext",
    "typeRoots": [
      "node_modules/@rbxts"
      // Add "node_modules/@flamework" here if using Flamework
    ]
  },
  "include": [
    "src"
  ]
}
```

## 4. Dependencies
Install standard dependencies:
```bash
npm install --save-dev roblox-ts @rbxts/types @rbxts/compiler-types
npm install @rbxts/services @rbxts/t @rbxts/maid @rbxts/signal
```

## 5. Building
Run the build command:
```bash
npm run build
# OR
rbxtsc
```

## 6. Toolchain Management (Rokit)
We use `rokit` to manage tools like Rojo, Lune, and Wally.

### `rokit.toml` Configuration
**Important**: Rokit requires full "owner/repo@version" specifications in `rokit.toml`.
```toml
[tools]
rojo = "rojo-rbx/rojo@7.4.4"
lune = "lune-org/lune@0.8.6"
stylo = "JohnnyMorganz/stylo@2.2.0"
selene = "kampfhannah/selene@0.27.1"
wally = "UpliftGames/wally@0.3.2"
```

### Installation
After configuring `rokit.toml`, run:
```bash
rokit install
```
*Note: You may be prompted to trust valid tools. Type 'y' to proceed.*

## 7. CLI Testing Setup (Lune + Jest)
To establish a robust, fast, and offline testing environment for `roblox-ts` using `lune` and `jest`:

### 1. Installation
Install the required Jest packages:
```bash
npm install --save-dev @rbxts/jest @rbxts/rbxts-jest
```
*   `@rbxts/jest`: Types for writing tests in TypeScript.
*   `@rbxts/rbxts-jest`: The Lua runtime implementation of Jest compatible with `roblox-ts`.

### 2. Test Runner Script (`lune/jest.luau`)
Create a custom Lune script to bridge the gap between compiled `roblox-ts` output and the Lune runtime. This script must:
1.  **Mock the Roblox Environment**: Create fake `ReplicatedStorage`, `ServerScriptService`, `RunService` (with Heartbeat), `Promise`, and `TS` runtime globals.
2.  **Mirror Filesystem**: Recursively scan the `out/` directory and create mock `ModuleScript` instances in the fake DataModel so `WaitForChild` calls in compiled code resolve correctly.
3.  **Hook `require`**: Intercept `require` calls to lazy-load code from disk when the mock `ModuleScript` instances are accessed.
4.  **Shim TestEz Syntax**: (Optional) Wrap `expect` to support traditional `expect(a).to.equal(b)` syntax alongside Jest's `expect(a).toBe(b)`.

### 3. Running Tests
Add the test script to `package.json`:
```json
"scripts": {
  "test": "lune run lune/jest"
}
```

Run your tests via:
```bash
npm test
```

### 4. Writing Tests
Write tests in `src` with the `.spec.ts` extension.
```typescript
/// <reference types="@rbxts/testez/globals" />

import { SharedUtils } from "./utils";

export = () => {
    describe("SharedUtils", () => {
        test("add", () => {
            expect(SharedUtils.add(1, 2)).to.equal(3);
        });
    });
};
```
*Note: The test runner automatically discovers and executes all `.spec` modules.*
