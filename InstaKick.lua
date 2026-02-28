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

-- BIG NN BUTTON
local minBox = Instance.new("TextButton", screenGui)
minBox.Visible = config.minimized; minBox.Size = UDim2.new(0, 60, 0, 60); minBox.Position = frame.Position; minBox.BackgroundColor3 = Color3.fromRGB(12,12,12); minBox.Text = "NN"; minBox.Font = Enum.Font.GothamBold; minBox.TextColor3 = Color3.new(1,1,1); minBox.TextSize = 22; minBox.Draggable = true; Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 15)
local minStroke = Instance.new("UIStroke", minBox); minStroke.Thickness = 1.5
local cTime = 0
minBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then cTime = tick() end end)
minBox.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and tick() - cTime < 0.25 then config.minimized = false; frame.Visible = true; minBox.Visible = false; frame.Position = minBox.Position; saveSettings() end end)

-- TITLE & CREDIT
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 22); title.Position = UDim2.new(0, 10, 0, 5); title.BackgroundTransparency = 1; title.Text = "NoName Hub"; title.Font = Enum.Font.GothamMedium; title.TextSize = 12; title.TextColor3 = Color3.new(1,1,1); title.TextXAlignment = Enum.TextXAlignment.Left

local credits = Instance.new("TextLabel", frame)
credits.Size = UDim2.new(1, 0, 0, 15); credits.Position = UDim2.new(0, 0, 1, -18); credits.BackgroundTransparency = 1; credits.Text = "MrFuNnYnUtZ on TT"; credits.Font = Enum.Font.GothamMedium; credits.TextSize = 9; credits.TextColor3 = Color3.fromRGB(180,180,180)

-- UI HELPERS
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

-- BUTTONS
local resB, resS = createUtil("RESPAWN")
local rejB, rejS = createUtil("REJOIN")
local leaB, leaS = createUtil("LEAVE")
local bBtn, bStr = createToggle("boostEnabled", "SPEED BOOST")
local lockBtn, lockStr = createUtil(config.sliderLocked and "UNLOCK SLIDER" or "LOCK SLIDER")
lockBtn.Size = UDim2.new(0.85, 0, 0, 25)

-- SLIDER (Locked back to 32 max for safety)
local sliderFrame = Instance.new("Frame", scroll); sliderFrame.Size = UDim2.new(0.85, 0, 0, 10); sliderFrame.BackgroundColor3 = Color3.fromRGB(45,45,45); sliderFrame.BorderSizePixel = 0; Instance.new("UICorner", sliderFrame)
local sliderFill = Instance.new("Frame", sliderFrame); sliderFill.Size = UDim2.new(((config.speed-16)/16), 0, 1, 0); sliderFill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", sliderFill)
local knob = Instance.new("Frame", sliderFrame); knob.Size = UDim2.new(0, 18, 0, 18); knob.Position = UDim2.new(((config.speed-16)/16), -9, 0.5, -9); knob.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
local speedValueLabel = Instance.new("TextLabel", scroll); speedValueLabel.Size = UDim2.new(0.85, 0, 0, 15); speedValueLabel.BackgroundTransparency = 1; speedValueLabel.Text = "Speed: "..config.speed.." (Safe: <32)"; speedValueLabel.Font = Enum.Font.GothamMedium; speedValueLabel.TextSize = 9; speedValueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)

lockBtn.MouseButton1Click:Connect(function()
    config.sliderLocked = not config.sliderLocked
    lockBtn.Text = config.sliderLocked and "UNLOCK SLIDER" or "LOCK SLIDER"
    saveSettings()
end)

local sBtn, sStr = createToggle("infJumpEnabled", "INF JUMP")
local eBtn, eStr = createToggle("espEnabled", "PLAYER ESP")
local rBtn, rStr = createToggle("antiRagdoll", "ANTI RAGDOLL")
local kBtn, kStr = createToggle("antiKB", "ANTI KNOCKBACK")

-- CORE LOOP
RunService.Stepped:Connect(function()
    local color = config.sliderLocked and Color3.fromRGB(255, 50, 50) or Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    frameStroke.Color = color; minStroke.Color = color; knob.BackgroundColor3 = color; sliderFill.BackgroundColor3 = color
    resS.Color = color; rejS.Color = color; leaS.Color = color; bStr.Color = color; lockStr.Color = color; sStr.Color = color; eStr.Color = color; rStr.Color = color; kStr.Color = color

    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and root then
        if config.boostEnabled and hum.MoveDirection.Magnitude > 0 then
            -- Steady Vector: Prevents directional lag-back during turns
            local moveVel = hum.MoveDirection * config.speed
            root.AssemblyLinearVelocity = Vector3.new(moveVel.X, root.AssemblyLinearVelocity.Y, moveVel.Z)
        end
        if config.antiRagdoll then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false); hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end
        if config.antiKB and not config.boostEnabled and not config.infJumpEnabled then 
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) 
        end
    end
end)

-- INF JUMP (RELATIVE CFRAME - NO HEIGHT CAP)
UserInputService.JumpRequest:Connect(function()
    if config.infJumpEnabled and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then 
            -- Moves you up 6 studs from where you currently are, every time.
            root.CFrame = root.CFrame * CFrame.new(0, 6, 0)
        end
    end
end)

-- SLIDER LOGIC
local isSliding = false
local function updateSlider(input)
    if config.sliderLocked then return end
    local p = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
    config.speed = math.floor(16 + (p * 16)) -- Maxes at 32
    speedValueLabel.Text = "Speed: " .. tostring(config.speed) .. " (Safe: <32)"
    sliderFill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -9, 0.5, -9)
end
sliderFrame.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and not config.sliderLocked then isSliding = true; updateSlider(i) end end)
UserInputService.InputChanged:Connect(function(i) if isSliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isSliding = false; saveSettings() end end)

-- ESP & KICK
local function applyESP(plr)
    if plr == player then return end
    RunService.RenderStepped:Connect(function()
        if plr.Character then
            local high = plr.Character:FindFirstChild("NN_ESP") or Instance.new("Highlight", plr.Character)
            high.Name = "NN_ESP"; high.Enabled = config.espEnabled
            high.FillColor = Color3.fromHSV(tick() % 5 / 5, 0.7, 1); high.FillTransparency = 0.5
        end
    end)
end
for _, p in pairs(game.Players:GetPlayers()) do applyESP(p) end
game.Players.PlayerAdded:Connect(applyESP)

resB.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.Health = 0 end end)
rejB.MouseButton1Click:Connect(function() TeleportService:Teleport(game.PlaceId, player) end)
leaB.MouseButton1Click:Connect(function() player:Kick("kicked by mrfunnynutz") end)

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0, 25, 0, 25); minBtn.Position = UDim2.new(1, -30, 0, 5); minBtn.BackgroundTransparency = 1; minBtn.Text = "-"; minBtn.Font = Enum.Font.GothamMedium; minBtn.TextSize = 20; minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.MouseButton1Click:Connect(function() config.minimized = true; frame.Visible = false; minBox.Visible = true; minBox.Position = frame.Position; saveSettings() end)
frame:GetPropertyChangedSignal("Position"):Connect(function() config.pos = {frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset}; saveSettings() end)
