-- MDUEL — minimal aimbot (ponytail: no GetDescendants, 60f rebuild)
local RS=game:GetService("RunService")
local LP=game:GetService("Players").LocalPlayer
local WS=game:GetService("Workspace")
local PS=game:GetService("Players")

local cfg={range=350,fov=200,smooth=0.15}
local RP_NAMES={UpperTorso=true,Head=true,HumanoidRootPart=true,LowerTorso=true,Torso=true,Root=true,Hip=true}

-- Character change → rebuild ASAP
LP.CharacterAdded:Connect(function() buildTick=999 end)

-- Root part finder: chest→head→waist→fallbacks
local function rp(m)
 if not m then return nil end
 for _,n in ipairs({"UpperTorso","Head","HumanoidRootPart","LowerTorso","Torso","Root","Hip"})do
  local p=m:FindFirstChild(n)
  if p and p:IsA("BasePart")then return p end
 end
 for _,c in ipairs(m:GetChildren())do if c:IsA("BasePart")then return c end end
 return nil
end

local targets,buildTick={},0

local function rebuildTargets()
 local built={}
 local selfChar=LP.Character
 local selfName=LP.Name

 -- Source 1: workspace direct children
 for _,c in ipairs(WS:GetChildren())do
  if c:IsA("Model")and c~=selfChar and c.Name~=selfName then
   local r=rp(c)
   if r then built[c]=r end
  end
 end

 -- Source 2: workspace.Characters folder
 local chars=WS:FindFirstChild("Characters")
 if chars then
  for _,c in ipairs(chars:GetChildren())do
   if c:IsA("Model")and c~=selfChar and c.Name~=selfName then
    local r=rp(c)
    if r then built[c]=r end
   end
  end
 end

 -- Source 3: Players + name fallback
 for _,p in ipairs(PS:GetPlayers())do
  if p~=LP then
   local c=p.Character or WS:FindFirstChild(p.Name)or WS:FindFirstChild(p.DisplayName)
   if c and c~=selfChar and c.Name~=selfName and not built[c]then
    local r=rp(c)
    if r then built[c]=r end
   end
  end
 end

 -- Source 5: Direct-children Folders (ponytail: no GetDescendants)
 for _,f in ipairs(WS:GetChildren())do
  if f:IsA("Folder")and f.Name~="Characters"then
   for _,c in ipairs(f:GetChildren())do
    if c:IsA("Model")and c~=selfChar and c.Name~=selfName and not built[c]then
     local r=rp(c)
     if r then built[c]=r end
    end
   end
  end
 end

 targets=built
 buildTick=0
end

rebuildTargets()

RS.RenderStepped:Connect(function()
 pcall(function()
  local cam=WS.CurrentCamera
  if not cam then return end
  local char=LP.Character
  if not char then return end
  local hrp=rp(char)
  if not hrp then return end

  -- Rebuild every 60 frames (~1s) — ponytail: less is more
  buildTick=buildTick+1
  if buildTick>=60 or not next(targets)then rebuildTargets()end

  local hp=hrp.Position
  local best,bd=nil,1/0

  for m,r in pairs(targets)do
   if not m.Parent or not r.Parent then targets[m]=nil
   elseif m==char then targets[m]=nil
   else
    local d=(hp-r.Position).Magnitude
    if d<=cfg.range and d<bd then
     local vp,on=cam:WorldToViewportPoint(r.Position)
     if on and vp.Z>0 then
      if cfg.fov==0 or(Vector2.new(vp.X-cam.ViewportSize.X/2,vp.Y-cam.ViewportSize.Y/2)).Magnitude<=cfg.fov then
       best=r;bd=d
      end
     end
    end
   end
  end

  if best then
   local vp=cam:WorldToViewportPoint(best.Position)
   local UIS=game:GetService("UserInputService")
   local tg=Vector2.new(vp.X,vp.Y)
   local cs=UIS:GetMousePosition()
   UIS:MoveMouse(cs+(tg-cs)*cfg.smooth)
  end
 end)
end)
