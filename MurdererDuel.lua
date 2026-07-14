-- MDUEL v4 - Fixed aimbot (Ketamine-safe)
local RunS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local HUGE = math.huge or 1/0

local settings = { enabled = true, range = 350, fov = 200, smooth = 0.15 }

local allDrawings = {}
local function cleanup()
	for _, d in ipairs(allDrawings) do pcall(function() d:Remove() end) end
	allDrawings = {}
end

local bx, tx, dt, fv, nm
if type(Drawing) == "table" and type(Drawing.new) == "function" then
	pcall(function()
		bx = Drawing.new("Square"); table.insert(allDrawings, bx)
		tx = Drawing.new("Text"); table.insert(allDrawings, tx)
		dt = Drawing.new("Circle"); table.insert(allDrawings, dt)
		fv = Drawing.new("Circle"); table.insert(allDrawings, fv)
		nm = Drawing.new("Text"); table.insert(allDrawings, nm)
		if bx then bx.Color = Color3.new(0,1,0); bx.Thickness = 1; bx.Filled = false end
		if tx then tx.Size = 13; tx.Center = true; tx.Outline = true; tx.Color = Color3.new(1,1,1) end
		if dt then dt.Radius = 4; dt.Filled = true; dt.Color = Color3.new(1,0,0); dt.NumSides = 12; dt.Transparency = 0.6 end
		if fv then fv.Visible = true; fv.Color = Color3.new(1,1,1); fv.Transparency = 0.3; fv.Thickness = 1; fv.NumSides = 60; fv.Radius = settings.fov end
		if nm then nm.Size = 14; nm.Center = true; nm.Outline = true; nm.Color = Color3.new(1,1,0) end
	end)
end

-- Find root part with fallback names (R6/R15/custom)
local function findRootPart(m)
	if not m then return nil end
	for _, n in ipairs({"HumanoidRootPart","UpperTorso","LowerTorso","Torso","Root","Hip"}) do
		local p = m:FindFirstChild(n)
		if p and p:IsA("BasePart") then return p end
	end
	for _, c in ipairs(m:GetChildren()) do if c:IsA("BasePart") then return c end end
	return nil
end

local chars = WS:FindFirstChild("Characters")
if not chars then warn("MDUEL no Characters"); cleanup(); return end

local lockedTarget, lockedName, lockedDist = nil, "", 0
local function hideAll()
	if bx then bx.Visible = false end; if tx then tx.Visible = false end
	if dt then dt.Visible = false end; if nm then nm.Visible = false end
end

local uiElems, uiVisible, uiReady = {}, true, false
local zDeb, ctrlDeb, fovDeb, smDeb = true, true, true, true
local UI_W, UI_H, pulse, pulseDir = 260, 180, 0, 1

