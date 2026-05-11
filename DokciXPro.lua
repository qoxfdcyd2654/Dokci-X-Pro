-- ============================================
--   DXP DOKCI X PRO | ULTIMATE v4.1 (FIXED)
--          Author: Dokci
-- ============================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- ========== ЦВЕТА ==========
local Colors = {
	BG = Color3.fromRGB(57, 57, 86),
	BGSecondary = Color3.fromRGB(20, 20, 30),
	BGTertiary = Color3.fromRGB(28, 28, 38),
	Accent = Color3.fromRGB(100, 80, 255),
	AccentGlow = Color3.fromRGB(130, 110, 255),
	Success = Color3.fromRGB(0, 200, 150),
	Danger = Color3.fromRGB(255, 70, 100),
	Text = Color3.fromRGB(230, 230, 250),
	TextDim = Color3.fromRGB(160, 160, 180),
	Border = Color3.fromRGB(137, 137, 206),
}

-- ========== КОНФИГ ==========
local Config = {
	Noclip = false,
	Fly = false,
	FlySpeed = 150,
	Speed = 16,
	JumpPower = 50,
	Invisible = false,
	ESP = false,
	Fullbright = false,
	AntiAFK = false,
	AutoFarm = false,
	Aimbot = false,
	AimbotSmooth = 0.3,
}

-- ========== ВСПОМОГАТЕЛЬНЫЕ ==========
local function GetChar() return LP.Character end
local function GetRoot() return GetChar() and GetChar():FindFirstChild("HumanoidRootPart") end
local function GetHumanoid() return GetChar() and GetChar():FindFirstChildOfClass("Humanoid") end

-- ========== БЛЮР ==========
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0
BlurEffect.Parent = game:GetService("Lighting")

-- ========== ФУНКЦИОНАЛ ==========
local NoclipConn, FlyConn, FlyBV, FlyBG = nil, nil, nil, nil
local ESPFolder = nil
local SavedLighting = {}

local function ToggleNoclip(state)
	Config.Noclip = state
	if NoclipConn then NoclipConn:Disconnect() end
	if state then
		NoclipConn = RunService.Heartbeat:Connect(function()
			if GetChar() then
				for _, v in pairs(GetChar():GetDescendants()) do
					if v:IsA("BasePart") then v.CanCollide = false end
				end
			end
		end)
	elseif GetChar() then
		for _, v in pairs(GetChar():GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = true end
		end
	end
end

local function ToggleFly(state)
	Config.Fly = state
	local root = GetRoot()
	if not root then return end
	if state then
		FlyBG = Instance.new("BodyGyro")
		FlyBG.P, FlyBG.D = 1000, 100
		FlyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		FlyBG.Parent = root
		FlyBV = Instance.new("BodyVelocity")
		FlyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		FlyBV.Parent = root
		if FlyConn then FlyConn:Disconnect() end
		FlyConn = RunService.Heartbeat:Connect(function()
			if not Config.Fly then return end
			local cam = Workspace.CurrentCamera
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end
			if move.Magnitude > 0 then move = move.Unit * Config.FlySpeed end
			FlyBV.Velocity = move
			FlyBG.CFrame = cam.CFrame
		end)
	else
		if FlyConn then FlyConn:Disconnect() end
		if FlyBG then FlyBG:Destroy() end
		if FlyBV then FlyBV:Destroy() end
	end
end

local function ToggleInvisible(state)
	Config.Invisible = state
	local char = GetChar()
	if not char then return end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = state and 1 or 0
		end
	end
end

local function ToggleESP(state)
	Config.ESP = state
	if ESPFolder then ESPFolder:Destroy() end
	if not state then return end
	ESPFolder = Instance.new("Folder")
	ESPFolder.Name = "DXP_ESP"
	ESPFolder.Parent = CoreGui
	local function add(plr)
		if plr == LP then return end
		local hl = Instance.new("Highlight")
		hl.FillColor = Colors.Accent
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.FillTransparency = 0.6
		hl.Adornee = plr.Character
		hl.Parent = ESPFolder
		plr.CharacterAdded:Connect(function(c) hl.Adornee = c end)
	end
	for _, plr in pairs(Players:GetPlayers()) do add(plr) end
	Players.PlayerAdded:Connect(add)
end

local function ToggleFullbright(state)
	Config.Fullbright = state
	if state then
		SavedLighting.Brightness = Lighting.Brightness
		SavedLighting.Ambient = Lighting.Ambient
		Lighting.Brightness = 10
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = SavedLighting.Brightness or 2
		Lighting.Ambient = SavedLighting.Ambient or Color3.fromRGB(127, 127, 127)
		Lighting.GlobalShadows = true
	end
end

local function UpdateMovement()
	local hum = GetHumanoid()
	if hum then
		hum.WalkSpeed = Config.Speed
		hum.JumpPower = Config.JumpPower
	end
end

LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	if Config.Noclip then ToggleNoclip(true) end
	if Config.Fly then ToggleFly(true) end
	if Config.Invisible then ToggleInvisible(true) end
	UpdateMovement()
end)

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DXP_Pro_" .. math.random(1000000, 9999999)
RunService.Heartbeat:Connect(function()
	ScreenGui.Name = "DXP_Pro_" .. math.random(1000000, 9999999)
end)
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 820, 0, 520)
MainFrame.Position = UDim2.new(0.5, -410, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(161, 170, 255)),
	ColorSequenceKeypoint.new(1, Colors.BG),
})
MainGradient.Parent = MainFrame

