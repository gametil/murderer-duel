-- RemoteSpy Hooking Core — No freeze, executor-safe (Ketamine/WEAO)
-- Based on richie0866/remote-spy pattern, stripped __namecall hook

local refs = {}

-- Serializer
local function codify(v, lvl)
	lvl = lvl or 0
	local t = typeof(v)
	if t == "string" then
		return string.format("%q", v)
	elseif t == "number" or t == "boolean" then
		return tostring(v)
	elseif t == "Vector3" then
		return string.format("Vector3.new(%.3f, %.3f, %.3f)", v.X, v.Y, v.Z)
	elseif t == "CFrame" then
		local c = v:GetComponents()
		return string.format("CFrame.new(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f)", table.unpack(c))
	elseif t == "Instance" then
		return v:GetFullName()
	elseif t == "table" then
		local parts = {}
		for k, val in pairs(v) do
			table.insert(parts, string.format("[%s]=%s", codify(k, lvl+1), codify(val, lvl+1)))
		end
		return "{" .. table.concat(parts, ", ") .. "}"
	elseif t == "Ray" then
		return string.format("Ray.new(%s, %s)", codify(v.Origin), codify(v.Direction))
	elseif t == "Color3" then
		return string.format("Color3.new(%.3f, %.3f, %.3f)", v.R, v.G, v.B)
	else
		return tostring(v) .. " --[[" .. t .. "]]"
	end
end

-- Hook RemoteEvent.FireServer via its metatable (safer than Instance.new)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()
	
	-- ONLY intercept FireServer on RemoteEvents — nothing else
	if method == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
		local args = { ... }
		local info = {}
		for i = 1, select("#", ...) do
			info[i] = codify(args[i])
		end
		print(string.format("[SPY] %s :: FireServer(%s)", self:GetFullName(), table.concat(info, ", ")))
	end
	
	return oldNamecall(self, ...)
end)

print("[SPY] RemoteSpy active — watching remotes...")
