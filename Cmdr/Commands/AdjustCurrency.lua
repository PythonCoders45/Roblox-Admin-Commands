return {
    Name = "adjustCurrency",
    Aliases = {"ac"},
    Description = "Adjusts the currency of a player by the specified amount.",
    Group = "Admin",
    Args = {
        {
            Type = "string",
            Name = "Currency",
            Description = "The currency you want to adjust."
        },
        {
            Type = "number",
            Name = "Amount",
            Description = "The amount you want to adjust the currency by."
        },
        {
            Type = "player",
            Name = "Player",
            Description = "The player whose currency you want to adjust.",
            optional = true
        }
    }
}
