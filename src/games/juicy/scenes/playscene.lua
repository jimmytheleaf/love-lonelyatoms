require 'external.middleclass'
require 'core.scene'
require 'collections.set'
require 'core.oldentity.group'
require 'core.systems.renderingsystem'
require 'core.systems.collisionsystem'
require 'core.systems.movementsystem'
require 'core.systems.behaviorsystem'
require 'core.systems.camerasystem'
require 'core.systems.inputsystem'
require 'core.systems.tweensystem'
require 'core.entity.world'
require 'core.components.transform'
require 'core.components.rendering'
require 'core.components.collider'
require 'core.components.motion'
require 'core.components.behavior'
require 'core.components.inputresponse'
require 'core.components.soundcomponent'
require 'core.shapedata'
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



    --[[ Initialize complicated entities ]]

    Walls.init(world)
    Player.init(world)
    Bricks.init(world)
    Ball.init(world)



    local em = world:getEntityManager()

    --[[ Script dealing with special input ]]

    local ir = em:createEntity('globalinputresponse')
    ir:addComponent(InputResponse():addResponse(globalInputResponse))


    --[[ Script constraining things to world ]]

    local world_constrainer = em:createEntity('world_constrainer')
    world_constrainer:addComponent(Behavior():addUpdateFunction(constrainActorsToWorld))
     

    --[[ Background Image ]]

    local background_image = em:createEntity('background_image')
    background_image:addComponent(Transform(0, 0):setLayerOrder(10))
    background_image:addComponent(ShapeRendering():setColor(63, 63, 63, 255):setShape(RectangleShape:new(love.graphics.getWidth(), love.graphics.getHeight())))
    world:tagEntity(Tags.BACKGROUND, background_image)


    --[[ Initialize and play Background Sound ]]
    local asset_manager = world:getAssetManager()

    local bsnd = "background.mp3"
    
    local this_sound = asset_manager:loadSound(Assets.BACKGROUND_SOUND, bsnd)
    this_sound:setVolume(0.25)
    this_sound:setLooping(true)

    local background_sound_entity = em:createEntity('background_sound')
    background_sound_entity:addComponent(SoundComponent():addSound(Assets.BACKGROUND_SOUND, this_sound))


    local sound_component = background_sound_entity:getComponent(SoundComponent)
    local retrieved_sound = sound_component:getSound(Assets.BACKGROUND_SOUND)
    love.audio.play(retrieved_sound)


end



function PlayScene:update(dt)

    local world = self.world

    --[[ Update tweens ]] 
    world:getSystem(TweenSystem):update(dt)

    --[[ Update input ]]
    world:getSystem(InputSystem):processInputResponses(entitiesRespondingToInput(world), dt)
    
    --[[ Update behaviors ]]
    world:getSystem(BehaviorSystem):processBehaviors(entitiesWithBehavior(world), dt) 

    --[[ Update movement ]]
    world:getSystem(MovementSystem):updateMovables(entitiesWithMovement(world), dt)

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

    world:getSystem(RenderingSystem):renderDrawables(entitiesWithDrawability(world))

    local debugstart = 400

    if DEBUG then

        local player_transform =  world:getTaggedEntity(Tags.PLAYER):getComponent(Transform)
        local ball_transform = world:getTaggedEntity(Tags.BALL):getComponent(Transform)

        love.graphics.print("Ball x: " .. ball_transform.position.x, 50, debugstart + 20)
        love.graphics.print("Ball y: " .. ball_transform.position.y, 50, debugstart + 40)
        love.graphics.print("Player x: " .. player_transform.position.x, 50, debugstart + 60)
        love.graphics.print("Player y: " .. player_transform.position.y, 50, debugstart + 80)
    end


end