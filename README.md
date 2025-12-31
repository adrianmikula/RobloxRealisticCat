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

### Directory Overview

```
RobloxRealisticCat/
├── src/                          # TypeScript source code
│   ├── client/                   # Client-side controllers (→ StarterPlayerScripts.TS)
│   │   ├── main.client.ts        # Client entry point, initializes Knit and controllers
│   │   ├── cat-controller.ts     # Main cat state management and synchronization
│   │   ├── cat-renderer.ts       # Cat visual rendering, model spawning, mood indicators
│   │   ├── interaction-controller.ts  # Proximity prompts and player-cat interactions
│   │   ├── animation-handler.ts  # Animation playback and blending
│   │   ├── ui-controller.ts      # UI management and notifications
│   │   └── cat-spawn-test.client.ts  # Testing utilities
│   │
│   ├── server/                   # Server-side services (→ ServerScriptService.TS)
│   │   ├── main.server.ts        # Server entry point, initializes Knit and services
│   │   ├── cat-service.ts        # Main service orchestrating all cat systems
│   │   ├── cat-manager.ts        # Cat lifecycle, creation, removal, state management
│   │   ├── cat-ai.ts             # AI decision making, behavior trees, pathfinding
│   │   ├── interaction-handler.ts    # Validates and processes player interactions
│   │   ├── relationship-manager.ts   # Player-cat relationship tracking and history
│   │   ├── player-manager.ts     # Player tool management and session handling
│   │   └── __tests__/            # Server-side unit tests
│   │       ├── cat-ai.spec.ts
│   │       ├── cat-manager.spec.ts
│   │       ├── cat-service.spec.ts
│   │       ├── interaction-handler.spec.ts
│   │       └── ...
│   │
│   ├── shared/                   # Shared code (→ ReplicatedStorage.TS)
│   │   ├── cat-types.ts          # TypeScript interfaces and type definitions
│   │   ├── cat-profile-data.ts   # Cat personality configs, mood effects, interactions
│   │   ├── math-utils.ts         # Shared mathematical utilities
│   │   └── __tests__/            # Shared unit tests
│   │
│   └── globals.d.ts              # TypeScript global type definitions
│
├── out/                          # Transpiled Luau output (gitignored, managed by Rojo)
│   ├── client/                   # Compiled client code
│   ├── server/                   # Compiled server code
│   └── shared/                   # Compiled shared code
│
├── docs/                         # Project documentation
│   ├── codebase/                 # Architecture and technical docs
│   ├── requirements/             # Gameplay requirements and design docs
│   ├── tasks/                    # Roadmap and status tracking
│   └── testing/                  # Testing guides and strategies
│
├── lune/                         # Lune test runner configuration
├── modules/                       # External modules (TestEZ)
├── Packages/                     # Wally dependencies (Knit, Signal, etc.)
├── DevPackages/                  # Development dependencies (Jest)
│
├── package.json                  # npm dependencies and scripts
├── tsconfig.json                 # TypeScript configuration
├── default.project.json          # Rojo project configuration
├── wally.toml                    # Wally dependency configuration
└── README.md                     # This file
```

### Key Components

#### 🖥️ Server-Side (`src/server/`)

**Core Services:**
- **`cat-service.ts`**: Main orchestrator service using Knit framework
  - Manages AI update loop (0.1s tick, 0.2s sync)
  - Handles cat creation/removal
  - Broadcasts state updates to clients via RemoteSignals
  - Coordinates all cat-related subsystems

- **`cat-manager.ts`**: Cat lifecycle and state management
  - Creates/removes cat instances
  - Manages cat data structures (position, mood, physical state)
  - Updates cat physical properties (hunger, energy, health)

- **`cat-ai.ts`**: Intelligent behavior system
  - Decision-making based on personality and mood
  - Behavior tree execution
  - State decay (hunger increases, energy decreases)
  - Action execution (Explore, SeekFood, Rest, etc.)

