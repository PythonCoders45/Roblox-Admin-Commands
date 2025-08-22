-- jump_ragdoll.lua

local Players = game:GetService("Players")

-- Admin list (UserIds)
local Admins = {
    [] = true, -- replace with actual IDs
    [] = true,
}

-- Helper to ragdoll a player
local function ragdollPlayer(player)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Disable humanoid controls
    humanoid.PlatformStand = true

    -- Optional: reset after 5 seconds
    delay(5, function()
        if humanoid then
            humanoid.PlatformStand = false
        end
    end)
end

return {
    Name = "jump_ragdoll";
    Aliases = {"jump", "ragdoll"};
    Description = "Change jump height or ragdoll yourself or others.";
    Group = "Admin"; -- admin only
    Args = {
        {
            Type = "string";
            Name = "action";
            Description = "Action: 'jump' or 'ragdoll'";
        },
        {
            Type = "number";
            Name = "value";
            Description = "Jump height multiplier (ignored for ragdoll)";
            Optional = true
        },
        {
            Type = "player";
            Name = "target";
            Description = "Target player (optional, defaults to yourself)";
            Optional = true
        }
    };

    Run = function(context, action, value, targetPlayer)
        local executor = context.Executor
        if not Admins[executor.UserId] then
            return "You are not an admin."
        end

        targetPlayer = targetPlayer or executor
        local character = targetPlayer.Character
        if not character then return "Target player has no character." end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return "Target player has no humanoid." end

        action = action:lower()

        if action == "jump" then
            if not value then value = 50 end
            humanoid.JumpPower = value
            return string.format("%s's jump power set to %d", targetPlayer.Name, value)
        elseif action == "ragdoll" then
            ragdollPlayer(targetPlayer)
            return string.format("%s has been ragdolled!", targetPlayer.Name)
        else
            return "Invalid action. Use 'jump' or 'ragdoll'."
        end
    end
}
