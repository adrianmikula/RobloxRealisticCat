import { CatData, RelationshipData, RelationshipTier, InteractionHistoryItem } from "shared/cat-types";
import { CatProfileData } from "shared/cat-profile-data";

export class RelationshipManager {
    private static playerRelationships = new Map<number, Map<string, RelationshipData>>();

    public static GetRelationship(player: Player, catId: string): RelationshipData {
        const userId = player.UserId;

        if (!this.playerRelationships.has(userId)) {
            this.playerRelationships.set(userId, new Map<string, RelationshipData>());
        }

        const playerMap = this.playerRelationships.get(userId)!;

        if (!playerMap.has(catId)) {
            playerMap.set(catId, this.CreateNewRelationship());
        }

        return playerMap.get(catId)!;
    }

    public static UpdateRelationship(player: Player, catId: string, change: number): RelationshipData {
        const relationship = this.GetRelationship(player, catId);

        relationship.trustLevel = math.clamp(relationship.trustLevel + change, 0, 1);
        relationship.lastInteraction = os.time();
        relationship.relationshipScore = this.CalculateRelationshipScore(relationship);
        relationship.relationshipTier = this.GetRelationshipTier(relationship);

        return relationship;
    }

    private static CreateNewRelationship(): RelationshipData {
        return {
            trustLevel: 0.5,
            relationshipScore: 0,
            interactionHistory: [],
            lastInteraction: 0,
            firstInteraction: os.time(),
            favoriteActivities: [],
            relationshipTier: "Neutral",
        };
    }

    public static CalculateRelationshipScore(relationship: RelationshipData): number {
        let score = 0;

        // Base score from trust level (0-50 points)
        score += relationship.trustLevel * 50;

        // Bonus for interaction frequency (0-30 points)
        const interactionCount = relationship.interactionHistory.size();
        const frequencyBonus = math.min(interactionCount * 0.5, 30);
        score += frequencyBonus;

        // Bonus for recent interactions (0-20 points)
        const timeSinceLast = os.time() - relationship.lastInteraction;
        const recencyBonus = math.max(0, 20 - timeSinceLast / 3600); // decays over hours
        score += recencyBonus;

        return math.min(score, 100);
    }

    public static GetRelationshipTier(relationship: RelationshipData): RelationshipTier {
        const score = relationship.relationshipScore;

        if (score >= 90) return "Best Friends";
        if (score >= 75) return "Close Friends";
        if (score >= 60) return "Friends";
        if (score >= 40) return "Acquaintances";
        if (score >= 20) return "Neutral";
        return "Strangers";
    }

    public static AddInteractionToHistory(player: Player, catId: string, item: InteractionHistoryItem) {
        const relationship = this.GetRelationship(player, catId);
        relationship.interactionHistory.push(item);

        if (relationship.interactionHistory.size() > 50) {
            relationship.interactionHistory.shift();
        }

        if (item.outcome === "positive") {
            this.UpdateFavoriteActivities(relationship);
        }
    }

    private static UpdateFavoriteActivities(relationship: RelationshipData) {
        const activityCounts = new Map<string, number>();

        for (const item of relationship.interactionHistory) {
            if (item.outcome === "positive") {
                const count = activityCounts.get(item.type) || 0;
                activityCounts.set(item.type, count + 1);
            }
        }

        const favorites: { activity: string; count: number }[] = [];
        activityCounts.forEach((count, activity) => {
            favorites.push({ activity, count });
        });

        favorites.sort((a, b) => b.count > a.count);

        // Manual slice since slice() might be missing
        const topFavorites: string[] = [];
        for (let i = 0; i < math.min(3, favorites.size()); i++) {
            topFavorites.push(favorites[i].activity);
        }
        relationship.favoriteActivities = topFavorites;
    }
}
