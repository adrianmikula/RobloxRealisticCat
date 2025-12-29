export interface Personality {
    curiosity: number;
    friendliness: number;
    aggression: number;
    playfulness: number;
    independence: number;
    shyness: number;
}

export interface Preferences {
    favoriteFoods: string[];
    favoriteToys: string[];
    dislikedItems: string[];
    preferredRestingSpots: string[];
}

export interface BehaviorConfig {
    sleepSchedule: [number, number];
    explorationRange: number;
    socialDistance: number;
    patrolFrequency: number;
    groomingFrequency: number;
}

export interface PhysicalConfig {
    movementSpeed: number;
    jumpHeight: number;
    climbAbility: number;
    maxEnergy: number;
    maxHunger: number;
}

export interface CatProfile {
    personality: Personality;
    preferences: Preferences;
    behavior: BehaviorConfig;
    physical: PhysicalConfig;
    breed: string;
}

export type MoodType = "Happy" | "Curious" | "Annoyed" | "Hungry" | "Tired" | "Afraid" | "Playful";

export interface MoodState {
    currentMood: MoodType;
    moodIntensity: number;
    moodDuration: number;
    moodTriggers: string[];
}

export interface PhysicalState {
    hunger: number;
    energy: number;
    health: number;
    grooming: number;
}

export interface BehaviorState {
    currentAction: string;
    targetPosition?: Vector3;
    currentPath: Vector3[];
    isMoving: boolean;
    isInteracting: boolean;
    actionData?: unknown;
}

export type RelationshipTier = "Strangers" | "Neutral" | "Acquaintances" | "Friends" | "Close Friends" | "Best Friends";

export interface InteractionHistoryItem {
    type: string;
    timestamp: number;
    outcome: "positive" | "negative";
    effects: Record<string, unknown>;
}

export interface RelationshipData {
    trustLevel: number;
    relationshipScore: number;
    interactionHistory: InteractionHistoryItem[];
    lastInteraction: number;
    firstInteraction: number;
    favoriteActivities: string[];
    relationshipTier: RelationshipTier;
}

export interface SocialState {
    playerRelationships: Map<number, RelationshipData>;
    catRelationships: Map<string, number>;
    lastInteraction: number;
}

export interface Timers {
    lastUpdate: number;
    nextActionTime: number;
    moodChangeTime: number;
}

export interface CatData {
    id: string;
    profile: CatProfile;
    currentState: {
        position: Vector3;
        rotation: Vector3;
        velocity: Vector3;
    };
    moodState: MoodState;
    physicalState: PhysicalState;
    behaviorState: BehaviorState;
    socialState: SocialState;
    timers: Timers;
}

export interface MoodEffect {
    movementModifier: number;
    duration: [number, number];
    interactionChance?: number;
    playfulnessBoost?: number;
    explorationBoost?: number;
    attentionSpan?: number;
    aggressionBoost?: number;
    foodSeekingBoost?: number;
    patienceReduction?: number;
    restSeekingBoost?: number;
    activityReduction?: number;
    hidingBoost?: number;
    fleeChance?: number;
    energyConsumption?: number;
}

export interface PlayerSettings {
    selectedTool: string;
    autoInteract: boolean;
    catNotifications: boolean;
    visualPreferences: {
        showMoodIndicators: boolean;
        showRelationshipBars: boolean;
        animationQuality: string;
    };
}

export interface PlayerData {
    player: Player;
    currentTool: string;
    lastInteractionTime: number;
    nearbyCats: string[];
    toolCooldowns: Map<string, number>;
    lastToolChange?: number;
}

export interface ToolConfig {
    name: string;
    type: string;
    interactionType: string;
    effectiveness: number;
    cooldown: number;
}

export interface InteractionEffect {
    relationshipChange: number;
    moodEffect: MoodType;
    energyCost?: number;
    successChance: number;
    hungerReduction?: number;
}

export interface AIData {
    lastDecisionTime: number;
    currentGoal?: string;
    memory: Map<string, unknown>;
    behaviorTree: BehaviorTree;
}

export interface BehaviorTree {
    root: string;
    nodes: Map<string, BTNode>;
}

export interface BTNode {
    type: "selector" | "sequence" | "action";
    children?: string[];
    action?: string;
}
