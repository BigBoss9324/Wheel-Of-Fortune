local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Speeds
local walkSpeed = 16
local sprintSpeed = 28

-- Track if sprinting
local isSprinting = false

-- Update humanoid reference if character respawns
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end)

-- Input detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = true
		if humanoid then
			humanoid.WalkSpeed = sprintSpeed
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		isSprinting = false
		if humanoid then
			humanoid.WalkSpeed = walkSpeed
		end
	end
end)
