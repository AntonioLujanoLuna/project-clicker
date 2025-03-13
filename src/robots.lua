-- project-clicker - Robots Module
-- Manages robot creation and behavior

local config = require("src.config")
local log = require("src.log")
local events = require("src.events")

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

-- Robot instance list (kept for backward compatibility)
local robot_instances = {}

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

function robots.update(dt, resources, world_robots)
    -- Update all robot instances from the world
    for _, robot in ipairs(world_robots) do
        if robot.type == "GATHERER" then
            -- Implement state-based behavior
            if robot.state == "idle" then
                -- Find a resource to gather
                robot.state = "moving"
                -- Find nearest resource (this will be implemented in world module)
                events.trigger("robot_find_resource", robot)
                events.trigger("robot_state_changed", robot, "moving")
                log.debug("Robot " .. robot.type .. " is now moving to find resources")
            elseif robot.state == "moving" then
                -- Move towards target
                if robot.target_x and robot.target_y then
                    local dx = robot.target_x - robot.x
                    local dy = robot.target_y - robot.y
                    local distance = math.sqrt(dx*dx + dy*dy)
                    
                    if distance < 10 then
                        robot.state = "working"
                        robot.cooldown = 1 -- Start working timer
                        events.trigger("robot_state_changed", robot, "working")
                        log.debug("Robot " .. robot.type .. " has reached target and is now working")
                    else
                        -- Move towards target
                        local speed = 50 -- pixels per second
                        robot.x = robot.x + (dx/distance) * speed * dt
                        robot.y = robot.y + (dy/distance) * speed * dt
                    end
                else
                    -- No target, go back to idle
                    robot.state = "idle"
                    robot.cooldown = 0.5 -- Small cooldown before next task
                    events.trigger("robot_state_changed", robot, "idle")
                    log.debug("Robot " .. robot.type .. " has no target, returning to idle")
                end
            elseif robot.state == "working" then
                -- Perform work
                robot.cooldown = robot.cooldown - dt
                if robot.cooldown <= 0 then
                    -- Work complete, gather resource
                    local resource_type = "wood" -- Default to wood for GATHERER
                    
                    -- Trigger collection event
                    events.trigger("resource_collected", resource_type, 1, robot.x, robot.y)
                    
                    -- Return to idle
                    robot.state = "idle"
                    robot.cooldown = 0.5 -- Small cooldown before next task
                    events.trigger("robot_state_changed", robot, "idle")
                    log.debug("Robot " .. robot.type .. " completed work and collected " .. resource_type)
                end
            end
        elseif robot.type == "TRANSPORTER" then
            -- Transporter robots improve resource collection efficiency
            -- This is a passive effect, no need for state-based behavior
            -- The efficiency bonus is applied in the resource collection event handler
        elseif robot.type == "RECYCLER" then
            -- Recycler robots reduce pollution
            -- This is a passive effect, no need for state-based behavior
            -- The pollution reduction is applied in the pollution update function
        end
    end
    
    -- For backward compatibility, also update robot_instances
    for _, robot in ipairs(robot_instances) do
        if robot.type == "Gatherer" then
            -- Gatherer robots collect resources
            local resource_types = {"wood", "stone", "food"}
            local target_resource = resource_types[math.random(1, #resource_types)]
            
            -- Convert to lowercase to match resources_collected keys
            local resource_key = target_resource:lower()
            if not resources[resource_key] then resources[resource_key] = 0 end
            resources[resource_key] = resources[resource_key] + robot.gather_rate * dt
        end
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
        else
            -- Fallback to simple square if pixel art not available
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 
                robot.x - robot_type.width/2, 
                robot.y - robot_type.height/2, 
                robot_type.width, 
                robot_type.height)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 
                robot.x - robot_type.width/2, 
                robot.y - robot_type.height/2, 
                robot_type.width, 
                robot_type.height)
            
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

-- Build a new robot
function robots.build(robot_type, resources)
    if robots.canAfford(robot_type, resources) then
        -- Subtract cost (with safety check)
        for resource_name, amount in pairs(robot_type.cost) do
            -- Initialize the resource if it doesn't exist
            if resources[resource_name] == nil then
                resources[resource_name] = 0
            end
            -- Now safely subtract
            resources[resource_name] = resources[resource_name] - amount
        end
        
        -- Create new robot instance
        local new_robot = {
            type = robot_type.name,
            description = robot_type.description,
            gather_rate = robot_type.gather_rate,
            efficiency_bonus = robot_type.efficiency_bonus,
            pollution_reduction = robot_type.pollution_reduction,
            pollution = robot_type.pollution,
            color = robot_type.color,
            x = robot_type.x + math.random(-50, 50), -- Random position
            y = robot_type.y + math.random(-50, 50),
            width = robot_type.width,
            height = robot_type.height
        }
        
        table.insert(robot_instances, new_robot)
        return true
    end
    
    return false
end

-- Get total resource gather rate bonus from all transporter robots
function robots.getGatherBonus()
    local bonus = 1.0 -- Base multiplier (100%)
    
    for _, robot in ipairs(robot_instances) do
        if robot.type == "Transporter" and robot.efficiency_bonus then
            bonus = bonus + robot.efficiency_bonus
        end
    end
    
    return bonus
end

-- Get total pollution reduction from all recycler robots
function robots.getPollutionReduction()
    local reduction = 1.0 -- Base multiplier (100%)
    
    for _, robot in ipairs(robot_instances) do
        if robot.type == "Recycler" and robot.pollution_reduction then
            reduction = reduction - robot.pollution_reduction
        end
    end
    
    -- Minimum 10% pollution
    return math.max(0.1, reduction)
end

-- Calculate total pollution from all robots (per minute)
function robots.getTotalPollution()
    local total = 0
    for _, robot in ipairs(robot_instances) do
        total = total + robot.pollution
    end
    return total
end

return robots 