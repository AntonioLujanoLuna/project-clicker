-- project-clicker - Buildings Module
-- Manages construction and production of buildings

local buildings = {}

-- Building definitions with monochrome colors
buildings.TYPES = {
    LUMBER_MILL = {
        name = "Lumber Mill",
        description = "Automatically produces wood over time",
        cost = {Wood = 50, Stone = 25},
        production = {Wood = 0.5}, -- Resources per second
        pollution = 5,             -- Pollution per minute
        icon_color = {1, 1, 1}, -- White
        x = 100,
        y = 400,
        width = 16,
        height = 16,
        pixels = {
            {0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0},
            {0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0},
            {0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,0,1,1,0,0,1,1,0,1,1,1,1,1},
            {1,1,0,0,1,1,0,0,1,1,0,0,1,1,1,1},
            {1,0,0,0,1,1,0,0,1,1,0,0,0,1,1,1},
            {0,0,0,0,1,1,0,0,1,1,0,0,0,0,1,1}
        },
        accent_color = {0.8, 0.6, 0.4} -- Wood accent
    },
    QUARRY = {
        name = "Quarry",
        description = "Automatically produces stone over time",
        cost = {Wood = 40, Stone = 40},
        production = {Stone = 0.4},
        pollution = 7,
        icon_color = {1, 1, 1}, -- White
        x = 200, 
        y = 400,
        width = 16,
        height = 16,
        pixels = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
        },
        accent_color = {0.7, 0.7, 0.7} -- Stone accent
    },
    FARM = {
        name = "Farm",
        description = "Automatically produces food over time",
        cost = {Wood = 30, Stone = 20},
        production = {Food = 0.3},
        pollution = 2,
        icon_color = {1, 1, 1}, -- White
        x = 300,
        y = 400,
        width = 16,
        height = 16,
        pixels = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0},
            {0,0,0,0,1,1,0,1,1,0,1,1,0,0,0,0},
            {0,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
        },
        accent_color = {0, 1, 0} -- Green accent for crops
    },
    SOLAR_PANEL = {
        name = "Solar Panel",
        description = "Reduces pollution over time",
        cost = {Wood = 20, Stone = 50},
        production = {},
        pollution = -10, -- Negative value means it reduces pollution
        icon_color = {1, 1, 1}, -- White
        x = 400,
        y = 400,
        width = 16,
        height = 16,
        pixels = {
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
            {0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
            {0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0},
            {0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0},
            {0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0},
            {0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0}
        },
        accent_color = {0.2, 0.6, 1} -- Blue accent for solar
    }
}

-- Building instance list
local building_instances = {}

-- Function to draw a pixel art building (similar to robot drawing function)
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

function buildings.load()
    -- Load building assets if any
    
    -- Add accent colors to the pixel art
    for type_key, building_type in pairs(buildings.TYPES) do
        -- Add accent colors to specific parts of the buildings
        if type_key == "LUMBER_MILL" then
            -- Add wood accent to lumber mill
            building_type.pixels[13][3] = 2
            building_type.pixels[13][4] = 2
            building_type.pixels[14][3] = 2
            building_type.pixels[14][4] = 2
            building_type.pixels[15][3] = 2
            building_type.pixels[15][4] = 2
        elseif type_key == "FARM" then
            -- Add green accent to farm (crops)
            building_type.pixels[7][5] = 2
            building_type.pixels[7][8] = 2
            building_type.pixels[7][11] = 2
            building_type.pixels[8][5] = 2
            building_type.pixels[8][8] = 2
            building_type.pixels[8][11] = 2
        elseif type_key == "SOLAR_PANEL" then
            -- Add blue accent to solar panel
            building_type.pixels[8][8] = 2
            building_type.pixels[8][9] = 2
            building_type.pixels[9][8] = 2
            building_type.pixels[9][9] = 2
            building_type.pixels[10][8] = 2
            building_type.pixels[10][9] = 2
        end
    end
end

function buildings.update(dt, resources)
    -- Update all building instances
    for _, building in ipairs(building_instances) do
        -- Add resources based on production rate
        for resource_name, amount_per_second in pairs(building.production) do
            resources[resource_name] = resources[resource_name] + amount_per_second * dt
        end
    end
end

function buildings.draw(building_list)
    -- Draw each building
    for _, building in pairs(building_list) do
        -- Get building type info
        local building_type = buildings.TYPES[building.type]
        
        if building_type and building_type.pixels then
            -- Draw building as pixel art
            local scale = 2 -- Scale up the pixel art for better visibility
            local x_offset = building.x - (building_type.width * scale) / 2
            local y_offset = building.y - (building_type.height * scale) / 2
            
            drawPixelArt(
                building_type.pixels, 
                x_offset, 
                y_offset, 
                scale, 
                {1, 1, 1}, -- Main color (white)
                building_type.accent_color -- Accent color specific to building type
            )
            
            -- Draw building name above it
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(
                building_type.name,
                building.x - 50, 
                building.y - (building_type.height * scale) - 15, 
                100, 
                "center"
            )
        else
            -- Fallback to simple rectangle if pixel art not available
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 
                building.x - building_type.width/2, 
                building.y - building_type.height/2, 
                building_type.width, 
                building_type.height)
            
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", 
                building.x - building_type.width/2, 
                building.y - building_type.height/2, 
                building_type.width, 
                building_type.height)
            
            -- Draw building name
            love.graphics.printf(
                building_type.name,
                building.x - 50, 
                building.y - building_type.height - 15, 
                100, 
                "center"
            )
        end
    end
end

-- Check if player has enough resources to build
function buildings.canAfford(building_type, resources)
    for resource_name, amount in pairs(building_type.cost) do
        if resources[resource_name] < amount then
            return false
        end
    end
    return true
end

-- Build a new building
function buildings.build(building_type, resources)
    if buildings.canAfford(building_type, resources) then
        -- Subtract cost
        for resource_name, amount in pairs(building_type.cost) do
            resources[resource_name] = resources[resource_name] - amount
        end
        
        -- Create new building instance
        local new_building = {
            type = building_type.name:gsub(" ", "_"):upper(), -- Convert name to type key
            name = building_type.name,
            description = building_type.description,
            production = building_type.production,
            pollution = building_type.pollution,
            icon_color = building_type.icon_color,
            x = love.math.random(-game.WORLD_WIDTH/2 + 200, game.WORLD_WIDTH/2 - 200), -- Random position
            y = game.GROUND_LEVEL - 16, -- Place on ground
            width = building_type.width,
            height = building_type.height
        }
        
        table.insert(building_instances, new_building)
        return true
    end
    
    return false
end

-- Calculate total pollution from all buildings (per minute)
function buildings.getTotalPollution()
    local total = 0
    for _, building in ipairs(building_instances) do
        total = total + building.pollution
    end
    return total
end

return buildings 