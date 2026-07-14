--[[ Murderer Duel v7 — WITH DIAGNOSTIC LOG ]]
-- Logs every action + error so we can see why it breaks

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Range = 200

-- LOG
local log = {"=== MDUEL LOG ==="}
local function add(...)
    local t = os.time()
    local msg = ""
    for _, v in ipairs({...}) do msg = msg .. tostring(v) .. " " end
    table.insert(log, "[" .. t .. "] " .. msg)
    if #log > 100 then table.remove(log, 1) end
end
local function showlog()
    warn(table.concat(log, "\n"))
end

add("Script started")

-- Drawing
local espBox, espTxt, espDot
pcall(function() espBox = Drawing.new("Square"); add("Drawing Square OK") end)
pcall(function() espTxt = Drawing.new("Text"); add("Drawing Text OK") end)
pcall(function() espDot = Drawing.new("Circle"); add("Drawing Circle OK") end)

-- Mouse
local Mouse
pcall(function() Mouse = LP:GetMouse(); add("Mouse OK") end)
if not Mouse then add("FAIL: Mouse nil") end

local cam = workspace.CurrentCamera
add("Camera: " .. tostring(cam))

-- Character check
add("Character: " .. tostring(LP.Character))
if LP.Character then
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    add("HRP: " .. tostring(root))
end

local fc = 0
local hadTarget = false
local errCount = 0

RunService.RenderStepped:Connect(function()
    fc = fc + 1
    if fc % 2 ~= 0 then return end
    if fc <= 10 then add("Frame " .. fc .. " running") end

    local success, err = pcall(function()
        local myChar = LP.Character
        if not myChar then
            if fc <= 10 then add("No character") end
            return
        end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            if fc <= 10 then add("No HRP") end
            return
        end
        
        -- Find target
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

        local c2 = workspace.CurrentCamera
        if not c2 then
            if fc <= 10 then add("No camera") end
            return
        end

        if target then
            if not hadTarget then add("First target: " .. target.Name .. " @" .. math.floor(cd) .. "m"); hadTarget = true end
            local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local sp, on = c2:WorldToViewportPoint(root.Position)
                if on and Mouse then
                    pcall(function()
                        mousemoverel((sp.X - Mouse.X) * 0.7, (sp.Y - Mouse.Y) * 0.7)
                    end)
                end
                -- ESP
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local hp = c2:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local bh = math.abs(sp.Y - hp.Y) * 1.8
                    local bw = bh * 0.6
                    local dist = math.floor((c2.CFrame.Position - root.Position).Magnitude)
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
            end
        else
            hadTarget = false
            if espBox then espBox.Visible = false end
            if espTxt then espTxt.Visible = false end
            if espDot then espDot.Visible = false end
        end
    end)

    if not success then
        errCount = errCount + 1
        if errCount <= 5 then add("ERROR: " .. tostring(err)) end
    end
end)

add("RenderStepped connected")

-- Avatar fix
task.spawn(function()
    add("Avatar fix starting in 3s")
    task.wait(3)
    local char = LP.Character
    add("Avatar fix char: " .. tostring(char))
    if not char then return end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh")
                if m then
                    local mid = tostring(m.MeshId)
                    if mid == "" or mid:find("110937062102535") then
                        acc:Destroy()
                        add("Destroyed broken accessory")
                    end
                end
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:BuildRigFromAttachments(); add("BuildRig OK") end)
    end
    add("Avatar fix done")
end)

LP.CharacterAdded:Connect(function(nc)
    add("Character respawned: " .. tostring(nc))
    task.spawn(function()
        task.wait(3)
        local char = LP.Character
        if not char then return end
        for _, acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local h = acc:FindFirstChild("Handle")
                if h then
                    local m = h:FindFirstChildOfClass("SpecialMesh")
                    if m then
                        local mid = tostring(m.MeshId)
                        if mid == "" or mid:find("110937062102535") then
                            acc:Destroy()
                        end
                    end
                end
            end
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:BuildRigFromAttachments() end) end
    end)
end)

-- UI
local s = Instance.new("ScreenGui")
s.Name = "MDUELv7"; s.ResetOnSpawn = false
s.Parent = LP:WaitForChild("PlayerGui")
local f = Instance.new("Frame")
f.Size = UDim2.new(0, 200, 0, 80)
f.Position = UDim2.new(0, 10, 0, 200)
f.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
f.BackgroundTransparency = 0.2
f.BorderSizePixel = 0
f.Active = true; f.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
f.Parent = s

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 24)
t.BackgroundTransparency = 1
t.Text = "🎯 MDUEL v7"
t.TextColor3 = Color3.fromRGB(200, 200, 255)
t.TextSize = 13; t.Font = Enum.Font.GothamBold
t.Parent = f

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 22)
btn.Position = UDim2.new(0, 10, 0, 28)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
btn.Text = "📋 Show Log"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 11; btn.BorderSizePixel = 0
Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
btn.Parent = f
btn.MouseButton1Click:Connect(function()
    showlog()
end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 18)
status.Position = UDim2.new(0, 10, 0, 54)
status.BackgroundTransparency = 1
status.Text = "● Running | Err: 0"
status.TextColor3 = Color3.fromRGB(50, 255, 100)
status.TextSize = 10; status.Font = Enum.Font.Gotham
status.Parent = f

-- Update status counter
task.spawn(function()
    while task.wait(1) do
        status.Text = "● Running | Err: " .. errCount
    end
end)

add("=== SETUP COMPLETE ===")
warn("[[ MDUEL v7 ]] Inject OK. Click 'Show Log' in UI or check console.")
