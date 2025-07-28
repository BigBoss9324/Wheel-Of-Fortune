local ModuleLoader = script
for _, module in ipairs(ModuleLoader:GetChildren()) do
	if module:IsA("ModuleScript") then
		local success, result = pcall(function()
			return require(module)
		end)
		if success then
			print("Successfully loaded:", module.Name)
		else
			warn("Failed to load module:", module.Name, "\nError:", result)
		end
	end
end