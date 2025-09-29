



🐱 Realistic NPC Cat Game - Requirements Documentation
🎯 Core Vision
Create a highly scalable, realistic NPC cat simulation system that can handle 1-100 cats with unique personalities, moods, and interactions for up to 100 concurrent players.

🏗️ Technical Architecture Requirements
Client-Server Model
✅ Already Implemented: Knit framework with ProfileService for data persistence
✅ Existing Foundation: Proper separation of ClientSource/ServerSource
✅ Data Management: ProfileTemplate system for player-cat relationship storage
Scalability Requirements
Target: 1-100 NPC cats per server instance
Concurrent Players: Up to 100 players
Performance: Maintain 60 FPS with 100 cats + 100 players
Memory: Efficient cat state management to prevent memory leaks
🐈 NPC Cat System Requirements
Core Cat Properties
- Unique ID per cat
- Personality Profile (configurable)
- Current Mood State (fluctuating)
- Physical State (hunger, energy, etc.)
- Player Relationship History (persistent)
- Current Behavior/Action
- Location & Movement State
Personality System
Configurable Profiles: JSON-based personality definitions
Traits: Curiosity, Friendliness, Aggression, Playfulness, Independence
Behavior Modifiers: Personality affects interaction responses
No Hardcoding: All traits defined in configuration files
Mood System (Fluctuating)
Primary Moods:
- Happy/Content
- Curious/Exploratory
- Annoyed/Irritated
- Hungry/Thirsty
- Tired/Sleepy
- Afraid/Anxious
- Playful/Energetic
Physical State Management
- Hunger/Thirst levels
- Energy/Fatigue
- Health/Injuries
- Grooming needs
- Age/Life stage
🤝 Player-Cat Interaction System
Relationship Building
Persistent Storage: Saved in player profiles via ProfileService
Gradual Development: Relationships built over multiple interactions
Positive/Negative: Cats remember good/bad interactions
Trust Levels: Cats have varying trust thresholds per player
Interaction Tools
Player Tools:
- Food items (different types)
- Toys (feather wands, balls, etc.)
- Grooming tools
- Medical items
- Comfort items (blankets, beds)
Cat Behaviors & Actions
- Climbing trees/structures
- Eating/drinking
- Sleeping/resting
- Playing with toys
- Grooming themselves
- Social interactions (with other cats)
- Avoiding threats
- Exploring environment
⚙️ Configuration & Customization
Profile-Based Configuration
Cat Profiles: JSON files defining personality archetypes
Mood Triggers: Configurable events that affect mood
Behavior Trees: Scriptable AI decision making
Animation Sets: Different animations per personality type
Easy Customization
No Code Changes: Modify behavior via configuration files
Template System: Use existing TemplateService/TemplateController patterns
Modular Design: Add new cat types without modifying core systems
🎮 Gameplay Features
Real-time Interactions
Responsive AI: Cats react to player actions in real-time
Environmental Awareness: Cats interact with world objects
Multi-cat Dynamics: Cats interact with each other
Player Progression: Unlock better interaction tools
Visual & Audio Feedback
Realistic Animations: Smooth cat movements and behaviors
Sound Effects: Meows, purrs, hisses based on mood
Visual Cues: Mood indicators (tail position, ear movement)
Particle Effects: Eating, playing, resting effects
🔧 Technical Implementation Plan
Existing Systems to Leverage
✅ ProfileService: Player-cat relationship storage
✅ Knit Framework: Client-server communication
✅ Component Architecture: Modular service design
✅ Template Patterns: Scalable system creation
New Systems Required
CatController (Client-side cat behavior rendering)
CatService (Server-side cat AI and state management)
CatProfileSystem (Personality and mood configuration)
InteractionSystem (Player-cat interaction handling)
AnimationSystem (Cat movement and behavior animations)
Performance Optimization
Object Pooling: Reuse cat instances
LOD System: Reduce detail for distant cats
AI Culling: Skip AI updates for inactive cats
Network Optimization: Only send relevant cat data to players
📊 Data Structure Requirements
Cat Profile Template
CatProfile = {
personality = {
curiosity = 0.8,
friendliness = 0.6,
aggression = 0.2,
playfulness = 0.9
},
preferences = {
favoriteFoods = {"tuna", "chicken"},
favoriteToys = {"feather", "ball"},
dislikedItems = {"water", "loud_noises"}
},
behavior = {
sleepSchedule = {22, 6}, -- hours
explorationRange = 50, -- studs
socialDistance = 10 -- studs from other cats
}
}
Player-Cat Relationship Data
PlayerCatRelationships = {
[catId] = {
trustLevel = 0.75,
interactionHistory = {
{type = "feed", timestamp = os.time(), outcome = "positive"},
{type = "play", timestamp = os.time()-3600, outcome = "neutral"}
},
lastInteraction = os.time(),
favoriteActivities = {"petting", "playing"}
}
}
🚀 Development Priority Order
Phase 1: Core Foundation
CatService with basic AI
CatController with movement
Basic personality system
Simple mood states
Phase 2: Interactions
Player tool system
Basic interactions (feed, pet)
Relationship tracking
Mood-based responses
Phase 3: Advanced Features
Complex behaviors (climbing, playing)
Multi-cat interactions
Environmental interactions
Performance optimization
Phase 4: Polish
Advanced animations
Sound design
UI/UX improvements
Bug fixes and optimization
📈 Success Metrics
Performance: Maintain 60 FPS with 100 cats + 100 players
Scalability: Smooth performance from 1 to 100 cats
Realism: Cats feel alive and responsive
Customization: Easy to add new cat profiles
Player Engagement: Meaningful relationship building
This documentation provides a comprehensive roadmap for your realistic NPC cat game. The existing Knit framework and ProfileService provide an excellent foundation for building this scalable system. Would you like me to start implementing any specific part of this system?







