-- project-clicker - Resource Bits Module
-- Manages resource bits physics, collision, and rendering

local config = require("src.config")
local log = require("src.log")

local bits = {}

-- Resource bits on the ground
bits.resource_bits = {}

-- Object pooling for resource bits
bits.bit_pool = {}
bits.pool_size = 1000

-- Grid-based spatial partitioning for collision detection
bits.grid = {}
bits.cell_size = 20 -- Size of each grid cell

-- Pixel art for resource bits
bits.resource_bit_pixels = {
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

-- Load function to initialize the bits module
function bits.load()
    log.info("Loading bits module")
    -- We'll call initPool in game.lua after this, so we can leave this empty
    -- or add any additional initialization here
end

-- Initialize object pool for resource bits
function bits.initPool()
    bits.bit_pool = {}
    
    -- Pre-allocate objects in the pool
    for i = 1, bits.pool_size do
        bits.bit_pool[i] = {
            active = false,
            x = 0,
            y = 0,
            type = "",
            size = 0,
            vx = 0,
            vy = 0,
            grounded = false,
            colliding_with = nil,
            moving_to_bank = false,
            grid_cell = nil,
            creation_time = 0
        }
    end
    
    log.info("Initialized resource bit pool with " .. bits.pool_size .. " objects")
end

-- Get a bit from the object pool
function bits.getBitFromPool()
    -- Initialize pool if it doesn't exist
    if #bits.bit_pool == 0 then
        bits.initPool()
    end
    
    -- Find an inactive bit in the pool
    for i = 1, #bits.bit_pool do
        if not bits.bit_pool[i].active then
            local bit = bits.bit_pool[i]
            bit.active = true
            bit.colliding_with = nil
            bit.grid_cell = nil -- Important for proper grid handling
            bit.creation_time = love.timer.getTime()
            return bit
        end
    end
    
    -- If no inactive bits found, create a new one (expand pool)
    local new_bit = {
        active = true,
        x = 0,
        y = 0,
        type = "",
        size = 0,
        vx = 0,
        vy = 0,
        grounded = false,
        colliding_with = nil,
        moving_to_bank = false,
        grid_cell = nil,
        creation_time = love.timer.getTime()
    }
    table.insert(bits.bit_pool, new_bit)
    
    log.debug("Expanded bit pool to " .. #bits.bit_pool .. " objects")
    return new_bit
end

-- Release a bit back to the pool
function bits.releaseBitToPool(bit)
    if bit then
        -- Remove from grid if it's in one
        if bit.grid_cell then
            bits.removeBitFromGrid(bit)
        end
        
        -- Reset properties
        bit.active = false
        bit.x = 0
        bit.y = 0
        bit.type = ""
        bit.size = 0
        bit.vx = 0
        bit.vy = 0
        bit.grounded = false
        bit.colliding_with = nil
        bit.moving_to_bank = false
        bit.grid_cell = nil
        bit.creation_time = 0
    end
end

-- Add a bit to the spatial grid for collision detection
function bits.addBitToGrid(bit)
    -- Calculate grid cell coordinates
    local grid_x = math.floor(bit.x / bits.cell_size)
    local grid_y = math.floor(bit.y / bits.cell_size)
    local cell_key = grid_x .. "," .. grid_y
    
    -- Initialize grid cell if it doesn't exist
    if not bits.grid[cell_key] then
        bits.grid[cell_key] = {}
    end
    
    -- Add bit to grid cell
    table.insert(bits.grid[cell_key], bit)
    
    -- Store grid position in bit for easy updates
    bit.grid_cell = cell_key
end

-- Update a bit's position in the spatial grid
function bits.updateBitGridPosition(bit)
    if bit.grid_cell then
        -- Calculate new grid cell
        local grid_x = math.floor(bit.x / bits.cell_size)
        local grid_y = math.floor(bit.y / bits.cell_size)
        local new_cell_key = grid_x .. "," .. grid_y
        
        -- If cell changed, update grid
        if new_cell_key ~= bit.grid_cell then
            -- Remove from old cell
            bits.removeBitFromGrid(bit)
            
            -- Add to new cell
            bits.addBitToGrid(bit)
        end
    else
        -- If bit doesn't have a grid cell, add it
        bits.addBitToGrid(bit)
    end
end

-- Remove a bit from the spatial grid
function bits.removeBitFromGrid(bit)
    if bit.grid_cell and bits.grid[bit.grid_cell] then
        -- Find and remove bit from its grid cell
        for i, grid_bit in ipairs(bits.grid[bit.grid_cell]) do
            if grid_bit == bit then
                table.remove(bits.grid[bit.grid_cell], i)
                break
            end
        end
        
        -- Clear grid cell reference
        bit.grid_cell = nil
    end
end

-- Get nearby bits for collision detection
function bits.getNearbyBits(bit)
    local nearby_bits = {}
    
    -- Check current cell and 8 surrounding cells
    for dx = -1, 1 do
        for dy = -1, 1 do
            local grid_x = math.floor(bit.x / bits.cell_size) + dx
            local grid_y = math.floor(bit.y / bits.cell_size) + dy
            local cell_key = grid_x .. "," .. grid_y
            
            if bits.grid[cell_key] then
                for _, other_bit in ipairs(bits.grid[cell_key]) do
                    if other_bit ~= bit and other_bit.active then
                        table.insert(nearby_bits, other_bit)
                    end
                end
            end
        end
    end
    
    return nearby_bits
end

-- Create bits from a resource
function bits.createBitsFromResource(resource, bits_to_generate, ground_level)
    local created_bits = {}
    
    for j = 1, bits_to_generate do
        local bit = bits.getBitFromPool() -- Use object pool
        if bit then
            bit.x = resource.x + love.math.random(-20, 20)
            bit.y = resource.y - love.math.random(5, 15)
            bit.type = resource.type
            bit.size = 3
            -- IMPORTANT: Give strong initial velocities to make bits visibly move
            bit.vx = love.math.random(-120, 120)  -- Much stronger horizontal movement
            bit.vy = -love.math.random(250, 400) -- Much stronger upward velocity
            bit.grounded = false
            bit.moving_to_bank = false
            bit.creation_time = love.timer.getTime()
            bit.active = true
            
            table.insert(bits.resource_bits, bit)
            table.insert(created_bits, bit)
        end
    end
    
    -- Debug output to verify bits are created with proper velocities
    if #created_bits > 0 then
        log.debug("Created " .. #created_bits .. " bits. Sample velocity: vx=" .. 
                 created_bits[1].vx .. ", vy=" .. created_bits[1].vy)
    end
    
    return created_bits
end

-- Send bits to a resource bank
function bits.sendBitsToBank(bit_list, bank_type, resource_banks)
    local bank = resource_banks[bank_type]
    if not bank then return 0 end
    
    local count = 0
    for _, bit in ipairs(bit_list) do
        -- Calculate direction toward bank
        local dx = bank.x - bit.x
        local dy = bank.y - bit.y
        local distance = math.sqrt(dx*dx + dy*dy)
        local dir_x = dx / distance
        local dir_y = dy / distance
        
        -- Jump strength based on distance, but with more consistent behavior
        local jump_strength = math.min(distance * 0.4, 300)
        
        -- Apply slight randomization for natural look
        jump_strength = jump_strength + love.math.random(-20, 20)
        
        -- Improved jumping physics - stronger velocities
        bit.vx = dir_x * jump_strength
        bit.vy = -400 - love.math.random(0, 100) -- Much stronger upward velocity
        bit.grounded = false
        bit.moving_to_bank = true
        
        -- Debug output to confirm velocity is set
        log.debug("Bit velocity toward bank: vx=" .. bit.vx .. ", vy=" .. bit.vy)
        
        count = count + 1
    end
    
    return count
end

-- Update physics and collisions for all bits
function bits.update(dt, ground_level, resource_banks, resources_collected, collection_animations, particles)
    -- Clear grid each frame
    bits.grid = {}
    
    -- First pass: update positions and add to grid
    for i, bit in ipairs(bits.resource_bits) do
        if bit.active then
            -- Apply gravity
            if not bit.grounded then
                bit.vy = bit.vy + 500 * dt
            end
            
            -- Update position
            bit.x = bit.x + bit.vx * dt
            bit.y = bit.y + bit.vy * dt
            
            -- Add to spatial grid
            bits.addBitToGrid(bit)
            
            -- Ground collision
            if bit.y > ground_level - bit.size/2 then
                bit.y = ground_level - bit.size/2
                bit.vy = 0
                bit.vx = bit.vx * 0.5  -- Less friction for more sliding
                bit.grounded = true    -- Always mark as grounded when hitting ground
            end
        
            -- Reset grounded flag if above ground
            if bit.y < ground_level - bit.size and bit.grounded then
                bit.grounded = false
            end
        end
    end
        
    -- Second pass: handle collisions using spatial grid
    for i = #bits.resource_bits, 1, -1 do
        local bit = bits.resource_bits[i]
        if bit.active then
            local supporting_bits = 0
            local nearby_bits = bits.getNearbyBits(bit)
        
            for _, other_bit in ipairs(nearby_bits) do
                local dx = bit.x - other_bit.x
                local dy = bit.y - other_bit.y
                local distance = math.sqrt(dx*dx + dy*dy)
                
                if distance < bit.size * 1.2 then
                    -- Collision response
                    local push_dx = dx
                    local push_dy = dy
                    
                    local push_length = math.sqrt(push_dx*push_dx + push_dy*push_dy)
                    if push_length > 0.001 then
                        push_dx = push_dx / push_length
                        push_dy = push_dy / push_length
                    else
                        local angle = love.math.random() * math.pi * 2
                        push_dx = math.cos(angle)
                        push_dy = math.sin(angle)
                    end
                    
                    local overlap = bit.size - distance
                    if overlap < 0 then overlap = 0 end
                    
                    bit.x = bit.x + push_dx * overlap * 0.6
                    bit.y = bit.y + push_dy * overlap * 0.6
                    other_bit.x = other_bit.x - push_dx * overlap * 0.6
                    other_bit.y = other_bit.y - push_dy * overlap * 0.6
                    
                    -- Update grid positions after moving
                    bits.updateBitGridPosition(bit)
                    bits.updateBitGridPosition(other_bit)
                    
                    -- Check if supported
                    if dy < -bit.size*0.5 and math.abs(dx) < bit.size*0.8 then
                        supporting_bits = supporting_bits + 1
                        
                        if other_bit.grounded then
                            bit.vx = bit.vx * 0.4
                            
                            if math.abs(bit.vx) < 10 and math.abs(bit.vy) < 20 then
                                bit.grounded = true
                            end
                        end
                    end
                end
            end
            
            -- Bank collision check
            if bit.moving_to_bank then
                local bank = resource_banks[bit.type]
                if bank then
                    local dx = bank.x - bit.x
                    local dy = bank.y - bit.y
                    local dist = math.sqrt(dx*dx + dy*dy)
                    
                    if dist < 25 then
                        -- Add to resource count 
                        resources_collected[bit.type] = resources_collected[bit.type] + 1
                        
                        -- Add collection animation if function is available
                        if collection_animations and type(collection_animations) == "function" then
                            collection_animations(bit.x, bit.y, bit.type, 1)
                        end
                        
                        -- Visual feedback with particles if available
                        if particles and particles[bit.type] then
                            particles[bit.type]:setPosition(bit.x, bit.y)
                            particles[bit.type]:emit(5)
                        end
                        
                        -- Return bit to pool
                        bits.releaseBitToPool(bit)
                        bits.removeBitFromGrid(bit)
                        
                        -- Remove from active bits
                        table.remove(bits.resource_bits, i)
                        
                        log.debug("Added " .. bit.type .. " to inventory! Total: " .. resources_collected[bit.type])
                    end
                end
            end
            
            -- Check for bits that have been around too long (cleanup)
            if love.timer.getTime() - bit.creation_time > 60 then -- 60 seconds lifetime
                bits.releaseBitToPool(bit)
                bits.removeBitFromGrid(bit)
                table.remove(bits.resource_bits, i)
                log.debug("Removed old resource bit")
            end
        end
    end
end

-- Draw all resource bits
function bits.draw()
    for _, bit in ipairs(bits.resource_bits) do
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

-- Clean up all bits
function bits.clearAll()
    for i = #bits.resource_bits, 1, -1 do
        bits.releaseBitToPool(bits.resource_bits[i])
    end
    bits.resource_bits = {}
    bits.grid = {}
end

-- Debug function to log physics states
function bits.debugPhysics()
    log.info("Debug Physics: checking resource bit velocities")
    for i, bit in ipairs(bits.resource_bits) do
        if bit.active then
            log.info(string.format("Bit #%d: vx=%.1f vy=%.1f active=%s grounded=%s", 
                i, bit.vx, bit.vy, tostring(bit.active), tostring(bit.grounded)))
        end
    end
end

return bits