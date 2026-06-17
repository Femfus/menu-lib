-- Example script demonstrating how to use the custom Vantura-style UI Library.
-- In a Roblox executor, you can load this script. It loads the library file remotely or locally.

-- Load the library (Choose Local Workspace or Remote GitHub)
local Vantura
local success, err = pcall(function()
    -- OPTION A: Load from GitHub (Recommended for distribution)
    -- Uncomment the line below to load remotely:
    Vantura = loadstring(game:HttpGet("https://raw.githubusercontent.com/Femfus/menu-lib/main/library.lua?t=" .. os.time()))()

    -- OPTION B: Load from local executor workspace (Default for local development)
    if not Vantura then
        if readfile then
            local content
            pcall(function() content = readfile("ui lib/library.lua") end)
            if not content then
                pcall(function() content = readfile("library.lua") end)
            end
            
            if content then
                Vantura = loadstring(content)()
            else
                error("Could not find local library.lua in executor's workspace folder.")
            end
        else
            -- Fallback for LocalPlugins / Command bar testing in studio
            Vantura = require(script.Parent.library)
        end
    end
end)

if not Vantura or not success then
    warn("Failed to load library, error: " .. tostring(err))
    warn("For local testing, verify library.lua is inside your executor's workspace folder.")
    warn("For remote execution, make sure to configure the game:HttpGet URL.")
    return
end

-- Initialize the GUI container matching the CS:GO style Title
-- This automatically triggers the loading screen sequence before showing the menu
-- Initialize the GUI container matching the CS:GO style Title
-- This automatically triggers the loading screen sequence before showing the menu
local GUI = Vantura:Create({
    Name = "Counter-Strike Client",
    Size = UDim2.fromOffset(620, 400)
})

-- Queue initial notification after UI loads
task.spawn(function()
    task.wait(2.2) -- Wait for loading screen to fade out
    GUI:Notification({
        Name = "Client Loaded",
        Description = "Premium modules ready to configure.",
        Duration = 4.0
    })
end)

-- Centralized registry for configurations
local widgets = {}

-- Tab 1: Aimbot (General Tab)
local AimbotTab = GUI:Tab({
    Name = "General",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/aimbot.png" -- Aimbot PNG
})

widgets["Aimbot"] = AimbotTab:Toggle({
    Name = "Aimbock",
    Description = "Enables automatic target tracking assistance.",
    StartingState = false,
    Callback = function(state)
        GUI:Notification({
            Name = "Aimbot Toggle",
            Description = state and "Aim Assist activated." or "Aim Assist deactivated.",
            Duration = 3.0
        })
    end
})

widgets["ForceAttack"] = AimbotTab:Toggle({
    Name = "Force Attack",
    StartingState = false,
    Callback = function(state)
        GUI:Notification({
            Name = "Force Attack",
            Description = state and "Force attack override enabled." or "Force attack override disabled.",
            Duration = 3.0
        })
    end
})

widgets["PreferLastTarget"] = AimbotTab:Toggle({
    Name = "Prefer last target",
    StartingState = true,
    Callback = function(state)
        print("[Client] Prefer Last Target: " .. tostring(state))
    end
})

widgets["CheckWalls"] = AimbotTab:Toggle({
    Name = "Check Walls",
    StartingState = true,
    Callback = function(state)
        print("[Client] Wall Check active: " .. tostring(state))
    end
})

-- Player WalkSpeed control dropdown
widgets["PlayerSpeed"] = AimbotTab:Dropdown({
    Name = "Walk Speed Override",
    Description = "Alters character movement speed value.",
    Options = {"16 (Normal)", "32 (Fast)", "64 (Extreme)"},
    Default = "16 (Normal)",
    Callback = function(val)
        local numericVal = tonumber(val:match("^%d+")) or 16
        task.spawn(function()
            local p = game:GetService("Players").LocalPlayer
            local c = p.Character or p.CharacterAdded:Wait()
            local hum = c:WaitForChild("Humanoid")
            hum.WalkSpeed = numericVal
        end)
        GUI:Notification({
            Name = "Movement Modifier",
            Description = "Player speed modified to " .. numericVal .. " studs.",
            Duration = 2.5
        })
    end
})


-- Tab 2: Triggerbot
local TriggerTab = GUI:Tab({
    Name = "Triggerbot",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/exploits.png" -- Exploits PNG
})

