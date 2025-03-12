-- project-clicker - Configuration Module
-- Central location for all game parameters and settings

local config = {}

-- World settings
config.world = {
    width = 4000,      -- World width
    height = 1200,     -- World height
    ground_height = 900, -- Height of the ground from bottom
    grid_size = 50     -- Size of grid cells
}

-- Resource generation settings
config.resources = {
    initial = {
        wood = 15,    -- Number of wood resources to generate
        stone = 12,   -- Number of stone resources to generate
        food = 10     -- Number of food resources to generate
    },
    min_bank_distance = 200, -- Minimum distance from resource banks
    types = {
        wood = {
            name = "Wood",
            color = {0.8, 0.6, 0.4},
            click_value = 1,
            pollution_per_click = 0.1,
            size = 30,
            bits = {
                min = 20,  -- Minimum bits for closest resources
                max = 80   -- Maximum bits for furthest resources
            }
        },
        stone = {
            name = "Stone",
            color = {0.7, 0.7, 0.7},
            click_value = 1,
            pollution_per_click = 0.2,
            size = 25,
            bits = {
                min = 20,
                max = 80
            }
        },
        food = {
            name = "Food",
            color = {0.5, 0.8, 0.3},
            click_value = 1,
            pollution_per_click = 0.05,
            size = 20,
            bits = {
                min = 20,
                max = 80
            }
        }
    },
    bits = {
        size = 3,        -- Size of resource bits
        initial_vx_range = {-30, 30},     -- Initial horizontal velocity range
        initial_vy_range = {-100, -200},  -- Initial vertical velocity range
        click_bits_to_generate = 15       -- How many bits generated per click
    }
}

-- Robot settings
config.robots = {
    types = {
        GATHERER = {
            name = "Gatherer",
            description = "Automatically gathers resources",
            cost = {Wood = 50, Stone = 30},
            gather_rate = 0.2,
            pollution = 1,
            size = 16,
            cooldown = 2  -- Gathering takes 2 seconds
        },
        TRANSPORTER = {
            name = "Transporter",
            description = "Increases resource gathering efficiency",
            cost = {Wood = 30, Stone = 50},
            efficiency_bonus = 0.1,
            pollution = 0.5,
            size = 16,
            speed = 80    -- Movement speed
        },
        RECYCLER = {
            name = "Recycler",
            description = "Reduces pollution from activities",
            cost = {Wood = 70, Stone = 40},
            pollution_reduction = 0.2,
            pollution = 0.2,
            size = 16,
            speed = 30    -- Movement speed
        }
    }
}

-- Building settings
config.buildings = {
    types = {
        LUMBER_MILL = {
            name = "Lumber Mill",
            description = "Automatically produces wood over time",
            cost = {Wood = 50, Stone = 25},
            production = {Wood = 0.5},
            pollution = 5,
            size = 16
        },
        QUARRY = {
            name = "Quarry",
            description = "Automatically produces stone over time",
            cost = {Wood = 40, Stone = 40},
            production = {Stone = 0.4},
            pollution = 7,
            size = 16
        },
        FARM = {
            name = "Farm",
            description = "Automatically produces food over time",
            cost = {Wood = 30, Stone = 20},
            production = {Food = 0.3},
            pollution = 2,
            size = 16
        },
        SOLAR_PANEL = {
            name = "Solar Panel",
            description = "Reduces pollution over time",
            cost = {Wood = 20, Stone = 50},
            production = {},
            pollution = -10,
            size = 16
        }
    }
}

-- Pollution settings
config.pollution = {
    max_level = 100,
    natural_recovery = 0.05,
    colors = {
        LOW = {1, 1, 1, 0.1},
        MEDIUM = {1, 1, 1, 0.2},
        HIGH = {1, 1, 1, 0.3}
    },
    effects = {
        thresholds = {20, 50, 80},
        resource_penalties = {0.1, 0.3, 0.5},
        robot_penalties = {0, 0.1, 0.3}
    }
}

-- Collection settings
config.collection = {
    auto_collect_radius = 150,
    auto_collect_cooldown = 1.5,
    collection_animation_duration = 1.5
}

-- Camera settings
config.camera = {
    min_scale = 0.5,
    max_scale = 2.0,
    smooth_factor = 5,
    edge_scroll_margin = 30,
    edge_scroll_speed = 300,
    key_scroll_speed = 300
}

-- Calculate dependent values
function config.init()
    -- Calculate ground level based on world height and ground height
    config.world.ground_level = config.world.ground_height - config.world.height/2
    config.world.horizon_level = config.world.ground_level - 200
    
    -- Set colors
    config.world.sky_color = {0.1, 0.1, 0.1}
    config.world.ground_color = {0.2, 0.2, 0.2}
    config.world.underground_color = {0.1, 0.1, 0.1}
end

return config