local function makeUI(vs)
	local ok = pcall(function()
		if vs.X < 100 or vs.Y < 100 then return false end
		local x, y = (vs.X-UI_W)/2, 40
		local bg = Drawing.new("Square"); table.insert(allDrawings, bg)
		bg.Filled = true; bg.Color = Color3.fromRGB(10,10,16); bg.Transparency = 0.88; bg.Size = Vector2.new(UI_W,UI_H); bg.Position = Vector2.new(x,y); bg.Thickness = 1.5; bg.ZIndex = 100
		local ln = Drawing.new("Line"); table.insert(allDrawings, ln)
		ln.From = Vector2.new(x,y+32); ln.To = Vector2.new(x+UI_W,y+32); ln.Color = Color3.fromRGB(0,200,255); ln.Thickness = 1; ln.Transparency = 0.5; ln.ZIndex = 101
		local ti = Drawing.new("Text"); table.insert(allDrawings, ti)
		ti.Text = "MDUEL V4"; ti.Size = 18; ti.Color = Color3.fromRGB(0,200,255); ti.Position = Vector2.new(x+12,y+6); ti.Font = 3; ti.Outline = true; ti.ZIndex = 102
		local st = Drawing.new("Text"); table.insert(allDrawings, st)
		st.Text = "ACTIVE"; st.Size = 11; st.Color = Color3.fromRGB(0,255,120); st.Position = Vector2.new(x+UI_W-65,y+11); st.Font = 2; st.Outline = true; st.ZIndex = 102
		local a1 = Drawing.new("Text"); table.insert(allDrawings, a1)
		a1.Text = "Z: Aimbot"; a1.Size = 14; a1.Color = Color3.fromRGB(210,210,240); a1.Position = Vector2.new(x+14,y+42); a1.Font = 2; a1.ZIndex = 102
		local a2 = Drawing.new("Square"); table.insert(allDrawings, a2)
		a2.Size = Vector2.new(14,14); a2.Position = Vector2.new(x+UI_W-28,y+43); a2.Color = Color3.fromRGB(0,255,120); a2.Filled = true; a2.Thickness = 1; a2.ZIndex = 101
		local f1 = Drawing.new("Text"); table.insert(allDrawings, f1)
		f1.Text = "[  ] FOV: "..settings.fov; f1.Size = 13; f1.Color = Color3.fromRGB(190,190,220); f1.Position = Vector2.new(x+14,y+72); f1.Font = 2; f1.ZIndex = 102
		local s1 = Drawing.new("Text"); table.insert(allDrawings, s1)
		s1.Text = "[  ] SMOOTH: "..string.format("%.2f",settings.smooth); s1.Size = 13; s1.Color = Color3.fromRGB(190,190,220); s1.Position = Vector2.new(x+14,y+97); s1.Font = 2; s1.ZIndex = 102
		local r1 = Drawing.new("Text"); table.insert(allDrawings, r1)
		r1.Text = "[  ] RANGE: "..settings.range; r1.Size = 13; r1.Color = Color3.fromRGB(190,190,220); r1.Position = Vector2.new(x+14,y+122); r1.Font = 2; r1.ZIndex = 102
		local h1 = Drawing.new("Text"); table.insert(allDrawings, h1)
		h1.Text = "Ctrl: hide   +/-: FOV   [ ]: smooth"; h1.Size = 10; h1.Color = Color3.fromRGB(90,90,110); h1.Position = Vector2.new(x+14,y+155); h1.Font = 2; h1.ZIndex = 102
		uiElems = {bg,ln,ti,st,a1,a2,f1,s1,r1,h1}
		return true
	end)
	if ok then uiReady = true end
end

local zeroFrames = 0

