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
            QueueManager:removePlayer(plr, 1)
        end
    end
    QueueManager:ClearPlayers()
    return players
end

task.spawn(function()
    while true do
        local countdown = Config.COUNTDOWN_TIME
        local lastCountdownTime = Config.COUNTDOWN_TIME
        local lastPlayerMin = Config.MIN_PLAYERS
        while countdown > 0 do
            if Config.COUNTDOWN_TIME ~= lastCountdownTime then
                countdown = Config.COUNTDOWN_TIME
                lastCountdownTime = countdown
                Timer.Text = "Changing Timer to " .. tostring(Config.COUNTDOWN_TIME)
                task.wait(1.5)
            end
            if Config.MIN_PLAYERS ~= lastPlayerMin then
                lastPlayerMin = Config.MIN_PLAYERS
                Timer.Text = "Changing Min Player \n Requirement to " .. tostring(Config.MIN_PLAYERS)
                task.wait(1.5)
            end
            Timer.Text = formatTime(countdown)
            task.wait(1)
            local tone = game.Workspace.QueueFolder.Timer.Tone
            tone:Stop()
            tone:Play()
            countdown = countdown - 1
        end

        local teleporting = task.spawn(function()
            local count = 3
            local dots = {"", ".", "..", "..."}
            while count >= 0 do
                for _, suffix in ipairs(dots) do
                    Timer.Text = "Teleporting" .. suffix
                    task.wait(0.35)
                end
                count = count - 1
            end
        end)

        local playersToTeleport = getQueuedPlayers()
        if #playersToTeleport >= Config.MIN_PLAYERS then
            task.wait(1)

            local success, err = pcall(function()
                local reservedCode = TeleportService:ReserveServer(Config.PLACE_ID)
                TeleportService:TeleportToPrivateServer(Config.PLACE_ID, reservedCode, playersToTeleport)
            end)

            if not success then
                task.cancel(teleporting)
                Timer.Text = "Teleport Failed Due to an Error :/ \n" .. tostring(err)
                warn("Teleport failed:", err)
                task.wait(1)
            end

        else
            task.cancel(teleporting)
            Timer.Text = "Not enough players \n to teleport."
        end
        task.wait(1)
    end
end)

return Countdown
