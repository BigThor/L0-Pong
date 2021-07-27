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

-- Player constants
PLAYER1 = 1
PLAYER2 = 2

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
    resetScores()

    -- initialize gamestate
    gameState = 'start'
    servingPlayer = PLAYER1
    winningPlayer = PLAYER1

    -- initialize IA variables
    isAiPlaying = false
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
        if gameState == 'serve' and servingPlayer == PLAYER2 then
            gameState = 'play'

        -- enter replays the game in the same mode (IA or PvP)
        elseif gameState == 'done' then
            changeToServeState(winningPlayer == PLAYER1 and PLAYER2 or PLAYER1)
        end

    elseif key == 'space' then
        -- player 1 serves with spacebar
        if gameState == 'serve' and servingPlayer == PLAYER1 then
            gameState = 'play'

        -- space returns to start state
        elseif gameState == 'done' then
            gameState = 'start'
        end

    -- select game mode
    elseif key == '1' or key == '2'then
        if gameState == 'start' then
            changeToServeState(PLAYER1)

            -- if key 1 is press, AI plays
            isAiPlaying = key == '1'
        end
    end
    
end

function resetScores()
    playerScores = {
        [PLAYER1] = 0,
        [PLAYER2] = 0
    }
end

function changeToServeState(servingPyr)
    servingPlayer = servingPyr
    gameState = 'serve'
    ball:reset(servingPlayer)
    resetScores()
end

--[[
    Called after updated by LOVE2D used to draw anything
    to the scren after its updated
]]
function love.draw()
    push:start()

    -- color screen with a gray blue-ish color
    love.graphics.clear(0.1, 0.1, 0.17, 1)

    displayTitle()
    displayFPS()
    displayScore()

    -- draw players paddles
    paddleP1:render()
    paddleP2:render()

    -- draw ball
    ball:render()

    push:finish()
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

    love.graphics.print(tostring(playerScores[PLAYER1]), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(playerScores[PLAYER2]), VIRTUAL_WIDTH / 2 + 28,
        VIRTUAL_HEIGHT / 3)

end

--[[
    Display a different title depending on game state
]]
function displayTitle()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(255, 255, 255, 255)

    title = ''
    subtitle = ''
    -- change title and subtitle depending on gameState
    if gameState == 'start' then
        title = 
            'Welcome to Pong!' ..
            '\nPress 1 to play against AI' ..
            '\nPress 2 to play Player vs Player'
        subtitle = 'Score ' .. tostring(SCORE_TO_WIN) .. ' points to win the Game!'
    elseif gameState == 'serve' then
        title = 'Player '.. tostring(servingPlayer) .. ' serve!' ..
                '\nPress ' .. (servingPlayer == PLAYER2 and 'Enter' or 'Spacebar') .. 
                ' to shoot'
    elseif gameState == 'done' then
        title = 'Player ' .. tostring(winningPlayer) .. ' won!'..
                '\nPress Enter to play again'
        subtitle = 'Press Spacebar to return to Start menu'
    end

    -- display title and subtitle
    love.graphics.printf(
        title,
        0, -- X
        10, -- Y
        VIRTUAL_WIDTH, -- disponible width for display
        'center' -- alignment
    )
    love.graphics.printf(
        subtitle,
        0, -- X
        VIRTUAL_HEIGHT - 30, -- Y
        VIRTUAL_WIDTH, -- disponible width for display
        'center' -- alignment
    )
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
            onBallPaddleCollision()
            ball.x = paddleP1.x + PADDLE_WIDTH
        end
        if ball:isColliding(paddleP2) then
            onBallPaddleCollision()
            ball.x = paddleP2.x - ball.side
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
        
        -- ball scored left
        if ball.x - ball.side < 0 then
            onScore(PLAYER2)
        end
        -- ball scored right
        if ball.x > VIRTUAL_WIDTH then
            onScore(PLAYER1)
        end
        
        ball:update(dt)
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
        onAITurn(dt)
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
    Actions triggered when collision between Paddle and Ball happens
]]
function onBallPaddleCollision()
    love.audio.play(sounds.paddle_hit)
    ball.dx = -ball.dx * SPEED_INCREMENT

    -- keep velocity the same direction, but random angle
    ball:randomizeYSpeed()
end

--[[
    Actions triggered when iPlayer scores a point
]]
function onScore(iPlayer)
    love.audio.play(sounds.score)

    -- Serving player is the one who did not score
    servingPlayer = iPlayer == PLAYER1 and PLAYER2 or PLAYER1
    ball:reset(servingPlayer)
    
    playerScores[iPlayer] = playerScores[iPlayer] + 1
    -- if player Won
    if playerScores[iPlayer] == SCORE_TO_WIN then
        winningPlayer = iPlayer
        gameState = 'done'
    -- continue playing
    else
        gameState = 'serve'
    end
end

--[[
    Actions triggered when the AI is playing
    Uses dt from update as parameter
]]
function onAITurn(dt)
    if gameState == 'serve' and servingPlayer == PLAYER2 then
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
end