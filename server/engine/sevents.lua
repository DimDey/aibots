SBotEvents = {
    --------------------
    -- bool or element SBotEvents.onColShapeHit ( element hitElement, bool matchingDimension )
    --[[
        Called when a player has entered a colshape.
    ]]
    onColShapeHit = function( hitElement, matchingDimension )
        if not matchingDimension then return end;
        local bot = getElementAttachedTo( source )
        if bot.type == 'ped' and bot ~= hitElement and bot.health > 0 then
            local botData = getElementTable( bot )
            local targetElement

            if not botData.attacks then return end;

            if hitElement.type == "player" then
                player = hitElement
            elseif hitElement.type == "vehicle" then
                player = getVehicleOccupant( hitElement )
            else
                return 
            end

            if player.team == bot.team then return end;
            
            if not isElement(botData.target) then
                botData:setTarget( player );
            end
        end
    end;

    --------------------
    -- bool SBotEvents.onBotStreamIn ( element bot )
    --[[
        Called from the clientside when bot entered the player`s stream.
    ]]

    onBotStreamIn = function( bot )  
        outputDebugString('onBotStreamIn')
        local botData = getElementTable( bot )
        if botData then
            setElementFrozen( bot, false );

            botData.sync.players[client] = true;
            botData.sync.playersCount = botData.sync.playersCount + 1
            botData:updateSyncer( );

            triggerEvent( 'onBotDataUpdate', bot, botData, false );
            return true;
        end
        return false;
    end;

    --------------------
    -- bool SBotEvents.onBotStreamOut ( element bot, table playerData )
    --[[
        Called from the clientside when the bot has leave from the player’s stream.
    ]]


    onBotStreamOut = function( bot, playerData ) 
        outputDebugString('onBotStreamOut')
        local botData = getElementTable( bot )
        if botData then
            
            if botData.sync.syncer == client then
                if type(playerData) == 'table' then
                    for index, value in pairs(playerData) do
                        botData[index] = value
                    end
                end
                botData:updateSyncer( );
            end
            if botData.target == client then
                botData:setTarget();
            end
        
            botData.sync.players[client] = false
            botData.sync.playersCount = botData.sync.playersCount - 1

            triggerClientEvent( client, 'onServerDeleteBot', bot )

            if botData.sync.playersCount == 0 then
                setElementFrozen( bot, true )
                setPedAnimation( bot )
            end
        end
        return false;
    end;

    --------------------
    -- bool SBotEvents.onBotDataUpdate ( table botData, table controlsList )
    --[[
        Called when server update data and send it to clientside syncer.
    ]]

    onBotDataUpdate = function( botData, controlsList )
        local bot = botData.element
        if isElement(bot) and botData.sync.syncer then
            triggerLatentClientEvent( botData.sync.syncer, 'onBotUpdateData', bot, botData, controlsList );
        end
    end;

    --------------------
    -- bool SBotEvents.onPlayerSendData ( table playerData, table syncData )
    --[[
        Called when syncer update data and send it to serverside.
    ]]

    onPlayerSendData = function( playerData, syncData ) 
        local botData = getElementTable(source)
        if botData.sync.syncer == client then 
            if playerData == nil then return error('SYNCER SEND NULL SYNC!') end

            for index, value in pairs(botData) do
                botData[index] = playerData[index]
            end
            
            triggerLatentClientEvent( botData.sync.players, 'onBotSyncData', source, syncData );

        else
            triggerClientEvent( client, 'onServerDeleteBot', source )
            return error('ANOTHER PLAYER ('..getPlayerName(client)..") TRY TO SENT DATA TO SYNC") 
        end
    end;

    onPlayerSendAnimation = function( ... )
        local botData = getElementTable(source)
        if botData.sync.syncer == client then
            setPedAnimation( source, ... )
        end
    end;
}
addEvent("onBotStreamIn",  true)
addEvent("onBotStreamOut", true)
addEvent("onBotDataUpdate")
addEvent('onPlayerSendData', true)
addEvent('onPlayerSendAnimation', true)


addEventHandler( "onBotStreamIn", root, SBotEvents.onBotStreamIn )
addEventHandler( "onBotStreamOut", root, SBotEvents.onBotStreamOut )
addEventHandler( "onBotDataUpdate", root, SBotEvents.onBotDataUpdate )
addEventHandler( 'onPlayerSendData', root, SBotEvents.onPlayerSendData )
addEventHandler( 'onPlayerSendAnimation', root, SBotEvents.onPlayerSendAnimation )