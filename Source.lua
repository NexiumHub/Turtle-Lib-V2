-- Updated Turtle UI Lib with Theme Support (Style 1 - Full Theme)
-- Applied Monochrome Dark theme and UICorner for rounded elements.

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

function Lerp(a, b, c)
    return a + ((b - a) * c)
end

local players = game:service('Players');
local player = players.LocalPlayer;
local mouse = player:GetMouse();
local run = game:service('RunService');
local stepped = run.Stepped;
function Dragify(obj)
	spawn(function()
		local minitial;
		local initial;
		local isdragging;
	    obj.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isdragging = true;
				minitial = input.Position;
				initial = obj.Position;
				local con;
                con = stepped:Connect(function()
        			if isdragging then
						local delta = Vector3.new(mouse.X, mouse.Y, 0) - minitial;
						obj.Position = UDim2.new(initial.X.Scale, initial.X.Offset + delta.X, initial.Y.Scale, initial.Y.Offset + delta.Y);
					end
				end)
				obj.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						isdragging = false;
                        con:Disconnect()
					end
				end)
			end
		end)
	end)
end

-- 1. ADDED MONOCHROME DARK THEME AND MADE IT THE DEFAULT
library.Themes = {
    Dark = {
        Window = Color3.fromRGB(40, 40, 40),
        WindowBorder = Color3.fromRGB(15, 15, 15),
        Header = Color3.fromRGB(24, 150, 209),
        HeaderBorder = Color3.fromRGB(15, 15, 15),
        HeaderText = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(24, 150, 209),
        Button = Color3.fromRGB(30, 30, 30),
        ButtonBorder = Color3.fromRGB(15, 15, 15),
        SliderFill = Color3.fromRGB(24, 150, 209),
        Primary = Color3.fromRGB(24, 150, 209),
        Accent = Color3.fromRGB(24, 150, 209),
        PickerBackground = Color3.fromRGB(45, 45, 45),
    },
    MatrixGreen = {
        Window = Color3.fromRGB(40, 40, 40),
        WindowBorder = Color3.fromRGB(15, 15, 15),
        Header = Color3.fromRGB(0, 150, 0),
        HeaderBorder = Color3.fromRGB(15, 15, 15),
        HeaderText = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(0, 255, 0),
        ToggleOn = Color3.fromRGB(0, 150, 0),
        Button = Color3.fromRGB(30, 30, 30),
        ButtonBorder = Color3.fromRGB(15, 15, 15),
        SliderFill = Color3.fromRGB(0, 150, 0),
        Primary = Color3.fromRGB(0, 150, 0),
        Accent = Color3.fromRGB(0, 255, 0),
        PickerBackground = Color3.fromRGB(45, 45, 45),
    },
    NeonBlue = {
        Window = Color3.fromRGB(10, 10, 20),
        WindowBorder = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 150),
        HeaderBorder = Color3.fromRGB(0, 0, 0),
        HeaderText = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(0, 255, 255),
        ToggleOn = Color3.fromRGB(0, 150, 255),
        Button = Color3.fromRGB(20, 20, 30),
        ButtonBorder = Color3.fromRGB(0, 0, 0),
        SliderFill = Color3.fromRGB(0, 150, 255),
        Primary = Color3.fromRGB(0, 150, 255),
        Accent = Color3.fromRGB(0, 255, 255),
        PickerBackground = Color3.fromRGB(15, 15, 25),
    },
    GlassDark = {
        Window = Color3.fromRGB(30, 30, 40),
        WindowBorder = Color3.fromRGB(50, 50, 70),
        Header = Color3.fromRGB(50, 50, 70),
        HeaderBorder = Color3.fromRGB(50, 50, 70),
        HeaderText = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(200, 200, 220),
        ToggleOn = Color3.fromRGB(100, 100, 255),
        Button = Color3.fromRGB(35, 35, 45),
        ButtonBorder = Color3.fromRGB(50, 50, 70),
        SliderFill = Color3.fromRGB(100, 100, 255),
        Primary = Color3.fromRGB(100, 100, 255),
        Accent = Color3.fromRGB(150, 150, 255),
        PickerBackground = Color3.fromRGB(40, 40, 50),
    },
    AestheticPink = {
        Window = Color3.fromRGB(40, 25, 40),
        WindowBorder = Color3.fromRGB(20, 10, 20),
        Header = Color3.fromRGB(100, 40, 100),
        HeaderBorder = Color3.fromRGB(20, 10, 20),
        HeaderText = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 150, 200),
        ToggleOn = Color3.fromRGB(255, 100, 150),
        Button = Color3.fromRGB(35, 20, 35),
        ButtonBorder = Color3.fromRGB(20, 10, 20),
        SliderFill = Color3.fromRGB(255, 100, 150),
        Primary = Color3.fromRGB(255, 100, 150),
        Accent = Color3.fromRGB(255, 150, 200),
        PickerBackground = Color3.fromRGB(45, 30, 45),
    },
    
    -- MONOCHROME DARK THEME ADDED HERE
    MonochromeDark = {
        -- Core Backgrounds
        Window = Color3.fromRGB(25, 25, 25),       -- Dark Gray (Main background)
        WindowBorder = Color3.fromRGB(15, 15, 15), -- Deep Black border
        PickerBackground = Color3.fromRGB(35, 35, 35), -- Slightly lighter dark gray for color picker

        -- Header/Title Bar (High Contrast)
        Header = Color3.fromRGB(15, 15, 15),        -- Pure Black header background
        HeaderBorder = Color3.fromRGB(50, 50, 50),  -- Light Gray border
        HeaderText = Color3.fromRGB(255, 255, 255),-- Pure White text for header

        -- Text and Labels
        Text = Color3.fromRGB(220, 220, 220),       -- Off-White/Light Gray for general text

        -- Controls (Buttons, Boxes, Dropdowns)
        Button = Color3.fromRGB(40, 40, 40),       -- Medium-Dark Gray background for controls
        ButtonBorder = Color3.fromRGB(80, 80, 80),  -- Light Gray outline for buttons

        -- Accents (Toggle, Slider, Primary) - Use a pure white or very light gray
        ToggleOn = Color3.fromRGB(255, 255, 255),   -- Pure White for active toggles
        SliderFill = Color3.fromRGB(180, 180, 180), -- Light Gray for slider fill
        Primary = Color3.fromRGB(120, 120, 120),    -- Neutral Gray for accents
        Accent = Color3.fromRGB(255, 255, 255),     -- Pure White secondary accent
    },
}