local BlurFrame = Instance.new("Frame")
BlurFrame.Parent = MainFrame
BlurFrame.Size = UDim2.new(1, 0, 1, 0)
BlurFrame.BackgroundColor3 = Colors.BG
BlurFrame.BackgroundTransparency = 0.35
BlurFrame.BorderSizePixel = 0

local BlurFrameCorner = Instance.new("UICorner")
BlurFrameCorner.CornerRadius = UDim.new(0, 23)
BlurFrameCorner.Parent = BlurFrame

local BorderStroke = Instance.new("UIStroke")
BorderStroke.Thickness = 1.5
BorderStroke.Color = Colors.Border
BorderStroke.Transparency = 0.01
BorderStroke.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 23)
MainCorner.Parent = MainFrame

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = Colors.BGSecondary
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Text = "DXP DOKCI X PRO  •  ULTIMATE"
Title.TextColor3 = Colors.Text
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local Subtitle = Instance.new("TextLabel")
Subtitle.Parent = TopBar
Subtitle.Size = UDim2.new(0.5, 0, 1, 0)
Subtitle.Position = UDim2.new(0, 20, 0, 17)
Subtitle.Text = "by Dokci  •  v4.1  •  cyber edition •  2026"
Subtitle.TextColor3 = Colors.TextDim
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.Position = UDim2.new(1, -48, 0, 8)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.Text
CloseBtn.BackgroundColor3 = Colors.Danger
CloseBtn.BackgroundTransparency = 0.2
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- TOGGLE BUTTON
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.Text = "⚡"
ToggleBtn.TextColor3 = Colors.Text
ToggleBtn.TextSize = 28
ToggleBtn.BackgroundColor3 = Colors.Accent
ToggleBtn.BackgroundTransparency = 0.15
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Colors.AccentGlow
ToggleStroke.Thickness = 1.5
ToggleStroke.Parent = ToggleBtn

local menuOpen = false
local function AnimateMenu(open)
	menuOpen = open
	if open then
		MainFrame.Visible = true
		local t1 = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
			{Position = UDim2.new(0.5, -410, 0.5, -260)})
		local t2 = TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 22})
		t1:Play()
		t2:Play()
	else
		local t1 = TweenService:Create(MainFrame, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
			{Position = UDim2.new(0.5, -410, 0.5, 1000)})
		local t2 = TweenService:Create(BlurEffect, TweenInfo.new(0.78), {Size = 0})
		t1:Play()
		t2:Play()
		t1.Completed:Wait()
		MainFrame.Visible = false
	end
end

ToggleBtn.MouseButton1Click:Connect(function()
	AnimateMenu(not menuOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
	AnimateMenu(false)
end)

-- ========== ПЛАВНОЕ ПЕРЕТАСКИВАНИЕ ==========
local dragConn = nil
local dragStartMouse = Vector2.new()
local dragStartPos = UDim2.new()

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mousePos = input.Position
		dragStartMouse = Vector2.new(mousePos.X, mousePos.Y)
		dragStartPos = MainFrame.Position

		if dragConn then dragConn:Disconnect() end
		dragConn = RunService.RenderStepped:Connect(function()
			local mouseLoc = UserInputService:GetMouseLocation()
			local delta = mouseLoc - dragStartMouse
			local tween = TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
				{ Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, 
					dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y) })
			tween:Play()
		end)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if dragConn then 
			dragConn:Disconnect()
			dragConn = nil
		end
	end
end)

