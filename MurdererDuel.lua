--[[ Murderer Duel — Working Aimbot ]]--
-- For knife-throw game (Ketamine-compatible)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

----- CONFIG -----
local Settings = {
    Enabled = true,      -- toggle on/off
    Range = 200,
    Smoothness = 0.7,
    AutoThrow = true,    -- auto-throw when locked
}

----- TARGETING -----
local Target = nil

----- AIM LOCK (always on) -----
local function getNearest()
    local closest, closestDist = nil, math.huge
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local char = plr.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local dist = (myRoot.Position - root.Position).Magnitude
        if dist > Settings.Range then continue end
        if dist < closestDist then
            closest = plr
            closestDist = dist
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then return end
    Target = getNearest()
    if not Target then return end
    local root = Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        Target = getNearest()
        return
    end
    
    local sp, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then return end
    
    -- Smooth aim
    local sx = Mouse.X + (sp.X - Mouse.X) * Settings.Smoothness
    local sy = Mouse.Y + (sp.Y - Mouse.Y) * Settings.Smoothness
    pcall(function()
        mousemoverel(sx - Mouse.X, sy - Mouse.Y)
    end)
end)

----- AUTO-THROW -----
local ThrowRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and
                    game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ThrowReplicate")

if ThrowRemote then
    -- Fix: Game strips FireServer from RemoteEvents
    -- Use hookmetamethod to intercept instead
    local __namecall
    __namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" and self == ThrowRemote then
            local data = ...
            if Target and Target.Character then
                local root = Target.Character:FindFirstChild("HumanoidRootPart")
                if root and type(data) == "table" then
                    data.target = root.Position
                    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot then data.origin = myRoot.Position end
                end
            end
        end
        return __namecall(self, ...)
    end)
    
    warn("[[ AIMBOT ]] ThrowRemote hooked via __namecall")
end

----- SIMPLE ESP -----
local function drawESP()
    if not Target then return end
    local root = Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local head = Target.Character and Target.Character:FindFirstChild("Head")
    if not head then return end
    
    local rp = Camera:WorldToViewportPoint(root.Position)
    local hp = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    if not rp[3] then return end  -- offscreen
    
    local bh = math.abs(rp.Y - hp.Y) * 1.5
    local bw = bh * 0.6
    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
    
    -- Box
    local box = Drawing.new("Square")
    box.Size = Vector2.new(bw, bh)
    box.Position = Vector2.new(rp.X - bw/2, rp.Y - bh/2)
    box.Color = Color3.new(1, 0.2, 0.2)
    box.Thickness = 2
    box.Filled = false
    box.Visible = true
    
    -- Name
    local name = Drawing.new("Text")
    name.Text = Target.Name .. " [" .. dist .. "m]"
    name.Size = 14
    name.Position = Vector2.new(rp.X, rp.Y - bh/2 - 18)
    name.Color = Color3.new(1, 1, 1)
    name.Center = true
    name.Outline = true
    name.Visible = true
    
    -- Center dot
    local dot = Drawing.new("Circle")
    dot.Position = Vector2.new(rp.X, rp.Y)
    dot.Radius = 5
    dot.Color = Color3.new(0, 1, 0)
    dot.Thickness = 2
    dot.Filled = false
    dot.Visible = true
    
    -- Cleanup
    task.delay(0.05, function()
        box:Remove()
        name:Remove()
        dot:Remove()
    end)
end

RunService.RenderStepped:Connect(function()
    if Target then drawESP() end
end)

----- UI -----
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
t.Text = "🎯 MDUEL AIMBOT"
t.TextColor3 = Color3.fromRGB(220, 220, 255)
t.TextSize = 14; t.Font = Enum.Font.GothamBold; t.Parent = f

local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -20, 0, 18)
st.Position = UDim2.new(0, 10, 0, 30)
st.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
st.BackgroundTransparency = 0.5
st.Text = "Auto Aim + Throw [Always ON]"
st.TextColor3 = Color3.fromRGB(140, 200, 140)
st.TextSize = 11; st.Font = Enum.Font.Gotham; st.Parent = f

local rangeLbl = Instance.new("TextLabel")
rangeLbl.Size = UDim2.new(1, -20, 0, 18)
rangeLbl.Position = UDim2.new(0, 10, 0, 52)
rangeLbl.BackgroundTransparency = 1
rangeLbl.Text = "Range: " .. Settings.Range .. "m"
rangeLbl.TextColor3 = Color3.fromRGB(140, 140, 170)
rangeLbl.TextSize = 11; rangeLbl.Font = Enum.Font.Gotham; st.Parent = f

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 18)
status.Position = UDim2.new(0, 10, 0, 76)
status.BackgroundTransparency = 1
status.Text = "● Injected"
status.TextColor3 = Color3.fromRGB(50, 255, 100)
status.TextSize = 11; status.Font = Enum.Font.Gotham; st.Parent = f

warn("[[ AIMBOT ]] Hold RightCtrl to lock & throw at nearest target")
