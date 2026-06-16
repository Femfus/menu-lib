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

-- Helper: Create a smooth color/size tween
local function Tween(instance, info, propertyTable)
    local tween = TweenService:Create(instance, info, propertyTable)
    tween:Play()
    return tween
end

function MercuryLib:Create(options)
    options = options or {}
    local windowTitle = options.Name or "Mercury GUI"
    local size = options.Size or UDim2.fromOffset(580, 380)

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
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(33, 38, 51)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = mainFrame

    -- Dragging Handler (Header region)
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = mainFrame
    MakeDraggable(headerFrame, mainFrame)

    -- Header Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = Color3.fromRGB(240, 243, 250)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame

    -- Sidebar Container
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 160, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 10)
    sidebarCorner.Parent = sidebar

    -- Hide bottom left corner roundedness to fit nicely inside main frame
    local sidebarCover = Instance.new("Frame")
    sidebarCover.Name = "Cover"
    sidebarCover.Size = UDim2.new(0, 10, 1, -10)
    sidebarCover.Position = UDim2.new(1, -10, 0, 0)
    sidebarCover.BackgroundColor3 = sidebar.BackgroundColor3
    sidebarCover.BorderSizePixel = 0
    sidebarCover.Parent = sidebar

    local sidebarCoverTop = Instance.new("Frame")
    sidebarCoverTop.Name = "CoverTop"
    sidebarCoverTop.Size = UDim2.new(1, 0, 0, 10)
    sidebarCoverTop.Position = UDim2.new(0, 0, 0, 0)
    sidebarCoverTop.BackgroundColor3 = sidebar.BackgroundColor3
    sidebarCoverTop.BorderSizePixel = 0
    sidebarCoverTop.Parent = sidebar

    -- Tab Button Scroll list
    local scrollTabs = Instance.new("ScrollingFrame")
    scrollTabs.Name = "TabScroll"
    scrollTabs.Size = UDim2.new(1, -8, 1, -50)
    scrollTabs.Position = UDim2.new(0, 4, 0, 8)
    scrollTabs.BackgroundTransparency = 1
    scrollTabs.BorderSizePixel = 0
    scrollTabs.ScrollBarThickness = 2
    scrollTabs.ScrollBarImageColor3 = Color3.fromRGB(40, 45, 55)
    scrollTabs.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollTabs.Parent = sidebar

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0, 4)
    tabsLayout.Parent = scrollTabs

    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollTabs.CanvasSize = UDim2.new(0, 0, 0, tabsLayout.AbsoluteContentSize.Y)
    end)

    -- Container for Tab pages
    local pageContainer = Instance.new("Frame")
    pageContainer.Name = "PageContainer"
    pageContainer.Size = UDim2.new(1, -172, 1, -52)
    pageContainer.Position = UDim2.new(0, 166, 0, 44)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = mainFrame

    -- Destroy function: Removes all traces
    local function DestroyGUI()
        screenGui:Destroy()
    end

    -- Create Destroy Script Button at the bottom of the sidebar
    local destroyBtn = Instance.new("TextButton")
    destroyBtn.Name = "DestroyButton"
    destroyBtn.Size = UDim2.new(1, -16, 0, 32)
    destroyBtn.Position = UDim2.new(0, 8, 1, -40)
    destroyBtn.BackgroundColor3 = Color3.fromRGB(244, 63, 94)
    destroyBtn.Text = "Destroy Script"
    destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    destroyBtn.Font = Enum.Font.GothamBold
    destroyBtn.TextSize = 12
    destroyBtn.BorderSizePixel = 0
    destroyBtn.Parent = sidebar

    local destroyCorner = Instance.new("UICorner")
    destroyCorner.CornerRadius = UDim.new(0, 6)
    destroyCorner.Parent = destroyBtn

    destroyBtn.MouseEnter:Connect(function()
        Tween(destroyBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(225, 29, 72) })
    end)
    destroyBtn.MouseLeave:Connect(function()
        Tween(destroyBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(244, 63, 94) })
    end)
    destroyBtn.MouseButton1Click:Connect(DestroyGUI)

    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        PageContainer = pageContainer,
        TabScroll = scrollTabs,
        Tabs = {},
        ActiveTab = nil
    }

    function window:Tab(tabOptions)
        tabOptions = tabOptions or {}
        local tabName = tabOptions.Name or "Tab"
        local iconId = tabOptions.Icon or "rbxassetid://6031225818" -- Fallback icon

        -- Create Page Scrolling Frame
        local page = Instance.new("ScrollingFrame")
        page.Name = tabName .. "_Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Visible = false
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(55, 60, 75)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Parent = pageContainer

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.Parent = page

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)

        -- Tab Selection Button in Sidebar
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "_Btn"
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.BorderSizePixel = 0
        tabButton.Parent = scrollTabs

        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = tabButton

        -- Tab Icon
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "Icon"
        tabIcon.Size = UDim2.fromOffset(16, 16)
        tabIcon.Position = UDim2.new(0, 8, 0.5, -8)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = iconId
        tabIcon.ImageColor3 = Color3.fromRGB(150, 160, 180)
        tabIcon.Parent = tabButton

        -- Tab Text
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.Size = UDim2.new(1, -36, 1, 0)
        tabLabel.Position = UDim2.new(0, 32, 0, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
        tabLabel.Font = Enum.Font.GothamMedium
        tabLabel.TextSize = 13
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton

        local tabObj = {
            Button = tabButton,
            Page = page,
            Icon = tabIcon,
            Label = tabLabel
        }

        local function Select()
            if window.ActiveTab then
                window.ActiveTab.Page.Visible = false
                window.ActiveTab.Button.BackgroundTransparency = 1
                window.ActiveTab.Label.TextColor3 = Color3.fromRGB(150, 160, 180)
                window.ActiveTab.Icon.ImageColor3 = Color3.fromRGB(150, 160, 180)
            end
            window.ActiveTab = tabObj
            page.Visible = true
            tabButton.BackgroundTransparency = 0
            tabButton.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
            tabLabel.TextColor3 = Color3.fromRGB(56, 189, 248) -- Cyan Highlight
            tabIcon.ImageColor3 = Color3.fromRGB(56, 189, 248)
        end

        tabButton.MouseButton1Click:Connect(Select)

        -- Hover effects
        tabButton.MouseEnter:Connect(function()
            if window.ActiveTab ~= tabObj then
                Tween(tabLabel, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(220, 225, 235) })
                Tween(tabIcon, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(220, 225, 235) })
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if window.ActiveTab ~= tabObj then
                Tween(tabLabel, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(150, 160, 180) })
                Tween(tabIcon, TweenInfo.new(0.2), { ImageColor3 = Color3.fromRGB(150, 160, 180) })
            end
        end)

        -- Set first tab as active automatically
        if not window.ActiveTab then
            Select()
        end

        -- Add components creator functions on tab object
        function tabObj:Button(btnOptions)
            btnOptions = btnOptions or {}
            local btnName = btnOptions.Name or "Button"
            local desc = btnOptions.Description or ""
            local callback = btnOptions.Callback or function() end

            local elementFrame = Instance.new("Frame")
            elementFrame.Name = btnName .. "_Element"
            elementFrame.Size = UDim2.new(1, -6, 0, 42)
            elementFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 33)
            elementFrame.BorderSizePixel = 0
            elementFrame.Parent = page

            local elCorner = Instance.new("UICorner")
            elCorner.CornerRadius = UDim.new(0, 6)
            elCorner.Parent = elementFrame

            local elStroke = Instance.new("UIStroke")
            elStroke.Color = Color3.fromRGB(28, 33, 45)
            elStroke.Thickness = 1
            elStroke.Parent = elementFrame

            -- Title and description labels container
            local textContainer = Instance.new("Frame")
            textContainer.Size = UDim2.new(0.7, 0, 1, 0)
            textContainer.BackgroundTransparency = 1
            textContainer.Parent = elementFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
            titleLabel.Position = UDim2.new(0, 12, 0.1, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = btnName
            titleLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
            titleLabel.Font = Enum.Font.GothamMedium
            titleLabel.TextSize = 13
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = textContainer

            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0.4, 0)
            descLabel.Position = UDim2.new(0, 12, 0.5, 0)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = desc
            descLabel.TextColor3 = Color3.fromRGB(130, 140, 155)
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 11
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textContainer

            -- Button trigger on the right side
            local actionBtn = Instance.new("TextButton")
            actionBtn.Name = "Trigger"
            actionBtn.Size = UDim2.new(0.25, 0, 0.65, 0)
            actionBtn.Position = UDim2.new(0.72, 0, 0.175, 0)
            actionBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 58)
            actionBtn.Text = "Run"
            actionBtn.TextColor3 = Color3.fromRGB(240, 245, 255)
            actionBtn.Font = Enum.Font.GothamBold
            actionBtn.TextSize = 12
            actionBtn.BorderSizePixel = 0
            actionBtn.Parent = elementFrame

            local actionCorner = Instance.new("UICorner")
            actionCorner.CornerRadius = UDim.new(0, 4)
            actionCorner.Parent = actionBtn

            actionBtn.MouseEnter:Connect(function()
                Tween(actionBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(56, 189, 248), TextColor3 = Color3.fromRGB(15, 17, 23) })
            end)

            actionBtn.MouseLeave:Connect(function()
                Tween(actionBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(35, 42, 58), TextColor3 = Color3.fromRGB(240, 245, 255) })
            end)

            actionBtn.MouseButton1Click:Connect(function()
                -- Visual click feedback
                actionBtn.TextSize = 10
                task.delay(0.08, function() actionBtn.TextSize = 12 end)
                callback()
            end)
        end

        function tabObj:Toggle(toggleOptions)
            toggleOptions = toggleOptions or {}
            local toggleName = toggleOptions.Name or "Toggle"
            local desc = toggleOptions.Description or ""
            local state = toggleOptions.StartingState or false
            local callback = toggleOptions.Callback or function() end

            local elementFrame = Instance.new("Frame")
            elementFrame.Name = toggleName .. "_Element"
            elementFrame.Size = UDim2.new(1, -6, 0, 42)
            elementFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 33)
            elementFrame.BorderSizePixel = 0
            elementFrame.Parent = page

            local elCorner = Instance.new("UICorner")
            elCorner.CornerRadius = UDim.new(0, 6)
            elCorner.Parent = elementFrame

            local elStroke = Instance.new("UIStroke")
            elStroke.Color = Color3.fromRGB(28, 33, 45)
            elStroke.Thickness = 1
            elStroke.Parent = elementFrame

            -- Labels
            local textContainer = Instance.new("Frame")
            textContainer.Size = UDim2.new(0.7, 0, 1, 0)
            textContainer.BackgroundTransparency = 1
            textContainer.Parent = elementFrame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0.5, 0)
            titleLabel.Position = UDim2.new(0, 12, 0.1, 0)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = toggleName
            titleLabel.TextColor3 = Color3.fromRGB(230, 235, 245)
            titleLabel.Font = Enum.Font.GothamMedium
            titleLabel.TextSize = 13
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = textContainer

            local descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0.4, 0)
            descLabel.Position = UDim2.new(0, 12, 0.5, 0)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = desc
            descLabel.TextColor3 = Color3.fromRGB(130, 140, 155)
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 11
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = textContainer

            -- Switch toggle graphic on right side
            local toggleBg = Instance.new("TextButton")
            toggleBg.Name = "ToggleBg"
            toggleBg.Size = UDim2.fromOffset(36, 18)
            toggleBg.Position = UDim2.new(0.95, -36, 0.5, -9)
            toggleBg.BackgroundColor3 = state and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(45, 50, 65)
            toggleBg.Text = ""
            toggleBg.BorderSizePixel = 0
            toggleBg.Parent = elementFrame

            local toggleBgCorner = Instance.new("UICorner")
            toggleBgCorner.CornerRadius = UDim.new(1, 0)
            toggleBgCorner.Parent = toggleBg

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Name = "Circle"
            toggleCircle.Size = UDim2.fromOffset(12, 12)
            toggleCircle.Position = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleBg

            local toggleCircleCorner = Instance.new("UICorner")
            toggleCircleCorner.CornerRadius = UDim.new(1, 0)
            toggleCircleCorner.Parent = toggleCircle

            local function updateToggle()
                if state then
                    Tween(toggleBg, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(16, 185, 129) })
                    Tween(toggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(1, -15, 0.5, -6) })
                else
                    Tween(toggleBg, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(45, 50, 65) })
                    Tween(toggleCircle, TweenInfo.new(0.2), { Position = UDim2.new(0, 3, 0.5, -6) })
                end
            end

            toggleBg.MouseButton1Click:Connect(function()
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
