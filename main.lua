local Inventory = require("inventory")
local Shop = require("shop")
local Encounter = require("encounter")

local message = ""
local messageTimer = 0
local MESSAGE_DURATION = 3 -- seconds

local player = {
    name = "Player",
    health = 100,
    maxHealth = 100,
    gold = 50,
}

local enemy = nil
local turn = "player" -- "player" or "enemy"
local gameState = "menu" -- "menu", "shop", or "encounter"

function love.load()
    local screenWidth, screenHeight = love.window.getDesktopDimensions()
    love.window.setMode(screenWidth, screenHeight) --{
        --borderless = true,
        --resizable = false
    --})

    love.graphics.setFont(love.graphics.newFont(14))
    Inventory:initialize()
    Shop:initialize(player)
    Inventory:equip("head", { name = "Stanky Breath", type = "head", damage = 5 }) -- needed an item to start in case player goes straight to fighting
end

function spawnEnemy()
    local enemies = {
        { name = "Wild Rat", health = 50, maxHealth = 50, damage = 5 },
        { name = "Fire Lizard", health = 80, maxHealth = 80, damage = 10 },
        { name = "Water Turtle", health = 100, maxHealth = 100, damage = 5 },
    }
    enemy = enemies[love.math.random(#enemies)]
    message = "A wild " .. enemy.name .. " appeared!"
    messageTimer = MESSAGE_DURATION
end

function love.draw()
    if gameState == "menu" then
        drawMainMenu()
    elseif gameState == "shop" then
        Shop:draw()
        drawBackButton()
    elseif gameState == "encounter" then
        drawEncounter()
    end
end

function drawMainMenu()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    love.graphics.printf("Main Menu", 0, screenHeight / 4, screenWidth, "center")
    love.graphics.printf("Press 1 to go to the Shop", 0, screenHeight / 2 - 20, screenWidth, "center")
    love.graphics.printf("Press 2 to start an Encounter", 0, screenHeight / 2 + 20, screenWidth, "center")
    love.graphics.printf("Press ESC to exit", 0, screenHeight / 2 + 60, screenWidth, "center")
end

function drawEncounter()
    -- Draw player and enemy health bars
    drawHealthBar(20, 50, 200, 20, player.health, player.maxHealth, "Player HP")
    drawHealthBar(love.graphics.getWidth() - 220, 50, 200, 20, enemy.health, enemy.maxHealth, enemy.name .. " HP")

    -- Draw inventory
    Inventory:draw()

    -- Draw message
    if message ~= "" then
        local screenWidth = love.graphics.getWidth()
        love.graphics.printf(message, 0, love.graphics.getHeight() / 2 - 20, screenWidth, "center")
    end
end

function drawBackButton()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    love.graphics.printf("Press B to return to the Main Menu", 0, screenHeight - 50, screenWidth, "center")
end

function drawHealthBar(x, y, width, height, current, max, label)
    local percent = current / max
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0, 0.8, 0)
    love.graphics.rectangle("fill", x, y, width * percent, height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.print(label, x, y - 20)
end

function love.update(dt)
    if messageTimer > 0 then
        messageTimer = messageTimer - dt
        if messageTimer <= 0 then
            message = ""
        end
    end

    if gameState == "encounter" and turn == "enemy" and enemy.health > 0 then
        enemyAttack()
        turn = "player"
    end
end

function enemyAttack()
    local damage = enemy.damage
    player.health = math.max(player.health - damage, 0)
    message = enemy.name .. " attacked for " .. damage .. " damage!"
    messageTimer = MESSAGE_DURATION

    if player.health <= 0 then
        message = "You were defeated!"
        gameState = "menu"
        player.health = player.maxHealth
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "1" then
            gameState = "shop"
        elseif key == "2" then
            gameState = "encounter"
            spawnEnemy()
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gameState == "shop" then
        if key == "b" then
            gameState = "menu"
        elseif tonumber(key) then
            local index = tonumber(key)
            if love.keyboard.isDown("lshift") then
              Shop:upgrade(index)
            else 
              Shop:buy(index)
            end
        end
    elseif gameState == "encounter" then
        if turn ~= "player" or player.health <= 0 or enemy.health <= 0 then
            return
        end

        local index = tonumber(key)
        if index and index >= 1 and index <= 4 then
            local ability = Inventory:getAbility(index)
            if ability then
                if ability.damage then
                    enemy.health = math.max(enemy.health - ability.damage, 0)
                    message = "You used " .. ability.name .. " for " .. ability.damage .. " damage!"
                elseif ability.heal then
                    player.health = math.min(player.health + ability.heal, player.maxHealth)
                    message = "You used " .. ability.name .. " and healed for " .. ability.heal .. " HP!"
                end

                if enemy.health <= 0 then
                    message = message .. " " .. enemy.name .. " was defeated!"
                    player.gold = player.gold + 20
                    gameState = "menu"
                    player.health = player.maxHealth
                end

                turn = "enemy"
                messageTimer = MESSAGE_DURATION
            else
                message = "No ability equipped in slot " .. index .. "!"
                messageTimer = MESSAGE_DURATION
            end
        end
    end
end

function love.mousepressed(x, y, button)
    if gameState == "shop" or gameState == "encounter" then
        Inventory:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if gameState == "shop" or gameState == "encounter" then
        Inventory:mousereleased(x, y, button)
    end
end



