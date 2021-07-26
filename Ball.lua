Ball = Class{}

function Ball:init(x, y, side)
    self.x = x
    self.y = y
    self.side = side

    self.dx = math.random(2) == 1 and 120 or -120
    self.dy = math.random(-50, 50)
end

function Ball:update(dt)
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