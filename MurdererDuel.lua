--[[ MDUEL — fresh start, remote-spy + camera aim + ESP ]]
local Players, RS = game:GetService("Players"), game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LP, Range, FOV, Target = Players.LocalPlayer, 200, 150, nil

-- Find throw remote
local ThrowRS = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("ThrowReplicate")
if not ThrowRS then
    for _, v in RS:GetDescendants() do
        if v.Name == "ThrowReplicate" and v:IsA("RemoteEvent") then ThrowRS = v end
    end
end

-- Hook FireServer (richie0866 method, no freeze)
local throwCount, lastArgs = 0
if hookfunction and ThrowRS then
    local fireServ = Instance.new("RemoteEvent").FireServer
    local old = hookfunction(fireServ, function(s, ...)
        if s == ThrowRS then
            throwCount = throwCount + 1; lastArgs = { ... }
            if throwCount <= 3 then warn("[MDUEL] THROW #"..throwCount.." | arg1:", ...) end
        end
        return old(s, ...)
    end)
end

-- Drawings
local bx, tx, dt, fv
pcall(function() bx = Drawing.new("Square") end)
pcall(function() tx = Drawing.new("Text") end)
pcall(function() dt = Drawing.new("Circle") end)
pcall(function() fv = Drawing.new("Circle")
    fv.Visible = true; fv.Color = Color3.fromRGB(255,255,255)
    fv.Transparency = 0.3; fv.Thickness = 1; fv.NumSides = 60; fv.Radius = FOV
end)

local fc, errC, gotTarget = 0, 0, false
RunService.RenderStepped:Connect(function()
    fc = fc + 1; if fc % 2 ~= 0 then return end
    local ok, e = pcall(function()
        local cam = workspace.CurrentCamera; if not cam then return end
        if fv then fv.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2); fv.Visible = FOV > 0 end
        local chr = LP.Character; if not chr then return end
        local hrp = chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        
        local t, cd = nil, math.huge
        for _, p in Players:GetPlayers() do
            if p == LP then continue end
            local c = p.Character; if not c then continue end
            local r = c:FindFirstChild("HumanoidRootPart"); if not r then continue end
            local h = c:FindFirstChildOfClass("Humanoid"); if not h or h.Health <= 0 then continue end
            local d = (hrp.Position - r.Position).Magnitude
            if d < Range and d < cd then t, cd = p, d end
        end
        Target = t

        if t then
            if not gotTarget then warn("[MDUEL] LOCK: "..t.Name.." @"..math.floor(cd).."m"); gotTarget = true end
            local r = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local sp, on = cam:WorldToViewportPoint(r.Position)
                if on and sp.Z > 0 then
                    local cx, cy = cam.ViewportSize.X/2, cam.ViewportSize.Y/2
                    local dfc = math.sqrt((sp.X-cx)^2 + (sp.Y-cy)^2)
                    if FOV == 0 or dfc <= FOV then
                        cam.CFrame = cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position, r.Position), 0.3)
                        if fv then fv.Color = Color3.fromRGB(0,255,0) end
                    else
                        if fv then fv.Color = Color3.fromRGB(255,255,255) end
                    end
                    local head = t.Character:FindFirstChild("Head")
                    if head then
                        local hp = cam:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                        local bh = math.abs(sp.Y - hp.Y) * 1.8
                        local bw = bh * 0.6
                        local dist = math.floor((cam.CFrame.Position - r.Position).Magnitude)
                        if bx then bx.Size = Vector2.new(bw,bh); bx.Position = Vector2.new(sp.X-bw/2,sp.Y-bh/2); bx.Visible = true end
                        if tx then tx.Text = t.Name.." ["..dist.."m]"; tx.Position = Vector2.new(sp.X,sp.Y-bh/2-18); tx.Visible = true end
                        if dt then dt.Position = Vector2.new(sp.X,sp.Y); dt.Visible = true end
                    end
                else
                    if bx then bx.Visible = false end; if tx then tx.Visible = false end; if dt then dt.Visible = false end
                    if fv then fv.Color = Color3.fromRGB(255,255,255) end
                end
            end
        else
            gotTarget = false
            if bx then bx.Visible = false end; if tx then tx.Visible = false end; if dt then dt.Visible = false end
            if fv then fv.Color = Color3.fromRGB(255,255,255) end
        end
    end)
    if not ok then errC = errC + 1; if errC <= 3 then warn("[MDUEL] ERR:", e) end end
end)

-- Avatar fix
local function fixChar()
    local char = LP.Character; if not char then return end
    for _, a in char:GetChildren() do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh")
                if m then
                    local id = tostring(m.MeshId)
                    if id == "" or id:find("110937062102535") then a:Destroy() end
                end
            end
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:BuildRigFromAttachments() end) end
end
task.spawn(function() task.wait(3); fixChar() end)
LP.CharacterAdded:Connect(function() task.spawn(function() task.wait(3); fixChar() end) end)

-- UI
local gui = Instance.new("ScreenGui"); gui.Name = "MDUEL"; gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")
local fr = Instance.new("Frame")
fr.Size = UDim2.new(0, 200, 0, 90); fr.Position = UDim2.new(0, 10, 0, 200)
fr.BackgroundColor3 = Color3.fromRGB(8,8,16); fr.BackgroundTransparency = 0.2
fr.BorderSizePixel = 0; fr.Active = true; fr.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0,6); fr.Parent = gui

local lb = Instance.new("TextLabel")
lb.Size = UDim2.new(1,0,0,20); lb.BackgroundTransparency = 1
lb.Text = "🎯 MDUEL"; lb.TextColor3 = Color3.fromRGB(200,200,255)
lb.TextSize = 13; lb.Font = Enum.Font.GothamBold; lb.Parent = fr

local st = Instance.new("TextLabel")
st.Size = UDim2.new(1,-20,0,16); st.Position = UDim2.new(0,10,0,22)
st.BackgroundTransparency = 1; st.Text = "Range "..Range.."m | FOV "..FOV.."px"
st.TextColor3 = Color3.fromRGB(140,140,180); st.TextSize = 10; st.Font = Enum.Font.Gotham; st.Parent = fr

local b1 = Instance.new("TextButton")
b1.Size = UDim2.new(1,-20,0,20); b1.Position = UDim2.new(0,10,0,42)
b1.BackgroundColor3 = Color3.fromRGB(40,40,60); b1.Text = "📊 Throw Data"
b1.TextColor3 = Color3.fromRGB(255,255,200); b1.TextSize = 11; b1.BorderSizePixel = 0
Instance.new("UICorner").CornerRadius = UDim.new(0,4); b1.Parent = fr
b1.MouseButton1Click:Connect(function()
    if not lastArgs then warn("[MDUEL] Throw a knife first!"); return end
    for i, v in ipairs(lastArgs) do
        warn("  ["..i.."]", v, "["..typeof(v).."]")
        if typeof(v) == "table" then
            for k2, v2 in pairs(v) do warn("    "..k2.."=", v2) end
        end
    end
end)

local b2 = Instance.new("TextButton")
b2.Size = UDim2.new(1,-20,0,20); b2.Position = UDim2.new(0,10,0,65)
b2.BackgroundColor3 = Color3.fromRGB(40,40,60); b2.Text = "📋 Log"
b2.TextColor3 = Color3.fromRGB(255,255,255); b2.TextSize = 11; b2.BorderSizePixel = 0
Instance.new("UICorner").CornerRadius = UDim.new(0,4); b2.Parent = fr

warn("[MDUEL] Ready — throw a knife then click 📊 Throw Data")
