--[[ Murderer Duel — Aimbot + ESP + Avatar Fix ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local Settings = {Aimbot = true, ESP = true, FOV = 200, Smoothness = 0.7, EspRange = 150}
Settings._holding = false

-- RightCtrl keybind
Mouse.KeyDown:Connect(function(k)
    if k == "rightcontrol" then Settings._holding = true end
end)
Mouse.KeyUp:Connect(function(k)
    if k == "rightcontrol" then Settings._holding = false end
end)

-- Avatar Fix — runs once on inject
spawn(function()
    task.wait(1.5)
    local char = LP.Character
    if not char then return end
    local n = {acc=0,decal=0,gui=0,hl=0,weld=0}
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Accessory") then
            local h = v:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh") or h:FindFirstChildOfClass("MeshPart")
                if m and (m.MeshId == "" or m.MeshId:find("rbxassetid://0")) then
                    v:Destroy(); n.acc = n.acc + 1
                end
            end
        end
        if v:IsA("MeshPart") and v.Parent and v.Parent:IsA("Accessory") then
            if math.abs(v.Size.X - v.Size.Y) < 0.5 and math.abs(v.Size.Y - v.Size.Z) < 0.5 then
                v.Parent:Destroy(); n.acc = n.acc + 1
            end
        end
        if v:IsA("Part") and v.Parent ~= char and v.Size.X > 8 then v:Destroy(); n.acc = n.acc + 1 end
        if v:IsA("Decal") and (v.Texture == "" or v.Texture == "rbxassetid://0") then v:Destroy(); n.decal = n.decal + 1 end
        if v:IsA("SurfaceGui") or v:IsA("BillboardGui") then v:Destroy(); n.gui = n.gui + 1 end
        if v:IsA("Highlight") then v:Destroy(); n.hl = n.hl + 1 end
        if v:IsA("WeldConstraint") and (not v.Part0 or not v.Part1) then v:Destroy(); n.weld = n.weld + 1 end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:BuildRigFromAttachments() end) end
    warn("[[ FIX ]] Removed: " .. n.acc .. " acc, " .. n.decal .. " decal, " .. n.gui .. " gui, " .. n.hl .. " hl, " .. n.weld .. " weld")
end)

-- UI
local s = Instance.new("ScreenGui"); s.Name = "MDUEL_UI"; s.ResetOnSpawn = false
local m = Instance.new("Frame")
m.Size = UDim2.new(0, 220, 0, 160)
m.Position = UDim2.new(0, 20, 0, 300)
m.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
m.BackgroundTransparency = 0.15; m.BorderSizePixel = 0
m.Active = true; m.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 8); m.Parent = s
local b = Instance.new("Frame")
b.Size = UDim2.new(1, 0, 0, 2); b.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
b.BorderSizePixel = 0; b.ZIndex = 3; b.Parent = m
local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 30); t.Position = UDim2.new(0, 0, 0, 4)
t.BackgroundTransparency = 1; t.Text = "✦ MDUEL"
t.TextColor3 = Color3.fromRGB(220, 220, 255); t.TextSize = 18
t.Font = Enum.Font.GothamBold; t.ZIndex = 4; t.Parent = m
local mn = Instance.new("TextButton")
mn.Size = UDim2.new(0, 24, 0, 24); mn.Position = UDim2.new(1, -28, 0, 4)
mn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); mn.Text = "─"
mn.TextColor3 = Color3.fromRGB(200, 200, 255); mn.TextSize = 16; mn.BorderSizePixel = 0; mn.ZIndex = 5
Instance.new("UICorner").CornerRadius = UDim.new(0, 4); mn.Parent = m

local function tog(name, def, y)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 190, 0, 28); bg.Position = UDim2.new(0, 15, 0, y)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 35); bg.BorderSizePixel = 0; bg.ZIndex = 4
    Instance.new("UICorner").CornerRadius = UDim.new(0, 6); bg.Parent = m
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200); lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Font = Enum.Font.Gotham; lbl.ZIndex = 5; lbl.Parent = bg
    local tg = Instance.new("TextButton")
    tg.Size = UDim2.new(0, 45, 0, 20); tg.Position = UDim2.new(1, -55, 0, 4)
    tg.BackgroundColor3 = def and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    tg.Text = def and "ON" or "OFF"; tg.TextColor3 = Color3.fromRGB(255, 255, 255)
    tg.TextSize = 11; tg.BorderSizePixel = 0; tg.Font = Enum.Font.GothamBold; tg.ZIndex = 5
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4); tg.Parent = bg
    tg.MouseButton1Click:Connect(function()
        if name == "Aimbot" then
            Settings.Aimbot = not Settings.Aimbot
            tg.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
            tg.Text = Settings.Aimbot and "ON" or "OFF"
        elseif name == "ESP" then
            Settings.ESP = not Settings.ESP
            tg.BackgroundColor3 = Settings.ESP and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
            tg.Text = Settings.ESP and "ON" or "OFF"
        end
    end)
end
tog("Aimbot", true, 40); tog("ESP", true, 75)

