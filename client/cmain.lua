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

local g_BotsData = {} -- Bot`s datatable

----------------
--- Main code block

CBots = {

    new = function(self, bot, targetPlayer, botData) 
        if isElement(botElement) then
            if type(botData) == 'table' then
                local id = getElementData(bot, "botTID")
                if not g_BotsData[id] or not id then
                    return self:init(botElement, targetPlayer, botData);
                end
                return g_BotsData[id];
            end
        end
        return false;
    end;

    init = function(self, botElement, targetPlayer, botData)
        outputDebugString("initial")
        local object = botData
            object.element  = botElement;
            object.target   = targetPlayer;
            object.lastHit = 0;
            object.seeData  = {
                see = false;
                pos = {Vector3(0,0,0)};
            };
        local botID = #g_BotsData + 1
        tableinsert(g_BotsData, botID, object)

        setElementData(botElement, "botTID", botID, false)
        return setmetatable(object, CBots);
    end;

    delete = function(self, id)
        outputDebugString("delete")
        local id = id or getElementData(self.element, "botTID")
        if id then
            tableremove(g_BotsData, id);
            setElementData(self.element, "botTID", nil, false)
            return true;
        end
        
        return false;
    end;

    update = function(self)
        outputDebugString(inspect(g_BotsData))
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
                        
                        self:trigger("onSee");
                    else
                        --onLost
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
        local aBotPos = Vector3(getElementPosition(self.element))
        local aTargetPos = Vector3(getElementPosition(self.target))
        local seeData = self.seeData
        
        if getDistanceBetweenPoints3D(aBotPos.x, aBotPos.y, aBotPos.z, aTPos.x, aTPos.y, aTPos.z) <= botData.viewdistance then
            local isclear = isLineOfSightClear(
                aBotPos.x, aBotPos.y, aBotPos.z, 
                aTargetPos.x, aTargetPos.y, aTargetPos.z, 
                true, false, checkPed, true, true, false, true, target);
            seeData.see = isclear
            if isclear then
                see.pos = aTargetPos
            end
            return isclear
        else
            seeData.see = false;
            return false
        end
    end;    

    trigger = function(self, event)
        if self.eventHandlers.event then
            outputDebugString("TRIGGERED EVENT: "..event)
        end
    end;

    eventHandlers = { -- EVENT HANDLERS
        onSee = function(self)
            if isElement(self.element) then
                local aBotPos = Vector3(getElementPosition(self.element));
                local aTargetPos = self.seeData.pos;

                local nTick = getTickCount();
                local nLastHit = self.lastHit;

                local block, anim = getPedAnimation(self.element)
            end
            return false;
        end;
    }
};
setTimer(CBots.update, nUpdateInterval, 0, CBots)

local ped = createPed(98, 132, -68, 1, 0)
CBots:new(ped, localPlayer, {})