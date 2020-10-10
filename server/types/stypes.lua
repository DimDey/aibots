aData.types = {}

function addBotType(typeData)
    if type(typeData) == 'table' then
        local typeName = typeData.name
        local isExists = getTypeData(typeName)
        if not isExists then
            aData.types[typeName] = typeData;
            return true
        end
    end
    return false
end

function getTypeData(typeName)
    return aData.types[typeName];
end;