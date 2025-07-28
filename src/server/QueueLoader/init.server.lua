if game.PlaceId ~= 77660193270787 then
	script:Destroy()
	return
end

local QueueLoader = script
for _, module in ipairs(QueueLoader:GetChildren()) do
	if module:IsA("ModuleScript") then
		local success, result = pcall(function()
			return require(module)
		end)
		if not success then
			warn("Failed to load module:", module.Name, "\nError:", result)
		end
	end
end