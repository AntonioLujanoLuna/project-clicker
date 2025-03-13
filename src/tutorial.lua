-- project-clicker - Tutorial Module
-- Provides a step-by-step tutorial for new players

local log = require("src.log")
local json = require("lib.json")

local tutorial = {}

-- Tutorial steps
tutorial.steps = {
    {
        id = "welcome",
        message = "Welcome to project-clicker! Let's learn how to play.",
        target = nil,
        position = "center"
    },
    {
        id = "click_resource",
        message = "Click on resources to gather them. Try clicking a wood resource node!",
        target = "wood_resource",
        position = "top",
        required_action = "click_wood"
    },
    {
        id = "collect_bits",
        message = "Great! Now click on the resource bits to send them to your collection bank.",
        target = "resource_bits",
        position = "bottom",
        required_action = "collect_bits"
    },
    {
        id = "open_robots",
        message = "Let's build a robot to help gather resources. Click the Robots button.",
        target = "robots_button",
        position = "bottom",
        required_action = "open_robots"
    },
    {
        id = "build_robot",
        message = "Build a Gatherer robot to automatically collect resources.",
        target = "gatherer_button",
        position = "bottom",
        required_action = "build_gatherer"
    },
    {
        id = "camera_controls",
        message = "Use the middle mouse button to pan the camera and the mouse wheel to zoom.",
        target = nil,
        position = "center"
    },
    {
        id = "auto_collect",
        message = "Press 'C' to toggle auto-collection of resources near your camera.",
        target = nil,
        position = "center",
        required_action = "toggle_auto_collect"
    },
    {
        id = "pollution",
        message = "Watch your pollution level! Building green technology helps reduce pollution.",
        target = "pollution_bar",
        position = "bottom"
    },
    {
        id = "tutorial_complete",
        message = "Tutorial complete! Press H anytime to open the help panel for more information.",
        target = nil,
        position = "center"
    }
}

-- Tutorial state
tutorial.current_step = 0
tutorial.active = false
tutorial.completed = false
tutorial.show_tutorial = true

-- Target element positions (to be set during game initialization)
tutorial.target_positions = {}

function tutorial.load()
    -- Try to load tutorial completion status
    local success, data = pcall(function()
        if love.filesystem.getInfo("tutorial.json") then
            local contents = love.filesystem.read("tutorial.json")
            return json.decode(contents)
        end
        return nil
    end)
    
    if success and data and data.tutorial_completed then
        tutorial.completed = true
        log.info("Tutorial already completed")
    else
        log.info("Tutorial not completed yet")
    end
end

-- Add the missing update function
function tutorial.update(dt)
    -- This could contain animations or timing logic for the tutorial
    -- For now, it can be a minimal implementation that just exists to prevent the nil error
    
    -- If we wanted to add tutorial timing or animations in the future:
    -- - Tutorial step timing
    -- - Highlighting animations
    -- - Automatic progression after waiting
    
    if tutorial.active then
        -- Currently no animations, but function exists to prevent nil error
    end
end

function tutorial.start()
    if not tutorial.completed and tutorial.show_tutorial then
        tutorial.active = true
        tutorial.current_step = 1
        log.info("Starting tutorial at step 1")
    end
end

function tutorial.nextStep()
    if tutorial.current_step < #tutorial.steps then
        tutorial.current_step = tutorial.current_step + 1
        log.info("Moving to tutorial step " .. tutorial.current_step)
    else
        tutorial.complete()
    end
end

function tutorial.complete()
    tutorial.active = false
    tutorial.completed = true
    log.info("Tutorial completed")
    
    -- Save tutorial completion status
    local data = {
        tutorial_completed = true
    }
    
    -- Write to file
    local success, err = pcall(function()
        love.filesystem.write("tutorial.json", json.encode(data))
    end)
    
    if not success then
        log.error("Failed to save tutorial status: " .. tostring(err))
    end
end

function tutorial.getCurrentStep()
    if tutorial.active and tutorial.current_step > 0 and tutorial.current_step <= #tutorial.steps then
        return tutorial.steps[tutorial.current_step]
    end
    return nil
end

function tutorial.checkAction(action, ...)
    local current_step = tutorial.getCurrentStep()
    
    if current_step and current_step.required_action == action then
        -- Step completed, move to next
        tutorial.nextStep()
        return true
    end
    
    return false
