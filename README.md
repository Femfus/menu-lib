# Vantura UI Library - Documentation

![Vantura UI Example Image](https://raw.githubusercontent.com/Femfus/menu-lib/main/assets/menu-example.png)

Vantura is a premium, modern executor-only GUI library for Roblox, utilizing a clean glassmorphism aesthetic with an animated rainbow topbar accent, smooth widget transitions, and translucent controls.

---

## 🚀 Execution & Loading

Because Vantura utilizes custom asset loaders and file-system configuration handling, it must be loaded using a Roblox-compatible script executor.

### Option A: Remote Load (Recommended)
This method grabs the latest stable code straight from the GitHub repository.

```lua
local Vantura = loadstring(game:HttpGet("https://raw.githubusercontent.com/Femfus/menu-lib/main/library.lua"))()

local GUI = Vantura:Create({
    Name = "Counter-Strike Client",
    Size = UDim2.fromOffset(620, 400)
})
```

### Option B: Local Load (Workspace)
If you are developing locally, save `library.lua` into your executor's `workspace` folder under a folder named `ui lib`, then execute:

```lua
local content = readfile("ui lib/library.lua")
local Vantura = loadstring(content)()
```

---

## 🛠️ API Reference

### 1. Creating the Window
Instantiates the main GUI frame and starts the animated progress loading bar.

```lua
local GUI = Vantura:Create({
    Name = "Window Title",   -- Title string
    Size = UDim2.fromOffset(620, 400) -- Default scale sizes
})
```

- **`GUI:SetSize(UDim2)`**: Scales the window dynamically on the fly.
- **`GUI:Destroy()`**: Cleans up all connections, icons, and removes the interface.
- **`GUI:Notification({ Name = string, Description = string, Duration = float })`**: Spawns a sleek slide-in notification toast on the bottom right.

---

### 2. Adding Tabs
Creates sidebar navigation elements. Icons are automatically downloaded and cached locally.

```lua
local GeneralTab = GUI:Tab({
    Name = "General",
    Icon = "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/aimbot.png"
})
```

---

### 3. Adding Widgets

All widgets must be added to a created tab object.

#### A. Toggle Checkbox
Creates a simple true/false option toggle. Returns a controller object to programmatically get or set its state.

```lua
local toggleController = GeneralTab:Toggle({
    Name = "Enable Feature",
    Description = "Subtext describing what this feature does.", -- (Optional)
    StartingState = false,
    Callback = function(state)
        print("Toggled to: ", state)
    end
})

-- Controller API:
-- toggleController:SetState(boolean)
-- toggleController:GetState() -> boolean
```

#### B. Executable Button
Creates a clickable button widget.

```lua
GeneralTab:Button({
    Name = "Execute Script",
    Description = "Run secondary command immediately.", -- (Optional)
    Callback = function()
        print("Button Clicked!")
    end
})
```

#### C. Dropdown Menu
Creates a selection list. Automatically collapses other active dropdowns and increases panel scrolling range when clicked.

```lua
local dropdownController = GeneralTab:Dropdown({
    Name = "Walk Speed",
    Description = "Modify walking speed modifier.", -- (Optional)
    Options = {"16 (Normal)", "32 (Fast)", "64 (Extreme)"},
    Default = "16 (Normal)",
    Callback = function(selectedOption)
        print("Selected: ", selectedOption)
    end
})

-- Controller API:
-- dropdownController:Set(string)
-- dropdownController:Get() -> string
-- dropdownController:Collapse()
```

#### D. TextInput Field
Creates a text-box region for custom string inputs (e.g. custom configuration names).

```lua
local textController = GeneralTab:TextInput({
    Name = "Config File Name",
    Placeholder = "Enter name here...",
    Default = "default_config",
    Description = "Name used for local file saving.", -- (Optional)
    Callback = function(textValue)
        print("User typed: ", textValue)
    end
})

-- Controller API:
-- textController:Set(string)
-- textController:Get() -> string
```

---

## 💾 Local Configuration Saving

You can save and load configurations to the executor's workspace as JSON files using the values stored in your widgets registry.

```lua
-- Save active settings to local file
local HttpService = game:GetService("HttpService")
local configData = {}

for key, widget in pairs(widgets) do
    if widget.GetState then
        configData[key] = widget:GetState()
    elseif widget.Get then
        configData[key] = widget:Get()
    end
end

writefile("my_config.json", HttpService:JSONEncode(configData))
```
