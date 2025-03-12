-- project-clicker - Robots Module
-- Manages robot creation and behavior

local config = require("src.config")

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

-- Robot instance list
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

function robots.update(dt, resources)
    -- Update all robot instances
    for _, robot in ipairs(robot_instances) do
        if robot.type == "Gatherer" then
            -- Gatherer robots collect resources
            local resource_types = {"Wood", "Stone", "Food"}
            local target_resource = resource_types[math.random(1, #resource_types)]
            
            resources[target_resource] = resources[target_resource] + robot.gather_rate * dt
        end
        
        -- Other robot types have passive effects (handled elsewhere)
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