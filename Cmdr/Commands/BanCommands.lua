-- BanCommands.lua
-- Cmdr commands for banning, unbanning, and listing banned players

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local banStore = DataStoreService:GetDataStore("PermanentBans")

-- In-memory ban tables
local tempBans = {}       -- [userId] = expireTime
local permBans = {}       -- [userId] = true

-- Permanent ban helpers
local function isPermanentlyBanned(userId)
	if permBans[userId] then return true end
	local success, result = pcall(function()
		return banStore:GetAsync(userId)
	end)
	if success and result == true then
		permBans[userId] = true
		return true
	end
	return false
end

local function addPermanentBan(userId)
	pcall(function()
		banStore:SetAsync(userId, true)
	end)
	permBans[userId] = true
end

local function removePermanentBan(userId)
	pcall(function()
		banStore:RemoveAsync(userId)
	end)
	permBans[userId] = nil
end

-- Temporary bans
local function addTempBan(userId, duration)
	tempBans[userId] = os.time() + duration
end

local function removeTempBan(userId)
	tempBans[userId] = nil
end

local function isBanned(userId)
	if isPermanentlyBanned(userId) then
		return true, "You are permanently banned."
	end
	local expireTime = tempBans[userId]
	if expireTime and os.time() < expireTime then
		local minutesLeft = math.floor((expireTime - os.time())/60)
		return true, "You are temporarily banned. Time left: " .. minutesLeft .. " minutes"
	end
	return false
end

-- Kick banned players when they join
Players.PlayerAdded:Connect(function(player)
	local banned, reason = isBanned(player.UserId)
	if banned then
		player:Kick(reason)
	end
end)

----------------------------------------------------------------
-- Cmdr Command Definitions
----------------------------------------------------------------
return {
	-- Temporary Ban
	{
		Name = "ban",
		Aliases = {"tempban"},
		Description = "Temporarily ban a player for a duration (seconds).",
		Group = "Admin",
		Args = {
			{Name = "playerName", Type = "string"},
			{Name = "duration", Type = "number"}
		},
		Run = function(ctx, playerName, duration)
			local userId = Players:GetUserIdFromNameAsync(playerName)
			addTempBan(userId, duration)
			local target = Players:FindFirstChild(playerName)
			if target then
				target:Kick("You are temporarily banned for " .. duration .. " seconds.")
			end
			return ("Temporarily banned %s for %d seconds"):format(playerName, duration)
		end
	},

	-- Permanent Ban
	{
		Name = "foreverban",
		Aliases = {"permban"},
		Description = "Permanently ban a player (saved in DataStore).",
		Group = "Admin",
		Args = {
			{Name = "playerName", Type = "string"}
		},
		Run = function(ctx, playerName)
			local userId = Players:GetUserIdFromNameAsync(playerName)
			addPermanentBan(userId)
			local target = Players:FindFirstChild(playerName)
			if target then
				target:Kick("You are permanently banned.")
			end
			return ("Permanently banned %s"):format(playerName)
		end
	},

	-- Unban
	{
		Name = "unban",
		Description = "Unban a player (removes both temp and permanent bans).",
		Group = "Admin",
		Args = {
			{Name = "playerName", Type = "string"}
		},
		Run = function(ctx, playerName)
			local userId = Players:GetUserIdFromNameAsync(playerName)
			removePermanentBan(userId)
			removeTempBan(userId)
			return ("Unbanned %s"):format(playerName)
		end
	},

	-- List banned players
	{
		Name = "banned",
		Description = "List all currently banned players.",
		Group = "Admin",
		Args = {},
		Run = function(ctx)
			local list = {}
			for userId, expire in pairs(tempBans) do
				if os.time() < expire then
					table.insert(list, "UserId " .. userId .. " (temp until " .. os.date("%X", expire) .. ")")
				end
			end
			for userId in pairs(permBans) do
				table.insert(list, "UserId " .. userId .. " (permanent)")
			end
			if #list == 0 then
				return "No players are currently banned."
			else
				return "Banned players:\n" .. table.concat(list, "\n")
			end
		end
	}
}
