local RS=game:GetService("RunService")
local LP=game:GetService("Players").LocalPlayer
local WS=game:GetService("Workspace")

local range=350; local fov=200; local smooth=0.15

local chars=WS:FindFirstChild("Characters")
if not chars then return end

RS.RenderStepped:Connect(function()
 pcall(function()
  local cam=WS.CurrentCamera
  if not cam then return end
  local char=LP.Character
  if not char then return end
  local hrp=char:FindFirstChild("HumanoidRootPart")or char:FindFirstChild("UpperTorso")or char:FindFirstChild("LowerTorso")or char:FindFirstChild("Torso")
  if not hrp then return end
  local hp=hrp.Position
  local best,bd=nil,1/0
  for _,c in ipairs(chars:GetChildren()) do
   if c~=char then
    local r=c:FindFirstChild("HumanoidRootPart")or c:FindFirstChild("UpperTorso")or c:FindFirstChild("LowerTorso")or c:FindFirstChild("Torso")
    if r then
     local d=(hp-r.Position).Magnitude
     if d<range and d<bd then
      local vp,on=cam:WorldToViewportPoint(r.Position)
      if on and vp.Z>0 and(fov==0 or(Vector2.new(vp.X-cam.ViewportSize.X/2,vp.Y-cam.ViewportSize.Y/2)).Magnitude<=fov)then
       best=r;bd=d
      end
     end
    end
   end
  end
  if best then cam.CFrame=cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position,best.Position),smooth)end
 end)
end)
