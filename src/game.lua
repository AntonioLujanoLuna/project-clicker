-- project-clicker - Game Module
-- Central coordinator for game systems and state

-- Import modules
local resources = require("src.resources")
local robots = require("src.robots")
local buildings = require("src.buildings")
local pollution = require("src.pollution")
local ui = require("src.ui")
local camera = require("src.camera")
local config = require("src.config")
local log = require("src.log")
local json = require("lib.json")
local utils = require("src.utils")
local bits = require("src.bits")
local audio = require("src.audio")
local world = require("src.world")
local input = require("src.input")
local tutorial = require("src.tutorial")
local events = require("src.events")  
local saveload = require("src.saveload")

local game = {}

-- Game state - minimized to focus on coordination rather than implementation
game.initialized = false
game.resources_collected = { wood = 0, stone = 0, food = 0 }
game.pollution_level = 0
game.research_points = 0
game.collection_animations = {}

-- Configuration constants (referenced from config to maintain compatibility)
game.WORLD_WIDTH = nil
game.WORLD_HEIGHT = nil
game.GROUND_LEVEL = nil
game.AUTO_COLLECT_RADIUS = nil
game.auto_collect_enabled = false
game.auto_collect_cooldown = 0
game.show_collect_radius = true
game.radius_pulse = 0
game.last_collect_time = 0

-- Save/load system
game.save_version = "0.1.0"
game.auto_save_interval = 300 -- 5 minutes in seconds
game.last_auto_save = 0

-- Resource particles for visual feedback
game.resource_particles = {}

-- Initialize the game
function game.load()
    log.info("Loading game module")
    
    -- Initialize configuration constants
    game.WORLD_WIDTH = config.world.width
    game.WORLD_HEIGHT = config.world.height
    game.GROUND_LEVEL = config.world.ground_height - config.world.height/2
    game.AUTO_COLLECT_RADIUS = config.collection.auto_collect_radius

    -- Load all modules
    world.load()
    resources.load()
    robots.load()
    buildings.load()
    pollution.load()
    ui.load()
    bits.load()
    tutorial.load()
    
    -- Set the ground level for the camera
    camera.load(game.WORLD_WIDTH, game.WORLD_HEIGHT)
    camera.setGroundLevel(game.GROUND_LEVEL)
    
    -- Initialize bits module
    bits.initPool()
    
    -- Associate callback functions
    resources.create_bits_callback = bits.createBitsFromResource
    
    -- Initialize resource particle systems
    game.initializeParticles()
    
    -- Generate initial world resources
    world.generateResources()
    
    -- Set up event handlers
    game.setupEventHandlers()
    
    game.initialized = true
    log.info("Game module loaded successfully")
end

-- Set up event handlers for game systems
function game.setupEventHandlers()
    -- Resource collection event
    events.on("resource_collected", function(resource_type, amount, x, y)
        -- Update resource count
        if not game.resources_collected[resource_type] then
            game.resources_collected[resource_type] = 0
        end
        game.resources_collected[resource_type] = game.resources_collected[resource_type] + amount
        
        -- Visual feedback
        game.addCollectionAnimation(x, y, resource_type, amount)
        
        -- Play sound
        audio.playSound("collect")
        
        -- Emit particles
        if game.resource_particles[resource_type] then
            game.resource_particles[resource_type]:setPosition(x, y)
            game.resource_particles[resource_type]:emit(15)
        end
        
        log.debug("Collected " .. amount .. " " .. resource_type)
    end)
    
    -- Resource depleted event
    events.on("resource_depleted", function(resource_type, x, y)
        -- Visual feedback
        if game.resource_particles[resource_type] then
            game.resource_particles[resource_type]:setPosition(x, y)
            game.resource_particles[resource_type]:emit(30) -- More particles for depletion
        end
        
        -- Play sound
        audio.playSound("depleted")
        
        log.debug(resource_type .. " resource depleted!")
    end)
    
    -- Auto-save event
    events.on("auto_save", function()
        local success, message = saveload.saveGame(game, world)
        if success then
            log.info("Auto-saved game.")
        else
            log.error("Auto-save failed: " .. message)
        end
    end)
    
    -- Pollution change event
    events.on("pollution_changed", function(new_level)
        game.pollution_level = new_level
    end)
    
    -- Research points earned event
    events.on("research_points_earned", function(amount)
        game.research_points = game.research_points + amount
    end)
    
    -- Robot creation event
    events.on("robot_created", function(robot_type_key)
        local robot = world.addRobot(robot_type_key, robots.TYPES)
        audio.playSound("robot_create")
        log.info("Robot created event handled: " .. robot_type_key)
    end)
    
    -- Robot state change event
    events.on("robot_state_changed", function(robot, new_state)
        log.debug("Robot " .. robot.type .. " changed state to: " .. new_state)
        -- Could trigger animations, sounds, etc.
        if new_state == "working" then
            audio.playSound("robot_work")
        elseif new_state == "idle" then
            -- Maybe play an idle sound
        end
    end)
    
    -- Building construction event
    events.on("building_constructed", function(building_type, x, y)
        -- Visual/audio feedback when building is constructed
        audio.playSound("build")
        log.info("Building constructed: " .. building_type .. " at position " .. x .. "," .. y)
    end)
    
    -- Building production event
    events.on("building_producing", function(building_type, resource_type, amount, x, y)
        -- Trigger when a building produces resources
        events.trigger("resource_collected", resource_type, amount, x, y)
        log.debug("Building " .. building_type .. " produced " .. amount .. " " .. resource_type)
    end)
    
    -- UI events
    events.on("ui_panel_opened", function(panel_name)
        log.debug("Panel opened: " .. panel_name)
        -- Could trigger tutorial steps, sounds, etc.
        audio.playSound("ui_open")
    end)
    
    events.on("ui_panel_closed", function(panel_name)
        log.debug("Panel closed: " .. panel_name)
        audio.playSound("ui_close")
    end)
    
    events.on("ui_button_clicked", function(button_name)
        log.debug("Button clicked: " .. button_name)
        audio.playSound("ui_click")
    end)