widgets["TriggerbotActive"] = TriggerTab:Toggle({
    Name = "Triggerbot Active",
    StartingState = false,
    Callback = function(state)
        GUI:Notification({
            Name = "Triggerbot Active",
            Description = state and "Auto fire enabled." or "Auto fire disabled.",
            Duration = 3.0
        })
    end
})

widgets["TriggerbotFriendlyFire"] = TriggerTab:Toggle({
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
        GUI:Notification({
            Name = "Hitbox Optimized",
            Description = "Trigger response optimized to 1ms intervals.",
            Duration = 3.5
        })
    end
})


-- Dynamic built-in ESP functionality
local espOptions = {
    enabled = false,
    names = true,
    boxes = true,
    healthBars = true,
    limitDistance = false
}

local espObjects = {}

local function setupCharacter(player, char)
    if not char then return end
    if espObjects[player] then
        pcall(function() espObjects[player]:Destroy() end)
        espObjects[player] = nil
    end

    local folder = Instance.new("Folder")
    folder.Name = "Vantura_ESP_" .. player.Name

    -- Outline Chams (Boxes substitute)
    local highlight = Instance.new("Highlight")
    highlight.Name = "Chams"
    highlight.FillColor = Color3.fromRGB(220, 38, 38)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0.1
    highlight.Adornee = char
    highlight.Enabled = espOptions.enabled and espOptions.boxes
    highlight.Parent = folder

    -- Billboard for Name & Health
    local head = char:WaitForChild("Head", 5)
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameTag"
        billboard.Size = UDim2.new(0, 120, 0, 32)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Enabled = espOptions.enabled and espOptions.names
        billboard.Parent = folder

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 10
        nameLabel.Parent = billboard

        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        healthLabel.Text = humanoid and ("HP: " .. math.floor(humanoid.Health)) or "HP: 100"
        healthLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        healthLabel.Font = Enum.Font.GothamMedium
        healthLabel.TextSize = 9
        healthLabel.Visible = espOptions.healthBars
        healthLabel.Parent = billboard

        if humanoid then
            humanoid.HealthChanged:Connect(function(health)
                healthLabel.Text = "HP: " .. math.floor(health)
            end)
        end
    end

    folder.Parent = char
    espObjects[player] = folder
end

local function applyESPState()
    for player, folder in pairs(espObjects) do
        pcall(function()
            local highlight = folder:FindFirstChild("Chams")
            if highlight then
                highlight.Enabled = espOptions.enabled and espOptions.boxes
            end
            local billboard = folder:FindFirstChild("NameTag")
            if billboard then
                billboard.Enabled = espOptions.enabled and espOptions.names
                local healthLabel = billboard:FindFirstChild("HealthLabel")
                if healthLabel then
                    healthLabel.Visible = espOptions.healthBars
                end
            end
        end)
    end
end

local function initESP()
    local Players = game:GetService("Players")
    local function monitorPlayer(player)
        if player == Players.LocalPlayer then return end
        player.CharacterAdded:Connect(function(char)
            setupCharacter(player, char)
        end)
        if player.Character then
            task.spawn(setupCharacter, player, player.Character)
        end
    end

    Players.PlayerAdded:Connect(monitorPlayer)
    for _, player in ipairs(Players:GetPlayers()) do
        monitorPlayer(player)
    end

    Players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            pcall(function() espObjects[player]:Destroy() end)
            espObjects[player] = nil
        end
    end)
end

task.spawn(initESP)


-- Tab 3: Visuals (ESP options)
local VisualsTab = GUI:Tab({
    Name = "Visuals",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/world.png" -- World PNG
})

-- Master ESP Toggle
widgets["EnableESP"] = VisualsTab:Toggle({
    Name = "Enable Master ESP",
    StartingState = false,
    Callback = function(state)
        espOptions.enabled = state
        applyESPState()
        GUI:Notification({
            Name = "Visuals ESP",
            Description = state and "Master ESP modules active." or "Master ESP cleared.",
            Duration = 3.0
        })
    end
})

widgets["ESPNames"] = VisualsTab:Toggle({
    Name = "Show Player Names",
    StartingState = true,
    Callback = function(state)
        espOptions.names = state
        applyESPState()
    end
})

