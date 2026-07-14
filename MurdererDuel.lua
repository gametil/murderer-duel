--[[ Murderer Duel — NO FREEZE aimbot + ESP ]]
-- v4: zero hooks, throttled, lightweight

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local Range = 200
local Smoothness = 0.7
local Target = nil

-----[ THROTTLED TARGETING (30fps) ]-----
local fc = 0
local function getNearest()
    local closest, cd = nil, math.huge
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local c = p.Character
        if not c then continue end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then continue end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then continue end
        local d = (myRoot.Position - r.Position).Magnitude
        if d > Range then continue end
        if d < cd then closest, cd = p, d end
    end
    return closest
end

-----[ AIM LOCK (smooth, throttled) ]-----
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    if fc % 2 ~= 0 then return end  -- 30fps throttle
    
    Target = getNearest()
    if not Target then return end
    
    local root = Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local sp, on = Camera:WorldToViewportPoint(root.Position)
    if not on then return end
    
    local sx = Mouse.X + (sp.X - Mouse.X) * Smoothness
    local sy = Mouse.Y + (sp.Y - Mouse.Y) * Smoothness
    pcall(function() mousemoverel(sx - Mouse.X, sy - Mouse.Y) end)
end)

-----[ ESP (reused Drawing, throttled) ]-----
local espBox = Drawing.new("Square")
local espName = Drawing.new("Text")
local espDot = Drawing.new("Circle")
espBox.Visible = false
espName.Visible = false
espDot.Visible = false

RunService.RenderStepped:Connect(function()
    if not Target or not Target.Character then
        espBox.Visible = false
        espName.Visible = false
        espDot.Visible = false
        return
    end
    
    local root = Target.Character:FindFirstChild("HumanoidRootPart")
    local head = Target.Character:FindFirstChild("Head")
    if not root or not head then
        espBox.Visible = false; espName.Visible = false; espDot.Visible = false
        return
    end
    
    local rp = Camera:WorldToViewportPoint(root.Position)
    local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    if not rp[3] then
        espBox.Visible = false; espName.Visible = false; espDot.Visible = false
        return
    end
    
    if fc % 2 ~= 0 then return end  -- same throttle as aim
    
    local bh = math.abs(rp.Y - hp.Y) * 1.8
    local bw = bh * 0.6
    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
    
    espBox.Size = Vector2.new(bw, bh)
    espBox.Position = Vector2.new(rp.X - bw/2, rp.Y - bh/2)
    espBox.Visible = true
    
    espName.Text = Target.Name .. " [" .. dist .. "m]"
    espName.Position = Vector2.new(rp.X, rp.Y - bh/2 - 18)
    espName.Visible = true
    
    espDot.Position = Vector2.new(rp.X, rp.Y)
    espDot.Visible = true
end)

-----[ AVATAR FIX (no loops, one-shot) ]-----
spawn(function()
    task.wait(3)
    local char = LP.Character
    if not char then return end
    local acc = char:FindFirstChildOfClass("Accessory")
    while acc do
        local h = acc:FindFirstChild("Handle")
        if h then
            local m = h:FindFirstChildOfClass("SpecialMesh") or h:FindFirstChildOfClass("MeshPart")
            if m then
                local mid = ""
                pcall(function() mid = m.MeshId end)
                if mid == "" or mid:find("110937062102535") then
                    acc:Destroy()
                end
            end
        end
        acc = char:FindFirstChildOfClass("Accessory")
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:BuildRigFromAttachments() end) end
end)

-----[ UI (lightweight, no hooks) ]-----
local s = Instance.new("ScreenGui")
s.Name = "MDUEL_AIM"; s.ResetOnSpawn = false
s.Parent = LP:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 200, 0, 100)
f.Position = UDim2.new(0, 15, 0, 250)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
f.BackgroundTransparency = 0.15
f.BorderSizePixel = 0
f.Active = true; f.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
f.Parent = s

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 28)
t.BackgroundTransparency = 1
t.Text = "🎯 MDUEL"
t.TextColor3 = Color3.fromRGB(220, 220, 255)
t.TextSize = 14; t.Font = Enum.Font.GothamBold
t.Parent = f

local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -20, 0, 18)
st.Position = UDim2.new(0, 10, 0, 32)
st.BackgroundTransparency = 0.5
st.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
st.Text = "Auto Aim [30fps]"
st.TextColor3 = Color3.fromRGB(140, 200, 140)
st.TextSize = 11; st.Font = Enum.Font.Gotham
st.Parent = f

local rl = Instance.new("TextLabel")
rl.Size = UDim2.new(1, -20, 0, 18)
rl.Position = UDim2.new(0, 10, 0, 54)
rl.BackgroundTransparency = 1
rl.Text = "Range: " .. Range .. "m"
rl.TextColor3 = Color3.fromRGB(140, 140, 170)
rl.TextSize = 11; rl.Font = Enum.Font.Gotham
rl.Parent = f

local sl = Instance.new("TextLabel")
sl.Size = UDim2.new(1, -20, 0, 18)
sl.Position = UDim2.new(0, 10, 0, 76)
sl.BackgroundTransparency = 1
sl.Text = "● Ready"
sl.TextColor3 = Color3.fromRGB(50, 255, 100)
sl.TextSize = 11; sl.Font = Enum.Font.Gotham
sl.Parent = f
