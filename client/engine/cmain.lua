----------------
-- Localization of global values, for greater optimization
local isElement             = isElement
local ipairs                = ipairs
local pairs                = ipairs
local setElementData        = setElementData
local getElementData        = getElementData
local tableinsert           = table.insert
local tableremove           = table.remove

----------------
--- Variables

aSettings = getScriptSettings();
g_BotsData = {} -- Bot`s datatable

----------------
--- Main code block

CBot = {

    --variables
    nLastSync = 0;
    nSyncControls = {
        'forwards', 'backwards', 
        'left', 'right', 
        'jump', 'sprint', 'walk', 'crouch', 
        'fire', 'aim_weapon'
    };

    new = function(self, bot, botData) 
        if isElement(bot) then
            if type(botData) == 'table' then
                local id = getElementData(bot, "dd_botTID")

                if not g_BotsData[id] or not id then
                    local obj = self:init(bot, targetPlayer, botData);
                    return obj;
                end
                return g_BotsData[id];
            end
        end
        return false;
    end;

    init = function(self, bot, targetPlayer, botData)
        local object = botData;
            object.element  = bot;
            object.target   = targetPlayer;
            object.lastHit = 0;
            object.seeData  = {
                see = false;
                pos = {
                    x = 0,
                    y = 0,
                    z = 0};
            };
        local botID = #g_BotsData + 1
        local newObject = setmetatable(object, self)
        tableinsert(g_BotsData, botID, newObject)

        setElementData(bot, "dd_botTID", botID, false)

        triggerEvent( 'onBotAdd', bot, newObject );
        return newObject;
    end;

    delete = function(self, botElement )
        local data, id = getElementTable( self.element or botElement )
        if data then
            g_BotsData[id] = nil;
            setElementData(data.element, "dd_botTID", nil, false)
            return true;
        end
        
        return false;
    end;

    update = function(self)
        for index, data in ipairs(g_BotsData) do
            local element = data.element
            if isElement(element) then
                if data.sync.syncer == localPlayer then
                    local tick = getTickCount()
                    if tick - self.nLastSync > aSettings.nSyncDataInterval then
                        data:syncElement( true );
                        self.nLastSync = tick
                    end
                end
                CStates:trigger( data, 'onUpdate' )
            else
                data:delete(index);
            end
        end;
    end;

    syncElement = function( self, fastTrigger )
        local element = self.element
        
        --Pairs control states
        local controls = {}
        for i, control in ipairs( self.nSyncControls ) do
            local state
            if disableAllControls then
                state = false
            else
                state =  getPedControlState(element, control)
            end
            controls[control] = state
        end

        if fastTrigger then
            triggerServerEvent('onPlayerSendData', element, self, controls)
        else
            triggerLatentServerEvent('onPlayerSendData', element, self, controls)
        end
        
    end;

    syncAnimation = function( self, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime, retainPedState )
        if self.sync.syncer == localPlayer then
            triggerServerEvent('onPlayerSendAnimation', self.element, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime, retainPedState)
        end
        setPedAnimation(self.element, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame, blendTime, retainPedState)
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
        local get = CBot[key]
        if get then
            return get;
        else
            return rawget(self, key);
    end;

};
setTimer(CBot.update, aSettings.nUpdateInterval, 0, CBot)