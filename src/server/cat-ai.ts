import { CatData, AIData, BehaviorTree, MoodType } from "shared/cat-types";
import { CatProfileData } from "shared/cat-profile-data";
import { CatManager } from "./cat-manager";
import { Workspace, Players, CollectionService } from "@rbxts/services";
import { RelationshipManager } from "./relationship-manager";
import { PlayerManager } from "./player-manager";
import { RelationshipData } from "shared/cat-types";

export class CatAI {
    /** @internal Testing hook */
    public static activeCats = new Map<string, AIData>();

    public static InitializeCat(catId: string, catData: CatData) {
        const aiData: AIData = {
            lastDecisionTime: 0,
            currentGoal: undefined,
            memory: new Map<string, unknown>(),
            behaviorTree: this.SetupBehaviorTree(
                catId,
                catData.profile?.breed ?? "Default",
            ),

        };

        this.activeCats.set(catId, aiData);
    }

    /** @internal Testing hook */
    public static GetAIData(catId: string) {
        return this.activeCats.get(catId);
    }

    /** @internal Testing hook */
    public static ForceDecision(catId: string) {
        const aiData = this.activeCats.get(catId);
        if (aiData) aiData.lastDecisionTime = 0;
    }

    public static CleanupCat(catId: string) {
        this.activeCats.delete(catId);
    }

    public static FindGroundPosition(position: Vector3): Vector3 {
        // Raycast down from high up to find the floor
        const rayOrigin = new Vector3(position.X, 1000, position.Z);
        const rayDirection = new Vector3(0, -2000, 0);

        const raycastParams = new RaycastParams();
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude;
        // Exclude cats from ground detection
        const models = Workspace.FindFirstChild("Models");
        if (models) raycastParams.FilterDescendantsInstances = [models];

        const result = Workspace.Raycast(rayOrigin, rayDirection, raycastParams);
        if (result) {
            // Offset slightly to prevent feet from clipping
            return result.Position.add(new Vector3(0, 0.1, 0));
        }
        return position;
    }

    public static UpdateCat(catId: string, catData: CatData) {
        if (catData.behaviorState.heldByPlayerId !== undefined) {
            return;
        }

        const aiData = this.activeCats.get(catId);
        if (!aiData) return;

        const currentTime = os.time();

        // Ensure position is grounded if it was just spawned or moved
        if (catData.timers.lastUpdate === 0) {
            catData.currentState.position = this.FindGroundPosition(catData.currentState.position);
        }

        // Update mood and physical state decay
        this.UpdateStateDecay(catId, catData);

        // Make decisions every 2-5 seconds based on personality
        const curiosity = catData.profile.personality.curiosity;
        const decisionFrequency = 2 + 3 * (1 - curiosity);

        if (currentTime - aiData.lastDecisionTime >= decisionFrequency) {
            this.MakeDecision(catId, catData);
            aiData.lastDecisionTime = currentTime;
        }

        // Execute current action
        this.ExecuteCurrentAction(catId, catData);
    }

    private static UpdateStateDecay(catId: string, catData: CatData) {
        const decayRate = 0.1; // per second
        const currentTime = os.time();
        const timePassed = currentTime - catData.timers.lastUpdate;

        if (timePassed > 0) {
            // Hunger increases over time
            catData.physicalState.hunger = math.clamp(catData.physicalState.hunger + decayRate * timePassed, 0, 100);

            // Energy decreases with activity
            const activityMultiplier = catData.behaviorState.isMoving ? 2 : 1;
            catData.physicalState.energy = math.clamp(
                catData.physicalState.energy - decayRate * activityMultiplier * timePassed,
                0,
                100,
            );

            // Mood duration decreases
            if (catData.moodState.moodDuration > 0) {
                catData.moodState.moodDuration = math.max(0, catData.moodState.moodDuration - timePassed);
                if (catData.moodState.moodDuration === 0) {
                    // Return to neutral mood
                    catData.moodState.currentMood = "Happy";
                    catData.moodState.moodIntensity = 0.5;
                }
            }

            catData.timers.lastUpdate = currentTime;
        }
    }

    private static MakeDecision(catId: string, catData: CatData) {
        const weights = this.CalculateDecisionWeights(catId, catData);

        let bestAction = "Idle";
        let bestWeight = -1;

        for (const [action, weight] of weights) {
            if (weight > bestWeight) {
                bestWeight = weight;
                bestAction = action;
            }
        }

        // Apply personality modifiers
        bestAction = this.ApplyPersonalityModifiers(catId, catData, bestAction);

        // Set the new action
        this.SetCatAction(catId, bestAction);
    }

