-- Import modules
local camera = require("src.camera")
local game = require("src.game")
local ui = require("src.ui")
local pollution = require("src.pollution")
local config = require("src.config")
local log = require("src.log")
local utils = require("src.utils")
local audio = require("src.audio")
local tutorial = require("src.tutorial")

-- Custom error handler
function love.errorhandler(msg)
    log.critical("Uncaught error: " .. tostring(msg))
    
    -- Display a simple error message
    love.graphics.reset()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("An error occurred:\n" .. tostring(msg) .. "\n\nPlease report this to the developers.", 50, 50, love.graphics.getWidth() - 100)
    love.graphics.present()
    
    return true
end

-- Initialize game
function love.load()
    -- Set up the window
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- Dark background
    
    -- Initialize logging
    log.info("Starting project-clicker")
    
    -- Initialize configuration
    config.init()
    
    -- Initialize modules using safe calls
    utils.safeCall(function()
        game.load()
        ui.load()
        pollution.load()
        audio.load()
        tutorial.load()
        
        -- Set up camera with game world dimensions
        camera.load(game.WORLD_WIDTH, game.WORLD_HEIGHT)
        
        -- Start tutorial after a short delay
        love.timer.simple(1, function()
            tutorial.start()
        end)
    end)
end

-- Update game state
function love.update(dt)
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Update game logic
        game.update(dt)
        
        -- Update UI
        ui.update(dt)
        
        -- Update camera
        camera.update(dt)
        
        -- Update pollution
        pollution.update(dt)
    end)
end

-- Draw game
function love.draw()
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Start camera transformation
        camera.set()
        
        -- Draw game world
        game.draw()
        
        -- Draw pollution overlay
        pollution.draw()
        
        -- End camera transformation
        camera.unset()
        
        -- Draw UI (in screen space)
        ui.draw(game.resources_collected, game.pollution_level, game.research_points)
        
        -- Draw tutorial overlay last
        tutorial.draw()
    end)
end

function love.mousepressed(x, y, button)
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Check if tutorial handled the click first
        if tutorial.mousepressed(x, y, button) then
            return
        end
        
        -- Handle camera controls first
        camera.mousepressed(x, y, button)
        
        if button == 1 then -- Left mouse button
            -- Convert screen coordinates to world coordinates
            local wx, wy = camera.screenToWorld(x, y)
            
            -- Check UI clicks first (FIX: Pass the game object)
            if ui.mousepressed(x, y, button, game) then
                return -- UI handled the click
            end
            
            -- Check resource bit clicks
            local bit_clicked = false
            for i, bit in ipairs(game.resource_bits) do
                if bit.active and math.abs(wx - bit.x) < bit.size/2 and math.abs(wy - bit.y) < bit.size/2 and bit.grounded then
                    -- Move to resource bank if clicked
                    local bank_x = game.resource_banks[bit.type].x
                    local bank_y = game.resource_banks[bit.type].y
                    
                    -- Set velocity toward bank
                    local dx = bank_x - bit.x
                    local dy = bank_y - bit.y
                    local dist = math.sqrt(dx*dx + dy*dy)
                    
                    bit.vx = dx / dist * 200
                    bit.vy = dy / dist * 200
                    bit.moving_to_bank = true
                    
                    bit_clicked = true
                    
                    -- Play collect sound
                    audio.playSound("collect")
                    
                    -- Check tutorial action
                    tutorial.checkAction("collect_bits")
                    
                    break
                end
            end
            
            if bit_clicked then
                return -- Resource bit handled the click
            end
            
            -- Check resource clicks
            if game.checkResourceClicks(wx, wy) then
                -- Play click sound
                audio.playSound("click")
                
                -- Check tutorial action
                tutorial.checkAction("click_wood")
                
                return -- Resource handled the click
            end
        end
    end)
end

function love.mousereleased(x, y, button)
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Handle camera controls
        camera.mousereleased(x, y, button)
        
        -- Handle UI
        ui.mousereleased(x, y, button)
    end)
end

function love.mousemoved(x, y, dx, dy)
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Handle camera drag
        camera.mousemoved(x, y, dx, dy)
        
        -- Handle UI hover effects
        ui.mousemoved(x, y)
    end)
end

function love.wheelmoved(x, y)
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Handle camera zoom
        if y ~= 0 then
            local mx, my = love.mouse.getPosition()
            local zoom_factor = y > 0 and 1.1 or 0.9
            camera.zoom(mx, my, zoom_factor)
        end
    end)
end

function love.keypressed(key)
    -- Use safe call to prevent crashes
    utils.safeCall(function()
        -- Camera shortcuts
        if key == "r" then
            camera.resetPosition()
        elseif key == "e" then
            local enabled = camera.toggleEdgeScrolling()
            log.info("Edge scrolling " .. (enabled and "enabled" or "disabled"))
        elseif key == "c" then
            local enabled = game.toggleAutoCollect()
            log.info("Auto-collection " .. (enabled and "enabled" or "disabled"))
            
            -- Check tutorial action
            tutorial.checkAction("toggle_auto_collect")
        end
        
        -- UI shortcuts
        ui.keypressed(key)
        
        -- Game shortcuts
        game.keypressed(key)
    end)
end