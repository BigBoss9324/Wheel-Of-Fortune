local Countdown = {}
local TeleportService = game:GetService("TeleportService")
local Config = require(script.Parent.QueueConfig)
local QueueManager = require(script.Parent.QueueManager)
local Timer = game.Workspace.QueueFolder.Timer.Display.SurfaceGui.Time

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
    QueueManager:ClearPlayers()
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
        Timer.Text = "Teleporting..."
        local playersToTeleport = getQueuedPlayers()
        if #playersToTeleport >= Config.MIN_PLAYERS then
            task.wait(1)
            local success, err = pcall(function()
                TeleportService:TeleportPartyAsync(Config.PLACE_ID, playersToTeleport)
            end)
            if not success then
                warn("Teleport failed:", err)
            end
        else
            Timer.Text = "Not enough players to teleport."
            print("Not enough players to teleport.")
        end
        task.wait(2)
    end
end)

return Countdown
