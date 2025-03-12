-- project-clicker - Game Module
-- Manages the core game state and logic

local resources = require("src.resources")
local robots = require("src.robots")
local buildings = require("src.buildings")
local pollution = require("src.pollution")
local ui = require("src.ui")
local camera = require("src.camera")

local game = {}

-- Game constants
game.WORLD_WIDTH = 4000  -- Extended world size
game.WORLD_HEIGHT = 1200
game.GROUND_HEIGHT = 900 -- Height of the ground from bottom (changed to make ground 1/4, sky 3/4)
game.GROUND_LEVEL = game.GROUND_HEIGHT - game.WORLD_HEIGHT/2 -- Y coordinate of ground level
game.HORIZON_LEVEL = game.GROUND_LEVEL - 200 -- Y coordinate of the horizon line
game.SKY_COLOR = {0.1, 0.1, 0.1} -- Dark gray/black sky
game.GROUND_COLOR = {0.1, 0.1, 0.1} -- Same dark color for ground
game.UNDERGROUND_COLOR = {0.1, 0.1, 0.1} -- Same dark color for underground
game.GRID_SIZE = 50 -- Size of grid cells

-- Game state
game.resources = {}
game.robots = {}
game.buildings = {}
game.pollution_level = 0
game.research_points = 0
game.hover_resource = nil -- Track which resource is being hovered
game.collection_animations = {} -- For visual feedback when collecting resources

-- Resource click feedback
game.resource_particles = {}
game.resource_feedback = {}

-- Resource bits on the ground (new mechanic)
game.resource_bits = {} -- {x, y, type, size, vx, vy, grounded, pixels, colliding_with}

-- Pixel art for resource bits
game.resource_bit_pixels = {
    wood = {
        {0,1,1,0},
        {1,1,1,1},
        {1,1,1,1},
        {0,1,1,0}
    },
    stone = {
        {1,1,1,1},
        {1,0,0,1},
        {1,0,0,1},
        {1,1,1,1}
    },
    food = {
        {0,1,0,0},
        {1,1,1,0},
        {0,1,1,1},
        {0,0,1,0}
    }
}

