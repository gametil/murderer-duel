-- MDUEL All-In-One v17 — Fixed self-filter + guaranteed init debug
local RS=game:GetService("RunService")
local LP=game:GetService("Players").LocalPlayer
local WS=game:GetService("Workspace")
local PS=game:GetService("Players")
local UIS=game:GetService("UserInputService")

local Settings={Enabled=false,FOV=120,Range=300,TargetLock=true}

-- ===== LIGHT THEME GUI =====
local PG=LP:WaitForChild("PlayerGui",5)
if PG then
 local sg=Instance.new("ScreenGui")
 sg.Name="MDUEL_GUI"
 sg.ResetOnSpawn=false
 sg.IgnoreGuiInset=true
 sg.Parent=PG

 local mod=Instance.new("ModuleScript")
 mod.Name="SettingsModule"
 mod.Source="return {Enabled=false,FOV=120,Range=300,TargetLock=true}"
 mod.Parent=sg

 local main=Instance.new("Frame")
 main.Name="MainFrame"
 main.Size=UDim2.new(0,280,0,240)
 main.Position=UDim2.new(0.5,-140,0.5,-120)
 main.BackgroundColor3=Color3.fromRGB(245,245,245)
 main.BorderSizePixel=0
 main.Active=true
 main.Draggable=true
 main.Parent=sg

 Instance.new("UICorner",main).CornerRadius=UDim.new(0,8)
 local stroke=Instance.new("UIStroke",main)
 stroke.Color=Color3.fromRGB(200,200,200);stroke.Thickness=1

 local title=Instance.new("TextLabel")
 title.Size=UDim2.new(1,0,0,36)
 title.BackgroundTransparency=1
 title.Text="MDUEL Aim Settings"
 title.Font=Enum.Font.GothamBold
 title.TextSize=16
 title.TextColor3=Color3.fromRGB(30,30,30)
 title.TextXAlignment=Enum.TextXAlignment.Left
 title.Parent=main
 Instance.new("UIPadding",title).PaddingLeft=UDim.new(0,12)

 local close=Instance.new("TextButton")
 close.Size=UDim2.new(0,28,0,28)
 close.Position=UDim2.new(1,-34,0,4)
 close.BackgroundColor3=Color3.fromRGB(220,220,220)
 close.Text="×"
 close.Font=Enum.Font.GothamBold
 close.TextSize=18
 close.TextColor3=Color3.fromRGB(30,30,30)
 close.Parent=main
 Instance.new("UICorner",close).CornerRadius=UDim.new(0,6)
 close.MouseButton1Click:Connect(function()main.Visible=false end)

 local layout=Instance.new("UIListLayout",main)
 layout.Padding=UDim.new(0,8)
 layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
 layout.SortOrder=Enum.SortOrder.LayoutOrder
 title.LayoutOrder=0

 local function row(name, order)
  local f=Instance.new("Frame")
  f.Name=name;f.Size=UDim2.new(1,-24,0,40);f.BackgroundTransparency=1;f.LayoutOrder=order;f.Parent=main
  return f
 end

 local function label(parent, text)
  local l=Instance.new("TextLabel")
  l.Size=UDim2.new(0,90,1,0);l.BackgroundTransparency=1;l.Text=text
  l.Font=Enum.Font.Gotham;l.TextSize=13;l.TextColor3=Color3.fromRGB(60,60,60);l.TextXAlignment=Enum.TextXAlignment.Left
  l.Parent=parent;return l
 end

 local function updateModule()
  mod.Source="return {Enabled="..tostring(Settings.Enabled)..",FOV="..Settings.FOV..",Range="..Settings.Range..",TargetLock="..tostring(Settings.TargetLock).."}"
 end

 local function toggle(parent, key, order)
  local f=row(key,order);label(f,key)
  local btn=Instance.new("TextButton")
  btn.Name="TextButton";btn.Size=UDim2.new(0,54,0,26);btn.Position=UDim2.new(1,-54,0.5,-13)
  btn.BackgroundColor3=Settings[key]and Color3.fromRGB(0,150,100)or Color3.fromRGB(220,220,220)
  btn.Text=Settings[key]and"ON"or"OFF";btn.Font=Enum.Font.GothamBold;btn.TextSize=12;btn.TextColor3=Color3.new(1,1,1)
  btn.Parent=f;Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
  btn.MouseButton1Click:Connect(function()
   Settings[key]=not Settings[key]
   btn.BackgroundColor3=Settings[key]and Color3.fromRGB(0,150,100)or Color3.fromRGB(220,220,220)
   btn.Text=Settings[key]and"ON"or"OFF";updateModule()
   warn("MD: GUI "..key.."="..tostring(Settings[key]))
  end)
 end

 local function slider(parent, key, min, max, order)
  local f=row(key,order);label(f,key)
  local track=Instance.new("Frame")
  track.Name="Track";track.Size=UDim2.new(0,160,0,6);track.Position=UDim2.new(0,100,0.5,-3)
  track.BackgroundColor3=Color3.fromRGB(220,220,220);track.Parent=f
  Instance.new("UICorner",track).CornerRadius=UDim.new(0,3)
  local fill=Instance.new("Frame");fill.Name="Fill";fill.BackgroundColor3=Color3.fromRGB(0,150,100)
  Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3);fill.Parent=track
  local val=Instance.new("TextLabel")
  val.Name="TextLabel";val.Size=UDim2.new(0,50,1,0);val.Position=UDim2.new(1,-50,0,0)
  val.BackgroundTransparency=1;val.Font=Enum.Font.Gotham;val.TextSize=12;val.TextColor3=Color3.fromRGB(60,60,60)
  val.Text=math.floor(Settings[key]);val.Parent=f
  local dragging=false
  local function update(x)
   local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
   Settings[key]=min+(max-min)*p
   fill.Size=UDim2.new(p,0,1,0);val.Text=math.floor(Settings[key]);updateModule()
  end
  track.InputBegan:Connect(function(inp)if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;update(inp.Position.X)end end)
  track.InputEnded:Connect(function(inp)if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
  UIS.InputChanged:Connect(function(inp)if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then update(inp.Position.X)end end)
  fill.Size=UDim2.new((Settings[key]-min)/(max-min),0,1,0)
 end

 toggle(main,"Enabled",1)
 slider(main,"FOV",20,300,2)
 slider(main,"Range",50,1000,3)
 toggle(main,"TargetLock",4)
 updateModule()
end

-- ===== AIMBOT / ESP =====
local env=getfenv()
local hmm=env.hookmetamethod
local gnm=env.getnamecallmethod
local mmr=env.mousemoverel

warn("MD: INIT hook="..tostring(hmm~=nil).." namecall="..tostring(gnm~=nil).." mmr="..tostring(mmr~=nil).." mmrType="..type(mmr))

local hasDraw=type(env.Drawing)=="table"and type(env.Drawing.new)=="function"
warn("MD: Draw="..tostring(hasDraw))

-- Expanded part names for Murderer Duel custom rigs
local RP_PRIORITY={"Head","UpperTorso","Torso","LowerTorso","Root","HumanoidRootPart","Hip","LeftUpperArm","RightUpperArm","LeftUpperLeg","RightUpperLeg","LeftHand","RightHand","LeftFoot","RightFoot"}
local function findRoot(m)
 if not m then return nil end
 for _,n in ipairs(RP_PRIORITY)do local p=m:FindFirstChild(n);if p and p:IsA("BasePart")then warn("MD: rootPart="..n.." for "..m.Name);return p end end
 for _,c in ipairs(m:GetChildren())do if c:IsA("BasePart")then warn("MD: fallbackRoot="..c.Name.." for "..m.Name);return c end end
 return nil
end
local function findTop(m)
 if not m then return nil end
 for _,n in ipairs({"Head","UpperTorso","Torso","Root","HumanoidRootPart"})do local p=m:FindFirstChild(n);if p and p:IsA("BasePart")then return p end end
 return findRoot(m)
end
local function findBot(m)
 if not m then return nil end
 for _,n in ipairs({"HumanoidRootPart","LowerTorso","Torso","Root","Hip"})do local p=m:FindFirstChild(n);if p and p:IsA("BasePart")then return p end end
 return findRoot(m)
end

local targets,buildTick,aimPos={},0,nil
LP.CharacterAdded:Connect(function()buildTick=999 end)

-- ROBUST self-check: instance, name, PlayerFromCharacter, AND UserId
local function isLocalPlayer(m)
 if not m then return true end
 if m==LP.Character then warn("MD: isLocalPlayer match by instance");return true end
 if m.Name==LP.Name then warn("MD: isLocalPlayer match by name "..m.Name);return true end
 local plr=PS:GetPlayerFromCharacter(m)
 if plr and plr==LP then warn("MD: isLocalPlayer match by PlayerFromCharacter");return true end
 if plr and plr.UserId==LP.UserId then warn("MD: isLocalPlayer match by UserId");return true end
 return false
end

local function rebuild()
 local t={}
 -- ONLY scan WS.Characters and Players - skip WS:GetChildren() (catches arena parts)
 local ch=WS:FindFirstChild("Characters")
 if ch then
  for _,c in ipairs(ch:GetChildren())do
   if c:IsA("Model")and not isLocalPlayer(c)then local r=findRoot(c);if r then t[c]=r end end
  end
 end
 for _,p in ipairs(PS:GetPlayers())do
  if p~=LP then local c=p.Character;if c and not isLocalPlayer(c)then local r=findRoot(c);if r then t[c]=r end end end
 end
 targets=t;buildTick=0
 local n=0;for _ in pairs(targets)do n=n+1 end
 warn("MD: targets="..n.." (self="..LP.Name..") Enabled="..tostring(Settings.Enabled))
end
rebuild()

local function getTarget()
 warn("MD:getTarget Enabled="..tostring(Settings.Enabled).." Range="..Settings.Range.." FOV="..Settings.FOV)
 if not Settings.Enabled then return nil end
 local cam=WS.CurrentCamera;if not cam then return nil end
 local char=LP.Character;if not char then return nil end
 local hrp=findRoot(char);if not hrp then warn("MD: no local HRP");return nil end
 local hp=hrp.Position
 local best,bd=nil,1/0
 for m,r in pairs(targets)do
  if not m.Parent then targets[m]=nil
  elseif isLocalPlayer(m) then targets[m]=nil;warn("MD: removed self from targets")
  else
   local d=(hp-r.Position).Magnitude
   if d<=Settings.Range and d<bd then
    local vp,on=cam:WorldToViewportPoint(r.Position)
    if on then
     local fovDist=(Vector2.new(vp.X-cam.ViewportSize.X/2,vp.Y-cam.ViewportSize.Y/2)).Magnitude
     warn("MD:getTarget candidate "..m.Name.." dist="..math.floor(d).." fovDist="..math.floor(fovDist))
     if Settings.FOV==0 or fovDist<=Settings.FOV then best=r;bd=d;warn("MD:getTarget CHOSEN "..m.Name.." dist="..math.floor(d))end
    end
   elseif d>Settings.Range then warn("MD:getTarget SKIP "..m.Name.." dist="..math.floor(d)..">Range="..Settings.Range)end
  end
 end
 if best then warn("MD: target="..best:GetFullName().." dist="..math.floor(bd))end
 return best
end

-- SILENT AIM: Mouse.Hit/Target
if hmm then pcall(function()
 local Mouse=LP:GetMouse()
 if Mouse then
  local oldIdx
  oldIdx=hmm(game,"__index",function(s,i)
   if Settings.Enabled and s==Mouse and(i=="Hit"or i=="Target")then
    local t=getTarget();if t then return i=="Hit"and t.CFrame or t end
   end
   return oldIdx(s,i)
  end)
  warn("MD: Mouse.Hit hook ok")
 else warn("MD: GetMouse nil")end
end)end

-- SILENT AIM: Raycast
if hmm and gnm then pcall(function()
 local old
 old=hmm(game,"__namecall",function(...)
  if not Settings.Enabled then return old(...)end
  local m=gnm()
  if m=="Raycast"or m=="FindPartOnRayWithIgnoreList"or m=="FindPartOnRayWithWhitelist"or m=="FindPartOnRay"then
   local a={...};local s=a[1]
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
end)end

-- INSTANT AIMBOT - guaranteed init log
warn("MD: AIMBOT INIT mmr="..tostring(mmr~=nil))
if mmr then
 warn("MD: mousemoverel FOUND - aimbot ENABLED")
 local frame=0
 RS.RenderStepped:Connect(function()
  pcall(function()
   frame=frame+1
   if not Settings.Enabled then if frame%60==0 then warn("MD:AIM Enabled=false")end return end
   local cam=WS.CurrentCamera;if not cam then return end
   local char=LP.Character;if not char then return end
   local hrp=findRoot(char);if not hrp then return end
   if not aimPos then aimPos=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2);warn("MD: aimPos init center")end
   buildTick=buildTick+1
   if buildTick>=60 or not next(targets)then rebuild()end
   local hp=hrp.Position
   local best,bd=nil,1/0
   for m,r in pairs(targets)do
    if not m.Parent then targets[m]=nil
    elseif isLocalPlayer(m) then targets[m]=nil
    else
     local d=(hp-r.Position).Magnitude
     if d<=Settings.Range and d<bd then
      local vp,on=cam:WorldToViewportPoint(r.Position)
      if on then
       local fovDist=(Vector2.new(vp.X-cam.ViewportSize.X/2,vp.Y-cam.ViewportSize.Y/2)).Magnitude
       if Settings.FOV==0 or fovDist<=Settings.FOV then best=r;bd=d end
      end
     end
    end
   end
   warn("MD:AIM Enabled=true best="..(best and best.Parent and best.Parent.Name or "nil").." hrpDist="..math.floor(bd).." targets="..(function()local c=0;for _ in pairs(targets)do c=c+1 end return c end)())
   if best then
    local vp=cam:WorldToViewportPoint(best.Position)
    local tg=Vector2.new(vp.X,vp.Y)
    local dx=(tg.X-aimPos.X)*0.5
    local dy=(tg.Y-aimPos.Y)*0.5
    warn("MD:AIM dx="..math.floor(dx).." dy="..math.floor(dy).." tg=("..math.floor(tg.X)..","..math.floor(tg.Y)..") aimPos=("..math.floor(aimPos.X)..","..math.floor(aimPos.Y)..") FOV="..Settings.FOV.." Range="..Settings.Range)
    if dx~=0 or dy~=0 then
     local ok,err=pcall(function()mmr(dx,dy)end)
     if ok then warn("MD:AIM mousemoverel OK dx="..math.floor(dx).." dy="..math.floor(dy))else warn("MD:AIM mousemoverel FAIL: "..tostring(err))end
     aimPos=Vector2.new(aimPos.X+dx,aimPos.Y+dy)
    end
   else warn("MD:AIM no best target")end
  end)
 end)
else
 warn("MD: NO mousemoverel - aimbot DISABLED (silent aim only)")
end

-- ESP
if hasDraw then
 local objs={}
 local function add(p)
  if p==LP or objs[p]then return end
  local b=Drawing.new("Square");local n=Drawing.new("Text")
  b.Thickness=2;b.Filled=false;b.Visible=false
  n.Size=14;n.Outline=true;n.Center=true;n.Visible=false
  objs[p]={box=b,name=n}
 end
 local function update()
  for p,o in pairs(objs)do
   local c=p.Character
   if not c or not c.Parent then o.box.Visible=false;o.name.Visible=false
   else
    local top=findTop(c);local bot=findBot(c)
    if top and bot then
     local tp,on=WS.CurrentCamera:WorldToViewportPoint(top.Position+Vector3.new(0,0.5,0))
     if on then
      local bp=WS.CurrentCamera:WorldToViewportPoint(bot.Position-Vector3.new(0,0.5,0))
      local h=math.abs(tp.Y-bp.Y);if h<20 then h=20 end
      local w=h*0.55;if w<15 then w=15 end
      local x=tp.X-w/2;local y=tp.Y-h
      o.box.Position=Vector2.new(x,y);o.box.Size=Vector2.new(w,h);o.box.Color=Color3.new(1,0,0);o.box.Visible=true
      o.name.Position=Vector2.new(x+w/2,y-14);o.name.Text=p.Name;o.name.Color=Color3.new(1,0,0);o.name.Visible=true
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

warn("MDUEL v17 loaded — fixed self-filter + guaranteed init debug")