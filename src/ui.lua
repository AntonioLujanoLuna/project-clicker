-- project-clicker - UI Module
-- Manages user interface elements

local robots = require("src.robots")

local ui = {}

-- UI state
local font
local ui_scale = 1.0 -- UI scaling factor
local min_scale = 0.75
local max_scale = 1.5
local resource_panel = {x = 10, y = 10, width = 200, height = 130}
local pollution_panel = {x = 220, y = 10, width = 200, height = 50}
local robot_panel = {x = 10, y = 150, width = 780, height = 120, visible = false}
local research_panel = {x = 10, y = 280, width = 780, height = 120, visible = false}
local tooltip = {text = "", x = 0, y = 0, visible = false, width = 200}
local help_panel = {visible = false, x = 200, y = 100, width = 400, height = 300}
local settings_panel = {visible = false, x = 200, y = 100, width = 400, height = 300}

-- Navigation buttons
local nav_buttons = {
    {name = "Robots", x = 430, y = 10, width = 80, height = 30, panel = "robot", hover = false, shortcut = "1"},
    {name = "Research", x = 520, y = 10, width = 80, height = 30, panel = "research", hover = false, shortcut = "2"},
    {name = "Help", x = 610, y = 10, width = 80, height = 30, panel = "help", hover = false, shortcut = "h"},
    {name = "Settings", x = 700, y = 10, width = 80, height = 30, panel = "settings", hover = false, shortcut = "s"}
}

-- Keyboard shortcuts
local shortcuts = {
    ["1"] = function() ui.togglePanel("robot") end,
    ["2"] = function() ui.togglePanel("research") end,
    ["h"] = function() ui.togglePanel("help") end,
    ["s"] = function() ui.togglePanel("settings") end,
    ["escape"] = function() ui.closeAllPanels() end
}

-- Button state
local buttons = {}

function ui.load()
    -- Load font
    font = love.graphics.getFont() -- Default font
    
    -- Initialize robot buttons
    ui.initRobotButtons()
end

function ui.initRobotButtons()
    buttons = {}
    
    -- Create robot buttons with monochrome colors
    local x_offset = 20
    for type_key, robot_type in pairs(robots.TYPES) do
        table.insert(buttons, {
            type = "robot",
            robot_type = type_key,
            x = robot_panel.x + x_offset,
            y = robot_panel.y + 30,
            width = 80,
            height = 60,
            color = {1, 1, 1}, -- White for all robot buttons
            name = robot_type.name,
            description = robot_type.description,
            cost = robot_type.cost,
            hover = false
        })
        
        x_offset = x_offset + 100
    end
    
    -- Create research buttons with monochrome colors
    x_offset = 20
    for i = 1, 5 do
        table.insert(buttons, {
            type = "research",
            x = research_panel.x + x_offset,
            y = research_panel.y + 30,
            width = 80,
            height = 60,
            color = {1, 1, 1}, -- White for research buttons
            name = "Tech " .. i,
            description = "Research new technology",
            cost = {Research = 10 * i},
            hover = false
        })
        
        x_offset = x_offset + 100
    end
end

function ui.update(dt)
    -- Update UI animations if any
    
    -- Update button hover states
    local mx, my = love.mouse.getPosition()
    
    -- Update navigation button hover states
    for _, button in ipairs(nav_buttons) do
        button.hover = mx >= button.x and mx <= button.x + button.width and
                      my >= button.y and my <= button.y + button.height
    end
    
    -- Update panel button hover states (only if panel is visible)
    for _, button in ipairs(buttons) do
        if (button.type == "robot" and robot_panel.visible) or
           (button.type == "research" and research_panel.visible) then
            button.hover = mx >= button.x and mx <= button.x + button.width and
                          my >= button.y and my <= button.y + button.height
        else
            button.hover = false
        end
    end
end

