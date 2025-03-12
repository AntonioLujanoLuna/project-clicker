-- Import modules
local camera = require("src.camera")
local game = require("src.game")
local ui = require("src.ui")
local pollution = require("src.pollution")
local config = require("src.config")

-- Initialize game
function love.load()
    -- Set up the window
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1) -- Dark background
    
    -- Initialize configuration
    config.init()
    
    -- Initialize modules
    game.load()
    ui.load()
    pollution.load()
    
    -- Set up camera with game world dimensions
    camera.load(game.WORLD_WIDTH, game.WORLD_HEIGHT)
end

-- Update game state
function love.update(dt)
    -- Update game logic
    game.update(dt)
    
    -- Update UI
    ui.update(dt)
    
    -- Update camera
    camera.update(dt)
    
    -- Update pollution
    pollution.update(dt)
end

-- Draw game
function love.draw()
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
end

function love.mousepressed(x, y, button)
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
            if math.abs(wx - bit.x) < bit.size/2 and math.abs(wy - bit.y) < bit.size/2 and bit.grounded then
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
                break
            end
        end
        
        if bit_clicked then
            return -- Resource bit handled the click
        end
        
        -- Check resource clicks
        if game.checkResourceClicks(wx, wy) then
            return -- Resource handled the click
        end
    end
end

function love.mousereleased(x, y, button)
    -- Handle camera controls
    camera.mousereleased(x, y, button)
    
    -- Handle UI
    ui.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    -- Handle camera drag
    camera.mousemoved(x, y, dx, dy)
    
    -- Handle UI hover effects
    ui.mousemoved(x, y)
end

function love.wheelmoved(x, y)
    -- Handle camera zoom
    if y ~= 0 then
        local mx, my = love.mouse.getPosition()
        local zoom_factor = y > 0 and 1.1 or 0.9
        camera.zoom(mx, my, zoom_factor)
    end
end

function love.keypressed(key)
    -- Camera shortcuts
    if key == "r" then
        camera.resetPosition()
    elseif key == "e" then
        local enabled = camera.toggleEdgeScrolling()
        print("Edge scrolling " .. (enabled and "enabled" or "disabled"))
    end
    
    -- UI shortcuts
    ui.keypressed(key)
    
    -- Game shortcuts
    game.keypressed(key)
end