--[[
    Pong remake

    Made by: Big Thor (Víctor Adrián Suárez Ruiz)

    This game was made following the course by CS50
    https://www.youtube.com/watch?v=GfwpRU0cT10&ab_channel=CS50
]]

push = require "push"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--[[
    Runs when the game first starts up, only once;
    used to initialize the game
]]
function love.load()
    -- prevents pixels to become blurry
    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })


end

--[[
    Keyboard handling, called by LOVE2D each frame;
    passes in the key pressed so it can be accessed.
]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

--[[
    Called after updated by LOVE2D used to draw anything
    to the scren after its updated
]]
function love.draw()
    push:start()

    love.graphics.printf(
        'Hello Pong!',
        0, -- X
        VIRTUAL_HEIGHT / 2, -- Y
        VIRTUAL_WIDTH, -- disponible width for display
        'center' -- alignment
    )

    push:finish()
end

--[[
    Called  each frame by LOVE; dt will be the elapsed time
    in seconds since the last framem and we can use this to
    scale any changes in our game for even behavior across
    frame rates
]]
function love.update(dt)

end
