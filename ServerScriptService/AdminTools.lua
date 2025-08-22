-- AdminTools.lua (put in ServerScriptService)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== Admin List =====
local Admins = {
    [] = true, -- replace with your UserIds
    [] = true,
}

-- ===== RemoteEvent and RemoteFunction =====
local event = ReplicatedStorage:FindFirstChild("AdminToolsEvent")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "AdminToolsEvent"
    event.Parent = ReplicatedStorage
end

local isAdminFunc = ReplicatedStorage:FindFirstChild("IsAdmin")
if not isAdminFunc then
    isAdminFunc = Instance.new("RemoteFunction")
    isAdminFunc.Name = "IsAdmin"
    isAdminFunc.Parent = ReplicatedStorage
end

isAdminFunc.OnServerInvoke = function(player)
    return Admins[player.UserId] == true
end

-- ===== Global Chat via MessagingService =====
event.OnServerEvent:Connect(function(player, data)
    if not Admins[player.UserId] then return end

    if data.Type == "GlobalMessage" then
        local msg = string.format("[GLOBAL] (%s): %s", player.Name, data.Text)

        -- broadcast to all servers
        pcall(function()
            MessagingService:PublishAsync("GlobalChat", msg)
        end)

        -- show instantly in this server
        for _, p in pairs(Players:GetPlayers()) do
            p:WaitForChild("PlayerGui")
            game.StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = msg;
                Color = Color3.fromRGB(0, 200, 255);
                Font = Enum.Font.SourceSansBold;
                TextSize = 18;
            })
        end
    elseif data.Type == "FlyToggle" then
        -- Toggle flight
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = character.HumanoidRootPart
        local existing = hrp:FindFirstChild("FlyForce")

        if existing then
            existing:Destroy()
        else
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyForce"
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end
    end
end)

-- Subscribe to messages from other servers
pcall(function()
    MessagingService:SubscribeAsync("GlobalChat", function(message)
        for _, p in pairs(Players:GetPlayers()) do
            p:WaitForChild("PlayerGui")
            game.StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = message.Data;
                Color = Color3.fromRGB(0, 200, 255);
                Font = Enum.Font.SourceSansBold;
                TextSize = 18;
            })
        end
    end)
end)

-- ===== Client setup for each admin =====
Players.PlayerAdded:Connect(function(player)
    if not Admins[player.UserId] then return end

    local playerScripts = player:WaitForChild("PlayerScripts")
    if playerScripts:FindFirstChild("AdminToolsClient") then return end

    local localScript = Instance.new("LocalScript")
    localScript.Name = "AdminToolsClient"
    localScript.Source = [[
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local player = Players.LocalPlayer

        local event = ReplicatedStorage:WaitForChild("AdminToolsEvent")
        local gui = Instance.new("ScreenGui")
        gui.Name = "AdminToolsGui"
        gui.ResetOnSpawn = false
        gui.Parent = player:WaitForChild("PlayerGui")

        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(0, 300, 0, 40)
        TextBox.Position = UDim2.new(0.5, -150, 1, -60)
        TextBox.PlaceholderText = "Enter global message..."
        TextBox.Text = ""
        TextBox.TextScaled = true
        TextBox.Visible = false
        TextBox.Parent = gui

        -- Toggle GUI with G
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.G then
                TextBox.Visible = not TextBox.Visible
                if TextBox.Visible then TextBox:CaptureFocus() else TextBox:ReleaseFocus() end
            end
        end)

        -- Send global message on Enter
        TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and TextBox.Text ~= "" then
                event:FireServer({Type = "GlobalMessage", Text = TextBox.Text})
                TextBox.Text = ""
            end
        end)

        -- Flight movement
        RunService.RenderStepped:Connect(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart
            local bv = hrp:FindFirstChild("FlyForce")
            if bv then
                local cam = workspace.CurrentCamera
                local dir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
                bv.Velocity = dir.Magnitude > 0 and dir.Unit * 50 or Vector3.zero
            end
        end)

        -- Toggle flight with F key
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.F then
                event:FireServer({Type = "FlyToggle"})
            end
        end)
    ]]
    localScript.Parent = playerScripts
end)
