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

-- Paddle constants
PADDLE_WIDTH = 5
PADDLE_HEIGHT = 20
PADDLE_SPEED = 200

-- Ball constants
BALL_SIDE = 4

--[[
    Runs when the game first starts up, only once;
    used to initialize the game
]]
function love.load()
    -- prevents pixels to become blurry
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- fonts
    smallFont = love.graphics.newFont('retro_gaming.ttf', 8);
    mediumFont = love.graphics.newFont('retro_gaming.ttf', 16);
    bigFont = love.graphics.newFont('retro_gaming.ttf', 24);

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- initialize score variables
    player1Score = 0
    player2Score = 0

    -- paddle positions on the Y axis (movable one)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - PADDLE_HEIGHT - 30

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

    love.graphics.setFont(smallFont)
    love.graphics.printf(
        'Hello Pong!',
        0, -- X
        10, -- Y
        VIRTUAL_WIDTH, -- disponible width for display
        'center' -- alignment
    )

    love.graphics.setFont(bigFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 25,
        VIRTUAL_HEIGHT / 3)

    -- style, x-offset, y-offset, width, height
    -- First paddle (left side)
    love.graphics.rectangle('fill', 10, player1Y, PADDLE_WIDTH, PADDLE_HEIGHT)
    
    -- Second paddle (right side)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 
        PADDLE_WIDTH, PADDLE_HEIGHT)

    -- Ball (center)
    love.graphics.rectangle('fill', (VIRTUAL_WIDTH - BALL_SIDE)/2, 
        (VIRTUAL_HEIGHT - BALL_SIDE)/2, BALL_SIDE, BALL_SIDE)

    push:finish()
end

--[[
    Called  each frame by LOVE; dt will be the elapsed time
    in seconds since the last framem and we can use this to
    scale any changes in our game for even behavior across
    frame rates
]]
function love.update(dt)
    
    -- use min and max to limit movement outside the screen
    if love.keyboard.isDown('w') then
        player1Y = math.max(0, player1Y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('s') then
        player1Y = math.min(VIRTUAL_HEIGHT-PADDLE_HEIGHT , player1Y + PADDLE_SPEED * dt)
    end
    
    if love.keyboard.isDown('up') then
        player2Y = math.max(0, player2Y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown('down') then
        player2Y = math.min(VIRTUAL_HEIGHT-PADDLE_HEIGHT , player2Y + PADDLE_SPEED * dt)
    end
end
