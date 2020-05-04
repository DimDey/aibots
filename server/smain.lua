local aSettings = getScriptSettings();
g_Data = {}
g_Data.Bots  = {}
g_Data.Types = {
    ['bot'] = {};
}

SBots = {
    create = function(botData)
        if type(botData) == 'table' then
            if not g_Data.Types[botData.type] then
                return false;
            end
            
            local spawnX, spawnY, spawnZ = botData.spawnX, botData.spawnY, botData.spawnZ
            local botElement  = createPed(botData.skin, spawnX, spawnY, spawnZ, botData.spawnRot)
            local botColShape = createColSphere(spawnX, spawnY, spawnZ, 10)
            attachElements(botColShape, botElement);


            local object, id = self:new{
                element = botElement;
                type    = botData.type;
                col     = botColShape;  
                spawn = {
                    pos = Vector3(spawnX, spawnY, spawnZ);
                    rot = botData.spawnRot;
                    skin  = skin;
                };
                sync = {
                    syncer = nil;
                    players = {};
                };
            };

            setElementData(botElement, 'dd_tableID', id);
            setElementData(botElement, "dd_isAIBot", true);
            
            return object;
        end
        return false;
    end;

    new = function(botData)
        local object = botData;
        local id = #g_Data.Bots + 1


        table.insert(g_Data.Bots, id, object)
        setmetatable(object, SBots);

        return object, id;
    end;


    methods = { -- public methods
        updateSyncer = function(self, player) -- choose the best representative for sync
            if self.sync.players then 
                local players = self.sync.players
    
                local minPing
                local repPlayer
                for player, sync in pairs(players) do
                    local playerPing = getPlayerPing(player);
                    if playerPing >= 300 then
                        players[player] = nil
                    end;
                    if minPing > playerPing then
                        repPlayer = player;
                        minPing = playerPing;
                    end;
                end;
    
                setElementSyncer(self.element, repPlayer);
                self.sync.syncer = repPlayer;
                return repPlayer
            end
            return false;
        end;
    
        setTarget = function(self, player)
            if not self.sync.syncer then
                self:setSyncer();
            end
    
        end;
    
        getTarget = function(self)
            return self.target;
        end;
    };

    events = {
        --------------------
        -- bool or element SBots.events.onBotStreamIn ( element hitElement )
        --[[
            Called when a player has entered a colshape.
        ]]

        onColShapeHit = function(hitElement)
            local element = getElementAttachedTo(source)
            if isElement(element) then
                local elementTable = getElementTable(element)
                local player


                if getElementHealth(element) > 0 then


                    if getElementType(hitElement) == "player" then
                        player = hitElement
                    elseif getElementType(hitElement) == "vehicle" then
                        player = getVehicleOccupant(hitElement)
                    end


                    if player then
                        if not elementTable.target then
                            return elementTable:setTarget(element);
                        end
                    end

                end
            end
            return false;
        end;

        --------------------
        -- bool SBots.events.onBotStreamIn ( element bot, element player )
        --[[
            Called from the clientside when bot entered the player`s stream.
        ]]

        onBotStreamIn = function(bot, player) 
            local elementTable = getElementTable(bot)
            if elementTable then
                if not elementTable.sync.players[player] then
                    elementTable.sync.players[player] = true;
                    if elementTable.target then
                        triggerClientEvent(player, 'dd_onServerData', bot, elementTable.target);
                    end

                    if not elementTable.sync.syncer then
                        elementTable:setSyncer();
                    end

                    return true;
                end
            end
            return false;
        end;

        --------------------
        -- bool SBots.events.onBotStreamOut ( element bot, element player )
        --[[
            Called from the clientside when the bot has leave from the player’s stream.
        ]]

        onBotStreamOut = function(bot, player)
            local elementTable = getElementTable(bot)
            if elementTable then
                if elementTable.sync.players[player] then
                    if elementTable.sync.syncer == player then
                        elementTable:updateSyncer();
                        return true;
                    end
                end
            end
            return false;
        end;    
    };


    __index = function(self, key)
        return rawget(self.methods, key)
    end;    
};

local bot = SBots:create{
    type    = 'bot';
    spawnX  = 132, 
    spawnY  = -68, 
    spawnZ  = 1    
}

print(bot);