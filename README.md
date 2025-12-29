# Roblox Realistic Cat (TypeScript Port)

A realistic cat simulation game for Roblox, ported to TypeScript with a focus on robust AI, relationship systems, and CLI-based automated testing.

## 🛠 Prerequisites

Ensure you have the following tools installed and available in your PATH:

- **Node.js** (v16+) & **npm**
- **roblox-ts**: `npm i -g roblox-ts`
- **Lune**: [Lune releases](https://github.com/lune-org/lune/releases) (For running tests)
- **Rojo CLI**: `cargo install rojo` (or via .exe/bin)
- **Wally**: [Wally releases](https://github.com/UpliftGames/wally/releases) (For dependency management)

## 🚀 Installation

1.  **Clone the repository**.
2.  **Install npm dependencies**:
    ```bash
    npm install
    ```
3.  **Install Wally dependencies**:
    ```bash
    npm run wally:install
    ```

## 💻 Development Workflow

To have a smooth development experience, keep two terminal windows open:

### 1. Transpilation (TypeScript to Luau)
This monitors your `src/` directory and compiles changes to `out/` in real-time.
```bash
npm run watch
```

### 2. Studio Sync (Rojo)
This syncs the compiled Luau code into Roblox Studio.
```bash
npm run rojo:serve
```
*In Roblox Studio, open the Rojo plugin and click **Connect**.*

## 🧪 Testing

We use a custom CLI testing environment powered by **Lune** and **@rbxts/jest**. This allows for extremely fast iteration without opening Roblox Studio.

Run all unit tests:
```bash
npm test
```

Tests are located in `**/__tests__/*.spec.ts` files. The suite currently covers:
- Math Utilities
- Cat State Management
- Relationship Systems
- Player/Tool Management
- AI Decision Making & State Decay

## 📁 Project Structure

- `src/shared`: Shared types and utilities (maps to `ReplicatedStorage.TS`)
- `src/server`: Server-side services and logic (maps to `ServerScriptService.TS`)
- `src/client`: Client-side controllers (maps to `StarterPlayerScripts.TS`)
- `lune/`: Contains the Jest runner configuration and Roblox environment mocks.
- `out/`: Transpilation output (ignored by git, managed by Rojo).

## 📖 Documentation Reference

- `docs/requirements`: Gameplay behavior and feature requirements.
- `docs/codebase`: Architectural details and module interaction.
- `docs/tasks`: Current status and roadmap.
