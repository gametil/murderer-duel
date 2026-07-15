-- MDUEL Ultimate v6 — debug every step
local RS=game:GetService("RunService")
local LP=game:GetService("Players").LocalPlayer
local WS=game:GetService("Workspace")
local PS=game:GetService("Players")

local cfg={
 range=350,fov=300,smooth=0.15,
 silent=true,esp=true,teamCheck=false,
 esp_color_enemy=Color3.new(1,0,0),
 esp_color_team=Color3.new(0,1,0)
}

local env=getfenv()
local hmm=env.hookmetamethod
local gnm=env.getnamecallmethod
local mmr=env.mousemoverel

warn("MD: hook="..tostring(hmm~=nil).." namecall="..tostring(gnm~=nil).." mmr="..tostring(mmr~=nil))

local hasDraw=type(env.Drawing)=="table"and type(env.Drawing.new)=="function"
warn("MD: Draw="..tostring(hasDraw))

local RP_TOP={"Head","UpperTorso","Torso","Root","HumanoidRootPart","Hip"}
local RP_BOT={"HumanoidRootPart","LowerTorso","Torso","Root","Hip","UpperTorso","Head"}
local function rp(m)
 if not m then return nil end
 for _,n in ipairs(RP_TOP)do
  local p=m:FindFirstChild(n)
  if p and p:IsA("BasePart")then return p end
 end
 for _,c in ipairs(m:GetChildren())do if c:IsA("BasePart")then return c end end
 return nil
end
local function rpTop(m)
 if not m then return nil end
 for _,n in ipairs(RP_TOP)do
  local p=m:FindFirstChild(n)
  if p and p:IsA("BasePart")then return p end
 end
 return rp(m)
end
local function rpBot(m)
 if not m then return nil end
 for _,n in ipairs(RP_BOT)do
  local p=m:FindFirstChild(n)
  if p and p:IsA("BasePart")then return p end
 end
 return rp(m)
end

local targets,buildTick,aimPos={},0,Vector2.new()
LP.CharacterAdded:Connect(function()buildTick=999 end)

local function rebuild()
 local t={}
 local sc=LP.Character;local sn=LP.Name
 local function add(m)
  if m and m~=sc and m.Name~=sn and not t[m]then
   local r=rp(m)
   if r then t[m]=r end
  end
 end
 for _,c in ipairs(WS:GetChildren())do if c:IsA("Model")then add(c)end end
 local ch=WS:FindFirstChild("Characters")
 if ch then for _,c in ipairs(ch:GetChildren())do if c:IsA("Model")then add(c)end end end
 for _,p in ipairs(PS:GetPlayers())do if p~=LP then local c=p.Character;if c then add(c)end end end
 for _,f in ipairs(WS:GetChildren())do if f:IsA("Folder")and f.Name~="Characters"then for _,c in ipairs(f:GetChildren())do if c:IsA("Model")then add(c)end end end end
 targets=t;buildTick=0
 local n=0;for _ in pairs(targets)do n=n+1 end
 warn("MD: targets="..n.." (self="..sn..")")
end
rebuild()

local function getTarget()
 local cam=WS.CurrentCamera
 if not cam then return nil end
 local char=LP.Character;if not char then return nil end
 local hrp=rp(char);if not hrp then return nil end
 local hp=hrp.Position
 local best,bd=nil,1/0
 for m,r in pairs(targets)do
  if not m.Parent then targets[m]=nil
  elseif m==char then targets[m]=nil
  else
   local d=(hp-r.Position).Magnitude
   if d<=cfg.range and d<bd then
    local vp,on=cam:WorldToViewportPoint(r.Position)
    if on then
     if cfg.fov==0 or(Vector2.new(vp.X-cam.ViewportSize.X/2,vp.Y-cam.ViewportSize.Y/2)).Magnitude<=cfg.fov then
      best=r;bd=d
     end
    end
   end
  end
 end
 if best then warn("MD: target="..best:GetFullName().." dist="..math.floor(bd)) end
 return best
end

-- SILENT AIM 1: Mouse.Hit/Target
if cfg.silent and hmm then
 pcall(function()
  local Mouse=LP:GetMouse()
  if Mouse then
   local oldIdx
   oldIdx=hmm(game,"__index",function(s,i)
    if s==Mouse and(i=="Hit"or i=="Target")then
     local t=getTarget()
     if t then return i=="Hit"and t.CFrame or t end
    end
    return oldIdx(s,i)
   end)
   warn("MD: Mouse.Hit hook ok")
  else
   warn("MD: GetMouse nil — Mouse.Hit disabled")
  end
 end)
