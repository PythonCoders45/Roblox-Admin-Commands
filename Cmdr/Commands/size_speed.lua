-- size_speed.lua (Cmdr command)

local Players = game:GetService("Players")

-- Admin list (UserIds)
local Admins = {
    [] = true, -- replace with actual IDs
    [] = true,
}

return {
    Name = "size";
    Aliases = {};
    Description = "Change a player's character size (percentage) or speed.";
    Group = "Admin"; -- only admins

    Args = {
        {
            Type = "string";
            Name = "type"; -- "size" or "speed"
            Description = "What to change: size or speed";
        },
        {
            Type = "number";
            Name = "percent";
            Description = "Percentage value (e.g., 200 for 200%)";
        },
        {
            Type = "player";
            Name = "target";
            Description = "Target player (optional, defaults to self)";
            Optional = true;
        }
    };

    Run = function(context, typeArg, percent, targetPlayer)
        local player = context.Executor
        if not Admins[player.UserId] then
            return "You are not an admin."
        end

        targetPlayer = targetPlayer or player
        local character = targetPlayer.Character
        if not character then return "Target player has no character." end

        if typeArg:lower() == "size" then
            local scale = percent / 100
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.Size = part.Size * scale
                end
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                if humanoid:FindFirstChild("BodyHeightScale") then
                    humanoid.BodyHeightScale.Value = humanoid.BodyHeightScale.Value * scale
                end
                if humanoid:FindFirstChild("BodyWidthScale") then
                    humanoid.BodyWidthScale.Value = humanoid.BodyWidthScale.Value * scale
                end
                if humanoid:FindFirstChild("BodyDepthScale") then
                    humanoid.BodyDepthScale.Value = humanoid.BodyDepthScale.Value * scale
                end
            end
            return string.format("%s's character scaled to %d%%", targetPlayer.Name, percent)
        elseif typeArg:lower() == "speed" then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * (percent / 100) -- default speed = 16
                return string.format("%s's walk speed set to %d%% (%d studs/sec)", targetPlayer.Name, percent, humanoid.WalkSpeed)
            else
                return "Target player has no humanoid."
            end
        else
            return "Invalid type. Use 'size' or 'speed'."
        end
    end
}
