local deg = math.deg
local atan2 = math.atan
local sW, sH = guiGetScreenSize()

-------------------------
-- number getRotateToPoint( element bot, number x, number y)

function getRotateToPoint(bot, x, y)
    local bX, bY = getElementPosition(bot)
    local angle = ( 360 - math.deg ( math.atan2 ( ( x - bX ), ( y - bY ) ) ) ) % 360
    return angle
end

------------------------------
-- table, number getElementTable ( element bot )

function getElementTable( bot )
    if isElement(bot) then
        local id = getElementData(bot, 'dd_botTID')
        if g_BotsData[id] then
            return g_BotsData[id], id;
        end
    end
    return false;
end

function isCursorIn( x, y, w, h )
    local nX, nY      = getCursorPosition()    
    local cX          = nX*sW;
    local cY          = nY*sH;
    return ( cX >= x and cX <= x+w and cY >= y and cY <= y+h ) == true
end