local Countdown = {}
local TeleportService = game:GetService("TeleportService")
local Config = require(script.Parent.QueueConfig)
local QueueManager = require(script.Parent.QueueManager)
local Timer = game.Workspace.QueueFolder.Timer.T.SurfaceGui.Time

local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d", minutes, secs)
end

-- Gets all active players in queue
local function getQueuedPlayers()
	local players = {}
	for plr, _ in pairs(QueueManager:GetAllPlayers()) do
		if plr and plr:IsDescendantOf(game.Players) then
			table.insert(players, plr)
		end
	end
	print("Total queued players:", #players)
	print("Players \n", players)
	return players
end

task.spawn(function()
	while true do
		local countdown = Config.COUNTDOWN_TIME
		while countdown > 0 do
			Timer.Text = formatTime(countdown)
			task.wait(1)
			countdown = countdown - 1
		end
		Timer.Text = "00:00"
		print("Countdown complete. Checking for queued players...")
		local playersToTeleport = getQueuedPlayers()
		if #playersToTeleport > 0 then
			print("Teleporting", #playersToTeleport, "players...")
			task.wait(1) -- wait a sec for UI clarity
			TeleportService:TeleportPartyAsync(Config.PLACE_ID, playersToTeleport)
		else
			warn("No players to teleport.")
		end
		task.wait(3)
	end
end)

return Countdown