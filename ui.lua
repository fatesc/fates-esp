if (Activated) then
	KillScript()
end

getgenv().Activated = true

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AssetId = "rbxassetid://6945229203" --getsynasset("fateui.rbxm")
local UIElements = game:GetObjects(AssetId)[1]
local GuiObjects = UIElements.GuiObjects

local MainUI
local UILibrary = {}
local Utils = {}

local Colors = {
	PageTextPressed = Color3.fromRGB(200, 200, 200);
	PageBackgroundPressed = Color3.fromRGB(15, 15, 15);
	PageBorderPressed = Color3.fromRGB(20, 20, 20);
	
	PageTextHover = Color3.fromRGB(175, 175, 175);
	PageBackgroundHover = Color3.fromRGB(16, 16, 16);
	
	PageTextIdle = Color3.fromRGB(150, 150, 150);
	PageBackgroundIdle = Color3.fromRGB(18, 18, 18);
	PageBorderIdle = Color3.fromRGB(18, 18, 18);
	
	ElementBackground = Color3.fromRGB(25, 25, 25);
}

 

local Connections = {}

local Connect = function(Signal, Func)
	local Connection = Signal:Connect(Func)
	table.insert(Connections, Connection)
	return Connection
end
	
getgenv().KillScript = function()
	for _, Connection in pairs(Connections) do
		Connection:Disconnect()
	end
	if (MainUI) then
		MainUI:Destroy()
	end
	getgenv().Activated = nil
end


local function NewThread(Func, ...)
	local Thread = coroutine.create(Func)
	return coroutine.resume(Thread, ...)
end

local function Debounce(Function)
	local Debounce_ = false

	return function(...)
		if (not Debounce_) then
			Debounce_ = true
			Function(...)
			Debounce_ = false
		end
	end
end

local function RandomString(Length)
	local String = ""
	for _ = 1, Length do
		String = String .. string.char(math.random(65, 122))
	end
	return String
end

local function InitUI(UI)
	UI.DisplayOrder = 69420
	UI.ResetOnSpawn = false
	UI.Name = RandomString(10)
	MainUI = UI

	if ((not is_sirhurt_closure) and (syn and syn.protect_gui)) then
		syn.protect_gui(UI)
		UI.Parent = CoreGui
	elseif (get_hidden_gui or gethui) then
		local HiddenUI = get_hidden_gui or gethui
		UI.Parent = HiddenUI
	elseif (CoreGui:FindFirstChild("RobloxGui")) then
		UI.Parent = CoreGui.RobloxGui
	else
		UI.Parent = CoreGui
	end

	return UI
end


function Utils.SmoothScroll(content, SmoothingFactor) -- by Elttob
	content.ScrollingEnabled = false

	local input = content:Clone()
	
	input:ClearAllChildren()
	input.BackgroundTransparency = 1
	input.ScrollBarImageTransparency = 1
	input.ZIndex = content.ZIndex + 1
	input.Name = "_smoothinputframe"
	input.ScrollingEnabled = true
	input.Parent = content.Parent

	local function syncProperty(prop)
		content:GetPropertyChangedSignal(prop):Connect(function()
			if prop == "ZIndex" then
				input[prop] = content[prop] + 1
			else
				input[prop] = content[prop]
			end
		end)
	end

	syncProperty "CanvasSize"
	syncProperty "Position"
	syncProperty "Rotation"
	syncProperty "ScrollingDirection"
	syncProperty "ScrollBarThickness"
	syncProperty "BorderSizePixel"
	syncProperty "ElasticBehavior"
	syncProperty "SizeConstraint"
	syncProperty "ZIndex"
	syncProperty "BorderColor3"
	syncProperty "Size"
	syncProperty "AnchorPoint"
	syncProperty "Visible"

	local smoothConnection = RunService.RenderStepped:Connect(function()
		local a = content.CanvasPosition
		local b = input.CanvasPosition
		local c = SmoothingFactor
		local d = (b - a) * c + a
		
		content.CanvasPosition = d
	end)

	content.AncestryChanged:Connect(function()
		if content.Parent == nil then
			input:Destroy()
			smoothConnection:Disconnect()
		end
	end)
