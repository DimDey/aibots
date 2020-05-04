local SCRIPT_SETTINGS = {
    nMaxBotPerPlayer = 0; --[[
        The number of bots a player may lead to aggression. 
        To disable, set the value to 0.
    ]]
    bBotVsBot = false; --[[
        Enables bots to attack each other.
        To disable, set the value to false.
    ]]
    nRespawnDistance = 0; --[[
        How long does the bot have to go to spawn after losing the target.
        To disable, set the value to 0.
    ]]
    nUpdateInterval = 100; --[[
        CAUTION! Decreasing the value leads to lags. CAUTION!
        The interval between updating bots on the client side. 
        Standard value: 100ms.
    ]]
};


function getScriptSettings(setting)
    return SCRIPT_SETTINGS[setting] or SCRIPT_SETTINGS;
end