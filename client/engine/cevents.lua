addEvent( 'onBotUpdateData', true );
addEvent( 'onBotControlsUpdate', true );
addEvent( 'onServerAddBot', true );
addEvent( 'onServerDeleteBot', true );


CEvents = {
    onClientElementStreamIn = function(  )
        if source.type == 'ped' then
            local isBot = source:getData( 'dd_isAIBot' );
            if isBot then
                triggerServerEvent( 'onBotStreamIn', localPlayer, source, localPlayer )
            end
        end
    end;

    onClientElementStreamOut = function(  )
        if source.type == 'ped' then
            local isBot = source:getData( 'dd_isAIBot' )
            if isBot then
                local elementTable, elementId = getElementTable(source)
                if elementTable then
                    elementTable:syncElement( true );  
                end
                triggerServerEvent( 'onBotStreamOut', localPlayer, source, localPlayer );
            end
        end
    end;

    onBotAdd = function( data )
        local existData = getElementTable(source)
        if existData then
            for index, value in pairs(data) do
                existData[index] = value;
            end
        else
            CBot:new( source, data);
        end
    end;

    onBotDelete = function( )
        local elementTable = getElementTable(source)
        if elementTable then
            elementTable:delete( );
        end
    end;

    onServerUpdateBotData = function( data )
        if source ~= localPlayer then
            local elementTable = getElementTable( source )
            if elementTable then
                for index, value in pairs(data) do
                    elementTable[index] = value;
                end
            end
        end
    end;

    onBotControlsUpdate = function(element, data, controls)
        if source ~= localPlayer then
            local elementTable = getElementTable(element)
            if elementTable then
                for controlIndex, controlState in pairs(controls) do
                    if getPedControlState(element, controlIndex) ~= controlState then
                        setPedControlState(element, controlIndex, controlState)
                    end
                end
            end
        end
    end;
};

addEventHandler( 'onClientElementStreamIn', root, CEvents.onClientElementStreamIn )
addEventHandler( 'onClientElementStreamOut', root, CEvents.onClientElementStreamOut )
addEventHandler( 'onBotUpdateData', root, CEvents.onServerUpdateBotData )
addEventHandler( 'onBotControlsUpdate', root, CEvents.onBotControlsUpdate )
addEventHandler( 'onServerAddBot', root, CEvents.onBotAdd )
addEventHandler( 'onServerDeleteBot', root, CEvents.onBotDelete )