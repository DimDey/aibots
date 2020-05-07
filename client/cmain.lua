----------------
-- Localization of global values, for greater optimization
local getElementData        = getElementData
local isElement             = isElement
local ipairs                = ipairs
local setElementData        = setElementData
local getElementData        = getElementData
local tableinsert           = table.insert
local tableremove           = table.remove

----------------
--- Variables

local aSettings = getScriptSettings();
local nUpdateInterval = aSettings.nUpdateInterval

g_BotsData = {} -- Bot`s datatable

----------------
--- Main code block

CBots = {
    new = function(self, bot, botData) 
        if isElement(bot) then
            if type(botData) == 'table' then
                local id = getElementData(bot, "dd_botTID")
                local targetPlayer = botData.target 

                if not targetPlayer then
                    return false;
                end

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
        local object = {unpack(botData)};
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
        return newObject;
    end;

    delete = function(self, id)
        local id = id or getElementData(self.element, "dd_botTID")
        if id then
            tableremove(g_BotsData, id);
            setElementData(self.element, "dd_botTID", nil, false)
            return true;
        end
        
        return false;
    end;

    update = function(self)
        for index, data in ipairs(g_BotsData) do
            local element = data.element
            local target  = data.target
            
            if isElement(element) and isElement(data.target) then
                if data.target then
                    if getElementHealth(element) == 0 or getElementHealth(target) == 0 then
                        data:delete(index);
                    end
                    local lX, lY, lZ = getElementPosition(target);
                    local bX, bY, bZ = getElementPosition(element);

                    
                    local see = data:isBotSeePlayer(false)
                    if see then
                        triggerEvent('onBotSee', data.element, data);
                    else
                        triggerEvent('onBotLost', data.element, data);
                    end

                else
                    data:delete(index);
                end
            else
                data:delete(index);
            end
        end;
    end;
    
    isBotSeePlayer = function(self, checkPed)
        local botPosX, botPosY, botPosZ = getElementPosition(self.element)
        local targetPosX, targetPosY, targetPosZ = getElementPosition(self.target)
        local seeData = self.seeData
        local viewdistance = self.viewdistance or 10
        
        if getDistanceBetweenPoints3D(botPosX, botPosY, botPosZ, targetPosX, targetPosY, targetPosZ) <= viewdistance then
            local isclear = isLineOfSightClear(
                botPosX, botPosY, botPosZ, 
                targetPosX, targetPosY, targetPosZ, 
                true, false, checkPed, true, true, false, true, target);
            seeData.see = isclear
            if isclear then
                seeData.pos = {
                    x = targetPosX, 
                    y = targetPosY, 
                    z = targetPosZ}
            end
            return isclear
        else
            seeData.see = false;
            return false
        end
    end;


    stateHandlers = {
        hunt = {
            onSee = function(self)
                local aBotPos = Vector3(getElementPosition(self.element));
                local aTargetPos = self.seeData.pos;
                local angle = getRotateToPoint(self.element, aTargetPos.x, aTargetPos.y);
                setElementRotation(self.element, 0, 0, angle, 'default', true)

                setPedControlState(self.element, "forwards", true);
            end; 
            
            onLost = function(self)
                local aTargetPos = self.seeData.pos;
                if aTargetPos.x and aTargetPos.y then
                    local aBotPos = Vector3(getElementPosition(self.element))
                    local distance = getDistanceBetweenPoints3D(
                        aTargetPos.x, aTargetPos.y, aTargetPos.z,
                        aBotPos.x, aBotPos.y, aBotPos.z)
                    if (distance <= 5) or (self.distance and self.distance < distance) then
                        setControlState(self.element, 'forwards', false);
                        self.distance = nil;
                    else
                        self.distance = distance;
                    end
                end
            end;
        }
    }

    eventHandlers = { -- EVENT HANDLERS
        onSee = function(self)
            if isElement(self.element) then
                self.stateHandlers[self.state].onSee(self);
            end
            return false;
        end;

        onLost = function( self )
            if self.target then
                elf.stateHandlers[self.state].onLost(self);
            end
        end;    
    };

    __index = function(self, key)
        local get = CBots[key]
        if get then
            return get;
        else
            return rawget(self, key)
        end
    end;
};
setTimer(CBots.update, nUpdateInterval, 0, CBots)

setDevelopmentMode(true, true)

addEvent('onBotSee', true)
addEvent('onBotLost', true)
addEventHandler('onBotSee', root, CBots.eventHandlers.onSee)
addEventHandler('onBotLost', root, CBots.eventHandlers.onLost)