-- project-clicker - World Module
-- Manages world entities, resource generation, and world drawing

local config = require("src.config")
local log = require("src.log")
local bits = require("src.bits")
local camera = require("src.camera")  
local events = require("src.events")

local world = {}

-- World constants
world.WIDTH = nil
world.HEIGHT = nil
world.GROUND_HEIGHT = nil
world.GROUND_LEVEL = nil
world.HORIZON_LEVEL = nil
world.SKY_COLOR = nil
world.GROUND_COLOR = nil
world.UNDERGROUND_COLOR = nil
world.GRID_SIZE = nil

-- World entities
world.entities = {
    resources = {},  -- {x, y, type, size, current_bits, max_bits}
    robots = {},     -- {x, y, size, robot_type, target_x, target_y, state, cooldown}
    buildings = {}   -- {x, y, type, width, height}
}

-- Resource banks (collection points)
world.resource_banks = {}

-- Initialize the world
function world.load()
    -- Load world constants from config
    world.WIDTH = config.world.width
    world.HEIGHT = config.world.height
    world.GROUND_HEIGHT = config.world.ground_height
    world.GROUND_LEVEL = world.GROUND_HEIGHT - world.HEIGHT/2
    
    -- Ensure horizon level is set
    if config.world.horizon_level then
        world.HORIZON_LEVEL = config.world.horizon_level
    else
        -- Calculate a default horizon level if not provided in config
        world.HORIZON_LEVEL = world.GROUND_LEVEL - 200
    end
    
    world.SKY_COLOR = config.world.sky_color
    world.GROUND_COLOR = config.world.ground_color
    world.UNDERGROUND_COLOR = config.world.underground_color
    world.GRID_SIZE = config.world.grid_size
    
    -- Initialize resource banks after GROUND_LEVEL is set
    world.resource_banks = {
        wood = {x = -120, y = world.GROUND_LEVEL, pixels = {
            {0,0,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,0},
            {1,1,1,1,1,1,1,1},
            {1,1,0,1,1,0,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1}
        }},
        stone = {x = 0, y = world.GROUND_LEVEL, pixels = {
            {0,0,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,0},
            {1,1,0,0,0,0,1,1},
            {1,1,0,1,1,0,1,1},
            {1,1,0,1,1,0,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1}
        }},
        food = {x = 120, y = world.GROUND_LEVEL, pixels = {
            {0,0,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,0},
            {1,1,1,0,0,1,1,1},
            {1,1,0,0,0,0,1,1},
            {1,1,0,0,0,0,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1}
        }}
    }
    
    log.info("World module loaded with dimensions " .. world.WIDTH .. "x" .. world.HEIGHT)
end

-- Function to check if a position is too close to any resource bank
function world.isTooCloseToBank(x, y, min_distance)
    for _, bank in pairs(world.resource_banks) do
        local dx = bank.x - x
        local dy = bank.y - y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance < min_distance then
            return true -- Too close to a bank
        end
    end
    return false -- Not too close to any bank
end

-- Generate resources in the world
function world.generateResources()
    log.info("Generating resources...")
    
    -- Clear existing resources
    world.entities.resources = {}
    
    -- Generate resources with proper properties
    local resource_types = {"wood", "stone", "food"}
    for _, resource_type in ipairs(resource_types) do
        -- Get configuration for this resource type
        local resource_config = config.resources.types[resource_type]
        local size = resource_config and resource_config.size or 20
        local min_bits = resource_config and resource_config.bits and resource_config.bits.min or 30
        local max_bits = resource_config and resource_config.bits and resource_config.bits.max or 50
        
        -- Create 10 resources of each type
        local resources_created = 0
        local attempts = 0
        local max_attempts = 200 -- Increase max attempts to ensure we find enough valid positions
        local min_distance = config.resources.min_bank_distance or 200
        
        while resources_created < 10 and attempts < max_attempts do
            local x = math.random(-world.WIDTH/2 + 100, world.WIDTH/2 - 100)
            local y = world.GROUND_LEVEL - math.random(10, 30)
            attempts = attempts + 1
            
            -- Check if the position is too close to any bank
            if not world.isTooCloseToBank(x, y, min_distance) then
                -- Calculate max bits (random value between min and max)
                local resource_max_bits = math.floor(min_bits + math.random() * (max_bits - min_bits))
                
                -- Create the resource with all required properties
                table.insert(world.entities.resources, {
                    x = x,
                    y = y,
                    type = resource_type,
                    size = size,
                    max_bits = resource_max_bits,
                    current_bits = resource_max_bits,
                    active = true
                })
                
                resources_created = resources_created + 1
            end
        end
        
        log.info("Created " .. resources_created .. " " .. resource_type .. " resources after " .. attempts .. " attempts")
    end
    
    log.info("Generated " .. #world.entities.resources .. " total resources")
end

-- Function to draw pixel art (used for resource banks)
local function drawPixelArt(pixels, x, y, scale, color, accent_color)
    scale = scale or 1
    color = color or {1, 1, 1}
    accent_color = accent_color or color
    
    for row = 1, #pixels do
        for col = 1, #pixels[row] do
            if pixels[row][col] == 1 then
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", 
                    x + (col-1) * scale, 
                    y + (row-1) * scale, 
                    scale, scale)
            elseif pixels[row][col] == 2 then
                love.graphics.setColor(accent_color)
                love.graphics.rectangle("fill", 
                    x + (col-1) * scale, 
                    y + (row-1) * scale, 
                    scale, scale)
            end
        end
    end
