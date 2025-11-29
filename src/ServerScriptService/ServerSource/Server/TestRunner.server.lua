-- Test Runner for Cat Game
-- This script runs all automated tests when the game starts

local TestService = game:GetService("TestService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load TestEZ framework
local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

-- Test configuration
local TEST_CONFIG = {
	VERBOSE = true, -- Print detailed test results
	SHOW_ERRORS = true, -- Show error details
	STOP_ON_FAILURE = false -- Continue running tests even if some fail
}

-- Function to run all tests
local function runAllTests()
	print("🧪 Starting Cat Game Automated Tests...")
	
	-- Define test locations
	local testLocations = {
		ReplicatedStorage:WaitForChild("SharedSource"):WaitForChild("Tests"),
		ServerScriptService:WaitForChild("ServerSource"):WaitForChild("Tests")
	}
	
	-- Filter out nil locations
	local validTestLocations = {}
	for _, location in ipairs(testLocations) do
		if location then
			table.insert(validTestLocations, location)
		end
	end
	
	if #validTestLocations == 0 then
		print("⚠️ No test locations found!")
		return
	end
	
	-- Run tests
	local results = TestEZ.TestBootstrap:run(validTestLocations, TestEZ.Reporters.TextReporter)
	
	-- Print summary
	print("
📊 Test Summary:")
	print("✅ Passed: " .. results.successCount)
	print("❌ Failed: " .. results.failureCount)
	print("⏱️ Duration: " .. string.format("%.2f", results.duration) .. " seconds")
	
	-- Report to TestService for CI/CD integration
	if results.failureCount > 0 then
		TestService:Error("Tests failed: " .. results.failureCount .. " failures")
	else
		TestService:Message("All tests passed!")
	end
	
	return results
end

-- Function to run specific test suites
local function runTestSuite(suiteName)
	print("🧪 Running test suite: " .. suiteName)
	
	local testPath
	if suiteName == "CatService" then
		testPath = ServerScriptService:WaitForChild("ServerSource"):WaitForChild("Tests"):WaitForChild("CatServiceTests")
	elseif suiteName == "CatController" then
		testPath = ReplicatedStorage:WaitForChild("SharedSource"):WaitForChild("Tests"):WaitForChild("CatControllerTests")
	elseif suiteName == "Data" then
		testPath = ReplicatedStorage:WaitForChild("SharedSource"):WaitForChild("Tests"):WaitForChild("DataTests")
	else
		print("❌ Unknown test suite: " .. suiteName)
		return
	end
	
	if not testPath then
		print("❌ Test suite not found: " .. suiteName)
		return
	end
	
	local results = TestEZ.TestBootstrap:run({testPath}, TestEZ.Reporters.TextReporter)
	
	print("📊 " .. suiteName .. " Test Results:")
	print("✅ Passed: " .. results.successCount)
	print("❌ Failed: " .. results.failureCount)
	
	return results
end

-- Performance testing function
local function runPerformanceTests()
	print("⚡ Running Performance Tests...")
	
	-- This would run performance benchmarks
	-- For now, just a placeholder
	print("📈 Performance tests not yet implemented")
	
	return {
		successCount = 0,
		failureCount = 0,
		duration = 0
	}
end

-- Main test execution
local function main()
	-- Wait a bit for game to initialize
	task.wait(2)
	
	-- Check if we should run tests
	local runTests = game:GetService("RunService"):IsStudio()
	
	if runTests then
		print("🏃‍♂️ TestRunner initialized in Studio mode...")
		print("📝 Note: TestEZ framework is disabled due to compatibility issues")
		print("🎮 Use in-game test runners instead:")
		print("   - /runtests (server tests)")
		print("   - /clienttests (client tests)")
		print("   - /spawncat [profile] [count] (manual testing)")
		
		-- Don't auto-run tests due to TestEZ issues
		-- Use in-game test runners instead
	else
		print("🚫 Tests disabled in live game mode")
	end
end

-- Disable TestEZ execution to prevent "Malformed string" errors
-- The framework has compatibility issues with current test structure

-- Export functions for manual testing
return {
	runAllTests = runAllTests,
	runTestSuite = runTestSuite,
	runPerformanceTests = runPerformanceTests,
	main = main
}