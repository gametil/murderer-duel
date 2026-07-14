--[[ TEST A: minimal aimbot, no Drawing, no UI, no avatar fix ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()
local Range = 200

RunService.RenderStepped:Connect(function()
    local myChar = LP.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
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
    if target then
        local r = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local sp = Camera:WorldToViewportPoint(r.Position)
            if sp[3] then
                mousemoverel((sp.X - Mouse.X) * 0.7, (sp.Y - Mouse.Y) * 0.7)
            end
        end
    end
end)