-- ========== ЛЕВАЯ ПАНЕЛЬ ==========
local TabPanel = Instance.new("Frame")
TabPanel.Parent = MainFrame
TabPanel.Size = UDim2.new(0, 180, 1, -52)
TabPanel.Position = UDim2.new(0, 0, 0, 52)
TabPanel.BackgroundTransparency = 1
TabPanel.ClipsDescendants = true

local InnerFrame = Instance.new("Frame")
InnerFrame.Name = "RoundingFrame"
InnerFrame.Parent = TabPanel
InnerFrame.Size = UDim2.new(2, 0, 2, 0) 
InnerFrame.Position = UDim2.new(0, 0, -1, 0) 
InnerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InnerFrame.BackgroundTransparency = 0.2
InnerFrame.BorderSizePixel = 0

local UICornerInner = Instance.new("UICorner")
UICornerInner.CornerRadius = UDim.new(0, 23)
UICornerInner.Parent = InnerFrame

local TabsPanelGradient = Instance.new("UIGradient")
TabsPanelGradient.Parent = InnerFrame
TabsPanelGradient.Rotation = 280
TabsPanelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(104, 110, 165)),
	ColorSequenceKeypoint.new(1, Colors.BG),
})

local TabList = Instance.new("ScrollingFrame")
TabList.Parent = TabPanel
TabList.Size = UDim2.new(1, -10, 1, -20)
TabList.Position = UDim2.new(0, 5, 0, 10)
TabList.BackgroundTransparency = 1
TabList.BorderSizePixel = 0
TabList.ScrollBarThickness = 3
TabList.ScrollBarImageColor3 = Colors.Accent

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabList
TabLayout.Padding = UDim.new(0, 8)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ========== ПРАВАЯ ПАНЕЛЬ ==========
local ContentPanel = Instance.new("Frame")
ContentPanel.Parent = MainFrame
ContentPanel.Size = UDim2.new(1, -190, 1, -62)
ContentPanel.Position = UDim2.new(0, 190, 0, 56)
ContentPanel.BackgroundTransparency = 1

local ContentScroller = Instance.new("ScrollingFrame")
ContentScroller.Parent = ContentPanel
ContentScroller.Size = UDim2.new(1, -10, 1, 0)
ContentScroller.BackgroundTransparency = 1
ContentScroller.BorderSizePixel = 0
ContentScroller.ScrollBarThickness = 4
ContentScroller.ScrollBarImageColor3 = Colors.Accent
ContentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = ContentScroller
ContentLayout.Padding = UDim.new(0, 12)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ========== СИСТЕМА ТАБОВ ==========
local tabs = {}
local function RefreshCanvas()
	task.defer(function()
		ContentScroller.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
	end)
end

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(RefreshCanvas)

local function CreateTab(name, icon)
	local btn = Instance.new("TextButton")
	btn.Parent = TabList
	btn.Size = UDim2.new(1, -10, 0, 48)
	btn.Text = "  " .. icon .. "  " .. name
	btn.TextColor3 = Colors.TextDim
	btn.BackgroundColor3 = Colors.BGTertiary
	btn.BackgroundTransparency = 0.4
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = btn

	-- КОНТЕНТ С АВТО-ВЫСОТОЙ
	local content = Instance.new("ScrollingFrame")
	content.Parent = ContentScroller
	content.Size = UDim2.new(1, 0, 0, 0)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 0
	content.Visible = false
	content.AutomaticSize = Enum.AutomaticSize.Y

	local contentInner = Instance.new("UIListLayout")
	contentInner.Parent = content
	contentInner.Padding = UDim.new(0, 12)
	contentInner.SortOrder = Enum.SortOrder.LayoutOrder

	btn.MouseButton1Click:Connect(function()
		for _, t in pairs(tabs) do
			t.content.Visible = false
			t.btn.BackgroundColor3 = Colors.BGTertiary
			t.btn.BackgroundTransparency = 0.4
			t.btn.TextColor3 = Colors.TextDim
		end
		content.Visible = true
		btn.BackgroundColor3 = Colors.Accent
		btn.BackgroundTransparency = 0.2
		btn.TextColor3 = Colors.Text
		
		-- Принудительно обновляем CanvasSize
		task.wait(0.05)
		ContentScroller.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
	end)

	table.insert(tabs, {btn = btn, content = content, layout = contentInner})
	return content, contentInner
end

