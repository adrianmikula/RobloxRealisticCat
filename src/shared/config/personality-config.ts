/**
 * Personality Configuration
 * 
 * Configure cat personality traits, base profiles, and breed definitions.
 * Adjust these values to change how cats behave and interact.
 */

import { CatProfile } from "shared/cat-types";

/**
 * Base profile template used for all cats.
 * Individual personality types override these values.
 */
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

/**
 * Personality type definitions.
 * Each type modifies the base profile with specific traits.
 */
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

/**
 * Cat breed definitions.
 * Each breed maps to a personality type that determines behavior.
 */
export const CAT_BREEDS = [
    { name: "Tabby", profileType: "Friendly" },
    { name: "Black Cat", profileType: "Independent" },
    { name: "Calico", profileType: "Calico" },
    { name: "Siamese", profileType: "Siamese" },
    { name: "Maine Coon", profileType: "Friendly" },
    { name: "Persian", profileType: "Independent" },
    { name: "Bengal", profileType: "Siamese" },
];

