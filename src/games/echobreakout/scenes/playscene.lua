require 'external.middleclass'
require 'game.scene'
require 'collections.set'
require 'entity.systems.renderingsystem'
require 'entity.systems.collisionsystem'
require 'entity.systems.movementsystem'
require 'entity.systems.behaviorsystem'
require 'entity.systems.camerasystem'
require 'entity.systems.inputsystem'
require 'entity.systems.tweensystem'
require 'entity.world'
require 'entity.components.transform'
require 'entity.components.rendering'
require 'entity.components.collider'
require 'entity.components.motion'
require 'entity.components.behavior'
require 'entity.components.inputresponse'
require 'entity.components.soundcomponent'
require 'game.shapedata'
require 'collisionbehaviors'
require 'entitybehaviors'
require 'entitysets'

require 'enums.actions'
require 'enums.assets'
require 'enums.tags'

Ball = require 'entityinit.ball'
Bricks = require 'entityinit.bricks'
Player = require 'entityinit.player'
Walls = require 'entityinit.walls'

PlayScene = class('Play', Scene)

function PlayScene:initialize(name, w)

    Scene.initialize(self, name, w)

    local world = self.world

    -- [[ Register Inputs ]]

    local input_system = world:getSystem(InputSystem)

    input_system:registerInput('right', Actions.PLAYER_RIGHT)
    input_system:registerInput('left', Actions.PLAYER_LEFT)
    input_system:registerInput('a', Actions.PLAYER_LEFT)
    input_system:registerInput('d', Actions.PLAYER_RIGHT)
    input_system:registerInput(' ', Actions.RESET_BALL)
    input_system:registerInput('escape', Actions.ESCAPE_TO_MENU)
    input_system:registerInput('q', Actions.QUIT_GAME)

    input_system:registerInput('f', Actions.CAMERA_LEFT)
    input_system:registerInput('h', Actions.CAMERA_RIGHT)
    input_system:registerInput('t', Actions.CAMERA_UP)
    input_system:registerInput('g', Actions.CAMERA_DOWN)
    input_system:registerInput('z', Actions.CAMERA_SCALE_UP)
    input_system:registerInput('x', Actions.CAMERA_SCALE_DOWN)



    

    local em = world:getEntityManager()

    --[[ Script dealing with special input ]]

    local ir = em:createEntity('globalinputresponse')
    ir:addComponent(InputResponse():addResponse(globalInputResponse))
    world:addEntityToGroup(Tags.PLAY_GROUP, ir)


    --[[ Script constraining things to world ]]

    local world_constrainer = em:createEntity('world_constrainer')
    world_constrainer:addComponent(Behavior():addUpdateFunction(constrainActorsToWorld))
    world:addEntityToGroup(Tags.PLAY_GROUP, world_constrainer)


    --[[ Background Image ]]

    local play_background = em:createEntity('play_background')
    play_background:addComponent(Transform(0, 0):setLayerOrder(10))
    play_background:addComponent(Rendering():addRenderable(ShapeRendering():setColor(63, 63, 63, 255):setShape(RectangleShape:new(love.graphics.getWidth(), love.graphics.getHeight()))))
    world:tagEntity(Tags.BACKGROUND, play_background)
    world:addEntityToGroup(Tags.PLAY_GROUP, play_background)

    --[[ Initialize complicated entities ]]

    Walls.init(world)
    Player.init(world)
    Ball.init(world)

    local collision_system = world:getSystem(CollisionSystem)

  


end

function PlayScene:enter(song)

    love.audio.stop()

    Bricks.init(world, song)

    local collision_system = world:getSystem(CollisionSystem)

    -- TODO better way to remove collision watching 
    collision_system:reset()

    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getEntitiesInGroup(Tags.BRICK_GROUP))
    collision_system:watchCollision(world:getTaggedEntity(Tags.PLAYER), world:getEntitiesInGroup(Tags.WALL_GROUP))
    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getTaggedEntity(Tags.PLAYER))
    collision_system:watchCollision(world:getTaggedEntity(Tags.BALL), world:getEntitiesInGroup(Tags.WALL_GROUP))


    local sound_component =  world:getTaggedEntity(Tags.BACKGROUND_SOUND):getComponent(SoundComponent)
    local retrieved_sound = sound_component:getSound(Assets.BACKGROUND_SOUND)
    love.audio.play(retrieved_sound)

    local ball = world:getTaggedEntity(Tags.BALL)
    local ball_collider = ball:getComponent(Collider)
    local ball_rendering = ball:getComponent(Rendering)

    ball_collider:disable()
    ball_rendering:disable()

end

function PlayScene:update(dt)

    local world = self.world

    local play_scene_items = world:getEntitiesInGroup(Tags.PLAY_GROUP)

    --[[ Update tweens ]] 
    world:getSystem(TweenSystem):update(dt)

    --[[ Update input ]]
    world:getSystem(InputSystem):processInputResponses(Set.intersection(play_scene_items, entitiesRespondingToInput(world)), dt)
    
    --[[ Update behaviors ]]
    world:getSystem(BehaviorSystem):processBehaviors(Set.intersection(play_scene_items, entitiesWithBehavior(world)), dt) 

    --[[ Update movement ]]
    world:getSystem(MovementSystem):updateMovables(Set.intersection(play_scene_items, entitiesWithMovement(world)), dt)

    --[[ Handle collisions ]]

    local collision_system = world:getSystem(CollisionSystem)

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

    local world = self.world

    local play_scene_items = world:getEntitiesInGroup(Tags.PLAY_GROUP)

    world:getSystem(RenderingSystem):renderDrawables(Set.intersection(play_scene_items, entitiesWithDrawability(world)))

    local debugstart = 400

    if DEBUG then

        local player_transform =  world:getTaggedEntity(Tags.PLAYER):getComponent(Transform)
        local ball_transform = world:getTaggedEntity(Tags.BALL):getComponent(Transform)
        local ball_collider = world:getTaggedEntity(Tags.BALL):getComponent(Collider)

        love.graphics.print("Ball x: " .. ball_transform.position.x, 50, debugstart + 20)
        love.graphics.print("Ball y: " .. ball_transform.position.y, 50, debugstart + 40)
        love.graphics.print("Ball collider active: " .. tostring(ball_collider.active), 50, debugstart + 60)
        love.graphics.print("Player x: " .. player_transform.position.x, 50, debugstart + 80)
        love.graphics.print("Player y: " .. player_transform.position.y, 50, debugstart + 100)
    end


end