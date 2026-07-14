--[[ Remote Spy — logs all RemoteEvents/RemoteFunctions ]]
local Spy = {log={}, enabled=true, hook={}}
local connections = {}
local output = Instance.new("ScreenGui")
output.Name = "MDUEL_SPY"; output.ResetOnSpawn = false
local f = Instance.new("Frame")
f.Size = UDim2.new(0, 500, 0, 300)
f.Position = UDim2.new(1, -520, 0, 10)
f.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
f.BackgroundTransparency = 0.1; f.BorderSizePixel = 0
f.Active = true; f.Draggable = true
local uc = Instance.new("UICorner"); uc.CornerRadius = UDim.new(0, 8); uc.Parent = f
f.Parent = output

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 28)
bar.BackgroundColor3 = Color3.fromRGB(30, 30, 40); bar.BorderSizePixel = 0
bar.Parent = f
local tl = Instance.new("TextLabel")
tl.Size = UDim2.new(1, -10, 1, 0); tl.Position = UDim2.new(0, 10, 0, 0)
tl.BackgroundTransparency = 1; tl.Text = "🔍 Remote Spy"; tl.TextColor3 = Color3.fromRGB(200, 200, 255)
tl.TextSize = 14; tl.Font = Enum.Font.GothamBold; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = bar

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, -28); list.Position = UDim2.new(0, 0, 0, 28)
list.BackgroundTransparency = 1; list.BorderSizePixel = 0
list.ScrollBarThickness = 4; list.CanvasSize = UDim2.new(0, 0, 0, 0)
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 2); layout.Parent = list
list.Parent = f

local function addLog(text, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 16)
    l.BackgroundTransparency = 0.9; l.BackgroundColor3 = color or Color3.fromRGB(20, 30, 50)
    l.Text = text; l.TextColor3 = Color3.fromRGB(200, 200, 220)
    l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.SourceSans; l.BorderSizePixel = 0; l.Parent = list
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    if list.CanvasSize.Y.Offset > 2000 then
        list:FindFirstChildOfClass("TextLabel"):Destroy()
    end
end

-- Hook all remotes
for _, v in pairs({game:GetService("ScriptContext"), workspace, game:GetService("Players")}) do
    local conn = v.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Spy.hook[obj] = true
            if obj:IsA("RemoteEvent") then
                local c = obj.OnClientEvent:Connect(function(...)
                    if not Spy.enabled then return end
                    local args = {...}
                    Spy.log[obj] = (Spy.log[obj] or 0) + 1
                    local s = obj.ClassName .. " " .. obj.Name
                    if #args > 0 then s = s .. " → " .. tostring(args[1]):sub(1, 40) end
                    addLog(s, Color3.fromRGB(30, 50, 80))
                end)
                table.insert(connections, c)
            else
                local c = obj.OnClientInvoke:Connect(function(...)
                    if not Spy.enabled then return end
                    Spy.log[obj] = (Spy.log[obj] or 0) + 1
                    addLog(obj.ClassName .. " " .. obj.Name .. " (invoked)", Color3.fromRGB(50, 30, 50))
                end)
                table.insert(connections, c)
            end
        end
    end)
    table.insert(connections, conn)
end

-- Hook already existing remotes
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        Spy.hook[obj] = true
        if obj:IsA("RemoteEvent") then
            local c = obj.OnClientEvent:Connect(function(...)
                if not Spy.enabled then return end
                local args = {...}
                Spy.log[obj] = (Spy.log[obj] or 0) + 1
                local s = obj.ClassName .. " " .. obj.Name
                if #args > 0 then s = s .. " → " .. tostring(args[1]):sub(1, 40) end
                addLog(s, Color3.fromRGB(30, 50, 80))
            end)
            table.insert(connections, c)
        else
            local c = obj.OnClientInvoke:Connect(function(...)
                if not Spy.enabled then return end
                Spy.log[obj] = (Spy.log[obj] or 0) + 1
                addLog(obj.ClassName .. " " .. obj.Name .. " (invoked)", Color3.fromRGB(50, 30, 50))
            end)
            table.insert(connections, c)
        end
    end
end

-- Toggle button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 80, 0, 22); toggle.Position = UDim2.new(1, -90, 0, 3)
toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
toggle.Text = "ON"; toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.TextSize = 11; toggle.Font = Enum.Font.GothamBold; toggle.BorderSizePixel = 0
local uc2 = Instance.new("UICorner"); uc2.CornerRadius = UDim.new(0, 4); uc2.Parent = toggle
toggle.Parent = bar
toggle.MouseButton1Click:Connect(function()
    Spy.enabled = not Spy.enabled
    toggle.BackgroundColor3 = Spy.enabled and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(60, 60, 70)
    toggle.Text = Spy.enabled and "ON" or "OFF"
end)

-- Clear button
local clear = Instance.new("TextButton")
clear.Size = UDim2.new(0, 50, 0, 22); clear.Position = UDim2.new(1, -170, 0, 3)
clear.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
clear.Text = "Clear"; clear.TextColor3 = Color3.fromRGB(200, 200, 220)
clear.TextSize = 11; clear.Font = Enum.Font.Gotham; clear.BorderSizePixel = 0
local uc3 = Instance.new("UICorner"); uc3.CornerRadius = UDim.new(0, 4); uc3.Parent = clear
clear.Parent = bar
clear.MouseButton1Click:Connect(function()
    for _, c in ipairs(list:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

output.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
addLog("Spy ready — watching " .. #Spy.hook .. " remotes", Color3.fromRGB(30, 50, 30))

warn("[[ SPY ]] Remote Spy loaded | " .. #Spy.hook .. " remotes hooked")
