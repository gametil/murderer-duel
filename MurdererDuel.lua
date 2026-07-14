--[[ Murderer Duel — Aimbot + ESP (target nearest only) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local Settings = {Aimbot = true, ESP = true, FOV = 200, Smoothness = 0.7}
Settings._holding = false

-- RightCtrl to aimlock
Mouse.KeyDown:Connect(function(k)
    if k == "rightcontrol" then Settings._holding = true end
end)
Mouse.KeyUp:Connect(function(k)
    if k == "rightcontrol" then Settings._holding = false end
end)

-- UI
local s = Instance.new("ScreenGui")
s.Name = "MDUEL_UI"; s.ResetOnSpawn = false
local m = Instance.new("Frame")
m.Size = UDim2.new(0, 220, 0, 160)
m.Position = UDim2.new(0, 20, 0, 300)
m.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
m.BackgroundTransparency = 0.15; m.BorderSizePixel = 0
m.Active = true; m.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 8); m.Parent = s
local b = Instance.new("Frame")
b.Size = UDim2.new(1, 0, 0, 2)
b.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
b.BorderSizePixel = 0; b.ZIndex = 3; b.Parent = m
local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 30)
t.Position = UDim2.new(0, 0, 0, 4)
t.BackgroundTransparency = 1
t.Text = "✦ MDUEL"; t.TextColor3 = Color3.fromRGB(220, 220, 255)
t.TextSize = 18; t.Font = Enum.Font.GothamBold; t.ZIndex = 4; t.Parent = m
local mn = Instance.new("TextButton")
mn.Size = UDim2.new(0, 24, 0, 24)
mn.Position = UDim2.new(1, -28, 0, 4)
mn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mn.Text = "─"; mn.TextColor3 = Color3.fromRGB(200, 200, 255)
mn.TextSize = 16; mn.BorderSizePixel = 0; mn.ZIndex = 5
Instance.new("UICorner").CornerRadius = UDim.new(0, 4); mn.Parent = m
local function mkTog(name, def, y)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 190, 0, 28)
    bg.Position = UDim2.new(0, 15, 0, y)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    bg.BorderSizePixel = 0; bg.ZIndex = 4
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6); bg.Parent = m
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    lbl.TextSize = 14; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham; lbl.ZIndex = 5; lbl.Parent = bg
    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 45, 0, 20)
    tog.Position = UDim2.new(1, -55, 0, 4)
    tog.BackgroundColor3 = def and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    tog.Text = def and "ON" or "OFF"
    tog.TextColor3 = Color3.fromRGB(255, 255, 255)
    tog.TextSize = 11; tog.BorderSizePixel = 0; tog.Font = Enum.Font.GothamBold; tog.ZIndex = 5
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4); tog.Parent = bg
    tog.MouseButton1Click:Connect(function()
        if name == "Aimbot" then
            Settings.Aimbot = not Settings.Aimbot
            tog.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
            tog.Text = Settings.Aimbot and "ON" or "OFF"
        elseif name == "ESP" then
            Settings.ESP = not Settings.ESP
            tog.BackgroundColor3 = Settings.ESP and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
            tog.Text = Settings.ESP and "ON" or "OFF"
        end
    end)
end
mkTog("Aimbot", true, 40)
mkTog("ESP", true, 75)
local hl = Instance.new("TextLabel")
hl.Size = UDim2.new(1, -30, 0, 20)
hl.Position = UDim2.new(0, 15, 0, 108)
hl.BackgroundTransparency = 1
hl.Text = "Hold RightCtrl to aimlock"
hl.TextColor3 = Color3.fromRGB(140, 140, 170)
hl.TextSize = 11; hl.TextXAlignment = Enum.TextXAlignment.Left
hl.Font = Enum.Font.Gotham; hl.ZIndex = 4; hl.Parent = m
local st = Instance.new("Frame")
st.Size = UDim2.new(1, 0, 0, 24)
st.Position = UDim2.new(0, 0, 1, -24)
st.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
st.BorderSizePixel = 0; st.ZIndex = 4
Instance.new("UICorner").CornerRadius = UDim.new(0, 8); st.Parent = m
local sl = Instance.new("TextLabel")
sl.Size = UDim2.new(1, -10, 1, 0)
sl.Position = UDim2.new(0, 10, 0, 0)
sl.BackgroundTransparency = 1; sl.Text = "● Injected"
sl.TextColor3 = Color3.fromRGB(50, 255, 100); sl.TextSize = 11
sl.TextXAlignment = Enum.TextXAlignment.Left; sl.Font = Enum.Font.Gotham; sl.ZIndex = 5; sl.Parent = st
local minimized = false
mn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        m:TweenSize(UDim2.new(0, 40, 0, 40), "Out", "Quad", 0.3, true)
        t.Visible = false
        for _, v in ipairs(m:GetChildren()) do
            if v:IsA("Frame") and v ~= b then v.Visible = false end
        end
        mn.Text = "◉"
    else
        m:TweenSize(UDim2.new(0, 220, 0, 160), "Out", "Quad", 0.3, true)
        t.Visible = true
        for _, v in ipairs(m:GetChildren()) do
            if v:IsA("Frame") and v ~= b then v.Visible = true end
        end
        mn.Text = "─"
    end
