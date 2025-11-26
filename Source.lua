-- TurtleUiLib (Updated) — Modern HTML-like style, themes, and smooth animations
-- Keeps original API: library:Window(name) -> functions: Button, Label, Toggle, Box, Slider, Dropdown, ColorPicker, Destroy

local library = {}
local windowCount = 0
local sizes = {}
local listOffset = {}
local windows = {}
local pastSliders = {}
local dropdowns = {}
local dropdownSizes = {}
local destroyed
local colorPickers = {}

if game.CoreGui:FindFirstChild('TurtleUiLib') then
    game.CoreGui:FindFirstChild('TurtleUiLib'):Destroy()
    destroyed = true
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local stepped = RunService.Stepped
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Helpers
function Lerp(a, b, c)
    return a + ((b - a) * c)
end

-- Drag helper
function Dragify(obj)
    spawn(function()
        local minitial
        local initial
        local isdragging
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isdragging = true
                minitial = input.Position
                initial = obj.Position
                local con
                con = stepped:Connect(function()
                    if isdragging then
                        local delta = Vector3.new(mouse.X, mouse.Y, 0) - minitial
                        obj.Position = UDim2.new(initial.X.Scale, initial.X.Offset + delta.X, initial.Y.Scale, initial.Y.Offset + delta.Y)
                    else
                        con:Disconnect()
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isdragging = false
                    end
                end)
            end
        end)
    end)
end

-- Instances and protection
local function protect_gui(obj)
    if destroyed then
       obj.Parent = game.CoreGui
       return
    end
    if syn and syn.protect_gui then
        syn.protect_gui(obj)
        obj.Parent = game.CoreGui
    elseif PROTOSMASHER_LOADED then
        obj.Parent = get_hidden_gui()
    else
        obj.Parent = game.CoreGui
    end
end

-- Theme engine (neutral, modern palettes)
local Themes = {
    Dark = {
        Window = Color3.fromRGB(28,28,28),
        WindowBorder = Color3.fromRGB(28,28,28),
        Header = Color3.fromRGB(40,40,40),
        HeaderBorder = Color3.fromRGB(40,40,40),
        HeaderText = Color3.fromRGB(240,240,240),
        Primary = Color3.fromRGB(60,60,60),
        Button = Color3.fromRGB(38,38,38),
        ButtonBorder = Color3.fromRGB(60,60,60),
        Text = Color3.fromRGB(230,230,230),
        Accent = Color3.fromRGB(220,220,220),
        SliderFill = Color3.fromRGB(255,255,255), -- white slider knob/fill
        ToggleOn = Color3.fromRGB(200,200,200),
        PickerBackground = Color3.fromRGB(32,32,32),
        RainbowAccent = false,
    },
    MatrixGreen = {
        Window = Color3.fromRGB(20,24,20),
        WindowBorder = Color3.fromRGB(20,24,20),
        Header = Color3.fromRGB(40,60,40),
        HeaderBorder = Color3.fromRGB(40,60,40),
        HeaderText = Color3.fromRGB(230,230,230),
        Primary = Color3.fromRGB(36,48,36),
        Button = Color3.fromRGB(25,30,25),
        ButtonBorder = Color3.fromRGB(50,60,50),
        Text = Color3.fromRGB(220,235,220),
        Accent = Color3.fromRGB(125,140,125),
        SliderFill = Color3.fromRGB(216,235,216),
        ToggleOn = Color3.fromRGB(100,140,100),
        PickerBackground = Color3.fromRGB(25,30,25),
        RainbowAccent = false,
    },
    NeonBlue = {
        Window = Color3.fromRGB(18,22,30),
        WindowBorder = Color3.fromRGB(18,22,30),
        Header = Color3.fromRGB(35,70,110),
        HeaderBorder = Color3.fromRGB(35,70,110),
        HeaderText = Color3.fromRGB(230,230,230),
        Primary = Color3.fromRGB(30,50,75),
        Button = Color3.fromRGB(28,33,45),
        ButtonBorder = Color3.fromRGB(65,90,120),
        Text = Color3.fromRGB(235,240,245),
        Accent = Color3.fromRGB(130,160,200),
        SliderFill = Color3.fromRGB(210,225,255),
        ToggleOn = Color3.fromRGB(110,140,180),
        PickerBackground = Color3.fromRGB(25,32,44),
        RainbowAccent = false,
    },
    GlassDark = {
        Window = Color3.fromRGB(30,32,38),
        WindowBorder = Color3.fromRGB(30,32,38),
        Header = Color3.fromRGB(70,90,150),
        HeaderBorder = Color3.fromRGB(70,90,150),
        HeaderText = Color3.fromRGB(240,240,240),
        Primary = Color3.fromRGB(36,46,60),
        Button = Color3.fromRGB(40,45,55),
        ButtonBorder = Color3.fromRGB(85,95,115),
        Text = Color3.fromRGB(240,240,240),
        Accent = Color3.fromRGB(150,175,220),
        SliderFill = Color3.fromRGB(220,230,255),
        ToggleOn = Color3.fromRGB(130,155,200),
        PickerBackground = Color3.fromRGB(45,50,60),
        RainbowAccent = false,
    },
    AestheticPink = {
        Window = Color3.fromRGB(36,24,30),
        WindowBorder = Color3.fromRGB(36,24,30),
        Header = Color3.fromRGB(158,111,125),
        HeaderBorder = Color3.fromRGB(158,111,125),
        HeaderText = Color3.fromRGB(245,245,245),
        Primary = Color3.fromRGB(48,36,40),
        Button = Color3.fromRGB(55,40,48),
        ButtonBorder = Color3.fromRGB(110,85,98),
        Text = Color3.fromRGB(245,245,245),
        Accent = Color3.fromRGB(190,150,165),
        SliderFill = Color3.fromRGB(220,180,190),
        ToggleOn = Color3.fromRGB(170,130,150),
        PickerBackground = Color3.fromRGB(55,40,48),
        RainbowAccent = false,
    }
}

