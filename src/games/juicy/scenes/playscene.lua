require 'external.middleclass'
require 'core.scene'
require 'collections.set'
require 'core.entity.world'
require 'core.components.transform'
require 'core.components.rendering'
require 'core.components.collider'
require 'core.components.motion'
require 'core.components.behavior'
require 'core.components.inputresponse'
require 'core.components.soundcomponent'
require 'core.shapedata'
require 'behaviors.ballbehaviors'
require 'behaviors.playerbehaviors'
require 'entitysets'
require 'scripts.oldeffects'

require 'settings'

require 'enums.actions'
require 'enums.assets'
require 'enums.tags'
require 'enums.palette'

require 'entitybuilders.ball'
require 'entitybuilders.player'
require 'entitybuilders.walls'
require 'entitybuilders.bricks'

GlobalEffects = require 'scripts.globaleffects'


PlayScene = class('Play', Scene)




local registerGlobalInputs = function (world)

    local em = world:getEntityManager()
    local input_system = world:getInputSystem()

    input_system:registerInput('escape', Actions.RESET_BOARD)
    input_system:registerInput('q', Actions.QUIT_GAME)

    local globalInputResponse = function(entity, held_actions, pressed_actions, dt)

        -- Reset the Board
        if pressed_actions[Actions.RESET_BOARD] then
            entity:getWorld():getSceneManager():changeScene(Scenes.PLAY)
        end

        -- Quit
        if pressed_actions[Actions.QUIT_GAME] then
            love.event.push("quit")
        end

    end

    local global_input_responder = em:createEntity('globalinputresponse')
    global_input_responder:addComponent(InputResponse():addResponse(globalInputResponse))
    world:addEntityToGroup(Tags.PLAY_GROUP, global_input_responder)


end

local createBackgroundImage = function (world)


    local em = world:getEntityManager()

    local play_background = em:createEntity('play_background')
    play_background:addComponent(Transform(0, 0):setLayerOrder(10))
    play_background:addComponent(ShapeRendering():setColor(Palette.COLOR_BACKGROUND:unpack()):setShape(RectangleShape:new(love.graphics.getWidth(), love.graphics.getHeight())))
    world:tagEntity(Tags.BACKGROUND, play_background)
    world:addEntityToGroup(Tags.PLAY_GROUP, play_background)


end

local loadBackgroundSound = function (world)

    local em = world:getEntityManager()

    local asset_manager = world:getAssetManager()
    local bsnd = "You_Kill_My_Brother_-_07_-_Micro_Invasion_-_You_Kill_My_Brother_-_Go_Go_Go.mp3"

    local this_sound = asset_manager:loadSound(Assets.BACKGROUND_SOUND, bsnd)
    this_sound:setVolume(0.25)
    this_sound:setLooping(true)
    this_sound:play()

    local background_sound_entity = em:createEntity('background_sound')
    background_sound_entity:addComponent(SoundComponent():addSound(Assets.BACKGROUND_SOUND, this_sound))
    world:tagEntity(Tags.BACKGROUND_SOUND, background_sound_entity)
    world:addEntityToGroup(Tags.PLAY_GROUP, background_sound_entity)

end


local resetCollisionSystem = function(world)

    local collision_system = world:getSystem(CollisionSystem)

    collision_system:reset()

    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getEntitiesInGroup(Tags.BRICK_GROUP))
    collision_system:watchCollision(world:getTaggedEntity(Tags.PLAYER), world:getEntitiesInGroup(Tags.WALL_GROUP))
    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getTaggedEntity(Tags.PLAYER))
    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getEntitiesInGroup(Tags.WALL_GROUP))

end

