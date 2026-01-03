/**
 * Behavior Configuration
 * 
 * Configure mood states and interaction effects.
 * Adjust these values to change how cats react to different situations.
 */

import { MoodType, MoodEffect, InteractionEffect } from "shared/cat-types";

/**
 * Mood state definitions and their effects.
 * Each mood modifies cat behavior in different ways.
 */
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

/**
 * Interaction type definitions and their effects.
 * Adjust success chances and relationship changes here.
 */
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
    Play: {
        relationshipChange: 0.2,
        moodEffect: "Playful",
        energyCost: 15,
        successChance: 0.7,
    },
};