end

function Utils.Tween(Object, Style, Direction, Time, Goal)
	local TInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
	local Tween = TweenService:Create(Object, TInfo, Goal)

	Tween:Play()

	return Tween
end


function Utils.MultColor3(Color, Delta)
	return Color3.new(math.clamp(Color.R * Delta, 0, 1), math.clamp(Color.G * Delta, 0, 1), math.clamp(Color.B * Delta, 0, 1))
end

function Utils.Draggable(UI, DragUi)
	local DragSpeed = 0
	local StartPos
	local DragToggle, DragInput, DragStart

	if not DragUi then
		DragUi = UI
	end
	
	local function UpdateInput(Input)
		local Delta = Input.Position - DragStart
		local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)

		Utils.Tween(UI, "Linear", "Out", .25, {
			Position = Position
		})
	end

	Connect(UI.InputBegan, function(Input)
		if ((Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and UserInputService:GetFocusedTextBox() == nil) then
			DragToggle = true
			DragStart = Input.Position
			StartPos = UI.Position

			local Objects = CoreGui:GetGuiObjectsAtPosition(DragStart.X, DragStart.Y)

			Connect(Input.Changed, function()
				if (Input.UserInputState == Enum.UserInputState.End) then
					DragToggle = false
				end
			end)
		end
	end)

	Connect(UI.InputChanged, function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			DragInput = Input
		end
	end)

	Connect(UserInputService.InputChanged, function(Input)
		if (Input == DragInput and DragToggle) then
			UpdateInput(Input)
		end
	end)
end

function Utils.Click(Object, Goal)
	local Hover = {
		[Goal] = Utils.MultColor3(Object[Goal], 0.9)
	}

	local Press = {
		[Goal] = Utils.MultColor3(Object[Goal], 1.2)
	}

	local Origin = {
		[Goal] = Object[Goal]
	}

	Object.MouseEnter:Connect(function()
		Utils.Tween(Object, "Quad", "Out", .25, Hover)
	end)

	Object.MouseLeave:Connect(function()
		Utils.Tween(Object, "Quad", "Out", .25, Origin)
	end)

	Object.MouseButton1Down:Connect(function()
		Utils.Tween(Object, "Quad", "Out", .3, Press)
	end)

	Object.MouseButton1Up:Connect(function()
		Utils.Tween(Object, "Quad", "Out", .4, Hover)
	end)
end

function Utils.Hover(Object, Goal)
	local Hover = {
		[Goal] = Utils.MultColor3(Object[Goal], 0.9)
	}

	local Origin = {
		[Goal] = Object[Goal]
	}

	Object.MouseEnter:Connect(function()
		Utils.Tween(Object, "Sine", "Out", .5, Hover)
	end)

	Object.MouseLeave:Connect(function()
		Utils.Tween(Object, "Sine", "Out", .5, Origin)
	end)
end

function Utils.Blink(Object, Goal, Color1, Color2, Time)
	local Normal = {
		[Goal] = Color1
	}

	local Blink = {
		[Goal] = Color2
	}
	
	coroutine.wrap(function()
		Utils.Tween(Object, "Quad", "Out", Time, Blink).Completed:Wait()
		Utils.Tween(Object, "Quad", "Out", Time, Normal).Completed:Wait()
	end)()
end

function Utils.TweenTrans(Object, Transparency)
	local Properties = {
		TextBox = "TextTransparency",
		TextLabel = "TextTransparency",
		TextButton = "TextTransparency",
		ImageButton = "ImageTransparency",
		ImageLabel = "ImageTransparency"
	}

	for _, Instance in ipairs(Object:GetDescendants()) do
		if (Instance:IsA("GuiObject")) then
			for Class, Property in pairs(Properties) do
				if (Instance:IsA(Class) and Instance[Property] ~= 1) then
					Utils.Tween(Instance, "Quad", "Out", .25, {
						[Property] = Transparency
					})
					break
				end
			end
			if Instance.Name == "Overlay" and Transparency == 0 then -- check for overlay
				Utils.Tween(Object, "Quad", "Out", .25, {
					BackgroundTransparency = .5
				})
			elseif (Instance.BackgroundTransparency ~= 1) then
				Utils.Tween(Instance, "Quad", "Out", .25, {
					BackgroundTransparency = Transparency
				})
			end
		end
	end

	return Utils.Tween(Object, "Quad", "Out", .25, {
		BackgroundTransparency = Transparency
	})
end

function Utils.Intro(Object)
	local Frame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local CornerRadius = Object:FindFirstChild("UICorner") and Object.UICorner.CornerRadius or UDim.new(0, 0)

	Frame.Name = "IntroFrame"
	Frame.ZIndex = 1000
	Frame.Size = UDim2.fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y)
	Frame.AnchorPoint = Vector2.new(.5, .5)
	Frame.Position = UDim2.new(Object.Position.X.Scale, Object.Position.X.Offset + (Object.AbsoluteSize.X / 2), Object.Position.Y.Scale, Object.Position.Y.Offset + (Object.AbsoluteSize.Y / 2))
	Frame.BackgroundColor3 = Object.BackgroundColor3
	Frame.BorderSizePixel = 0

	UICorner.CornerRadius = CornerRadius
	UICorner.Parent = Frame

	Frame.Parent = Object.Parent

	if (Object.Visible) then
		Frame.BackgroundTransparency = 1

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 0
		})

		Tween.Completed:Wait()
		Object.Visible = false

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2.fromOffset(0, 0)
		})

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = UDim.new(1, 0)
		})

		Tween.Completed:Wait()
		Frame:Destroy()
	else
		Frame.Visible = true
		Frame.Size = UDim2.fromOffset(0, 0)
		UICorner.CornerRadius = UDim.new(1, 0)

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			Size = UDim2.fromOffset(Object.AbsoluteSize.X, Object.AbsoluteSize.Y)
		})

		Utils.Tween(UICorner, "Quad", "Out", .25, {
			CornerRadius = CornerRadius
		})

		Tween.Completed:Wait()
		Object.Visible = true

		local Tween = Utils.Tween(Frame, "Quad", "Out", .25, {
			BackgroundTransparency = 1
		})

		Tween.Completed:Wait()
		Frame:Destroy()
	end
