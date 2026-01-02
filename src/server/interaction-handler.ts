import { CatManager } from "./cat-manager";
import { RelationshipManager } from "./relationship-manager";
import { CatProfileData } from "shared/cat-profile-data";
import { CatAI } from "./cat-ai";
import { Players } from "@rbxts/services";
import { INTERACTION_TYPES } from "shared/config/behavior-config";
import { CatData, InteractionEffect } from "shared/cat-types";

export class InteractionHandler {
    private static interactionCooldowns = new Map<string, number>();

    public static HandleInteraction(
        player: Player,
        catId: string,
        interactionType: string,
        interactionData?: unknown,
    ): { success: boolean; message: string; interactionType?: string } {
        if (this.IsOnCooldown(player, catId, interactionType)) {
            return { success: false, message: "Interaction on cooldown" };
        }

        const catData = CatManager.GetCat(catId);
        if (!catData) {
            return { success: false, message: "Cat not found" };
        }

        const effects = INTERACTION_TYPES[interactionType];

        // Special case: Release if already held by this player
        if (interactionType === "Hold" && catData.behaviorState.heldByPlayerId === player.UserId) {
            this.ApplyRelease(catId, catData);
            return { success: true, message: "Released cat", interactionType: "Hold" };
        }

        if (catData.behaviorState.heldByPlayerId !== undefined) {
            return { success: false, message: "Cat is already being held" };
        }

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
            this.ApplyFailedInteraction(player, catId, catData);
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
        } else if (interactionType === "Hold") {
            personalityModifier = (personality.friendliness + (1 - personality.shyness)) / 2;
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
        const relationship = RelationshipManager.UpdateRelationship(player, catId, relChange);

        // Sync relationship to catData so client can access it
        if (!catData.socialState.playerRelationships.has(player.UserId)) {
            catData.socialState.playerRelationships.set(player.UserId, relationship);
        } else {
            // Update existing relationship
            const existingRel = catData.socialState.playerRelationships.get(player.UserId)!;
            existingRel.trustLevel = relationship.trustLevel;
            existingRel.relationshipScore = relationship.relationshipScore;
            existingRel.relationshipTier = relationship.relationshipTier;
            existingRel.lastInteraction = relationship.lastInteraction;
        }

        if (effects.moodEffect) {
            CatManager.UpdateCatMood(catId, effects.moodEffect, 0.7);
        }

        if (effects.hungerReduction !== undefined) {
            CatManager.UpdateCatPhysical(catId, { hunger: -effects.hungerReduction });
        }

        if (effects.energyCost !== undefined) {
            CatManager.UpdateCatPhysical(catId, { energy: -effects.energyCost });
        }

        if (interactionType === "Hold") {
            catData.behaviorState.heldByPlayerId = player.UserId;
            catData.behaviorState.isMoving = false;
        }

        // Special reaction for Pet interaction: cat looks at player and purrs, then stays near them
        if (interactionType === "Pet") {
            const char = player.Character;
            const hrp = char?.FindFirstChild("HumanoidRootPart") as Part;
            if (hrp) {
                // Store that this player recently petted the cat
                const aiData = CatAI.GetAIData(catId);
                if (aiData) {
                    aiData.memory.set("LastPettedBy", player.UserId);
                    aiData.memory.set("LastPettedTime", os.time());
                    aiData.memory.set("StayNearPlayerUntil", os.time() + 15); // Stay near for 15 seconds
                }

                // Initial purr reaction (3 seconds)
                catData.behaviorState.currentAction = "Purr";
                catData.behaviorState.targetPosition = hrp.Position;
                catData.behaviorState.isMoving = false;
                catData.behaviorState.actionData = { reactingToPlayerId: player.UserId };
                
                // After purring, transition to staying near player
                task.delay(3, () => {
                    const updatedCatData = CatManager.GetCat(catId);
                    const updatedAiData = CatAI.GetAIData(catId);
                    if (updatedCatData && updatedAiData) {
                        const stayUntil = updatedAiData.memory.get("StayNearPlayerUntil") as number | undefined;
                        const pettedPlayerId = updatedAiData.memory.get("LastPettedBy") as number | undefined;
                        
                        // If still within the stay-near window, transition to Follow/LookAt
                        if (stayUntil && os.time() < stayUntil && pettedPlayerId) {
                            const pettedPlayer = Players.GetPlayerByUserId(pettedPlayerId);
                            if (pettedPlayer?.Character?.PrimaryPart) {
                                updatedCatData.behaviorState.currentAction = "Follow";
                                updatedCatData.behaviorState.targetPosition = pettedPlayer.Character.PrimaryPart.Position;
                                updatedAiData.memory.set("SocialTarget", pettedPlayerId);
                            }
                        } else {
                            // Time window expired, return to normal behavior
                            updatedCatData.behaviorState.currentAction = "Idle";
                            updatedCatData.behaviorState.actionData = undefined;
                        }
                    }
                });

                // Clear the stay-near state after the full duration
                task.delay(15, () => {
                    const updatedCatData = CatManager.GetCat(catId);
                    const updatedAiData = CatAI.GetAIData(catId);
                    if (updatedCatData && updatedAiData) {
                        const stayUntil = updatedAiData.memory.get("StayNearPlayerUntil") as number | undefined;
                        // Only clear if this is still the same petting session
                        if (stayUntil && os.time() >= stayUntil) {
                            updatedAiData.memory.delete("LastPettedBy");
                            updatedAiData.memory.delete("LastPettedTime");
                            updatedAiData.memory.delete("StayNearPlayerUntil");
                            
                            // If cat is still following/looking at this player, transition to idle
                            if (updatedCatData.behaviorState.currentAction === "Follow" || 
                                updatedCatData.behaviorState.currentAction === "LookAt") {
                                const currentTarget = updatedAiData.memory.get("SocialTarget") as number | undefined;
                                if (currentTarget === player.UserId) {
                                    updatedCatData.behaviorState.currentAction = "Idle";
                                    updatedAiData.memory.delete("SocialTarget");
                                }
                            }
                        }
                    }
                });
            }
        }

        RelationshipManager.AddInteractionToHistory(player, catId, {
            type: interactionType,
            timestamp: os.time(),
            outcome: "positive",
            effects: {},
        });
    }

    private static ApplyFailedInteraction(player: Player, catId: string, catData: CatData) {
        const relationship = RelationshipManager.UpdateRelationship(player, catId, -0.05);

        // Sync relationship to catData so client can access it
        if (!catData.socialState.playerRelationships.has(player.UserId)) {
            catData.socialState.playerRelationships.set(player.UserId, relationship);
        } else {
            // Update existing relationship
            const existingRel = catData.socialState.playerRelationships.get(player.UserId)!;
            existingRel.trustLevel = relationship.trustLevel;
            existingRel.relationshipScore = relationship.relationshipScore;
            existingRel.relationshipTier = relationship.relationshipTier;
            existingRel.lastInteraction = relationship.lastInteraction;
        }

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

    private static ApplyRelease(catId: string, catData: CatData) {
        catData.behaviorState.heldByPlayerId = undefined;
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

    // For testing: Clear cooldown for a specific interaction
    public static ClearCooldown(player: Player, catId: string, interactionType: string): void {
        const key = `${player.UserId}_${catId}_${interactionType}`;
        this.interactionCooldowns.delete(key);
    }
}
