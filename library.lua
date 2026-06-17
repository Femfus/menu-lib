local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local VanturaLib = {}
VanturaLib.__index = VanturaLib

local globalConnections = {}

-- Helper: Dragging functionality for frames
local function MakeDraggable(dragFrame, parentFrame)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        parentFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    local beganConn = dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position

            local changedConn
            changedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if changedConn then
                        changedConn:Disconnect()
                    end
                end
            end)
        end
    end)

    local changedInputConn = dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    local globalInputConn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local globalEndedConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    table.insert(globalConnections, beganConn)
    table.insert(globalConnections, changedInputConn)
    table.insert(globalConnections, globalInputConn)
    table.insert(globalConnections, globalEndedConn)
end

-- Helper: Create a smooth tween
local function Tween(instance, info, propertyTable)
    local tween = TweenService:Create(instance, info, propertyTable)
    tween:Play()
    return tween
end

-- Helper: Load remote web icons dynamically for Roblox executors
local function LoadCustomAsset(url)
    if not tostring(url):match("^http") then
        return url -- Standard rbxassetid
    end

    -- Gracefully detect SVGs since Roblox cannot render vector images
    if url:lower():match("%.svg$") then
        return "rbxassetid://6034853644"
    end

    local cleanName = url:match("([^/]+)$"):gsub("[^%w%.]", "_")
    local hash = 0
    for i = 1, #url do
        hash = (hash + url:byte(i)) % 100000
    end
    local filepath = "vantura_icons_" .. hash .. "_" .. cleanName

    local success_fs, hasFileSystem = pcall(function() 
        return writefile and isfile and getcustomasset 
    end)
    
    if success_fs and hasFileSystem then
        local exists = false
        pcall(function() exists = isfile(filepath) end)
        
        if not exists then
            local success_download, data = pcall(function() return game:HttpGet(url) end)
            if success_download and data then
                pcall(function() writefile(filepath, data) end)
            end
        end
        
        local assetPath
        local success_asset = pcall(function()
            assetPath = getcustomasset(filepath)
        end)
        
        if success_asset and assetPath then
            return assetPath
        end
    end

    return "rbxassetid://6034853644" 
end

