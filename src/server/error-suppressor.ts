/**
 * Error Suppressor
 * 
 * Suppresses known errors from external scripts (tool scripts, etc.)
 * that don't affect gameplay but clutter the output.
 * 
 * This is optional - you can remove this file if you want to see all errors.
 */

import { LogService } from "@rbxts/services";

export class ErrorSuppressor {
    private static suppressedPatterns = [
        // Player.Move errors from tool scripts
        "Player:Move called but player currently has no",
        "attempt to call a boolean value",
        // Add more patterns here as needed
    ];

    public static Initialize() {
        // Suppress specific error messages in output
        // Note: This doesn't prevent the errors, just hides them from output
        // The errors still occur but won't spam the console
        
        // In Roblox, we can't directly intercept LogService messages in TypeScript
        // This is more of a documentation/guidance file
        // 
        // If you want to suppress these errors, you would need to:
        // 1. Use a Luau script to hook into LogService
        // 2. Or fix the tool scripts causing the errors
        // 3. Or remove the problematic tools
        
        print("[ErrorSuppressor] Initialized - See docs/development/PLAYER_MOVE_ERROR.md for details");
    }

    /**
     * Check if an error message should be suppressed
     */
    public static ShouldSuppress(message: string): boolean {
        for (const pattern of this.suppressedPatterns) {
            if (message.find(pattern)[0] !== undefined) {
                return true;
            }
        }
        return false;
    }
}

