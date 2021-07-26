Ball = Class{}

function Ball:init(x, y, side)
    self.x = x
    self.y = y
    self.side = side

    self.dx = math.random(2) == 1 and 120 or -120
    self.dy = math.random(-50, 50)
end

function Ball:update(dt)
    -- ball is going to touch top or bottom side
    if self.y < 0 or self.y + self.side > VIRTUAL_HEIGHT  then
        self.dy = -self.dy
    end

    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.side, self.side)
end

--[[
    Re center the ball and change its speed
]]
function Ball:reset()
    self.x = (VIRTUAL_WIDTH - BALL_SIDE) / 2
    self.y = (VIRTUAL_HEIGHT - BALL_SIDE) / 2
    
    self.dx = math.random(2) == 1 and 120 or -120
    self.dy = math.random(-50, 50)
end

function Ball:isColliding(paddle)

    -- either ball x is outside (greater) of paddle's right side 
    --   or paddle x is outside (greater) of ball's right side
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.side then
        return false
    end

    -- either ball y is outside (greater) of paddle's bottom side
    --   or paddle y is outside (greater) of ball's bottom side
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.side then
        return false
    end

    -- they are colliding
    return true
end

function Ball:randomizeYSpeed()
    if self.dy < 0 then 
        self.dy = -math.random (10, 150)
    else
        self.dy = math.random (10, 150)
    end
end