-- chaos_admin.lua
-- Admin-only fun/chaotic commands

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Admins = {
    []=true,
    []=true,
}

-- Keep track of ongoing commands
local ongoingKill = {}

local function getChar(player)
    return player.Character
end

-- ====================== Commands ======================

local commands = {}

-- ===== ForceField =====
commands.forcefield = {
    Name="forcefield";
    Description="Activate a forcefield around a player";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char then
            local ff = Instance.new("ForceField")
            ff.Parent = char
            return string.format("ForceField added to %s", target.Name)
        end
        return "No character"
    end
}

-- ===== Sparkle =====
commands.sparkle = {
    Name="sparkle";
    Description="Add a sparkle effect to a player";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    local sparkle = Instance.new("Sparkles")
                    sparkle.Parent = part
                end
            end
            return string.format("Sparkles added to %s", target.Name)
        end
        return "No character"
    end
}

-- ===== Continuous Kill =====
commands.killloop = {
    Name="killloop";
    Description="Continuously kills a player until stopped";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        ongoingKill[target] = true
        spawn(function()
            while ongoingKill[target] do
                local char = getChar(target)
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Health = 0
                    end
                end
                wait(1)
            end
        end)
        return string.format("Continuous kill started on %s", target.Name)
    end
}

commands.stopkill = {
    Name="stopkill";
    Description="Stop continuous kill on a player";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        ongoingKill[target] = false
        return string.format("Continuous kill stopped on %s", target.Name)
    end
}

-- ===== Random Teleport =====
commands.randomtp = {
    Name="randomtp";
    Description="Teleport player to random location";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = Vector3.new(math.random(-100,100),math.random(5,50),math.random(-100,100))
            char.HumanoidRootPart.CFrame = CFrame.new(pos)
            return string.format("%s teleported randomly", target.Name)
        end
        return "No character"
    end
}

-- ===== Skyrocket =====
commands.skyrocket = {
    Name="skyrocket";
    Description="Launch a player into the sky and explode";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            hrp.Velocity = Vector3.new(0,200,0)
            wait(2)
            local explosion = Instance.new("Explosion")
            explosion.Position = hrp.Position
            explosion.Parent = workspace
            return string.format("%s rocketed and exploded!", target.Name)
        end
        return "No character"
    end
}

-- ===== Zombie Infection =====
commands.zombie = {
    Name="zombie";
    Description="Turn player into an infectious zombie";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.BrickColor = BrickColor.new("Bright green")
                end
            end
            return string.format("%s turned into zombie!", target.Name)
        end
        return "No character"
    end
}

-- ===== Invincible =====
commands.invincible = {
    Name="invincible";
    Description="Make a player invincible";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = math.huge
                humanoid.Health = math.huge
                return string.format("%s is now invincible", target.Name)
            end
        end
        return "No character"
    end
}

-- ===== Head Size =====
commands.headsize = {
    Name="headsize";
    Description="Change a player's head size";
    Group="Admin";
    Args={{Type="player",Name="target"},{Type="number",Name="size"}};
    Run=function(context,target,size)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        local head = char and char:FindFirstChild("Head")
        if head then
            head.Size = Vector3.new(size,size,size)
            return string.format("%s head size set to %d", target.Name,size)
        end
        return "No character"
    end
}

-- ===== Immobilize =====
commands.freeze = {
    Name="freeze";
    Description="Immobilize a player";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                return string.format("%s immobilized", target.Name)
            end
        end
        return "No character"
    end
}

-- ===== Invisible =====
commands.invisible = {
    Name="invisible";
    Description="Make a player's avatar invisible";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char then
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
            return string.format("%s is now invisible", target.Name)
        end
        return "No character"
    end
}

-- ===== Explosion =====
commands.explode = {
    Name="explode";
    Description="Cause a player to explode";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local explosion = Instance.new("Explosion")
            explosion.Position = char.HumanoidRootPart.Position
            explosion.Parent = workspace
            return string.format("%s exploded!", target.Name)
        end
        return "No character"
    end
}

-- ===== Lightning Strike =====
commands.lightning = {
    Name="lightning";
    Description="Strike a player with lightning";
    Group="Admin";
    Args={{Type="player",Name="target"}};
    Run=function(context,target)
        if not Admins[context.Executor.UserId] then return "Not admin" end
        local char = getChar(target)
        if char and char:FindFirstChild("HumanoidRootPart") then
            local lightning = Instance.new("Part")
            lightning.Anchored = true
            lightning.CanCollide = false
            lightning.Size = Vector3.new(1,1,1)
            lightning.Position = char.HumanoidRootPart.Position + Vector3.new(0,50,0)
            lightning.BrickColor = BrickColor.new("Bright yellow")
            lightning.Material = Enum.Material.Neon
            lightning.Parent = workspace
            Debris:AddItem(lightning,1)
            local explosion = Instance.new("Explosion")
            explosion.Position = char.HumanoidRootPart.Position
            explosion.Parent = workspace
            return string.format("%s struck by lightning!", target.Name)
        end
        return "No character"
    end
}

return commands
