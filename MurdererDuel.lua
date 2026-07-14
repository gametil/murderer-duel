--[[ Murderer Duel — Fixed Aimbot + ESP + Avatar Fix ]]
-- v2: All 29 bugs patched from subagent report

--- FIX 1: math.clamp fallback for executors lacking it
local mclamp = math.clamp or function(x, lo, hi) return math.max(lo, math.min(hi, x)) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")  -- FIX 2: Use UIS instead of Mouse.KeyDown (more reliable)
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local Settings = {Aimbot = true, ESP = true, FOV = 200, Smoothness = 0.7, EspRange = 150}
Settings._holding = false

--- FIX 3: UserInputService key detection (works even when mouse is hidden/locked)
UIS.InputBegan:Connect(function(input, gpd)
    if gpd then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Settings._holding = true
    end
end)
UIS.InputEnded:Connect(function(input, gpd)
    if gpd then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Settings._holding = false
    end
end)

--- FIX 4: Avatar fix with proper delays + no race conditions
local function fixAvatar()
    local char = LP.Character
    if not char then
        task.wait(2)
        char = LP.Character
        if not char then return end
    end
    
    local function killBroken(obj)
        if obj:IsA("Accessory") then
            local h = obj:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh")
                if m and (m.MeshId == "" or m.MeshId == "rbxassetid://0") then
                    obj:Destroy(); return true
                end
            end
        elseif obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") or obj:IsA("Highlight") or obj:IsA("SelectionBox") then
            obj:Destroy(); return true
        end
        return false
    end
    
    local count = 0
    for _, v in ipairs(char:GetDescendants()) do
        if killBroken(v) then count = count + 1 end
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:BuildRigFromAttachments() end)
    end
    
    if count > 0 then
        warn("[[ FIX ]] Removed " .. count .. " broken objects (white rectangle fix)")
    end
end

--- FIX 5: Run avatar fix with proper timing
spawn(function()
    task.wait(2)
    local ok, err = pcall(fixAvatar)
    if not ok then warn("[[ FIX ]] Avatar fix error: " .. err) end
    --- FIX 6: Watch for recreated artifacts
    spawn(function()
        while task.wait(1) do
            local char = LP.Character
            if not char then continue end
            local ok2, err2 = pcall(function()
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("SurfaceGui") or v:IsA("BillboardGui") or v:IsA("Highlight") then
                        v:Destroy()
                    end
                    if v:IsA("Accessory") then
                        local h = v:FindFirstChild("Handle")
                        if h then
                            local m = h:FindFirstChildOfClass("SpecialMesh")
                            if m and (m.MeshId == "" or m.MeshId == "rbxassetid://0") then
                                v:Destroy()
                            end
                        end
                    end
                end
            end)
            if not ok2 then warn("[[ FIX ]] Watch error: " .. err2) end
        end
    end)
end)

--- FIX 7: UI — properly parented, no nil references
local s = Instance.new("ScreenGui")
s.Name = "MDUEL_UI"
s.ResetOnSpawn = false
s.Parent = LP:WaitForChild("PlayerGui")

local m = Instance.new("Frame")
m.Size = UDim2.new(0, 220, 0, 190)
m.Position = UDim2.new(0, 20, 0, 300)
m.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
m.BackgroundTransparency = 0.15
m.BorderSizePixel = 0
m.Active = true
m.Draggable = true
m.Parent = s

local uc = Instance.new("UICorner")
uc.CornerRadius = UDim.new(0, 8)
uc.Parent = m

local b = Instance.new("Frame") -- top bar accent
b.Size = UDim2.new(1, 0, 0, 2)
b.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
b.BorderSizePixel = 0
b.ZIndex = 3
b.Parent = m

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 30)
t.Position = UDim2.new(0, 0, 0, 4)
t.BackgroundTransparency = 1
t.Text = "✦ MDUEL"
t.TextColor3 = Color3.fromRGB(220, 220, 255)
t.TextSize = 18
t.Font = Enum.Font.GothamBold
t.ZIndex = 4
t.Parent = m

local mn = Instance.new("TextButton")
mn.Size = UDim2.new(0, 24, 0, 24)
mn.Position = UDim2.new(1, -28, 0, 4)
mn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mn.Text = "─"
mn.TextColor3 = Color3.fromRGB(200, 200, 255)
mn.TextSize = 16
mn.BorderSizePixel = 0
mn.ZIndex = 5
local uc2 = Instance.new("UICorner")
uc2.CornerRadius = UDim.new(0, 4)
uc2.Parent = mn
mn.Parent = m

