-- Camera module for handling 2D world view

local camera = {
    x = 0,
    y = 0,
    scale = 1,
    drag = false,
    last_x = 0,
    last_y = 0,
    min_scale = 0.5,
    max_scale = 2.0,
    -- World boundaries
    world_width = 0,
    world_height = 0,
    -- Ground level in world coordinates
    ground_level = 0,
    -- Smooth camera movement
    target_x = 0,
    target_y = 0,
    target_scale = 1,
    smooth_factor = 5, -- Higher = smoother but slower
    -- Edge scrolling
    edge_scroll_enabled = true,
    edge_scroll_margin = 30,
    edge_scroll_speed = 300,
    -- Key scrolling
    key_scroll_speed = 300  -- Speed for keyboard scrolling (pixels per second)
}

-- Set the ground level in world coordinates
function camera.setGroundLevel(level)
    camera.ground_level = level
end

function camera.load(world_width, world_height)
    -- Store world dimensions for boundary checking
    camera.world_width = world_width
    camera.world_height = world_height
    
    -- Initialize camera position
    camera.x = 0
    camera.y = 0
    
    -- Start at a reasonable zoom level
    camera.scale = 0.8
    
    -- Calculate appropriate min/max zoom levels
    camera.calculateZoomLimits()
    
    -- Apply initial boundary enforcement
    camera.enforceWorldBoundaries()
end

function camera.calculateZoomLimits()
    -- Calculate minimum scale to ensure the world fills the screen
    local min_width_scale = love.graphics.getWidth() / camera.world_width
    local min_height_scale = love.graphics.getHeight() / camera.world_height
    
    -- Use the larger of the two to ensure no black areas in either dimension
    local min_scale = math.max(min_width_scale, min_height_scale)
    
    -- We want to be able to zoom in enough to see details
    local max_scale = 2.0
    
    -- Set the limits
    camera.min_scale = min_scale
    camera.max_scale = max_scale
end

function camera.set()
    -- Apply camera transformations
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.scale(camera.scale, camera.scale)
    love.graphics.translate(-camera.x, -camera.y)
end

function camera.unset()
    -- Remove camera transformations
    love.graphics.pop()
end

function camera.move(dx, dy)
    -- Apply movement to target position
    camera.target_x = camera.target_x + dx / camera.scale
    camera.target_y = camera.target_y + dy / camera.scale
end

function camera.zoom(x, y, factor)
    -- Store old scale for position adjustment
    local old_scale = camera.scale
    
    -- Calculate new target scale within limits
    local new_scale = camera.target_scale * factor
    new_scale = math.min(math.max(new_scale, camera.min_scale), camera.max_scale)
    
    -- Only proceed if scale actually changed
    if new_scale ~= camera.target_scale then
        -- Calculate mouse position in world coordinates before zooming
        local wx, wy = camera.screenToWorld(x, y)
        
        -- Apply new scale
        camera.target_scale = new_scale
        
        -- Adjust position to zoom toward mouse cursor
        local new_wx, new_wy = camera.screenToWorld(x, y)
        camera.target_x = camera.target_x + (wx - new_wx)
        camera.target_y = camera.target_y + (wy - new_wy)
    end
end

function camera.enforceWorldBoundaries()
    -- Calculate visible area dimensions in world coordinates
    local visible_width = love.graphics.getWidth() / camera.scale
    local visible_height = love.graphics.getHeight() / camera.scale
    
    -- Enforce horizontal boundaries
    if visible_width >= camera.world_width then
        -- If zoomed out enough to see the entire world width, center it
        camera.x = 0
    else
        -- Otherwise, ensure we don't see beyond the world edges
        local max_x = camera.world_width/2 - visible_width/2
        local min_x = -camera.world_width/2 + visible_width/2
        camera.x = math.min(math.max(camera.x, min_x), max_x)
    end
    
    -- Calculate where the ground should be on screen (3/4 from the top)
    local target_ground_screen_y = love.graphics.getHeight() * 0.75
    
    -- Convert to world coordinates
    local target_ground_offset = (target_ground_screen_y - love.graphics.getHeight() / 2) / camera.scale
    
    -- Set camera y position to place ground at target position
    camera.y = camera.ground_level - target_ground_offset
    
    -- Additional check: ensure we don't see beyond the bottom of the world
    local world_bottom = camera.world_height/2
    local screen_bottom_in_world = camera.y + visible_height/2
    
    if screen_bottom_in_world > world_bottom then
        camera.y = world_bottom - visible_height/2
    end
    
    -- Additional check: ensure we don't see beyond the top of the world
    local world_top = -camera.world_height/2
    local screen_top_in_world = camera.y - visible_height/2
    
    if screen_top_in_world < world_top then
        camera.y = world_top + visible_height/2
    end
    
    -- Final check: if we're zoomed out enough to see the entire world height,
    -- center it vertically
    if visible_height >= camera.world_height then
        camera.y = 0
    end
end

function camera.mousepressed(x, y, button)
    if button == 2 then -- Middle mouse button for drag
        camera.drag = true
        camera.last_x = x
        camera.last_y = y
        love.mouse.setVisible(false) -- Hide cursor during drag
    end
end

function camera.mousereleased(x, y, button)
    if button == 2 then -- Middle mouse button for drag
        camera.drag = false
        love.mouse.setVisible(true) -- Show cursor again
    end
end

function camera.mousemoved(x, y, dx, dy)
    if camera.drag then
        -- Move camera based on mouse movement
        camera.move(-dx, -dy)
        
        -- Update last position
        camera.last_x = x
        camera.last_y = y
    end
end

-- Toggle edge scrolling
function camera.toggleEdgeScrolling()
    camera.edge_scroll_enabled = not camera.edge_scroll_enabled
    return camera.edge_scroll_enabled
end

-- Reset camera to center of world
function camera.resetPosition()
    camera.target_x = 0
    camera.target_y = 0
    camera.target_scale = 0.8
end

function camera.update(dt)
    -- Handle edge scrolling if enabled
    if camera.edge_scroll_enabled then
        local mx, my = love.mouse.getPosition()
        local window_width, window_height = love.graphics.getDimensions()
        
        -- Left edge
        if mx < camera.edge_scroll_margin then
            camera.target_x = camera.target_x - camera.edge_scroll_speed * dt / camera.scale
        end
        
        -- Right edge
        if mx > window_width - camera.edge_scroll_margin then
            camera.target_x = camera.target_x + camera.edge_scroll_speed * dt / camera.scale
        end
    end
    
    -- Handle keyboard camera panning
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        camera.target_x = camera.target_x - camera.key_scroll_speed * dt / camera.scale
    end
    
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        camera.target_x = camera.target_x + camera.key_scroll_speed * dt / camera.scale
    end
    
    -- Smooth camera movement
    camera.x = camera.x + (camera.target_x - camera.x) * camera.smooth_factor * dt
    camera.y = camera.y + (camera.target_y - camera.y) * camera.smooth_factor * dt
    camera.scale = camera.scale + (camera.target_scale - camera.scale) * camera.smooth_factor * dt
    
    -- Enforce world boundaries
    camera.enforceWorldBoundaries()
end

function camera.worldToScreen(x, y)
    return (x - camera.x) * camera.scale + love.graphics.getWidth() / 2,
           (y - camera.y) * camera.scale + love.graphics.getHeight() / 2
end

function camera.screenToWorld(x, y)
    return (x - love.graphics.getWidth() / 2) / camera.scale + camera.x,
           (y - love.graphics.getHeight() / 2) / camera.scale + camera.y
end

function camera.getPosition()
    return camera.x, camera.y
end

return camera 