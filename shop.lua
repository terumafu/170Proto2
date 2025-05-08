local Shop = {}
local Inventory = require("inventory")

Shop.items = {
    { name = "Punch", type = "arm", damage = 10, cost = 10 },
    { name = "Slash", type = "arm", damage = 15, cost = 15 },
    { name = "Headbutt", type = "head", damage = 20, cost = 20 },
    { name = "Stomp", type = "legs", damage = 25, cost = 25 },
    { name = "Kick", type = "legs", damage = 15, cost = 15 },
    { name = "Fire Breath", type = "head", damage = 30, cost = 30 },
    { name = "Uppercut", type = "arm", damage = 20, cost = 20 },
    { name = "Spin Kick", type = "legs", damage = 20, cost = 20 },
    { name = "Repair", type = "arm", heal = 50, cost = 30 },
}

local player = nil

function Shop:initialize(p)
    player = p
    self.selectedItem = nil
end

function Shop:draw()
    local x = love.graphics.getWidth() - 300
    local y = 100
    love.graphics.print("Shop (Gold: " .. player.gold .. ")", x, y - 30)

    for i, item in ipairs(self.items) do
        local text = i .. ". " .. item.name .. " (" .. item.type .. ") - " .. item.cost .. "G"
        love.graphics.print(text, x, y + (i - 1) * 20)
    end
end

function Shop:buy(index)
    local item = self.items[index]
    if item and player.gold >= item.cost then
        if Inventory:addToBag(item) then
            player.gold = player.gold - item.cost
            message = "You bought " .. item.name .. "!"
        else
            message = "Your bag is full!"
        end
    else
        message = "Not enough gold!"
    end
    messageTimer = MESSAGE_DURATION
end

function Shop:sell(index)
    local item = Inventory.slots.bag[index]
    if item then
        player.gold = player.gold + math.floor(item.cost / 2) -- Sell for half the cost
        Inventory.slots.bag[index] = nil
        message = "You sold " .. item.name .. " for " .. math.floor(item.cost / 2) .. "G!"
        messageTimer = MESSAGE_DURATION
    else
        message = "No item in bag slot " .. index .. " to sell!"
        messageTimer = MESSAGE_DURATION
    end
end

return Shop