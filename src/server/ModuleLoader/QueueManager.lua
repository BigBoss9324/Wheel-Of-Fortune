local QueueManager = {}
local Players = game:GetService("Players")
local QueueFolder = game.Workspace:WaitForChild("QueueFolder")
local QueueCircle = QueueFolder:WaitForChild("QueueCircle")
local QueueLeave = QueueFolder:WaitForChild("QueueLeave")

local activePlayers = {}

local function removePlayer(plr, x)
	if activePlayers[plr] then
		activePlayers[plr] = nil
		print("Removed player from Queue:", plr.Name)
		if x ~= 1 then
			plr:FindFirstChild("HumanoidRootPart").CFrame = QueueLeave.CFrame
		end
	end
end

local function addPlayerToQueue(char)
	local plr = game.Players:GetPlayerFromCharacter(char)
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

function QueueManager:GetAllPlayers()
	return activePlayers
end

function QueueManager:ClearPlayers()
    for x in pairs(activePlayers) do
        activePlayers[x] = nil
    end
end

-- Debug Will remove
task.spawn(function()
	print("Queue server is running...")
	while true do
		print(os.date("%X"), "Active players:")
		for plr, _ in pairs(activePlayers) do
			print(" -", plr.Name)
		end
		task.wait(7.5)
	end
end)

return QueueManager