if game.PlaceId ~= 98028268871340 then
	script.Enabled = false
	return
end

local Players = game:GetService("Players")
local arrivedPlayers = 0
local expectedPlayers = 5 -- fallback
local fallbackTriggered = false
local Fallback = 10

-- Fallback after 60 seconds if not all players arrive
task.delay(Fallback, function()
	fallbackTriggered = true
	print("Fallback triggered: Not all players arrived in time.")
end)

-- Track joined players and get teleport data
Players.PlayerAdded:Connect(function(player)
	local joinData = player:GetJoinData()
	local teleportData = joinData.TeleportData

	if teleportData and teleportData.PlayersCount then
		expectedPlayers = teleportData.PlayersCount
	end

	arrivedPlayers = arrivedPlayers + 1
	print(player.Name .. " joined. ArrivedPlayers: " .. arrivedPlayers .. "/" .. math.floor(expectedPlayers * 0.75))
end)

-- Wait until enough players arrive or fallback is triggered
task.spawn(function()
	while arrivedPlayers < math.floor(expectedPlayers * 0.75) and not fallbackTriggered do
		task.wait(0.25)
	end

	print("Player load complete. Starting game with " .. arrivedPlayers .. " players.")
	-- Continue with game/cutscene/etc.
end)
