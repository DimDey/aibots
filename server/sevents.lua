addEvent("onBotStreamIn",  true)
addEvent("onBotStreamOut", true)

SEvents = {
    --------------------
    -- bool or element SEvents.onColShapeHit ( element hitElement, bool matchingDimension )
    --[[
        Called when a player has entered a colshape.
    ]]

    onColShapeHit = function( hitElement, matchingDimension )
        if matchingDimension then
            local element = getElementAttachedTo( source )
            if isElement( element ) and element ~= hitElement then
                local elementTable = getElementTable( element )
                local player


                if getElementHealth( element ) > 0 then
                    if getElementType( hitElement ) == "player" then
                        player = hitElement
                    elseif getElementType( hitElement ) == "vehicle" then
                        player = getVehicleOccupant( hitElement )
                    end


                    if player then
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
            if not elementTable.sync.players[player] then
                table.insert(elementTable.sync.players, player)
                
                if not elementTable.sync.syncer then
                    elementTable:updateSyncer( );
                end
                triggerClientEvent( elementTable.sync.players, 'dd_updateBotData', bot, elementTable );
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
                    return true;
                end
            end
        end
        return false;
    end;    
};  

addEventHandler( "onBotStreamIn", root, SEvents.onBotStreamIn )
addEventHandler( "onBotStreamOut", root, SEvents.onBotStreamOut )