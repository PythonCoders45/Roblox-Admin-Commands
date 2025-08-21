local CURRENCIES = {
    "shekels",
    "coins"
}

return function (registry)
    registry:RegisterType("currency", registry.Cmdr.Util.MakeEnumType("currency", CURRENCIES))
end
