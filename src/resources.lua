-- project-clicker - Resources Module
-- Manages resources like wood, stone, food, etc.

local config = require("src.config")

local resources = {}
resources.last_click_pollution = nil  -- Track pollution from last click

-- Resource definitions with monochrome colors
resources.TYPES = {
    WOOD = {
        name = config.resources.types.wood.name,
        color = config.resources.types.wood.color,
        x = 100,
        y = 300,
        click_value = config.resources.types.wood.click_value,
        pollution_per_click = config.resources.types.wood.pollution_per_click,
        size = config.resources.types.wood.size
    },
    STONE = {
        name = config.resources.types.stone.name,
        color = config.resources.types.stone.color,
        x = 250, 
        y = 300,
        click_value = config.resources.types.stone.click_value,
        pollution_per_click = config.resources.types.stone.pollution_per_click,
        size = config.resources.types.stone.size
    },
    FOOD = {
        name = config.resources.types.food.name,
        color = config.resources.types.food.color,
        x = 400,
        y = 300,
        click_value = config.resources.types.food.click_value,
        pollution_per_click = config.resources.types.food.pollution_per_click,
        size = config.resources.types.food.size
    }
}

-- Resource particle system for click effects
local particles = {}

function resources.load()
    -- Initialize particle systems for resource clicking effects
    for _, resource in pairs(resources.TYPES) do
        local particle_system = love.graphics.newParticleSystem(
            love.graphics.newCanvas(4, 4), -- Small particle
            50 -- Max particles
        )
        
        particle_system:setParticleLifetime(0.5, 1.5)
        particle_system:setLinearAcceleration(-50, -100, 50, 0)
        particle_system:setColors(
            resource.color[1], resource.color[2], resource.color[3], 1,
            resource.color[1], resource.color[2], resource.color[3], 0
        )
        particle_system:setSizes(1, 0.5)
        
        particles[resource.name] = particle_system
    end
end

function resources.initialize()
    -- Starting resources
    return {
        Wood = 0,
        Stone = 0,
        Food = 0
    }
end

function resources.update(dt)
    -- Update particle systems
    for _, particle_system in pairs(particles) do
        particle_system:update(dt)
    end
end

function resources.draw()
    -- Draw resource nodes as squares
    for type, resource in pairs(resources.TYPES) do
        -- Draw resource node as a square
        love.graphics.setColor(resource.color)
        local half_size = resource.size / 2
        love.graphics.rectangle("fill", resource.x - half_size, resource.y - half_size, resource.size, resource.size)
        
        -- Draw resource label
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            resource.name, 
            resource.x - 40, 
            resource.y - 15, 
            80, 
            "center"
        )
    end
    
    -- Draw particle systems
    love.graphics.setColor(1, 1, 1)
    for _, particle_system in pairs(particles) do
        love.graphics.draw(particle_system)
    end
end

-- This function is now used to create resource bits rather than directly adding resources
function resources.click(x, y, resource_amounts, pollution_level, create_bits_callback)
    for type_key, resource in pairs(resources.TYPES) do
        -- Check if click is within resource square
        local half_size = resource.size / 2
        if x >= resource.x - half_size and x <= resource.x + half_size and
           y >= resource.y - half_size and y <= resource.y + half_size then
            
            -- Create particles at click position
            particles[resource.name]:setPosition(resource.x, resource.y)
            particles[resource.name]:emit(10)
            
            -- Call the callback to create resource bits if provided
            if create_bits_callback then
                -- Pass the lowercase resource type to match game.lua's expectations
                local resource_type = resource.name:lower()
                create_bits_callback(resource_type, resource.x, resource.y)
            end
            
            -- Return pollution generated
            return resource.pollution_per_click
        end
    end
    
    return 0 -- No pollution if no resource was clicked
end

-- Helper function to convert between resource.TYPES keys and game.resource_banks keys
function resources.getResourceType(resource_name)
    if type(resource_name) == "string" then
        return resource_name:lower()
    end
    return nil
end

return resources 