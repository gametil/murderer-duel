--[[ Murderer Duel — 4layy Cheat UI Loader ]]
-- 3 working cheats: Aimbot, ESP, Silent Aim

-- Auto-fix avatar white rectangle
spawn(function()
    task.wait(1)
    local char = game:GetService("Players").LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("Accessory") then
            local h = v:FindFirstChild("Handle")
            if h then
                local m = h:FindFirstChildOfClass("SpecialMesh")
                if m and (m.MeshId == "" or m.MeshId == "rbxassetid://0") then
                    v:Destroy()
                end
            end
        end
        if v:IsA("SurfaceGui") or v:IsA("BillboardGui") or v:IsA("Highlight") then
            v:Destroy()
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:BuildRigFromAttachments() end) end
end)

-- UI
local s = Instance.new("ScreenGui"); s.Name = "MDUEL"; s.ResetOnSpawn = false
local m = Instance.new("Frame")
m.Size = UDim2.new(0, 230, 0, 200)
m.Position = UDim2.new(0.5, -115, 0.5, -100)
m.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
m.BorderSizePixel = 0; m.Active = true; m.Draggable = true
Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke").Thickness = 1.5; m.Parent = s
local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0, 36); t.BackgroundTransparency = 1
t.Text = "🎯 Murderer Duel"; t.TextColor3 = Color3.fromRGB(220, 220, 255)
t.TextSize = 18; t.Font = Enum.Font.GothamBold; t.Parent = m
local btnY = 44
local function btn(text, url, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 200, 0, 36); b.Position = UDim2.new(0, 15, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 42, 54)
    b.Text = text; b.TextColor3 = Color3.fromRGB(200, 200, 220)
    b.TextSize = 14; b.Font = Enum.Font.Gotham; b.BorderSizePixel = 0
    Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        b.Text = "✓ LOADING..."; b.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        pcall(function() loadstring(game:HttpGet(url))() end)
        b.Text = "✓ LOADED"; task.wait(1); b.Text = text
        b.BackgroundColor3 = Color3.fromRGB(40, 42, 54)
    end)
    b.Parent = m
end
btn("🎯 Aimbot", "https://raw.githubusercontent.com/DanielHubll/DanielHubll/refs/heads/main/Aimbot%20Mobile", 44)
btn("👁 ESP", "https://raw.githubusercontent.com/4layy/4layy-s-Open-Source-ESP/refs/heads/main/SCRIPT", 88)
btn("🎯 Silent Aim", "https://raw.githubusercontent.com/Averiias/Universal-SilentAim/main/main.lua", 132)
local st = Instance.new("TextLabel")
st.Size = UDim2.new(1, -30, 0, 18); st.Position = UDim2.new(0, 15, 0, 176)
st.BackgroundTransparency = 1; st.Text = "● Press buttons to inject each"
st.TextColor3 = Color3.fromRGB(100, 100, 130); st.TextSize = 10; st.Font = Enum.Font.Gotham; st.Parent = m
s.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
warn("[[ MDUEL ]] Loader ready — click aimbot/ESP buttons")
