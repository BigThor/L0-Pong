--[[
    Pong remake

    Made by: Big Thor (Víctor Adrián Suárez Ruiz)

    This game was made following the course by CS50
    https://www.youtube.com/watch?v=GfwpRU0cT10&ab_channel=CS50
]]

push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

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

    -- initialize RNG
    math.randomseed(os.time())

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

    -- initialize ball
    ball = Ball((VIRTUAL_WIDTH - BALL_SIDE) / 2, (VIRTUAL_HEIGHT - BALL_SIDE) / 2,
        BALL_SIDE, BALL_SIDE)

    -- intialize paddles
    paddleP1 = Paddle(10, 30, PADDLE_WIDTH, PADDLE_HEIGHT)
    paddleP2 = Paddle(VIRTUAL_WIDTH - PADDLE_WIDTH - 10, 
        VIRTUAL_HEIGHT - PADDLE_HEIGHT - 30, PADDLE_WIDTH, PADDLE_HEIGHT)
end

--[[
    Keyboard handling, called by LOVE2D each frame;
    passes in the key pressed so it can be accessed.
]]
function love.keypressed(key)
    -- exit game
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        else
            gameState = 'start'
            ball:reset()
        end
    end
end

--[[
    Called after updated by LOVE2D used to draw anything
    to the scren after its updated
]]
function love.draw()
    push:start()

    -- display title
    love.graphics.setFont(smallFont)
    love.graphics.printf(
        'Hello Pong!',
        0, -- X
        10, -- Y
        VIRTUAL_WIDTH, -- disponible width for display
        'center' -- alignment
    )

    -- display score
    love.graphics.setFont(bigFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 25,
        VIRTUAL_HEIGHT / 3)

    -- draw players paddles
    paddleP1:render()
    paddleP2:render()

    -- draw ball
    ball:render()

    push:finish()
end

--[[
    Called  each frame by LOVE; dt will be the elapsed time
    in seconds since the last framem and we can use this to
    scale any changes in our game for even behavior across
    frame rates
]]
function love.update(dt)
    -- Player 1 controls
    if love.keyboard.isDown('w') then
        paddleP1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddleP1.dy = PADDLE_SPEED
    else
        paddleP1.dy = 0
    end

    -- Player 2 controls
    if love.keyboard.isDown('up') then
        paddleP2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        paddleP2.dy = PADDLE_SPEED
    else
        paddleP2.dy = 0
    end

    -- update paddles
    paddleP1:update(dt)
    paddleP2:update(dt)

    -- move the ball only when gamestate is play
    if gameState == 'play' then
        ball:update(dt)
    end
end