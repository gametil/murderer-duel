--[[ Murderer Duel v6 — NO FREEZE ]]
-- Removed warn/print overrides (main freeze cause)
-- Single RenderStepped, minimal overhead

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Range = 200
local Target = nil

-- Reusable Drawing
local espOk, box, txt, dot
pcall(function()
    box = Drawing.new("Square")
    txt = Drawing.new("Text")
    dot = Drawing.new("Circle")
    espOk = true
end)

-- Mouse helper (works on all executors)
local MX, MY = 0, 0
pcall(function()
    local m = LP:GetMouse()
    RunService.RenderStepped:Connect(function()
        MX, MY = m.X, m.Y
    end)
end)

-- Single RenderStepped callback — 30fps
local fc = 0
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    if fc % 2 ~= 0 then return end

    -- Aim lock
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local nearest, nd = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local c = p.Character
            if not c then continue end
            local r = c:FindFirstChild("HumanoidRootPart")
            if not r then continue end
            local h = c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health <= 0 then continue end
            local d = (root.Position - r.Position).Magnitude
            if d < Range and d < nd then nearest, nd = p, d end
        end
        Target = nearest
        if Target then
            local r = Target.Character and Target.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local cam = workspace.CurrentCamera
                if cam then
                    local sp, on = cam:WorldToViewportPoint(r.Position)
                    if on then
                        pcall(function() mousemoverel((sp.X - MX) * 0.7, (sp.Y - MY) * 0.7) end)
                    end
                end
            end
        end
    end

    -- ESP
    if espOk and Target and Target.Character then
        local r = Target.Character:FindFirstChild("HumanoidRootPart")
        local h = Target.Character:FindFirstChild("Head")
        local cam = workspace.CurrentCamera
        if r and h and cam then
            local rp = cam:WorldToViewportPoint(r.Position)
            local hp = cam:WorldToViewportPoint(h.Position + Vector3.new(0, 0.5, 0))
            if rp[3] then
                local bh = math.abs(rp.Y - hp.Y) * 1.8
                local bw = bh * 0.6
                local dist = math.floor((cam.CFrame.Position - r.Position).Magnitude)
                box.Size = Vector2.new(bw, bh)
                box.Position = Vector2.new(rp.X - bw/2, rp.Y - bh/2)
                box.Visible = true
                txt.Text = Target.Name .. " [" .. dist .. "m]"
                txt.Position = Vector2.new(rp.X, rp.Y - bh/2 - 18)
                txt.Visible = true
                dot.Position = Vector2.new(rp.X, rp.Y)
                dot.Visible = true
            else
                box.Visible = false; txt.Visible = false; dot.Visible = false
            end
        else
            box.Visible = false; txt.Visible = false; dot.Visible = false
        end
    elseif espOk then
        box.Visible = false; txt.Visible = false; dot.Visible = false
    end
end)

-- Avatar fix (one-shot, no thread)
task.delay(3, function()
    local char = LP.Character
    if not char then return end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh")
                if m then
                    local mid = tostring(m.MeshId)
                    if mid == "" or mid:find("110937062102535") then acc:Destroy() end
                end
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:BuildRigFromAttachments() end) end
end)

-- UI (minimal)
local s = Instance.new("ScreenGui")
s.Name = "MDUEL"; s.ResetOnSpawn = false
s.Parent = LP:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 180, 0, 60)
f.Position = UDim2.new(0, 10, 0, 200)
f.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
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