end

-- Draw the world background and ground
function world.drawBackground()
    -- Draw ground
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", -world.WIDTH/2, world.GROUND_LEVEL, world.WIDTH, world.HEIGHT/2)
    
    -- Draw horizon line
    if world.HORIZON_LEVEL then
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.line(-world.WIDTH/2, world.HORIZON_LEVEL, world.WIDTH/2, world.HORIZON_LEVEL)
    end
end

-- Draw resource banks
function world.drawResourceBanks(resources_collected)
    -- Draw resource banks
    for type, bank in pairs(world.resource_banks) do
        local color = {1, 1, 1} -- Default white color
        local accent_color = {1, 1, 1}
        
        -- Set accent colors based on resource type
        if type == "wood" then
            accent_color = {0.8, 0.6, 0.4} -- Brown accent for wood
        elseif type == "stone" then
            accent_color = {0.7, 0.7, 0.7} -- Gray accent for stone
        elseif type == "food" then
            accent_color = {0.5, 0.8, 0.3} -- Green accent for food
        end
        
        -- Draw the pixel art bank (positioned so bottom of bank is at ground level)
        -- Increase scale to make buildings larger
        local scale = 6 -- Larger scale for more prominent buildings
        drawPixelArt(bank.pixels, bank.x - 24, bank.y - 48, scale, accent_color)
        
        -- Format number with commas for thousands
        local amount = resources_collected[type] or 0
        local formatted_amount = tostring(amount)
        local formatted_with_commas = ""
        
        -- Add commas for thousands
        local length = string.len(formatted_amount)
        local position = 1
        
        while position <= length do
            local end_pos = length - position + 1
            local start_pos = math.max(1, end_pos - 2)
            local segment = string.sub(formatted_amount, start_pos, end_pos)
            
            if formatted_with_commas ~= "" then
                formatted_with_commas = segment .. "," .. formatted_with_commas
            else
                formatted_with_commas = segment
            end
            
            position = position + 3
        end
        
        -- Draw resource count with better visibility
        -- Draw a background for the text
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", bank.x - 40, bank.y - 60, 80, 30)
        
        -- Draw the resource count with a shadow for better readability
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(formatted_with_commas, bank.x - 9, bank.y - 49)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(formatted_with_commas, bank.x - 10, bank.y - 50)
        
        -- Draw resource type label with better visibility
        -- Draw a background for the text
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", bank.x - 40, bank.y - 90, 80, 25)
        
        -- Draw the resource type with a shadow for better readability
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.print(type:upper(), bank.x - 19, bank.y - 79)
        love.graphics.setColor(accent_color)
        love.graphics.print(type:upper(), bank.x - 20, bank.y - 80)
    end
end

-- Draw world resources
function world.drawResources(hover_resource, auto_collect_enabled, auto_collect_radius, show_collect_radius, camera_position, resource_particles, radius_pulse)
    for _, resource in ipairs(world.entities.resources) do
        -- Determine if this resource is being hovered
        local is_hovered = (hover_resource == resource)
        
        -- Determine if resource is within auto-collection radius
        local in_collection_radius = world.isResourceInCollectionRadius(
            resource, 
            auto_collect_enabled, 
            auto_collect_radius, 
            camera_position
        )
        
        -- Draw the resource with appropriate visual state
        world.drawResourceEntity(
            resource, 
            is_hovered, 
            in_collection_radius, 
            show_collect_radius, 
            camera_position, 
            radius_pulse
        )
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Check if a resource is within the auto-collection radius
function world.isResourceInCollectionRadius(resource, auto_collect_enabled, auto_collect_radius, camera_position)
    if not auto_collect_enabled then
        return false
    end
    
    local cam_x, cam_y = camera_position.x, camera_position.y
    local dx = resource.x - cam_x
    local dy = resource.y - cam_y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    return (distance < auto_collect_radius)
