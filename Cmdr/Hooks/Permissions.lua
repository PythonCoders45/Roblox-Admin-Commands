local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrConfig = require(ReplicatedStorage.Configs.cmdr)

return function (registry)
    registry:RegisterHook("BeforeRun", function (context)
        local userId = context.Executor.UserId
        local isAdmin = table.find(CmdrConfig.Admins, userId)
        local isAdminCommand = context.Group == "Admin"

        if isAdminCommand and not isAdmin then
            return "You do not have permission to use this command!"
        end

        if not isAdmin then
            return "You do not have permission to use this command!"
        end
    end)
end
