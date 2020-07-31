local CDefaultState = {
    type = 'default';
    states = {
        onUpdate = function( self, data )
            local element = data.element;
            local target = data.target;
            if isElement(target) then
                if element.health == 0 or target.health == 0 then
                    data:delete(index);
                end
                local lX, lY, lZ = target.position;
                local bX, bY, bZ = element.position;
                
                local see = data:isBotSeePosition(lX, lY, lZ, false)
                if see then
                    CStates:trigger( data, 'onSee' )
                else
                    CStates:trigger( data, 'onLost' )
                end
            end
        end;

        onSee = function( self, data )
            local nBotX, nBotY, nBotZ = data.element.position;
            local aTargetPos = data.seeData.pos;
            local distance = getDistanceBetweenPoints3D(aTargetPos.x, aTargetPos.y, aTargetPos.z, nBotX, nBotY, nBotZ)
        
            local angle = getRotateToPoint(data.element, aTargetPos.x, aTargetPos.y);
            setElementRotation(data.element, 0, 0, angle, 'default', true)
            setPedControlState(data.element, "forwards", true);
        
            if distance <= 1 then
                setPedControlState(data.element, 'fire', true)
                setPedControlState(data.element, "forwards", false);
            else
                setPedControlState(data.element, 'fire', false)
            end
        end;

        onLost = function( self, data )
            local aTargetPos = data.seeData.pos;
            if aTargetPos.x and aTargetPos.y then
                local aBotPosX, aBotPosY, aBotPosZ = data.element.position
                local distance = getDistanceBetweenPoints3D(aTargetPos.x, aTargetPos.y, aTargetPos.z, aBotPosX, aBotPosY, aBotPosZ)
                local lastDistance = getElementData(data.element, 'lastDistanceToTarget')
        
        
                if not lastDistance then
                    setElementData(data.element, 'lastDistanceToTarget', distance, false);
                    lastDistance = distance;
                else
                    if lastDistance == distance then
                        CStates:trigger( data, 'onStopSearchTarget' )
                        return
                    end
                end 
        
                if ( distance <= 1 ) or ( lastDistance < distance ) then
                    CStates:trigger( data, 'onStopSearchTarget' )
                    return
                else
                    setElementData(data.element, 'lastDistanceToTarget', distance, false);
                end
            end
        end;

        onStopSearchTarget = function( self, data )
            setControlState(self.element, 'forwards', false);
            setElementData(self.element, 'lastDistanceToTarget', nil, false);
            self.target = nil    
        end;    
    };
};
CStates:add(CDefaultState);