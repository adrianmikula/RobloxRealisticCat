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

export interface SocialState {
    playerRelationships: Map<number, number>;
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

export interface InteractionEffect {
    relationshipChange: number;
    moodEffect: MoodType;
    energyCost?: number;
    successChance: number;
    hungerReduction?: number;
}
