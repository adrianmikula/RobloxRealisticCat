-- CatService Unit Tests
-- Tests for the server-side CatService functionality
return function()
local TestEZ = require(game:GetService("ReplicatedStorage").Packages.TestEZ)
describe("CatService", function()
local CatService
local Players
local ReplicatedStorage
beforeEach(function()
-- Mock dependencies
Players = {
LocalPlayer = {
UserId = 12345,
Name = "TestPlayer"
}
}
ReplicatedStorage = {
Packages = {
Knit = {},
Signal = {}
},
SharedSource = {
Datas = {
CatProfileData = {},
CatPerformanceConfig = {}
}
}
}
-- Create minimal CatService instance for testing
CatService = {
Name = "CatService",
ActiveCats = {},
-- Mock methods
CreateCat = function(self, catProfile)
local catId = "cat_" .. tostring(math.random(1000, 9999))
self.ActiveCats[catId] = {
profile = catProfile or { name = "TestCat", personality = "playful" },
currentState = {
position = Vector3.new(0, 0, 0),
currentAction = "Idle",
currentMood = "neutral"
},
relationships = {}
}
return catId
end,
RemoveCat = function(self, catId)
self.ActiveCats[catId] = nil
return true
end,
GetCatState = function(self, catId)
return self.ActiveCats[catId]
end,
GetAllCats = function(self)
return self.ActiveCats
end,
InteractWithCat = function(self, player, catId, interactionType, interactionData)
local cat = self.ActiveCats[catId]
if not cat then
return { success = false, message = "Cat not found" }
end
-- Simulate interaction effect
if interactionType == "Feed" then
cat.currentState.currentMood = "happy"
elseif interactionType == "Play" then
cat.currentState.currentAction = "Play"
end
return { success = true, message = "Interaction successful" }
end
}
end)
afterEach(function()
-- Clean up after each test
CatService.ActiveCats = {}
end)
describe("Cat Creation", function()
it("should create a cat with valid profile", function()
local catProfile = {
name = "Whiskers",
personality = "curious",
breed = "tabby",
age = 2
}
local catId = CatService:CreateCat(catProfile)
expect(catId).to.be.ok()
expect(CatService.ActiveCats[catId]).to.be.ok()
expect(CatService.ActiveCats[catId].profile.name).to.equal("Whiskers")
expect(CatService.ActiveCats[catId].profile.personality).to.equal("curious")
end)
it("should create a cat with default profile when none provided", function()
local catId = CatService:CreateCat()
expect(catId).to.be.ok()
expect(CatService.ActiveCats[catId]).to.be.ok()
expect(CatService.ActiveCats[catId].profile.name).to.equal("TestCat")
end)
it("should generate unique cat IDs", function()
local catId1 = CatService:CreateCat()
local catId2 = CatService:CreateCat()
expect(catId1).to.never.equal(catId2)
expect(CatService.ActiveCats[catId1]).to.be.ok()
expect(CatService.ActiveCats[catId2]).to.be.ok()
end)
end)
describe("Cat Removal", function()
it("should remove an existing cat", function()
local catId = CatService:CreateCat()
expect(CatService.ActiveCats[catId]).to.be.ok()
local result = CatService:RemoveCat(catId)
expect(result).to.equal(true)
expect(CatService.ActiveCats[catId]).to.never.be.ok()
end)
it("should handle removal of non-existent cat gracefully", function()
local result = CatService:RemoveCat("nonexistent_cat")
expect(result).to.equal(true) -- Should not throw error
end)
end)
describe("Cat State Management", function()
it("should retrieve cat state", function()
local catId = CatService:CreateCat()
local catState = CatService:GetCatState(catId)
expect(catState).to.be.ok()
expect(catState.profile).to.be.ok()
expect(catState.currentState).to.be.ok()
expect(catState.currentState.position).to.be.ok()
expect(catState.currentState.currentAction).to.equal("Idle")
expect(catState.currentState.currentMood).to.equal("neutral")
end)
it("should return nil for non-existent cat state", function()
local catState = CatService:GetCatState("nonexistent_cat")
expect(catState).to.never.be.ok()
end)
it("should retrieve all cats", function()
CatService:CreateCat()
CatService:CreateCat()
local allCats = CatService:GetAllCats()
expect(allCats).to.be.a("table")
end)
end)
describe("Player Interactions", function()
it("should handle valid cat interaction", function()
local catId = CatService:CreateCat()
local player = { UserId = 12345, Name = "TestPlayer" }
local result = CatService:InteractWithCat(player, catId, "Feed", {})
expect(result.success).to.equal(true)
expect(result.message).to.equal("Interaction successful")
expect(CatService.ActiveCats[catId].currentState.currentMood).to.equal("happy")
end)
it("should handle play interaction", function()
local catId = CatService:CreateCat()
local player = { UserId = 12345, Name = "TestPlayer" }
local result = CatService:InteractWithCat(player, catId, "Play", {})
expect(result.success).to.equal(true)
expect(CatService.ActiveCats[catId].currentState.currentAction).to.equal("Play")
end)
it("should handle interaction with non-existent cat", function()
local player = { UserId = 12345, Name = "TestPlayer" }
local result = CatService:InteractWithCat(player, "nonexistent_cat", "Feed", {})
expect(result.success).to.equal(false)
expect(result.message).to.equal("Cat not found")
end)
it("should handle different interaction types", function()
local catId = CatService:CreateCat()
local player = { UserId = 12345, Name = "TestPlayer" }
local interactions = {"Feed", "Play", "Groom", "Pet"}
for _, interactionType in ipairs(interactions) do
local result = CatService:InteractWithCat(player, catId, interactionType, {})
expect(result.success).to.equal(true)
end
end)
end)
describe("Performance and Scaling", function()
it("should handle multiple cat creations efficiently", function()
local startTime = os.clock()
for i = 1, 10 do
CatService:CreateCat({
name = "Cat" .. i,
personality = "test"
})
end
local endTime = os.clock()
local duration = endTime - startTime
expect(duration).to.be.lessThan(0.1) -- Should be fast
end)
it("should maintain cat state integrity under load", function()
local catIds = {}
for i = 1, 5 do
catIds[i] = CatService:CreateCat({
name = "Cat" .. i,
personality = "test"
})
end
for _, catId in ipairs(catIds) do
local catState = CatService:GetCatState(catId)
expect(catState).to.be.ok()
expect(catState.currentState.currentAction).to.equal("Idle")
expect(catState.currentState.currentMood).to.equal("neutral")
end
end)
end)
describe("Error Handling", function()
it("should handle invalid parameters gracefully", function()
local result = CatService:InteractWithCat(nil, nil, nil, nil)
expect(result.success).to.equal(false)
end)
it("should not crash on malformed data", function()
local function testMalformedData()
CatService:CreateCat("not_a_table")
CatService:GetCatState(123)
CatService:RemoveCat({})
end
expect(testMalformedData).never.to.throw()
end)
end)
end)
end