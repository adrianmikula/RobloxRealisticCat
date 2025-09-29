-- Shared Cat Data Unit Tests
-- Tests for data modules that define cat behavior and profiles

return function()
	local TestEZ = require(game:GetService("ReplicatedStorage").Packages.TestEZ)

	describe("Cat Data Modules", function()
		local CatProfileData
		local CatPerformanceConfig

		beforeEach(function()
			-- Mock the data modules for testing
			CatProfileData = {
				PersonalityTypes = {
					PLAYFUL = "Playful cats are energetic and love to interact with players. They frequently engage in playful behaviors and respond positively to toys and attention.",
					CURIOUS = "Curious cats are explorers at heart. They investigate their environment and are drawn to new objects and areas that capture their interest.",
					CALM = "Calm cats prefer peaceful environments. They are relaxed, gentle creatures that enjoy quiet moments and gentle petting.",
					SKITTISH = "Skittish cats are easily startled and prefer to keep their distance. They need time to build trust and approach cautiously.",
					AFFETIONATE = "Affectionate cats crave human interaction. They seek out players for petting and cuddles, and form strong bonds quickly.",
					INDEPENDENT = "Independent cats march to the beat of their own drum. They do what they want when they want, on their own schedule."
				},

				MoodStates = {
					HAPPY = {
						description = "The cat is content and enjoying its current situation",
						visual = {
							color = Color3.fromRGB(100, 255, 100),
							emojis = {"😺", "😸", "😀"}
						},
						behaviors = {"purring", "kneading", "affectionate"}
					},
					CONTENT = {
						description = "The cat is comfortable in its current state",
						visual = {
							color = Color3.fromRGB(200, 255, 100),
							emojis = {"🙂", "😊", "😐"}
						},
						behaviors = {"relaxed", "calm"}
					},
					NEUTRAL = {
						description = "The cat is in its normal state",
						visual = {
							color = Color3.fromRGB(255, 255, 100),
							emojis = {"😐", "🙄", "😑"}
						},
						behaviors = {"normal routine"}
					},
					ANXIOUS = {
						description = "The cat is worried or tense about its surroundings",
						visual = {
							color = Color3.fromRGB(255, 200, 100),
							emojis = {"😬", "😟", "😰"}
						},
						behaviors = {"twitching", "alert"}
					},
					STRESSED = {
						description = "The cat is experiencing significant discomfort or fear",
						visual = {
							color = Color3.fromRGB(255, 100, 100),
							emojis = {"😨", "😱", "🤯"}
						},
						behaviors = {"hiding", "avoiding"}
					},
					ANGRY = {
						description = "The cat is displaying aggressive or defensive behavior",
						visual = {
							color = Color3.fromRGB(255, 50, 50),
							emojis = {"😠", "😾", "👿"}
						},
						behaviors = {"hissing", "growling", "swatting"}
					}
				},

				BreedTypes = {
					TABBY = {
						name = "Tabby",
						description = "Classic striped or spotted patterns",
						physical = {
							size = "medium",
							speed = 1.0,
							climbing = 0.9
						}
					},
					SIAMESE = {
						name = "Siamese",
						description = "Elegant, social, vocal cats",
						physical = {
							size = "medium",
							speed = 1.1,
							climbing = 1.0
						}
					},
					PERSIAN = {
						name = "Persian",
						description = "Fluffy longhaired breed",
						physical = {
							size = "medium",
							speed = 0.8,
							climbing = 0.7
						}
					}
				},

				GetPersonalityType = function(typeName)
					return CatProfileData.PersonalityTypes[typeName]
				end,

				GetMoodState = function(moodName)
					return CatProfileData.MoodStates[moodName]
				end,

				GetBreedInfo = function(breedName)
					return CatProfileData.BreedTypes[breedName]
				end,

				GenerateCatProfile = function()
					return {
						name = "TestCat",
						personality = "PLAYFUL",
						breed = "TABBY",
						age = 2,
						mood = "NEUTRAL"
					}
				end
			}

			CatPerformanceConfig = {
				LODSettings = {
					LOD1 = {
						distance = 20,
						animationQuality = "high",
						updateFrequency = 0.1
					},
					LOD2 = {
						distance = 50,
						animationQuality = "medium",
						updateFrequency = 0.3
					}
				},

				PerformanceModes = {
					High = { maxCats = 50, LODDistanceMultiplier = 1.0 },
					Balanced = { maxCats = 25, LODDistanceMultiplier = 0.8 },
					Low = { maxCats = 10, LODDistanceMultiplier = 0.6 }
				},

				GetLODLevel = function(self, distance)
					if distance <= self.LODSettings.LOD1.distance then
						return 1
					elseif distance <= self.LODSettings.LOD2.distance then
						return 2
					else
						return 3
					end
				end,

				GetLODSettings = function(self, level)
					return self.LODSettings["LOD" .. level] or self.LODSettings.LOD2
				end,

				GetPerformanceMode = function(self, modeName)
					return self.PerformanceModes[modeName] or self.PerformanceModes.Balanced
				end
			}
		end)

		describe("Personality Types", function()
			it("should have all required personality types", function()
				expect(CatProfileData.PersonalityTypes.PLAYFUL).to.be.ok()
				expect(CatProfileData.PersonalityTypes.CURIOUS).to.be.ok()
				expect(CatProfileData.PersonalityTypes.CALM).to.be.ok()
				expect(CatProfileData.PersonalityTypes.SKITTISH).to.be.ok()
				expect(CatProfileData.PersonalityTypes.AFFETIONATE).to.be.ok()
				expect(CatProfileData.PersonalityTypes.INDEPENDENT).to.be.ok()
			end)

			it("should return correct personality descriptions", function()
				local description = CatProfileData:GetPersonalityType("PLAYFUL")
				expect(description).to.be.ok()
				expect(description:find("energetic")).to.never.equal(nil)

				local unknown = CatProfileData:GetPersonalityType("UNKNOWN")
				expect(unknown).to.never.be.ok()
			end)
		end)

		describe("Mood States", function()
			it("should have all required mood states", function()
				expect(CatProfileData.MoodStates.HAPPY).to.be.ok()
				expect(CatProfileData.MoodStates.CONTENT).to.be.ok()
				expect(CatProfileData.MoodStates.NEUTRAL).to.be.ok()
				expect(CatProfileData.MoodStates.ANXIOUS).to.be.ok()
				expect(CatProfileData.MoodStates.STRESSED).to.be.ok()
				expect(CatProfileData.MoodStates.ANGRY).to.be.ok()
			end)

			it("should have proper mood data structure", function()
				local happyMood = CatProfileData:GetMoodState("HAPPY")

				expect(happyMood.description).to.be.ok()
				expect(happyMood.visual).to.be.ok()
				expect(happyMood.visual.color).to.be.ok()
				expect(happyMood.behaviors).to.be.a("table")
				expect(#happyMood.behaviors).to.be.greaterThan(0)
			end)

			it("should have valid color values for all moods", function()
				for moodName, moodData in pairs(CatProfileData.MoodStates) do
					expect(moodData.visual.color).to.be.a("Color3")
					expect(moodData.visual.color.R).to.be.greaterThanOrEqualTo(0)
					expect(moodData.visual.color.R).to.be.lessThanOrEqualTo(1)
				end
			end)
		end)

		describe("Breed Types", function()
			it("should have required breed types", function()
				expect(CatProfileData.BreedTypes.TABBY).to.be.ok()
				expect(CatProfileData.BreedTypes.SIAMESE).to.be.ok()
				expect(CatProfileData.BreedTypes.PERSIAN).to.be.ok()
			end)

			it("should have proper breed data structure", function()
				local tabby = CatProfileData:GetBreedInfo("TABBY")

				expect(tabby.name).to.equal("Tabby")
				expect(tabby.description).to.be.ok()
				expect(tabby.physical).to.be.ok()
				expect(tabby.physical.speed).to.be.a("number")
				expect(tabby.physical.climbing).to.be.a("number")
			end)
		end)

		describe("Profile Generation", function()
			it("should generate valid cat profiles", function()
				local profile = CatProfileData:GenerateCatProfile()

				expect(profile.name).to.be.ok()
				expect(profile.personality).to.be.ok()
				expect(profile.breed).to.be.ok()
				expect(profile.age).to.be.a("number")
				expect(profile.age).to.be.greaterThan(0)
			end)
		end)

		describe("Performance Configuration", function()
			describe("LOD Settings", function()
				it("should calculate correct LOD levels", function()
					expect(CatPerformanceConfig:GetLODLevel(10)).to.equal(1) -- Close
					expect(CatPerformanceConfig:GetLODLevel(30)).to.equal(2) -- Medium
					expect(CatPerformanceConfig:GetLODLevel(70)).to.equal(3) -- Far
				end)

				it("should return correct LOD settings", function()
					local lod1 = CatPerformanceConfig:GetLODSettings(1)
					expect(lod1.distance).to.be.lessThanOrEqualTo(20)
					expect(lod1.animationQuality).to.equal("high")

					local lod2 = CatPerformanceConfig:GetLODSettings(2)
					expect(lod2.distance).to.be.lessThanOrEqualTo(50)
					expect(lod2.animationQuality).to.equal("medium")
				end)

				it("should handle invalid LOD levels gracefully", function()
					local defaultLOD = CatPerformanceConfig:GetLODSettings(99)
					expect(defaultLOD).to.be.ok()
					expect(defaultLOD.animationQuality).to.equal("medium")
				end)
			end)

			describe("Performance Modes", function()
				it("should have all required performance modes", function()
					expect(CatPerformanceConfig.PerformanceModes.High).to.be.ok()
					expect(CatPerformanceConfig.PerformanceModes.Balanced).to.be.ok()
					expect(CatPerformanceConfig.PerformanceModes.Low).to.be.ok()
				end)

				it("should return correct performance settings", function()
					local highMode = CatPerformanceConfig:GetPerformanceMode("High")
					expect(highMode.maxCats).to.be.greaterThanOrEqualTo(50)

					local balancedMode = CatPerformanceConfig:GetPerformanceMode("Balanced")
					expect(balancedMode.maxCats).to.be.lessThanOrEqualTo(25)
				end)

				it("should handle unknown performance modes", function()
					local unknownMode = CatPerformanceConfig:GetPerformanceMode("Unknown")
					expect(unknownMode).to.be.ok()
					expect(unknownMode.maxCats).to.be.lessThanOrEqualTo(25) -- Should default to Balanced
				end)
			end)

			describe("Performance Utilities", function()
				it("should determine rendering based on distance", function()
					local shouldRender = CatPerformanceConfig:ShouldRenderCat(15, "High")
					expect(shouldRender).to.equal(true)

					local shouldNotRender = CatPerformanceConfig:ShouldRenderCat(150, "Balanced")
					expect(shouldNotRender).to.equal(false)
				end)

				it("should calculate update frequencies", function()
					local freq = CatPerformanceConfig:GetUpdateFrequency(25, "High")
					expect(freq).to.be.greaterThan(0)
					expect(freq).to.be.lessThan(1) -- Should be reasonable
				end)
			end)
		end)

		describe("Data Validation", function()
			it("should validate personality type existence", function()
				expect(CatProfileData:GetPersonalityType("NONEXISTENT")).to.never.be.ok()
				expect(CatProfileData:GetPersonalityType("PLAYFUL")).to.be.ok()
			end)

			it("should validate mood state data", function()
				expect(CatProfileData:GetMoodState("SUPER_HAPPY")).to.never.be.ok()
				expect(CatProfileData:GetMoodState("HAPPY")).to.be.ok()

				local happyMood = CatProfileData:GetMoodState("HAPPY")
				expect(happyMood.visual.emojis).to.be.a("table")
				expect(#happyMood.visual.emojis).to.be.greaterThan(0)
			end)

			it("should validate breed information", function()
				expect(CatProfileData:GetBreedInfo("MYTHICAL_BREED")).to.never.be.ok()
				expect(CatProfileData:GetBreedInfo("TABBY")).to.be.ok()

				local tabbyBreed = CatProfileData:GetBreedInfo("TABBY")
				expect(tabbyBreed.physical.speed).to.be.lessThanOrEqualTo(1.5)
				expect(tabbyBreed.physical.speed).to.be.greaterThanOrEqualTo(0.5)
			end)
		end)

		describe("Data Consistency", function()
			it("should have consistent data references", function()
				local profile = CatProfileData:GenerateCatProfile()
				local personalityDesc = CatProfileData:GetPersonalityType(profile.personality)
				expect(personalityDesc).to.be.ok()
			end)

			it("should handle edge cases gracefully", function()
				-- Test with nil or empty parameters
				local function testEdgeCases()
					CatProfileData:GetPersonalityType(nil)
					CatProfileData:GetMoodState("")
					CatProfileData:GetBreedInfo(123)
				end

				expect(testEdgeCases).never.to.throw()
			end)
		end)
	end)
end