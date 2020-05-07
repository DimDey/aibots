------------------------------
-- table getElementTable ( )

function getElementTable(element)
    if isElement(element) then
        local id = getElementData(element, 'dd_tableID')
        if g_Data.Bots[id] then
            return g_Data.Bots[id];
        end
    end
    return false;
end