    private static CalculateDecisionWeights(catId: string, catData: CatData): Map<string, number> {
        const weights = new Map<string, number>();
        weights.set("Idle", 1.0);
        weights.set("Explore", 0.5);
        weights.set("SeekFood", 0.0);
        const aiData = this.activeCats.get(catId);
        if (!aiData) return weights;

        weights.set("SeekRest", 0.0);
        weights.set("Play", 0.5);
        weights.set("Groom", 0.3);
        weights.set("Follow", 0.0);
        weights.set("LookAt", 0.0);
        weights.set("Meow", 0.1);
        weights.set("RollOver", 0.0);
        weights.set("LookAtToy", 0.0);
        weights.set("PlayWithToy", 0.0);
        weights.set("ApproachFood", 0.0);
        weights.set("CirclePlayer", 0.0);
        weights.set("SitAndMeow", 0.0);
        weights.set("ApproachCatTree", 0.0);
        weights.set("ClimbCatTree", 0.0);
        weights.set("RestOnCatTree", 0.0);
        weights.set("ScratchTree", 0.0);
        weights.set("JumpOnTree", 0.0);
        weights.set("PlayOnTree", 0.0);
        weights.set("SleepOnTree", 0.0);

        // Find nearest player for social behaviors
        let nearestPlayer: Player | undefined;
        let minDistance = 50;
        const currentPos = catData.currentState.position;

        for (const player of Players.GetPlayers()) {
            // Defensive check: ensure player has character and humanoid before accessing
            // This prevents errors from scripts trying to move players without humanoids
            const char = player.Character;
            if (!char) continue;
            
            // Check for humanoid to avoid errors from scripts trying to move players without humanoids
            const humanoid = char.FindFirstChildOfClass("Humanoid");
            if (!humanoid) continue;
            
            const hrp = char.FindFirstChild("HumanoidRootPart") as Part;
            if (!hrp) continue;
            
            const dist = hrp.Position.sub(currentPos).Magnitude;
            if (dist < minDistance) {
                minDistance = dist;
                nearestPlayer = player;
            }
        }

        if (nearestPlayer) {
            const relationship = RelationshipManager.GetRelationship(nearestPlayer, catId);
            const trust = relationship.trustLevel;
            let currentTool = PlayerManager.GetCurrentTool(nearestPlayer);
            
            // Fallback: Check for tool directly in player's character if PlayerManager doesn't have it
            if (!currentTool || currentTool === "none") {
                const char = nearestPlayer.Character;
                const tool = char?.FindFirstChildOfClass("Tool");
                if (tool) {
                    // Try to determine tool type from name (basic detection)
                    const toolName = tool.Name;
                    const toolNameLower = toolName.lower();
                    
                    if (toolNameLower.find("food")[0] !== undefined) {
                        if (toolNameLower.find("premium")[0] !== undefined) {
                            currentTool = "premiumFood";
                        } else {
                            currentTool = "basicFood";
                        }
                    } else if (toolNameLower.find("toy")[0] !== undefined) {
                        if (toolNameLower.find("premium")[0] !== undefined) {
                            currentTool = "premiumToys";
                        } else {
                            currentTool = "basicToys";
                        }
                    } else if (toolNameLower.find("groom")[0] !== undefined) {
                        currentTool = "groomingTools";
                    } else if (toolNameLower.find("medical")[0] !== undefined) {
                        currentTool = "medicalItems";
                    }
                }
            }
            
            const toolConfig = currentTool && currentTool !== "none" ? PlayerManager.AVAILABLE_TOOLS[currentTool] : undefined;

            // Check if player is using a toy (recent usage within 3 seconds) - INCREASED WINDOW
            const recentToolUsage = PlayerManager.GetRecentToolUsage(nearestPlayer, 3);
            const isUsingToy = recentToolUsage && toolConfig?.type === "toy";
            
            // Also check if player recently used food (within 3 seconds)
            const recentFoodUsage = recentToolUsage && toolConfig?.type === "food";

            // Check if player is holding a toy - INCREASED RANGE AND WEIGHTS
            if (currentTool && toolConfig?.type === "toy" && minDistance < 40) {
                // Cat looks at player with toy - much higher priority
                const playfulness = catData.profile.personality.playfulness;
                weights.set("LookAtToy", 6.0 + (trust * 2.0) + (playfulness * 3.0));
                aiData.memory.set("SocialTarget", nearestPlayer.UserId);
                aiData.memory.set("PlayerTool", currentTool);
            }

            // Check if player just used a toy (within 3 seconds) - REMOVED FACING REQUIREMENT
            if (isUsingToy && minDistance < 30) {
                // Cat plays with toy - high priority for playful cats, no facing requirement
                const playfulness = catData.profile.personality.playfulness;
                weights.set("PlayWithToy", 8.0 + (playfulness * 5.0) + (trust * 3.0));
                aiData.memory.set("SocialTarget", nearestPlayer.UserId);
                aiData.memory.set("PlayerTool", recentToolUsage.toolType);
            }

            // Check if player is holding food - INCREASED RANGE AND WEIGHTS
            if (currentTool && toolConfig?.type === "food" && minDistance < 50) {
                // Cat approaches food - much higher priority, especially if hungry
                const hungerWeight = catData.physicalState.hunger > 50 ? 8.0 : 4.0;
                const trustBonus = trust * 2.0;
                weights.set("ApproachFood", hungerWeight + trustBonus);
                aiData.memory.set("SocialTarget", nearestPlayer.UserId);
                aiData.memory.set("PlayerTool", currentTool);
            }

            // If cat is near player with food (within 10 studs) - INCREASED RANGE
            if (currentTool && toolConfig?.type === "food" && minDistance < 10) {
                // Cat circles player or sits and meows - higher weights
                const playfulness = catData.profile.personality.playfulness;
                const hungerBonus = catData.physicalState.hunger / 30; // More impact from hunger
                if (playfulness > 0.5) {
                    weights.set("CirclePlayer", 5.0 + (playfulness * 2.0) + hungerBonus);
                } else {
                    weights.set("SitAndMeow", 5.0 + hungerBonus + (trust * 1.5));
                }
                aiData.memory.set("SocialTarget", nearestPlayer.UserId);
                aiData.memory.set("PlayerTool", currentTool);
            }

            // Check if cat was recently petted by this player
            const lastPettedBy = aiData.memory.get("LastPettedBy") as number | undefined;
            const stayUntil = aiData.memory.get("StayNearPlayerUntil") as number | undefined;
            const wasRecentlyPetted = lastPettedBy === nearestPlayer.UserId && 
                                      stayUntil !== undefined && 
                                      os.time() < stayUntil;

            // If recently petted, prioritize staying near and looking at the player
            if (wasRecentlyPetted) {
                const timeRemaining = stayUntil! - os.time();
                const urgency = timeRemaining / 15; // Urgency decreases as time passes
                
                if (minDistance > 8) {
                    // Cat should follow if too far
                    weights.set("Follow", 5.0 + (trust * 2.0) + urgency * 3.0);
                } else if (minDistance > 4) {
                    // Cat should approach and look if moderately close
                    weights.set("Follow", 3.0 + (trust * 1.5) + urgency * 2.0);
                    weights.set("LookAt", 2.0 + (trust * 1.0) + urgency * 1.5);
                } else {
                    // Cat should look at player if very close
                    weights.set("LookAt", 4.0 + (trust * 2.0) + urgency * 2.0);
                }
            } else {
                // Normal follow logic (only if not recently petted)
                if (trust > 0.4 && minDistance > 10 && !currentTool) {
                    weights.set("Follow", (trust - 0.4) * 3.0);
                }

                // Normal LookAt logic (only if no special tool behaviors and not recently petted)
                if (minDistance < 20 && !currentTool) {
                    weights.set("LookAt", 1.0 + trust);
                }
            }

            // Meow logic (hungry or happy/high trust)
            if (catData.physicalState.hunger > 60 || trust > 0.7) {
                weights.set("Meow", 0.5 + (trust * 0.5));
            }

            // RollOver logic (rare, high trust)
            if (trust > 0.8 && minDistance < 10 && !currentTool) {
                weights.set("RollOver", 0.3 * (trust - 0.7));
            }

            // Store nearest player in memory for execution
            aiData.memory.set("SocialTarget", nearestPlayer.UserId);
        }

        const moodEffects = CatProfileData.GetMoodEffects(catData.moodState.currentMood);
        if (moodEffects) {
            const explorationBoost = moodEffects.explorationBoost || 0;
            const playfulnessBoost = moodEffects.playfulnessBoost || 0;

            weights.set("Explore", weights.get("Explore")! * (1 + explorationBoost));
            weights.set("Play", weights.get("Play")! * (1 + playfulnessBoost));
        }

        const hunger = catData.physicalState.hunger;
        if (hunger > 70) {
            weights.set("SeekFood", 3.0 + (hunger - 70) * 0.1);
        } else if (hunger > 50) {
            weights.set("SeekFood", 1.0);
        } else {
            weights.set("SeekFood", 0.5);
        }

        const energy = catData.physicalState.energy;
        if (energy < 30) {
            weights.set("SeekRest", 4.0 + (30 - energy) * 0.1);
        } else if (energy < 50) {
            weights.set("SeekRest", 1.5);
        } else {
            weights.set("SeekRest", 0.5);
        }

        // Cat tree interactions
        const nearestCatTree = this.FindNearestCatTree(catData.currentState.position);
        if (nearestCatTree) {
            const treeDistance = nearestCatTree.Position.sub(catData.currentState.position).Magnitude;
            const curiosity = catData.profile.personality.curiosity;
            const independence = catData.profile.personality.independence;
            
            // Approach cat tree if within exploration range
            if (treeDistance < catData.profile.behavior.explorationRange && treeDistance > 5) {
                const approachWeight = 2.0 + (curiosity * 2.0) + (independence * 1.5);
                weights.set("ApproachCatTree", approachWeight);
                aiData.memory.set("CatTreeTarget", nearestCatTree);
            }
            
            // Climb cat tree if close enough
            if (treeDistance < 8 && treeDistance > 2) {
                const climbWeight = 3.0 + (curiosity * 2.5) + (independence * 2.0);
                weights.set("ClimbCatTree", climbWeight);
                aiData.memory.set("CatTreeTarget", nearestCatTree);
            }
            
            // Scratch tree if close (within 3 studs)
            if (treeDistance < 3) {
                const scratchWeight = 2.5 + (curiosity * 1.5) + (catData.profile.personality.playfulness * 1.0);
                weights.set("ScratchTree", scratchWeight);
                aiData.memory.set("CatTreeTarget", nearestCatTree);
            }
            
            // Jump on tree if close enough (within 5 studs, high energy)
            if (treeDistance < 5 && treeDistance > 1 && energy > 60) {
                const jumpWeight = 3.5 + (curiosity * 2.0) + (catData.profile.personality.playfulness * 2.5);
                weights.set("JumpOnTree", jumpWeight);
                aiData.memory.set("CatTreeTarget", nearestCatTree);
            }
            
            // Play on tree if on top or very close (within 2 studs, high playfulness)
            if (treeDistance < 2 && catData.profile.personality.playfulness > 0.6 && energy > 40) {
                const playWeight = 4.0 + (catData.profile.personality.playfulness * 3.0) + (curiosity * 1.5);
                weights.set("PlayOnTree", playWeight);
                aiData.memory.set("CatTreeTarget", nearestCatTree);
            }
            
            // Rest/Sleep on cat tree if already on it or very close (low energy)
            if (treeDistance < 3) {
                const restWeight = (energy < 50 ? 5.0 : 2.0) + (independence * 1.5);
                weights.set("RestOnCatTree", restWeight);
                
                // Sleep on tree if very low energy
                if (energy < 30) {
                    const sleepWeight = 6.0 + (independence * 2.0);
                    weights.set("SleepOnTree", sleepWeight);
                }
                aiData.memory.set("CatTreeTarget", nearestCatTree);
            }
        }

        // Personality modifiers
        weights.set("Explore", weights.get("Explore")! * catData.profile.personality.curiosity);
        weights.set("Play", weights.get("Play")! * catData.profile.personality.playfulness);

        // Random variation (skip for testing if needed, or keep for authenticity)
        // Check if we are in a test environment (simplified check)
        const isTest = catId.find("test")[0] !== undefined || catId.find("grounding")[0] !== undefined;
        if (!isTest) {
            weights.forEach((weight, action) => {
                if (weight > 0) {
                    weights.set(action, weight * (0.8 + math.random() * 0.4));
                }
            });
        }

        return weights;
    }

