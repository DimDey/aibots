local CWaypointState = {

    type = 'waypoint';
    states = {

        onUpdate = function( self, data )

            local waypoints = data.waypoints

            local currentPoint = data.currentWaypoint or 1;
            local currentTarget = waypoints[currentPoint]
            
            if data.target then  
                return CStates['default'].states['onUpdate']( CStates['default'], data )
            end
            
            local wX, wY, wZ = currentTarget.x, currentTarget.y, currentTarget.z
            local seeWaypoint, waypointDistance = data:isBotSeePosition(wX, wY, wZ, false, 100)
    
    
            if seeWaypoint then
                if waypointDistance < 2 then -- if element near waypoint
                    if currentTarget.reachTime then
                        if not data.reachTime then
                            data.reachTime = getTickCount( );
                        end

                        setPedControlState(data.element, "forwards", false);

                        if currentTarget.reachAnimation and not data.playReachAnimation then
                            data.playReachAnimation = true
                            setPedAnimation( data.element, currentTarget.reachAnimation.block, currentTarget.reachAnimation.anim, -1, false, false )
                            triggerEvent( 'onAIReachAnimation', data.element, currentTarget.reachAnimation );
                        end

                        if getTickCount( ) - (data.reachTime + currentTarget.reachTime) > 0 then

                            self:onWayReached( data );

                            setPedAnimation( data.element );
                            data.reachTime = nil
                            data.playReachAnimation = false
                        end
                    else
                        self:onWayReached( data );
                    end
                else
                    local angle = getRotateToPoint(data.element, wX, wY);
                    setElementRotation(data.element, 0, 0, angle, 'default', true)
                    setPedControlState(data.element, "forwards", true);
                end
            else
                triggerEvent( 'onAILostWay', data.element, currentTarget )
                if aSettings.waypointTeleport then
                    setElementPosition(data.element, wX, wY, wZ, true);
                else
                    self:changeDirection( data, false );
                end
            end
        end;  

    };

    onWayReached = function( self, data )

        local waypoints = data.waypoints
        local waypointDirection = data.waypointDirection or 'next';

        local currentPoint = data.currentWaypoint or 1;
        local currentTarget = waypoints[currentPoint]

        triggerEvent( 'onAIReached', data.element, currentTarget );

        if not currentTarget[waypointDirection] or #currentTarget[waypointDirection] == 0 then 
            --If the next point in the current direction does not exist
            self:changeDirection( data, true );
        end

        local wayCounts = #currentTarget[waypointDirection]
        local nextWay

        if wayCounts > 1 then
            local randomNext = math.random(1, wayCounts)
            nextWay = currentTarget[waypointDirection][randomNext]
        else
            nextWay = currentTarget[waypointDirection][1]
        end

        data.currentWaypoint = nextWay

        return nextWay;
    end;

    changeDirection = function( self, data, calledFromReach )
        local waypointDirection = data.waypointDirection or 'next';

        if waypointDirection == 'next' then
            data.waypointDirection = 'back'
        else
            data.waypointDirection = 'next'
        end
        waypointDirection = data.waypointDirection

        if not calledFromReach then
            self:onWayReached( data );
        end
        
        return waypointDirection;
    end;


}
CStates:add(CWaypointState);

--------------------------------
--- States events
addEvent('onAIReachAnimation')
addEvent('onAIReached')
addEvent('onAILostWay')