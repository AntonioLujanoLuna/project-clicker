-- project-clicker - Utilities Module
-- Provides utility functions for the game

local log = require("src.log")

local utils = {}

-- Function to safely call functions and handle errors
function utils.safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        log.error("Error in function call: " .. tostring(result))
        return nil, result
    end
    return result
end

-- Deep copy a table (useful for save/load)
function utils.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[utils.deepCopy(orig_key)] = utils.deepCopy(orig_value)
        end
        setmetatable(copy, utils.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Check if a file exists
function utils.fileExists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Format a number with commas for thousands
function utils.formatNumber(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

return utils 