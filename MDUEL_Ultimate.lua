-- MDUEL Ultimate — silent aim + mousemoverel aimbot + ESP
-- Combined: gametil/murderer-duel
-- Sources: mitka1337 silent aim, ic3w0lf22/Unnamed-ESP drawing

local RS=game:GetService("RunService")
local LP=game:GetService("Players").LocalPlayer
local WS=game:GetService("Workspace")
local PS=game:GetService("Players")
local UIS=game:GetService("UserInputService")

-- Config
local cfg={
 range=350,fov=200,smooth=0.15,
 silent=true,esp=true,teamCheck=false,
 esp_color_enemy=Color3.new(1,0,0),
 esp_color_team=Color3.new(0,1,0)
}

-- Root part names in priority order
local RP_NAMES={UpperTorso=true,Head=true,HumanoidRootPart=true,LowerTorso=true,Torso=true,Root=true,Hip=true}
local RP_LIST={"UpperTorso","Head","HumanoidRootPart","LowerTorso","Torso","Root","Hip"}

-- Root part finder
local function rp(m)
 if not m then return nil end
 for _,n in ipairs(RP_LIST)do
  local p=m:FindFirstChild(n)
  if p and p:IsA("BasePart")then return p end
 end
 for _,c in ipairs(m:GetChildren())do if c:IsA("BasePart")then return c end end
 return nil
end

-- Target cache
local targets,buildTick,aimPos={},0,Vector2.new()

LP.CharacterAdded:Connect(function()buildTick=999 end)

local function rebuildTargets()
 local built={}
 local selfChar=LP.Character
 local selfName=LP.Name
 for _,c in ipairs(WS:GetChildren())do
  if c:IsA("Model")and c~=selfChar and c.Name~=selfName then
   local r=rp(c)
   if r then built[c]=r end
  end
 end
 local chars=WS:FindFirstChild("Characters")
 if chars then
  for _,c in ipairs(chars:GetChildren())do
   if c:IsA("Model")and c~=selfChar and c.Name~=selfName then
    local r=rp(c)
    if r then built[c]=r end
   end
  end
 end
 for _,p in ipairs(PS:GetPlayers())do
  if p~=LP then
   local c=p.Character or WS:FindFirstChild(p.Name)or WS:FindFirstChild(p.DisplayName)
   if c and c~=selfChar and c.Name~=selfName and not built[c]then
    local r=rp(c)
    if r then built[c]=r end
   end
  end
 end
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
 targets=built;buildTick=0
end

rebuildTargets()

-- Get closest target for silent aim
local function getClosestTarget()
 local cam=WS.CurrentCamera
 if not cam then return nil end
 local char=LP.Character
 if not char then return nil end
 local hrp=rp(char)
 if not hrp then return nil end
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
 return best
end

--- SILENT AIM — hook __namecall for Raycast/FindPartOnRay
if cfg.silent then
 local oldNamecall
 oldNamecall=hookmetamethod(game,"__namecall",function(...)
  local method=getnamecallmethod()
  local args={...}
  local self=args[1]
  
  if(self==WS or self==WS.Terrain)and cfg.silent then
   local target=getClosestTarget()
   if target then
    if method=="Raycast"and #args>=3 then
     args[3]=(target.Position-args[2]).Unit*1000
     return oldNamecall(unpack(args))
    elseif(method=="FindPartOnRayWithIgnoreList"or method=="FindPartOnRayWithWhitelist")and #args>=3 then
     local ray=args[2]
     args[2]=Ray.new(ray.Origin,(target.Position-ray.Origin).Unit*1000)
     return oldNamecall(unpack(args))
    elseif(method=="FindPartOnRay"or method=="findPartOnRay")and #args>=2 then
     local ray=args[2]
     args[2]=Ray.new(ray.Origin,(target.Position-ray.Origin).Unit*1000)
     return oldNamecall(unpack(args))
    end
   end
  end
  return oldNamecall(...)
 end)
