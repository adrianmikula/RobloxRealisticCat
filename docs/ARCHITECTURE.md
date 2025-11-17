# Realistic Cat AI System - Architecture Documentation

## 🏗️ System Overview

This project implements a highly scalable, realistic NPC cat simulation system using the **SuperbulletFramework-KnitV1** architecture. The system is designed to handle 1-100 NPC cats with unique personalities, moods, and interactions for up to 100 concurrent players.

## 📁 Project Structure

```
src/
├── ServerScriptService/
│   ├── KnitServer.server.lua          # Knit server bootstrap
│   └── ServerSource/
│       └── Server/
│           ├── CatService/            # Server-side cat AI and state management
│           │   ├── Components/
│           │   │   ├── Get().lua      # Data retrieval operations
│           │   │   ├── Set().lua      # State modification operations
│           │   │   └── Others/        # Internal helper modules
│           │   └── init.lua           # Main service orchestration
│           ├── ProfileService.lua     # Data persistence service
│           └── TemplateService/       # Service template
│
├── ReplicatedStorage/
│   ├── ClientSource/
│   │   └── Client/
│   │       ├── CatController/         # Client-side cat rendering and interaction
│   │       │   ├── Components/
│   │       │   │   ├── Get().lua      # Client data access
│   │       │   │   ├── Set().lua      # Client interaction handling
│   │       │   │   └── Others/        # Client helper modules
│   │       │   └── init.lua           # Main controller orchestration
│   │       ├── DataController.lua     # Client data management
│   │       └── TemplateController/    # Controller template
│   │
│   ├── Packages/                      # External libraries
│   │   ├── Knit.lua
│   │   ├── Promise.lua
│   │   └── Signal.lua
│   │
│   └── SharedSource/
│       ├── Datas/                     # Configuration and data definitions
│       │   ├── CatProfileData.lua     # Cat personality and behavior configs
│       │   ├── CatPerformanceConfig.lua
│       │   └── ProfileTemplate.lua    # Player data structure
│       ├── Utilities/                 # Shared utility functions
│       └── Tests/                     # Test files
│
└── StarterPlayer/
    └── StarterPlayerScripts/
        ├── KnitClient.client.lua      # Knit client bootstrap
        └── ProximityPromptClient.lua  # Client proximity handling
```

## 🔧 Core Architecture Components

### 1. Knit Framework Integration
- **Server-Side**: Services handle AI logic, state management, and data persistence
- **Client-Side**: Controllers handle rendering, animations, and user interactions
- **Communication**: Remote events and signals for real-time updates

### 2. Component-Based Architecture
Each service/controller follows the **3-part component structure**:
- **Get()**: Read-only data retrieval operations
- **Set()**: State modification and write operations  
- **Others/**: Internal helper modules and subsystems

### 3. Data Persistence Layer
- **ProfileService**: Manages player-cat relationship data
- **ProfileTemplate**: Defines data structure for persistent storage
- **CatProfileData**: Configuration-driven personality system

## 🐱 Cat System Architecture

### Server-Side (CatService)
```
CatService
├── CatManager          # Cat lifecycle and state management
├── CatAI              # AI decision making and behavior trees
├── RelationshipManager # Player-cat relationship tracking
├── PlayerManager      # Player tool and interaction management
└── InteractionHandler # Interaction validation and processing
```

### Client-Side (CatController)
```
CatController
├── CatRenderer        # Cat model spawning and visual updates
├── AnimationHandler   # Animation control and blending
├── ActionHandler      # Action execution and cleanup
├── MoodVisualizer     # Mood indicators and effects
├── ToolManager        # Player tool management
├── InputHandler       # User input processing
└── PerformanceManager # LOD and optimization
```

## 🔄 Data Flow

### Player Interaction Flow
1. **Input**: Player interacts with cat via client controller
2. **Validation**: Server validates interaction and checks permissions
3. **Processing**: Server processes interaction and updates cat state
4. **Response**: Server sends updated state to all clients
5. **Visual Update**: Client renders updated cat behavior

### AI Update Loop
1. **State Assessment**: AI evaluates current cat state and environment
2. **Decision Making**: Behavior tree selects appropriate action
3. **State Update**: Server updates cat state and physical properties
4. **Client Notification**: Server broadcasts state changes to clients
5. **Visual Rendering**: Client updates animations and visual effects

## 🎯 Key Design Patterns

### 1. Configuration-Driven Behavior
- All cat personalities, moods, and behaviors defined in data files
- No hardcoded logic - easily customizable via JSON-like structures
- Template-based cat creation with personality archetypes

### 2. Event-Driven Architecture
- Real-time state synchronization via Knit signals
- Loose coupling between components
- Efficient network usage with targeted updates

### 3. Performance Optimization
- LOD (Level of Detail) system for distant cats
- AI culling for inactive cats
- Object pooling for cat instances
- Network bandwidth optimization

## 📊 Data Structures

### Cat State Object
```lua
CatState = {
    profile = CatProfile,           -- Personality and preferences
    moodState = MoodState,          -- Current mood and effects
    physicalState = PhysicalState,  -- Hunger, energy, health
    behaviorState = BehaviorState,  -- Current action and targets
    currentState = CurrentState,    -- Position, movement, etc.
    relationships = Relationships   -- Player interaction history
}
```

### Player-Cat Relationship
```lua
Relationship = {
    trustLevel = 0.75,              -- 0-1 scale
    interactionHistory = {},        -- Past interactions
    lastInteraction = timestamp,    -- Last interaction time
    favoriteActivities = {}         -- Preferred interactions
}
```

## 🔧 Technical Implementation Notes

### Initialization Order
1. **KnitInit()**: Service/controller dependencies and component loading
2. **Component .Init()**: Component-specific initialization
3. **KnitStart()**: Event connections and main loops
4. **Component .Start()**: Component-specific startup logic

### Component Communication
- Components communicate through parent service/controller
- No direct component-to-component references
- All external dependencies resolved in Init methods

### Error Handling
- Comprehensive validation for all interactions
- Graceful degradation for performance issues
- Proper cleanup for disconnected players

## 🚀 Scalability Features

- **Horizontal Scaling**: Multiple server instances supported
- **Vertical Optimization**: Efficient memory and CPU usage
- **Network Efficiency**: Minimal data transfer for state updates
- **Performance Tuning**: Configurable update frequencies and LOD levels

This architecture provides a solid foundation for building a realistic, scalable cat AI system that can grow from a simple prototype to a full-featured game system.