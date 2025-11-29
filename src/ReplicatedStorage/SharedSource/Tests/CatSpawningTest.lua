 -- Cat Spawning Basic Test
-- This test verifies that the cat spawning system works correctly

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local TestService = game:GetService("TestService")
	
	-- Load TestEZ
	local TestEZ = require(ReplicatedStorage.Packages.TestEZ)
	
	describe("Cat Spawning System", function()
		
		it("should have CatService available", function()
			-- Check if CatService exists
			local Knit = require(ReplicatedStorage.Packages.Knit)
			local CatService = Knit.GetService("CatService")
			
			expect(CatService).to.be.ok()
			expect(CatService.CreateCat).to.be.a("function")
		end)
		
		it("should have CatController available", function()
			-- Check if CatController exists
			local Knit = require(ReplicatedStorage.Packages.Knit)
			local CatController = Knit.GetController("CatController")
			
			expect(CatController).to.be.ok()
			expect(CatController.CreateCatVisual).to.be.a("function")
		end)
		
		it("should have proper component structure", function()
			-- Check if components are properly loaded
			local Knit = require(ReplicatedStorage.Packages.Knit)
			local CatService = Knit.GetService("CatService")
			
			expect(CatService.Components).to.be.ok()
			expect(CatService.Components.CatManager).to.be.ok()
			expect(CatService.Components.CatAI).to.be.ok()
			expect(CatService.Components.PlayerManager).to.be.ok()
		end)
		
		it("should have data modules available", function()
			-- Check if data modules exist
			local CatProfileData = require(ReplicatedStorage.SharedSource.Datas.CatProfileData)
			local CatPerformanceConfig = require(ReplicatedStorage.SharedSource.Datas.CatPerformanceConfig)
			
			expect(CatProfileData).to.be.ok()
			expect(CatPerformanceConfig).to.be.ok()
			expect(CatProfileData.PersonalityTypes).to.be.a("table")
			expect(CatPerformanceConfig.CatOptimization).to.be.a("table")
		end)
		
		it("should have client methods available", function()
			-- Check if client methods are properly defined
			local Knit = require(ReplicatedStorage.Packages.Knit)
			local CatService = Knit.GetService("CatService")
			
			-- These should be available as client methods
			expect(CatService.Client.SpawnCat).to.be.a("function")
			expect(CatService.Client.GetAllCats).to.be.a("function")
			expect(CatService.Client.GetPlayerTools).to.be.a("function")
			expect(CatService.Client.EquipTool).to.be.a("function")
		end)
		
	end)
end