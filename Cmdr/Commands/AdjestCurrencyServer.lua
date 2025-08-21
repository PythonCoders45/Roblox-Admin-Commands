local ServerScriptService = game:GetService("ServerScriptService")
local PlayerDataService = require(ServerScriptService.Services.PlayerDataService)

return function (context, currency: string, amount: number, player: Player?)
	player = if player then player else context.Executor

	local action: PlayerDataService.StateAction = {
		action = "UpdateCurrency",
		currency = currency,
		amount = amount
	}
  PlayerDataService.UpdateState(player, action)

	local state = PlayerDataService.GetState(player)
	if not state then
		return "Player state not found."
	end

	local balance = state[currency]

	return `{player.Name} now has {balance} {currency}.`
end
