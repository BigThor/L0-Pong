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
SPEED_INCREMENT = 1.1

SCORE_TO_WIN = 5

-- AI related constants
AI_FOLLOW_BALL_RADIO = PADDLE_HEIGHT / 4
AI_SERVE_TIME = 1
AI_REACTION_TIME = 0.09

--[[
    Runs when the game first starts up, only once;
    used to initialize the game
]]
function love.load()
    -- set game title
    love.window.setTitle('Big Pong')

    -- prevents pixels to become blurry
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- initialize RNG
    math.randomseed(os.time())

    -- fonts
    smallFont = love.graphics.newFont('retro_gaming.ttf', 11);
    mediumFont = love.graphics.newFont('retro_gaming.ttf', 16);
    bigFont = love.graphics.newFont('retro_gaming.ttf', 24);

    -- set up sound effect
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
    
    -- initialize ball
    ball = Ball((VIRTUAL_WIDTH - BALL_SIDE) / 2, (VIRTUAL_HEIGHT - BALL_SIDE) / 2,
        BALL_SIDE, BALL_SIDE)

    -- intialize paddles
    paddleP1 = Paddle(10, 30, PADDLE_WIDTH, PADDLE_HEIGHT)
    paddleP2 = Paddle(VIRTUAL_WIDTH - PADDLE_WIDTH - 10, 
        VIRTUAL_HEIGHT - PADDLE_HEIGHT - 30, PADDLE_WIDTH, PADDLE_HEIGHT)

    -- initialize score variables
    player1Score = 0
    player2Score = 0
    servingPlayer = 1
    winningPlayer = 1

    -- initialize gamestate and IA boolean
    isAiPlaying = false
    gameState = 'start'

    aiServeTimer = AI_SERVE_TIME
    aiReactionTimer = AI_REACTION_TIME
end

--[[
    Keyboard handling, called by LOVE2D each frame;
    passes in the key pressed so it can be accessed.
]]
function love.keypressed(key)
    -- exit game
    if key == 'escape' then
        love.event.quit()
    elseif key == 'return' then
        -- player 2 serves with enter
        if gameState == 'serve' and servingPlayer == 2 then
            gameState = 'play'
        -- enter replays the game in the same mode (IA or PvP)
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset(servingPlayer)
            servingPlayer = winningPlayer == 1 and 2 or 1
            player1Score = 0
            player2Score = 0
        end
    elseif key == 'space' then
        -- player 1 serves with spacebar
        if gameState == 'serve' and servingPlayer == 1 then
            gameState = 'play'
        -- space returns to start state
        elseif gameState == 'done' then
            gameState = 'start'
            servingPlayer = 1
            ball:reset(servingPlayer)
            player1Score = 0
            player2Score = 0
        end
    elseif key == '1' or key == '2'then
        if gameState == 'start' then
            ball:reset(servingPlayer)
            gameState = 'serve'
            isAiPlaying = key == '1'
        end
    end
    
end

--[[
    Called after updated by LOVE2D used to draw anything
    to the scren after its updated
]]
function love.draw()
    push:start()
    love.graphics.clear(0.1, 0.1, 0.17, 1)

    displayTitle()
    displayFPS()
    displayScore()

    -- set white color for paddles and ball
    love.graphics.setColor(255, 255, 255, 255)
    -- draw players paddles
    paddleP1:render()
    paddleP2:render()
    -- draw ball
    ball:render()

    push:finish()
end

--[[
    Called by LOVE whenever we resize the screen
]]
function love.resize(w, h)
    push:resize(w, h)
end


