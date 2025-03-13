-- project-clicker - Robots Module
-- Manages robot creation and behavior

local config = require("src.config")
local log = require("src.log")
local events = require("src.events")
local audio = require("src.audio")
local bits = require("src.bits")
local world = require("src.world")

local robots = {}

-- Robot type definitions with monochrome colors
robots.TYPES = {
    GATHERER = {
        name = config.robots.types.GATHERER.name,
        description = config.robots.types.GATHERER.description,
        cost = config.robots.types.GATHERER.cost,
        gather_rate = config.robots.types.GATHERER.gather_rate,
        pollution = config.robots.types.GATHERER.pollution,
        color = {1, 1, 1}, -- White
        x = 500,
        y = 400,
        width = config.robots.types.GATHERER.size,
        height = config.robots.types.GATHERER.size,
        pixels = {
            {0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {1,1,1,1,0,0,1,1,0,0,1,1,1,1,0,0},
            {1,1,1,1,0,0,1,1,0,0,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0},
            {0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0},
            {0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0},
            {0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0},
            {0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0}
        },
        accent_color = {0, 0.7, 1} -- Light blue accent for gatherer
    },
    TRANSPORTER = {
        name = config.robots.types.TRANSPORTER.name,
        description = config.robots.types.TRANSPORTER.description,
        cost = config.robots.types.TRANSPORTER.cost,
        efficiency_bonus = config.robots.types.TRANSPORTER.efficiency_bonus,
        pollution = config.robots.types.TRANSPORTER.pollution,
        color = {1, 1, 1}, -- White
        x = 550, 
        y = 400,
        width = config.robots.types.TRANSPORTER.size,
        height = config.robots.types.TRANSPORTER.size,
        pixels = {
            {0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0},
            {0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {1,1,1,1,0,0,1,1,0,0,1,1,1,1,0,0},
            {1,1,1,1,0,0,1,1,0,0,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0},
            {0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0},
            {0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0},
            {0,0,0,1,1,1,0,0,1,1,1,0,0,0,0,0},
            {0,0,1,1,1,0,0,0,0,1,1,1,0,0,0,0}
        },
        accent_color = {0, 1, 0} -- Green accent for transporter
    },
    RECYCLER = {
        name = config.robots.types.RECYCLER.name,
        description = config.robots.types.RECYCLER.description,
        cost = config.robots.types.RECYCLER.cost,
        pollution_reduction = config.robots.types.RECYCLER.pollution_reduction,
        pollution = config.robots.types.RECYCLER.pollution,
        color = {1, 1, 1}, -- White
        x = 600,
        y = 400,
        width = config.robots.types.RECYCLER.size,
        height = config.robots.types.RECYCLER.size,
        pixels = {
            {0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {1,1,1,1,0,0,1,1,0,0,1,1,1,1,0,0},
            {1,1,1,1,0,0,1,1,0,0,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0},
            {0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0},
            {0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0},
            {0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0},
            {0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0}
        },
        accent_color = {1, 0, 0} -- Red accent for recycler
    }
}

-- Function to draw a pixel art robot
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

function robots.load()
    -- Load robot assets if any
    
    -- Add accent colors to the pixel art
    for type_key, robot_type in pairs(robots.TYPES) do
        -- Add accent colors to specific parts of the robot
        if type_key == "GATHERER" then
            -- Add blue accent to gatherer (tool)
            robot_type.pixels[5][3] = 2
            robot_type.pixels[6][3] = 2
            robot_type.pixels[7][3] = 2
            robot_type.pixels[8][3] = 2
        elseif type_key == "TRANSPORTER" then
            -- Add green accent to transporter (arrow)
            robot_type.pixels[14][4] = 2
            robot_type.pixels[14][5] = 2
            robot_type.pixels[14][6] = 2
            robot_type.pixels[15][5] = 2
            robot_type.pixels[15][6] = 2
            robot_type.pixels[15][7] = 2
        elseif type_key == "RECYCLER" then
            -- Add red accent to recycler (recycling symbol)
            robot_type.pixels[13][5] = 2
            robot_type.pixels[13][6] = 2
            robot_type.pixels[14][6] = 2
            robot_type.pixels[14][7] = 2
            robot_type.pixels[15][7] = 2
            robot_type.pixels[15][8] = 2
        end
    end
end

-- Helper function to find the nearest resource of a given type
local function findNearestResource(world_resources, x, y, resource_type)
    local nearest_resource = nil
    local nearest_distance = math.huge
    local nearest_index = nil
    
    for i, resource in ipairs(world_resources) do
        -- Skip resources with no bits left
        if resource.current_bits and resource.current_bits > 0 then
            -- If resource_type is nil, find any type, otherwise match the specified type
            if resource_type == nil or resource.type == resource_type then
                local dx = resource.x - x
                local dy = resource.y - y
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance < nearest_distance then
                    nearest_resource = resource
                    nearest_distance = distance
                    nearest_index = i
                end
            end
        end
    end
    
    return nearest_resource, nearest_index, nearest_distance
end

-- Helper function to find the nearest resource bit of a given type
local function findNearestBit(resource_bits, x, y, bit_type)
    local nearest_bit = nil
    local nearest_distance = math.huge
    local nearest_index = nil
    
    for i, bit in ipairs(resource_bits) do
        if bit.active and not bit.moving_to_bank and (bit_type == nil or bit.type == bit_type) then
            local dx = bit.x - x
            local dy = bit.y - y
            local distance = math.sqrt(dx*dx + dy*dy)
            
            if distance < nearest_distance then
                nearest_bit = bit
                nearest_distance = distance
                nearest_index = i
            end
        end
    end
    
    return nearest_bit, nearest_index, nearest_distance
end

function robots.update(dt, resources, world_robots)
    -- Update all robot instances from the world
    for i, robot in ipairs(world_robots) do
        -- Update robot cooldown if it exists
        if robot.cooldown then
            robot.cooldown = math.max(0, robot.cooldown - dt)
        else
            robot.cooldown = 0
        end
        
        -- Different behavior based on robot type
        if robot.type == "GATHERER" then
            -- GATHERER BEHAVIOR
            -- States: idle (looking for resource) -> moving (going to resource) -> clicking (generating bits)
            
            if robot.state == "idle" and robot.cooldown <= 0 then
                -- Find a resource to gather
                local resource, resource_index = findNearestResource(world.entities.resources, robot.x, robot.y)
                
                if resource then
                    -- Found a resource, let's move to it
                    robot.target_resource = resource_index
                    robot.target_x = resource.x
                    robot.target_y = resource.y
                    robot.state = "moving"
                    events.trigger("robot_state_changed", robot, "moving")
                    log.debug("Gatherer found resource at " .. resource.x .. "," .. resource.y)
                else
                    -- No resources found, wait a bit before trying again
                    robot.cooldown = 1.0
                end
            elseif robot.state == "moving" then
                -- Move towards target resource
                if robot.target_x and robot.target_y then
                    local dx = robot.target_x - robot.x
                    local dy = robot.target_y - robot.y
                    local distance = math.sqrt(dx*dx + dy*dy)
                    
                    if distance < 10 then
                        -- Reached the resource, start clicking
                        robot.state = "clicking"
                        robot.cooldown = 0.5 -- Time to perform click
                        events.trigger("robot_state_changed", robot, "clicking")
                        log.debug("Gatherer reached resource, starting to click")
                    else
                        -- Move towards target
                        local speed = 50 -- pixels per second
                        robot.x = robot.x + (dx/distance) * speed * dt
                        robot.y = robot.y + (dy/distance) * speed * dt
                    end
                else
                    -- No target, go back to idle
                    robot.state = "idle"
                    robot.cooldown = 0.5
                    events.trigger("robot_state_changed", robot, "idle")
                    log.debug("Gatherer lost target, returning to idle")
                end
            elseif robot.state == "clicking" and robot.cooldown <= 0 then
                -- Resource clicking action
                local resource = world.entities.resources[robot.target_resource]
                
                if resource and resource.current_bits and resource.current_bits > 0 then
                    -- Generate resource bits like a player click
                    local bits_to_generate = math.min(5, resource.current_bits) -- Gatherers generate fewer bits than players
                    local created_bits = bits.createBitsFromResource(resource, bits_to_generate, world.GROUND_LEVEL)
                    
                    -- Update the resource's bit count
                    world.updateResource(robot.target_resource, bits_to_generate)
                    
                    -- Play click sound
                    audio.playSound("click")
                    
                    log.debug("Gatherer clicked resource and generated " .. #created_bits .. " bits")
                end
                
                -- Return to idle state to find next resource
                robot.state = "idle"
                robot.cooldown = 1.0 -- Cooldown before next action
                robot.target_resource = nil
                events.trigger("robot_state_changed", robot, "idle")
            end
            
        elseif robot.type == "TRANSPORTER" then
            -- TRANSPORTER BEHAVIOR
            -- States: idle (looking for bits) -> moving_to_bit (going to bit) -> 
            --         carrying (carrying bit to bank) -> depositing (at bank)
            
            if robot.state == "idle" and robot.cooldown <= 0 then
                -- Find resource bits to transport (any type for now)
                local bit, bit_index = findNearestBit(bits.resource_bits, robot.x, robot.y)
                
                if bit then
                    -- Found a bit, let's move to it
                    robot.target_bit_index = bit_index
                    robot.target_bit = bit
                    robot.target_x = bit.x
                    robot.target_y = bit.y
                    robot.state = "moving_to_bit"
                    events.trigger("robot_state_changed", robot, "moving_to_bit")
                    log.debug("Transporter found bit at " .. bit.x .. "," .. bit.y)
                else
                    -- No bits found, wait a bit before trying again
                    robot.cooldown = 1.0
                end
            elseif robot.state == "moving_to_bit" then
                -- Check if the target bit still exists and is valid
                if not robot.target_bit or not robot.target_bit.active or robot.target_bit.moving_to_bank then
                    -- Bit is no longer valid, return to idle
                    robot.state = "idle"
                    robot.cooldown = 0.5
                    events.trigger("robot_state_changed", robot, "idle")
                    log.debug("Transporter's target bit is no longer valid")
                    goto continue
                end
                
                -- Update target position as the bit might be moving
                robot.target_x = robot.target_bit.x
                robot.target_y = robot.target_bit.y
                
                -- Move towards target bit
                local dx = robot.target_x - robot.x
                local dy = robot.target_y - robot.y
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance < 10 then
                    -- Reached the bit, pick it up
                    robot.state = "carrying"
                    robot.carried_bit = robot.target_bit
                    robot.carried_bit.moving_to_bank = true
                    
                    -- Set target to the appropriate bank
                    local bank = world.resource_banks[robot.carried_bit.type]
                    if bank then
                        robot.target_x = bank.x
                        robot.target_y = bank.y
                        events.trigger("robot_state_changed", robot, "carrying")
                        log.debug("Transporter picked up bit and is heading to bank")
                    else
                        -- No bank found for this bit type, drop it
                        robot.carried_bit.moving_to_bank = false
                        robot.state = "idle"
                        robot.cooldown = 0.5
                        events.trigger("robot_state_changed", robot, "idle")
                        log.debug("Transporter couldn't find bank for bit type " .. robot.carried_bit.type)
                    end
                else
                    -- Move towards bit
                    local speed = 70 -- pixels per second, transporters are faster
                    robot.x = robot.x + (dx/distance) * speed * dt
                    robot.y = robot.y + (dy/distance) * speed * dt
                end
            elseif robot.state == "carrying" then
                -- Check if we still have a valid carried bit
                if not robot.carried_bit or not robot.carried_bit.active then
                    -- Bit is no longer valid, return to idle
                    robot.state = "idle"
                    robot.cooldown = 0.5
                    events.trigger("robot_state_changed", robot, "idle")
                    log.debug("Transporter's carried bit is no longer valid")
                    goto continue
                end
                
                -- Move towards resource bank
                local dx = robot.target_x - robot.x
                local dy = robot.target_y - robot.y
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance < 15 then
                    -- Reached the bank, deposit the bit
                    robot.state = "depositing"
                    robot.cooldown = 0.3
                    events.trigger("robot_state_changed", robot, "depositing")
                    log.debug("Transporter reached bank, depositing bit")
                else
                    -- Move towards bank
                    local speed = 70 -- pixels per second
                    robot.x = robot.x + (dx/distance) * speed * dt
                    robot.y = robot.y + (dy/distance) * speed * dt
                    
                    -- Move the carried bit with the robot
                    robot.carried_bit.x = robot.x
                    robot.carried_bit.y = robot.y - 10 -- Position bit slightly above robot
                end
            elseif robot.state == "depositing" and robot.cooldown <= 0 then
                -- Add resource to collection
                if robot.carried_bit and robot.carried_bit.active and robot.carried_bit.type then
                    resources[robot.carried_bit.type] = resources[robot.carried_bit.type] or 0
                    resources[robot.carried_bit.type] = resources[robot.carried_bit.type] + 1
                    
                    -- Play collection sound
                    audio.playSound("collect")
                    
                    -- Create a collection animation
                    events.trigger("resource_collected", robot.carried_bit.type, 1, robot.x, robot.y)
                    
                    -- Remove the bit from the world
                    for i, bit in ipairs(bits.resource_bits) do
                        if bit == robot.carried_bit then
                            bits.releaseBitToPool(bit)
                            table.remove(bits.resource_bits, i)
                            break
                        end
                    end
                    
                    log.debug("Transporter deposited bit of type " .. robot.carried_bit.type)
                end
                
                -- Return to idle
                robot.carried_bit = nil
                robot.state = "idle"
                robot.cooldown = 0.5 -- Short cooldown before finding next bit
                events.trigger("robot_state_changed", robot, "idle")
            end
            
        elseif robot.type == "RECYCLER" then
            -- RECYCLER BEHAVIOR
            -- States: idle -> roaming (moving randomly) -> recycling (reducing pollution)
            
            if robot.state == "idle" and robot.cooldown <= 0 then
                -- Choose a random location to roam to
                robot.target_x = robot.x + love.math.random(-100, 100)
                robot.target_y = world.GROUND_LEVEL - love.math.random(5, 15)
                robot.state = "roaming"
                robot.cooldown = love.math.random(2, 5) -- Random roam time
                events.trigger("robot_state_changed", robot, "roaming")
                log.debug("Recycler started roaming to " .. robot.target_x .. "," .. robot.target_y)
            elseif robot.state == "roaming" then
                -- Move towards target location
                local dx = robot.target_x - robot.x
                local dy = robot.target_y - robot.y
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance < 10 or robot.cooldown <= 0 then
                    -- Reached target or roam time expired, start recycling
                    robot.state = "recycling"
                    robot.cooldown = love.math.random(3, 6) -- Random recycling time
                    events.trigger("robot_state_changed", robot, "recycling")
                    log.debug("Recycler started recycling")
                else
                    -- Move towards target
                    local speed = 30 -- pixels per second, recyclers are slower
                    robot.x = robot.x + (dx/distance) * speed * dt
                    robot.y = robot.y + (dy/distance) * speed * dt
                    robot.cooldown = robot.cooldown - dt
                end
            elseif robot.state == "recycling" then
                -- Actively reduce pollution while recycling
                -- This is handled in the pollution module based on number of recyclers
                
                -- Visual effect for recycling - could add particle effects here
                
                robot.cooldown = robot.cooldown - dt
                if robot.cooldown <= 0 then
                    -- Recycling complete, return to idle
                    robot.state = "idle"
                    robot.cooldown = 1.0
                    events.trigger("robot_state_changed", robot, "idle")
                    log.debug("Recycler finished recycling")
                end
            end
        end
        
        ::continue::
    end
end

function robots.draw(robot_list)
    -- Draw each robot
    for _, robot in pairs(robot_list) do
        -- Get robot type info
        local robot_type = robots.TYPES[robot.type]
        
        if robot_type and robot_type.pixels then
            -- Draw robot as pixel art
            local scale = 2 -- Scale up the pixel art for better visibility
            local x_offset = robot.x - (robot_type.width * scale) / 2
            local y_offset = robot.y - (robot_type.height * scale) / 2
            
            drawPixelArt(
                robot_type.pixels, 
                x_offset, 
                y_offset, 
                scale, 
                {1, 1, 1}, -- Main color (white)
                robot_type.accent_color -- Accent color specific to robot type
            )
            
            -- Draw current state above the robot
            love.graphics.setColor(1, 1, 1, 0.8)
            love.graphics.printf(
                robot.state or "idle",
                robot.x - 30, 
                robot.y - robot_type.height * scale - 15, 
                60, 
                "center"
            )
            
            -- Draw carrying indicator for transporters carrying bits
            if robot.type == "TRANSPORTER" and robot.state == "carrying" and robot.carried_bit then
                love.graphics.setColor(0.8, 0.8, 0.2)
                love.graphics.circle("fill", robot.x, robot.y - 20, 3)
            end
        else
            -- Fallback to simple square if pixel art not available
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 
                robot.x - robot_type.width/2, 
                robot.y - robot_type.height/2, 
                robot_type.width, robot_type.height)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 
                robot.x - robot_type.width/2, 
                robot.y - robot_type.height/2, 
                robot_type.width, robot_type.height)
            
            -- Draw robot type indicator
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(
                robot_type.name:sub(1, 1),
                robot.x - robot_type.width/2, 
                robot.y - 8, 
                robot_type.width, 
                "center"
            )
        end
    end
end

-- Check if player has enough resources to build a robot
function robots.canAfford(robot_type, resources)
    for resource_name, amount in pairs(robot_type.cost) do
        -- Make sure the resource exists in the resources table
        local available = resources[resource_name] or 0
        -- Now we can safely compare
        if available < amount then
            return false
        end
    end
    return true
end

-- Get total pollution reduction from all recycler robots
function robots.getPollutionReduction(world_robots)
    local reduction = 0
    
    for _, robot in ipairs(world_robots) do
        if robot.type == "RECYCLER" and robot.state == "recycling" then
            -- Each actively recycling robot reduces pollution by its reduction rate
            reduction = reduction + config.robots.types.RECYCLER.pollution_reduction
        end
    end
    
    return reduction
end

-- Calculate total pollution from all robots (per minute)
function robots.getTotalPollution(world_robots)
    local total = 0
    for _, robot in ipairs(world_robots) do
        total = total + robots.TYPES[robot.type].pollution
    end
    return total
end

return robots