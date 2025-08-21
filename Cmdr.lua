local ServerScriptService = game:GetService("ServerScriptService")
local Cmdr = require(ServerScriptService.Packages.Cmdr)

local Commands = script.Parent.Commands
local Types = script.Parent.Types
local Hooks = script.Parent.Hooks

Cmdr:RegisterDefaultCommands()

Cmdr:RegisterCommandsIn(Commands)
Cmdr:RegisterTypesIn(Types)
Cmdr:RegisterHooksIn(Hooks)
