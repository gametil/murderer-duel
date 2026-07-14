--[[ Murderer Duel — Aimbot + ESP + Animated UI ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local Settings = {
    Aimbot = true,
    ESP = true,
    FOV = 120,
    Smoothness = 0.6,
}

-- MouseButton4 hold state
local holdingMB4 = false

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton4 then
        holdingMB4 = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton4 then
        holdingMB4 = false
    end
end)

-- === UI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MDUEL_UI"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 180)
Main.Position = UDim2.new(0, 20, 0, 300)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BackgroundTransparency = 0.15
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Main

local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 0, 0, 2)
Border.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Border.BorderSizePixel = 0
Border.ZIndex = 3
Border.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 4)
Title.BackgroundTransparency = 1
Title.Text = "✦ MDUEL"
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 4
Title.Parent = Main

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -28, 0, 4)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
MinBtn.TextSize = 16
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex = 5
local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 4)
MinBtnCorner.Parent = MinBtn
MinBtn.Parent = Main

local function makeToggle(name, default, yPos)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 190, 0, 28)
    bg.Position = UDim2.new(0, 15, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    bg.BorderSizePixel = 0
    bg.ZIndex = 4
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 6)
    bgCorner.Parent = bg
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(180, 180, 200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.ZIndex = 5
    label.Parent = bg
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 45, 0, 20)
    toggle.Position = UDim2.new(1, -55, 0, 4)
    toggle.BackgroundColor3 = default and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 11
    toggle.BorderSizePixel = 0
    toggle.Font = Enum.Font.GothamBold
    toggle.ZIndex = 5
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 4)
    toggleCorner.Parent = toggle
    
    toggle.MouseButton1Click:Connect(function()
        if name == "Aimbot" then
            Settings.Aimbot = not Settings.Aimbot
            toggle.BackgroundColor3 = Settings.Aimbot and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
            toggle.Text = Settings.Aimbot and "ON" or "OFF"
        elseif name == "ESP" then
            Settings.ESP = not Settings.ESP
            toggle.BackgroundColor3 = Settings.ESP and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
            toggle.Text = Settings.ESP and "ON" or "OFF"
        end
    end)
    
    toggle.Parent = bg
    bg.Parent = Main
end

makeToggle("Aimbot", true, 40)
makeToggle("ESP", true, 75)

-- Hold instruction
local HoldLabel = Instance.new("TextLabel")
HoldLabel.Size = UDim2.new(1, -30, 0, 20)
HoldLabel.Position = UDim2.new(0, 15, 0, 108)
HoldLabel.BackgroundTransparency = 1
HoldLabel.Text = "Hold MB4 to aimlock"
HoldLabel.TextColor3 = Color3.fromRGB(140, 140, 170)
HoldLabel.TextSize = 11
HoldLabel.TextXAlignment = Enum.TextXAlignment.Left
HoldLabel.Font = Enum.Font.Gotham
HoldLabel.ZIndex = 4
HoldLabel.Parent = Main

local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(1, 0, 0, 24)
StatusBar.Position = UDim2.new(0, 0, 1, -24)
StatusBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
StatusBar.BorderSizePixel = 0
StatusBar.ZIndex = 4
local StatusBarCorner = Instance.new("UICorner")
StatusBarCorner.CornerRadius = UDim.new(0, 8)
StatusBarCorner.Parent = StatusBar
StatusBar.Parent = Main

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "● Injected"
StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 100)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.ZIndex = 5
StatusLabel.Parent = StatusBar

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Main:TweenSize(UDim2.new(0, 40, 0, 40), "Out", "Quad", 0.3, true)
        Title.Visible = false
        for _, v in ipairs(Main:GetChildren()) do
            if v:IsA("Frame") and v ~= Border then v.Visible = false end
        end
        MinBtn.Text = "◉"
    else
        Main:TweenSize(UDim2.new(0, 220, 0, 180), "Out", "Quad", 0.3, true)
        Title.Visible = true
        for _, v in ipairs(Main:GetChildren()) do
            if v:IsA("Frame") and v ~= Border then v.Visible = true end
        end
        MinBtn.Text = "─"
    end
end)

-- Animated border
spawn(function()
    local hue = 0
    while task.wait(0.05) do
        hue = (hue + 0.005) % 1
        Border.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 0.8)
    end
end)

ScreenGui.Parent = LP:WaitForChild("PlayerGui")

-- === FUNCTIONS ===
local function getRole(plr)
    local char = plr.Character
    if not char then return "Unknown" end
    local role = char:FindFirstChild("Role") or char:FindFirstChild("Murderer") or char:FindFirstChild("Sheriff")
    if role then
        if role:IsA("BoolValue") then return role.Name end
        return tostring(role.Value)
    end
    return plr.Name
end

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getTarget()
    local closest, closestDist = nil, math.huge
    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not isAlive(plr) then continue end
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local vec, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        local dist = math.sqrt((vec.X - cx) ^ 2 + (vec.Y - cy) ^ 2)
        if dist > Settings.FOV then continue end
        if dist < closestDist then
            closest = plr
            closestDist = dist
        end
    end
    return closest
end

-- === ESP ===
local ESP = {}

local function updateESP()
    for _, v in pairs(ESP) do
        if v.Box then v.Box.Visible = false end
        if v.Name then v.Name.Visible = false end
        if v.Line then v.Line.Visible = false end
    end
    ESP = {}
    if not Settings.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not isAlive(plr) then continue end
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if not root or not head then continue end
        local rp, on = Camera:WorldToViewportPoint(root.Position)
        local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        if not on then continue end
        local role = getRole(plr)
        local color = role:lower():find("murder") and Color3.new(1, 0.15, 0.15) or role:lower():find("sheriff") and Color3.new(0.2, 0.6, 1) or Color3.new(0.3, 1, 0.3)
        local bh = math.abs(rp.Y - hp.Y) * 2
        local bw = bh * 0.6
        local box = Drawing.new("Square")
        box.Size = Vector2.new(bw, bh)
        box.Position = Vector2.new(rp.X - bw / 2, rp.Y - bh / 2)
        box.Color = color
        box.Thickness = 2
        box.Filled = false
        box.Visible = true
        local nm = Drawing.new("Text")
        nm.Text = plr.Name .. " [" .. role .. "]"
        nm.Size = 16
        nm.Position = Vector2.new(rp.X, rp.Y - bh / 2 - 20)
        nm.Color = color
        nm.Center = true
        nm.Outline = true
        nm.Visible = true
        local ln = Drawing.new("Line")
        ln.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        ln.To = Vector2.new(rp.X, rp.Y)
        ln.Color = color
        ln.Thickness = 1
        ln.Transparency = 0.4
        ln.Visible = true
        ESP[plr] = {Box = box, Name = nm, Line = ln}
    end
end

-- === MAIN LOOP ===
RunService.RenderStepped:Connect(function()
    updateESP()
    if not Settings.Aimbot then return end
    if not holdingMB4 then return end -- only aim while holding MB4
    local target = getTarget()
    if not target then return end
    local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tp = Camera:WorldToViewportPoint(root.Position)
    if tp.Z < 0 then return end
    local tx, ty = tp.X, tp.Y
    local mx, my = Mouse.X, Mouse.Y
    local sx = mx + (tx - mx) * Settings.Smoothness
    local sy = my + (ty - my) * Settings.Smoothness
    mousemoverel(sx - mx, sy - my)
end)

warn("[[ MDUEL ]] Loaded | Hold MB4 for aimlock")