widgets["ESPBoxes"] = VisualsTab:Toggle({
    Name = "Show Box ESP",
    StartingState = true,
    Callback = function(state)
        espOptions.boxes = state
        applyESPState()
    end
})

widgets["ESPHashBars"] = VisualsTab:Toggle({
    Name = "Show Health Bars",
    StartingState = true,
    Callback = function(state)
        espOptions.healthBars = state
        applyESPState()
    end
})

widgets["ESPLimitDistance"] = VisualsTab:Toggle({
    Name = "Limit Render Distance",
    StartingState = false,
    Callback = function(state)
        espOptions.limitDistance = state
        applyESPState()
    end
})


-- Tab 4: Configs & Settings
local SettingsTab = GUI:Tab({
    Name = "Settings",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/settings.png" -- Settings PNG
})

-- Dynamic resizing dropdown
widgets["MenuSize"] = SettingsTab:Dropdown({
    Name = "Change Menu Size",
    Options = {"Compact", "Default", "Large"},
    Default = "Default",
    Callback = function(val)
        if val == "Compact" then
            GUI:SetSize(UDim2.fromOffset(520, 340))
        elseif val == "Default" then
            GUI:SetSize(UDim2.fromOffset(620, 400))
        elseif val == "Large" then
            GUI:SetSize(UDim2.fromOffset(720, 460))
        end
        GUI:Notification({
            Name = "Interface Size",
            Description = "Menu scaled to " .. val .. " bounds.",
            Duration = 2.5
        })
    end
})

-- Custom Config Name input
local configFilename = "default_config"
widgets["ConfigName"] = SettingsTab:TextInput({
    Name = "Config File Name",
    Placeholder = "Enter config name...",
    Default = "default_config",
    Description = "Name of the config file to save or load.",
    Callback = function(val)
        if val ~= "" then
            configFilename = val:gsub("[^%w_%-]", "")
        end
    end
})

SettingsTab:Button({
    Name = "Save Config",
    Description = "Saves active features to local JSON configuration file.",
    Callback = function()
        local configData = {}
        for key, widget in pairs(widgets) do
            if widget.GetState then
                configData[key] = widget:GetState()
            elseif widget.Get then
                configData[key] = widget:Get()
            end
        end

        local success, json = pcall(function() 
            return game:GetService("HttpService"):JSONEncode(configData) 
        end)
        
        local fsSuccess = false
        local filename = configFilename .. ".json"
        if success then
            local pcallFs = pcall(function()
                if writefile then
                    writefile(filename, json)
                    fsSuccess = true
                end
            end)
            fsSuccess = fsSuccess and pcallFs
        end

        if fsSuccess then
            GUI:Notification({
                Name = "Configuration",
                Description = "Saved configuration to " .. filename .. ".",
                Duration = 4.0
            })
        else
            GUI:Notification({
                Name = "Save Failed",
                Description = "Local filesystem access is not supported by executor.",
                Duration = 4.0
            })
        end
    end
})

SettingsTab:Button({
    Name = "Load Config",
    Description = "Applies stored configurations from local JSON file.",
    Callback = function()
        local successLoad = false
        local dataLoaded = nil
        local filename = configFilename .. ".json"

        pcall(function()
            if isfile and isfile(filename) and readfile then
                local content = readfile(filename)
                if content then
                    local decodeSuccess, decoded = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(content)
                    end)
                    if decodeSuccess then
                        dataLoaded = decoded
                        successLoad = true
                    end
                end
            end
        end)

        if successLoad and dataLoaded then
            for key, val in pairs(dataLoaded) do
                local widget = widgets[key]
                if widget then
                    if widget.SetState and type(val) == "boolean" then
                        widget:SetState(val)
                    elseif widget.Set and type(val) == "string" then
                        widget:Set(val)
                    end
                end
            end
            GUI:Notification({
                Name = "Configuration",
                Description = "Applied configuration from " .. filename .. ".",
                Duration = 4.0
            })
        else
            GUI:Notification({
                Name = "Load Failed",
                Description = filename .. " not found or corrupted.",
                Duration = 4.0
            })
        end
    end
})

SettingsTab:Button({
    Name = "Unload GUI",
    Description = "Destroys the screen interface and disconnects connections.",
    Callback = function()
        GUI:Destroy()
    end
})

print("[Client] Vantura UI successfully initialized.")
