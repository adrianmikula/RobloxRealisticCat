/**
 * Cat Profile Data
 * 
 * This file re-exports configuration from src/config for backwards compatibility.
 * New code should import directly from config files.
 */

import { CatProfile, MoodEffect, MoodType, InteractionEffect } from "./cat-types";
import { BASE_PROFILE as BASE_PROFILE_CONFIG, PERSONALITY_TYPES as PERSONALITY_TYPES_CONFIG, CAT_BREEDS as CAT_BREEDS_CONFIG } from "shared/config/personality-config";
import { MOOD_STATES as MOOD_STATES_CONFIG, INTERACTION_TYPES as INTERACTION_TYPES_CONFIG } from "shared/config/behavior-config";

// Re-export from config files for backwards compatibility
export const BASE_PROFILE = BASE_PROFILE_CONFIG;
export const PERSONALITY_TYPES = PERSONALITY_TYPES_CONFIG;
export const CAT_BREEDS = CAT_BREEDS_CONFIG;
export const MOOD_STATES = MOOD_STATES_CONFIG;
export const INTERACTION_TYPES = INTERACTION_TYPES_CONFIG;

export namespace CatProfileData {
    export function CreateProfile(profileType: string, customSettings?: Partial<CatProfile>): CatProfile {
        const personalityType = PERSONALITY_TYPES_CONFIG[profileType] || {};

        const profile: CatProfile = {
            personality: { ...BASE_PROFILE_CONFIG.personality, ...(personalityType.personality || {}) },
            preferences: { ...BASE_PROFILE_CONFIG.preferences, ...(personalityType.preferences || {}) },
            behavior: { ...BASE_PROFILE_CONFIG.behavior, ...(personalityType.behavior || {}) },
            physical: { ...BASE_PROFILE_CONFIG.physical, ...(personalityType.physical || {}) },
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
        return MOOD_STATES_CONFIG[moodType] || MOOD_STATES_CONFIG.Happy;
    }
}
