--[[local wayp = {}
local activePoint = nil
local isMenuActive = false
local waypointsCount = 0
local nLastClick = 0
local sW, sH = guiGetScreenSize()

local function createWaypoint(x, y, z)
    waypointsCount = waypointsCount + 1
    local object = {
        x = math.floor(x),
        y = math.floor(y),
        z = math.ceil(z),
        next = {},
        back = {}
    }
    local backPoint
    if activePoint then
        backPoint = activePoint
        activePoint = waypointsCount

        table.insert(wayp[backPoint].next, waypointsCount)
    else
        activePoint = 1
        backPoint = nil
    end
    table.insert(object.back, backPoint)

    table.insert(wayp, object)
end


local function onClientClick( button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement )
    if not isCursorShowing() or not isMenuActive then
        return false;
    end

    local bFindClick = false

    if state == 'down' then
        if button == 'left' then
            for index, waypoint in ipairs(wayp) do
                local x, y, z = waypoint.x, waypoint.y, waypoint.z
                local sX, sY = getScreenFromWorldPosition(x, y, z)
                if sX and sY then
                    if isCursorIn(sX, sY, 20, 20) then
                        bFindClick = true

                        activePoint = index
                        break;
                    end
                end
            end

            if bFindClick == false then
                createWaypoint(worldX, worldY, worldZ)
            end
        else
            for index, waypoint in ipairs(wayp) do
                local x, y, z = waypoint.x, waypoint.y, waypoint.z
                local sX, sY = getScreenFromWorldPosition(x, y, z)
                if sX and sY then
                    if isCursorIn(sX, sY, 20, 20) then
                        if activePoint and activePoint ~= index then
                            table.insert( wayp[activePoint].next, index )
                            table.insert( wayp[index].back, activePoint )
                            activePoint = index;
                            break;
                        end
                    end
                end
            end
        end
    end
end
addEventHandler('onClientClick', root, onClientClick)

local function onClientKey(button, press)
    if press then
        if button == 'm' then
            showCursor(not isCursorShowing())
            isMenuActive = not isMenuActive
        elseif button == 'k' then
            local waypJSON = toJSON(wayp, false, 'tabs')
            
            local waypointFilePath = 'data/waypoints/'

            --get files count
            local isExists = true
            local index = 0
            while ( isExists ) do
                index = index + 1
                isExists = fileExists(waypointFilePath.."waypoint"..index..".json")
            end

            local wayFile = fileCreate("data/waypoints/waypoint"..index..".json")
            if (wayFile) then
                fileWrite(wayFile, waypJSON)
                fileClose(wayFile)
            end
        elseif button == 'l' then
            local wayFile = fileOpen('data/waypoints/waypoint1.json')
            local count = fileGetSize(wayFile)
            local data = fileRead(wayFile, count)
            fileClose(wayFile)

            wayp = fromJSON(data)
        end
    end
end
addEventHandler('onClientKey', root, onClientKey)

local function onRend()
    for index, waypoint in ipairs(wayp) do
        local x, y, z = waypoint.x, waypoint.y, waypoint.z
        local sX, sY = getScreenFromWorldPosition(x, y, z)
        if sX and sY then
            local backPoints = waypoint.back
            local nextPoints = waypoint.next
            local pointColor = tocolor(255, 10, 10, 155)
        
            if index == activePoint then
                pointColor = tocolor(255, 155, 155, 155)
            end

            dxDrawRectangle(sX, sY, 15, 15, pointColor)
            dxDrawText(index, sX, sY, sX+15, sY+15, tocolor(255, 255, 255, 255), 1, 'default-bold', 'center', 'center')
        
            if backPoints then
                for i, backId in ipairs(backPoints) do
                    local backPoint = wayp[backId]
                    local bX, bY, bZ = backPoint.x, backPoint.y, backPoint.z
                    dxDrawLine3D(x, y, z, bX, bY - 0.2, bZ, tocolor(255, 50, 50, 100))
                end
            end

            if nextPoints then
                for i, nextId in ipairs(nextPoints) do
                    local nextPoint = wayp[nextId]
                    local nX, nY, nZ = nextPoint.x, nextPoint.y, nextPoint.z
                    dxDrawLine3D(x, y, z, nX, nY + 0.1, nZ, tocolor(50, 255, 50, 100))
                end
                
            end
        end
    end
    dxDrawText(inspect(wayp), 500, sH - 10, 600, sH - 100, white, 1, 'default-bold', 'left', 'bottom' )
end
addEventHandler('onClientRender', root, onRend)]]