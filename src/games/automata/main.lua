require 'core.systems.inputsystem'
require 'core.systems.schedulesystem'

require 'external.middleclass'

require 'utils.counters'

require 'spatial.screenmap'
require 'collections.matrix'

require 'automata.cellularautomata'

Actions = {}


DEBUG = true

frame = 1
memsize = 0

function love.load()


    input_system = InputSystem()
    input_system:registerInput(' ', "reset")

    schedule_system = ScheduleSystem()

    local xtiles = 20
    local ytiles = 20

    screen_map = ScreenMap(love.graphics.getWidth(), love.graphics.getHeight(), xtiles, ytiles)

    mouse_x = 0
    mouse_y = 0

    time_interval = 0.5

    schedule_system:doEvery(time_interval, processAutomata)

    cellular_grid = CellularGrid(xtiles, ytiles)

end

function processAutomata()
    cellular_grid:updateFrame()
end


-- Perform computations, etc. between screen refreshes.
function love.update(dt)

    input_system:update(dt)
    
    mouse_x, mouse_y = love.mouse.getPosition()
    tile_hover = screen_map:getCoordinates(mouse_x, mouse_y)

    if input_system:newAction("reset") then
        cellular_grid:reset()
    end

    schedule_system:update(dt)


end




function love.mousepressed(x, y, button)
    mouse_x, mouse_y = love.mouse.getPosition()
    tile_hover = screen_map:getCoordinates(mouse_x, mouse_y)
    local x, y = tile_hover:unpack()
    local current = cellular_grid:getCell(x, y)
    current:invertState()
end



-- Update the screen.

function love.draw()


    love.graphics.setBackgroundColor(63, 63, 63, 255)

    drawCellularAutomata(screen_map)


    if DEBUG then
       local debugstart = 50
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 50, debugstart + 20)

        frame = frame + 1

        if frame % 10 == 0 then
            memsize = collectgarbage('count')
        end

        love.graphics.print('Memory actually used (in kB): ' .. memsize, 10, debugstart + 320)
    end

end


function drawCellularAutomata(screen_map)

    local r = 200
    local b = 40

    for x = 0, screen_map.xtiles - 1 do 

        r = r - 10
        b = b + 10
        local g = 50

        for y = 0, screen_map.ytiles - 1 do

            g = g + 10

            local current = cellular_grid:getCell(x + 1, y + 1)

            local mode = "line"
            
            if current:isOn() then 
                love.graphics.setColor(r,g,b, 255)
                mode = "fill"
            else
                love.graphics.setColor(200,200,200, 255)
            end

            love.graphics.rectangle(mode, x * screen_map.tile_width, y * screen_map.tile_height, screen_map.tile_width, screen_map.tile_height)
           
        end
    end


end

