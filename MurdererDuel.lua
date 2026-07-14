-- MDUEL Clean — ESP + Aimbot (modular, independent)
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local PS = game:GetService("Players")

-- Config
local cfg = {
	esp = true,
	aim = true,
	range = 350,
	fov = 200,
	smooth = 0.15,
}

-- Find root part (fallback names)
local function root(m)
	if not m then return nil end
	for _, n in ipairs({"HumanoidRootPart","UpperTorso","LowerTorso","Torso","Root","Hip"}) do
		local p = m:FindFirstChild(n)
		if p and p:IsA("BasePart") then return p end
	end
	for _, c in ipairs(m:GetChildren()) do if c:IsA("BasePart") then return c end end
	return nil
end

-- ESP Drawing management
local espObjs = {}
local function drawClear()
	for _, d in ipairs(espObjs) do pcall(function() d:Remove() end) end
	espObjs = {}
end
local function drawNew(t) local d = Drawing.new(t); table.insert(espObjs, d); return d end

-- ESP per-model state
local espData = {}
local function ensureESP(m)
	if espData[m] then return end
	local e = {
		box = drawNew("Square"),
		name = drawNew("Text"),
		dist = drawNew("Text"),
		hb = drawNew("Square"),
		hl = drawNew("Square"),
	}
	e.box.Thickness = 1; e.box.Filled = false; e.box.Color = Color3.new(1,0,0)
	e.name.Size = 13; e.name.Center = true; e.name.Outline = true; e.name.Color = Color3.new(1,1,1)
	e.dist.Size = 11; e.dist.Center = true; e.dist.Outline = true; e.dist.Color = Color3.new(0.8,0.8,1)
	e.hb.Thickness = 0; e.hb.Filled = true; e.hb.Color = Color3.new(0,1,0)
	e.hl.Thickness = 1; e.hl.Filled = false; e.hl.Color = Color3.new(1,1,1)
	espData[m] = e
end
local function hideESP(m)
	local e = espData[m]
	if e then
		e.box.Visible = false; e.name.Visible = false; e.dist.Visible = false
		e.hb.Visible = false; e.hl.Visible = false
	end
end
local function removeESP(m)
	local e = espData[m]
	if e then
		for _, d in pairs(e) do if typeof(d) == "Drawing" then pcall(function() d:Remove() end) end end
		espData[m] = nil
	end
end

-- Target tracking via events
local targets = {}
local function addTarget(m)
	if not m or m == LP.Character then return end
	if root(m) then targets[m] = true end
end
local function remTarget(m) targets[m] = nil; removeESP(m) end

local chars = WS:FindFirstChild("Characters")
if chars then
	for _, c in chars:GetChildren() do addTarget(c) end
	chars.ChildAdded:Connect(function(c) delay(0.5, function() if c.Parent then addTarget(c) end end) end)
end
for _, p in PS:GetPlayers() do
	if p ~= LP and p.Character then addTarget(p.Character) end
	p.CharacterAdded:Connect(function(m) delay(0.5, function() if m.Parent then addTarget(m) end end) end)
end
PS.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(m) delay(0.5, function() if m.Parent then addTarget(m) end end) end)
end)

-- Aimbot state
local aimTarget, aimName = nil, ""

-- Main loop
RS.RenderStepped:Connect(function()
	pcall(function()
		local cam = WS.CurrentCamera
		if not cam then return end
		local char = LP.Character
		if not char then drawClear(); aimTarget = nil; return end
		local hrp = root(char)
		if not hrp then drawClear(); aimTarget = nil; return end
		local vs = cam.ViewportSize
		local hp = hrp.Position

		local bestAim, bestDist = nil, 1/0

		-- Collect valid targets first (avoid modifying table during pairs)
		local active = {}
		for m in pairs(targets) do
			if m.Parent and root(m) then table.insert(active, m) else targets[m] = nil; removeESP(m) end
		end

		for _, m in ipairs(active) do
			local r = root(m)
			local d = (hp - r.Position).Magnitude
			if d > cfg.range then
				hideESP(m)
			else
				-- ESP
				if cfg.esp then
					ensureESP(m)
					local e = espData[m]
					local sp, on = cam:WorldToViewportPoint(r.Position)
					if on and sp.Z > 0 then
						local head = m:FindFirstChild("Head")
						local top = head and cam:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0)) or Vector2.new(sp.X, sp.Y - 50)
						local bh = math.abs(sp.Y - top.Y) * 1.8
						local bw = bh * 0.6
						e.box.Size = Vector2.new(bw, bh)
						e.box.Position = Vector2.new(sp.X - bw/2, sp.Y - bh/2)
						e.box.Visible = true
						e.name.Text = m.Name
						e.name.Position = Vector2.new(sp.X, sp.Y - bh/2 - 14)
						e.name.Visible = true
						e.dist.Text = math.floor(d) .. "m"
						e.dist.Position = Vector2.new(sp.X, sp.Y + bh/2 + 4)
						e.dist.Visible = true
						local hum = m:FindFirstChildOfClass("Humanoid")
						local pct = hum and math.max(0, math.min(1, hum.Health / hum.MaxHealth)) or 1
						e.hb.Size = Vector2.new(3, bh * pct)
						e.hb.Position = Vector2.new(sp.X - bw/2 - 5, sp.Y + bh/2 - bh * pct)
						e.hb.Color = Color3.new(1 - pct, pct, 0)
						e.hb.Visible = true
						e.hl.Size = Vector2.new(3, bh)
						e.hl.Position = Vector2.new(sp.X - bw/2 - 5, sp.Y - bh/2)
						e.hl.Visible = true
					else
						hideESP(m)
					end
				end

				-- Aimbot candidate
				if cfg.aim and d < bestDist then
					local vp, on = cam:WorldToViewportPoint(r.Position)
					if on and vp.Z > 0 then
						if cfg.fov == 0 or (Vector2.new(vp.X - vs.X/2, vp.Y - vs.Y/2)).Magnitude <= cfg.fov then
							bestAim = r; bestDist = d; aimName = m.Name
						end
					end
				end
			end
		end

		-- Apply aimbot
		aimTarget = bestAim
		if aimTarget then
			cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, aimTarget.Position), cfg.smooth)
		end
	end)
end)

-- Controls
UIS.InputBegan:Connect(function(key, gpe)
	if gpe then return end
	if key.KeyCode == Enum.KeyCode.Z then cfg.aim = not cfg.aim
	elseif key.KeyCode == Enum.KeyCode.X then cfg.esp = not cfg.esp
		if not cfg.esp then drawClear() end
	end
end)

game:BindToClose(function() drawClear() end)
