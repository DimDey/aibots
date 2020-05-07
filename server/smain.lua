local aSettings = getScriptSettings();
g_Data = {}
g_Data.Bots  = {}
g_Data.Types = {
    ['bot'] = true;
}

SBots = {
    methods = {
        --------------------
        -- bool or element SBots:create ( table botData )
        --[[
            Creating new AIbot.
            If the bot is successfully created, the function 
            returns a metatable of data, otherwise returns false.

            An example you can see in line 147-160[CreateObject function]
        ]]
        create = function( self )
       
            if not g_Data.Types[self.type] then
                return false;
            end

            -- create ped and colshape
            local spawnX, spawnY, spawnZ = self.spawnX, self.spawnY, self.spawnZ
            local botElement  = createPed( self.skin, spawnX, spawnY, spawnZ, self.spawnRot ) 
            local botColShape = createColSphere( spawnX, spawnY, spawnZ, 10 )
            attachElements( botColShape, botElement );

            addEventHandler( 'onColShapeHit', botColShape, SEvents.onColShapeHit  )
    

            local object = {} -- initilize data 
                object.element = botElement;
                object.type    = self.type;
                object.col     = botColShape;  
                object.spawn = {
                    pos = Vector3(spawnX, spawnY, spawnZ);
                    rot = self.spawnRot;
                    skin  = self.skin;
                };
                object.sync = {
                    syncer = nil;
                    players = {};
                };
            self = object;
            
            -- Insert data in datatable and init metatable
            local id = #g_Data.Bots + 1
            table.insert(g_Data.Bots, id, self)
            setmetatable(self, { 
                __index = function(self, key)
                    outputDebugString(key)
                    local get = SBots.methods[key]
                    if get then
                    
                        return get;
                    else
                        return rawget(self, key);
                    end
                end; 
            });

            
            -- Set main element data
            setElementData( botElement, 'dd_tableID', id, false );
            setElementData( botElement, "dd_isAIBot", true );

            return self;
        end;
    
        --------------------
        -- BOT METHODS

        --------------------
        -- bool SBots:respawn ( )
        --[[
            Revives a bot and teleports it to its starting position
        ]]

        respawn = function( self )
            local x, y, z, rotation = self:getSpawnPositions();
            local element = self.element;
            element.health = 100;
            element.position = x, y, z;
            element.rotation = 0, 0, rotation;
            return true;
        end;

        --------------------
        -- Vector3, number SBots:getSpawnPositions ( )
        -- Allows you to retrieve the spawn position coordinates of an element.
        
        getSpawnPositions = function( self )
            return self.spawn.pos, self.spawn.rot
        end;

        --------------------
        -- Vector3 SBots:getSpawnPositions ( Vector3 positionVector )
        -- This function sets the position of an element to the specified coordinates.

        setSpawnPositions = function( self, positionVector )
            self.spawn.pos = positionVector
            return self.spawn.pos;
        end;   
        

        getPosition = function( self )
            local x, y, z = self.element.position
            return Vector3(x, y, z);
        end;

        setPosition = function( self, positionVector )
            self.element.position = positionVector;
            return true;
        end;

        updateSyncer = function( self, player ) -- choose the best representative for sync
            if self.sync.players then 
                local players = self.sync.players
    
                local minPing = 3000
                local repPlayer
                outputDebugString(inspect(players))
                for i, player in ipairs( players ) do
                    local playerPing = getPlayerPing( player );
                    if playerPing >= 300 then
                        players[player] = nil
                    end;
                    if minPing > playerPing then
                        repPlayer = player;
                        minPing = playerPing;
                    end;
                end;
    
                if repPlayer then
                    setElementSyncer( self.element, repPlayer );
                    self.sync.syncer = repPlayer;
                    return repPlayer
                end;
            end
            return false;
        end;
    
        setTarget = function( self, player )
            if not self.sync.syncer then
                self:updateSyncer( );
            end
            local players = self.sync.players
            if not players[player] and player.type == 'player' then
                table.insert(self.sync.players, player);
            end
            self.target = player;
            
            triggerClientEvent( players, "dd_updateBotData", self.element, self )
            return player;
        end;
    
        getTarget = function(self)
            return self.target;
        end;
    };
};

function createBot( object )
    setmetatable( object, {
        __index = function(self, key)
            local get = SBots.methods[key]
            if get then
                return get;
            else
                return rawget(self, key);
            end
        end; 
    });
    return object:create();
end


local bot = createBot{
    type    = 'bot';
    spawnX  = 132, 
    spawnY  = -68, 
    spawnZ  = 1,
    skin = 0
};