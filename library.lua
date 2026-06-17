local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local MercuryLib = {}
MercuryLib.__index = MercuryLib

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

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parentFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
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

    local cleanName = url:match("([^/]+)$"):gsub("[^%w%.]", "_")
    local filepath = "mercury_icons_" .. cleanName

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

    -- Return a robust fallback Roblox Icon asset ID (Eye/Visuals or Cog icon style)
    return "rbxassetid://6034853644" 
end

function MercuryLib:Create(options)
    options = options or {}
    local windowTitle = options.Name or "Mercury GUI"
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
    screenGui.Name = "MercuryLib_" .. HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 8)
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = parent

    -- Main Container Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = size
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 5)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(45, 45, 50)
    mainStroke.Thickness = 1
    mainStroke.Parent = mainFrame

    -- Premium Top Accent Line
    local topAccent = Instance.new("Frame")
    topAccent.Name = "TopAccent"
    topAccent.Size = UDim2.new(1, 0, 0, 3)
    topAccent.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
    topAccent.BorderSizePixel = 0
    topAccent.ZIndex = 5
    topAccent.Parent = mainFrame

    local topAccentCorner = Instance.new("UICorner")
    topAccentCorner.CornerRadius = UDim.new(0, 5)
    topAccentCorner.Parent = topAccent

    local topAccentCover = Instance.new("Frame")
    topAccentCover.Name = "Cover"
    topAccentCover.Size = UDim2.new(1, 0, 0, 2)
    topAccentCover.Position = UDim2.new(0, 0, 1, -2)
    topAccentCover.BackgroundColor3 = topAccent.BackgroundColor3
    topAccentCover.BorderSizePixel = 0
    topAccentCover.Parent = topAccent

    -- Dragging Handler
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 37)
    headerFrame.Position = UDim2.new(0, 0, 0, 3)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = mainFrame
    MakeDraggable(headerFrame, mainFrame)

    -- Header Title
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

    -- Vertical Icon Sidebar Strip
    local iconSidebar = Instance.new("Frame")
    iconSidebar.Name = "IconSidebar"
    iconSidebar.Size = UDim2.new(0, 48, 1, -40)
    iconSidebar.Position = UDim2.new(0, 0, 0, 40)
    iconSidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    iconSidebar.BorderSizePixel = 0
    iconSidebar.Parent = mainFrame

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

    -- Text sub-tabs label column
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

    -- Destroy function: Removes all traces
    local function DestroyGUI()
        -- Attempt to clean local icon assets
        pcall(function()
            if listfiles and delfile then
                for _, file in ipairs(listfiles("")) do
                    if file:match("mercury_icons_") then
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
    destroyBtn.Image = LoadCustomAsset("https://raw.githubusercontent.com/Femfus/menu-lib/refs/heads/main/icons/power.png")
    destroyBtn.ImageColor3 = Color3.fromRGB(150, 50, 50)
    destroyBtn.Parent = iconSidebar

    destroyBtn.MouseEnter:Connect(function()
        Tween(destroyBtn, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(220, 38, 38) })
    end)
    destroyBtn.MouseLeave:Connect(function()
        Tween(destroyBtn, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(150, 50, 50) })
    end)
    destroyBtn.MouseButton1Click:Connect(DestroyGUI)

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

    function window:Tab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local iconInput = tabOptions.Icon or "https://raw.githubusercontent.com/Femfus/menu-lib/refs/heads/main/icons/fallback.png"

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
        iconButton.ImageColor3 = Color3.fromRGB(100, 100, 105)
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
                window.ActiveTab.IconButton.ImageColor3 = Color3.fromRGB(100, 100, 105)
            end
            window.ActiveTab = tabObj
            page.Visible = true
            tabIndicator.BackgroundTransparency = 0
            tabLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            tabLabel.Font = Enum.Font.GothamBold
            iconButton.ImageColor3 = Color3.fromRGB(220, 38, 38)
        end

        tabButton.MouseButton1Click:Connect(Select)
        iconButton.MouseButton1Click:Connect(Select)

        -- Hover triggers
        local function onEnter()
            if window.ActiveTab ~= tabObj then
                Tween(tabLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(200, 200, 205) })
                Tween(iconButton, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(180, 180, 185) })
            end
        end

        local function onLeave()
            if window.ActiveTab ~= tabObj then
                Tween(tabLabel, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(130, 130, 135) })
                Tween(iconButton, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(100, 100, 105) })
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
        end

        return tabObj
    end

    function window:Destroy()
        DestroyGUI()
    end

    return window
end

return MercuryLib
