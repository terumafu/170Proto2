local Inventory = {}

Inventory.slots = {
    leftArm = nil,
    rightArm = nil,
    head = nil,
    legs = nil,
    bag = { nil, nil, nil, nil }
}

local draggingItem = nil
local draggingSource = nil

function Inventory:initialize()
    -- Initialize inventory slots
    self.slots.leftArm = nil
    self.slots.rightArm = nil
    self.slots.head = nil
    self.slots.legs = nil
    for i = 1, 4 do
        self.slots.bag[i] = nil
    end
end

function Inventory:addToBag(item)
    for i = 1, 4 do
        if not self.slots.bag[i] then
            self.slots.bag[i] = item
            return true
        end
    end
    return false
end

function Inventory:equip(slot, item)
    if slot == "leftArm" or slot == "rightArm" then
        if item.type == "arm" then
            self.slots[slot] = item
            return true
        end
    elseif slot == "head" then
        if item.type == "head" then
            self.slots[slot] = item
            return true
        end
    elseif slot == "legs" then
        if item.type == "legs" then
            self.slots[slot] = item
            return true
        end
    end
    return false
end

function Inventory:unequip(slot)
    local item = self.slots[slot]
    if item and self:addToBag(item) then
        self.slots[slot] = nil
        return true
    end
    return false
end

function Inventory:getAbility(index)
    if index == 1 then return self.slots.leftArm end
    if index == 2 then return self.slots.rightArm end
    if index == 3 then return self.slots.head end
    if index == 4 then return self.slots.legs end
    return nil
end

function Inventory:draw()
    local screenWidth = love.graphics.getWidth()
    local baseY = love.graphics.getHeight() - 200
    local spacing = 100

    -- Draw equipped slots
    local slots = { "leftArm", "rightArm", "head", "legs" }
    for i, slot in ipairs(slots) do
        local x = 20 + (i - 1) * spacing
        local item = self.slots[slot]
        local name = item and ("#" .. i .. " " .. item.name .. " (" .. item.type .. ")") or "Empty"
        love.graphics.printf(slot .. ": " .. name, x, baseY, 100, "left")

        -- Highlight slot if dragging an item
        if draggingItem and self:isValidSlot(slot, draggingItem) then
            love.graphics.setColor(0, 1, 0, 0.5)
            love.graphics.rectangle("fill", x, baseY, 100, 20)
            love.graphics.setColor(1, 1, 1)
        end
    end

    -- Draw bag slots
    for i = 1, 4 do
        local x = 20 + (i - 1) * spacing
        local item = self.slots.bag[i]
        local name = item and (item.name .. " (" .. item.type .. ")") or "Empty"
        love.graphics.printf("Bag slot " .. i .. ": " .. name, x, baseY + 50, 100, "left")

        -- Highlight slot if dragging an item
        if draggingItem and draggingSource ~= "bag" then
            love.graphics.setColor(0, 1, 0, 0.5)
            love.graphics.rectangle("fill", x, baseY + 50, 100, 20)
            love.graphics.setColor(1, 1, 1)
        end
    end

    -- Draw the dragged item
    if draggingItem then
        local mx, my = love.mouse.getPosition()
        love.graphics.printf(draggingItem.name .. " (" .. draggingItem.type .. ")", mx, my, 100, "left")
    end
end

function Inventory:isValidSlot(slot, item)
    if slot == "leftArm" or slot == "rightArm" then
        return item.type == "arm"
    elseif slot == "head" then
        return item.type == "head"
    elseif slot == "legs" then
        return item.type == "legs"
    elseif slot == "bag" then
        return true -- Items can always go into the bag
    end
    return false
end

function Inventory:mousepressed(x, y, button)
    if button == 1 then -- Left mouse button
        local baseY = love.graphics.getHeight() - 200
        local spacing = 100

        -- Check if clicking on equipped slots
        local slots = { "leftArm", "rightArm", "head", "legs" }
        for i, slot in ipairs(slots) do
            local slotX = 20 + (i - 1) * spacing
            if x >= slotX and x <= slotX + 100 and y >= baseY and y <= baseY + 20 then
                if self.slots[slot] then
                    draggingItem = self.slots[slot]
                    draggingSource = slot
                    self.slots[slot] = nil
                end
                return
            end
        end

        -- Check if clicking on bag slots
        for i = 1, 4 do
            local slotX = 20 + (i - 1) * spacing
            if x >= slotX and x <= slotX + 100 and y >= baseY + 50 and y <= baseY + 70 then
                if self.slots.bag[i] then
                    draggingItem = self.slots.bag[i]
                    draggingSource = "bag" .. i
                    self.slots.bag[i] = nil
                end
                return
            end
        end
    end
end

function Inventory:mousereleased(x, y, button)
    if button == 1 and draggingItem then -- Left mouse button
        local baseY = love.graphics.getHeight() - 200
        local spacing = 100

        -- Check if dropping on equipped slots
        local slots = { "leftArm", "rightArm", "head", "legs" }
        for i, slot in ipairs(slots) do
            local slotX = 20 + (i - 1) * spacing
            if x >= slotX and x <= slotX + 100 and y >= baseY and y <= baseY + 20 then
                if self:isValidSlot(slot, draggingItem) then
                    self.slots[slot] = draggingItem
                    draggingItem = nil
                    draggingSource = nil
                    return
                end
            end
        end

        -- Check if dropping on bag slots
        for i = 1, 4 do
            local slotX = 20 + (i - 1) * spacing
            if x >= slotX and x <= slotX + 100 and y >= baseY + 50 and y <= baseY + 70 then
                if not self.slots.bag[i] then
                    self.slots.bag[i] = draggingItem
                    draggingItem = nil
                    draggingSource = nil
                    return
                end
            end
        end

        -- If no valid drop location, return the item to its original slot
        if draggingSource then
            if draggingSource:sub(1, 3) == "bag" then
                local index = tonumber(draggingSource:sub(4))
                self.slots.bag[index] = draggingItem
            else
                self.slots[draggingSource] = draggingItem
            end
        end

        draggingItem = nil
        draggingSource = nil
    end
end

function Inventory:handleSell(key)
    local index = tonumber(key)
    if index and index >= 1 and index <= 4 then
        Shop:sell(index)
    end
end

return Inventory
