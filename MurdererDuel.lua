-- MDUEL v3 - Always-on aimbot (Ketamine-safe)
local RunS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")

local settings = { enabled = true, range = 250, fov = 200, smooth = 0.15 }

-- Drawing setup
local bx, tx, dt, fv, nm
if type(Drawing) == "table" and type(Drawing.new) == "function" then
	pcall(function()
		bx = Drawing.new("Square")
		tx = Drawing.new("Text")
		dt = Drawing.new("Circle")
		fv = Drawing.new("Circle")
		nm = Drawing.new("Text")
		fv.Visible = true; fv.Color = Color3.new(1,1,1)
		fv.Transparency = 0.3; fv.Thickness = 1; fv.NumSides = 60; fv.Radius = settings.fov
		if tx then tx.Size = 13; tx.Center = true; tx.Outline = true; tx.Color = Color3.new(1,1,1) end
		if dt then dt.Radius = 4; dt.Filled = true; dt.Color = Color3.new(1,0,0); dt.NumSides = 12; dt.Transparency = 0.6 end
		if nm then nm.Size = 14; nm.Center = true; nm.Outline = true; nm.Color = Color3.new(1,1,0) end
	end)
end

local chars = WS:FindFirstChild("Characters")
if not chars then warn("MDUEL no Characters"); return end

-- Friend check
local friendIds = {}
delay(5, function()
	pcall(function()
		local t = {}
		for _, p in game:GetService("Players"):GetPlayers() do
			if p ~= LP then
				local s, r = pcall(function() return p:IsFriendsWithAsync(LP.UserId) end)
				if s and r then t[p.UserId] = true end
			end
		end
		friendIds = t
	end)
end)

local lockedTarget, lockedName, lockedDist = nil, "", 0
local function hideAll()
	if bx then bx.Visible = false end; if tx then tx.Visible = false end
	if dt then dt.Visible = false end; if nm then nm.Visible = false end
end

-- UI elements
local uiElems, uiVisible, uiReady, uiToggleDeb = {}, true, false, true
local UI_W, UI_H, pulse, pulseDir = 260, 180, 0, 1

local function makeUI(vs)
	local x, y = (vs.X-UI_W)/2, 40
	local bg = Drawing.new("Square"); bg.Filled = true; bg.Color = Color3.fromRGB(10,10,16); bg.Transparency = 0.88; bg.Size = Vector2.new(UI_W,UI_H); bg.Position = Vector2.new(x,y); bg.Thickness = 1.5; bg.ZIndex = 100
	local ln = Drawing.new("Line"); ln.From = Vector2.new(x,y+32); ln.To = Vector2.new(x+UI_W,y+32); ln.Color = Color3.fromRGB(0,200,255); ln.Thickness = 1; ln.Transparency = 0.5; ln.ZIndex = 101
	local ti = Drawing.new("Text"); ti.Text = "MDUEL V3"; ti.Size = 18; ti.Color = Color3.fromRGB(0,200,255); ti.Position = Vector2.new(x+12,y+6); ti.Font = 3; ti.Outline = true; ti.ZIndex = 102
	local st = Drawing.new("Text"); st.Text = "ACTIVE"; st.Size = 11; st.Color = Color3.fromRGB(0,255,120); st.Position = Vector2.new(x+UI_W-65,y+11); st.Font = 2; st.Outline = true; st.ZIndex = 102
	local a1 = Drawing.new("Text"); a1.Text = "Z: Aimbot"; a1.Size = 14; a1.Color = Color3.fromRGB(210,210,240); a1.Position = Vector2.new(x+14,y+42); a1.Font = 2; a1.ZIndex = 102
	local a2 = Drawing.new("Square"); a2.Size = Vector2.new(14,14); a2.Position = Vector2.new(x+UI_W-28,y+43); a2.Color = Color3.fromRGB(0,255,120); a2.Filled = true; a2.Thickness = 1; a2.ZIndex = 101
	local f1 = Drawing.new("Text"); f1.Text = "[  ] FOV: "..settings.fov; f1.Size = 13; f1.Color = Color3.fromRGB(190,190,220); f1.Position = Vector2.new(x+14,y+72); f1.Font = 2; f1.ZIndex = 102
	local s1 = Drawing.new("Text"); s1.Text = "[  ] SMOOTH: "..string.format("%.2f",settings.smooth); s1.Size = 13; s1.Color = Color3.fromRGB(190,190,220); s1.Position = Vector2.new(x+14,y+97); s1.Font = 2; s1.ZIndex = 102
	local r1 = Drawing.new("Text"); r1.Text = "[  ] RANGE: "..settings.range; r1.Size = 13; r1.Color = Color3.fromRGB(190,190,220); r1.Position = Vector2.new(x+14,y+122); r1.Font = 2; r1.ZIndex = 102
	local h1 = Drawing.new("Text"); h1.Text = "Ctrl: hide   +/-: FOV   [ ]: smooth"; h1.Size = 10; h1.Color = Color3.fromRGB(90,90,110); h1.Position = Vector2.new(x+14,y+155); h1.Font = 2; h1.ZIndex = 102
	uiElems = {bg,ln,ti,st,a1,a2,f1,s1,r1,h1}
end

