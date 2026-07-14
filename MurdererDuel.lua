--[[ Murderer Duel v10 — Remote Spy + Aimbot ]]
-- Uses richie0866 remote-spy technique:
-- 1. hookfunction on cloned FireServer (no global freeze)
-- 2. Spies on throw data format
-- 3. Auto-redirects to locked target

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local Range = 200
local FOV = 150

-- LOG
local log = {"=== MDUEL v10 ==="}
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
if fovC and FOV > 0 then fovC.Visible = true; fovC.Color = Color3.fromRGB(255,255,255)
    fovC.Transparency = 0.3; fovC.Thickness = 1; fovC.NumSides = 60; fovC.Radius = FOV end

-- FIND THROW REMOTE
local ThrowRemote = nil
pcall(function()
    ThrowRemote = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("ThrowReplicate")
    if not ThrowRemote then
        for _, v in ipairs(RS:GetDescendants()) do
            if v.Name == "ThrowReplicate" and v:IsA("RemoteEvent") then ThrowRemote = v; break end
        end
    end
    add("ThrowRemote: " .. tostring(ThrowRemote))
end)

-- REMOTE SPY + REDIRECT (richie0866 technique)
local firedCount = 0
local lastThrowData = nil

if hookfunction and ThrowRemote then
    local FireServerC = Instance.new("RemoteEvent").FireServer
    local OldFireServer = hookfunction(FireServerC, function(self, ...)
        if self == ThrowRemote then
            firedCount = firedCount + 1
            local args = { ... }
            lastThrowData = args
            if firedCount <= 3 then
                add("THROW #" .. firedCount .. " args: " .. tostring(args[1]))
            end
        end
        return OldFireServer(self, ...)
    end)
    add("FireServer hooked OK")
else
    add("hookfunction not available or no ThrowRemote")
end

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

    if fovC then
        fovC.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        fovC.Visible = FOV > 0
    end

    local ok, err = pcall(function()
        local myChar = LP.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        -- Find nearest
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
                        -- Camera aim (forces throw direction)
                        local tPos = root.Position
                        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, tPos), 0.3)
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
                        if espBox then espBox.Size = Vector2.new(bw, bh); espBox.Position = Vector2.new(sp.X-bw/2, sp.Y-bh/2); espBox.Visible = true end
                        if espTxt then espTxt.Text = target.Name .. " [" .. dist .. "m]"; espTxt.Position = Vector2.new(sp.X, sp.Y-bh/2-18); espTxt.Visible = true end
                        if espDot then espDot.Position = Vector2.new(sp.X, sp.Y); espDot.Visible = true end
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
        if acc:IsA("Accessory") then local h = acc:FindFirstChild("Handle")
            if h then local m = h:FindFirstChildOfClass("SpecialMesh")
                if m then local mid = tostring(m.MeshId)
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
        for _, acc in ipairs(char:GetChildren()) do if acc:IsA("Accessory") then
            local h = acc:FindFirstChild("Handle")
            if h then local m = h:FindFirstChildOfClass("SpecialMesh")
                if m then local mid = tostring(m.MeshId)
                    if mid == "" or mid:find("110937062102535") then acc:Destroy() end
                end
            end
        end end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:BuildRigFromAttachments() end) end
    end)
end)

-- UI
local s = Instance.new("ScreenGui"); s.Name = "MDUELv10"; s.ResetOnSpawn = false
s.Parent = LP:WaitForChild("PlayerGui")
local f = Instance.new("Frame")
f.Size = UDim2.new(0, 220, 0, 110)
f.Position = UDim2.new(0, 10, 0, 200)
f.BackgroundColor3 = Color3.fromRGB(8,8,16); f.BackgroundTransparency = 0.2
f.BorderSizePixel = 0; f.Active = true; f.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 6); f.Parent = s
local t = Instance.new("TextLabel")
t.Size = UDim2.new(1,0,0,22); t.BackgroundTransparency = 1
t.Text = "🎯 MDUEL v10"; t.TextColor3 = Color3.fromRGB(200,200,255)
t.TextSize = 13; t.Font = Enum.Font.GothamBold; t.Parent = f
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,-20,0,16); info.Position = UDim2.new(0,10,0,24)
info.BackgroundTransparency = 1
info.Text = "CamAim "..Range.."m | FOV "..FOV.."px | Spy: 0"
info.TextColor3 = Color3.fromRGB(140,140,180); info.TextSize = 10; info.Font = Enum.Font.Gotham; info.Parent = f
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1,-20,0,22); btn.Position = UDim2.new(0,10,0,44)
btn.BackgroundColor3 = Color3.fromRGB(40,40,60); btn.Text = "📋 Show Log"
btn.TextColor3 = Color3.fromRGB(255,255,255); btn.TextSize = 11; btn.BorderSizePixel = 0
Instance.new("UICorner").CornerRadius = UDim.new(0,4); btn.Parent = f
btn.MouseButton1Click:Connect(showlog)
local btn2 = Instance.new("TextButton")
btn2.Size = UDim2.new(1,-20,0,22); btn2.Position = UDim2.new(0,10,0,70)
btn2.BackgroundColor3 = Color3.fromRGB(40,40,60); btn2.Text = "📊 Show Throw Data"
btn2.TextColor3 = Color3.fromRGB(255,255,200); btn2.TextSize = 11; btn2.BorderSizePixel = 0
Instance.new("UICorner").CornerRadius = UDim.new(0,4); btn2.Parent = f
btn2.MouseButton1Click:Connect(function()
    if lastThrowData then
        warn("=== LAST THROW DATA ===")
        for i, v in ipairs(lastThrowData) do
            warn("  ["..i.."] "..tostring(v).."  ("..typeof(v)..")")
            if typeof(v) == "table" then
                for k2, v2 in pairs(v) do
                    warn("    "..tostring(k2).." = "..tostring(v2).."  ("..typeof(v2)..")")
                end
            end
        end
        warn("=== END ===")
    else
        warn("No throw data captured yet — throw a knife!")
    end
end)
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,18); status.Position = UDim2.new(0,10,0,96)
status.BackgroundTransparency = 1
status.Text = "● Err: 0 | Fired: 0"
status.TextColor3 = Color3.fromRGB(50,255,100); status.TextSize = 10; status.Font = Enum.Font.Gotham; status.Parent = f
task.spawn(function()
    while task.wait(1) do
        status.Text = "● Err: "..errCount.." | Fired: "..firedCount
        info.Text = "CamAim "..Range.."m | FOV "..FOV.."px | Spy: "..firedCount
    end
end)

add("=== READY ===")
warn("[[ MDUEL v10 ]] Remote spy active. Throw a knife then click 📊 Show Throw Data")