end

function tutorial.setTargetPosition(id, x, y, width, height)
    tutorial.target_positions[id] = {
        x = x,
        y = y,
        width = width or 50,
        height = height or 50
    }
end

function tutorial.getTargetPosition(target_id)
    return tutorial.target_positions[target_id]
end

function tutorial.draw()
    if not tutorial.active then return end
    
    local step = tutorial.getCurrentStep()
    if not step then return end
    
    -- Draw tutorial box
    local box_width = 300
    local box_height = 100
    local box_x, box_y
    
    if step.target and tutorial.target_positions[step.target] then
        -- Position based on target element
        local target = tutorial.target_positions[step.target]
        
        if step.position == "top" then
            box_x = target.x + target.width/2 - box_width/2
            box_y = target.y - box_height - 10
        elseif step.position == "bottom" then
            box_x = target.x + target.width/2 - box_width/2
            box_y = target.y + target.height + 10
        elseif step.position == "left" then
            box_x = target.x - box_width - 10
            box_y = target.y + target.height/2 - box_height/2
        elseif step.position == "right" then
            box_x = target.x + target.width + 10
            box_y = target.y + target.height/2 - box_height/2
        else
            -- Default to center
            box_x = love.graphics.getWidth() / 2 - box_width / 2
            box_y = love.graphics.getHeight() / 2 - box_height / 2
        end
        
        -- Keep box on screen
        box_x = math.max(10, math.min(love.graphics.getWidth() - box_width - 10, box_x))
        box_y = math.max(10, math.min(love.graphics.getHeight() - box_height - 10, box_y))
        
        -- Draw highlight around target
        love.graphics.setColor(1, 1, 0, 0.5)
        love.graphics.rectangle("line", target.x - 5, target.y - 5, target.width + 10, target.height + 10)
    else
        -- Center position
        box_x = love.graphics.getWidth() / 2 - box_width / 2
        box_y = love.graphics.getHeight() / 2 - box_height / 2
    end
    
    -- Draw box background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", box_x, box_y, box_width, box_height)
    
    -- Draw box border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", box_x, box_y, box_width, box_height)
    
    -- Draw message
    love.graphics.printf(step.message, box_x + 10, box_y + 10, box_width - 20, "center")
    
    -- Draw continue button
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", box_x + box_width - 110, box_y + box_height - 40, 100, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", box_x + box_width - 110, box_y + box_height - 40, 100, 30)
    love.graphics.printf("Continue", box_x + box_width - 110, box_y + box_height - 35, 100, "center")
end

function tutorial.mousepressed(x, y, button)
    if not tutorial.active then return false end
    
    local step = tutorial.getCurrentStep()
    if not step then return false end
    
    -- Calculate box position
    local box_width = 300
    local box_height = 100
    local box_x, box_y
    
    if step.target and tutorial.target_positions[step.target] then
        -- Position based on target element
        local target = tutorial.target_positions[step.target]
        
        if step.position == "top" then
            box_x = target.x + target.width/2 - box_width/2
            box_y = target.y - box_height - 10
        elseif step.position == "bottom" then
            box_x = target.x + target.width/2 - box_width/2
            box_y = target.y + target.height + 10
        elseif step.position == "left" then
            box_x = target.x - box_width - 10
            box_y = target.y + target.height/2 - box_height/2
        elseif step.position == "right" then
            box_x = target.x + target.width + 10
            box_y = target.y + target.height/2 - box_height/2
        else
            -- Default to center
            box_x = love.graphics.getWidth() / 2 - box_width / 2
            box_y = love.graphics.getHeight() / 2 - box_height / 2
        end
        
        -- Keep box on screen
        box_x = math.max(10, math.min(love.graphics.getWidth() - box_width - 10, box_x))
        box_y = math.max(10, math.min(love.graphics.getHeight() - box_height - 10, box_y))
    else
        -- Center position
        box_x = love.graphics.getWidth() / 2 - box_width / 2
        box_y = love.graphics.getHeight() / 2 - box_height / 2
    end
    
    -- Check if Continue button was clicked
    if x >= box_x + box_width - 110 and x <= box_x + box_width - 10 and
       y >= box_y + box_height - 40 and y <= box_y + box_height - 10 then
        tutorial.nextStep()
        return true
    end
    
    return false
end

return tutorial