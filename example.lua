-- Example script demonstrating how to use the custom Mercury-style UI Library.
-- In a Roblox executor, you can load this script. It loads the library file remotely or locally.

-- Load the library (Choose Local Workspace or Remote GitHub)
local Mercury
local success, err = pcall(function()
    -- OPTION A: Load from GitHub (Recommended for distribution)
    -- Uncomment the line below to load remotely:
    Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/Femfus/menu-lib/main/library.lua"))()

    -- OPTION B: Load from local executor workspace (Default for local development)
    if not Mercury then
        if readfile then
            local content
            pcall(function() content = readfile("ui lib/library.lua") end)
            if not content then
                pcall(function() content = readfile("library.lua") end)
            end
            
            if content then
                Mercury = loadstring(content)()
            else
                error("Could not find local library.lua in executor's workspace folder.")
            end
        else
            -- Fallback for LocalPlugins / Command bar testing in studio
            Mercury = require(script.Parent.library)
        end
    end
end)

if not Mercury or not success then
    warn("Failed to load library, error: " .. tostring(err))
    warn("For local testing, verify library.lua is inside your executor's workspace folder.")
    warn("For remote execution, make sure to configure the game:HttpGet URL.")
    return
end

-- Initialize the GUI container matching the CS:GO style Title
local GUI = Mercury:Create({
    Name = "Counter-Strike Client",
    Size = UDim2.fromOffset(620, 400)
})

-- Tab 1: Aimbot (General Tab)
local AimbotTab = GUI:Tab({
    Name = "General",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/aimbot.png" -- Aimbot PNG
})

AimbotTab:Toggle({
    Name = "Aimbock",
    StartingState = false,
    Callback = function(state)
        print("[Client] Aimbot enabled: " .. tostring(state))
    end
})

AimbotTab:Toggle({
    Name = "Force Attack",
    StartingState = false,
    Callback = function(state)
        print("[Client] Force Attack set to: " .. tostring(state))
    end
})

AimbotTab:Toggle({
    Name = "Prefer last target",
    StartingState = true,
    Callback = function(state)
        print("[Client] Prefer Last Target: " .. tostring(state))
    end
})

AimbotTab:Toggle({
    Name = "Check Walls",
    StartingState = true,
    Callback = function(state)
        print("[Client] Wall Check active: " .. tostring(state))
    end
})

AimbotTab:Toggle({
    Name = "Shoot while blind",
    StartingState = false,
    Callback = function(state)
        print("[Client] Shoot While Blind: " .. tostring(state))
    end
})


-- Tab 2: Triggerbot
local TriggerTab = GUI:Tab({
    Name = "Triggerbot",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/exploits.png" -- Exploits PNG
})

TriggerTab:Toggle({
    Name = "Triggerbot Active",
    StartingState = false,
    Callback = function(state)
        print("[Client] Triggerbot set to: " .. tostring(state))
    end
})

TriggerTab:Toggle({
    Name = "Triggerbot Friendly Fire",
    StartingState = false,
    Callback = function(state)
        print("[Client] Friendly Fire set to: " .. tostring(state))
    end
})

TriggerTab:Button({
    Name = "Optimize Hitbox Delay",
    Description = "Forces trigger reaction to execute within 1ms intervals.",
    Callback = function()
        print("[Client] Optimizing Hitbox Delay...")
    end
})


-- Tab 3: Visuals (ESP options)
local VisualsTab = GUI:Tab({
    Name = "Visuals",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/world.png" -- World PNG
})

VisualsTab:Toggle({
    Name = "Enable ESP Outlines",
    StartingState = false,
    Callback = function(state)
        print("[Client] ESP Outline rendering: " .. tostring(state))
    end
})

VisualsTab:Toggle({
    Name = "Box ESP style",
    StartingState = false,
    Callback = function(state)
        print("[Client] Border Box styling: " .. tostring(state))
    end
})

VisualsTab:Toggle({
    Name = "Name & Distance tags",
    StartingState = true,
    Callback = function(state)
        print("[Client] Billboard Labels active: " .. tostring(state))
    end
})


-- Tab 4: Configs & Settings
local SettingsTab = GUI:Tab({
    Name = "Settings",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/settings.png" -- Settings PNG
})

SettingsTab:Button({
    Name = "Save Config (Default)",
    Description = "Saves active features to local JSON configuration.",
    Callback = function()
        print("[Client] Configuration saved to workspace/default.json")
    end
})

SettingsTab:Button({
    Name = "Load Config (Default)",
    Description = "Applies stored configurations from local JSON file.",
    Callback = function()
        print("[Client] Configuration successfully loaded.")
    end
})

print("[Client] Premium UI successfully initialized.")
