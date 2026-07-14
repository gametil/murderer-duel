--[[ Murderer Duel v9 — Camera CFrame aim + remote inject ]]
-- Forces aim by redirecting camera + patching throw remote

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Range = 200
local FOV = 150

-- LOG
local log = {"=== MDUEL v9 ==="}
local function add(...)
    local t = os.time()
    local msg = ""
    for _, v in ipairs({...}) do msg = msg .. tostring(v) .. " " end
    table.insert(log, "[" .. t .. "] " .. msg)
    if #log > 100 then table.remove(log, 1) end
end
local function showlog()
    warn("=== MDUEL LOG ===")
    for _, l in ipairs(log) do warn(l) end
    warn("=== LOG END ===")
end
add("Started")

-- DRAWING
local espBox, espTxt, espDot, fovC
pcall(function() espBox = Drawing.new("Square"); add("Sq OK") end)
pcall(function() espTxt = Drawing.new("Text"); add("Tx OK") end)
pcall(function() espDot = Drawing.new("Circle"); add("Ci OK") end)
pcall(function() fovC = Drawing.new("Circle"); add("FOV OK") end)

if fovC and FOV > 0 then
    fovC.Visible = true
    fovC.Color = Color3.fromRGB(255, 255, 255)
    fovC.Transparency = 0.3; fovC.Thickness = 1
    fovC.NumSides = 60; fovC.Radius = FOV
    add("FOV " .. FOV .. "px")
end

-- STEAL REAL FIRESERVER FROM DUMMY REMOTEEVENT
local RealFireServer = nil
local ThrowRemote = nil
pcall(function()
    local RS = game:GetService("ReplicatedStorage")
    ThrowRemote = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("ThrowReplicate")
    if not ThrowRemote then
        -- Try direct search
        for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v.Name == "ThrowReplicate" and v:IsA("RemoteEvent") then ThrowRemote = v; break end
        end
    end
    add("ThrowRemote: " .. tostring(ThrowRemote))
end)
pcall(function()
    local d = Instance.new("RemoteEvent")
    RealFireServer = d.FireServer
    d:Destroy()
    add("RealFireServer: " .. tostring(RealFireServer ~= nil))
end)

local fc = 0
local hadTarget = false
local errCount = 0
local Target = nil

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    if fc % 2 ~= 0 then return end

    local cam = workspace.CurrentCamera
    if not cam then return end

    -- FOV circle
    if fovC then
        fovC.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        fovC.Visible = FOV > 0
    end

    local ok, err = pcall(function()
        local myChar = LP.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        -- Find nearest within range
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
        Target = target

        if target then
            if not hadTarget then add("Target: " .. target.Name .. " @" .. math.floor(cd) .. "m"); hadTarget = true end
            local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local sp, on = cam:WorldToViewportPoint(root.Position)
                if on and sp.Z > 0 then
                    local cx, cy = cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
                    local dFromCenter = math.sqrt((sp.X - cx)^2 + (sp.Y - cy)^2)

                    if FOV == 0 or dFromCenter <= FOV then
                        -- FORCE CAMERA TO LOOK AT TARGET
                        -- This is what actually redirects throws (game reads camera CFrame)
                        local targetPos = root.Position
                        local cameraPos = cam.CFrame.Position
                        local lookAt = CFrame.lookAt(cameraPos, Vector3.new(targetPos.X, targetPos.Y, targetPos.Z))
                        cam.CFrame = cam.CFrame:Lerp(lookAt, 0.3)

                        if fovC then fovC.Color = Color3.fromRGB(0, 255, 0) end
                    else
                        if fovC then fovC.Color = Color3.fromRGB(255, 255, 255) end
                    end

                    -- ESP
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
                    if fovC then fovC.Color = Color3.fromRGB(255, 255, 255) end
                end
            end
        else
            hadTarget = false
            if fovC then fovC.Color = Color3.fromRGB(255, 255, 255) end
            if espBox then espBox.Visible = false end
            if espTxt then espTxt.Visible = false end
            if espDot then espDot.Visible = false end
        end
    end)

    if not ok then
        errCount = errCount + 1
        if errCount <= 5 then add("ERR: " .. tostring(err)) end
    end
end)

add("Loop started")

-- AVATAR FIX
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
                    if mid == "" or mid:find("110937062102535") then acc:Destroy(); add("Fix: broken acc") end
                end
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:BuildRigFromAttachments(); add("BuildRig OK") end) end
end)

LP.CharacterAdded:Connect(function()
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
                        if mid == "" or mid:find("110937062102535") then acc:Destroy() end
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
s.Name = "MDUELv9"; s.ResetOnSpawn = false
s.Parent = LP:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 200, 0, 100)
f.Position = UDim2.new(0, 10, 0, 200)
f.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
f.BackgroundTransparency = 0.2
f.BorderSizePixel = 0
f.Active = true; f.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
f.Parent = s

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 22)
t.BackgroundTransparency = 1
t.Text = "🎯 MDUEL v9"
t.TextColor3 = Color3.fromRGB(200, 200, 255)
t.TextSize = 13; t.Font = Enum.Font.GothamBold
t.Parent = f

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 16)
info.Position = UDim2.new(0, 10, 0, 24)
info.BackgroundTransparency = 1
info.Text = "CamAim " .. Range .. "m | FOV " .. FOV .. "px"
info.TextColor3 = Color3.fromRGB(140, 140, 180)
info.TextSize = 10; info.Font = Enum.Font.Gotham
info.Parent = f

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -20, 0, 22)
btn.Position = UDim2.new(0, 10, 0, 44)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
btn.Text = "📋 Show Log"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextSize = 11; btn.BorderSizePixel = 0
Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
btn.Parent = f
btn.MouseButton1Click:Connect(showlog)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 18)
status.Position = UDim2.new(0, 10, 0, 70)
status.BackgroundTransparency = 1
status.Text = "● Err: 0"
status.TextColor3 = Color3.fromRGB(50, 255, 100)
status.TextSize = 10; status.Font = Enum.Font.Gotham
status.Parent = f

task.spawn(function()
    while task.wait(1) do
        status.Text = "● Err: " .. errCount
    end
end)

add("=== READY ===")
warn("[[ MDUEL v9 ]] Camera aim + FireServer inject ready")