end

-- Calculate the display size of a resource based on remaining bits
function world.calculateResourceDisplaySize(resource)
    local remaining_ratio = 1
    if resource.max_bits and resource.current_bits then
        remaining_ratio = resource.current_bits / resource.max_bits
        -- Ensure resource doesn't get too small even when nearly depleted
        remaining_ratio = 0.3 + remaining_ratio * 0.7
    end
    
    return resource.size * remaining_ratio
end

-- Get the appropriate color for a resource based on its state
function world.getResourceColor(resource_type, is_hovered, in_collection_radius, show_collect_radius)
    if resource_type == "wood" then
        if is_hovered then
            return {0.8, 0.6, 0.2, 1} -- Brighter brown when hovered
        elseif in_collection_radius and show_collect_radius then
            return {0.7, 0.5, 0.15, 1} -- Slightly brighter when in collection radius
        else
            return {0.6, 0.4, 0.2, 1} -- Normal brown
        end
    elseif resource_type == "stone" then
        if is_hovered then
            return {0.9, 0.9, 0.9, 1} -- Brighter gray when hovered
        elseif in_collection_radius and show_collect_radius then
            return {0.8, 0.8, 0.8, 1} -- Slightly brighter when in collection radius
        else
            return {0.7, 0.7, 0.7, 1} -- Normal gray
        end
    elseif resource_type == "food" then
        if is_hovered then
            return {0.3, 1.0, 0.3, 1} -- Brighter green when hovered
        elseif in_collection_radius and show_collect_radius then
            return {0.25, 0.9, 0.25, 1} -- Slightly brighter when in collection radius
        else
            return {0.2, 0.8, 0.2, 1} -- Normal green
        end
    end
    
    return {1, 1, 1, 1} -- Default white
end

-- Draw a single resource entity
function world.drawResourceEntity(resource, is_hovered, in_collection_radius, show_collect_radius, camera_position, radius_pulse)
    -- Calculate the display size based on remaining bits
    local display_size = world.calculateResourceDisplaySize(resource)
    
    -- Set color based on resource type, hover state, and collection radius
    local color = world.getResourceColor(resource.type, is_hovered, in_collection_radius, show_collect_radius)
    love.graphics.setColor(color)
    
    -- Draw the resource with adjusted size
    love.graphics.rectangle("fill", resource.x - display_size/2, resource.y - display_size/2, display_size, display_size)
    
    -- Draw hover effects if needed
    if is_hovered then
        world.drawResourceHoverEffects(resource, display_size)
    else
        -- Always show remaining bits (smaller text when not hovered)
        if resource.current_bits then
            love.graphics.setColor(1, 1, 1, 0.7)
            love.graphics.printf(resource.current_bits, 
                resource.x - 20, 
                resource.y - 8, 
                40, "center")
        end
    end
    
    -- Draw collection radius indicator if needed
    if in_collection_radius and show_collect_radius and not is_hovered then
        world.drawCollectionRadiusIndicator(resource, display_size, camera_position, radius_pulse)
    end
end

-- Draw hover effects for a resource
function world.drawResourceHoverEffects(resource, display_size)
    -- Pulsating glow effect
    local pulse = 0.7 + math.sin(love.timer.getTime() * 5) * 0.3
    local glow_size = display_size * (1.2 + pulse * 0.2)
    
    -- Draw glow
    love.graphics.setColor(1, 1, 1, 0.3 * pulse)
    love.graphics.rectangle("fill", 
        resource.x - glow_size/2, 
        resource.y - glow_size/2, 
        glow_size, glow_size)
        
    -- Draw "Click to collect" text and remaining bits
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.printf("Click to collect", 
        resource.x - 60, 
        resource.y - display_size - 20, 
        120, "center")
    
    -- Show remaining bits if available
    if resource.current_bits then
        love.graphics.printf(resource.current_bits .. "/" .. resource.max_bits .. " bits", 
            resource.x - 60, 
            resource.y - display_size - 40, 
            120, "center")
    end
