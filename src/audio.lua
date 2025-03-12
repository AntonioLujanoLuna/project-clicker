-- project-clicker - Audio Module
-- Manages sound effects and music

local log = require("src.log")

local audio = {}

-- Sound effects
audio.sounds = {
    click = nil,
    collect = nil,
    build = nil,
    depleted = nil,
    robot_create = nil,
    error = nil,
    ambient = nil
}

-- Audio settings
audio.volume = {
    master = 1.0,
    sfx = 0.8,
    music = 0.5
}

audio.enabled = true

function audio.load()
    log.info("Loading audio assets...")
    
    -- Create assets/sounds directory if it doesn't exist
    if not love.filesystem.getInfo("assets/sounds") then
        love.filesystem.createDirectory("assets/sounds")
    end
    
    -- Try to load sound effects, with fallbacks for missing files
    local function loadSound(name, type)
        local path = "assets/sounds/" .. name .. ".wav"
        if love.filesystem.getInfo(path) then
            audio.sounds[name] = love.audio.newSource(path, type or "static")
            log.info("Loaded sound: " .. path)
            return true
        else
            log.warning("Sound file not found: " .. path .. " - using placeholder")
            -- Create a placeholder sound
            audio.createPlaceholderSound(name, type)
            return false
        end
    end
    
    -- Load sound effects
    loadSound("click", "static")
    loadSound("collect", "static")
    loadSound("build", "static")
    loadSound("depleted", "static")
    loadSound("robot_create", "static")
    loadSound("error", "static")
    
    -- Load ambient sound (looping)
    if loadSound("ambient", "stream") and audio.sounds.ambient then
        audio.sounds.ambient:setLooping(true)
    end
    
    -- Start ambient sound
    audio.playAmbient()
end

-- Create a placeholder sound if the real one doesn't exist
function audio.createPlaceholderSound(name, type)
    -- Create a simple beep sound as placeholder
    local sample_rate = 44100
    local duration = 0.2
    local frequency = 440 -- A4 note
    
    if name == "error" then frequency = 220 -- Lower for error
    elseif name == "collect" then frequency = 660 -- Higher for collect
    elseif name == "build" then frequency = 550 -- Medium-high for build
    elseif name == "depleted" then frequency = 330 -- Medium-low for depleted
    elseif name == "robot_create" then frequency = 880 -- Highest for robot creation
    elseif name == "ambient" then 
        duration = 2.0 -- Longer for ambient
        frequency = 110 -- Very low for ambient
    end
    
    local samples = love.sound.newSoundData(math.floor(duration * sample_rate), sample_rate, 16, 1)
    
    for i = 0, samples:getSampleCount() - 1 do
        local t = i / sample_rate
        local value = 0.5 * math.sin(2 * math.pi * frequency * t)
        
        -- Apply fade in/out
        local fade = 1.0
        local fade_time = 0.05
        if t < fade_time then
            fade = t / fade_time
        elseif t > duration - fade_time then
            fade = (duration - t) / fade_time
        end
        
        value = value * fade
        
        -- Clamp to valid range
        value = math.max(-1.0, math.min(1.0, value))
        
        samples:setSample(i, value)
    end
    
    audio.sounds[name] = love.audio.newSource(samples, type or "static")
    
    if name == "ambient" then
        audio.sounds.ambient:setLooping(true)
    end
    
    log.info("Created placeholder sound for: " .. name)
end

function audio.playSound(sound_name)
    if not audio.enabled then return end
    
    local sound = audio.sounds[sound_name]
    if sound then
        -- Create a clone to allow overlapping sounds
        local clone = sound:clone()
        clone:setVolume(audio.volume.master * audio.volume.sfx)
        clone:play()
    else
        log.warning("Attempted to play non-existent sound: " .. sound_name)
    end
end

function audio.playAmbient()
    if not audio.enabled or not audio.sounds.ambient then return end
    
    audio.sounds.ambient:setVolume(audio.volume.master * audio.volume.music)
    audio.sounds.ambient:play()
end

function audio.stopAmbient()
    if audio.sounds.ambient then
        audio.sounds.ambient:stop()
    end
end

function audio.toggleSounds()
    audio.enabled = not audio.enabled
    
    if audio.enabled then
        audio.playAmbient()
        log.info("Audio enabled")
    else
        audio.stopAmbient()
        log.info("Audio disabled")
    end
    
    return audio.enabled
end

function audio.setMasterVolume(volume)
    audio.volume.master = math.max(0, math.min(1, volume))
    
    -- Update ambient volume
    if audio.sounds.ambient then
        audio.sounds.ambient:setVolume(audio.volume.master * audio.volume.music)
    end
    
    log.info("Master volume set to " .. audio.volume.master)
    return audio.volume.master
end

function audio.setSfxVolume(volume)
    audio.volume.sfx = math.max(0, math.min(1, volume))
    log.info("SFX volume set to " .. audio.volume.sfx)
    return audio.volume.sfx
end

function audio.setMusicVolume(volume)
    audio.volume.music = math.max(0, math.min(1, volume))
    
    -- Update ambient volume
    if audio.sounds.ambient then
        audio.sounds.ambient:setVolume(audio.volume.master * audio.volume.music)
    end
    
    log.info("Music volume set to " .. audio.volume.music)
    return audio.volume.music
end

return audio 