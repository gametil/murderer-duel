--[[ Murderer Duel v6 — NO FREEZE ]]
-- Root cause found: warn/print overrides + 2x RenderStepped + camera math spam
-- Fix: zero overrides, 1 callback, WorldToViewportPoint called once per active frame

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Range = 200

-- Drawing (safe, both types guarded)
local espBox, espTxt, espDot = nil, nil, nil
pcall(function() espBox = Drawing.new("Square") end)
pcall(function() espTxt = Drawing.new("Text") end)
pcall(function() espDot = Drawing.new("Circle") end)

-- Single callback, 30fps, gate at TOP
local fc = 0
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    if fc % 2 ~= 0 then return end

    -- Get nearest alive player
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        if espBox then espBox.Visible = false end
        if espTxt then espTxt.Visible = false end
        if espDot then espDot.Visible = false end
        return
    end

    local target, cd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local c = p.Character
        if not c then continue end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then continue end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then continue end
        local d = (myRoot.Position - r.Position).Magnitude
        if d < Range and d < cd then target, cd = p, d end
    end

    local cam = workspace.CurrentCamera
    if not cam then return end

    if target then
        local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local sp, on = cam:WorldToViewportPoint(root.Position)
            if on then
                -- Smooth aim
                pcall(function() mousemoverel((sp.X - Mouse.X) * 0.7, (sp.Y - Mouse.Y) * 0.7) end)

                -- Draw ESP (one call per active frame)
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local hp = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local bh = math.abs(sp.Y - hp.Y) * 1.8
                    local bw = bh * 0.6
                    local dist = math.floor((cam.CFrame.Position - root.Position).Magnitude)
                    if espBox then
                        espBox.Size = Vector2.new(bw, bh)
                        espBox.Position = Vector2.new(sp.X - bw/2, sp.Y - bh/2)
                        espBox.Visible = true
                    end
                    if espTxt then
                        espTxt.Text = target.Name .. " [" .. dist .. "m]"
                        espTxt.Position = Vector2.new(sp.X, sp.Y - bh/2 - 18)
                        espTxt.Visible = true
                    end
                    if espDot then
                        espDot.Position = Vector2.new(sp.X, sp.Y)
                        espDot.Visible = true
                    end
                end
            else
                if espBox then espBox.Visible = false end
                if espTxt then espTxt.Visible = false end
                if espDot then espDot.Visible = false end
            end
        end
    else
        if espBox then espBox.Visible = false end
        if espTxt then espTxt.Visible = false end
        if espDot then espDot.Visible = false end
    end
end)

-- Avatar fix (one-shot, no warn/print overrides)
task.spawn(function()
    task.wait(3)
    local char = LP.Character
    if not char then return end
    local acc = char:FindFirstChildOfClass("Accessory")
    local iter = 0
    while acc and iter < 20 do
        iter = iter + 1
        local h = acc:FindFirstChild("Handle")
        if h then
            local m = h:FindFirstChildOfClass("SpecialMesh")
            if m then
                local mid = ""
                pcall(function() mid = tostring(m.MeshId) end)
                if mid == "" or mid:find("110937062102535") then acc:Destroy() end
            end
        end
        acc = char:FindFirstChildOfClass("Accessory")
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:BuildRigFromAttachments() end) end
end)
LP.CharacterAdded:Connect(function()
    task.spawn(function()
        task.wait(3)
        local char = LP.Character
        if not char then return end
        local acc = char:FindFirstChildOfClass("Accessory")
        local iter = 0
        while acc and iter < 20 do
            iter = iter + 1
            local h = acc:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh")
                if m then
                    local mid = ""
                    pcall(function() mid = tostring(m.MeshId) end)
                    if mid == "" or mid:find("110937062102535") then acc:Destroy() end
                end
            end
            acc = char:FindFirstChildOfClass("Accessory")
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:BuildRigFromAttachments() end) end
    end)
end)

-- UI (minimal, no pcall)
local s = Instance.new("ScreenGui")
s.Name = "MDUELv6"; s.ResetOnSpawn = false
s.Parent = LP:WaitForChild("PlayerGui")
local f = Instance.new("Frame")
f.Size = UDim2.new(0, 180, 0, 40)
f.Position = UDim2.new(0, 10, 0, 200)
f.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
f.BackgroundTransparency = 0.2
f.BorderSizePixel = 0
f.Active = true; f.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
f.Parent = s
local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 1, 0)
t.BackgroundTransparency = 1
t.Text = "🎯 MDUEL | Range " .. Range .. "m"
t.TextColor3 = Color3.fromRGB(200, 200, 255)
t.TextSize = 13; t.Font = Enum.Font.Gotham
t.Parent = f
