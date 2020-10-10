function error( msg )
    local errorMessage = '[ ERROR ]: '..msg

    outputServerLog( errorMessage );

    outputDebugString( errorMessage )
    return true;
end;

------------------------------
-- table/boolean getElementTable ( element element )

function getElementTable(element)
    if isElement(element) then
        local id = getElementData(element, 'dd_tableID')
        if aData.bots[id] then
            return aData.bots[id];
        end
    end
    return false;
end

------------------------------
-- table/boolean loadWaypointsFromJSON ( string fileName )

function loadWaypointsFromJSON(fileName)
    local wayFile = fileOpen('server/data/waypoints/'..fileName)
    local count = fileGetSize(wayFile)
    local data = fileRead(wayFile, count)
    fileClose(wayFile)

    return fromJSON(data)
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end