local hl = Instance.new("TextLabel")
hl.Size = UDim2.new(1, -30, 0, 20); hl.Position = UDim2.new(0, 15, 0, 108)
hl.BackgroundTransparency = 1; hl.Text = "Hold RightCtrl | Range: " .. Settings.EspRange .. "m"
hl.TextColor3 = Color3.fromRGB(140, 140, 170); hl.TextSize = 11
hl.TextXAlignment = Enum.TextXAlignment.Left; hl.Font = Enum.Font.Gotham; hl.ZIndex = 4; hl.Parent = m
local st = Instance.new("Frame")
st.Size = UDim2.new(1, 0, 0, 24); st.Position = UDim2.new(0, 0, 1, -24)
st.BackgroundColor3 = Color3.fromRGB(20, 20, 28); st.BorderSizePixel = 0; st.ZIndex = 4
Instance.new("UICorner").CornerRadius = UDim.new(0, 8); st.Parent = m
local sl = Instance.new("TextLabel")
sl.Size = UDim2.new(1, -10, 1, 0); sl.Position = UDim2.new(0, 10, 0, 0)
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
    local pchar = plr.Character
    if not pchar then return false end
    local hum = pchar:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getNearest()
    local closest, closestDist = nil, math.huge
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, 0 end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not isAlive(plr) then continue end
        local pchar = plr.Character
        local root = pchar and pchar:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local d = (myRoot.Position - root.Position).Magnitude
        if d > Settings.EspRange then continue end
        if d < closestDist then closest, closestDist = plr, d end
    end
    return closest, closestDist
end

-- ESP objects (created once, reused)
local espBox, espName, espLine, hudBg, hudNm
local function drawESP(plr, color)
    if not Settings.ESP or not plr then
        if espBox then
            espBox.Visible = false; espName.Visible = false; espLine.Visible = false
            hudBg.Visible = false; hudNm.Visible = false
        end
        return
    end
    -- Init once
    if not espBox then
        espBox = Drawing.new("Square"); espName = Drawing.new("Text")
        espLine = Drawing.new("Line"); hudBg = Drawing.new("Square"); hudNm = Drawing.new("Text")
    end
    local pchar = plr.Character
    local root = pchar and pchar:FindFirstChild("HumanoidRootPart")
    local head = pchar and pchar:FindFirstChild("Head")
    if not root or not head then
        espBox.Visible = false; espName.Visible = false; espLine.Visible = false
        hudBg.Visible = false; hudNm.Visible = false; return
    end
    local rp, on = Camera:WorldToViewportPoint(root.Position)
    local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    if not on then
        espBox.Visible = false; espName.Visible = false; espLine.Visible = false
        hudBg.Visible = false; hudNm.Visible = false; return
    end
    local bh = math.abs(rp.Y - hp.Y) * 2; local bw = bh * 0.6
    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
    espBox.Size = Vector2.new(bw, bh); espBox.Position = Vector2.new(rp.X - bw / 2, rp.Y - bh / 2)
    espBox.Color = color; espBox.Thickness = 2; espBox.Filled = false; espBox.Visible = true
    espName.Text = plr.Name .. " [" .. dist .. "m]"; espName.Size = 16
    espName.Position = Vector2.new(rp.X, rp.Y - bh / 2 - 20)
    espName.Color = color; espName.Center = true; espName.Outline = true; espName.Visible = true
    espLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    espLine.To = Vector2.new(rp.X, rp.Y); espLine.Color = color; espLine.Thickness = 1; espLine.Transparency = 0.4; espLine.Visible = true
    -- Center HUD below crosshair
    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
    hudBg.Size = Vector2.new(180, 24); hudBg.Position = Vector2.new(cx - 90, cy + 30)
    hudBg.Color = Color3.new(0, 0, 0); hudBg.Filled = true; hudBg.Transparency = 0.6; hudBg.Visible = true
    hudNm.Text = "▶ " .. plr.Name .. " [" .. dist .. "m]"; hudNm.Size = 18
    hudNm.Position = Vector2.new(cx, cy + 42); hudNm.Color = color; hudNm.Center = true; hudNm.Outline = true; hudNm.Visible = true
end

-- Aim
local function doAim(plr)
    if not plr then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tp = Camera:WorldToViewportPoint(root.Position)
    if tp.Z < 0 then return end
    local sx = Mouse.X + (tp.X - Mouse.X) * Settings.Smoothness
    local sy = Mouse.Y + (tp.Y - Mouse.Y) * Settings.Smoothness
    pcall(function() mousemoverel(sx - Mouse.X, sy - Mouse.Y) end)
end

-- Main loop (throttled to reduce lag)
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if frameCount % 2 == 0 then return end  -- skip every other frame = ~30fps
    
    local nearest = getNearest()
    local color = Color3.new(1, 0.3, 0.3)
    
    -- Safe color calc — won't crash if character nil
    if nearest then
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local pRoot = nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and pRoot then
            local d = (myRoot.Position - pRoot.Position).Magnitude
            local hue = math.clamp(d / 150, 0, 1) * 0.3
            color = Color3.fromHSV(hue, 0.9, 0.9)
        end
    end
    
    drawESP(nearest, color)
    
    if Settings.Aimbot and Settings._holding and nearest then
        doAim(nearest)
    end
end)

warn("[[ MDUEL ]] Loaded | Hold RightCtrl to aim")
