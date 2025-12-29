import { CatManager } from "./cat-manager";
import { RelationshipManager } from "./relationship-manager";
import { CatProfileData, INTERACTION_TYPES } from "shared/cat-profile-data";
import { CatData, InteractionEffect } from "shared/cat-types";

export class InteractionHandler {
    private static interactionCooldowns = new Map<string, number>();

    public static HandleInteraction(player: Player, catId: string, interactionType: string): { success: boolean; message: string; interactionType?: string } {
        if (this.IsOnCooldown(player, catId, interactionType)) {
            return { success: false, message: "Interaction on cooldown" };
        }

        const catData = CatManager.GetCat(catId);
        if (!catData) {
            return { success: false, message: "Cat not found" };
        }

        const effects = INTERACTION_TYPES[interactionType];
        if (!effects) {
            return { success: false, message: "Invalid interaction type" };
        }

        const successChance = this.CalculateSuccessChance(player, catId, interactionType, catData);
        const success = math.random() <= successChance;

        const result = {
            success,
            interactionType,
            message: success ? "Interaction successful!" : "Interaction failed - cat was not interested",
        };

        if (success) {
            this.ApplySuccessfulInteraction(player, catId, interactionType, catData, effects);
        } else {
            this.ApplyFailedInteraction(player, catId);
        }

        this.SetCooldown(player, catId, interactionType);
        return result;
    }

    private static CalculateSuccessChance(player: Player, catId: string, interactionType: string, catData: CatData): number {
        const effects = INTERACTION_TYPES[interactionType];
        const baseChance = effects?.successChance || 0.5;

        const relationship = RelationshipManager.GetRelationship(player, catId);
        const relationshipModifier = 0.5 + relationship.trustLevel;

        const moodModifier = CatProfileData.GetMoodEffects(catData.moodState.currentMood).interactionChance || 1.0;

        let personalityModifier = 1.0;
        const personality = catData.profile.personality;

        if (interactionType === "Pet") {
            personalityModifier = personality.friendliness;
        } else if (interactionType === "Play") {
            personalityModifier = personality.playfulness;
        }

        const successChance = baseChance * relationshipModifier * moodModifier * personalityModifier;
        return math.clamp(successChance, 0.1, 0.95);
    }

    private static ApplySuccessfulInteraction(
        player: Player,
        catId: string,
        interactionType: string,
        catData: CatData,
        effects: InteractionEffect,
    ) {
        const relChange = effects.relationshipChange || 0.1;
        RelationshipManager.UpdateRelationship(player, catId, relChange);

        if (effects.moodEffect) {
            CatManager.UpdateCatMood(catId, effects.moodEffect, 0.7);
        }

        if (effects.hungerReduction !== undefined) {
            CatManager.UpdateCatPhysical(catId, { hunger: -effects.hungerReduction });
        }

        if (effects.energyCost !== undefined) {
            CatManager.UpdateCatPhysical(catId, { energy: -effects.energyCost });
        }

        RelationshipManager.AddInteractionToHistory(player, catId, {
            type: interactionType,
            timestamp: os.time(),
            outcome: "positive",
            effects: {},
        });
    }

    private static ApplyFailedInteraction(player: Player, catId: string) {
        RelationshipManager.UpdateRelationship(player, catId, -0.05);

        if (math.random() < 0.3) {
            CatManager.UpdateCatMood(catId, "Annoyed", 0.4);
        }

        RelationshipManager.AddInteractionToHistory(player, catId, {
            type: "failed_interaction",
            timestamp: os.time(),
            outcome: "negative",
            effects: {},
        });
    }

    private static IsOnCooldown(player: Player, catId: string, interactionType: string): boolean {
        const key = `${player.UserId}_${catId}_${interactionType}`;
        const cooldownEnd = this.interactionCooldowns.get(key);
        return cooldownEnd !== undefined && os.time() < cooldownEnd;
    }

    private static SetCooldown(player: Player, catId: string, interactionType: string) {
        const key = `${player.UserId}_${catId}_${interactionType}`;
        this.interactionCooldowns.set(key, os.time() + 2);
    }
}
