-- Updated Turtle UI Lib with Theme Support (Style 1 - Full Theme)
-- Adds built-in themes: Dark, MatrixGreen, NeonBlue, GlassDark, AestheticPink
-- Backwards compatible with original API.

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
						obj.Position = UDim2.new(initial.X.Scale, initial.X.Offset + delta.X, initial.Y.Scale, initial.Y.Offset + delta.Y)
					end
				end)
				input.InputEnded:Connect(function(input2)
					if input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
						isdragging = false;
						con:Disconnect()
					end
				end)
			end
		end)
	end)
end

-- ====================================================================
-- THEME CONFIGURATION
-- ====================================================================

-- Default Theme: MonochromeDark
-- Now the default style is a dark monochrome scheme with rounded corners.
local MonochromeDark = {
    -- Core Backgrounds
    Window = Color3.fromRGB(30, 30, 30),        -- Main window body
    WindowBorder = Color3.fromRGB(15, 15, 15),  -- Dark border color
    PickerBackground = Color3.fromRGB(25, 25, 25), -- Color picker pop-up background

    -- Header/Title Bar
    Header = Color3.fromRGB(20, 20, 20),        -- Header background
    HeaderBorder = Color3.fromRGB(15, 15, 15),  -- Header border
    HeaderText = Color3.fromRGB(200, 200, 200), -- Header text color

    -- Text and Labels
    Text = Color3.fromRGB(180, 180, 180),       -- General text color

    -- Controls (Buttons, Boxes, Dropdowns)
    Button = Color3.fromRGB(45, 45, 45),        -- Button/Box background
    ButtonBorder = Color3.fromRGB(25, 25, 25),  -- Button/Box border/outline

    -- Accents (Toggle, Slider) - Subtle White/Gray
    ToggleOn = Color3.fromRGB(100, 100, 100),   -- Gray for active toggles
    SliderFill = Color3.fromRGB(100, 100, 100), -- Gray for slider fill
    Primary = Color3.fromRGB(80, 80, 80),       -- Main accent color (hover/active states)
    Accent = Color3.fromRGB(150, 150, 150),     -- Secondary accent color (hover/inactive accents)
}

local currentTheme = MonochromeDark

function library:SetTheme(themeTable)
    currentTheme = themeTable
    -- Re-apply theme properties to existing windows if necessary (complex, usually requires recreation)
    -- For simplicity, we assume this is called before window creation.
end

-- ====================================================================
-- WINDOW & UI COMPONENT CREATION
-- ====================================================================

