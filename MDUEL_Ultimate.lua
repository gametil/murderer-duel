-- MDUEL Ultimate v2 — mousemoverel aimbot + silent aim + ESP (Ketamine-safe)
local RS=game:GetService("RunService")
local LP=game:GetService("Players").LocalPlayer
local WS=game:GetService("Workspace")
local PS=game:GetService("Players")

local cfg={
 range=350,fov=200,smooth=0.15,
 silent=true,esp=true,teamCheck=false,
 esp_color_enemy=Color3.new(1,0,0),
 esp_color_team=Color3.new(0,1,0)
}

local RP_LIST={"UpperTorso","Head","HumanoidRootPart","LowerTorso","Torso","Root","Hip"}
local function rp(m)
 if not m then return nil end
 for _,n in ipairs(RP_LIST)do
  local p=m:FindFirstChild(n)
  if p and p:IsA("BasePart")then return p end
 end
 for _,c in ipairs(m:GetChildren())do if c:IsA("BasePart")then return c end end
 return nil
end

local targets,buildTick,aimPos={},0,Vector2.new()
LP.CharacterAdded:Connect(function()buildTick=999 end)

local function rebuild()
 local built={}
 local sc=LP.Character;local sn=LP.Name
 for _,c in ipairs(WS:GetChildren())do
  if c:IsA("Model")and c~=sc and c.Name~=sn then local r=rp(c)if r then built[c]=r end end
 end
 local ch=WS:FindFirstChild("Characters")
 if ch then
  for _,c in ipairs(ch:GetChildren())do
   if c:IsA("Model")and c~=sc and c.Name~=sn then local r=rp(c)if r then built[c]=r end end
  end
 end
 for _,p in ipairs(PS:GetPlayers())do
  if p~=LP then
   local c=p.Character or WS:FindFirstChild(p.Name)or WS:FindFirstChild(p.DisplayName)
   if c and c~=sc and c.Name~=sn and not built[c]then local r=rp(c)if r then built[c]=r end end
  end
 end
 for _,f in ipairs(WS:GetChildren())do
  if f:IsA("Folder")and f.Name~="Characters"then
   for _,c in ipairs(f:GetChildren())do
    if c:IsA("Model")and c~=sc and c.Name~=sn and not built[c]then local r=rp(c)if r then built[c]=r end end
   end
  end
 end
 targets=built;buildTick=0
end
rebuild()

-- Get best target
local function getTarget()
 local cam=WS.CurrentCamera
 if not cam then return nil end
 local char=LP.Character;if not char then return nil end
 local hrp=rp(char);if not hrp then return nil end
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

-- Silent aim via __namecall (via getfenv for Ketamine compat)
local env=getfenv()
local hmm=env.hookmetamethod
local gnm=env.getnamecallmethod
if cfg.silent and hmm and gnm then
 pcall(function()
  local old
  old=hmm(game,"__namecall",function(...)
   local m=gnm()
   if m=="Raycast"or m=="FindPartOnRayWithIgnoreList"or m=="FindPartOnRayWithWhitelist"or m=="FindPartOnRay"or m=="findPartOnRay"then
    local args={...}
    local self=args[1]
    if(self==WS or self==WS.Terrain)and args[2]then
     local t=getTarget()
     if t then
      if m=="Raycast"and #args>=3 then
       args[3]=(t.Position-args[2]).Unit*1000
       return old(unpack(args))
      else
       local ray=args[2]
       if ray and ray.Origin then
        args[2]=Ray.new(ray.Origin,(t.Position-ray.Origin).Unit*1000)
        return old(unpack(args))
       end
      end
     end
    end
   end
   return old(...)
  end)
 end)
end

-- mousemoverel aimbot
RS.RenderStepped:Connect(function()
 pcall(function()
  local cam=WS.CurrentCamera
  if not cam then return end;local char=LP.Character
  if not char then return end;local hrp=rp(char)
  if not hrp then return end
  buildTick=buildTick+1
  if buildTick>=60 or not next(targets)then rebuild()end
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

-- ESP via Drawing (wrapped, graceful if no Drawing)
if cfg.esp then
 pcall(function()
  if not Drawing then return end
  local espObjs={}
  local function cr(p)
   if p==LP or espObjs[p]then return end
   local b=Drawing.new("Square");local f=Drawing.new("Square")
   local n=Drawing.new("Text");local h=Drawing.new("Text")
   b.Thickness=1;b.Filled=false;b.Visible=false
   f.Filled=true;f.Color=Color3.new(0,0,0);f.Transparency=0.6;f.Visible=false
   n.Size=14;n.Outline=true;n.Center=true;n.Visible=false
   h.Size=12;h.Outline=true;h.Visible=false
   espObjs[p]={box=b,fill=f,name=n,health=h}
  end
  local function up()
   for p,o in pairs(espObjs)do
    local c=p.Character or WS:FindFirstChild(p.Name)
    if not c or not c.Parent then
     for _,d in pairs(o)do d.Visible=false end
    else
     local head=rp(c);local root=rp(c)
     if head and root then
      local hp,on=WS.CurrentCamera:WorldToViewportPoint(head.Position+Vector3.new(0,1.5,0))
      if on then
       local rp=WS.CurrentCamera:WorldToViewportPoint(root.Position+Vector3.new(0,-1.5,0))
       local hh=math.abs(hp.Y-rp.Y);local w=hh*0.6
       local x=hp.X-w/2;local y=hp.Y-hh
       local cl=cfg.esp_color_enemy
       if cfg.teamCheck and p.Team==LP.Team then cl=cfg.esp_color_team end
       o.box.Position=Vector2.new(x,y);o.box.Size=Vector2.new(w,hh);o.box.Color=cl;o.box.Visible=true
       o.fill.Position=Vector2.new(x,y);o.fill.Size=Vector2.new(w,hh);o.fill.Visible=true
       o.name.Position=Vector2.new(x+w/2,y-16);o.name.Text=p.Name;o.name.Color=cl;o.name.Visible=true
       o.health.Position=Vector2.new(x+w/2,y+hh+2);o.health.Text=p.Name:sub(1,3);o.health.Color=cl;o.health.Visible=true
      else for _,d in pairs(o)do d.Visible=false end end
     else for _,d in pairs(o)do d.Visible=false end end
    end
   end
  end
  for _,p in ipairs(PS:GetPlayers())do cr(p)end
  PS.PlayerAdded:Connect(cr)
  PS.PlayerRemoving:Connect(function(p)
   if espObjs[p]then for _,d in pairs(espObjs[p])do d:Remove()end;espObjs[p]=nil end
  end)
  RS.RenderStepped:Connect(up)
 end)
end

warn("MDUEL ULTIMATE v2")