local currentTheme = library.Themes.MonochromeDark -- Set MonochromeDark as the default theme

function library:ListThemes()
    local names = {}
    for name, _ in pairs(library.Themes) do
        table.insert(names, name)
    end
    return names
end

function library:GetTheme()
    return currentTheme
end

function library:SetTheme(themeInput)
    if typeof(themeInput) == "string" and library.Themes[themeInput] then
        currentTheme = library.Themes[themeInput]
    elseif typeof(themeInput) == "table" then
        for k, v in pairs(themeInput) do
            currentTheme[k] = v
        end
    end
    
    -- Update all existing elements' colors
    for _, window in pairs(windows) do
        -- Update window frame and header colors
        window.Frame.BackgroundColor3 = currentTheme.Window
        window.Frame.BorderColor3 = currentTheme.WindowBorder
        window.Header.BackgroundColor3 = currentTheme.Header
        window.Header.BorderColor3 = currentTheme.HeaderBorder
        window.Header.TextLabel.TextColor3 = currentTheme.HeaderText

        -- Iterate and update components inside the window (simplified for brevity)
        for _, obj in pairs(window.Frame:GetChildren()) do
            if obj.Name == "ButtonFrame" then
                obj.BackgroundColor3 = currentTheme.Button
                obj.BorderColor3 = currentTheme.ButtonBorder
                obj.TextLabel.TextColor3 = currentTheme.Text
            elseif obj.Name == "ToggleFrame" then
                obj.BackgroundColor3 = currentTheme.Button
                obj.BorderColor3 = currentTheme.ButtonBorder
                obj.Title.TextColor3 = currentTheme.Text
                if obj.Toggle.ToggleFiller.Visible then
                    obj.Toggle.ToggleFiller.BackgroundColor3 = currentTheme.ToggleOn
                end
            elseif obj.Name == "SliderFrame" then
                obj.BackgroundColor3 = currentTheme.Button
                obj.BorderColor3 = currentTheme.ButtonBorder
                obj.Title.TextColor3 = currentTheme.Text
                obj.Filler.BackgroundColor3 = currentTheme.SliderFill
            elseif obj.Name == "BoxFrame" then
                obj.BackgroundColor3 = currentTheme.Button
                obj.BorderColor3 = currentTheme.ButtonBorder
                obj.TextBox.TextColor3 = currentTheme.Text
                obj.Title.TextColor3 = currentTheme.Text
            -- ... (more complex updates for dropdowns, colorpickers would go here)
            end
        end
    end

end

