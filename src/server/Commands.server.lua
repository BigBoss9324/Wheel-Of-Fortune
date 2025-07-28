-- Made by BigBoss9324 690634329591906316 --
local Admins = {267811095}

local Prefix = ":"

local Commands = {
    respawn = function(plr, args)
        plr:LoadCharacter()
    end,
    kill = function(plr, args)
        if args[1] and args[1] ~= "" then
            local targetName = string.lower(args[1])
            local y = nil
            for _, x in ipairs(game.Players:GetPlayers()) do
                if string.find(string.lower(x.Name), targetName, 1, true) then
                    y = x
                    break
                end
            end
            if y then
                plr = y
            else
                warn("Player not found:", args[1])
                return
            end
        end
        local char = plr.Character
        if char then
            char:BreakJoints()
        end
    end,
    refresh = function(plr, args)
        local pos = plr.Character:GetPrimaryPartCFrame()
        plr:LoadCharacter()
        plr.Character:SetPrimaryPartCFrame(pos)
        if plr.Character:FindFirstChild("ForceField") then
            plr.Character["ForceField"]:Destroy()
        end
    end,
    settime = function(plr, args)
        local QueueConfig = require(game.ServerScriptService.ModuleLoader.QueueConfig)
        if tonumber(args[1]) == nil then
            return
        end
        QueueConfig.COUNTDOWN_TIME = tonumber(args[1])
    end,
    setminplayers = function(plr, args)
        print("Setting Min Players:", args[1])
        print(args)
        local QueueConfig = require(game.ServerScriptService.ModuleLoader.QueueConfig)
        if tonumber(args[1]) == nil then
            return
        end
        QueueConfig.MIN_PLAYERS = tonumber(args[1])
    end
}

local function onChatted(plr, msg)
    if string.sub(msg, 1, 1) ~= Prefix then
        return
    end
    msg = string.sub(msg, 2)

    local args = string.split(msg, " ")
    local command = table.remove(args, 1)
    if Commands[command] then
        Commands[command](plr, args)
    end
end

local function isAdmin(plr)
    for _, id in ipairs(Admins) do
        if plr.UserId == id then
            return true
        end
    end
    return false
end

game.Players.PlayerAdded:Connect(function(plr)
    if not isAdmin(plr) then
        return
    end
    plr.Chatted:Connect(function(msg)
        onChatted(plr, msg)
    end)
end)
