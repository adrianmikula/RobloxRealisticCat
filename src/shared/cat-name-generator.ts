/**
 * Cat Name Generator
 * 
 * Generates names for cats based on their breed and personality.
 */

import { CatProfile } from "./cat-types";

export class CatNameGenerator {
    private static catNames = new Map<string, string>();

    // Name pools for different breeds
    private static breedNames: Record<string, string[]> = {
        "Siamese": ["Luna", "Milo", "Nala", "Simba", "Cleo", "Phoenix", "Sage", "Aria"],
        "Persian": ["Fluffy", "Princess", "Duke", "Bella", "Max", "Sophie", "Oliver", "Chloe"],
        "Tabby": ["Tiger", "Stripe", "Patches", "Rusty", "Ginger", "Shadow", "Smokey", "Bandit"],
        "Calico": ["Callie", "Patches", "Marbles", "Splotch", "Rainbow", "Autumn", "Sunset", "Ember"],
        "Bengal": ["Jungle", "Safari", "Hunter", "Wild", "Storm", "Thunder", "Blaze", "Rocket"],
        "Maine Coon": ["Bear", "Leo", "Atlas", "Titan", "Aurora", "Nova", "Zeus", "Luna"],
        "Default": ["Whiskers", "Mittens", "Boots", "Paws", "Tails", "Felix", "Luna", "Charlie"],
    };

    // Personality-based name modifiers
    private static personalityNames: Record<string, string[]> = {
        friendly: ["Buddy", "Sunny", "Happy", "Joy", "Smiley"],
        independent: ["Solo", "Rogue", "Ace", "Rebel", "Free"],
        playful: ["Bounce", "Ziggy", "Zoom", "Dash", "Spark"],
        curious: ["Explorer", "Scout", "Quest", "Riddle", "Mystery"],
        shy: ["Whisper", "Shadow", "Shy", "Quiet", "Gentle"],
    };

    /**
     * Generate a name for a cat based on its profile.
     * Names are cached per cat ID to ensure consistency.
     */
    public static GenerateName(catId: string, profile: CatProfile): string {
        // Return cached name if already generated
        if (this.catNames.has(catId)) {
            return this.catNames.get(catId)!;
        }

        // Generate name based on breed
        const breedNames = this.breedNames[profile.breed] || this.breedNames["Default"];
        let name = breedNames[math.floor(math.random() * breedNames.size())];

        // Sometimes add personality-based modifier (30% chance)
        if (math.random() < 0.3) {
            const personality = profile.personality;
            
            // Determine dominant personality trait
            let dominantTrait = "friendly";
            let maxValue = personality.friendliness;
            
            if (personality.independence > maxValue) {
                dominantTrait = "independent";
                maxValue = personality.independence;
            }
            if (personality.playfulness > maxValue) {
                dominantTrait = "playful";
                maxValue = personality.playfulness;
            }
            if (personality.curiosity > maxValue) {
                dominantTrait = "curious";
                maxValue = personality.curiosity;
            }
            if (personality.shyness > maxValue) {
                dominantTrait = "shy";
                maxValue = personality.shyness;
            }

            const personalityNames = this.personalityNames[dominantTrait] || [];
            if (personalityNames.size() > 0) {
                // Sometimes use personality name instead (20% chance)
                if (math.random() < 0.2) {
                    name = personalityNames[math.floor(math.random() * personalityNames.size())];
                }
            }
        }

        // Cache the name
        this.catNames.set(catId, name);
        return name;
    }

    /**
     * Get a cat's name (generates if not exists).
     */
    public static GetName(catId: string, profile: CatProfile): string {
        return this.GenerateName(catId, profile);
    }

    /**
     * Clear cached names (useful for testing).
     */
    public static ClearCache(): void {
        this.catNames.clear();
    }
}

