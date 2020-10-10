aData = {}
aData.bots = {}

SBotModule = {
    --------------------
    -- bool or element SBotModule:create ( table botData )
    --[[
        Creating new AIbot.
        If the bot is successfully created, the function 
        returns a metatable of data, otherwise returns false.

        An example you can see in line 147-160[CreateObject function]
    ]]
    create = function( self, object )
        if not getTypeData(object.type) then
            return false;
        end

        local typeData = getTypeData(object.type);
        local bot = object
            bot.element = createPed( object.skin, object.spawnX, object.spawnY, object.spawnZ, object.spawnRot )
            bot.col     = createColSphere( object.spawnX, object.spawnY, object.spawnZ, typeData.viewdistance )
            bot.type    = object.type

            bot.spawn   = {
                    pos          = Vector3(object.spawnX, object.spawnY, object.spawnZ);
                    rot          = object.spawnRot;
                    skin         = object.skin;
            }
            bot.sync    = {
                    syncer       = nil;
                    players      = {};
                    playersCount = 0;
            }
        

        
        setPedWalkingStyle(bot.element, typeData.walkingstyle)
        setPedFightingStyle(bot.element, typeData.fightingstyle)

        attachElements( bot.col, bot.element );
        addEventHandler( 'onColShapeHit', bot.col, SBotEvents.onColShapeHit  )

        local id = #aData.bots + 1
        setmetatable(bot, { 
            __index = function(self, key)
                local get = SBotModule.public[key]
                if get then
                    return get;
                else
                    return rawget(self, key);
                end
            end; 
        });
        table.insert(aData.bots, id, bot)

        setElementData( bot.element, 'dd_tableID', id, false );
        setElementData( bot.element, "dd_isAIBot", true );
        
        return bot
    end;

    --------------------
    --  BOT METHODS

    --------------------
    public = {
        
        -- bool SBotModule:respawn ( )
        --[[
            Revives a bot and teleports it to its starting position
        ]]

        respawn = function( self )
            local x, y, z, rotation = self:getSpawnPositions();
            local element = self.element;
            element.health = 100;
            element.position = x, y, z;
            element.rotation = 0, 0, rotation;

            triggerEvent( 'onAIRespawn', element );

            return true;
        end;

        --------------------
        -- Vector3, number SBotModule:getSpawnPositions ( )
        -- Allows you to retrieve the spawn position coordinates of an element.
        
        getSpawnPositions = function( self )
            return self.spawn.pos, self.spawn.rot
        end;

        --------------------
        -- Vector3 SBotModule:getSpawnPositions ( Vector3 positionVector )
        -- This function sets the position of an element to the specified coordinates.

        setSpawnPositions = function( self, positionVector )
            self.spawn.pos = positionVector
            return self.spawn.pos;
        end;   

        getPosition = function( self )
            local x, y, z = self.element.position
            return x, y, z;
        end;

        setPosition = function( self, positionVector )
            self.element.position = positionVector;
            return true;
        end;

        updateSyncer = function( self, bestPlayer ) -- choose the best representative for sync
            bestPlayer = bestPlayer or nil

            if self.sync.playersCount > 0 then
                local prevSyncer = self.sync.syncer
                local minPing = 99999999
                
                for player, sync in pairs( self.sync.players ) do
                    if not sync then return end
                    if player.type == 'player' then
                        if player.ping < minPing then
                            bestPlayer = player
                            minPing = player.ping
                        end
                    end
                end
            end

            if prevSyncer then
                triggerClientEvent( prevSyncer, 'onServerDeleteBot', bot )
            end

            if bestPlayer then
                setElementSyncer( self.element, bestPlayer );
                self.sync.syncer = bestPlayer;
                triggerClientEvent( bestPlayer, 'onServerAddBot', self.element, self );

                
                return bestPlayer
            else
                error('SYNCER FOR AI('..tostring(self.element)..') NOT FOUND')
                return false;
            end
        end;
    
        setTarget = function( self, player )
            local players = self.sync.players
            if player.type == 'player' then
                self.sync.players[player] = true
            else
                self.sync.players[player] = false
            end
            self.target = player;

            triggerEvent( 'onBotDataUpdate', self.element, self, false )
            
            return player;
        end;
    
        getTarget = function(self)
            return self.target;
        end;

        setTeam = function(self, team)
            if team.type == 'team' then
                self.team = team;
            end
            triggerEvent( 'onBotDataUpdate', self.element, self, false )
        end;

        getTeam = function(self)
            return self.team;
        end;

        setWaypoints = function( self, waypointsTable )
            if type(waypointsTable) == 'table' then
                self.waypoints = waypointsTable;
                triggerEvent( 'onBotDataUpdate', self.element, self, false )
                return true;
            end
        end;
    };

    __index = function(self, key)
        local get = SBotModule.public[key]
        if get then
            return get;
        else
            return rawget(self, key);
        end
    end; 
};