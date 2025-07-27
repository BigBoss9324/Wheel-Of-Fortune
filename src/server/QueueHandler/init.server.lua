local QueueHandler = script.Parent
for _, x in ipairs(QueueHandler:GetChildren()) do
    if x:IsA("ModuleScript") then
        require(x)
    end
end