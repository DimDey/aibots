addEventHandler('onResourceStart', resourceRoot, function()

    local wayData1 = loadWaypointsFromJSON('waypoint1.json')
    local wayData2 = loadWaypointsFromJSON('waypoint2.json')
    local wayData3 = loadWaypointsFromJSON('waypoint3.json')

    local bot = SBotModule:create{
        type    = 'waypoint';
        spawnX  = 135, 
        spawnY  = -67, 
        spawnZ  = 1,
        skin = 44;
        waypoints = wayData1;
        attacks = true;
    };

    local bot2 = SBotModule:create{
        type    = 'waypoint';
        spawnX  = 125, 
        spawnY  = -86, 
        spawnZ  = 1,
        skin = 77;
        waypoints = wayData2;
        attacks = true;
    };

    local bot3 = SBotModule:create{
        type    = 'waypoint';
        spawnX  = 126, 
        spawnY  = -77, 
        spawnZ  = 1,
        skin = 98;
        waypoints = wayData3;
        attacks = false;
    };
end);