g_Data.Types = {}

function addBotType(typeData)
    if type(typeData) == 'table' then
        local typeName = typeData.name
        local isExists = getTypeData(typeName)
        if not isExists then
            g_Data.Types[typeName] = typeData;
            return true
        end
    end
    return false
end

function getTypeData(typeName)
    return g_Data.Types[typeName];
end;