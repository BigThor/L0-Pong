Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:update(dt)
    -- paddle is going up
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    --paddle is going down
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.setColor(255, 255, 255, 255)
    -- style, x-offset, y-offset, width, height
    love.graphics.rectangle('fill', self.x, self.y, 
        self.width, self.height)
end
