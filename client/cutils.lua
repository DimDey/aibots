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
        local id = getElementData(bot, 'dd_botClientTID')
        if aBots[id] then
            return aBots[id], id;
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

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end