-- project-clicker - Logging Module
-- Provides logging functionality for debugging and error tracking

local log = {}

log.LEVEL = {
    DEBUG = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4,
    CRITICAL = 5
}

log.level = log.LEVEL.INFO -- Default level

function log.setLevel(level)
    log.level = level
end

function log.format(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    return string.format("[%s] [%s] %s", timestamp, level, message)
end

function log.debug(message)
    if log.level <= log.LEVEL.DEBUG then
        print(log.format("DEBUG", message))
    end
end

function log.info(message)
    if log.level <= log.LEVEL.INFO then
        print(log.format("INFO", message))
    end
end

function log.warning(message)
    if log.level <= log.LEVEL.WARNING then
        print(log.format("WARNING", message))
    end
end

function log.error(message)
    if log.level <= log.LEVEL.ERROR then
        print(log.format("ERROR", message))
    end
end

function log.critical(message)
    if log.level <= log.LEVEL.CRITICAL then
        print(log.format("CRITICAL", message))
        
        -- Write critical errors to a file
        local file = io.open("error.log", "a")
        if file then
            file:write(log.format("CRITICAL", message) .. "\n")
            file:close()
        end
    end
end

return log 