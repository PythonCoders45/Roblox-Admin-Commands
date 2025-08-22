-- jail.lua

local Players = game:GetService("Players")
local Debris = game:GetService("Debris") -- auto-remove temporary objects

-- Admin list (UserIds)
local Admins = {
    [12345678] = true, -- replace with actual IDs
    [87654321] = true,
}

-- Function to create a temporary jail around a player
local function jailPlayer(targetPlayer, duration)
    local character = targetPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart

    -- Create jail parts (4 walls + top)
    local size = Vector3.new(6, 10, 6)
    local jailParts = {}

    local function makePart(pos)
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = true
        part.Size = Vector3.new(6, 10, 1)
        part.Position = pos
        part.Color = Color3.fromRGB(50, 50, 50)
        part.Parent = workspace
        table.insert(jailParts, part)
        Debris:AddItem(part, duration) -- remove after duration
    end

    local center = hrp.Position

    -- Four walls
    makePart(center + Vector3.new(3.5, 5, 0)) -- right
    makePart(center + Vector3.new(-3.5, 5, 0)) -- left
    makePart(center + Vector3.new(0, 5, 3.5)) -- front
    makePart(center + Vector3.new(0, 5, -3.5)) -- back
    -- Ceiling
    local ceiling = Instance.new("Part")
    ceiling.Anchored = true
    ceiling.CanCollide = true
    ceiling.Size = Vector3.new(6, 1, 6)
    ceiling.Position = center + Vector3.new(0, 10, 0)
    ceiling.Color = Color3.fromRGB(50, 50, 50)
    ceiling.Parent = workspace
    table.insert(jailParts, ceiling)
    Debris:AddItem(ceiling, duration)
end

return {
    Name = "jail";
    Aliases = {};
    Description = "Trap a player in a jail for a certain duration (seconds).";
    Group = "Admin"; -- admin only
    Args = {
        {
            Type = "player";
            Name = "target";
            Description = "Player to jail";
        },
        {
            Type = "number";
            Name = "duration";
            Description = "Duration in seconds";
        }
    };

    Run = function(context, targetPlayer, duration)
        local executor = context.Executor
        if not Admins[executor.UserId] then
            return "You are not an admin."
        end

        if not targetPlayer then return "No target player provided." end
        if not duration or duration <= 0 then duration = 10 end -- default 10 sec

        jailPlayer(targetPlayer, duration)
        return string.format("%s has been jailed for %d seconds!", targetPlayer.Name, duration)
    end
}