end

function Utils.MakeGradient(ColorTable)
	local Table = {}
	for Time, Color in pairs(ColorTable) do
		table.insert(Table, ColorSequenceKeypoint.new(Time, Color))
	end
	return ColorSequence.new(Table)
end

UILibrary.__index = UILibrary

function UILibrary.new(ColorTheme)
	assert(typeof(ColorTheme) == "Color3", "[UI] ColorTheme must be a Color3.")

	local NewUI = {}
	local UI = Instance.new("ScreenGui")

	setmetatable(NewUI, UILibrary)
	InitUI(UI)
	NewUI.UI = UI
	NewUI.ColorTheme = ColorTheme

	return NewUI
end

function UILibrary:LoadWindow(Title, Size)
	local Window = GuiObjects.Load.Window:Clone()
	local Main = Window.Main
	local Overlay = Main.Overlay
	local OverlayMain = Overlay.Main
	local ColorPicker = OverlayMain.ColorPicker
	local Settings = OverlayMain.Settings
	local ClosePicker = OverlayMain.Close
	local ColorCanvas = ColorPicker.ColorCanvas
	local ColorSlider = ColorPicker.ColorSlider
	local ColorGradient = ColorCanvas.ColorGradient
	local DarkGradient = ColorGradient.DarkGradient
	local CanvasBar = ColorGradient.Bar
	local RainbowGradient = ColorSlider.RainbowGradient
	local SliderBar = RainbowGradient.Bar
	local CanvasHitbox = ColorCanvas.Hitbox
	local SliderHitbox = ColorSlider.Hitbox
	local ColorPreview = Settings.ColorPreview
	local ColorOptions = Settings.Options
	local RedTextBox = ColorOptions.Red.TextBox
	local BlueTextBox = ColorOptions.Blue.TextBox
	local GreenTextBox = ColorOptions.Green.TextBox
	local RainbowToggle = ColorOptions.Rainbow
	Utils.Click(OverlayMain.Close, "BackgroundColor3")
	
	Window.Size = Size
	Window.Position = UDim2.new(0.5, -Size.X.Offset / 2, 0.5, -Size.Y.Offset / 2)
	Window.Main.Title.Text = Title
	Window.Parent = self.UI
	
	Utils.Draggable(Window)

	local Idle = false
	local LeftWindow = false
	local Timer = tick()
	Connect(Window.MouseEnter, function()
		LeftWindow = false
		if Idle then
			Idle = false
			Utils.TweenTrans(Window, 0)
		end
	end)
	Connect(Window.MouseLeave, function()
		LeftWindow = true
		Timer = tick()
	end)
	
	Connect(RunService.RenderStepped, function()
		if LeftWindow then
			local Time = tick() - Timer
			if Time >= 3 and not Idle then
				Utils.TweenTrans(Window, .75)
				Idle = true
			end
		end
	end)
	
	
	local WindowLibrary = {}
	local PageCount = 0
	local SelectedPage
    

	function WindowLibrary.NewPage(Title)
		local Page = GuiObjects.New.Page:Clone()
		local TextButton = GuiObjects.New.TextButton:Clone()

		if PageCount == 0 then
			TextButton.TextColor3 = Colors.PageTextPressed
			TextButton.BackgroundColor3 = Colors.PageBackgroundPressed
			TextButton.BorderColor3 = Colors.PageBorderPressed
			SelectedPage = Page
		end
		
		Connect(TextButton.MouseEnter, function()
			if SelectedPage.Name ~= TextButton.Name then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextHover;
					BackgroundColor3 = Colors.PageBackgroundHover;
					BorderColor3 = Colors.PageBorderHover;
				})
			end
		end)
		
		Connect(TextButton.MouseLeave, function()
			if SelectedPage.Name ~= TextButton.Name then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextIdle;
					BackgroundColor3 = Colors.PageBackgroundIdle;
					BorderColor3 = Colors.PageBackgroundIdle;
				})
			end
		end)
		
		Connect(TextButton.MouseButton1Down, function()
			if SelectedPage.Name ~= TextButton.Name then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextPressed;
				})
			end
		end)
		
		Connect(TextButton.MouseButton1Click, function()
			if SelectedPage.Name ~= TextButton.Name then
				Utils.Tween(TextButton, "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextPressed;
					BackgroundColor3 = Colors.PageBackgroundPressed;
					BorderColor3 = Colors.PageBorderPressed;
				})
				
				Utils.Tween(Window.Main.Selection[SelectedPage.Name], "Quad", "Out", .25, {
					TextColor3 = Colors.PageTextIdle;
					BackgroundColor3 = Colors.PageBackgroundIdle;
					BorderColor3 = Colors.PageBackgroundIdle;
				})
				
				SelectedPage = Page
				Window.Main.Container.UIPageLayout:JumpTo(SelectedPage)
			end
		end)

		
		Page.Name = Title
		TextButton.Name = Title
		TextButton.Text = Title
		
		Page.Parent = Window.Main.Container
		TextButton.Parent = Window.Main.Selection
		
		PageCount = PageCount + 1
		
		local PageLibrary = {}
		
		function PageLibrary.NewSection(Title)
			local Section = GuiObjects.Section.Container:Clone()
			local SectionOptions = Section.Options
			local SectionUIListLayout = Section.Options.UIListLayout

            -- Utils.SmoothScroll(Section.Options, .14)
			Section.Title.Text = Title
			Section.Parent = Page.Selection
			
			Connect(SectionUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionOptions.CanvasSize = UDim2.fromOffset(0, SectionUIListLayout.AbsoluteContentSize.Y + 5)
			end)
			
			local ElementLibrary = {}
			
			
			local function ToggleFunction(Container, Enabled, Callback) -- fpr color picker
				local Switch = Container.Switch
				local Hitbox = Container.Hitbox
				Container.BackgroundColor3 = self.ColorTheme
				
				if not Enabled then
					Switch.Position = UDim2.fromOffset(2, 2)
					Container.BackgroundColor3 = Colors.ElementBackground
				end
                
				Connect(Hitbox.MouseButton1Click, function()
					Enabled = not Enabled
					
					Utils.Tween(Switch, "Quad", "Out", .25, {
						Position = Enabled and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
					})
					Utils.Tween(Container, "Quad", "Out", .25, {
						BackgroundColor3 = Enabled and self.ColorTheme or Colors.ElementBackground
					})
					
					Callback(Enabled)
				end)
			end
			
            
			function ElementLibrary.Toggle(Title, Enabled, Callback)
				local Toggle = GuiObjects.Elements.Toggle:Clone()
				local Container = Toggle.Container
				ToggleFunction(Container, Enabled, Callback)
                
				Toggle.Title.Text = Title
				Toggle.Parent = Section.Options
			end
			
			
			function ElementLibrary.Slider(Title, Args, Callback)
				local Slider = GuiObjects.Elements.Slider:Clone()
				local Container = Slider.Container
				local ContainerSliderBar = Container.SliderBar
				local BarFrame = ContainerSliderBar.BarFrame
				local Bar = BarFrame.Bar
				local Label = Bar.Label
				local Hitbox = Container.Hitbox
				
				Bar.BackgroundColor3 = self.ColorTheme
				Bar.Size = UDim2.fromScale(Args.Default / Args.Max, 1)
				Label.Text = tostring(Args.Default)
				Label.BackgroundTransparency = 1
				Label.TextTransparency = 1
				Container.Min.Text = tostring(Args.Min)
				Container.Max.Text = tostring(Args.Max)
				Slider.Title.Text = Title
								
				local Moving = false
                
                local function Update()
					local RightBound = BarFrame.AbsoluteSize.X
					local Position = math.clamp(Mouse.X - BarFrame.AbsolutePosition.X, 0, RightBound)
					local Value = Args.Min + (Args.Max - Args.Min) * (Position / RightBound) -- get difference then add min value, lol lerp
					
					Value = Value - (Value % Args.Step)
					Callback(Value)
					
					local Precent = Value / Args.Max
					local Size = UDim2.fromScale(Precent, 1)
					local Tween = Utils.Tween(Bar, "Linear", "Out", .05, {
						Size = Size
					})
					
					Label.Text = Value
					Tween.Completed:Wait()
                end
			
				Connect(Hitbox.MouseButton1Down, function()
					Moving = true
					
					Utils.Tween(Label, "Quad", "Out", .25, {
						BackgroundTransparency = 0;
						TextTransparency = 0;
					})
					
					Update()
				end)
				
				Connect(UserInputService.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
						Moving = false
						
						Utils.Tween(Label, "Quad", "Out", .25, {
							BackgroundTransparency = 1;
							TextTransparency = 1;
						})
					end
				end)
				
				Connect(Mouse.Move, Debounce(function()
					if Moving then
						Update()
					end
				end))
				
				Slider.Parent = Section.Options
			end
			
			function ElementLibrary.ColorPicker(Title, DefaultColor, Callback)
				local SelectColor = GuiObjects.Elements.SelectColor:Clone()
				local CurrentColor = DefaultColor
				local Button = SelectColor.Button
                               
				local H, S, V = DefaultColor:ToHSV()
				local Opened = false
				local Rainbow = false
                
                local function UpdateText()
					RedTextBox.PlaceholderText = tostring(math.floor(CurrentColor.R * 255))
					GreenTextBox.PlaceholderText = tostring(math.floor(CurrentColor.G * 255))
					BlueTextBox.PlaceholderText = tostring(math.floor(CurrentColor.B * 255))
				end
                
                local function UpdateColor()
					H, S, V = CurrentColor:ToHSV()
					
					SliderBar.Position = UDim2.new(0, 0, H, 2)
					CanvasBar.Position = UDim2.new(S, 2, 1 - V, 2)
					ColorGradient.UIGradient.Color = Utils.MakeGradient({
						[0] = Color3.new(1, 1, 1);
						[1] = Color3.fromHSV(H, 1, 1);
					})
					
					ColorPreview.BackgroundColor3 = CurrentColor
					UpdateText()
				end

                local function UpdateHue(Hue)
					SliderBar.Position = UDim2.new(0, 0, Hue, 2)
					ColorGradient.UIGradient.Color = Utils.MakeGradient({
						[0] = Color3.new(1, 1, 1);
						[1] = Color3.fromHSV(Hue, 1, 1);
					})
					
					ColorPreview.BackgroundColor3 = CurrentColor
					UpdateText()
				end
                
                local function ColorSliderInit()
					local Moving = false
                    
                    local function Update()
						if Opened and not Rainbow then
							local LowerBound = SliderHitbox.AbsoluteSize.Y
							local Position = math.clamp(Mouse.Y - SliderHitbox.AbsolutePosition.Y, 0, LowerBound)
							local Value = Position / LowerBound
							
							H = Value
							CurrentColor = Color3.fromHSV(H, S, V)
							ColorPreview.BackgroundColor3 = CurrentColor
							ColorGradient.UIGradient.Color = Utils.MakeGradient({
								[0] = Color3.new(1, 1, 1);
								[1] = Color3.fromHSV(H, 1, 1);
							})
							
							UpdateText()
							
							local Position = UDim2.new(0, 0, Value, 2)
							local Tween = Utils.Tween(SliderBar, "Linear", "Out", .05, {
								Position = Position
							})
							
							Callback(CurrentColor)
							Tween.Completed:Wait()
						end
                    end
				
					Connect(SliderHitbox.MouseButton1Down, function()
						Moving = true
						Update()
					end)
					
					Connect(UserInputService.InputEnded, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
							Moving = false
						end
					end)
					
					Connect(Mouse.Move, Debounce(function()
						if Moving then
							Update()
						end
					end))
				end
				local function ColorCanvasInit()
					local Moving = false
                    
                    local function Update()
						if Opened then
							local LowerBound = CanvasHitbox.AbsoluteSize.Y
							local YPosition = math.clamp(Mouse.Y - CanvasHitbox.AbsolutePosition.Y, 0, LowerBound)
							local YValue = YPosition / LowerBound
							local RightBound = CanvasHitbox.AbsoluteSize.X
							local XPosition = math.clamp(Mouse.X - CanvasHitbox.AbsolutePosition.X, 0, RightBound)
							local XValue = XPosition / RightBound
							
							S = XValue
							V = 1 - YValue
							
							CurrentColor = Color3.fromHSV(H, S, V)
							ColorPreview.BackgroundColor3 = CurrentColor
							UpdateText()
							
							local Position = UDim2.new(XValue, 2, YValue, 2)
							local Tween = Utils.Tween(CanvasBar, "Linear", "Out", .05, {
								Position = Position
							})
							Callback(CurrentColor)
							Tween.Completed:Wait()
						end
                    end
				
					Connect(CanvasHitbox.MouseButton1Down, function()
						Moving = true
						Update()
					end)
					
					Connect(UserInputService.InputEnded, function(Input)
						if Input.UserInputType == Enum.UserInputType.MouseButton1 and Moving then
							Moving = false
						end
					end)
					
					Connect(Mouse.Move, Debounce(function()
						if Moving then
							Update()
						end
					end))
				end
				
				ColorSliderInit()
				ColorCanvasInit()
				
				Connect(Button.MouseButton1Click, function()
					if not Opened then
						Opened = true
						UpdateColor()
						RainbowToggle.Container.Switch.Position = Rainbow and UDim2.new(1, -18, 0, 2) or UDim2.fromOffset(2, 2)
						RainbowToggle.Container.BackgroundColor3 = Rainbow and self.ColorTheme or Colors.ElementBackground
						Overlay.Visible = true
						OverlayMain.Visible = false
						Utils.Intro(OverlayMain)
					end
				end)
				
				Connect(ClosePicker.MouseButton1Click, Debounce(function()
					Button.BackgroundColor3 = CurrentColor
					Utils.Intro(OverlayMain)
					Overlay.Visible = false
					Opened = false
				end))
				
				Connect(RedTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(RedTextBox.Text)
						if Number then
							Number = math.clamp(math.floor(Number), 0, 255)
							CurrentColor = Color3.new(Number / 255, CurrentColor.G, CurrentColor.B)
							UpdateColor()
							RedTextBox.PlaceholderText = tostring(Number)
							Callback(CurrentColor)
						end
						RedTextBox.Text = ""
					end
				end)
				
				Connect(GreenTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(GreenTextBox.Text)
						if Number then
							Number = math.clamp(math.floor(Number), 0, 255)
							CurrentColor = Color3.new(CurrentColor.R, Number / 255, CurrentColor.B)
							UpdateColor()
							GreenTextBox.PlaceholderText = tostring(Number)
							Callback(CurrentColor)
						end
						GreenTextBox.Text = ""
					end
				end)
				
				Connect(BlueTextBox.FocusLost, function()
					if Opened then
						local Number = tonumber(BlueTextBox.Text)
						if Number then
							Number = math.clamp(math.floor(Number), 0, 255)
							CurrentColor = Color3.new(CurrentColor.R, CurrentColor.G, Number / 255)
							UpdateColor()
							BlueTextBox.PlaceholderText = tostring(Number)
							Callback(CurrentColor)
						end
						BlueTextBox.Text = ""
					end
				end)
				
				ToggleFunction(RainbowToggle.Container, false, function(Callback)
					if Opened then
						Rainbow = Callback
					end
				end)
				
				Connect(RunService.RenderStepped, function()
					if Rainbow then
						local Hue = (tick() / 5) % 1
						CurrentColor = Color3.fromHSV(Hue, S, V)
						
						if Opened then
							UpdateHue(Hue)
						end
						
						Button.BackgroundColor3 = CurrentColor
						Callback(CurrentColor)
					end
				end)
                				
				Button.BackgroundColor3 = DefaultColor
				SelectColor.Title.Text = Title
				SelectColor.Parent = Section.Options
			end
            
			function ElementLibrary.Dropdown(Title, Options, Callback)
				local DropdownElement = GuiObjects.Elements.Dropdown.DropdownElement:Clone()
				local DropdownSelection = GuiObjects.Elements.Dropdown.DropdownSelection:Clone()
				local TextButton = GuiObjects.Elements.Dropdown.TextButton
				local Button = DropdownElement.Button
				local Opened = false
				local Size = (TextButton.Size.Y.Offset + 5) * #Options
				
                local function ToggleDropdown()
					Opened = not Opened
					
					if Opened then
						DropdownSelection.Frame.Visible = true
						DropdownSelection.Visible = true
						
						Utils.Tween(DropdownSelection, "Quad", "Out", .25, {
							Size = UDim2.new(1, -10, 0, Size)
						})
						Utils.Tween(DropdownElement.Button, "Quad", "Out", .25, {
							Rotation = 180
						})
					else
						Utils.Tween(DropdownElement.Button, "Quad", "Out", .25, {
							Rotation = 0
						})
						Utils.Tween(DropdownSelection, "Quad", "Out", .25, {
							Size = UDim2.new(1, -10, 0, 0)
						}).Completed:Wait()
						
						DropdownSelection.Frame.Visible = false
						DropdownSelection.Visible = false
					end
				end

				for _, v in ipairs(Options) do
					local Clone = TextButton:Clone()
					
					Connect(Clone.MouseButton1Click, function()
						DropdownElement.Title.Text = Title .. ": " .. v
						Callback(v)
                        ToggleDropdown()
                    end)
					
					Utils.Click(Clone, "BackgroundColor3")
					Clone.Text = v
					Clone.Parent = DropdownSelection.Container
				end
				
				Connect(Button.MouseButton1Click, ToggleDropdown)
				
				DropdownElement.Title.Text = Title
				DropdownSelection.Visible = false
				DropdownSelection.Frame.Visible = false
				DropdownSelection.Size = UDim2.new(1, -10, 0, 0)
				DropdownElement.Parent = Section.Options
				DropdownSelection.Parent = Section.Options
			end
			
			return ElementLibrary
            
		end
		
		return PageLibrary
	end
    	
	return WindowLibrary
end

return UILibrary