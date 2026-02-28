local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local FILE_NAME = "NoNameHub.json"
local boostEnabled = false
local boostSpeed = 32 -- Optimized for maximum force with zero lag-back

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
frame.Size = UDim2.new(0, 190, 0, 195)
frame.Position = loadPosition()
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Thickness = 1

frame:GetPropertyChangedSignal("Position"):Connect(function()
    if writefile then
        local pos = frame.Position
        local data = {XScale = pos.X.Scale, XOffset = pos.X.Offset, YScale = pos.Y.Scale, YOffset = pos.Y.Offset}
        writefile(FILE_NAME, HttpService:JSONEncode(data))
    end
end)

-- MINIMIZED BOX (NN)
local minBox = Instance.new("TextButton")
minBox.Parent = screenGui
minBox.Visible = false
minBox.Size = UDim2.new(0, 45, 0, 45)
minBox.Position = frame.Position
minBox.BackgroundColor3 = Color3.fromRGB(18,18,18)
minBox.Text = "NN"
minBox.Font = Enum.Font.GothamMedium
minBox.TextSize = 18
minBox.Draggable = true
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 10)
local minStroke = Instance.new("UIStroke", minBox)
minStroke.Thickness = 1

-- MINIMIZE BUTTON
local minBtn = Instance.new("TextButton")
minBtn.Parent = frame
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(1, -30, 0, 5)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamMedium
minBtn.TextSize = 20
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, -40, 0, 22)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "NoName Hub"
title.Font = Enum.Font.GothamMedium
title.TextSize = 12
title.TextColor3 = Color3.fromRGB(240,240,240)
title.TextXAlignment = Enum.TextXAlignment.Left

local function createBtn(name, pos)
    local b = Instance.new("TextButton")
    b.Parent = frame
    b.Size = UDim2.new(0.85, 0, 0, 30)
    b.Position = pos
    b.BackgroundColor3 = Color3.fromRGB(28,28,28)
    b.Text = name
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", b)
    s.Thickness = 1
    return b, s
end

local boostBtn, boostStroke = createBtn("SPEED BOOST: OFF", UDim2.new(0.075, 0, 0.18, 0))
local respawnButton, respawnStroke = createBtn("RESPAWN", UDim2.new(0.075, 0, 0.38, 0))
local rejoinButton, rejoinStroke = createBtn("REJOIN", UDim2.new(0.075, 0, 0.58, 0))
local leaveButton, leaveStroke = createBtn("LEAVE", UDim2.new(0.075, 0, 0.78, 0))

local credit = Instance.new("TextLabel")
credit.Parent = frame
credit.Size = UDim2.new(1, -10, 0, 10)
credit.Position = UDim2.new(0, 0, 1, -12)
credit.BackgroundTransparency = 1
credit.Text = "@MrFuNnYnUtZ on TT"
credit.Font = Enum.Font.GothamMedium
credit.TextSize = 8
credit.TextColor3 = Color3.fromRGB(110,110,110)
credit.TextXAlignment = Enum.TextXAlignment.Right

-- GOD-MODE SPEED METHOD
RunService.PreSimulation:Connect(function(delta)
    local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    frameStroke.Color = color
    minStroke.Color = color
    minBox.TextColor3 = color
    boostStroke.Color = color
    respawnStroke.Color = color
    rejoinStroke.Color = color
    leaveStroke.Color = color

    if boostEnabled then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if root and hum then
            if hum.MoveDirection.Magnitude > 0 then
                -- Force state to Running to prevent "Slowdown" animations
                hum:ChangeState(Enum.HumanoidStateType.Running)
                
                -- The "God" Shove: Move CFrame slightly and match Velocity perfectly
                local vel = hum.MoveDirection * boostSpeed
                root.AssemblyLinearVelocity = Vector3.new(vel.X, root.AssemblyLinearVelocity.Y, vel.Z)
                root.CFrame = root.CFrame + (hum.MoveDirection * (boostSpeed * delta * 0.45))
            else
                -- Stop immediately when keys are released to avoid sliding into lag-back
                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            end
        end
    end
end)

-- TOGGLE LOGIC
boostBtn.MouseButton1Click:Connect(function()
    boostEnabled = not boostEnabled
    boostBtn.Text = "SPEED BOOST: " .. (boostEnabled and "ON" or "OFF")
end)

minBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    minBox.Visible = true
    minBox.Position = frame.Position
end)

minBox.MouseButton1Click:Connect(function()
    minBox.Visible = false
    frame.Visible = true
    frame.Position = minBox.Position
end)

respawnButton.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)

rejoinButton.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, player)
end)

leaveButton.MouseButton1Click:Connect(function()
    player:Kick("Left via NoName Hub")
end)
