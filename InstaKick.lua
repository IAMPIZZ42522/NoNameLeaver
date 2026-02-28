local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local FILE_NAME = "NoNameHub_Final.json"
local config = {
    pos = {0.5, -95, 0.5, -60},
    boostEnabled = false,
    infJumpEnabled = false,
    espEnabled = false,
    antiRagdoll = false,
    antiKB = false,
    fpsBoost = false,
    speed = 32,
    minimized = false
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
screenGui.Name = "NoNameHub_V4"; screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 420) -- Slightly taller for FPS button
frame.Position = UDim2.new(config.pos[1], config.pos[2], config.pos[3], config.pos[4])
frame.BackgroundColor3 = Color3.fromRGB(12,12,12); frame.BorderSizePixel = 0; frame.Active = true; frame.Draggable = true; frame.Visible = not config.minimized
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
local frameStroke = Instance.new("UIStroke", frame); frameStroke.Thickness = 2

-- MINIMIZE
local minBox = Instance.new("TextButton", screenGui)
minBox.Visible = config.minimized; minBox.Size = UDim2.new(0, 50, 0, 50); minBox.Position = frame.Position; minBox.BackgroundColor3 = Color3.fromRGB(12,12,12); minBox.Text = "NN"; minBox.Font = Enum.Font.GothamBold; minBox.TextColor3 = Color3.new(1,1,1); minBox.Draggable = true; Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 12)
local minStroke = Instance.new("UIStroke", minBox); minStroke.Thickness = 2
local cTime = 0
minBox.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then cTime = tick() end end)
minBox.InputEnded:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and tick() - cTime < 0.25 then config.minimized = false; frame.Visible = true; minBox.Visible = false; frame.Position = minBox.Position; saveSettings() end end)

-- TOGGLE GENERATOR
local offset = 0.1
local function createToggle(prop, text)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.85, 0, 0, 28); btn.Position = UDim2.new(0.075, 0, offset, 0); btn.BackgroundColor3 = Color3.fromRGB(22,22,22); btn.Text = text .. ": " .. (config[prop] and "ON" or "OFF"); btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.TextColor3 = Color3.new(1,1,1)
    local stroke = Instance.new("UIStroke", btn); stroke.Thickness = 1.2; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        config[prop] = not config[prop]
        btn.Text = text .. ": " .. (config[prop] and "ON" or "OFF")
        saveSettings()
    end)
    offset = offset + 0.08
    return btn, stroke
end

local bBtn, bStr = createToggle("boostEnabled", "SPEED BOOST")
offset = offset + 0.04 -- Space for slider
local sBtn, sStr = createToggle("infJumpEnabled", "INF JUMP")
local eBtn, eStr = createToggle("espEnabled", "PLAYER ESP")
local rBtn, rStr = createToggle("antiRagdoll", "ANTI RAGDOLL")
local kBtn, kStr = createToggle("antiKB", "ANTI KNOCKBACK")
local fBtn, fStr = createToggle("fpsBoost", "BOOST FPS (GAME)")

-- SLIDER
local sliderFrame = Instance.new("Frame", frame)
sliderFrame.Size = UDim2.new(0.85, 0, 0, 6); sliderFrame.Position = UDim2.new(0.075, 0, 0.22, 0); sliderFrame.BackgroundColor3 = Color3.fromRGB(40,40,40); sliderFrame.BorderSizePixel = 0; Instance.new("UICorner", sliderFrame)
local sliderFill = Instance.new("Frame", sliderFrame); sliderFill.Size = UDim2.new(0.5, 0, 1, 0); sliderFill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", sliderFill)
local knob = Instance.new("Frame", sliderFrame); knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(0.5, -7, 0.5, -7); knob.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- FPS BOOST LOGIC (CLEAN GAME)
RunService.Heartbeat:Connect(function()
    if config.fpsBoost then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = 1
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        -- Strip other players of laggy accessories
        for _, plr in pairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                for _, acc in pairs(plr.Character:GetChildren()) do
                    if acc:IsA("Accessory") then acc:Destroy() end
                end
            end
        end
    end
end)

-- ESP
local function applyESP(plr)
    if plr == player then return end
    RunService.RenderStepped:Connect(function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local high = plr.Character:FindFirstChild("NN_ESP") or Instance.new("Highlight", plr.Character)
            high.Name = "NN_ESP"; high.Enabled = config.espEnabled
            high.FillColor = Color3.fromHSV(tick() % 5 / 5, 0.7, 1); high.FillTransparency = 0.5
        end
    end)
end
for _, p in pairs(game.Players:GetPlayers()) do applyESP(p) end
game.Players.PlayerAdded:Connect(applyESP)

-- PHYSICS LOOP
RunService.Stepped:Connect(function()
    local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    frameStroke.Color = color; minStroke.Color = color; knob.BackgroundColor3 = color; sliderFill.BackgroundColor3 = color
    bStr.Color = color; sStr.Color = color; eStr.Color = color; rStr.Color = color; kStr.Color = color; fStr.Color = color

    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and root then
        if config.boostEnabled and hum.MoveDirection.Magnitude > 0 then
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(Vector3.new(hum.MoveDirection.X * config.speed, root.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * config.speed), 0.75)
        end
        if config.antiRagdoll then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
        if config.antiKB and not config.boostEnabled then
            root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
        end
    end
end)

-- SLIDER INPUT
local isSliding = false
local function updateSlider(input)
    local p = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
    config.speed = math.floor(16 + (p * 34))
    sliderFill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -7, 0.5, -7)
end
sliderFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isSliding = true; updateSlider(i) end end)
UserInputService.InputChanged:Connect(function(i) if isSliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateSlider(i) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isSliding = false; saveSettings() end end)

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if config.infJumpEnabled and player.Character then
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait()
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 58, root.AssemblyLinearVelocity.Z)
        end
    end
end)
