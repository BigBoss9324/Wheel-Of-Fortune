local Players = game:GetService("Players")
local QueueFolder = game.Workspace:WaitForChild("QueueFolder")
local QueueCircle = QueueFolder:WaitForChild("QueueCircle")
local QueueLeave = QueueFolder:WaitForChild("QueueLeave")

activePlayers = {}

local function removePlayer(plr, x)
	if activePlayers[plr] then
		activePlayers[plr] = nil
		print("Removed player from Queue:", plr.Name)
		if x ~= 1 then
			plr:FindFirstChild("HumanoidRootPart").CFrame = QueueLeave.CFrame
		end
	end
end

local function addPlayerToQueue(plr)
    print("Adding player to matchmaking folder:", plr.Name)
    if not activePlayers[plr] then
        activePlayers[plr] = plr
        local humanoid = plr:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                removePlayer(plr, 1)
            end)
        end-- Ensure the player is fully added before any further actions
    end
end

QueueCircle.Touched:Connect(function(hit)
	local plr = hit.Parent
	if not plr or not plr:FindFirstChild("Humanoid") then return end
    if activePlayers[plr] then return end
	addPlayerToQueue(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
	print("Player leaving:", plr.Name)
	removePlayer(plr, 1)
end)

--Debug Will remove
while true do
	print("Queue server is running...", os.date("%X"))
	print("Active players:")
	for plr, _ in pairs(activePlayers) do
		print(" -", plr.Name)
	end
	task.wait(7.5)
end

return activePlayers