-- Resource banks (collection points)
game.resource_banks = {
    wood = {x = -120, y = game.GROUND_LEVEL, pixels = {
        {0,0,1,1,1,1,0,0},
        {0,1,1,1,1,1,1,0},
        {1,1,1,1,1,1,1,1},
        {1,1,0,1,1,0,1,1},
        {1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1}
    }},
    stone = {x = 0, y = game.GROUND_LEVEL, pixels = {
        {0,0,1,1,1,1,0,0},
        {0,1,1,1,1,1,1,0},
        {1,1,0,0,0,0,1,1},
        {1,1,0,1,1,0,1,1},
        {1,1,0,1,1,0,1,1},
        {1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1},
        {1,1,1,1,1,1,1,1}
    }},
    food = {x = 120, y = game.GROUND_LEVEL, pixels = {
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

-- World entities (temporary representation)
game.world_entities = {
    resources = {},  -- {x, y, type, size}
    robots = {}      -- {x, y, size, robot_type, target_x, target_y, state, cooldown}
}

-- Resources collected (player's inventory)
game.resources_collected = {
    wood = 0,
    stone = 0,
    food = 0
}

-- Add to game state section
game.AUTO_COLLECT_RADIUS = 150 -- Radius for auto-collection
game.auto_collect_enabled = false -- Disable auto-collection by default
game.auto_collect_cooldown = 0 -- Cooldown for auto-collection
game.show_collect_radius = true -- Whether to show the collection radius
game.radius_pulse = 0 -- For pulsing effect
game.last_collect_time = 0 -- To track when resources were last collected

local function initializeWorld()
    -- Add some random resources in the world
    local resource_types = {"wood", "stone", "food"}
    
    -- Wood resources - placed on ground
    for i = 1, 15 do
        local x = love.math.random(-game.WORLD_WIDTH/2 + 100, game.WORLD_WIDTH/2 - 100)
        table.insert(game.world_entities.resources, {
            x = x,
            y = game.GROUND_LEVEL, -- Place exactly on ground
            type = "wood",
            size = 30
        })
    end
    
    -- Stone resources - placed on ground
    for i = 1, 12 do
        local x = love.math.random(-game.WORLD_WIDTH/2 + 100, game.WORLD_WIDTH/2 - 100)
        table.insert(game.world_entities.resources, {
            x = x,
            y = game.GROUND_LEVEL, -- Place exactly on ground
            type = "stone",
            size = 25
        })
    end
    
    -- Food resources - placed on ground
    for i = 1, 10 do
        local x = love.math.random(-game.WORLD_WIDTH/2 + 100, game.WORLD_WIDTH/2 - 100)
        table.insert(game.world_entities.resources, {
            x = x,
            y = game.GROUND_LEVEL, -- Place exactly on ground
            type = "food",
            size = 20
        })
    end
    
    -- No robots at the beginning
end

function game.load()
    -- Initialize camera with world boundaries
    camera.load(game.WORLD_WIDTH, game.WORLD_HEIGHT)
    
    -- Set the ground level for the camera
    camera.setGroundLevel(game.GROUND_LEVEL)
    
    resources.load()
    robots.load()
    buildings.load()
    pollution.load()
    ui.load()
    
    -- Initialize resource feedback array
    game.resource_feedback = {}
    
    -- Initialize world entities
    initializeWorld()
    
    -- Initialize resource particle systems
    local particle_img = love.graphics.newCanvas(4, 4)
    love.graphics.setCanvas(particle_img)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 4, 4)
    love.graphics.setCanvas()
    
    -- Create particle systems for each resource type
    local resource_colors = {
        wood = {0.8, 0.6, 0.4},  -- Brown for wood
        stone = {0.7, 0.7, 0.7}, -- Gray for stone
        food = {0.5, 0.8, 0.3}   -- Green for food
    }
    
    game.resource_particles = {}
    for type, color in pairs(resource_colors) do
        local ps = love.graphics.newParticleSystem(particle_img, 50)
        ps:setParticleLifetime(0.5, 1.5)
        ps:setEmissionRate(0)
        ps:setSizeVariation(0.5)
        ps:setLinearAcceleration(-50, -100, 50, 0)
        ps:setColors(color[1], color[2], color[3], 1, color[1], color[2], color[3], 0)
        ps:setSizes(2, 1)
        game.resource_particles[type] = ps
    end
    
    -- Debug info
    print("project-clicker game loaded!")
    print("Initial pollution level:", game.pollution_level)
    print("World size:", game.WORLD_WIDTH, "x", game.WORLD_HEIGHT)
    print("Ground level at y =", game.GROUND_LEVEL)
    
    -- Connect resources.lua with game.lua
    resources.create_bits_callback = game.createResourceBit
end

function game.draw()
    -- Apply camera transformations
    camera.set()
    
    -- Draw ground
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", -game.WORLD_WIDTH/2, game.GROUND_LEVEL, game.WORLD_WIDTH, game.WORLD_HEIGHT/2)
    
    -- Draw horizon line
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.line(-game.WORLD_WIDTH/2, game.HORIZON_LEVEL, game.WORLD_WIDTH/2, game.HORIZON_LEVEL)
    
    -- Draw collection radius
    game.drawCollectionRadius()
    
    -- Draw resource banks
    game.drawResourceBanks()
    
    -- Draw resources with hover effect
    for _, resource in ipairs(game.world_entities.resources) do
        -- Determine if this resource is being hovered
        local is_hovered = (game.hover_resource == resource)
        
        -- Determine if resource is within auto-collection radius
        local in_collection_radius = false
        if game.auto_collect_enabled then
            local cam_x, cam_y = camera.getPosition()
            local dx = resource.x - cam_x
            local dy = resource.y - cam_y
            local distance = math.sqrt(dx*dx + dy*dy)
            in_collection_radius = (distance < game.AUTO_COLLECT_RADIUS)
        end
        
        -- Set color based on resource type, hover state, and collection radius
        if resource.type == "wood" then
            if is_hovered then
                love.graphics.setColor(0.8, 0.6, 0.2, 1) -- Brighter brown when hovered
            elseif in_collection_radius and game.show_collect_radius then
                love.graphics.setColor(0.7, 0.5, 0.15, 1) -- Slightly brighter when in collection radius
            else
                love.graphics.setColor(0.6, 0.4, 0.2, 1) -- Normal brown
            end
        elseif resource.type == "stone" then
            if is_hovered then
                love.graphics.setColor(0.9, 0.9, 0.9, 1) -- Brighter gray when hovered
            elseif in_collection_radius and game.show_collect_radius then
                love.graphics.setColor(0.8, 0.8, 0.8, 1) -- Slightly brighter when in collection radius
            else
                love.graphics.setColor(0.7, 0.7, 0.7, 1) -- Normal gray
            end
        elseif resource.type == "food" then
            if is_hovered then
                love.graphics.setColor(0.3, 1.0, 0.3, 1) -- Brighter green when hovered
            elseif in_collection_radius and game.show_collect_radius then
                love.graphics.setColor(0.25, 0.9, 0.25, 1) -- Slightly brighter when in collection radius
            else
                love.graphics.setColor(0.2, 0.8, 0.2, 1) -- Normal green
            end
        end
        
        -- Draw the resource
        love.graphics.rectangle("fill", resource.x - resource.size/2, resource.y - resource.size/2, resource.size, resource.size)
        
        -- Draw highlight effect if hovered
        if is_hovered then
            -- Pulsating glow effect
            local pulse = 0.7 + math.sin(love.timer.getTime() * 5) * 0.3
            local glow_size = resource.size * (1.2 + pulse * 0.2)
            
            -- Draw glow
            love.graphics.setColor(1, 1, 1, 0.3 * pulse)
            love.graphics.rectangle("fill", 
                resource.x - glow_size/2, 
                resource.y - glow_size/2, 
                glow_size, glow_size)
                
            -- Draw "Click to collect" text
            love.graphics.setColor(1, 1, 1, 0.9)
            love.graphics.printf("Click to collect", 
                resource.x - 60, 
                resource.y - resource.size - 20, 
                120, "center")
        end
        
        -- Draw indicator for resources in collection radius
        if in_collection_radius and game.show_collect_radius and not is_hovered then
            -- Pulsating effect based on radius pulse
            local pulse = 0.5 + math.sin(game.radius_pulse) * 0.2
            
            -- Draw a small indicator above the resource
            love.graphics.setColor(0.2, 0.8, 0.2, pulse)
            love.graphics.circle("fill", resource.x, resource.y - resource.size/2 - 15, 5)
            
            -- Draw a connecting line to the center
            local cam_x, cam_y = camera.getPosition()
            love.graphics.setColor(0.2, 0.8, 0.2, pulse * 0.3)
            love.graphics.line(resource.x, resource.y, cam_x, cam_y)
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
    
    -- Draw resource bits
    game.drawResourceBits()
    
    -- Draw resource feedback
    game.drawResourceFeedback()
    
    -- Draw robots
    for _, robot in ipairs(game.robots) do
        local robot_type = robots.TYPES[robot.type]
        robots.draw(robot, robot_type)
    end
    
    -- Draw buildings
    for _, building in ipairs(game.buildings) do
        local building_type = buildings.TYPES[building.type]
        buildings.draw(building, building_type)
    end
    
    -- Draw collection animations
    if game.collection_animations then
        for _, anim in ipairs(game.collection_animations) do
            local alpha = 1 - (anim.lifetime / anim.max_lifetime)
            local y_offset = 30 * (anim.lifetime / anim.max_lifetime)
            
            love.graphics.setColor(anim.color[1], anim.color[2], anim.color[3], alpha)
            love.graphics.print(anim.text, anim.x, anim.y - y_offset)
        end
    end
    
    -- Remove camera transformations
    camera.unset()
    
    -- Draw pollution overlay in screen space
    if game.pollution_level > 0 then
        local color
        if game.pollution_level < 30 then
            color = pollution.COLORS.LOW
        elseif game.pollution_level < 70 then
            color = pollution.COLORS.MEDIUM
        else
            color = pollution.COLORS.HIGH
        end
        
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end
    
    -- Draw UI elements
    ui.draw(game.resources, game.pollution_level, game.research_points)
end

function game.drawWorldEntities()
    -- Draw resource nodes in the world
    for _, resource in ipairs(game.world_entities.resources) do
        -- All resources are white in monochrome
        love.graphics.setColor(1, 1, 1)
        
        -- Draw resource as a square
        love.graphics.rectangle("fill", resource.x - resource.size/2, resource.y - resource.size/2, resource.size, resource.size)
        
        -- Draw resource label
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            resource.type:sub(1,1):upper() .. resource.type:sub(2), 
            resource.x - 40, 
            resource.y - resource.size/2 - 20, 
            80, 
            "center"
        )
    end
    
    -- Draw robots in the world
    for _, robot in ipairs(game.world_entities.robots) do
        -- Draw robot as a square with a different shade
        love.graphics.setColor(1, 1, 1) -- White for robots too
        love.graphics.rectangle("fill", robot.x - robot.size/2, robot.y - robot.size/2, robot.size, robot.size)
        
        -- Draw a small indicator of robot type (could be a letter or symbol)
        love.graphics.setColor(0, 0, 0) -- Black text for contrast
        local type_initial = robot.type:sub(1,1):upper()
        love.graphics.printf(
            type_initial, 
            robot.x - 10, 
            robot.y - 7, 
            20, 
            "center"
        )
    end
end

function game.update(dt)
    -- Update camera
    camera.update(dt)
    
    -- Update game systems
    resources.update(dt)
    robots.update(dt, game.resources)
    buildings.update(dt, game.resources)
    
    -- Update pollution level
    local new_pollution = pollution.update(dt, game.pollution_level, game.resources, game.buildings, game.robots)
    if new_pollution then
        game.pollution_level = new_pollution
    end
    
    -- Generate research points over time (very slowly)
    game.research_points = game.research_points + 0.01 * dt
    
    -- Update UI
    ui.update(dt)
    
    -- Handle resource clicking pollution
    if resources.last_click_pollution then
        game.pollution_level = pollution.generate(resources.last_click_pollution, game.pollution_level)
        resources.last_click_pollution = nil
    end
    
    -- Update resource particle systems
    for _, ps in pairs(game.resource_particles) do
        ps:update(dt)
    end
    
    -- Update resource feedback
    for i = #game.resource_feedback, 1, -1 do
        local feedback = game.resource_feedback[i]
        feedback.time = feedback.time - dt
        feedback.y = feedback.y - 50 * dt -- Move upward
        
        if feedback.time <= 0 then
            table.remove(game.resource_feedback, i)
        end
    end
    
    -- Update collection animations
    if game.collection_animations then
        for i = #game.collection_animations, 1, -1 do
            local anim = game.collection_animations[i]
            anim.lifetime = anim.lifetime + dt
            if anim.lifetime >= anim.max_lifetime then
                table.remove(game.collection_animations, i)
            end
        end
    else
        -- Initialize if it doesn't exist
        game.collection_animations = {}
    end
    
    -- Update radius pulse effect
    game.radius_pulse = game.radius_pulse + dt * 2
    if game.radius_pulse > math.pi * 2 then
        game.radius_pulse = 0
    end
    
    -- Auto-collection feature
    if game.auto_collect_enabled then
        -- Update cooldown
        if game.auto_collect_cooldown > 0 then
            game.auto_collect_cooldown = game.auto_collect_cooldown - dt
        else
            -- Get camera position (center of screen)
            local cam_x, cam_y = camera.getPosition()
            
            -- Check for resources within auto-collect radius
            for i, resource in ipairs(game.world_entities.resources) do
                local dx = resource.x - cam_x
                local dy = resource.y - cam_y
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance < game.AUTO_COLLECT_RADIUS then
                    -- Auto-collect this resource
                    game.collectResource(resource.type, 1, resource.x, resource.y)
                    
                    -- Reset cooldown (shorter for auto-collection)
                    game.auto_collect_cooldown = 1.5
                    
                    -- Visual feedback
                    game.resource_particles[resource.type]:setPosition(resource.x, resource.y)
                    game.resource_particles[resource.type]:emit(8) -- Fewer particles
                    
                    -- Add collection animation
                    game.addCollectionAnimation(resource.x, resource.y, resource.type, 1)
                    
                    -- Update last collect time for pulse effect
                    game.last_collect_time = love.timer.getTime()
                    
                    break -- Only collect one resource per cooldown
                end
            end
        end
    end
    
    -- Update robots
    for _, robot in ipairs(game.world_entities.robots) do
        -- Initialize robot state if not set
        if not robot.state then
            robot.state = "idle"
            robot.cooldown = 0
            robot.target_x = robot.x
            robot.target_y = robot.y
        end
        
        -- Robot behavior based on type
        if robot.type == "GATHERER" then
            -- Gatherer robot behavior
            if robot.state == "idle" then
                -- Find a random resource to gather
                if #game.world_entities.resources > 0 then
                    local target_resource = game.world_entities.resources[love.math.random(1, #game.world_entities.resources)]
                    robot.target_x = target_resource.x
                    robot.target_resource = target_resource
                    robot.state = "moving"
                end
            elseif robot.state == "moving" then
                -- Move toward target
                local dx = robot.target_x - robot.x
                local speed = 50 * dt -- Movement speed
                
                if math.abs(dx) < speed then
                    -- Reached target
                    robot.x = robot.target_x
                    robot.state = "gathering"
                    robot.cooldown = 2 -- Gathering takes 2 seconds
                else
                    -- Move toward target
                    robot.x = robot.x + (dx > 0 and speed or -speed)
                end
            elseif robot.state == "gathering" then
                -- Gathering resource
                robot.cooldown = robot.cooldown - dt
                
                if robot.cooldown <= 0 then
                    -- Gathered resource - create resource bits instead of directly adding to inventory
                    if robot.target_resource then
                        -- Create resource bits
                        for i = 1, 3 do
                            table.insert(game.resource_bits, {
                                x = robot.target_resource.x + love.math.random(-20, 20),
                                y = robot.target_resource.y - 20,
                                type = robot.target_resource.type,
                                size = 4, -- Smaller size for powder-like appearance
                                vx = love.math.random(-30, 30), -- Less horizontal velocity
                                vy = -love.math.random(50, 100), -- Just a small initial upward velocity
                                grounded = false,
                                colliding_with = nil -- Track collisions with other bits
                            })
                        end
                        
                        -- Visual feedback
                        game.resource_particles[robot.target_resource.type]:setPosition(
                            robot.target_resource.x, 
                            robot.target_resource.y - 20)
                        game.resource_particles[robot.target_resource.type]:emit(5)
                    end
                    
                    -- Return to idle state
                    robot.state = "idle"
                    robot.target_resource = nil
                end
            end
        elseif robot.type == "TRANSPORTER" then
            -- Transporter robot behavior - moves between resources
            if robot.state == "idle" then
                -- Find a random position to move to
                robot.target_x = love.math.random(-game.WORLD_WIDTH/2 + 200, game.WORLD_WIDTH/2 - 200)
                robot.state = "moving"
            elseif robot.state == "moving" then
                -- Move toward target
                local dx = robot.target_x - robot.x
                local speed = 80 * dt -- Faster movement speed
                
                if math.abs(dx) < speed then
                    -- Reached target
                    robot.x = robot.target_x
                    robot.state = "idle"
                    robot.cooldown = love.math.random(1, 3) -- Random pause
                else
                    -- Move toward target
                    robot.x = robot.x + (dx > 0 and speed or -speed)
                end
            end
        elseif robot.type == "RECYCLER" then
            -- Recycler robot behavior - stays mostly in place
            if not robot.home_x then
                robot.home_x = robot.x
            end
            
            -- Small random movements around home position
            if love.math.random() < 0.02 then
                robot.target_x = robot.home_x + love.math.random(-100, 100)
                robot.state = "moving"
            end
            
            if robot.state == "moving" then
                -- Move toward target
                local dx = robot.target_x - robot.x
                local speed = 30 * dt -- Slower movement speed
                
                if math.abs(dx) < speed then
                    -- Reached target
                    robot.x = robot.target_x
                    robot.state = "idle"
                else
                    -- Move toward target
                    robot.x = robot.x + (dx > 0 and speed or -speed)
                end
            end
        end
    end
    
    -- Update resource bits physics
    for i = #game.resource_bits, 1, -1 do
        local bit = game.resource_bits[i]
        
        -- Apply gravity if not grounded
        if not bit.grounded and not bit.moving_to_bank then
            bit.vy = bit.vy + 600 * dt -- Stronger gravity for faster falling
        end
        
        -- Update position
        bit.x = bit.x + bit.vx * dt
        bit.y = bit.y + bit.vy * dt
        
        -- Reset collision state
        bit.colliding_with = nil
        
        -- Check for ground collision
        if bit.y > game.GROUND_LEVEL - bit.size/2 and not bit.moving_to_bank then
            bit.y = game.GROUND_LEVEL - bit.size/2
            bit.vy = 0 -- Stop vertical movement instead of bouncing
            bit.vx = bit.vx * 0.8 -- Apply friction
            
            -- Check if almost stopped
            if math.abs(bit.vx) < 5 then
                bit.vx = 0
                bit.grounded = true
            end
        end
        
        -- Simplified collision handling for powder-like behavior
        for j, other_bit in ipairs(game.resource_bits) do
            if i ~= j then
                -- Simple grid-based collision for powder-like behavior
                local dx = math.abs(bit.x - other_bit.x)
                local dy = math.abs(bit.y - other_bit.y)
                
                -- If bits are very close (overlapping)
                if dx < bit.size and dy < bit.size then
                    -- Resolve collision by pushing bits apart slightly
                    if bit.x < other_bit.x then
                        bit.x = bit.x - 1
                        other_bit.x = other_bit.x + 1
                    else
                        bit.x = bit.x + 1
                        other_bit.x = other_bit.x - 1
                    end
                    
                    -- If this bit is above the other, let it rest on top
                    if bit.y < other_bit.y and bit.vy > 0 then
                        bit.y = other_bit.y - bit.size
                        bit.vy = 0
                        bit.vx = bit.vx * 0.9 -- Apply friction
                        
                        -- If the bit below is grounded, this one becomes grounded too
                        if other_bit.grounded then
                            bit.grounded = true
                        end
                        
                        -- If almost stopped while on top of another bit
                        if math.abs(bit.vx) < 5 then
                            bit.vx = 0
                        end
                    end
                end
            end
        end
        
        -- Check for resource bank collision
        if bit.moving_to_bank then
            local bank = game.resource_banks[bit.type]
            if bank then
                local dx = bank.x - bit.x
                local dy = bank.y - bit.y
                local dist = math.sqrt(dx*dx + dy*dy)
                
                -- If very close to bank, collect the resource
                if dist < 20 then
                    -- Add to resource count
                    game.resources_collected[bit.type] = game.resources_collected[bit.type] + 1
                    
                    -- Visual feedback
                    table.insert(game.resource_feedback, {
                        x = bit.x,
                        y = bit.y - 20,
                        type = bit.type,
                        amount = 1,
                        time = 1.5
                    })
                    
                    -- Remove the bit
                    table.remove(game.resource_bits, i)
                    
                    -- Debug output
                    print("Added " .. bit.type .. " to inventory! Total: " .. game.resources_collected[bit.type])
                -- If bit has landed but is still not close enough to bank, make it jump again
                elseif bit.grounded and math.abs(dx) > 20 then
                    -- Calculate direction toward bank
                    local direction = dx > 0 and 1 or -1
                    local distance = math.abs(dx)
                    
                    -- Jump toward bank with a distance-based velocity
                    local jump_strength = math.min(distance * 0.2, 200)
                    
                    -- Proper jumping physics
                    bit.vx = direction * jump_strength
                    bit.vy = -250 -- Stronger upward velocity for a more pronounced jump
                    bit.grounded = false
                    
                    -- Debug output
                    print("Resource bit jumping again toward bank! Distance: " .. distance)
                end
            end
        end
    end
end

function game.mousepressed(x, y, button)
    -- Handle camera drag
    camera.mousepressed(x, y, button)
    
    -- Convert screen coordinates to world coordinates for resource clicking
    if button == 1 then -- Left mouse button
        local wx, wy = camera.screenToWorld(x, y)
        
        -- First check if we clicked on a resource in resources.lua
        local screen_x, screen_y = x, y -- Keep original screen coordinates for UI
        if game.checkResourceClicks(screen_x, screen_y) then
            -- Resource was clicked, bits were created
            return
        end
        
        -- Check if clicked on any resource in world entities
        for _, resource in ipairs(game.world_entities.resources) do
            -- Simple square collision check for all resource types
            if wx >= resource.x - resource.size/2 and wx <= resource.x + resource.size/2 and
               wy >= resource.y - resource.size/2 and wy <= resource.y + resource.size/2 then
                
                -- Generate resource bits without initial bias toward bank
                for i = 1, 10 do -- More bits for a powder-like effect
                    local bit = {
                        x = resource.x + love.math.random(-20, 20),
                        y = resource.y - love.math.random(5, 15), -- Start slightly above the resource
                        type = resource.type,
                        size = 4, -- Smaller size for powder-like appearance
                        vx = love.math.random(-30, 30), -- Less horizontal velocity
                        vy = -love.math.random(50, 100), -- Just a small initial upward velocity
                        grounded = false,
                        colliding_with = nil, -- Track collisions with other bits
                        moving_to_bank = false -- Bits don't automatically move to bank
                    }
                    table.insert(game.resource_bits, bit)
                end
                
                -- Generate pollution
                resources.last_click_pollution = resources.TYPES[string.upper(resource.type)].pollution_per_click
                
                -- Visual feedback - particles
                game.resource_particles[resource.type]:setPosition(resource.x, resource.y)
                game.resource_particles[resource.type]:emit(15)
                
                -- Visual feedback - console
                print("Created " .. resource.type .. " bits!")
                break
            end
        end
        
        -- Check if clicked on any resource bit
        for i, bit in ipairs(game.resource_bits) do
            if wx >= bit.x - bit.size/2 and wx <= bit.x + bit.size/2 and
               wy >= bit.y - bit.size/2 and wy <= bit.y + bit.size/2 then
                
                -- Set the bit in motion toward its bank
                local bank = game.resource_banks[bit.type]
                if bank then
                    -- Calculate direction toward bank
                    local dx = bank.x - bit.x
                    local distance = math.abs(dx)
                    local direction = dx > 0 and 1 or -1
                    
                    -- Improved jumping physics
                    -- Jump toward bank with a distance-based velocity
                    local jump_strength = math.min(distance * 0.2, 200)
                    
                    bit.vx = direction * jump_strength
                    bit.vy = -250 -- Stronger upward velocity for a more pronounced jump
                    bit.grounded = false
                    bit.moving_to_bank = true -- Now we set this flag when clicked
                    
                    -- Visual feedback - console
                    print("Moving " .. bit.type .. " bit toward bank! Distance: " .. distance)
                else
                    -- Just give it a kick with improved physics
                    bit.vx = love.math.random(-100, 100)
                    bit.vy = -200 -- Upward velocity for jumping
                    bit.grounded = false
                end
                
                break
            end
        end
    end
    
    -- Check UI interactions (in screen space)
    ui.mousepressed(x, y, button, game)
end

function game.mousereleased(x, y, button)
    camera.mousereleased(x, y, button)
    ui.mousereleased(x, y, button)
end

function game.wheelmoved(x, y)
    -- Handle zooming with mouse wheel
    if y > 0 then
        camera.zoom(love.graphics.getWidth()/2, love.graphics.getHeight()/2, 1.1)
    elseif y < 0 then
        camera.zoom(love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0.9)
    end
end

function game.keypressed(key)
    -- Handle any game-specific key presses
    if key == "a" then
        local enabled = game.toggleAutoCollect()
        print("Auto-collection " .. (enabled and "enabled" or "disabled"))
    elseif key == "v" then
        local visible = game.toggleCollectRadiusVisibility()
        print("Collection radius " .. (visible and "visible" or "hidden"))
    end
end

-- Function to add a robot to the world
function game.addRobot(robot_type_key)
    local robot_type = robots.TYPES[robot_type_key or "GATHERER"]
    
    local robot = {
        x = love.math.random(-game.WORLD_WIDTH/2 + 200, game.WORLD_WIDTH/2 - 200),
        y = game.GROUND_LEVEL - 16,  -- Place on ground, adjusted for pixel art height
        size = 16,
        type = robot_type_key or "GATHERER", -- Store the type key
        state = "idle",
        cooldown = 0,
        target_x = 0,
        target_y = 0
    }
    
    table.insert(game.world_entities.robots, robot)
    return robot
end

-- Function to draw pixel art (similar to the one in robots.lua)
local function drawPixelArt(pixels, x, y, scale, color)
    scale = scale or 1
    color = color or {1, 1, 1}
    
    for row = 1, #pixels do
        for col = 1, #pixels[row] do
            if pixels[row][col] == 1 then
                love.graphics.setColor(color)
                love.graphics.rectangle("fill", 
                    x + (col-1) * scale, 
                    y + (row-1) * scale, 
                    scale, scale)
            end
        end
    end
end

-- Draw resource bits
function game.drawResourceBits()
    for i, bit in ipairs(game.resource_bits) do
        -- Use simple squares for powder-like appearance
        local color = {1, 1, 1} -- Default white color
        
        -- Add accent colors based on resource type
        if bit.type == "wood" then
            color = {0.8, 0.6, 0.4} -- Brown accent for wood
        elseif bit.type == "stone" then
            color = {0.7, 0.7, 0.7} -- Gray accent for stone
        elseif bit.type == "food" then
            color = {0.5, 0.8, 0.3} -- Green accent for food
        end
        
        -- Draw as a simple square for powder-like appearance
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", 
            bit.x - bit.size/2, 
            bit.y - bit.size/2, 
            bit.size, 
            bit.size)
    end
end

-- Create a resource bit when a resource is clicked
function game.createResourceBit(resource_type, x, y)
    -- Convert resource type to lowercase if needed
    resource_type = resource_type:lower()
    
    -- Create multiple bits
    for i = 1, 10 do -- More bits for a powder-like effect
        local bit = {
            x = x + love.math.random(-20, 20),
            y = y - love.math.random(5, 15), -- Start slightly above the resource
            type = resource_type,
            size = 4, -- Smaller size for powder-like appearance
            vx = love.math.random(-30, 30), -- Less horizontal velocity
            vy = -love.math.random(50, 100), -- Just a small initial upward velocity
            grounded = false, -- Whether the bit has landed on the ground
            colliding_with = nil, -- Track collisions with other bits
            moving_to_bank = false -- Don't automatically move to bank
        }
        table.insert(game.resource_bits, bit)
    end
    
    -- Visual feedback - particles
    if game.resource_particles[resource_type] then
        game.resource_particles[resource_type]:setPosition(x, y)
        game.resource_particles[resource_type]:emit(15)
    end
    
    -- Visual feedback - console
    print("Created " .. resource_type .. " bits!")
    
    -- Generate pollution
    resources.last_click_pollution = resources.TYPES[string.upper(resource_type)].pollution_per_click
    
    return true
end

-- Check for resource clicks
function game.checkResourceClicks(x, y)
    -- Use resources.lua's click function to handle resource clicking
    local pollution = resources.click(x, y, game.resources_collected, game.pollution_level, game.createResourceBit)
    
    if pollution > 0 then
        -- Handle pollution generation
        resources.last_click_pollution = pollution
        return true
    end
    
    return false
end

-- Draw resource banks
function game.drawResourceBanks()
    -- Draw resource banks
    for type, bank in pairs(game.resource_banks) do
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
        local amount = game.resources_collected[type] or 0
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

-- Initialize the game
function game.initialize()
    -- Initialize resources
    game.resources = {
        wood = {},
        stone = {},
        food = {}
    }
    
    -- Initialize resource bits
    game.resource_bits = {}
    
    -- Initialize robots
    game.robots = {}
    
    -- Initialize buildings
    game.buildings = {}
    
    -- Initialize resources collected
    game.resources_collected = {
        wood = 0,
        stone = 0,
        food = 0
    }
    
    -- Generate initial resources
    for i = 1, 10 do
        table.insert(game.resources.wood, {
            x = math.random(-game.WORLD_WIDTH/2, game.WORLD_WIDTH/2),
            y = game.GROUND_LEVEL - math.random(10, 30)
        })
        
        table.insert(game.resources.stone, {
            x = math.random(-game.WORLD_WIDTH/2, game.WORLD_WIDTH/2),
            y = game.GROUND_LEVEL - math.random(10, 30)
        })
        
        table.insert(game.resources.food, {
            x = math.random(-game.WORLD_WIDTH/2, game.WORLD_WIDTH/2),
            y = game.GROUND_LEVEL - math.random(10, 30)
        })
    end
end

-- Draw resource feedback (floating text)
function game.drawResourceFeedback()
    love.graphics.setColor(1, 1, 1)
    for _, feedback in ipairs(game.resource_feedback) do
        -- Calculate alpha based on remaining time
        local alpha = math.min(1, feedback.time)
        love.graphics.setColor(1, 1, 1, alpha)
        
        -- Draw the feedback text
        love.graphics.print("+" .. feedback.amount .. " " .. feedback.type, 
                           feedback.x - 20, feedback.y)
    end
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

-- Add this function to the game module near the end
function game.addCollectionAnimation(x, y, resource_type, amount)
    local colors = {
        wood = {0.6, 0.4, 0.2},
        stone = {0.7, 0.7, 0.7},
        food = {0.2, 0.8, 0.2}
    }
    
    -- Initialize collection_animations if it doesn't exist
    if not game.collection_animations then
        game.collection_animations = {}
    end
    
    table.insert(game.collection_animations, {
        x = x,
        y = y,
        text = "+" .. amount,
        color = colors[resource_type] or {1, 1, 1},
        lifetime = 0,
        max_lifetime = 1.5
    })
end

-- Function to toggle auto-collection
function game.toggleAutoCollect()
    game.auto_collect_enabled = not game.auto_collect_enabled
    return game.auto_collect_enabled
end

-- Function to toggle collection radius visualization
function game.toggleCollectRadiusVisibility()
    game.show_collect_radius = not game.show_collect_radius
    return game.show_collect_radius
end

-- Draw the auto-collection radius
function game.drawCollectionRadius()
    if not game.auto_collect_enabled or not game.show_collect_radius then
        return -- Don't draw if auto-collection is disabled or radius is hidden
    end
    
    -- Get camera position (center of screen)
    local cam_x, cam_y = camera.getPosition()
    
    -- Calculate pulse effect
    local base_alpha = 0.2
    local pulse_alpha = 0.1 * math.sin(game.radius_pulse)
    local alpha = base_alpha + pulse_alpha
    
    -- Enhance pulse effect if recently collected
    local time_since_collect = love.timer.getTime() - game.last_collect_time
    if time_since_collect < 0.5 then
        alpha = alpha + 0.3 * (1 - time_since_collect * 2)
    end
    
    -- Draw the radius circle
    love.graphics.setColor(0.2, 0.8, 0.2, alpha)
    love.graphics.circle("line", cam_x, cam_y, game.AUTO_COLLECT_RADIUS)
    
    -- Draw a slightly larger, more transparent circle for better visibility
    love.graphics.setColor(0.2, 0.8, 0.2, alpha * 0.5)
    love.graphics.circle("line", cam_x, cam_y, game.AUTO_COLLECT_RADIUS + 5)
    
    -- Draw a small indicator at the center
    love.graphics.setColor(0.2, 0.8, 0.2, alpha * 2)
    love.graphics.circle("fill", cam_x, cam_y, 5)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

-- Modify the collectResource function to not automatically set moving_to_bank
function game.collectResource(resource_type, amount, x, y)
    -- Get the bank for this resource type
    local bank = game.resource_banks[resource_type]
    local direction = 0
    
    if bank then
        -- Calculate direction toward bank
        local dx = bank.x - x
        direction = dx > 0 and 1 or -1
    end
    
    -- Generate resource bits
    for j = 1, amount * 5 do -- More bits for a powder-like effect
        -- Calculate initial velocity without bias toward bank
        local bit = {
            x = x + love.math.random(-20, 20),
            y = y - love.math.random(5, 15), -- Start slightly above the resource
            type = resource_type,
            size = 4, -- Smaller size for powder-like appearance
            vx = love.math.random(-30, 30), -- Less horizontal velocity
            vy = -love.math.random(50, 100), -- Just a small initial upward velocity
            grounded = false,
            colliding_with = nil, -- Track collisions with other bits
            moving_to_bank = false -- Don't automatically move to bank
        }
        table.insert(game.resource_bits, bit)
    end
    
    -- Visual feedback - particles
    if game.resource_particles[resource_type] then
        game.resource_particles[resource_type]:setPosition(x, y)
        game.resource_particles[resource_type]:emit(8) -- Fewer particles for auto-collection
    end
    
    return true
end

return game 