local CWaypointState = {

    type = 'waypoint';
    states = {

        onUpdate = function( self, data )

            local waypoints = data.waypoints
            local currentPoint = data.currentWaypoint or 1;
            local waypointDirection = data.waypointDirection or 'next';
            local currentTarget = waypoints[currentPoint]

            if data.target ~= 'lost' and data.target ~= nil then  
                return CStates['default'].states['onUpdate']( CStates['default'], data )
            end
            
            local wX, wY, wZ = currentTarget.x, currentTarget.y, currentTarget.z
            local seeWaypoint, waypointDistance = data:isBotSeePosition(wX, wY, wZ, false, 100)
    
    
            if seeWaypoint then

                local angle = getRotateToPoint(data.element, wX, wY);
                setElementRotation(data.element, 0, 0, angle, 'default', true)
                setPedControlState(data.element, "forwards", true);

                if waypointDistance < 2 then -- if element near waypoint
                    self:onWayReached( data );
                end
            else
                if aSettings.waypointTeleport then
                    outputConsole(inspect(data))
                    setElementPosition(data.element, wX, wY, wZ, true);
                else
                    self:changeDirection( data, false );
                end
            end
        end;  

    };

    onWayReached = function( self, element )
        local waypoints = element.waypoints
        local waypointDirection = element.waypointDirection or 'next';
        local currentPoint = element.currentWaypoint or 1;
        local currentTarget = waypoints[currentPoint]

        if not currentTarget[waypointDirection] or #currentTarget[waypointDirection] == 0 then 
            --If the next point in the current direction does not exist
            self:changeDirection( element, true );
        end

        local wayCounts = #currentTarget[waypointDirection]
        local nextWay

        if wayCounts > 1 then
            local randomNext = math.random(1, wayCounts)
            nextWay = currentTarget[waypointDirection][randomNext]
        else
            nextWay = currentTarget[waypointDirection][1]
        end

        element.currentWaypoint = nextWay

        return nextWay;
    end;

    changeDirection = function( self, element, calledFromReach )
        local waypointDirection = element.waypointDirection or 'next';

        if waypointDirection == 'next' then
            element.waypointDirection = 'back'
        else
            element.waypointDirection = 'next'
        end
        waypointDirection = element.waypointDirection

        if not calledFromReach then
            self:onWayReached( element );
        end
        
        return waypointDirection;
    end;


}
CStates:add(CWaypointState);