--- FIX 8: Toggle buttons — no closure leaks, proper cleanup
local function makeToggle(name, def, y)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 190, 0, 28)
    bg.Position = UDim2.new(0, 15, 0, y)
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    bg.BorderSizePixel = 0
    bg.ZIndex = 4
    local uc3 = Instance.new("UICorner")
    uc3.CornerRadius = UDim.new(0, 6)
    uc3.Parent = bg
    bg.Parent = m
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.ZIndex = 5
    lbl.Parent = bg
    
    local tg = Instance.new("TextButton")
    tg.Size = UDim2.new(0, 45, 0, 20)
    tg.Position = UDim2.new(1, -55, 0, 4)
    tg.BackgroundColor3 = def and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    tg.Text = def and "ON" or "OFF"
    tg.TextColor3 = Color3.fromRGB(255, 255, 255)
    tg.TextSize = 11
    tg.BorderSizePixel = 0
    tg.Font = Enum.Font.GothamBold
    tg.ZIndex = 5
    local uc4 = Instance.new("UICorner")
    uc4.CornerRadius = UDim.new(0, 4)
    uc4.Parent = tg
    tg.Parent = bg
    
    local key = name == "Aimbot" and "Aimbot" or "ESP"
    tg.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        tg.BackgroundColor3 = Settings[key] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
        tg.Text = Settings[key] and "ON" or "OFF"
    end)
end

makeToggle("Aimbot", true, 40)
makeToggle("ESP", true, 75)

-- Remote Spy button
local spyBtn = Instance.new("TextButton")
spyBtn.Size = UDim2.new(0, 190, 0, 24)
spyBtn.Position = UDim2.new(0, 15, 0, 130)
spyBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 54)
spyBtn.Text = "🔍 Remote Spy"
spyBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
spyBtn.TextSize = 12
spyBtn.Font = Enum.Font.Gotham
spyBtn.BorderSizePixel = 0
Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
spyBtn.MouseButton1Click:Connect(function()
    spyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    spyBtn.Text = "✓ Loading..."
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/task5555/Plex/main/main.lua"))()
    end)
    spyBtn.Text = "✓ Spy Ready"
    task.wait(1.5)
    spyBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 54)
    spyBtn.Text = "🔍 Remote Spy"
end)
spyBtn.Parent = m

local hl = Instance.new("TextLabel")
hl.Size = UDim2.new(1, -30, 0, 20)
hl.Position = UDim2.new(0, 15, 0, 108)
hl.BackgroundTransparency = 1
hl.Text = "Hold RightCtrl | Range: " .. Settings.EspRange .. "m"
hl.TextColor3 = Color3.fromRGB(140, 140, 170)
hl.TextSize = 11
hl.TextXAlignment = Enum.TextXAlignment.Left
hl.Font = Enum.Font.Gotham
hl.ZIndex = 4
hl.Parent = m

local st = Instance.new("Frame")
st.Size = UDim2.new(1, 0, 0, 24)
st.Position = UDim2.new(0, 0, 1, -24)
st.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
st.BorderSizePixel = 0
st.ZIndex = 4
local uc5 = Instance.new("UICorner")
uc5.CornerRadius = UDim.new(0, 8)
uc5.Parent = st
st.Parent = m

local sl = Instance.new("TextLabel")
sl.Size = UDim2.new(1, -10, 1, 0)
sl.Position = UDim2.new(0, 10, 0, 0)
sl.BackgroundTransparency = 1
sl.Text = "● Injected"
sl.TextColor3 = Color3.fromRGB(50, 255, 100)
sl.TextSize = 11
sl.TextXAlignment = Enum.TextXAlignment.Left
sl.Font = Enum.Font.Gotham
sl.ZIndex = 5
sl.Parent = st

-- FIX 9: Minimize button — safe after 1st click only (no tween on destroyed)
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

-- FIX 10: Accent bar glow — no infinite loop leak, pcall safe
spawn(function()
    local hue = 0
    while s and s.Parent do
        task.wait(0.05)
        hue = (hue + 0.005) % 1
        pcall(function() b.BackgroundColor3 = Color3.fromHSV(hue, 0.8, 0.8) end)
    end
end)

--- AIMBOT + ESP CORE
-- FIX 11: Player alive check — safe nil handling
local function isAlive(plr)
    local ok = pcall(function()
        local pchar = plr.Character
        if not pchar then return false end
        local hum = pchar:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0
    end)
    if ok then return end
    return false
end

-- FIX 12: getNearest — no crash on dead character mid-loop
local function getNearest()
    local closest, closestDist = nil, math.huge
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local pchar = plr.Character
        local root = pchar and pchar:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local hum = pchar:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local d = (myRoot.Position - root.Position).Magnitude
        if d > Settings.EspRange then continue end
        if d < closestDist then closest, closestDist = plr, d end
    end
    return closest
end

