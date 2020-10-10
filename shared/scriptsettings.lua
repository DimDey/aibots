local SCRIPT_SETTINGS = {
    nMaxBotPerPlayer = 0; --[[ NUMBER
        The number of bots a player may lead to aggression. 
        To disable, set the value to 0.
    ]]
    bBotVsBot = false; --[[ BOOL
        Enables bots to attack each other.
        To disable, set the value to false.
    ]]
    nRespawnDistance = 0; --[[ NUMBER 
        How long does the bot have to go to spawn after losing the target.
        To disable, set the value to 0.
    ]]
    nUpdateInterval = 100; --[[ NUMBER
        CAUTION! Decreasing the value leads to lags. CAUTION!
        The interval between updating bots on the client side. 
        Standard value: 100ms.
    ]]
    nSyncDataInterval = 200;
    waypointTeleport = false; --[[ BOOL
        If the bot does not see the waypoint, it teleports to the waypoint.
    ]]
};


function getScriptSettings(setting)
    return SCRIPT_SETTINGS[setting] or SCRIPT_SETTINGS;
end