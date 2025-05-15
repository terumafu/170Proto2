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
    
    love.graphics.print("Upgrades", x, y + 300) 
    love.graphics.print("50 gold each", x, y + 320)
    showAvailableUpgrade(Inventory.slots.leftArm, "Shift + 1. " ,  x, y + 360)
    showAvailableUpgrade(Inventory.slots.rightArm, "Shift + 2. " ,x, y + 380)
    showAvailableUpgrade(Inventory.slots.head,"Shift + 3. ", x, y + 400)
    showAvailableUpgrade(Inventory.slots.legs,"Shift + 4. ", x, y + 420)
    love.graphics.print("Shift + 5. Total Health + 10", x, y + 440)
    love.graphics.print("Press B to go back", x, y + 480)
end

function showAvailableUpgrade(bodypart, position, x, y)
  if bodypart then
    love.graphics.print(position .. bodypart.name, x, y)
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

function Shop:upgrade(index)
  if index >= 1 and index <= 4 then -- upgrading a body part 
    local indexOfBodyParts = {Inventory.slots.leftArm, 
                              Inventory.slots.rightArm, 
                              Inventory.slots.head, 
                              Inventory.slots.legs,
                             }
    local skillToUpgrade = indexOfBodyParts[index]                         
    if skillToUpgrade and player.gold >= 50 then
      if skillToUpgrade.damage then 
        skillToUpgrade.damage = skillToUpgrade.damage + 10
      elseif skillToUpgrade.heal then
        skillToUpgrade.heal = skillToUpgrade.heal + 10
      end
      player.gold = player.gold - 50
      
    end
  end
  
  if index == 5 and player.gold >= 50 then
    player.health = player.health + 10
    player.maxHealth = player.maxHealth + 10
    player.gold = player.gold - 50
  end
    
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