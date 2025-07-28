-- Made by BigBoss9324 690634329591906316 --
local Admins = {267811095}

local Prefix = ":"

local Commands = {
    settime = function(plr, args)
        local QueueConfig = require(game.ServerScriptService.QueueLoader.QueueConfig)
        if tonumber(args[1]) == nil then
            return
        end
        QueueConfig.COUNTDOWN_TIME = tonumber(args[1])
    end,
    setminplayers = function(plr, args)
        print("Setting Min Players:", args[1])
        print(args)
        local QueueConfig = require(game.ServerScriptService.QueueLoader.QueueConfig)
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