end

-- Create particle systems for visual feedback
function game.initializeParticles()
    local particle_img = love.graphics.newCanvas(4, 4)
    love.graphics.setCanvas(particle_img)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 4, 4)
    love.graphics.setCanvas()
    
    -- Create particle systems for each resource type
    local resource_colors = {
        wood = config.resources.types.wood.color,
        stone = config.resources.types.stone.color,
        food = config.resources.types.food.color
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
end

-- Core update loop
function game.update(dt)
    -- Update camera
    camera.update(dt)
    
    -- Update resource bits
    bits.update(dt, game.GROUND_LEVEL, world.resource_banks, game.resources_collected, game.addCollectionAnimation, game.resource_particles)
    
    -- Update modules using a more event-driven approach
    game.updateSystems(dt)
    
    -- Update resource particle systems
    for _, ps in pairs(game.resource_particles) do
        ps:update(dt)
    end
    
    -- Update collection animations
    game.updateCollectionAnimations(dt)
    
    -- Update radius pulse effect
    game.radius_pulse = game.radius_pulse + dt * 2
    if game.radius_pulse > math.pi * 2 then
        game.radius_pulse = 0
    end
    
    -- Auto-collection feature
    game.updateAutoCollection(dt)
    
    -- Auto-save
    game.updateAutoSave(dt)
    
    -- Update tutorial
    tutorial.update(dt)
end

-- Update all game systems
function game.updateSystems(dt)
    -- Update resources
    resources.update(dt)
    
    -- Update robots - pass world.entities.robots
    robots.update(dt, game.resources_collected, world.entities.robots)
    
    -- Update buildings
    buildings.update(dt, game.resources_collected)
    
    -- Update pollution level
    local new_pollution = pollution.update(dt, game.pollution_level, game.resources_collected, world.entities.buildings, world.entities.robots)
    if new_pollution and new_pollution ~= game.pollution_level then
        events.trigger("pollution_changed", new_pollution)
    end
    
    -- Generate research points over time (very slowly)
    local research_earned = 0.01 * dt
    events.trigger("research_points_earned", research_earned)
    
    -- Update UI
    ui.update(dt)
end

-- Update collection animations
function game.updateCollectionAnimations(dt)
    if game.collection_animations then
        for i = #game.collection_animations, 1, -1 do
            local anim = game.collection_animations[i]
            anim.lifetime = anim.lifetime + dt
            if anim.lifetime >= anim.max_lifetime then
                table.remove(game.collection_animations, i)
            end
        end
    else
        game.collection_animations = {}
    end
end

-- Update auto-save system
function game.updateAutoSave(dt)
    game.last_auto_save = game.last_auto_save + dt
    if game.last_auto_save >= game.auto_save_interval then
        events.trigger("auto_save")
        game.last_auto_save = 0
    end
end

-- Auto-collection update
function game.updateAutoCollection(dt)
    if game.auto_collect_enabled then
        -- Update cooldown
        if game.auto_collect_cooldown > 0 then
            game.auto_collect_cooldown = game.auto_collect_cooldown - dt
        else
            -- Get camera position (center of screen)
            local cam_x, cam_y = camera.getPosition()
            
            -- Check for resources within auto-collection radius
            for i, resource in ipairs(world.entities.resources) do
                local dx = resource.x - cam_x
                local dy = resource.y - cam_y
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance < game.AUTO_COLLECT_RADIUS then
                    -- Check if resource has bits remaining
                    if resource.current_bits and resource.current_bits > 0 then
                        -- Determine how many bits to collect (1 or resource.current_bits, whichever is smaller)
                        local bits_to_collect = math.min(1, resource.current_bits)
                        
                        -- Auto-collect this resource
                        game.collectResource(resource.type, bits_to_collect, resource.x, resource.y)
                        
                        -- Trigger resource collection event
                        events.trigger("resource_collected", resource.type, bits_to_collect, resource.x, resource.y)
                        
                        -- Reset cooldown (shorter for auto-collection)
                        game.auto_collect_cooldown = 1.5
                        
                        -- Update last collect time for pulse effect
                        game.last_collect_time = love.timer.getTime()
                        
                        -- If resource is depleted, remove it from the world
                        if resource.current_bits <= 0 then
                            -- Trigger resource depleted event
                            events.trigger("resource_depleted", resource.type, resource.x, resource.y)
                            
                            -- Remove the resource
                            table.remove(world.entities.resources, i)
                        end
                        
                        break -- Only collect one resource per cooldown
                    end
                end
            end
        end
    end
end

-- Draw game world and entities
function game.draw()
    -- Apply camera transformations
    camera.set()
    
    -- Draw world background
    world.drawBackground()
    
    -- Draw collection radius
    local cam_x, cam_y = camera.getPosition()
    world.drawCollectionRadius(game.auto_collect_enabled, game.show_collect_radius, 
                              game.AUTO_COLLECT_RADIUS, {x = cam_x, y = cam_y}, 
                              game.radius_pulse, game.last_collect_time)
    
    -- Draw resource banks
    world.drawResourceBanks(game.resources_collected)
    
    -- Draw resources (we're not tracking which resource is hovered directly anymore)
    world.drawResources(nil, game.auto_collect_enabled, game.AUTO_COLLECT_RADIUS,
                       game.show_collect_radius, {x = cam_x, y = cam_y}, 
                       game.resource_particles, game.radius_pulse)
    
    -- Draw resource bits
    bits.draw()
    
    -- Draw robots
    world.drawRobots()
    
    -- Draw buildings
    buildings.draw(world.entities.buildings)
    
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
    ui.draw(game.resources_collected, game.pollution_level, game.research_points)
    
    -- Draw tutorial overlay
    tutorial.draw()
end

-- Mouse press handling
function game.mousepressed(x, y, button)
    -- Pass to input module
    return input.mousepressed(x, y, button, world, camera, game, ui, tutorial)
end

-- Mouse release handling
function game.mousereleased(x, y, button)
    camera.mousereleased(x, y, button)
    ui.mousereleased(x, y, button)
end

-- Mouse wheel handling
function game.wheelmoved(x, y)
    input.wheelmoved(x, y, camera)
end


-- Add a robot to the world
function game.addRobot(robot_type_key)
    -- Trigger the robot_created event instead of directly calling world.addRobot
    events.trigger("robot_created", robot_type_key)
    -- We don't need to call world.addRobot here as it's handled by the event handler
    -- Return nil for now, we'll improve this in a future update
    return nil
end

-- Check for resource clicks
function game.checkResourceClicks(x, y)
    -- Convert world coordinates to screen coordinates if needed
    local screen_x, screen_y = x, y
    
    -- Check if these are world coordinates that need conversion
    if camera.isWorldCoordinate(x, y) then
        screen_x, screen_y = camera.worldToScreen(x, y)
    end
    
    -- Use resources.lua's click function to handle resource clicking
    local pollution = resources.click(screen_x, screen_y, game.resources_collected, game.pollution_level, bits.createBitsFromResource)
    
    if pollution > 0 then
        -- Handle pollution generation
        game.pollution_level = game.pollution_level + pollution
        return true
    end
    
    return false
end

-- Add collection animation
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

-- Collect resource and generate bits
function game.collectResource(resource_type, amount, x, y)
    -- Generate resource bits
    local created_bits = {}
    
    for j = 1, amount * 5 do -- More bits for a powder-like effect
        local bit = bits.getBitFromPool()
        if bit then
            bit.x = x + love.math.random(-20, 20)
            bit.y = y - love.math.random(5, 15) -- Start slightly above the resource
            bit.type = resource_type
            bit.size = 4 -- Smaller size for powder-like appearance
            bit.vx = love.math.random(-30, 30) -- Less horizontal velocity
            bit.vy = -love.math.random(50, 100) -- Just a small initial upward velocity
            bit.grounded = false
            bit.moving_to_bank = false -- Don't automatically move to bank
            bit.active = true
            bit.creation_time = love.timer.getTime()
            
            table.insert(created_bits, bit)
        end
    end
    
    return created_bits
end


return game