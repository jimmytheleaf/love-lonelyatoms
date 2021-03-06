require 'external.middleclass'
require 'entity.systems.renderingsystem'
require 'entity.systems.collisionsystem'
require 'entity.systems.movementsystem'
require 'entity.systems.behaviorsystem'
require 'entity.systems.camerasystem'
require 'entity.systems.inputsystem'
require 'entity.systems.tweensystem'
require 'entity.systems.menuguisystem'
require 'entity.world'
require 'scenes.playscene'
require 'scenes.menuscene'
require 'enums.scenes'
require 'external.slam'

DEBUG = false

function love.load()
 
    world = World()

    -- Load Fonts and Globally Used Assets
    loadAssets(world)
    loadSystems(world)
    loadScenes(world)

end

function loadAssets(world)

    local ps2p = "PressStart2P.ttf"
    
    local asset_manager = world:getAssetManager()
    asset_manager:loadFont(Assets.FONT_LARGE, ps2p, 30)
    asset_manager:loadFont(Assets.FONT_MEDIUM, ps2p, 18)
    asset_manager:loadFont(Assets.FONT_SMALL, ps2p, 14)

end


function loadSystems(world)

    local rendering_system = RenderingSystem()
    local camera_system = CameraSystem()
    rendering_system:setCamera(camera_system)
    world:setSystem(rendering_system)
    world:setSystem(camera_system)


    local collision_system = CollisionSystem(world)
    world:setSystem(collision_system)

    local movement_system = MovementSystem()
    world:setSystem(movement_system)

    local behavior_system = BehaviorSystem()
    world:setSystem(behavior_system)

    local input_system = InputSystem()
    world:setSystem(input_system)

    local tween_system = TweenSystem()
    world:setSystem(tween_system)

    local menu_system = MenuGuiSystem(world)
    world:setSystem(menu_system)


end


function loadScenes(world)

    local scene_manager = world:getSceneManager()

    local play_scene = PlayScene(Scenes.PLAY, world)
    scene_manager:registerScene(play_scene)

    local menu_scene = MenuScene(Scenes.MENU, world)
    scene_manager:registerScene(menu_scene)

    scene_manager:changeScene(Scenes.MENU)
    


end

-- Perform computations, etc. between screen refreshes.
function love.update(dt)

   world:getSceneManager():update(dt)

end

-- Update the screen.

function love.draw()

   world:getSceneManager():draw(dt)

end
