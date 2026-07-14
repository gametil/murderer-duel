-- MDUEL v6 — Comprehensive detection pipeline
local RS=game:GetService("RunService")
local LP=game:GetService("Players").LocalPlayer
local WS=game:GetService("Workspace")
local PS=game:GetService("Players")

local cfg={range=350,fov=200,smooth=0.15}
local debugCount=0
local RP_NAMES={["UpperTorso"]=true,["Head"]=true,["HumanoidRootPart"]=true,["LowerTorso"]=true,["Torso"]=true,["Root"]=true,["Hip"]=true}
local sCount={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0}

-- Per-player character monitor for late joiners
PS.PlayerAdded:Connect(function(p)
 p.CharacterAdded:Connect(function(c)
  delay(0.5,function()
   if c and c~=LP.Character then
    local r=rp(c)
    if r then targets[c]=r end
   end
  end)
 end)
end)

-- CharacterAdded listener: when LP changes character (duel start/respawn), rebuild ASAP
LP.CharacterAdded:Connect(function()
buildTick=999
end)

-- Root part finder (7 named roots + any BasePart fallback)
local function rp(m)
 if not m then return nil end
 for _,n in ipairs({"UpperTorso","Head","HumanoidRootPart","LowerTorso","Torso","Root","Hip"})do
  local p=m:FindFirstChild(n)
  if p and p:IsA("BasePart")then return p end
 end
 for _,c in ipairs(m:GetChildren())do if c:IsA("BasePart")then return c end end
 return nil
end

-- Target cache + frame counter for rebuild
local targets,buildTick,frameSkip={},0,0

local function rebuildTargets()
 local built={}
 local selfChar=LP.Character
 local selfName=LP.Name
 for i=1,6 do sCount[i]=0 end
 
 -- Source 1: workspace direct children (standard player placement)
 for _,c in ipairs(WS:GetChildren())do
  if c:IsA("Model")and c~=selfChar and c.Name~=selfName then
   local r=rp(c)
   if r then built[c]=r;sCount[1]=sCount[1]+1 end
  end
 end
 
 -- Source 2: workspace.Characters folder (custom duel rigs)
 local chars=WS:FindFirstChild("Characters")
 if chars then
  for _,c in ipairs(chars:GetChildren())do
   if c:IsA("Model")and c~=selfChar and c.Name~=selfName then
    local r=rp(c)
    if r then built[c]=r;sCount[2]=sCount[2]+1 end
   end
  end
 end
 
 -- Source 3: Players characters + name fallback
 for _,p in ipairs(PS:GetPlayers())do
  if p~=LP then
   local c=p.Character or WS:FindFirstChild(p.Name)or WS:FindFirstChild(p.DisplayName)
   if c and c~=selfChar and c.Name~=selfName and not built[c]then
    local r=rp(c)
    if r then built[c]=r;sCount[3]=sCount[3]+1 end
   end
  end
 end
 
 -- Source 4+6 combined: single GetDescendants pass (BasePart root names + Humanoid)
 for _,p in ipairs(WS:GetDescendants())do
  if p:IsA("BasePart")and RP_NAMES[p.Name]then
   local m=p.Parent
   if m and m:IsA("Model")and m~=selfChar and m.Name~=selfName and not built[m]then
    built[m]=p;sCount[4]=sCount[4]+1
   end
  elseif p:IsA("Humanoid")then
   local m=p.Parent
   if m and m:IsA("Model")and m~=selfChar and m.Name~=selfName and not built[m]then
    local r=rp(m)
    if r then built[m]=r;sCount[6]=sCount[6]+1 end
   end
  end
 end
 
 -- Source 5: All direct-children Folders containing character models (catches alternate names)
 for _,f in ipairs(WS:GetChildren())do
  if f:IsA("Folder")and f.Name~="Characters"then
   for _,c in ipairs(f:GetChildren())do
    if c:IsA("Model")and c~=selfChar and c.Name~=selfName and not built[c]then
     local r=rp(c)
     if r then built[c]=r;sCount[5]=sCount[5]+1 end
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
  
  -- Rebuild every 15 frames (~0.25s); empty-target hot loop prevented by frameSkip
  buildTick=buildTick+1
  if frameSkip>0 then frameSkip=frameSkip-1 end
  if buildTick>=15 or(not next(targets)and frameSkip==0)then rebuildTargets()
   frameSkip=5
   debugCount=debugCount+1
   if debugCount%5==0 then
    local n=0;for _ in pairs(targets)do n=n+1 end
    warn("MDUEL: "..n.." targets (s1:"..sCount[1].." s2:"..sCount[2].." s3:"..sCount[3].." s4:"..sCount[4].." s5:"..sCount[5].." s6:"..sCount[6]..")")
   end
  end
  
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
  
  -- Aim at nearest valid target via UIS MoveMouse (reliable absolute positioning)
  if best then
   local vp=cam:WorldToViewportPoint(best.Position)
   local UIS=game:GetService("UserInputService")
   local tg=Vector2.new(vp.X,vp.Y)
   local cs=UIS:GetMousePosition()
   UIS:MoveMouse(cs+(tg-cs)*cfg.smooth)
  end
 end)
end)
