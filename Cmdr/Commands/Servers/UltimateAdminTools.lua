-- UltimateAdminTools.lua
-- Place in: ReplicatedStorage.Cmdr.Commands.Server

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local MessagingService = game:GetService("MessagingService")
local Debris = game:GetService("Debris")
local ChatService = game:GetService("Chat")

-- ===== Admin list =====
local Admins = {
    [] = true, -- replace with actual IDs
    [] = true,
}

-- ===== Global message helper =====
local function broadcastGlobalMessage(adminPlayer, msg)
    local text = string.format("[GLOBAL] (%s): %s", adminPlayer.Name, msg)
    pcall(function()
        MessagingService:PublishAsync("GlobalChat", text)
    end)
    for _, p in pairs(Players:GetPlayers()) do
        p:WaitForChild("PlayerGui")
        game.StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = text;
            Color = Color3.fromRGB(0, 200, 255);
            Font = Enum.Font.SourceSansBold;
            TextSize = 18;
        })
    end
end

pcall(function()
    MessagingService:SubscribeAsync("GlobalChat", function(msg)
        for _, p in pairs(Players:GetPlayers()) do
            p:WaitForChild("PlayerGui")
            game.StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = msg.Data;
                Color = Color3.fromRGB(0, 200, 255);
                Font = Enum.Font.SourceSansBold;
                TextSize = 18;
            })
        end
    end)
end)

-- ===== Spawn location =====
local spawnLocation = workspace:FindFirstChild("AdminSpawn") or Instance.new("Part")
spawnLocation.Name = "AdminSpawn"
spawnLocation.Anchored = true
spawnLocation.CanCollide = false
spawnLocation.Transparency = 1
spawnLocation.Parent = workspace

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if spawnLocation then
            char:SetPrimaryPartCFrame(spawnLocation.CFrame + Vector3.new(0,5,0))
        end
    end)
end)

-- ===== Command table =====
local commands = {}

-- ========== /fly ==========
commands.fly = {
    Name = "fly";
    Description = "Toggle fly mode";
    Group = "Admin";
    Run = function(context)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local player = context.Executor
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return "No character" end
        local hrp = char.HumanoidRootPart
        local existing = hrp:FindFirstChild("FlyForce")
        if existing then
            existing:Destroy()
            return "Fly disabled"
        else
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyForce"
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
            return "Fly enabled"
        end
    end
}

-- ========== /global ==========
commands.global = {
    Name = "global";
    Description = "Send global message to all servers (admins only)";
    Group = "Admin";
    Args = {{Type="string", Name="msg"}};
    Run = function(context, msg)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        broadcastGlobalMessage(context.Executor, msg)
        return "Message sent!"
    end
}

-- ========== /size ==========
commands.size = {
    Name = "size";
    Description = "Change character size";
    Group = "Admin";
    Args = {{Type="number", Name="percent"},{Type="player", Name="target", Optional=true}};
    Run = function(context, percent, targetPlayer)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        targetPlayer = targetPlayer or context.Executor
        local char = targetPlayer.Character
        if not char then return "No character" end
        local scale = percent/100
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
                part.Size = part.Size * scale
            end
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, prop in pairs({"BodyHeightScale","BodyWidthScale","BodyDepthScale"}) do
                if humanoid:FindFirstChild(prop) then
                    humanoid[prop].Value = humanoid[prop].Value * scale
                end
            end
        end
        return string.format("%s scaled to %d%%", targetPlayer.Name, percent)
    end
}

-- ========== /speed ==========
commands.speed = {
    Name = "speed";
    Description = "Change walk speed";
    Group = "Admin";
    Args = {{Type="number", Name="percent"},{Type="player", Name="target", Optional=true}};
    Run = function(context, percent, targetPlayer)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        targetPlayer = targetPlayer or context.Executor
        local char = targetPlayer.Character
        if not char then return "No character" end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * percent/100
            return string.format("%s speed set to %d%% (%d)", targetPlayer.Name, percent, humanoid.WalkSpeed)
        end
        return "No humanoid"
    end
}

-- ========== /sky ==========
commands.sky = {
    Name = "sky";
    Description = "Change sky/lighting";
    Group = "Admin";
    Args = {{Type="string", Name="preset"}};
    Run = function(context, preset)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        preset = preset:lower()
        local Presets = {
            normal=function() Lighting.ClockTime=14; Lighting.FogColor=Color3.fromRGB(192,192,255); Lighting.OutdoorAmbient=Color3.fromRGB(128,128,128); Lighting.Sky=nil end,
            ["7pm"]=function() Lighting.ClockTime=19; Lighting.FogColor=Color3.fromRGB(255,100,50) end,
            ["3am"]=function() Lighting.ClockTime=3; Lighting.FogColor=Color3.fromRGB(50,50,100) end,
            space=function() local sky=Instance.new("Sky"); sky.Parent=Lighting; Lighting.ClockTime=0; Lighting.FogColor=Color3.new(0,0,0) end
        }
        local colorMap = {red=Color3.fromRGB(255,0,0),blue=Color3.fromRGB(0,0,255),green=Color3.fromRGB(0,255,0),purple=Color3.fromRGB(128,0,128),yellow=Color3.fromRGB(255,255,0)}
        if preset=="random" then
            Lighting.FogColor=Color3.new(math.random(),math.random(),math.random())
            Lighting.OutdoorAmbient=Color3.new(math.random(),math.random(),math.random())
            return "Sky set to random"
        elseif Presets[preset] then
            Presets[preset]()
            return "Sky set to "..preset
        elseif colorMap[preset] then
            Lighting.FogColor=colorMap[preset]
            Lighting.OutdoorAmbient=colorMap[preset]*0.5
            return "Sky color set to "..preset
        else
            return "Unknown preset"
        end
    end
}