-- ========== КОМПОНЕНТЫ UI ==========
local function AddToggle(parent, layout, text, callback)
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(1, 0, 0, 46)
	frame.BackgroundColor3 = Colors.BGSecondary
	frame.BackgroundTransparency = 0.3
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Parent = frame
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 16, 0, 0)
	label.Text = text
	label.TextColor3 = Colors.Text
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1

	local switchBg = Instance.new("Frame")
	switchBg.Parent = frame
	switchBg.Size = UDim2.new(0, 56, 0, 24)
	switchBg.Position = UDim2.new(1, -72, 0, 11)
	switchBg.BackgroundColor3 = Colors.Danger
	switchBg.BorderSizePixel = 0
	local switchBgCorner = Instance.new("UICorner")
	switchBgCorner.CornerRadius = UDim.new(1, 0)
	switchBgCorner.Parent = switchBg

	local switchThumb = Instance.new("TextButton")
	switchThumb.Parent = switchBg
	switchThumb.Size = UDim2.new(0, 20, 0, 20)
	switchThumb.Position = UDim2.new(0, 2, 0, 2)
	switchThumb.Text = ""
	switchThumb.BackgroundColor3 = Colors.Text
	switchThumb.BorderSizePixel = 0
	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(1, 0)
	thumbCorner.Parent = switchThumb

	local state = false
	
	local function UpdateSwitch(animated)
		local targetPos = state and 34 or 2
		local targetColor = state and Colors.Accent or Colors.Danger
		
		if animated then
			local thumbTween = TweenService:Create(switchThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, targetPos, 0, 2)
			})
			local bgTween = TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetColor
			})
			thumbTween:Play()
			bgTween:Play()
		else
			switchThumb.Position = UDim2.new(0, targetPos, 0, 2)
			switchBg.BackgroundColor3 = targetColor
		end
	end

	switchThumb.MouseButton1Click:Connect(function()
		state = not state
		UpdateSwitch(true)
		callback(state)
	end)
	
switchBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		state = not state
		UpdateSwitch(true)
		callback(state)
	end
end)

	callback(false)
	task.wait(0.05)
	RefreshCanvas()  -- 👈 КЛЮЧЕВОЕ
	return frame
end

local function AddButton(parent, layout, text, callback)
	local btn = Instance.new("TextButton")
	btn.Parent = parent
	btn.Size = UDim2.new(1, 0, 0, 48)
	btn.Text = text
	btn.TextColor3 = Colors.Text
	btn.BackgroundColor3 = Colors.Accent
	btn.BackgroundTransparency = 0.15
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 14
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 12)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		local anim = TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.5})
		anim:Play()
		anim.Completed:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency = 0.15}):Play()
		end)
		callback()
	end)

	return btn
end

local function AddSlider(parent, layout, text, min, max, default, callback)
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(1, 0, 0, 68)
	frame.BackgroundColor3 = Colors.BGSecondary
	frame.BackgroundTransparency = 0.3
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Parent = frame
	label.Size = UDim2.new(1, -20, 0, 24)
	label.Position = UDim2.new(0, 12, 0, 8)
	label.Text = text .. " : " .. tostring(default)
	label.TextColor3 = Colors.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1

	local sliderBg = Instance.new("Frame")
	sliderBg.Parent = frame
	sliderBg.Size = UDim2.new(1, -24, 0, 12)
	sliderBg.Position = UDim2.new(0, 12, 0, 40)
	sliderBg.BackgroundColor3 = Colors.BGTertiary
	local sliderCorner = Instance.new("UICorner")
	sliderCorner.CornerRadius = UDim.new(1, 0)
	sliderCorner.Parent = sliderBg

	local fill = Instance.new("Frame")
	fill.Parent = sliderBg
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Colors.Accent
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill

	local dragging = false
	
	local function UpdateFromMouse(mouseX)
		local relativeX = math.clamp(mouseX - sliderBg.AbsolutePosition.X, 0, sliderBg.AbsoluteSize.X)
		local percent = relativeX / sliderBg.AbsoluteSize.X
		local val = min + percent * (max - min)
		val = math.floor(val * 10) / 10
		
		fill.Size = UDim2.new(percent, 0, 1, 0)
		label.Text = text .. " : " .. tostring(val)
		callback(val)
	end
	
	local function UpdateFromPercent(percent)
		local val = min + percent * (max - min)
		val = math.floor(val * 10) / 10
		fill.Size = UDim2.new(percent, 0, 1, 0)
		label.Text = text .. " : " .. tostring(val)
		callback(val)
	end

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			UpdateFromMouse(input.Position.X)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateFromMouse(input.Position.X)
		end
	end)

	UpdateFromPercent((default - min) / (max - min))
	task.wait(0.05)
	RefreshCanvas()  -- 👈 КЛЮЧЕВОЕ
	return frame
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.Q then
		AnimateMenu(not menuOpen)
	end