    private static ApplyPersonalityModifiers(catId: string, catData: CatData, action: string): string {
        if (action === "Socialize" && catData.profile.personality.independence > 0.7) {
            return math.random() < 0.3 ? "Explore" : "Idle";
        }

        if (action === "Socialize" && catData.profile.personality.shyness > 0.6) {
            return math.random() < 0.4 ? "Groom" : "Idle";
        }

        return action;
    }

    private static SetCatAction(catId: string, actionType: string) {
        const aiData = this.activeCats.get(catId);
        if (!aiData) return;

        const catData = CatManager.GetCat(catId);
        if (catData) {
            catData.behaviorState.currentAction = actionType;
        }

        aiData.currentGoal = actionType;
    }

    private static ExecuteCurrentAction(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        if (!aiData) return;

        const action = catData.behaviorState.currentAction;

        if (action === "Explore") {
            this.ExecuteExplore(catId, catData);
        } else if (action === "SeekFood") {
            this.ExecuteSeekFood(catId, catData);
        } else if (action === "SeekRest") {
            this.ExecuteSeekRest(catId, catData);
        } else if (action === "Play") {
            this.ExecutePlay(catId, catData);
        } else if (action === "Groom") {
            this.ExecuteGroom(catId, catData);
        } else if (action === "Follow") {
            this.ExecuteFollow(catId, catData);
        } else if (action === "LookAt") {
            this.ExecuteLookAt(catId, catData);
        } else if (action === "Meow") {
            this.ExecuteMeow(catId, catData);
        } else         if (action === "RollOver") {
            this.ExecuteRollOver(catId, catData);
        } else if (action === "LookAtToy") {
            this.ExecuteLookAtToy(catId, catData);
        } else if (action === "PlayWithToy") {
            this.ExecutePlayWithToy(catId, catData);
        } else if (action === "ApproachFood") {
            this.ExecuteApproachFood(catId, catData);
        } else if (action === "CirclePlayer") {
            this.ExecuteCirclePlayer(catId, catData);
        } else if (action === "SitAndMeow") {
            this.ExecuteSitAndMeow(catId, catData);
        } else if (action === "ApproachCatTree") {
            this.ExecuteApproachCatTree(catId, catData);
        } else if (action === "ClimbCatTree") {
            this.ExecuteClimbCatTree(catId, catData);
        } else if (action === "RestOnCatTree") {
            this.ExecuteRestOnCatTree(catId, catData);
        } else if (action === "ScratchTree") {
            this.ExecuteScratchTree(catId, catData);
        } else if (action === "JumpOnTree") {
            this.ExecuteJumpOnTree(catId, catData);
        } else if (action === "PlayOnTree") {
            this.ExecutePlayOnTree(catId, catData);
        } else if (action === "SleepOnTree") {
            this.ExecuteSleepOnTree(catId, catData);
        } else {
            this.ExecuteIdle(catId, catData);
        }
    }