end

-- SILENT AIM 2: Raycast __namecall
if cfg.silent and hmm and gnm then
 pcall(function()
  local old
  old=hmm(game,"__namecall",function(...)
   local m=gnm()
   if m=="Raycast"or m=="FindPartOnRayWithIgnoreList"or m=="FindPartOnRayWithWhitelist"or m=="FindPartOnRay"then
    local a={...}
    local s=a[1]
    if(s==WS or s==WS.Terrain)and a[2]then
     local t=getTarget()
     if t then
      if m=="Raycast"then a[3]=(t.Position-a[2]).Unit*1000
      elseif a[2].Origin then local r=a[2];a[2]=Ray.new(r.Origin,(t.Position-r.Origin).Unit*1000)end
      return old(unpack(a))
     end
    end
   end
   return old(...)
  end)
  warn("MD: Raycast hook ok")
 end)
end

-- MOUSEMOVEREL AIMBOT — debug every frame
if mmr then
 local frame=0
 RS.RenderStepped:Connect(function()
  pcall(function()
   frame=frame+1
   local cam=WS.CurrentCamera
   if not cam then return end;local char=LP.Character
   if not char then return end;local hrp=rp(char)
   if not hrp then return end
   buildTick=buildTick+1
   if buildTick>=60 or not next(targets)then rebuild()end
   local hp=hrp.Position
   local best,bd=nil,1/0
   for m,r in pairs(targets)do
    if not m.Parent then targets[m]=nil
    elseif m==char then targets[m]=nil
    else
     local d=(hp-r.Position).Magnitude
     if d<=cfg.range and d<bd then
      local vp,on=cam:WorldToViewportPoint(r.Position)
      if on then
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
    local dx=aimPos.X-prev.X
    local dy=aimPos.Y-prev.Y
    -- DEBUG: log every 30 frames
    if frame%30==0 then
     warn("MD: aim dx="..math.floor(dx).." dy="..math.floor(dy).." tg=("..math.floor(tg.X)..","..math.floor(tg.Y)..") pos=("..math.floor(aimPos.X)..","..math.floor(aimPos.Y)..")")
    end
    mmr(dx,dy)
   elseif frame%120==0 then
    warn("MD: no target in aimbot loop (targets="..#targets..")")
   end
  end)
 end)
end

if cfg.esp and hasDraw then
 local objs={}
 local function add(p)
  if p==LP or objs[p]then return end
  local b=Drawing.new("Square")
  local n=Drawing.new("Text")
  b.Thickness=2;b.Filled=false;b.Visible=false
  n.Size=14;n.Outline=true;n.Center=true;n.Visible=false
  objs[p]={box=b,name=n}
 end
 local function update()
  for p,o in pairs(objs)do
   local c=p.Character
   if not c or not c.Parent then o.box.Visible=false;o.name.Visible=false
   else
    local top=rpTop(c);local bot=rpBot(c)
    if top and bot then
     local tp,on=WS.CurrentCamera:WorldToViewportPoint(top.Position+Vector3.new(0,0.5,0))
     if on then
      local bp=WS.CurrentCamera:WorldToViewportPoint(bot.Position-Vector3.new(0,0.5,0))
      local h=math.abs(tp.Y-bp.Y);if h<20 then h=20 end
      local w=h*0.55;if w<15 then w=15 end
      local x=tp.X-w/2;local y=tp.Y-h
      local cl=cfg.esp_color_enemy
      if cfg.teamCheck and p.Team==LP.Team then cl=cfg.esp_color_team end
      o.box.Position=Vector2.new(x,y);o.box.Size=Vector2.new(w,h);o.box.Color=cl;o.box.Visible=true
      o.name.Position=Vector2.new(x+w/2,y-14);o.name.Text=p.Name;o.name.Color=cl;o.name.Visible=true
     else o.box.Visible=false;o.name.Visible=false end
    else o.box.Visible=false;o.name.Visible=false end
   end
  end
 end
 for _,p in ipairs(PS:GetPlayers())do add(p)end
 PS.PlayerAdded:Connect(add)
 PS.PlayerRemoving:Connect(function(p)if objs[p]then objs[p].box:Remove();objs[p].name:Remove();objs[p]=nil end end)
 game:BindToClose(function()for _,o in pairs(objs)do pcall(function()o.box:Remove();o.name:Remove()end)end end)
 RS.RenderStepped:Connect(update)
end

warn("MDUEL ULTIMATE v6 loaded — check console for debug")