local currentTheme = Themes.Dark

local function resolveThemeInput(v)
    if type(v) == "string" then
        return Themes[v] or currentTheme
    elseif type(v) == "table" then
        local t = {}
        for k, val in pairs(currentTheme) do t[k] = val end
        for k, val in pairs(v) do t[k] = val end
        return t
    else
        return currentTheme
    end
end

-- helper: add UICorner + optional UIStroke
local function addCornerAndStroke(instance, radius, strokeThickness, strokeColor)
    local ok, err = pcall(function()
        if instance and instance:IsA("Instance") then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, radius or 6)
            corner.Parent = instance
            if strokeThickness and strokeThickness > 0 then
                local stroke = Instance.new("UIStroke")
                stroke.Thickness = strokeThickness
                if strokeColor then stroke.Color = strokeColor else
                    if instance:IsA("Frame") or instance:IsA("ImageLabel") then
                        stroke.Color = instance.BorderColor3 or Color3.new(0,0,0)
                    else
                        stroke.Color = Color3.new(0,0,0)
                    end
                end
                stroke.Parent = instance
            end
        end
    end)
    if not ok then warn("Corner/Stroke helper failed:", err) end
end

-- Apply theme to existing UI elements (best-effort)
local function applyThemeToExisting(theme)
    for _, obj in ipairs(game.CoreGui:GetDescendants()) do
        -- Only affect TurtleUiLib descendants
        if obj.Parent and obj.Parent:IsDescendantOf(game.CoreGui) and obj:FindFirstAncestor("TurtleUiLib") then
            pcall(function()
                if obj.Name == "UiWindow" then obj.BackgroundColor3 = theme.Window end
                if obj.Name == "Header" then obj.BackgroundColor3 = theme.Header end
                if obj.Name == "Window" then obj.BackgroundColor3 = theme.Window end
                if obj.Name == "Button" and obj.Parent and obj.Parent.Name == "Window" then
                    obj.BackgroundColor3 = theme.Button
                    obj.BorderColor3 = theme.ButtonBorder
                end
                if obj.Name == "ToggleButton" then obj.BackgroundColor3 = theme.Window end
                if obj.Name == "ToggleFiller" then obj.BackgroundColor3 = theme.ToggleOn end
                if obj.Name == "Slider" then obj.BackgroundColor3 = theme.Window end
                if obj.Name == "SilderFiller" then obj.BackgroundColor3 = theme.SliderFill end
                if obj.Name == "Dropdown" then
                    obj.BackgroundColor3 = theme.Button
                    obj.BorderColor3 = theme.ButtonBorder
                end
                if obj.Name == "ColorPicker" then obj.BackgroundColor3 = theme.Button end
                if obj.Name == "ColorPickerFrame" then
                    obj.BackgroundColor3 = theme.PickerBackground
                    obj.BorderColor3 = theme.PickerBackground
                end
                if (obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton")) then
                    if obj.Name == "HeaderText" or obj.Name == "Title" then
                        obj.TextColor3 = theme.HeaderText
                    else
                        obj.TextColor3 = theme.Text
                    end
                end
            end)
        end
    end
end

function library:SetTheme(themeInput)
    local t = resolveThemeInput(themeInput)
    currentTheme = t
    applyThemeToExisting(currentTheme)
end

function library:GetTheme()
    return currentTheme
end

function library:ListThemes()
    local names = {}
    for k, _ in pairs(Themes) do table.insert(names, k) end
    return names
end

library.Themes = Themes
library:SetTheme("Dark")

-- Create main ScreenGui
local TurtleUiLib = Instance.new("ScreenGui")
TurtleUiLib.Name = "TurtleUiLib"
protect_gui(TurtleUiLib)

local xOffset = 20
local keybindConnection

function library:Destroy()
    if TurtleUiLib and TurtleUiLib.Parent then TurtleUiLib:Destroy() end
    if keybindConnection then keybindConnection:Disconnect() end
end

function library:Hide()
   TurtleUiLib.Enabled = not TurtleUiLib.Enabled
end

function library:Keybind(key)
    if keybindConnection then keybindConnection:Disconnect() end
    keybindConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode[key] then
            TurtleUiLib.Enabled = not TurtleUiLib.Enabled
        end
    end)
end

