local Countdown = {}

local CS = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local DataStoreService = game:GetService("DataStoreService")
local ServerAccessCodes = DataStoreService:GetDataStore("ServerCodeData")

local Config = require(script.Parent.QueueConfig)
local QueueManager = require(script.Parent.QueueManager)

local function NoErr(fn, errMsg, errReturn)
    local suc, err = pcall(fn)
    if not suc then
        warn(errMsg, err)
        return errReturn
    end
    return err
end

local function GetTag(tagName)
    local loaded = NoErr(function()
        local loadG = {}
        for _, item in ipairs(CS:GetTagged(tagName)) do
            if item:IsA("TextLabel") then
                if not table.find(loadG, item) then
                    table.insert(loadG, item)
                end
            end
        end
        return loadG
    end, "Error retrieving GUIs with tag: " .. tagName, nil)
    return loaded
end

local function formatTime(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

local timer = {}
timer = GetTag("timerText")
local function updateAllTimers(text)
    for _, t in ipairs(timer) do
        t.Text = text
    end
end

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

local function teleportPlayers()
    local count = 3
    local teleporting = task.spawn(function()
        local dots = {"", ".", "..", "..."}
        while count >= 0 do
            for _, suffix in ipairs(dots) do
                updateAllTimers("Teleporting" .. suffix)
                task.wait(0.35)
            end
            count = count - 1
        end
    end)

    local playersToTeleport = getQueuedPlayers()
    if #playersToTeleport >= Config.MIN_PLAYERS then
        task.wait(0.2)

        local success, err = pcall(function()
            local teleportOptions = Instance.new("TeleportOptions")

            local teleportData = {
                PlayersCount = #playersToTeleport,
            }

            teleportOptions.ShouldReserveServer = true
            teleportOptions:SetTeleportData(teleportData)
            local teleportAsyncResult = TeleportService:TeleportAsync(Config.PLACE_ID, {playersToTeleport}, teleportOptions)

            -- Testing
            ServerAccessCodes:SetAsync(teleportAsyncResult.ReservedServerAccessCode, teleportAsyncResult.PrivateServerId)
        end)

        if not success then
            task.cancel(teleporting)
            updateAllTimers("Teleport Failed Due to an Error :/ \n" .. tostring(err))
            warn("Teleport failed:", err)
            task.wait(1)
        end

    else
        task.cancel(teleporting)
        updateAllTimers("Not enough players \n to teleport.")
    end
end

local function playTone()
	local tone = game.Workspace.QueueFolder:FindFirstChild("Tone")
	if tone and tone:IsA("Sound") then
		tone:Stop()
		tone:Play()
	end
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
                updateAllTimers("Changing Timer to " .. tostring(Config.COUNTDOWN_TIME))
                task.wait(1.5)
            end
            if Config.MIN_PLAYERS ~= lastPlayerMin then
                lastPlayerMin = Config.MIN_PLAYERS
                updateAllTimers("Changing Min Player \n Requirement to " .. tostring(Config.MIN_PLAYERS))
                task.wait(1.5)
            end
            updateAllTimers(formatTime(countdown))
            task.wait(1)
            playTone()
            countdown = countdown - 1
        end

        teleportPlayers()
        task.wait(2.5)
    end
end)

return Countdown