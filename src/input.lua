-- project-clicker - Input Module
-- Manages user input, resource clicking, and interactions

local config = require("src.config")
local log = require("src.log")
local bits = require("src.bits")
local audio = require("src.audio")

local input = {}

-- Handle mouse button press events
function input.mousepressed(x, y, button, world, camera, game, ui, tutorial)
    -- Use safe call to prevent crashes
    local success, message = pcall(function()
        -- Check if tutorial handled the click first
        if tutorial and tutorial.mousepressed and tutorial.mousepressed(x, y, button) then
            return true
        end
        
        -- Handle camera controls first
        if camera.mousepressed(x, y, button) then
            return true
        end
        
        if button == 1 then -- Left mouse button
            -- Convert screen coordinates to world coordinates
            local wx, wy = camera.screenToWorld(x, y)
            
            -- Check UI clicks first
            if ui.mousepressed(x, y, button, game) then
                return true -- UI handled the click
            end
            
            -- Check resource bit clicks
            local bit_clicked = false
            for i, bit in ipairs(bits.resource_bits) do
                if bit.active and math.abs(wx - bit.x) < bit.size and math.abs(wy - bit.y) < bit.size then
                    local clicked_bits = {bit}
                    
                    -- Find nearby bits to also send toward bank (powder effect)
                    for j, other_bit in ipairs(bits.resource_bits) do
                        if i ~= j and bit.type == other_bit.type then
                            local dx = bit.x - other_bit.x
                            local dy = bit.y - other_bit.y
                            local distance = math.sqrt(dx*dx + dy*dy)
                            
                            -- If close enough, include in the clicked group
                            if distance < bit.size * 4 then
                                table.insert(clicked_bits, other_bit)
                            end
                        end
                    end
                    
                    -- Send bits to bank
                    local count = bits.sendBitsToBank(clicked_bits, bit.type, world.resource_banks)
                    
                    -- Play collect sound
                    audio.playSound("collect")
                    
                    -- Check tutorial action
                    if tutorial then tutorial.checkAction("collect_bits") end
                    
                    bit_clicked = true
                    break -- Only process one click at a time
                end
            end
            
            if bit_clicked then
                return true -- Resource bit was clicked
            end
            
            -- Check world resource clicks
            for i, resource in ipairs(world.entities.resources) do
                if wx >= resource.x - resource.size/2 and wx <= resource.x + resource.size/2 and
                   wy >= resource.y - resource.size/2 and wy <= resource.y + resource.size/2 then
                    
                    -- If resource has bits remaining
                    if resource.current_bits and resource.current_bits > 0 then
                        -- Determine how many bits to generate (between 5-15 based on resource size)
                        local bits_to_generate = math.min(15, resource.current_bits)
                        
                        -- Generate bits
                        local created_bits = bits.createBitsFromResource(resource, bits_to_generate, world.GROUND_LEVEL)
                        log.info("Created " .. #created_bits .. " bits from resource click")
                        
                        -- Update resource bits count
                        local was_depleted = world.updateResource(i, bits_to_generate)
                        
                        -- Generate pollution
                        game.pollution_level = game.pollution_level + 
                          config.resources.types[resource.type].pollution_per_click
                        
                        -- Play sound
                        audio.playSound("click")
                        
                        -- Visual feedback
                        if game.resource_particles and game.resource_particles[resource.type] then
                            game.resource_particles[resource.type]:setPosition(resource.x, resource.y)
                            game.resource_particles[resource.type]:emit(20)
                            
                            -- Special depletion effect
                            if was_depleted then
                                game.resource_particles[resource.type]:emit(30)
                            end
                        end
                        
                        -- Check tutorial action
                        if tutorial then tutorial.checkAction("click_wood") end
                        
                        return true
                    end
                end
            end
        end

        return false
    end)
    
    if not success then
        log.error("Error in mousepressed handler: " .. tostring(message))
        return false
    end
end

-- Handle mouse button release events
function input.mousereleased(x, y, button, camera, ui)
    -- Handle camera controls
    camera.mousereleased(x, y, button)
    
    -- Handle UI
    ui.mousereleased(x, y, button)
end

-- Handle mouse movement events
function input.mousemoved(x, y, dx, dy, camera, ui)
    -- Handle camera drag
    camera.mousemoved(x, y, dx, dy)
    
    -- Handle UI hover effects
    ui.mousemoved(x, y)
    
    -- Track hovered resource for visual effects
    local hover_resource = nil
    local wx, wy = camera.screenToWorld(x, y)
    
    for _, resource in ipairs(world.entities.resources) do
        if wx >= resource.x - resource.size/2 and wx <= resource.x + resource.size/2 and
           wy >= resource.y - resource.size/2 and wy <= resource.y + resource.size/2 then
            hover_resource = resource
            break
        end
    end
    
    return hover_resource
end

-- Handle mouse wheel events
function input.wheelmoved(x, y, camera)
    -- Handle camera zoom
    if y ~= 0 then
        local mx, my = love.mouse.getPosition()
        local zoom_factor = y > 0 and 1.1 or 0.9
        camera.zoom(mx, my, zoom_factor)
    end
end

-- Handle keyboard events
function input.keypressed(key, camera, game, ui, tutorial)
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
        if tutorial then tutorial.checkAction("toggle_auto_collect") end
    end
    
    -- UI shortcuts
    ui.keypressed(key)
    
    -- Game shortcuts
    game.keypressed(key)
end

return input