--[[
    Called  each frame by LOVE; dt will be the elapsed time
    in seconds since the last framem and we can use this to
    scale any changes in our game for even behavior across
    frame rates
]]
function love.update(dt)
    -- move the ball only when gamestate is play
    if gameState == 'play' then

        if ball:isColliding(paddleP1) then
            love.audio.play(sounds.paddle_hit)

            ball.dx = -ball.dx * SPEED_INCREMENT
            ball.x = paddleP1.x + PADDLE_WIDTH

            -- keep velocity the same direction, but random angle
            ball:randomizeYSpeed()
        end
        
        if ball:isColliding(paddleP2) then
            love.audio.play(sounds.paddle_hit)

            ball.dx = -ball.dx * SPEED_INCREMENT
            ball.x = paddleP2.x - ball.side

            -- keep velocity the same direction, but random angle
            ball:randomizeYSpeed()
        end

        -- ball is going to touch top or bottom side
        if ball.y < 0 or ball.y + ball.side > VIRTUAL_HEIGHT then
            love.audio.play(sounds.wall_hit)
            ball.dy = -ball.dy

            -- top
            if ball.y < 0 then  
                ball.y = 1
            -- bottom
            elseif ball.y + ball.side > VIRTUAL_HEIGHT  then
                ball.y = VIRTUAL_HEIGHT - ball.side - 1
            end
        end
        
        ball:update(dt)
    end

    -- ball scored left
    if ball.x - ball.side < 0 then
        love.audio.play(sounds.score)

        servingPlayer = 1
        player2Score = player2Score + 1

        if player2Score == SCORE_TO_WIN then
            winningPlayer = 2
            gameState = 'done'
        else
            gameState = 'serve'
        end
        ball:reset(servingPlayer)

    end
    -- ball scored right
    if ball.x > VIRTUAL_WIDTH then
        love.audio.play(sounds.score)

        servingPlayer = 2
        player1Score = player1Score + 1
        
        if player1Score == SCORE_TO_WIN then
            winningPlayer = 1
            gameState = 'done'
        else
            gameState = 'serve'
        end
        ball:reset(servingPlayer)
    end

    -- Player 1 controls
    if love.keyboard.isDown('w') then
        paddleP1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        paddleP1.dy = PADDLE_SPEED
    else
        paddleP1.dy = 0
    end

    -- Player 2 controls
    --  disabled when against AI
    if isAiPlaying then
        if gameState == 'serve' and servingPlayer == 2 then
            if aiServeTimer < 0 then
                gameState = 'play'
                aiServeTimer = 1
            else
                aiServeTimer = aiServeTimer - dt
            end
        end
        -- AI actions
        paddleYCenter = paddleP2.y + paddleP2.height / 2

        -- Add reaction time to AI to ease the game
        if aiReactionTimer < 0 then
            -- AI tries to center paddle to ball
            if paddleYCenter > ball.y and 
            (paddleYCenter - ball.y) > AI_FOLLOW_BALL_RADIO then
                paddleP2.dy = -PADDLE_SPEED
            elseif ball.y > paddleYCenter  and 
            (ball.y - paddleYCenter) > AI_FOLLOW_BALL_RADIO then
                paddleP2.dy = PADDLE_SPEED
            else
                paddleP2.dy = 0
                aiReactionTimer = AI_REACTION_TIME
            end
        else
            aiReactionTimer = aiReactionTimer - dt
        end
    else
        if love.keyboard.isDown('up') then
            paddleP2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddleP2.dy = PADDLE_SPEED
        else
            paddleP2.dy = 0
        end
    end

    -- update paddles
    paddleP1:update(dt)
    paddleP2:update(dt)
end

--[[
    Render FPS, because everyone wants to know them 
]]
function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

--[[
    Display score of both players
]]
function displayScore()
    love.graphics.setFont(bigFont)
    love.graphics.setColor(255, 255, 255, 255)

    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)

end

--[[
    Display a different title depending on game state
]]
function displayTitle()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(255, 255, 255, 255)

    -- display title
    if gameState == 'start' then
        love.graphics.printf(
            'Welcome to Pong!' ..
            '\nPress 1 to play against AI' ..
            '\nPress 2 to play Player vs Player',
            0, -- X
            10, -- Y
            VIRTUAL_WIDTH, -- disponible width for display
            'center' -- alignment
        )
        love.graphics.printf(
            'Score ' .. tostring(SCORE_TO_WIN) .. ' points to win the Game!',
            0, -- X
            VIRTUAL_HEIGHT - 30, -- Y
            VIRTUAL_WIDTH, -- disponible width for display
            'center' -- alignment
        )
    elseif gameState == 'serve' then
        love.graphics.printf(
            'Player '.. tostring(servingPlayer) .. ' serve!' ..
            '\nPress ' .. (servingPlayer == 2 and 'Enter' or 'Spacebar') .. ' to shoot',
            0, -- X
            10, -- Y
            VIRTUAL_WIDTH, -- disponible width for display
            'center' -- alignment
        )
    elseif gameState == 'done' then
        if winningPlayer ~= nil then
            love.graphics.printf(
                'Player ' .. tostring(winningPlayer) .. ' won!'..
                '\nPress Enter to play again' ..
                '\nPress Spacebar to return to Start menu',
                0, -- X
                10, -- Y
                VIRTUAL_WIDTH, -- disponible width for display
                'center' -- alignment
            )
        end
    end
end