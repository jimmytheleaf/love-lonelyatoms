require 'core.components.transform'
require 'core.components.rendering'
require 'core.components.collider'
require 'core.components.motion'
require 'core.components.behavior'
require 'core.components.inputresponse'
require 'core.components.soundcomponent'

require 'enums.tags'
require 'enums.palette'


Walls = {}

function Walls.init(world)

    local em = world:getEntityManager()

     -- Tends to fall off world
    local TILE_SIZE = 10

    local top_tile = em:createEntity('top_tile')
    top_tile:addComponent(Transform(0, 0))
    top_tile:addComponent(Collider():setHitbox(RectangleShape:new(love.graphics.getWidth(), TILE_SIZE)))
    top_tile:addComponent(ShapeRendering():setColor(Palette.COLOR_BRICK:unpack()):setShape(RectangleShape:new(love.graphics.getWidth(), TILE_SIZE)))

    local bottom_tile = em:createEntity('bottom_tile')
    bottom_tile:addComponent(Transform(0, love.graphics.getHeight() - TILE_SIZE))
    bottom_tile:addComponent(Collider():setHitbox(RectangleShape:new(love.graphics.getWidth(), TILE_SIZE)))
    bottom_tile:addComponent(ShapeRendering():setColor(Palette.COLOR_BRICK:unpack()):setShape(RectangleShape:new(love.graphics.getWidth(), TILE_SIZE)))

    local left_tile = em:createEntity('left_tile')
    left_tile:addComponent(Transform(0, TILE_SIZE))
    left_tile:addComponent(Collider():setHitbox(RectangleShape:new(TILE_SIZE, love.graphics.getHeight() - 2 * TILE_SIZE)))
    left_tile:addComponent(ShapeRendering():setColor(Palette.COLOR_BRICK:unpack()):setShape(RectangleShape:new(TILE_SIZE, love.graphics.getHeight() - 2 * TILE_SIZE)))


    local right_tile = em:createEntity('right_tile')
    right_tile:addComponent(Transform(love.graphics.getWidth() - TILE_SIZE, TILE_SIZE))
    right_tile:addComponent(Collider():setHitbox(RectangleShape:new(TILE_SIZE, love.graphics.getHeight() - 2 * TILE_SIZE)))
    right_tile:addComponent(ShapeRendering():setColor(Palette.COLOR_BRICK:unpack()):setShape(RectangleShape:new(TILE_SIZE, love.graphics.getHeight() - 2 * TILE_SIZE)))

    world:addEntityToGroup(Tags.WALL_GROUP, top_tile)
    world:addEntityToGroup(Tags.WALL_GROUP, bottom_tile)
    world:addEntityToGroup(Tags.WALL_GROUP, left_tile)
    world:addEntityToGroup(Tags.WALL_GROUP, right_tile)

    world:tagEntity(Tags.TOP_WALL, top_tile)
    world:tagEntity(Tags.BOTTOM_WALL, bottom_tile)
    world:tagEntity(Tags.LEFT_WALL, left_tile)
    world:tagEntity(Tags.RIGHT_WALL, right_tile)


end 

return Walls