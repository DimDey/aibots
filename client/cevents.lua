addEvent('dd_updateBotData', true);


CEvents = {
    onClientElementStreamIn = function(  )
        if source.type == 'ped' then
            local isBot = source:getData( 'dd_isAIBot' );
            if isBot then
                local elementTable = getElementTable(source)
                if not elementTable then
                    triggerServerEvent( 'onBotStreamIn', localPlayer, source, localPlayer )
                end
            end
        end
    end;

    onClientElementStreamOut = function(  )
        if source.type == 'ped' then
            local isBot = source:getData( 'dd_isAIBot' )
            if isBot then
                local elementTable, elementId = getElementTable(source)
                if elementTable then
                    g_BotsData[elementId]:remove();
                end

                triggerServerEvent( 'onBotStreamOut', localPlayer, source, localPlayer );
            end
        end
    end;

    onServerChangeTarget = function(target)
        local elementTable = getElementTable(source)
        if elementTable then
            local bot = elementTable;
            bot.target = target;
            return;
        end

        CBots:new( source, {target = target} )
    end;

    onServerUpdateBotData = function(data)
        outputDebugString(inspect(data))
        local elementTable = getElementTable(source)
        if elementTable then
            for index, value in pairs(data) do
                elementTable[index] = value;
            end
        else
            outputDebugString('lol')
            CBots:new( source, data );
        end
    end;
};

addEventHandler( 'onClientElementStreamIn', root, CEvents.onClientElementStreamIn )
addEventHandler( 'onClientElementStreamOut', root, CEvents.onClientElementStreamOut )
addEventHandler( 'dd_updateBotData', root, CEvents.onServerUpdateBotData )