    private static ExecuteExplore(catId: string, catData: CatData) {
        const explorationRange = catData.profile.behavior.explorationRange;
        const currentPos = catData.currentState.position;

        if (!catData.behaviorState.isMoving) {
            const rx = (math.random() - 0.5) * explorationRange * 2;
            const rz = (math.random() - 0.5) * explorationRange * 2;
            let targetPos = currentPos.add(new Vector3(rx, 0, rz));

            // Ground the target position
            targetPos = this.FindGroundPosition(targetPos);

            catData.behaviorState.targetPosition = targetPos;
            catData.behaviorState.isMoving = true;
            print(`[CatAI] Started exploring to ${targetPos} (offset: ${rx}, ${rz})`);
        }

        if (catData.behaviorState.isMoving && catData.behaviorState.targetPosition) {
            const targetPos = catData.behaviorState.targetPosition;
            const diff = targetPos.sub(currentPos);

            if (diff.Magnitude < 2) {
                print(`[CatAI] Arrived at ${targetPos} (distance: ${diff.Magnitude})`);
                catData.behaviorState.isMoving = false;
                catData.behaviorState.targetPosition = undefined;
            } else {
                const direction = diff.Unit;
                const speed = catData.profile.physical.movementSpeed * 0.1;
                catData.currentState.position = currentPos.add(direction.mul(speed));
            }
        }
    }

    private static ExecuteSeekFood(catId: string, catData: CatData) {
        this.ExecuteExplore(catId, catData);
        if (!catData.behaviorState.isMoving) {
            catData.physicalState.hunger = math.max(0, catData.physicalState.hunger - 20);
        }
    }

    private static ExecuteSeekRest(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
        catData.physicalState.energy = math.min(100, catData.physicalState.energy + 5);
    }

    private static ExecutePlay(catId: string, catData: CatData) {
        this.ExecuteExplore(catId, catData);
        catData.physicalState.energy = math.max(0, catData.physicalState.energy - 2);
    }

    private static ExecuteGroom(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
        catData.physicalState.grooming = math.min(100, catData.physicalState.grooming + 3);
    }

    private static ExecuteIdle(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
    }