-- ========== /jump_ragdoll ==========
commands.jump_ragdoll = {
    Name="jump_ragdoll";
    Description="Set jump or ragdoll yourself/others";
    Group="Admin";
    Args={{Type="string", Name="action"},{Type="number", Name="value", Optional=true},{Type="player", Name="target", Optional=true}};
    Run=function(context, action, value, targetPlayer)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        targetPlayer = targetPlayer or context.Executor
        local char = targetPlayer.Character
        if not char then return "No character" end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return "No humanoid" end
        action=action:lower()
        if action=="jump" then
            if not value then value=50 end
            humanoid.JumpPower=value
            return string.format("%s jump set to %d", targetPlayer.Name, value)
        elseif action=="ragdoll" then
            humanoid.PlatformStand=true
            delay(5,function() humanoid.PlatformStand=false end)
            return string.format("%s ragdolled!", targetPlayer.Name)
        else return "Invalid action" end
    end
}

-- ========== /jail ==========
commands.jail={
    Name="jail";
    Description="Trap a player in a cage";
    Group="Admin";
    Args={{Type="player",Name="target"},{Type="number",Name="duration"}};
    Run=function(context,targetPlayer,duration)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        duration=duration or 10
        if not targetPlayer then return "No target" end
        local char=targetPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return "No character" end
        local hrp=char.HumanoidRootPart
        local walls={}
        local function makeWall(pos) local p=Instance.new("Part");p.Anchored=true;p.CanCollide=true;p.Size=Vector3.new(6,10,1);p.Position=pos;p.Color=Color3.fromRGB(50,50,50);p.Parent=workspace;table.insert(walls,p);Debris:AddItem(p,duration) end
        local center=hrp.Position
        makeWall(center+Vector3.new(3.5,5,0))
        makeWall(center+Vector3.new(-3.5,5,0))
        makeWall(center+Vector3.new(0,5,3.5))
        makeWall(center+Vector3.new(0,5,-3.5))
        local ceil=Instance.new("Part");ceil.Anchored=true;ceil.CanCollide=true;ceil.Size=Vector3.new(6,1,6);ceil.Position=center+Vector3.new(0,10,0);ceil.Color=Color3.fromRGB(50,50,50);ceil.Parent=workspace;Debris:AddItem(ceil,duration)
        return string.format("%s jailed for %d seconds", targetPlayer.Name,duration)
    end
}

-- ========== /randomtp ==========
commands.randomtp={
    Name="randomtp";
    Description="Teleport player/mob to random location";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,targetPlayer)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char=targetPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return "No character" end
        local minPos, maxPos=Vector3.new(-100,5,-100), Vector3.new(100,50,100)
        local x=math.random(minPos.X,maxPos.X)
        local y=math.random(minPos.Y,maxPos.Y)
        local z=math.random(minPos.Z,maxPos.Z)
        char.HumanoidRootPart.CFrame=CFrame.new(x,y,z)
        return string.format("%s teleported randomly", targetPlayer.Name)
    end
}

-- ========== /spectate ==========
local spectating={}
commands.spectate={
    Name="spectate";
    Description="Spectate a player/entity";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,targetPlayer)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local cam=workspace.CurrentCamera
        if targetPlayer and targetPlayer.Character and targetPlayer.Character.PrimaryPart then
            cam.CameraType=Enum.CameraType.Scriptable
            cam.CFrame=targetPlayer.Character.PrimaryPart.CFrame
            spectating[context.Executor]=targetPlayer
            return string.format("Spectating %s", targetPlayer.Name)
        end
    end
}

commands.unspectate={
    Name="unspectate";
    Description="Stop spectating";
    Group="Admin";
    Run=function(context)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local cam=workspace.CurrentCamera
        cam.CameraType=Enum.CameraType.Custom
        spectating[context.Executor]=nil
        return "Stopped spectating"
    end
}

-- ========== /setspawn ==========
commands.setspawn={
    Name="setspawn";
    Description="Set spawn location for new players";
    Group="Admin";
    Run=function(context)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char=context.Executor.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            spawnLocation.CFrame=char.HumanoidRootPart.CFrame
            return "Spawn location set!"
        end
        return "No character"
    end
}

-- ========== /tpto ==========
commands.tpto={
    Name="tpto";
    Description="Teleport admin to a player";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,targetPlayer)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local adminChar=context.Executor.Character
        if adminChar and adminChar:FindFirstChild("HumanoidRootPart") and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            adminChar.HumanoidRootPart.CFrame=targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
            return string.format("Teleported to %s", targetPlayer.Name)
        end
        return "Teleport failed"
    end
}

-- ========== /tpbring ==========
commands.tpbring={
    Name="tpbring";
    Description="Teleport player to admin";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,targetPlayer)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local adminChar=context.Executor.Character
        if adminChar and adminChar:FindFirstChild("HumanoidRootPart") and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            targetPlayer.Character.HumanoidRootPart.CFrame=adminChar.HumanoidRootPart.CFrame + Vector3.new(0,5,0)
            return string.format("%s brought to you", targetPlayer.Name)
        end
        return "Teleport failed"
    end
}

-- ========== /say ==========
commands.say={
    Name="say";
    Description="Make a player appear to say a message";
    Group="Admin";
    Args={{Type="player",Name="target"},{Type="string",Name="message"}};
    Run=function(context,targetPlayer,message)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        if targetPlayer and message and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
            ChatService:Chat(targetPlayer.Character.Head,message,Enum.ChatColor.Blue)
            return string.format("%s said: %s", targetPlayer.Name,message)
        end
        return "Failed"
    end
}

-- Return commands table
return commands
