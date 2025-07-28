local QueueManager = {}

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local QueueFolder = game.Workspace:WaitForChild("QueueFolder")
local QueueCircle = QueueFolder:WaitForChild("QueueCircle")

local activePlayers = {}

function QueueManager:removePlayer(plr, x)
    if activePlayers[plr] then
        activePlayers[plr] = nil
        RS.RemoteEvents.Queue:FireClient(plr, "0")
        if x ~= 1 then
            local validPoints = {}

            for _, x in ipairs(QueueFolder.QueueLeave:GetChildren()) do
                if x:IsA("Part") and x.Name:find("LeavePoint") then
                    table.insert(validPoints, x)
                end
            end

            if #validPoints > 0 and plr.Character:FindFirstChild("HumanoidRootPart") then
                local chosen = validPoints[math.random(#validPoints)]
                plr.Character.HumanoidRootPart.CFrame = chosen.CFrame
            end
        end
    end
end

local function addPlayerToQueue(char)
    local plr = game.Players:GetPlayerFromCharacter(char)
    if not activePlayers[plr] then
        activePlayers[plr] = plr
        local humanoid = plr:FindFirstChild("Humanoid")
        RS.RemoteEvents.Queue:FireClient(plr, "1")
        if humanoid then
            humanoid.Died:Connect(function()
                QueueManager:removePlayer(plr, 1)
            end)
        end
    end
end

QueueCircle.Touched:Connect(function(hit)
    local plr = Players:GetPlayerFromCharacter(hit.Parent)
    if plr and not activePlayers[plr] then
        addPlayerToQueue(hit.Parent)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    print("Player leaving:", plr.Name)
    QueueManager:removePlayer(plr, 1)
end)

function QueueManager:GetAllPlayers()
    return activePlayers
end

function QueueManager:ClearPlayers()
    for x in pairs(activePlayers) do
        activePlayers[x] = nil
    end
end

RS.RemoteEvents.Queue.OnServerEvent:Connect(function(plr, x)
    if x == "1" then
        return QueueManager:removePlayer(plr)
    end
end)

-- Debug Will remove
-- task.spawn(function()
--     print("Queue server is running...")
--     while true do
--         print(os.date("%X"), "Active players:")
--         for plr, _ in pairs(activePlayers) do
--             print(" -", plr.Name)
--         end
--         task.wait(7.5)
--     end
-- end)

return QueueManager
