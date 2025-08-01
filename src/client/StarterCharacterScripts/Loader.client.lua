local RR = game.ReplicatedStorage
for _, module in ipairs(RR:GetChildren()) do
	if module:IsA("ModuleScript") then
		local success, err = pcall(function()
			return require(module)
		end)
		if not success then
			warn("Failed to load module:", module.Name, "\nError:", err)
		end
	end
end