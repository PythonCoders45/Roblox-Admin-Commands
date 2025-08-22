-- utility.lua
-- Fully functional utility commands for Admins

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StartTime = tick()

local Admins = {
    [] = true, -- replace with your UserIds
}

local function IsAdmin(player)
    return Admins[player.UserId] == true
end

local commands = {}

-- JSON ENCODE / DECODE
commands["json-array-encode"] = {
    Name="json-array-encode";
    Description="Encodes Lua table into JSON array";
    Args={{Type="string",Name="data"}};
    Run=function(context, data)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local success, result = pcall(function()
            return HttpService:JSONEncode({data})
        end)
        return success and result or "Encoding failed"
    end
}

commands["json-array-decode"] = {
    Name="json-array-decode";
    Description="Decodes JSON array into Lua table";
    Args={{Type="string",Name="data"}};
    Run=function(context, data)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local success, result = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        return success and result or "Decoding failed"
    end
}

-- LEN
commands.len = {
    Name="len";
    Description="Returns length of a string/value";
    Args={{Type="string",Name="value"}};
    Run=function(context, value)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        return #tostring(value)
    end
}

-- BLINK
commands.blink = {
    Name="blink";
    Description="Makes a player blink";
    Args={{Type="player",Name="target"}};
    Run=function(context, target)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local head = target.Character and target.Character:FindFirstChild("Head")
        if head then
            head.Transparency = 1
            task.wait(0.2)
            head.Transparency = 0
        end
        return target.Name.." blinked!"
    end
}

-- SIMPLE MATH
commands.math = {
    Name="math";
    Description="Performs math expression (e.g. 2+2)";
    Args={{Type="string",Name="expression"}};
    Run=function(context, expression)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local func, err = loadstring("return "..expression)
        if not func then return err end
        local success, result = pcall(func)
        return success and result or "Invalid expression"
    end
}

-- NUKE PLAYERS
commands.nukeplayers = {
    Name="nukeplayers";
    Description="Nukes all players (explodes them)";
    Run=function(context)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local exp = Instance.new("Explosion", workspace)
                exp.Position = plr.Character.HumanoidRootPart.Position
            end
        end
        return "All players nuked!"
    end
}

-- GLOBAL RESTART
commands.globalrestart = {
    Name="globalrestart";
    Description="Restarts all servers (kick all players)";
    Run=function(context)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        for _,plr in ipairs(Players:GetPlayers()) do
            plr:Kick("Server restarting...")
        end
        return "Servers restarting..."
    end
}

-- SET FIRE
commands.setfire = {
    Name="setfire";
    Description="Sets a player on fire";
    Args={{Type="player",Name="target"}};
    Run=function(context, target)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local fire = Instance.new("Fire", hrp)
        end
        return target.Name.." is on fire!"
    end
}

-- UPTIME
commands.uptime = {
    Name="uptime";
    Description="Shows server uptime";
    Run=function(context)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        return "Uptime: "..math.floor(tick()-StartTime).." seconds"
    end
}

-- UNBIND (example, unbind key binds if used in your admin system)
commands.unbind = {
    Name="unbind";
    Description="Unbinds key or command";
    Args={{Type="string",Name="key"}};
    Run=function(context, key)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        -- Implementation depends on your keybind system
        return "Unbound "..key
    end
}

-- POSITION
commands.position = {
    Name="position";
    Description="Gets player's position";
    Args={{Type="player",Name="target"}};
    Run=function(context, target)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        return hrp and tostring(hrp.Position) or "No HumanoidRootPart"
    end
}

-- PICK RANDOM PLAYER
commands.pick = {
    Name="pick";
    Description="Pick random player";
    Run=function(context)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local players = Players:GetPlayers()
        return #players > 0 and players[math.random(1,#players)].Name or "No players"
    end
}

-- RUN SCRIPT
commands.run = {
    Name="run";
    Description="Executes Lua script";
    Args={{Type="string",Name="code"}};
    Run=function(context, code)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local f, err = loadstring(code)
        if not f then return err end
        local success, result = pcall(f)
        return success and result or "Script failed"
    end
}

-- RUN MULTIPLE LINES
commands["run-lines"] = {
    Name="run-lines";
    Description="Executes multiple lines of code";
    Args={{Type="string",Name="code"}};
    Run=function(context, code)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local f, err = loadstring(code)
        if not f then return err end
        local success, result = pcall(f)
        return success and result or "Execution failed"
    end
}

-- EDIT GAME ELEMENTS (for example, change part properties)
commands.edit = {
    Name="edit";
    Description="Edits part properties by name";
    Args={{Type="string",Name="partName"},{Type="string",Name="property"},{Type="any",Name="value"}};
    Run=function(context, partName, property, value)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local part = workspace:FindFirstChild(partName)
        if part and part[property] ~= nil then
            part[property] = value
            return "Edited "..partName.." "..property.." to "..tostring(value)
        end
        return "Part or property not found"
    end
}

-- RANDOM NUMBER
commands.rand = {
    Name="rand";
    Description="Generates random number";
    Args={{Type="number",Name="min"},{Type="number",Name="max"}};
    Run=function(context, min,max)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        return math.random(min,max)
    end
}

-- REPLACE
commands.replace = {
    Name="replace";
    Description="Replace part with another";
    Args={{Type="string",Name="oldPart"},{Type="string",Name="newPart"}};
    Run=function(context, oldPart,newPart)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local old = workspace:FindFirstChild(oldPart)
        local newP = workspace:FindFirstChild(newPart)
        if old and newP then
            newP.CFrame = old.CFrame
            old:Destroy()
            return oldPart.." replaced with "..newPart
        end
        return "Parts not found"
    end
}

-- RESOLVE (run arbitrary function safely)
commands.resolve = {
    Name="resolve";
    Description="Resolve function";
    Args={{Type="function",Name="func"}};
    Run=function(context, func)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        local success, result = pcall(func)
        return success and result or "Failed"
    end
}

-- RUNIF
commands.runif = {
    Name="runif";
    Description="Runs code conditionally";
    Args={{Type="boolean",Name="condition"},{Type="string",Name="code"}};
    Run=function(context, condition, code)
        if not IsAdmin(context.Executor) then return "Not admin!" end
        if condition then
            local f, err = loadstring(code)
            if not f then return err end
            local success, result = pcall(f)
            return success and result or "Execution failed"
        else
            return "Condition false, not executed"
        end
    end
}

return commands
