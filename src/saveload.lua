-- project-clicker - Save/Load Module
-- Manages saving and loading game state

local json = require("lib.json")
local log = require("src.log")

local saveload = {}

-- Save version for compatibility checks
saveload.version = "0.1.0"

-- Save game state to a file
function saveload.saveGame(game, world)
    log.info("Saving game state...")
    
    -- Create a save data structure
    local save_data = {
        version = saveload.version,
        timestamp = os.time(),
        resources_collected = game.resources_collected,
        pollution_level = game.pollution_level,
        research_points = game.research_points,
        -- Serialize only necessary properties of each entity
        buildings = {},
        robots = {}
    }
    
    -- Add buildings data
    for i, building in ipairs(game.buildings) do
        table.insert(save_data.buildings, {
            type = building.type,
            x = building.x,
            y = building.y
        })
    end
    
    -- Add robots data
    for i, robot in ipairs(world.entities.robots) do
        table.insert(save_data.robots, {
            type = robot.type,
            x = robot.x,
            y = robot.y,
            state = robot.state
        })
    end
    
    -- Add resources data
    save_data.resources = {}
    for i, resource in ipairs(world.entities.resources) do
        table.insert(save_data.resources, {
            type = resource.type,
            x = resource.x,
            y = resource.y,
            current_bits = resource.current_bits,
            max_bits = resource.max_bits
        })
    end
    
    -- Write to file
    local success, message = pcall(function()
        love.filesystem.write("save.json", json.encode(save_data))
    end)
    
    if success then
        log.info("Game saved successfully")
    else
        log.error("Failed to save game: " .. tostring(message))
    end
    
    return success, message
end

-- Load game state from a file
function saveload.loadGame(game, world, bits, robots_config)
    log.info("Loading game state...")
    
    if not love.filesystem.getInfo("save.json") then
        log.warning("No save file found")
        return false, "No save file found."
    end
    
    local success, data = pcall(function()
        local contents = love.filesystem.read("save.json")
        return json.decode(contents)
    end)
    
    if not success then
        log.error("Failed to load save file: " .. tostring(data))
        return false, "Corrupted save file."
    end
    
    -- Check version compatibility
    if data.version ~= saveload.version then
        log.warning("Save version mismatch: " .. data.version .. " vs " .. saveload.version)
        -- For now, we'll still try to load it
    end
    
    -- Reset game state
    game.buildings = {}
    world.entities.robots = {}
    world.entities.resources = {}
    
    -- Clear resource bits
    bits.clearAll()
    
    -- Load resources
    game.resources_collected = data.resources_collected
    game.pollution_level = data.pollution_level
    game.research_points = data.research_points
    
    -- Load buildings
    for _, building_data in ipairs(data.buildings) do
        local building = {
            type = building_data.type,
            x = building_data.x,
            y = building_data.y
        }
        table.insert(game.buildings, building)
    end
    
    -- Load robots
    for _, robot_data in ipairs(data.robots) do
        local robot = {
            type = robot_data.type,
            x = robot_data.x,
            y = robot_data.y,
            state = robot_data.state or "idle",
            size = robots_config[robot_data.type].size,
            cooldown = 0
        }
        table.insert(world.entities.robots, robot)
    end
    
    -- Load resources
    if data.resources then
        for _, resource_data in ipairs(data.resources) do
            local resource = {
                type = resource_data.type,
                x = resource_data.x,
                y = resource_data.y,
                current_bits = resource_data.current_bits,
                max_bits = resource_data.max_bits
            }
            table.insert(world.entities.resources, resource)
        end
    else
        -- If no resources in save, regenerate them
        world.generateResources()
    end
    
    log.info("Game loaded successfully")
    return true, "Game loaded successfully."
end

return saveload