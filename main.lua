-- project-clicker - An eco-themed clicker game
-- Main entry point for Love2D

local game = require("src.game")
local utils = require("src.utils")  -- Added missing import
local input = require("src.input")  -- Added missing import
local camera = require("src.camera")  -- Added missing import
local ui = require("src.ui")  -- Added missing import
local tutorial = require("src.tutorial")  -- Added missing import

function love.load()
    game.load()
end

function love.update(dt)
    game.update(dt)
end

function love.draw()
    game.draw()
end

function love.mousepressed(x, y, button)
    game.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    game.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
    game.wheelmoved(x, y)
end

function love.keypressed(key)
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Process the key in input module
        input.keypressed(key, camera, game, ui, tutorial)
        
        -- Check for quit
        if key == "escape" then
            -- Only quit if no panels are open
            if not ui.anyPanelVisible() then
                love.event.quit()
            end
        end
    end)
end