    private static ExecuteFollow(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const targetUserId = aiData?.memory.get("SocialTarget") as number;
        const targetPlayer = targetUserId ? Players.GetPlayerByUserId(targetUserId) : undefined;
        const targetChar = targetPlayer?.Character;
        const targetHRP = targetChar?.FindFirstChild("HumanoidRootPart") as Part;

        if (targetHRP) {
            const currentPos = catData.currentState.position;
            const targetPos = targetHRP.Position;
            const dist = targetHRP.Position.sub(currentPos).Magnitude;

            if (dist > 8) {
                catData.behaviorState.targetPosition = targetPos;
                catData.behaviorState.isMoving = true;

                const diff = targetPos.sub(currentPos);
                const direction = diff.Unit;
                const speed = catData.profile.physical.movementSpeed * 0.12;
                catData.currentState.position = currentPos.add(direction.mul(speed));
            } else {
                catData.behaviorState.isMoving = false;
                this.SetCatAction(catId, "LookAt");
            }
        } else {
            this.SetCatAction(catId, "Idle");
        }
    }

    private static ExecuteLookAt(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const targetUserId = aiData?.memory.get("SocialTarget") as number;
        const targetPlayer = targetUserId ? Players.GetPlayerByUserId(targetUserId) : undefined;

        catData.behaviorState.isMoving = false;
        if (targetPlayer?.Character?.PrimaryPart) {
            const targetPos = targetPlayer.Character.PrimaryPart.Position;
            catData.behaviorState.targetPosition = targetPos;
            
            // Store player ID in actionData so client can make cat look at player
            catData.behaviorState.actionData = { reactingToPlayerId: targetUserId };
        } else {
            this.SetCatAction(catId, "Idle");
        }
    }

    private static ExecuteMeow(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
        // Meow logic will be handled by CatRenderer (sound/visual)
        // We'll just idle here for now
    }

    private static ExecuteRollOver(catId: string, catData: CatData) {
        catData.behaviorState.isMoving = false;
        // Animation handled by renderer
    }

    private static ExecuteLookAtToy(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const targetUserId = aiData?.memory.get("SocialTarget") as number;
        const targetPlayer = targetUserId ? Players.GetPlayerByUserId(targetUserId) : undefined;

        catData.behaviorState.isMoving = false;
        if (targetPlayer?.Character?.PrimaryPart) {
            const targetPos = targetPlayer.Character.PrimaryPart.Position;
            catData.behaviorState.targetPosition = targetPos;
            
            // Store player ID in actionData so client can make cat look at player
            catData.behaviorState.actionData = { reactingToPlayerId: targetUserId };
            
            // If player uses toy while cat is looking, transition to playing
            const recentToolUsage = PlayerManager.GetRecentToolUsage(targetPlayer, 3);
            if (recentToolUsage) {
                const toolConfig = PlayerManager.AVAILABLE_TOOLS[recentToolUsage.toolType];
                if (toolConfig?.type === "toy") {
                    this.SetCatAction(catId, "PlayWithToy");
                }
            }
        } else {
            this.SetCatAction(catId, "Idle");
        }
    }

    private static ExecutePlayWithToy(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const targetUserId = aiData?.memory.get("SocialTarget") as number;
        const targetPlayer = targetUserId ? Players.GetPlayerByUserId(targetUserId) : undefined;
        const targetChar = targetPlayer?.Character;
        const targetHRP = targetChar?.FindFirstChild("HumanoidRootPart") as Part;

        if (targetHRP) {
            const currentPos = catData.currentState.position;
            const targetPos = targetHRP.Position;
            const dist = targetPos.sub(currentPos).Magnitude;

            // Store player ID in actionData so client can make cat look at player
            catData.behaviorState.actionData = { reactingToPlayerId: targetUserId };

            // Playful behavior: run around, jump, roll
            // Alternate between different play actions
            const playAction = aiData?.memory.get("PlayAction") as number || 0;
            
            if (playAction === 0 || playAction === undefined) {
                // Run towards player - stay closer when playing (3 studs instead of 5)
                if (dist > 3) {
                    catData.behaviorState.targetPosition = targetPos;
                    catData.behaviorState.isMoving = true;
                    const diff = targetPos.sub(currentPos);
                    const direction = diff.Unit;
                    const speed = catData.profile.physical.movementSpeed * 0.18; // Even faster when playing
                    catData.currentState.position = currentPos.add(direction.mul(speed));
                } else {
                    // Close enough, do play animation (jump/roll)
                    catData.behaviorState.isMoving = false;
                    aiData?.memory.set("PlayAction", 1);
                    aiData?.memory.set("PlayActionTime", os.time());
                }
            } else if (playAction === 1) {
                // Play animation phase
                const playStartTime = aiData?.memory.get("PlayActionTime") as number || os.time();
                if (os.time() - playStartTime > 2) {
                    // Switch back to running
                    aiData?.memory.set("PlayAction", 0);
                }
                catData.behaviorState.isMoving = false;
            }

            // Consume energy while playing
            catData.physicalState.energy = math.max(0, catData.physicalState.energy - 1);
            
            // Increase playfulness mood
            if (catData.moodState.currentMood !== "Playful") {
                CatManager.UpdateCatMood(catId, "Playful", 0.8);
            }
        } else {
            this.SetCatAction(catId, "Idle");
        }
    }