function VanturaLib:Create(options)
    options = options or {}
    local windowTitle = options.Name or "Vantura GUI"
    local size = options.Size or UDim2.fromOffset(620, 400)

    -- Detect parent (CoreGui for exploits, PlayerGui for testing in studio)
    local parent
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then
        parent = coreGui
    else
        parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "VanturaLib_" .. HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 8)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parent

    -- Loading Progression GUI Centered Container
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Name = "LoadingFrame"
    loadingFrame.Size = UDim2.fromOffset(300, 120)
    loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -60)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.ZIndex = 10
    loadingFrame.Parent = screenGui

    local loadingCorner = Instance.new("UICorner")
    loadingCorner.CornerRadius = UDim.new(0, 5)
    loadingCorner.Parent = loadingFrame

    local loadingStroke = Instance.new("UIStroke")
    loadingStroke.Color = Color3.fromRGB(45, 45, 50)
    loadingStroke.Thickness = 1
    loadingStroke.Parent = loadingFrame

    -- Loading Red Top Line
    local loadingAccent = Instance.new("Frame")
    loadingAccent.Size = UDim2.new(1, 0, 0, 3)
    loadingAccent.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
    loadingAccent.BorderSizePixel = 0
    loadingAccent.Parent = loadingFrame

    local loadingAccentCorner = Instance.new("UICorner")
    loadingAccentCorner.CornerRadius = UDim.new(0, 5)
    loadingAccentCorner.Parent = loadingAccent

    -- Loading title
    local loadingTitle = Instance.new("TextLabel")
    loadingTitle.Size = UDim2.new(1, 0, 0, 30)
    loadingTitle.Position = UDim2.new(0, 0, 0, 15)
    loadingTitle.BackgroundTransparency = 1
    loadingTitle.Text = windowTitle
    loadingTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
    loadingTitle.Font = Enum.Font.GothamBold
    loadingTitle.TextSize = 14
    loadingTitle.Parent = loadingFrame

    -- Loading description info
    local loadingDesc = Instance.new("TextLabel")
    loadingDesc.Size = UDim2.new(1, 0, 0, 20)
    loadingDesc.Position = UDim2.new(0, 0, 0, 45)
    loadingDesc.BackgroundTransparency = 1
    loadingDesc.Text = "Configuring client assets..."
    loadingDesc.TextColor3 = Color3.fromRGB(150, 150, 155)
    loadingDesc.Font = Enum.Font.Gotham
    loadingDesc.TextSize = 11
    loadingDesc.Parent = loadingFrame

    -- Progress Bar Background
    local pBarBg = Instance.new("Frame")
    pBarBg.Size = UDim2.new(0.8, 0, 0, 6)
    pBarBg.Position = UDim2.new(0.1, 0, 0, 80)
    pBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    pBarBg.BorderSizePixel = 0
    pBarBg.Parent = loadingFrame

    local pBarBgCorner = Instance.new("UICorner")
    pBarBgCorner.CornerRadius = UDim.new(1, 0)
    pBarBgCorner.Parent = pBarBg

    -- Progress Bar Filling
    local pBarFill = Instance.new("Frame")
    pBarFill.Size = UDim2.new(0, 0, 1, 0)
    pBarFill.BackgroundColor3 = Color3.fromRGB(220, 38, 38) -- Accent red
    pBarFill.BorderSizePixel = 0
    pBarFill.Parent = pBarBg

    local pBarFillCorner = Instance.new("UICorner")
    pBarFillCorner.CornerRadius = UDim.new(1, 0)
    pBarFillCorner.Parent = pBarFill

    -- Main Container Frame (Deep near-black background)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = size
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 1 -- Start transparent for transition
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    -- Rounded corners
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 5)
    mainCorner.Parent = mainFrame

    -- Thin border matching CS:GO/CS2 layout style
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(45, 45, 50)
    mainStroke.Thickness = 1
    mainStroke.Parent = mainFrame

    -- Premium Top Accent Line (Red color highlight)
    local topAccent = Instance.new("Frame")
    topAccent.Name = "TopAccent"
    topAccent.Size = UDim2.new(1, 0, 0, 3)
    topAccent.BackgroundColor3 = Color3.fromRGB(220, 38, 38) -- Bright Red
    topAccent.BorderSizePixel = 0
    topAccent.ZIndex = 5
    topAccent.Parent = mainFrame

    local topAccentCorner = Instance.new("UICorner")
    topAccentCorner.CornerRadius = UDim.new(0, 5)
    topAccentCorner.Parent = topAccent

    -- Cover bottom corners of top accent to keep it clean
    local topAccentCover = Instance.new("Frame")
    topAccentCover.Name = "Cover"
    topAccentCover.Size = UDim2.new(1, 0, 0, 2)
    topAccentCover.Position = UDim2.new(0, 0, 1, -2)
    topAccentCover.BackgroundColor3 = topAccent.BackgroundColor3
    topAccentCover.BorderSizePixel = 0
    topAccentCover.Parent = topAccent

    -- Dragging Handler (Header region below accent line)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 37)
    headerFrame.Position = UDim2.new(0, 0, 0, 3)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = mainFrame
    MakeDraggable(headerFrame, mainFrame)

    -- Header Title (Left aligned)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame

    -- Vertical Icon Sidebar Strip (Far Left)
    local iconSidebar = Instance.new("Frame")
    iconSidebar.Name = "IconSidebar"
    iconSidebar.Size = UDim2.new(0, 48, 1, -40)
    iconSidebar.Position = UDim2.new(0, 0, 0, 40)
    iconSidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    iconSidebar.BorderSizePixel = 0
    iconSidebar.Parent = mainFrame

    -- Inner line separation
    local sidebarSeparator = Instance.new("Frame")
    sidebarSeparator.Size = UDim2.new(0, 1, 1, 0)
    sidebarSeparator.Position = UDim2.new(1, -1, 0, 0)
    sidebarSeparator.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    sidebarSeparator.BorderSizePixel = 0
    sidebarSeparator.Parent = iconSidebar

    -- Scroll Area for Sidebar Icons
    local scrollIcons = Instance.new("ScrollingFrame")
    scrollIcons.Name = "IconScroll"
    scrollIcons.Size = UDim2.new(1, 0, 1, -45)
    scrollIcons.Position = UDim2.new(0, 0, 0, 5)
    scrollIcons.BackgroundTransparency = 1
    scrollIcons.BorderSizePixel = 0
    scrollIcons.ScrollBarThickness = 0
    scrollIcons.Parent = iconSidebar

    local iconsLayout = Instance.new("UIListLayout")
    iconsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    iconsLayout.Padding = UDim.new(0, 8)
    iconsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    iconsLayout.Parent = scrollIcons

    -- Text sub-tabs label column (Beside icons)
    local tabSidebar = Instance.new("Frame")
    tabSidebar.Name = "TabSidebar"
    tabSidebar.Size = UDim2.new(0, 112, 1, -40)
    tabSidebar.Position = UDim2.new(0, 48, 0, 40)
    tabSidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
    tabSidebar.BorderSizePixel = 0
    tabSidebar.Parent = mainFrame

    local tabSeparator = Instance.new("Frame")
    tabSeparator.Size = UDim2.new(0, 1, 1, 0)
    tabSeparator.Position = UDim2.new(1, -1, 0, 0)
    tabSeparator.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    tabSeparator.BorderSizePixel = 0
    tabSeparator.Parent = tabSidebar

    local scrollTabs = Instance.new("ScrollingFrame")
    scrollTabs.Name = "TabScroll"
    scrollTabs.Size = UDim2.new(1, 0, 1, -10)
    scrollTabs.Position = UDim2.new(0, 0, 0, 5)
    scrollTabs.BackgroundTransparency = 1
    scrollTabs.BorderSizePixel = 0
    scrollTabs.ScrollBarThickness = 0
    scrollTabs.Parent = tabSidebar

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 2)
    tabsLayout.Parent = scrollTabs

    -- Container for Tab pages
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = "PageContainer"
    pageContainer.Size = UDim2.new(1, -172, 1, -52)
    pageContainer.Position = UDim2.new(0, 166, 0, 44)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = mainFrame

    -- Stacking Notification ScreenGui Layer
    local toastContainer = Instance.new("Frame")
    toastContainer.Name = "ToastContainer"
    toastContainer.Size = UDim2.new(0, 280, 1, -20)
    toastContainer.Position = UDim2.new(1, -290, 0, 10)
    toastContainer.BackgroundTransparency = 1
    toastContainer.Parent = screenGui

    local toastLayout = Instance.new("UIListLayout")
    toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
    toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    toastLayout.Padding = UDim.new(0, 8)
    toastLayout.Parent = toastContainer

    -- Handle group fade out for loading
    local function TransitionToMenu()
        -- Fade Loading elements
        Tween(loadingTitle, TweenInfo.new(0.3), { TextTransparency = 1 })
        Tween(loadingDesc, TweenInfo.new(0.3), { TextTransparency = 1 })
        Tween(pBarBg, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
        Tween(pBarFill, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
        local fadeTween = Tween(loadingFrame, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
        fadeTween.Completed:Connect(function()
            loadingFrame:Destroy()
            
            -- Fade in menu frame
            mainFrame.Visible = true
            -- Set internal transparencies
            mainFrame.BackgroundTransparency = 0
            mainStroke.Transparency = 0
            topAccent.BackgroundTransparency = 0
            iconSidebar.BackgroundTransparency = 0
            sidebarSeparator.BackgroundTransparency = 0
            tabSidebar.BackgroundTransparency = 0
            tabSeparator.BackgroundTransparency = 0
        end)
    end

    -- Trigger mock progress bar animation
    task.spawn(function()
        task.wait(0.2)
        loadingDesc.Text = "Synchronizing hooks..."
        Tween(pBarFill, TweenInfo.new(0.6, Enum.EasingStyle.Sine), { Size = UDim2.new(0.4, 0, 1, 0) })
        task.wait(0.6)
        loadingDesc.Text = "Loading theme configs..."
        Tween(pBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Sine), { Size = UDim2.new(0.75, 0, 1, 0) })
        task.wait(0.5)
        loadingDesc.Text = "Ready."
        local finalFill = Tween(pBarFill, TweenInfo.new(0.4, Enum.EasingStyle.Sine), { Size = UDim2.new(1.0, 0, 1, 0) })
        finalFill.Completed:Connect(TransitionToMenu)
    end)

    -- Destroy function: Removes all traces
    local function DestroyGUI()
        -- Disconnect global connections to prevent memory leaks
        for _, conn in ipairs(globalConnections) do
            if conn and conn.Connected then
                conn:Disconnect()
            end
        end
        globalConnections = {}

        -- Attempt to clean local icon assets
        pcall(function()
            if listfiles and delfile then
                for _, file in ipairs(listfiles("")) do
                    if file:match("vantura_icons_") then
                        delfile(file)
                    end
                end
            end
        end)
        screenGui:Destroy()
    end

    -- Create Destroy Script Button
    local destroyBtn = Instance.new("ImageButton")
    destroyBtn.Name = "DestroyButton"
    destroyBtn.Size = UDim2.fromOffset(24, 24)
    destroyBtn.Position = UDim2.new(0.5, -12, 1, -34)
    destroyBtn.BackgroundTransparency = 1
    destroyBtn.Image = LoadCustomAsset("https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/quit.png")
    destroyBtn.ImageColor3 = Color3.fromRGB(200, 200, 205)
    destroyBtn.Parent = iconSidebar

    local destroyCorner = Instance.new("UICorner")
    destroyCorner.CornerRadius = UDim.new(0, 4)
    destroyCorner.Parent = destroyBtn

    destroyBtn.MouseEnter:Connect(function()
        Tween(destroyBtn, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(220, 38, 38) })
    end)
    destroyBtn.MouseLeave:Connect(function()
        Tween(destroyBtn, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(200, 200, 205) })
    end)
    destroyBtn.MouseButton1Click:Connect(DestroyGUI)

    local activeToasts = {}

    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        PageContainer = pageContainer,
        TabScroll = scrollTabs,
        IconScroll = scrollIcons,
        Tabs = {},
        ActiveTab = nil,
        TabCount = 0
    }

    -- Toast system method
    function window:Notification(toastOptions)
        toastOptions = toastOptions or {}
        local toastTitle = toastOptions.Name or "System Alert"
        local message = toastOptions.Description or ""
        local duration = toastOptions.Duration or 3.5

        -- Manage Queue Cap: Remove oldest if > 3
        if #activeToasts >= 3 then
            local oldest = activeToasts[1]
            if oldest then
                oldest:Dismiss()
            end
        end

        local toastFrame = Instance.new("Frame")
        toastFrame.Name = "Toast"
        toastFrame.Size = UDim2.new(1, 0, 0, 52)
        toastFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
        toastFrame.BorderSizePixel = 0
        -- Start slide offset to the right
        toastFrame.Position = UDim2.new(0, 60, 0, 0)
        toastFrame.BackgroundTransparency = 1
        toastFrame.ZIndex = 15
        toastFrame.Parent = toastContainer

        local toastCorner = Instance.new("UICorner")
        toastCorner.CornerRadius = UDim.new(0, 4)
        toastCorner.Parent = toastFrame

        local toastStroke = Instance.new("UIStroke")
        toastStroke.Color = Color3.fromRGB(45, 45, 50)
        toastStroke.Thickness = 1
        toastStroke.Transparency = 1
        toastStroke.Parent = toastFrame

        -- Notification Left Red Indicator Stripe
        local toastStripe = Instance.new("Frame")
        toastStripe.Size = UDim2.new(0, 3, 1, 0)
        toastStripe.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        toastStripe.BorderSizePixel = 0
        toastStripe.BackgroundTransparency = 1
        toastStripe.Parent = toastFrame

        local stripeCorner = Instance.new("UICorner")
        stripeCorner.CornerRadius = UDim.new(0, 4)
        stripeCorner.Parent = toastStripe

        -- Title Label
        local tLabel = Instance.new("TextLabel")
        tLabel.Size = UDim2.new(1, -20, 0.45, 0)
        tLabel.Position = UDim2.new(0, 10, 0.08, 0)
        tLabel.BackgroundTransparency = 1
        tLabel.Text = toastTitle
        tLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = 11
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.TextTransparency = 1
        tLabel.Parent = toastFrame

        -- Desc Label
        local dLabel = Instance.new("TextLabel")
        dLabel.Size = UDim2.new(1, -20, 0.45, 0)
        dLabel.Position = UDim2.new(0, 10, 0.45, 0)
        dLabel.BackgroundTransparency = 1
        dLabel.Text = message
        dLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 10
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.TextTransparency = 1
        dLabel.Parent = toastFrame

        -- Bottom Progress Timer Bar
        local tBar = Instance.new("Frame")
        tBar.Size = UDim2.new(1, 0, 0, 2)
        tBar.Position = UDim2.new(0, 0, 1, -2)
        tBar.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        tBar.BorderSizePixel = 0
        tBar.BackgroundTransparency = 1
        tBar.Parent = toastFrame

        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(0, 4)
        barCorner.Parent = tBar

        local toastObj = {}

        local function reparentToasts()
            for i, toast in ipairs(activeToasts) do
                toast.Frame.LayoutOrder = i
            end
        end

        local function Dismiss()
            -- Remove from track list
            for i, v in ipairs(activeToasts) do
                if v == toastObj then
                    table.remove(activeToasts, i)
                    break
                end
            end
            
            reparentToasts()

            -- Fade Out & Slide Right
            Tween(tLabel, TweenInfo.new(0.2), { TextTransparency = 1 })
            Tween(dLabel, TweenInfo.new(0.2), { TextTransparency = 1 })
            Tween(tBar, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
            Tween(toastStroke, TweenInfo.new(0.2), { Transparency = 1 })
            Tween(toastStripe, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
            local slideOut = Tween(toastFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1, Position = UDim2.new(0, 60, 0, 0) })
            
            slideOut.Completed:Connect(function()
                toastFrame:Destroy()
            end)
        end

        toastObj.Frame = toastFrame
        toastObj.Dismiss = Dismiss

        table.insert(activeToasts, toastObj)
        reparentToasts()

        -- Fade and slide in
        Tween(toastFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) })
        Tween(toastStroke, TweenInfo.new(0.25), { Transparency = 0 })
        Tween(toastStripe, TweenInfo.new(0.25), { BackgroundTransparency = 0 })
        Tween(tLabel, TweenInfo.new(0.25), { TextTransparency = 0 })
        Tween(dLabel, TweenInfo.new(0.25), { TextTransparency = 0 })
        Tween(tBar, TweenInfo.new(0.25), { BackgroundTransparency = 0 })

        -- Progress bar shrinking (100% to 0%)
        local progressTween = Tween(tBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })
        
        progressTween.Completed:Connect(function()
            Dismiss()
        end)
    end

    function window:Tab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local iconInput = tabOptions.Icon or "https://raw.githubusercontent.com/Femfus/menu-lib/main/icons/file.png"

        window.TabCount = window.TabCount + 1
        local tabId = window.TabCount

        -- Create Page Scrolling Frame
        local page = Instance.new("ScrollingFrame")
        page.Name = tabName .. "_Page"
        page.Size = UDim2.new(1, -6, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = false
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 50)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Parent = pageContainer

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.Parent = page

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Icon button (on Left Strip)
        local iconButton = Instance.new("ImageButton")
        iconButton.Name = tabName .. "_IconBtn"
        iconButton.Size = UDim2.fromOffset(24, 24)
        iconButton.BackgroundTransparency = 1
        iconButton.Image = LoadCustomAsset(iconInput)
        iconButton.ImageColor3 = Color3.fromRGB(180, 180, 185)
        iconButton.LayoutOrder = tabId
        iconButton.Parent = scrollIcons

        -- Tab Text Label button (on Sub Sidebar)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "_Btn"
        tabButton.Size = UDim2.new(1, 0, 0, 28)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.BorderSizePixel = 0
        tabButton.LayoutOrder = tabId
        tabButton.Parent = scrollTabs

        -- Red Vertical Indicator bar
        local tabIndicator = Instance.new("Frame")
        tabIndicator.Name = "Indicator"
        tabIndicator.Size = UDim2.new(0, 2, 1, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0, 0)
        tabIndicator.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        tabIndicator.BorderSizePixel = 0
        tabIndicator.BackgroundTransparency = 1
        tabIndicator.Parent = tabButton

        -- Tab Label Text
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.Size = UDim2.new(1, -12, 1, 0)
        tabLabel.Position = UDim2.new(0, 10, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Color3.fromRGB(130, 130, 135)
        tabLabel.Font = Enum.Font.Gotham
        tabLabel.TextSize = 12
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton

        local tabObj = {
            Button = tabButton,
            IconButton = iconButton,
            Page = page,
            Label = tabLabel,
            Indicator = tabIndicator,
            Id = tabId
        }

        local function Select()
            if window.ActiveTab then
                window.ActiveTab.Page.Visible = false
                window.ActiveTab.Indicator.BackgroundTransparency = 1
                window.ActiveTab.Label.TextColor3 = Color3.fromRGB(130, 130, 135)
                window.ActiveTab.Label.Font = Enum.Font.Gotham
                window.ActiveTab.IconButton.ImageColor3 = Color3.fromRGB(180, 180, 185)
            end
            window.ActiveTab = tabObj
            page.Visible = true
            tabIndicator.BackgroundTransparency = 0
            tabLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            tabLabel.Font = Enum.Font.GothamBold
            iconButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
        end

        tabButton.MouseButton1Click:Connect(Select)
        iconButton.MouseButton1Click:Connect(Select)

        -- Hover triggers
        local function onEnter()
            if window.ActiveTab ~= tabObj then
                Tween(tabLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(200, 200, 205) })
                Tween(iconButton, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(240, 240, 245) })
            end
        end

        local function onLeave()
            if window.ActiveTab ~= tabObj then
                Tween(tabLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(130, 130, 135) })
                Tween(iconButton, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(180, 180, 185) })
            end
        end

        tabButton.MouseEnter:Connect(onEnter)
        tabButton.MouseLeave:Connect(onLeave)
        iconButton.MouseEnter:Connect(onEnter)
        iconButton.MouseLeave:Connect(onLeave)

        if not window.ActiveTab then
            Select()
        end

        -- Widgets
        function tabObj:Button(btnOptions)
            btnOptions = btnOptions or {}
            local btnName = btnOptions.Name or "Button"
            local desc = btnOptions.Description or ""
            local callback = btnOptions.Callback or function() end

            local elementFrame = Instance.new("Frame")
            elementFrame.Name = btnName .. "_Element"
            elementFrame.Size = UDim2.new(1, -6, 0, 38)
            elementFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            elementFrame.BorderSizePixel = 0
            elementFrame.Parent = page

            local elCorner = Instance.new("UICorner")
            elCorner.CornerRadius = UDim.new(0, 3)
            elCorner.Parent = elementFrame

            local elStroke = Instance.new("UIStroke")
            elStroke.Color = Color3.fromRGB(36, 36, 40)
            elStroke.Thickness = 1
            elStroke.Parent = elementFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            titleLabel.Position = UDim2.new(0, 12, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = btnName
            titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            titleLabel.Font = Enum.Font.GothamMedium
            titleLabel.TextSize = 12
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = elementFrame

            local actionBtn = Instance.new("TextButton")
            actionBtn.Name = "Trigger"
            actionBtn.Size = UDim2.new(0, 70, 0, 22)
            actionBtn.Position = UDim2.new(1, -82, 0.5, -11)
            actionBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 38)
            actionBtn.Text = "Execute"
            actionBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            actionBtn.Font = Enum.Font.GothamBold
            actionBtn.TextSize = 11
            actionBtn.BorderSizePixel = 0
            actionBtn.Parent = elementFrame

            local actionCorner = Instance.new("UICorner")
            actionCorner.CornerRadius = UDim.new(0, 3)
            actionCorner.Parent = actionBtn

            local actionStroke = Instance.new("UIStroke")
            actionStroke.Color = Color3.fromRGB(50, 50, 55)
            actionStroke.Thickness = 1
            actionStroke.Parent = actionBtn

            actionBtn.MouseEnter:Connect(function()
                Tween(actionBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(220, 38, 38), TextColor3 = Color3.fromRGB(255, 255, 255) })
                Tween(actionStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(220, 38, 38) })
            end)

            actionBtn.MouseLeave:Connect(function()
                Tween(actionBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(34, 34, 38), TextColor3 = Color3.fromRGB(200, 200, 200) })
                Tween(actionStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(50, 50, 55) })
            end)

            actionBtn.MouseButton1Click:Connect(callback)
        end

        function tabObj:Toggle(toggleOptions)
            toggleOptions = toggleOptions or {}
            local toggleName = toggleOptions.Name or "Toggle"
            local state = toggleOptions.StartingState or false
            local callback = toggleOptions.Callback or function() end

            local elementFrame = Instance.new("Frame")
            elementFrame.Name = toggleName .. "_Element"
            elementFrame.Size = UDim2.new(1, -6, 0, 38)
            elementFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            elementFrame.BorderSizePixel = 0
            elementFrame.Parent = page

            local elCorner = Instance.new("UICorner")
            elCorner.CornerRadius = UDim.new(0, 3)
            elCorner.Parent = elementFrame

            local elStroke = Instance.new("UIStroke")
            elStroke.Color = Color3.fromRGB(36, 36, 40)
            elStroke.Thickness = 1
            elStroke.Parent = elementFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            titleLabel.Position = UDim2.new(0, 12, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = toggleName
            titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            titleLabel.Font = Enum.Font.GothamMedium
            titleLabel.TextSize = 12
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = elementFrame

            local toggleBox = Instance.new("TextButton")
            toggleBox.Name = "ToggleBox"
            toggleBox.Size = UDim2.fromOffset(14, 14)
            toggleBox.Position = UDim2.new(1, -26, 0.5, -7)
            toggleBox.BackgroundColor3 = state and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(15, 15, 17)
            toggleBox.Text = ""
            toggleBox.BorderSizePixel = 0
            toggleBox.Parent = elementFrame

            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 2)
            boxCorner.Parent = toggleBox

            local boxStroke = Instance.new("UIStroke")
            boxStroke.Color = state and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(50, 50, 55)
            boxStroke.Thickness = 1
            boxStroke.Parent = toggleBox

            local function updateToggle()
                if state then
                    Tween(toggleBox, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(220, 38, 38) })
                    boxStroke.Color = Color3.fromRGB(220, 38, 38)
                else
                    Tween(toggleBox, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(15, 15, 17) })
                    boxStroke.Color = Color3.fromRGB(50, 50, 55)
                end
            end

            toggleBox.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
                callback(state)
            end)

            local controller = {}
            function controller:SetState(val)
                state = val
                updateToggle()
                callback(state)
            end
            function controller:GetState()
                return state
            end

            return controller
        end

        function tabObj:Dropdown(ddOptions)
            ddOptions = ddOptions or {}
            local ddName = ddOptions.Name or "Dropdown"
            local optionsList = ddOptions.Options or {}
            local default = ddOptions.Default or optionsList[1] or ""
            local callback = ddOptions.Callback or function() end

            local currentVal = default
            local expanded = false

            local elementFrame = Instance.new("Frame")
            elementFrame.Name = ddName .. "_Element"
            elementFrame.Size = UDim2.new(1, -6, 0, 38)
            elementFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
            elementFrame.BorderSizePixel = 0
            elementFrame.ClipsDescendants = false
            elementFrame.Parent = page

            local elCorner = Instance.new("UICorner")
            elCorner.CornerRadius = UDim.new(0, 3)
            elCorner.Parent = elementFrame

            local elStroke = Instance.new("UIStroke")
            elStroke.Color = Color3.fromRGB(36, 36, 40)
            elStroke.Thickness = 1
            elStroke.Parent = elementFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(0.4, 0, 1, 0)
            titleLabel.Position = UDim2.new(0, 12, 0, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = ddName
            titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            titleLabel.Font = Enum.Font.GothamMedium
            titleLabel.TextSize = 12
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = elementFrame

            local selectorBtn = Instance.new("TextButton")
            selectorBtn.Name = "Selector"
            selectorBtn.Size = UDim2.new(0, 110, 0, 22)
            selectorBtn.Position = UDim2.new(1, -122, 0.5, -11)
            selectorBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 38)
            selectorBtn.Text = currentVal
            selectorBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            selectorBtn.Font = Enum.Font.Gotham
            selectorBtn.TextSize = 11
            selectorBtn.BorderSizePixel = 0
            selectorBtn.ZIndex = 8
            selectorBtn.Parent = elementFrame

            local selCorner = Instance.new("UICorner")
            selCorner.CornerRadius = UDim.new(0, 3)
            selCorner.Parent = selectorBtn

            local selStroke = Instance.new("UIStroke")
            selStroke.Color = Color3.fromRGB(50, 50, 55)
            selStroke.Thickness = 1
            selStroke.Parent = selectorBtn

            local chevron = Instance.new("ImageLabel")
            chevron.Name = "Chevron"
            chevron.Size = UDim2.fromOffset(10, 10)
            chevron.Position = UDim2.new(1, -16, 0.5, -5)
            chevron.BackgroundTransparency = 1
            chevron.Image = "rbxassetid://6034818372" -- Standard down chevron
            chevron.ImageColor3 = Color3.fromRGB(150, 150, 155)
            chevron.ZIndex = 9
            chevron.Parent = selectorBtn

            -- Options container frame (absolute positioning beneath option)
            local listFrame = Instance.new("Frame")
            listFrame.Name = "OptionsList"
            listFrame.Size = UDim2.new(1, 0, 0, 0)
            listFrame.Position = UDim2.new(0, 0, 1, 2)
            listFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
            listFrame.BorderSizePixel = 0
            listFrame.ZIndex = 20
            listFrame.Visible = false
            listFrame.Parent = selectorBtn

            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 3)
            listCorner.Parent = listFrame

            local listStroke = Instance.new("UIStroke")
            listStroke.Color = Color3.fromRGB(50, 50, 55)
            listStroke.Thickness = 1
            listStroke.Parent = listFrame

            local listLayout = Instance.new("UIListLayout")
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = listFrame

            local function refreshSelectorText()
                selectorBtn.Text = currentVal
            end

            local optionObjects = {}

            local function toggleDropdown()
                expanded = not expanded
                listFrame.Visible = expanded
                if expanded then
                    Tween(chevron, TweenInfo.new(0.15), { Rotation = 180 })
                    listFrame.Size = UDim2.new(1, 0, 0, #optionsList * 20)
                else
                    Tween(chevron, TweenInfo.new(0.15), { Rotation = 0 })
                    listFrame.Size = UDim2.new(1, 0, 0, 0)
                end
            end

            selectorBtn.MouseButton1Click:Connect(toggleDropdown)

            for i, opt in ipairs(optionsList) do
                local optBtn = Instance.new("TextButton")
                optBtn.Name = opt
                optBtn.Size = UDim2.new(1, 0, 0, 20)
                optBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
                optBtn.BorderSizePixel = 0
                optBtn.Text = opt
                optBtn.TextColor3 = (opt == currentVal) and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(180, 180, 185)
                optBtn.Font = Enum.Font.Gotham
                optBtn.TextSize = 10
                optBtn.LayoutOrder = i
                optBtn.ZIndex = 21
                optBtn.Parent = listFrame

                optBtn.MouseEnter:Connect(function()
                    if currentVal ~= opt then
                        Tween(optBtn, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(240, 240, 240) })
                    end
                end)

                optBtn.MouseLeave:Connect(function()
                    if currentVal ~= opt then
                        Tween(optBtn, TweenInfo.new(0.1), { TextColor3 = Color3.fromRGB(180, 180, 185) })
                    end
                end)

                optBtn.MouseButton1Click:Connect(function()
                    currentVal = opt
                    refreshSelectorText()
                    toggleDropdown()
                    for _, obj in ipairs(optionObjects) do
                        obj.TextColor3 = (obj.Text == currentVal) and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(180, 180, 185)
                    end
                    callback(currentVal)
                end)

                table.insert(optionObjects, optBtn)
            end

            local controller = {}
            function controller:Set(val)
                for _, opt in ipairs(optionsList) do
                    if opt == val then
                        currentVal = val
                        refreshSelectorText()
                        for _, obj in ipairs(optionObjects) do
                            obj.TextColor3 = (obj.Text == currentVal) and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(180, 180, 185)
                        end
                        callback(currentVal)
                        break
                    end
                end
            end

            function controller:Get()
                return currentVal
            end

            return controller
        end

        return tabObj
    end

    function window:SetSize(newSize)
        size = newSize
        mainFrame.Size = size
        mainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    end

    function window:Destroy()
        DestroyGUI()
    end

    return window
end

return VanturaLib