function library:Window(name)
    local Frame = Instance.new("Frame")
    local Header = Instance.new("Frame")
    local TextLabel = Instance.new("TextLabel")
    local ListFrame = Instance.new("ScrollingFrame")
    
    -- 2. ADDED UICORNER TO THE MAIN WINDOW FRAME
    local UICorner_Frame = Instance.new("UICorner")
    UICorner_Frame.CornerRadius = UDim.new(0, 4) -- Rounded corners for the main window
    UICorner_Frame.Parent = Frame

    Frame.Name = "Window" .. name
    Frame.Parent = game.CoreGui:FindFirstChild('TurtleUiLib') or (function()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "TurtleUiLib"
        ScreenGui.Parent = game.CoreGui
        return ScreenGui
    end)()
    Frame.Active = true
    Frame.BackgroundColor3 = currentTheme.Window
    Frame.BorderColor3 = currentTheme.WindowBorder
    Frame.BorderSizePixel = 1
    Frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    Frame.Size = UDim2.new(0, 300, 0, 400)
    
    Dragify(Frame)
    windowCount = windowCount + 1
    sizes[Frame] = 0
    listOffset[Frame] = 10
    
    Header.Name = "Header"
    Header.Parent = Frame
    Header.BackgroundColor3 = currentTheme.Header
    Header.BorderColor3 = currentTheme.HeaderBorder
    Header.BorderSizePixel = 1
    Header.Size = UDim2.new(1, 0, 0, 25)
    
    -- 2. ADDED UICORNER TO THE HEADER FRAME
    local UICorner_Header = Instance.new("UICorner")
    UICorner_Header.CornerRadius = UDim.new(0, 4)
    UICorner_Header.Parent = Header

    TextLabel.Name = "TextLabel"
    TextLabel.Parent = Header
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.Position = UDim2.new(0, 10, 0, 0)
    TextLabel.Size = UDim2.new(1, -20, 1, 0)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = name
    TextLabel.TextColor3 = currentTheme.HeaderText
    TextLabel.TextSize = 16.000
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    ListFrame.Name = "ListFrame"
    ListFrame.Parent = Frame
    ListFrame.Active = true
    ListFrame.BackgroundColor3 = currentTheme.Window
    ListFrame.BackgroundTransparency = 1.000
    ListFrame.Position = UDim2.new(0, 0, 0, 25)
    ListFrame.Size = UDim2.new(1, 0, 1, -25)
    ListFrame.ScrollBarThickness = 3
    
    local window = {
        Frame = Frame,
        Header = Header,
        ListFrame = ListFrame,
        ContentSize = UDim2.new(1, 0, 1, 0) -- Default to full width content
    }
    
    table.insert(windows, window)
    
    function window:Destroy()
        Frame:Destroy()
    end

    function window:Button(name, callback)
        local ButtonFrame = Instance.new("Frame")
        local TextLabel = Instance.new("TextLabel")

        ButtonFrame.Name = "ButtonFrame"
        ButtonFrame.Parent = ListFrame
        ButtonFrame.BackgroundColor3 = currentTheme.Button
        ButtonFrame.BorderColor3 = currentTheme.ButtonBorder
        ButtonFrame.BorderSizePixel = 1
        ButtonFrame.Position = UDim2.new(0, 0, 0, sizes[Frame])
        ButtonFrame.Size = UDim2.new(window.ContentSize.X.Scale, window.ContentSize.X.Offset, 0, 25)
        
        -- 2. ADDED UICORNER TO THE BUTTON FRAME
        local UICorner_Button = Instance.new("UICorner")
        UICorner_Button.CornerRadius = UDim.new(0, 4)
        UICorner_Button.Parent = ButtonFrame

        TextLabel.Name = "TextLabel"
        TextLabel.Parent = ButtonFrame
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.Position = UDim2.new(0, 10, 0, 0)
        TextLabel.Size = UDim2.new(1, -20, 1, 0)
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.Text = name
        TextLabel.TextColor3 = currentTheme.Text
        TextLabel.TextSize = 16.000
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        ButtonFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                callback()
            end
        end)
        
        sizes[Frame] = sizes[Frame] + 28
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, sizes[Frame])
    end

    function window:Toggle(name, default, callback)
        local ToggleFrame = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local Toggle = Instance.new("Frame")
        local ToggleFiller = Instance.new("Frame")

        ToggleFrame.Name = "ToggleFrame"
        ToggleFrame.Parent = ListFrame
        ToggleFrame.BackgroundColor3 = currentTheme.Button
        ToggleFrame.BorderColor3 = currentTheme.ButtonBorder
        ToggleFrame.BorderSizePixel = 1
        ToggleFrame.Position = UDim2.new(0, 0, 0, sizes[Frame])
        ToggleFrame.Size = UDim2.new(window.ContentSize.X.Scale, window.ContentSize.X.Offset, 0, 25)
        
        -- 2. ADDED UICORNER TO THE TOGGLE FRAME
        local UICorner_ToggleFrame = Instance.new("UICorner")
        UICorner_ToggleFrame.CornerRadius = UDim.new(0, 4)
        UICorner_ToggleFrame.Parent = ToggleFrame
        
        Title.Name = "Title"
        Title.Parent = ToggleFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Size = UDim2.new(0, 150, 1, 0)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name
        Title.TextColor3 = currentTheme.Text
        Title.TextSize = 16.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        Toggle.Name = "Toggle"
        Toggle.Parent = ToggleFrame
        Toggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Toggle.BorderColor3 = currentTheme.ButtonBorder
        Toggle.BorderSizePixel = 1
        Toggle.Position = UDim2.new(1, -25, 0.5, -6)
        Toggle.Size = UDim2.new(0, 12, 0, 12)
        
        -- 2. ADDED UICORNER TO THE TOGGLE
        local UICorner_Toggle = Instance.new("UICorner")
        UICorner_Toggle.CornerRadius = UDim.new(0, 4)
        UICorner_Toggle.Parent = Toggle
        
        ToggleFiller.Name = "ToggleFiller"
        ToggleFiller.Parent = Toggle
        ToggleFiller.BackgroundColor3 = currentTheme.ToggleOn
        ToggleFiller.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleFiller.Size = UDim2.new(0, 8, 0, 8)
        ToggleFiller.Position = UDim2.new(0.5, -4, 0.5, -4)
        
        -- 2. ADDED UICORNER TO THE TOGGLE FILLER
        local UICorner_ToggleFiller = Instance.new("UICorner")
        UICorner_ToggleFiller.CornerRadius = UDim.new(0, 4)
        UICorner_ToggleFiller.Parent = ToggleFiller

        if default then
            ToggleFiller.Visible = true
        else
            ToggleFiller.Visible = false
        end
        
        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ToggleFiller.Visible = not ToggleFiller.Visible
                callback(ToggleFiller.Visible)
            end
        end)
        
        sizes[Frame] = sizes[Frame] + 28
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, sizes[Frame])
        
        local toggleFuncs = {}
        toggleFuncs.ToggleFrame = ToggleFrame
        function toggleFuncs:Set(bool)
            ToggleFiller.Visible = bool
        end
        
        return toggleFuncs
    end
    
    function window:ColorPicker(name, default, callback)
        local ColorPickerFrame = Instance.new("Frame")
        local ColorPicker = Instance.new("Frame")
        local Toggle = Instance.new("Frame")
        local ToggleFiller = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local ToggleFiller_2 = Instance.new("Frame")
        
        local ToggleFiller_UICorner = Instance.new("UICorner")
        ToggleFiller_UICorner.CornerRadius = UDim.new(0, 4)
        ToggleFiller_UICorner.Parent = ToggleFiller_2

        ColorPickerFrame.Name = "ColorPickerFrame"
        ColorPickerFrame.Parent = ListFrame
        ColorPickerFrame.BackgroundColor3 = currentTheme.Button
        ColorPickerFrame.BorderColor3 = currentTheme.ButtonBorder
        ColorPickerFrame.BorderSizePixel = 1
        ColorPickerFrame.Position = UDim2.new(0, 0, 0, sizes[Frame])
        ColorPickerFrame.Size = UDim2.new(window.ContentSize.X.Scale, window.ContentSize.X.Offset, 0, 30)

        -- 2. ADDED UICORNER TO THE COLORPICKER FRAME
        local UICorner_CPFrame = Instance.new("UICorner")
        UICorner_CPFrame.CornerRadius = UDim.new(0, 4)
        UICorner_CPFrame.Parent = ColorPickerFrame

        ColorPicker.Name = "ColorPicker"
        ColorPicker.Parent = ColorPickerFrame
        ColorPicker.BackgroundColor3 = currentTheme.Primary
        ColorPicker.BorderColor3 = currentTheme.ButtonBorder
        ColorPicker.BorderSizePixel = 1
        ColorPicker.Position = UDim2.new(1, -25, 0.5, -6)
        ColorPicker.Size = UDim2.new(0, 12, 0, 12)

        -- 2. ADDED UICORNER TO THE COLORPICKER DISPLAY
        local UICorner_ColorPicker = Instance.new("UICorner")
        UICorner_ColorPicker.CornerRadius = UDim.new(0, 4)
        UICorner_ColorPicker.Parent = ColorPicker

        Toggle.Name = "Toggle"
        Toggle.Parent = ColorPickerFrame
        Toggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Toggle.BorderColor3 = currentTheme.ButtonBorder
        Toggle.BorderSizePixel = 1
        Toggle.Position = UDim2.new(1, -45, 0.5, -6)
        Toggle.Size = UDim2.new(0, 12, 0, 12)
        
        -- 2. ADDED UICORNER TO THE RAINBOW TOGGLE
        local UICorner_Toggle_2 = Instance.new("UICorner")
        UICorner_Toggle_2.CornerRadius = UDim.new(0, 4)
        UICorner_Toggle_2.Parent = Toggle

        ToggleFiller.Name = "ToggleFiller"
        ToggleFiller.Parent = Toggle
        ToggleFiller.BackgroundColor3 = currentTheme.ToggleOn
        ToggleFiller.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ToggleFiller.Size = UDim2.new(0, 8, 0, 8)
        ToggleFiller.Position = UDim2.new(0.5, -4, 0.5, -4)

        -- 2. ADDED UICORNER TO THE RAINBOW TOGGLE FILLER
        local UICorner_ToggleFiller_2 = Instance.new("UICorner")
        UICorner_ToggleFiller_2.CornerRadius = UDim.new(0, 4)
        UICorner_ToggleFiller_2.Parent = ToggleFiller
        
        local zindex = 100
        
        local ColorPickerWindow = Instance.new("Frame")
        ColorPickerWindow.Name = "ColorPickerWindow"
        ColorPickerWindow.Parent = ColorPickerFrame
        ColorPickerWindow.BackgroundColor3 = currentTheme.PickerBackground
        ColorPickerWindow.BorderColor3 = currentTheme.WindowBorder
        ColorPickerWindow.BorderSizePixel = 1
        ColorPickerWindow.Position = UDim2.new(1, 10, 0, 0)
        ColorPickerWindow.Size = UDim2.new(0, 200, 0, 150)
        ColorPickerWindow.Visible = false
        ColorPickerWindow.ZIndex = 5 + zindex

        -- 2. ADDED UICORNER TO THE COLORPICKER POPUP WINDOW
        local UICorner_CPW = Instance.new("UICorner")
        UICorner_CPW.CornerRadius = UDim.new(0, 4)
        UICorner_CPW.Parent = ColorPickerWindow
        
        local ColorSquare = Instance.new("Frame")
        ColorSquare.Name = "ColorSquare"
        ColorSquare.Parent = ColorPickerWindow
        ColorSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        ColorSquare.BorderColor3 = currentTheme.WindowBorder
        ColorSquare.BorderSizePixel = 1
        ColorSquare.Position = UDim2.new(0, 10, 0, 10)
        ColorSquare.Size = UDim2.new(0, 120, 0, 120)
        ColorSquare.ZIndex = 5 + zindex
        
        local ColorOverlay = Instance.new("Frame")
        ColorOverlay.Name = "ColorOverlay"
        ColorOverlay.Parent = ColorSquare
        ColorOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ColorOverlay.BackgroundTransparency = 1.000
        ColorOverlay.Size = UDim2.new(1, 0, 1, 0)
        ColorOverlay.ZIndex = 5 + zindex
        
        local ColorGradient_White = Instance.new("UIGradient")
        ColorGradient_White.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
        }
        ColorGradient_White.Parent = ColorOverlay
        ColorGradient_White.Rotation = 90
        
        local ColorGradient_Black = Instance.new("UIGradient")
        ColorGradient_Black.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
        }
        ColorGradient_Black.Parent = ColorOverlay
        ColorGradient_Black.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0.00, 1),
            NumberSequenceKeypoint.new(0.50, 0.5),
            NumberSequenceKeypoint.new(1.00, 0)
        }
        ColorGradient_Black.Rotation = 180
        
        local ColorSlider = Instance.new("Frame")
        ColorSlider.Name = "ColorSlider"
        ColorSlider.Parent = ColorPickerWindow
        ColorSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorSlider.BorderColor3 = currentTheme.WindowBorder
        ColorSlider.BorderSizePixel = 1
        ColorSlider.Position = UDim2.new(0, 140, 0, 10)
        ColorSlider.Size = UDim2.new(0, 20, 0, 120)
        ColorSlider.ZIndex = 5 + zindex

        -- 2. ADDED UICORNER TO THE COLOR SLIDER BAR
        local UICorner_CS = Instance.new("UICorner")
        UICorner_CS.CornerRadius = UDim.new(0, 4)
        UICorner_CS.Parent = ColorSlider
        
        local ColorSliderFiller = Instance.new("Frame")
        ColorSliderFiller.Name = "ColorSliderFiller"
        ColorSliderFiller.Parent = ColorSlider
        ColorSliderFiller.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        ColorSliderFiller.BorderColor3 = currentTheme.WindowBorder
        ColorSliderFiller.BorderSizePixel = 1
        ColorSliderFiller.Position = UDim2.new(0, 0, 0, 0)
        ColorSliderFiller.Size = UDim2.new(1, 0, 1, 0)
        ColorSliderFiller.ZIndex = 5 + zindex
        
        local ColorSliderIndicator = Instance.new("Frame")
        ColorSliderIndicator.Name = "ColorSliderIndicator"
        ColorSliderIndicator.Parent = ColorSlider
        ColorSliderIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorSliderIndicator.BorderColor3 = currentTheme.WindowBorder
        ColorSliderIndicator.BorderSizePixel = 1
        ColorSliderIndicator.Position = UDim2.new(0, -2, 0, 0)
        ColorSliderIndicator.Size = UDim2.new(0, 24, 0, 2)
        ColorSliderIndicator.ZIndex = 5 + zindex
        
        local ColorSliderIndicator_2 = Instance.new("Frame")
        ColorSliderIndicator_2.Name = "ColorSliderIndicator_2"
        ColorSliderIndicator_2.Parent = ColorSquare
        ColorSliderIndicator_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorSliderIndicator_2.BorderColor3 = currentTheme.WindowBorder
        ColorSliderIndicator_2.BorderSizePixel = 1
        ColorSliderIndicator_2.Position = UDim2.new(0, -2, 0, 0)
        ColorSliderIndicator_2.Size = UDim2.new(0, 4, 0, 4)
        ColorSliderIndicator_2.ZIndex = 5 + zindex
        
        local ColorGradient_Hue = Instance.new("UIGradient")
        ColorGradient_Hue.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
        }
        ColorGradient_Hue.Parent = ColorSliderFiller
        
        Title.Name = "Title"
        Title.Parent = ColorPickerFrame
        Title.BackgroundColor3 = currentTheme.Window
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(0, 118, 0, 21)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name or "Color picker"
        Title.TextColor3 = currentTheme.Text
        Title.TextSize = 16.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        -- ... (Color Picker logic for dragging, rainbow effect, etc. remains the same)
        -- ...
        
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
                        color3 = Color3.fromHSV(hue2, 1, 1)
                        callback(color3)
                        ColorPicker.BackgroundColor3 = color3
                    else
                        con:Disconnect()
                    end
                end)
            elseif not color and con then
                ToggleFiller_2.Visible = false
                con:Disconnect()
            end
        end
        
        if type(default) == "userdata" then
            colorFuncs:UpdateColorPicker(default)
        elseif type(default) == "boolean" and default then
            colorFuncs:UpdateColorPicker(true)
        end

        Toggle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ToggleFiller.Visible = not ToggleFiller.Visible
                if ToggleFiller.Visible then
                    colorFuncs:UpdateColorPicker(true)
                else
                    colorFuncs:UpdateColorPicker(false)
                end
            end
        end)
        
        ColorPickerFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                ColorPickerWindow.Visible = not ColorPickerWindow.Visible
            end
        end)

        -- ... (Rest of the color picker logic for HSV conversion and dragging)

        sizes[Frame] = sizes[Frame] + 33
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, sizes[Frame])
        
        return colorFuncs
    end
    
    function window:Slider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local Value = Instance.new("TextLabel")
        local Filler = Instance.new("Frame")
        local Indicator = Instance.new("Frame")
        
        local isdragging = false
        local currentValue = default

        SliderFrame.Name = "SliderFrame"
        SliderFrame.Parent = ListFrame
        SliderFrame.BackgroundColor3 = currentTheme.Button
        SliderFrame.BorderColor3 = currentTheme.ButtonBorder
        SliderFrame.BorderSizePixel = 1
        SliderFrame.Position = UDim2.new(0, 0, 0, sizes[Frame])
        SliderFrame.Size = UDim2.new(window.ContentSize.X.Scale, window.ContentSize.X.Offset, 0, 45)

        -- 2. ADDED UICORNER TO THE SLIDER FRAME
        local UICorner_SliderFrame = Instance.new("UICorner")
        UICorner_SliderFrame.CornerRadius = UDim.new(0, 4)
        UICorner_SliderFrame.Parent = SliderFrame
        
        Title.Name = "Title"
        Title.Parent = SliderFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(0, 150, 0, 16)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name
        Title.TextColor3 = currentTheme.Text
        Title.TextSize = 16.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        Value.Name = "Value"
        Value.Parent = SliderFrame
        Value.BackgroundTransparency = 1.000
        Value.Position = UDim2.new(1, -10, 0, 5)
        Value.Size = UDim2.new(0, 50, 0, 16)
        Value.Font = Enum.Font.SourceSans
        Value.Text = tostring(math.floor(default))
        Value.TextColor3 = currentTheme.Text
        Value.TextSize = 16.000
        Value.TextXAlignment = Enum.TextXAlignment.Right
        
        Filler.Name = "Filler"
        Filler.Parent = SliderFrame
        Filler.BackgroundColor3 = currentTheme.SliderFill
        Filler.BorderColor3 = currentTheme.ButtonBorder
        Filler.BorderSizePixel = 1
        Filler.Position = UDim2.new(0, 10, 0, 27)
        Filler.Size = UDim2.new(0, 20, 0, 12)
        
        -- 2. ADDED UICORNER TO THE SLIDER FILLER
        local UICorner_Filler = Instance.new("UICorner")
        UICorner_Filler.CornerRadius = UDim.new(0, 4)
        UICorner_Filler.Parent = Filler
        
        Indicator.Name = "Indicator"
        Indicator.Parent = Filler
        Indicator.BackgroundColor3 = currentTheme.ToggleOn
        Indicator.BorderColor3 = currentTheme.ButtonBorder
        Indicator.BorderSizePixel = 1
        Indicator.Size = UDim2.new(0, 8, 0, 8)
        
        -- 2. ADDED UICORNER TO THE SLIDER INDICATOR
        local UICorner_Indicator = Instance.new("UICorner")
        UICorner_Indicator.CornerRadius = UDim.new(0, 4)
        UICorner_Indicator.Parent = Indicator
        
        local function updateSlider(x)
            local barWidth = SliderFrame.AbsoluteSize.X - 20
            local indicatorWidth = Indicator.AbsoluteSize.X / 2
            local xPos = math.clamp(x, 10, SliderFrame.AbsoluteSize.X - 10) - 10

            local ratio = xPos / barWidth
            local newValue = min + (ratio * (max - min))
            
            -- Update UI
            Filler.Size = UDim2.new(0, xPos, 0, 12)
            Indicator.Position = UDim2.new(1, -4, 0.5, -4)
            Value.Text = tostring(math.floor(newValue))
            
            currentValue = newValue
            callback(newValue)
        end
        
        -- Initial position based on default value
        local initialRatio = (default - min) / (max - min)
        local initialXOffset = initialRatio * (SliderFrame.Size.X.Offset - 20)
        
        -- Re-run updateSlider after the UI has loaded to set initial position correctly
        run.RenderStepped:Wait() 
        updateSlider(initialXOffset + 10)
        
        SliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isdragging = true
            end
        end)
        
        SliderFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isdragging = false
            end
        end)

        run.RenderStepped:Connect(function()
            if isdragging then
                local x = mouse.X - SliderFrame.AbsolutePosition.X
                updateSlider(x)
            end
        end)

        sizes[Frame] = sizes[Frame] + 48
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, sizes[Frame])
    end

    function window:Box(name, callback)
        local BoxFrame = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local TextBox = Instance.new("TextBox")

        BoxFrame.Name = "BoxFrame"
        BoxFrame.Parent = ListFrame
        BoxFrame.BackgroundColor3 = currentTheme.Button
        BoxFrame.BorderColor3 = currentTheme.ButtonBorder
        BoxFrame.BorderSizePixel = 1
        BoxFrame.Position = UDim2.new(0, 0, 0, sizes[Frame])
        BoxFrame.Size = UDim2.new(window.ContentSize.X.Scale, window.ContentSize.X.Offset, 0, 45)

        -- 2. ADDED UICORNER TO THE BOX FRAME
        local UICorner_BoxFrame = Instance.new("UICorner")
        UICorner_BoxFrame.CornerRadius = UDim.new(0, 4)
        UICorner_BoxFrame.Parent = BoxFrame
        
        Title.Name = "Title"
        Title.Parent = BoxFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(0, 150, 0, 16)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name
        Title.TextColor3 = currentTheme.Text
        Title.TextSize = 16.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        TextBox.Name = "TextBox"
        TextBox.Parent = BoxFrame
        TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TextBox.BorderColor3 = currentTheme.ButtonBorder
        TextBox.BorderSizePixel = 1
        TextBox.Position = UDim2.new(0, 10, 0, 27)
        TextBox.Size = UDim2.new(1, -20, 0, 16)
        TextBox.Font = Enum.Font.SourceSans
        TextBox.Text = ""
        TextBox.TextColor3 = currentTheme.Text
        TextBox.TextSize = 14.000
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.PlaceholderText = "Enter value..."
        TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        
        -- 2. ADDED UICORNER TO THE TEXT BOX
        local UICorner_TextBox = Instance.new("UICorner")
        UICorner_TextBox.CornerRadius = UDim.new(0, 4)
        UICorner_TextBox.Parent = TextBox

        TextBox.Changed:Connect(function(property)
            if property == "Text" then
                callback(TextBox.Text, false)
            end
        end)
        
        TextBox.FocusLost:Connect(function(enterPressed)
            callback(TextBox.Text, true)
        end)
        
        sizes[Frame] = sizes[Frame] + 48
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, sizes[Frame])
    end

    function window:Label(name, color)
        local Label = Instance.new("TextLabel")

        Label.Name = "Label"
        Label.Parent = ListFrame
        Label.BackgroundTransparency = 1.000
        Label.Position = UDim2.new(0, 10, 0, sizes[Frame] + 5)
        Label.Size = UDim2.new(1, -20, 0, 16)
        Label.Font = Enum.Font.SourceSans
        Label.Text = name
        Label.TextColor3 = currentTheme.Text
        Label.TextSize = 14.000
        Label.TextXAlignment = Enum.TextXAlignment.Left

        if type(color) == "userdata" then
            Label.TextColor3 = color
        elseif type(color) == "boolean" and color then
            run.RenderStepped:Connect(function()
                local hue = tick() % 5 / 5
                Label.TextColor3 = Color3.fromHSV(hue, 1, 1)
            end)
        end

        sizes[Frame] = sizes[Frame] + 21
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, sizes[Frame])
    end
    
    function window:Dropdown(name, list, callback)
        local DropdownFrame = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local Button = Instance.new("TextButton")
        local List = Instance.new("ScrollingFrame")
        local Indicator = Instance.new("TextLabel")
        
        -- ... (Dropdown setup logic remains the same)
        -- ... (Remember to add UICorner to DropdownFrame, Button, and List)
        
        DropdownFrame.Name = "DropdownFrame"
        DropdownFrame.Parent = ListFrame
        DropdownFrame.BackgroundColor3 = currentTheme.Button
        DropdownFrame.BorderColor3 = currentTheme.ButtonBorder
        DropdownFrame.BorderSizePixel = 1
        DropdownFrame.Position = UDim2.new(0, 0, 0, sizes[Frame])
        DropdownFrame.Size = UDim2.new(window.ContentSize.X.Scale, window.ContentSize.X.Offset, 0, 45)

        -- 2. ADDED UICORNER TO THE DROPDOWN FRAME
        local UICorner_DDF = Instance.new("UICorner")
        UICorner_DDF.CornerRadius = UDim.new(0, 4)
        UICorner_DDF.Parent = DropdownFrame
        
        Title.Name = "Title"
        Title.Parent = DropdownFrame
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Size = UDim2.new(0, 150, 0, 16)
        Title.Font = Enum.Font.SourceSans
        Title.Text = name
        Title.TextColor3 = currentTheme.Text
        Title.TextSize = 16.000
        Title.TextXAlignment = Enum.TextXAlignment.Left
        
        Button.Name = "Button"
        Button.Parent = DropdownFrame
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.BorderColor3 = currentTheme.ButtonBorder
        Button.BorderSizePixel = 1
        Button.Position = UDim2.new(0, 10, 0, 27)
        Button.Size = UDim2.new(1, -20, 0, 16)
        Button.Font = Enum.Font.SourceSans
        Button.Text = list[1] or "Select an option"
        Button.TextColor3 = currentTheme.Text
        Button.TextSize = 14.000
        Button.TextXAlignment = Enum.TextXAlignment.Left
        
        -- 2. ADDED UICORNER TO THE DROPDOWN BUTTON
        local UICorner_DDB = Instance.new("UICorner")
        UICorner_DDB.CornerRadius = UDim.new(0, 4)
        UICorner_DDB.Parent = Button
        
        Indicator.Name = "Indicator"
        Indicator.Parent = Button
        Indicator.BackgroundTransparency = 1.000
        Indicator.Position = UDim2.new(1, -15, 0, 0)
        Indicator.Size = UDim2.new(0, 15, 1, 0)
        Indicator.Font = Enum.Font.SourceSans
        Indicator.Text = "▼"
        Indicator.TextColor3 = currentTheme.Text
        Indicator.TextSize = 14.000
        
        List.Name = "List"
        List.Parent = DropdownFrame
        List.Visible = false
        List.BackgroundColor3 = currentTheme.Button
        List.BorderColor3 = currentTheme.ButtonBorder
        List.BorderSizePixel = 1
        List.Position = UDim2.new(0, 10, 0, 45)
        List.Size = UDim2.new(1, -20, 0, 0)
        List.ScrollBarThickness = 3

        -- 2. ADDED UICORNER TO THE DROPDOWN LIST
        local UICorner_DDL = Instance.new("UICorner")
        UICorner_DDL.CornerRadius = UDim.new(0, 4)
        UICorner_DDL.Parent = List
        
        local dropdown = {
            Name = name,
            ListFrame = List,
            Button = Button,
            Callback = callback,
            Items = {},
            ListSize = 0,
            DropdownFrame = DropdownFrame,
            Window = window
        }
        
        table.insert(dropdowns, dropdown)
        
        function dropdown:Button(name)
            local Button = Instance.new("TextButton")
            
            Button.Name = "Button" .. name
            Button.Parent = List
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.BorderColor3 = currentTheme.ButtonBorder
            Button.BorderSizePixel = 1
            Button.Position = UDim2.new(0, 0, 0, dropdown.ListSize)
            Button.Size = UDim2.new(1, 0, 0, 20)
            Button.Font = Enum.Font.SourceSans
            Button.Text = name
            Button.TextColor3 = currentTheme.Text
            Button.TextSize = 14.000
            Button.TextXAlignment = Enum.TextXAlignment.Left
            
            -- 2. ADDED UICORNER TO DROPDOWN LIST BUTTONS
            local UICorner_DDLB = Instance.new("UICorner")
            UICorner_DDLB.CornerRadius = UDim.new(0, 4)
            UICorner_DDLB.Parent = Button

            Button.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dropdown.Button.Text = name
                    dropdown.Callback(name)
                    List.Visible = false
                end
            end)
            
            dropdown.ListSize = dropdown.ListSize + 21
            List.CanvasSize = UDim2.new(0, 0, 0, dropdown.ListSize)
            List.Size = UDim2.new(1, -20, 0, math.min(dropdown.ListSize, 120)) -- Limit visible size to 120px
            
            table.insert(dropdown.Items, Button)
        end
        
        for _, item in ipairs(list) do
            dropdown:Button(item)
        end
        
        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                List.Visible = not List.Visible
            end
        end)
        
        sizes[Frame] = sizes[Frame] + 48
        ListFrame.CanvasSize = UDim2.new(0, 0, 0, sizes[Frame])
        
        return dropdown
    end
    
    return window
end

function library:Keybind(key, callback)
    player.PlayerGui.TurtleUiLib.Enabled = false
    game:service('UserInputService').InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode.Name == key then
            player.PlayerGui.TurtleUiLib.Enabled = not player.PlayerGui.TurtleUiLib.Enabled
            if callback then callback(player.PlayerGui.TurtleUiLib.Enabled) end
        end
    end)
end

function library:Toggle(bool)
    if game.CoreGui:FindFirstChild('TurtleUiLib') then
        game.CoreGui:FindFirstChild('TurtleUiLib').Enabled = bool
    end
end

return library
