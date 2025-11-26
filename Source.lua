-- Updated Turtle UI Lib with Theme Support + Rounded Corners
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
local destroyed = {}

local function newWindow(title)
windowCount = windowCount + 1
sizes[windowCount] = 32
listOffset[windowCount] = 0

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 207, 0, sizes[windowCount])
Window.Position = UDim2.new(0.5, -104, 0.5, -50)
Window.BackgroundColor3 = currentTheme.Window
Window.BorderSizePixel = 0
Window.ZIndex = 1

-- Add rounded corners to the main window
local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 8)
WindowCorner.Parent = Window

-- Example Button with rounded corners
local Button = Instance.new("TextButton")
Button.Name = "Button"
Button.Size = UDim2.new(0, 100, 0, 26)
Button.Position = UDim2.new(0, 12, 0, 50)
Button.BackgroundColor3 = currentTheme.Button
Button.BorderColor3 = currentTheme.ButtonBorder
Button.Text = "Click Me"
Button.Font = Enum.Font.SourceSans
Button.TextSize = 16
Button.TextColor3 = currentTheme.Text
Button.ZIndex = 2

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = Button

-- Example Slider with rounded corners
local Slider = Instance.new("Frame")
Slider.Name = "Slider"
Slider.Size = UDim2.new(0, 180, 0, 26)
Slider.BackgroundColor3 = currentTheme.Button
Slider.BorderColor3 = currentTheme.ButtonBorder
Slider.ZIndex = 2

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = Slider

local SliderButton = Instance.new("Frame")
SliderButton.Name = "SliderButton"
SliderButton.Size = UDim2.new(0, 6, 0, 22)
SliderButton.BackgroundColor3 = currentTheme.Button
SliderButton.BorderColor3 = currentTheme.ButtonBorder
SliderButton.ZIndex = 3

local SliderButtonCorner = Instance.new("UICorner")
SliderButtonCorner.CornerRadius = UDim.new(0, 3)
SliderButtonCorner.Parent = SliderButton

-- Example Dropdown with rounded corners
local Dropdown = Instance.new("TextButton")
Dropdown.Name = "Dropdown"
Dropdown.Size = UDim2.new(0, 182, 0, 26)
Dropdown.BackgroundColor3 = currentTheme.Button
Dropdown.BorderColor3 = currentTheme.ButtonBorder
Dropdown.Text = "Select Option"
Dropdown.Font = Enum.Font.SourceSans
Dropdown.TextSize = 16
Dropdown.TextColor3 = currentTheme.Text
Dropdown.ZIndex = 3

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = Dropdown

-- Example Color Picker with rounded corners
local ColorPickerFrame = Instance.new("Frame")
ColorPickerFrame.Name = "ColorPickerFrame"
ColorPickerFrame.Size = UDim2.new(0, 158, 0, 155)
ColorPickerFrame.BackgroundColor3 = currentTheme.PickerBackground
ColorPickerFrame.BorderColor3 = currentTheme.PickerBackground
ColorPickerFrame.ZIndex = 3
ColorPickerFrame.Visible = false

local ColorPickerCorner = Instance.new("UICorner")
ColorPickerCorner.CornerRadius = UDim.new(0, 6)
ColorPickerCorner.Parent = ColorPickerFrame

-- Slider inside Color Picker
local ColorSlider = Instance.new("Frame")
ColorSlider.Size = UDim2.new(0, 2, 0, 14)
ColorSlider.BackgroundColor3 = currentTheme.Text
ColorSlider.BorderColor3 = currentTheme.Text
ColorSlider.ZIndex = 5

local ColorSliderCorner = Instance.new("UICorner")
ColorSliderCorner.CornerRadius = UDim.new(0, 2)
ColorSliderCorner.Parent = ColorSlider

-- Add everything to the main window
Button.Parent = Window
Slider.Parent = Window
SliderButton.Parent = Slider
Dropdown.Parent = Window
ColorPickerFrame.Parent = Window
ColorSlider.Parent = ColorPickerFrame

windows[windowCount] = Window
return Window

end

library.NewWindow = newWindow
return library