end)
spawn(function()
    local hue = 0
    while task.wait(0.05) do
        hue = (hue + 0.005) % 1
        b.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 0.8)
    end
end)
s.Parent = LP:WaitForChild("PlayerGui")

-- Core
local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- Find ONLY the nearest player across the whole game
local function getNearestPlayer()
    local closest, closestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not isAlive(plr) then continue end
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        -- Distance in 3D world space (not screen)
        local dist3d = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and (LP.Character.HumanoidRootPart.Position - root.Position).Magnitude) or math.huge
        
        if dist3d < closestDist then
            closest = plr
            closestDist = dist3d
        end
    end
    return closest, closestDist
end

-- ESP for nearest player ONLY
local esps = {}
local function drawESP(plr, color)
    -- Clean old
    for _, v in pairs(esps) do
        if v.Box then v.Box.Visible = false end
        if v.Name then v.Name.Visible = false end
        if v.Line then v.Line.Visible = false end
    end
    esps = {}
    if not Settings.ESP or not plr then return end
    
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    if not root or not head then return end
    
    local rp, on = Camera:WorldToViewportPoint(root.Position)
    local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    if not on then return end
    
    local bh = math.abs(rp.Y - hp.Y) * 2
    local bw = bh * 0.6
    
    local box = Drawing.new("Square")
    box.Size = Vector2.new(bw, bh)
    box.Position = Vector2.new(rp.X - bw / 2, rp.Y - bh / 2)
    box.Color = color; box.Thickness = 2; box.Filled = false; box.Visible = true
    
    local nm = Drawing.new("Text")
    nm.Text = plr.Name .. " [" .. math.floor((Camera.CFrame.Position - char.HumanoidRootPart.Position).Magnitude) .. "m]"
    nm.Size = 16; nm.Position = Vector2.new(rp.X, rp.Y - bh / 2 - 20)
    nm.Color = color; nm.Center = true; nm.Outline = true; nm.Visible = true
    
    local ln = Drawing.new("Line")
    ln.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    ln.To = Vector2.new(rp.X, rp.Y)
    ln.Color = color; ln.Thickness = 1; ln.Transparency = 0.4; ln.Visible = true
    
    esps[1] = {Box = box, Name = nm, Line = ln}
end

-- Aim at nearest player
local function doAimbot(plr)
    if not plr then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local tp = Camera:WorldToViewportPoint(root.Position)
    if tp.Z < 0 then return end
    
    local sx = Mouse.X + (tp.X - Mouse.X) * Settings.Smoothness
    local sy = Mouse.Y + (tp.Y - Mouse.Y) * Settings.Smoothness
    
    pcall(function() mousemoverel(sx - Mouse.X, sy - Mouse.Y) end)
end

-- Main
RunService.RenderStepped:Connect(function()
    pcall(function()
        local nearest, dist = getNearestPlayer()
        
        -- ESP - nearest only with color
        local color = Color3.new(1, 0.3, 0.3) -- red = enemy
        if nearest and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local distVal = (LP.Character.HumanoidRootPart.Position - nearest.Character.HumanoidRootPart.Position).Magnitude
            -- Color by distance: red (close) -> yellow -> green (far)
            local hue = math.clamp(distVal / 150, 0, 1) * 0.3
            color = Color3.fromHSV(hue, 0.9, 0.9)
        end
        drawESP(nearest, color)
        
        -- Aimbot on nearest
        if Settings.Aimbot and Settings._holding and nearest then
            doAimbot(nearest)
        end
    end)
end)

warn("[[ MDUEL ]] Loaded | Targets NEAREST player only | Hold RightCtrl")