RunS.RenderStepped:Connect(function()
	pcall(function()
		local cam = WS.CurrentCamera; if not cam then return end
		local vs = cam.ViewportSize

		if not uiReady and vs.X > 100 and vs.Y > 100 then makeUI(vs) end
		pulse = pulse + pulseDir * 1.5
		if pulse >= 360 or pulse <= 0 then pulseDir = -pulseDir end

		if uiVisible and uiReady then
			local hsv = Color3.fromHSV(math.max(0, math.min(360, pulse))/360, 0.75, 1)
			for i,e in ipairs(uiElems) do
				if e then e.Visible = true
					if i==1 then e.Color = hsv end
					if i==2 or i==3 then e.Color = hsv end
				end
			end
			if uiElems[4] then uiElems[4].Text = settings.enabled and "ACTIVE" or "OFF"; uiElems[4].Color = settings.enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,50,50) end
			if uiElems[6] then uiElems[6].Color = settings.enabled and Color3.fromRGB(0,255,120) or Color3.fromRGB(255,50,50) end
			if uiElems[7] then uiElems[7].Text = "[  ] FOV: "..settings.fov end
			if uiElems[8] then uiElems[8].Text = "[  ] SMOOTH: "..string.format("%.2f",settings.smooth) end
			if uiElems[9] then uiElems[9].Text = "[  ] RANGE: "..settings.range end
		elseif uiReady then for _,e in ipairs(uiElems) do if e then e.Visible = false end end end

		if fv then fv.Radius = settings.fov; fv.Position = Vector2.new(vs.X/2, vs.Y/2); fv.Visible = settings.fov>0 and uiVisible end
		if not settings.enabled then hideAll(); return end

		local char = LP.Character
		if not char then hideAll(); lockedTarget = nil; zeroFrames = zeroFrames + 1; return end

		local hrp = findRootPart(char)
		if not hrp then hideAll(); lockedTarget = nil; zeroFrames = zeroFrames + 1
			if zeroFrames == 1 then warn("MDUEL: no root part on local char") end; return end
		zeroFrames = 0

		local keep = false
		if lockedTarget and lockedTarget.Parent then
			if (hrp.Position - lockedTarget.Position).Magnitude <= settings.range then
				keep = true; lockedDist = (hrp.Position - lockedTarget.Position).Magnitude
			end
		end
		if not keep then
			lockedTarget = nil; lockedName = ""
			local best, bdist = nil, HUGE
			local cName = char and char.Name or ""
			-- Method 1: workspace.Characters (custom folder)
			if chars then
				for _, c in chars:GetChildren() do
					if c ~= char and c.Name ~= cName then
						local r = findRootPart(c)
						if r then
							local d = (hrp.Position - r.Position).Magnitude
							if d < settings.range and d < bdist then best, bdist = r, d; lockedName = c.Name end
						end
					end
				end
			end
			-- Method 2: Players:GetPlayers() via v.Character
			for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
				if p ~= LP and p.Character then
					local r = findRootPart(p.Character)
					if r then
						local d = (hrp.Position - r.Position).Magnitude
						if d < settings.range and d < bdist then best, bdist = r, d; lockedName = p.Name end
					end
				end
			end
			-- Method 3: Any HumanoidRootPart in workspace (lobby/non-standard)
			local sm = hrp.Position
			for _, p in ipairs(workspace:GetDescendants()) do
				if p:IsA("BasePart") then
					local nn = p.Name
					if nn == "HumanoidRootPart" or nn == "UpperTorso" or nn == "LowerTorso" or nn == "Torso" or nn == "Root" then
						local m = p.Parent
						if m and m ~= char and m.Name ~= cName then
							local d = (sm - p.Position).Magnitude
							if d < settings.range and d < bdist then best, bdist = p, d; lockedName = m.Name end
						end
					end
				end
			end
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
					if tx then tx.Text=math.floor(lockedDist).."m"; tx.Position=Vector2.new(sp.X,sp.Y-bh/2-18); tx.Visible=true end
					if dt then dt.Position=Vector2.new(sp.X,sp.Y); dt.Visible=true end
					if nm then nm.Text="> "..lockedName; nm.Position=Vector2.new(sp.X,sp.Y+bh/2+4); nm.Visible=true end
				end
			else hideAll() end
		else hideAll(); if fv then fv.Color=Color3.new(1,1,1) end end
	end)
end)

UIS.InputBegan:Connect(function(key, gpe)
	if gpe then return end
	local kc = key.KeyCode
	if (kc == Enum.KeyCode.RightControl or kc == Enum.KeyCode.LeftControl) and ctrlDeb then uiVisible = not uiVisible; ctrlDeb = false
	elseif kc == Enum.KeyCode.Z and zDeb then settings.enabled = not settings.enabled; zDeb = false
	elseif uiVisible and uiReady then
		if kc == Enum.KeyCode.LeftBracket and smDeb then settings.smooth = math.max(0.02, settings.smooth - 0.03); smDeb = false
		elseif kc == Enum.KeyCode.RightBracket and smDeb then settings.smooth = math.min(0.5, settings.smooth + 0.03); smDeb = false
		elseif kc == Enum.KeyCode.Minus and fovDeb then settings.fov = math.max(0, settings.fov - 20); fovDeb = false
		elseif kc == Enum.KeyCode.Equals and fovDeb then settings.fov = math.min(500, settings.fov + 20); fovDeb = false
		end
	end
end)
UIS.InputEnded:Connect(function(key, gpe)
	if gpe then return end
	local kc = key.KeyCode
	if kc == Enum.KeyCode.RightControl or kc == Enum.KeyCode.LeftControl then ctrlDeb = true
	elseif kc == Enum.KeyCode.Z then zDeb = true
	elseif kc == Enum.KeyCode.LeftBracket or kc == Enum.KeyCode.RightBracket then smDeb = true
	elseif kc == Enum.KeyCode.Minus or kc == Enum.KeyCode.Equals then fovDeb = true end
end)

game:BindToClose(function() cleanup() end)
print("MDUEL v4 - Z=aimbot Ctrl=UI [-/+]=FOV [[/]]=smooth range="..settings.range)
