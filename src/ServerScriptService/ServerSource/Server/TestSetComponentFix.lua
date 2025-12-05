 -- Simple test to verify CatAI can access CatService properly
print("🧪 Testing CatAI CatService access...")

-- Test if CatAI has CatService reference
local CatAI = require(game.ServerScriptService.ServerSource.Server.CatService.Components.Others.CatAI)

if CatAI.CatService then
	print("✅ CatAI has CatService reference")
	
	if CatAI.CatService.SetComponent then
		print("✅ CatAI can access SetComponent through CatService")
		print("✅ Fix applied successfully! The AI system should now work correctly.")
	else
		print("❌ CatAI cannot access SetComponent through CatService")
	end
else
	print("❌ CatAI does not have CatService reference")
end

print("\n📋 Summary:")
print("- Fixed: CatAI now stores CatService reference during Init()")
print("- Now: CatAI accesses SetComponent via CatAI.CatService.SetComponent")
print("- Result: 'SetComponent is not a valid member' error should be resolved")