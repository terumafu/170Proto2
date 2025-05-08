local Encounter = {}

Encounter.current = nil

function Encounter:set(encounter)
    self.current = encounter
end

function Encounter:get()
    return self.current
end

function Encounter:hasHealth()
    return self.current and self.current.health and self.current.maxHealth
end

function Encounter:drawHealthBar(x, y, width, height)
    if not self:hasHealth() then return end

    local percent = self.current.health / self.current.maxHealth
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, width * percent, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
end

return Encounter
