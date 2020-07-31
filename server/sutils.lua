------------------------------
-- table/boolean getElementTable ( element element )

function getElementTable(element)
    if isElement(element) then
        local id = getElementData(element, 'dd_tableID')
        if g_Data.Bots[id] then
            return g_Data.Bots[id];
        end
    end
    return false;
end

------------------------------
-- table/boolean loadWaypointsFromJSON ( string fileName )

function loadWaypointsFromJSON(fileName)
    local wayFile = fileOpen('data/waypoints/'..fileName)
    local count = fileGetSize(wayFile)
    local data = fileRead(wayFile, count)
    fileClose(wayFile)

    return fromJSON(data)
end