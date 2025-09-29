local function componentsInitializer(selectedScript)
	for _,v in pairs(selectedScript.Components:GetDescendants()) do
		if v:IsA("ModuleScript") then
			local module = require(v)
			if typeof(module) ~= "function" then
				module.Init()
				task.spawn(function()
					module.Start()
				end)
			end
		end
	end
end

return componentsInitializer
