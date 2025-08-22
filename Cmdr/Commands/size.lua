-- size.lua (Cmdr command)

local Players = game:GetService("Players")

-- Admin list (UserIds)
local Admins = {
    [12345678] = true, -- replace with actual IDs
    [87654321] = true,
}

return {
    Name = "size";
    Aliases = {};
    Description = "Change a player's character size (percentage).";
    Group = "Admin"; -- only admins
    Args = {
        {
            Type = "number";
            Name = "percent";
            Description = "Size percentage (e.g., 200 for 200%)";
        },
        {
            Type = "player";
            Name = "target";
            Description = "Player to resize (optional, defaults to self)";
            Optional = true;
        }
    };

    Run = function(context, percent, targetPlayer)
        local player = context.Executor
        if not Admins[player.UserId] then
            return "You are not an admin."
        end

        targetPlayer = targetPlayer or player
        local character = targetPlayer.Character
        if not character then return "Target player has no character." end

        local scale = percent / 100

        -- Scale all parts of character
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Size = part.Size * scale
            end
        end

        -- Also scale Humanoid (walk speed and jump height optional)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.BodyHeightScale.Value = humanoid.BodyHeightScale.Value * scale
            humanoid.BodyWidthScale.Value = humanoid.BodyWidthScale.Value * scale
            humanoid.BodyDepthScale.Value = humanoid.BodyDepthScale.Value * scale
        end

        return string.format("%s's character scaled to %d%%", targetPlayer.Name, percent)
    end
}