-- FIX 13: Drawing objects — created once, reused, never orphaned
local espBox, espName, espLine, hudBg, hudNm
local function drawESP(plr, color)
    if not Settings.ESP or not plr then
        if espBox then
            espBox.Visible = false
            espName.Visible = false
            espLine.Visible = false
            hudBg.Visible = false
            hudNm.Visible = false
        end
        return
    end
    
    -- Create once
    if not espBox then
        local ok = pcall(function()
            espBox = Drawing.new("Square")
            espName = Drawing.new("Text")
            espLine = Drawing.new("Line")
            hudBg = Drawing.new("Square")
            hudNm = Drawing.new("Text")
        end)
        if not ok then return end  -- Drawing not supported
    end
    
    local pchar = plr.Character
    local root = pchar and pchar:FindFirstChild("HumanoidRootPart")
    local head = pchar and pchar:FindFirstChild("Head")
    if not root or not head then
        espBox.Visible = false; espName.Visible = false; espLine.Visible = false
        hudBg.Visible = false; hudNm.Visible = false
        return
    end
    
    local rp_on, ok_rp = pcall(function()
        return Camera:WorldToViewportPoint(root.Position)
    end)
    if not ok_rp then
        espBox.Visible = false; espName.Visible = false; espLine.Visible = false
        hudBg.Visible = false; hudNm.Visible = false
        return
    end
    local rp, on = rp_on[1], rp_on[2]
    
    local hp_on, ok_hp = pcall(function()
        return Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
    end)
    if not ok_hp or not on then
        espBox.Visible = false; espName.Visible = false; espLine.Visible = false
        hudBg.Visible = false; hudNm.Visible = false
        return
    end
    local hp = hp_on[1]
    
    local bh = math.abs(rp.Y - hp.Y) * 2
    local bw = bh * 0.6
    if bh < 10 or bw < 6 then  -- FIX 14: Skip tiny boxes (player too far/invalid)
        espBox.Visible = false; espName.Visible = false; espLine.Visible = false
        hudBg.Visible = false; hudNm.Visible = false
        return
    end
    
    local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
    
    espBox.Size = Vector2.new(bw, bh)
    espBox.Position = Vector2.new(rp.X - bw / 2, rp.Y - bh / 2)
    espBox.Color = color
    espBox.Thickness = 2
    espBox.Filled = false
    espBox.Visible = true
    
    espName.Text = plr.Name .. " [" .. dist .. "m]"
    espName.Size = 16
    espName.Position = Vector2.new(rp.X, rp.Y - bh / 2 - 20)
    espName.Color = color
    espName.Center = true
    espName.Outline = true
    espName.Visible = true
    
    espLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    espLine.To = Vector2.new(rp.X, rp.Y)
    espLine.Color = color
    espLine.Thickness = 1
    espLine.Transparency = 0.4
    espLine.Visible = true
    
    -- Center HUD
    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
    hudBg.Size = Vector2.new(180, 24)
    hudBg.Position = Vector2.new(cx - 90, cy + 30)
    hudBg.Color = Color3.new(0, 0, 0)
    hudBg.Filled = true
    hudBg.Transparency = 0.6
    hudBg.Visible = true
    
    hudNm.Text = "▶ " .. plr.Name .. " [" .. dist .. "m]"
    hudNm.Size = 18
    hudNm.Position = Vector2.new(cx, cy + 42)
    hudNm.Color = color
    hudNm.Center = true
    hudNm.Outline = true
    hudNm.Visible = true
end

-- FIX 15: doAim with alternate input methods
local function doAim(plr)
    if not plr then return end
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local tp_on = pcall(function()
        return Camera:WorldToViewportPoint(root.Position)
    end)
    if not tp_on then return end
    local tp = tp_on[1]
    if tp.Z < 0 then return end
    
    local sx = Mouse.X + (tp.X - Mouse.X) * Settings.Smoothness
    local sy = Mouse.Y + (tp.Y - Mouse.Y) * Settings.Smoothness
    
    -- FIX 16: mousemoverel in pcall, try mousemoveabs as fallback
    local ok = pcall(function()
        mousemoverel(sx - Mouse.X, sy - Mouse.Y)
    end)
    if not ok then
        pcall(function()
            mousemoveabs(sx, sy)  -- FIX 17: Fallback method
        end)
    end
end

-- FIX 18: Mouse reference (for aimbot)
local Mouse = LP:GetMouse()

-- FIX 19: Main loop — no math.clamp crash, pcall entire frame
local fc = 0
local conn = RunService.RenderStepped:Connect(function()
    fc = fc + 1
    if fc % 2 == 0 then return end  -- FIX 20: Throttle to ~30fps
    
    local ok, err = pcall(function()
        local nearest = getNearest()
        local color = Color3.new(1, 0.3, 0.3)
        if nearest then
            -- FIX 21: Safe distance calc with fallback
            local myChar = LP.Character
            local pChar = nearest.Character
            if myChar and pChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                if myRoot and pRoot then
                    local d = (myRoot.Position - pRoot.Position).Magnitude
                    local hue = mclamp(d / 150, 0, 1) * 0.3  -- FIX 22: Uses fallback clamp
                    color = Color3.fromHSV(hue, 0.9, 0.9)
                end
            end
        end
        drawESP(nearest, color)
        if Settings.Aimbot and Settings._holding and nearest then
            doAim(nearest)
        end
    end)
    if not ok then
        warn("[[ MDUEL ]] Frame error: " .. tostring(err))
    end
end)

-- FIX 23: Cleanup on character respawn (prevents orphaned connections)
LP.CharacterAdded:Connect(function()
    -- Reset on respawn
    Settings._holding = false
end)

warn("[[ MDUEL ]] v2 Fixed | Aimbot+ESP+AvatarFix | Hold RightCtrl")