end

--- MOUSEMOVEREL AIMBOT (fallback)
RS.RenderStepped:Connect(function()
 pcall(function()
  local cam=WS.CurrentCamera
  if not cam then return end
  local char=LP.Character
  if not char then return end
  local hrp=rp(char)
  if not hrp then return end
  
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
   local tg=Vector2.new(vp.X,vp.Y)
   local prev=aimPos
   aimPos=prev+(tg-prev)*cfg.smooth
   mousemoverel(aimPos.X-prev.X,aimPos.Y-prev.Y)
  end
 end)
end)

--- ESP
if cfg.esp and Drawing then
 local espObjects={}
 
 local function createESP(player)
  if player==LP then return end
  if espObjects[player]then return end
  
  local box=Drawing.new("Square")
  local fill=Drawing.new("Square")
  local nameLabel=Drawing.new("Text")
  local healthLabel=Drawing.new("Text")
  
  box.Thickness=1;box.Filled=false;box.Visible=false
  fill.Filled=true;fill.Color=Color3.new(0,0,0);fill.Transparency=0.6;fill.Visible=false
  nameLabel.Size=14;nameLabel.Outline=true;nameLabel.Center=true;nameLabel.Visible=false
  healthLabel.Size=12;healthLabel.Outline=true;healthLabel.Visible=false
  
  espObjects[player]={box=box,fill=fill,name=nameLabel,health=healthLabel}
 end
 
 local function updateESP()
  for player,objs in pairs(espObjects)do
   local char=player.Character or WS:FindFirstChild(player.Name)
   if not char or not char.Parent then
    for _,o in pairs(objs)do o.Visible=false end
   else
    local head=rp(char)
    local hrp=rp(char)
    if head and hrp then
     local headPos,onScreen=WS.CurrentCamera:WorldToViewportPoint(head.Position+(cfg.teamCheck and Vector3.new(0,0.5,0)or Vector3.new(0,1.5,0)))
     if onScreen then
      local rootPos=WS.CurrentCamera:WorldToViewportPoint(hrp.Position+(cfg.teamCheck and Vector3.new(0,-1.5,0)or Vector3.new(0,-1.5,0)))
      local h=math.abs(headPos.Y-rootPos.Y)
      local w=h*0.6
      local x=headPos.X-w/2
      local y=headPos.Y-h
      
      local color=cfg.esp_color_enemy
      if cfg.teamCheck and player.Team==LP.Team then color=cfg.esp_color_team end
      
      objs.box.Position=Vector2.new(x,y)
      objs.box.Size=Vector2.new(w,h)
      objs.box.Color=color
      objs.box.Visible=true
      
      objs.fill.Position=Vector2.new(x,y)
      objs.fill.Size=Vector2.new(w,h)
      objs.fill.Visible=true
      
      objs.name.Position=Vector2.new(x+w/2,y-16)
      objs.name.Text=player.Name
      objs.name.Color=color
      objs.name.Visible=true
      
      local hum=char:FindFirstChildOfClass("Humanoid")
      local hpText=hum and tostring(math.floor(hum.Health))or"?"
      objs.health.Position=Vector2.new(x+w/2,y+h+2)
      objs.health.Text=hpText
      objs.health.Color=color
      objs.health.Visible=true
     else
      for _,o in pairs(objs)do o.Visible=false end
     end
    else
     for _,o in pairs(objs)do o.Visible=false end
    end
   end
  end
 end
 
 for _,p in ipairs(PS:GetPlayers())do createESP(p)end
 PS.PlayerAdded:Connect(createESP)
 PS.PlayerRemoving:Connect(function(p)
  if espObjects[p]then
   for _,o in pairs(espObjects[p])do o:Remove()end
   espObjects[p]=nil
  end
 end)
 
 RS.RenderStepped:Connect(updateESP)
end

warn("MDUEL ULTIMATE")
