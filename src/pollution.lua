-- project-clicker - Pollution Module
-- Manages pollution levels and effects

local config = require("src.config")

local pollution = {}

-- Pollution constants
local MAX_POLLUTION = config.pollution.max_level
local NATURAL_RECOVERY = config.pollution.natural_recovery -- Natural pollution reduction per second

-- Monochrome pollution colors
pollution.COLORS = config.pollution.colors

function pollution.load()
    -- Load pollution assets if any
end

function pollution.initialize()
    -- Starting pollution level (0-100)
    return 0
end

function pollution.update(dt, current_level, resources, buildings, robots)
    if not current_level then
        current_level = 0
    end
    
    -- This would normally update pollution based on game activities
    -- For now, we'll just apply the natural recovery
    return math.max(0, current_level - NATURAL_RECOVERY * dt)
end

function pollution.draw(pollution_level, camera_x, camera_y, screen_width, screen_height)
    -- Visual representation of pollution in the world
    if not pollution_level or pollution_level <= 0 then
        return -- No pollution to draw
    end
    
    -- Determine pollution color based on level
    local color
    if pollution_level < config.pollution.effects.thresholds[1] then
        color = pollution.COLORS.LOW
    elseif pollution_level < config.pollution.effects.thresholds[2] then
        color = pollution.COLORS.MEDIUM
    else
        color = pollution.COLORS.HIGH
    end
    
    -- Save current color
    local r, g, b, a = love.graphics.getColor()
    
    -- Draw a semi-transparent overlay to represent pollution
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", camera_x, camera_y, screen_width, screen_height)
    
    -- Restore previous color
    love.graphics.setColor(r, g, b, a)
end

-- Add pollution to the world (called when activities generate pollution)
function pollution.generate(amount, current_level)
    if not current_level then
        current_level = 0
    end
    if not amount then
        amount = 0
    end
    
    local new_level = current_level + amount
    return math.min(MAX_POLLUTION, new_level)
end

-- Check if pollution effects should be applied
function pollution.getEffects(pollution_level)
    if not pollution_level then
        pollution_level = 0
    end
    
    local effects = {
        resource_penalty = 0,
        robot_penalty = 0
    }
    
    -- Calculate penalties based on pollution levels
    if pollution_level > config.pollution.effects.thresholds[1] then
        effects.resource_penalty = config.pollution.effects.resource_penalties[1]
    end
    
    if pollution_level > config.pollution.effects.thresholds[2] then
        effects.resource_penalty = config.pollution.effects.resource_penalties[2]
        effects.robot_penalty = config.pollution.effects.robot_penalties[2]
    end
    
    if pollution_level > config.pollution.effects.thresholds[3] then
        effects.resource_penalty = config.pollution.effects.resource_penalties[3]
        effects.robot_penalty = config.pollution.effects.robot_penalties[3]
    end
    
    return effects
end

return pollution 