-- Main Window builder
function library:Window(name)
    windowCount = windowCount + 1
    local winCount = windowCount
    local zindex = winCount * 7

    -- Outer frame (UiWindow)
    local UiWindow = Instance.new("Frame")
    UiWindow.Name = "UiWindow"
    UiWindow.Parent = TurtleUiLib
    UiWindow.BackgroundColor3 = currentTheme.Primary
    UiWindow.BorderColor3 = currentTheme.WindowBorder
    UiWindow.Position = UDim2.new(0, xOffset, 0, 20)
    UiWindow.Size = UDim2.new(0, 207, 0, 33)
    UiWindow.ZIndex = 4 + zindex
    UiWindow.Active = true
    addCornerAndStroke(UiWindow, 8, 0)
    Dragify(UiWindow)
    xOffset = xOffset + 230

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = UiWindow
    Header.BackgroundColor3 = currentTheme.Header
    Header.BorderColor3 = currentTheme.HeaderBorder
    Header.Position = UDim2.new(0, 0, -0.0202544238, 0)
    Header.Size = UDim2.new(0, 207, 0, 26)
    Header.ZIndex = 5 + zindex
    addCornerAndStroke(Header, 8, 0)

    local HeaderText = Instance.new("TextLabel")
    HeaderText.Name = "HeaderText"
    HeaderText.Parent = Header
    HeaderText.BackgroundTransparency = 1
    HeaderText.Position = UDim2.new(0, 12, -0.0020698905, 0)
    HeaderText.Size = UDim2.new(0, 180, 0, 26)
    HeaderText.ZIndex = 6 + zindex
    HeaderText.Font = Enum.Font.SourceSans
    HeaderText.Text = name or "Window"
    HeaderText.TextColor3 = currentTheme.HeaderText
    HeaderText.TextSize = 17

    -- Minimise button with tween
    local Minimise = Instance.new("TextButton")
    Minimise.Name = "Minimise"
    Minimise.Parent = Header
    Minimise.BackgroundColor3 = currentTheme.Header
    Minimise.BorderColor3 = currentTheme.HeaderBorder
    Minimise.Position = UDim2.new(0, 185, 0, 2)
    Minimise.Size = UDim2.new(0, 22, 0, 22)
    Minimise.ZIndex = 7 + zindex
    Minimise.Font = Enum.Font.SourceSansLight
    Minimise.Text = "_"
    Minimise.TextColor3 = currentTheme.Text
    Minimise.TextSize = 20
    addCornerAndStroke(Minimise, 5, 0)

    local Window = Instance.new("Frame")
    Window.Name = "Window"
    Window.Parent = Header
    Window.BackgroundColor3 = currentTheme.Window
    Window.BorderColor3 = currentTheme.WindowBorder
    Window.Position = UDim2.new(0, 0, 0, 0)
    Window.Size = UDim2.new(0, 207, 0, 33)
    Window.ZIndex = 1 + zindex
    addCornerAndStroke(Window, 6, 0)

    -- animate minimize/open
    Minimise.MouseButton1Up:Connect(function()
        local visible = not Window.Visible
        local tInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if visible then
            Window.Visible = true
            TweenService:Create(Window, tInfo, {Size = UDim2.new(0,207,0,sizes[winCount]+10), BackgroundTransparency = 0}):Play()
            Minimise.Text = "_"
        else
            -- collapse to header height then hide
            local closeTween = TweenService:Create(Window, tInfo, {Size = UDim2.new(0,207,0,33), BackgroundTransparency = 1})
            closeTween:Play()
            closeTween.Completed:Connect(function()
                Window.Visible = false
                Minimise.Text = "+"
            end)
        end
    end)

    -- functions table returned to user
    local functions = {}
    functions.__index = functions
    functions.Ui = UiWindow

    sizes[winCount] = 33
    listOffset[winCount] = 10

    function functions:Destroy()
        if self.Ui and self.Ui.Parent then self.Ui:Destroy() end
    end

    -- Button
    function functions:Button(name, callback)
        local name = name or "Button"
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32
        local Button = Instance.new("TextButton")
        Button.Name = "Button"
        Button.Parent = Window
        Button.BackgroundColor3 = currentTheme.Button
        Button.BorderColor3 = currentTheme.ButtonBorder
        Button.Position = UDim2.new(0, 12, 0, listOffset[winCount])
        Button.Size = UDim2.new(0, 182, 0, 26)
        Button.ZIndex = 2 + zindex
        Button.Font = Enum.Font.SourceSans
        Button.TextColor3 = currentTheme.Text
        Button.TextSize = 16
        Button.TextWrapped = true
        Button.Text = name
        addCornerAndStroke(Button, 6, 0)

        -- hover tween
        Button.MouseEnter:Connect(function()
            local t = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            pcall(function() TweenService:Create(Button, t, {BackgroundColor3 = currentTheme.Accent}):Play() end)
        end)
        Button.MouseLeave:Connect(function()
            local t = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            pcall(function() TweenService:Create(Button, t, {BackgroundColor3 = currentTheme.Button}):Play() end)
        end)

        Button.MouseButton1Down:Connect(function(...)
            pcall(callback, ...)
        end)

        pastSliders[winCount] = false
    end

    -- Label
    function functions:Label(text, color)
        local color = color or currentTheme.Text

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32
        local Label = Instance.new("TextLabel")
        Label.Name = "Label"
        Label.Parent = Window
        Label.BackgroundTransparency = 1
        Label.BorderColor3 = currentTheme.WindowBorder
        Label.Position = UDim2.new(0, 0, 0, listOffset[winCount])
        Label.Size = UDim2.new(0, 206, 0, 29)
        Label.Font = Enum.Font.SourceSans
        Label.Text = text or "Label"
        Label.TextSize = 16
        Label.ZIndex = 2 + zindex

        if type(color) == "boolean" and color then
            spawn(function()
                while Label.Parent and wait() do
                    local hue = tick() % 5 / 5
                    Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
                end
            end)
        else
            Label.TextColor3 = color
        end
        pastSliders[winCount] = false
        return Label
    end

    -- Toggle
    function functions:Toggle(text, on, callback)
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32

        local ToggleDescription = Instance.new("TextLabel")
        ToggleDescription.Name = "ToggleDescription"
        ToggleDescription.Parent = Window
        ToggleDescription.BackgroundTransparency = 1
        ToggleDescription.Position = UDim2.new(0, 14, 0, listOffset[winCount])
        ToggleDescription.Size = UDim2.new(0, 131, 0, 26)
        ToggleDescription.Font = Enum.Font.SourceSans
        ToggleDescription.Text = text or "Toggle"
        ToggleDescription.TextColor3 = currentTheme.Text
        ToggleDescription.TextSize = 16
        ToggleDescription.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDescription.ZIndex = 2 + zindex

        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Parent = ToggleDescription
        ToggleButton.BackgroundColor3 = currentTheme.Window
        ToggleButton.BorderColor3 = currentTheme.ButtonBorder
        ToggleButton.Position = UDim2.new(1.2061069, 0, 0.0769230798, 0)
        ToggleButton.Size = UDim2.new(0, 22, 0, 22)
        ToggleButton.Font = Enum.Font.SourceSans
        ToggleButton.Text = ""
        ToggleButton.TextColor3 = currentTheme.Text
        ToggleButton.ZIndex = 2 + zindex
        addCornerAndStroke(ToggleButton, 6, 0)

        local ToggleFiller = Instance.new("Frame")
        ToggleFiller.Name = "ToggleFiller"
        ToggleFiller.Parent = ToggleButton
        ToggleFiller.BackgroundColor3 = currentTheme.ToggleOn
        ToggleFiller.BorderColor3 = currentTheme.Window
        ToggleFiller.Position = UDim2.new(0, 5, 0, 5)
        ToggleFiller.Size = UDim2.new(0, 12, 0, 12)
        ToggleFiller.Visible = on
        ToggleFiller.ZIndex = 2 + zindex
        addCornerAndStroke(ToggleFiller, 6, 0)

        -- animate toggle
        ToggleButton.MouseButton1Up:Connect(function()
            ToggleFiller.Visible = not ToggleFiller.Visible
            local targetPos = ToggleFiller.Visible and UDim2.new(0,5,0,5) or UDim2.new(0,5,0,5) -- internal filler used as a check (keeps layout)
            pcall(function() TweenService:Create(ToggleFiller, TweenInfo.new(0.12), {BackgroundColor3 = ToggleFiller.Visible and currentTheme.ToggleOn or currentTheme.Window}):Play() end)
            callback(ToggleFiller.Visible)
        end)

        pastSliders[winCount] = false
    end

    -- Text Box
    function functions:Box(text, callback)
        local callback = callback or function() end

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)

        listOffset[winCount] = listOffset[winCount] + 32
        local TextBox = Instance.new("TextBox")
        local BoxDescription = Instance.new("TextLabel")
        TextBox.Parent = Window
        TextBox.BackgroundColor3 = currentTheme.Button
        TextBox.BorderColor3 = currentTheme.ButtonBorder
        TextBox.Position = UDim2.new(0, 99, 0, listOffset[winCount])
        TextBox.Size = UDim2.new(0, 95, 0, 26)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.PlaceholderColor3 = Color3.fromRGB(220, 221, 225)
        TextBox.PlaceholderText = "..."
        TextBox.Text = ""
        TextBox.TextColor3 = currentTheme.Text
        TextBox.TextSize = 16
        TextBox.ZIndex = 2 + zindex
        addCornerAndStroke(TextBox, 6, 0)

        TextBox:GetPropertyChangedSignal('Text'):Connect(function()
            callback(TextBox.Text, false)
        end)
        TextBox.FocusLost:Connect(function()
            callback(TextBox.Text, true)
        end)

        BoxDescription.Name = "BoxDescription"
        BoxDescription.Parent = TextBox
        BoxDescription.BackgroundTransparency = 1
        BoxDescription.Position = UDim2.new(-0.894736826, 0, 0, 0)
        BoxDescription.Size = UDim2.new(0, 75, 0, 26)
        BoxDescription.Font = Enum.Font.SourceSans
        BoxDescription.Text = text or "Box"
        BoxDescription.TextColor3 = currentTheme.Text
        BoxDescription.TextSize = 16
        BoxDescription.TextXAlignment = Enum.TextXAlignment.Left
        BoxDescription.ZIndex = 2 + zindex
        pastSliders[winCount] = false
    end

    -- Slider (modern, smooth)
    function functions:Slider(text, min, max, default, callback)
        local text = text or "Slider"
        local min = min or 1
        local max = max or 100
        local default = default or max/2
        local callback = callback or function() end
        local offset = 70
        if default > max then default = max elseif default < min then default = min end
        if pastSliders[winCount] then offset = 60 end

        sizes[winCount] = sizes[winCount] + offset
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)
        listOffset[winCount] = listOffset[winCount] + offset

        local Slider = Instance.new("Frame")
        local SliderButton = Instance.new("Frame")
        local Description = Instance.new("TextLabel")
        local SilderFiller = Instance.new("Frame")
        local Current = Instance.new("TextLabel")
        local Min = Instance.new("TextLabel")
        local Max = Instance.new("TextLabel")

        Slider.Name = "Slider"
        Slider.Parent = Window
        Slider.BackgroundColor3 = currentTheme.Window
        Slider.BorderColor3 = currentTheme.WindowBorder
        Slider.Position = UDim2.new(0, 13, 0, listOffset[winCount])
        Slider.Size = UDim2.new(0, 180, 0, 6)
        Slider.ZIndex = 2 + zindex

        SilderFiller.Name = "SilderFiller"
        SilderFiller.Parent = Slider
        SilderFiller.BackgroundColor3 = currentTheme.SliderFill
        SilderFiller.BorderColor3 = currentTheme.Window
        SilderFiller.Size = UDim2.new(0, (Slider.Size.X.Offset - 5) * ((default - min)/(max-min)), 0, 6)
        SilderFiller.ZIndex = 2 + zindex
        SilderFiller.BorderMode = Enum.BorderMode.Inset
        addCornerAndStroke(Slider, 4, 0)
        addCornerAndStroke(SilderFiller, 4, 0)

        SliderButton.Name = "SliderButton"
        SliderButton.Parent = Slider
        -- white knob in Dark, otherwise theme button
        SliderButton.BackgroundColor3 = (currentTheme == Themes.Dark) and Color3.fromRGB(255,255,255) or currentTheme.Button
        SliderButton.BorderColor3 = currentTheme.ButtonBorder
        SliderButton.Size = UDim2.new(0, 10, 0, 14)
        SliderButton.ZIndex = 3 + zindex
        SliderButton.Position = UDim2.new(0, (Slider.Size.X.Offset - 5) * ((default - min)/(max-min)), -1.333337, 0)
        addCornerAndStroke(SliderButton, 6, 0)

        Current.Name = "Current"
        Current.Parent = SliderButton
        Current.BackgroundTransparency = 1
        Current.Position = UDim2.new(0, 3, 0, 22)
        Current.Size = UDim2.new(0, 0, 0, 18)
        Current.Font = Enum.Font.SourceSans
        Current.Text = tostring(default)
        Current.TextColor3 = currentTheme.Text
        Current.TextSize = 14
        Current.ZIndex = 2 + zindex

        Description.Name = "Description"
        Description.Parent = Slider
        Description.BackgroundTransparency = 1
        Description.Position = UDim2.new(0, -10, 0, -35)
        Description.Size = UDim2.new(0, 200, 0, 21)
        Description.Font = Enum.Font.SourceSans
        Description.Text = text
        Description.TextColor3 = currentTheme.Text
        Description.TextSize = 16
        Description.ZIndex = 2 + zindex

        Min.Name = "Min"
        Min.Parent = Slider
        Min.BackgroundTransparency = 1
        Min.Position = UDim2.new(-0.00555555569, 0, -7.33333397, 0)
        Min.Size = UDim2.new(0, 77, 0, 50)
        Min.Font = Enum.Font.SourceSans
        Min.Text = tostring(min)
        Min.TextColor3 = currentTheme.Text
        Min.TextSize = 14
        Min.TextXAlignment = Enum.TextXAlignment.Left
        Min.ZIndex = 2 + zindex

        Max.Name = "Max"
        Max.Parent = Slider
        Max.BackgroundTransparency = 1
        Max.Position = UDim2.new(0.577777743, 0, -7.33333397, 0)
        Max.Size = UDim2.new(0, 77, 0, 50)
        Max.Font = Enum.Font.SourceSans
        Max.Text = tostring(max)
        Max.TextColor3 = currentTheme.Text
        Max.TextSize = 14
        Max.TextXAlignment = Enum.TextXAlignment.Right
        Max.ZIndex = 2 + zindex

        -- tween helper
        local function updateVisualsTo(xOffset)
            local tInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            pcall(function()
                TweenService:Create(SilderFiller, tInfo, {Size = UDim2.new(0, xOffset, 0, 6)}):Play()
                TweenService:Create(SliderButton, tInfo, {Position = UDim2.new(0, xOffset, -1.33333337, 0)}):Play()
            end)
        end

        local isdragging = false
        local delta1 = 0
        local function SliderMovement(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isdragging = true
                delta1 = SliderButton.AbsolutePosition.X - SliderButton.Position.X.Offset
                local con
                con = stepped:Connect(function()
                    if isdragging then
                        local xOffset = math.clamp(mouse.X - delta1 - 3, 0, Slider.Size.X.Offset - 5)
                        SliderButton.Position = UDim2.new(0, xOffset , -1.33333337, 0)
                        SilderFiller.Size = UDim2.new(0, xOffset, 0, 6)
                        local value = Lerp(min, max, SliderButton.Position.X.Offset/(Slider.Size.X.Offset-5))
                        Current.Text = tostring(math.round(value))
                    else
                        con:Disconnect()
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isdragging = false
                        local xOffset = SliderButton.Position.X.Offset
                        local value = Lerp(min, max, xOffset/(Slider.Size.X.Offset-5))
                        callback(math.round(value))
                        updateVisualsTo(xOffset)
                    end
                end)
            end
        end

        Slider.InputBegan:Connect(SliderMovement)
        Slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local xOffset = SliderButton.Position.X.Offset
                local value = Lerp(min, max, xOffset/(Slider.Size.X.Offset-5))
                callback(math.round(value))
            end
        end)
        SliderButton.InputBegan:Connect(SliderMovement)
        SliderButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local xOffset = SliderButton.Position.X.Offset
                local value = Lerp(min, max, xOffset/(Slider.Size.X.Offset-5))
                callback(math.round(value))
                updateVisualsTo(xOffset)
            end
        end)

        pastSliders[winCount] = true

        local slider = {}
        function slider:SetValue(value)
            value = math.clamp(value, min, max)
            local xOffset = (value-min)/(max-min) * (Slider.Size.X.Offset - 5)
            Current.Text = tostring(math.round(value))
            updateVisualsTo(xOffset)
        end
        return slider
    end

    -- Dropdown (animated)
    function functions:Dropdown(text, buttons, callback, selective)
        local text = text or "Dropdown"
        local buttons = buttons or {}
        local callback = callback or function() end

        local Dropdown = Instance.new("TextButton")
        local DownSign = Instance.new("TextLabel")
        local DropdownFrame = Instance.new("ScrollingFrame")

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)
        listOffset[winCount] = listOffset[winCount] + 32

        Dropdown.Name = "Dropdown"
        Dropdown.Parent = Window
        Dropdown.BackgroundColor3 = currentTheme.Button
        Dropdown.BorderColor3 = currentTheme.ButtonBorder
        Dropdown.Position = UDim2.new(0, 12, 0, listOffset[winCount])
        Dropdown.Size = UDim2.new(0, 182, 0, 26)
        Dropdown.Font = Enum.Font.SourceSans
        Dropdown.Text = tostring(text)
        Dropdown.TextColor3 = currentTheme.Text
        Dropdown.TextSize = 16
        Dropdown.TextWrapped = true
        Dropdown.ZIndex = 3 + zindex
        addCornerAndStroke(Dropdown, 6, 0)

        DownSign.Name = "DownSign"
        DownSign.Parent = Dropdown
        DownSign.BackgroundTransparency = 1
        DownSign.Position = UDim2.new(0, 155, 0, 2)
        DownSign.Size = UDim2.new(0, 27, 0, 22)
        DownSign.Font = Enum.Font.SourceSans
        DownSign.Text = "^"
        DownSign.TextColor3 = currentTheme.Text
        DownSign.TextSize = 20
        DownSign.ZIndex = 4 + zindex
        DownSign.TextYAlignment = Enum.TextYAlignment.Bottom

        DropdownFrame.Name = "DropdownFrame"
        DropdownFrame.Parent = Dropdown
        DropdownFrame.Active = true
        DropdownFrame.BackgroundColor3 = currentTheme.Button
        DropdownFrame.BorderColor3 = currentTheme.Button
        DropdownFrame.Position = UDim2.new(0, 0, 0, 28)
        DropdownFrame.Size = UDim2.new(0, 182, 0, 0)
        DropdownFrame.Visible = false
        DropdownFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        DropdownFrame.ScrollBarThickness = 4
        DropdownFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
        DropdownFrame.ZIndex = 5 + zindex
        DropdownFrame.ScrollingDirection = Enum.ScrollingDirection.Y
        DropdownFrame.ScrollBarImageColor3 = currentTheme.Text
        addCornerAndStroke(DropdownFrame, 6, 0)

        table.insert(dropdowns, DropdownFrame)
        local dropFunctions = {}
        local canvasSize = 0

        local function toggleDropdown()
            -- animate height and caret rotation
            local tInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            if DropdownFrame.Visible then
                -- collapse
                TweenService:Create(DropdownFrame, tInfo, {Size = UDim2.new(0,182,0,0)}):Play()
                TweenService:Create(DownSign, tInfo, {Rotation = 0}):Play()
                wait(0.18)
                DropdownFrame.Visible = false
            else
                DropdownFrame.Visible = true
                TweenService:Create(DropdownFrame, tInfo, {Size = UDim2.new(0,182,0,math.min(27*#DropdownFrame:GetChildren(), 162))}):Play()
                TweenService:Create(DownSign, tInfo, {Rotation = 180}):Play()
            end
        end

        Dropdown.MouseButton1Up:Connect(function()
            -- hide other dropdowns
            for i, v in pairs(dropdowns) do
                if v ~= DropdownFrame then
                    if v.Visible then
                        TweenService:Create(v, TweenInfo.new(0.12), {Size = UDim2.new(0,182,0,0)}):Play()
                        v.Visible = false
                    end
                end
            end
            toggleDropdown()
        end)

        function dropFunctions:Button(name)
            local name = name or ""
            local Button_2 = Instance.new("TextButton")
            Button_2.Name = "Button"
            Button_2.Parent = DropdownFrame
            Button_2.BackgroundColor3 = currentTheme.Button
            Button_2.BorderColor3 = currentTheme.ButtonBorder
            Button_2.Position = UDim2.new(0, 6, 0, canvasSize + 1)
            Button_2.Size = UDim2.new(0, 170, 0, 26)
            Button_2.Font = Enum.Font.SourceSans
            Button_2.TextColor3 = currentTheme.Text
            Button_2.TextSize = 16
            Button_2.ZIndex = 6 + zindex
            Button_2.Text = name
            Button_2.TextWrapped = true
            addCornerAndStroke(Button_2, 6, 0)
            canvasSize = canvasSize + 27
            DropdownFrame.CanvasSize = UDim2.new(0, 182, 0, canvasSize + 1)
            if #DropdownFrame:GetChildren() < 8 then
                DropdownFrame.Size = UDim2.new(0, 182, 0, DropdownFrame.Size.Y.Offset + 27)
            end
            Button_2.MouseButton1Up:Connect(function()
                callback(name)
                -- collapse animated
                toggleDropdown()
                if selective then Dropdown.Text = name end
            end)
        end

        function dropFunctions:Remove(name)
            local foundIt
            for i, v in pairs(DropdownFrame:GetChildren()) do
                if foundIt then
                    canvasSize = canvasSize - 27
                    v.Position = UDim2.new(0, 6, 0, v.Position.Y.Offset - 27)
                    DropdownFrame.CanvasSize = UDim2.new(0, 182, 0, canvasSize + 1)
                end
                if v.Text == name then
                    foundIt = true
                    v:Destroy()
                    if #DropdownFrame:GetChildren() < 8 then
                        DropdownFrame.Size = UDim2.new(0, 182, 0, DropdownFrame.Size.Y.Offset - 27)
                    end
                end
            end
            if not foundIt then warn("The button you tried to remove didn't exist!") end
        end

        for i,v in pairs(buttons) do dropFunctions:Button(v) end
        return dropFunctions
    end

    -- ColorPicker (kept original behavior but with small visual helpers)
    function functions:ColorPicker(name, default, callback)
        local callback = callback or function() end

        local ColorPicker = Instance.new("TextButton")
        local PickerCorner = Instance.new("UICorner")
        local PickerDescription = Instance.new("TextLabel")
        local ColorPickerFrame = Instance.new("Frame")
        local ToggleRGB = Instance.new("TextButton")
        local ToggleFiller_2 = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")
        local ClosePicker = Instance.new("TextButton")
        local Canvas = Instance.new("Frame")
        local CanvasGradient = Instance.new("UIGradient")
        local Cursor = Instance.new("ImageLabel")
        local Color = Instance.new("Frame")
        local ColorGradient = Instance.new("UIGradient")
        local ColorSlider = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local UICorner = Instance.new("UICorner")
        local ColorCorner = Instance.new("UICorner")
        local BlackOverlay = Instance.new("ImageLabel")

        sizes[winCount] = sizes[winCount] + 32
        Window.Size = UDim2.new(0, 207, 0, sizes[winCount] + 10)
        listOffset[winCount] = listOffset[winCount] + 32

        ColorPicker.Name = "ColorPicker"
        ColorPicker.Parent = Window
        ColorPicker.Position = UDim2.new(0, 137, 0, listOffset[winCount])
        ColorPicker.Size = UDim2.new(0, 57, 0, 26)
        ColorPicker.Font = Enum.Font.SourceSans
        ColorPicker.Text = ""
        ColorPicker.TextColor3 = currentTheme.Text
        ColorPicker.TextSize = 14
        ColorPicker.ZIndex = 2 + zindex
        addCornerAndStroke(ColorPicker, 6, 0)

        ColorPicker.MouseButton1Up:Connect(function()
            for i, v in pairs(colorPickers) do v.Visible = false end
            ColorPickerFrame.Visible = not ColorPickerFrame.Visible
        end)

        PickerDescription.Name = "PickerDescription"
        PickerDescription.Parent = ColorPicker
        PickerDescription.BackgroundTransparency = 1
        PickerDescription.Position = UDim2.new(-2.15789509, 0, 0, 0)
        PickerDescription.Size = UDim2.new(0, 116, 0, 26)
        PickerDescription.Font = Enum.Font.SourceSans
        PickerDescription.Text = name or "Color picker"
        PickerDescription.TextColor3 = currentTheme.Text
        PickerDescription.TextSize = 16
        PickerDescription.TextXAlignment = Enum.TextXAlignment.Left
        PickerDescription.ZIndex = 2 + zindex

        ColorPickerFrame.Name = "ColorPickerFrame"
        ColorPickerFrame.Parent = ColorPicker
        ColorPickerFrame.BackgroundColor3 = currentTheme.PickerBackground
        ColorPickerFrame.BorderColor3 = currentTheme.PickerBackground
        ColorPickerFrame.Position = UDim2.new(1.40350854, 0, -2.84615374, 0)
        ColorPickerFrame.Size = UDim2.new(0, 158, 0, 155)
        ColorPickerFrame.ZIndex = 3 + zindex
        ColorPickerFrame.Visible = false
        addCornerAndStroke(ColorPickerFrame, 6, 0)

        ToggleRGB.Name = "ToggleRGB"
        ToggleRGB.Parent = ColorPickerFrame
        ToggleRGB.BackgroundColor3 = currentTheme.Button
        ToggleRGB.BorderColor3 = currentTheme.ButtonBorder
        ToggleRGB.Position = UDim2.new(0, 125, 0, 127)
        ToggleRGB.Size = UDim2.new(0, 22, 0, 22)
        ToggleRGB.Font = Enum.Font.SourceSans
        ToggleRGB.Text = ""
        ToggleRGB.TextColor3 = currentTheme.Text
        ToggleRGB.TextSize = 14
        ToggleRGB.ZIndex = 4 + zindex
        addCornerAndStroke(ToggleRGB, 4, 0)

        ToggleFiller_2.Name = "ToggleFiller"
        ToggleFiller_2.Parent = ToggleRGB
        ToggleFiller_2.BackgroundColor3 = currentTheme.Accent
        ToggleFiller_2.BorderColor3 = currentTheme.Window
        ToggleFiller_2.Position = UDim2.new(0, 5, 0, 5)
        ToggleFiller_2.Size = UDim2.new(0, 12, 0, 12)
        ToggleFiller_2.ZIndex = 4 + zindex
        ToggleFiller_2.Visible = false
        addCornerAndStroke(ToggleFiller_2, 4, 0)

        TextLabel.Parent = ToggleRGB
        TextLabel.BackgroundTransparency = 1
        TextLabel.Position = UDim2.new(-5.13636351, 0, 0, 0)
        TextLabel.Size = UDim2.new(0, 106, 0, 22)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = "Rainbow"
        TextLabel.TextColor3 = currentTheme.Text
        TextLabel.TextSize = 16
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.ZIndex = 4 + zindex

        ClosePicker.Name = "ClosePicker"
        ClosePicker.Parent = ColorPickerFrame
        ClosePicker.BackgroundColor3 = currentTheme.Button
        ClosePicker.BorderColor3 = currentTheme.ButtonBorder
        ClosePicker.Position = UDim2.new(0, 132, 0, 5)
        ClosePicker.Size = UDim2.new(0, 21, 0, 21)
        ClosePicker.Font = Enum.Font.SourceSans
        ClosePicker.Text = "X"
        ClosePicker.TextColor3 = currentTheme.Text
        ClosePicker.TextSize = 18
        ClosePicker.ZIndex = 4 + zindex
        addCornerAndStroke(ClosePicker, 4, 0)
        ClosePicker.MouseButton1Down:Connect(function()
            ColorPickerFrame.Visible = not ColorPickerFrame.Visible
        end)

        -- Canvas (color selection)
        Canvas.Name = "Canvas"
        Canvas.Parent = ColorPickerFrame
        Canvas.BackgroundColor3 = Color3.fromRGB(255,255,255)
        Canvas.Position = UDim2.new(0, 5, 0, 34)
        Canvas.Size = UDim2.new(0, 148, 0, 64)
        Canvas.ZIndex = 4 + zindex
        addCornerAndStroke(Canvas, 4, 0)

        CanvasGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,255,255))}
        CanvasGradient.Parent = Canvas

        BlackOverlay.Name = "BlackOverlay"
        BlackOverlay.Parent = Canvas
        BlackOverlay.BackgroundTransparency = 1
        BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
        BlackOverlay.Image = "rbxassetid://5107152095"
        BlackOverlay.ZIndex = 5 + zindex

        Cursor.Name = "Cursor"
        Cursor.Parent = Canvas
        Cursor.BackgroundTransparency = 1
        Cursor.Size = UDim2.new(0, 8, 0, 8)
        Cursor.Image = "rbxassetid://5100115962"
        Cursor.ZIndex = 5 + zindex

        local ColorFrame = Instance.new("Frame")
        ColorFrame.Name = "Color"
        ColorFrame.Parent = ColorPickerFrame
        ColorFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
        ColorFrame.Position = UDim2.new(0, 5, 0, 105)
        ColorFrame.Size = UDim2.new(0, 148, 0, 14)
        ColorFrame.BorderMode = Enum.BorderMode.Inset
        ColorFrame.ZIndex = 4 + zindex
        addCornerAndStroke(ColorFrame, 2, 0)

        ColorGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
        })
        ColorGradient.Parent = ColorFrame

        Title.Name = "Title"
        Title.Parent = ColorPickerFrame
        Title.BackgroundTransparency = 1
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(0, 118, 0, 21)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name or "Color picker"
        Title.TextColor3 = currentTheme.Text
        Title.TextSize = 16
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 4 + zindex

        -- color logic (kept behaviour)
        local draggingColor = false
        local hue = 0
        local sat = 1
        local brightness = 1
        local con

        ToggleRGB.MouseButton1Down:Connect(function()
            ToggleFiller_2.Visible = not ToggleFiller_2.Visible
            if ToggleFiller_2.Visible then
                con = stepped:Connect(function()
                    if ToggleFiller_2.Visible then
                        local hue2 = tick() % 5 / 5
                        local color3 = Color3.fromHSV(hue2, 1, 1)
                        callback(color3, true)
                        ColorPicker.BackgroundColor3 = color3
                    else
                        con:Disconnect()
                    end
                end)
            end
        end)

        if default and type(default) == "boolean" then
            ToggleFiller_2.Visible = true
            if ToggleFiller_2.Visible then
                con = stepped:Connect(function()
                    if ToggleFiller_2.Visible then
                        local hue2 = tick() % 5 / 5
                        local color3 = Color3.fromHSV(hue2, 1, 1)
                        callback(color3)
                        ColorPicker.BackgroundColor3 = color3
                    else
                        con:Disconnect()
                    end
                end)
            end
        else
            ColorPicker.BackgroundColor3 = default or currentTheme.Primary
        end

        -- Canvas interaction
        local canvasSize, canvasPosition = Canvas.AbsoluteSize, Canvas.AbsolutePosition
        Canvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local initial = Vector2.new(Cursor.Position.X.Offset, Cursor.Position.Y.Offset)
                local delta = Cursor.AbsolutePosition - initial
                local innerCon
                local isdraggingCanvas = true

                innerCon = stepped:Connect(function()
                    if isdraggingCanvas then
                        local delta2 = Vector2.new(mouse.X, mouse.Y) - delta
                        local x = math.clamp(delta2.X, 2, Canvas.Size.X.Offset - 2)
                        local y = math.clamp(delta2.Y, 2, Canvas.Size.Y.Offset - 2)
                        sat = 1 - math.clamp((mouse.X - canvasPosition.X) / canvasSize.X, 0, 1)
                        brightness = 1 - math.clamp((mouse.Y - canvasPosition.Y) / canvasSize.Y, 0, 1)
                        local color3 = Color3.fromHSV(hue, sat, brightness)
                        Cursor.Position = UDim2.fromOffset(x - 4, y - 4)
                        ColorPicker.BackgroundColor3 = color3
                        callback(color3)
                    else
                        innerCon:Disconnect()
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isdraggingCanvas = false
                    end
                end)
            end
        end)

        ColorFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local draggingColorLocal = true
                local initial2 = ColorSlider.Position and ColorSlider.Position.X.Offset or 0
                local delta1 = ColorSlider.AbsolutePosition and ColorSlider.AbsolutePosition.X - initial2 or 0
                local innerCon
                innerCon = stepped:Connect(function()
                    if draggingColorLocal then
                        local colorPosition, colorSize = ColorFrame.AbsolutePosition, ColorFrame.AbsoluteSize
                        hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
                        CanvasGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromHSV(hue, 1, 1)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,255,255))}
                        local xOffset = math.clamp(mouse.X - delta1, 0, ColorFrame.Size.X.Offset - 3)
                        if ColorSlider then ColorSlider.Position = UDim2.new(0, xOffset, 0, 0) end
                        local color3 = Color3.fromHSV(hue, sat, brightness)
                        ColorPicker.BackgroundColor3  = color3
                        callback(color3)
                    else
                        innerCon:Disconnect()
                    end
                end)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then draggingColorLocal = false end
                end)
            end
        end)

        table.insert(colorPickers, ColorPickerFrame)

        local colorFuncs = {}
        function colorFuncs:UpdateColorPicker(color)
            if type(color) == "userdata" then
                ToggleFiller_2.Visible = false
                ColorPicker.BackgroundColor3 = color
            elseif color and type(color) == "boolean" and not con then
                ToggleFiller_2.Visible = true
                con = stepped:Connect(function()
                    if ToggleFiller_2.Visible then
                        local hue2 = tick() % 5 / 5
                        local color3 = Color3.fromHSV(hue2, 1, 1)
                        callback(color3)
                        ColorPicker.BackgroundColor3 = color3
                    else
                        con:Disconnect()
                    end
                end)
            end
        end
        return colorFuncs
    end

    return setmetatable(functions, functions)
end

return library
