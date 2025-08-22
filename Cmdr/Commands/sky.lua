-- sky.lua

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

-- Admin list (UserIds)
local Admins = {
    [] = true, -- replace with actual IDs
    [] = true,
}

-- Preset skies
local Presets = {
    normal = function()
        Lighting.ClockTime = 14
        Lighting.FogColor = Color3.fromRGB(192, 192, 255)
        Lighting.FogEnd = 100000
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.Sky = nil
    end,

    ["7pm"] = function()
        Lighting.ClockTime = 19
        Lighting.FogColor = Color3.fromRGB(255, 100, 50)
    end,

    ["3am"] = function()
        Lighting.ClockTime = 3
        Lighting.FogColor = Color3.fromRGB(50, 50, 100)
    end,

    space = function()
        local sky = Instance.new("Sky")
        sky.SkyboxBk = ""
        sky.SkyboxDn = ""
        sky.SkyboxFt = ""
        sky.SkyboxLf = ""
        sky.SkyboxRt = ""
        sky.SkyboxUp = ""
        sky.Parent = Lighting
        Lighting.ClockTime = 0
        Lighting.FogColor = Color3.new(0, 0, 0)
    end
}

-- Colors preset
local function colorPreset(colorName)
    local colorMap = {
        red = Color3.fromRGB(255, 0, 0),
        blue = Color3.fromRGB(0, 0, 255),
        green = Color3.fromRGB(0, 255, 0),
        purple = Color3.fromRGB(128, 0, 128),
        yellow = Color3.fromRGB(255, 255, 0),
    }
    return colorMap[colorName:lower()]
end

return {
    Name = "sky";
    Aliases = {};
    Description = "Change the sky/lighting with presets or colors.";
    Group = "Admin"; -- admin only
    Args = {
        {
            Type = "string";
            Name = "preset";
            Description = "Preset sky: normal, random, 7pm, 3am, space, red, blue, etc.";
        }
    };

    Run = function(context, preset)
        local player = context.Executor
        if not Admins[player.UserId] then
            return "You are not an admin."
        end

        preset = preset:lower()

        if preset == "random" then
            Lighting.FogColor = Color3.new(math.random(), math.random(), math.random())
            Lighting.OutdoorAmbient = Color3.new(math.random(), math.random(), math.random())
            return "Sky set to random colors!"
        elseif Presets[preset] then
            Presets[preset]()
            return "Sky set to " .. preset
        else
            local color = colorPreset(preset)
            if color then
                Lighting.FogColor = color
                Lighting.OutdoorAmbient = color * 0.5
                return "Sky color set to " .. preset
            else
                return "Unknown preset. Use: normal, random, 7pm, 3am, space, red, blue, etc."
            end
        end
    end
}