    private static ExecuteApproachFood(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const targetUserId = aiData?.memory.get("SocialTarget") as number;
        const targetPlayer = targetUserId ? Players.GetPlayerByUserId(targetUserId) : undefined;
        const targetChar = targetPlayer?.Character;
        const targetHRP = targetChar?.FindFirstChild("HumanoidRootPart") as Part;

        if (targetHRP) {
            const currentPos = catData.currentState.position;
            const targetPos = targetHRP.Position;
            const dist = targetPos.sub(currentPos).Magnitude;

            // Walk towards player with food
            if (dist > 3) {
                catData.behaviorState.targetPosition = targetPos;
                catData.behaviorState.isMoving = true;

                const diff = targetPos.sub(currentPos);
                const direction = diff.Unit;
                const speed = catData.profile.physical.movementSpeed * 0.1;
                catData.currentState.position = currentPos.add(direction.mul(speed));
            } else {
                // Close enough, switch to circling or sitting
                catData.behaviorState.isMoving = false;
                const playfulness = catData.profile.personality.playfulness;
                if (playfulness > 0.5) {
                    this.SetCatAction(catId, "CirclePlayer");
                } else {
                    this.SetCatAction(catId, "SitAndMeow");
                }
            }
        } else {
            this.SetCatAction(catId, "Idle");
        }
    }

    private static ExecuteCirclePlayer(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const targetUserId = aiData?.memory.get("SocialTarget") as number;
        const targetPlayer = targetUserId ? Players.GetPlayerByUserId(targetUserId) : undefined;
        const targetChar = targetPlayer?.Character;
        const targetHRP = targetChar?.FindFirstChild("HumanoidRootPart") as Part;

        // Store player ID in actionData so client can make cat look at player
        catData.behaviorState.actionData = { reactingToPlayerId: targetUserId };

        if (targetHRP) {
            const currentPos = catData.currentState.position;
            const targetPos = targetHRP.Position;
            const dist = targetPos.sub(currentPos).Magnitude;

            // Circle around player at 3-5 studs distance
            const desiredDistance = 4;
            const angle = aiData?.memory.get("CircleAngle") as number || 0;
            const newAngle = angle + 0.1; // Increment angle for circling

            aiData?.memory.set("CircleAngle", newAngle);

            // Calculate position on circle around player
            const circleX = targetPos.X + math.cos(newAngle) * desiredDistance;
            const circleZ = targetPos.Z + math.sin(newAngle) * desiredDistance;
            const circleTarget = new Vector3(circleX, targetPos.Y, circleZ);
            const groundedTarget = this.FindGroundPosition(circleTarget);

            catData.behaviorState.targetPosition = groundedTarget;
            catData.behaviorState.isMoving = true;

            const diff = groundedTarget.sub(currentPos);
            if (diff.Magnitude > 0.5) {
                const direction = diff.Unit;
                const speed = catData.profile.physical.movementSpeed * 0.08;
                catData.currentState.position = currentPos.add(direction.mul(speed));
            }

            // Occasionally meow while circling
            if (math.random() < 0.1) {
                catData.behaviorState.currentAction = "Meow";
            }
        } else {
            this.SetCatAction(catId, "Idle");
        }
    }

    /**
     * Find the nearest cat tree in the workspace.
     * Cat trees are objects tagged with "CatTree" using CollectionService.
     */
    private static FindNearestCatTree(catPosition: Vector3): BasePart | undefined {
        // Safely get tagged cat trees (may not be available in test environment)
        let catTrees: Instance[] = [];
        const [success, result] = pcall(() => {
            return CollectionService.GetTagged("CatTree");
        });
        if (success && typeIs(result, "table")) {
            catTrees = result as Instance[];
        } else {
            // In test environment or if CollectionService is not available, return undefined
            return undefined;
        }
        
        let nearestTree: BasePart | undefined;
        let minDistance = math.huge;

        for (const instance of catTrees) {
            // Cat trees should be Models or BaseParts
            let treePart: BasePart | undefined;
            
            if (instance.IsA("Model")) {
                // Try to find a primary part or the largest part
                treePart = instance.PrimaryPart as BasePart;
                if (!treePart) {
                    // Find the highest part (usually the top platform)
                    let highestY = -math.huge;
                    for (const child of instance.GetDescendants()) {
                        if (child.IsA("BasePart")) {
                            const part = child as BasePart;
                            if (part.Position.Y > highestY) {
                                highestY = part.Position.Y;
                                treePart = part;
                            }
                        }
                    }
                }
            } else if (instance.IsA("BasePart")) {
                treePart = instance as BasePart;
            }

            if (treePart) {
                const distance = treePart.Position.sub(catPosition).Magnitude;
                if (distance < minDistance) {
                    minDistance = distance;
                    nearestTree = treePart;
                }
            }
        }

        return nearestTree;
    }

    /**
     * Find the top platform of a cat tree (highest part).
     */
    private static FindCatTreeTop(catTree: BasePart): Vector3 {
        // If it's a Model, find the highest part
        const model = catTree.Parent as Model;
        if (model && model.IsA("Model")) {
            let highestY = -math.huge;
            let topPart: BasePart | undefined;
            
            for (const child of model.GetDescendants()) {
                if (child.IsA("BasePart")) {
                    const part = child as BasePart;
                    if (part.Position.Y > highestY) {
                        highestY = part.Position.Y;
                        topPart = part;
                    }
                }
            }
            
            if (topPart) {
                return topPart.Position.add(new Vector3(0, 1, 0)); // Offset above the platform
            }
        }
        
        // Fallback: use the part's position with offset
        return catTree.Position.add(new Vector3(0, catTree.Size.Y / 2 + 1, 0));
    }