function ui.draw(resources, pollution_level, research_points)
    -- Draw resource panel
    love.graphics.setColor(0, 0, 0, 0.7) -- Black background with transparency
    love.graphics.rectangle("fill", resource_panel.x, resource_panel.y, resource_panel.width, resource_panel.height)
    love.graphics.setColor(1, 1, 1) -- White border
    love.graphics.rectangle("line", resource_panel.x, resource_panel.y, resource_panel.width, resource_panel.height)
    
    -- Draw resource counts
    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.printf("Resources:", resource_panel.x + 10, resource_panel.y + 10, resource_panel.width - 20, "left")
    
    -- Get resources from game.resources_collected instead of resources parameter
    local game = require("src.game")
    local y_offset = 35
    
    -- Display resources with proper formatting
    if game.resources_collected then
        for resource_name, amount in pairs(game.resources_collected) do
            -- Format resource name to be capitalized
            local display_name = resource_name:sub(1,1):upper() .. resource_name:sub(2)
            -- Format number with commas for thousands
            local formatted_amount = tostring(amount)
            local formatted_with_commas = ""
            
            -- Add commas for thousands
            local length = string.len(formatted_amount)
            local position = 1
            
            while position <= length do
                local end_pos = length - position + 1
                local start_pos = math.max(1, end_pos - 2)
                local segment = string.sub(formatted_amount, start_pos, end_pos)
                
                if formatted_with_commas ~= "" then
                    formatted_with_commas = segment .. "," .. formatted_with_commas
                else
                    formatted_with_commas = segment
                end
                
                position = position + 3
            end
            
            -- Display the resource with formatted number
            love.graphics.printf(display_name .. ": " .. formatted_with_commas, 
                resource_panel.x + 20, resource_panel.y + y_offset, 
                resource_panel.width - 40, "left")
            
            y_offset = y_offset + 25
        end
    else
        -- Fallback to the old method if resources_collected is not available
        for resource_name, amount in pairs(resources) do
            love.graphics.printf(resource_name .. ": " .. amount, 
                resource_panel.x + 20, resource_panel.y + y_offset, 
                resource_panel.width - 40, "left")
            y_offset = y_offset + 25
        end
    end
    
    -- Draw pollution panel
    love.graphics.setColor(0, 0, 0, 0.7) -- Black background with transparency
    love.graphics.rectangle("fill", pollution_panel.x, pollution_panel.y, pollution_panel.width, pollution_panel.height)
    love.graphics.setColor(1, 1, 1) -- White border
    love.graphics.rectangle("line", pollution_panel.x, pollution_panel.y, pollution_panel.width, pollution_panel.height)
    
    -- Draw pollution bar
    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.printf("Pollution:", pollution_panel.x + 10, pollution_panel.y + 10, 80, "left")
    
    -- Draw pollution bar background
    love.graphics.setColor(0.2, 0.2, 0.2) -- Dark gray background
    love.graphics.rectangle("fill", pollution_panel.x + 90, pollution_panel.y + 15, 100, 20)
    
    -- Draw pollution level
    local pollution_width = math.min(pollution_level, 100) -- Cap at 100%
    love.graphics.setColor(1, 1, 1) -- White for pollution
    love.graphics.rectangle("fill", pollution_panel.x + 90, pollution_panel.y + 15, pollution_width, 20)
    
    -- Draw research points
    love.graphics.setColor(1, 1, 1) -- White text
    love.graphics.printf("Research: " .. research_points, 610, pollution_panel.y + 15, 100, "left")
    
    -- Draw navigation buttons
    for _, button in ipairs(nav_buttons) do
        if button.hover then
            love.graphics.setColor(0.3, 0.3, 0.3) -- Darker gray when hovering
        else
            love.graphics.setColor(0, 0, 0, 0.7) -- Black with transparency
        end
        
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        love.graphics.setColor(1, 1, 1) -- White border
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
        
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.printf(button.name, button.x, button.y + 8, button.width, "center")
    end
    
    -- Draw robot panel if visible
    if robot_panel.visible then
        love.graphics.setColor(0, 0, 0, 0.7) -- Black background with transparency
        love.graphics.rectangle("fill", robot_panel.x, robot_panel.y, robot_panel.width, robot_panel.height)
        love.graphics.setColor(1, 1, 1) -- White border
        love.graphics.rectangle("line", robot_panel.x, robot_panel.y, robot_panel.width, robot_panel.height)
        
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.printf("Robots:", robot_panel.x + 10, robot_panel.y + 10, 100, "left")
        
        -- Draw robot buttons
        for _, button in ipairs(buttons) do
            if button.type == "robot" then
                if button.hover then
                    love.graphics.setColor(0.3, 0.3, 0.3) -- Darker gray when hovering
                else
                    love.graphics.setColor(0, 0, 0, 0.7) -- Black with transparency
                end
                
                love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
                love.graphics.setColor(1, 1, 1) -- White border
                love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
                
                love.graphics.setColor(1, 1, 1) -- White text
                love.graphics.printf(button.name, button.x, button.y + 10, button.width, "center")
                
                -- Draw cost
                local cost_text = ""
                for resource, amount in pairs(button.cost) do
                    cost_text = cost_text .. resource .. ": " .. amount .. " "
                end
                
                love.graphics.printf(cost_text, button.x, button.y + 35, button.width, "center")
            end
        end
    end
    
    -- Draw research panel if visible
    if research_panel.visible then
        love.graphics.setColor(0, 0, 0, 0.7) -- Black background with transparency
        love.graphics.rectangle("fill", research_panel.x, research_panel.y, research_panel.width, research_panel.height)
        love.graphics.setColor(1, 1, 1) -- White border
        love.graphics.rectangle("line", research_panel.x, research_panel.y, research_panel.width, research_panel.height)
        
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.printf("Research:", research_panel.x + 10, research_panel.y + 10, 100, "left")
        
        -- Draw research buttons
        for _, button in ipairs(buttons) do
            if button.type == "research" then
                if button.hover then
                    love.graphics.setColor(0.3, 0.3, 0.3) -- Darker gray when hovering
                else
                    love.graphics.setColor(0, 0, 0, 0.7) -- Black with transparency
                end
                
                love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
                love.graphics.setColor(1, 1, 1) -- White border
                love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
                
                love.graphics.setColor(1, 1, 1) -- White text
                love.graphics.printf(button.name, button.x, button.y + 10, button.width, "center")
                
                -- Draw cost
                local cost_text = ""
                for resource, amount in pairs(button.cost) do
                    cost_text = cost_text .. resource .. ": " .. amount .. " "
                end
                
                love.graphics.printf(cost_text, button.x, button.y + 35, button.width, "center")
            end
        end
    end
    
    -- Draw tooltip for hovered button
    for _, button in ipairs(buttons) do
        if button.hover then
            love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
            love.graphics.rectangle("fill", love.mouse.getX() + 10, love.mouse.getY() + 10, 200, 50)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", love.mouse.getX() + 10, love.mouse.getY() + 10, 200, 50)
            love.graphics.printf(button.description, love.mouse.getX() + 15, love.mouse.getY() + 15, 190, "left")
        end
    end
    
    -- Draw tooltip for navigation buttons
    for _, button in ipairs(nav_buttons) do
        if button.hover then
            love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
            love.graphics.rectangle("fill", love.mouse.getX() + 10, love.mouse.getY() + 10, 200, 30)
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("line", love.mouse.getX() + 10, love.mouse.getY() + 10, 200, 30)
            
            local tooltip = "Click to " .. (button.panel == "robot" and "build robots" or "research technologies")
            love.graphics.printf(tooltip, love.mouse.getX() + 15, love.mouse.getY() + 15, 190, "left")
        end
    end
    
    -- Draw tooltip if visible
    if tooltip.visible then
        -- Calculate tooltip dimensions
        local text_width, wrapped_text = font:getWrap(tooltip.text, tooltip.width)
        local text_height = #wrapped_text * font:getHeight()
        
        -- Draw tooltip background
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", tooltip.x, tooltip.y, tooltip.width, text_height + 10)
        
        -- Draw tooltip border
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", tooltip.x, tooltip.y, tooltip.width, text_height + 10)
        
        -- Draw tooltip text
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(tooltip.text, tooltip.x + 5, tooltip.y + 5, tooltip.width - 10)
    end
    
    -- Draw help panel if visible
    if help_panel.visible then
        -- Draw panel background
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", help_panel.x, help_panel.y, help_panel.width, help_panel.height)
        
        -- Draw panel border
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", help_panel.x, help_panel.y, help_panel.width, help_panel.height)
        
        -- Draw help content
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("project-clicker Help", help_panel.x + 10, help_panel.y + 10, help_panel.width - 20, "center")
        
        local help_text = [[
Keyboard Shortcuts:
1 - Toggle Robots Panel
2 - Toggle Research Panel
H - Toggle Help Panel
S - Toggle Settings Panel
R - Reset Camera Position
E - Toggle Edge Scrolling
A - Toggle Auto-Collection
V - Toggle Collection Radius
+ / - - Adjust UI Scale
ESC - Close All Panels

Mouse Controls:
Left Click - Collect Resources
Middle Click & Drag - Move Camera
Mouse Wheel - Zoom In/Out

Game Features:
- Resources are highlighted when hovered
- Auto-collection gathers resources near the camera
- Collection radius shows the auto-collection area
- UI can be scaled in the Settings panel
]]
        
        love.graphics.printf(help_text, help_panel.x + 10, help_panel.y + 40, help_panel.width - 20)
        
        -- Draw close button
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle("fill", help_panel.x + help_panel.width - 30, help_panel.y + 10, 20, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("X", help_panel.x + help_panel.width - 30, help_panel.y + 10, 20, "center")
    end
    
    -- Draw settings panel if visible
    if settings_panel.visible then
        -- Draw panel background
        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
        love.graphics.rectangle("fill", settings_panel.x, settings_panel.y, settings_panel.width, settings_panel.height)
        
        -- Draw panel border
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("line", settings_panel.x, settings_panel.y, settings_panel.width, settings_panel.height)
        
        -- Draw settings content
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Settings", settings_panel.x + 10, settings_panel.y + 10, settings_panel.width - 20, "center")
        
        -- UI Scale setting
        love.graphics.printf("UI Scale: " .. string.format("%.1f", ui_scale), 
            settings_panel.x + 20, settings_panel.y + 50, settings_panel.width - 40, "left")
        
        -- Scale decrease button
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", settings_panel.x + 20, settings_panel.y + 80, 40, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", settings_panel.x + 20, settings_panel.y + 80, 40, 30)
        love.graphics.printf("-", settings_panel.x + 20, settings_panel.y + 85, 40, "center")
        
        -- Scale increase button
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", settings_panel.x + settings_panel.width - 60, settings_panel.y + 80, 40, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", settings_panel.x + settings_panel.width - 60, settings_panel.y + 80, 40, 30)
        love.graphics.printf("+", settings_panel.x + settings_panel.width - 60, settings_panel.y + 85, 40, "center")
        
        -- Scale slider
        local slider_width = settings_panel.width - 120
        local slider_x = settings_panel.x + 70
        local slider_y = settings_panel.y + 95
        
        -- Draw slider background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", slider_x, slider_y, slider_width, 2)
        
        -- Draw slider handle
        local handle_pos = slider_x + (ui_scale - min_scale) / (max_scale - min_scale) * slider_width
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", handle_pos - 5, slider_y - 8, 10, 18)
        
        -- Auto-collection setting
        love.graphics.printf("Auto-Collection: " .. (game.auto_collect_enabled and "Enabled" or "Disabled"), 
            settings_panel.x + 20, settings_panel.y + 120, settings_panel.width - 40, "left")
        
        -- Toggle button
        love.graphics.setColor(game.auto_collect_enabled and 0.2 or 0.5, game.auto_collect_enabled and 0.5 or 0.2, 0.2)
        love.graphics.rectangle("fill", settings_panel.x + settings_panel.width - 100, settings_panel.y + 120, 80, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", settings_panel.x + settings_panel.width - 100, settings_panel.y + 120, 80, 30)
        love.graphics.printf(game.auto_collect_enabled and "Disable" or "Enable", 
            settings_panel.x + settings_panel.width - 100, settings_panel.y + 125, 80, "center")
        
        -- Show collection radius setting
        love.graphics.printf("Show Collection Radius: " .. (game.show_collect_radius and "Visible" or "Hidden"), 
            settings_panel.x + 20, settings_panel.y + 160, settings_panel.width - 40, "left")
        
        -- Toggle button for radius visibility
        love.graphics.setColor(game.show_collect_radius and 0.2 or 0.5, game.show_collect_radius and 0.5 or 0.2, 0.2)
        love.graphics.rectangle("fill", settings_panel.x + settings_panel.width - 100, settings_panel.y + 160, 80, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", settings_panel.x + settings_panel.width - 100, settings_panel.y + 160, 80, 30)
        love.graphics.printf(game.show_collect_radius and "Hide" or "Show", 
            settings_panel.x + settings_panel.width - 100, settings_panel.y + 165, 80, "center")
        
        -- Keyboard shortcuts info
        love.graphics.printf("Keyboard Shortcuts:", 
            settings_panel.x + 20, settings_panel.y + 200, settings_panel.width - 40, "left")
        love.graphics.printf("A - Toggle Auto-Collection\nV - Toggle Collection Radius\nS - Toggle Settings Panel\n+ / - - Adjust UI Scale", 
            settings_panel.x + 40, settings_panel.y + 230, settings_panel.width - 80, "left")
        
        -- Draw close button
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle("fill", settings_panel.x + settings_panel.width - 30, settings_panel.y + 10, 20, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("X", settings_panel.x + settings_panel.width - 30, settings_panel.y + 10, 20, "center")
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function ui.mousepressed(x, y, button, game)
    if button == 1 then -- Left mouse button
        -- Check navigation button clicks
        for _, nav_button in ipairs(nav_buttons) do
            if nav_button.hover then
                if nav_button.panel == "robot" then
                    robot_panel.visible = not robot_panel.visible
                    research_panel.visible = false
                elseif nav_button.panel == "research" then
                    research_panel.visible = not research_panel.visible
                    robot_panel.visible = false
                elseif nav_button.panel == "help" then
                    help_panel.visible = not help_panel.visible
                    settings_panel.visible = false
                elseif nav_button.panel == "settings" then
                    settings_panel.visible = not settings_panel.visible
                    help_panel.visible = false
                end
                return true -- Return true to indicate we handled the click
            end
        end
        
        -- Check panel button clicks
        for _, ui_button in ipairs(buttons) do
            if ui_button.hover then
                if ui_button.type == "robot" then
                    -- Try to build the robot using resources_collected instead of resources
                    local robot_type = robots.TYPES[ui_button.robot_type]
                    
                    -- Check if the player has enough resources manually
                    local can_afford = true
                    for resource_name, amount in pairs(robot_type.cost) do
                        local resource_key = resource_name:lower() -- Convert to lowercase to match resources_collected keys
                        if not game.resources_collected[resource_key] or game.resources_collected[resource_key] < amount then
                            can_afford = false
                            break
                        end
                    end
                    
                    if can_afford then
                        -- Subtract resources
                        for resource_name, amount in pairs(robot_type.cost) do
                            local resource_key = resource_name:lower()
                            game.resources_collected[resource_key] = game.resources_collected[resource_key] - amount
                        end
                        
                        -- Create a robot in the game world with the correct type
                        local robot_entity = game.addRobot(ui_button.robot_type)
                        
                        print("Built a " .. ui_button.name .. " robot!")
                        return true
                    else
                        print("Not enough resources to build " .. ui_button.name)
                        return true
                    end
                elseif ui_button.type == "research" then
                    -- Handle research button clicks (placeholder)
                    if game.research_points >= ui_button.cost.Research then
                        game.research_points = game.research_points - ui_button.cost.Research
                        print("Researched " .. ui_button.name .. "!")
                        -- TODO: Implement actual research effects
                    else
                        print("Not enough research points for " .. ui_button.name)
                    end
                    return true
                end
            end
        end
        
        -- Check settings panel button clicks
        if settings_panel.visible then
            -- Check scale decrease button
            if x >= settings_panel.x + 20 and x <= settings_panel.x + 60 and
               y >= settings_panel.y + 80 and y <= settings_panel.y + 110 then
                ui.decreaseScale()
                return true
            end
            
            -- Check scale increase button
            if x >= settings_panel.x + settings_panel.width - 60 and x <= settings_panel.x + settings_panel.width - 20 and
               y >= settings_panel.y + 80 and y <= settings_panel.y + 110 then
                ui.increaseScale()
                return true
            end
            
            -- Check auto-collection toggle button
            if x >= settings_panel.x + settings_panel.width - 100 and x <= settings_panel.x + settings_panel.width - 20 and
               y >= settings_panel.y + 120 and y <= settings_panel.y + 150 then
                game.toggleAutoCollect()
                return true
            end
            
            -- Check collection radius visibility toggle button
            if x >= settings_panel.x + settings_panel.width - 100 and x <= settings_panel.x + settings_panel.width - 20 and
               y >= settings_panel.y + 160 and y <= settings_panel.y + 190 then
                game.toggleCollectRadiusVisibility()
                return true
            end
            
            -- Check close button
            if x >= settings_panel.x + settings_panel.width - 30 and x <= settings_panel.x + settings_panel.width - 10 and
               y >= settings_panel.y + 10 and y <= settings_panel.y + 30 then
                settings_panel.visible = false
                return true
            end
        end
        
        return false -- Return false to indicate we didn't handle the click
    end
    
    return false
end

function ui.mousereleased(x, y, button)
    -- Handle UI button releases
end

function ui.mousemoved(x, y)
    -- Update tooltip
    tooltip.visible = false
    
    -- Check button hovers for tooltips
    for _, button in ipairs(buttons) do
        if button.hover then
            tooltip.text = button.description
            if button.cost then
                tooltip.text = tooltip.text .. "\n\nCost: "
                for resource, amount in pairs(button.cost) do
                    tooltip.text = tooltip.text .. "\n" .. resource .. ": " .. amount
                end
            end
            tooltip.x = x + 15
            tooltip.y = y + 15
            tooltip.visible = true
            break
        end
    end
    
    -- Check nav button hovers for tooltips
    for _, button in ipairs(nav_buttons) do
        if button.hover then
            tooltip.text = "Open " .. button.name .. " panel"
            if button.shortcut then
                tooltip.text = tooltip.text .. " (Press " .. button.shortcut .. ")"
            end
            tooltip.x = x + 15
            tooltip.y = y + 15
            tooltip.visible = true
            break
        end
    end
end

function ui.keypressed(key)
    -- Handle keyboard shortcuts
    if shortcuts[key] then
        shortcuts[key]()
    elseif key == "+" or key == "=" then
        ui.increaseScale()
    elseif key == "-" then
        ui.decreaseScale()
    end
end

function ui.togglePanel(panel_name)
    if panel_name == "robot" then
        robot_panel.visible = not robot_panel.visible
        research_panel.visible = false
        help_panel.visible = false
        settings_panel.visible = false
    elseif panel_name == "research" then
        research_panel.visible = not research_panel.visible
        robot_panel.visible = false
        help_panel.visible = false
        settings_panel.visible = false
    elseif panel_name == "help" then
        help_panel.visible = not help_panel.visible
        robot_panel.visible = false
        research_panel.visible = false
        settings_panel.visible = false
    elseif panel_name == "settings" then
        settings_panel.visible = not settings_panel.visible
        robot_panel.visible = false
        research_panel.visible = false
        help_panel.visible = false
    end
end

function ui.closeAllPanels()
    robot_panel.visible = false
    research_panel.visible = false
    help_panel.visible = false
    settings_panel.visible = false
end

-- Function to increase UI scale
function ui.increaseScale()
    ui_scale = math.min(ui_scale + 0.1, max_scale)
    ui.updatePanelPositions()
    return ui_scale
end

-- Function to decrease UI scale
function ui.decreaseScale()
    ui_scale = math.max(ui_scale - 0.1, min_scale)
    ui.updatePanelPositions()
    return ui_scale
end

-- Function to update panel positions based on scale
function ui.updatePanelPositions()
    -- Base positions (at scale 1.0)
    local base_resource_panel = {x = 10, y = 10, width = 200, height = 130}
    local base_pollution_panel = {x = 220, y = 10, width = 200, height = 50}
    local base_robot_panel = {x = 10, y = 150, width = 780, height = 120}
    local base_research_panel = {x = 10, y = 280, width = 780, height = 120}
    local base_help_panel = {x = 200, y = 100, width = 400, height = 300}
    local base_settings_panel = {x = 200, y = 100, width = 400, height = 300}
    
    -- Base button positions
    local base_buttons = {
        {name = "Robots", x = 430, y = 10, width = 80, height = 30},
        {name = "Research", x = 520, y = 10, width = 80, height = 30},
        {name = "Help", x = 610, y = 10, width = 80, height = 30},
        {name = "Settings", x = 700, y = 10, width = 80, height = 30}
    }
    
    -- Update panel dimensions
    resource_panel.width = base_resource_panel.width * ui_scale
    resource_panel.height = base_resource_panel.height * ui_scale
    
    pollution_panel.x = base_pollution_panel.x * ui_scale
    pollution_panel.width = base_pollution_panel.width * ui_scale
    pollution_panel.height = base_pollution_panel.height * ui_scale
    
    robot_panel.y = base_robot_panel.y * ui_scale
    robot_panel.width = base_robot_panel.width * ui_scale
    robot_panel.height = base_robot_panel.height * ui_scale
    
    research_panel.y = base_research_panel.y * ui_scale
    research_panel.width = base_research_panel.width * ui_scale
    research_panel.height = base_research_panel.height * ui_scale
    
    help_panel.x = base_help_panel.x * ui_scale
    help_panel.y = base_help_panel.y * ui_scale
    help_panel.width = base_help_panel.width * ui_scale
    help_panel.height = base_help_panel.height * ui_scale
    
    settings_panel.x = base_settings_panel.x * ui_scale
    settings_panel.y = base_settings_panel.y * ui_scale
    settings_panel.width = base_settings_panel.width * ui_scale
    settings_panel.height = base_settings_panel.height * ui_scale
    
    -- Update button positions and sizes
    for i, base_button in ipairs(base_buttons) do
        nav_buttons[i].x = base_button.x * ui_scale
        nav_buttons[i].width = base_button.width * ui_scale
        nav_buttons[i].height = base_button.height * ui_scale
    end
    
    -- Update tooltip width
    tooltip.width = 200 * ui_scale
    
    -- Reinitialize robot buttons with new positions
    ui.initRobotButtons()
end

return ui 