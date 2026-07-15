-- MDUEL GUI — Settings UI for aimbot
local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local LP=game:GetService("Players").LocalPlayer
local PG=LP:WaitForChild("PlayerGui")

local Settings={
 Enabled=false,FOV=120,Smoothness=0.18,TargetLock=true
}

-- Create ScreenGui
local sg=Instance.new("ScreenGui")
sg.Name="MDUEL_GUI"
sg.ResetOnSpawn=false
sg.IgnoreGuiInset=true
sg.Parent=PG

-- Main Frame
local main=Instance.new("Frame")
main.Name="MainFrame"
main.Size=UDim2.new(0,280,0,240)
main.Position=UDim2.new(0.5,-140,0.5,-120)
main.BackgroundColor3=Color3.fromRGB(30,30,30)
main.BorderSizePixel=0
main.Active=true
main.Draggable=true
main.Parent=sg

Instance.new("UICorner",main).CornerRadius=UDim2.new(0,8)
local stroke=Instance.new("UIStroke",main)
stroke.Color=Color3.fromRGB(60,60,60);stroke.Thickness=1

-- Title Bar
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,36)
title.BackgroundTransparency=1
title.Text="Aim Settings"
title.Font=Enum.Font.GothamBold
title.TextSize=16
title.TextColor3=Color3.new(1,1,1)
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=main
Instance.new("UIPadding",title).PaddingLeft=UDim.new(0,12)

-- Close Button
local close=Instance.new("TextButton")
close.Size=UDim2.new(0,28,0,28)
close.Position=UDim2.new(1,-34,0,4)
close.BackgroundColor3=Color3.fromRGB(60,60,60)
close.Text="×"
close.Font=Enum.Font.GothamBold
close.TextSize=18
close.TextColor3=Color3.new(1,1,1)
close.Parent=main
Instance.new("UICorner",close).CornerRadius=UDim.new(0,6)

close.MouseButton1Click:Connect(function()
 main.Visible=false
end)

-- Layout
local layout=Instance.new("UIListLayout",main)
layout.Padding=UDim.new(0,8)
layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
layout.SortOrder=Enum.SortOrder.LayoutOrder

-- Helper: create row with label + control
local function row(name, order)
 local f=Instance.new("Frame")
 f.Size=UDim2.new(1,-24,0,40)
 f.BackgroundTransparency=1
 f.LayoutOrder=order
 f.Parent=main
 return f
end

local function label(parent, text)
 local l=Instance.new("TextLabel")
 l.Size=UDim2.new(0,90,1,0)
 l.BackgroundTransparency=1
 l.Text=text
 l.Font=Enum.Font.Gotham
 l.TextSize=13
 l.TextColor3=Color3.new(0.8,0.8,0.8)
 l.TextXAlignment=Enum.TextXAlignment.Left
 l.Parent=parent
 return l
end

-- Toggle
local function toggle(parent, key, order)
 local f=row("",order)
 label(f,key)
 local btn=Instance.new("TextButton")
 btn.Size=UDim2.new(0,54,0,26)
 btn.Position=UDim2.new(1,-54,0.5,-13)
 btn.BackgroundColor3=Settings[key]and Color3.fromRGB(0,120,215)or Color3.fromRGB(60,60,60)
 btn.Text=Settings[key]and"ON"or"OFF"
 btn.Font=Enum.Font.GothamBold
 btn.TextSize=12
 btn.TextColor3=Color3.new(1,1,1)
 btn.Parent=f
 Instance.new("UICorner",btn).CornerRadius=UDim.new(0,4)
 btn.MouseButton1Click:Connect(function()
  Settings[key]=not Settings[key]
  btn.BackgroundColor3=Settings[key]and Color3.fromRGB(0,120,215)or Color3.fromRGB(60,60,60)
  btn.Text=Settings[key]and"ON"or"OFF"
 end)
end

-- Slider
local function slider(parent, key, min, max, order, fmt)
 local f=row("",order)
 label(f,key)
 local track=Instance.new("Frame")
 track.Size=UDim2.new(0,160,0,6)
 track.Position=UDim2.new(0,100,0.5,-3)
 track.BackgroundColor3=Color3.fromRGB(60,60,60)
 track.Parent=f
 Instance.new("UICorner",track).CornerRadius=UDim.new(0,3)
 local fill=Instance.new("Frame",track)
 fill.BackgroundColor3=Color3.fromRGB(0,120,215)
 Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
 local val=Instance.new("TextLabel")
 val.Size=UDim2.new(0,50,1,0)
 val.Position=UDim2.new(1,-50,0,0)
 val.BackgroundTransparency=1
 val.Font=Enum.Font.Gotham
 val.TextSize=12
 val.TextColor3=Color3.new(1,1,1)
 val.Text=fmt and fmt(Settings[key])or Settings[key]
 val.Parent=f
 local dragging=false
 local function update(x)
  local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
  Settings[key]=min+(max-min)*p
  fill.Size=UDim2.new(p,0,1,0)
  val.Text=fmt and fmt(Settings[key])or string.format("%.2f",Settings[key])
 end
 track.InputBegan:Connect(function(inp)
  if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;update(inp.Position.X)end
 end)
 track.InputEnded:Connect(function(inp)
  if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
 end)
 UIS.InputChanged:Connect(function(inp)
  if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then update(inp.Position.X)end
 end)
 -- init
 fill.Size=UDim2.new((Settings[key]-min)/(max-min),0,1,0)
end

-- Build UI
toggle(main,"Enabled",1)
slider(main,"FOV",20,300,2,function(v)return math.floor(v)end)
slider(main,"Smoothness",0.01,1,3,function(v)return string.format("%.2f",v)end)
toggle(main,"TargetLock",4)

-- Re-add title to top via layout order hack
title.LayoutOrder=0

warn("MDUEL GUI loaded — Settings table exposed")