local createGlobalEventListener = function(world)

    local em = world:getEntityManager()
    local message_system = world:getSystem(MessageSystem)

    -- Global listener that sets effects
    local panopticon = em:createEntity('panopticon')
    world:tagEntity(Tags.PANOPTICON, panopticon)

    local pan_message = Messaging(world:getSystem(MessageSystem))
    panopticon:addComponent(pan_message)

    pan_message:registerMessageResponse(Events.BALL_COLLISION_PLAYER, function(ball, player)

        local statistics_system = world:getStatisticsSystem()
        local time_system = world:getTimeSystem()

        statistics_system:addToEventTally(Events.BALL_COLLISION_PLAYER)
        statistics_system:registerTimedEventOccurence(Events.BALL_COLLISION_PLAYER, time_system:getTime())

        GlobalEffects.cameraShake(world)
        EffectDispatcher.allEffects(ball, 2, 1.5)
        EffectDispatcher.scaleEntity(player, 1.5, 1.3)
        --EffectDispatcher.rotateJitter(player, 1)

    end)

    pan_message:registerMessageResponse(Events.BALL_COLLISION_BRICK, function(ball, brick)


        local statistics_system = world:getStatisticsSystem()
        local time_system = world:getTimeSystem()

        statistics_system:addToEventTally(Events.BALL_COLLISION_BRICK)
        EffectDispatcher.playBrickSoundWithAdjustedPitch(brick, statistics_system:timeSinceLastEventOccurence(Events.BALL_COLLISION_BRICK, time_system:getTime()))
        statistics_system:registerTimedEventOccurence(Events.BALL_COLLISION_BRICK, time_system:getTime())

        EffectDispatcher.dispatchBrick(ball, brick)
        GlobalEffects.cameraShake(world)
        EffectDispatcher.allEffects(ball, 2, 1.5)
        GlobalEffects.slowMo(world, 0.5)
        --EffectDispatcher.cameraZoom(brick)

    end)

    pan_message:registerMessageResponse(Events.BALL_COLLISION_WALL, function(ball, wall)
        
        local statistics_system = world:getStatisticsSystem()
        local time_system = world:getTimeSystem()

        statistics_system:addToEventTally(Events.BALL_COLLISION_WALL)
        statistics_system:registerTimedEventOccurence(Events.BALL_COLLISION_WALL, time_system:getTime())

        GlobalEffects.cameraShake(world)
        EffectDispatcher.allEffects(ball, 2, 1.5)
        EffectDispatcher.scaleEntity(wall, 5, 5)


    end)
end

function PlayScene:initialize(name, w)

    Scene.initialize(self, name, w)

    local world = self.world

    self.effects = EffectDispatcher(world)

    registerGlobalInputs(world)

    createBackgroundImage(world)

    loadBackgroundSound(world)

    -- Initialize complicated entities

    self.ball_builder = BallBuilder(world)
    self.player_builder = PlayerBuilder(world)
    self.wall_builder = WallBuilder(world)
    self.brick_builder = BrickBuilder(world)


    self.ball_builder:create()
    self.player_builder:create()
    self.wall_builder:create()
    self.brick_builder:create()

    createGlobalEventListener(world)

  
end

function PlayScene:reset()

    self.world:getTimeSystem():stop()
    
    self.ball_builder:reset()
    self.player_builder:reset()
    self.brick_builder:reset()

    resetCollisionSystem(self.world)

    -- TODO: add to brick reset
    if Settings.BRICKS_DROPIN then
        self.effects:dropInBricks()
    end

    -- TODO: add to player reset
    if Settings.PLAYER_DROPIN then
        self.effects:dropInPlayer()
    end

end

function PlayScene:enter()

    self:reset()

end

