function love.conf(t)
    t.title = "Bullet Testing"
    t.author = "Jim Fingal"
    t.url = nil
    t.identity = nil
    t.version = "0.8.0"
    t.console = false
    t.release = false
    t.screen.width = 900
    t.screen.height = 900
    t.screen.fullscreen = false
    t.screen.vsync = false
    t.screen.fsaa = 0
    t.modules.joystick = false
    t.modules.audio = true
    t.modules.keyboard = true
    t.modules.event = true
    t.modules.image = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.mouse = false
    t.modules.sound = true
    t.modules.physics = false
end
