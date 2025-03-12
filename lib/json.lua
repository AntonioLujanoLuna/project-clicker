--
-- json.lua
--
-- A simple JSON encoding/decoding library for Lua
-- Based on the cjson module but simplified for our needs
--

local json = {}

-- Encode a Lua value to JSON
function json.encode(value)
    local encode_value
    
    local encode_map = {
        ["nil"] = function() return "null" end,
        ["boolean"] = function(v) return v and "true" or "false" end,
        ["number"] = function(v) return tostring(v) end,
        ["string"] = function(v)
            v = v:gsub("\\", "\\\\")
            v = v:gsub('"', '\\"')
            v = v:gsub("\n", "\\n")
            v = v:gsub("\r", "\\r")
            v = v:gsub("\t", "\\t")
            return '"' .. v .. '"'
        end,
        ["table"] = function(t)
            -- Check if table is an array
            local is_array = true
            local n = 0
            
            for k, _ in pairs(t) do
                if type(k) ~= "number" or k <= 0 or math.floor(k) ~= k then
                    is_array = false
                    break
                end
                n = n + 1
            end
            
            if is_array and n > 0 then
                -- Encode as array
                local parts = {}
                for i = 1, n do
                    parts[i] = encode_value(t[i])
                end
                return "[" .. table.concat(parts, ",") .. "]"
            else
                -- Encode as object
                local parts = {}
                for k, v in pairs(t) do
                    if type(k) == "string" or type(k) == "number" then
                        table.insert(parts, json.encode(tostring(k)) .. ":" .. encode_value(v))
                    end
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
        end
    }
    
    encode_value = function(v)
        local t = type(v)
        local encoder = encode_map[t]
        if encoder then
            return encoder(v)
        else
            error("Cannot encode " .. t .. " to JSON")
        end
    end
    
    return encode_value(value)
end

-- Decode a JSON string to a Lua value
function json.decode(str)
    local pos = 1
    local char = function() return string.sub(str, pos, pos) end
    
    local next_char = function()
        pos = pos + 1
        return char()
    end
    
    local skip_whitespace = function()
        while pos <= #str and string.match(char(), "^[ \t\n\r]$") do
            pos = pos + 1
        end
    end
    
    local decode_value
    
    local decode_string = function()
        local result = ""
        assert(char() == '"', "Expected string")
        next_char() -- Skip opening quote
        
        while pos <= #str and char() ~= '"' do
            if char() == '\\' then
                next_char() -- Skip backslash
                local c = char()
                if c == 'n' then result = result .. '\n'
                elseif c == 'r' then result = result .. '\r'
                elseif c == 't' then result = result .. '\t'
                elseif c == 'u' then
                    -- Skip Unicode for simplicity
                    next_char() next_char() next_char() next_char()
                else result = result .. c
                end
            else
                result = result .. char()
            end
            next_char()
        end
        
        assert(char() == '"', "Unterminated string")
        next_char() -- Skip closing quote
        return result
    end
    
    local decode_number = function()
        local start = pos
        while pos <= #str and string.match(char(), "^[%d%.eE%+%-]$") do
            next_char()
        end
        return tonumber(string.sub(str, start, pos - 1))
    end
    
    local decode_array = function()
        local result = {}
        assert(char() == '[', "Expected array")
        next_char() -- Skip opening bracket
        skip_whitespace()
        
        if char() == ']' then
            next_char() -- Skip closing bracket
            return result
        end
        
        while true do
            table.insert(result, decode_value())
            skip_whitespace()
            
            if char() == ']' then
                next_char() -- Skip closing bracket
                return result
            end
            
            assert(char() == ',', "Expected comma or closing bracket")
            next_char() -- Skip comma
            skip_whitespace()
        end
    end
    
    local decode_object = function()
        local result = {}
        assert(char() == '{', "Expected object")
        next_char() -- Skip opening brace
        skip_whitespace()
        
        if char() == '}' then
            next_char() -- Skip closing brace
            return result
        end
        
        while true do
            skip_whitespace()
            assert(char() == '"', "Expected string key")
            local key = decode_string()
            
            skip_whitespace()
            assert(char() == ':', "Expected colon")
            next_char() -- Skip colon
            
            skip_whitespace()
            result[key] = decode_value()
            
            skip_whitespace()
            if char() == '}' then
                next_char() -- Skip closing brace
                return result
            end
            
            assert(char() == ',', "Expected comma or closing brace")
            next_char() -- Skip comma
        end
    end
    
    decode_value = function()
        skip_whitespace()
        
        local c = char()
        if c == '{' then return decode_object()
        elseif c == '[' then return decode_array()
        elseif c == '"' then return decode_string()
        elseif string.match(c, "^[%d%-]$") then return decode_number()
        elseif c == 't' then
            assert(string.sub(str, pos, pos + 3) == "true", "Expected 'true'")
            pos = pos + 4
            return true
        elseif c == 'f' then
            assert(string.sub(str, pos, pos + 4) == "false", "Expected 'false'")
            pos = pos + 5
            return false
        elseif c == 'n' then
            assert(string.sub(str, pos, pos + 3) == "null", "Expected 'null'")
            pos = pos + 4
            return nil
        else
            error("Unexpected character: " .. c)
        end
    end
    
    return decode_value()
end

return json 