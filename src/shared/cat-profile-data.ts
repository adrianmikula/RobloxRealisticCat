import { CatProfile, MoodEffect, MoodType, InteractionEffect } from "./cat-types";

export const BASE_PROFILE: Omit<CatProfile, "breed"> = {
    personality: {
        curiosity: 0.5,
        friendliness: 0.5,
        aggression: 0.1,
        playfulness: 0.5,
        independence: 0.5,
        shyness: 0.3,
    },
    preferences: {
        favoriteFoods: ["fish", "chicken"],
        favoriteToys: ["ball", "feather"],
        dislikedItems: ["water", "loud_noises"],
        preferredRestingSpots: ["sunny_spots", "high_places"],
    },
    behavior: {
        sleepSchedule: [22, 6],
        explorationRange: 50,
        socialDistance: 10,
        patrolFrequency: 0.3,
        groomingFrequency: 0.7,
    },
    physical: {
        movementSpeed: 16,
        jumpHeight: 8,
        climbAbility: 0.8,
        maxEnergy: 100,
        maxHunger: 100,
    },
};

export const PERSONALITY_TYPES: Record<string, Partial<CatProfile>> = {
    Friendly: {
        personality: {
            friendliness: 0.9,
            curiosity: 0.7,
            playfulness: 0.8,
            aggression: 0.05,
            independence: 0.5,
            shyness: 0.3,
        },
        preferences: {
            favoriteFoods: ["tuna", "salmon"],
            favoriteToys: ["laser_pointer", "string"],
            dislikedItems: ["water", "loud_noises"],
            preferredRestingSpots: ["sunny_spots", "high_places"],
        },
    },
    Independent: {
        personality: {
            independence: 0.9,
            friendliness: 0.3,
            curiosity: 0.6,
            shyness: 0.4,
            aggression: 0.1,
            playfulness: 0.5,
        },
        behavior: {
            socialDistance: 20,
            patrolFrequency: 0.7,
            sleepSchedule: [22, 6],
            explorationRange: 50,
            groomingFrequency: 0.7,
        },
    },
    Calico: {
        personality: {
            friendliness: 0.7,
            curiosity: 0.9,
            playfulness: 0.6,
            aggression: 0.1,
            independence: 0.4,
            shyness: 0.2,
        },
    },
    Siamese: {
        personality: {
            friendliness: 0.8,
            curiosity: 0.5,
            playfulness: 0.9,
            aggression: 0.2,
            independence: 0.3,
            shyness: 0.1,
        },
    },
};

export const CAT_BREEDS = [
    { name: "Tabby", profileType: "Friendly" },
    { name: "Black Cat", profileType: "Independent" },
    { name: "Calico", profileType: "Calico" },
    { name: "Siamese", profileType: "Siamese" },
    { name: "Maine Coon", profileType: "Friendly" },
    { name: "Persian", profileType: "Independent" },
    { name: "Bengal", profileType: "Siamese" },
];

export const MOOD_STATES: Record<MoodType, MoodEffect> = {
    Happy: {
        movementModifier: 1.2,
        interactionChance: 0.8,
        playfulnessBoost: 0.3,
        duration: [300, 600],
    },
    Curious: {
        movementModifier: 1.1,
        explorationBoost: 0.4,
        attentionSpan: 0.7,
        duration: [180, 300],
    },
    Annoyed: {
        movementModifier: 0.8,
        interactionChance: 0.2,
        aggressionBoost: 0.3,
        duration: [120, 240],
    },
    Hungry: {
        movementModifier: 0.9,
        foodSeekingBoost: 0.8,
        patienceReduction: 0.5,
        duration: [300, 600],
    },
    Tired: {
        movementModifier: 0.6,
        restSeekingBoost: 0.9,
        activityReduction: 0.7,
        duration: [240, 480],
    },
    Afraid: {
        movementModifier: 1.3,
        hidingBoost: 0.9,
        fleeChance: 0.8,
        duration: [60, 180],
    },
    Playful: {
        movementModifier: 1.4,
        playfulnessBoost: 0.6,
        energyConsumption: 1.5,
        duration: [180, 360],
    },
};

export const INTERACTION_TYPES: Record<string, InteractionEffect> = {
    Pet: {
        relationshipChange: 0.1,
        moodEffect: "Happy",
        energyCost: 5,
        successChance: 0.8,
    },
    Feed: {
        relationshipChange: 0.3,
        moodEffect: "Happy",
        hungerReduction: 30,
        successChance: 0.95,
    },
    Hold: {
        relationshipChange: 0.05,
        moodEffect: "Happy",
        energyCost: 2,
        successChance: 0.4, // Harder than petting
    },
};

export namespace CatProfileData {
    export function CreateProfile(profileType: string, customSettings?: Partial<CatProfile>): CatProfile {
        const personalityType = PERSONALITY_TYPES[profileType] || {};

        const profile: CatProfile = {
            personality: { ...BASE_PROFILE.personality, ...(personalityType.personality || {}) },
            preferences: { ...BASE_PROFILE.preferences, ...(personalityType.preferences || {}) },
            behavior: { ...BASE_PROFILE.behavior, ...(personalityType.behavior || {}) },
            physical: { ...BASE_PROFILE.physical, ...(personalityType.physical || {}) },
            breed: (customSettings as { breed?: string } | undefined)?.breed || "Default",
        };

        if (customSettings) {
            if (customSettings.personality) {
                for (const [k, v] of pairs(customSettings.personality)) {
                    (profile.personality as unknown as Record<string, number>)[k as string] = v;
                }
            }
            if (customSettings.preferences) {
                for (const [k, v] of pairs(customSettings.preferences)) {
                    (profile.preferences as unknown as Record<string, unknown>)[k as string] = v;
                }
            }
            if (customSettings.behavior) {
                for (const [k, v] of pairs(customSettings.behavior)) {
                    (profile.behavior as unknown as Record<string, unknown>)[k as string] = v;
                }
            }
            if (customSettings.physical) {
                for (const [k, v] of pairs(customSettings.physical)) {
                    (profile.physical as unknown as Record<string, unknown>)[k as string] = v;
                }
            }
        }

        return profile;
    }

    export function GetMoodEffects(moodType: MoodType): MoodEffect {
        return MOOD_STATES[moodType] || MOOD_STATES.Happy;
    }
}