- **`interaction-handler.ts`**: Player interaction processing
  - Validates interaction requests
  - Calculates success chances based on relationship/mood/personality
  - Applies interaction effects (mood changes, relationship updates)
  - Handles special cases (holding/releasing cats)

- **`relationship-manager.ts`**: Relationship tracking
  - Manages player-cat trust levels
  - Tracks interaction history
  - Calculates relationship tiers (Strangers → Best Friends)

- **`player-manager.ts`**: Player session management
  - Handles player join/leave events
  - Manages player tools and cooldowns

#### 💻 Client-Side (`src/client/`)

**Core Controllers:**
- **`cat-controller.ts`**: Client-side cat state synchronization
  - Listens for server state updates
  - Coordinates rendering and interaction systems
  - Handles performance culling for distant cats

- **`cat-renderer.ts`**: Visual representation
  - Spawns cat models from templates
  - Updates cat positions and animations
  - Creates mood indicators (BillboardGui)
  - Handles holding state (welds cat to player)

- **`interaction-controller.ts`**: Player interaction UI
  - Creates ProximityPrompts for interactions (Pet, Hold, Feed)
  - Dynamically updates prompts based on cat state
  - Shows visual feedback for interactions
  - Manages prompt lifecycle (creation, updates, cleanup)

- **`animation-handler.ts`**: Animation management
  - Plays cat animations (Idle, Walk, Meow, etc.)
  - Handles animation blending and transitions

- **`ui-controller.ts`**: UI management
  - Handles notifications and UI updates

#### 🔄 Shared (`src/shared/`)

**Type Definitions:**
- **`cat-types.ts`**: Complete TypeScript type system
  - `CatData`: Full cat state structure
  - `Personality`: Cat personality traits
  - `MoodState`: Current mood and effects
  - `RelationshipData`: Player-cat relationship info
  - `InteractionEffect`: Interaction outcome definitions

- **`cat-profile-data.ts`**: Configuration data
  - Personality types (Friendly, Independent, Calico, Siamese)
  - Mood effects and modifiers
  - Interaction type definitions (Pet, Feed, Hold)
  - Success chance calculations

- **`math-utils.ts`**: Shared utilities
  - Mathematical helper functions used by both client and server

### 🔄 Data Flow

```
Player Action
    ↓
[Client] interaction-controller.ts
    ↓ (Remote call)
[Server] cat-service.ts → interaction-handler.ts
    ↓ (Validates & processes)
[Server] relationship-manager.ts (updates relationship)
[Server] cat-manager.ts (updates cat state)
[Server] cat-ai.ts (may trigger behavior changes)
    ↓ (RemoteSignal broadcast)
[Client] cat-controller.ts → cat-renderer.ts
    ↓
Visual Update (animation, mood indicator, position)
```

### 🏗️ Architecture Patterns

1. **Knit Framework**: Service/Controller pattern for client-server communication
2. **Component-Based**: Modular design with clear separation of concerns
3. **Event-Driven**: Real-time updates via RemoteSignals
4. **Configuration-Driven**: Behavior defined in data files, not hardcoded
5. **Type-Safe**: Full TypeScript coverage with shared type definitions

### 📊 State Management

**Cat State Structure:**
- `currentState`: Position, rotation, velocity
- `moodState`: Current mood, intensity, duration, triggers
- `physicalState`: Hunger, energy, health, grooming
- `behaviorState`: Current action, target position, movement flags
- `socialState`: Player relationships, cat relationships, last interaction
- `profile`: Personality traits, preferences, behavior config, physical config

**Update Frequency:**
- AI decisions: Every 2-5 seconds (based on personality)
- State sync to clients: Every 0.2 seconds
- Visual updates: Continuous (client-side)

## 📖 Documentation Reference

- `docs/requirements`: Gameplay behavior and feature requirements.
- `docs/development`: Coding tips and common mistakes.
- `docs/codebase`: Architectural details and module interaction.
- `docs/standards`: Coding standards and vbest practices to follow.
- `docs/tasks`: Current status and roadmap.
- `docs/testing`: How to design and implement tests for the project.