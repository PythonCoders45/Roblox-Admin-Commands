local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local CmdrConfig = require(ReplicatedStorage.Configs.Cmdr)
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local isAdmin = table.find(CmdrConfig.Admins, Player.UserId)
if isAdmin then
    Cmdr:SetActivationKeys((Enum.KeyCode.F2))
end
