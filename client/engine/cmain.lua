----------------
-- Localization of global values, for greater optimization
local isElement             = isElement
local setElementData        = setElementData
local getElementData        = getElementData
local tableinsert           = table.insert
local tableremove           = table.remove

----------------
--- Variables

aSettings = getScriptSettings();
aBots = {} -- Bot`s datatable

----------------
--- Main code block

CBotModule = {
    nLastSync = 0;
    nSyncControls = {
        'forwards', 'backwards', 
        'left', 'right', 
        'jump', 'sprint', 'walk', 'crouch', 
        'fire', 'aim_weapon'
    };

    add = function(self, bot, botData) 
        if isElement(bot) then
            if type(botData) == 'table' then
                local id = getElementData(bot, "dd_botClientTID")

                if not aBots[id] or not id then
                    local obj = self:create(bot, botData);
                    return obj;
                end
                return aBots[id];
            end
        end
        return false;
    end;

    create = function(self, bot, botData)
        local object = botData;
            object.target   = false;
            object.lastHit  = 0;
            object.seeData  = {
                see = false;
                pos = {
                    x = 0,
                    y = 0,
                    z = 0
                };
            };
        local botID = #aBots + 1
        local newObject = setmetatable(object, self)
        tableinsert(aBots, botID, newObject)

        setElementData(bot, "dd_botClientTID", botID, false)

        triggerEvent( 'onBotAdd', bot, newObject );
        return newObject;
    end;

    delete = function( self )
        local data, id = getElementTable( self.element )
        if data then
            aBots[id] = nil;
            setElementData(data.element, "dd_botTID", nil, false)
            return true;
        end
        
        return false;
    end;

    update = function( self )
        for index, data in ipairs(aBots) do
            local element = data.element
            if not isElement(element) then
                data:delete();
            end
            
            if data.sync.syncer ~= localPlayer then
                data:delete();
            end 

            local nTick = getTickCount()
            local nLastSync = self.nLastSync or 0
            if nTick - nLastSync > aSettings.nSyncDataInterval then
                data:syncAll( );
                self.nLastSync = tick
            end
            CStates:trigger( data, 'onUpdate' )

        end
    end;

    syncAll = function( self )
        local controls = {}
        for i, control in ipairs( self.nSyncControls ) do
            local state
            if disableAllControls then
                state = false
            else
                state = getPedControlState(self.element, control)
            end
            controls[control] = state
        end

        triggerLatentServerEvent('onPlayerSendData', self.element, self, controls)

    end;

    syncAnimation = function( self, ... )
        if self.sync.syncer == localPlayer then
            triggerServerEvent('onPlayerSendAnimation', ...)
        end
        setPedAnimation( ... )
    end;

    isBotSeePosition = function(self, x, y, z, checkPed, viewDistance)
        local botPosX, botPosY, botPosZ = getElementPosition(self.element)
        local seeData = self.seeData
        local viewDistance = viewDistance or self.viewdistance or 10
        local distanceToPoint = getDistanceBetweenPoints3D(botPosX, botPosY, botPosZ, x, y, z)
        
        if distanceToPoint <= viewDistance+15 then
            local hit, hitX, hitY, hitZ = processLineOfSight(botPosX, botPosY, botPosZ, x, y, z, true, false, checkPed, true, true, false, true, true, target);
            seeData.see = not hit
            if not hit then
                seeData.pos = {x = x, y = y, z = z}
            end
            return not hit, distanceToPoint
        else
            seeData.see = false;
            return false, distanceToPoint
        end
    end;

    __index = function(self, key)
        local get = CBotModule[key]
        if get then
            return get;
        else
            return rawget(self, key);
        end
    end;
}
setTimer(CBotModule.update, aSettings.nUpdateInterval, 0, CBotModule)