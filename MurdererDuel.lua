-- MDUEL (ultra simple)
local RS = game:GetService("RunService")
local LP = game:GetService("Players").LocalPlayer
local WS = game:GetService("Workspace")
local HUGE = 1/0

local setting = {range=350,fov=200,smooth=0.15,on=true}
local lt, ln = nil, ""

-- Find any BasePart in model (by known names or first part)
local function rp(m)
 for _,n in ipairs({"HumanoidRootPart","UpperTorso","LowerTorso","Torso","Root","Hip"}) do
  local p = m:FindFirstChild(n)
  if p and p:IsA("BasePart") then return p end
 end
 for _,c in ipairs(m:GetChildren()) do if c:IsA("BasePart") then return c end end
 return nil
end

local chars = WS:FindFirstChild("Characters")
if not chars then return end

RS.RenderStepped:Connect(function()
 pcall(function()
  local cam = WS.CurrentCamera
  if not cam or not setting.on then return end
  local char = LP.Character
  if not char then return end
  local hrp = rp(char)
  if not hrp then return end

  local best, bd = nil, HUGE
  local sp = hrp.Position
  for _, c in ipairs(chars:GetChildren()) do
   if c ~= char then
    local r = rp(c)
    if r then
     local d = (sp - r.Position).Magnitude
     if d < setting.range and d < bd then best, bd = r, d; ln = c.Name end
    end
   end
  end
  if best then lt = best else lt = nil end

  if lt then
   local vp, on = cam:WorldToViewportPoint(lt.Position)
   if on and vp.Z > 0 then
    if setting.fov == 0 or (Vector2.new(vp.X-cam.ViewportSize.X/2,vp.Y-cam.ViewportSize.Y/2)).Magnitude <= setting.fov then
     cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, lt.Position), setting.smooth)
    end
   end
  end
 end)
end)
