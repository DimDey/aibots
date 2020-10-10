CBotEvents = {
    onClientElementStreamIn = function(  )
        if source.type == 'ped' then
            local isBot = source:getData( 'dd_isAIBot' );
            if isBot then
                triggerServerEvent( 'onBotStreamIn', localPlayer, source )
            end
        end
    end;

    onClientElementStreamOut = function(  )
        if source.type == 'ped' then
            local isBot = source:getData( 'dd_isAIBot' )
            if isBot then
                local elementTable, elementId = getElementTable(source)
                triggerServerEvent( 'onBotStreamOut', localPlayer, source, elementTable );
            end
        end
    end;

    onBotAdd = function( data )
        local existData = getElementTable(source)
        if existData then
            existData:delete( )
        end
        CBotModule:add( source, data );
    end;

    onBotDelete = function( )
        local elementTable = getElementTable(source)
        if elementTable then
            elementTable:delete( );
        end
    end;

    onServerUpdateBotData = function( data )
        if source ~= localPlayer and data.sync.syncer == localPlayer then
            local elementTable = getElementTable( source )
            if elementTable then
                for index, value in pairs(data) do
                    elementTable[index] = value;
                end
            else
                return CBotModule:add( source, elementTable );
            end
        end
    end;

    onBotSyncData = function(syncData)
        if syncData.controls then
            for control, state in pairs(syncData.controls) do
                setPedControlState( source, control, state )
            end
        end
    end;
};

addEvent( 'onBotUpdateData', true );
addEvent( 'onBotSyncData', true );
addEvent( 'onServerAddBot', true );
addEvent( 'onServerDeleteBot', true );

addEventHandler( 'onClientElementStreamIn', root, CBotEvents.onClientElementStreamIn )
addEventHandler( 'onClientElementStreamOut', root, CBotEvents.onClientElementStreamOut )

addEventHandler( 'onBotUpdateData', root, CBotEvents.onServerUpdateBotData )
addEventHandler( 'onBotSyncData', root, CBotEvents.onBotSyncData )
addEventHandler( 'onServerAddBot', root, CBotEvents.onBotAdd )
addEventHandler( 'onServerDeleteBot', root, CBotEvents.onBotDelete )