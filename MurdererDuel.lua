-- MDUEL v2 — Always-on aimbot for Murderer Duel (ignore friends)
local RunS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local LP = game:GetService("Players").LocalPlayer
local Range, FOV = 250, 200

local bx, tx, dt, fv
pcall(function()
	bx = Drawing.new("Square")
	tx = Drawing.new("Text")
	dt = Drawing.new("Circle")
	fv = Drawing.new("Circle")
	fv.Visible = true; fv.Color = Color3.new(1,1,1)
	fv.Transparency = 0.3; fv.Thickness = 1; fv.NumSides = 60; fv.Radius = FOV
end)

local chars = WS:FindFirstChild("Characters")
if not chars then warn("[MDUEL] No Characters folder"); return end

-- Friend check
local friendIds = {}
local function refreshFriends()
	friendIds = {}
	for _, p in game:GetService("Players"):GetPlayers() do
		if p ~= LP and p:IsFriendsWithAsync(LP.UserId) then
			friendIds[p.UserId] = true
		end
	end
end
task.spawn(function() while task.wait(30) do pcall(refreshFriends) end end)
task.spawn(function() task.wait(3); pcall(refreshFriends) end)

RunS.RenderStepped:Connect(function()
	local cam = WS.CurrentCamera; if not cam then return end
	if fv then fv.Position = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2); fv.Visible = FOV>0 end

	local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local target, tdist = nil, math.huge
	for _, c in chars:GetChildren() do
		if c == LP.Character then continue end
		local r = c:FindFirstChild("HumanoidRootPart")
		local h = c:FindFirstChildOfClass("Humanoid")
		if not r or not h or h.Health <= 0 then continue end
		-- Friend check via UserId attribute
		local uid = c:GetAttribute("userId") or c:FindFirstChild("userId")
		if uid and friendIds[tostring(uid.Value or uid)] then continue end
		local d = (hrp.Position - r.Position).Magnitude
		if d < Range and d < tdist then target, tdist = r, d end
	end

	if target then
		local sp, on = cam:WorldToViewportPoint(target.Position)
		if on and sp.Z > 0 then
			local cx, cy = cam.ViewportSize.X/2, cam.ViewportSize.Y/2
			if FOV==0 or (Vector2.new(sp.X-cx,sp.Y-cy).Magnitude) <= FOV then
				cam.CFrame = CFrame.lookAt(cam.CFrame.Position, target.Position)
				if fv then fv.Color = Color3.new(0,1,0) end
			else
				if fv then fv.Color = Color3.new(1,1,1) end
			end
			local head = target.Parent:FindFirstChild("Head")
			if head then
				local hp = cam:WorldToViewportPoint(head.Position+Vector3.new(0,0.5,0))
				local bh = math.abs(sp.Y-hp.Y)*1.8; local bw = bh*0.6
				if bx then bx.Size=Vector2.new(bw,bh); bx.Position=Vector2.new(sp.X-bw/2,sp.Y-bh/2); bx.Visible=true end
				if tx then tx.Text=tostring(tdist).."m"; tx.Position=Vector2.new(sp.X,sp.Y-bh/2-18); tx.Visible=true end
				if dt then dt.Position=Vector2.new(sp.X,sp.Y); dt.Visible=true end
			end
		else
			if bx then bx.Visible=false end; if tx then tx.Visible=false end; if dt then dt.Visible=false end
		end
	else
		if bx then bx.Visible=false end; if tx then tx.Visible=false end; if dt then dt.Visible=false end
		if fv then fv.Color=Color3.new(1,1,1) end
	end
end)

print("[MDUEL] v2 active — friends ignored")