function library:Window(name)
	windowCount += 1
	local zindex = 10

	local WindowFrame = Instance.new("Frame")
	local ListFrame = Instance.new("ScrollingFrame")
	local UICorner_1 = Instance.new("UICorner")
	local UIListLayout_1 = Instance.new("UIListLayout")
	local Header = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local UICorner_2 = Instance.new("UICorner")
	
	WindowFrame.Name = "WindowFrame"
	WindowFrame.Parent = game:GetService("CoreGui")
	WindowFrame.Active = true
	WindowFrame.BackgroundColor3 = currentTheme.Window
	WindowFrame.BorderColor3 = currentTheme.WindowBorder
	WindowFrame.BorderSizePixel = 1
	WindowFrame.Position = UDim2.new(0.5, -125, 0.5, -200)
	WindowFrame.Size = UDim2.new(0, 250, 0, 400)
    WindowFrame.ZIndex = 2
	
	UICorner_1.CornerRadius = UDim.new(0, 8) -- Standard rounded corners
	UICorner_1.Parent = WindowFrame
	
	ListFrame.Name = "ListFrame"
	ListFrame.Parent = WindowFrame
	ListFrame.Active = true
	ListFrame.BackgroundColor3 = currentTheme.Window
	ListFrame.BackgroundTransparency = 1.000
	ListFrame.BorderSizePixel = 0
	ListFrame.Position = UDim2.new(0, 0, 0.1, 0)
	ListFrame.Size = UDim2.new(1, 0, 0.9, 0)
	ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ListFrame.ScrollBarThickness = 6
    ListFrame.ZIndex = 1
	
	UIListLayout_1.Parent = ListFrame
	UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
	UIListLayout_1.Padding = UDim.new(0, 5)
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Top
	
	Header.Name = "Header"
	Header.Parent = WindowFrame
	Header.Active = true
	Header.BackgroundColor3 = currentTheme.Header
	Header.BorderColor3 = currentTheme.HeaderBorder
	Header.BorderSizePixel = 1
	Header.Size = UDim2.new(1, 0, 0.1, 0)
	Header.ZIndex = 5 -- ZIndex set high to ensure it is always on top
	Dragify(Header)

	UICorner_2.CornerRadius = UDim.new(0, 8)
	UICorner_2.Parent = Header
	
	Title.Name = "Title"
	Title.Parent = Header
	Title.BackgroundColor3 = currentTheme.Header
	Title.BackgroundTransparency = 1.000
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.Font = Enum.Font.SourceSansBold
	Title.Text = name or "Turtle Lib UI"
	Title.TextColor3 = currentTheme.HeaderText
	Title.TextSize = 16.000
    Title.ZIndex = 6
	
	local funcs = {}
	
	local function updateListCanvasSize()
		local size = UIListLayout_1.AbsoluteContentSize
		ListFrame.CanvasSize = UDim2.new(0, 0, 0, size.Y + 10)
	end
	
	local function createCorner(instance, radius)
	    local corner = Instance.new("UICorner")
	    corner.CornerRadius = UDim.new(0, radius or 5)
	    corner.Parent = instance
	    return corner
	end
	
	function funcs:Destroy()
		WindowFrame:Destroy()
	end

    function funcs:SetTitle(newTitle)
        Title.Text = newTitle
    end
    
    function funcs:SetSize(size)
        WindowFrame.Size = size
    end

    function funcs:SetPosition(pos)
        WindowFrame.Position = pos
    end

    -- Allows customization of the content area size (used for full-width layout)
    function funcs:SetContentSize(udim2)
        ListFrame.Position = UDim2.new(udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset)
        ListFrame.Size = UDim2.new(1 - udim2.X.Scale, -udim2.X.Offset, 1 - udim2.Y.Scale, -udim2.Y.Offset)
        -- Adjust Header size if ListFrame starts below the header (standard 0, 0.1, 1, 0)
        Header.Size = UDim2.new(1, 0, udim2.Y.Scale, udim2.Y.Offset)
    end
    
    function funcs:GetWindow()
        return WindowFrame
    end

	function funcs:Label(text, color)
		local LabelFrame = Instance.new("Frame")
		local Title = Instance.new("TextLabel")

		LabelFrame.Name = "LabelFrame"
		LabelFrame.Parent = ListFrame
		LabelFrame.BackgroundColor3 = currentTheme.Window
		LabelFrame.BackgroundTransparency = 1.000
		LabelFrame.Size = UDim2.new(1, -10, 0, 30)
		LabelFrame.ZIndex = 2
		
		Title.Name = "Title"
		Title.Parent = LabelFrame
		Title.BackgroundColor3 = currentTheme.Window
		Title.BackgroundTransparency = 1.000
		Title.Size = UDim2.new(1, 0, 1, 0)
		Title.Font = Enum.Font.SourceSans
		Title.Text = text or "Label"
		Title.TextColor3 = currentTheme.Text
		Title.TextSize = 16.000
		Title.ZIndex = 3
		
		if color then
			if typeof(color) == "boolean" and color then
				Title.Font = Enum.Font.SourceSans
				local con = stepped:Connect(function()
					local hue = tick() % 5 / 5
					Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
				end)
				LabelFrame.Destroying:Connect(function() con:Disconnect() end)
			else
				Title.TextColor3 = color
			end
		end

		updateListCanvasSize()
		return LabelFrame
	end
	
	function funcs:Button(text, callback)
		local ButtonFrame = Instance.new("Frame")
		local Button = Instance.new("TextButton")
        local UICorner_3 = createCorner(ButtonFrame, 5)
        local UICorner_4 = createCorner(Button, 5)

		ButtonFrame.Name = "ButtonFrame"
		ButtonFrame.Parent = ListFrame
		ButtonFrame.BackgroundColor3 = currentTheme.Window
		ButtonFrame.BackgroundTransparency = 1.000
		ButtonFrame.Size = UDim2.new(1, -10, 0, 30)
		ButtonFrame.ZIndex = 2
		
		Button.Name = "Button"
		Button.Parent = ButtonFrame
		Button.BackgroundColor3 = currentTheme.Button
		Button.BorderColor3 = currentTheme.ButtonBorder
		Button.BorderSizePixel = 1
		Button.Size = UDim2.new(1, 0, 1, 0)
		Button.Font = Enum.Font.SourceSans
		Button.Text = text or "Button"
		Button.TextColor3 = currentTheme.Text
		Button.TextSize = 16.000
		Button.ZIndex = 3
		
		Button.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)

		updateListCanvasSize()
		return ButtonFrame
	end

	function funcs:Toggle(name, default, callback)
		local ToggleFrame = Instance.new("Frame")
		local Title = Instance.new("TextLabel")
		local ToggleButton = Instance.new("Frame")
		local UICorner_3 = createCorner(ToggleButton, 5)
		local ToggleBackground = Instance.new("Frame")
		local UICorner_4 = createCorner(ToggleBackground, 5)
		local ToggleFiller = Instance.new("Frame")
		local UICorner_5 = createCorner(ToggleFiller, 5)

		ToggleFrame.Name = "ToggleFrame"
		ToggleFrame.Parent = ListFrame
		ToggleFrame.BackgroundColor3 = currentTheme.Window
		ToggleFrame.BackgroundTransparency = 1.000
		ToggleFrame.Size = UDim2.new(1, -10, 0, 30)
		ToggleFrame.ZIndex = 2
		
		Title.Name = "Title"
		Title.Parent = ToggleFrame
		Title.BackgroundColor3 = currentTheme.Window
		Title.BackgroundTransparency = 1.000
		Title.Position = UDim2.new(0, 10, 0, 5)
		Title.Size = UDim2.new(0, 118, 0, 21)
		Title.Font = Enum.Font.SourceSans
		Title.Text = name or "Toggle"
		Title.TextColor3 = currentTheme.Text
		Title.TextSize = 16.000
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.ZIndex = 3
		
		ToggleButton.Name = "ToggleButton"
		ToggleButton.Parent = ToggleFrame
		ToggleButton.BackgroundColor3 = currentTheme.Window
		ToggleButton.BackgroundTransparency = 1.000
		ToggleButton.Position = UDim2.new(1, -65, 0, 5)
		ToggleButton.Size = UDim2.new(0, 50, 0, 20)
		ToggleButton.ZIndex = 3
		
		ToggleBackground.Name = "ToggleBackground"
		ToggleBackground.Parent = ToggleButton
		ToggleBackground.BackgroundColor3 = currentTheme.Button
		ToggleBackground.BorderColor3 = currentTheme.ButtonBorder
		ToggleBackground.BorderSizePixel = 1
		ToggleBackground.Size = UDim2.new(1, 0, 1, 0)
		ToggleBackground.ZIndex = 4
		
		ToggleFiller.Name = "ToggleFiller"
		ToggleFiller.Parent = ToggleBackground
		ToggleFiller.BackgroundColor3 = currentTheme.ToggleOn
		ToggleFiller.BorderColor3 = currentTheme.ToggleOn
		ToggleFiller.BorderSizePixel = 1
		ToggleFiller.Size = UDim2.new(0, 15, 0, 15)
		ToggleFiller.ZIndex = 5
		
		local toggleState = default
		local function updateToggle(state)
			toggleState = state
			if state then
				ToggleFiller:TweenPosition(UDim2.new(1, -17, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.2)
				ToggleBackground.BackgroundColor3 = currentTheme.ToggleOn
			else
				ToggleFiller:TweenPosition(UDim2.new(0, 2, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Sine, 0.2)
				ToggleBackground.BackgroundColor3 = currentTheme.Button
			end
			if callback then callback(toggleState) end
		end
		
		ToggleButton.MouseButton1Click:Connect(function()
			updateToggle(not toggleState)
		end)
		
		updateToggle(default)

		updateListCanvasSize()
		return {
			ToggleFrame = ToggleFrame,
			UpdateToggle = updateToggle
		}
	end

	function funcs:Slider(name, min, max, default, callback)
		local SliderFrame = Instance.new("Frame")
		local Title = Instance.new("TextLabel")
		local SliderValue = Instance.new("TextLabel")
		local Slider = Instance.new("Frame")
		local UICorner_3 = createCorner(Slider, 5)
		local Filler = Instance.new("Frame")
		local UICorner_4 = createCorner(Filler, 5)
		local Handle = Instance.new("ImageLabel")
		local UICorner_5 = createCorner(Handle, 6)

		SliderFrame.Name = "SliderFrame"
		SliderFrame.Parent = ListFrame
		SliderFrame.BackgroundColor3 = currentTheme.Window
		SliderFrame.BackgroundTransparency = 1.000
		SliderFrame.Size = UDim2.new(1, -10, 0, 50)
		SliderFrame.ZIndex = 2
		
		Title.Name = "Title"
		Title.Parent = SliderFrame
		Title.BackgroundColor3 = currentTheme.Window
		Title.BackgroundTransparency = 1.000
		Title.Position = UDim2.new(0, 10, 0, 5)
		Title.Size = UDim2.new(0, 118, 0, 21)
		Title.Font = Enum.Font.SourceSans
		Title.Text = name or "Slider"
		Title.TextColor3 = currentTheme.Text
		Title.TextSize = 16.000
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.ZIndex = 3
		
		SliderValue.Name = "SliderValue"
		SliderValue.Parent = SliderFrame
		SliderValue.BackgroundColor3 = currentTheme.Window
		SliderValue.BackgroundTransparency = 1.000
		SliderValue.Position = UDim2.new(1, -60, 0, 5)
		SliderValue.Size = UDim2.new(0, 50, 0, 21)
		SliderValue.Font = Enum.Font.SourceSans
		SliderValue.Text = tostring(default)
		SliderValue.TextColor3 = currentTheme.Text
		SliderValue.TextSize = 16.000
		SliderValue.TextXAlignment = Enum.TextXAlignment.Right
		SliderValue.ZIndex = 3
		
		Slider.Name = "Slider"
		Slider.Parent = SliderFrame
		Slider.BackgroundColor3 = currentTheme.Button
		Slider.BorderColor3 = currentTheme.ButtonBorder
		Slider.BorderSizePixel = 1
		Slider.Position = UDim2.new(0.5, -115, 0, 25)
		Slider.Size = UDim2.new(0, 230, 0, 10)
		Slider.ZIndex = 3
		
		Filler.Name = "Filler"
		Filler.Parent = Slider
		Filler.BackgroundColor3 = currentTheme.SliderFill
		Filler.BorderColor3 = currentTheme.SliderFill
		Filler.BorderSizePixel = 1
		Filler.Size = UDim2.new(0, 0, 1, 0)
		Filler.ZIndex = 4
		
		Handle.Name = "Handle"
		Handle.Parent = Filler
		Handle.BackgroundColor3 = currentTheme.Text
		Handle.BorderColor3 = currentTheme.Text
		Handle.BorderSizePixel = 1
		Handle.Image = "rbxassetid://2703923974" -- Solid white dot
		Handle.Position = UDim2.new(1, -6, 0.5, -6)
		Handle.Size = UDim2.new(0, 12, 0, 12)
		Handle.ZIndex = 5

		local value = default
		local dragging = false
		local width = Slider.AbsoluteSize.X
		local diff = max - min
		
		local function updateSlider(x)
			local newX = math.clamp(x, 0, width)
			local percent = newX / width
			value = (percent * diff) + min
			SliderValue.Text = tostring(math.floor(value + 0.5)) -- Round to nearest integer
			Filler.Size = UDim2.new(0, newX, 1, 0)
			if callback then callback(value) end
		end
		
		Slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				local x = mouse.X - Slider.AbsolutePosition.X
				updateSlider(x)
			end
		end)
		
		Slider.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		
		run.RenderStepped:Connect(function()
			if dragging then
				local x = mouse.X - Slider.AbsolutePosition.X
				updateSlider(x)
			end
		end)
		
		-- Initial position
		local initialPercent = (default - min) / diff
		updateSlider(initialPercent * width)

		updateListCanvasSize()
		return {
			SliderFrame = SliderFrame,
			UpdateSlider = updateSlider
		}
	end

	function funcs:Box(name, callback)
		local BoxFrame = Instance.new("Frame")
		local Title = Instance.new("TextLabel")
		local InputBox = Instance.new("TextBox")
        local UICorner_3 = createCorner(InputBox, 5)

		BoxFrame.Name = "BoxFrame"
		BoxFrame.Parent = ListFrame
		BoxFrame.BackgroundColor3 = currentTheme.Window
		BoxFrame.BackgroundTransparency = 1.000
		BoxFrame.Size = UDim2.new(1, -10, 0, 50)
		BoxFrame.ZIndex = 2
		
		Title.Name = "Title"
		Title.Parent = BoxFrame
		Title.BackgroundColor3 = currentTheme.Window
		Title.BackgroundTransparency = 1.000
		Title.Position = UDim2.new(0, 10, 0, 5)
		Title.Size = UDim2.new(0, 118, 0, 21)
		Title.Font = Enum.Font.SourceSans
		Title.Text = name or "Input Box"
		Title.TextColor3 = currentTheme.Text
		Title.TextSize = 16.000
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.ZIndex = 3
		
		InputBox.Name = "InputBox"
		InputBox.Parent = BoxFrame
		InputBox.BackgroundColor3 = currentTheme.Button
		InputBox.BorderColor3 = currentTheme.ButtonBorder
		InputBox.BorderSizePixel = 1
		InputBox.Position = UDim2.new(0.5, -115, 0, 25)
		InputBox.Size = UDim2.new(0, 230, 0, 20)
		InputBox.Font = Enum.Font.SourceSans
		InputBox.PlaceholderText = "Enter value..."
		InputBox.PlaceholderColor3 = currentTheme.Text * 0.5
		InputBox.Text = ""
		InputBox.TextColor3 = currentTheme.Text
		InputBox.TextSize = 16.000
		InputBox.TextXAlignment = Enum.TextXAlignment.Left
		InputBox.ZIndex = 3
		InputBox.Text = ""
		
		InputBox.FocusGained:Connect(function()
			InputBox.BorderColor3 = currentTheme.Primary
		end)
		
		InputBox.FocusLost:Connect(function(enterPressed)
			InputBox.BorderColor3 = currentTheme.ButtonBorder
			if callback then callback(InputBox.Text, true) end
		end)
		
		InputBox.Changed:Connect(function(property)
			if property == "Text" then
				if callback then callback(InputBox.Text, false) end
			end
		end)

		updateListCanvasSize()
		return BoxFrame
	end

	function funcs:Dropdown(name, tableOfButtons, callback)
		local DropdownFrame = Instance.new("Frame")
		local Title = Instance.new("TextLabel")
		local DropdownButton = Instance.new("TextButton")
        local UICorner_3 = createCorner(DropdownButton, 5)
        
        -- The permanent frame that holds the title and button
		DropdownFrame.Name = "DropdownFrame"
		DropdownFrame.Parent = ListFrame
		DropdownFrame.BackgroundColor3 = currentTheme.Window
		DropdownFrame.BackgroundTransparency = 1.000
		DropdownFrame.Size = UDim2.new(1, -10, 0, 30)
		DropdownFrame.ZIndex = 1 -- ZIndex lowered to 1: Renders behind the Header (ZIndex 5)
		
		Title.Name = "Title"
		Title.Parent = DropdownFrame
		Title.BackgroundColor3 = currentTheme.Window
		Title.BackgroundTransparency = 1.000
		Title.Position = UDim2.new(0, 10, 0, 5)
		Title.Size = UDim2.new(0, 118, 0, 21)
		Title.Font = Enum.Font.SourceSans
		Title.Text = name or "Dropdown"
		Title.TextColor3 = currentTheme.Text
		Title.TextSize = 16.000
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.ZIndex = 2
		
		DropdownButton.Name = "DropdownButton"
		DropdownButton.Parent = DropdownFrame
		DropdownButton.BackgroundColor3 = currentTheme.Button
		DropdownButton.BorderColor3 = currentTheme.ButtonBorder
		DropdownButton.BorderSizePixel = 1
		DropdownButton.Position = UDim2.new(1, -65, 0, 5)
		DropdownButton.Size = UDim2.new(0, 50, 0, 20)
		DropdownButton.Font = Enum.Font.SourceSans
		DropdownButton.Text = "Select"
		DropdownButton.TextColor3 = currentTheme.Text
		DropdownButton.TextSize = 16.000
		DropdownButton.ZIndex = 2
		
		local DropdownPopUp = Instance.new("Frame")
		local DropdownList = Instance.new("ScrollingFrame")
		local ListLayout = Instance.new("UIListLayout")
        local UICorner_4 = createCorner(DropdownPopUp, 5)

		DropdownPopUp.Name = "DropdownPopUp"
		DropdownPopUp.Parent = WindowFrame
		DropdownPopUp.BackgroundColor3 = currentTheme.Button
		DropdownPopUp.BorderColor3 = currentTheme.ButtonBorder
		DropdownPopUp.BorderSizePixel = 1
		DropdownPopUp.Size = UDim2.new(0, 100, 0, 150)
		DropdownPopUp.Visible = false
		DropdownPopUp.ZIndex = 10 -- ZIndex set high to ensure it always draws on top
		
		DropdownList.Name = "DropdownList"
		DropdownList.Parent = DropdownPopUp
		DropdownList.BackgroundColor3 = currentTheme.Button
		DropdownList.BackgroundTransparency = 1.000
		DropdownList.Size = UDim2.new(1, 0, 1, 0)
		DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
		DropdownList.ScrollBarThickness = 6
		
		ListLayout.Parent = DropdownList
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		ListLayout.Padding = UDim.new(0, 2)
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		
		local dropdownFuncs = {}
		local buttons = {}
		
		local function updateListPopUpCanvasSize()
			local size = ListLayout.AbsoluteContentSize
			DropdownList.CanvasSize = UDim2.new(0, 0, 0, size.Y + 4)
		end
		
		local function createButton(name)
			local button = Instance.new("TextButton")
			button.Parent = DropdownList
			button.BackgroundColor3 = currentTheme.Button
			button.BorderColor3 = currentTheme.ButtonBorder
			button.BorderSizePixel = 1
			button.Size = UDim2.new(1, -4, 0, 20)
			button.Font = Enum.Font.SourceSans
			button.Text = name
			button.TextColor3 = currentTheme.Text
			button.TextSize = 16.000
			
			button.MouseEnter:Connect(function()
				button.BackgroundColor3 = currentTheme.Primary
			end)
			
			button.MouseLeave:Connect(function()
				button.BackgroundColor3 = currentTheme.Button
			end)
			
			button.MouseButton1Click:Connect(function()
				DropdownPopUp.Visible = false
				DropdownButton.Text = name
				if callback then callback(name) end
			end)
			
			table.insert(buttons, button)
			updateListPopUpCanvasSize()
			return button
		end
		
		for _, name in pairs(tableOfButtons) do
			createButton(name)
		end
		
		function dropdownFuncs:Button(name)
			return createButton(name)
		end
		
		function dropdownFuncs:RemoveButton(name)
			for i, button in ipairs(buttons) do
				if button.Text == name then
					button:Destroy()
					table.remove(buttons, i)
					updateListPopUpCanvasSize()
					return true
				end
			end
			warn("TurtleLib: Dropdown button '" .. name .. "' not found.")
			return false
		end
		
		DropdownButton.MouseButton1Click:Connect(function()
			local absPos = DropdownButton.AbsolutePosition
			local absSize = DropdownButton.AbsoluteSize
			local windowAbsPos = WindowFrame.AbsolutePosition
			
			-- Position the popup relative to the window
			DropdownPopUp.Position = UDim2.new(0, absPos.X - windowAbsPos.X, 0, absPos.Y - windowAbsPos.Y + absSize.Y + 5)
			DropdownPopUp.Visible = not DropdownPopUp.Visible
		end)
		
		updateListCanvasSize()
		return dropdownFuncs
	end

	function funcs:ColorPicker(name, default, callback)
		local ColorPickerFrame = Instance.new("Frame")
		local ColorPicker = Instance.new("TextButton")
        local UICorner_3 = createCorner(ColorPicker, 5)
		local ToggleFiller_2 = Instance.new("Frame")
        local UICorner_4 = createCorner(ToggleFiller_2, 5)
		local ColorPopup = Instance.new("Frame")
        local UICorner_5 = createCorner(ColorPopup, 5)
		local ColorPickerHue = Instance.new("Frame")
        local UICorner_6 = createCorner(ColorPickerHue, 5)
		local ColorSlider = Instance.new("Frame")
		local ColorSliderHandle = Instance.new("ImageLabel")
        local UICorner_7 = createCorner(ColorSliderHandle, 6)
		local Title = Instance.new("TextLabel")
		
		ColorPickerFrame.Name = "ColorPickerFrame"
		ColorPickerFrame.Parent = ListFrame
		ColorPickerFrame.BackgroundColor3 = currentTheme.Window
		ColorPickerFrame.BackgroundTransparency = 1.000
		ColorPickerFrame.Size = UDim2.new(1, -10, 0, 30)
		ColorPickerFrame.ZIndex = 2
		
		ColorPicker.Name = "ColorPicker"
		ColorPicker.Parent = ColorPickerFrame
		ColorPicker.BackgroundColor3 = currentTheme.Button
		ColorPicker.BorderColor3 = currentTheme.ButtonBorder
		ColorPicker.BorderSizePixel = 1
		ColorPicker.Position = UDim2.new(1, -30, 0, 5)
		ColorPicker.Size = UDim2.new(0, 25, 0, 20)
		ColorPicker.Font = Enum.Font.SourceSans
		ColorPicker.Text = ""
		ColorPicker.TextColor3 = currentTheme.Text
		ColorPicker.TextSize = 16.000
		ColorPicker.ZIndex = 3
		
		ToggleFiller_2.Name = "ToggleFiller_2"
		ToggleFiller_2.Parent = ColorPicker
		ToggleFiller_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ToggleFiller_2.BackgroundTransparency = 1.000
		ToggleFiller_2.Size = UDim2.new(1, 0, 1, 0)
		ToggleFiller_2.ZIndex = 4
		ToggleFiller_2.Visible = false
		
		ColorPopup.Name = "ColorPopup"
		ColorPopup.Parent = WindowFrame
		ColorPopup.BackgroundColor3 = currentTheme.PickerBackground
		ColorPopup.BorderColor3 = currentTheme.WindowBorder
		ColorPopup.BorderSizePixel = 1
		ColorPopup.Size = UDim2.new(0, 150, 0, 150)
		ColorPopup.Visible = false
		ColorPopup.ZIndex = 10
		
		ColorPickerHue.Name = "ColorPickerHue"
		ColorPickerHue.Parent = ColorPopup
		ColorPickerHue.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		ColorPickerHue.Position = UDim2.new(0, 5, 0, 5)
		ColorPickerHue.Size = UDim2.new(0, 120, 0, 140)
		ColorPickerHue.ZIndex = 4
		
		ColorSlider.Name = "ColorSlider"
		ColorSlider.Parent = ColorPopup
		ColorSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ColorSlider.Position = UDim2.new(0, 130, 0, 5)
		ColorSlider.Size = UDim2.new(0, 10, 0, 140)
		ColorSlider.ZIndex = 4
		
		ColorSliderHandle.Name = "ColorSliderHandle"
		ColorSliderHandle.Parent = ColorSlider
		ColorSliderHandle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		ColorSliderHandle.BorderColor3 = Color3.fromRGB(0, 0, 0)
		ColorSliderHandle.BorderSizePixel = 1
		ColorSliderHandle.Image = "rbxassetid://2703923974"
		ColorSliderHandle.Position = UDim2.new(0.5, -6, 0.5, -6)
		ColorSliderHandle.Size = UDim2.new(0, 12, 0, 12)
        ColorSliderHandle.ZIndex = 5
        
        -- ColorPickerHue Gradient Overlays (Slightly simplified for brevity but functional)
        local OverlayWhite = Instance.new("Frame")
        OverlayWhite.Parent = ColorPickerHue
        OverlayWhite.BackgroundTransparency = 0.5
        OverlayWhite.BackgroundColor3 = Color3.new(1, 1, 1)
        OverlayWhite.Size = UDim2.new(1, 0, 1, 0)

        local OverlayBlack = Instance.new("Frame")
        OverlayBlack.Parent = ColorPickerHue
        OverlayBlack.BackgroundTransparency = 0.5
        OverlayBlack.BackgroundColor3 = Color3.new(0, 0, 0)
        OverlayBlack.Size = UDim2.new(1, 0, 1, 0)
        
        -- The saturation/value picker handle
        local ColorPickerHandle = Instance.new("ImageLabel")
        ColorPickerHandle.Name = "ColorPickerHandle"
        ColorPickerHandle.Parent = ColorPickerHue
        ColorPickerHandle.BackgroundColor3 = Color3.new(1, 1, 1)
        ColorPickerHandle.BorderColor3 = Color3.new(0, 0, 0)
        ColorPickerHandle.BorderSizePixel = 1
        ColorPickerHandle.Image = "rbxassetid://2703923974"
        ColorPickerHandle.Size = UDim2.new(0, 10, 0, 10)
        ColorPickerHandle.ZIndex = 5
        
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
		Title.ZIndex = 4
		
	    table.insert(colorPickers, ColorPickerFrame)

	    local currentHue = 0
	    local currentSat = 1
	    local currentVal = 1
	    local color3 = Color3.fromHSV(currentHue, currentSat, currentVal)
	    local draggingHue = false
	    local draggingSV = false
        local con

        local function updateColorPicker()
            color3 = Color3.fromHSV(currentHue, currentSat, currentVal)
            ColorPicker.BackgroundColor3 = color3
            ColorPickerHandle.BackgroundColor3 = color3
            if callback then callback(color3) end
        end

        local function updateHue(y)
            local height = ColorSlider.AbsoluteSize.Y
            local percent = math.clamp(y / height, 0, 1)
            currentHue = 1 - percent
            ColorSliderHandle:TweenPosition(UDim2.new(0.5, -6, percent, -6), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
            ColorPickerHue.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
            updateColorPicker()
        end

        local function updateSV(x, y)
            local width = ColorPickerHue.AbsoluteSize.X
            local height = ColorPickerHue.AbsoluteSize.Y
            
            local xPercent = math.clamp(x / width, 0, 1)
            local yPercent = math.clamp(y / height, 0, 1)
            
            currentSat = xPercent
            currentVal = 1 - yPercent
            
            ColorPickerHandle:TweenPosition(UDim2.new(xPercent, -5, yPercent, -5), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.1, true)
            updateColorPicker()
        end

        ColorSlider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
                local y = mouse.Y - ColorSlider.AbsolutePosition.Y
                updateHue(y)
            end
        end)

        ColorPickerHue.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSV = true
                local x = mouse.X - ColorPickerHue.AbsolutePosition.X
                local y = mouse.Y - ColorPickerHue.AbsolutePosition.Y
                updateSV(x, y)
            end
        end)

        ColorPopup.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = false
                draggingSV = false
            end
        end)

        run.RenderStepped:Connect(function()
            if draggingHue then
                local y = mouse.Y - ColorSlider.AbsolutePosition.Y
                updateHue(y)
            elseif draggingSV then
                local x = mouse.X - ColorPickerHue.AbsolutePosition.X
                local y = mouse.Y - ColorPickerHue.AbsolutePosition.Y
                updateSV(x, y)
            end
        end)

        ColorPicker.MouseButton1Click:Connect(function()
            local absPos = ColorPicker.AbsolutePosition
            local absSize = ColorPicker.AbsoluteSize
            local windowAbsPos = WindowFrame.AbsolutePosition
            
            ColorPopup.Position = UDim2.new(0, absPos.X - windowAbsPos.X - ColorPopup.Size.X.Offset, 0, absPos.Y - windowAbsPos.Y + absSize.Y + 5)
            ColorPopup.Visible = not ColorPopup.Visible
        end)

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
                ColorPicker.Destroying:Connect(function() if con then con:Disconnect() end end)
            end
        end
        
        -- Initialize with default color
        if typeof(default) == "userdata" then
            local h, s, v = Color3.toHSV(default)
            currentHue = h
            currentSat = s
            currentVal = v
            updateHue(ColorSlider.AbsoluteSize.Y * (1 - h))
            updateSV(ColorPickerHue.AbsoluteSize.X * s, ColorPickerHue.AbsoluteSize.Y * (1 - v))
        end

		colorFuncs:UpdateColorPicker(default or Color3.fromRGB(255, 255, 255))

		updateListCanvasSize()
		return colorFuncs
	end

	table.insert(windows, WindowFrame)
	
	-- Set the default ContentSize to ensure ListFrame starts below Header
	funcs:SetContentSize(UDim2.new(0, 0, 0.1, 0))

	return setmetatable(funcs, {
		__index = funcs,
		__newindex = function(self, key, value)
			if key == "ContentSize" and typeof(value) == "UDim2" then
				self:SetContentSize(value)
			else
				rawset(self, key, value)
			end
		end
	})
end

return library