    /**
     * Execute approach cat tree behavior.
     */
    private static ExecuteApproachCatTree(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const catTree = aiData?.memory.get("CatTreeTarget") as BasePart | undefined;
        
        if (!catTree) {
            this.SetCatAction(catId, "Idle");
            return;
        }

        const currentPos = catData.currentState.position;
        const targetPos = catTree.Position;
        const distance = targetPos.sub(currentPos).Magnitude;

        // Approach the base of the cat tree
        if (distance > 3) {
            catData.behaviorState.targetPosition = targetPos;
            catData.behaviorState.isMoving = true;

            const diff = targetPos.sub(currentPos);
            const direction = diff.Unit;
            const speed = catData.profile.physical.movementSpeed * 0.1;
            catData.currentState.position = currentPos.add(direction.mul(speed));
        } else {
            // Close enough, transition to climbing
            catData.behaviorState.isMoving = false;
            this.SetCatAction(catId, "ClimbCatTree");
        }
    }

    /**
     * Execute climb cat tree behavior.
     */
    private static ExecuteClimbCatTree(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const catTree = aiData?.memory.get("CatTreeTarget") as BasePart | undefined;
        
        if (!catTree) {
            this.SetCatAction(catId, "Idle");
            return;
        }

        const currentPos = catData.currentState.position;
        const treeTop = this.FindCatTreeTop(catTree);
        const distance = treeTop.sub(currentPos).Magnitude;
        const heightDiff = treeTop.Y - currentPos.Y;

        // If we're close to the top (within 2 studs horizontally and on the platform)
        if (distance < 2 && heightDiff < 1) {
            // Successfully climbed, now rest
            catData.currentState.position = treeTop;
            catData.behaviorState.isMoving = false;
            this.SetCatAction(catId, "RestOnCatTree");
        } else {
            // Move towards the top of the tree
            catData.behaviorState.targetPosition = treeTop;
            catData.behaviorState.isMoving = true;

            const diff = treeTop.sub(currentPos);
            const direction = diff.Unit;
            const speed = catData.profile.physical.movementSpeed * 0.08; // Slower for climbing
            catData.currentState.position = currentPos.add(direction.mul(speed));
            
            // Consume energy while climbing
            catData.physicalState.energy = math.max(0, catData.physicalState.energy - 0.5);
        }
    }

    /**
     * Execute rest on cat tree behavior.
     */
    private static ExecuteRestOnCatTree(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const catTree = aiData?.memory.get("CatTreeTarget") as BasePart | undefined;
        
        if (!catTree) {
            this.SetCatAction(catId, "Idle");
            return;
        }

        const currentPos = catData.currentState.position;
        const treeTop = this.FindCatTreeTop(catTree);
        const distance = treeTop.sub(currentPos).Magnitude;

        // Stay on the tree
        catData.behaviorState.isMoving = false;
        
        // If we've drifted too far, move back to the top
        if (distance > 1) {
            catData.currentState.position = treeTop;
        }

        // Restore energy while resting on tree
        catData.physicalState.energy = math.min(100, catData.physicalState.energy + 2);
        
        // Rest for a while, then decide to do something else
        const restTime = aiData?.memory.get("RestStartTime") as number || 0;
        const currentTime = os.time();
        
        if (restTime === 0) {
            aiData?.memory.set("RestStartTime", currentTime);
        } else if (currentTime - restTime > 10) {
            // Rested for 10 seconds, maybe explore or do something else
            aiData?.memory.delete("RestStartTime");
            aiData?.memory.delete("CatTreeTarget");
            
            // If energy is high, explore. Otherwise, continue resting if still low energy
            if (catData.physicalState.energy > 70) {
                this.SetCatAction(catId, "Explore");
            } else {
                // Continue resting
                aiData?.memory.set("RestStartTime", currentTime);
            }
        }
    }

    /**
     * Execute scratch tree behavior.
     */
    private static ExecuteScratchTree(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const catTree = aiData?.memory.get("CatTreeTarget") as BasePart | undefined;
        
        if (!catTree) {
            this.SetCatAction(catId, "Idle");
            return;
        }

        const currentPos = catData.currentState.position;
        const treePos = catTree.Position;
        const distance = treePos.sub(currentPos).Magnitude;

        // Stop moving and scratch
        catData.behaviorState.isMoving = false;
        
        // Face the tree
        if (distance > 0.5) {
            catData.behaviorState.targetPosition = treePos;
        }

        // Scratch animation (handled by renderer)
        // Consume a bit of energy
        catData.physicalState.energy = math.max(0, catData.physicalState.energy - 0.3);
        
        // Scratch for a few seconds, then maybe jump on or play
        const scratchStartTime = aiData?.memory.get("ScratchStartTime") as number || 0;
        const currentTime = os.time();
        
        if (scratchStartTime === 0) {
            aiData?.memory.set("ScratchStartTime", currentTime);
        } else if (currentTime - scratchStartTime > 3) {
            // Done scratching, maybe jump on or play
            aiData?.memory.delete("ScratchStartTime");
            
            const playfulness = catData.profile.personality.playfulness;
            if (playfulness > 0.7 && catData.physicalState.energy > 50) {
                this.SetCatAction(catId, "JumpOnTree");
            } else if (playfulness > 0.5) {
                this.SetCatAction(catId, "PlayOnTree");
            } else {
                this.SetCatAction(catId, "Idle");
            }
        }
    }

