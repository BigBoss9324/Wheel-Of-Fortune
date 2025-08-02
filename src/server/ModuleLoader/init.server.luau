local ModuleLoader = script
for _, module in ipairs(ModuleLoader:GetChildren()) do
	if module:IsA("ModuleScript") then
		local success, err = pcall(function()
			return require(module)
		end)
		if not success then
			warn("Failed to load module: " .. module.Name .. " \nError:", err)
		end
	end
end

if game.PlaceId == 77660193270787 then
	script.Starting:Destroy()
	return
end