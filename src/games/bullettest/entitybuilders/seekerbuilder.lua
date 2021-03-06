
require 'external.middleclass'
require 'entity.entitybuilder'

require 'enums.palette'
require 'enums.tags'
require 'enums.actions'


require 'entitybuilders.emissionport'
require 'particles.playerbulletparticle'

AISteering = require 'game.ai.steering'

require 'socket'

SeekerBuilder  = class('SeekerBuilder', EntityBuilder)

function SeekerBuilder:initialize(world)
    EntityBuilder.initialize(self, world, 'seeker')
    return self
end

function SeekerBuilder:create()

	EntityBuilder.create(self)

    self.entity:addComponent(Transform(397, 397))
    self.entity:addComponent(Rendering():addRenderable(ShapeRendering():setColor(Palette.COLOR_SEEKER:unpack()):setShape(RectangleShape:new(10, 10))))
    self.entity:addComponent(Motion():setDrag(50, 50):setMaxAcceleration(600, 0):setMaxVelocity(200, 0))
    self.entity:tag(Tags.SEEKER)


    local behavior = Behavior()

    local mothership = self.entity:getWorld():getTaggedEntity(Tags.MOTHERSHIP)

    local seekerAI = function()

        -- AISteering.steer(AISteering.seek, self.entity, mothership)
        -- AISteering.steer(AISteering.pursue, self.entity, mothership)
        -- AISteering.steer(AISteering.evade, self.entity, mothership)
        -- AISteering.steer(AISteering.flee, self.entity, mothership)
        -- AISteering.steer(AISteering.arrive, self.entity, mothership, 20, 100)
        -- AISteering.steer(AISteering.wander, self.entity, 100, 0.3)
        -- AISteering.steer(AISteering.keepTargetDistance, self.entity, mothership, 300, 100)
        -- AISteering.steer(AISteering.orbit, self.entity, mothership,  100, 200)
        
        AISteering.steer(AISteering.matchVelocity, self.entity, mothership)



    end

    behavior:addRoutine(seekerAI)
    behavior:addUpdateFunction(GenericBehaviors.bounceEntityOffWorldEdges)
    --behavior:addUpdateFunction(GenericBehaviors.wrapEntityAroundWorldEdges)

    self.entity:addComponent(behavior)


end