function PlayScene:update(love_dt)

    -- Update time system
    local time_system = world:getTimeSystem()

    time_system:update(love_dt)

    -- Spoof DT to be the current time system's dt
    local dt = time_system:getDt()

    -- Update scheduled functions
    self.world:getScheduleSystem():update(dt)

    -- Update tweens 
    self.world:getTweenSystem():update(dt)

    -- Update input
    self.world:getInputSystem():processInputResponses(entitiesRespondingToInput(world), dt)
    
    -- Update behaviors
    self.world:getBehaviorSystem():processBehaviors(entitiesWithBehavior(world), dt) 

    -- Update movement 

    self.world:getMovementSystem():updateMovables(entitiesWithMovement(world), dt)

    --[[ Handle collisions ]]

    local collision_system = self.world:getCollisionSystem()

    local collisions = collision_system:getCollisions()

    -- TODO: don't have if / elses
    for collision_event in collisions:members() do


        if collision_event.a == world:getTaggedEntity(Tags.PLAYER) and
           world:getGroupsContainingEntity(collision_event.b):contains(Tags.WALL_GROUP) then

           collidePlayerWithWall(collision_event.a, collision_event.b)

        elseif collision_event.a == world:getTaggedEntity(Tags.BALL) and
           world:getGroupsContainingEntity(collision_event.b):contains(Tags.WALL_GROUP) then

          collideBallWithWall(collision_event.a, collision_event.b)

        elseif collision_event.a == world:getTaggedEntity(Tags.BALL) and
           collision_event.b == world:getTaggedEntity(Tags.PLAYER) then

           collideBallWithPaddle(collision_event.a, collision_event.b)
      
        elseif collision_event.a == world:getTaggedEntity(Tags.BALL) and
           world:getGroupsContainingEntity(collision_event.b):contains(Tags.BRICK_GROUP) then

          collideBallWithBrick(collision_event.a, collision_event.b)

        end

    end
   


end


function PlayScene:draw()

    -- If we're currently paused, unpause
    self.world:getTimeSystem():go()

    love.graphics.setBackgroundColor(Palette.COLOR_BRICK:unpack())

    self.world:getRenderingSystem():renderDrawables(entitiesWithDrawability(world))

    local debugstart = 50

    if Settings.DEBUG then

        local player_transform =  world:getTaggedEntity(Tags.PLAYER):getComponent(Transform)
        local ball_transform = world:getTaggedEntity(Tags.BALL):getComponent(Transform)
        local ball_collider = world:getTaggedEntity(Tags.BALL):getComponent(Collider)

        love.graphics.print("Ball x: " .. ball_transform.position.x, 50, debugstart + 20)
        love.graphics.print("Ball y: " .. ball_transform.position.y, 50, debugstart + 40)
        love.graphics.print("Ball collider active: " .. tostring(ball_collider.active), 50, debugstart + 60)
        love.graphics.print("Player x: " .. player_transform.position.x, 50, debugstart + 80)
        love.graphics.print("Player y: " .. player_transform.position.y, 50, debugstart + 100)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 50, debugstart + 120)

        local statistics_system = world:getStatisticsSystem()
        local timer_system = world:getTimeSystem()


        love.graphics.print("Number of times ball hit player: " .. statistics_system:getEventTally(Events.BALL_COLLISION_PLAYER), 50, debugstart + 140)
        love.graphics.print("Number of times ball hit wall: " .. statistics_system:getEventTally(Events.BALL_COLLISION_WALL), 50, debugstart + 160)
        love.graphics.print("Number of times ball hit brick: " .. statistics_system:getEventTally(Events.BALL_COLLISION_BRICK), 50, debugstart + 180)

        love.graphics.print("Time since ball hit player: " .. statistics_system:timeSinceLastEventOccurence(Events.BALL_COLLISION_PLAYER, timer_system:getTime()), 50, debugstart + 200)
        love.graphics.print("Time since ball hit wall: " .. statistics_system:timeSinceLastEventOccurence(Events.BALL_COLLISION_WALL, timer_system:getTime()), 50, debugstart + 220)
        love.graphics.print("Time since ball hit brick: " .. statistics_system:timeSinceLastEventOccurence(Events.BALL_COLLISION_BRICK, timer_system:getTime()), 50, debugstart + 240)



    end


end