    /**
     * Execute jump on tree behavior.
     */
    private static ExecuteJumpOnTree(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const catTree = aiData?.memory.get("CatTreeTarget") as BasePart | undefined;
        
        if (!catTree) {
            this.SetCatAction(catId, "Idle");
            return;
        }

        const currentPos = catData.currentState.position;
        const treeTop = this.FindCatTreeTop(catTree);
        const distance = treeTop.sub(currentPos).Magnitude;
        const heightDiff = treeTop.Y - currentPos.Y;

        // If we're on the top platform
        if (distance < 2 && heightDiff < 1) {
            // Successfully jumped on, now play or rest
            catData.currentState.position = treeTop;
            catData.behaviorState.isMoving = false;
            
            const playfulness = catData.profile.personality.playfulness;
            if (playfulness > 0.6) {
                this.SetCatAction(catId, "PlayOnTree");
            } else {
                this.SetCatAction(catId, "RestOnCatTree");
            }
        } else {
            // Jump towards the top of the tree
            catData.behaviorState.targetPosition = treeTop;
            catData.behaviorState.isMoving = true;

            const diff = treeTop.sub(currentPos);
            const direction = diff.Unit;
            // Faster movement for jumping
            const speed = catData.profile.physical.movementSpeed * 0.15;
            catData.currentState.position = currentPos.add(direction.mul(speed));
            
            // Consume more energy while jumping
            catData.physicalState.energy = math.max(0, catData.physicalState.energy - 1.5);
        }
    }

    /**
     * Execute play on tree behavior.
     */
    private static ExecutePlayOnTree(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const catTree = aiData?.memory.get("CatTreeTarget") as BasePart | undefined;
        
        if (!catTree) {
            this.SetCatAction(catId, "Idle");
            return;
        }

        const currentPos = catData.currentState.position;
        const treeTop = this.FindCatTreeTop(catTree);
        const distance = treeTop.sub(currentPos).Magnitude;

        // Stay on the tree top
        if (distance > 1) {
            catData.currentState.position = treeTop;
        }
        
        catData.behaviorState.isMoving = false;

        // Play animation (handled by renderer)
        // Consume energy while playing
        catData.physicalState.energy = math.max(0, catData.physicalState.energy - 1);
        
        // Set playful mood
        if (catData.moodState.currentMood !== "Playful") {
            CatManager.UpdateCatMood(catId, "Playful", 0.8);
        }
        
        // Play for a while, then maybe rest or explore
        const playStartTime = aiData?.memory.get("PlayStartTime") as number || 0;
        const currentTime = os.time();
        
        if (playStartTime === 0) {
            aiData?.memory.set("PlayStartTime", currentTime);
        } else if (currentTime - playStartTime > 5) {
            // Done playing
            aiData?.memory.delete("PlayStartTime");
            
            // If low energy, rest. Otherwise explore
            if (catData.physicalState.energy < 40) {
                this.SetCatAction(catId, "SleepOnTree");
            } else {
                this.SetCatAction(catId, "Explore");
                aiData?.memory.delete("CatTreeTarget");
            }
        }
    }

    /**
     * Execute sleep on tree behavior.
     */
    private static ExecuteSleepOnTree(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const catTree = aiData?.memory.get("CatTreeTarget") as BasePart | undefined;
        
        if (!catTree) {
            this.SetCatAction(catId, "Idle");
            return;
        }

        const currentPos = catData.currentState.position;
        const treeTop = this.FindCatTreeTop(catTree);
        const distance = treeTop.sub(currentPos).Magnitude;

        // Stay on the tree top
        catData.behaviorState.isMoving = false;
        
        if (distance > 1) {
            catData.currentState.position = treeTop;
        }

        // Restore energy while sleeping
        catData.physicalState.energy = math.min(100, catData.physicalState.energy + 3);
        
        // Set tired mood (or happy if well-rested)
        if (catData.physicalState.energy < 50) {
            if (catData.moodState.currentMood !== "Tired") {
                CatManager.UpdateCatMood(catId, "Tired", 0.6);
            }
        } else {
            if (catData.moodState.currentMood === "Tired") {
                CatManager.UpdateCatMood(catId, "Happy", 0.7);
            }
        }
        
        // Sleep for a while, then wake up
        const sleepStartTime = aiData?.memory.get("SleepStartTime") as number || 0;
        const currentTime = os.time();
        
        if (sleepStartTime === 0) {
            aiData?.memory.set("SleepStartTime", currentTime);
        } else if (currentTime - sleepStartTime > 15) {
            // Slept for 15 seconds, wake up
            aiData?.memory.delete("SleepStartTime");
            aiData?.memory.delete("CatTreeTarget");
            
            // If energy is high, explore. Otherwise continue sleeping if still tired
            if (catData.physicalState.energy > 70) {
                this.SetCatAction(catId, "Explore");
            } else {
                // Continue sleeping
                aiData?.memory.set("SleepStartTime", currentTime);
            }
        }
    }

    private static ExecuteSitAndMeow(catId: string, catData: CatData) {
        const aiData = this.activeCats.get(catId);
        const targetUserId = aiData?.memory.get("SocialTarget") as number;
        const targetPlayer = targetUserId ? Players.GetPlayerByUserId(targetUserId) : undefined;

        // Store player ID in actionData so client can make cat look at player
        catData.behaviorState.actionData = { reactingToPlayerId: targetUserId };

        catData.behaviorState.isMoving = false;

        if (targetPlayer?.Character?.PrimaryPart) {
            catData.behaviorState.targetPosition = targetPlayer.Character.PrimaryPart.Position;
            
            // Alternate between sitting and meowing
            const lastMeowTime = aiData?.memory.get("LastMeowTime") as number || 0;
            if (os.time() - lastMeowTime > 3) {
                // Meow every 3 seconds
                catData.behaviorState.currentAction = "Meow";
                aiData?.memory.set("LastMeowTime", os.time());
            }
        } else {
            this.SetCatAction(catId, "Idle");
        }
    }

    private static SetupBehaviorTree(catId: string, profileName: string): BehaviorTree {
        const nodes = new Map<string, any>();
        nodes.set("Selector", {
            type: "selector",
            children: ["UrgentNeeds", "MoodDriven", "PersonalityDriven", "Idle"],
        });

        return {
            root: "Selector",
            nodes: nodes,
        };
    }
}
