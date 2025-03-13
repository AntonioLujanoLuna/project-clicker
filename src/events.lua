-- project-clicker - Events Module
-- Centralized event system for decoupling game components

local log = require("src.log")

local events = {}
events.handlers = {}

-- Register an event handler
function events.on(event_name, handler_function)
    if not events.handlers[event_name] then
        events.handlers[event_name] = {}
    end
    table.insert(events.handlers[event_name], handler_function)
    log.debug("Registered handler for event: " .. event_name)
end

-- Trigger an event
function events.trigger(event_name, ...)
    if events.handlers[event_name] then
        log.debug("Triggering event: " .. event_name .. " with " .. #events.handlers[event_name] .. " handlers")
        for _, handler in ipairs(events.handlers[event_name]) do
            handler(...)
        end
    else
        log.debug("Triggered event: " .. event_name .. " (no handlers)")
    end
end

-- Remove a specific handler
function events.off(event_name, handler_function)
    if events.handlers[event_name] then
        for i, handler in ipairs(events.handlers[event_name]) do
            if handler == handler_function then
                table.remove(events.handlers[event_name], i)
                log.debug("Removed handler for event: " .. event_name)
                break
            end
        end
    end
end

-- Clear all handlers for an event
function events.clear(event_name)
    events.handlers[event_name] = {}
    log.debug("Cleared all handlers for event: " .. event_name)
end

return events
