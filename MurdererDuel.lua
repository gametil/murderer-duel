-- MDUEL v3 - Always-on aimbot (Ketamine-safe)
local RunS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LP = game:GetService("Players").LocalPlayer
local Range, FOV, Smoothness = 250, 200, 0.15

-- Drawing (with nil-guard for executors that lack it)
local bx, tx, dt, fv, nm
if type(Drawing) == "table" and type(Drawing.new) == "function" then
	pcall(function()
		bx = Drawing.new("Square")
		tx = Drawing.new("Text")
		dt = Drawing.new("Circle")
		fv = Drawing.new("Circle")
		nm = Drawing.new("Text")
		fv.Visible = true; fv.Color = Color3.new(1,1,1)
		fv.Transparency = 0.3; fv.Thickness = 1; fv.NumSides = 60; fv.Radius = FOV
		if nm then nm.Size = 14; nm.Center = true; nm.Outline = true; nm.Color = Color3.new(1,1,0) end
	end)
end

local chars = WS:FindFirstChild("Characters")
if not chars then warn("MDUEL no Characters"); return end

-- Friend check (delay instead of task.spawn)
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
	if bx then bx.Visible = false end
	if tx then tx.Visible = false end
	if dt then dt.Visible = false end
	if nm then nm.Visible = false end
end

RunS.RenderStepped:Connect(function()
	pcall(function()
		local cam = WS.CurrentCamera; if not cam then return end
		if fv then fv.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2); fv.Visible = FOV>0 end
		local char = LP.Character; if not char then hideAll(); lockedTarget = nil; return end
		local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then hideAll(); lockedTarget = nil; return end

		-- Check if current lock is still valid
		local keep = false
		if lockedTarget and lockedTarget.Parent then
			local h = lockedTarget.Parent:FindFirstChildOfClass("Humanoid")
			if h and h.Health > 0 and (hrp.Position - lockedTarget.Position).Magnitude <= Range then
				keep = true; lockedDist = (hrp.Position - lockedTarget.Position).Magnitude
			end
		end
		if not keep then
			lockedTarget = nil; lockedName = ""
			local best, bdist = nil, math.huge
			for _, c in chars:GetChildren() do
				if c == char then end -- skip self
				local r = c:FindFirstChild("HumanoidRootPart")
				local h = c:FindFirstChildOfClass("Humanoid")
				if r and h and h.Health > 0 then
					local uid
					local aok = pcall(function() uid = c:GetAttribute("userId") end)
					if not aok or not uid then
						local obj = c:FindFirstChild("userId")
						if obj then uid = obj.Value end
					end
					if not uid or not friendIds[tostring(uid)] then
						local d = (hrp.Position - r.Position).Magnitude
						if d < Range and d < bdist then best, bdist = r, d; lockedName = c.Name end
					end
				end
			end
			if best then lockedTarget = best; lockedDist = bdist end
		end

		if lockedTarget then
			local sp, on = cam:WorldToViewportPoint(lockedTarget.Position)
			if on and sp.Z > 0 then
				if FOV == 0 or Vector2.new(sp.X-cam.ViewportSize.X/2,sp.Y-cam.ViewportSize.Y/2).Magnitude <= FOV then
					cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, lockedTarget.Position), Smoothness)
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

print("MDUEL v3")
