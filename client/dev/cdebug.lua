local DEBUG_MODE = true
setDevelopmentMode(DEBUG_MODE, DEBUG_MODE)

function renderDebug()
    for index, data in ipairs(g_BotsData) do
        local bX, bY, bZ = getElementPosition(data.element)
        if data.target and data.target ~= 'lost' then
            local tX, tY, tZ = getElementPosition(data.target)

            local color
            if data.seeData.see then
                color = tocolor(10, 155, 10, 155)
            else
                color = tocolor(155, 10, 10, 155)
            end

            dxDrawLine3D(bX, bY, bZ, tX, tY, tZ, color, 3)
        end
        if data.waypoints then
            for i = 1, #data.waypoints do
                local waypoint = data.waypoints[i]
                local wX, wY, wZ = waypoint.x, waypoint.y, waypoint.z
                dxDrawLine3D(wX, wY, wZ, wX, wY, wZ + 3, tocolor(155, 10, 10, 155), 3)

                local backPoints = waypoint.back
                local nextPoints = waypoint.next
                local pointColor = tocolor(255, 10, 10, 155)
            
                if backPoints then
                    for i, backId in ipairs(backPoints) do
                        local backPoint = data.waypoints[backId]
                        local bX, bY, bZ = backPoint.x, backPoint.y, backPoint.z
                        dxDrawLine3D(wX, wY, wZ, bX, bY - 0.2, bZ, tocolor(255, 50, 50, 100))
                    end
                end
    
                if nextPoints then
                    for i, nextId in ipairs(nextPoints) do
                        local nextPoint = data.waypoints[nextId]
                        local nX, nY, nZ = nextPoint.x, nextPoint.y, nextPoint.z
                        dxDrawLine3D(wX, wY, wZ, nX, nY + 0.1, nZ, tocolor(50, 255, 50, 100))
                    end
                    
                end
            end
        end
    end
end
addEventHandler("onClientPreRender", root, renderDebug)