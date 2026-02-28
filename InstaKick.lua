local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local FILE_NAME = "NoNameHub.json"
local boostEnabled = false
local infJumpEnabled = false
local boostSpeed = 32 

local function loadPosition()
    if readfile and isfile and isfile(FILE_NAME) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(FILE_NAME))
        end)
        if success and decoded then
            return UDim2.new(decoded.XScale, decoded.XOffset, decoded.YScale, decoded.YOffset)
        end
    end
    return UDim2.new(0.5, -95, 0.5, -60)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoNameHub"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 190, 0, 260) 
frame.Position = loadPosition()
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Thickness = 1

-- UI HEADER
local title = Instance.new("TextLabel")
title.Parent = frame; title.Size = UDim2.new(1, -40, 0, 22); title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1; title.Text = "NoName Hub"; title.Font = Enum.Font.GothamMedium; title.TextSize = 12; title.TextColor3 = Color3.fromRGB(240,240,240); title.TextXAlignment = Enum.TextXAlignment.Left

-- 1. SPEED BOOST TOGGLE
local boostBtn = Instance.new("TextButton")
boostBtn.Parent = frame; boostBtn.Size = UDim2.new(0.85, 0, 0, 28); boostBtn.Position = UDim2.new(0.075, 0, 0.12, 0)
boostBtn.BackgroundColor3 = Color3.fromRGB(28,28,28); boostBtn.Text = "SPEED BOOST: OFF"; boostBtn.Font = Enum.Font.GothamMedium; boostBtn.TextSize = 10; boostBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", boostBtn).CornerRadius = UDim.new(0, 8); local boostStroke = Instance.new("UIStroke", boostBtn)

-- 2. SLIDER (Now strictly between Speed and Inf Jump)
local sliderFrame = Instance.new("TextButton") -- Using TextButton for better hit detection
sliderFrame.Name = "SliderFrame"
sliderFrame.Parent = frame; sliderFrame.Size = UDim2.new(0.85, 0, 0, 6); sliderFrame.Position = UDim2.new(0.075, 0, 0.28, 0)
sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45); sliderFrame.Text = ""; sliderFrame.AutoButtonColor = false
Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame"); sliderFill.Parent = sliderFrame; sliderFill.Size = UDim2.new(0.4, 0, 1, 0); sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255); sliderFill.BorderSizePixel = 0; Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)
local knob = Instance.new("Frame"); knob.Parent = sliderFrame; knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = UDim2.new(0.4, -6, 0.5, -6); knob.BackgroundColor3 = Color3.fromRGB(255,255,255); Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

local speedValueLabel = Instance.new("TextLabel")
speedValueLabel.Parent = frame; speedValueLabel.Size = UDim2.new(0.85, 0, 0, 15); speedValueLabel.Position = UDim2.new(0.075, 0, 0.31, 0)
speedValueLabel.BackgroundTransparency = 1; speedValueLabel.Text = "Speed: 32"; speedValueLabel.Font = Enum.Font.GothamMedium; speedValueLabel.TextSize = 9; speedValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

-- 3. INF JUMP TOGGLE
local jumpBtn = Instance.new("TextButton")
jumpBtn.Parent = frame; jumpBtn.Size = UDim2.new(0.85, 0, 0, 28); jumpBtn.Position = UDim2.new(0.075, 0, 0.42, 0)
jumpBtn.BackgroundColor3 = Color3.fromRGB(28,28,28); jumpBtn.Text = "INF JUMP: OFF"; jumpBtn.Font = Enum.Font.GothamMedium; jumpBtn.TextSize = 10; jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(0, 8); local jumpStroke = Instance.new("UIStroke", jumpBtn)

-- UTILITIES
local function createBtn(name, pos)
    local b = Instance.new("TextButton"); b.Parent = frame; b.Size = UDim2.new(0.85, 0, 0, 22); b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(28,28,28); b.Text = name; b.Font = Enum.Font.GothamMedium; b.TextSize = 9; b.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); return b, Instance.new("UIStroke", b)
end
local respawnButton, respawnStroke = createBtn("RESPAWN", UDim2.new(0.075, 0, 0.58, 0))
local rejoinButton, rejoinStroke = createBtn("REJOIN", UDim2.new(0.075, 0, 0.71, 0))
local leaveButton, leaveStroke = createBtn("LEAVE", UDim2.new(0.075, 0, 0.84, 0))

-- REWRITTEN SLIDER LOGIC
local dragging = false
local function updateSlider()
    local mousePos = UserInputService:GetMouseLocation().X
    local sliderAbsPos = sliderFrame.AbsolutePosition.X
    local sliderAbsSize = sliderFrame.AbsoluteSize.X
    local percentage = math.clamp((mousePos - sliderAbsPos) / sliderAbsSize, 0, 1)
    
    knob.Position = UDim2.new(percentage, -6, 0.5, -6)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    boostSpeed = math.floor(16 + (percentage * 34))
    speedValueLabel.Text = "Speed: " .. tostring(boostSpeed)
end

sliderFrame.MouseButton1Down:Connect(function() dragging = true end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

RunService.RenderStepped:Connect(function()
    if dragging then updateSlider() end
    
    -- Rainbow sync
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    frameStroke.Color = color; knob.BackgroundColor3 = color; sliderFill.BackgroundColor3 = color
    boostStroke.Color = color; jumpStroke.Color = color; respawnStroke.Color = color; rejoinStroke.Color = color; leaveStroke.Color = color
end)

-- SMOOTH SPEED PHYSICS
RunService.Stepped:Connect(function()
    if boostEnabled then
        local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            local targetVel = Vector3.new(hum.MoveDirection.X * boostSpeed, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * boostSpeed)
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(targetVel, 0.6)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

-- STEALTH INF JUMP (NO STATE CHANGE)
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            -- A gentle "Nudge" instead of a hard jump force to prevent respawn
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 45, root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- BUTTONS
boostBtn.MouseButton1Click:Connect(function() boostEnabled = not boostEnabled; boostBtn.Text = "SPEED BOOST: " .. (boostEnabled and "ON" or "OFF") end)
jumpBtn.MouseButton1Click:Connect(function() infJumpEnabled = not infJumpEnabled; jumpBtn.Text = "INF JUMP: " .. (infJumpEnabled and "ON" or "OFF") end)
respawnButton.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.Health = 0 end end)
rejoinButton.MouseButton1Click:Connect(function() TeleportService:Teleport(game.PlaceId, player) end)
leaveButton.MouseButton1Click:Connect(function() player:Kick("Left via NoName Hub") end)
