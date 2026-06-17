# Vantura UI Library — Developer Documentation & Architecture Guide

This guide details the internals, UI hierarchies, layout systems, component lifecycles, and customization APIs of the Vantura UI Library. It is designed to assist developers in maintaining, extending, or refactoring the library.

---

## 🗺️ Architectural Overview

Vantura is constructed as a structured object-oriented library in Lua, optimized for Roblox exploit execution contexts. It features clean separation between window creation, navigation management (tabs), and interactive controls (widgets).

### UI Hierarchy Tree
```
ScreenGui (ResetOnSpawn = false, ZIndexBehavior = Sibling)
 ├── LoadingFrame (Centered loading window, destroyed on ready)
 ├── ToastContainer (Right-aligned stacking frame for notifications)
 │    └── Toast (Sliding container, progressive timer bar)
 └── MainFrame (The Primary Menu)
      ├── TopAccent (UIGradient-driven animated rainbow line)
      │    └── Cover (Overlay to straighten bottom rounded corners)
      ├── Header (Region configured for drag detection)
      │    └── Title (Window Label)
      ├── IconSidebar (Left strip housing page-group icons)
      │    ├── IconScroll (Scrolling icons list)
      │    └── DestroyButton (Quit button)
      ├── TabSidebar (Sub-navigation for text page buttons)
      │    └── TabScroll (Scrolling list of tab button labels)
      └── PageContainer (Houses individual page ScrollingFrames)
           └── Page (ScrollingFrame per tab, clipsDescendants = false)
```

---

## 🎨 Design System & Glassmorphism Theme

Vantura implements a glassmorphism style theme optimized for dark modes, featuring harmonious grey-black tones, rounded corners, and translucent elements.

### Color Tokens
- **Backgrounds**: `Color3.fromRGB(18, 18, 20)` (Deep grey-black base).
- **Element Overlays**: `Color3.fromRGB(24, 24, 26)` (Lighter accent panels).
- **Secondary Containers**: `Color3.fromRGB(28, 28, 30)` / `Color3.fromRGB(34, 34, 38)`.
- **Borders/Strokes**: `Color3.fromRGB(45, 45, 50)` / `Color3.fromRGB(36, 36, 40)`.
- **Text (Primary)**: `Color3.fromRGB(240, 240, 240)` (Off-white).
- **Text (Secondary)**: `Color3.fromRGB(150, 150, 155)` (Muted grey).

### Translucency Calculations
- Base window containers, sidebars, and individual widgets utilize a background transparency of `0.15` (`BackgroundTransparency = 0.15`).
- This allows active gameplay contexts behind the client UI to be subtly visible, achieving a premium glassmorphic screen overlay.

---

## ⚡ Core Helper Functions

### 1. Drag Handler (`MakeDraggable`)
Enables smooth GUI dragging without frame stuttering.
- **Parameters**: `dragFrame` (trigger region), `parentFrame` (frame that relocates).
- **Methodology**: Listens to `InputBegan` for mouse button or touch triggers, captures start coordinates, and updates placement relative to mouse movement offsets using a `UserInputService.InputChanged` connection.
- **Garbage Collection**: Drag connections are inserted into a central tracking list `globalConnections` to be disconnected on library cleanup.

```lua
local beganConn = dragFrame.InputBegan:Connect(function(input)
    -- Capture input coordinates and parent positions
end)
```

### 2. Custom Asset Loader (`LoadCustomAsset`)
Handles remote asset synchronization for executors.
- **Functionality**: Accepts standard `rbxassetid://` strings or HTTP urls (e.g., pointing to raw PNGs on GitHub).
- **Local Caching**: When an HTTP url is supplied, it downloads the file via `game:HttpGet`, saves it locally to the executor's workspace using `writefile` with a hash prefix, and exposes it using `getcustomasset` to bypass loading delays on consecutive executions.
- **Fallback**: Gracefully falls back to a standard gear icon if file operations are unsupported or fail.

```lua
local function LoadCustomAsset(url)
    -- Local hash caching logic using writefile / getcustomasset
end
```

---

## 📦 Lifecycle & Window Management

### Initialization (`VanturaLib:Create`)
- Generates a randomly named `ScreenGui` to prevent detection by basic script scanners.
- Instantiates a centered `LoadingFrame` with a stylized red progress bar that simulates script verification states before fading out to reveal the main menu.
- Transitions transparency values on all internal panels simultaneously.

### Programmatic Sizing (`window:SetSize`)
Resizes the main panel dynamically. This alters both target dimensions and offsets, recalculating centering positions so the window remains centered.

```lua
function window:SetSize(newSize)
    size = newSize
    mainFrame.Size = size
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
end
```

### Garbage Collection (`window:Destroy`)
Exposes a clean garbage collection API. Calling `:Destroy()` will:
1. Loop through and disconnect all connections stored in `globalConnections` (preventing Roblox memory leaks).
2. Clean up locally cached image icons from the executor's file system using `listfiles` and `delfile`.
3. Destroy the root `ScreenGui` instance.

---

## 🧩 Tab & Widget Layout Mechanics

### Sibling Z-Index Behavior
Roblox `ZIndexBehavior.Sibling` renders elements in order of hierarchy insertion unless explicit values are specified. To prevent lower widgets (such as text boxes or toggles) from overlaying active dropdown lists, Vantura uses dynamic Z-Index Elevation.

```lua
local function expandDropdown()
    elementFrame.ZIndex = 100 -- Elevate parent container frame
    listFrame.Visible = true
end
```

### Dynamic Scrolling Constraints
 Robox scrolling pages natively clip nested elements if `ClipsDescendants = true`. Because dropdown selections must render outside of their parent borders, page scrolling layouts are configured with `ClipsDescendants = false`. 

To prevent options from falling off the bottom of the container, an active layout listener dynamically expands the `CanvasSize` when a dropdown opens, adjusting padding offsets relative to the amount of selections inside:

```lua
pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + (#optionsList * 20) + 15)
end)
```

---

## 🎨 Rainbow Topbar Animation

The premium rainbow accent line at the top of the interface is implemented utilizing a `UIGradient` instance. Instead of shifting the gradient position (which can look pixelated), Vantura dynamically updates the color sequence array in a RenderStepped loop:

```lua
connection = game:GetService("RunService").RenderStepped:Connect(function(delta)
    hueTick = hueTick + delta * 0.15 -- Animation speed modifier
    local keypoints = {}
    for i = 0, 6 do
        local hue = (i / 6 + hueTick) % 1
        table.insert(keypoints, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(hue, 0.85, 1)))
    end
    rainbowGradient.Color = ColorSequence.new(keypoints)
end)
```

---

## 🛠️ Developer Checklist for Custom Widgets

When adding new components to `library.lua`:
1. Ensure the outermost component container uses `BackgroundTransparency = 0.15`.
2. Check if a `Description` property is provided. If so, scale the widget height to `46` to fit the description text label, otherwise scale it to `38`.
3. Add any event connections to the global registry: `table.insert(globalConnections, connection)`.
4. Ensure widgets return a structured controller object `{ Get(), Set() }` supporting configuration loading.