end)

-- ========== ДИНАМИЧЕСКИЕ ФУНКЦИИ ==========
local function LoadPlayersForTp(Tab, Layout)
	local TpButts = {}

	local function DeleteAllTps()
		for _, TpButton in pairs(TpButts) do
			TpButton:Destroy()
		end
		table.clear(TpButts)
	end

	local function UpdateTps(player)
		local TPButt = AddButton(Tab, Layout, "TP To " .. player.Name, function()
			local MyChar = GetChar()
			if MyChar and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				MyChar:MoveTo(player.Character.HumanoidRootPart.Position)
			end
		end)
		table.insert(TpButts, TPButt)
	end

	local function RefreshAll()
		DeleteAllTps()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LP then
				UpdateTps(player)
			end
		end
		RefreshCanvas()
	end

	RefreshAll()
	Players.PlayerAdded:Connect(RefreshAll)
	Players.PlayerRemoving:Connect(RefreshAll)
end

local function LoadPlayersForSpectate(Tab, Layout)
	local SpectateButts = {}
	 
	local function DeleteAllSpectates()
		for _, SpectateButton in pairs(SpectateButts) do
			SpectateButton:Destroy()
		end
		table.clear(SpectateButts)
	end
	 
	local function UpdateSpectates(player)
		local SpectateButt = AddButton(Tab, Layout, "Spectate " .. player.Name, function()
			local Camera = Workspace.CurrentCamera
			Camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		end)
		table.insert(SpectateButts, SpectateButt)
	end
	 
	local function RefreshAll()
		DeleteAllSpectates()
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LP then
				UpdateSpectates(player)
			end
		end
		RefreshCanvas()
	end

	RefreshAll()
	Players.PlayerAdded:Connect(RefreshAll)
	Players.PlayerRemoving:Connect(RefreshAll)
end

-- ========== СОЗДАЁМ ТАБЫ ==========
local home, homeLayout = CreateTab("HOME", "🏠")
local combat, combatLayout = CreateTab("COMBAT", "⚔️")
local move, moveLayout = CreateTab("MOVEMENT", "🚀")
local visuals, visualsLayout = CreateTab("VISUALS", "👁️")
local tpToPlayers, tpToPlayersLayout = CreateTab("TP TO PLAYERS", "👥")
local Spectate, SpectateLayout = CreateTab("SPECTATE", "👀")
local utils, utilsLayout = CreateTab("UTILS", "🔧")

LoadPlayersForTp(tpToPlayers, tpToPlayersLayout)
LoadPlayersForSpectate(Spectate, SpectateLayout)

AddToggle(home, homeLayout, "Anti AFK", function(s) Config.AntiAFK = s end)
AddToggle(home, homeLayout, "Auto Farm", function(s) Config.AutoFarm = s end)
AddButton(home, homeLayout, "Kill All Players", function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.Health = 0 end
		end
	end
end)

AddToggle(combat, combatLayout, "Aimbot", function(s) Config.Aimbot = s end)
AddSlider(combat, combatLayout, "Smoothness", 0.1, 1, 0.3, function(v) Config.AimbotSmooth = v end)

AddToggle(move, moveLayout, "Noclip", ToggleNoclip)
AddToggle(move, moveLayout, "Fly", ToggleFly)
AddSlider(move, moveLayout, "Fly Speed", 50, 500, 150, function(v) Config.FlySpeed = v end)
AddSlider(move, moveLayout, "Walk Speed", 16, 300, 16, function(v) Config.Speed = v UpdateMovement() end)
AddSlider(move, moveLayout, "Jump Power", 50, 300, 50, function(v) Config.JumpPower = v UpdateMovement() end)

AddToggle(visuals, visualsLayout, "ESP", ToggleESP)
AddToggle(visuals, visualsLayout, "Invisible", ToggleInvisible)
AddToggle(visuals, visualsLayout, "Fullbright", ToggleFullbright)

AddButton(utils, utilsLayout, "Rejoin (Teleport)", function()
	game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- Активируем первую вкладку
if tabs[1] then
	tabs[1].content.Visible = true
	tabs[1].btn.BackgroundColor3 = Colors.Accent
	tabs[1].btn.BackgroundTransparency = 0.2
	tabs[1].btn.TextColor3 = Colors.Text
end

print("========================================")
print("💀 DXP DOKCI X PRO v4.1 ЗАГРУЖЕН 💀")
print("🔥 Кнопка ⚡ в левом верхнем углу — открыть меню")
print("✅ Все ошибки исправлены!")
print("========================================")
