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
                local targetPosition = target.position;
                
                local see = data:isBotSeePosition(targetPosition.x, targetPosition.y, targetPosition.z, false)
                if see then
                    CStates:trigger( data, 'onSee' )
                    triggerEvent( 'onAISeeTarget', data.element, data.target )
                else
                    CStates:trigger( data, 'onLost' )
                    triggerEvent( 'onAILostTarget', data.element, data.target )

                end
            end
        end;

        onSee = function( self, data )
            local nBotX, nBotY, nBotZ = data.element.position;
            local aTargetPos = data.seeData.pos;
            local nDistance = getDistanceBetweenPoints3D(aTargetPos.x, aTargetPos.y, aTargetPos.z, nBotX, nBotY, nBotZ)
        
            local nAngle = getRotateToPoint(data.element, aTargetPos.x, aTargetPos.y);
            setElementRotation(data.element, 0, 0, nAngle, 'default', true)
            setPedControlState(data.element, "forwards", true);
        
            if nDistance <= 1 then
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
            triggerEvent( 'onAIStopSearchTarget', data.element, data.target )

            setPedControlState(data.element, 'forwards', false);
            setElementData(data.element, 'lastDistanceToTarget', nil, false);
            data.target = false;  
            if data.sync.syncer == localPlayer then
                data:syncAll();
            end
        end;    
    };
};
CStates:add(CDefaultState);

--------------------------------
--- States events

addEvent('onAISeeTarget')
addEvent('onAILostTarget')
addEvent('onAIStopSearchTarget')