end

-- Draw collection radius indicator for a resource
function world.drawCollectionRadiusIndicator(resource, display_size, camera_position, radius_pulse)
    -- Pulsating effect based on radius pulse
    local pulse = 0.5 + math.sin(radius_pulse or 0) * 0.2
    
    -- Draw a small indicator above the resource
    love.graphics.setColor(0.2, 0.8, 0.2, pulse)
    love.graphics.circle("fill", resource.x, resource.y - display_size/2 - 15, 5)
    
    -- Draw a connecting line to the center
    local cam_x, cam_y = camera_position.x, camera_position.y
    love.graphics.setColor(0.2, 0.8, 0.2, pulse * 0.3)
    love.graphics.line(resource.x, resource.y, cam_x, cam_y)
end

-- Draw world robots
function world.drawRobots()
    for _, robot in ipairs(world.entities.robots) do
        -- Draw each robot
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 
            robot.x - robot.size/2, 
            robot.y - robot.size/2, 
            robot.size, robot.size)
        
        -- Draw robot type for debugging
        love.graphics.setColor(0, 0, 0)
        local type_initial = robot.type:sub(1,1)
        love.graphics.print(type_initial, robot.x - 4, robot.y - 6)
    end
end

-- Draw resource collection radius
function world.drawCollectionRadius(auto_collect_enabled, show_collect_radius, auto_collect_radius, camera_position, radius_pulse, last_collect_time)
    if not auto_collect_enabled or not show_collect_radius then
        return -- Don't draw if auto-collection is disabled or radius is hidden
    end
    
    -- Get camera position (center of screen)
    local cam_x, cam_y = camera_position.x, camera_position.y
    
    -- Calculate pulse effect
    local base_alpha = 0.2
    local pulse_alpha = 0.1 * math.sin(radius_pulse or 0)
    local alpha = base_alpha + pulse_alpha
    
    -- Enhance pulse effect if recently collected
    local time_since_collect = love.timer.getTime() - (last_collect_time or 0)
    if time_since_collect < 0.5 then
        alpha = alpha + 0.3 * (1 - time_since_collect * 2)
    end
    
    -- Draw the radius circle
    love.graphics.setColor(0.2, 0.8, 0.2, alpha)
    love.graphics.circle("line", cam_x, cam_y, auto_collect_radius)
    
    -- Draw a slightly larger, more transparent circle for better visibility
    love.graphics.setColor(0.2, 0.8, 0.2, alpha * 0.5)
    love.graphics.circle("line", cam_x, cam_y, auto_collect_radius + 5)
    
    -- Draw a small indicator at the center
    love.graphics.setColor(0.2, 0.8, 0.2, alpha * 2)
    love.graphics.circle("fill", cam_x, cam_y, 5)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Add a robot to the world
function world.addRobot(robot_type_key, robots_config)
    local robot_type = robots_config[robot_type_key or "GATHERER"]
    local cam_x, cam_y = camera.getPosition()
    
    local robot = {
        x = cam_x + love.math.random(-100, 100), -- Spawn near camera
        y = world.GROUND_LEVEL - 16,
        size = 16,
        type = robot_type_key or "GATHERER",
        state = "idle",
        cooldown = 0,
        target_x = 0,
        target_y = 0
    }
    
    table.insert(world.entities.robots, robot)
    log.info("Robot created: " .. robot_type_key .. " at position " .. robot.x .. "," .. robot.y)
    return robot
end

-- Update resource bits counts
function world.updateResource(resource_index, bits_used)
    local resource = world.entities.resources[resource_index]
    if resource then
        resource.current_bits = resource.current_bits - bits_used
        
        -- Remove resource if depleted
        if resource.current_bits <= 0 then
            -- Trigger resource depleted event before removing the resource
            events.trigger("resource_depleted", resource.type, resource.x, resource.y)
            table.remove(world.entities.resources, resource_index)
            return true -- Resource was depleted
        end
    end
    return false -- Resource was not depleted
end

-- Find a resource by type
function world.findResourceByType(resource_type)
    for i, resource in ipairs(world.entities.resources) do
        if resource.type == resource_type and resource.current_bits > 0 then
            return resource, i
        end
    end
    return nil, nil
end

-- Reset the world
function world.reset()
    world.entities.resources = {}
    world.entities.robots = {}
    world.entities.buildings = {}
    world.generateResources()
    
    log.info("World has been reset")
end

return world