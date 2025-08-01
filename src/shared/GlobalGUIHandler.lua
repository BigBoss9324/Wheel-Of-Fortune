local GlobalGUIHandler = {}

local plr = game.Players.LocalPlayer

local function NoErr(fn, errMsg, errReturn)
    local suc, err = pcall(fn)
    if not suc then
        warn(errMsg, err)
        return errReturn
    end
    return err
end

function GlobalGUIHandler:GetGUIsWithTag(tagName)
    local CollectionService = game:GetService("CollectionService")
    local loaded = NoErr(function()
        local loadG = {}
        for _, item in ipairs(CollectionService:GetTagged(tagName)) do
            if item:IsA("GuiObject") then
                if item:IsDescendantOf(plr.PlayerGui) and not table.find(loadG, item) then
                    table.insert(loadG, item)
                end
            else
                if not table.find(loadG, item) then
                    table.insert(loadG, item)
                end
            end
        end
        return loadG
    end, "Error retrieving GUIs with tag: " .. tagName, nil)
    return loaded
end

local popups = {}
popups = GlobalGUIHandler:GetGUIsWithTag("popupGUI")

local GUIActivators = {}
GUIActivators = GlobalGUIHandler:GetGUIsWithTag("GUIActivator")

local test = {}
test = GlobalGUIHandler:GetGUIsWithTag("testGUI")

NoErr(function()
    for _, gui in ipairs(popups) do
        if gui:FindFirstChild("Close") and gui.Close:IsA("TextButton") then
            local x = function()
                gui.Visible = false
            end
            gui.MouseButton1Click:Connect(x)
            gui.Activated:Connect(x)
        end
    end
end, "Error handling popup GUI1: ")

NoErr(function()
    for _, gui in ipairs(popups) do
        local closeBtn = gui:FindFirstChild("Close")
        if closeBtn and (closeBtn:IsA("TextButton") or closeBtn:IsA("ImageButton")) then
            local debounce = false
            local function x()
                if debounce then
                    return
                end
                debounce = true
                gui.Visible = false
                task.delay(0.1, function()
                    debounce = false
                end)
            end
            closeBtn.MouseButton1Click:Connect(x)
            closeBtn.Activated:Connect(x)
        end
    end
end, "Error: ")

local function CheckForConfig(input)
    local config = input:FindFirstChild("Configuration")
    local target = config and config:GetAttribute("OpenGUI")

    if not target then
        warn("Activator does not have a valid 'Configuration' or 'OpenGUI' attribute.")
        return
    end
    return target
end

function GlobalGUIHandler:ActivateGUI(input, guiList)
    NoErr(function()
        local target = CheckForConfig(input)

        local targetGUI
        for _, gui in ipairs(guiList) do
            if gui:IsA("Frame") and gui.Name:lower():find(target:lower(), 1, true) then
                targetGUI = gui
                break
            end
        end

        if targetGUI then
            targetGUI.Visible = not targetGUI.Visible
        else
            warn("No popup GUI found matching: " .. tostring(target))
        end
    end, "Error: ")
end

function GlobalGUIHandler:HideOtherGUI(input, guiList)
    NoErr(function()
        local target = CheckForConfig(input)

        for _, gui in ipairs(guiList) do
            if gui:IsA("Frame") and not gui.Name:lower():find(target:lower(), 1, true) then
                gui.Visible = false
            end
        end
    end, "Error: ")
end

for _, Activator in ipairs(GUIActivators) do
    if Activator and typeof(Activator) == "Instance" then
        if Activator:IsA("TextButton") or Activator:IsA("ImageButton") then
            local debounce = false
            local function x()
                if debounce then
                    return
                end
                debounce = true
                GlobalGUIHandler:ActivateGUI(Activator, popups)
                GlobalGUIHandler:HideOtherGUI(Activator, popups)
                task.delay(0.1, function()
                    debounce = false
                end)
            end
            Activator.MouseButton1Click:Connect(x)
            Activator.Activated:Connect(x)
        else
            local ProximityPrompt = NoErr(function()
                return Activator:FindFirstChildOfClass("ProximityPrompt")
            end, "Activator does not have a ProximityPrompt", nil)

            if ProximityPrompt and ProximityPrompt:IsA("ProximityPrompt") then
                ProximityPrompt.Triggered:Connect(function(player)
                    GlobalGUIHandler:ActivateGUI(Activator, popups)
                    GlobalGUIHandler:HideOtherGUI(Activator, popups)
                end)
            end
        end
    end
end

return GlobalGUIHandler