RunS.RenderStepped:Connect(function()
	pcall(function()
		local cam = WS.CurrentCamera; if not cam then return end
		local vs = cam.ViewportSize

		if not uiReady then makeUI(vs); uiReady = true end
		pulse = math.max(0, math.min(360, pulse + pulseDir * 1.5))

		if uiVisible and #uiElems > 0 then
			local hsv = Color3.fromHSV(pulse/360, 0.75, 1)
			for i,e in ipairs(uiElems) do
				if e then
					e.Visible = true
					if i==1 then e.Color = hsv end
					if i==2 or i==3 then e.Color = hsv end
				end
			end
			uiElems[4].Text = settings.enabled and "ACTIVE" or "OFF"
			uiElems[4].Color = settings.enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,50,50)
			uiElems[6].Color = settings.enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,50,50)
			uiElems[7].Text = "[-/+] FOV: "..settings.fov
			uiElems[8].Text = "[[/]] SMOOTH: "..string.format("%.2f",settings.smooth)
			uiElems[9].Text = "[  ] RANGE: "..settings.range
		else
			for _,e in ipairs(uiElems) do if e then e.Visible = false end end
		end

		if fv then fv.Radius = settings.fov; fv.Position = Vector2.new(vs.X/2, vs.Y/2); fv.Visible = settings.fov>0 and uiVisible end
		if not settings.enabled then hideAll(); return end

		local char = LP.Character; if not char then hideAll(); lockedTarget = nil; return end
		local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then hideAll(); lockedTarget = nil; return end

		local keep = false
		if lockedTarget and lockedTarget.Parent then
			local h = lockedTarget.Parent:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 and (hrp.Position - lockedTarget.Position).Magnitude <= settings.range then
				keep = true; lockedDist = (hrp.Position - lockedTarget.Position).Magnitude
			end
		end
		if not keep then
			lockedTarget = nil; lockedName = ""
			local best, bdist = nil, math.huge
			for _, c in chars:GetChildren() do
				if c ~= char then
				local r = c:FindFirstChild("HumanoidRootPart")
				local h = c:FindFirstChildOfClass("Humanoid")
				if r and h and h.Health > 0 then
					local uid
					local aok = pcall(function() uid = c:GetAttribute("userId") end)
					if not aok or not uid then
						local obj = c:FindFirstChild("userId")
						if obj then uid = obj.Value end
					end
					if not uid or not friendIds[uid] then
						local d = (hrp.Position - r.Position).Magnitude
						if d < settings.range and d < bdist then best, bdist = r, d; lockedName = c.Name end
					end
				end
			end -- if c~=char
			end -- for
			if best then lockedTarget = best; lockedDist = bdist end
		end

		if lockedTarget then
			local sp, on = cam:WorldToViewportPoint(lockedTarget.Position)
			if on and sp.Z > 0 then
				if settings.fov == 0 or Vector2.new(sp.X-vs.X/2,sp.Y-vs.Y/2).Magnitude <= settings.fov then
					cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, lockedTarget.Position), settings.smooth)
					if fv then fv.Color = Color3.new(0,1,0) end
				elseif fv then fv.Color = Color3.new(1,1,1) end
				local head = lockedTarget.Parent and lockedTarget.Parent:FindFirstChild("Head")
				if head then
					local hp = cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0))
					local bh = math.abs(sp.Y-hp.Y)*1.8; local bw = bh*0.6
					if bx then bx.Size=Vector2.new(bw,bh); bx.Position=Vector2.new(sp.X-bw/2,sp.Y-bh/2); bx.Visible=true end
					if tx then tx.Text="#1 "..math.floor(lockedDist).."m"; tx.Position=Vector2.new(sp.X,sp.Y-bh/2-18); tx.Visible=true end
					if dt then dt.Position=Vector2.new(sp.X,sp.Y); dt.Visible=true end
					if nm then nm.Text="#1 "..lockedName; nm.Position=Vector2.new(sp.X,sp.Y+bh/2+4); nm.Visible=true end
				end
			else hideAll() end
		else hideAll(); if fv then fv.Color=Color3.new(1,1,1) end end
	end)
end)

UIS.InputBegan:Connect(function(key, gpe)
	if gpe then return end
	local kc = key.KeyCode
	if kc == Enum.KeyCode.RightControl or kc == Enum.KeyCode.LeftControl then
		if uiToggleDeb then uiVisible = not uiVisible; uiToggleDeb = false end
	elseif kc == Enum.KeyCode.Z then settings.enabled = not settings.enabled
	elseif uiVisible then
		if kc == Enum.KeyCode.LeftBracket then settings.smooth = math.max(0.02, settings.smooth - 0.03)
		elseif kc == Enum.KeyCode.RightBracket then settings.smooth = math.min(0.5, settings.smooth + 0.03)
		elseif kc == Enum.KeyCode.Minus then settings.fov = math.max(20, settings.fov - 20)
		elseif kc == Enum.KeyCode.Equals then settings.fov = math.min(500, settings.fov + 20)
		end
	end
end)
UIS.InputEnded:Connect(function(key, gpe)
	if gpe then return end
	if key.KeyCode == Enum.KeyCode.RightControl or key.KeyCode == Enum.KeyCode.LeftControl then
		uiToggleDeb = true
	end
end)

print("MDUEL v3 - Z=aimbot, Ctrl=UI, [-/+]=FOV, [[/]]=smooth")
