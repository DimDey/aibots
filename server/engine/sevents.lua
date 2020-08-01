addEvent("onBotStreamIn",  true)
addEvent("onBotStreamOut", true)
addEvent("onBotDataUpdate")
addEvent('onPlayerSendData', true)
addEvent('onBotControlsUpdate', true)

SEvents = {
    --------------------
    -- bool or element SEvents.onColShapeHit ( element hitElement, bool matchingDimension )
    --[[
        Called when a player has entered a colshape.
    ]]

    onColShapeHit = function( hitElement, matchingDimension )
        outputDebugString('onColShapeHit')
        if matchingDimension then
            local element = getElementAttachedTo( source )
            if isElement( element ) and element ~= hitElement then
                local elementTable = getElementTable( element )
                
                if not elementTable.attacks then return end;
                
                if element.health > 0 then
                    local player
                    
                    if hitElement.type == "player" then
                        player = hitElement
                    elseif hitElement.type == "vehicle" then
                        player = getVehicleOccupant( hitElement )
                    else
                        return 
                    end
                    
                    if player then
                        local playerTeam = player.team

                        if playerTeam == elementTable.team then
                            return;
                        end

                        if not elementTable.syncer then
                            elementTable:updateSyncer( );
                        end

                        if not elementTable.target then
                            return elementTable:setTarget( player );
                        end
                    end
                    
                end
            end
        end
        return false;
    end;

    --------------------
    -- bool SEvents.onBotStreamIn ( element bot, element player )
    --[[
        Called from the clientside when bot entered the player`s stream.
    ]]

    onBotStreamIn = function( bot, player )  
        outputDebugString('onBotStreamIn')
        local elementTable = getElementTable( bot )
        if elementTable then
            local firstPlayer = false
            if #elementTable.sync.players == 0 then
                setElementFrozen( bot, false );
                firstPlayer = player;
            end;

            if not elementTable.sync.players[player] then
                elementTable.sync.players[player] = true;
                
                if not elementTable.sync.syncer then
                    elementTable:updateSyncer( );
                end
                triggerClientEvent( player, 'onServerAddBot', bot, elementTable );

                triggerEvent( 'onBotDataUpdate', bot, elementTable, firstPlayer );
                return true;
            end
        end
        return false;
    end;

    --------------------
    -- bool SEvents.onBotStreamOut ( element bot, element player )
    --[[
        Called from the clientside when the bot has leave from the player’s stream.
    ]]

    onBotStreamOut = function( bot, player )
        outputDebugString('onBotStreamOut')
        local elementTable = getElementTable( bot )
        if elementTable then
            
            if elementTable.sync.players[player] then
                if elementTable.sync.syncer == player then
                    elementTable:updateSyncer( );
                end
                elementTable.sync.players[player] = nil
                if elementTable:getTarget() == player then
                    elementTable:setTarget();
                end
            else
                if #elementTable.sync.players == 0 then
                    setElementFrozen( bot, true )
                    setPedAnimation( bot )
                end
            end
        end
        return false;
    end;    

    --------------------
    -- bool SEvents.onBotDataUpdate ( table elementData, element notSendToPlayer )
    --[[
        Called when server update data and send it to clientside syncable players.
    ]]

    onBotDataUpdate = function( elementData, notSendToPlayer )
        local element = elementData.element
        if isElement(element) then
            local players = elementData.sync.players
            for player, syncable in pairs(players) do
                if player ~= notSendToPlayer then
                    triggerClientEvent( player, 'onBotUpdateData', element, elementData );
                end
            end
        end
    end;

    --------------------
    -- bool SEvents.onBotControlsUpdate ( table elementData, table controlsList )
    --[[
        Called when server update ped controls and send it to clientside syncable players.
    ]]

    onBotControlsUpdate = function( element, elementData, controlsList, withoutPlayer )
        if element then
            local players = elementData.sync.players
            if players then
                for player, syncable in pairs(players) do
                    triggerClientEvent( player, 'onBotControlsUpdate', source, element, controlsList );
                end
            end
        end
    end;

    --------------------
    -- bool SEvents.onPlayerSendData ( table elementData, table controlsData )
    --[[
        Called when syncer update data and send it to serverside.
    ]]

    onPlayerSendData = function( elementData, controlsData )
        local element = source
        local elementTable = getElementTable(element)
        local players = elementData.sync.players
        if elementTable then
            for index, value in pairs(elementData) do
                elementTable[index] = value
                if index == 'target' then
                    outputDebugString('target: '..tostring(value))
                    if value == 'lost' then
                        elementTable:setTarget( );
                    end
                end
            end
        end

        if players then
            if controlsData then
                for player, syncable in pairs(players) do
                    triggerClientEvent(players, 'onBotControlsUpdate', client, source, elementData, controlsData, client );
                end
            end
        end
        triggerEvent('onBotDataUpdate', client, source, elementTable, client);
    end;
    
    --------------------
    -- bool SEvents.onSyncerSendAnimation ( table elementData, string block = nil, string anim = nil, int time = -1, bool loop = true, bool updatePosition = true,
    --[[                                    bool interruptable = true, bool freezeLastFrame = true, int blendTime = 250, bool retainPedState = false )
        Called when syncer updates the bot animation. 
        Eventhandler synchronizes animations with other players who sync this bot.
    ]]
    onSyncerSendAnimation = function(block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime, retainPedState)
        local element = source
        local elementTable = getElementTable(element)
        if elementTable then
            if elementTable.sync.syncer ~= client then
                triggerClientEvent(client, 'onBotUpdateData', element, elementData)
            else
                setPedAnimation(element, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime, retainPedState)
            end
        end
    end;
};  

addEventHandler( "onBotStreamIn", root, SEvents.onBotStreamIn )
addEventHandler( "onBotStreamOut", root, SEvents.onBotStreamOut )
addEventHandler( "onBotDataUpdate", root, SEvents.onBotDataUpdate )
addEventHandler( 'onPlayerSendData', root, SEvents.onPlayerSendData )
addEventHandler( 'onSyncerSendAnimation', root, SEvents.onSyncerSendAnimation )
addEventHandler( 'onBotControlsUpdate', root, SEvents.onBotControlsUpdate )