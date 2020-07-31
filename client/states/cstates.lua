CStates = {
    trigger = function( self, data, stateIndex )
        local dataType = data.type
        if dataType then
            local state = CStates[dataType]
            if state and state.states[stateIndex] then
                return state.states[stateIndex]( state, data);
            else
                state = CStates['default'].states[stateIndex] -- if not dataType state, then return default state
                return state( CStates['default'], data);
            end 
        end 
    end;

    add = function( self, typeData )
        local typeName = typeData.type
        CStates[typeName] = typeData;
        CStates[typeName].states = typeData.states or {}
    end;

    addState = function( self, stateData )
        if not( type( stateData ) == 'table' ) then return false end
        local stateFunction = stateData.func
        local stateName = stateData.stateName
        local typeName = stateData.type
    
        if CStates[typeName] then
            CStates[typeName][stateName] = stateFunction;
            return true;
        else
            addType({type = typeName, [stateName] = stateFunction});
            return true;
        end
    end;
};