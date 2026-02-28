local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local FILE_NAME = "NoNameHub_Elite.json"
local config = {
    pos = {0.5, -95, 0.5, -60},
    boostEnabled = false,
    infJumpEnabled = false,
    espEnabled = false,
    antiRagdoll = false,
    antiKB = false,
    speed = 32,
    minimized = false,
    sliderLocked = false
}

-- LOAD/SAVE
local function loadSettings()
    if isfile and isfile(FILE_NAME) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
        if success then for k,v in pairs(decoded) do config[k] = v end end
    end
end
loadSettings()
local function saveSettings() if writefile then writefile(FILE_NAME, HttpService:JSONEncode(config)) end end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "NoNameHub"; screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 190, 0, 290) 
frame.Position = UDim2.new(config.pos[1], config.pos[2], config.pos[3], config.pos[4])
frame.BackgroundColor3 = Color3.fromRGB(12,12,12); frame.BorderSizePixel = 0; frame.Active = true; frame.Draggable = true; frame.Visible = not config.minimized
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", frame); frameStroke.Thickness = 1.5

-- SCROLLING CONTAINER
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1, 0, 1, -50); scroll.Position = UDim2.new(0, 0, 0, 30)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0, 0, 0, 520) 

local layout = Instance.new("UIListLayout", scroll)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Padding = UDim.new(0, 8); layout.SortOrder = Enum.SortOrder.LayoutOrder

-- TITLE & CREDIT
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 22); title.Position = UDim2.new(0, 10, 0, 5); title.BackgroundTransparency = 1; title.Text = "NoName Hub"; title.Font = Enum.Font.GothamMedium; title.TextSize = 12; title.TextColor3 = Color3.new(1,1,1); title.TextXAlignment = Enum.TextXAlignment.Left

local function createUtil(name)
    local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(0.85, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(28,28,28); b.Text = name; b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.TextColor3 = Color3.new(1,1,1)
    local s = Instance.new("UIStroke", b); s.Thickness = 1.2; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); return b, s
end

local function createToggle(prop, text)
    local btn, str = createUtil(text .. ": " .. (config[prop] and "ON" or "OFF"))
    btn.MouseButton1Click:Connect(function()
        config[prop] = not config[prop]
        btn.Text = text .. ": " .. (config[prop] and "ON" or "OFF")
        saveSettings()
    end)
    return btn, str
end

local bBtn, bStr = createToggle("boostEnabled", "SPEED BOOST")

-- SLIDER (Max 50)
local sliderFrame = Instance.new("Frame", scroll); sliderFrame.Size = UDim2.new(0.85, 0, 0, 10); sliderFrame.BackgroundColor3 = Color3.fromRGB(45,45,45); sliderFrame.BorderSizePixel = 0; Instance.new("UICorner", sliderFrame)
local sliderFill = Instance.new("Frame", sliderFrame); sliderFill.Size = UDim2.new(((config.speed-16)/34), 0, 1, 0); sliderFill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", sliderFill)
local knob = Instance.new("Frame", sliderFrame); knob.Size = UDim2.new(0, 18, 0, 18); knob.Position = UDim2.new(((config.speed-16)/34), -9, 0.5, -9); knob.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
local speedValueLabel = Instance.new("TextLabel", scroll); speedValueLabel.Size = UDim2.new(0.85, 0, 0, 15); speedValueLabel.BackgroundTransparency = 1; speedValueLabel.Text = "Speed: "..config.speed.." (Safe: <32)"; speedValueLabel.Font = Enum.Font.GothamMedium; speedValueLabel.TextSize = 9; speedValueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)

local sBtn, sStr = createToggle("infJumpEnabled", "INF JUMP")

-- CORE MOVEMENT LOGIC
local jumpBV = Instance.new("BodyVelocity")
jumpBV.MaxForce = Vector3.new(0, 0, 0) -- Hidden until needed

RunService.Stepped:Connect(function()
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if root and hum then
        -- Speed: Constant velocity push for sharp turns
        if config.boostEnabled and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = (hum.MoveDirection * config.speed) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
        
        -- Inf Jump Logic: Apply force directly to root
        if config.infJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            jumpBV.Parent = root
            jumpBV.MaxForce = Vector3.new(0, 50000, 0)
            jumpBV.Velocity = Vector3.new(0, 50, 0)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        else
            jumpBV.MaxForce = Vector3.new(0, 0, 0)
        end
    end
end)

-- SLIDER LOGIC
local isSliding = false
local function updateSlider(input)
    local p = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
    config.speed = math.floor(16 + (p * 34)) -- 16 + 34 = 50
    speedValueLabel.Text = "Speed: " .. tostring(config.speed) .. (config.speed < 32 and " (Safe: <32)" or " (Lags >32)")
    sliderFill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -9, 0.5, -9)
end
sliderFrame.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then isSliding = true; updateSlider(i) end end)
UserInputService.InputChanged:Connect(function(i) if isSliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isSliding = false; saveSettings() end end)

-- MINIMIZE LOGIC (Same as your original)
local minBox = Instance.new("TextButton", screenGui)
minBox.Visible = config.minimized; minBox.Size = UDim2.new(0, 60, 0, 60); minBox.Position = frame.Position; minBox.BackgroundColor3 = Color3.fromRGB(12,12,12); minBox.Text = "NN"; minBox.Font = Enum.Font.GothamBold; minBox.TextColor3 = Color3.new(1,1,1); minBox.TextSize = 22; minBox.Draggable = true; Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 15)
local minStroke = Instance.new("UIStroke", minBox); minStroke.Thickness = 1.5

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 25, 0, 25); minBtn.Position = UDim2.new(1, -30, 0, 5); minBtn.BackgroundTransparency = 1; minBtn.Text = "-"; minBtn.Font = Enum.Font.GothamMedium; minBtn.TextSize = 20; minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.MouseButton1Click:Connect(function() config.minimized = true; frame.Visible = false; minBox.Visible = true; minBox.Position = frame.Position; saveSettings() end)
minBox.MouseButton1Click:Connect(function() config.minimized = false; frame.Visible = true; minBox.Visible = false; frame.Position = minBox.Position; saveSettings() end)

-- Visual Rainbow Sync
RunService.RenderStepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    frameStroke.Color = color; minStroke.Color = color; knob.BackgroundColor3 = color; sliderFill.BackgroundColor3 = color
end)
