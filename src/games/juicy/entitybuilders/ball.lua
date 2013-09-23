require 'core.components.transform'
require 'core.components.rendering'
require 'core.components.collider'
require 'core.components.motion'
require 'core.components.behavior'
require 'core.components.inputresponse'
require 'core.components.soundcomponent'
require 'core.components.messaging'
require 'core.systems.messagesystem'
require 'enums.events'
require 'enums.tags'
require 'enums.palette'
require 'behaviors.genericbehaviors'

require 'core.entity.entitybuilder'

require 'external.middleclass'

BallBuilder  = class('BallInitializer', EntityBuilder)

function BallBuilder:initialize(world)
    EntityBuilder.initialize(self, world, 'ball')
    return self
end

function BallBuilder:create()

    EntityBuilder.create(self)

    self.entity:addComponent(Transform(395, 485))
    self.entity:addComponent(ShapeRendering():setColor(Palette.COLOR_BALL:unpack()):setShape(RectangleShape:new(15, 15)))
    self.entity:addComponent(Collider():setHitbox(RectangleShape:new(15, 15)))
    self.entity:addComponent(Motion():setMaxVelocity(600, 400):setMinVelocity(-600, -400):setVelocity(200, -425))
    -- self.entity:addComponent(Behavior():addUpdateFunction(ballAutoResetOnNonexistence))
    self.entity:addComponent(InputResponse():addResponse(ballInputResponse))
    self.entity:addComponent(Messaging(self.world:getSystem(MessageSystem)))

    self.entity:addToGroup(Tags.PLAY_GROUP)
    self.entity:tag(Tags.BALL)

    local ball_behavior = Behavior()
    ball_behavior:addUpdateFunction(constrainEntityToWorld)
    -- ball_behavior:addUpdateFunction(ballAutoResetOnNonexistence)
    self.entity:addComponent(ball_behavior)

end 

function BallBuilder:reset()

    local collider = self.entity:getComponent(Collider)
    local rendering = self.entity:getComponent(ShapeRendering)

    collider:disable()
    rendering:disable()

end


function ballInputResponse(ball, held_actions, pressed_actions, dt)

    if pressed_actions[Actions.RESET_BALL] then
  
        local player = ball:getWorld():getTaggedEntity(Tags.PLAYER)

        local ball_transform = ball:getComponent(Transform)
        local ball_movement = ball:getComponent(Motion)
        local ball_collider = ball:getComponent(Collider)
        local ball_rendering = ball:getComponent(ShapeRendering)

        local player = ball:getWorld():getTaggedEntity(Tags.PLAYER)

        local player_transform = player:getComponent(Transform)
        local player_render = player:getComponent(ShapeRendering)


        ball_collider:enable()
        ball_rendering:enable()
        ball_movement:setVelocity(200, -425)

        ball_transform:moveTo(player_transform:getPosition().x + player_render:getShape().width / 2, 
                            player_transform:getPosition().y - ball_collider:hitbox().height)

    end

end